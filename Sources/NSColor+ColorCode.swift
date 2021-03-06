//
//  NSColor+ColorCode.swift
//
//  Created by 1024jp on 2014-04-22.

/*
 The MIT License (MIT)
 
 Copyright (c) 2014-2016 1024jp
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import Foundation
import AppKit.NSColor

public enum ColorCodeType: Int {
    
    /// Color code is invalid.
    case invalid
    
    /// 6-digit hexadecimal color code with # symbol. For example: `#ffffff`
    case hex
    
    /// 3-digit hexadecimal color code with # symbol. For example: `#fff`
    case shortHex
    
    /// CSS style color code in RGB. For example: `rgb(255,255,255)`
    case cssRGB
    
    /// CSS style color code in RGB with alpha channel. For example: `rgba(255,255,255,1)`
    case cssRGBa
    
    /// CSS style color code in HSL. For example: `hsl(0,0%,100%)`
    case cssHSL
    
    /// CSS style color code in HSL with alpha channel. For example: `hsla(0,0%,100%,1)`
    case cssHSLa
    
    /// CSS style color code with keyrowd. For example: `White`
    case cssKeyword
}



/**
 This extension on NSColor allows creating NSColor instance from a CSS color code string, or color code string from a NSColor instance.
 */
public extension NSColor {
    
