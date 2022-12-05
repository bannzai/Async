import SwiftUI

public class AsyncValue<T>: ObservableObject {
    public enum State {
        case success(T)
        case failure(Error)
        case loading
    }
    @Published public var state: State

    public init(_ task: Task<T, Error>) {
        state = .loading

        Task {
            do {
                let value = try await task.value
                self.state = .success(value)
            } catch {
                self.state = .failure(error)
            }
        }
    }

    public init(_ action: @escaping @Sendable () async throws -> T) {
        state = .loading

        Task {
            do {
                let value = try await action()
                self.state = .success(value)
            } catch {
                self.state = .failure(error)
            }
        }
    }
}

public struct AsyncView<T>: View {
    @StateObject var async: AsyncValue<T>

    public init(_ task: Task<T, Error>) {
        _async = StateObject(wrappedValue: .init(task))
    }

    public init(_ action: @escaping @Sendable () async throws -> T) {
        _async = StateObject(wrappedValue: .init(action))
    }

    public var body: some View {
        self
    }

    @ViewBuilder public func when<S: View, F: View, L: View>(success: (T) -> S, failure: (Error) -> F, loading: () -> L) -> some View {
        switch async.state {
        case .success(let value):
            success(value)
        case .failure(let error):
            failure(error)
        case .loading:
            loading()
        }
    }
}

struct Test: View {
    var body: some View {
        AsyncView {
            return await run()
        }
        .when(
            success: { value in
                Text("\(value)")
            },
            failure: { error in
                Text(error.localizedDescription)
            },
            loading: {
                ProgressView()
            }
        )
    }

    func run() async -> Int {
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        } catch {
            // Ignore
        }
        return 1
    }
}

struct Test2: View {
    @StateObject var async: AsyncValue<Int> = .init {
        <#code#>
    }
    var body: some View {

    }
}
