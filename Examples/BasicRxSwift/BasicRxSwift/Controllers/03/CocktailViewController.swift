//
//  CocktailViewController.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 8/28/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CocktailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private let bag = DisposeBag()
    private let categories = BehaviorRelay<[CocktailCategory]>(value: [])
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        
        categories
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            })
            .disposed(by: bag)
        
        loadAPI()
    }
    
    // MARK: - Private Methods
    private func configUI() {
        title = "The Cocktail"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func loadAPI() {
        let newCategories = Networking.shared().getCategories(kind: "c")
        
        let downloadItems = newCategories
            .flatMap { categories in
                return Observable.from(categories.map { category in
                    Networking.shared().getDrinks(kind: "c", value: category.strCategory)
                })
            }
            .merge(maxConcurrent: 2)
       
        let updateCategories = newCategories.flatMap { categories  in
            downloadItems
                .enumerated()
                .scan([]) { (updated, element:(index: Int, drinks: [Drink])) -> [CocktailCategory] in
                    
                    var new: [CocktailCategory] = updated
                    new.append(CocktailCategory(strCategory: categories[element.index].strCategory, items: element.drinks))
                    
                    return new
            }
        }

        updateCategories
            .bind(to: categories)
            .disposed(by: bag)
    }

}

extension CocktailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let item = categories.value[indexPath.row]
        cell.textLabel?.text = "\(item.strCategory) - \(item.items.count) items"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = categories.value[indexPath.row]
        print("\(item.strCategory) - \(item.items.count) items")
        
        let vc = DrinksViewController()
        vc.categoryName = item.strCategory
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
