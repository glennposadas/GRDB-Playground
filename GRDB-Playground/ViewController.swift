//
//  ViewController.swift
//  GRDB-Playground
//
//  Created by Glenn Posadas on 5/22/22.
//

import Combine
import GRDB
import UIKit

class VM {
  var cancellables = Set<AnyCancellable>()
  
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
  
  func start() {
    postPublisher
      .removeDuplicates()
      .sink { completion in
        
      } receiveValue: { posts in
                
        print("===============")
        print("RECEIVE VALUE! ✅: \(posts)")
        print("===============")
        
      }.store(in: &cancellables)
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

class ViewController: UIViewController {

  let vm = VM()
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    vm.start()
  }
}
