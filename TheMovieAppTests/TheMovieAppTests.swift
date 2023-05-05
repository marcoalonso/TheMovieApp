//
//  TheMovieAppTests.swift
//  TheMovieAppTests
//
//  Created by Marco Alonso Rodriguez on 05/05/23.
//

import XCTest
import YouTubeiOSPlayerHelper
@testable import TheMovieApp


final class TheMovieAppTests: XCTestCase {
    
    var sut: MoviesManager!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        sut = MoviesManager()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
        
    }

    func test_search_movies_by_name(){
        
        let nameOfMovieDemo = "Titanic"
        
        sut.searchMovies(nameOfMovie: nameOfMovieDemo) {  numPages, listOfMovies , error in
            XCTAssertNotNil(listOfMovies)
            XCTAssertGreaterThanOrEqual(numPages, 1)
        }
    }
    
    func test_search_upcoming_movies(){
        sut.getUpcomingMovies { numPages, listOfMovies, error in
            XCTAssertNotNil(listOfMovies)
            XCTAssertGreaterThanOrEqual(numPages, 1)
        }
        
       
    }


}
