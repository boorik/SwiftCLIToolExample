//
//  File.swift
//  
//
//  Created by vincent blanchet on 17/04/2024.
//

import Foundation
import OSLog

package struct ImageImporter {
    package init() {
    }

    let fileManager = FileManager()

    fileprivate func cleanImagesetFolder(_ imagesetPath: String) {
        Logger.importer.info("cleaning \(imagesetPath)")
        try? fileManager.contentsOfDirectory(atPath: imagesetPath).forEach { imagesetFile in
            let itemToRemove = "\(imagesetPath)/\(imagesetFile)"
            try fileManager.removeItem(atPath: itemToRemove)
            print("deleted \(itemToRemove)")
        }
    }

    fileprivate func copy1xScale(sourceFolder: String, fileName: String, imagesetPath: String) throws {
        Logger.importer.info("copying 1x scale")
        let sourcePath = "\(sourceFolder)/\(fileName)"
        let destinationPath = "\(imagesetPath)/\(fileName)"
        do {
            try fileManager.copyItem(
                atPath: sourcePath,
                toPath: destinationPath
            )
        } catch {
            throw FileExportError.copy1x(error)
        }
        Logger.importer.info("created \(destinationPath)")
    }

    fileprivate func copy2xScale(sourceFolder: String, fileName: String, _ imagesetPath: String) throws {
        Logger.importer.info("copying 2x scale")
        let retinaName = getRetinaNameFrom(fileName: fileName)
        do {
            try fileManager.copyItem(
                atPath: "\(sourceFolder)/RETINA/\(fileName)",
                toPath: "\(imagesetPath)/\(retinaName)"
            )
        } catch {
            throw FileExportError.copy2x(error)
        }
        Logger.importer.info("created \(imagesetPath)/\(retinaName)")
    }

    func getRetinaNameFrom(fileName: String) -> String {
        let fileNameWithoutExtension = fileName.prefix(upTo: fileName.lastIndex(of: ".") ?? fileName.endIndex)
        return "\(fileNameWithoutExtension)@2x.png"
    }

    fileprivate func createContentsJson(_ fileName: String, _ imagesetPath: String) throws {
        let asset = AssetContent(images: [
            ImageContent(filename: fileName, scale: .one),
            ImageContent(filename: getRetinaNameFrom(fileName: fileName), scale: .two)
        ])

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let encodedJson = try encoder.encode(asset)
            fileManager.createFile(atPath: "\(imagesetPath)/Contents.json", contents: encodedJson)
            Logger.importer.info("created \(imagesetPath)/content.json")
        } catch {
            throw FileExportError.jsonCreation(error)
        }
    }


    /// Create assets for one folder
    /// - Parameters:
    ///   - sourceFolder: the source folder, ex: /Users/someone/Downloads/PICTOGRAMME/Shield
    ///   - destinationFolder: the destination folder, ex: /Users/someone/Projects/MyAwesomeApp/Resources/Shield
    ///   - createImageset: Create imagesets if not exists. Should be use only after a first run to see if asset naming is good.
    package func importOneFolder(
        sourceFolder: String,
        destinationFolder: String,
        createImageset: Bool = false
    ) throws {
        Logger.importer.info("importation started")
        Logger.importer.info("reading: \(sourceFolder)")
        Logger.importer.info("destination: \(destinationFolder)")
        var errors = [FileExportError]()
        var success = 0
        try fileManager.contentsOfDirectory(atPath: sourceFolder).forEach { fileName in
            guard isPng(fileName: fileName) else { return }
            print("📲 processing \(fileName)")
            let imageset = destinationImagesetNameFrom(
                sourceFileName: fileName,
                sourceFolder: sourceFolder,
                destinationFolder: destinationFolder
            )

            let imagesetPath = "\(destinationFolder)/\(imageset)"

            do {
                try checkIfImagesetExists(imagesetPath, shouldCreate: createImageset)

                cleanImagesetFolder(imagesetPath)

                try copy1xScale(sourceFolder: sourceFolder, fileName: fileName, imagesetPath: imagesetPath)

                try copy2xScale(sourceFolder: sourceFolder, fileName: fileName, imagesetPath)

                try createContentsJson(fileName, imagesetPath)

                success += 1
            } catch {
                Logger.importer.error("\(error)")
                if let fileExport = error as? FileExportError {
                    errors.append(fileExport)
                }
            }
        }

        displayExecutionReport(success: success, errors: errors)
    }

    private func checkIfImagesetExists(_ imagesetPath: String, shouldCreate: Bool) throws {
        if !fileManager.fileExists(atPath: imagesetPath) {
            if shouldCreate {
                Logger.importer.info("\(imagesetPath) does not exists. Creating...")
                try fileManager.createDirectory(atPath: imagesetPath, withIntermediateDirectories: false)
                Logger.importer.info("Imageset created")
            } else {
                throw FileExportError.noImageset(imagesetPath)
            }
        }
    }

    private func displayExecutionReport(success: Int, errors: [FileExportError]) {
        if errors.isEmpty {
            Logger.importer.info("🎉 \(success) assets successfully exported !")
        } else {
            Logger.importer.info("⚠️ export completed with \(errors.count) errors, \(success) assets successfully exported")
            errors.forEach { error in
                print(error.localizedDescription)
                print("-------------")
            }
        }
    }

    private func isPng(fileName: String) -> Bool {
        fileName.contains(".png")
    }

    private func destinationImagesetNameFrom(sourceFileName: String, sourceFolder: String, destinationFolder: String) -> String {
        var mutableFolder = sourceFolder
        if mutableFolder.last == "/" {
            mutableFolder.removeLast()
        }
        let components = mutableFolder.components(separatedBy: "/")
        let prefix = components.last ?? ""
        let fileNameWithoutExtension = sourceFileName.prefix(upTo: sourceFileName.lastIndex(of: ".") ?? sourceFileName.endIndex)
        return "\(prefix)_\(fileNameWithoutExtension).imageset"
    }
}
