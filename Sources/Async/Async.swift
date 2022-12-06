import SwiftUI

public class AsyncValue<T>: ObservableObject {
    public enum State {
        case success(T)
        case failure(Error)
        case loading
    }

    @Published public var state: State = .loading
    public init() {

    }

    @discardableResult public func callAsFunction(_ task: Task<T, Error>) -> Self {
        state = .loading

        Task {
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
        state = .loading

        Task {
            do {
                let value = try await action()
                self.state = .success(value)
            } catch {
                self.state = .failure(error)
            }
        }

        return self
    }
}

@propertyWrapper
public struct Async<T>: DynamicProperty {
    @StateObject var async: AsyncValue<T> = .init()

    public init() {

    }

    public var wrappedValue: AsyncValue<T>.State { async.state }

    public var projectedValue: AsyncValue<T> { async }
}

public struct AsyncView<T>: View {
    @StateObject var async = AsyncValue<T>()

    public init(_ task: Task<T, Error>) {
        async(task)
    }

    public init(_ action: @escaping () async throws -> T) {
        async(action)
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
            await run()
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
    @Async<Int> var async

    var body: some View {
        switch $async(run).state {
        case .success(let value):
            Text("\(value)")
        case .failure(let error):
            Text(error.localizedDescription)
        case .loading:
            ProgressView()
        }
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
