//
//  OtherPlayerView.swift
//  Idiot Card Game
//
//  Created by Mitchell Rust on 1/10/21.
//

import UIKit

@IBDesignable class OtherPlayerViewWrapper : NibWrapperView<OtherPlayerView> { }

class OtherPlayerView: UIView {

    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var pile1ImageView: UIImageView!
    @IBOutlet weak var pile2ImageView: UIImageView!
    @IBOutlet weak var pile3ImageView: UIImageView!    
}
