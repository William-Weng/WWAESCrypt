//
//  AESCrypt.swift
//  WWAESCrypt
//
//  Created by William.Weng on 2024/1/21.
//

import UIKit
import CommonCrypto

// MARK: - AESCrypt
struct AESCrypt {
    
    enum AESError: Error {
        case invalidKeySize
        case generateRandomIVFailed
        case encryptionFailed
        case decryptionFailed
        case dataToStringFailed
    }
    
    private let key: Data
    private let ivSize: Int = kCCBlockSizeAES128
    private let options: CCOptions = CCOptions(kCCOptionPKCS7Padding)
    
    init(key: Data) throws {
        guard key.count == kCCKeySizeAES256 else { throw AESError.invalidKeySize }
        self.key = key
    }
}

// MARK: - 小工具
extension AESCrypt {
    
    /// [AES加密 - String](https://zh.wikipedia.org/zh-tw/高级加密标准)
    /// - Parameter string: String
    /// - Returns: Data
    func encrypt(_ string: String) throws -> Data {
        let data = Data(string.utf8)
        return try encrypt(data)
    }
    
    /// [AES加密 - Data](https://kotlin.tw/swift/aes)
    /// - Parameter data: Data
    /// - Returns: Data
    func encrypt(_ data: Data) throws -> Data {
        
        let bufferSize: Int = ivSize + data.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        try generateRandomIV(for: &buffer)
        
        var numberBytesEncrypted: Int = 0
        
        do {
            try key.withUnsafeBytes { keyBytes in
                try data.withUnsafeBytes { dataToEncryptBytes in
                    try buffer.withUnsafeMutableBytes { bufferBytes in
                        
                        guard let keyBytesBaseAddress = keyBytes.baseAddress,
                              let dataToEncryptBytesBaseAddress = dataToEncryptBytes.baseAddress,
                              let bufferBytesBaseAddress = bufferBytes.baseAddress
                        else {
                            throw AESError.encryptionFailed
                        }
                        
                        let cryptStatus: CCCryptorStatus = CCCrypt(CCOperation(kCCEncrypt), CCAlgorithm(kCCAlgorithmAES), options, keyBytesBaseAddress, key.count, bufferBytesBaseAddress, dataToEncryptBytesBaseAddress, dataToEncryptBytes.count, bufferBytesBaseAddress + ivSize, bufferSize, &numberBytesEncrypted)
                        
                        guard cryptStatus == CCCryptorStatus(kCCSuccess) else { throw AESError.encryptionFailed }
                    }
                }
            }
            
        } catch {
            throw AESError.encryptionFailed
        }
        
        let encryptedData: Data = buffer[..<(numberBytesEncrypted + ivSize)]
        return encryptedData
    }
    
    /// [AES解密](https://www.smartm.com/ch/technology/aes-256-encryption)
    /// - Parameter data: Data
    /// - Returns: String
    func decrypt(_ data: Data) throws -> String {
        
        let bufferSize: Int = data.count - ivSize
        var buffer = Data(count: bufferSize)
        
        var numberBytesDecrypted: Int = 0
        
        do {
            try key.withUnsafeBytes { keyBytes in
                try data.withUnsafeBytes { dataToDecryptBytes in
                    try buffer.withUnsafeMutableBytes { bufferBytes in
                        
                        guard let keyBytesBaseAddress = keyBytes.baseAddress,
                              let dataToDecryptBytesBaseAddress = dataToDecryptBytes.baseAddress,
                              let bufferBytesBaseAddress = bufferBytes.baseAddress
                        else {
                            throw AESError.encryptionFailed
                        }
                        
                        let cryptStatus: CCCryptorStatus = CCCrypt(CCOperation(kCCDecrypt), CCAlgorithm(kCCAlgorithmAES128), options, keyBytesBaseAddress, key.count, dataToDecryptBytesBaseAddress, dataToDecryptBytesBaseAddress + ivSize, bufferSize, bufferBytesBaseAddress, bufferSize, &numberBytesDecrypted)
                        
                        guard cryptStatus == CCCryptorStatus(kCCSuccess) else { throw AESError.decryptionFailed }
                    }
                }
            }
        } catch {
            throw AESError.encryptionFailed
        }
        
        let decryptedData: Data = buffer[..<numberBytesDecrypted]
        
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else { throw AESError.dataToStringFailed }
        return decryptedString
    }
}

// MARK: - 小工具
private extension AESCrypt {
    
    /// [產生隨機的初始向量 - Initialization Vector](https://zh.wikipedia.org/zh-tw/初始向量)
    /// - Parameter data: Data
    func generateRandomIV(for data: inout Data) throws {
        
        try data.withUnsafeMutableBytes { dataBytes in
            guard let dataBytesBaseAddress = dataBytes.baseAddress else { throw AESError.generateRandomIVFailed }
            let status: Int32 = SecRandomCopyBytes( kSecRandomDefault, kCCBlockSizeAES128, dataBytesBaseAddress)
            guard status == 0 else { throw AESError.generateRandomIVFailed }
        }
    }
}
