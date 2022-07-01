/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: MIT
/*
███████╗██╗  ██╗██╗███╗   ███╗   ███████╗██╗███╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗
██╔════╝██║  ██║██║████╗ ████║   ██╔════╝██║████╗  ██║██╔══██╗████╗  ██║██╔════╝██╔════╝
███████╗███████║██║██╔████╔██║   █████╗  ██║██╔██╗ ██║███████║██╔██╗ ██║██║     █████╗  
╚════██║██╔══██║██║██║╚██╔╝██║   ██╔══╝  ██║██║╚██╗██║██╔══██║██║╚██╗██║██║     ██╔══╝  
███████║██║  ██║██║██║ ╚═╝ ██║██╗██║     ██║██║ ╚████║██║  ██║██║ ╚████║╚██████╗███████╗
╚══════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚═╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝
*/
//     https://shim.finance/
// SHIM PROTOCOL COPYRIGHT (C) 2022 


pragma solidity ^0.8.11;

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

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }
    
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

}

contract ShimStaking is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    string public name = "ShimStaking";

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        IERC20 lpToken;
        uint256 allocPoint;
        uint256 accMaftecPerShare;
        uint256 rewardPackage;
        uint16 depositFeeBP;
    }

    address public injector;
    address public treasuryDAO;

    address public immutable BUSD = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //BUSD

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    uint256 public totalAllocPoint;
    uint256 public totalBusdReward;

    bool inReward = false;
    modifier injecting() {
        inReward = true;
        _;
        inReward = false;
    }

    modifier onlyOwnerOrInjector() {
        require((msg.sender == owner()) || (msg.sender == injector), "Not owner or injector");
        _;
    }

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount,
                            uint256 poolAccMaftecPerShare, uint256 userRewardDebt);
    event NewTreasuryDAOAndInjector(address _treasuryDAO, address _injector);

    constructor() {
        totalAllocPoint = 0;
        totalBusdReward = 0;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }
    
    function add(uint256 _allocPoint, IERC20 _lpToken, uint16 _depositFeeBP) public onlyOwner {
        require(_depositFeeBP <= 10000, "add: invalid deposit fee basis points");

        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            accMaftecPerShare: 0,
            rewardPackage: 0,
            depositFeeBP: _depositFeeBP
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, uint16 _depositFeeBP) public onlyOwner {
        require(_depositFeeBP <= 10000, "set: invalid deposit fee basis points");

        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(_allocPoint);
        }
    }

    function pendingBUSD(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accMaftecPerShare = pool.accMaftecPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply != 0) {
            accMaftecPerShare = accMaftecPerShare.add(pool.rewardPackage.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accMaftecPerShare).div(1e12).sub(user.rewardDebt);
    }

    function injectReward(uint256 _busdReward) external injecting onlyOwnerOrInjector{
        IERC20(BUSD).transferFrom(msg.sender, address(this), _busdReward);
        totalBusdReward += _busdReward;
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            poolInfo[pid].rewardPackage += _busdReward.mul(
                poolInfo[pid].allocPoint).div(totalAllocPoint);
        }
    }

    function updatePool(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        if (pool.rewardPackage == 0) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            return;
        }
        pool.accMaftecPerShare = pool.accMaftecPerShare.add(pool.rewardPackage.mul(1e12).div(lpSupply));
        pool.rewardPackage = 0;
    }

    function deposit(uint256 _pid, uint256 _amount) public nonReentrant {
        if (inReward) {
            return;
        }
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accMaftecPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                IERC20(BUSD).transfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.transferFrom(msg.sender, address(this), _amount);
            if (pool.depositFeeBP > 0) {
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                pool.lpToken.transfer(treasuryDAO, depositFee);
                user.amount = user.amount.add(_amount).sub(depositFee);
            } else {
                user.amount = user.amount.add(_amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accMaftecPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public nonReentrant {
        if (inReward) {
            return;
        }
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accMaftecPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            IERC20(BUSD).transfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.transfer(msg.sender, _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accMaftecPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.transfer(msg.sender, user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount, pool.accMaftecPerShare, user.rewardDebt);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function setTreasuryDAOAndInjector(
        address _treasuryDAO,
        address _injector
    ) external onlyOwner {
        require(_treasuryDAO != address(0), "Cannot be zero address");
        require(_injector != address(0), "Cannot be zero address");

        treasuryDAO = _treasuryDAO;
        injector = _injector;

        emit NewTreasuryDAOAndInjector(_treasuryDAO, _injector);
    }
}