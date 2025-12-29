//
//  TextTruncationEffect.swift
//  UI
//
//  Created by Ayren King on 12/25/25.
//

import SwiftUI

public extension Text {
    @ViewBuilder
    func truncationEffect(length: Int, isEnabled: Bool, animation: Animation) -> some View {
        self
            .modifier(
                TruncationEffectViewModifier(
                    length: length,
                    isEnabled: isEnabled,
                    animation: animation
                )
            )
    }
}

fileprivate struct TruncationEffectViewModifier: ViewModifier {
    var length: Int
    var isEnabled: Bool
    var animation: Animation
    /// View Properties
    @State private var limitedSize: CGSize = .zero
    @State private var fullSize: CGSize = .zero
    @State private var animatedProgress: CGFloat = 0
    func body(content: Content) -> some View {
        content
            .lineLimit(length)
            .opacity(0)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onGeometryChange(for: CGSize.self) {
                $0.size
            } action: { newValue in
                limitedSize = newValue
            }
            .frame(height: isExpanded ? fullSize.height : nil)
            .overlay {
                /// Full Content With Animation
                GeometryReader {
                    let contentSize = $0.size

                    content
                        .textRenderer(
                            TruncationTextRenderer(
                                length: length,
                                progress: animatedProgress
                            )
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .onGeometryChange(for: CGSize.self) {
                            $0.size
                        } action: { newValue in
                            fullSize = newValue
                        }
                        .frame(
                            width: contentSize.width,
                            height: contentSize.height,
                            alignment: isExpanded ? .leading : .topLeading
                        )
                }
            }
            .contentShape(.rect)
            .onChange(of: isEnabled) { oldValue, newValue in
                withAnimation(animation) {
                    animatedProgress = !newValue ? 1 : 0
                }
            }
            .onAppear {
                /// Setting Initial Value without animation
                animatedProgress = !isEnabled ? 1 : 0
            }
    }

    var isExpanded: Bool {
        animatedProgress == 1
    }
}

/// Text Renderer
@Animatable
fileprivate struct TruncationTextRenderer: TextRenderer {
    @AnimatableIgnored var length: Int
    /// Only Want the progress to be animated!
    var progress: CGFloat
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        for (index, line) in layout.enumerated() {
            var copyContext = ctx
            if index == length - 1 {
                drawMoreTextAtEnd(line: line, context: &copyContext)
            } else {
                if index < length {
                    /// Drawing All Other Lines
                    copyContext.draw(line)
                } else {
                    drawLinesWithBlurEffect(index: index, layout: layout, in: &copyContext)
                }
            }
        }
    }

    func drawLinesWithBlurEffect(index: Int, layout: Text.Layout, in ctx: inout GraphicsContext) {
        let line = layout[index]

        let lineIndex = Double(index - length)
        let totalExtraLines = Double(layout.count - length)

        // Divide the animation progress among all extra lines
        let lineStartProgress = lineIndex / max(1, totalExtraLines)
        let lineEndProgress = (lineIndex + 1) / max(1, totalExtraLines)

        // Calculate this specific line's progress
        let lineProgress = max(0, min(1, (progress - lineStartProgress) / (lineEndProgress - lineStartProgress)))

        ctx.opacity = lineProgress
        ctx.addFilter(.blur(radius: blurRadius - (blurRadius * lineProgress)))
        ctx.draw(line)
    }

    func drawMoreTextAtEnd(line: Text.Layout.Element, context: inout GraphicsContext) {
        let runs = line.flatMap({ $0 })
        let runsCount = runs.count
        let text = "...More"
        let textCount = text.count

        /// Drawing the runs till the text count
        for index in 0..<max(runsCount - textCount, 0) {
            let run = runs[index]
            context.draw(run)
        }

        /// Drawing the remaining run with opacity filter
        for index in max(runsCount - textCount, 0)..<runsCount {
            let run = runs[index]
            context.opacity = progress
            context.draw(run)
        }

        /// Drawing Text
        let textRunIndex = max(runsCount - textCount, 0)
        var typography: Text.Layout.TypographicBounds
        if !runs.isEmpty {
            typography = runs[textRunIndex].typographicBounds
        } else {
            typography = line.typographicBounds
        }

        /// Displays with Default System Font!
        let fontSize: CGFloat = typography.ascent
        let font = UIFont.systemFont(ofSize: fontSize)

        let spacing: CGFloat = NSString(string: text).size(withAttributes: [
            .font: font,
        ]).width / 2

        let swiftUIText = Text(text)
            .font(Font(font))
            .foregroundStyle(.gray)

        let origin = CGPoint(
            x: typography.rect.minX + spacing,
            y: typography.rect.midY
        )

        context.opacity = 1 - progress
        context.draw(swiftUIText, at: origin)
    }

    var blurRadius: CGFloat {
        return 5
    }
}

#Preview {
    @Previewable @State var isEnabled: Bool = true

    VStack {
        Text("This is a very long text that should be truncated with an effect. This is a very long text that should be truncated with an effect. This is a very long text that should be truncated with an effect. This is a very long text that should be truncated with an effect. This is a very long text that should be truncated with an effect. This is a very long text that should be truncated with an effect. This is a very long text that should be truncated with an effect. This is a very long text that should be truncated with an effect.")
            .truncationEffect(
                length: 3,
                isEnabled: isEnabled,
                animation: .smooth(duration: 0.5, extraBounce: 0)
            )
            .onTapGesture {
                isEnabled.toggle()
            }
            .padding()
        Spacer()
    }
    .padding()
    .loadCustomFonts()
}
