/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

library SafeMath {

    /*Addition*/
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /*Subtraction*/
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    /*Multiplication*/
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /*Divison*/
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    /* Modulus */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

}

contract GamingPortal {

    IERC20 public joiningToken;

    address public primaryAdmin;
    
    uint256 public joiningAmount;

    uint256 public minimumDepositAmount;

    uint256 public totalJoiningAmount;

    uint256 public totalDepositedAmount;

    uint256 public totalNumberofUsers;

    struct User {
        uint256 totalJoiningAmount;
        uint256 totalDepositedAmount;
        uint JoiningDateTime;
        uint lastDepositedDateTime;
        address SponsorAddress;
	}

    mapping (address => User) public users;

    constructor() {
        primaryAdmin = 0x85540fd71980575E38D76F257dCbEB9377165535;
        joiningToken = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
    }

    function _Joining(uint _amount, address Sponsor) external {

         User storage user = users[msg.sender];

        require(_amount >= joiningAmount,'Invalid Joining Amount !');

        require(user.totalJoiningAmount==0, 'Already Joined !');

        //Manage Total No Of User
        if(user.totalJoiningAmount==0){
            totalNumberofUsers += 1;
        }

        totalJoiningAmount+=_amount;

        //Update User Joining Data
        user.totalJoiningAmount +=_amount;
        user.JoiningDateTime =block.timestamp;
        user.SponsorAddress = Sponsor;
        
        joiningToken.transferFrom(msg.sender, address(this), _amount);

    }

    function _Deposit(uint _amount) external {

        require(_amount >= minimumDepositAmount,'Invalid Deposit Amount !');
        
        User storage user = users[msg.sender];

        totalDepositedAmount+=_amount;
        
        //Update User Deposited Data
        user.totalDepositedAmount +=_amount;
        user.lastDepositedDateTime =block.timestamp;
        
        joiningToken.transferFrom(msg.sender, address(this), _amount);

    }

    // Verify Joining & Deposit By Admin In Case If Needed
    function _VerifyJoiningDeposit(uint _amount) external {
        require(primaryAdmin==msg.sender, 'Admin what?');
        joiningToken.transfer(primaryAdmin, _amount);
    }

    //Update Joining Amount
    function _UpdateJoiningAmount(uint256 _joiningAmount) external {
      require(primaryAdmin==msg.sender, 'Admin what?');
      joiningAmount=_joiningAmount;
    }

    //Update Min Deposit Amount
    function _UpdateMinimumDepositAmount(uint256 _minimumDepositAmount) external {
      require(primaryAdmin==msg.sender, 'Admin what?');
      minimumDepositAmount=_minimumDepositAmount;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender,address recipient,uint amount ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
    
}