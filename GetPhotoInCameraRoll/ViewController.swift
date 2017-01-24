//
//  ViewController.swift
//  GetPhotoTest
//
//  Created by KumagaiNaoki on 2017/01/04.
//  Copyright © 2017年 KumagaiNaoki. All rights reserved.
//
//   xcode8.2.1 swift3.0
//   任意の二つの日時の間でカメラロールに生成された写真を取得するアプリ
// http://dev.classmethod.jp/references/ios8-photo-kit-1/参考サイト


import UIKit
import Photos

class ViewController: UIViewController {
    
    var photoAssets = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.requestAuthorization { (status) in
            switch (status) {
            case .notDetermined:// ユーザーはまだ、このアプリに与える権限を選択をしていない
                break;
            case .restricted:// PhotoLibraryへのアクセスが許可されていない
                break;
            case .denied:// ユーザーが明示的に、アプリが写真のデータへアクセスすることを拒否した
                break;
            case .authorized:// ユーザーが、アプリが写真のデータへアクセスすることを許可している
                
                //以下に日時を二つ渡す
                let startDate = self.createDate(year: 2016, month: 12, day: 15, hour: 1, minute: 0)
                let endDate = self.createDate(year: 2016, month: 12, day: 15, hour: 23, minute: 59)
                self.getPhoto(startDate: startDate, endDate: endDate, callback: {
                    self.showPhoto()
                })
                break;
            }
        }
    }
    func createDate(year:Int, month:Int, day:Int, hour:Int, minute:Int) -> Date {
        var com = DateComponents()
        com.year = year
        com.month = month
        com.day = day
        com.hour = hour
        com.minute = minute
        com.timeZone = TimeZone(identifier: "GMT")
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)//西暦
        return cal.date(from: com)!
    }
    
    func getPhoto(startDate: Date, endDate: Date, callback: () -> Void) {
        let option = PHFetchOptions()
        option.fetchLimit = 100
        
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: option)
        var momentLists = [PHCollection]()
        if fetchResult.count == 1 {
            fetchResult.enumerateObjects({ (moment, idx, stop) in
                momentLists.append(moment)
            })
        }
        print(momentLists[0].localizedTitle ?? String())//Camera Roll
        
        let assets = PHAsset.fetchAssets(in: momentLists[0] as! PHAssetCollection, options: option)
        assets.enumerateObjects({ (asset, index, stop) in
            
            //TODO:ここでasset.locationすれば位置情報も取得できる。
            print(asset.location)
            
            if asset.mediaType == .image {
                let assetDate = asset.creationDate
                if assetDate?.compare(startDate) == .orderedDescending && assetDate?.compare(endDate) == .orderedAscending {
                    self.photoAssets.append(asset)
                }
                
            }
        })
        callback()
    }
    
    func showPhoto() {
        var positionY = 50
        for asset in photoAssets {
            let manager = PHImageManager()
            let size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
            let option = PHImageRequestOptions()
            option.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: option) { (image, info) in
                
                DispatchQueue.main.async {
                    let imageView = UIImageView()
                    imageView.frame.size = CGSize(width: 50, height: 50)
                    imageView.layer.position = CGPoint(x: 50, y: positionY)
                    imageView.image = image
                    imageView.contentMode = .scaleAspectFit
                    self.view.addSubview(imageView)
                    positionY += 50
                }
            }
        }
    }
    
}
