import SwiftUI
import Async

struct ContentView: View {
  var body: some View {
    List {
      NavigationLink("Task") {
        TaskPage()
      }
      NavigationLink("Closure") {
        ClosurePage()
      }
      NavigationLink("Stream") {
        StreamPage()
      }
    }
    .listStyle(.plain)
    .padding()
  }
}

struct User: Identifiable, Codable {
  let id: String
  let name: String
}
class APIClient {
  func fetch<T: Codable>(path: String) async throws -> T {
    fatalError()
  }
}

struct ErrorPage: View {
  let error: Error
  var body: some View { fatalError() }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
