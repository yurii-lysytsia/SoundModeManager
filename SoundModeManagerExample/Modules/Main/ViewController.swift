// Copyright © 2021 Yurii Lysytsia. All rights reserved.

import UIKit
import SoundModeManager

final class ViewController: UIViewController {

    // MARK: - Public Properties
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Private Properties
    
    private var isObserved = false
    private var observationToken: SoundModeManager.ObservationToken?
    
    // MARK: - Dependencies
    
    private let manager = SoundModeManager()
    
    // MARK: - Outlets
    
    @IBOutlet private weak var soundModeLabel: UILabel!
    @IBOutlet private weak var observationButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeSoundMode()
        setupView()
    }

}

// MARK: - Private

private extension ViewController {
    
    // MARK: - Services
    
    func observeSoundMode() {
        observationToken = manager.observeCurrentMode { [weak self] _ in
            self?.updateSoundModeLabel()
        }
    }
    
    // MARK: - View
    
    func setupView() {
        updateSoundModeLabel()
        updateObservationButton()
    }
    
    func updateSoundModeLabel() {
        print(manager.currentMode)
        switch manager.currentMode {
        case .notDetermined:
            soundModeLabel.text = "Not determined"
        case .silent:
            soundModeLabel.text = "📴 Silent"
        case .ring:
            soundModeLabel.text = "📳 Ring"
        }
    }
    
    func updateObservationButton() {
        let title = isObserved ? "End observing" : "Begin observing"
        observationButton.setTitle(title, for: .normal)
    }
    
    // MARK: - Actions
    
    @IBAction func observationButtonDidTap(_ sender: UIButton) {
        isObserved.toggle()
        isObserved ? manager.beginUpdatingCurrentMode() : manager.endUpdatingCurrentMode()
        updateObservationButton()
    }
    
}
