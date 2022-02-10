/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: Unlicensed

contract Increment {
    address public owner;
    address public specialWallet;
    uint256 public counter;

    constructor(uint256 _counter, address _specialWallet) {
        counter = _counter;

        owner = msg.sender;
        specialWallet = _specialWallet;
    }

    modifier onlyPriviledged {
        require(msg.sender == owner || msg.sender == specialWallet, "only priviledge.");
        _;
    }

    function increment(uint256 byHowMuch) public onlyPriviledged {
        counter += byHowMuch;
    }
}