    /**
     Creates and returns a `NSColor` object using the given color code. Or returns `nil` if color code is invalid.
     
     Example usage:
     ```
     var colorCodeType: WFColorCodeType = .invalid
     let whiteColor = NSColor(colorCode: "hsla(0,0%,100%,0.5)", codeTypfe: &colorCodeType)
     let hex = whiteColor.colorCode(type: .hex)  // => "#ffffff"
     ```
     
     - parameter colorCode:  The CSS3 style color code string. The given code as hex or CSS keyword is case insensitive.
     - parameter type:       Upon return, contains the detected color code type.
     - returns:              The color object.
     */
    public convenience init?(colorCode: String, type: UnsafeMutablePointer<ColorCodeType>? = nil) {
        
        let code = colorCode.trimmingCharacters(in: .whitespacesAndNewlines)
        let codeRange = NSRange(location: 0, length: code.utf16.count)
        
        let patterns: [ColorCodeType : String] = [
            .hex: "^#[0-9a-fA-F]{6}$",
            .shortHex: "^#[0-9a-fA-F]{3}$",
            .cssRGB: "^rgb\\( *([0-9]{1,3}) *, *([0-9]{1,3}) *, *([0-9]{1,3}) *\\)$",
            .cssRGBa: "^rgba\\( *([0-9]{1,3}) *, *([0-9]{1,3}) *, *([0-9]{1,3}) *, *([0-9.]+) *\\)$",
            .cssHSL: "^hsl\\( *([0-9]{1,3}) *, *([0-9.]+)% *, *([0-9.]+)% *\\)$",
            .cssHSLa: "^hsla\\( *([0-9]{1,3}) *, *([0-9.]+)% *, *([0-9.]+)% *, *([0-9.]+) *\\)$",
            .cssKeyword: "^[a-zA-Z]+$",
            ]
        
        // detect code type
        var detectedCodeType: ColorCodeType = .invalid
        var result: NSTextCheckingResult!
        for (key, pattern) in patterns {
            let regex = try! NSRegularExpression(pattern: pattern)
            let matches = regex.matches(in: code, range: codeRange)
            if let match = matches.first, matches.count == 1 {
                detectedCodeType = key
                result = match
                break
            }
        }
        
        type?.pointee = detectedCodeType
        
        // create color from result
        switch detectedCodeType {
        case .hex:
            let hex = Int(String(code.characters.dropFirst()), radix: 16) ?? 0
            self.init(hex: hex)
            
        case .shortHex:
            let hex = Int(String(code.characters.dropFirst()), radix: 16) ?? 0
            let r = (hex & 0xF00) >> 8
            let g = (hex & 0x0F0) >> 4
            let b = (hex & 0x00F)
            self.init(calibratedRed: CGFloat(r) / 15, green: CGFloat(g) / 15, blue: CGFloat(b) / 15, alpha: 1.0)
            
        case .cssRGB:
            let r = Double(code.substring(with: result.rangeAt(1))) ?? 0
            let g = Double(code.substring(with: result.rangeAt(2))) ?? 0
            let b = Double(code.substring(with: result.rangeAt(3))) ?? 0
            self.init(calibratedRed: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1.0)
            
        case .cssRGBa:
            let r = Double(code.substring(with: result.rangeAt(1))) ?? 0
            let g = Double(code.substring(with: result.rangeAt(2))) ?? 0
            let b = Double(code.substring(with: result.rangeAt(3))) ?? 0
            let a = Double(code.substring(with: result.rangeAt(4))) ?? 1
            self.init(calibratedRed: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a))
            
        case .cssHSL:
            let h = Double(code.substring(with: result.rangeAt(1))) ?? 0
            let s = Double(code.substring(with: result.rangeAt(2))) ?? 0
            let l = Double(code.substring(with: result.rangeAt(3))) ?? 0
            self.init(calibratedHue: CGFloat(h) / 360, saturation: CGFloat(s) / 100, lightness: CGFloat(l) / 100, alpha: 1.0)
            
        case .cssHSLa:
            let h = Double(code.substring(with: result.rangeAt(1))) ?? 0
            let s = Double(code.substring(with: result.rangeAt(2))) ?? 0
            let l = Double(code.substring(with: result.rangeAt(3))) ?? 0
            let a = Double(code.substring(with: result.rangeAt(4))) ?? 1
            self.init(calibratedHue: CGFloat(h) / 360, saturation: CGFloat(s) / 100, lightness: CGFloat(l) / 100, alpha: CGFloat(a))
            
        case .cssKeyword:
            let lowercase = code.lowercased()
            guard let hex = ColorKeywordMap.first(where: {
                $0.key.lowercased() == lowercase
            })?.value else {
                type?.pointee = .invalid
                return nil
            }
            self.init(hex: hex)
            
        case .invalid:
            return nil
        }
    }
    
    
    /**
     Creates and returns a `NSColor` object using the given hex color code. Or returns `nil` if color code is invalid.
     
     Example usage:
     ```
     let redColor = NSColor(hex: 0xFF0000, alpha:1.0)
     let hex = redColor.colorCode(type: .hex)  // => "#ff0000"
     ```
     
     - parameter hex:        The 6-digit hexadecimal color code.
     - parameter alpha:      The opacity value of the color object.
     - returns:              The color object.
     */
    public convenience init?(hex: Int, alpha: CGFloat = 1.0) {
        
        guard (0...0xFFFFFF).contains(hex) else { return nil }
        
        let r = (hex & 0xFF0000) >> 16
        let g = (hex & 0x00FF00) >> 8
        let b = (hex & 0x0000FF)
        
        self.init(calibratedRed: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: alpha)
    }
    
    
    /**
     Creates and returns a `<String, NSColor>` paired dictionary represents all keyword colors specified in CSS3.
     
     - returns:              The Dcitonary of the stylesheet keyword names and colors pairs. The names are in upper camel case.
     */
    public static var stylesheetKeywordColors: [String: NSColor] {
        
        return ColorKeywordMap.reduce([:]) { (dict, item) in
            var dict = dict
            dict[item.key] = NSColor(hex: item.value)
            return dict
        }
    }
    
    
    /**
     Returns the receiver’s color code in desired type.
     
     This method works only with objects representing colors in the `NSCalibratedRGBColorSpace` or `NSDeviceRGBColorSpace` color space. Sending it to other objects raises an exception.
     
     - parameter type:       The type of color code to format the returned string. You may use one of the types listed in `ColorCodeType`.
     - returns:              The color code string formatted in the input type.
     */
    public func colorCode(type: ColorCodeType) -> String? {
        
        let r = Int(round(255 * self.redComponent))
        let g = Int(round(255 * self.greenComponent))
        let b = Int(round(255 * self.blueComponent))
        let alpha = self.alphaComponent
        
        switch type {
        case .hex:
            return String(format: "#%02x%02x%02x", r, g, b)
            
        case .shortHex:
            return String(format: "#%1x%1x%1x", r / 16, g / 16, b / 16)
            
        case .cssRGB:
            return String(format: "rgb(%d,%d,%d)", r, g, b)
            
        case .cssRGBa:
            return String(format: "rgba(%d,%d,%d,%g)", r, g, b, alpha)
            
        case .cssHSL, .cssHSLa:
            let hue = self.hueComponent
            let saturation = self.hslSaturationComponent
            let lightness = self.lightnessComponent
            
            let h = (saturation > 0) ? Int(round(360 * hue)) : 0
            let s = Int(round(100 * saturation))
            let l = Int(round(100 * lightness))
            
            if type == .cssHSLa {
                return String(format: "hsla(%d,%d%%,%d%%,%g)", h, s, l, alpha)
            }
            return String(format: "hsl(%d,%d%%,%d%%)", h, s, l)
            
        case .cssKeyword:
            let hex = ((Int(r) & 0xff) << 16) + ((Int(g) & 0xff) << 8) + (Int(b) & 0xff)
            return ColorKeywordMap.first { $0.value == hex }?.key
            
        case .invalid:
            return nil
        }
    }
    
}



