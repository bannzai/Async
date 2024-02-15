import Async
import SwiftUI

struct AsyncGroupPage: View {
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
  @Async<String, Error> var asyncWithError1
  @Async<String, Error> var asyncWithError2

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Run basically")

      switch AsyncGroup((
        asyncWithError1(Self.stream()),
        asyncWithError2(Self.throwingStream())
      )).state {
      case .success(let value):
        Text("asyncWithError1:\(value.0)")
        Text("asyncWithError2:\(value.1)")
      case.failure(let error):
        Text("Error: \(error.localizedDescription)")
      case .loading:
        ProgressView()
          .progressViewStyle(.circular)
      }
    }
    .alert(isPresented: .constant(asyncWithError2.error != nil), error: asyncWithError2.error?.toAlertError()) {
      Button("Reload") {
        asyncWithError2.resetState()
      }
    }
  }

  private static func stream() -> AsyncStream<String> {
    .init { continuation in
      continuation.yield("Done 1")
    }
  }

  private static var i = 0
  private static func throwingStream() -> AsyncThrowingStream<String, Error> {
    .init { continuation in
      if i == 0 {
        i += 1
        continuation.finish(throwing: "Error")
      } else {
        continuation.yield("Done 2")
      }
    }
  }
}

