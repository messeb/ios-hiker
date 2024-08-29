import Foundation

/// An enumeration representing the various states that a view model can be in.
///
/// - initial: the view model is initiated
/// - loading: The view model is in a loading state.
/// - empty: The view model has no data.
/// - data: The view model contains valid data of type `T`.
/// - error: The view model encountered an error.
enum ViewModelState<T> {
    
    /// The initial state of the view model, typically before any data has been requested or operation started.
    case initial
    
    /// Indicates that the view model is currently loading data or performing an operation.
    case loading
    
    /// Represents a state where the operation was successful but no data is available.
    case empty
    
    /// Represents a state where the view model has successfully retrieved data of type `T`.
    ///
    /// - Parameter data: The data of type `T` that the view model has retrieved.
    case data(T)
    
    /// Indicates that the view model encountered an error during an operation.
    ///
    /// - Parameter error: An optional `Error` object that provides details about what went wrong.
    case error(Error?)
}

/// A protocol that provides state handling capabilities for a view model.
///
/// Types conforming to this protocol will have a state property of type `ViewModelState<T>`,
/// and an `update` method to change the state.
///
/// - Note: The conforming type must be a class (`AnyObject`), as state handling is typically
/// used with reference types in view models.
protocol ViewModelStateHandling: AnyObject {
    
    /// The type of data that the view model will handle in its state.
    associatedtype T
    
    /// The current state of the view model.
    var state: ViewModelState<T> { get set }
    
    /// Updates the state of the view model with a new state.
    ///
    /// - Parameter newState: The new state to update to.
    @MainActor func update(newState: ViewModelState<T>)
}

extension ViewModelStateHandling {
    
    /// Updates the state of the view model on the main thread.
    ///
    /// This method provides a default implementation that updates the view model's state
    /// property with the new state. The update is performed on the main actor, ensuring
    /// that any UI-related state changes occur on the main thread.
    ///
    /// - Parameter newState: The new state to update to.
    @MainActor func update(newState: ViewModelState<T>) {
        self.state = newState
    }
}
