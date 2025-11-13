import SwiftUI
import UIKit

struct PageView<Content: View>: UIViewRepresentable {
    let views: [Content]
    @Binding var currentPage: Int  // SwiftUI state we keep in sync

    init(
        currentPage: Binding<Int>,
        @ResultBuilder<Content> content: () -> [Content]
    ) {
        self.views = content()
        self._currentPage = currentPage
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.delegate = context.coordinator

        setupPages(in: scrollView, context: context)

        return scrollView
    }

    private func setupPages(in scrollView: UIScrollView, context: Context) {
        var previousPage: UIView?
        context.coordinator.hostingControllers.removeAll()

        for (index, content) in views.enumerated() {
            // Create a hosting controller to embed the SwiftUI view
            let hostingController = UIHostingController(rootView: content)
            hostingController.view.backgroundColor = .clear

            // Store the hosting controller to prevent deallocation
            context.coordinator.hostingControllers.append(hostingController)

            let page = hostingController.view!
            scrollView.addSubview(page)

            // Set up Auto Layout constraints
            page.activateConstraints {
                $0.topAnchor.constraint(equalTo: scrollView.topAnchor)
                $0.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
                $0.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
                $0.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            }

            if let previous = previousPage {
                page.leadingAnchor.constraint(equalTo: previous.trailingAnchor).isActive = true
            } else {
                page.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            }

            if index == views.count - 1 {
                page.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
            }

            previousPage = page
        }
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        // Update hosting controllers if views have changed
        let needsRebuild = context.coordinator.hostingControllers.count != views.count

        if needsRebuild {
            // Views count changed, need to rebuild
            scrollView.subviews.forEach { $0.removeFromSuperview() }
            setupPages(in: scrollView, context: context)
        } else {
            // Update existing hosting controllers with new views
            for (index, hostingController) in context.coordinator.hostingControllers.enumerated() {
                if index < views.count {
                    hostingController.rootView = views[index]
                }
            }
        }

        // Keep scroll position in sync with currentPage when changed from SwiftUI
        // Only update if the scroll view is not currently being dragged/scrolled by the user
        let width = scrollView.bounds.width
        guard width > 0, !scrollView.isDragging, !scrollView.isDecelerating else { return }

        let targetX = CGFloat(currentPage) * width
        let currentX = scrollView.contentOffset.x

        // Only update scroll position if it's significantly different
        // This prevents jumping when views are updated during buffer shifts
        // The user's visual position should be preserved
        if abs(currentX - targetX) > width * 0.1 {
            scrollView.setContentOffset(CGPoint(x: targetX, y: 0), animated: false)
        }
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: PageView
        var hostingControllers: [UIHostingController<Content>] = []

        init(_ parent: PageView) {
            self.parent = parent
        }

        // Called when dragging ends; if it’s not going to decelerate further,
        // this is effectively "scrolling stopped".
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                updateCurrentPage(for: scrollView)
            }
        }

        // Called when scrolling slows to a stop after deceleration.
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            updateCurrentPage(for: scrollView)
        }

        private func updateCurrentPage(for scrollView: UIScrollView) {
            let pageWidth = scrollView.bounds.width
            guard pageWidth > 0 else { return }

            let rawPage = scrollView.contentOffset.x / pageWidth
            let page = max(0, min(parent.views.count - 1, Int(round(rawPage))))

            if parent.currentPage != page {
                parent.currentPage = page  // UIKit → SwiftUI
                print("User stopped on page \(page)")
            }
        }
    }
}
