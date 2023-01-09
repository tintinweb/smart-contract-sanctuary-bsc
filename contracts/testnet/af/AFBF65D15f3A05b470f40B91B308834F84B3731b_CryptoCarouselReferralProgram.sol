/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract CryptoCarouselReferralProgram{
    uint256 constant levels = 3;
    uint256 constant percent_1 = 5;
    uint256 constant percent_2 = 3;
    uint256 constant percent_3 = 1;
    
    constructor(){}

    function getPercent(uint256 _level) public pure returns(uint256){
        require(_level > 0 && _level <= levels, "Incorrect level");
        if(_level == 1)
            return percent_1;
        if(_level == 2)
            return percent_2;
        if(_level == 3)
            return percent_3;
        return 0;
    }

    function getLevels() public pure returns(uint256){
        return levels;
    }
}