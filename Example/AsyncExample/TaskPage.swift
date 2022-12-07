import Async
import SwiftUI

struct TaskPage: View {
    var body: some View {
        List {
            Section("Use Async Property") {
                UseAsyncPropertyWrapper()
            }
            Section("Use AsyncView") {
                UseAsyncView()
            }
        }
        .listStyle(.grouped)
    }
}

private struct UseAsyncPropertyWrapper: View {
    @Async<String> var async
    @Async<String> var asyncWithError

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Run basically")

            switch async(Self.task()).state {
            case .success(let value):
                Text(value)
            case .failure(let error):
                Text(error.errorMessage)
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }

        VStack(alignment: .leading, spacing: 4) {
            Text("Run with error")

            switch asyncWithError(Self.taskWithError()).state {
            case .success(let value):
                Text(value)
            case .failure(let error):
                Text(error.errorMessage)
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .alert(isPresented: .constant(asyncWithError.error != nil), error: asyncWithError.error?.toAlertError()) {
            Button("Reload") {
                asyncWithError.resetState()
            }
        }
    }

    private static func task() -> Task<String, Error> {
        .init { @MainActor in
            return "Done"
        }
    }

    private static var i = 0
    private static func taskWithError() -> Task<String, Error> {
        .init { @MainActor in
            if i == 0 {
                i += 1
                throw "Error"
            } else {
                return "Done runWithError()"
            }
        }
    }
}

private struct UseAsyncView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Run basically")
            AsyncView(Self.task(), when: (
                success: { Text($0) },
                failure: { Text($0.errorMessage) },
                loading: { ProgressView().progressViewStyle(.circular) }
            ))
        }

        VStack(alignment: .leading, spacing: 4) {
            Text("Run with error")

            AsyncView(Self.taskWithError(), when: (
                success: { Text($0) },
                failure: { Text($0.errorMessage) },
                loading: { ProgressView().progressViewStyle(.circular) }
            ))
        }
    }

    private static func task() -> Task<String, Error> {
        .init { @MainActor in
            return "Done"
        }
    }

    private static var i = 0
    private static func taskWithError() -> Task<String, Error> {
        .init { @MainActor in
            if i == 0 {
                i += 1
                throw "Error"
            } else {
                return "Done runWithError()"
            }
        }
    }
}

