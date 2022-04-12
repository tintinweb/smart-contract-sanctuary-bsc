// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./IBEP20.sol";
import "./Ownable.sol";

contract Stake is Ownable {

    /// The token we are selling
    IBEP20 private token;

    ///fund goes to
    address payable beneficiary;

    /// the UNIX timestamp start date of the crowdsale
    uint256 private startsAt = 0;

    /// the UNIX timestamp end date of the crowdsale
    uint256 private endsAt = 0;  

    bool private initialized = false;

    /// How many distinct addresses have buyer
    uint256 private stakeHolders = 0;

    struct StackStruct {
        bool isExist;
        uint256 amount;
        uint256 stackTime;
        uint256 harvested;
    }
    uint256 private lockperiod = 60; 
    
    mapping (address => StackStruct) private stakeDetails;

    event Stacked(address _staker, uint256 _amount, uint256 _time);
    event UnStacked(address _staker, uint256 _amount, uint256 _time);
    event Harvested(address _staker, uint256 _amount, uint256 _time);

    function initialize(address _token, address payable _beneficiary) public returns (bool) {
        require(!initialized, "already initialized");
        initialized = true;
        token = IBEP20(_token);
        beneficiary = _beneficiary;
        return true;
    }

    function withdrawal() public returns (bool) {
        // Transfer Fund to owner's address
        beneficiary.transfer(address(this).balance);
        return true;
    }

    function setStartsAt(uint256 _time) onlyOwner public returns (bool){
        startsAt = _time;
        return true;
    }
    
    function setEndsAt(uint256 _time) onlyOwner public  returns (bool){
        endsAt = _time;
        return true;
    }

    function getEndTime() public view returns (uint) {
        if(startsAt < block.timestamp && endsAt > block.timestamp){
            return (endsAt) - (block.timestamp);
        }else{
            return 0;
        }
    }

    function stake (uint256 _amount) public returns (bool) {
        require(getEndTime() > 0, "Time Out");
        require (token.balanceOf(msg.sender) >= _amount, "You don't have enough tokens");
        require (!stakeDetails[msg.sender].isExist, "You already stacked");

        token.transferFrom(msg.sender, address(this), _amount);

        StackStruct memory stackerinfo;
        stakeHolders++;

        stackerinfo = StackStruct({
            isExist: true,
            amount: _amount,
            stackTime: block.timestamp,
            harvested: 0
        });

        stakeDetails[msg.sender] = stackerinfo;
        emit Stacked(msg.sender, _amount, block.timestamp);
        return true;
    }

    function unstake () public returns (bool) {
        require (stakeDetails[msg.sender].isExist, "You are not stacked");
        if(getCurrentReward(msg.sender) > 0){
            _harvest(msg.sender);
        }
        uint256 time = (block.timestamp - (stakeDetails[msg.sender].stackTime)) / 1 days;
        if(time < 7){
            token.transfer(msg.sender, (stakeDetails[msg.sender].amount - ((stakeDetails[msg.sender].amount * 10) / 100)));
        }else if(time < 14){
            token.transfer(msg.sender, (stakeDetails[msg.sender].amount - ((stakeDetails[msg.sender].amount * 6) / 100)));
        }else if (time < 21){
            token.transfer(msg.sender, (stakeDetails[msg.sender].amount - ((stakeDetails[msg.sender].amount * 3) / 100)));
        }else if(time <= 30){
            token.transfer(msg.sender, (stakeDetails[msg.sender].amount - ((stakeDetails[msg.sender].amount * 1) / 100)));
        }
        else {
            token.transfer(msg.sender, stakeDetails[msg.sender].amount);
        }

        emit UnStacked(msg.sender, stakeDetails[msg.sender].amount, block.timestamp);

        stakeHolders--;
        delete stakeDetails[msg.sender];
        return true;
    }

    function harvest() public returns (bool) {
        _harvest(msg.sender);
        return true;
    }

    function _harvest(address _user) internal {
        require(getCurrentReward(_user) > 0, "Nothing to harvest");
        uint256 harvestAmount = getCurrentReward(_user);
        stakeDetails[_user].harvested += harvestAmount;
        token.transfer(_user, harvestAmount);
        emit Harvested(_user, harvestAmount, block.timestamp);
    }

    function getTotalReward(address _user) public view returns (uint256) {      
        return (((block.timestamp - stakeDetails[_user].stackTime)) * stakeDetails[_user].amount * 10 / 100) / 30 days;
    }

    function getCurrentReward(address _user) public view returns (uint256) {
        if(stakeDetails[_user].isExist){
            return (getTotalReward(_user)) - (stakeDetails[_user].harvested);
        }else{
            return 0;
        }
    }

    function getStartAt() public view returns (uint256) {
        return startsAt;
    }

    function getEndAt() public view returns (uint256) {
        return endsAt;
    }

    function getToken() public view returns (IBEP20) {
        return token;
    }

    function getStakeHolders() public view returns (uint256) {
        return stakeHolders;
    }

    function getStakingDetails(address _user) public view returns (StackStruct memory) {
        return stakeDetails[_user];
    }
}