# Async
**Async** is a easily handle async state and simple state management library for `SwiftUI`.

## Features
In the **Async** philosophy the asynchronous state is seen as divided into three parts. One is `success`. The other is `failure`. Finally, the `loading` state before execute async function.
Async is provided two way for async state management named `@Async` property wrapper and `AsyncView`. These two structures are used separately and simplify the division of the three states. They essentially have the same function, but can be used in different usecase. 

## Example

1. Use `@Async`.
First, Define `@Async` with state type. The code example below refers to a `String`.
Next, `async` call as function with asynchronous function. The code example below refers to a `run` function and can chain to access async state for switching decide view for each async state.
This method also allows access to `async.state` and the use of `alert(isPresented:error:actions)` modifier with `async.error`. See `Example` for more information.

```swift
struct ContentView: View {
  @Async<String> var async

  var body: some View {
    switch async(run).state {
    case .success(let value):
      Text("\(value)")
    case .failure(let error):
      Text(error.localizedDescription)
    case .loading:
      ProgressView()
    }
  }
}
```

2. Use `AsyncView`.
Pass async function directly to `AsyncView` initializer, and define three states view via `when`.

```swift
struct ContentView: View {
  var body: some View {
    AsyncView(run, when: (
      success: { Text("\($0)") },
      failure: { Text($0.localizedDescription) },
      loading: { ProgressView() }
    ))
  }
}
```

## LICENSE
Teapot is released under the MIT license. See LICENSE for details.
