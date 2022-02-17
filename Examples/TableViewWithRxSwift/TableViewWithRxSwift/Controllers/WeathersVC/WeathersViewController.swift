//
//  WeathersViewController.swift
//  TableViewWithRxSwift
//
//  Created by Tien Le P. VN.Danang on 2/16/22.
//

import UIKit
import RxSwift
import RxCocoa

class WeathersViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    
    private var bag = DisposeBag()
    private let citiesName = ["Hà Nội","Hải Phòng", "Vinh", "Huế", "Đà Nẵng", "Nha Trang", "Đà Lạt", "Vũng Tàu", "Hồ Chí Minh"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Weathers"
        
        //register cell
        let nib1 = UINib(nibName: "WeatherCell", bundle: .main)
        tableView.register(nib1, forCellReuseIdentifier: "cell1")
        
        let nib2 = UINib(nibName: "WeatherWithoutStatusCell", bundle: .main)
        tableView.register(nib2, forCellReuseIdentifier: "cell2")

        // bind data
        bindTableView()
        
        // set delegate
        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)
    }
    
    func bindTableView() {
        let citiesObservable = Observable.of(citiesName)
        
//        citiesObservable
//            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: WeatherCell.self)) { (index, element, cell) in
//                cell.cityNameLabel.text = element
//                cell.tempLable.text = "\(Int.random(in: 10...35))°C"
//            }
//            .disposed(by: bag)
        
        citiesObservable
            .bind(to: tableView.rx.items) { (tableView, index, element) in
                let randomStatus = Bool.random()
                let indexPath = IndexPath(row: index, section: 0)
                if randomStatus {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! WeatherCell
                    cell.cityNameLabel.text = element
                    cell.tempLable.text = "\(Int.random(in: 10...35))°C"
                    return cell

                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! WeatherWithoutStatusCell
                    cell.cityNameLabel.text = element
                    cell.tempLable.text = "\(Int.random(in: 10...35))°C"
                    return cell

                }
            }
            .disposed(by: bag)
    }

}

extension WeathersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did selected TableView with \(indexPath)")
    }
}
