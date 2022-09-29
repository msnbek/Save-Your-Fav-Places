//
//  toMapViewController.swift
//  Travel Book
//
//  Created by Mahmut Şenbek on 29.09.2022.
//

import UIKit

class toMapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addNewLocation) )
        // Do any additional setup after loading the view.
    }
    @objc func addNewLocation() {
        
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }

    

}
