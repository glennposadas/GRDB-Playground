import Foundation
import GRDB

extension DatabaseMigrator {
  mutating func v1_0() {
    registerMigration("1.0") { db in
      /**
       Post
       */
      try db.create(table: "post") { table in
        table.autoIncrementedPrimaryKey("idx")
        table.column("id", .text).unique()
        table.column("content", .text).notNull()
        table.column("createdAt", .datetime)
        table.column("updatedAt", .datetime)
      }
    }
  }
}