private let ColorKeywordMap: [String: Int] = [
    // CSS2.1
    "Black": 0x000000,
    "Navy": 0x000080,
    "Blue": 0x0000FF,
    "Green": 0x008000,
    "Lime": 0x00FF00,
    "Aqua": 0x00FFFF,
    "Teal": 0x008080,
    "Maroon": 0x800000,
    "Purple": 0x800080,
    "Olive": 0x808000,
    "Gray": 0x808080,
    "Silver": 0xC0C0C0,
    "Red": 0xFF0000,
    "Fuchsia": 0xFF00FF,
    "Orange": 0xFFA500,
    "Yellow": 0xFFFF00,
    "White": 0xFFFFFF,
    
    // CSS3
    "DarkBlue": 0x00008B,
    "MediumBlue": 0x0000CD,
    "DarkGreen": 0x006400,
    "DarkCyan": 0x008B8B,
    "DeepSkyBlue": 0x00BFFF,
    "DarkTurquoise": 0x00CED1,
    "MediumSpringGreen": 0x00FA9A,
    "SpringGreen": 0x00FF7F,
    "Cyan": 0x00FFFF,
    "MidnightBlue": 0x191970,
    "DodgerBlue": 0x1E90FF,
    "LightSeaGreen": 0x20B2AA,
    "ForestGreen": 0x228B22,
    "SeaGreen": 0x2E8B57,
    "DarkSlateGray": 0x2F4F4F,
    "LimeGreen": 0x32CD32,
    "MediumSeaGreen": 0x3CB371,
    "Turquoise": 0x40E0D0,
    "RoyalBlue": 0x4169E1,
    "SteelBlue": 0x4682B4,
    "DarkSlateBlue": 0x483D8B,
    "MediumTurquoise": 0x48D1CC,
    "Indigo ": 0x4B0082,
    "DarkOliveGreen": 0x556B2F,
    "CadetBlue": 0x5F9EA0,
    "CornflowerBlue": 0x6495ED,
    "RebeccaPurple": 0x663399,
    "MediumAquaMarine": 0x66CDAA,
    "DimGray": 0x696969,
    "SlateBlue": 0x6A5ACD,
    "OliveDrab": 0x6B8E23,
    "SlateGray": 0x708090,
    "LightSlateGray": 0x778899,
    "MediumSlateBlue": 0x7B68EE,
    "LawnGreen": 0x7CFC00,
    "Chartreuse": 0x7FFF00,
    "Aquamarine": 0x7FFFD4,
    "SkyBlue": 0x87CEEB,
    "LightSkyBlue": 0x87CEFA,
    "BlueViolet": 0x8A2BE2,
    "DarkRed": 0x8B0000,
    "DarkMagenta": 0x8B008B,
    "SaddleBrown": 0x8B4513,
    "DarkSeaGreen": 0x8FBC8F,
    "LightGreen": 0x90EE90,
    "MediumPurple": 0x9370DB,
    "DarkViolet": 0x9400D3,
    "PaleGreen": 0x98FB98,
    "DarkOrchid": 0x9932CC,
    "YellowGreen": 0x9ACD32,
    "Sienna": 0xA0522D,
    "Brown": 0xA52A2A,
    "DarkGray": 0xA9A9A9,
    "LightBlue": 0xADD8E6,
    "GreenYellow": 0xADFF2F,
    "PaleTurquoise": 0xAFEEEE,
    "LightSteelBlue": 0xB0C4DE,
    "PowderBlue": 0xB0E0E6,
    "FireBrick": 0xB22222,
    "DarkGoldenRod": 0xB8860B,
    "MediumOrchid": 0xBA55D3,
    "RosyBrown": 0xBC8F8F,
    "DarkKhaki": 0xBDB76B,
    "MediumVioletRed": 0xC71585,
    "IndianRed ": 0xCD5C5C,
    "Peru": 0xCD853F,
    "Chocolate": 0xD2691E,
    "Tan": 0xD2B48C,
    "LightGray": 0xD3D3D3,
    "Thistle": 0xD8BFD8,
    "Orchid": 0xDA70D6,
    "GoldenRod": 0xDAA520,
    "PaleVioletRed": 0xDB7093,
    "Crimson": 0xDC143C,
    "Gainsboro": 0xDCDCDC,
    "Plum": 0xDDA0DD,
    "BurlyWood": 0xDEB887,
    "LightCyan": 0xE0FFFF,
    "Lavender": 0xE6E6FA,
    "DarkSalmon": 0xE9967A,
    "Violet": 0xEE82EE,
    "PaleGoldenRod": 0xEEE8AA,
    "LightCoral": 0xF08080,
    "Khaki": 0xF0E68C,
    "AliceBlue": 0xF0F8FF,
    "HoneyDew": 0xF0FFF0,
    "Azure": 0xF0FFFF,
    "SandyBrown": 0xF4A460,
    "Wheat": 0xF5DEB3,
    "Beige": 0xF5F5DC,
    "WhiteSmoke": 0xF5F5F5,
    "MintCream": 0xF5FFFA,
    "GhostWhite": 0xF8F8FF,
    "Salmon": 0xFA8072,
    "AntiqueWhite": 0xFAEBD7,
    "Linen": 0xFAF0E6,
    "LightGoldenRodYellow": 0xFAFAD2,
    "OldLace": 0xFDF5E6,
    "Magenta": 0xFF00FF,
    "DeepPink": 0xFF1493,
    "OrangeRed": 0xFF4500,
    "Tomato": 0xFF6347,
    "HotPink": 0xFF69B4,
    "Coral": 0xFF7F50,
    "DarkOrange": 0xFF8C00,
    "LightSalmon": 0xFFA07A,
    "LightPink": 0xFFB6C1,
    "Pink": 0xFFC0CB,
    "Gold": 0xFFD700,
    "PeachPuff": 0xFFDAB9,
    "NavajoWhite": 0xFFDEAD,
    "Moccasin": 0xFFE4B5,
    "Bisque": 0xFFE4C4,
    "MistyRose": 0xFFE4E1,
    "BlanchedAlmond": 0xFFEBCD,
    "PapayaWhip": 0xFFEFD5,
    "LavenderBlush": 0xFFF0F5,
    "SeaShell": 0xFFF5EE,
    "Cornsilk": 0xFFF8DC,
    "LemonChiffon": 0xFFFACD,
    "FloralWhite": 0xFFFAF0,
    "Snow": 0xFFFAFA,
    "LightYellow": 0xFFFFE0,
    "Ivory": 0xFFFFF0,
]



private extension String {
    
    func substring(with range: NSRange) -> String {
        
        return (self as NSString).substring(with: range)
    }
    
}
