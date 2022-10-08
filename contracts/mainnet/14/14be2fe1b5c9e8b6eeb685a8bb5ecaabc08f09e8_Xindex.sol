/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

// SPDX-License-Identifier: MIT
// Xindex.space Contract
pragma solidity 0.8.16;



contract Xindex {
    using SafeMath for uint256;
    uint public depositsCount = 0;
    uint256 public commission = 5;
    uint public PERCENT_DIVIDER = 100;
    address public dev = 0x3a215816512F9C9BC492057437bE615CDa0c4aB4;
    address public mar = 0x3E8d869ed4393579c5f903BE7a52710D47Ff4f8d;
    address public owner;
    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;
    using SafeERC20 for IERC20;
    IERC20 public BUSD;
    

    address[] public stakers;
    mapping(address => uint) public Balance;
    mapping(address => uint) public TotalInvest;
    mapping(address => uint) public TotalInvestCount;
    mapping(address => uint) public TotalWithdrawal;
    mapping(address => uint) public TotalCommission;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;
    mapping(address => address) public Upline;
    mapping(address => uint) public dividends;
    mapping(address => uint40) public last_payout;
    mapping(uint => Deposit) public deposits;

    struct Deposit {
    uint id;   
    address owner;
    uint8 profit;
    uint8 life_days;
    uint256 amount;
    uint40 time;
    }

    constructor() {
        owner = msg.sender;
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
        

    }

    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            last_payout[_addr] = uint40(block.timestamp);
            Balance[_addr] += payout;
        }
    }

    function deposit(uint256 _amount, address _upline) public {
        require(_upline != msg.sender, "You cannot refer your address!");

        uint256 dev_commisison = _amount * 5 / PERCENT_DIVIDER;
        uint256 mar_commisison = _amount * 1 / PERCENT_DIVIDER;
        uint256 original_amount = _amount * 94 / PERCENT_DIVIDER;
        
        BUSD.safeTransferFrom(msg.sender, address(this), original_amount);
        BUSD.safeTransferFrom(msg.sender, dev, dev_commisison);
        BUSD.safeTransferFrom(msg.sender, mar, mar_commisison);
        

        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }


        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;

        TotalInvest[msg.sender] = TotalInvest[msg.sender] + original_amount; 


        uint256 bonus = original_amount * commission / PERCENT_DIVIDER;
        TotalCommission[_upline] = TotalCommission[_upline] + bonus;
        Balance[_upline] = Balance[_upline] + bonus;
        match_bonus += bonus;
  
        TotalInvestCount[msg.sender] ++;
        invested += original_amount; 

        depositsCount ++;

        deposits[depositsCount] = Deposit(depositsCount, msg.sender, 180, 30, original_amount, uint40(block.timestamp));

    }
    
    function withdraw() external {
        
        _payout(msg.sender);

        uint balance = Balance[msg.sender]; 
        
        BUSD.safeTransfer(msg.sender, balance); 

        Balance[msg.sender] = 0;
        TotalWithdrawal[msg.sender] = TotalWithdrawal[msg.sender] + balance;

        withdrawn += balance;
        
        isStaking[msg.sender] = false; 
    } 

    
    function payoutOf(address _addr) view external returns(uint256 value) {
        

        for(uint256 i=0;i<depositsCount;i++) {
            if(deposits[i].owner == _addr){


            uint40 time_end = deposits[i].time + 2592000; // deposit timestamp + 30 days in sec
            uint40 from = last_payout[_addr] > deposits[i].time ? last_payout[_addr] : deposits[i].time;
            uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);

            if(from < to) {
                value += deposits[i].amount * (to - from) * deposits[i].profit / deposits[i].life_days / 8640000;
            }
        }
        }
        return value;
    }



    function userInfo(address _addr) external {

        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            last_payout[msg.sender] = uint40(block.timestamp);
            Balance[msg.sender] += payout;
        }



    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size; assembly {
            size := extcodesize(account)
        } return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target,bytes memory data,uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target,bytes memory data,uint256 value,string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target,bytes memory data,string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(bool success,bytes memory returndata,string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
library SafeERC20 {
    using Address for address;
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token,address spender,uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token,address spender,uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {   
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}