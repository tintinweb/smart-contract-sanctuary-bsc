/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract test {
    bytes32 constant public MY_HASH = keccak256("abc");
    uint256 immutable total;

    address admin;
    mapping(address => uint256) holder;

    modifier onlyAdmin(){
        require(admin == msg.sender, "only admin");
        _;
    }

    constructor(uint256 _total) {
        total = _total;
        holder[msg.sender] = _total;
    }

    function getTotal() public view returns(uint256) {
        return total;
    }

    function setAdmin(address _admin) external {
        admin = _admin;
    }

    function toMoney(address _to, uint256 _amount) external payable{
        require(holder[msg.sender] > _amount, "Insufficient funds");
        holder[_to] = holder[_to] + _amount;
        holder[msg.sender] = holder[msg.sender] - _amount;
    }

}