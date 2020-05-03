//
//  utilities.swift
//  IndexCards
//
//  Created by James Lambert on 02/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import UIKit

extension String {
    func attributedText() -> NSAttributedString{
        
        let font = UIFontMetrics.default.scaledFont(
            for: UIFont.preferredFont(forTextStyle: .body))
        
        let attributedString = NSAttributedString(
            string: self,
            attributes: [.font : font])
        
        return attributedString
    }
}
