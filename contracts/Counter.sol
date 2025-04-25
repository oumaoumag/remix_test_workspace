// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Country {
    uint256 public count;

    // Function to get the current count
    function Counter() public view returns (uint256) {
        return count;
    }

    // Function to increment count by 1
    function inc() public {
        count += 1;
    }

    // Function to decrement count by 1
    function dec() public {
        count -= 1;
    }

    // function to reset count to zero 
    function reset() public {
        count = 0;
    }

}