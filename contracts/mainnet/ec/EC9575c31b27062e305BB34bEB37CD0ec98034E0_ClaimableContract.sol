/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

/**
__/\\\\\\\\\\\\\\\__/\\\______________/\\\_______/\\\\\__________/\\\\\\\\\\\\__/\\\\\\\\\\\\\\\____________/\\\\\\\\\\\__/\\\\\_____/\\\__/\\\________/\\\_        
 _\///////\\\/////__\/\\\_____________\/\\\_____/\\\///\\\______/\\\//////////__\/\\\///////////____________\/////\\\///__\/\\\\\\___\/\\\_\/\\\_______\/\\\_       
  _______\/\\\_______\/\\\_____________\/\\\___/\\\/__\///\\\___/\\\_____________\/\\\___________________________\/\\\_____\/\\\/\\\__\/\\\_\/\\\_______\/\\\_      
   _______\/\\\_______\//\\\____/\\\____/\\\___/\\\______\//\\\_\/\\\____/\\\\\\\_\/\\\\\\\\\\\___________________\/\\\_____\/\\\//\\\_\/\\\_\/\\\_______\/\\\_     
    _______\/\\\________\//\\\__/\\\\\__/\\\___\/\\\_______\/\\\_\/\\\___\/////\\\_\/\\\///////____________________\/\\\_____\/\\\\//\\\\/\\\_\/\\\_______\/\\\_    
     _______\/\\\_________\//\\\/\\\/\\\/\\\____\//\\\______/\\\__\/\\\_______\/\\\_\/\\\___________________________\/\\\_____\/\\\_\//\\\/\\\_\/\\\_______\/\\\_   
      _______\/\\\__________\//\\\\\\//\\\\\______\///\\\__/\\\____\/\\\_______\/\\\_\/\\\___________________________\/\\\_____\/\\\__\//\\\\\\_\//\\\______/\\\__  
       _______\/\\\___________\//\\\__\//\\\_________\///\\\\\/_____\//\\\\\\\\\\\\/__\/\\\\\\\\\\\\\\\____________/\\\\\\\\\\\_\/\\\___\//\\\\\__\///\\\\\\\\\/___ 
        _______\///_____________\///____\///____________\/////________\////////////____\///////////////____________\///////////__\///_____\/////_____\/////////_____
                            Best of Elon Musk ( TWITTER + DOGE ) Meme token
                                Website: https://twogeinu.io
                                Telegram: https://t.me/TwogeInu
                                Twitter: https://twitter.com/twogeinu

*/


//SPDX-License-Identifier: MIT Licensed
pragma solidity ^0.8.10;

interface IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ClaimableContract {
    IBEP20 public TOKEN;

    address payable public owner;

    uint256 public claimTime;
    uint256 public totalTokenClaimed;
    uint256 public claimableAmount;
    uint256 public minAmount;

    bool public isclaimactive;

    struct user {
        uint256 claimedTime;
        uint256 token_balance;
        uint256 claimCount;
    }

    mapping(address => user) public users;

    modifier onlyOwner() {
        require(msg.sender == owner, "PRESALE: Not an owner");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
        TOKEN = IBEP20(0xbA2aE424d960c26247Dd6c32edC70B295c744C43);
        claimTime = 1 days;
        claimableAmount = 10 * 10 ** TOKEN.decimals();
        minAmount = 20_000_000_000e5;
        isclaimactive = true;
    }

    receive() external payable {}

    // to claim token after start time => for web3 use
    function claimToken() public {
        require(isclaimactive, "Claim not active");
        require(
            block.timestamp >= users[msg.sender].claimedTime + claimTime,
            "Already claimed"
        );
        require(TOKEN.balanceOf(msg.sender) >= minAmount,"Amount less than min amount");
        TOKEN.transferFrom(owner, msg.sender, claimableAmount);
        totalTokenClaimed += claimableAmount;
        users[msg.sender].token_balance += claimableAmount;
        users[msg.sender].claimedTime = block.timestamp;
        users[msg.sender].claimCount += 1;
    }

    //to enable and disable claim
    function enableOrDisableClaim() public onlyOwner {
        if(isclaimactive == false)
        isclaimactive = true;
        else isclaimactive = false;
    }

    // to change  time
    function changeClaimTime(uint256 _time) external onlyOwner {
        claimTime = _time;
    }

    // to change  claim Amount
    function changeRewardAmount(uint256 _amount) external onlyOwner {
        claimableAmount = _amount;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // change tokens
    function changeToken(address _token) external onlyOwner {
        TOKEN = IBEP20(_token);
    }

    // change amount
    function changeMinAmount(uint256 _amount) external onlyOwner {
        minAmount = _amount;
    }

    // to draw funds for liquidity
    function transferFundsBNB(uint256 _value) external onlyOwner {
        owner.transfer(_value);
    }

    // to draw out tokens
    function transferStuckTokens(IBEP20 token, uint256 _value)
        external
        onlyOwner
    {
        token.transfer(msg.sender, _value);
    }

    // to get contract token balance
    function getContractTokenApproval() external view returns (uint256) {
        return TOKEN.allowance(owner, address(this));
    }
}