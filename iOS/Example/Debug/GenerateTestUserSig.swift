//
//  GenerateTestUserSig.swift
//  TUILiveKitApp
//
//  Created by abyyxwang on 2021/5/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation
import CommonCrypto
import zlib

/**
 * Tencent Cloud SDKAppId, which needs to be replaced with the SDKAppId under your own account.
 *
 * Enter Tencent Cloud IM to create an application, and you can see the SDKAppId, which is the unique identifier used by Tencent Cloud to distinguish customers.
 */
let SDKAPPID: Int = 0

/**
 *  Signature expiration time, it is recommended not to set it too short
 *
 *  Time unit: seconds
 *  Default time: 7 x 24 x 60 x 60 = 604800 = 7 days
 */
let EXPIRETIME: Int = 604_800

/**
 * Encryption key used for calculating the signature, the steps to obtain it are as follows:
 *
 * step1. Enter Tencent Cloud IM, if you do not have an application yet, create one,
 * step2. Click "Application Configuration" to enter the basic configuration page, and further find the "Account System Integration" section.
 * step3. Click the "View Key" button, you can see the encryption key used to calculate UserSig, please copy and paste it into the following variable
 *
 * Note: This solution is only applicable to debugging demos.
 * Before going online officially, please migrate the UserSig calculation code and keys to your backend server to avoid traffic theft caused by encryption key leakage.
 */
let SECRETKEY = ""

let BEAUTY_LICENSE_KEY = ""

let BEAUTY_LICENSE_URL = ""

let PLAYER_LICENSE_KEY = ""

let PLAYER_LICENSE_URL = ""

class GenerateTestUserSig {
    
    class func genTestUserSig(identifier: String) -> String {
        let current = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970
        let TLSTime: CLong = CLong(floor(current))
        var obj: [String: Any] = [
            "TLS.ver": "2.0",
            "TLS.identifier": identifier,
            "TLS.sdkappid": SDKAPPID,
            "TLS.expire": EXPIRETIME,
            "TLS.time": TLSTime,
        ]
        let keyOrder = [
            "TLS.identifier",
            "TLS.sdkappid",
            "TLS.time",
            "TLS.expire",
        ]
        var stringToSign = ""
        keyOrder.forEach { (key) in
            if let value = obj[key] {
                stringToSign += "\(key):\(value)\n"
            }
        }
        print("string to sign: \(stringToSign)")
        let sig = hmac(stringToSign)
        obj["TLS.sig"] = sig
        print("sig: \(String(describing: sig))")
        guard let jsonData = try? JSONSerialization.data(withJSONObject: obj, options: .sortedKeys) else { return "" }
        
        let bytes = jsonData.withUnsafeBytes { (result) -> UnsafePointer<Bytef> in
            if let baseAddress = result.bindMemory(to: Bytef.self).baseAddress{
                return baseAddress
            }else{
                return UnsafePointer<Bytef>("")
            }
        }
        let srcLen: uLongf = uLongf(jsonData.count)
        let upperBound: uLong = compressBound(srcLen)
        let capacity: Int = Int(upperBound)
        let dest: UnsafeMutablePointer<Bytef> = UnsafeMutablePointer<Bytef>.allocate(capacity: capacity)
        var destLen = upperBound
        let ret = compress2(dest, &destLen, bytes, srcLen, Z_BEST_SPEED)
        if ret != Z_OK {
            print("[Error] Compress Error \(ret), upper bound: \(upperBound)")
            dest.deallocate()
            return ""
        }
        let count = Int(destLen)
        let result = self.base64URL(data: Data(bytesNoCopy: dest, count: count, deallocator: .free))
        return result
    }
    
    class func hmac(_ plainText: String) -> String? {
        let cKey = SECRETKEY.cString(using: .ascii)
        let cData = plainText.cString(using: .ascii)
        
        let cKeyLen = SECRETKEY.lengthOfBytes(using: .ascii)
        let cDataLen = plainText.lengthOfBytes(using: .ascii)
        
        var cHMAC = [CUnsignedChar](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        cHMAC.withUnsafeMutableBufferPointer { (bufferPointer) in
            CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), cKey, cKeyLen, cData, cDataLen, bufferPointer.baseAddress)
        }
       
        let data = Data(cHMAC)
        return data.base64EncodedString(options: [])
    }
    
    class func base64URL(data: Data) -> String {
        let result = data.base64EncodedString()
        var final = ""
        result.forEach { (char) in
            switch char {
            case "+":
                final += "*"
            case "/":
                final += "-"
            case "=":
                final += "_"
            default:
                final += "\(char)"
            }
        }
        return final
    }
}
