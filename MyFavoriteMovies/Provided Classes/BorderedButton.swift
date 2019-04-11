//
//  BorderedButton.swift
//  MyFavoriteMovies
//
//  Created by Geek on 3/9/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import UIKit

class BorderedButton: UIButton{
    let darkerBlue = UIColor(red: 0.0, green: 0.298, blue: 0.686, alpha: 1.0)
    let lighterBlue = UIColor(red: 0.0, green: 0.502, blue: 0.839, alpha: 1.0)
    let titleLabelFontSize: CGFloat = 17.0
    let borderButtonHeight: CGFloat = 44.0
    let borderButtonCornerRadius: CGFloat = 4.0
    let phoneBorderedButtonExtraPadding: CGFloat = 14.0
    
    var backingColor: UIColor? = nil
    var highlightedBackingColor: UIColor? = nil
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        themeBorderedButton()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        themeBorderedButton()
    }
    private func themeBorderedButton(){
        layer.masksToBounds = true
        layer.cornerRadius = borderButtonCornerRadius
        highlightedBackingColor = darkerBlue
        backingColor = lighterBlue
        backgroundColor = lighterBlue
        setTitleColor(.white, for: UIControl.State())
        titleLabel?.font = UIFont.systemFont(ofSize: titleLabelFontSize)
    }
    private func setBackingColor(_ newBackingColor: UIColor){
        if let _ = backingColor{
            backingColor = newBackingColor
            backgroundColor = newBackingColor
        }
    }
    private func setHighlightedBackingColor(_ newHighlightedBackingColor: UIColor){
        highlightedBackingColor = newHighlightedBackingColor
        backingColor = highlightedBackingColor
    }
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        backgroundColor = highlightedBackingColor
        return true
    }
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        backgroundColor = backingColor
    }
    override func cancelTracking(with event: UIEvent?) {
        backgroundColor = backingColor
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let extraButtonPadding: CGFloat = phoneBorderedButtonExtraPadding
        var sizeThatFits = CGSize.zero
        sizeThatFits.width = super.sizeThatFits(size).width + extraButtonPadding
        sizeThatFits.height = borderButtonHeight
        return sizeThatFits
    }
}
