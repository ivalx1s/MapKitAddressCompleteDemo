//
//  InlineSuggestionsListView.swift
//  MapKitAddressCompleteDemo

import SwiftUI

// MARK: - Inline SuggestionsListView
/// Used for inline suggestions of City or State.
struct InlineSuggestionsListView<Suggestion: Identifiable, Content: View>: View {
    let suggestions: [Suggestion]
    let onSelect: (Suggestion) -> Void
    let content: (Suggestion) -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(suggestions) { suggestion in
                Button {
                    onSelect(suggestion)
                } label: {
                    content(suggestion)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
                .buttonStyle(.plain)
                
                // Divider except for the last
                if suggestion.id != suggestions.last?.id {
                    Divider()
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}
