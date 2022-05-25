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
}

// MARK: - ViewController


class ViewController: UITableViewController {
  
  var cancellables = Set<AnyCancellable>()
  
  let vm = VM()
  
  typealias DS = UITableViewDiffableDataSource<Int, Post>
  
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
    
    vm
      .postPublisher
      .removeDuplicates()
      .sink { completion in
        
      } receiveValue: { [weak self] posts in
        
        guard let self = self else {
          return
        }
        
        print("===============")
        print("RECEIVE VALUE! ✅: \(posts)")
        print("===============")
        
        var snapshot = self.datasource.snapshot()
        snapshot.deleteAllItems()
        
        snapshot.appendSections([0])
        snapshot.appendItems(posts, toSection: 0)
        self.datasource.apply(snapshot)
        
        self.tableView.scrollToRow(at: IndexPath(row: posts.count - 1, section: 0), at: .bottom, animated: true)
        
      }.store(in: &cancellables)
  }
  
  @IBAction func newPost(_ sender: Any) {
    let p = vm.newPost()
    vm.savePost(p)
  }
  
}

// MARK: - UITableViewCell

class Cell: UITableViewCell {
  @IBOutlet weak var idLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
}
