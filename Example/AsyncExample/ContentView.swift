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

struct UserView3: View {
  @Async<User, Error> var async

  var body: some View {
    switch async(fetch).state {
    case .success(let user):
      Text(user.name)
    case .failure(let error):
      ErrorPage(error: error)
    case .loading:
      ProgressView()
    }
  }

  @Sendable private func fetch() async throws -> User {
    try await apiClient.fetch(path: "user")
  }
}

struct UserView4: View {
  var body: some View {
    AsyncView(fetch, when: (
      success: { user in
        Text(user.name)
      },
      failure: { error in
        ErrorPage(error: error)
      },
      loading: {
        ProgressView()
      }
    ))
  }

  @Sendable private func fetch() async throws -> User {
    try await apiClient.fetch(path: "user")
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

let apiClient = APIClient()
final class UserViewModel: ObservableObject {
  @Published var user: User?
  @Published var error: Error?

  func fetch() {
    Task { @MainActor in
      do {
        user = try await apiClient.fetch(path: "user")
      } catch {
        self.error = error
      }
    }
  }
}

struct UserView2: View {
  @StateObject var viewModel = UserViewModel()

  var body: some View {
    Group {
      if let user = viewModel.user {
        Text(user.name)
      } else if let error = viewModel.error {
        ErrorPage(error: error)
      } else {
        ProgressView()
      }
    }
    .onAppear {
      viewModel.fetch()
    }
  }
}

struct UserView: View {
  @State var user: User?
  @State var error: Error?

  var body: some View {
    Group {
      if let user {
        Text(user.name)
      } else if let error {
        ErrorPage(error: error)
      } else {
        ProgressView()
      }
    }
    .task {
      await fetch()
    }
  }

  private func fetch() async {
    do {
      user = try await apiClient.fetch(path: "user")
    } catch {
      self.error = error
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
