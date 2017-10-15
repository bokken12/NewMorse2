//
//  ViewController.swift
//  MorseFlash22
//
//  Created by Casey Manning on 10/13/17.
//  Copyright © 2017 Casey Manning. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController {
    
    let ryanski = [" ", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", ".", ",", "?", "!", "_"]

    @IBOutlet weak var inputText: UITextField!

    @IBOutlet weak var sendButton: UIButton!

    @IBOutlet weak var resultsLabel: UILabel!
    
    @IBOutlet weak var image: UIImageView!
    var flash: CameraFlash?

    @IBOutlet weak var recieveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //send(str:"hello", i:0, c:0)
        // Do any additional setup after loading the view, typically from a nib./Users/caseymanning/Documents/MorseFlash/MorseFlash22/CameraFlash.swift

        sendButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchDown)
        recieveButton.addTarget(self, action: #selector(buttonTwoTapped(_:)), for: .touchDown)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)

        self.flash = CameraFlash(foo: image, label: resultsLabel)
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6), execute: {
//            self.flash.capture()
//        })
    }

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    var intrinsicContentSize : CGSize {
            //override func intrinsicContentSize() -> CGSize {
            //...
        return CGSize(width: 240, height: 44)
    }

        // MARK: Button Action
    func buttonTapped(_ button: UIButton) {
        print("Button pressed. Yay.")
        ryanSend(str: getText()!)
    }
    
    func buttonTwoTapped(_ button: UIButton) {
        print("The recieve button was pressed. Yay.")
        flash?.startCapture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getText() -> String? {
        return inputText.text
    }
    
    func send(str: String) {
        send(str: "\0" + str, i:8, c:0)
    }
    
    func ryanSend(str:String) {
        setFlash(on:true)
            var index: Int = 0
            var bit:Int = 0
            var timer:Timer?
            timer = Timer.scheduledTimer(withTimeInterval:1, repeats:true) {
                [weak self] _ in
                self?.setFlash(on:((self?.ryanski.index(of: String(str[str.index(str.startIndex, offsetBy: index)])) ?? 0) >> bit) & 0x01 != 0)
                if ((self?.ryanski.index(of: String(str[str.index(str.startIndex, offsetBy: index)])) ?? 0) >> bit) & 0x01 != 0 {
                    print("sending a 1")
                } else {
                    print("sending a 0")
                }
                bit += 1
                if(bit == 5){
                    index += 1
                    bit = 0
                }
                if(index == str.characters.count) {
                    timer?.invalidate()
                }
            }
    }
    
    func send(str: String, i: UInt8, c: UInt8) {
        var newS = str
        var newI = i
        var newC = c
        
        if str.characters.count <= 1 {
            return
        }
        
        if (i == 8) {
            let index = str.index(str.startIndex, offsetBy: 1)
            newS = str.substring(from: index)
            newC = [UInt8](newS.utf8)[0]
            newI = 0
        }
        
        print(newC & 0x01 != 0)
        setFlash(on: newC & 0x01 != 0)

        newI = newI + 1
        newC = newC >> 1

        setFlash(on: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
            self.setFlash(on: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: {
                self.send(str: newS, i: newI, c: newC)
            })
        })
    }

    func setFlash(on: Bool) {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if device?.hasTorch ?? false {
            do {
                try device?.lockForConfiguration()
                if (on) {
                    do {
                        try device?.setTorchModeOnWithLevel(1.0)
                    } catch {
                        print(error)
                    }
                } else {
                    device?.torchMode = AVCaptureTorchMode.off
                }
                device?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
}

