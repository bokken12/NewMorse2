//
//  Serial.swift
//  MorseFlash22
//
//  Created by joel on 10/13/17.
//  Copyright © 2017 Casey Manning. All rights reserved.
//

import Foundation
import AVFoundation

class Serial {
    
    enum Endian {
        case lsb
        case msb
    }
    
    var baud:Int
    var len:TimeInterval
    var endian:Endian
    var parity:Bool
    var timer:Timer?
    
    let device:AVCaptureDevice?
    
    init(baud:Int, endian:Endian, parity:Bool){
        self.baud = baud;
        self.len = 1.0/Double(baud)
        self.endian = endian;
        self.parity = parity;
        self.device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    }
    
    func send(data:[UInt8]) {
        var handshake: Bool = false
        var pos:UInt8 = 0
        timer = Timer.scheduledTimer(withTimeInterval:len, repeats:true) {
            [weak self] _ in
            if !handshake {
                //has not yet done the handshake, continue until response from receiver
                if self!.device?.torchMode == AVCaptureTorchMode.off {
                    handshake = self!.hasResponse()
                }
                self!.setFlash(on:self!.device?.torchMode == AVCaptureTorchMode.off)
            } else {
                let current = pos / 10
                let index = pos % 10
            }
            pos += 1
        }
    }
    
    func setFlash(on:Bool) {
        if (device?.hasTorch)! {
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
    
    /*
     * Placeholder
     */
    func hasResponse() -> Bool {
        return false
    }
    
}
