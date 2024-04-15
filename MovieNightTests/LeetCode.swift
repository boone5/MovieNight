//
//  LeetCode.swift
//  MovieNightTests
//
//  Created by Boone on 9/4/23.
//

import XCTest

final class LeetCode: XCTestCase {
    private var lc: LeetCodeProblems!

    override func setUp() {
        self.lc = LeetCodeProblems()
    }

    override func tearDown() {
        lc = nil
    }

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

    func testIsValidParanthesis() {
        let testString = "()[]{}"
        let complexString = "(([{}]))"

        XCTAssertTrue(ValidParanthesis().isValid(testString))
    }

    func testEvalRPN() {
        let tokens1 = ["10","6","9","3","+","-11","*","/","*","17","+","5","+"]
        let tokens2 = ["4","13","5","/","+"]

        let unwrap = "+"

        let num = Int(unwrap)

        XCTAssertEqual(1, num)

//        XCTAssertEqual(lc.evalRPN(tokens1), 22)
    }

    func testBinarySearch() {
        XCTAssertEqual(lc.search([-1,0,3,5,9,12], 9), 4)
    }

    func testSearchMatrix() {
        XCTAssertTrue(lc.searchMatrix([[1,3,5,7],[10,11,16,20],[23,30,34,60]], 30))
    }

    func testKokoBananas() {
        let input1 = [3,6,7,11]
        let h1 = 8
        // output = 4
        let input2 = [30,11,23,4,20]
        let h2 = 5
        // output = 30
        let input3 = [30,11,23,4,20]
        let h3 = 6
        // output = 23

        XCTAssertEqual(lc.minEatingSpeed(input1, h1), 4)
    }

    func testMinWindow() {
        let answ = "BANC"
        let res = lc.minWindow("ADOBECODEBANC", "ABC")

        XCTAssertEqual(answ, res)
    }

    func testMaxFreq() {
        let answ = 2
        let res = lc.maxFrequency([3 ,9,6], 2)

        XCTAssertEqual(answ, res)
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

class ValidParanthesis {
    func isValid(_ s: String) -> Bool {
        guard s.count % 2 == 0 else { return false}

        let paranthesisDict: [Character: Character] = ["{": "}", "[": "]", "(": ")"]

        let openBrackets: Set<Character> = ["(", "{", "["]
        var openStore: [Character] = []

        for char in s {
            if openBrackets.contains(char) {
                openStore.append(char)
            } else if let lastChar = openStore.last,
                        paranthesisDict[lastChar] == char 
            {
                openStore.removeLast()
                continue
            } else {
                return false
            }
        }

        return true
    }
}

class LeetCodeProblems {
    init() { }

    func maxFrequency(_ nums: [Int], _ k: Int) -> Int {
        let nums = nums.sorted()
        var left = 0, windowSum = 0

        for (right, num) in nums.enumerated() {
            windowSum += num
            if ((right - left + 1) * num - windowSum > k)
            {
                windowSum -= nums[left]
                left += 1
            }
        }

        return nums.count - left
    }

    func minWindow(_ s: String, _ t: String) -> String {
        if t == "" {
            return ""
        }

        var sArray = Array(s)
        var tArray = Array(t)

        var countT = [Character: Int]()
        var window = [Character: Int]()

        for c in tArray {
            countT[c, default: 0] += 1
        }

        var have = 0
        var need = countT.count
        var res = (0, 0)
        var resLen = Int.max

        var l = 0
        for r in 0..<sArray.count {
            var c = sArray[r]
            window[c, default: 0] += 1

            if countT[c] != nil && window[c] == countT[c] {
                have += 1
            }

            while have == need {
                if r - l + 1 < resLen {
                    res = (l, r)
                    resLen = r - l + 1
                }

                window[sArray[l], default: 0] -= 1

                if countT[sArray[l]] != nil && window[sArray[l]]! < countT[sArray[l]]! {
                    have -= 1
                }

                l += 1
            }
        }

        if resLen != Int.max {
            return String(sArray[res.0...res.1])
        } else {
            return ""
        }
    }

    // https://leetcode.com/problems/evaluate-reverse-polish-notation/
    func evalRPN(_ tokens: [String]) -> Int {
        guard tokens.count > 1 else {
            if let stringNum = tokens.first,
               let num = Int(stringNum)
            {
                return num
            }
            return -1
        }

        var sum: Int = 0
        var orderOfOperations: [Int] = []

        for token in tokens {
            switch token {
            case "+":
                let first = orderOfOperations[orderOfOperations.count - 2]
                let second = orderOfOperations[orderOfOperations.count - 1]

                sum = first + second
                orderOfOperations.removeLast(2)
                orderOfOperations.append(sum)
            case "-":
                let first = orderOfOperations[orderOfOperations.count - 2]
                let second = orderOfOperations[orderOfOperations.count - 1]

                sum = first - second
                orderOfOperations.removeLast(2)
                orderOfOperations.append(sum)
            case "*":
                let first = orderOfOperations[orderOfOperations.count - 2]
                let second = orderOfOperations[orderOfOperations.count - 1]

                sum = first * second
                orderOfOperations.removeLast(2)
                orderOfOperations.append(sum)
            case "/":
                let first = orderOfOperations[orderOfOperations.count - 2]
                let second = orderOfOperations[orderOfOperations.count - 1]

                sum = first / second
                orderOfOperations.removeLast(2)
                orderOfOperations.append(sum)
            default:
                // number
                if let num = Int(token) {
                    orderOfOperations.append(num)
                }
            }
        }

        return sum
    }

    func search(_ nums: [Int], _ target: Int) -> Int {
        var left = 0
        var right = nums.count - 1

        while left <= right {
            let mid = left + right / 2

            if nums[mid] == target {
                return mid
            } else if nums[mid] > target {
                right = mid - 1
            } else if nums[mid] < target {
                left = mid + 1
            }
        }

        return -1
    }

    func searchMatrix(_ matrix: [[Int]], _ target: Int) -> Bool {
        // subarrays
        let m = matrix.count
        // assuming each array is of the same size
        let n = matrix[0].count

        var lhs = 0
        var rhs = m * n - 1 // total elements treated as one array

        while lhs <= rhs {
            let mid = lhs + ((rhs - lhs) / 2)

            let element = matrix[mid / n][mid % n]
            guard element != target else { return true }

            if element < target {
                lhs = mid + 1
            } else {
                rhs = mid - 1
            }
        }

        return false
    }

    func minEatingSpeed(_ piles: [Int], _ h: Int) -> Int {
        // we take the range from 1 to the max element in the array
        // this is because koko isn't greedy and wants to eat the least amount of bananas possible
        var (l, r) = (1, piles.max()!)

        while l < r {
            // bananas per hour
            var k = (l + r) / 2
            let hours = piles.reduce(0) {
                // tells us how many many hours it takes at the current banana count
                return $0 + ($1 + k - 1)/k
            }

            // adjust the bounds
            (l, r) = hours <= h ? (l,k) : (k+1, r)
        }

        return l
    }
}
