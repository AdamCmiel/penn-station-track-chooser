import Combine
import Foundation

class TrackData: ObservableObject {
    private var cancellable = Set<AnyCancellable>()
    @Published var trackUpdates = [TrackUpdate]()

    init(updates: AnyPublisher<[TrackUpdate], Never>) {
        updates
            .receive(on: RunLoop.main)
            .assign(to: \.trackUpdates, on: self)
            .store(in: &cancellable)
    }
}
