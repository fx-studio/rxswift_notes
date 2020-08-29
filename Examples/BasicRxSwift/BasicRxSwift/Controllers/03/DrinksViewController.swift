//
//  DrinksViewController.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 8/28/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DrinksViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private let bag = DisposeBag()
    private let drinks = BehaviorRelay<[Drink]>(value: [])
    var categoryName: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        
        drinks
            .asObservable()
            .subscribe(onNext: { [weak self] drinks in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.title = "\(self!.categoryName) (\(drinks.count))"
                }
            })
            .disposed(by: bag)
        
        loadAPI()
    }
    
    // MARK: - Private Methods
    private func configUI() {
        title = categoryName
        
        let nib = UINib(nibName: "DrinkCell", bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func loadAPI() {
        Networking.shared().getDrinks(kind: "c", value: categoryName)
            .bind(to: drinks)
            .disposed(by: bag)
    }

}

extension DrinksViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        drinks.value.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DrinkCell
        
        let item = drinks.value[indexPath.row]
        cell.nameLabel.text = item.strDrink
        cell.thumbnailImageView.kf.setImage(with: URL(string: item.strDrinkThumb)!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}
