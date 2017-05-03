//
//  GridEditorViewController.swift
//  GameOfLife
//
//  Created by Benjamin Hendricks on 03/05/2017.
//  Copyright © 2017 coolbnjmn. All rights reserved.
//

import UIKit

class GridEditorViewController: UIViewController, StoryboardIdentifiable {

    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var saveButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
    }
    
}
