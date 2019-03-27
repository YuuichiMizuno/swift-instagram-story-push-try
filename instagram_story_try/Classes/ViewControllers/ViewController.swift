//
//  ViewController.swift
//  instagram_faceBook_story_try
//
//  Created by Mizuno Yuuichi on 2019/03/26.
//  Copyright © 2019 Mizuno Yuuichi. All rights reserved.
//

import UIKit
import Photos


class ViewController: UIViewController {

    
    // MARK: - properties
    fileprivate var photosAgent = PhotosAgent()
    
    fileprivate var instaAgent = InstaAgent()
    
    fileprivate let storiesShareURLScheme = "instagram-stories://share"
    
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

}



// MARK: - action
extension ViewController {
    
    @IBAction func didTapURLScheme(_ sender: Any) {
        self.checkInstagram()
    }
    
    @IBAction func didTapInstagramSchemeWithPath(_ sender: Any) {
        self.postInstagramFromPhotoLibrary()
    }
    
    @IBAction func didTapInstagramSchemeWithCopy(_ sender: Any) {
        self.postInstagramWithPaste()
    }
    
}



// MARK: - private
extension ViewController {
    
    fileprivate func configure() {
        
    }

    /// 端末にインスタが入っているかチェック
    fileprivate func checkInstagram() {
        guard let url = URL(string: "instagram-stories://") else {
            print("URLスキーム用のURL作成に失敗しました。。")
            return
        }
        let answer = UIApplication.shared.canOpenURL(url)
                ? "インスタグラムあります"
                : "インスタグラムありません"
        UIAlertController.showInduction(message: answer) {
            UIApplication.shared.open(url)
        }
    }
    
    /// フォトライブラリーのパスを使ってインスタ.ストーリーズに投稿
    fileprivate func postInstagramFromPhotoLibrary() {
        self.photosAgent.pickingMedia(clientViewController: self) { [weak self] (result) in
            switch result {
            case .success(let info):
                let instaLibraryURLScheme = "instagram://library?LocalIdentifier="
                guard let referenceURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL,
                      let url = URL(string: instaLibraryURLScheme + referenceURL.absoluteString) else {
                    print("画像のURL取れませんでした")
                    return
                }
                
                // URLSchemeで開く(画像もパスで渡す)
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
                self?.photosAgent.clearHander()

            case .failure(_): break
            }
        }
    }
    
    /// コピぺを使ってインスタ.ストーリーズに投稿
    fileprivate func postInstagramWithPaste() {
        self.photosAgent.pickingMedia(clientViewController: self) { [weak self] (result) in
            switch result {
            case .success(let info):
                guard let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
                
                // URLSchemeで開く(画像をコピーしてペーストする)
                _ = self?.instaAgent.post(bgImage: editedImage)
                
                self?.photosAgent.clearHander()
            case .failure(_): break
            }
        }
    }

}

