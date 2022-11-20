/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

/**
*
*
*    ________  ________      ___    ___ ________  _________  ________  ________  ___  ___  ________   ___  __                   _____ ______   ___  ________   _______   ________     
*   |\   ____\|\   __  \    |\  \  /  /|\   __  \|\___   ___\\   __  \|\   __  \|\  \|\  \|\   ___  \|\  \|\  \                |\   _ \  _   \|\  \|\   ___  \|\  ___ \ |\   __  \    
*   \ \  \___|\ \  \|\  \   \ \  \/  / | \  \|\  \|___ \  \_\ \  \|\  \ \  \|\  \ \  \\\  \ \  \\ \  \ \  \/  /|_  ____________\ \  \\\__\ \  \ \  \ \  \\ \  \ \   __/|\ \  \|\  \   
*    \ \  \    \ \   _  _\   \ \    / / \ \   ____\   \ \  \ \ \  \\\  \ \   ____\ \  \\\  \ \  \\ \  \ \   ___  \|\____________\ \  \\|__| \  \ \  \ \  \\ \  \ \  \_|/_\ \   _  _\  
*     \ \  \____\ \  \\  \|   \/  /  /   \ \  \___|    \ \  \ \ \  \\\  \ \  \___|\ \  \\\  \ \  \\ \  \ \  \\ \  \|____________|\ \  \    \ \  \ \  \ \  \\ \  \ \  \_|\ \ \  \\  \| 
*      \ \_______\ \__\\ _\ __/  / /      \ \__\        \ \__\ \ \_______\ \__\    \ \_______\ \__\\ \__\ \__\\ \__\              \ \__\    \ \__\ \__\ \__\\ \__\ \_______\ \__\\ _\ 
*       \|_______|\|__|\|__|\___/ /        \|__|         \|__|  \|_______|\|__|     \|_______|\|__| \|__|\|__| \|__|               \|__|     \|__|\|__|\|__| \|__|\|_______|\|__|\|__|
*                          \|___|/                                                                                                                                                    
*                                                                                                                                                                                  
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
    uint256 startDate;
    uint256 divs;
    uint256 refBonus;
    uint256 totalInits;
    uint256 totalWithRefBonus;
    uint256 totalAccrued;
    uint256 lastWith;
    uint256 timesCmpd;
    uint256 keyCounter;
    Depo [] depoList;
}
struct Depo {
    uint256 key;
    uint256 depoTime;
    uint256 finishTime;
    uint256 level;
    address reffy;
    bool    done;
}
struct Main {
    uint256 ovrTotalDeps;
    uint256 ovrTotalWiths;
    uint256 users;
    uint256 compounds;
}
struct CryptoPunk{
    uint256 daysInSeconds; // updated to be in seconds
    uint256 dailyProfit;
    uint256 price;
}
struct FeesPercs{
    uint256 daysInSeconds;
    uint256 feePercentage;
}
contract CryptoPunkMiner {
    using SafeMath for uint256;
    bool public launch;
  	uint256 constant hardDays = 86400;
    uint256 constant minStakeAmt = 50 * 10**18;
    uint256 constant percentdiv = 1000;
    uint256 constant MIN_WITHDRAW = 10 ** 18;
    uint256 refPercentage1 = 50;
    uint256 refPercentage2 = 30;
    uint256 refPercentage3 = 20;
    uint256 devFee = 100;
    mapping (address => mapping(uint256 => Depo)) public DeposMap;
    mapping (address => User) public UsersKey;
    mapping (uint256 => CryptoPunk) public CryptoPunkGroup;
    mapping (uint256 => Main) public MainKey;
    mapping (address => bool) public Investors;
    mapping (address => bool) public FreeMinted;
    using SafeERC20 for IERC20;
    IERC20 public BUSD;
    address public owner;

    constructor() {
            owner = address(0x0B61278fcc44fB76bbDb753aB6D52804F085dfea);
            CryptoPunkGroup[0] = CryptoPunk(10000000000, 10 ** 16, 0);                  // Free
            CryptoPunkGroup[1] = CryptoPunk(30 days, 25 * 10 ** 16, 5 * 10 ** 18);      // $0.25 per day
            CryptoPunkGroup[2] = CryptoPunk(30 days, 11 * 10 ** 17, 20 * 10 ** 18);     // $1.1 per day
            CryptoPunkGroup[3] = CryptoPunk(45 days, 5 * 10 ** 18, 120 * 10 ** 18);
            CryptoPunkGroup[4] = CryptoPunk(45 days, 14 * 10 ** 18, 300 * 10 ** 18);
            CryptoPunkGroup[5] = CryptoPunk(60 days, 50 * 10 ** 18, 1000 * 10 ** 18);
            CryptoPunkGroup[6] = CryptoPunk(60 days, 255 * 10 ** 18, 5000 * 10 ** 18);
            
            BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
            // BUSD = IERC20(0xfB299533C9402B3CcF3d0743F4000c1AA2C26Ae0); 
    }

    function fundContract(uint256 _amount) external {
        BUSD.safeTransferFrom(msg.sender, address(this), _amount);
    }

    function startMining() external {
        require(msg.sender == owner, "only owner can start");
        require(launch == false, "only owner can start");
        launch = true;
    }

    function buyCryptoPunk(uint256 amtx, uint256 _level, address ref) external {
        require(launch == true, "App did not launch yet.");
        require(_level >= 0 && _level <= 6 , "You should select level between 0 and 6.");
        require(amtx >= CryptoPunkGroup[_level].price, "Your payment is not enough to buy CryptoPunks.");
        if (_level == 0) {
            require(FreeMinted[msg.sender] == false, "You can purchase only one free Ape.");
            FreeMinted[msg.sender] = true;
        }

        BUSD.safeTransferFrom(msg.sender, address(this), amtx);
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        if (user.lastWith == 0){
            user.lastWith = block.timestamp;
            user.startDate = block.timestamp;
        }
        // uint256 userStakePercentAdjustment = 1000 - devFee;
        // uint256 adjustedAmt = amtx.mul(userStakePercentAdjustment).div(percentdiv); 
        uint256 stakeFee = amtx.mul(devFee).div(percentdiv); 
        
        user.totalInits += amtx; //adjustedAmt
        uint256 refAmtx1 = amtx.mul(refPercentage1).div(percentdiv);
        uint256 refAmtx2 = amtx.mul(refPercentage2).div(percentdiv);
        uint256 refAmtx3 = amtx.mul(refPercentage3).div(percentdiv);
        if (ref != address(0) && ref != msg.sender) {
            User storage user2 = UsersKey[ref];
            user2.refBonus += refAmtx1;
            if (user2.depoList.length > 0) {
                address ref2 = user2.depoList[user2.depoList.length-1].reffy;
                User storage user3 = UsersKey[ref2];
                user3.refBonus += refAmtx2;
            
                if (user3.depoList.length > 0) {
                    address ref3 = user3.depoList[user3.depoList.length-1].reffy;
                    User storage user4 = UsersKey[ref3];
                    user4.refBonus += refAmtx3;
                }
            }
        }

        user.depoList.push(Depo({
            key: user.depoList.length,
            depoTime: block.timestamp,
            finishTime: block.timestamp + CryptoPunkGroup[_level].daysInSeconds,
            level: _level,
            reffy: ref,
            done: false
        }));

        user.keyCounter += 1;
        main.ovrTotalDeps += amtx;
        if (Investors[msg.sender] == false) {
            Investors[msg.sender] = true;
            main.users += 1;
        }
        BUSD.safeTransfer(owner, stakeFee);
    }

    function userInfo() view external returns (Depo [] memory depoList) {
        User storage user = UsersKey[msg.sender];
        return(
            user.depoList
        );
    }

    function claimRewards() external {
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        uint256 x = calcdiv(msg.sender);
        x = min(getBalance(), x);
        require(x >= MIN_WITHDRAW, 'You can withdraw over minimum $1.');
      	for (uint i = 0; i < user.depoList.length; i++){
            if (user.depoList[i].done == false) {
                user.depoList[i].depoTime = min(block.timestamp, user.depoList[i].finishTime);
                if (user.depoList[i].depoTime == user.depoList[i].finishTime) {
                    user.depoList[i].done = true;
                }
            }
        }
        uint256 adjustedPercent = 1000 - devFee;
        uint256 adjustedAmt = x.mul(adjustedPercent).div(percentdiv); 
        uint256 withdrawFee = x.mul(devFee).div(percentdiv);

        main.ovrTotalWiths += x;
        user.totalAccrued += x;
        user.lastWith = block.timestamp;

        uint256 amtz = user.refBonus;
        user.refBonus = 0;
        user.totalWithRefBonus += amtz;

        BUSD.safeTransfer(owner, withdrawFee);
        BUSD.safeTransfer(msg.sender, adjustedAmt + amtz);
    }

    // function withdrawRefBonus() external {
    //     User storage user = UsersKey[msg.sender];
    //     uint256 amtz = user.refBonus;
    //     user.refBonus = 0;
    //     user.totalWithRefBonus += amtz;
    //     BUSD.safeTransfer(msg.sender, amtz);
    // }

    function calcdiv(address dy) public view returns (uint256) {
        User storage user = UsersKey[dy];

        uint256 with;
        for (uint256 i = 0; i < user.depoList.length; i++){
            if (user.depoList[i].done == false) {
                uint256 elapsedTime = min(block.timestamp, user.depoList[i].finishTime).sub(user.depoList[i].depoTime);
                uint256 level = user.depoList[i].level;
                uint256 dailyReturn = CryptoPunkGroup[level].dailyProfit;
                uint256 currentReturn = dailyReturn.mul(elapsedTime).div(1 days);
                with += currentReturn;
            }
        }

        return with;
    }

    function changeOwner(address _account) external {
        require(msg.sender == owner, "Only owner is accessable");
        owner = _account;
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
}