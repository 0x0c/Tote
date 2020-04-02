//
//  GalleryViewModel.swift
//  Tote
//
//  Created by Brian Michel on 4/1/20.
//  Copyright © 2020 Brian Michel. All rights reserved.
//

import Combine
import Foundation
import Nuke

final class GalleryViewModel {
    enum State {
        case initial
        case error(message: String)
    }

    enum Action {
        case loadFolders
        case loadDetail(mediaGroup: MediaGroup)
        case switchFolder(folderName: String)
    }

    @Published var selectedFolder: Folder?
    @Published var cellViewModels: [GalleryCellViewModel]?
    @Published var folders: [Folder] = []

    let state = CurrentValueSubject<State, Never>(.initial)
    let action = PassthroughSubject<Action, Never>()

    private let api: API = NetworkAPI.standard
    private var storage = Set<AnyCancellable>()

    init() {
        action.sink(receiveValue: { [weak self] action in
            self?.process(action: action)
        }).store(in: &storage)

        state.sink(receiveValue: { [weak self] state in
            self?.process(state: state)
        }).store(in: &storage)
    }

    private func process(state: State) {
        switch state {
        case .initial:
            action.send(.loadFolders)
        case let .error(message):
            Log.error("There was an error performing some action, \(message)")
        }
    }

    private func process(action: Action) {
        switch action {
        case .loadFolders:
            api.folders()
                .sink(
                    receiveCompletion: { completion in
                        Log.info("\(completion)")
                    },
                    receiveValue: { [weak self] value in
                        Log.debug(String(describing: value))

                        self?.folders = value.folders

                        guard let firstFolderName = value.folders.first?.name else {
                            return
                        }
                        self?.action.send(.switchFolder(folderName: firstFolderName))
                    }
                )
                .store(in: &storage)
        case let .switchFolder(folderName):
            let folder = folders.first(where: { $0.name == folderName })
            selectedFolder = folder
            cellViewModels = folder?.reversedGroups.map { GalleryCellViewModel(mediaGroup: $0, api: api) }
        case let .loadDetail(mediaGroup: mediaGroup):
            break
        }
    }
}