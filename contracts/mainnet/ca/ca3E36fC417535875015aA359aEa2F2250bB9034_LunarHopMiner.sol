/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

/**
*
*    ___       ___  ___  ________   ________  ________          ___  ___  ________  ________        _____ ______   ___  ________   _______   ________     
*   |\  \     |\  \|\  \|\   ___  \|\   __  \|\   __  \        |\  \|\  \|\   __  \|\   __  \      |\   _ \  _   \|\  \|\   ___  \|\  ___ \ |\   __  \    
*   \ \  \    \ \  \\\  \ \  \\ \  \ \  \|\  \ \  \|\  \       \ \  \\\  \ \  \|\  \ \  \|\  \     \ \  \\\__\ \  \ \  \ \  \\ \  \ \   __/|\ \  \|\  \   
*    \ \  \    \ \  \\\  \ \  \\ \  \ \   __  \ \   _  _\       \ \   __  \ \  \\\  \ \   ____\     \ \  \\|__| \  \ \  \ \  \\ \  \ \  \_|/_\ \   _  _\  
*     \ \  \____\ \  \\\  \ \  \\ \  \ \  \ \  \ \  \\  \|       \ \  \ \  \ \  \\\  \ \  \___|      \ \  \    \ \  \ \  \ \  \\ \  \ \  \_|\ \ \  \\  \| 
*      \ \_______\ \_______\ \__\\ \__\ \__\ \__\ \__\\ _\        \ \__\ \__\ \_______\ \__\          \ \__\    \ \__\ \__\ \__\\ \__\ \_______\ \__\\ _\ 
*       \|_______|\|_______|\|__| \|__|\|__|\|__|\|__|\|__|        \|__|\|__|\|_______|\|__|           \|__|     \|__|\|__|\|__| \|__|\|_______|\|__|\|__|
*                                                                                                                                                      
*/

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
//libraries
struct User {
    uint256 totalDeposit;
    uint256 totalAccured;
    address referrer;
    uint256 refBonus;
    uint256 totalWithRefBonus;
    Depo [] depoList;
}

struct Depo {
    uint256 level;
    uint256 totalEarned;
    uint256 lastWithdraw;
    bool    done;
}

struct Main {
    uint256 ovrTotalDeps;
    uint256 ovrTotalWiths;
    uint256 users;
    uint256 compounds;
}

struct LunarHop {
    string name;
    uint256 lifeSpan; // updated to be in seconds
    uint256 dailyProfit;
    uint256 price;
    uint256 totalIncome;
}

