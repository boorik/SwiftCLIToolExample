// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import FileProvider

enum Scale: String, Codable {
    case one = "1x"
    case two = "2x"
    case three = "3x"
}

struct ImageContent: Codable {
    let filename: String
    var idiom = "universal"
    let scale: Scale
}

struct Info: Codable {
    var author = "assetImporter"
    var version = 1
}

struct AssetContent: Codable {
    let images: [ImageContent]
    var info = Info()
}

enum FileExportError: Error {
    case copy1x(Error)
    case copy2x(Error)
    case jsonCreation(Error)
    case noImageset(String)

    var localizedDescription: String {
        switch self {
        case .copy1x(let error):
            "error during copy of 1x: \(error.localizedDescription)"
        case .copy2x(let error):
            "error during copy of 2x: \(error.localizedDescription)"
        case .jsonCreation(let error):
            "error during json creation: \(error.localizedDescription)"
        case .noImageset(let path):
            "imageset doesn't exist, path: \(path)"
        }
    }
}

@main
struct AssetsImporter: ParsableCommand {
    static let configuration: CommandConfiguration = CommandConfiguration(
        commandName: "AssetsImporter",
        abstract: "import assets provided by Random Company to Resources",
        usage: nil,
        discussion: "imagesets should exists",
        version: "1.0.0",
        shouldDisplay: true,
        subcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong
    )

    @Argument(help: "the source folder, ex: /Users/someone/Downloads/PICTOGRAMME/Shield")
    var sourceFolder: String

    @Argument(help: "the destination folder, ex: /Users/someone/Projects/MyAwesomeApp/Resources/Shield")
    var destinationFolder: String

    @Flag(help: "Create imagesets if not exists. Should be use only after a first run to see if asset naming is good.")
    var createImageset: Bool = false    

    @Flag(help: "Loop on all folders in the source folder")
    var multipleFolder: Bool = false

    mutating func run() throws {
        let importer = ImageImporter()
//        if multipleFolder {
//            try importer.importMultipleFolders(
//                sourceFolder: sourceFolder,
//                destinationFolder: destinationFolder,
//                createImageset: createImageset
//            )
//            return
//        }
        try importer.importOneFolder(
            sourceFolder: sourceFolder,
            destinationFolder: destinationFolder,
            createImageset: createImageset
        )
    }
}
