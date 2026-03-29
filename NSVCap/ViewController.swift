// NSVCap/ViewController.swift
import UIKit
import WebKit
import AVFoundation

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    private var webView: WKWebView!
    private var filePathCallback: (([URL]?) -> Void)?
    private let webURL = "https://ns.fiber-gate.ru"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioSession()
        setupWebView()
        loadURL()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    // 🔥 АУДИО: Критично для WebRTC
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord,
                                  mode: .videoChat,
                                  options: [
                                      .allowBluetooth,
                                      .allowBluetoothA2DP,
                                      .allowAirPlay,
                                      .defaultToSpeaker,
                                      .mixWithOthers
                                  ])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            print("✅ Audio session configured")
        } catch {
            print("❌ Audio session error: \(error)")
        }
    }
    
    // 🔥 WKWEBVIEW
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsInlineMediaPlayback = true
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        config.preferences = preferences
        
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        view.addSubview(webView)
    }
    
    private func loadURL() {
        guard let url = URL(string: webURL) else { return }
        webView.load(URLRequest(url: url))
    }
    
    // 🔥 РАЗРЕШЕНИЯ: Микрофон/камера
    func webView(_ webView: WKWebView,
                 decideMediaCapturePermissionsFor origin: WKSecurityOrigin,
                 initiatedByFrame frame: WKFrameInfo,
                 type: WKMediaCaptureType,
                 decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }
    
    // 🔥 ВЫБОР ФАЙЛОВ
    func webView(_ webView: WKWebView,
                 runOpenPanelWith parameters: WKOpenPanelParameters,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping ([URL]?) -> Void) {
        self.filePathCallback = completionHandler
        showImagePicker()
    }
    
    private func showImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image"]
        present(picker, animated: true)
    }
    
    // 🔥 НАВИГАЦИЯ
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
           url.host == URL(string: webURL)?.host {
            decisionHandler(.allow)
            return
        }
        decisionHandler(.cancel)
    }
    
    deinit {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

// 🔥 IMAGE PICKER
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                              didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let url = info[.imageURL] as? URL ?? info[.mediaURL] as? URL {
            filePathCallback?([url])
        }
        filePathCallback = nil
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        filePathCallback?(nil)
        filePathCallback = nil
    }
}