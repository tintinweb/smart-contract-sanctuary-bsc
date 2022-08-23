//** Decubate NFT Staking Contract */
//** Author : Aceson */

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC721EnumerableUpgradeable.sol";
import "./interfaces/IStaking.sol";

contract DCBNFTStaking is Initializable, OwnableUpgradeable, IStaking, IERC721ReceiverUpgradeable {
  using SafeMathUpgradeable for uint256;

  /**
   * Pool Struct
   */
  struct PoolExtended {
    Pool common;
    string name;
    string logo;
    string headerLogo;
    string collection;
    uint32 startIdx;
    uint32 endIdx;
    uint32 maxPerUser;
    uint32[] depositedIds;
    mapping(uint256 => uint256) idToArrayIdx;
  }

  struct PoolInfo {
    Pool common;
    string name;
    string logo;
    string headerLogo;
    string collection;
    uint32 startIdx;
    uint32 endIdx;
    uint32 maxPerUser;
    uint32[] depositedIds;
  }

  struct UserExtended {
    User common;
    uint32[] depositedIds;
    mapping(uint256 => uint256) idToArrayIdx;
  }

  PoolExtended[] public poolExt;
  Multiplier[] public multipliers;

  mapping(uint256 => mapping(address => UserExtended)) public userExt;

  event Stake(address indexed user, uint16 _pid, uint32[] indexed ids, uint256 time);
  event ReStake(uint16 _pid, address user, uint256 timestamp);
  event Unstake(address indexed user, uint16 _pid, uint32[] indexed ids, uint256 time);

  function initialize() external initializer {
    __Ownable_init();
  }

  function add(
    bool _isWithdrawLocked,
    uint128 _rewardRate,
    uint16 _lockPeriodInDays,
    uint32 _endDate,
    uint256 _hardCap,
    address _input,
    address _reward
  ) external onlyOwner {
    PoolExtended storage pool = poolExt.push();

    pool.common.isWithdrawLocked = _isWithdrawLocked;
    pool.common.rewardRate = _rewardRate;
    pool.common.lockPeriodInDays = _lockPeriodInDays;
    pool.common.startDate = uint32(block.timestamp);
    pool.common.endDate = _endDate;
    pool.common.hardCap = _hardCap;
    pool.common.input = _input;
    pool.common.reward = _reward;

    multipliers.push(
      Multiplier({ active: false, name: "", contractAdd: address(0), start: 0, end: 0, multi: 100 })
    );
  }

  function set(
    uint16 _pid,
    bool _isWithdrawLocked,
    uint128 _rewardRate,
    uint16 _lockPeriodInDays,
    uint32 _endDate,
    uint256 _hardCap,
    address _input,
    address _reward
  ) external onlyOwner {
    PoolExtended storage pool = poolExt[_pid];

    pool.common.isWithdrawLocked = _isWithdrawLocked;
    pool.common.rewardRate = _rewardRate;
    pool.common.lockPeriodInDays = _lockPeriodInDays;
    pool.common.endDate = _endDate;
    pool.common.hardCap = _hardCap;
    pool.common.input = _input;
    pool.common.reward = _reward;
  }

  function setMultiplier(
    uint16 _pid,
    string calldata _name,
    address _contractAdd,
    bool _isUsed,
    uint16 _multiplier,
    uint128 _start,
    uint128 _end
  ) external onlyOwner {
    Multiplier storage multiplier = multipliers[_pid];

    multiplier.name = _name;
    multiplier.contractAdd = _contractAdd;
    multiplier.active = _isUsed;
    multiplier.multi = _multiplier;
    multiplier.start = _start;
    multiplier.end = _end;
  }

  function setNFTInfo(
    uint16 _pid,
    string memory _name,
    string memory _logo,
    string memory _headerLogo,
    string memory _collection,
    uint32 _startIdx,
    uint32 _endIdx,
    uint32 _maxPerUser
  ) external onlyOwner {
    PoolExtended storage pool = poolExt[_pid];

    pool.name = _name;
    pool.logo = _logo;
    pool.headerLogo = _headerLogo;
    pool.collection = _collection;
    pool.startIdx = _startIdx;
    pool.endIdx = _endIdx;
    pool.maxPerUser = _maxPerUser;
  }

  function stake(uint16 _pid, uint32[] calldata _ids) external {
    PoolExtended storage pool = poolExt[_pid];
    UserExtended storage user = userExt[_pid][msg.sender];

    uint256 stopDepo = pool.common.endDate - (pool.common.lockPeriodInDays * 1 days);
    require(block.timestamp <= stopDepo, "DCB : Staking is disabled for this pool");
    uint256 len = _ids.length;
    require(user.common.totalInvested + len <= pool.maxPerUser, "DCB : Max per user exceeding");
    require(pool.common.totalInvested + len <= pool.common.hardCap, "DCB : Pool is full");

    _claim(_pid, msg.sender);

    IERC721Upgradeable nft = IERC721Upgradeable(pool.common.input);
    uint256 poolLen = pool.depositedIds.length;
    uint256 userLen = user.depositedIds.length;
    uint32 id;

    for (uint256 i = 0; i < len; ) {
      id = _ids[i];
      require(id >= pool.startIdx && id <= pool.endIdx, "DCB : Invalid NFT");
      nft.safeTransferFrom(msg.sender, address(this), id);
      pool.depositedIds.push(id);
      pool.idToArrayIdx[id] = poolLen + i;
      user.depositedIds.push(id);
      user.idToArrayIdx[id] = userLen + i;
      unchecked {
        i++;
      }
    }
    unchecked {
      if (user.common.totalInvested == 0) {
        pool.common.totalInvestors++;
      }
      user.common.totalInvested = user.common.totalInvested + len;
      pool.common.totalInvested = pool.common.totalInvested + len;
      user.common.lastPayout = uint32(block.timestamp);
      user.common.depositTime = uint32(block.timestamp);
    }

    emit Stake(msg.sender, _pid, _ids, block.timestamp);
  }

  function claim(uint16 _pid) external returns (bool) {
    bool status = _claim(_pid, msg.sender);

    require(status, "DCB : Claim not unlocked");

    return true;
  }

  function claimAll() external returns (bool) {
    uint256 len = poolExt.length;

    for (uint16 pid = 0; pid < len; ) {
      _claim(pid, msg.sender);
      unchecked {
        ++pid;
      }
    }

    return true;
  }

  function claimAndRestake(uint16 _pid) external {
    Pool memory pool = poolExt[_pid].common;
    User storage user = userExt[_pid][msg.sender].common;

    uint256 stopDepo = pool.endDate - (pool.lockPeriodInDays * 1 days);
    require(block.timestamp <= stopDepo, "DCB : Staking is disabled for this pool");

    bool status = _claim(_pid, msg.sender);
    require(status, "DCB : Claim still locked");

    user.lastPayout = uint32(block.timestamp);
    user.depositTime = uint32(block.timestamp);

    emit ReStake(_pid, msg.sender, block.timestamp);
  }

  function unStake(uint16 _pid, uint32[] calldata _ids) external {
    UserExtended storage user = userExt[_pid][msg.sender];
    PoolExtended storage pool = poolExt[_pid];

    if (pool.common.isWithdrawLocked) {
      require(canClaim(_pid, msg.sender), "DCB : Stake still in locked state");
    }

    uint256 len = _ids.length;
    uint256 poolLen = pool.depositedIds.length;
    uint256 userLen = user.depositedIds.length;

    require(userLen >= len, "DCB : Deposit/Withdraw Mismatch");

    _claim(_pid, msg.sender);

    IERC721Upgradeable nft = IERC721Upgradeable(pool.common.input);

    for (uint256 i = 0; i < len; ) {
      uint32 id = _ids[i];
      require(
        user.idToArrayIdx[id] != 0 || user.depositedIds[0] == id,
        "DCB : Not staked by caller"
      );
      nft.safeTransferFrom(address(this), msg.sender, id);

      uint256 idx = user.idToArrayIdx[id];
      uint32 last = user.depositedIds[userLen - i - 1];
      user.depositedIds[idx] = last;
      user.idToArrayIdx[last] = idx;
      user.depositedIds.pop();
      user.idToArrayIdx[id] = 0;

      idx = pool.idToArrayIdx[id];
      last = pool.depositedIds[poolLen - i - 1];
      pool.depositedIds[idx] = last;
      pool.idToArrayIdx[last] = idx;
      pool.depositedIds.pop();
      pool.idToArrayIdx[id] = 0;

      unchecked {
        i++;
      }
    }

    unchecked {
      user.common.totalWithdrawn = user.common.totalWithdrawn + len;
      user.common.totalInvested = user.common.totalInvested - len;
      pool.common.totalInvested = pool.common.totalInvested - len;
      if (user.common.totalInvested == 0) {
        pool.common.totalInvestors--;
      }
      user.common.lastPayout = uint32(block.timestamp);
    }

    emit Unstake(msg.sender, _pid, _ids, block.timestamp);
  }

  function transferStuckToken(address _token) external onlyOwner returns (bool) {
    IERC20Upgradeable token = IERC20Upgradeable(_token);
    uint256 balance = token.balanceOf(address(this));
    token.transfer(owner(), balance);

    return true;
  }

  function transferStuckNFT(address _nft, uint256 _id) external onlyOwner returns (bool) {
    IERC721Upgradeable nft = IERC721Upgradeable(_nft);
    nft.safeTransferFrom(address(this), owner(), _id);

    return true;
  }

  function poolLength() external view override returns (uint256) {
    return poolExt.length;
  }

  function getPools() external view returns (PoolInfo[] memory pools) {
    pools = new PoolInfo[](poolExt.length);

    for (uint256 i = 0; i < poolExt.length; i++) {
      pools[i].common = poolExt[i].common;
      pools[i].name = poolExt[i].name;
      pools[i].logo = poolExt[i].logo;
      pools[i].headerLogo = poolExt[i].headerLogo;
      pools[i].collection = poolExt[i].collection;
      pools[i].startIdx = poolExt[i].startIdx;
      pools[i].endIdx = poolExt[i].endIdx;
      pools[i].maxPerUser = poolExt[i].maxPerUser;
      pools[i].depositedIds = poolExt[i].depositedIds;
    }
  }

  /**
   *
   *
   * @dev Fetching relevant nfts owned by a user
   *
   */
  function walletOfOwner(uint256 _pid, address _owner) external view returns (uint256[] memory) {
    PoolExtended storage pool = poolExt[_pid];
    IERC721EnumerableUpgradeable nft = IERC721EnumerableUpgradeable(pool.common.input);
    uint256 tokenCount = nft.balanceOf(_owner);
    uint256 id;

    uint256[] memory tokensId = new uint256[](tokenCount);
    uint256 count;
    for (uint256 i; i < tokenCount; i++) {
      id = nft.tokenOfOwnerByIndex(_owner, i);
      if (id >= pool.startIdx && id <= pool.endIdx) {
        tokensId[count] = id;
        count++;
      }
    }

    uint256[] memory validIds = new uint256[](count);
    for (uint256 i; i < count; i++) {
      validIds[i] = tokensId[i];
    }

    return validIds;
  }

  function getDepositedIdsOfPool(uint16 _pid) external view returns (uint32[] memory) {
    return poolExt[_pid].depositedIds;
  }

  function getDepositedIdsOfUser(uint16 _pid, address _user)
    external
    view
    returns (uint32[] memory)
  {
    return userExt[_pid][_user].depositedIds;
  }

  // function getIndexOfIdUser(
  //   uint16 _pid,
  //   address _user,
  //   uint256[] memory ids
  // ) external view returns (uint256[] memory idx) {
  //   UserExtended storage user = userExt[_pid][_user];
  //   idx = new uint256[](ids.length);
  //   for (uint256 i = 0; i < ids.length; i++) {
  //     idx[i] = user.idToArrayIdx[ids[i]];
  //   }
  // }

  // function getIndexOfIdPool(uint16 _pid, uint256[] memory ids)
  //   external
  //   view
  //   returns (uint256[] memory idx)
  // {
  //   idx = new uint256[](ids.length);
  //   for (uint256 i = 0; i < ids.length; i++) {
  //     idx[i] = poolExt[_pid].idToArrayIdx[ids[i]];
  //   }
  // }

  /** Always returns `IERC721Receiver.onERC721Received.selector`. */
  function onERC721Received(
    address,
    address,
    uint256,
    bytes memory
  ) public virtual override returns (bytes4) {
    return this.onERC721Received.selector;
  }

  function canClaim(uint16 _pid, address _addr) public view returns (bool) {
    User memory user = userExt[_pid][_addr].common;
    Pool memory pool = poolExt[_pid].common;

    return (block.timestamp >= user.depositTime + (pool.lockPeriodInDays * 1 days));
  }

  function payout(uint16 _pid, address _addr) public view returns (uint256 value) {
    User memory user = userExt[_pid][_addr].common;
    Pool memory pool = poolExt[_pid].common;

    uint256 from = user.lastPayout > user.depositTime ? user.lastPayout : user.depositTime;
    uint256 userTime = block.timestamp > (user.depositTime + (pool.lockPeriodInDays * 1 days))
      ? (user.depositTime + (pool.lockPeriodInDays * 1 days))
      : block.timestamp;
    uint256 to = userTime > pool.endDate ? pool.endDate : userTime;

    if (to > from) {
      value = (to.sub(from)).mul(pool.rewardRate).mul(user.totalInvested).div(1 days);
      uint256 multiplier = calcMultiplier(_pid, _addr);
      value = value.mul(multiplier).div(100);
    }
  }

  /**
   *
   * @dev Return multiplier value for user
   *
   * @param _pid  id of the pool
   * @param _addr address of the user
   *
   * @return multi Value of multiplier
   *
   */

  function calcMultiplier(uint16 _pid, address _addr) public view override returns (uint16 multi) {
    Multiplier memory multiplier = multipliers[_pid];

    if (multiplier.active && ownsCorrectMulti(_pid, _addr)) {
      multi = multiplier.multi;
    } else {
      multi = 100;
    }
  }

  /**
   *
   * @dev check if user have multiplier
   *
   * @param _pid  id of the pool
   * @param _addr address of the user
   *
   * @return Status of multiplier
   *
   */
  function ownsCorrectMulti(uint16 _pid, address _addr) public view override returns (bool) {
    return
      IERC20Upgradeable(multipliers[_pid].contractAdd).balanceOf(_addr) >= multipliers[_pid].start;
  }

  function _claim(uint16 _pid, address _user) internal returns (bool) {
    Pool storage pool = poolExt[_pid].common;
    User storage user = userExt[_pid][_user].common;

    if (!canClaim(_pid, _user)) {
      return false;
    }

    uint256 amount = payout(_pid, _user);

    if (amount > 0) {
      _safeTOKENTransfer(pool.reward, _user, amount);

      user.totalClaimed = user.totalClaimed.add(amount);
    }

    user.lastPayout = uint32(block.timestamp);

    emit Claim(_pid, _user, amount, block.timestamp);

    return true;
  }

  function _safeTOKENTransfer(
    address _token,
    address _to,
    uint256 _amount
  ) internal {
    IERC20Upgradeable token = IERC20Upgradeable(_token);
    uint256 bal = token.balanceOf(address(this));
    require(bal >= _amount, "DCB : Not enough funds in treasury");
    token.transfer(_to, _amount);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IStaking {
  struct Multiplier {
    string name;
    address contractAdd;
    bool active;
    uint16 multi;
    uint128 start;
    uint128 end;
  }

  struct User {
    uint256 totalInvested;
    uint256 totalWithdrawn;
    uint32 lastPayout;
    uint32 depositTime;
    uint256 totalClaimed;
  }

  struct Pool {
    bool isWithdrawLocked;
    uint128 rewardRate;
    uint16 lockPeriodInDays;
    uint32 totalInvestors;
    uint32 startDate;
    uint32 endDate;
    uint256 totalInvested;
    uint256 hardCap;
    address input;
    address reward;
  }

  event Claim(uint16 pid, address indexed addr, uint256 amount, uint256 time);

  function setMultiplier(
    uint16 _pid,
    string calldata _name,
    address _contractAdd,
    bool _isUsed,
    uint16 _multiplier,
    uint128 _startIdx,
    uint128 _endIdx
  ) external;

  function add(
    bool _isWithdrawLocked,
    uint128 _rewardRate,
    uint16 _lockPeriodInDays,
    uint32 _endDate,
    uint256 _hardCap,
    address _inputToken,
    address _rewardToken
  ) external;

  function set(
    uint16 _pid,
    bool _isWithdrawLocked,
    uint128 _rewardRate,
    uint16 _lockPeriodInDays,
    uint32 _endDate,
    uint256 _hardCap,
    address _inputToken,
    address _rewardToken
  ) external;

  function claim(uint16 _pid) external returns (bool);

  function claimAll() external returns (bool);

  function transferStuckNFT(address _nft, uint256 _id) external returns (bool);

  function transferStuckToken(address _token) external returns (bool);

  function canClaim(uint16 _pid, address _addr) external view returns (bool);

  function calcMultiplier(uint16 _pid, address _addr) external view returns (uint16);

  function ownsCorrectMulti(uint16 _pid, address _addr) external view returns (bool);

  function poolLength() external view returns (uint256);

  function payout(uint16 _pid, address _addr) external view returns (uint256 value);
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
library SafeMathUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Receiver.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721ReceiverUpgradeable.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20Upgradeable.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}