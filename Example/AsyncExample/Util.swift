import Foundation

extension String: Error {}

struct AlertError: LocalizedError {
    let underlyingError: Error

    var errorDescription: String? {
        underlyingError.localizedDescription
    }
}

extension Error {
    var errorMessage: String {
        if let message = self as? String {
            return message
        }
        return localizedDescription
    }

    func toAlertError() -> AlertError {
        .init(underlyingError: self)
    }
}
