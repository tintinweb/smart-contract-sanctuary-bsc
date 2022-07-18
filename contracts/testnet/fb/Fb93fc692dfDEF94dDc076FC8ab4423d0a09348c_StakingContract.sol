/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: MIT 
pragma solidity 0.8.4;

contract StakingContract{

    uint256 blocks = 720;
    // uint256 timeStart = ;

    struct Stake{
        uint256 amount;
        uint256 stakeEntry;
    }

    Stake[] public stakeList;

    function stake(uint256 _stakeAmount) public returns(string memory){
        // stakerList[msg.sender].push(Stake(_stakeAmount, block.timestamp));
        return "Stake successful";
    }

    function queryStakes(address _address) public view returns(Stake[] memory){
        // return stakerList[_address];
    }

    function harvest(address _address) public view returns(uint){
        uint result = 1;
        for(uint i = 1; i < blocks; i++){
            result = result * 5;
        }

        return result;
    }

    // function queryAmountStake(address _address) public view returns(Stake[] memory){
    //     foreach(stakerList[_address]){

    //     }
    // }

}