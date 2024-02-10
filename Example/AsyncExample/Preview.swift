import Async
import SwiftUI

private struct UseAsyncPropertyWrapper: View {
  @Async<String, Never> var async
  @Async<String, Error> var asyncWithError

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Run basically")

      switch async(Self.stream()).state {
      case .success(let value):
        Text(value)
      case .loading:
        ProgressView()
          .progressViewStyle(.circular)
      }
    }

    VStack(alignment: .leading, spacing: 4) {
      Text("Run with error")

      switch asyncWithError(Self.throwingStream()).state {
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

  private static func stream() -> AsyncStream<String> {
    .init { continuation in
      continuation.yield("Done")
    }
  }

  private static var i = 0
  private static func throwingStream() -> AsyncThrowingStream<String, Error> {
    .init { continuation in
      if i == 0 {
        i += 1
        continuation.finish(throwing: "Error")
      } else {
        continuation.yield("Done")
      }
    }
  }
}

private struct UseAsyncView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Run basically")
      AsyncView(Self.stream(), when: (
        success: { Text($0) },
        loading: { ProgressView().progressViewStyle(.circular) }
      ))
    }

    VStack(alignment: .leading, spacing: 4) {
      Text("Run with error")

      AsyncView(Self.throwingStream(), when: (
        success: { Text($0) },
        failure: { Text($0.errorMessage) },
        loading: { ProgressView().progressViewStyle(.circular) }
      ))
    }
  }

  private static func stream() -> AsyncStream<String> {
    .init { continuation in
      continuation.yield("Done")
    }
  }

  private static var i = 0
  private static func throwingStream() -> AsyncThrowingStream<String, Error> {
    .init { continuation in
      if i == 0 {
        i += 1
        continuation.finish(throwing: "Error")
      } else {
        continuation.yield("Done")
      }
    }
  }
}


#Preview {
  UseAsyncPropertyWrapper(
    async: .init(forPreviewState: .success("value")),
    asyncWithError: .init(forPreviewState: .success("value2"))
  )
}
