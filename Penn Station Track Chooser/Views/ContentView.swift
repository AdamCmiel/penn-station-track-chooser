//
//  ContentView.swift
//  Penn Station Track Chooser
//
//  Created by Adam Cmiel on 5/10/20.
//  Copyright © 2020 Adam Cmiel. All rights reserved.
//
import Combine
import SwiftUI

struct ContentView: View {
    @ObservedObject var data: TrackData

    var body: some View {
        VStack {
            ForEach(data.trackUpdates, id: \.self) { update in
                VStack {
                    Text(update.direction.rawValue)
                        .padding(.all, 10.0)

                    ForEach(update.trainUpdates, id: \.self) { trainUpdate in
                        HStack {
                            Text(trainUpdate.train.rawValue)
                                .padding(.all, 10.0)
                            Text(String(trainUpdate.minutesToArrive))
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView(data: TrackData())
    }
}

private extension TrackData {
    convenience init() {
        let north = TrackUpdate(direction: .northbound,
                                trainUpdates: [
                                   TrainUpdate(train: .C, minutesToArrive: 0),
                                   TrainUpdate(train: .A, minutesToArrive: 5),
                                ])

        let south = TrackUpdate(direction: .southbound,
                                trainUpdates: [
                                   TrainUpdate(train: .E, minutesToArrive: 2),
                                   TrainUpdate(train: .E, minutesToArrive: 7),
                                ])

        self.init(updates: Just([north, south]).eraseToAnyPublisher())
    }
}
