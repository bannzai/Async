import SwiftUI

@Observable public class AsyncGroup<each U, E: Error> {
  internal let asyncGroup: (repeat _Async<each U, E>)

  public init(_ asyncGroup: (repeat _Async<each U, E>)) {
    self.asyncGroup = asyncGroup
  }

  private struct UtilError: Error {

  }

  // MARK: - Convenience accessor

  /// Retrieve value from a `state` when async task is already success.
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
  /// Retrieve error from a `state` when async task is failure.
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

  /// isLoading is true means task is not yet execute.
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
