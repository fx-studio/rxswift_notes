//
//  CitiesViewController.swift
//  TableViewWithRxSwift
//
//  Created by Tien Le P. VN.Danang on 2/16/22.
//

import UIKit
import RxSwift
import RxCocoa

class CitiesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var bag = DisposeBag()
    private var cities = ["Hà Nội","Hải Phòng", "Vinh", "Huế", "Đà Nẵng", "Nha Trang", "Đà Lạt", "Vũng Tàu", "Hồ Chí Minh"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title
        title = "Cities"
        
        // register cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // create observable
        let observable = Observable.of(cities)
        // bind to tableview
        observable
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { (index, element, cell) in
                cell.textLabel?.text = element
            }
            .disposed(by: bag)
        
        // selected cell
        tableView.rx
            .modelSelected(String.self)
            .subscribe(onNext: { element in
                print("Selected \(element)")
            })
            .disposed(by: bag)
        
        // de-selected index
        tableView.rx
            .itemDeselected
            .subscribe(onNext: { indexPath in
                print("Deselected with indextPath: \(indexPath)")
            })
            .disposed(by: bag)
    }
}
