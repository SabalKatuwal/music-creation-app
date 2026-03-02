import Foundation
import SwiftUI
import Combine

final class MusicCreationViewModel: ObservableObject {
    @Published private(set) var generationManager: GenerationManager
    @Published private(set) var store: TracksStore

    @Published private(set) var listItems: [ListItem] = []

    private var cancellables: Set<AnyCancellable> = []

    enum ListItem: Identifiable, Equatable {
        case generating(GeneratedTrack, progress: Double, stage: LoadingStage)
        case generated(GeneratedTrack)
        case library(MusicTrack)

        var id: UUID {
            switch self {
            case .generating(let g, _, _):
                return g.id
            case .generated(let g):
                return g.id
            case .library(let m):
                return m.id
            }
        }
    }

    init(generationManager: GenerationManager, store: TracksStore) {
        self.generationManager = generationManager
        self.store = store
        bind()
    }

    // MARK: - Binding

    private func bind() {
        let genPub = Publishers.CombineLatest3(
            generationManager.$activeTrack,
            generationManager.$progress,
            generationManager.$stage
        )
        .map { active, progress, stage -> ListItem? in
            guard let active = active, self.generationManager.isGenerating else { return nil }
            return .generating(active, progress: progress, stage: stage)
        }

        // Recompose the list whenever any of these change
        Publishers.CombineLatest3(
            genPub,
            generationManager.$completedTracks,
            store.$tracks
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] activeItem, completed, library in
            guard let self = self else { return }
            var items: [ListItem] = []

            if let activeItem = activeItem { items.append(activeItem) }

            // Newest completed first
            items += completed.map { .generated($0) }

            // Exclude library items that correspond to currently displayed generated ones
            let generatedIDs: Set<UUID> = Set(items.map { $0.id })
            let filteredLibrary = library.filter { !generatedIDs.contains($0.id) }
            items += filteredLibrary.map { .library($0) }

            self.listItems = items
        }
        .store(in: &cancellables)

        // When a generation completes, push it into the store as a library item
        generationManager.$completedTracks
            .dropFirst()
            .sink { [weak self] tracks in
                guard let self = self else { return }
                // Insert only the newest finish (at index 0)
                if let latest = tracks.first {
                    _ = self.store.addGenerated(latest)
                }
            }
            .store(in: &cancellables)
    }
}
