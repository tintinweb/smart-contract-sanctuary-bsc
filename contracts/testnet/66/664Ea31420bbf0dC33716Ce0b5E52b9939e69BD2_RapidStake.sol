/**
 *Submitted for verification at BscScan.com on 2022-05-15
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
    address public rusd;
    address public rapidToken;

    address[] public stakers;
    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    // in constructor pass in the address for rusd token and your custom bank token
    // that will be used to pay interest
    constructor() public {
        rusd = 0x54AE4ce7806d031B0efa32D6f3570A6B2E1cCa19;
        rapidToken = 0x5E0bE16D0604c8011B1950698fb09a402bc8A853;
    }

    // allow user to stake rusd tokens in contract

    function stakeTokens(uint256 _amount) public {
        // Trasnfer rusd tokens to contract for staking
        IERC20(rusd).transferFrom(msg.sender, address(this), _amount);

        // Update the staking balance in map
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        // Add user to stakers array if they haven't staked already
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // Update staking status to track
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    // allow user to unstake total balance and withdraw rusd from the contract

    function unstakeTokens() public {
        // get the users staking balance in rusd
        uint256 balance = stakingBalance[msg.sender];

        // reqire the amount staked needs to be greater then 0
        require(balance > 0, "staking balance can not be 0");

        // transfer rusd tokens out of this contract to the msg.sender
        IERC20(rusd).transfer(msg.sender, balance);

        // reset staking balance map to 0
        stakingBalance[msg.sender] = 0;

        // update the staking status
        isStaking[msg.sender] = false;
    }

    // Issue bank tokens as a reward for staking

    function issueInterestToken() public {
        for (uint256 i = 0; i < stakers.length; i++) {
            address recipient = stakers[i];
            uint256 balance = stakingBalance[recipient];

            // if there is a balance transfer the SAME amount of bank tokens to the account that is staking as a reward

            if (balance > 0) {
                IERC20(rapidToken).transfer(recipient, balance);
            }
        }
    }
}