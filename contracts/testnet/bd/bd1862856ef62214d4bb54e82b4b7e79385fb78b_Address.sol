/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.16;

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

struct User {
    uint256 totalDeposits;
    uint256 lastWith;
    Depo [] depoList;
}

struct Depo {
    uint256 key;
    uint256 depoTime;
    uint256 amount;
}

contract BUSDMiner {
    uint256 constant launch = 0; // launch date
    
    uint256 constant divsYield = 33; // daily yield
    uint256 constant depositFee = 33;
    uint256 constant withdrawFee = 10;

    mapping (address => mapping(uint256 => Depo)) public depositMap;
    mapping (address => User) public UsersKey;

    address public owner;

    IERC20 public BUSD;

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    constructor() {
        owner = msg.sender;
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    /*
     * Still needs referral bonus functionality
     */
    function depositTokens(uint256 _amount) external {
        require(block.timestamp >= launch, "App did not launch yet.");
        uint256 fee = _amount.div(depositFee);
        uint256 adjustedAmount = _amount.sub(fee);
   
        User storage user = UsersKey[msg.sender];
        user.depoList.push(Depo({
            key: user.depoList.length,
            depoTime: block.timestamp,
            amount: adjustedAmount
        }));
        user.totalDeposits += adjustedAmount;
        if (user.lastWith == 0){
            user.lastWith = block.timestamp;
        }

        BUSD.safeTransferFrom(msg.sender, address(this), _amount);
        BUSD.safeTransfer(owner, fee);
    }

    function withdrawDeposits() external {
        User storage user = UsersKey[msg.sender];
        uint256 deposits = user.totalDeposits;
        uint256 fee = deposits / withdrawFee;
        uint256 adjustedDeposits = deposits - fee;
        BUSD.safeTransfer(msg.sender, adjustedDeposits);
        for (uint256 i = 0; i < user.depoList.length; i++) {
            user.depoList.pop();
        }
        user.totalDeposits;
    }

    function calculateEarnings(User storage _user) private view returns (uint256) {
        uint256 earnings = 0;
        uint256 currTime = block.timestamp;

        for (uint256 i = 0; i < _user.depoList.length; i++) {
            uint256 elapsedTime = currTime.sub(_user.depoList[i].depoTime);
            uint256 amount = _user.depoList[i].amount;
            uint256 dailyReturn = amount.div(divsYield);
            uint256 currReturn = dailyReturn.mul(elapsedTime.div(1 days));
            earnings += currReturn;
        }
        return earnings;
    }

    /*
     * Still need to add referral bonus functionality
     */

    function withdrawEarnings() external {
        User storage user = UsersKey[msg.sender];
        uint256 earnings = calculateEarnings(user);
        uint256 fee = earnings.div(withdrawFee);
        uint256 adjustedEarnings = earnings - fee;
        for (uint256 i = 0; i < user.depoList.length; i++) {
            user.depoList[i].depoTime = block.timestamp;
        }
        BUSD.safeTransfer(msg.sender, adjustedEarnings);
    }
    
    /*
     * Still need to add referral bonus functionality
     */
    function compoundEarnings() external {
        User storage user = UsersKey[msg.sender];
        uint256 earnings = calculateEarnings(user);
        uint256 adjustedEarnings = earnings;
        for (uint256 i = 0; i < user.depoList.length; i++) {
            user.depoList[i].depoTime = block.timestamp;
        }
        user.depoList.push(Depo({
            key: user.depoList.length,
            depoTime: block.timestamp,
            amount: adjustedEarnings
        }));
        user.totalDeposits += adjustedEarnings;
    }

    function changeOwner(address newOwner) external {
        require(msg.sender == owner, "Permission denied: Only contract owner accessible.");
        owner = newOwner;
    }
}