/**
 *Submitted for verification at BscScan.com on 2021-02-12
*/

pragma solidity ^0.8.15;

contract PriceConsumerV3 {
    
    uint public price = 13374449721; // 133$, 8 decimals
    address public admin;
    
    constructor() {
        admin = msg.sender;
    }
    
    function setLatestPrice(uint _price) public returns (uint) {
        require(msg.sender == admin);
        price = _price;
    }
    
    function latestAnswer() public view returns (uint) {
        return price;
    }
}