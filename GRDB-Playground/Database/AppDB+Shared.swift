import GRDB
import Foundation

extension AppDB {
  /// The database for the application
  static var shared = makeShared()
  
  /// We are recreating the database by  deleting the DB file.
  /// We need to recreate the DB to reset the sequences (ie index column row count).
  static func recreateDB() {
    do {
      let path = try getFolderURL().path
      try FileManager.default.removeItem(atPath: path)
      shared = makeShared()
    } catch {
      print("error")
    }
  }
  
  /// Method for generating Singleton. Taken from GRDB sample.
  private static func makeShared() -> AppDB {
    do {
      let dbURL = try getDatabaseURL()
      let dbPool = try DatabasePool(path: dbURL.path)
      
      print("Chaos Database file path: \(dbURL.path)")
      
      // Create the AppDatabase
      let appDatabase = try AppDB(dbPool)
      
      return appDatabase
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate.
      //
      // Typical reasons for an error here include:
      // * The parent directory cannot be created, or disallows writing.
      // * The database is not accessible, due to permissions or data protection when the device is locked.
      // * The device is out of space.
      // * The database could not be migrated to its latest schema version.
      // Check the error message to determine what the actual problem was.
      fatalError("Unresolved error \(error)")
    }
  }
  
  private static func getFolderURL(_ fileManager: FileManager = FileManager()) throws -> URL {
    let folderURL = try fileManager
      .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
      .appendingPathComponent("database", isDirectory: true)
    return folderURL
  }
  
  private static func getDatabaseURL() throws -> URL {
    // Create a folder for storing the SQLite database, as well as
    // the various temporary files created during normal database
    // operations (https://sqlite.org/tempfiles.html).
    let fileManager = FileManager()
    let folderURL = try getFolderURL(fileManager)
    try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
    
    // Connect to a database on disk
    // See https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections
    let dbURL = folderURL.appendingPathComponent("db.sqlite")
    return dbURL
  }
}
