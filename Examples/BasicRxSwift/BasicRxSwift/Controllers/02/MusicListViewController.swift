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
    private let musicsFileURL = cachedFileURL("musics.json")
    private let bag = DisposeBag()
    private var musics = BehaviorRelay<[Music]>(value: [])
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        
        // read musics file
        let decoder = JSONDecoder()
        if let musicsData = try? Data(contentsOf: musicsFileURL),
           let preMusics = try? decoder.decode([Music].self, from: musicsData) {
            self.musics.accept(preMusics)
        }

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
    
    private func processMusics(newMusics: [Music]) {
        // update UI
        DispatchQueue.main.async {
            self.musics.accept(newMusics)
            self.tableView.reloadData()
        }
        
        // save to file
        let encoder = JSONEncoder()
        if let musicsData = try? encoder.encode(newMusics) {
            try? musicsData.write(to: musicsFileURL, options: .atomicWrite)
        }
    }
    
    // MARK: - API
    private func loadAPI() {
        let response = Observable<String>.of(urlMusic)
            .map { urlString -> URL in
                return URL(string: urlString)!
            }
            .map { url -> URLRequest in
                let request = URLRequest(url: url)
                
                // modified Header here
                
                return request
            }
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }
            .share(replay: 1)
        
        // subscription #1
        response
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
                self.processMusics(newMusics: musics)
            })
            .disposed(by: bag)
    }
    
    // MARK: File plist
    static func cachedFileURL(_ fileName: String) -> URL {
        return FileManager.default
            .urls(for: .cachesDirectory, in: .allDomainsMask)
            .first!
            .appendingPathComponent(fileName)
    }

}

extension MusicListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        musics.value.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MusicCell
        
        let item = musics.value[indexPath.row]
        cell.nameLabel.text = item.name
        cell.artistNameLabel.text = item.artistName
        cell.thumbnailImageView.kf.setImage(with: URL(string: item.artworkUrl100)!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
