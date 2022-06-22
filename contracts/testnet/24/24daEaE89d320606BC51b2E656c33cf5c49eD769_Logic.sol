/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

pragma solidity >=0.6.0 <0.8.0;


contract Logic {
    uint256 public amount;


    constructor() public {}

    function getAmount() public view returns(uint256) {
        return amount;
    }

    function setAmount(uint256 _newAmount) public {
        amount = _newAmount;
    }

}