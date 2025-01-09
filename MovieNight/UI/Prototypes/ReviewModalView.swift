//
//  ReviewModalView.swift
//  MovieNight
//
//  Created by Boone on 12/14/24.
//

import SwiftUI

struct ReviewModalView: View {
    @ObservedObject var vm: FilmDetailView.ViewModel
    @Environment(\.dismiss) private var dismiss
//    @State private var rating: Int

    let backgroundColor: UIColor

    init(vm: FilmDetailView.ViewModel) {
        self.vm = vm
        self.backgroundColor = vm.averageColor
//        self.rating = Int(vm.rating())
    }

   enum Star: CaseIterable {
       case horrible
       case alright
       case notSure
       case good
       case amazing
   }

   var body: some View {
       VStack(alignment: .center, spacing: 0) {
           Spacer()
           Text("What did you think?")
               .font(.system(size: 22, weight: .medium))
               .foregroundStyle(.white)

           // Stars Stack
           HStack(spacing: 5) {
               ForEach(0..<Star.allCases.count, id: \.self) { idx in
                   Spacer()
//                   Image(systemName: idx < rating ? "star.fill" : "star")
//                       .resizable()
//                       .frame(width: 50, height: 50)
//                       .foregroundStyle(colorForIndex(rating))
//                       .onTapGesture {
//                           rating = idx+1
//                       }
               }
               Spacer()
           }
           .padding(.top, 30)
           .padding(.horizontal, 30)

//           Text(titleForIndex(rating))
//               .font(.system(size: 16, weight: .regular))
//               .foregroundStyle(.white)
//               .padding(.top, 20)

           Spacer()

           Button {
//               if rating != 0 {
//                   vm.addActivity(rating: rating)
//               }

               dismiss()

           } label: {
               Text("Submit")
                   .font(.system(size: 16, weight: .regular))
                   .foregroundStyle(.white)
                   .padding(.vertical, 15)
                   .frame(maxWidth: .infinity)
           }
           .background {
               ZStack {
                   Color(uiColor: backgroundColor)

//                   if rating != 0 {
//                       Color(.black).opacity(0.6)
//                   } else {
//                       Color(.black).opacity(0.2)
//                   }
               }
           }
           .clipShape(RoundedRectangle(cornerRadius: 15))
           .padding(.horizontal, 30)
       }
       .background {
           Color(uiColor: backgroundColor)
               .ignoresSafeArea()
       }
   }

   private func colorForIndex(_ idx: Int?) -> Color {
       guard let idx else { return .white }

       switch idx {
       case 1:
           return Color(uiColor: UIColor(hex: "#FF6B6B"))
       case 2:
           return .orange
       case 3:
           return Color(uiColor: UIColor(hex: "#4D96FF"))
       case 4:
           return Color(uiColor: UIColor(hex: "#6BCB77"))
       case 5:
           return Color(uiColor: UIColor(resource: .gold))
       default:
           return .white
       }
   }

   private func titleForIndex(_ idx: Int?) -> String {
       guard let idx else { return "Not Rated" }

       switch idx {
       case 1:
           return "Horrible!"
       case 2:
           return "Alright"
       case 3:
           return "Not Sure"
       case 4:
           return "Good"
       case 5:
           return "Amazing!"
       default:
           return "Not Rated"
       }
   }
}

//#Preview {
//    @StateObject var vm = FilmDetailView.ViewModel(movieDataStore: <#T##MovieDataStore#>, posterImage: <#T##UIImage?#>)
//    ReviewModalView(backgroundColor: .init(resource: .brightRed))
//}
