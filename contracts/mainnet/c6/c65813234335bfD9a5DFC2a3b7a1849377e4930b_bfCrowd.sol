/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface Token{
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
}
interface NFTLike{
    function mint(address) external;
}
contract bfCrowd  {

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "bfCrowd/not-authorized");
        _;
    }
    address                                           public  projectAddress = 0x54f2EefAC44861B17e18391b56Bcc1334b1c87Fb;
    uint256                                           public  min = 10;
    uint256                                           public  people;
    uint256                                           public  max = 200;
    mapping (address => uint256)                      public  weight; 
    mapping (address => address)                      public  recommend;
    mapping (address => bool)                         public  minted;
    mapping (address => uint256)                      public  renum;   
    Token                                             public  usdt = Token(0x55d398326f99059fF775485246999027B3197955);
    Token                                             public  bf;
    NFTLike                                           public  nft = NFTLike(0x4542cD1589b3D056efeaa4d8270BDD90c1d16157);
    constructor() {
        wards[msg.sender] = 1;
    }

    function crowd(address recommender) public {
        require(weight[msg.sender]==0,'1');
        require(people < max,'4');
        if (recommender != address(0)){
            recommend[msg.sender] = recommender;
            renum[recommender] +=1;
            if(renum[recommender]>=min && renum[recommender]%min == 0) nft.mint(recommender);
        }
        usdt.transferFrom(msg.sender, projectAddress, 100*1E18);
        weight[msg.sender] = 1;
        people +=1;
    }
    function withdrawBf() public{
        require(weight[msg.sender]==1,'2');
        bf.transfer(msg.sender, 1000*1E18);
        weight[msg.sender] = 2;
    }
    function withdrawNFT() public{
        require(renum[msg.sender]>=min && !minted[msg.sender],'3');
        minted[msg.sender] = true;
    }
    function setfound(address _found) public auth {
        projectAddress = _found;
    }
    function setnft(address _nft) public auth {
        nft = NFTLike(_nft);
    }
    function setbf(address _bf) public auth {
        bf = Token(_bf);
    }
    function setMin(uint256 _min) public auth {
        min = _min;
    }
    function setMan(uint256 _max) public auth {
        max = _max;
    }
    function withdraw(address asset,uint256 wad, address  usr) public  auth returns (bool) {
        Token(asset).transfer(usr,wad);
        return true;
    }
}