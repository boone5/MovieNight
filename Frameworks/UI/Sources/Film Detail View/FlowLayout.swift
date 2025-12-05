//
//  FlowLayout.swift
//  MovieNight
//
//  Created by Boone on 8/5/25.
//


import SwiftUI

// Custom FlowLayout that wraps content
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var verticalSpacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            spacing: spacing,
            verticalSpacing: verticalSpacing,
            subviews: subviews
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            spacing: spacing,
            verticalSpacing: verticalSpacing,
            subviews: subviews
        )
        
        for (index, subview) in subviews.enumerated() {
            print("\(bounds.minX) - \(result.positions[index].x)")
            subview.place(
                at: CGPoint(
                    x: bounds.minX + result.positions[index].x,
                    y: bounds.minY + result.positions[index].y
                ),
                proposal: ProposedViewSize(result.sizes[index])
            )
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []
        
        init(
            in maxWidth: CGFloat,
            spacing: CGFloat,
            verticalSpacing: CGFloat,
            subviews: Subviews
        ) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            var maxX: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                sizes.append(size)

                print("Size: \(size)")

                // Check if item fits in current row
                if x + size.width > maxWidth && x > 0 {
                    // Move to next row
                    x = 0
                    y += rowHeight + verticalSpacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                x += size.width + spacing
                maxX = max(maxX, x - spacing)
                rowHeight = max(rowHeight, size.height)
            }
            
            self.size = CGSize(width: maxX, height: y + rowHeight)
        }
    }
}

// Sample data model for rectangles
struct RectangleItem: Identifiable {
    let id = UUID()
    let width: CGFloat
    let color: Color
    
    static func randomItems(count: Int) -> [RectangleItem] {
        (0..<count).map { _ in
            RectangleItem(
                width: CGFloat.random(in: 40...150),
                color: Color(
                    red: Double.random(in: 0.3...0.9),
                    green: Double.random(in: 0.3...0.9),
                    blue: Double.random(in: 0.3...0.9)
                )
            )
        }
    }
}

// Main content view
struct ContentView: View {
    @State private var items = RectangleItem.randomItems(count: 20)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Flow Layout with Wrapping Rectangles")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Flow layout container
                FlowLayout(spacing: 10, verticalSpacing: 10) {
                    ForEach(items) { item in
                        Rectangle()
                            .fill(item.color)
                            .frame(width: item.width, height: 50)
                            .cornerRadius(8)
                            .overlay(
                                Text("\(Int(item.width))pt")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            )
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Control buttons
                HStack {
                    Button("Add Rectangle") {
                        withAnimation(.spring()) {
                            items.append(RectangleItem.randomItems(count: 1).first!)
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Remove Last") {
                        withAnimation(.spring()) {
                            if !items.isEmpty {
                                items.removeLast()
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(items.isEmpty)
                    
                    Button("Shuffle") {
                        withAnimation(.spring()) {
                            items.shuffle()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
