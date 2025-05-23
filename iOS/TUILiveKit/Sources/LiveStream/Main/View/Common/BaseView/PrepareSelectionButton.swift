//
//  PrepareSelectionButton.swift
//  TUILiveKit
//
//  Created by WesleyLei on 2023/10/17.
//

import Foundation
import Combine

class PrepareSelectionModel {
    var textLeftDiff:Float = 8.0
    var leftIcon: UIImage?
    @Published var midText: String = ""
    var rightIcon: UIImage?
}

class PrepareSelectionButton: UIButton {
    private var model: PrepareSelectionModel
    private var cancelableSet: Set<AnyCancellable> = []

    init(model: PrepareSelectionModel) {
        self.model = model
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        backgroundColor = .clear
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }

    private lazy var leftIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = self.model.leftIcon
        return view
    }()

    private lazy var titleLab: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = .customFont(ofSize: 14)
        view.textColor = .g7
        view.text = self.model.midText
        view.sizeToFit()
        return view
    }()

    private lazy var rightIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = self.model.rightIcon
        return view
    }()
}

// MARK: Layout

extension PrepareSelectionButton {
    func constructViewHierarchy() {
        addSubview(leftIconImageView)
        addSubview(titleLab)
        addSubview(rightIconImageView)
    }

    func activateConstraints() {
        leftIconImageView.snp.remakeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(16.scale375())
            make.height.equalTo(16.scale375())
        }

        titleLab.snp.remakeConstraints { make in
            make.leading.equalTo(leftIconImageView.snp.trailing).offset(self.model.textLeftDiff)
            make.centerY.equalToSuperview()
            make.width.equalTo(titleLab.mm_w)
            make.height.equalTo(titleLab.mm_h)
        }

        rightIconImageView.snp.remakeConstraints { make in
            make.leading.equalTo(titleLab.snp.trailing)
            make.centerY.equalToSuperview()
            make.width.equalTo(20.scale375())
            make.height.equalTo(20.scale375())
        }
    }

    func updateTitleLable(text: String) {
        titleLab.text = model.midText
        titleLab.sizeToFit()
        titleLab.snp.remakeConstraints { make in
            make.leading.equalTo(leftIconImageView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(titleLab.mm_w)
            make.height.equalTo(titleLab.mm_h)
        }
    }
    
    private func bindInteraction() {
        model.$midText
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                self.updateTitleLable(text: text)
            }
            .store(in: &cancelableSet)
    }
}
