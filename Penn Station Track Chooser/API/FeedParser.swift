import Foundation

struct FeedParser {
    let message: TransitRealtime_FeedMessage
}

enum Train: String {
    case A
    case C
    case E
}

enum Station: String {
    case PennStation = "A28"

    var trains: [Train] {
        switch self {
        case .PennStation:
            return [.A, .C, .E]
        }
    }
}

enum Direction: CaseIterable {
    case northbound
    case southbound
}

enum Track {
    case local
    case express
}

struct TrainUpdate {
    let train: Train
    let minutesToArrive: Int
}

struct TrackUpdate {
    let direction: Direction
    let trainUpdates: [TrainUpdate]
}

extension FeedParser {
    func trackUpdates(at station: Station) -> [TrackUpdate] {
        let trains = station.trains

        let entities = message.entity.filter { entity in
            entity.tripUpdate.stopTimeUpdate.filter { update in
                return update.stopID.contains(station.rawValue)
            }.count > 0
        }

        return Direction.allCases.map { direction in
            let updatesPerTrain: [Train: [TransitRealtime_FeedEntity]] = trains.reduce(into: [:]) { map, train in
                map[train] = entities.filter { $0.tripUpdate.trip.routeID == train.rawValue }
            }

            let stopUpdatesPerTrain: [Train: [Date]] = updatesPerTrain.reduce(into: [:]) { map, update in
                let (train, updates) = update
                map[train] = updates
                    .map { update -> [TransitRealtime_TripUpdate.StopTimeUpdate] in
                        return update.tripUpdate.stopTimeUpdate
                            .filter { $0.stopID.contains(station.rawValue) }
                            .filter { $0.stopID.last == direction.terminalCharacter }
                    }
                    .flatMap { $0 }
                    .map { (update: TransitRealtime_TripUpdate.StopTimeUpdate) in
                        if !update.nyctStopTimeUpdate.scheduledTrack.isEmpty {
                            print(update.nyctStopTimeUpdate.scheduledTrack)
                        }

                        if !update.nyctStopTimeUpdate.actualTrack.isEmpty {
                            print(update.nyctStopTimeUpdate.actualTrack)
                        }

                        return Date(timeIntervalSince1970: Double(update.arrival.time))
                    }
            }

            let trainUpdates: [TrainUpdate] = stopUpdatesPerTrain.map { update -> [TrainUpdate] in
                let (train, arrivalTimes) = update
                let sortedArrivals = arrivalTimes.sorted().filter({ $0.timeIntervalSinceNow > 0 }).prefix(3)
                return sortedArrivals
                    .map { Int($0.timeIntervalSinceNow / 60) }
                    .map { TrainUpdate(train: train, minutesToArrive: $0) }
            }.flatMap { $0 }

            return TrackUpdate(direction: direction, trainUpdates: trainUpdates)
        }
    }

    var updatesOnTheATrain: [TransitRealtime_FeedEntity] {
        message.entity.filter { $0.tripUpdate.trip.routeID == "A" }
    }
}

extension Direction {
    var directionDTO: NyctTripDescriptor.Direction {
        switch self {
        case .northbound:
            return .north
        case .southbound:
            return .south
        }
    }

    var terminalCharacter: Character {
        switch self {
        case .northbound:
            return "N"
        case .southbound:
            return "S"
        }
    }
}
