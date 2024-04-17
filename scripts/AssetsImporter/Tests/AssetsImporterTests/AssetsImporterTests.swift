//
//  AssetsImporterTests.swift
//  
//
//  Created by vincent blanchet on 17/04/2024.
//

import XCTest
import AssetsImporter

final class AssetsImporterTests: XCTestCase {
    let fileManager = FileManager()
    lazy var currentFolder: URL = {
        URL(string: #filePath)?.deletingLastPathComponent() ?? URL.currentDirectory()
    }()

    lazy var assetsFolder: URL = {
        var folder = currentFolder
        for _ in 0...3 { folder = folder.deletingLastPathComponent() }
        folder.append(path: "dataToImport/ImageBundle")
        return folder
    }()

    lazy var exportFolder: URL = currentFolder.appendingPathComponent("results")

    override func setUpWithError() throws {
        try? fileManager.removeItem(atPath: exportFolder.absoluteString)
        try fileManager.createDirectory(atPath: exportFolder.absoluteString, withIntermediateDirectories: false)
    }

    override func tearDownWithError() throws {
        try? fileManager.removeItem(atPath: exportFolder.absoluteString)
    }

    func test_single_folder_import_with_imageset_creation() throws {
        let shieldFolder = assetsFolder.appending(component: "shield", directoryHint: .isDirectory)
        let sut = ImageImporter()
        try sut.importOneFolder(
            sourceFolder: shieldFolder.absoluteString,
            destinationFolder: exportFolder.absoluteString,
            createImageset: true
        )

        let filesExported = try fileManager.contentsOfDirectory(at: exportFolder, includingPropertiesForKeys: nil)
        let sourceFiles = try fileManager.contentsOfDirectory(at: shieldFolder, includingPropertiesForKeys: nil).filter { url in
            url.pathExtension == "png"
        }
        XCTAssertEqual(filesExported.count, sourceFiles.count)
    }

    func test_single_folder_import_without_imageset_creation() throws {
        let shieldFolder = assetsFolder.appending(component: "shield", directoryHint: .isDirectory)
        let sut = ImageImporter()
        try sut.importOneFolder(
            sourceFolder: shieldFolder.absoluteString,
            destinationFolder: exportFolder.absoluteString,
            createImageset: true
        )

        let filesExported = try fileManager.contentsOfDirectory(at: exportFolder, includingPropertiesForKeys: nil)

        XCTAssertEqual(filesExported.count, 0)
    }
}
