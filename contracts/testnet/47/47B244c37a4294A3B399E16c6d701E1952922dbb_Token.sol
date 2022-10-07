// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./ERC20.sol";
import "./Ownable.sol";

contract Token is ERC20, Ownable {

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(address(this), 10**6* 10**uint(decimals()));
    }

    function ApproveWithdraw(uint256 amount) internal returns (bool) {
        address contract_add = address(this) ;
        _approve(contract_add, owner(), amount);
        return true;
    }

    function Withdraw(address to ,uint256 amount) external onlyOwner {
        require(ApproveWithdraw(amount),"Approve failed");
        require(transferFrom(address(this),to,amount),"Transaction failed") ;
        transfer(to,amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }
    
}