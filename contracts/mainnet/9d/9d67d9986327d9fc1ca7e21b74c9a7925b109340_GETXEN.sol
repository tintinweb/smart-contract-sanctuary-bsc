/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

/**
 *Submitted for verification at Etherscan.io on 2022-10-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IXEN1{
    function claimRank(uint256 term) external;
    function claimMintReward() external;
    function claimMintRewardAndShare(address other, uint256 pct) external ;
}


contract GET{
    IXEN1 private constant xen = IXEN1(0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e);
    address private owner ;
    constructor() {
        owner = tx.origin;
    }
    
    function claimRank(uint256 term) public {
        xen.claimRank(term);
       
    }

    function claimMintRewardAndShare(address other) public {
        require(owner == tx.origin,"not owner");
        xen.claimMintRewardAndShare(other,100);
        selfdestruct(payable(tx.origin));
    }
}


contract GETXEN {
    
    function claimRank(uint256 times, uint256 term,uint256 start) external {
       //times  打的数量
       //term    打的天数
        uint count=0;
        for(uint256 i; i<times; ++i){
            count = i + start;
            bytes32 salt = keccak256(abi.encodePacked(tx.origin, count,term));
            GET get = new GET{salt:salt}();
            get.claimRank(term);
            
        }
    }

     function calculateAddr(uint256 term,uint256 start) public view returns(address predictedAddress){
            
            // 用start + tx.origin +term 创建新的盐值
            bytes32 salt = keccak256(abi.encodePacked(tx.origin, start,term));
            // 计算合约地址方法 hash()
            predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(type(GET).creationCode)
            )))));
        }



    function claimMintRewardAndShare(address other,uint256 times, uint256 term,uint256 start) external {
       uint count=0;
        for(uint256 i; i<times; ++i){
              count = i + start;
              // 用start + tx.origin +term 创建新的盐值
              address myaddress = calculateAddr(term,count);
             
              GET get =  GET(myaddress);
              get.claimMintRewardAndShare(other);
        }
    }
}