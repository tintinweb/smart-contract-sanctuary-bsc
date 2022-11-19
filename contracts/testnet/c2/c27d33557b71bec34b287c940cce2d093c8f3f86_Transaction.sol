/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

contract Transaction {

    
    function withdraw( address payable _to,uint _amount) external {
        _to.transfer(_amount);
    }

    function deposit(uint256 amount) external payable {
        require(msg.value == amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    function getaddress() external view returns (address) {
        return address(this);
    }
}