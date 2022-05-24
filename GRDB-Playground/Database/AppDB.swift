import Foundation
import GRDB

/**
 The Chaos App.Database that uses GRDB layer.
 
 See documentation: https://github.com/groue/GRDB.swift
 */
final class AppDB {
  
  // MARK: - Properties
  
  let dbWriter: DatabaseWriter
  
  private var migrator: DatabaseMigrator {
    var migrator = DatabaseMigrator()
    migrator.v1_0()
    return migrator
  }
  
  // MARK: - Functions
  // MARK: Init
  
  /**
   Init the AppDB.
   
   When writing Unit Tests, pass in a `DatabaseQueue()` for in-memory DB.
   
   Use `shared` (see `AppDB+Shared`) when accessing AppDB functions.
   
   - Parameters:
      - dbWriter: a DatabaseWriter (eg. `DatabaseQueue()`).
   */
  init(_ dbWriter: DatabaseWriter) throws {
    self.dbWriter = dbWriter
    try migrator.migrate(dbWriter)
  }
  
  // MARK: - Common
  
  /**
   Executes an INSERT or an UPDATE statement so that self is saved in the database.

   If the receiver has a non-nil primary key and a matching row in the database, this method performs an update.
   Otherwise, performs an insert.
   
   save() is unchanged: it still falls back to insert when record has no primary key or nil primary key, and thus generates INSERT OR REPLACE.
   
   See: GRDB's `save` for  complete documentation.
   
   - Parameter t:  Any MutablePersistableRecord.
   */
  func save<T: MutablePersistableRecord>(_ t: inout T) throws {
    try dbWriter.write { db in
      try t.save(db)
    }
  }
  
  /**
   Executes an INSERT statement.

   This method is guaranteed to have inserted a row in the database if it returns without error.
   Upon successful insertion, the didInsert(with:for:) method is called with the inserted RowID and the eventual INTEGER PRIMARY KEY column name.
   
   insert() always generates INSERT OR REPLACE
   
   See: GRDB's `insert` for  complete documentation.
   
   - Parameter t:  Any MutablePersistableRecord.
   */
  func insert<T: MutablePersistableRecord>(_ t: inout T) throws {
    try dbWriter.write { db in
      try t.insert(db)
    }
  }
}
