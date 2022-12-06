import SwiftUI

public class _Async<T>: ObservableObject {
    public enum State {
        case success(T)
        case failure(Error)
        case loading
    }

    internal enum Action {
        case task(Task<T, Error>)
        case action(() async throws -> T)
        case stream(AsyncStream<T>)
        case throwingStream(AsyncThrowingStream<T, Error>)
    }

    @Published public var state: State = .loading
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

    @discardableResult public func callAsFunction(_ task: Task<T, Error>) -> Self {
        guard case .loading = state else {
            return self
        }

        if executingTask?.isCancelled == false {
            executingTask?.cancel()
        }
        executingTask = Task { @MainActor in
            do {
                let value = try await task.value
                self.state = .success(value)
            } catch {
                self.state = .failure(error)
            }
        }

        return self
    }

    @discardableResult public func callAsFunction(_ action: @escaping () async throws -> T) -> Self {
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

    @discardableResult public func callAsFunction(_ stream: AsyncStream<T>) -> Self {
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

    @discardableResult public func callAsFunction(_ throwingStream: AsyncThrowingStream<T, Error>) -> Self {
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
                self.state = .failure(error)
            }
        }

        return self
    }


    @discardableResult internal func callAsFunction(_ action: Action) -> Self {
        switch action {
        case .task(let task):
            return callAsFunction(task)
        case .action(let action):
            return callAsFunction(action)
        case .stream(let stream):
            return callAsFunction(stream)
        case .throwingStream(let throwingStream):
            return callAsFunction(throwingStream)
        }
    }
}

@propertyWrapper
public struct Async<T>: DynamicProperty {
    public typealias State = _Async<T>.State

    @StateObject var async: _Async<T> = .init()

    public init() {
        debugPrint("Async", #function)
    }

    public var wrappedValue: State { async.state }

    public var projectedValue: _Async<T> { async }
}

public struct AsyncView<T, S: View, F: View, L: View>: View {
    public typealias When = (success: (T) -> S, failure: (Error) -> F, loading: () -> L)

    let action: _Async<T>.Action
    let when: When

    public init(_ task: Task<T, Error>, when: When) {
        self.action = .task(task)
        self.when = when
    }

    public init(_ action: @escaping () async throws -> T, when: When) {
        self.action = .action(action)
        self.when = when
    }

    public init(_ stream: AsyncStream<T>, when: When) {
        self.action = .stream(stream)
        self.when = when
    }

    public init(_ throwingStream: AsyncThrowingStream<T, Error>, when: When) {
        self.action = .throwingStream(throwingStream)
        self.when = when
    }

    @Async<T> var async

    public var body: some View {
        switch $async(action).state {
        case .success(let value):
            when.success(value)
        case .failure(let error):
            when.failure(error)
        case .loading:
            when.loading()
        }
    }
}
