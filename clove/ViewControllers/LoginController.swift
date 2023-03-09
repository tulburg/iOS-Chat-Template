//
//  ViewController.swift
//  clove
//
//  Created by Tolu Oluwagbemi on 07/03/2023.
//

import UIKit

class LoginViewController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .background
        
        Api.main.start { data, error in
            if let responseData = data {
                let user = Response<DataType.Message>(responseData.json() as NSDictionary)
                print(user.message!)
            }
        }
        
        Api.main.send { data, error in
            if let response = data {
                let message = Response<DataType.Message>(response.json() as NSDictionary)
                print(message.data?.recipient, message.status!)
            }
        }
        
        let button = ButtonXL("Open messages", action: #selector(openMessages))
        button.setTitleColor(.white, for: .normal)
        view.addSubview(button)
        view.constrain(type: .horizontalCenter, button)
        view.constrain(type: .verticalCenter, button)
        
    }
    
    @objc func openMessages() {
        let messagerVC = MessagerViewController()
        navigationController?.pushViewController(messagerVC, animated: true)
    }


}

