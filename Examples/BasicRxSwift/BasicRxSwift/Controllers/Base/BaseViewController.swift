//
//  BaseViewController.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 8/18/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let names = ["Register",
                 "Fetching Data",
                 "Networking Model",
                 "RxCocoa"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "RxSwift Notes"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension BaseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = "\(indexPath.row + 1) : \(names[indexPath.row])"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let vc = RegisterViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            
        case 1:
            let vc = MusicListViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            
        case 2:
            let vc = CocktailViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            
        case 3:
            let vc = WeatherCityViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            
        default:
            print("COMING SOON")
        }
    }
    
    
}
