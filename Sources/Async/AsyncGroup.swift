import SwiftUI

/// `AsyncGroup` can group `@Async` to manage state for each async state..
///
/// Example:
/// ```swift
/// struct ContentView: View {
///   @Async<String, Error> var async1
///   @Async<String, Error> var async2
///
///   var body: some View {
///     switch AsyncGroup(async1(run1), async2(run2)).state {
///     case .success(let value1, let value2):
///       Text("\(value1):\(value2)")
///     case .failure(let error):
///       Text(error.localizedDescription)
///     case .loading:
///       ProgressView()
///     }
///   }
/// }
/// ```
///
public struct AsyncGroup<each U, E: Error> {
  internal let asyncGroup: (repeat _Async<each U, E>)

  public init(_ asyncGroup: (repeat _Async<each U, E>)) {
    self.asyncGroup = asyncGroup
  }

  public var state: _Async<(repeat each U), E>.State {
    if let value {
      return .success(value)
    }
    if let error {
      // FIXME: safe cast
      return .failure(error as! E)
    }
    return .loading
  }

  // MARK: - Convenience accessor
  /// Retrieve value from a each async`state` when all async task is already success.
  public var value: (repeat each U)? {
    func extractValue<A>(async: _Async<A, E>) throws -> A {
      if case let .success(value) = async.state {
        return value
      }
      throw UtilError()
    }

    do {
      return (repeat try extractValue(async: (each asyncGroup)))
    } catch {
      return nil
    }
  }
  private struct UtilError: Error {

  }

  /// Retrieve error from a each async `state` when any async task is failure.
  public var error: Error? {
    var captureError: E?
    func extractError<A>(async: _Async<A, E>) {
      if captureError != nil {
        return
      }

      if case let .failure(error) = async.state {
        captureError = error
      }
    }

    (repeat extractError(async: (each asyncGroup)))
    
    return captureError
  }

  /// isLoading is true means any async task is not yet execute.
  public var isLoading: Bool {
    var captureIsLoading: Bool = false
    func extractIsLoading<A>(async: _Async<A, E>) {
      if captureIsLoading {
        return
      }
      
      if case .loading = async.state {
        captureIsLoading = true
      }
    }

    (repeat extractIsLoading(async: (each asyncGroup)))

    return captureIsLoading
  }

  /// Reset to .loading state.
  /// NOTE: After reset state, published change value to `View` and  revaluate View `body`.
  public func resetState() {
    func callResetState<A>(async: _Async<A, E>) {
      async.resetState()
    }
    repeat callResetState(async: (each asyncGroup))
  }
}

