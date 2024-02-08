//
//  MovieActor.swift
//  MovieNight
//
//  Created by Boone on 2/4/24.
//

actor MovieActor {
    private var _details: DetailViewRepresentable?

    func setMovieDetails(_ details: DetailViewRepresentable) {
        guard let movieDetails_CD = MovieProvider.shared.exists(id: details.id) else {
            self._details = details
            return
        }

        // set details to the retrieved CoreData model
        self._details = movieDetails_CD
    }

    // Read access to the Movie object
    func getMovie() -> DetailViewRepresentable? {
        return _details
    }
}
