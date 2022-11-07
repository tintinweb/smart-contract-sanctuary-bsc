// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract Scoreboard {
    
    uint256 score;

    // read the current score

    function read() public view returns (uint256) {
        return score;
    }

    // update a new score

    function write(uint256 newScore) public {
        score = newScore;
    }
}