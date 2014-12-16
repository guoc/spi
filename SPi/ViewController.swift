//
//  ViewController.swift
//  SPi
//
//  Created by GuoChen on 2/12/2014.
//  Copyright (c) 2014 guoc. All rights reserved.
//

import UIKit

class ViewController: UINavigationController, IASKSettingsDelegate {
    
    var appSettingsViewController: IASKAppSettingsViewController!
    
    override init() {
        var appSettingsViewController = IASKAppSettingsViewController()
        super.init(rootViewController: appSettingsViewController)
        appSettingsViewController.delegate = self
        appSettingsViewController.showCreditsFooter = false
        appSettingsViewController.showDoneButton = false
        appSettingsViewController.title = "SPi 双拼输入法"
        self.appSettingsViewController = appSettingsViewController
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func settingsViewControllerDidEnd(sender: IASKAppSettingsViewController!) {
        
    }
    
    func settingsViewController(settingsViewController: IASKViewController!, tableView: UITableView!, heightForHeaderForSection section: Int) -> CGFloat {
        if let key = settingsViewController.settingsReader.keyForSection(section) {
            if key == "kScreenshotTapKeyboardSettingsIcon" {
                return UIImage(named: "Screenshot tap keyboard settings icon")!.size.height
            }
        }
        return 0
    }

    func settingsViewController(settingsViewController: IASKViewController!, tableView: UITableView!, viewForHeaderForSection section: Int) -> UIView! {
        if let key = settingsViewController.settingsReader.keyForSection(section) {
            if key == "kScreenshotTapKeyboardSettingsIcon" {
                var imageView = UIImageView(image: UIImage(named: "Screenshot tap keyboard settings icon"))
                imageView.contentMode = .ScaleAspectFit
                return imageView
            }
        }
        return nil
    }
    
    func settingsViewController(sender: IASKAppSettingsViewController!, buttonTappedForSpecifier specifier: IASKSpecifier!) {
        if specifier.key() == "kFeedback" {
            UserVoice.presentUserVoiceInterfaceForParentViewController(self)
        }
    }
    
    func pushToTutorialIfNecessary() {
        if isCustomKeyboardEnabled() == false {
            self.appSettingsViewController.tableView(self.appSettingsViewController.tableView, didSelectRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blueColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isCustomKeyboardEnabled() -> Bool {
        let bundleID = "name.guoc.SPi.SPiKeyboard"
        if let keyboards: [String] = NSUserDefaults.standardUserDefaults().dictionaryRepresentation()["AppleKeyboards"] as? [String] {   // Array of all active keyboards
            for keyboard in keyboards {
                if keyboard == bundleID {
                    return true
                }
            }
        }
        return false
    }
    

}

