import SwiftUI

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
