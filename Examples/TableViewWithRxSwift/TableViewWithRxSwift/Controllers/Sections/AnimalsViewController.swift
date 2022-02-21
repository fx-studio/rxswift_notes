//
//  AnimalsViewController.swift
//  TableViewWithRxSwift
//
//  Created by Tien Le P. VN.Danang on 2/18/22.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class AnimalsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var bag = DisposeBag()
    
    // data
    let sections = [
        // section #1
        AnimalSection(header: "Mammals",
                      items: [
                        Animal(name: "Cats"),
                        Animal(name: "Dogs"),
                        Animal(name: "Pigs"),
                        Animal(name: "Elephants"),
                        Animal(name: "Rabbits"),
                        Animal(name: "Tigers")
                      ]),
        // section #2
        AnimalSection(header: "Birds",
                      items: [
                        Animal(name: "Sparrows"),
                        Animal(name: "Hummingbirds"),
                        Animal(name: "Pigeons"),
                        Animal(name: "Doves"),
                        Animal(name: "Bluebirds"),
                        Animal(name: "Cardinal"),
                        Animal(name: "Robin"),
                        Animal(name: "Goldfinch"),
                        Animal(name: "Herons"),
                        Animal(name: "Ducks")
                      ])
    ]
    
    // datasource
    let dataSource = RxTableViewSectionedReloadDataSource<AnimalSection> (
        // cell
        configureCell: { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AnimalCell
            cell.nameLabel.text = item.name
            return cell
        }
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title
        title = "Animals"
        
        // register cell
        let nib = UINib(nibName: "AnimalCell", bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        // set delegate
        tableView
          .rx.setDelegate(self)
          .disposed(by: bag)
        
        // Binding to TableView
        Observable.just(sections)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
    
}

extension AnimalsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("AnimalHeader", owner: self, options: nil)?.first as! AnimalHeader
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        
        headerView.titleLabel.text = dataSource[section].header
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
