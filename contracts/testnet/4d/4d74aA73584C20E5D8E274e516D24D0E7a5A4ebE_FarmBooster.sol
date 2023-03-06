// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './interfaces/ICakePool.sol';
import './interfaces/IMasterChefV3.sol';
import './libraries/IterateMapping.sol';

contract FarmBooster is Ownable {
    using IterableMapping for ItMap;

    /// @notice cake token.
    address public immutable CAKE;
    /// @notice cake pool.
    address public immutable CAKE_POOL;
    /// @notice MasterChef V3 contract.
    IMasterChefV3 public immutable MASTER_CHEF_V3;

    /// @notice Cake Pool total locked liquidity
    uint256 public totalLockedAmount;

    /// @notice The latest total locked Amount In CakePool
    uint256 latestTotalLockedAmountInCakePool;

    struct UserLockedInfo {
        bool init;
        uint256 lockedAmount;
    }

    /// @notice Record user lockedAmount
    mapping(address => UserLockedInfo) userLockedInfos;

    /// @notice Maximum allowed boosted position numbers
    uint256 public MAX_BOOST_POSITION;
    /// @notice limit max boost
    uint256 public cA;
    /// @notice include 1e4
    uint256 public constant MIN_CA = 1e4;
    /// @notice include 1e5
    uint256 public constant MAX_CA = 1e5;
    /// @notice cA precision
    uint256 public constant CA_PRECISION = 1e5;
    /// @notice controls difficulties
    uint256 public cB;
    /// @notice not include 0
    uint256 public constant MIN_CB = 0;
    /// @notice include 50
    uint256 public constant MAX_CB = 50;
    /// @notice MCV2 basic boost factor, none boosted user"s boost factor
    uint256 public constant BOOST_PRECISION = 100 * 1e10;
    /// @notice MCV2 Hard limit for maxmium boost factor
    uint256 public constant MAX_BOOST_PRECISION = 200 * 1e10;
    /// @notice Average boost ratio precision
    uint256 public constant BOOST_RATIO_PRECISION = 1e5;
    /// @notice Cake pool BOOST_WEIGHT precision
    uint256 public constant BOOST_WEIGHT_PRECISION = 100 * 1e10; // 100%

    /// @notice The whitelist of pools allowed for farm boosting.
    mapping(uint256 => bool) public whiteList;

    /// @notice Info of each pool user.
    mapping(address => ItMap) public userInfo;

    event UpdateMaxBoostPosition(uint256 max);
    event UpdateCA(uint256 oldCA, uint256 newCA);
    event UpdateCB(uint256 oldCB, uint256 newCB);
    event UpdateBoostFarms(uint256 pid, bool status);
    event ActiveFarmPool(address indexed user, uint256 indexed pid, uint256 indexed tokenId);
    event DeactiveFarmPool(address indexed user, uint256 indexed pid, uint256 indexed tokenId);
    event UpdatePoolBoostMultiplier(
        address indexed user,
        uint256 indexed pid,
        uint256 indexed tokenId,
        uint256 oldMultiplier,
        uint256 newMultiplier
    );
    event UpdateCakePool(
        address indexed user,
        uint256 lockedAmount,
        uint256 lockedDuration,
        uint256 totalLockedAmount,
        uint256 maxLockDuration
    );

    /// @param _cake CAKE token contract address.
    /// @param _cakePool Cake Pool contract address.
    /// @param _v3 MasterChefV3 contract address.
    /// @param _max Maximum allowed boosted farm quantity.
    /// @param _cA Limit max boost.
    /// @param _cB Controls difficulties.
    constructor(address _cake, address _cakePool, IMasterChefV3 _v3, uint256 _max, uint256 _cA, uint256 _cB) {
        require(
            _max > 0 && _cA >= MIN_CA && _cA <= MAX_CA && _cB > MIN_CB && _cB <= MAX_CB,
            'constructor: Invalid parameter'
        );
        CAKE = _cake;
        CAKE_POOL = _cakePool;
        MASTER_CHEF_V3 = _v3;
        MAX_BOOST_POSITION = _max;
        cA = _cA;
        cB = _cB;

        // Record latest total locked amount in cake pool
        uint256 currentLockedAmount = ICakePool(_cakePool).totalLockedAmount();
        totalLockedAmount = currentLockedAmount;
        latestTotalLockedAmountInCakePool = currentLockedAmount;
    }

    /// @notice Checks if the msg.sender is a contract or a proxy
    modifier notContract() {
        require(!_isContract(msg.sender), 'contract not allowed');
        require(msg.sender == tx.origin, 'proxy contract not allowed');
        _;
    }

    /// @notice Checks if the msg.sender is the cake pool.
    modifier onlyCakePool() {
        require(msg.sender == CAKE_POOL, 'onlyCakePool: Not cake pool');
        _;
    }

    /// @notice Checks if the msg.sender is the MasterChef V3.
    modifier onlyMasterChefV3() {
        require(msg.sender == address(MASTER_CHEF_V3), 'onlyMasterChefV3: Not MasterChef V3');
        _;
    }

    /// @notice set maximum allowed boosted position numbers.
    function setMaxBoostPosition(uint256 _max) external onlyOwner {
        require(_max > 0, 'setMaxBoostPosition: Maximum boost position should greater than 0');
        MAX_BOOST_POSITION = _max;
        emit UpdateMaxBoostPosition(_max);
    }

    /// @notice Only allow whitelisted pids for farm boosting
    /// @param _pid pool id(MasterchefV2 pool).
    /// @param _status farm pool allowed boosted or not
    function setBoosterFarms(uint256 _pid, bool _status) external onlyOwner {
        whiteList[_pid] = _status;
        emit UpdateBoostFarms(_pid, _status);
    }

    /// @notice limit max boost
    /// @param _cA max boost
    function setCA(uint256 _cA) external onlyOwner {
        require(_cA >= MIN_CA && _cA <= MAX_CA, 'setCA: Invalid cA');
        uint256 temp = cA;
        cA = _cA;
        emit UpdateCA(temp, cA);
    }

    /// @notice controls difficulties
    /// @param _cB difficulties
    function setCB(uint256 _cB) external onlyOwner {
        require(_cB > MIN_CB && _cB <= MAX_CB, 'setCB: Invalid cB');
        uint256 temp = cB;
        cB = _cB;
        emit UpdateCB(temp, cB);
    }

    function updateTotalLockedAmount(address _user) internal {
        uint256 totalLockedAmountInCakePool = ICakePool(CAKE_POOL).totalLockedAmount();
        (, , , , , , , , uint256 userLockedAmount) = ICakePool(CAKE_POOL).userInfo(_user);
        UserLockedInfo storage lockedInfo = userLockedInfos[_user];
        if (!lockedInfo.init) {
            lockedInfo.init = true;
            lockedInfo.lockedAmount = userLockedAmount;

            if (totalLockedAmountInCakePool >= latestTotalLockedAmountInCakePool) {
                totalLockedAmount += totalLockedAmountInCakePool - latestTotalLockedAmountInCakePool;
            } else {
                totalLockedAmount -= latestTotalLockedAmountInCakePool - totalLockedAmountInCakePool;
            }
        } else {
            totalLockedAmount = totalLockedAmount - lockedInfo.lockedAmount + userLockedAmount;
            lockedInfo.lockedAmount = userLockedAmount;
        }
        latestTotalLockedAmountInCakePool = totalLockedAmountInCakePool;
    }

    /// @notice Cakepool operation(deposit/withdraw) automatically call this function.
    /// @param _user user address.
    /// @param _lockedAmount user locked amount in cake pool.
    /// @param _lockedDuration user locked duration in cake pool.
    /// @param _totalLockedAmount Total locked cake amount in cake pool.
    /// @param _maxLockDuration maximum locked duration in cake pool.
    function onCakePoolUpdate(
        address _user,
        uint256 _lockedAmount,
        uint256 _lockedDuration,
        uint256 _totalLockedAmount,
        uint256 _maxLockDuration
    ) external onlyCakePool {
        updateTotalLockedAmount(_user);
        ItMap storage itmap = userInfo[_user];
        uint256 avgDuration;
        bool flag;
        for (uint256 i = 0; i < itmap.keys.length; i++) {
            uint256 tokenId = itmap.keys[i];
            if (!flag) {
                avgDuration = avgLockDuration();
                flag = true;
            }
            (uint128 liquidity, , , , , address user, uint256 pid, , ) = MASTER_CHEF_V3.userPositionInfos(tokenId);
            if (_user == user) _updateBoostMultiplier(itmap, user, pid, tokenId, avgDuration, liquidity);
        }

        emit UpdateCakePool(_user, _lockedAmount, _lockedDuration, _totalLockedAmount, _maxLockDuration);
    }

    /// @notice Update user boost multiplier,only for MasterChef V3.
    /// @param _tokenId Token Id of position NFT.
    function updatePositionBoostMultiplier(uint256 _tokenId) external onlyMasterChefV3 returns (uint256 _multiplier) {
        (uint128 liquidity, , , , , address user, uint256 pid, , ) = MASTER_CHEF_V3.userPositionInfos(_tokenId);
        ItMap storage itmap = userInfo[user];
        if (!whiteList[pid]) {
            _multiplier = BOOST_PRECISION;
            if (itmap.contains(_tokenId)) {
                itmap.remove(_tokenId);
            }
        } else {
            _multiplier = _boostCalculate(user, pid, avgLockDuration(), uint256(liquidity));
            itmap.insert(_tokenId, _multiplier);
        }
    }

    /// @notice Remove user boost multiplier when user withdraw or butn in MasterChef,only for MasterChef V3.
    /// @param _tokenId Token Id of position NFT.
    function removeBoostMultiplier(uint256 _tokenId) external onlyMasterChefV3 {
        (, , , , , address user, , , ) = MASTER_CHEF_V3.userPositionInfos(_tokenId);
        ItMap storage itmap = userInfo[user];
        itmap.remove(_tokenId);
    }

    /// @notice Active user farm pool.
    /// @param _tokenId Token Id of position NFT.
    function activate(uint256 _tokenId) external {
        (uint128 liquidity, , , , , address user, uint256 pid, , ) = MASTER_CHEF_V3.userPositionInfos(_tokenId);
        require(whiteList[pid], 'Not boosted farm pool');
        require(user == msg.sender, 'Not owner');
        ItMap storage itmap = userInfo[user];
        require(!itmap.contains(_tokenId), 'Already boosted');
        require(itmap.keys.length < MAX_BOOST_POSITION, 'Boosted positions reach to MAX');

        _updateBoostMultiplier(itmap, user, pid, _tokenId, avgLockDuration(), uint256(liquidity));

        emit ActiveFarmPool(user, pid, _tokenId);
    }

    /// @notice Deactive user farm pool.
    /// @param _tokenId Token Id of position NFT.
    function deactive(uint256 _tokenId) external {
        ItMap storage itmap = userInfo[msg.sender];
        require(itmap.contains(_tokenId), 'None boost user');

        if (itmap.data[_tokenId] > BOOST_PRECISION) {
            MASTER_CHEF_V3.updateBoostMultiplier(_tokenId, BOOST_PRECISION);
        }
        itmap.remove(_tokenId);

        (, , , , , , uint256 pid, , ) = MASTER_CHEF_V3.userPositionInfos(_tokenId);
        emit DeactiveFarmPool(msg.sender, pid, _tokenId);
    }

    /// @param _user user address.
    /// @param _pid pool id.
    /// @param _tokenId token id.
    /// @param _duration cake pool average locked duration.
    /// @param _liquidity position liquidity.
    function _updateBoostMultiplier(
        ItMap storage itmap,
        address _user,
        uint256 _pid,
        uint256 _tokenId,
        uint256 _duration,
        uint256 _liquidity
    ) internal {
        // ItMap storage itmap = userInfo[_user];

        // Used to be boost farm pool and current is not, remove from mapping
        if (!whiteList[_pid]) {
            if (itmap.data[_tokenId] > BOOST_PRECISION) {
                // reset to BOOST_PRECISION
                MASTER_CHEF_V3.updateBoostMultiplier(_tokenId, BOOST_PRECISION);
            }
            itmap.remove(_tokenId);
            return;
        }

        (, , , , , , , uint256 prevMultiplier, ) = MASTER_CHEF_V3.userPositionInfos(_tokenId);
        uint256 multiplier = _boostCalculate(_user, _pid, _duration, _liquidity);

        if (multiplier < BOOST_PRECISION) {
            multiplier = BOOST_PRECISION;
        } else if (multiplier > MAX_BOOST_PRECISION) {
            multiplier = MAX_BOOST_PRECISION;
        }

        // Update multiplier to MCV3
        if (multiplier != prevMultiplier) {
            MASTER_CHEF_V3.updateBoostMultiplier(_tokenId, multiplier);
        }
        itmap.insert(_tokenId, multiplier);

        emit UpdatePoolBoostMultiplier(_user, _pid, _tokenId, prevMultiplier, multiplier);
    }

    /// @notice Whether position boosted specific farm pool.
    /// @param _tokenId Token Id of position NFT.
    function isBoostedPool(uint256 _tokenId) external view returns (bool, uint256) {
        (, , , , , address user, uint256 pid, , ) = MASTER_CHEF_V3.userPositionInfos(_tokenId);
        return (userInfo[user].contains(_tokenId), pid);
    }

    /// @notice Actived position list.
    /// @param _user user address.
    function activedPositions(address _user) external view returns (uint256[] memory positions) {
        ItMap storage itmap = userInfo[_user];
        if (itmap.keys.length == 0) return positions;

        positions = new uint256[](itmap.keys.length);
        // solidity for-loop not support multiple variables initializae by "," separate.
        uint256 i;
        for (uint256 index = 0; index < itmap.keys.length; index++) {
            uint256 tokenId = itmap.keys[index];
            positions[i] = tokenId;
            i++;
        }
    }

    /// @notice Anyone can call this function, if you find some guys effectived multiplier is not fair
    /// for other users, just call "refresh" function.
    /// @param _tokenId Token Id of position NFT.
    /// @dev If return value not in range [BOOST_PRECISION, MAX_BOOST_PRECISION]
    /// the actual effectived multiplier will be the close to side boundry value.
    function getUserMultiplier(uint256 _tokenId) external view returns (uint256) {
        (uint128 liquidity, , , , , address user, uint256 pid, , ) = MASTER_CHEF_V3.userPositionInfos(_tokenId);
        if (!whiteList[pid]) {
            return BOOST_PRECISION;
        } else {
            return _boostCalculate(user, pid, avgLockDuration(), uint256(liquidity));
        }
    }

    /// @notice cake pool average locked duration calculator.
    function avgLockDuration() public view returns (uint256) {
        uint256 totalStakedAmount = IERC20(CAKE).balanceOf(CAKE_POOL);

        // uint256 totalLockedAmount = ICakePool(CAKE_POOL).totalLockedAmount();

        uint256 pricePerFullShare = ICakePool(CAKE_POOL).getPricePerFullShare();

        uint256 flexibleShares;
        if (totalStakedAmount > totalLockedAmount)
            flexibleShares = ((totalStakedAmount - totalLockedAmount) * 1e18) / pricePerFullShare;
        if (flexibleShares == 0) return 0;

        uint256 originalShares = (totalLockedAmount * 1e18) / pricePerFullShare;
        if (originalShares == 0) return 0;

        uint256 boostedRatio = ((ICakePool(CAKE_POOL).totalShares() - flexibleShares) * BOOST_RATIO_PRECISION) /
            originalShares;
        if (boostedRatio <= BOOST_RATIO_PRECISION) return 0;

        uint256 boostWeight = ICakePool(CAKE_POOL).BOOST_WEIGHT();
        uint256 maxLockDuration = ICakePool(CAKE_POOL).MAX_LOCK_DURATION() * BOOST_RATIO_PRECISION;

        uint256 duration = ((boostedRatio - BOOST_RATIO_PRECISION) * 365 * BOOST_WEIGHT_PRECISION) / boostWeight;
        return duration <= maxLockDuration ? duration : maxLockDuration;
    }

    /// @param _user user address.
    /// @param _pid pool id(MasterchefV3 pool).
    /// @param _duration cake pool average locked duration.
    /// @param _liquidity position liquidity.
    function _boostCalculate(
        address _user,
        uint256 _pid,
        uint256 _duration,
        uint256 _liquidity
    ) internal view returns (uint256) {
        if (_duration == 0) return BOOST_PRECISION;

        uint256 dB = (cA * _liquidity) / CA_PRECISION;
        // dB == 0 means _liquidity close to 0
        if (_liquidity == 0 || dB == 0) return BOOST_PRECISION;

        (, , , , uint256 lockStartTime, uint256 lockEndTime, , , uint256 userLockedAmount) = ICakePool(CAKE_POOL)
            .userInfo(_user);
        if (userLockedAmount == 0 || block.timestamp >= lockEndTime) return BOOST_PRECISION;

        // userLockedAmount > 0 means totalLockedAmount > 0
        // uint256 totalLockedAmount = ICakePool(CAKE_POOL).totalLockedAmount();

        (, , , , , , uint256 totalLiquidity, ) = MASTER_CHEF_V3.poolInfo(_pid);
        uint256 userLockedDuration = (lockEndTime - lockStartTime) / (3600 * 24); // days

        uint256 aB = (((totalLiquidity * userLockedAmount * userLockedDuration) * BOOST_RATIO_PRECISION) / cB) /
            (totalLockedAmount * _duration);

        // should "*" BOOST_PRECISION
        return ((_liquidity < (dB + aB) ? _liquidity : (dB + aB)) * BOOST_PRECISION) / dB;
    }

    /// @notice Checks if address is a contract
    /// @dev It prevents contract from being targetted
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICakePool {
    function userInfo(
        address _user
    ) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, bool, uint256);

    function getPricePerFullShare() external view returns (uint256);

    function totalLockedAmount() external view returns (uint256);

    function totalShares() external view returns (uint256);

    function BOOST_WEIGHT() external view returns (uint256);

    function MAX_LOCK_DURATION() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IMasterChefV3 {
    function userPositionInfos(
        uint256 _tokenId
    ) external view returns (uint128, int24, int24, uint256, uint256, address, uint256, uint256, uint256);

    function poolInfo(
        uint256 _pid
    ) external view returns (uint256, address, address, address, address, uint24, uint256, uint256);

    function getBoostMultiplier(address _user, uint256 _pid) external view returns (uint256);

    function updateBoostMultiplier(uint256 _tokenId, uint256 _newMultiplier) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

struct ItMap {
    // pid => boost
    mapping(uint256 => uint256) data;
    // pid => index
    mapping(uint256 => uint256) indexs;
    // array of pid
    uint256[] keys;
    // never use it, just for keep compile success.
    uint256 size;
}

library IterableMapping {
    function insert(ItMap storage self, uint256 key, uint256 value) internal {
        uint256 keyIndex = self.indexs[key];
        self.data[key] = value;
        if (keyIndex > 0) return;
        else {
            self.indexs[key] = self.keys.length + 1;
            self.keys.push(key);
            return;
        }
    }

    function remove(ItMap storage self, uint256 key) internal {
        uint256 index = self.indexs[key];
        if (index == 0) return;
        uint256 lastKey = self.keys[self.keys.length - 1];
        if (key != lastKey) {
            self.keys[index - 1] = lastKey;
            self.indexs[lastKey] = index;
        }
        delete self.data[key];
        delete self.indexs[key];
        self.keys.pop();
    }

    function contains(ItMap storage self, uint256 key) internal view returns (bool) {
        return self.indexs[key] > 0;
    }
}