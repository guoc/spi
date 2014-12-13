//
//  ViewController.swift
//  SPi
//
//  Created by GuoChen on 2/12/2014.
//  Copyright (c) 2014 guoc. All rights reserved.
//

import UIKit

class ViewController: UINavigationController, IASKSettingsDelegate {
    
    override init() {
        var appSettingsViewController = IASKAppSettingsViewController()
        super.init(rootViewController: appSettingsViewController)
        appSettingsViewController.delegate = self
        appSettingsViewController.showCreditsFooter = false
        appSettingsViewController.showDoneButton = false
        appSettingsViewController.title = "SPi 双拼输入法"
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
                return imageView
            }
        }
        return nil
    }
    
//    override func viewWillAppear(animated: Bool) {
//        self.setNavigationBarHidden(true, animated: animated)
//        super.viewWillAppear(animated)
//    }
//
//    override func viewWillDisappear(animated: Bool) {
//        self.setNavigationBarHidden(false, animated: animated)
//        super.viewWillDisappear(animated)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blueColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

