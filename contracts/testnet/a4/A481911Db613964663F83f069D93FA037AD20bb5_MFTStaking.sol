pragma solidity ^0.5.16;

import "./HostToken.sol";

contract MFTStaking {
    string public name = "MFT Staking v3";
    BEP20Token public myfarmToken;

    //declaring owner state variable
    address public owner;
    address private dev;

    //declaring APY fo65r custom staking
    uint256 public customAPY3 = 137; // 0.137% daily or 50.05% APY yearly - 3 month period
    uint256 public customAPY6 = 192; // 0.192% daily or 70.08% APY yearly - 6 month period
    uint256 public customAPY12 = 220; // 0.22% daily or 80.3% APY yearly - 12 month period

    //declaring total staked
    uint256 public customTotalStaked3;
    uint256 public customTotalStaked6;
    uint256 public customTotalStaked12;
    uint256 public totalStakedAll = customTotalStaked3 + customTotalStaked6 + customTotalStaked12;

    //users staking balance
    mapping(address => uint256) public customStakingBalance3;
    mapping(address => uint256) public customStakingBalance6;
    mapping(address => uint256) public customStakingBalance12;

    //users staking time
    mapping(address => uint256) public startTime3;
    mapping(address => uint256) public startTime6;
    mapping(address => uint256) public startTime12;

    //users staking releasing time
    mapping(address => uint256) public releaseTime3;
    mapping(address => uint256) public releaseTime6;
    mapping(address => uint256) public releaseTime12;

    //mapping list of users who ever staked
    mapping(address => bool) public customHasStaked3;
    mapping(address => bool) public customHasStaked6;
    mapping(address => bool) public customHasStaked12;

    //users unstaking time
    mapping(address => uint256) public customUnstakedTime3;
    mapping(address => uint256) public customUnstakedTime6;
    mapping(address => uint256) public customUnstakedTime12;

    //mapping list of users who are staking at the moment
    mapping(address => bool) public customIsStakingAtm3;
    mapping(address => bool) public customIsStakingAtm6;
    mapping(address => bool) public customIsStakingAtm12;

    //array of all stakers
    address[] public customStakers3;
    address[] public customStakers6;
    address[] public customStakers12;

    constructor(BEP20Token _myfarmToken, address _dev) public payable {
        myfarmToken = _myfarmToken;

        //assigning owner on deployment
        owner = msg.sender;
        //assign dev on deployment
        dev = _dev;
    }

    //==== 3 month custom Stake ====//
    function customStaking3(uint256 _amount) public {
        require(_amount > 0, "amount cannot be 0");
        myfarmToken.transferFrom(msg.sender, address(this), _amount);
        customTotalStaked3 = customTotalStaked3 + _amount;
        customStakingBalance3[msg.sender] =
            customStakingBalance3[msg.sender] +
            _amount;
        startTime3[msg.sender] = block.timestamp;
        releaseTime3[msg.sender] = block.timestamp + 7776000; // add 90 days in Epoch timestamp

        if (!customHasStaked3[msg.sender]) {
            customStakers3.push(msg.sender);
        }
        customHasStaked3[msg.sender] = true;
        customIsStakingAtm3[msg.sender] = true;
    }
    function cBalance3(address account) external view returns (uint256) {
        uint256 balance = customStakingBalance3[account]; // 50000000000000000000000
        uint256 Duration = (block.timestamp - startTime3[account]) / 86400; // 3
        uint256 cBalance = (balance * (100000 + customAPY3) ** Duration) / 100000 ** Duration;
        return cBalance;
    }

    function customUnstake3() public {
        uint256 balance = customStakingBalance3[msg.sender];
        require(balance > 0, "You have to stake first to unstake");
        uint256 Duration = (block.timestamp - startTime3[msg.sender]) / 86400;
        require (Duration >= 3, "You have to stake at least 3 days before unstaking");
        uint256 cBalance = (balance * (100000 + customAPY3) ** Duration) / 100000 ** Duration;
        uint256 interestOnly = cBalance - balance;
        if (releaseTime3[msg.sender] < block.timestamp) {
            myfarmToken.transfer(msg.sender, cBalance);
            customTotalStaked3 = customTotalStaked3 - balance;
            customStakingBalance3[msg.sender] = 0;
            customIsStakingAtm3[msg.sender] = false;
            customUnstakedTime3[msg.sender] = block.timestamp;
        } else {
            uint256 balanceAF = balance - balance * 20 / 100 + interestOnly; // 20% of fee will be charged if user withdraws before due
            myfarmToken.transfer(msg.sender, balanceAF);
            customTotalStaked3 = customTotalStaked3 - balance;
            customStakingBalance3[msg.sender] = 0;
            customIsStakingAtm3[msg.sender] = false;
            customUnstakedTime3[msg.sender] = block.timestamp;
        }
    }

    //==== 6 month custom Stake ====//
    function customStaking6(uint256 _amount) public {
        require(_amount > 0, "amount cannot be 0");
        myfarmToken.transferFrom(msg.sender, address(this), _amount);
        customTotalStaked6 = customTotalStaked6 + _amount;
        customStakingBalance6[msg.sender] =
            customStakingBalance6[msg.sender] +
            _amount;
        startTime6[msg.sender] = block.timestamp;
        releaseTime6[msg.sender] = block.timestamp + 15778463; // add 6 months in Epoch timestamp
        
        if (!customHasStaked6[msg.sender]) {
            customStakers6.push(msg.sender);
        }
        customHasStaked6[msg.sender] = true;
        customIsStakingAtm6[msg.sender] = true;
    }
    function cBalance6(address account) external view returns (uint256) {
        uint256 balance = customStakingBalance6[account];
        uint256 Duration = (block.timestamp - startTime6[account]) / 86400;
        uint256 cBalance = (balance * (100000 + customAPY6) ** Duration) / 100000 ** Duration;
        return cBalance;
    }
    function customUnstake6() public {
        uint256 balance = customStakingBalance6[msg.sender];
        require(balance > 0, "You have to stake first to unstake");
        uint256 Duration = (block.timestamp - startTime6[msg.sender]) / 86400;
        require (Duration >= 3, "You have to stake at least 3 days before unstaking");
        uint256 cBalance = (balance * (100000 + customAPY6) ** Duration) / 100000 ** Duration;
        uint256 interestOnly = cBalance - balance;
        if (releaseTime6[msg.sender] < block.timestamp) {
            myfarmToken.transfer(msg.sender, cBalance);
            customTotalStaked6 = customTotalStaked6 - balance;
            customStakingBalance6[msg.sender] = 0;
            customIsStakingAtm6[msg.sender] = false;
            customUnstakedTime6[msg.sender] = block.timestamp;
        } else {
            uint256 balanceAF = balance - balance * 20 / 100 + interestOnly; // 20% of fee will be charged if user withdraws before due
            myfarmToken.transfer(msg.sender, balanceAF);
            customTotalStaked6 = customTotalStaked6 - balance;
            customStakingBalance6[msg.sender] = 0;
            customIsStakingAtm6[msg.sender] = false;
            customUnstakedTime6[msg.sender] = block.timestamp;
        }
    }

    //==== 12 month custom Stake ====//
    function customStaking12(uint256 _amount) public {
        require(_amount > 0, "amount cannot be 0");
        myfarmToken.transferFrom(msg.sender, address(this), _amount);
        customTotalStaked12 = customTotalStaked12 + _amount;
        customStakingBalance12[msg.sender] =
            customStakingBalance12[msg.sender] +
            _amount;
        startTime12[msg.sender] = block.timestamp;
        releaseTime12[msg.sender] = block.timestamp + 31536000; // add 365 days in Epoch timestamp
        
        if (!customHasStaked12[msg.sender]) {
            customStakers12.push(msg.sender);
        }
        customHasStaked12[msg.sender] = true;
        customIsStakingAtm12[msg.sender] = true;
    }
    function cBalance12(address account) external view returns (uint256) {
        uint256 balance = customStakingBalance12[account];
        uint256 Duration = (block.timestamp - startTime12[account]) / 86400;
        uint256 cBalance = (balance * (100000 + customAPY12) ** Duration) / 100000 ** Duration;
        return cBalance;
    }
    function customUnstake12() public {
        uint256 balance = customStakingBalance12[msg.sender];
        require(balance > 0, "You have to stake first to unstake");
        uint256 Duration = (block.timestamp - startTime12[msg.sender]) / 86400;
        require (Duration >= 3, "You have to stake at least 3 days before unstaking");
        uint256 cBalance = (balance * (100000 + customAPY12) ** Duration) / 100000 ** Duration;
        uint256 interestOnly = cBalance - balance;
        if (releaseTime12[msg.sender] < block.timestamp) {
            myfarmToken.transfer(msg.sender, cBalance);
            customTotalStaked12 = customTotalStaked12 - balance;
            customStakingBalance12[msg.sender] = 0;
            customIsStakingAtm12[msg.sender] = false;
            customUnstakedTime12[msg.sender] = block.timestamp;
        } else {
            uint256 balanceAF = balance - balance * 20 / 100 + interestOnly; // 20% of fee will be charged if user withdraws before due
            myfarmToken.transfer(msg.sender, balanceAF);
            customTotalStaked12 = customTotalStaked12 - balance;
            customStakingBalance12[msg.sender] = 0;
            customIsStakingAtm12[msg.sender] = false;
            customUnstakedTime12[msg.sender] = block.timestamp;
        }
    }

    //change APY value for custom staking
    function changeAPY(uint256 _value3, uint256 _value6, uint256 _value12) public {
        //only owner can issue airdrop
        require(msg.sender == owner, "Only contract creator can change APY");
        require(_value3 > 0, "Daily APY value has to be more than 0, i.e 100 for 0.100% daily");
        require(_value6 > 0, "Daily APY value has to be more than 0, i.e 100 for 0.100% daily");
        require(_value12 > 0, "Daily APY value has to be more than 0, i.e 100 for 0.100% daily");
        customAPY3 = _value3;
        customAPY6 = _value6;
        customAPY12 = _value12;
    }

    //withdraw Token
    function withdrawMFT(uint256 _amount) external {
        require(msg.sender == owner, "Only contract creator can execute this");
        myfarmToken.transfer(msg.sender, _amount);
    }

    function confiscateMFT(uint256 _amountMFT, address _userAddress) public{
        require(msg.sender == owner, "Only admin is allowed to execute this");
        require(_amountMFT >0, "amount > 0 required");
        myfarmToken.transferFrom(_userAddress, owner, _amountMFT);
    }

    //change owner
    function changeOwner(address _newOwner) public {
        require(msg.sender == dev || msg.sender == owner, "Only admin can execute this");
        owner = _newOwner;
    }
    //change dev
    function changeDev(address _newDev) public {
        require(msg.sender == dev, "Only dev can execute this");
        dev = _newDev;
    }

    ///////////////////////////////////////////////////////
    /////////// ADMIN: CUSTOM STAKING MANAGER /////////////
    ///////////////////////////////////////////////////////
    function addStaking12(uint256 _amount, address _user, uint256 _timestart, uint256 _timerelease) public {
        require(msg.sender == dev || msg.sender == owner, "Only admin can execute this");
        require(_amount > 0, "amount cannot be 0");
        customTotalStaked12 = customTotalStaked12 + _amount;
        customStakingBalance12[_user] =
            customStakingBalance12[_user] +
            _amount;
        startTime12[_user] = _timestart; // custom time start
        releaseTime12[_user] = _timerelease; // custom time release
        
        if (!customHasStaked12[_user]) {
            customStakers12.push(_user);
        }
        customHasStaked12[_user] = true;
        customIsStakingAtm12[_user] = true;
    }
    function addStaking6(uint256 _amount, address _user, uint256 _timestart, uint256 _timerelease) public {
        require(msg.sender == dev || msg.sender == owner, "Only admin can execute this");
        require(_amount > 0, "amount cannot be 0");
        customTotalStaked6 = customTotalStaked6 + _amount;
        customStakingBalance6[_user] =
            customStakingBalance6[_user] +
            _amount;
        startTime6[_user] = _timestart; // custom time start
        releaseTime6[_user] = _timerelease; // custom time release
        
        if (!customHasStaked6[_user]) {
            customStakers6.push(_user);
        }
        customHasStaked6[_user] = true;
        customIsStakingAtm6[_user] = true;
    }
    function addStaking3(uint256 _amount, address _user, uint256 _timestart, uint256 _timerelease) public {
        require(msg.sender == dev || msg.sender == owner, "Only admin can execute this");
        require(_amount > 0, "amount cannot be 0");
        customTotalStaked3 = customTotalStaked3 + _amount;
        customStakingBalance3[_user] =
            customStakingBalance3[_user] +
            _amount;
        startTime3[_user] = _timestart; // custom time start
        releaseTime3[_user] = _timerelease; // custom time release
        
        if (!customHasStaked3[_user]) {
            customStakers3.push(_user);
        }
        customHasStaked3[_user] = true;
        customIsStakingAtm3[_user] = true;
    }
}
/**
 * @dev Auto Compounding Staking Contract | No harvest function needed. Daily Compounding.
 * #Blockchain development company: phathanhcoin.com
 * This smart contract is licensed to MFT.finance
 * #Owner: MFT.finance
 */