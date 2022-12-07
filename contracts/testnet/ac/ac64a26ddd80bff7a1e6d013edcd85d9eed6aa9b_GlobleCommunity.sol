/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface BEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract GlobleCommunity {
    BEP20 public usdt3 = BEP20(0xDc6cc6d847DF088C3eEDA72404864B59c0cD53B2);// Tether3.0  0x7cD4d42b1779ec004080Ef1375784eC3CE6E20d5
    address public aggregator;
    
    struct UserInfo {
        address referrer;
        bool isReg;
        bool isActive;
    }

    mapping(address=>UserInfo) public userInfo;
    event Register(address user, address referrer);
    event Deposit(address user, uint256 amount);

    modifier onlyAggregator(){
        require(msg.sender == aggregator,"You are not aggregator.");
        _;
    }

    modifier security {
        uint size;
        address sandbox = msg.sender;
        assembly { size := extcodesize(sandbox) }
        require(size == 0, "Smart contract detected!");
        _;
    }

    constructor() public {
        aggregator = msg.sender;
        userInfo[msg.sender].isReg = true;
        userInfo[msg.sender].isActive = true;
    }

    function contractInfo() public view returns(uint256 balance){
        return (usdt3.balanceOf(address(this)));
    }

    function register(address _referrer) public security{
        require(userInfo[_referrer].isActive==true,"Referral is not active.");
        require(_referrer!=msg.sender,"You cannot refer yourself!");
        userInfo[msg.sender].referrer = _referrer;
        userInfo[msg.sender].isReg = true;
        emit Register(msg.sender,_referrer);
    }

    function deposit(uint256 _usdt3) public security{
        require(userInfo[msg.sender].isReg==true,"Please register first!.");
        require(_usdt3>=25e6,"Please invest at least 25 USDT3.0!");
        usdt3.transferFrom(msg.sender,address(this),_usdt3);

        if(userInfo[msg.sender].isActive==false){
            userInfo[msg.sender].isActive = true;
        }
        emit Deposit(msg.sender, _usdt3);

    }

    function distributeStake(address _staker, uint256 _amount) external onlyAggregator security{
        usdt3.transfer(_staker,_amount);
    }

}