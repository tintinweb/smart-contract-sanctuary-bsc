/**
 *Submitted for verification at BscScan.com on 2022-11-22
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
    address                                           public  projectAddress;
    uint256                                           public  min = 10;
    mapping (address => uint256)                      public  weight; 
    mapping (address => address)                      public  recommend;
    mapping (address => bool)                         public  minted;
    mapping (address => uint256)                      public  renum;   
    Token                                             public  usdt = Token(0xE85131c9530A2Fc55D3587F914Ba6c1415f7EF86);
    Token                                             public  bf;
    NFTLike                                           public  nft = NFTLike(0x79A0842743c7a37a2914D42294FCdF68f33a742c);
    constructor() {
        wards[msg.sender] = 1;
    }

    function crowd(address recommender) public {
        require(weight[msg.sender]==0,'1');
        if (recommender != address(0)){
            recommend[msg.sender] = recommender;
            renum[recommender] +=1;
        }
        usdt.transferFrom(msg.sender, projectAddress, 100*1E18);
        weight[msg.sender] = 1;
    }
    function withdrawBf() public{
        require(weight[msg.sender]==1,'2');
        bf.transfer(msg.sender, 1000*1E18);
        weight[msg.sender] = 2;
    }
    function withdrawNFT() public{
        require(renum[msg.sender]>=min && !minted[msg.sender],'3');
        nft.mint(msg.sender);
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
    function setmin(uint256 _min) public auth {
        min = _min;
    }
    function withdraw(address asset,uint256 wad, address  usr) public  auth returns (bool) {
        Token(asset).transfer(usr,wad);
        return true;
    }
}