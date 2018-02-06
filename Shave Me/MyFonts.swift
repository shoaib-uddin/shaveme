//
//  MyFonts.swift
//  Shave Me
//
//  Created by NoorAli on 1/16/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit

extension UIFont {
    static func logoFont(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Franchise-Bold", size: fontSize)!
    }
    
    static func normalArabicFont(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "GEDinarOne-Light", size: fontSize)!
    }
    
    static func mediumArabicFont(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "GEDinarOne-Medium", size: fontSize)!
    }
    
    static func boldArabicFont(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "GESSTwoBold-Bold", size: fontSize)!
    }
    
    static func lightArabicFont(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "GEDinarTwo-Light", size: fontSize)!
    }
    
    static func lightEnglishFont(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Light", size: fontSize)!
    }
    
    static func boldEnglishFont(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Bold", size: fontSize)!
    }
    
    static func normalEnglishFont(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Regular", size: fontSize)!
    }
    
    static func mediumEnglishFont(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Medium", size: fontSize)!
    }
}
