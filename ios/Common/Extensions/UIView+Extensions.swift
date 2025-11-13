//
//  UIView+Extensions.swift
//  ios
//
//  Created by Connor Black on 13/10/2025.
//

import UIKit

@resultBuilder
enum ResultBuilder<T> {
  static func buildBlock(_ components: T...) -> [T] {
    Array(components)
  }
}

extension UIView {
  /// Activates Auto Layout constraints created in the provided closure.
  /// - Parameter constraints: A closure that receives the view and builds constraints to activate.
  /// - Returns: The activated constraints for further customization if needed.
  /// - Note: Automatically sets `translatesAutoresizingMaskIntoConstraints = false`.
  @discardableResult
  func activateConstraints(
    @ResultBuilder<NSLayoutConstraint> _ constraints: (UIView) -> [NSLayoutConstraint]
  )
    -> [NSLayoutConstraint]
  {
    translatesAutoresizingMaskIntoConstraints = false
    let constraintsToActivate = constraints(self)
    NSLayoutConstraint.activate(constraintsToActivate)
    return constraintsToActivate
  }

  /// Pins the view to the leading, trailing, top, and bottom anchors of the specified superview.
  /// - Parameters:
  ///   - superview: The superview to pin to. If `nil`, uses `self.superview`.
  ///   - insets: Optional insets for the constraints. Defaults to `.zero`.
  /// - Returns: The activated constraints for further customization if needed.
  @discardableResult
  func pinToEdges(
    of superview: UIView? = nil,
    insets: UIEdgeInsets = .zero
  ) -> [NSLayoutConstraint] {
    guard let superview = superview ?? self.superview else {
      fatalError("View must have a superview or one must be provided")
    }

    translatesAutoresizingMaskIntoConstraints = false

    let constraints = [
      topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
      leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
      trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
      bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom),
    ]

    NSLayoutConstraint.activate(constraints)
    return constraints
  }
}
