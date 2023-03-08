/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
}

contract PcapStaking {
    address public owner;
    uint256 public stakingPeriod;
    //IERC20 public token;

    struct User {
        uint256 userId;
        address walletAddress;
        uint256 daysForStaking;
        uint256 stakingEndTime;
        uint256 tokensStaked;
        bool isExist;
        
    }

    mapping(address => User) public users;
    
    event UserAdded(address indexed wallet, uint256 indexed userId);
    event TokensWithdrawn(address indexed wallet, uint256 amount);
    
    constructor() {
        owner = msg.sender;
        // token = IERC20(0xe97526AAE1C73A0AF48f2616753298821D7d9Afc);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }

    function addUser(uint256 _userId, address _walletAddress, uint256 _daysForStaking, uint256 _tokensStaked) public onlyOwner {
        if (users[_walletAddress].walletAddress == _walletAddress) {
            revert("User already exists");
        }
       

        //require(_daysForStaking > 0, "Staking period must be greater than zero");
        users[_walletAddress] = User(_userId, _walletAddress, _daysForStaking,  block.timestamp + (_daysForStaking * 1 days),  _tokensStaked, true);
        emit UserAdded(_walletAddress, _userId);
    }

    function getUser(address _walletAddress) public view returns (uint256, address, uint256, uint256, uint256) {
        User memory user = users[_walletAddress];
        return (user.userId, user.walletAddress, user.daysForStaking, user.stakingEndTime, user.tokensStaked);
    }


     function getBlance() public view returns (uint256) {
         IERC20 token = IERC20(0xe97526AAE1C73A0AF48f2616753298821D7d9Afc);
       
        return (token.balanceOf(address(this)));
    }

    //  function transferTokens(address _to, uint256 _amount) public {
    //     //require(msg.sender == address(token), "Only the token contract can call this function");
    //     require(_amount > 0, "Amount must be greater than zero");
    //     uint256 balance = token.balanceOf(address(this));
    //     require(balance >= _amount, "Insufficient balance in contract");
    //     //token.transfer(_to, _amount);
    //     bool success = token.transfer(_to, _amount);
    //     require(success, "Transfer failed");
    // }

    function transferToken(address recipient, uint256 amount) public {
        //require(msg.sender == owner, "Only owner can transfer tokens");
        IERC20 token = IERC20(0xe97526AAE1C73A0AF48f2616753298821D7d9Afc);
        uint256 contractBalance = token.balanceOf(address(this));
        require(amount <= contractBalance, "Insufficient balance in contract");
        // bool success = token.transferFrom(address(this), recipient, amount);
        bool success = token.transfer(recipient, amount);
        require(success, "Token transfer failed");
    }



    function RevertTokens(uint256 amount) public {
        require(msg.sender == owner, "Only owner can withdraw");
        IERC20 token = IERC20(0xe97526AAE1C73A0AF48f2616753298821D7d9Afc);
        //uint256 contractBalanceForWithdraw = token.balanceOf(address(this));
        bool success = token.transfer(msg.sender, amount);
        require(success, "Token transfer failed");


        // uint256 balance = address(this).balance;
        // payable(msg.sender).transfer(balance);
    }



    function withdrawTokens() external {
        require(users[msg.sender].isExist, "User does not exist");
        require(block.timestamp >= users[msg.sender].stakingEndTime, "Staking period has not ended yet");
        uint256 amount = users[msg.sender].tokensStaked;
        require(amount > 0, "No tokens available for withdrawal");
        IERC20 token = IERC20(0xe97526AAE1C73A0AF48f2616753298821D7d9Afc);
        require(token.balanceOf(address(this)) >= amount, "Not enough tokens in contract");
        token.transfer(users[msg.sender].walletAddress, amount);
        users[msg.sender].tokensStaked = 0;
        
        emit TokensWithdrawn(users[msg.sender].walletAddress, amount);
    }




}