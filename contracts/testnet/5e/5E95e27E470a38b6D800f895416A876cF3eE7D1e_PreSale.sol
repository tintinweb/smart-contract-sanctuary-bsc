// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";

contract PreSale is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20; 

    uint256 public usdtLock = 0;
    uint256 public usdtTotal = 0;
    mapping(address => address) public userReffer;
    mapping(address => uint256) public userReward;
    //address public usdtAddr = address(0x55d398326f99059fF775485246999027B3197955);
    address public usdtAddr = address(0x70B0a558945f9377CFA8d7fdc78f60128a070954);
    address public saleAddr = address(0xEDa1844BC5BcFe21B146e89a0AE7623047dfE5E4);
    address public adminAddr = address(0xEDa1844BC5BcFe21B146e89a0AE7623047dfE5E4);
    address public teamAddr = address(0xEDa1844BC5BcFe21B146e89a0AE7623047dfE5E4);

    event CreatePresale(uint256 pid, uint256 salePrice, uint256 saleTokenNum, uint256 start, uint256 end);
    event JoinPresale(address user, uint256 pid, uint256 usdtAmount, uint256 getTokenNum);
    event Claim(address user, uint256 pid, uint256 amount);
    event ClaimRefferReward(address user, uint256 amount);
    event Withdraw(address indexed user, address token, uint256 amount);

    struct Presale {
        uint256 salePrice; 
        uint256 saleTokenNum;
        uint256 saledTokenNum;
        uint256 start; 
        uint256 end; 
    }

    struct User {
        uint256 balance;
        uint256 firstLockBal; 
        uint256 firstUnlockTime; 
        bool firstClaimed;
        uint256 perSecondUnlockAmt; 
        uint256 lastUnlockTime; 
    }

    Presale[] public presales;
    mapping(uint256 => mapping(address => User)) public userPreSales;

    constructor() public {}

    modifier onlyAdmin() {
        require(msg.sender == adminAddr, "!adminAddr");
        _;
    } 

    function presaleLength() public view returns (uint256) {
        return presales.length;
    }

    function bindReffer(address parrent) public {
        userReffer[msg.sender] = parrent;
    }

    function createPresale(uint256 salePrice, uint256 saleTokenNum, uint256 start, uint256 end) public onlyAdmin {
        IERC20(saleAddr).transferFrom(address(msg.sender), address(this), saleTokenNum);
        Presale memory presale = Presale(salePrice, saleTokenNum, 0, start, end);
        presales.push(presale);

        emit CreatePresale(presales.length - 1, salePrice, saleTokenNum, start, end);
    }

    function presale(uint256 pid, uint256 amount) public payable nonReentrant {   
        Presale memory presale = presales[pid];
        IERC20(usdtAddr).transferFrom(address(msg.sender), address(this), amount);
        usdtTotal += amount;

        User storage user = userPreSales[pid][msg.sender];

        uint256 getTokenNum = amount.mul(presale.salePrice).div(1e18);
        uint256 firstLockBal = getTokenNum.mul(30).div(100);
        uint256 firstUnlockTime = presale.end + 86400 * 25;
        uint256 perSecondUnlockAmt = getTokenNum.sub(firstLockBal) * 3 / 1000 / 86400;

        user.balance += getTokenNum;
        user.firstLockBal += firstLockBal;
        user.firstUnlockTime = firstUnlockTime;
        user.perSecondUnlockAmt += perSecondUnlockAmt;
        user.lastUnlockTime =  presale.end + 86400 * 26;
        userPreSales[pid][msg.sender] = user;
        presale.saledTokenNum += getTokenNum;

        address parrent = userReffer[msg.sender];
        if(parrent != address(0)) {
            userReward[parrent] += amount * 5 / 100;
            usdtLock += amount * 5 / 100;

            parrent = userReffer[parrent];
            if(parrent != address(0)) {
                userReward[parrent] += amount * 3 / 100;
                usdtLock += amount * 3 / 100;
            }
        }

        emit JoinPresale(msg.sender, pid, amount, getTokenNum);
    }

    function claimRefferReward() public {
        uint256 reward = userReward[msg.sender];
        if(reward <= 0) return;

        IERC20(usdtAddr).transferFrom(address(this), address(msg.sender), reward);
        userReward[msg.sender] = 0;
        emit ClaimRefferReward(msg.sender, reward);
    }

    function claim(uint256 pid) public {
        Presale memory presale = presales[pid];
        User storage user = userPreSales[pid][msg.sender];
        if(!user.firstClaimed && user.firstLockBal > 0) {
            user.balance -= user.firstLockBal;
            user.firstClaimed = true;

            safeTransfer(saleAddr, msg.sender, user.firstLockBal);
            emit Claim(msg.sender, pid, user.firstLockBal);
        }

        if(block.timestamp <= user.lastUnlockTime) return;
        if(user.balance <= 0) return;

        uint256 time = getMultiplier(user.lastUnlockTime, block.timestamp);
        uint256 unlockTokens = user.perSecondUnlockAmt.mul(time);
        if(unlockTokens >= user.balance) {
            unlockTokens = user.balance;
        }

        user.balance -= unlockTokens;
        user.lastUnlockTime = block.timestamp;
        safeTransfer(saleAddr, msg.sender, unlockTokens);

        emit Claim(msg.sender, pid, unlockTokens);
    }

    function withdraw(uint256 amount) public nonReentrant {
        require(msg.sender == teamAddr, "Account not permission");
        require(amount > 0, "amount must be >= 0");

        uint256 usdtBalance = usdtTotal - usdtLock;
        require(amount <= usdtBalance, "amount must be <= usdtBalance");

        safeTransfer(usdtAddr, teamAddr, amount);
        emit Withdraw(teamAddr, usdtAddr, amount);
    }

    function pendingTokens(uint256 pid) public view returns (uint256 pendingTokenNum) {
        Presale memory presale = presales[pid];
        User storage user = userPreSales[pid][msg.sender];
        if(!user.firstClaimed && user.firstLockBal > 0) {
            pendingTokenNum = user.firstLockBal;
        }

        if(block.timestamp < user.lastUnlockTime) return pendingTokenNum;

        uint256 time = getMultiplier(user.lastUnlockTime, block.timestamp);
        uint256 unlockTokens = user.perSecondUnlockAmt.mul(time);
        if(unlockTokens >= user.balance) {
            unlockTokens = user.balance;
        }

        pendingTokenNum += unlockTokens;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return _to.sub(_from);
    } 

    function safeTransfer(address token, address _to, uint256 amount) internal {
        uint256 bal = IERC20(token).balanceOf(address(this));
        if (amount > bal) {
            IERC20(token).transfer(_to, bal);
        } else {
            IERC20(token).transfer(_to, amount);
        }
    }
}