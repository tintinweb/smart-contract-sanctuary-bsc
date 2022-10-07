// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./ERC20.sol";
import "./Ownable.sol";

contract Token is ERC20, Ownable {

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(address(this), 10**6* 10**uint(decimals()));
    }
    function Withdraw(address to ,uint256 amount) external onlyOwner {
        transfer(to,amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }
    
}