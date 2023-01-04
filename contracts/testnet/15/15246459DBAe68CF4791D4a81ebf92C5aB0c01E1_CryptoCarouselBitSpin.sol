/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface CryptoCarouselReferralProgram {
    function getLevels() external view returns (uint256);
    function getPercent(uint256 _level) external view returns(uint256);
}

interface CryptoCarouselWeeklyLottery {
    function getPlayers() external view returns(address[] memory, uint256[] memory);
    function addCount(address _address, uint256 _count) external;
}

interface CryptoCarouselReferrals {
    function newPlayer(address _address, address _ref) external;
}

contract CryptoCarouselBitSpin{
    address owner;
    address weeklyLotteryContract;
    address referralProgramContract;
    address referralsContract;
    CryptoCarouselWeeklyLottery weeklyLottery;
    CryptoCarouselReferralProgram referralProgram;
    CryptoCarouselReferrals referrals;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Function is OnlyOwner");
        _;
    }

    function setWeeklyLotteryContract(address _address) onlyOwner public{
        weeklyLotteryContract = _address;
        weeklyLottery = CryptoCarouselWeeklyLottery(_address);
    }

    function setReferralProgramContract(address _address) onlyOwner public{
        referralProgramContract = _address;
        referralProgram = CryptoCarouselReferralProgram(_address);
    }

    function setReferralsContract(address _address) onlyOwner public{
        referralsContract = _address;
        referrals = CryptoCarouselReferrals(_address);
    }

    function startGame(address _ref) payable public{
        require(msg.value > 0, "Not enough money");
        uint256 balance = msg.value;
        referrals.newPlayer(msg.sender, _ref);
        weeklyLottery.addCount(msg.sender, msg.value);
        payable(weeklyLotteryContract).transfer(balance * 10 / 100);
        payable(owner).transfer(balance / 100);
        //for(uint256 i = 1; i <= referralProgram.getLevels(); i++){
        //    payable(referrals.getRefByLevel(msg.sender,i)).transfer(balance * referralProgram.getPercent(i) / 100);
        //}
    }

    function startGame() payable public{
        startGame(owner);
    }

    function getStatistic() view public returns(address[] memory, uint256[] memory){
        return weeklyLottery.getPlayers();
    }

    function getRef() view public returns(uint256){
        return weeklyLotteryContract.balance;
    }

}