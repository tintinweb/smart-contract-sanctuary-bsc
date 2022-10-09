// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface ICat{
    function idToCat(uint256 _number) external view returns (uint256, uint256);
}

contract LFW2 {
    function testView(address _sc, uint256 _number) public view returns(uint256 myAge) {
        (myAge, ) = ICat(_sc).idToCat(_number);
    }
}