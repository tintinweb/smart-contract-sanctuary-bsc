// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./ERC20.sol";
import "./Ownable.sol";

contract Token is ERC20, Ownable {



    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(address(this), 10**6* 10**uint(decimals()));
        //@dev If there is fees

    }

    function Withdraw(address to ,uint256 amount) external onlyOwner {
        approve(msg.sender, amount);
        require(transferFrom(address(this),to,amount),"Transaction failed") ;
    }
}