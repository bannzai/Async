import Async
import SwiftUI

struct StreamPage: View {
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

            switch async(stream()).state {
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

            switch asyncWithError(throwingStream()).state {
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
            AsyncView(stream(), when: (
                success: { Text($0) },
                failure: { Text($0.errorMessage) },
                loading: { ProgressView().progressViewStyle(.circular) }
            ))
        }

        VStack(alignment: .leading, spacing: 4) {
            Text("Run with error")

            AsyncView(throwingStream(), when: (
                success: { Text($0) },
                failure: { Text($0.errorMessage) },
                loading: { ProgressView().progressViewStyle(.circular) }
            ))
        }
    }
}

private func stream() -> AsyncStream<String> {
    .init { continuation in
        continuation.yield("Done")
    }
}

private var i = 0
private func throwingStream() -> AsyncThrowingStream<String, Error> {
    .init { continuation in
        defer {
            i += 1
        }
        if i == 0 {
            continuation.finish(throwing: "Error")
        } else {
            continuation.yield("Done")
        }
    }
}
