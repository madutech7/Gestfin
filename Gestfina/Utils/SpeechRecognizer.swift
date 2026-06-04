import Foundation
import AVFoundation
import Speech
import SwiftUI

class SpeechRecognizer: ObservableObject {
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorized
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorized: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
    
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    
    init() {
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR"))
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // Handle authorization
        }
    }
    
    func startTranscribing() {
        Task { @MainActor in
            do {
                try startRecording()
            } catch {
                print("Speech error: \(error)")
            }
        }
    }
    
    func stopTranscribing() {
        reset()
        isRecording = false
    }
    
    private func startRecording() throws {
        reset()
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let audioEngine = AVAudioEngine()
        self.audioEngine = audioEngine
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.request = request
        
        guard let recognizer = recognizer, recognizer.isAvailable else {
            throw RecognizerError.recognizerIsUnavailable
        }
        
        task = recognizer.recognitionTask(with: request) { result, error in
            if let result = result {
                self.transcript = result.bestTranscription.formattedString
            }
            if error != nil {
                self.reset()
            }
        }
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        isRecording = true
    }
    
    private func reset() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        request = nil
        task = nil
    }
}