contract LunarHopMiner {
    using SafeMath for uint256;
    uint256 constant launch = 1674349200;  // 09:00 AM, 22th Jan 2023, UTC + 8(Chain Time Zone)
  	uint256 constant hardDays = 86400;
    uint256 constant PERCENTS_DIVIDER = 1000;
    uint256 refPercentage = 100;
    uint256 DEPOSIT_FEE = 100;
    uint256 WITHDRAW_FEE = 50;
    // mapping (address => mapping(uint256 => Depo)) public DeposMap;
    mapping (address => User) internal Users;
    mapping (uint256 => LunarHop) public LunarHopGroup;
    mapping (uint256 => Main) public MainKey;

    using SafeERC20 for IERC20;
    IERC20 public BUSD;
    address public CEO;
    address public dev;

    constructor() {
            CEO = address(0x79D6012c0193BBE31dd2a80c4352BC5af69359D7);
            dev = address(0x7419189d0f5B11A1303978077Ce6C8096d899dAd);
            //LunarHop NFT Info:          name          life span       daily roi              price           totalIncome
            LunarHopGroup[0] = LunarHop('Common',       30 days,       2 * 10 ** 18,       50 * 10 ** 18,      60 * 10 ** 18);
            LunarHopGroup[1] = LunarHop('Uncommon',     30 days,      42 * 10 ** 17,      100 * 10 ** 18,     126 * 10 ** 18);
            LunarHopGroup[2] = LunarHop('Rare',         45 days,      22 * 10 ** 18,      500 * 10 ** 18,     990 * 10 ** 18);
            LunarHopGroup[3] = LunarHop('Super Rare',   45 days,      45 * 10 ** 18,     1000 * 10 ** 18,    2025 * 10 ** 18);
            LunarHopGroup[4] = LunarHop('Legendary',    60 days,     235 * 10 ** 18,     5000 * 10 ** 18,   14100 * 10 ** 18);
            LunarHopGroup[5] = LunarHop('Mytical',      60 days,     480 * 10 ** 18,    10000 * 10 ** 18,   28800 * 10 ** 18);
            
            BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
    }

    function fundContract(uint256 _amount) external {
        BUSD.safeTransferFrom(msg.sender, address(this), _amount);
    }

    function buyLunarHop(uint256 _level, address _referrer) external {
        require(block.timestamp >= launch, "App did not launch yet.");
        require(_level >= 0 && _level <= 5 , "You should select level between 0 and 6.");

        uint256 amount = LunarHopGroup[_level].price;
        BUSD.safeTransferFrom(msg.sender, address(this), amount);

        User storage user = Users[msg.sender];
        Main storage main = MainKey[1];

        uint256 depositFee = amount.mul(DEPOSIT_FEE).div(PERCENTS_DIVIDER);
        BUSD.safeTransfer(CEO, depositFee / 2);
        BUSD.safeTransfer(dev, depositFee / 2);
        
        if (user.referrer == address(0)) {
			if (Users[_referrer].totalDeposit > 0 && _referrer != msg.sender) {
				user.referrer = _referrer;
			}
		}

        uint256 refAmount = amount * refPercentage / PERCENTS_DIVIDER;
        if (user.referrer != address(0)) {
			address upline = user.referrer;
            Users[upline].refBonus = Users[upline].refBonus + refAmount;
		} else {
            Users[dev].refBonus = Users[dev].refBonus + refAmount;
		}

        if (user.totalDeposit == 0) {
            main.users += 1;
        }
        user.totalDeposit += amount;

        user.depoList.push(Depo({
            level: _level,
            totalEarned: 0,
            lastWithdraw: block.timestamp,
            done: false
        }));
    }

    function claimRewards(uint256 _no) external {
        require(block.timestamp >= launch, "App did not launch yet.");

        User storage user = Users[msg.sender];
        
        require(user.depoList.length > _no, "Invalid param");
        require(user.depoList[_no].done == false, "Already claimed!");
        require(user.depoList[_no].lastWithdraw + 1 days < block.timestamp, "Not claimable, yet");
        
        uint256 _level = user.depoList[_no].level;
        uint256 _totalIncome = LunarHopGroup[_level].totalIncome;
        uint256 dailyROI = LunarHopGroup[_level].dailyProfit;
        uint256 rewards = (block.timestamp - user.depoList[_no].lastWithdraw) * dailyROI / 1 days;
        rewards = min(rewards, _totalIncome - user.depoList[_no].totalEarned);
        if (rewards > getBalance()) {
            rewards = getBalance();
        }

        user.totalAccured += rewards;
        user.depoList[_no].totalEarned += rewards;
        user.depoList[_no].lastWithdraw = block.timestamp;
        if (user.depoList[_no].totalEarned ==  _totalIncome) {
            user.depoList[_no].done = true;
        }

        uint256 withdrawFee = rewards.mul(WITHDRAW_FEE).div(PERCENTS_DIVIDER);
        rewards = rewards - withdrawFee;

        BUSD.safeTransfer(dev, withdrawFee/2);
        BUSD.safeTransfer(CEO, withdrawFee/2);
        BUSD.safeTransfer(msg.sender, rewards);
    }
    
    function buyAgain(uint256 _no) external {
        require(block.timestamp >= launch, "App did not launch yet.");

        User storage user = Users[msg.sender];
        
        require(user.depoList.length > _no, "Invalid param");
        require(user.depoList[_no].done == false, "Already claimed!");
        require(user.depoList[_no].lastWithdraw + 1 days < block.timestamp, "Not claimable, yet");
        
        uint256 _level = user.depoList[_no].level;
        uint256 _totalIncome = LunarHopGroup[_level].totalIncome;
        uint256 dailyROI = LunarHopGroup[_level].dailyProfit;
        uint256 rewards = (block.timestamp - user.depoList[_no].lastWithdraw) * dailyROI / 1 days;
        rewards = min(rewards, _totalIncome - user.depoList[_no].totalEarned);

        require(rewards >= LunarHopGroup[_level].price, "Reward is not enough to buy new NFT, yet!");
        user.totalAccured += rewards;
        user.depoList[_no].totalEarned += rewards;
        user.depoList[_no].lastWithdraw = block.timestamp;
        if (user.depoList[_no].totalEarned ==  _totalIncome) {
            user.depoList[_no].done = true;
        }

        BUSD.safeTransfer(msg.sender, rewards - LunarHopGroup[_level].price);

        user.totalDeposit += LunarHopGroup[_level].price;

        user.depoList.push(Depo({
            level: _level,
            totalEarned: 0,
            lastWithdraw: block.timestamp,
            done: false
        }));
    }

    function sellLunarHop(uint256 _no) external {
        require(block.timestamp >= launch, "App did not launch yet.");
        
        User storage user = Users[msg.sender];
        
        require(user.depoList.length > _no, "Invalid param");
        require(user.depoList[_no].done == false, "Already claimed!");
        require(user.depoList[_no].lastWithdraw + 1 days < block.timestamp, "Not claimable, yet");

        uint256 _level = user.depoList[_no].level;
        uint256 _price = LunarHopGroup[_level].price;
        
        require(_price > user.depoList[_no].totalEarned, "Could not sell, anymore!");
        uint256 leftPayment = (_price - user.depoList[_no].totalEarned) / 2;

        if (leftPayment > getBalance()) {
            leftPayment = getBalance();
        }

        user.totalAccured += leftPayment;
        user.depoList[_no].totalEarned += leftPayment;
        user.depoList[_no].lastWithdraw = block.timestamp;
        user.depoList[_no].done = true;

        uint256 withdrawFee = leftPayment.mul(WITHDRAW_FEE).div(PERCENTS_DIVIDER);
        leftPayment = leftPayment - withdrawFee;

        BUSD.safeTransfer(dev, withdrawFee/2);
        BUSD.safeTransfer(CEO, withdrawFee/2);
        BUSD.safeTransfer(msg.sender, leftPayment);
	}

    function userInfo() view external returns (Depo [] memory depoList) {
        User storage user = Users[msg.sender];
        return(
            user.depoList
        );
    }

    function withdrawRefBonus() external {
        User storage user = Users[msg.sender];
        uint256 amtz = user.refBonus;
        user.refBonus = 0;
        user.totalWithRefBonus += amtz;
        BUSD.safeTransfer(msg.sender, amtz);
    }

    function getTotalRewards(address _account) public view returns (uint256) {
        User storage user = Users[_account];

        uint256 with;
        for (uint256 i = 0; i < user.depoList.length; i++){
            if (user.depoList[i].done == false) {
                uint256 _level = user.depoList[i].level;
                uint256 _totalIncome = LunarHopGroup[_level].totalIncome;
                uint256 dailyROI = LunarHopGroup[_level].dailyProfit;
                uint256 rewards = (block.timestamp - user.depoList[i].lastWithdraw) * dailyROI / 1 days;
                rewards = min(rewards, _totalIncome - user.depoList[i].totalEarned);
                with += rewards;
            }
        }

        return with;
    }

    function changeDEV(address _account) external {
        require(msg.sender == dev, "Only dev is accessable");
        dev = _account;
    }
    
    function changeCEO(address _account) external {
        require(msg.sender == CEO, "Only CEO is accessable");
        CEO = _account;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a > b) {
            return b;
        } else {
            return a;
        }
    }

    function getBalance() public view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }

    function getUserInfo() public view returns(uint256 totalDeposit, uint256 totalAccured, 
                            address referrer, uint256 refBonus, uint256 totalWithRefBonus, uint256 totalDepositCnt) {
        User storage user = Users[msg.sender];
        return (
            user.totalDeposit,
            user.totalAccured,
            user.referrer,
            user.refBonus,
            user.totalWithRefBonus,
            user.depoList.length
        );
    }

    function getUserDepositInfo(address _account, uint256 _no) public view returns(uint256 level, 
                                uint256 totalEarned, uint256 lastWithdraw, bool done) {
        User storage user = Users[_account];
        require(_no < user.depoList.length, "Invalid param!");

        return (
            user.depoList[_no].level,
            user.depoList[_no].totalEarned,
            user.depoList[_no].lastWithdraw,
            user.depoList[_no].done
        );
    }
}