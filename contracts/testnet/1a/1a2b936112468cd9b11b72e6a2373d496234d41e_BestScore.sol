/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

pragma solidity ^0.8.0;

contract BestScore {
    uint256 public bestScore;

    function saveBestScore(uint256 newScore) public {
        if (newScore > bestScore) {
            bestScore = newScore;
        }
    }

    function getBestScore() public view returns (uint256) {
        return bestScore;
    }
}