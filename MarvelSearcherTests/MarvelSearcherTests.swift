//
//  MarvelSearcherTests.swift
//  MarvelSearcherTests
//
//  Created by subError on 4/26/24.
//

import XCTest
@testable import MarvelSearcher

final class SearchViewControllerTests: XCTestCase {
    
    var sut: SearchViewController!
    var mockMarvelData: MockMarvelData!

    override func setUpWithError() throws {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
        
        mockMarvelData = MockMarvelData()
        sut.marvelData = mockMarvelData
        
        sut.loadViewIfNeeded()
    
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockMarvelData = nil
    }
    
    
    func testSearchBarTextChange() {
        let searchText = "sp"
        sut.searchBar.text = searchText
        sut.searchBar(sut.searchBar, textDidChange: searchText)
        XCTAssertTrue(mockMarvelData.getMarvelInfoCalled, "search text is changed")
        
    }
    
    func testUpdateFavoriteState() {
        mockMarvelData.heroInfo.append(HeroDisplayInfo(name: "Iron Man", favorite: false))
        sut.collectionView(sut.heroCollectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(mockMarvelData.updateFavoriteStateCalled, "item selected")
    }
    
    func testDataLoad() {
        mockMarvelData.isLoading = { isLoading in
            if !isLoading {
                self.sut.heroCollectionView.reloadData()
            }
        }
        mockMarvelData.heroInfo = [HeroDisplayInfo(name: "Iron Man", favorite: false), HeroDisplayInfo(name: "Thor", favorite: true)]
        mockMarvelData.isLoading?(false)
        
        XCTAssertEqual(sut.heroCollectionView.numberOfItems(inSection: 0), mockMarvelData.heroInfo.count, "CollectionView update")
    }
}


class MockMarvelData: MarvelData {
    var getMarvelInfoCalled = false
    var updateFavoriteStateCalled = false
    
    override func getMarvelInfo(name: String) {
        getMarvelInfoCalled = true
        super.getMarvelInfo(name: name)
    }
    
    override func updateFavoriteState(index: Int) {
        updateFavoriteStateCalled = true
        super.updateFavoriteState(index: index)
    }
}
