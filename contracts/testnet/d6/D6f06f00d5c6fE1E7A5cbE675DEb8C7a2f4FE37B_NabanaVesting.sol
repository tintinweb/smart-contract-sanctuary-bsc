/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

pragma solidity ^0.8.10;
// SPDX-License-Identifier: GNU GPLv3

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

    uint256 public unlockTimeLast;
    uint256 public unlockInterval;

    bool public vestState;

    // addresses for lock
    address public pancakeSwapLaunchWallet;
    address public pinkSaleWallet;
    address public privateSaleWallet;
    address public managementAllocationWallet;
    address public advisorsWallet;
    address public influencersWallet;
    address public strategicPartnersWallet;
    address public bountyWallet;
    address public reserveWallet;
    address public supplyWallet;
    address public operationsWallet;

    // structs

    struct Vesting {
        address vester;
        uint256 totalAmount;
        uint256 totalIntervals;
        uint256 unlockInterval;
        uint256 percentageToUnlock;
    }

    // mappings

    // vesting information
    mapping (address => Vesting) public getVestings;

    // addresses with permission to access certain Vesting functions
    mapping (address => bool) public permitted;

    // events

    event DistributedVest(address vester, uint256 unlockInterval, uint256 unlockAmount, uint256 timestamp);

    constructor() {
        unlockTimeLast = block.timestamp;
        unlockInterval = 30 days;

        privateSaleWallet = 0x8f35Aa5fB354AaD8F5cBb98c62f25E76DC32D37D;
        managementAllocationWallet = 0x726704EC919CEAFb4c51b807e2Bc33B1a1e818F2;
        advisorsWallet = 0x8E4f7a8Ca048ddF7BB4bda8B853DF1770AC49660;
        influencersWallet = 0xDd5D35D9a781C8B3Ee3eA858b7b22AFD8CD44eA4;
        strategicPartnersWallet = 0x70d4bEf912a73A0D9fA07A1066bc49a745783D85;
        bountyWallet = 0x81ED33AC3875379ee1A0d4625E2230b1A013e77d;
        reserveWallet = 0x91Bc6E15b7786480107413833C2e230631A77413;
        operationsWallet = 0x45faf7923BAb5A5380515E055CA700519B3e4705;

        // distribution of tokens to vesters
        getVestings[privateSaleWallet] = Vesting(privateSaleWallet, 1000000 * (10**18), 6, 0, 10);
        getVestings[managementAllocationWallet] = Vesting(managementAllocationWallet, 70000000 * (10**18), 12, 0, 5);
        getVestings[advisorsWallet] = Vesting(advisorsWallet, 5000000 * (10**18), 12, 0, 1);
        getVestings[influencersWallet] = Vesting(influencersWallet, 25000000 * (10**18), 6, 0, 1);
        getVestings[strategicPartnersWallet] = Vesting(strategicPartnersWallet, 25000000 * (10**18), 12, 0, 1);
        getVestings[bountyWallet] = Vesting(bountyWallet, 5000000 * (10**18), 3, 0, 10);
        getVestings[reserveWallet] = Vesting(reserveWallet, 150000000 * (10**18), 100, 0, 1);
        getVestings[operationsWallet] = Vesting(operationsWallet, 160000000 * (10**18), 50, 0, 2);
    }

    function updateNabana(address _nabana) external onlyOwner {
        require(address(nabana) != _nabana, "NabanaVesting: Nabana is already this address");
        nabana = IERC20(_nabana);
    }

    function updateVestingState(bool _vestState) external onlyOwner {
        require(vestState != _vestState, "NabanaVesting: Stake State is already of the value 'state'");
        vestState = _vestState;
    }

    function updatePermission(address _vester, bool _state) external onlyOwner {
        require(permitted[_vester] != _state, "NabanaVesting: Address is already of the value 'state'");
        permitted[_vester] = _state;
    }

    function updatePermissionForAllVesters(bool _state) external onlyOwner {
        permitted[privateSaleWallet] = _state;
        permitted[managementAllocationWallet] = _state;
        permitted[advisorsWallet] = _state;
        permitted[influencersWallet] = _state;
        permitted[strategicPartnersWallet] = _state;
        permitted[bountyWallet] = _state;
        permitted[reserveWallet] = _state;
        permitted[operationsWallet] = _state;
    }

    function claimVestings() external vestActive permission {
        uint256 currentTime = block.timestamp;

        require(currentTime > unlockTimeLast.add(unlockInterval), "NabanaVesting: No unlocks available");

        Vesting storage vesting;
        uint256 unlockValidator;

        vesting = getVestings[privateSaleWallet];
        bool isUnlockable = vesting.unlockInterval < vesting.totalIntervals;

        if (isUnlockable) {
            uint256 unlockAmount = vesting.totalAmount.mul(vesting.percentageToUnlock).div(100);

            vesting.unlockInterval++;
            unlockValidator++;

            nabana.transfer(vesting.vester, unlockAmount);

            emit DistributedVest(vesting.vester, vesting.unlockInterval, unlockAmount, currentTime);
        }

        vesting = getVestings[managementAllocationWallet];
        isUnlockable = vesting.unlockInterval < vesting.totalIntervals;

        if (isUnlockable) {
            uint256 unlockAmount = vesting.totalAmount.mul(vesting.percentageToUnlock).div(100);

            vesting.unlockInterval++;
            unlockValidator++;

            nabana.transfer(vesting.vester, unlockAmount);

            emit DistributedVest(vesting.vester, vesting.unlockInterval, unlockAmount, currentTime);
        }

        vesting = getVestings[advisorsWallet];
        isUnlockable = vesting.unlockInterval < vesting.totalIntervals;
        
        if (isUnlockable) {
            uint256 unlockAmount = vesting.totalAmount.mul(vesting.percentageToUnlock).div(100);

            vesting.unlockInterval++;
            unlockValidator++;

            nabana.transfer(vesting.vester, unlockAmount);

            emit DistributedVest(vesting.vester, vesting.unlockInterval, unlockAmount, currentTime);
        }

        vesting = getVestings[influencersWallet];
        isUnlockable = vesting.unlockInterval < vesting.totalIntervals;
        
        if (isUnlockable) {
            uint256 unlockAmount = vesting.totalAmount.mul(vesting.percentageToUnlock).div(100);

            vesting.unlockInterval++;
            unlockValidator++;

            nabana.transfer(vesting.vester, unlockAmount);

            emit DistributedVest(vesting.vester, vesting.unlockInterval, unlockAmount, currentTime);
        }

        vesting = getVestings[strategicPartnersWallet];
        isUnlockable = vesting.unlockInterval < vesting.totalIntervals;
        
        if (isUnlockable) {
            uint256 unlockAmount = vesting.totalAmount.mul(vesting.percentageToUnlock).div(100);

            vesting.unlockInterval++;
            unlockValidator++;

            nabana.transfer(vesting.vester, unlockAmount);

            emit DistributedVest(vesting.vester, vesting.unlockInterval, unlockAmount, currentTime);
        }

        vesting = getVestings[bountyWallet];
        isUnlockable = vesting.unlockInterval < vesting.totalIntervals;
        
        if (isUnlockable) {
            uint256 unlockAmount = vesting.totalAmount.mul(vesting.percentageToUnlock).div(100);

            vesting.unlockInterval++;
            unlockValidator++;

            nabana.transfer(vesting.vester, unlockAmount);

            emit DistributedVest(vesting.vester, vesting.unlockInterval, unlockAmount, currentTime);
        }

        vesting = getVestings[reserveWallet];
        isUnlockable = vesting.unlockInterval < vesting.totalIntervals;
        
        if (isUnlockable) {
            uint256 unlockAmount = vesting.totalAmount.mul(vesting.percentageToUnlock).div(100);

            vesting.unlockInterval++;
            unlockValidator++;

            nabana.transfer(vesting.vester, unlockAmount);

            emit DistributedVest(vesting.vester, vesting.unlockInterval, unlockAmount, currentTime);
        }

        vesting = getVestings[operationsWallet];
        isUnlockable = vesting.unlockInterval < vesting.totalIntervals;
        
        if (isUnlockable) {
            uint256 unlockAmount = vesting.totalAmount.mul(vesting.percentageToUnlock).div(100);

            vesting.unlockInterval++;
            unlockValidator++;

            nabana.transfer(vesting.vester, unlockAmount);

            emit DistributedVest(vesting.vester, vesting.unlockInterval, unlockAmount, currentTime);
        }

        if (unlockValidator != 0) {
            unlockTimeLast += unlockInterval;
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