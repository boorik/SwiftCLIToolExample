//
//  ContentView.swift
//  MyAwesomeApp
//
//  Created by vincent blanchet on 17/04/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var armor: ArmorType = .boot
    @State private var rarity: Rarity = .common
    @State private var metal: Metal = .iron
    @State private var rank: Rank = .king
    @State private var imageId: String = ""
    var body: some View {
        VStack {
            Spacer()
            Image("\(armor.rawValue)_\(rarity.rawValue)_\(metal.rawValue)_\(rank.rawValue)", bundle: nil)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer()

            Grid(alignment: .center) {
                GridRow {
                    Picker("Armor", selection: $armor) {
                        ForEach(ArmorType.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    Picker("Rarity", selection: $rarity) {
                        ForEach(Rarity.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                }
                GridRow {
                    Picker("Metal", selection: $metal) {
                        ForEach(Metal.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }

                    Picker("Rank", selection: $rank) {
                        ForEach(Rank.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
