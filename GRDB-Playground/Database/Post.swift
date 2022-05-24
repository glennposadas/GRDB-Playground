import CloudKit
import Foundation
import GRDB

struct Post: Identifiable {
  var idx: Int64?
  var id: String
  var content: String
  let createdAt: Date?
  var updatedAt: Date?
}

// MARK: - Hashable, Equatable

extension Post: Hashable, Equatable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(content)
  }
  
  static func ==(lhs: Post, rhs: Post) -> Bool {
    return lhs.id == rhs.id && lhs.content == rhs.content
  }
}

// MARK: - MutablePersistableRecord

extension Post: MutablePersistableRecord {
  static let persistenceConflictPolicy = PersistenceConflictPolicy(
    insert: .replace,
    update: .replace
  )
}

// MARK: - Codable, FetchableRecord

extension Post: Codable, FetchableRecord {
  fileprivate enum Columns {
    static let id = Column(CodingKeys.id)
    static let createdAt = Column(CodingKeys.createdAt)
    static let updatedAt = Column(CodingKeys.updatedAt)
    static let content = Column(CodingKeys.content)
  }
  
  enum CodingKeys: CodingKey {
    case idx, id, createdAt, updatedAt, content
  }
}

// MARK: - CustomStringConvertible

extension Post: CustomStringConvertible {
  var description: String {
    "💭 Post ID: \(id) | content: \(content)"
  }
}
