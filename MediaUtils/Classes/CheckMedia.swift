//
//  CheckMedia.swift
//  FBSnapshotTestCase
//
//  Created by 聂飞安 on 2020/9/16.
//

import UIKit
import AVFoundation
import NFAToolkit

open class CheckMedia: NSObject {

   @objc open class func checkMicroPermission(_ baseVC : UIViewController , _ cb : @escaping (Bool) -> Void){
       AVAudioSession.sharedInstance().requestRecordPermission { (allow) in
            queueMainAsync(work: {
                if allow {
                    cb(allow)
                } else {
                    showAlertController(baseVC, title: "无法访问您的麦克风", message: "请到  [设置->隐私->麦克风] 打开访问权限")
                }
            })
       }
    }
    
    
    @objc open  class func checkCameraPermission( _ baseVC : UIViewController , _ cb : @escaping (Bool) -> Void){
           if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
               AVCaptureDevice.requestAccess(for: AVMediaType.video) { (b) in
                   queueMainAsync(work: {
                       if b {
                           cb(true)
                       }
                       else
                       {
                         showAlertController(baseVC, title: "无法访问您的摄像头", message: "请到[设置 ->隐私->相机]打开访问权限")
                        }
                   })
               }
           }
           else
           {
                showAlertController(baseVC, title: "无法访问您的摄像头", message: "请到[设置 ->隐私->相机]打开访问权限")
           }
    }
    
    
    @objc open  class func showAlertController(_ baseVC : UIViewController , title : String , message : String)
    {
        let alertController = UIAlertController(title: title,message: message, preferredStyle: .alert)
         let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
         let okAction = UIAlertAction(title: "确定", style: .default, handler: {
             action in
            let _ = AppOperation.openURL(UIApplication.openSettingsURLString)
         })
         alertController.addAction(cancelAction)
         alertController.addAction(okAction)
         baseVC.present(alertController, animated: true, completion: nil)
    }
    
    //设置静音播放
    @objc open  class func beginReceivingRemoteControlEvents(){
        do {
          let session = AVAudioSession.sharedInstance()
          if #available(iOS 10.0, *) {
            try session.setCategory(AVAudioSession.Category.playback)
          } else {
              // Fallback on earlier versions
          }
          try session.setActive(true)
          UIApplication.shared.beginReceivingRemoteControlEvents()
      } catch {
          
      }
    }
    
}
