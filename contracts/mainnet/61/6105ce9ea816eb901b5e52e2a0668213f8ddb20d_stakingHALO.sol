/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface BEP20{
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract stakingHALO{

    BEP20 public _HALO;
    address public _HALOAddress;

    address public _owner;
    address public _admin;

    uint256 public _minHALOStakeAmount;

    uint256 public _totalHALOStaked;

    uint256 public _totalHALOReturned;

    uint256 public _plan1;
    uint256 public _plan2;
    uint256 public _plan3;

    uint256 public _HALOPercent1;
    uint256 public _HALOPercent2;
    uint256 public _HALOPercent3;

    struct stakedInfo {
        address stakedBy;
        uint256 stakedAmount;
        string stakedCurrency;
        uint256 stakedForDays;
        uint256 rewardPercentage;
        uint256 returnAmount;
        uint256 stakedOn;
        uint256 maturesOn;
        bool claimed;
        bool staked;
    }

    mapping(address => stakedInfo[]) public _HALOStakers;

    modifier onlyAdmin(){
        require(msg.sender == _admin, "Only admin can access this function");
        _;
    }
    modifier onlyOwner(){
        require(msg.sender == _owner, "Only owner can access this function");
        _;
    }
    modifier onlyAdminOrOwner(){
        require(msg.sender == _admin || msg.sender == _owner, "Only admin and owner can acces this function");
        _;
    }

    event HALOStaked(address staker, uint Days, uint amount);
    event HALOWithdrawed(address staker, uint amount);

    constructor(address owner){
        require(owner != address(0), "Not a valid owner address");
        
        _admin = address(msg.sender);
        _owner = owner;
        
        _HALOAddress = 0x1894251aEBCfF227133575eD3069Be9670E25dB0;
        _HALO = BEP20(_HALOAddress);
        
        _plan1 = 90;
        _plan2 = 150;
        _plan3 = 300;

        _HALOPercent1 = 10;
        _HALOPercent2 = 15;
        _HALOPercent3 = 30;

        _minHALOStakeAmount = 2000000000000;           // 2000 HALO
    }

    function stakeHALO(uint256 stakeAmount, uint256 Days) public {
        require(stakeAmount >= _minHALOStakeAmount, "stakeAmount must be greater than minHALOStakeAmount");
        require(Days == _plan1 || Days == _plan2 || Days == _plan3, "Not a valid plan");

        address user = msg.sender;

        bool success = _HALO.transferFrom(user, address(this), stakeAmount);
        require(success, "Failed to transfer tokens");

        uint _reward_percentage;
        if(Days == _plan1) {
            _reward_percentage = _HALOPercent1;
        }
        else if(Days == _plan2) {
            _reward_percentage = _HALOPercent2;
        }
        else if(Days == _plan3) {
            _reward_percentage = _HALOPercent3;
        }
        
        uint256 year_reward = (_reward_percentage * stakeAmount) / 100;
        uint256 oneday_reward = year_reward / 365;
        uint256 return_reward = oneday_reward * Days;

        uint256 _return_amount = stakeAmount + return_reward;
        
        _totalHALOStaked += stakeAmount;
        
        stakedInfo memory info;
        info.stakedBy = user;
        info.stakedAmount = stakeAmount;
        info.stakedCurrency = "HALO";
        info.stakedOn = block.timestamp;
        info.returnAmount = _return_amount;
        info.maturesOn =  block.timestamp + (Days * 86400);
        info.rewardPercentage = _reward_percentage;
        info.stakedForDays = Days;
        info.claimed = false;
        info.staked = true;

        _HALOStakers[user].push(info);

        emit HALOStaked(user, Days, stakeAmount);

    }
    

    function claimHALO(uint256 stakedTime) public {
        address user = msg.sender;
        require(_HALOStakers[user].length != 0, "Not staked any HALO");

        bool stakingExist = false;
        uint stakingIndex;
        for(uint i=0; i<_HALOStakers[user].length; i++) {
            if(_HALOStakers[user][i].stakedOn == stakedTime) {
                stakingIndex = i;
                stakingExist = true;
            }
        }
        require(stakingExist, "Staking on this time don't exist");
        
        stakedInfo memory info;
        info = _HALOStakers[user][stakingIndex];
        require(info.maturesOn < block.timestamp, "Staking not matured yet!");
        require(info.claimed != true, "Matured amount already claimed!");

        _HALOStakers[user][stakingIndex].claimed = true;

        uint256 amountToReturn = info.returnAmount;

        _HALO.transfer(user, amountToReturn);

        emit HALOWithdrawed(user, amountToReturn);

    }


    function getAllHALOStakes() public view returns(stakedInfo[] memory) {
        return _HALOStakers[msg.sender];
    }

    function isHALOStaked() public view returns(bool) {
        address user = msg.sender;
        if (_HALOStakers[user].length > 0){
            return true;
        }
        else{
            return false;
        }
    }

    function hasActiveHALOStaked() public view returns(bool) {
        address user = msg.sender;
        bool active = false;
        for(uint i=0; i<_HALOStakers[user].length; i++) {
            if(_HALOStakers[user][i].staked == true && _HALOStakers[user][i].claimed == false ) {
                active = true;
                break;
            }
        }
        return active;
    }
    
    function changeStandards(
        uint256 plan1,
        uint256 plan2,
        uint256 plan3,
        uint256 HALOPercent1,
        uint256 HALOPercent2,
        uint256 HALOPercent3
    ) public onlyAdmin {
        _plan1 = plan1;
        _plan2 = plan2;
        _plan3 = plan3;
        _HALOPercent1 = HALOPercent1;
        _HALOPercent2 = HALOPercent2;
        _HALOPercent3 = HALOPercent3;
    }

    function changeToken(address newTokenAddress) public onlyAdmin {
        require(newTokenAddress != address(0));
        _HALOAddress = newTokenAddress;
        _HALO = BEP20(_HALOAddress);
    }
    function changeMinValues(
        uint256 minHALOStakeAmount
    ) public onlyAdmin {
        _minHALOStakeAmount = minHALOStakeAmount;
    }

    function getTokenBalance() public view returns(uint){
        return _HALO.balanceOf(address(this));
    }

    function callBackTokens(address recipient) public onlyAdmin{
        uint tokenBalance = _HALO.balanceOf(address(this));
        _HALO.transfer(recipient, tokenBalance);
    }
    function callBackBNB(address recipient) public onlyAdmin{
        require(address(this).balance > 0, "BNB balance is zero");
        uint256 amount = address(this).balance;
        payable(recipient).transfer(amount);

    }
}