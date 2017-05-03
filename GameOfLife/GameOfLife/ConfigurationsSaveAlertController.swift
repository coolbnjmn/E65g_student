//
//  ConfigurationsSaveAlertController.swift
//  GameOfLife
//
//  Created by Benjamin Hendricks on 5/3/17.
//  Copyright © 2017 coolbnjmn. All rights reserved.
//

import UIKit

class ConfigurationsSaveAlertController {
    
    static func displayNameExistsAlert(presentingViewController: UIViewController, completion: @escaping ()->Void) {
        let alertController = UIAlertController(title: Constants.Strings.configurationExistsAlertTitle, message: Constants.Strings.configurationExistsAlertMessage, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: Constants.Strings.configurationExistsReplaceConfirmButtonTitle, style: .destructive, handler: {
            action in
            completion()
        })
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: Constants.Strings.configurationExistsReplaceCancelButtonTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            presentingViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    static func displayContentsExistsOverrideAlert(presentingViewController: UIViewController, completion: @escaping ()->Void) {
        let alertController = UIAlertController(title: Constants.Strings.configurationExistsAlertTitle, message: Constants.Strings.displayContentsExistsOverrideAlertMessage, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: Constants.Strings.configurationExistsReplaceConfirmButtonTitle, style: .destructive, handler: {
            action in
            completion()
        })
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: Constants.Strings.configurationExistsReplaceCancelButtonTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            presentingViewController.present(alertController, animated: true, completion: nil)
        }
    }
}
