//
//  RealmConfig.swift
//  bluepin
//
//  Created by Alex A on 7/16/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import Foundation
import RealmSwift

extension URL {
    
    // returns an absolute URL to the desired file in documents folder
    static func inDocumentsFolder(fileName: String) -> URL {
        return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0], isDirectory: true)
            .appendingPathComponent(fileName)
    }
}


enum RealmConfig {
    
    // MARK: - private configurations
    private static let mainConfig = Realm.Configuration(
        fileURL: URL.inDocumentsFolder(fileName: "main.realm"),
        schemaVersion: 0)
    private static let presetConfig = Realm.Configuration(
        fileURL: Bundle.main.url(forResource: "preset-data", withExtension: "realm"),
        readOnly: true,
        schemaVersion: 0)
    
    
    // MARK: - enum cases
    case main
    case preset
    
    // MARK: - current configuration
    var configuration: Realm.Configuration {
        switch self {
        case .main:
            _ = RealmConfig.copyInitialFile
            return RealmConfig.mainConfig
        case .preset:
            return RealmConfig.presetConfig
        }
    }

    private static var copyInitialFile: Void = {
        copyInitialData(
            Bundle.main.url(forResource: "preset-data", withExtension: "realm")!,
            to: RealmConfig.mainConfig.fileURL!)
    }()
    
    static func copyInitialData(_ from: URL, to: URL) {
        let copy = {
            _ = try? FileManager.default.removeItem(at: to)
            try! FileManager.default.copyItem(at: from, to: to)
            deletePresetReminders()
        }
        
        let exists: Bool
        do {
            exists = try to.checkPromisedItemIsReachable()
        } catch {
            copy()
            return
        }
        if !exists {
            copy()
        }
    }

    static func deletePresetReminders() {
        let realm = try! Realm(configuration: mainConfig)
        do {
            try realm.write {
                let presetReminder = realm.objects(Reminder.self)
                realm.delete(presetReminder)
            }
        } catch {
            print("error")
        }
    }
    
    
}
