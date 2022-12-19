/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier: GNU GPLv3

pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

library SafeMath {
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);

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

contract NabanaVesting is Ownable {
    using SafeMath for uint256;

    IERC20 public nabana;

    uint256 public currentInterval;
    uint256 public immutable maxInterval;

    uint256 public unlockTimeLast;
    uint256 public immutable unlockIntervalTime;

    bool public vestState;

    // addresses for vesting
    address private constant managementAllocationWallet = 0x49E695A35bd65C735BB2b0033e77205b4C8cf02c;
    address private constant advisorsWallet = 0x20027f3D87D107d7a5A304A940f3A63F98E67298;
    address private constant influencersWallet = 0x3d574DE90E80b9Ce7CC48aC9520bDC9d19e549E4;
    address private constant strategicPartnersWallet = 0xA0f77506698e9e2F5919fbbC76c362a0e41555f3;
    address private constant rewardsIncentivesWallet = 0xa9E8627F2c78992de6aF3c76120625930E1A826F;
    address private constant reserveWallet = 0xFA38bFA8D5f3B4FB2E3B410F86a27776Ab3AAb4d;

    // structs

    struct Vesting {
        address vester;
        uint256 amountToUnlock;
        uint256 percentageToUnlock;
        uint256 lockupIntervals;
        uint256 vestingIntervals;
        uint256 totalIntervals;
    }

    // mappings

    // vesting information
    mapping (address => Vesting) public getVestings;

    // addresses with permission to access certain Vesting functions
    mapping (address => bool) public permitted;

    // events

    event ClaimedVesting(address vester, uint256 unlockInterval, uint256 unlockAmount, uint256 timestamp);

    constructor() {
        currentInterval = 0;
        maxInterval = 62;

        unlockTimeLast = block.timestamp;
        unlockIntervalTime = 30 days;

        // distribution of tokens to vesters
        getVestings[managementAllocationWallet] = Vesting(managementAllocationWallet, 5_000_000 * (10 ** 18), 4, 36, 25, 61);
        getVestings[advisorsWallet] = Vesting(advisorsWallet, 1_000_000 * (10 ** 18), 2, 12, 50, 62);
        getVestings[influencersWallet] = Vesting(influencersWallet, 1_000_000 * (10 ** 18), 4, 6, 25, 31);
        getVestings[strategicPartnersWallet] = Vesting(strategicPartnersWallet, 3_000_000 * (10 ** 18), 4, 6, 25, 31);
        getVestings[rewardsIncentivesWallet] = Vesting(rewardsIncentivesWallet, 5_000_000 * (10 ** 18), 100, 2, 1, 3);
        getVestings[reserveWallet] = Vesting(reserveWallet, 5_000_000 * (10 ** 18), 4, 12, 25, 37);
    }

    function updateNabana(address _nabana) external onlyOwner {
        require(address(nabana) != _nabana, "NabanaVesting: Nabana is already this address");
        nabana = IERC20(_nabana);
    }

    function updateVestingState(bool _vestState) external onlyOwner {
        require(vestState != _vestState, "NabanaVesting: Stake State is already of this state");
        vestState = _vestState;
    }

    function updatePermission(address _vester, bool _state) external onlyOwner {
        require(permitted[_vester] != _state, "NabanaVesting: Address is already of this state");
        permitted[_vester] = _state;
    }

    function updatePermissionForAllVesters(bool _state) external onlyOwner {
        permitted[managementAllocationWallet] = _state;
        permitted[advisorsWallet] = _state;
        permitted[influencersWallet] = _state;
        permitted[strategicPartnersWallet] = _state;
        permitted[rewardsIncentivesWallet] = _state;
        permitted[reserveWallet] = _state;
    }

    function _claimVesting(address _walletAddress, uint256 _timestamp, uint256 _unlockValidator) internal returns (uint256) {
        Vesting memory vesting = getVestings[_walletAddress];

        if (currentInterval < vesting.lockupIntervals) {
            _unlockValidator++;
        }
        else {
            if (currentInterval < vesting.totalIntervals) {
                uint256 unlockAmount = vesting.amountToUnlock.mul(vesting.percentageToUnlock).div(100);

                _unlockValidator++;

                nabana.transfer(vesting.vester, unlockAmount);

                emit ClaimedVesting(vesting.vester, currentInterval, unlockAmount, _timestamp);
            }
        }

        return _unlockValidator;
    }

    function claimVestings() external vestActive permission {
        uint256 timestamp = block.timestamp;

        require(timestamp > unlockTimeLast.add(unlockIntervalTime), "NabanaVesting: No unlocks currently available");
        require(currentInterval < maxInterval, "NabanaVesting: Vesting complete");

        uint256 unlockValidator;

        unlockValidator = _claimVesting(managementAllocationWallet, timestamp, unlockValidator);

        unlockValidator = _claimVesting(advisorsWallet, timestamp, unlockValidator);

        unlockValidator = _claimVesting(influencersWallet, timestamp, unlockValidator);

        unlockValidator = _claimVesting(strategicPartnersWallet, timestamp, unlockValidator);

        unlockValidator = _claimVesting(rewardsIncentivesWallet, timestamp, unlockValidator);

        unlockValidator = _claimVesting(reserveWallet, timestamp, unlockValidator);

        if (unlockValidator != 0) {
            currentInterval++;

            unlockTimeLast += unlockIntervalTime;
        }
    }

    function emergencyWithdraw() external onlyOwner {
        nabana.transfer(owner(), nabana.balanceOf(address(this)));
    }

    // modifiers

    modifier vestActive() {
        require(vestState, "NabanaVesting: Vesting not yet started");
        _;
    }

    modifier permission() {
        require(permitted[msg.sender] || msg.sender == owner(), "NabanaVesting: Not permitted");
        _;
    }
}