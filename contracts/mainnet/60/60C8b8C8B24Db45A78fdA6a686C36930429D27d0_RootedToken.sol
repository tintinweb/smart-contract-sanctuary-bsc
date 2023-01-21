// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;

import "./LiquidityLockedERC20.sol";

contract RootedToken is LiquidityLockedERC20("Degen Protocol Elite", "SH33P") {
    address public minter;

    function setMinter(address _minter) public ownerOnly() {
        minter = _minter;
    }

    function mint(uint256 amount) public {
        require(msg.sender == minter, "Not a minter");
        require(this.totalSupply() == 0, "Already minted");
        _mint(msg.sender, amount);
    }
}