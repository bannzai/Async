import Async
import SwiftUI

struct ClosurePage: View {
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

      switch async(Self.run).state {
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

      switch asyncWithError(Self.runWithError).state {
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

  @Sendable private static func run() async throws -> String {
    return "Done run()"
  }

  private static var i = 0
  @Sendable private static func runWithError() async throws -> String {
    if i == 0 {
      i += 1
      throw "Error"
    } else {
      return "Done runWithError()"
    }
  }
}

private struct UseAsyncView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Run basically")
      AsyncView(Self.run, when: (
        success: { Text($0) },
        failure: { Text($0.errorMessage) },
        loading: { ProgressView().progressViewStyle(.circular) }
      ))
    }

    VStack(alignment: .leading, spacing: 4) {
      Text("Run with error")

      AsyncView(Self.runWithError, when: (
        success: { Text($0) },
        failure: { Text($0.errorMessage) },
        loading: { ProgressView().progressViewStyle(.circular) }
      ))
    }
  }

  @Sendable private static func run() async throws -> String {
    return "Done run()"
  }

  private static var i = 0
  @Sendable private static func runWithError() async throws -> String {
    if i == 0 {
      i += 1
      throw "Error"
    } else {
      return "Done runWithError()"
    }
  }
}
