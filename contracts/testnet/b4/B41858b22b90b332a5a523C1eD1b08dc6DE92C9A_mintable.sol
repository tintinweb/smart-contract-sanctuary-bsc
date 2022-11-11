//SPDX-License-Identifier:Unlicensed
pragma solidity 0.8.17;

import "./erc20.sol";

contract mintable is ERC20{

    constructor(uint256 totalSupply_,string memory name_,string memory symbol_,address owner_) ERC20(totalSupply_,name_,symbol_,owner_){

    }


    function mint(address account, uint256 amount) external  onlyOwner{
        require(account != address(0), "ERC20: mint to the zero address");


        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

    }
    
}