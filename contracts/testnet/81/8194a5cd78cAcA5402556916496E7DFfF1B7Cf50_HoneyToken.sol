// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";

contract HoneyToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("HoneyToken", "HT") {
        whiteList[msg.sender]=true;
        _mint(msg.sender, 500000 * 10 ** decimals());
        
    }
    function addToWhiteList(address add) public onlyOwner{
        whiteList[add]=true;
    }
    function removeFromWhiteList(address add)public onlyOwner{
        whiteList[add]=false;
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        require(whiteList[msg.sender],"This function is not allowed");
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) public virtual override returns (bool) {
        require(whiteList[msg.sender],"This function is not allowed");
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
}