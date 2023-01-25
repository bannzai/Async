import SwiftUI

/// `_Async` is management state and published current state for async action. And execute passed async action for call as function.
public class _Async<T, E: Error>: ObservableObject {
  /// `_Async.State` is presenting all state of `Async`.
  public enum State {
    case success(T)
    case failure(E)
    case loading
  }

  /// `_Async.Action` is presenting supported Action.
  internal enum Action {
    case task(Task<T, E>)
    case stream(AsyncStream<T>)
    case throwingStream(AsyncThrowingStream<T, E>)
  }

  /// `state` is `loading` first.  after call `callAsFunction`, state changed to success or failure.
  @Published public private(set) var state: State = .loading
  internal var executingTask: Task<Void, Never>?

  public init() {
    debugPrint("_Async", #function)
  }

  deinit {
    debugPrint("_Async", #function)

    if executingTask?.isCancelled == false {
      executingTask?.cancel()
    }
  }

  // MARK: - Call As Function
  @discardableResult public func callAsFunction(_ task: Task<T, E>) -> Self {
    guard case .loading = state else {
      return self
    }

    if executingTask?.isCancelled == false {
      executingTask?.cancel()
    }
    executingTask = Task { @MainActor in
        let result = await task.result
        switch result {
        case .failure(let e):
            self.state = .failure(e)
        case .success(let value):
            self.state = .success(value)
        }
    }

    return self
  }

  @discardableResult public func callAsFunction(_ action: @escaping @Sendable () async throws -> T) -> Self where E == Error {
    guard case .loading = state else {
      return self
    }

    if executingTask?.isCancelled == false {
      executingTask?.cancel()
    }
    executingTask = Task { @MainActor in
      do {
        let value = try await action()
        self.state = .success(value)
      } catch {
        self.state = .failure(error)
      }
    }

    return self
  }

  @discardableResult public func callAsFunction(_ stream: AsyncStream<T>) -> Self where E == Never {
    guard case .loading = state else {
      return self
    }

    if executingTask?.isCancelled == false {
      executingTask?.cancel()
    }
    executingTask = Task { @MainActor in
      for await element in stream {
        self.state = .success(element)
      }
    }

    return self
  }

  @discardableResult public func callAsFunction(_ throwingStream: AsyncThrowingStream<T, E>) -> Self {
    guard case .loading = state else {
      return self
    }

    if executingTask?.isCancelled == false {
      executingTask?.cancel()
    }
    executingTask = Task { @MainActor in
      do {
        for try await element in throwingStream {
          self.state = .success(element)
        }
      } catch {
        // FIXME: safe cast
        self.state = .failure(error as! E)
      }
    }

    return self
  }

  @_disfavoredOverload @discardableResult internal func callAsFunction(_ action: Action) -> Self {
    switch action {
    case .task(let task):
      return callAsFunction(task)
    case .throwingStream(let throwingStream):
      return callAsFunction(throwingStream)
    case .stream:
      fatalError(".action or .stream can't call this function")
    }
  }

  @discardableResult internal func callAsFunction(_ action: Action) -> Self where E == Never {
    switch action {
    case .task(let task):
      return callAsFunction(task)
    case .stream(let stream):
      return callAsFunction(stream)
    case .throwingStream(let throwingStream):
      return callAsFunction(throwingStream)
    }
  }


  // MARK: - Convenience accessor

  /// Retrieve value from a `state` when async task is already success.
  public var value: T? {
    if case let .success(value) = state {
      return value
    }
    return nil
  }
  /// Retrieve error from a `state` when async task is failure.
  public var error: Error? {
    if case let .failure(error) = state {
      return error
    }
    return nil
  }
  /// isLoading is true means task is not yet execute.
  public var isLoading: Bool {
    if case .loading = state {
      return true
    }
    return false
  }

  /// Reset to .loading state.
  /// NOTE: After reset state, published change value to `View` and  revaluate View `body`.
  public func resetState() {
    state = .loading
  }
}

/// `Async` is a wrapped `_Async`. Basically usage to define with `@Async` for property in SwiftUI.View instead of @StateObject or @ObservedObject.
///
/// Example:
/// struct ContentView2: View {
///   @Async<Int> var async
///
/// ```swift
/// struct ContentView: View {
///   @Async<String> var async
///
///   var body: some View {
///     switch async(run).state {
///     case .success(let value):
///       Text("\(value)")
///     case .failure(let error):
///       Text(error.localizedDescription)
///     case .loading:
///       ProgressView()
///     }
///   }
/// }
/// ```
///
@propertyWrapper public struct Async<T, E: Error>: DynamicProperty {
  @StateObject var async: _Async<T, E> = .init()

  public init() {
    debugPrint("Async", #function)
  }

  /// Basically to use call as function or access to `_Async` properties other than `state`. E.g) value, error, isLoading
  public var wrappedValue: _Async<T, E> { async }
}
