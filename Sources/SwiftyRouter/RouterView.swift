//
//  RouterView.swift
//  SwiftyRouter
//
//  Created by Yevhen Biiak on 18.11.2024.
//

import SwiftUI


public struct RouterView<T: View>: View {
    
    private let navigationBarHidden: Bool
    private let content: (Router) -> T
    
    public init(_ content: T) {
        self.init({ content })
    }
    
    public init(_ content: @escaping () -> T) {
        self.init(navigationBarHidden: true, content: { _ in content()})
    }
    
    public init(navigationBarHidden: Bool, @ViewBuilder content: @escaping (_ router: Router) -> T) {
        self.navigationBarHidden = navigationBarHidden
        self.content = content
    }
    
    public var body: some View {
        NavigationControllerView(navigationBarHidden: navigationBarHidden, content: content)
            .edgesIgnoringSafeArea(.all)
    }
}


struct RouterEnvironmentKey: EnvironmentKey {
    static let defaultValue: Router = Router(nil)
}

extension EnvironmentValues {
    public var router: Router {
        get { self[RouterEnvironmentKey.self] }
        set { self[RouterEnvironmentKey.self] = newValue }
    }
}


struct NavigationControllerView<Content: View>: UIViewControllerRepresentable {
    
    private let content: (Router) -> Content
    private let navigationBarHidden: Bool
    
    init(navigationBarHidden: Bool, content: @escaping (Router) -> Content) {
        self.content = content
        self.navigationBarHidden = navigationBarHidden
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let rootController = RouterHostingController(rootView: AnyView(EmptyView()))
        let navigationController = UINavigationController(rootViewController: rootController)
        navigationController.setNavigationBarHidden(navigationBarHidden, animated: false)
        let router = Router(rootController)
        rootController.view.backgroundColor = .clear
        rootController.rootView = AnyView(content(router).environment(\.router, router))
        return navigationController
    }
    
    func updateUIViewController(_ uiView: UIViewController, context: Context) {
        if let navController = uiView as? UINavigationController, let rootController = navController.viewControllers.first as? UIHostingController<AnyView> {
            let router = Router(rootController)
            rootController.rootView = AnyView(content(router).environment(\.router, router))
        }
    }
}


final class RouterHostingController<T: View>: UIHostingController<AnyView> {
    
    class InteractivePopGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
        let canGoBack: () -> Bool
        init(canGoBack: @escaping () -> Bool) {
            self.canGoBack = canGoBack
        }
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return canGoBack()
        }
    }
    
    private var originalPopGestureDelegate: UIGestureRecognizerDelegate?
    private var delegate: InteractivePopGestureRecognizerDelegate?
    private var allowsSwipeBack: Bool
    
    init(rootView: T, allowsSwipeBack: Bool = true) {
        self.allowsSwipeBack = allowsSwipeBack
        super.init(rootView: AnyView(EmptyView()))
        self.rootView = AnyView(rootView.environment(\.router, Router(self)))
    }
    required init?(coder: NSCoder) { nil }
    
    deinit {
        if Router.logEnabled {
            print("[Router]: ☘️ deinit \(String(describing: T.self))")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if modalPresentationStyle == .overFullScreen || modalPresentationStyle == .overCurrentContext {
            view.backgroundColor = .clear
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate = InteractivePopGestureRecognizerDelegate(canGoBack: { [weak self] in
            (self?.navigationController?.viewControllers.count ?? 0) > 1 && (self?.allowsSwipeBack ?? true)
        })
        originalPopGestureDelegate = navigationController?.interactivePopGestureRecognizer?.delegate
        navigationController?.interactivePopGestureRecognizer?.delegate = delegate
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = originalPopGestureDelegate
        originalPopGestureDelegate = nil
        delegate = nil
    }
}


struct AlertView<A: View>: View {
    @Environment(\.router) private var router
    @State private var isPresented: Bool = true
    
    let title: String?
    let message: String?
    let actions: () -> A
    let style: UIAlertController.Style
    
    var body: some View {
        switch style {
        case .actionSheet:
            Color.clear.frame(width: 1, height: 1).confirmationDialog(title ?? "", isPresented: $isPresented, titleVisibility: title == nil ? .hidden : .visible, actions: actions) {
                if let message {
                    Text(message)
                }
            }
        default: // .alert
            Color.clear.alert(title ?? "", isPresented: $isPresented, actions: actions) {
                if let message {
                    Text(message)
                }
            }
        }
        Spacer().onChange(of: isPresented) { _ in
            router.dismiss(animated: false)
        }
    }
}
