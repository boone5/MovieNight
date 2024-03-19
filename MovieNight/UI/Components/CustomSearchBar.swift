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

    class Coordinator: NSObject, UISearchBarDelegate {
        @ObservedObject var vm: SearchViewModel
        @Binding var searchText: String

        init(searchText: Binding<String>, searchViewModel: SearchViewModel) {
            _searchText = searchText
            self.vm = searchViewModel
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.searchText = searchText
        }

        @MainActor
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            print("searching for: \(searchText)")
            Task {
                await vm.fetchAllResults(for: searchText)
            }
        }
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.backgroundColor = UIColor(named: "BrightRed")
        searchBar.searchTextField.leftView?.tintColor = .white
        searchBar.searchTextField.textColor = .white
        searchBar.setImage(UIImage(systemName: "trash.circle"), for: .clear, state: .normal)

        return searchBar
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(searchText: $searchText, searchViewModel: vm)
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = searchText
    }
}
