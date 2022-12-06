import SwiftUI

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
            NavigationLink("ThrowingStream") {
                ThrowingStreamPage()
            }
        }
        .listStyle(.plain)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
