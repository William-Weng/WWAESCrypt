//
//  WWAESCrypt.swift
//  WWAESCrypt
//
//  Created by William.Weng on 2024/1/21.
//

import UIKit

@propertyWrapper
public struct WWAESCrypt {
    
    let key: String
    let encoding: String.Encoding

    private var string: String?
    
    public var wrappedValue: String? {
        get { return string }
        set { string = Self.encoding(newValue, forKey: key, using: encoding) }
    }
    
    /// [初始化](https://youtu.be/vVbLSba6vOI)
    /// - Parameters:
    ///   - key: [加密金鑰](https://youtu.be/7kB9-nQJR44)
    ///   - encoding: [資料編碼](https://youtu.be/RUtvBkibIT8)
    public init(_ key: String, using encoding: String.Encoding = .utf8) {
        self.key = key
        self.encoding = encoding
    }
}

// MARK: - WWAESCrypt
public extension WWAESCrypt {

    /// [AES解密](https://youtu.be/tRMJtXPxdlM)
    /// - Parameters:
    ///   - base64EncodedString: [String?](https://youtu.be/UF2UzFHVYQs)
    ///   - key: String?
    ///   - encoding: String.Encoding
    /// - Returns: String?
    static func decoding(base64EncodedString: String?, forKey key: String?, using encoding: String.Encoding = .utf8) -> String? {
        
        guard let base64EncodedString = base64EncodedString,
              let data = Data(base64Encoded: base64EncodedString),
              let key = key?.data(using: encoding),
              let aes = try? AESCrypt(key: key)
        else {
            return nil
        }
        
        return try? aes.decrypt(data)
    }
    
    /// [AES加密](https://youtu.be/BruRNCe5gH0)
    /// - Parameters:
    ///   - string: [String?](https://youtu.be/i8CVb7-c0lY)
    ///   - key: String?
    ///   - encoding: String.Encoding
    /// - Returns: base64編碼字串
    static func encoding(_ string: String?, forKey key: String, using encoding: String.Encoding = .utf8) -> String? {
        
        guard let string = string,
              let data = string.data(using: encoding),
              let key = key.data(using: encoding),
              let aes = try? AESCrypt(key: key)
        else {
            return nil
        }
        
        return try? aes.encrypt(data).base64EncodedString()
    }
}
