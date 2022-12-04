/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface Token{
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
}
interface NFTLike{
    function mints(address,uint) external;
}
contract HOTPOTShop  {

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "HOTPOTShop/not-authorized");
        _;
    }
   
    uint256                                           public  min = 1000*1E18;
    uint256                                           public  rate = 1400;
    mapping (address => address[])                    public  under;
    Token                                             public  usdt = Token(0xE85131c9530A2Fc55D3587F914Ba6c1415f7EF86);
    Token                                             public  hot;
    NFTLike                                           public  nft = NFTLike(0x1F34A930C8ff462753EC6d7A5AC2d34Df7167da8);
    mapping (address => UserInfo)                     public  userInfo;

    struct UserInfo {
        address    recommend;   
        uint256    renum;
        uint256    minted;
        uint256    rechargeed;
    }
    struct UnderInfo {
        address    owner;   
        uint256    rechargeed;
    }

    constructor() {
        wards[msg.sender] = 1;
    }

    function recharge(uint256 wad,address recommender) public {
        require(wad >= 1E18,'HOTPOTShop/1');
        UserInfo storage user = userInfo[msg.sender];
        user.rechargeed += wad;
        if(user.recommend == address(0) && recommender != address(0)) {
           user.recommend = recommender;
           under[recommender].push(msg.sender);
        }
        address up = user.recommend;
        if(up != address(0)) {
           UserInfo storage user1 = userInfo[up]; 
           user1.renum +=wad;
           uint256 nftamount = user1.renum/min - user1.minted;
           if(nftamount > 0) {
              user1.minted += nftamount;
              nft.mints(up,nftamount);
           }
        }
        usdt.transferFrom(msg.sender, address(this), wad);
        hot.transfer(msg.sender, wad*rate/10000);
    }

    function setnft(address _nft) public auth {
        nft = NFTLike(_nft);
    }
    function setHOT(address _hot) public auth {
        hot = Token(_hot);
    }
    function setMin(uint256 _min) public auth {
        min = _min;
    }
    function setRate(uint256 _rate) public auth {
        rate = _rate;
    }
    function withdraw(address asset,uint256 wad, address  usr) public  auth {
        Token(asset).transfer(usr,wad);
    }

    function getUnderInfo(address usr) public view returns(UnderInfo[] memory){
        uint length = under[usr].length;
        UnderInfo[] memory underInfo = new UnderInfo[](length);
        for (uint i = 0; i <length ; ++i) {
            address underAddress = under[usr][i];
            underInfo[i].owner  = underAddress;
            underInfo[i].rechargeed  = userInfo[underAddress].rechargeed;
        }
        return underInfo;
    }
}