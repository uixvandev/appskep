//
//  PaymentWebView.swift
//  appskep
//
//  Created by irfan wahendra on 03/08/25.
//

import SwiftUI
import WebKit

struct PaymentWebView: View {
    let url: URL
    @EnvironmentObject var viewModel: TransactionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var showCloseConfirmation = false
    @State private var didCompletePayment = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            if isLoading {
                ProgressView()
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
                    .tint(.main)
            }
            
            // WebView
            WebViewRepresentable(
                url: url,
                isLoading: $isLoading,
                canGoBack: $canGoBack,
                canGoForward: $canGoForward
            ) { success, orderID in
                Task {
                    print("💳 Payment callback: success=\(success) orderID=\(orderID ?? "nil")")
                    didCompletePayment = true
                    await viewModel.handlePaymentCallback(success: success, orderID: orderID)
                    dismiss()
                }
            }
        }
        .navigationTitle("Pembayaran")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Tutup") {
                    showCloseConfirmation = true
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        // Go back in webview
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(canGoBack ? .main : .gray)
                    }
                    .disabled(!canGoBack)
                    
                    Button(action: {
                        // Go forward in webview
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(canGoForward ? .main : .gray)
                    }
                    .disabled(!canGoForward)
                }
            }
        }
        .alert("Batalkan Pembayaran", isPresented: $showCloseConfirmation) {
            Button("Lanjutkan Pembayaran", role: .cancel) { }
            Button("Batalkan", role: .destructive) {
                Task {
                    await viewModel.handlePaymentCallback(success: false)
                    dismiss()
                }
            }
        } message: {
            Text("Apakah Anda yakin ingin membatalkan proses pembayaran?")
        }
        .onDisappear {
            guard !didCompletePayment else { return }
            Task {
                await viewModel.verifyPaymentStatusAfterDismiss()
            }
        }
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    let onPaymentComplete: (Bool, String?) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebViewRepresentable
        
        init(_ parent: WebViewRepresentable) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            // Intercept custom scheme deep link (e.g., appskep://payment-callback?...)
            if handleCustomPaymentCallback(url) {
                // Prevent WebView from navigating to the custom scheme
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }
        
        private func handleCustomPaymentCallback(_ url: URL) -> Bool {
            guard let scheme = url.scheme?.lowercased(), scheme == "appskep" else {
                return false
            }

            // Expecting URL like: appskep://payment-callback?status=success&order_id=123
            let host = url.host?.lowercased()
            if host == "payment-callback" {
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                let status = components?.queryItems?.first(where: { $0.name == "status" })?.value?.lowercased()
                let orderID = components?.queryItems?.first(where: { $0.name == "order_id" })?.value

                switch status {
                case "success", "settlement", "capture", "pending":
                    parent.onPaymentComplete(true, orderID)
                case "cancel", "deny", "expire", "failure":
                    parent.onPaymentComplete(false, orderID)
                default:
                    // Unknown status: treat as failure to be safe
                    parent.onPaymentComplete(false, orderID)
                }
                return true
            }

            return false
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.canGoBack = webView.canGoBack
            parent.canGoForward = webView.canGoForward
            
            // Check if payment completed
            if let url = webView.url {
                checkPaymentStatus(url: url)
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
        
        private func checkPaymentStatus(url: URL) {
            let urlString = url.absoluteString
            
            // Check for success indicators
            if urlString.contains("status_code=200") ||
               urlString.contains("transaction_status=settlement") ||
               urlString.contains("success") {
                
                // Extract order ID if available
                let orderID = extractOrderID(from: urlString)
                parent.onPaymentComplete(true, orderID)
                
            } else if urlString.contains("status_code=201") ||
                     urlString.contains("transaction_status=pending") {
                
                // Payment pending
                let orderID = extractOrderID(from: urlString)
                parent.onPaymentComplete(true, orderID)
                
            } else if urlString.contains("status_code=202") ||
                     urlString.contains("transaction_status=cancel") ||
                     urlString.contains("cancel") {
                
                // Payment cancelled
                parent.onPaymentComplete(false, nil)
            }
        }
        
        private func extractOrderID(from urlString: String) -> String? {
            // Extract order_id from URL parameters
            guard let url = URL(string: urlString),
                  let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let queryItems = components.queryItems else {
                return nil
            }
            
            return queryItems.first { $0.name == "order_id" }?.value
        }
    }
}

#Preview {
    NavigationStack {
        PaymentWebView(url: URL(string: "https://simulator.sandbox.midtrans.com")!)
            .environmentObject(TransactionViewModel())
    }
}
