// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6;

interface IASDICCard {
     function mint(address to, uint16 cardType) external returns (uint256);

     function batchByAmountMint(
        address to,
        uint16 _type,
        uint256 _num
    ) external returns (uint256[] memory);

     function safeBatchTransferFrom(address from, address to,
        uint256[] memory tokenIds) external;

        function _cardType(uint256 tokenId) external view returns(uint16);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function mint(address recipient, uint256 amount) external;

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
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./TokenFreed.sol";
import "../interfaces/IASDICCard.sol";

contract SunPool is TokenFreed {
    using SafeMath for uint256;

    IASDICCard public card;
    uint256 public level;
    uint256 private _totalSupply;
    uint256 public initreward;
    uint256 public starttime;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public donateAmount;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public stakeTime;
    mapping(address => uint256[]) public nftOwner;
    mapping(address => uint256) public aAmount;
    event RewardAdded(uint256 reward);
    event Donate(address indexed user, uint256 amount);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    uint256 public constant DURATION = 30 days;

    constructor(
        uint256 _initreward,
        uint256 _starttme,
        IASDICCard _card
    ) {
        card = _card;
        initreward = _initreward;
        starttime = _starttme;
        starts = _starttme;
        period = starttime;
        lastUpdateTime = starttime;
        periodFinish = lastUpdateTime;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function userCard(address account)
        external
        view
        returns (uint256[] memory)
    {
        return nftOwner[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp.add(_time), periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function onERC721ExReceived(
        address operator,
        address from,
        uint256[] memory tokenIds,
        bytes memory data
    ) external returns (bytes4) {
        for (uint256 index = 0; index != tokenIds.length; index++) {
            require(card._cardType(tokenIds[index]) == 1, "not type");
            nftOwner[from].push(tokenIds[index]);
        }
        _stake(from, tokenIds.length);
        return ERC721_RECEIVER_EX_RETURN;
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function _stake(address account, uint256 amount)
        internal
        updateReward(account)
        checkhalve
        checkStart
    {
        _totalSupply = _totalSupply.add(amount * 10**18);
        _balances[account] = _balances[account].add(amount * 10**18);
        emit Staked(account, amount);
    }

    function withdraw() public updateReward(msg.sender) checkhalve checkStart {
        uint256[] memory tokenIds = nftOwner[msg.sender];
        uint256 amount = tokenIds.length;
        require(amount != 0, "nft does not exist");

        card.safeBatchTransferFrom(address(this), msg.sender, tokenIds);
        nftOwner[msg.sender] = new uint256[](0);
        _totalSupply = _totalSupply.sub(amount * 10**18);
        _balances[msg.sender] = _balances[msg.sender].sub(amount * 10**18);
        emit Withdrawn(msg.sender, amount);
    }

    function donate(uint256 value)
        external
        updateReward(address(0))
        checkhalve
    {
        donateAmount = donateAmount.add(value);
        token.transferFrom(msg.sender, address(this), value);
        emit Donate(msg.sender, value);
    }

    function getReward() public updateReward(msg.sender) checkhalve checkStart {
        uint256 reward = earned(msg.sender);
        if (reward <= 0) return;

        rewards[msg.sender] = 0;
        token.mint(msg.sender, reward.mul(30).div(100));
        freed(reward.mul(70).div(100));
        aAmount[msg.sender] = aAmount[msg.sender].add(reward.mul(30).div(100));

        emit RewardPaid(msg.sender, reward);
    }

    uint256 public starts;
    uint256 public DURATION_N = 360 days;
    uint256 public period;

    function updateYear() public {
        if (block.timestamp.add(_time) >= period) {
            initreward = initreward.add(donateAmount).mul(50).div(100);
            donateAmount = 0;
            level = 1;

            if (block.timestamp.add(_time) > starts.add(DURATION_N)) {
                starts = starts.add(DURATION_N);
            }
            period = starts.add(DURATION_N);
            emit RewardAdded(initreward);
        }
    }

    modifier checkhalve() {
        if (block.timestamp.add(_time) >= periodFinish) {
            level = level.add(1);
            updateYear();

            if(level == 1) {
                rewardRate = initreward.mul(3).div(100).div(DURATION_N);
            } else if(level == 2) {
                rewardRate = initreward.mul(4).div(100).div(DURATION_N);
            } else if(level == 3) {
                rewardRate = initreward.mul(5).div(100).div(DURATION_N);
            } else if(level == 4) {
                rewardRate = initreward.mul(6).div(100).div(DURATION_N);
            } else if(level == 5) {
                rewardRate = initreward.mul(7).div(100).div(DURATION_N);
            } else if(level == 6) {
                rewardRate = initreward.mul(8).div(100).div(DURATION_N);
            } else if(level == 7) {
                rewardRate = initreward.mul(9).div(100).div(DURATION_N);
            } else if(level == 8) {
                rewardRate = initreward.mul(10).div(100).div(DURATION_N);
            } else if(level == 9) {
                rewardRate = initreward.mul(11).div(100).div(DURATION_N);
            } else if(level == 10) {
                rewardRate = initreward.mul(12).div(100).div(DURATION_N);
            } else if(level == 11) {
                rewardRate = initreward.mul(12).div(100).div(DURATION_N);
            } else if(level == 12) {
                rewardRate = initreward.mul(13).div(100).div(DURATION_N);
            }

            if (block.timestamp.add(_time) > starttime.add(DURATION)) {
                starttime = starttime.add(DURATION);
            }
            periodFinish = starttime.add(DURATION);
            emit RewardAdded(initreward);
        }
        _;
    }

    modifier checkStart() {
        require(block.timestamp.add(_time) > starttime, "not start");
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/Math.sol";

abstract contract TokenFreed is Ownable {
    using SafeMath for uint256;

    bytes4 internal constant ERC721_RECEIVER_EX_RETURN = 0x0f7b88e3;

    uint256 public constant UPGRADE_LOCK_DURATION = 60 * 60 * 24 * 365;

    struct LockedToken {
        uint256 locked;
        uint256 lockTime;
        int256 unlocked;
    }

    IERC20 public token;

    mapping(address => LockedToken) public upgradeLockedTokens;
    mapping(address => uint256) public alreadyAmount;

    uint256 public _time;

    function addDays(uint256 num) public onlyOwner {
        _time = _time.add(num.mul(86400));
    }

    function setToken(address _token) external onlyOwner {
        token = IERC20(_token);
    }

    function freed(uint256 _value) internal {
        LockedToken storage lt = upgradeLockedTokens[msg.sender];
        uint256 _now = block.timestamp.add(_time);
        if (_now < lt.lockTime + UPGRADE_LOCK_DURATION) {
            uint256 amount_ = (lt.locked * (_now - lt.lockTime)) /
                UPGRADE_LOCK_DURATION;
            lt.locked = lt.locked - amount_ + _value;
            lt.unlocked += int256(amount_);
        } else {
            lt.unlocked += int256(lt.locked);
            lt.locked = _value;
        }

        lt.lockTime = _now;
    }

    function pending(address _account) external view returns (uint256) {
        LockedToken memory lt = upgradeLockedTokens[_account];
        int256 available = lt.unlocked;
        uint256 _now = block.timestamp.add(_time);

        if (_now < lt.lockTime + UPGRADE_LOCK_DURATION) {
            available += int256(
                (lt.locked * (_now - lt.lockTime)) / UPGRADE_LOCK_DURATION
            );
        } else {
            available += int256(lt.locked);
        }
        return uint256(available);
    }

    function receiveReward() external {
        LockedToken storage lt = upgradeLockedTokens[msg.sender];
        int256 available = lt.unlocked;
        uint256 _now = block.timestamp.add(_time);

        if (_now < lt.lockTime + UPGRADE_LOCK_DURATION) {
            available += int256(
                (lt.locked * (_now - lt.lockTime)) / UPGRADE_LOCK_DURATION
            );
        } else {
            available += int256(lt.locked);
        }

        require(available > 0, "no token available");
        lt.unlocked -= available;

        alreadyAmount[msg.sender] = alreadyAmount[msg.sender].add(uint256(available));
        token.mint(msg.sender, uint256(available));
    }

}