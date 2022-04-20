// SPDX-License-Identifier: MIT
// contract 0x9246735636283a9c6CeFA0d4449B770d6cceE73F owner 0xa979A7D30B281Deb4136b48aB14135a2e2467BB7
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";

contract  SJB is ERC20, Ownable{
    using SafeERC20 for IERC20;
    constructor(string memory name_, string memory symbol_) ERC20(name_,symbol_){}

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }
}