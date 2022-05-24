import Foundation
import GRDB

public final class Database {
  
  let dbWriter: DatabaseWriter

  private var migrator: DatabaseMigrator {
    
    var migrator = DatabaseMigrator()
    
    migrator.registerMigration("1.0") { db in
      try db.create(table: "user") { table in
        table.column("id", .text).unique()
        table.column("firstName", .text).notNull().defaults(to: "")
      }
    }
    return migrator
  }

  init(_ dbWriter: DatabaseWriter) throws {
    self.dbWriter = dbWriter
    try migrator.migrate(dbWriter)
  }
}
