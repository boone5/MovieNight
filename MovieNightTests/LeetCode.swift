//
//  LeetCode.swift
//  MovieNightTests
//
//  Created by Boone on 9/4/23.
//

import XCTest

final class LeetCode: XCTestCase {
    func testSortAnArray() {
        let res = SortAnArray().sortArray([5,1,1,2,0,0])

        XCTAssertEqual(res, [0,0,1,1,2,5])
    }

    func testSortColors() {
        var arr = [2,0,2,1,1,0]

        SortColors().sortColors(&arr)

        XCTAssertEqual(arr, [0,0,1,1,2,2])
    }

    func testIsPalindrome() {
        var palin = "A man, a plan, a canal: Panama"
        var palin2 = " "

        XCTAssertTrue(IsPalindrome().isPalindrome(palin))
    }
}

// https://leetcode.com/problems/sort-an-array/description/
// 912. Sort an Array
// - I used Merge Sort to satisy the requirement of O(nlog(n))
class SortAnArray {
    func sortArray(_ nums: [Int]) -> [Int] {
        if nums.count < 2 { return nums }

        let mid = nums.count / 2
        let count = nums.count
        let left = sortArray(Array(nums[0..<mid]))
        let right = sortArray(Array(nums[mid..<count]))

        return mergeSort(left, right)
    }

    func mergeSort(_ left: [Int], _ right: [Int]) -> [Int] {
        var sorted = [Int]()
        var left = left
        var right = right

        while left.count > 0 && right.count > 0 {
            if left[0] < right[0] {
                sorted.append(left[0])
                left.remove(at: 0)
            } else {
                sorted.append(right[0])
                right.remove(at: 0)
            }
        }
        return sorted + left + right
    }
}

class SortColors {
    // - Complexity:
    //   - time: O(n), where n is the length of the nums.
    //   - space: O(1), only constant space is used.
    func sortColors(_ nums: inout [Int]) {
        var zeroPntr = 0
        var twoPntr = nums.count-1
        var currIndex = 0

        while currIndex <= twoPntr {
            if nums[currIndex] == 0 {
                nums.swapAt(zeroPntr, currIndex)
                currIndex += 1
                zeroPntr += 1
            } else if nums[currIndex] == 2 {
                nums.swapAt(currIndex, twoPntr)
                twoPntr -= 1
            } else {
                currIndex += 1
            }
        }
    }

    // Beats 100%. Beats 69% at Memory
    func sortColors2(_ nums: inout [Int]) {

    }
}

class IsPalindrome {
    func isPalindrome(_ s: String) -> Bool {
        guard !s.isEmpty else { return false }

        var converted = Array(s)
        var left = 0
        var right = converted.count - 1

        while left < right {
            if !converted[left].isLetter, !converted[left].isNumber {
                left += 1
                continue
            }

            if !converted[right].isLetter, !converted[right].isNumber {
                right -= 1
                continue
            }

            guard converted[left].lowercased() == converted[right].lowercased() else { return false }

            left += 1
            right -= 1
        }

        return true
    }
}
