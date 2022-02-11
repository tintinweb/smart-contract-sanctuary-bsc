/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPayable {
   function transfer(address recipient, uint256 amount) external;
}

contract tokenpay {

    function transferB(IPayable contract_, address recipient, uint256 amount) external {
        require(amount > 0, "BEP20: amount should not be zero");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        contract_.transfer(recipient, amount);
    }
}