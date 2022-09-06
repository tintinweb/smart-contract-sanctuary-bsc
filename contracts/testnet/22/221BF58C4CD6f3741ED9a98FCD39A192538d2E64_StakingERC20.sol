/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StakingERC20 {
    using Counters for Counters.Counter;
    string public name = "Staking ERC20";
    address public owner;
    IERC20 public rewardToken;
    IERC20 public Token;
    uint256 amount;
    address[] public stakers;
    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;
    mapping(address => mapping (IERC20 => bool))  istokenstaking;
    mapping(address => uint256) public _balances;
    uint256 private releasetime ;
    Counters.Counter private _claimdropNumber;
    Counters.Counter private _unlockedDropsNumber;
    struct Stake {
        uint256 dropId;
        IERC20 reward_token;
        IERC20 _token;
        address claimer;
        uint256 amount;
        uint256 releasetime;
    }
    Stake[] allstake;
    constructor(IERC20 _rewardToken) {
        rewardToken = _rewardToken;
        rewardToken.transferFrom(msg.sender,address(this), 1000000000000000000000000000);
        owner = msg.sender;
    }

    function stakeTokens(IERC20 _token,uint256 _amount) public {
        require(_amount > 0, "amount can not be zero"); //if amount is zero
        require (istokenstaking[msg.sender][_token] != true,"user already staked this token ");
        Token = _token;
        Token.transferFrom(msg.sender, address(this), _amount); //transfer token
        stakingBalance[msg.sender] += _amount; //update the staking balanace
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender); // add user to staker array
        }
        isStaking[msg.sender] = true; // update staking status for the user
        hasStaked[msg.sender] = true;
        amount = _amount;
        releasetime = block.timestamp ;
        istokenstaking[msg.sender][_token] = true;
        uint256 currentdropId = _unlockedDropsNumber.current();
        allstake.push(
            Stake(
                currentdropId,
                rewardToken,
                _token,
                msg.sender,
                amount,
                releasetime
            )
        );
        _unlockedDropsNumber.increment();
    }
    function unstakeToken() public {
        uint256 balance = stakingBalance[msg.sender]; //fetch balance of staker
        require (stakingBalance[msg.sender] > 0 ,"staking balance should be greater than zero");
        require(balance > 0, "staking balance is zero"); // check if balance is zero
        require(block.timestamp >= releasetime+2592000,"you can unstake after 30 days" );        if ( block.timestamp ==  releasetime + 7776000){
           Token.transferFrom(address(this),msg.sender, balance); //transfer back token to use
           rewardToken.transferFrom(address(this),(msg.sender), (20*amount)/100 );
           _balances[msg.sender] = (20*amount)/100;
        }else{
            if ( block.timestamp ==  releasetime + 5184000){
           Token.transferFrom(address(this),msg.sender, balance); //transfer back token to use
           rewardToken.transferFrom(address(this),(msg.sender), (15*amount)/100 );
           _balances[msg.sender] = (15*amount)/100;
        }else{
            if ( block.timestamp ==  releasetime + 2592000){
           Token.transferFrom(address(this),msg.sender, balance); //transfer back token to use
           rewardToken.transferFrom(address(this),(msg.sender), (10*amount)/100 );
           _balances[msg.sender] = (10*amount)/100;
        }
        stakingBalance[msg.sender] = 0; // set staking balance to zero
        isStaking[msg.sender] = false; // update the staking status
        istokenstaking[msg.sender][rewardToken] = false;
    }
    }
    }
    function issueDummy() public {
        require(msg.sender == owner, "caller must be the owner"); // check if owner is access
        for (uint256 i = 0; i < stakers.length; i++) {
            address recipient = stakers[i]; // recipient
            uint256 balance = stakingBalance[recipient]; // balance for recipient
            if (balance > 0) {
                rewardToken.transfer(recipient, balance); // trnasfer dummy token to recipient
            }
        }
    }
}