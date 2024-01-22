//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2024/1/1.
//

import UIKit
import WWPrint
import WWAESCrypt

final class ViewController: UIViewController {

    private static let AESKey = "0123456789_0123456789_0123456789"
    
    @WWAESCrypt(ViewController.AESKey) var plainText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (0..<5).forEach { _ in cipherTextTest() }
    }
}

// MARK: - 小工具
private extension ViewController {
    
    /// 加解密測試
    func cipherTextTest() {
        
        plainText = "進階加密標準 - Advanced Encryption Standard"
        
        guard let cipherText = plainText,
              let decodingText = WWAESCrypt.decoding(base64EncodedString: plainText, forKey: ViewController.AESKey)
        else {
            return
        }
        
        wwPrint(cipherText)
        wwPrint(decodingText)
    }
}
