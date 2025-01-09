//
//  CustomSearchBar.swift
//  MovieNight
//
//  Created by Boone on 3/13/24.
//

import SwiftUI

struct CustomSearchBar: UIViewRepresentable {
    @ObservedObject var vm: SearchViewModel

    @Binding var searchText: String
    @Binding var searchState: SearchState

    class Coordinator: NSObject, UISearchBarDelegate {
        var vm: SearchViewModel
        @Binding var searchText: String
        @Binding var searchState: SearchState

        init(searchText: Binding<String>, searchViewModel: SearchViewModel, searchState: Binding<SearchState>) {
            _searchText = searchText
            _searchState = searchState
            self.vm = searchViewModel
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.searchText = searchText
        }

        @MainActor
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            print("searching for: \(searchText)")
            searchState = .results

            Task {
                await vm.fetchAllResults(for: searchText)
            }
        }

        @objc func didTapCancelButton() {
            searchState = .explore
        }
    }

    func makeUIView(context: Context) -> UISearchBar {
        let image = UIImage(systemName: "xmark")?.withTintColor(.white, renderingMode: .alwaysTemplate)

        let imageView = UIImageView(image: image)
        imageView.isUserInteractionEnabled = true

        let uiTapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.didTapCancelButton)
        )

        imageView.addGestureRecognizer(uiTapGesture)

        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.backgroundColor = UIColor(named: "BrightRed")
        searchBar.searchTextField.leftView?.tintColor = .white
        searchBar.searchTextField.rightView = imageView
        searchBar.searchTextField.rightViewMode = .always

        return searchBar
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(searchText: $searchText, searchViewModel: vm, searchState: $searchState)
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = searchText
    }
}
