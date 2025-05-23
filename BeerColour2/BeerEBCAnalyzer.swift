//
//  BeerColorAnalyzer.swift
//  BeerColour2
//
//  Created by GitHub Copilot on 23/5/2025.
//

import Foundation
import UIKit
import CoreImage

class BeerColorAnalyzer {
    
    // EBC color ranges and their descriptions
    static let ebcColorRanges: [(range: ClosedRange<Double>, name: String)] = [
        (0...4, "Pale straw"),
        (5...7, "Straw"),
        (8...11, "Pale gold"),
        (12...15, "Gold"),
        (16...19, "Amber"),
        (20...25, "Deep amber"),
        (26...33, "Light copper"),
        (34...39, "Copper"),
        (40...47, "Dark copper"),
        (48...57, "Light brown"),
        (58...69, "Brown/Reddish brown"),
        (70...79, "Dark brown"),
        (80...100, "Very dark brown"),
        (101...500, "Black")
    ]
    
    // Convert RGB to Lab color space
    private static func rgbToLab(r: Double, g: Double, b: Double) -> (l: Double, a: Double, b: Double) {
        // Convert RGB to XYZ
        var r = r / 255.0
        var g = g / 255.0
        var b = b / 255.0
        
        // Apply gamma correction
        r = (r > 0.04045) ? pow((r + 0.055) / 1.055, 2.4) : r / 12.92
        g = (g > 0.04045) ? pow((g + 0.055) / 1.055, 2.4) : g / 12.92
        b = (b > 0.04045) ? pow((b + 0.055) / 1.055, 2.4) : b / 12.92
        
        // Scale
        r *= 100
        g *= 100
        b *= 100
        
        // Convert to XYZ
        let x = r * 0.4124 + g * 0.3576 + b * 0.1805
        let y = r * 0.2126 + g * 0.7152 + b * 0.0722
        let z = r * 0.0193 + g * 0.1192 + b * 0.9505
        
        // Convert XYZ to Lab
        let xRef: Double = 95.047
        let yRef: Double = 100.0
        let zRef: Double = 108.883
        
        let x1 = x / xRef
        let y1 = y / yRef
        let z1 = z / zRef
        
        let fx = (x1 > 0.008856) ? pow(x1, 1/3) : (7.787 * x1) + (16/116)
        let fy = (y1 > 0.008856) ? pow(y1, 1/3) : (7.787 * y1) + (16/116)
        let fz = (z1 > 0.008856) ? pow(z1, 1/3) : (7.787 * z1) + (16/116)
        
        let l = (116 * fy) - 16
        let a = 500 * (fx - fy)
        let c = 200 * (fy - fz)
        
        return (l, a, c)
    }
    
    // Calculate EBC from color
    static func analyzeImage(_ image: UIImage) -> BeerAnalysisResult {
        // Get the central square area of the image (the targeting area)
        let centralSquareImage = cropToCenter(image)
        
        // Get the average color of the central area
        guard let averageColor = centralSquareImage.averageColor else {
            return BeerAnalysisResult(ebcValue: 0, colorName: "Unknown", accuracy: 0, rgb: (0, 0, 0))
        }
        
        // Extract RGB components
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        averageColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Convert RGB to Lab for better color analysis
        let lab = rgbToLab(r: Double(red * 255), g: Double(green * 255), b: Double(blue * 255))
        
        // Calculate approximate EBC value using the SRM formula and conversion
        let srmApprox = 1.4922 * (Double(red * 255) * 0.299 + Double(green * 255) * 0.587 + Double(blue * 255) * 0.114) / 100
        let ebcValue = 1.97 * srmApprox
        
        // Find the color name from our ranges
        let colorName = getColorName(for: ebcValue)
        
        // Calculate accuracy (higher L value means more light, which means more accuracy)
        let accuracy = min(1.0, max(0.3, lab.l / 100.0))
        
        return BeerAnalysisResult(
            ebcValue: ebcValue,
            colorName: colorName,
            accuracy: accuracy,
            rgb: (Int(red * 255), Int(green * 255), Int(blue * 255))
        )
    }
    
    // Helper method to get the color name based on EBC value
    static func getColorName(for ebcValue: Double) -> String {
        for (range, name) in ebcColorRanges {
            if range.contains(ebcValue) {
                return name
            }
        }
        return "Black"
    }
    
    // Crop image to center square
    private static func cropToCenter(_ image: UIImage) -> UIImage {
        let cgImage = image.cgImage!
        
        let width = cgImage.width
        let height = cgImage.height
        
        // Calculate the square size (40% of the shorter side)
        let shorterSide = min(width, height)
        let squareSize = Int(Double(shorterSide) * 0.4)
        
        // Calculate the center point
        let centerX = width / 2
        let centerY = height / 2
        
        // Calculate the origin point for cropping
        let originX = centerX - squareSize / 2
        let originY = centerY - squareSize / 2
        
        // Create the cropping rectangle
        let cropRect = CGRect(x: originX, y: originY, width: squareSize, height: squareSize)
        
        // Perform the crop
        if let croppedCGImage = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCGImage)
        } else {
            return image
        }
    }
}

// Result structure for beer analysis
struct BeerAnalysisResult {
    let ebcValue: Double
    let colorName: String
    let accuracy: Double  // 0.0 to 1.0 where 1.0 is highly accurate
    let rgb: (red: Int, green: Int, blue: Int)
    
    // Formatted EBC value string
    var formattedEBC: String {
        return String(format: "%.1f", ebcValue)
    }
    
    // Accuracy level description
    var accuracyDescription: String {
        if accuracy > 0.8 {
            return "High"
        } else if accuracy > 0.5 {
            return "Medium"
        } else {
            return "Low"
        }
    }
    
    // Color representation for UI
    var uiColor: UIColor {
        return UIColor(red: CGFloat(rgb.red) / 255.0,
                      green: CGFloat(rgb.green) / 255.0,
                      blue: CGFloat(rgb.blue) / 255.0,
                      alpha: 1.0)
    }
}

// Extension to get the average color of a UIImage
extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                   y: inputImage.extent.origin.y,
                                   z: inputImage.extent.size.width,
                                   w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage",
                                  parameters: [kCIInputImageKey: inputImage,
                                             kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        
        context.render(outputImage,
                      toBitmap: &bitmap,
                      rowBytes: 4,
                      bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                      format: .RGBA8,
                      colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255,
                      green: CGFloat(bitmap[1]) / 255,
                      blue: CGFloat(bitmap[2]) / 255,
                      alpha: CGFloat(bitmap[3]) / 255)
    }
}
