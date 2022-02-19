/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

interface ERC20 {
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract Lottery {

    ERC20 lpToken;

    address[] bettors;

    uint firstNum = 1;
    uint secondNum = 10;
    uint thirdNum = 20;
    uint firstRatio = 50;
    uint secondRatio = 30;
    uint thirdRatio = 20;
    address[] firstWinners;
    address[] secondWinners;
    address[] thirdWinners;

    uint public round = 1;              // round
    uint public stake = 1000000000;     // stake
    uint currentStake = 0;              // current，50%
    uint totalStake = 0;                // total，20%
    uint inviteStake = 0;               // invite，20%
    uint managerStake = 0;              // manager，10%
    address public manager;

    constructor(ERC20 _lpToken) {
        lpToken = ERC20(_lpToken);
        manager = msg.sender;
    }

    // getBettors
    function getBettors() public view returns(address[] memory) {
        return bettors;
    }

    // getNumberOfBettors
    function getNumberOfBettors() public view returns(uint){
        return bettors.length;
    }

    // getStakeOfCurrent
    function getStakeOfCurrent() public view returns(uint){
        return currentStake;
    }

    // getStakeOfTotal
    function getStakeOfTotal() public view returns(uint){
        return totalStake;
    }

    // getStakeOfInvite
    function getStakeOfInvite() public view returns(uint){
        return inviteStake;
    }

    // getStakeOfManager
    function getStakeOfManager() public view returns(uint){
        return managerStake;
    }

    // setStake
    function setStake(uint _stake) public onlyManagerCanCall {
        stake = _stake;
    }
    
    // setFirstNum
    function setFirstNum(uint _num) public onlyManagerCanCall {
        firstNum = _num;
    }
    
    // setFirstNum
    function setFirstRatio(uint _ratio) public onlyManagerCanCall {
        firstRatio = _ratio;
    }
    
    // setSecondNum
    function setSecondNum(uint _num) public onlyManagerCanCall {
        secondNum = _num;
    }
    
    // setSecondRatio
    function setSecondRatio(uint _ratio) public onlyManagerCanCall {
        secondRatio = _ratio;
    }
    
    // setThirdNum
    function setThirdNum(uint _num) public onlyManagerCanCall {
        thirdNum = _num;
    }
    
    // setThirdRatio
    function setThirdRatio(uint _ratio) public onlyManagerCanCall {
        thirdRatio = _ratio;
    }

    // bet
    function bet() public {
        require(lpToken.balanceOf(msg.sender) >= stake);

        lpToken.transferFrom(msg.sender, address(this), stake); // transfer

        currentStake = currentStake + stake * 50 / 100; // 50%
        totalStake = totalStake + stake * 20 / 100;     // 20%
        inviteStake = inviteStake + stake * 20 / 100;   // 20%
        managerStake = managerStake + stake * 10 / 100; // 10%

        bettors.push(msg.sender);
    }

    // lottery
    function lottery() public onlyManagerCanCall {
        require(bettors.length > firstNum + secondNum + thirdNum, "bet people is not enough !!");

        for ( uint i = 0; i < firstNum; i++ ) {
            uint256 index1 = random(bettors.length);
            firstWinners.push(bettors[index1]);
            removeAtIndex(index1);
        }
        for ( uint j = 0; j < secondNum; j++ ) {
            uint256 index2 = random(bettors.length);
            secondWinners.push(bettors[index2]);
            removeAtIndex(index2);
        }
        for ( uint k = 0; k < thirdNum; k++ ) {
            uint256 index3 = random(bettors.length);
            thirdWinners.push(bettors[index3]);
            removeAtIndex(index3);
        }

        uint firstReward = currentStake * firstRatio / 100 / firstNum;
        for ( uint i1 = 0; i1 < firstWinners.length; i1++ ) {
            lpToken.transfer(firstWinners[i1], firstReward); // transfer
        }

        uint secondReward = currentStake * secondRatio / 100 / secondNum;
        for ( uint j1 = 0; j1 < secondWinners.length; j1++ ) {
            lpToken.transfer(secondWinners[j1], secondReward); // transfer
        }

        uint thirdReward = currentStake * thirdRatio / 100 / thirdNum;
        for ( uint k1 = 0; k1 < thirdWinners.length; k1++ ) {
            lpToken.transfer(thirdWinners[k1], thirdReward); // transfer
        }

        // delete
        delete bettors;
        delete firstWinners;
        delete secondWinners;
        delete thirdWinners;

        currentStake = 0;

        round++;

    }

    // withdraw all
    function withdrawAll() public onlyManagerCanCall {
        lpToken.transfer(manager, lpToken.balanceOf(address(this))); // transfer
    }

    // withdraw invite
    function withdrawStakeOfInvite(address _address) public onlyManagerCanCall {
        require(inviteStake > 0, "invite stake is not enough !!");
        lpToken.transfer(_address, inviteStake); // transfer
    }

    // withdraw manager
    function withdrawStakeOfManager(address _address) public onlyManagerCanCall {
        require(managerStake > 0, "manager stake is not enough !!");
        lpToken.transfer(_address, managerStake); // transfer
    }

    // random
    function random(uint256 _length) internal view returns(uint256) {
        uint256 r = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return r % _length;
    }

    // remove 
    function removeAtIndex(uint index) internal returns (address[] memory) {
        require(index < bettors.length);

        for (uint i = index; i < bettors.length-1; i++) {
            bettors[i] = bettors[i+1];
        }
        bettors.pop();

        return bettors;
    }

    // only manager
    modifier onlyManagerCanCall() {
        require(msg.sender == manager);
        _;
    }

}