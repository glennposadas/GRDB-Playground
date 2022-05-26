//
//  ViewController.swift
//  GRDB-Playground
//
//  Created by Glenn Posadas on 5/22/22.
//

import Combine
import GRDB
import UIKit

// MARK: - ViewModel

class VM {
  
  var postPublisher: DatabasePublishers.Value<[Post]> {
    let dbWriter = AppDB.shared.dbWriter
    let publisher = ValueObservation
      .tracking { db in
        try Post
          .fetchAll(db)
      }
      .publisher(in: dbWriter)
    return publisher
  }
  
  func newPost() -> Post {
    Post(id: UUID().uuidString, content: Lorem.shortTweet, createdAt: Date())
  }
  
  func savePost(_ post: Post) {
    do {
      try AppDB.shared.dbWriter.write { db in
        var p = post
        try p.save(db)
      }
      
      print("Saved!")
      
    } catch {
      print("ERROR!: \(error.localizedDescription)")
    }
  }
  
  func post(_ id: String) -> Post? {
    do {
      let post = try AppDB.shared.dbWriter.read { db in
        try Post
          .filter(Column("id") == id)
          .fetchOne(db)
      }
      return post
    } catch {
      return nil
    }
  }
  
  func allPosts() -> [Post]? {
    do {
      let posts = try AppDB.shared.dbWriter.read { db in
        try Post
          .fetchAll(db)
      }
      return posts
    } catch {
      return nil
    }
  }
}

// MARK: - ViewController


class ViewController: UITableViewController {
  
  var cancellables = Set<AnyCancellable>()
  
  let vm = VM()
  
  enum Section: Hashable {
    case main
  }
  
  typealias DS = UITableViewDiffableDataSource<Section, Post>
  
  lazy var datasource: DS = {
    let datasource = DS(tableView: tableView, cellProvider: { (tableView, indexPath, post) -> Cell? in
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? Cell
      cell?.idLabel.text = "Idx: \(post.idx ?? 0)\nId: \(post.id)"
      cell?.contentLabel.text = post.content
      return cell
    })
    
    return datasource
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //    vm
    //      .postPublisher
    //      .removeDuplicates()
    //      .sink { completion in
    //
    //      } receiveValue: { [weak self] posts in
    //
    //        guard let self = self else {
    //          return
    //        }
    //
    //        print("===============")
    //        print("RECEIVE VALUE! ✅: \(posts)")
    //        print("===============")
    //
    //        var snapshot = self.datasource.snapshot()
    //
    //        if !snapshot.sectionIdentifiers.contains(.main) {
    //          snapshot.appendSections([.main])
    //        }
    //
    //        snapshot.appendItems(posts, toSection: .main)
    //        self.datasource.apply(snapshot)
    //
    //        self.tableView.scrollToRow(at: IndexPath(row: posts.count - 1, section: 0), at: .bottom, animated: true)
    //
    //      }.store(in: &cancellables)
    
    guard let posts = vm.allPosts() else {
      return
    }
    
    var snapshot = self.datasource.snapshot()
    
    if !snapshot.sectionIdentifiers.contains(.main) {
      snapshot.appendSections([.main])
    }
    
    snapshot.appendItems(posts, toSection: .main)
    self.datasource.apply(snapshot)
    
    self.tableView.scrollToRow(at: IndexPath(row: posts.count - 1, section: 0), at: .bottom, animated: true)
  }
  
  @IBAction func newPost(_ sender: Any) {
    let a = vm.newPost()
    vm.savePost(a)
    
    let p = vm.post(a.id)!
    
    var snapshot = datasource.snapshot()
    
    snapshot.appendItems([p], toSection: .main)
    datasource.apply(snapshot)
    
    tableView.scrollToRow(at: IndexPath(row: snapshot.numberOfItems - 1, section: 0), at: .bottom, animated: true)
  }
  
  @IBAction func add100Posts(_ sender: Any) {
    for _ in 1...100 {
      let p = vm.newPost()
      vm.savePost(p)
    }
  }
  
  @IBAction func editLastPost(_ sender: Any) {
    guard let posts = vm.allPosts() else {
      return
    }
    
    print("Post count: \(posts.count)")
    
    guard var last = posts.last else {
      return
    }
    
    var snapshot = datasource.snapshot()
    
    snapshot.deleteItems([last])
    
    last.content = last.content + "✅"
    try? AppDB.shared.save(&last)
    
    snapshot.appendItems([last], toSection: .main)
    datasource.apply(snapshot)
    
    tableView.scrollToRow(at: IndexPath(row: snapshot.numberOfItems - 1, section: 0), at: .bottom, animated: true)
  }
}

// MARK: - UITableViewCell

class Cell: UITableViewCell {
  @IBOutlet weak var idLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
}
