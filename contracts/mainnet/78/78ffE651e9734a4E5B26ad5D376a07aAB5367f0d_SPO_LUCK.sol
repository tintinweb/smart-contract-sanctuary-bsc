/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.5.10;


interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
}

contract SPO_LUCK {
    using SafeMath for uint256;
    
    address public owner;
    IERC20 public SPO;
    uint256 public endTime;
    constructor() public {
        owner = address(0x9DF09E0ca505326837Ad8fa5f1821f0298288bF9);
        endTime = now.add(86400*90);
        SPO = IERC20(0xBf6fDb357F96FDcb13F9aEA3118f659EbBCABAd8);
    }

    function withdrawSpo() public {
        require(msg.sender == owner);
        require(now >= endTime);
        SPO.transfer(msg.sender,SPO.balanceOf(address(this)));
    }
}