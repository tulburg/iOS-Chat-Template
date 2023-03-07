//
//  ViewController.swift
//  clove
//
//  Created by Tolu Oluwagbemi on 07/03/2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .background
        
        Api.main.start { data, error in
            if let responseData = data {
                let user = Response.User.decode(from: responseData)
            }
            if error != nil {
                
            }
        }
    }


}

