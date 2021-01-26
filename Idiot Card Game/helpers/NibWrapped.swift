//
//  NibWrapped.swift
//  Idiot Card Game
//
//  Created by Mitchell Rust on 1/11/21.
//

import UIKit

// Property wrapper used to wrapp a view instanciated from a Nib
@propertyWrapper public struct NibWrapped<T: UIView> {
    
    // Initializer
    //
    // - Parameter type: Type of the wrapped view
    public init(_ type: T.Type) { }
    
    // The wrapped value
    public var wrappedValue: UIView!
    
    // The final view
    public var unwrapped: T { (wrappedValue as! NibWrapperView<T>).contentView }
}
