//
//  MultipleImageViewer.swift
//  ALNASR
//

import SwiftUI
import SDWebImageSwiftUI

extension View {
    func imageViewerOverlay(
        viewerShown: Binding<Bool>,
        images: [String],
        selectedImageIndex: Int = 0
    ) -> some View {
        overlay(
            MultipleImageViewer(
                viewerShown: viewerShown,
                images: images,
                selectedImageTag: selectedImageIndex
            )
        )
    }
}

struct MultipleImageViewer: View {

    @Binding var viewerShown: Bool
    let images: [String]
    @State var selectedImageTag: Int

    // Zoom & Pan
    @State private var scale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        if viewerShown, !images.isEmpty {
            ZStack {
                Color.black.opacity(0.85)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    closeButton

                    GeometryReader { geo in
                        TabView(selection: $selectedImageTag) {
                            ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                                zoomableImage(
                                    url: image,
                                    containerSize: geo.size
                                )
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(
                            indexDisplayMode: images.count <= 1 ? .never : .always
                        ))
                        .onChange(of: selectedImageTag) { _ in
                            resetZoom(animated: false)
                        }
                    }
                }
            }
            .transition(.opacity)
            .onAppear {
                resetZoom(animated: false)
            }
        }
    }

    // MARK: - Close Button
    private var closeButton: some View {
        HStack {
            Spacer()
            Button {
                viewerShown = false
            } label: {
                Image(IC.ACTIONS.CLOSE_WHITE)
                    .padding()
                    .shadow(radius: 3)
            }
        }
        .padding(.top)
    }

    // MARK: - Zoomable Image
    private func zoomableImage(
        url: String,
        containerSize: CGSize
    ) -> some View {
        URLImage(url: url)
            .scaledToFit()
            .scaleEffect(scale)
            .offset(offset)
            .gesture(gesture(containerSize: containerSize))
            .onTapGesture(count: 2) {
                withAnimation(.easeInOut) {
                    if scale > 1 {
                        resetZoom(animated: true)
                    } else {
                        scale = 2
                    }
                }
            }
            .frame(
                width: containerSize.width,
                height: containerSize.height
            )
    }

    // MARK: - Gesture
    private func gesture(containerSize: CGSize) -> some Gesture {
        SimultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    scale = max(1, value)
                }
                .onEnded { _ in
                    if scale <= 1 {
                        resetZoom(animated: true)
                    } else {
                        clampOffset(containerSize: containerSize)
                    }
                },

            DragGesture()
                .onChanged { value in
                    guard scale > 1 else { return }

                    let newOffset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )

                    offset = clampedOffset(
                        newOffset,
                        containerSize: containerSize
                    )
                }
                .onEnded { _ in
                    lastOffset = offset
                }
        )
    }

    // MARK: - Clamp Logic
    private func clampedOffset(
        _ proposed: CGSize,
        containerSize: CGSize
    ) -> CGSize {

        let maxX = (containerSize.width * (scale - 1)) / 2
        let maxY = (containerSize.height * (scale - 1)) / 2

        return CGSize(
            width: min(max(proposed.width, -maxX), maxX),
            height: min(max(proposed.height, -maxY), maxY)
        )
    }

    private func clampOffset(containerSize: CGSize) {
        offset = clampedOffset(offset, containerSize: containerSize)
        lastOffset = offset
    }

    // MARK: - Reset
    private func resetZoom(animated: Bool) {
        let action = {
            scale = 1
            offset = .zero
            lastOffset = .zero
        }

        animated ? withAnimation(.easeOut) { action() } : action()
    }
}
