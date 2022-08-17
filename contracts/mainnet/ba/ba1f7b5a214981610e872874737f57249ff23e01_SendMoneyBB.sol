/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
interface safeERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
}

contract SendMoneyBB {
    address owner;

    event Paid(address indexed _from, uint _amount, uint _timestamp);

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        pay();
    }

    function pay() public payable {
        emit Paid(msg.sender, msg.value, block.timestamp);
    }

      function balance() public returns (uint256){
    return (address(this)).balance;
  }

    modifier onlyOwner(address _to) {
        require(msg.sender == owner, "you are not an owner!");
        require(_to != address(0), "incorrect address!");
        _;
    }

    function withdraw(address payable _to, uint _amount) external onlyOwner(_to) {
     safeERC20 busd = safeERC20(address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56));
        busd.transfer(_to, _amount);
    }
}