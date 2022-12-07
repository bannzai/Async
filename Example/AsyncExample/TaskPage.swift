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

            switch async(AsyncExample.task()).state {
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

            switch asyncWithError(taskWithError()).state {
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
}

private struct UseAsyncView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Run basically")
            AsyncView(AsyncExample.task(), when: (
                success: { Text($0) },
                failure: { Text($0.errorMessage) },
                loading: { ProgressView().progressViewStyle(.circular) }
            ))
        }

        VStack(alignment: .leading, spacing: 4) {
            Text("Run with error")

            AsyncView(taskWithError(), when: (
                success: { Text($0) },
                failure: { Text($0.errorMessage) },
                loading: { ProgressView().progressViewStyle(.circular) }
            ))
        }
    }
}

private func task() -> Task<String, Error> {
    .init { @MainActor in
        return "Done"
    }
}

private var i = 0
private func taskWithError() -> Task<String, Error> {
    .init { @MainActor in
        defer {
            i += 1
        }
        if i == 0 {
            throw "Error"
        } else {
            return "Done runWithError()"
        }
    }
}
