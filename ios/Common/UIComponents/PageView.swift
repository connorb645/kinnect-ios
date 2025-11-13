import SwiftUI
import UIKit

/// A horizontal paging scroll view that displays multiple SwiftUI views as pages.
/// Updates a binding when the user scrolls to a new page.
struct PageView<Content: View>: UIViewRepresentable {
    let views: [Content]
    @Binding var currentPage: Int

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

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        updateHostingControllers(in: scrollView, context: context)
        syncScrollPosition(in: scrollView)
    }

    // MARK: - Private Helpers

    private func setupPages(in scrollView: UIScrollView, context: Context) {
        context.coordinator.hostingControllers.removeAll()

        for (index, content) in views.enumerated() {
            let hostingController = UIHostingController(rootView: content)
            hostingController.view.backgroundColor = .clear
            context.coordinator.hostingControllers.append(hostingController)

            let pageView = hostingController.view!
            scrollView.addSubview(pageView)
            configurePageConstraints(pageView, at: index, in: scrollView)
        }
    }

    private func configurePageConstraints(
        _ pageView: UIView,
        at index: Int,
        in scrollView: UIScrollView
    ) {
        pageView.activateConstraints {
            $0.topAnchor.constraint(equalTo: scrollView.topAnchor)
            $0.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
            $0.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            $0.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        }

        if index == 0 {
            pageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        } else {
            let previousPage = scrollView.subviews[index - 1]
            pageView.leadingAnchor.constraint(equalTo: previousPage.trailingAnchor).isActive = true
        }

        if index == views.count - 1 {
            pageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        }
    }

    private func updateHostingControllers(
        in scrollView: UIScrollView,
        context: Context
    ) {
        let needsRebuild = context.coordinator.hostingControllers.count != views.count

        if needsRebuild {
            scrollView.subviews.forEach { $0.removeFromSuperview() }
            setupPages(in: scrollView, context: context)
        } else {
            for (index, hostingController) in context.coordinator.hostingControllers.enumerated() {
                if index < views.count {
                    hostingController.rootView = views[index]
                }
            }
        }
    }

    private func syncScrollPosition(in scrollView: UIScrollView) {
        let width = scrollView.bounds.width
        guard width > 0, !scrollView.isDragging, !scrollView.isDecelerating else { return }

        let targetX = CGFloat(currentPage) * width
        let currentX = scrollView.contentOffset.x
        let threshold = width * 0.1

        // Only update scroll position if significantly different
        // This prevents jumping when views update during buffer shifts
        if abs(currentX - targetX) > threshold {
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

        func scrollViewDidEndDragging(
            _ scrollView: UIScrollView,
            willDecelerate decelerate: Bool
        ) {
            if !decelerate {
                updateCurrentPage(for: scrollView)
            }
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            updateCurrentPage(for: scrollView)
        }

        private func updateCurrentPage(for scrollView: UIScrollView) {
            let pageWidth = scrollView.bounds.width
            guard pageWidth > 0 else { return }

            let rawPage = scrollView.contentOffset.x / pageWidth
            let clampedPage = max(0, min(parent.views.count - 1, Int(round(rawPage))))

            if parent.currentPage != clampedPage {
                parent.currentPage = clampedPage
            }
        }
    }
}
