/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

contract TestMainContract{
   
    mapping(address => address) public rewardAddresses;
    mapping(address => uint256) public rewardAmountOwner;

    address public checkContractAddr;
    address public checkRewardAddr;
    address public checkHardCoded;

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function registerContract(address contractAddr, address rewardAddr) external returns (bool) {

        //require(isContract(contractAddr) || !isContract(0x0000000000000000000000000000000000001000), "contractAddr isn't contract");
        rewardAddresses[contractAddr] = rewardAddr;
        rewardAmountOwner[rewardAddr] = 0;

        checkContractAddr = contractAddr;
        checkRewardAddr = rewardAddr;
        checkHardCoded = 0x0000000000000000000000000000000000001000;
       
        return true;
        
    }

}