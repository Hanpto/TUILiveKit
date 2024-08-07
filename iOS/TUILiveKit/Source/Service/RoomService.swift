//
//  RoomService.swift
//  VoiceRoom
//
//  Created by aby on 2024/3/8.
//

import RTCRoomEngine
import Combine

// TODO: - Dependency management, needs to consolidate RoomEngine instances.
class RoomService: BaseServiceProtocol {
    var roomEngine: TUIRoomEngine
    required init(roomEngine: TUIRoomEngine) {
        self.roomEngine = roomEngine
    }
    
    deinit {
        debugPrint("deinit \(type(of: self))")
    }
    
    func start(roomInfo: TUIRoomInfo) -> AnyPublisher<TUIRoomInfo, InternalError> {
        DataReporter.reportFramework()
        return createRoom(info: roomInfo)
            .flatMap({ [weak self] () -> AnyPublisher<TUIRoomInfo, InternalError> in
                guard let self = self else {
                    let error = InternalError(error: TUIError.failed, message: "RoomService instance is nil.")
                    // TODO: - Error .exit
                    return Fail(error: error).eraseToAnyPublisher()
                }
                return self.enterRoom(roomId: roomInfo.roomId)
            })
            .eraseToAnyPublisher()
    }
    
    func join(roomId: String) -> AnyPublisher<TUIRoomInfo, InternalError> {
        DataReporter.reportFramework()
        return enterRoom(roomId: roomId)
    }
    
    func leave() -> AnyPublisher<Void, InternalError> {
        return Future<Void, InternalError> { [weak self] promise in
            guard let self = self else { return }
            roomEngine.exitRoom(syncWaiting: true) {
                promise(.success(()))
            } onError: { err, message in
                let error = InternalError(error: err, message: message)
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func stop() -> AnyPublisher<Void, InternalError> {
        return Future<Void, InternalError> { [weak self] promise in
            guard let self = self else { return }
            roomEngine.destroyRoom {
                promise(.success(()))
            } onError: { err, message in
                var error = InternalError(error: err, message: message)
                error.actions = [
                    MediaActions.stopLocalPreview(),
                    RoomActions.stopSuccess(),
                    MediaActions.cameraClosed(),
                    MediaActions.microphoneClosed(),
                    ViewActions.updateLiveStatus(payload: .finished),
                ]
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}

extension RoomService {
    private func createRoom(info: TUIRoomInfo) -> AnyPublisher<Void, InternalError> {
        let future = Future<Void, InternalError> { [weak self] promise in
            guard let self = self else { return }
            roomEngine.createRoom(info) {
                promise(.success(()))
            } onError: { err, message in
                let error = InternalError(error: err, message: message)
                promise(.failure(error))
            }
        }
        return future.eraseToAnyPublisher()
    }
    
    private func enterRoom(roomId: String) -> AnyPublisher<TUIRoomInfo, InternalError> {
        let future = Future<TUIRoomInfo, InternalError> { [weak self] promise in
            guard let self = self else { return }
            roomEngine.enterRoom(roomId, roomType: .live) { roomInfo in
                guard let info = roomInfo else {
                    let error = InternalError(error: TUIError.roomIdInvalid, message: TUIError.roomIdInvalid.description)
                    promise(.failure(error))
                    return
                }
                promise(.success(info))
            } onError: { err, message in
                let error = InternalError(error: err, message: message)
                promise(.failure(error))
            }
        }
        return future.eraseToAnyPublisher()
        
    }
}

extension RoomService {
    func fetchRoomInfo(onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) -> AnyPublisher<TUIRoomInfo, InternalError> {
        return Future<TUIRoomInfo, InternalError> { [weak self] promise in
            guard let self = self else { return }
            roomEngine.fetchRoomInfo { roomInfo in
                guard let roomInfo = roomInfo else {
                    let error = InternalError(error: TUIError.failed, message: "fetch room info fail.")
                    promise(.failure(error))
                    return
                }
                promise(.success(roomInfo))
            } onError: { err, message in
                let error = InternalError(error: err, message: message)
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchRoomOwnerInfo(ownerId: String) -> AnyPublisher<User, InternalError> {
        return Future<User, InternalError> { [weak self] promise in
            guard let self = self else { return }
            roomEngine.getUserInfo(ownerId) { userInfo in
                if let user = userInfo {
                    promise(.success(User(userInfo: user)))
                } else {
                    let error = InternalError(error: TUIError.userNotExist, message: TUIError.userNotExist.description)
                    promise(.failure(error))
                }
            } onError: { err, message in
                let error = InternalError(error: err, message: message)
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchLiveInfo(roomId: String) -> AnyPublisher<TUILiveInfo, InternalError> {
        return Future<TUILiveInfo, InternalError> { [weak self] promise in
            guard let self = self else { return }
            guard let liveListManager = roomEngine.getExtension(extensionType: .liveListManager) as? TUILiveListManager else {
                let error = InternalError(error: TUIError.userNotExist, message: TUIError.userNotExist.description)
                promise(.failure(error))
                return
            }
            liveListManager.getLiveInfo(roomId) { liveInfo in
                promise(.success(liveInfo))
            } onError: { error, message in
                let error = InternalError(error: error, message: message)
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func setLiveInfo(liveInfo: TUILiveInfo, modifyFlag: TUILiveModifyFlag) -> AnyPublisher<Void, InternalError> {
        return Future<Void, InternalError> { [weak self] promise in
            guard let self = self else { return }
            guard let liveListManager = roomEngine.getExtension(extensionType: .liveListManager) as? TUILiveListManager else {
                let error = InternalError(error: TUIError.userNotExist, message: TUIError.userNotExist.description)
                promise(.failure(error))
                return
            }
            liveListManager.setLiveInfo(liveInfo, modifyFlag: modifyFlag) {
                promise(.success(()))
            } onError: { error, message in
                let error = InternalError(error: error, message: message)
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}

extension RoomService {
    func setRoomSeatModeByAdmin(_ seatMode: TUISeatMode) -> AnyPublisher<Void, InternalError> {
        return Future<Void, InternalError> { [weak self] promise in
            guard let self = self else { return }
            self.roomEngine.updateRoomSeatModeByAdmin(seatMode) {
                promise(.success(()))
            } onError: { error, message in
                let error = InternalError(error: error, message: message)
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}
