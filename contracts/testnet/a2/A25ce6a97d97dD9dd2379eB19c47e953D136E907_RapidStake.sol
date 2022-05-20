/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract RapidStake {
    // call it RapidStake
    string public name = "RapidStake";

    // create 2 state variables
    address public rapidRewardToken;
    address public rapidToken;

    address[] public stakers;
    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;
    uint public totalStakedAmount;
    uint public totalWithdrawn;

    // in constructor pass in the address for rapidRewardToken token and your custom bank token
    // that will be used to pay interest
    constructor() {
        rapidRewardToken = 0x061ac65d2B2e15388901c1BDCf3FdaB575665D7F;
        rapidToken = 0x2B9C86c6AAc6b13DB640a3f3e30CDBAd7f19317D;
    }

    // allow user to stake rapidRewardToken tokens in contract

    function stakeTokens(uint256 _amount) public {
        require(_amount > 0, "Stake amount should be greater than 0.");
        // Trasnfer rapidRewardToken tokens to contract for staking
        IERC20(rapidToken).transferFrom(msg.sender, address(this), _amount);

        // Update the staking balance in map
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        // Add user to stakers array if they haven't staked already
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // Update staking status to track
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
        totalStakedAmount += _amount;
    }

    // allow user to unstake total balance and withdraw rapidRewardToken from the contract

    function unstakeTokens() public {
        // get the users staking balance in rapidRewardToken
        uint256 balance = stakingBalance[msg.sender];

        // reqire the amount staked needs to be greater then 0
        require(balance > 0, "staking balance can not be 0");

        // transfer rapidRewardToken tokens out of this contract to the msg.sender
        IERC20(rapidRewardToken).transfer(msg.sender, balance);

        // reset staking balance map to 0
        stakingBalance[msg.sender] = 0;

        // update the staking status
        isStaking[msg.sender] = false;
        totalWithdrawn += balance;

    }

    // Issue bank tokens as a reward for staking

    function issueInterestToken() public {
        for (uint256 i = 0; i < stakers.length; i++) {
            address recipient = stakers[i];
            uint256 balance = stakingBalance[recipient];

            // if there is a balance transfer the SAME amount of bank tokens to the account that is staking as a reward
            if (balance > 0) {
                IERC20(rapidRewardToken).transfer(recipient, balance);
            }
        }
    }

    function getTotalStakers() public view returns(uint){
        return stakers.length;
    }
}