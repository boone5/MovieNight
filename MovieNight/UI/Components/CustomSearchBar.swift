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

        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            self.searchState = .searching
        }

        @MainActor
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            print("searching for: \(searchText)")
            searchState = .results

            Task {
                await vm.fetchAllResults(for: searchText)
            }
        }
    }

    func makeUIView(context: Context) -> UISearchBar {
        let image = UIImage(systemName: "xmark.circle")

        let imageView = UIImageView()
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.tintColor = .white

        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.backgroundColor = UIColor(named: "BrightRed")
        searchBar.searchTextField.leftView?.tintColor = .white
        searchBar.searchTextField.rightView = imageView
        searchBar.searchTextField.rightViewMode = .always
//        searchBar.setRightImage(image)
        searchBar.searchTextField.textColor = .white

        return searchBar
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(searchText: $searchText, searchViewModel: vm, searchState: $searchState)
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = searchText
    }
}

extension UISearchBar {
    func setRightImage(_ image: UIImage?) {
        if let btn = searchTextField.rightView as? UIButton {
            btn.setImage(image, for: .normal)
            btn.setImage(image, for: .highlighted)
        }
    }
}
