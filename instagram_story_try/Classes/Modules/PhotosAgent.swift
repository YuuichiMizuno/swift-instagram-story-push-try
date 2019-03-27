//
//  PhotosAgent.swift
//  instagram_faceBook_story_try
//
//  Created by Mizuno Yuuichi on 2019/03/26.
//  Copyright © 2019 Mizuno Yuuichi. All rights reserved.
//

import UIKit

import CoreImage
import UIKit
import Photos



final class PhotosAgent: NSObject {

    
    // MARK: - properties
    fileprivate var compHandler: ((Result<[UIImagePickerController.InfoKey : Any]>) -> Void)?

    fileprivate var resultInfo: [UIImagePickerController.InfoKey : Any]?
    
    fileprivate let kThumbnailImageName = "thumbnailImage.png"

    
    // MARK: - public
    func pickingMedia(clientViewController: UIViewController, _ compHandler: @escaping (Result<[UIImagePickerController.InfoKey : Any]>) -> Void) {
        self.compHandler = compHandler
        self.accessLibraryIfCould(client: clientViewController)
    }
    
    func clearHander() {
        self.compHandler = nil
    }
    
    func saveCurrentThumbnailImage(_ image: UIImage) {
        self.setCurrentThumbnailImage(image)
    }
    
    func loadCurrentThumbnailImage() -> UIImage? {
        return self.load(name: kThumbnailImageName)
    }
    
    func eraseThumbnailImage() {
        self.delete(name: kThumbnailImageName)
    }
    
}



// MARK: - UIImagePickerControllerDelegate
extension PhotosAgent: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //guard let editedImage  = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
        //      let referenceURL = info[UIImagePickerController.InfoKey.referenceURL] as? String else { return }

        picker.dismiss(animated: true) { [weak self] in
            self?.compHandler?(Result.success(info))
            print("閉じました")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print(picker)
        picker.dismiss(animated: true) {
            print("キャンセルにつき 閉じました")
        }
    }
    
}



// MARK: - private
extension PhotosAgent {
    
    fileprivate func accessLibraryIfCould(client: UIViewController) {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized,
                 .restricted:
                    print(" -- Authorization: authorized(許可済 or 利用制限)")
                    self.accessLibrary(client)
            case .denied:
                    print(" -- Authorization: denied(明示的拒否)")
                    self.askForSettingChange()
            case .notDetermined:
                    print(" -- Authorization: NotDetermined(許可も拒否もしていない)")
                    // first time no need access code.
            }
        }
    }
    
    fileprivate func accessLibrary(_ client: UIViewController) {
        let picker = UIImagePickerController()
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            picker.allowsEditing = true     // Trimming function activated!
            picker.delegate = self //as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        client.present(picker, animated: true)
    }
    
    fileprivate func setCurrentThumbnailImage(_ image: UIImage) {
        guard let path = self.path(filename: kThumbnailImageName) else { return }
        self.save(image, path: path)
    }

    
    // MARK: - private - clean
    fileprivate func path(filename: String) -> String? {
        if let docPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL).path {
            return docPath + "/" + filename
        }
        else {
            return nil
        }
    }
    
    fileprivate func exixts(filename: String) -> Bool {
        if let path = self.path(filename: filename),
           FileManager.default.fileExists(atPath: path) {
            print("存在します")
            return true
        }
        else {
            print("存在しません")
            return false
        }
    }
    
    fileprivate func load(name: String) -> UIImage? {
        guard let path  = self.path(filename: name),
              let image = UIImage(contentsOfFile: path) else {
                print(" !!! failed !!! get thumbnail image")
                return nil
        }
        return image
    }
    
    fileprivate func save(_ image: UIImage, path: String) {
        do {
            guard let pngImageData = image.pngData() else { return }
            
            try pngImageData.write(to: URL(fileURLWithPath: path), options: .atomic)
            print(" -- 画像保存成功しました")
        }
        catch {
            print(" !!! error !!! 画像保存に失敗しました \(error)")
        }
    }
    
    fileprivate func delete(name: String) {
        if self.exixts(filename: name),
           let path = self.path(filename: name) {
            do {
                try FileManager.default.removeItem(atPath: path)
            }
            catch (let error) {
                print(error)
            }
        }
    }
    
    fileprivate func crop(image: UIImage, cropRect: CGRect) -> UIImage? {
        guard let cgImage  = image.cgImage,
              let imageRef = cgImage.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: imageRef)
    }
    
    fileprivate func askForSettingChange() {
        UIAlertController.showAlertTwo(message: "サムネールを変更にするには、フォトライブラリへのアクセスを有効にしてください。",
                                       yesButtonText:  "設定", noButtonText: "今はいいです") {
                                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                                        if UIApplication.shared.canOpenURL(settingsUrl) {
                                            UIApplication.shared.open(settingsUrl)
                                        }
        }
    }
    
}
