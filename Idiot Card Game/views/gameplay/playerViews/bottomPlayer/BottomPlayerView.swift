//
//  BottomPlayerView.swift
//  Idiot Card Game
//
//  Created by Mitchell Rust on 1/14/21.
//

import UIKit

@IBDesignable class BottomPlayerViewWrapper : NibWrapperView<BottomPlayerView> { }

class BottomPlayerView: UIView {

    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var pile1ImageView: UIImageView!
    @IBOutlet weak var pile2ImageView: UIImageView!
    @IBOutlet weak var pile3ImageView: UIImageView!
    @IBOutlet weak var handCollectionView: UICollectionView!
    
}
