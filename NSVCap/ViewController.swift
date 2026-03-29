import UIKit
import WebKit
import AVFoundation

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    private var webView: WKWebView!
    private let webURL = "https://ns.fiber-gate.ru"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioSession()
        setupWebView()
        loadURL()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord,
                                  mode: .videoChat,
                                  options: [.allowBluetooth, .allowBluetoothA2DP, .allowAirPlay, .defaultToSpeaker, .mixWithOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
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
    
    func webView(_ webView: WKWebView,
                 decideMediaCapturePermissionsFor origin: WKSecurityOrigin,
                 initiatedByFrame frame: WKFrameInfo,
                 type: WKMediaCaptureType,
                 decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }
    
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