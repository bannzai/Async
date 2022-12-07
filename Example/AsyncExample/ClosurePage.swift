import Async
import SwiftUI

struct ClosurePage: View {
    var body: some View {
        List {
            Section("Use Async Property") {
                UseAsyncPropertyWrapper()
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

            switch async(run).state {
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

            switch asyncWithError(runWithError).state {
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
        AsyncView(run, when: (
            success: { Text($0) },
            failure: { Text($0.errorMessage) },
            loading: { ProgressView().progressViewStyle(.circular) }
        ))
    }
}

@MainActor private func run() async throws -> String {
    return "Done run()"
}

private var i = 0
@MainActor private func runWithError() async throws -> String {
    defer {
        i += 1
    }
    if i % 2 == 0 {
        throw "Error"
    } else {
        return "Done runWithError()"
    }
}
