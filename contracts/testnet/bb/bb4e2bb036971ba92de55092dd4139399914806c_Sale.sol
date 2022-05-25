/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract Sale {

    struct Buyer {
        address buyerAddress;
        uint256 amount;
    }

    Buyer[] public buyers;

    function buyTokens(uint256 _amount) public {
        buyers.push(Buyer(msg.sender, _amount));
    }

    function showBuyers() public view returns(Buyer[] memory) {
        return buyers;
    }

}