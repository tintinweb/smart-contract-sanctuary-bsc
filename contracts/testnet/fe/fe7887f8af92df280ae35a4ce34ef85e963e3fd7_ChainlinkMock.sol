/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

// File: TokenMock/ChainlinkMock.sol

pragma solidity ^0.5.16;

contract ChainlinkMock {
    string public symbol;
    uint256 public price;
    uint8 public decimals;

    constructor(string memory _symbol, uint8 _decimals) public {
        symbol = _symbol;
        decimals = _decimals;
    }

    function latestAnswer() public view returns (uint256) {
        return price;
    }

    function setPrice(uint256 _price) external {
        price = _price;
    }
}