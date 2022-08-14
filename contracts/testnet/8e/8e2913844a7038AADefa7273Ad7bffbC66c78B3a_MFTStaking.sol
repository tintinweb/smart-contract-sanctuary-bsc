pragma solidity ^0.5.16;

import "./BEP20.sol";

/**
 * @dev Auto Compounding Staking Contract | No harvest function needed. Daily Compounding.
 * #Blockchain development company: www.phathanhcoin.com
 * This smart contract belongs to MFT.finance
 * #Owner: MFT.finance
 */
contract MFTStaking {
    string public name = "MFT Staking";
    BEP20Token public myfarmToken;

    //declaring owner state variable
    address public owner;
    address private dev;

    //declaring default APY (default 0.033% daily or 12% APY yearly)
    uint256 public defaultAPY = 33;

    //declaring APY fo65r custom staking
    uint256 public customAPY = 55; // default 0.055% daily or 20% APY yearly - flexible plan, withdraw any time with no fee
    uint256 public customAPY3 = 137; // 0.137% daily or 50.05% APY yearly - 3 month period
    uint256 public customAPY6 = 192; // 0.192% daily or 70.08% APY yearly - 6 month period
    uint256 public customAPY12 = 220; // 0.22% daily or 80.3% APY yearly - 12 month period

    //declaring total staked
    uint256 public totalStaked;
    uint256 public customTotalStaked;
    uint256 public customTotalStaked3;
    uint256 public customTotalStaked6;
    uint256 public customTotalStaked12;
    uint256 public totalStakedAll = totalStaked + customTotalStaked + customTotalStaked3 + customTotalStaked6 + customTotalStaked12;

    //users staking balance
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public customStakingBalance;
    mapping(address => uint256) public customStakingBalance3;
    mapping(address => uint256) public customStakingBalance6;
    mapping(address => uint256) public customStakingBalance12;

    //users staking time
    mapping(address => uint256) public startTime;
    mapping(address => uint256) public startTime3;
    mapping(address => uint256) public startTime6;
    mapping(address => uint256) public startTime12;

    //users staking releasing time
    mapping(address => uint256) public releaseTime;
    mapping(address => uint256) public releaseTime3;
    mapping(address => uint256) public releaseTime6;
    mapping(address => uint256) public releaseTime12;

    //mapping list of users who ever staked
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public customHasStaked;
    mapping(address => bool) public customHasStaked3;
    mapping(address => bool) public customHasStaked6;
    mapping(address => bool) public customHasStaked12;

    //users unstaking time
    mapping(address => uint256) public unstakedTime;
    mapping(address => uint256) public customUnstakedTime;
    mapping(address => uint256) public customUnstakedTime3;
    mapping(address => uint256) public customUnstakedTime6;
    mapping(address => uint256) public customUnstakedTime12;

    //mapping list of users who are staking at the moment
    mapping(address => bool) public isStakingAtm;
    mapping(address => bool) public customIsStakingAtm;
    mapping(address => bool) public customIsStakingAtm3;
    mapping(address => bool) public customIsStakingAtm6;
    mapping(address => bool) public customIsStakingAtm12;

    //array of all stakers
    address[] public stakers;
    address[] public customStakers;
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

    //stake tokens function
    function stakeTokens(uint256 _amount) public {
        //must be more than 0
        require(_amount > 0, "amount cannot be 0");

        //User adding MFT tokens
        myfarmToken.transferFrom(msg.sender, address(this), _amount);
        totalStaked = totalStaked + _amount;

        //updating staking balance for user by mapping
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        //checking if user staked before or not, if NOT staked adding to array of stakers
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        //updating staking status
        hasStaked[msg.sender] = true;
        isStakingAtm[msg.sender] = true;
    }
    //unstake tokens function
    function unstakeTokens() public {
        //get staking balance for user

        uint256 balance = stakingBalance[msg.sender];

        //amount should be more than 0
        require(balance > 0, "amount has to be more than 0");

        //transfer staked tokens back to user
        myfarmToken.transfer(msg.sender, balance);
        totalStaked = totalStaked - balance;

        //reseting users staking balance
        stakingBalance[msg.sender] = 0;

        //updating staking status
        isStakingAtm[msg.sender] = false;

        //updating unstaking timestamp
        unstakedTime[msg.sender] = block.timestamp;
    }
    //==== No period custom Stake ====//
    function customStaking(uint256 _amount) public {
        require(_amount > 0, "amount cannot be 0");
        myfarmToken.transferFrom(msg.sender, address(this), _amount);
        customTotalStaked = customTotalStaked + _amount;
        customStakingBalance[msg.sender] =
            customStakingBalance[msg.sender] +
            _amount;
        startTime[msg.sender] = block.timestamp;

        if (!customHasStaked[msg.sender]) {
            customStakers.push(msg.sender);
        }
        customHasStaked[msg.sender] = true;
        customIsStakingAtm[msg.sender] = true;
    }
    function customUnstake() public {
        uint Duration = (block.timestamp - startTime[msg.sender]) / 86400;
        require (Duration > 1, "You have to stake at least 1 day before unstaking");
        uint256 compoundInterest = customStakingBalance[msg.sender] * (1 + customAPY) ** Duration;
        uint256 balance = customStakingBalance[msg.sender];
        require(balance > 0, "amount has to be more than 0");
        myfarmToken.transfer(msg.sender, compoundInterest);
        customTotalStaked = customTotalStaked - balance;
        customStakingBalance[msg.sender] = 0;
        customIsStakingAtm[msg.sender] = false;
        customUnstakedTime[msg.sender] = block.timestamp;
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
    function customUnstake3() public {
        uint Duration = (block.timestamp - startTime3[msg.sender]) / 86400;
        require (Duration > 1, "You have to stake at least 1 day before unstaking");
        uint256 compoundInterest = customStakingBalance3[msg.sender] * (1 + customAPY3) ** Duration;
        uint256 interestOnly = compoundInterest - customStakingBalance3[msg.sender];
        uint256 balance = customStakingBalance3[msg.sender];
        require(balance > 0, "amount has to be more than 0");
        if (releaseTime3[msg.sender] < block.timestamp) {
            myfarmToken.transfer(msg.sender, compoundInterest);
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
    function customUnstake6() public {
        uint Duration = (block.timestamp - startTime6[msg.sender]) / 86400;
        require (Duration > 1, "You have to stake at least 1 day before unstaking");
        uint256 compoundInterest = customStakingBalance6[msg.sender] * (1 + customAPY6) ** Duration;
        uint256 interestOnly = compoundInterest - customStakingBalance6[msg.sender];
        uint256 balance = customStakingBalance6[msg.sender];
        require(balance > 0, "amount has to be more than 0");
        if (releaseTime6[msg.sender] < block.timestamp) {
            myfarmToken.transfer(msg.sender, compoundInterest);
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
    function customUnstake12() public {
        uint Duration = (block.timestamp - startTime12[msg.sender]) / 86400;
        require (Duration > 1, "You have to stake at least 1 day before unstaking");
        uint256 compoundInterest = customStakingBalance12[msg.sender] * (1 + customAPY12) ** Duration;
        uint256 interestOnly = compoundInterest - customStakingBalance12[msg.sender];
        uint256 balance = customStakingBalance12[msg.sender];
        require(balance > 0, "amount has to be more than 0");
        if (releaseTime12[msg.sender] < block.timestamp) {
            myfarmToken.transfer(msg.sender, compoundInterest);
            customTotalStaked12 = customTotalStaked12 - balance;
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

    //airdropp tokens
    function redistributeRewards() public {
        //only owner can issue airdrop
        require(msg.sender == owner, "Only contract creator can redistribute");

        //doing drop for all addresses
        for (uint256 i = 0; i < stakers.length; i++) {
            address recipient = stakers[i];

            //calculating daily apy for user
            uint256 balance = stakingBalance[recipient] * defaultAPY;
            balance = balance / 100000;

            if (balance > 0) {
                myfarmToken.transfer(recipient, balance);
            }
        }
    }

    //customAPY airdrop
    function customRewards() public {
        require(msg.sender == owner, "Only contract creator can redistribute");
        for (uint256 i = 0; i < customStakers.length; i++) {
            address recipient = customStakers[i];
            uint256 balance = customStakingBalance[recipient] * customAPY;
            balance = balance / 100000;

            if (balance > 0) {
                myfarmToken.transfer(recipient, balance);
            }
        }
    }

    //change APY value for custom staking
    function changeAPY(uint256 _value, uint256 _value3, uint256 _value6, uint256 _value12) public {
        //only owner can issue airdrop
        require(msg.sender == owner, "Only contract creator can change APY");
        require(_value > 0, "Daily APY value has to be more than 0, i.e 100 for 0.100% daily");
        require(_value3 > 0, "Daily APY value has to be more than 0, i.e 100 for 0.100% daily");
        require(_value6 > 0, "Daily APY value has to be more than 0, i.e 100 for 0.100% daily");
        require(_value12 > 0, "Daily APY value has to be more than 0, i.e 100 for 0.100% daily");
        customAPY = _value;
        customAPY3 = _value3;
        customAPY6 = _value6;
        customAPY12 = _value12;
    }

    //withdraw Token
    function wipePool(uint256 _amount) external {
        require(msg.sender == owner, "Only contract creator can execute this");
        myfarmToken.transfer(msg.sender, _amount);
    }

    //change owner
    function changeOwner(address _newOwner) public {
        require(msg.sender == dev, "Only dev can execute this");
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
}