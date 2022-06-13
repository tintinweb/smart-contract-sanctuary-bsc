/**
 *Submitted for verification at BscScan.com on 2022-06-13
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

contract ATCCSwaping {

    IERC20 public swapToken;

    address public primaryAdmin;

    uint private _totalSupply;

    mapping(address => uint) public _totalswapbalances;

    uint256 public totalNumberofSwapper;
	uint256 public totalSwapedATCC;

    struct User {
        uint256 totalSwapped;
        uint lastSwappedUpdateTime;
	}

    mapping (address => User) public users;

    constructor() {
        primaryAdmin = 0x737cB465da81c4236bdb25488Be92860773cd844;
        swapToken = IERC20(0x18D2F7E95e6Ff50336935B797338393FaC829960);
    }

    //Swap ATCC
    function _SwapATCC(uint _amount) external {
        User storage user = users[msg.sender];
        //Manage Swaper & Swapped ATCC
        if(_totalswapbalances[msg.sender]==0){
            totalNumberofSwapper += 1;
        }
        totalSwapedATCC +=_amount;
        //Update Total Swapped & Swap of User
        _totalSupply += _amount;
        _totalswapbalances[msg.sender] += _amount;
        //Update Swap Section
        user.totalSwapped +=_amount;
        user.lastSwappedUpdateTime =block.timestamp;
        swapToken.transferFrom(msg.sender, address(this), _amount);
    }

    //Collect Swapped ATCC
    function _CollectSwappedATCC(uint _amount) external {
        require(primaryAdmin==msg.sender, 'Admin what?');
        _totalSupply -= _amount;
        swapToken.transfer(primaryAdmin, _amount);
    }

    //Change Owner For Swapping Smart Contract
    function _ChnageOwnership(address newOwner) external {
     require(newOwner != address(0), "Ownable: new owner is the zero address");
     require(primaryAdmin==msg.sender, 'Admin what?');
     primaryAdmin = newOwner;
   }

    //View Get Current Time Stamp
    function view_GetCurrentTimeStamp() public view returns(uint _timestamp){
       return (block.timestamp);
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