/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT

/*

  _  _____  _   _  ____   ____  _   _ ____  ____  
 | |/ / _ \| \ | |/ ___| | __ )| | | / ___||  _ \ 
 | ' / | | |  \| | |  _  |  _ \| | | \___ \| | | |
 | . \ |_| | |\  | |_| | | |_) | |_| |___) | |_| |
 |_|\_\___/|_| \_|\____| |____/ \___/|____/|____/ 
                                                  
The KONG BUSD is a ROI Dapp and part of the KONG-Eco System. 
The KONG BUSD is crated by combining the great features of the existing and past ROI Dapps. 
KONG BUSD is a 100% decentralized investment platform built on the Binance Smart Chain (BEP20). 
It offers a variable yield % of 1% to 4% with a maximum profit of 300% of the total deposited amount.

Visit website for more details: https://kongbusd.finance
*/




pragma solidity ^0.8.15;

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface KongBusdV2{
    function getUserAllStakeDetailsByAddress(address _userAddress) external view returns(userStakeV2[] memory);
    function stake(uint256 _amount, address _referrer) external returns (bool);
    function claim(uint256 _stakeId)  external returns (bool);
    function compound(uint256 _stakeId) external returns (bool);
    function setActionedTime(uint256 _stakeId, uint256 _days)  external;
    function setNextActionTime(uint256 _stakeId, uint256 _days)  external;
    function getClaimableBalance(uint256 _stakeId) external view returns(uint256);
}


struct userStakeV2{
    uint256 id;
    uint256 roi;
    uint256 stakeAmount;
    uint256 totalClaimed;
    uint256 totalCompounded;
    uint256 lastActionedTime;
    uint256 nextActionTime;
    uint256 status; //0 : Unstaked, 1 : Staked
    address referrer;
    address owner;
    uint256 createdTime;
}

