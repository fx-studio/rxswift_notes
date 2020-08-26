//
//  MusicListViewController.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 8/26/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class MusicListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private let urlMusic = "https://rss.itunes.apple.com/api/v1/us/itunes-music/new-music/all/100/explicit.json"
    private let bag = DisposeBag()
    private var musics: [Music] = []
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        loadAPI()
    }
    
    // MARK: - Private Methods
    private func configUI() {
        title = "New Music"
        
        let nib = UINib(nibName: "MusicCell", bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func loadAPI() {
        let observable = Observable<String>.of(urlMusic)
            .map { urlString -> URL in
                return URL(string: urlString)!
            }
            .map { url -> URLRequest in
                return URLRequest(url: url)
            }
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }
            .share(replay: 1)
        
        observable
            .filter { response, _ -> Bool in
                return 200..<300 ~= response.statusCode
            }
            .map { _, data -> [Music] in
                let decoder = JSONDecoder()
                let results = try? decoder.decode(FeedResults.self, from: data)
                return results?.feed.results ?? []
            }
            .filter { objects in
                return !objects.isEmpty
            }
            .subscribe(onNext: { musics in
                DispatchQueue.main.async {
                    self.musics = musics
                    self.tableView.reloadData()
                }
            })
            .disposed(by: bag)
            
        
    }
    
}

extension MusicListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        musics.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MusicCell
        
        let item = musics[indexPath.row]
        cell.nameLabel.text = item.name
        cell.artistNameLabel.text = item.artistName
        cell.thumbnailImageView.kf.setImage(with: URL(string: item.artworkUrl100)!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
