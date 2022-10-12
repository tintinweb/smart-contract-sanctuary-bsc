// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Ownable.sol";

interface IClaimAndShare {
    function claimMintRewardAndShare(address other, uint256 pct) external;
    function claimRank(uint256 term) external payable;
}

contract GankXener {
    function doClaim(address xenAddress) public  {
        IClaimAndShare(xenAddress).claimRank(1);
    }

    function doClaimMintRewardAndShare(address xenAddress, address other, uint256 pct) public  {
        IClaimAndShare(xenAddress).claimMintRewardAndShare(other, pct);
    }
}

contract GankXen is Ownable {

    address[1000] gankers;
    uint hasInit = 0;
    uint batchCount;

    function init(uint _batchCount) external {
        require(hasInit == 0, "already init");
        for (uint i = 0; i < _batchCount; i++) {
            GankXener gankerContract = new GankXener();
            gankers[i] = address(gankerContract);
        }

        hasInit = 1;
        batchCount = _batchCount;
    }

    function doGank(address xenAddress) external onlyOwner {
        for (uint i = 0; i < batchCount; i++) {
            GankXener(gankers[i]).doClaim(xenAddress);
        }
    }

    function doReward(address xenAddress, address other) external onlyOwner  {
        for (uint i = 0; i < batchCount; i++) {
            GankXener(gankers[i]).doClaimMintRewardAndShare(xenAddress, other, 100);
        }
    }

}