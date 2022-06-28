// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interface/IDaos.sol";
import "./interface/IFuel.sol";

contract LpDeposit is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    constructor() {}

    bool public rewardWithdrawSwitch = true;
    address public daos = 0xfFB79F85B1EA778ca4Db97DdF535870067479bf4;
    address public fuel = 0xAE5d77aD2F987D637C0FF86acE113E66B7e25093;
    address public usdtDaosPair = 0x199c5CdBae6B311f08EE29f72163ec426b84645F;
    uint256 public startTimestamp = block.timestamp;
    uint256 public endTimestamp = block.timestamp + 30 * 24 * 3600;
    uint256 public userDepositInterval = 12 * 3600;
    address public usdtToken = 0xbd1E08E4d1B8290892c14cF2caA70D63d00b8d71;
    mapping(address => uint256) public lastDepositTimestamp;

    function setRewardWithdrawSwitch(bool _bool) public onlyOwner {
        rewardWithdrawSwitch = _bool;
    }

    function setUserDepositInterval(uint256 _userDepositInterval) public onlyOwner {
        userDepositInterval = _userDepositInterval;
    }

    function setDaos(address _addr) public onlyOwner {
        daos = _addr;
    }

    function setUsdtDaosPair(address _addr) public onlyOwner {
        usdtDaosPair = _addr;
    }

    function setStartTimestamp(uint256 _startTimestamp) public onlyOwner {
        startTimestamp = _startTimestamp;
    }

    function setEndTimestamp(uint256 _endTimestamp) public onlyOwner {
        endTimestamp = _endTimestamp;
    }

    struct UserCurrentInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 totalAward;
    }
    struct UserDepositInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 totalAward;
        uint256 lockTimestampUntil;
        bool status;
    }
    struct PoolInfo {
        uint256 allocPoint;
        uint256 lockSecond;
        uint256 lastRewardTimestamp;
        uint256 accAwardPerShare;
        uint256 totalAmount;
        bool status;
        //token 分红比例
        uint256 rewardPercent;
    }

    uint256 public awardPerSecond = 0.01 * 1e18;
    uint256 public totalAllocPoint = 0;
    PoolInfo[] public poolInfos;

    function setAwardPerSecond(uint256 _awardPerSecond) public onlyOwner {
        awardPerSecond = _awardPerSecond;
    }

    function add(
        uint256 _allocPoint,
        uint256 _lockSecond,
        uint256 _rewardPercent,
        bool _status,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardTimestamp = block.timestamp > startTimestamp ? block.timestamp : startTimestamp;
        totalAllocPoint += _allocPoint;
        poolInfos.push(
            PoolInfo({
                allocPoint: _allocPoint,
                lockSecond: _lockSecond,
                lastRewardTimestamp: lastRewardTimestamp,
                accAwardPerShare: 0,
                totalAmount: 0,
                rewardPercent: _rewardPercent,
                status: _status
            })
        );
    }

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        uint256 _lockSecond,
        uint256 _rewardPercent,
        bool _status,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        require(_pid < poolInfos.length, "Pool id is not exist");
        totalAllocPoint = totalAllocPoint - poolInfos[_pid].allocPoint + _allocPoint;
        poolInfos[_pid].allocPoint = _allocPoint;
        poolInfos[_pid].lockSecond = _lockSecond;
        poolInfos[_pid].status = _status;
        poolInfos[_pid].rewardPercent = _rewardPercent;
    }

    function massUpdatePools() public {
        uint256 length = poolInfos.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public returns (PoolInfo memory pool) {
        pool = poolInfos[_pid];
        if (block.timestamp > pool.lastRewardTimestamp) {
            uint256 timeSeconds;
            if (pool.totalAmount > 0) {
                if (block.timestamp > endTimestamp) {
                    timeSeconds = endTimestamp - pool.lastRewardTimestamp;
                } else {
                    timeSeconds = block.timestamp - pool.lastRewardTimestamp;
                }
                uint256 reward = timeSeconds * awardPerSecond * pool.allocPoint / totalAllocPoint;
                pool.accAwardPerShare += reward * 1e18 / pool.totalAmount;
            }
            pool.lastRewardTimestamp += timeSeconds;
            poolInfos[_pid] = pool;
        }
    }

    function allPool() public view returns (PoolInfo[] memory) {
        return poolInfos;
    }

    mapping(address => UserCurrentInfo) public userCurrentInfos;
    mapping(address => mapping(uint256 => UserDepositInfo[])) public userDepositInfos;
    mapping(address => uint256) public availableWithdrawBalance;

    //奖励模块
    uint256 public accBonus;
    uint256 public totalEffectAmount;
    uint256 public totalDepositAmount;
    mapping(address => uint256) public bonusWithdrawAbles;
    uint256 public totalBonusAmount;
    uint256 public totalBonusUsedAmount;
    uint256 public bonusRate = 1;
    uint256 public bonusInterval = 5 * 60;
    uint256 public nextBonusTime = 0;

    mapping(address => mapping(uint256 => BonusDepositInfo[])) public bonusDepositInfos; //定期质押记录
    mapping(address => BonusCurrentDepositInfo) public bonusCurrentDepositInfos;    //活期质押记录

    //活期
    struct BonusCurrentDepositInfo {
        uint256 amount;
        uint256 effect;
        uint256 debt;
        uint256 reward;
    }
    //定期
    struct BonusDepositInfo {
        uint256 pid;
        uint256 amount;
        uint256 effect;
        bool status;
        uint256 debt;
        uint256 reward;
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo memory pool = updatePool(_pid);
        uint256 effect = (pool.rewardPercent * _amount) / 1000; // 池子分红占比按照1000的倍数填写
        if (pool.lockSecond == 0) {
            userCurrentInfos[msg.sender].amount += _amount;
            userCurrentInfos[msg.sender].rewardDebt += _amount * poolInfos[_pid].accAwardPerShare / 1e18;
            //分红业务逻辑
            bonusCurrentDepositInfos[msg.sender].amount += _amount;
            bonusCurrentDepositInfos[msg.sender].effect += effect;
            bonusCurrentDepositInfos[msg.sender].debt += _amount * accBonus / 1e18;
        } else {
            require(lastDepositTimestamp[msg.sender] + userDepositInterval < block.timestamp, "Operation limit");
            userDepositInfos[msg.sender][_pid].push(
                UserDepositInfo({
                    amount: _amount,
                    rewardDebt: _amount * pool.accAwardPerShare / 1e18,
                    totalAward: 0,
                    lockTimestampUntil: block.timestamp + pool.lockSecond,
                    status: true
                })
            );
            lastDepositTimestamp[msg.sender] = block.timestamp;
            //分红业务逻辑
            BonusDepositInfo storage bonusDepositInfo = bonusDepositInfos[msg.sender][_pid].push();
            bonusDepositInfo.pid = _pid;
            bonusDepositInfo.amount = _amount;
            bonusDepositInfo.effect = effect;
            bonusDepositInfo.status = true;
            bonusDepositInfo.debt = effect * accBonus / 1e18;
        }
        totalEffectAmount += effect;
        totalDepositAmount += _amount;
        pool.totalAmount += _amount;
        IERC20(usdtDaosPair).safeTransferFrom(msg.sender, address(this), _amount);
        poolInfos[_pid] = pool;
    }

    function withdraw(
        uint256 _pid,
        uint256 _amount,
        uint256 _index
    ) public {
        PoolInfo memory pool = updatePool(_pid);
        uint256 effect = (pool.rewardPercent * _amount) / 1000;
        if (pool.lockSecond == 0) {
            uint256 accumulatedAward = userCurrentInfos[msg.sender].amount * pool.accAwardPerShare / 1e18;
            uint256 _pending = accumulatedAward - userCurrentInfos[msg.sender].rewardDebt;
            userCurrentInfos[msg.sender].rewardDebt = accumulatedAward - (_amount * pool.accAwardPerShare / 1e18);
            userCurrentInfos[msg.sender].amount -= _amount;
            userCurrentInfos[msg.sender].totalAward += _pending;

            availableWithdrawBalance[msg.sender] += _pending;
            IERC20(usdtDaosPair).safeTransfer(msg.sender, _amount);
            //分红业务逻辑
            uint256 bonusPending = effect * accBonus / 1e18 - bonusCurrentDepositInfos[msg.sender].debt;
            bonusCurrentDepositInfos[msg.sender].reward += bonusPending;
            bonusCurrentDepositInfos[msg.sender].debt = (bonusCurrentDepositInfos[msg.sender].amount - _amount) * accBonus / 1e18;
            bonusCurrentDepositInfos[msg.sender].amount -= _amount;
            bonusCurrentDepositInfos[msg.sender].effect -= effect;
            bonusWithdrawAbles[msg.sender] += bonusPending;
        } else {
            UserDepositInfo storage depositInfo = userDepositInfos[msg.sender][_pid][_index];
            require(depositInfo.status, "The deposit is withdraw");
            require(depositInfo.amount == _amount, "You must withdraw all amount of deposit");
            require(depositInfo.lockTimestampUntil <= block.timestamp);

            depositInfo.status = false;
            uint256 accumulatedAward = depositInfo.amount * pool.accAwardPerShare / 1e18;
            depositInfo.totalAward = accumulatedAward - depositInfo.rewardDebt;

            availableWithdrawBalance[msg.sender] += depositInfo.totalAward;
            IERC20(usdtDaosPair).safeTransfer(msg.sender, _amount);
            //分红业务逻辑
            BonusDepositInfo storage bonusDepositInfo = bonusDepositInfos[msg.sender][_pid][_index];
            uint256 bonusPending = pendingForBonus(msg.sender, _pid, _index);
            bonusDepositInfo.reward += bonusPending;
            bonusDepositInfo.status = false;
            bonusWithdrawAbles[msg.sender] += bonusPending;
        }
        pool.totalAmount = pool.totalAmount.sub(_amount);
        poolInfos[_pid] = pool;
        totalEffectAmount -= effect;
        totalDepositAmount -= _amount;
    }

    function harvestBatch() public {
        require(rewardWithdrawSwitch, "Can not harvest now");
        massUpdatePools();
        PoolInfo[] memory poolInfosMemory = poolInfos;
        uint256 totalPending = 0;
        for (uint256 i = 0; i < poolInfosMemory.length; i++) {
            if (poolInfosMemory[i].lockSecond == 0) {
                uint256 accumulatedAward = userCurrentInfos[msg.sender].amount * poolInfosMemory[i].accAwardPerShare / 1e18;
                uint256 _pending = accumulatedAward - userCurrentInfos[msg.sender].rewardDebt;
                userCurrentInfos[msg.sender].rewardDebt = accumulatedAward;
                if (_pending > 0) {
                    userCurrentInfos[msg.sender].totalAward = userCurrentInfos[msg.sender].totalAward + _pending;
                    totalPending += _pending;
                }
            } else {
                UserDepositInfo[] storage userDepositInfosPool = userDepositInfos[msg.sender][i];
                uint256 accAwardPerShare = poolInfosMemory[i].accAwardPerShare;
                for (uint256 j = 0; j < userDepositInfosPool.length; j++) {
                    if (!userDepositInfosPool[j].status) {
                        continue;
                    }
                    uint256 _pending = userDepositInfosPool[j].amount * accAwardPerShare / 1e18 - userDepositInfosPool[j].rewardDebt;
                    userDepositInfosPool[j].rewardDebt += _pending;
                    userDepositInfosPool[j].totalAward += _pending;
                    totalPending += _pending;
                }
            }
        }
        if (availableWithdrawBalance[msg.sender] > 0) {
            totalPending += availableWithdrawBalance[msg.sender];
            availableWithdrawBalance[msg.sender] = 0;
        }
        if (totalPending > 0) {
            IDaos(daos).mint(msg.sender, totalPending);
        }
    }

    function pendingAll(address _addr) external view returns(uint256) {
        uint256 totalPending = 0;
        PoolInfo[] memory poolInfosMemory = poolInfos;
        for(uint256 i = 0; i < poolInfosMemory.length; i++) {
            totalPending += pending(_addr, i);
        }
        return totalPending;
    }

    // 池子所有的pending(挖矿)
    function pending(address _addr, uint256 _pid) public view returns (uint256) {
        uint256 accAwardPerShare = poolInfos[_pid].accAwardPerShare;
        uint256 lpSupply = poolInfos[_pid].totalAmount;
        if (poolInfos[_pid].lockSecond == 0) {
            if (block.timestamp > poolInfos[_pid].lastRewardTimestamp && lpSupply != 0) {
                uint256 timeSeconds = (block.timestamp > endTimestamp) ? endTimestamp - poolInfos[_pid].lastRewardTimestamp : block.timestamp - poolInfos[_pid].lastRewardTimestamp;
                uint256 reward = timeSeconds * awardPerSecond * poolInfos[_pid].allocPoint / totalAllocPoint;
                accAwardPerShare += reward * 1e18 / lpSupply;
            }
            return userCurrentInfos[_addr].amount * accAwardPerShare / 1e18 - userCurrentInfos[_addr].rewardDebt;
        } else {
            uint256 totalPending = 0;
            UserDepositInfo[] memory userDepositInfosPool = userDepositInfos[_addr][_pid];
            for (uint256 i = 0; i < userDepositInfosPool.length; i++) {
                totalPending = totalPending.add(pendingDeposit(_addr, _pid, i));
            }
            return totalPending;
        }
    }

    //定期每条记录pending（挖矿）
    function pendingDeposit(
        address _addr,
        uint256 _pid,
        uint256 _index
    ) public view returns (uint256) {
        UserDepositInfo storage userDepositInfo = userDepositInfos[_addr][_pid][_index];
        if (!userDepositInfo.status) {
            return 0;
        }
        uint256 accAwardPerShare = poolInfos[_pid].accAwardPerShare;
        uint256 lpSupply = poolInfos[_pid].totalAmount;
        if (block.timestamp > poolInfos[_pid].lastRewardTimestamp && lpSupply != 0) {
            uint256 timeSeconds = block.timestamp > endTimestamp ? endTimestamp - poolInfos[_pid].lastRewardTimestamp : block.timestamp - poolInfos[_pid].lastRewardTimestamp;
            uint256 reward = timeSeconds * awardPerSecond * poolInfos[_pid].allocPoint / totalAllocPoint;
            accAwardPerShare += reward * 1e18 / lpSupply;
        }
        return userDepositInfo.amount * accAwardPerShare / 1e18 - userDepositInfo.rewardDebt;
    }

    function userDepositPoolInfos(address _addr, uint256 _pid) public view returns (UserDepositInfo[] memory) {
        return userDepositInfos[_addr][_pid];
    }

    //充值
    function bonusRescue(uint256 _amount) public {
        require(_amount > 0, "Cannot be zero");
        IERC20(usdtToken).transferFrom(msg.sender,address(this), _amount);
        totalBonusAmount += _amount;
    }

    //分红
    function award() public {
        uint256 bonusAmount = (totalBonusAmount - totalBonusUsedAmount) * bonusRate / 1000 ;
        require(bonusAmount > 0, "Cannot award");
        require(block.timestamp >= nextBonusTime, "Already Award");
        nextBonusTime = block.timestamp + bonusInterval;
        totalBonusUsedAmount += bonusAmount;
        accBonus += bonusAmount * 1e18 / totalEffectAmount;
    }

    function setBonusRate(uint256 _rate) public onlyOwner {
        require(_rate != 0, "Rate Is Error!");
        bonusRate = _rate;
    }

    //领取分红
    function harvestForBonus() public {
        PoolInfo[] memory poolInfosMemory = poolInfos;
        uint256 totalBonusPending = 0;
        for (uint256 i = 0; i < poolInfosMemory.length; i++) {
            if (poolInfosMemory[i].lockSecond == 0) {
                 //分红收割业务逻辑
                uint256 currentPending = bonusCurrentDepositInfos[msg.sender].amount * accBonus / 1e18 - bonusCurrentDepositInfos[msg.sender].debt;
                bonusCurrentDepositInfos[msg.sender].debt += currentPending;
                bonusCurrentDepositInfos[msg.sender].reward += currentPending;
                totalBonusPending += currentPending;
            } else {
                BonusDepositInfo[] storage bonusDepositInfoList = bonusDepositInfos[msg.sender][i];
                for(uint256 k = 0; k < bonusDepositInfoList.length; k++) {
                    if(!bonusDepositInfoList[k].status) {
                        continue;
                    }
                    uint256 _bonusDepositPending = pendingForBonus(msg.sender, i, k);
                    bonusDepositInfoList[k].debt += _bonusDepositPending;
                    bonusDepositInfoList[k].reward += _bonusDepositPending;
                    totalBonusPending += _bonusDepositPending;
                }
            }
        }

        if(bonusWithdrawAbles[msg.sender] > 0) {
            totalBonusPending += bonusWithdrawAbles[msg.sender];
            bonusWithdrawAbles[msg.sender] = 0;
        }

        if(totalBonusPending > 0) {
            uint256 burnAmount = totalBonusPending / 100;
            IFuel(fuel).burnFrom(msg.sender, burnAmount);
            IERC20(usdtToken).safeTransfer(msg.sender, totalBonusPending);
        }
    }

    function pendingForBonus(address _addr, uint256 _pid, uint256 _index) public view returns(uint256) {
       BonusDepositInfo storage bonusDepositInfo =  bonusDepositInfos[_addr][_pid][_index];
       return bonusDepositInfo.effect * accBonus / 1e18 - bonusDepositInfo.debt;
    }

    //查询用户所有质押分红收益
    function pendingForAllBonus(address _addr) public view returns(uint256) {
        PoolInfo[] memory poolInfosMemory = poolInfos;
        uint256 totalBonusPending = 0;
        for (uint256 i = 0; i < poolInfosMemory.length; i++) {
            if (poolInfosMemory[i].lockSecond == 0) {
                uint256 currentPending = bonusCurrentDepositInfos[_addr].amount * accBonus / 1e18 - bonusCurrentDepositInfos[_addr].debt;
                totalBonusPending += currentPending;
            } else {
                BonusDepositInfo[] storage bonusDepositInfoList = bonusDepositInfos[_addr][i];
                for(uint256 k = 0; k < bonusDepositInfoList.length; k++) {
                    if(!bonusDepositInfoList[k].status) {
                        continue;
                    }
                    uint256 _bonusDepositPending = pendingForBonus(_addr, i, k);
                    totalBonusPending += _bonusDepositPending;
                }
            }
        }
        return totalBonusPending;
    }

    //查询活期分红收益
    function pendingCurrentForBonus(address _addr) public view returns(uint256) {
        return bonusCurrentDepositInfos[_addr].amount * accBonus / 1e18 - bonusCurrentDepositInfos[_addr].debt;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
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

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IDaos {
    function mint(address account, uint256 amount) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IFuel {
    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function mint(address account, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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