contract babyKongPool {
    
    struct babyStake{
        uint256 id;
        uint256 totalClaimed;
        uint256 nextClaimTime;
        uint256 lastClaimedTime;
        address owner;
        uint256 createdTime;
    }
    babyStake[] public userStakeArray;

    address public busdAddress = 0xAe12F7EeA8FF55383109E0B28B95300082c5f78e;
    IERC20 busd = IERC20(busdAddress);

    address public kongV2Address = 0xF6b4F80181edE3BFB25cf3F60c730A5566eA2f16;
    KongBusdV2 kongV2 = KongBusdV2(kongV2Address);

    address public owner;
    uint256 public stakeAmount;
    uint256 public createdTime;
    uint256 public totalStaked;
    uint256 public totalClaimed;
    uint256 public totalCompounded;

    uint256 public stakeIndex;
    uint256 public nextCycleAction; //0 = compound, 1 = claim
    uint256 public nextActionTime;

    mapping (uint256 => babyStake) public userStakesById;
    mapping (address => babyStake) public userStakesByAddress;

    constructor(address _creatorAddress, uint256 _stakeAmount){
        owner = _creatorAddress;
        stakeAmount = _stakeAmount;
        nextCycleAction = 1; // compounding after 1 day
        nextActionTime =block.timestamp + 1 days;
        createdTime = block.timestamp;
    }

    function stake() external returns (bool) {
        uint256 _amount = 10 ether;
        address _referrer = owner;
        babyStake memory userStakeDetails;
        uint256 stakeId = stakeIndex++;
        userStakeDetails.id = stakeId;
        userStakeDetails.nextClaimTime = block.timestamp + 7 days;
        userStakeDetails.owner = msg.sender;
        userStakeDetails.createdTime = block.timestamp;
        userStakesById[stakeId] = userStakeDetails;
        userStakesByAddress[msg.sender] = userStakeDetails;
        require(busd.allowance(msg.sender, address(this)) >= _amount,"Not enough BUSD approved for transfer"); 
        bool success = busd.transferFrom(msg.sender, address(this), _amount);
        require(success, "BUSD Transfer failed.");
        busd.approve(kongV2Address,_amount);
        kongV2.stake(_amount, _referrer);

        return true;
    }

    /*
    function claim(uint256 _stakeId) public returns (bool){
        require(block.timestamp >= nextActionTime && nextCycleAction == 1,"Claiming not available" );
        babyStake memory userStakeDetails = userStakesById[_stakeId];
        require(userStakeDetails.nextClaimTime <= block.timestamp,"You are not eligibale to claim");
        userStakeDetails.nextClaimTime = block.timestamp + ((userStakeArray.length * 7)* 86400);
        kongV2.claim(_stakeId);
        nextActionTime =block.timestamp + 7 days;
        nextCycleAction = 0;
        return true;
    }
    
    function compound(uint256 _stakeId) public returns (bool){
        require(block.timestamp >= nextActionTime && nextCycleAction == 0,"Compounding not available" );
        kongV2.compound(_stakeId);
        nextActionTime =block.timestamp + 7 days;
        nextCycleAction = 1;
        return true;
    }
    */

    function getClaimableBalance(uint256 _stakeId) public view returns(uint256){    
        return kongV2.getClaimableBalance(_stakeId);
    }

    function getTotalClaimableBalance() public view returns(uint256){    
        userStakeV2[] memory userStakesList = kongV2.getUserAllStakeDetailsByAddress(address(this));
        uint256 totalClaimableBalance;
        for(uint256 i = 0; i < userStakesList.length; i++){
            uint256 lapsedDays = ((block.timestamp - userStakesList[i].lastActionedTime)/3600)/24; //3600 seconds per hour so: lapsed days = lapsed time * (3600seconds /24hrs)
            if(lapsedDays >= 1){
                totalClaimableBalance += kongV2.getClaimableBalance(userStakesList[i].id);
            }
        }

        return totalClaimableBalance;
    }

    function getUserAllStakeDetailsByAddress(address _userAddress) external view returns(userStakeV2[] memory){
        userStakeV2[] memory userStakesList = kongV2.getUserAllStakeDetailsByAddress(_userAddress);
        return userStakesList;
    }

    function claimAllStakes() public {
        require(block.timestamp >= nextActionTime && nextCycleAction == 1,"Claiming not available" );
        babyStake memory userStakeDetails = userStakesByAddress[msg.sender];
        require(userStakeDetails.nextClaimTime <= block.timestamp,"You are not eligibale to claim");
        userStakeDetails.nextClaimTime = block.timestamp + (userStakeArray.length * 86400);
        nextActionTime =block.timestamp + 7 days;
        nextCycleAction = 0;

        userStakeV2[] memory userStakesList = kongV2.getUserAllStakeDetailsByAddress(address(this));

        for(uint256 i = 0; i < userStakesList.length; i++){
            uint256 lapsedDays = ((block.timestamp - userStakesList[i].lastActionedTime)/3600)/24; //3600 seconds per hour so: lapsed days = lapsed time * (3600seconds /24hrs)
            if(lapsedDays >= 1){
                kongV2.claim(userStakesList[i].id);
            }
        }

        bool success = busd.transfer(msg.sender, busd.balanceOf(address(this)));
        require(success, "BUSD Transfer failed.");
    }

    function compoundAllStakes() public {
        require(block.timestamp >= nextActionTime && nextCycleAction == 0,"Compounding not available" );
        userStakeV2[] memory userStakesList = kongV2.getUserAllStakeDetailsByAddress(address(this));
        nextActionTime =block.timestamp + 7 days;
        nextCycleAction = 1;

        for(uint256 i = 0; i < userStakesList.length; i++){
            uint256 lapsedDays = ((block.timestamp - userStakesList[i].lastActionedTime)/3600)/24; //3600 seconds per hour so: lapsed days = lapsed time * (3600seconds /24hrs)
            if(lapsedDays >= 1){
                kongV2.compound(userStakesList[i].id);
            }
        }
        
    }
    //Testing functions

    function setActionedTime(uint256 _stakeId, uint256 _days)  public {
        kongV2.setActionedTime(_stakeId,_days);
    }

    function setNextActionTime(uint256 _stakeId, uint256 _days)  public {
       kongV2.setNextActionTime(_stakeId,_days);
    }
    
    function setPoolNextActionedTime(uint256 _action, uint256 _days)  public {
        nextActionTime = block.timestamp + (_days * 86400);
        nextCycleAction = _action;

    }

    receive() external payable {}
}