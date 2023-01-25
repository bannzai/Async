import SwiftUI

/// `AsyncView` is convenience build View with async task.
/// Sutable for expressing the three states of `success`, `failure` and `loading`.
///
/// Example:
/// ```swift
/// struct ContentView: View {
///   var body: some View {
///     AsyncView(run, when: (
///       success: { Text("\($0)") },
///       failure: { Text($0.localizedDescription) },
///       loading: { ProgressView() }
///     ))
///   }
/// }
/// ```
///
public struct AsyncView<T, E: Error, S: View, F: View, L: View>: View {
  public typealias When = (success: (T) -> S, failure: (E) -> F, loading: () -> L)

  let action: _Async<T, E>.Action
  let when: When

  public init(_ task: Task<T, E>, when: When) {
    self.action = .task(task)
    self.when = when
  }

  public init(_ action: @escaping @Sendable () async throws -> T, when: When) where E == Error {
    self.action = .task(.init(operation: action))
    self.when = when
  }

  public init(_ stream: AsyncStream<T>, when: When) where E == Never {
    self.action = .stream(stream)
    self.when = when
  }

  public init(_ throwingStream: AsyncThrowingStream<T, E>, when: When) {
    self.action = .throwingStream(throwingStream)
    self.when = when
  }

  @Async<T, E> var async

  public var body: some View {
    switch async(action).state {
    case .success(let value):
      when.success(value)
    case .failure(let error):
      when.failure(error)
    case .loading:
      when.loading()
    }
  }
}
