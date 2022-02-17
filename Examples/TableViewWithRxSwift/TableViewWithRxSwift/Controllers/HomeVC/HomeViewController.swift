//
//  HomeViewController.swift
//  TableViewWithRxSwift
//
//  Created by Tien Le P. VN.Danang on 2/14/22.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell --> cho #1
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // setup data cho TableView
        bindTableView()
        
        // Liên quan tới model hay chính là các item của data
        tableView.rx
            .modelSelected(String.self)
            .subscribe(onNext: { item in
                print("Selected with \(item)")
            })
            .disposed(by: bag)
        
        // de-selected --> liên quan tới cell hay là indexPath
        tableView.rx
            .itemDeselected
            .subscribe(onNext: { indexPath in
                print("Deselected with indextPath: \(indexPath)")
            })
            .disposed(by: bag)
        
        // set delegate cho UITableView
        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)

    }
    
    // Tiến hành bind dữ liệu lên UITableView
    func bindTableView() {
        
        // Tạo một Observable từ 1 array String cho trước
        let cities = Observable.of(["Hà Nội","Hải Phòng", "Vinh", "Huế", "Đà Nẵng", "Nha Trang", "Đà Lạt", "Vũng Tàu", "Hồ Chí Minh"])
        
        // Tiến hành đưa dữ liệu lên UITableView bằng phương thức .bind()
        // #1 là có register cell như bình thường
//        cities
//            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { (index, element, cell) in
//                cell.textLabel?.text = element
//            }
//            .disposed(by: bag)
        
        // #2 là auto tự sinh cell luôn, ưu điểm không cần register cell
        cities
            .bind(to: tableView.rx.items) { (tableView: UITableView, index: Int, element: String) in
                // cách này xem như bạn tạo đối tượng cell mới
                let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
                cell.textLabel?.text = element
                // return
                return cell
            }
            .disposed(by: bag)
    }

}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("UITableViewDelegate --> did selected with \(indexPath)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
