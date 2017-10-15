import Foundation
import AVFoundation
import UIKit

//On the top of your swift
extension UIImage {
    func getPixelGray(pos: CGPoint) -> UInt8 {

        let pixelData = self.cgImage!.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

        let r = data[pixelInfo]
        let g = data[pixelInfo+1]
        let b = data[pixelInfo+2]
        //sprint(self.cgImage)
        return r/3 + g/3 + b/3
    }
}

class CameraFlash: FrameExtractorDelegate {
    
    let ryanski = [" ", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", ".", ",", "?", "!", "_"]
    
    enum State {
        case waitingForBlack
        case waitingForWhite
        case waitingForBlack2
        case handshook
    }

    var captured = [UInt8]()
    var i = 0
    var byte:UInt8 = 0
    
    var fimage: UIImageView?
    var brightBuffer: UInt8
    
    var extractor: FrameExtractor
    var timer: Timer?
    var begun: Bool
    var begunbegun: Bool
    
    var laabel : UILabel?

    init(foo: UIImageView, label: UILabel) {
        extractor = FrameExtractor()
        brightBuffer = 0
        begun = false
        begunbegun = false
        extractor.delegate = self
        fimage = foo
        laabel = label
    }
    
    func startCapture() {
        timer?.invalidate()
        begun = false
//        begunbegun = false
        timer = Timer.scheduledTimer(withTimeInterval:1, repeats:true) {
            [weak self] _ in
            self!.useBuffer()
        }
    }

//    public func capture() {
//        captureOutput()
//    }
    
    internal func captured(image: UIImage) {

        let newSize = CGSize(width:1, height:1)
        let rect = CGRect(origin:CGPoint(x:0, y:0), size:newSize)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in:rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        fimage?.image = image;

        brightBuffer = newImage!.getPixelGray(pos:CGPoint(x:0, y:0))
    }
    
    func useBuffer() {
                if self.brightBuffer > 127 {
                    if begun {
//                        if begunbegun {
                            self.byte += (1 << i)
                            self.i += 1
//                        } else {
//                            begunbegun = true
//                        }
                    } else {
                        begun = true
                    }
                } else {
                    if begun {
//                        if(begunbegun) {
                        self.i += 1
//                        } else {
//                            begunbegun = true
//                        }
                    }
                }
                
                //print(self.byte)
        
                if (self.i == 5) {
                    print(ryanski[Int(self.byte)], terminator: "")
                    
                    laabel?.text = laabel!.text ?? "" + ryanski[Int(self.byte)]
                    self.i = 0
                    self.byte = 0
                }
    }

    
//    private func setDelayedReceive() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: {
//            self.shouldRecieve = true
//        })
//    }

    public func getString() {
        if let string = String(bytes: self.captured, encoding: .utf8) {
            print(string)
        } else {
            print("not a valid UTF-8 sequence")
        }
    }

}
