/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// Part: IOracle

interface IOracle {
    function update() external;

    function consult(address _token, uint256 _amountIn) external view returns (uint144 amountOut);

    function twap(address _token, uint256 _amountIn) external view returns (uint144 _amountOut);
}

// Part: openzeppelin/[email protected]/Context

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

// Part: openzeppelin/[email protected]/IERC20

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

// Part: openzeppelin/[email protected]/SafeMath

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

// Part: IERC20Taxable

interface IERC20Taxable is IERC20 {

    function taxOffice() external returns(address);

    function staticTaxRate() external returns(uint256);

    function dynamicTaxRate() external returns(uint256);
    
    function getCurrentTaxRate() external returns(uint256);

    function setTaxOffice(address _taxOffice) external; 

    function setStaticTaxRate(uint256 _taxRate) external;

    function setEnableDynamicTax(bool _enableDynamicTax) external;
    
    function setWhitelistType(address _token, uint8 _type) external;

    function isWhitelistedSender(address _account) external view returns(bool isWhitelisted);

    function isWhitelistedRecipient(address _account) external view returns(bool isWhitelisted);

    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 _amount,
        address _to
    ) external;
    
}

// Part: openzeppelin/[email protected]/Ownable

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
contract Ownable is Context {
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

// Part: Operator

contract Operator is Context, Ownable {
    address private _operator;

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    constructor() internal {
        _operator = _msgSender();
        emit OperatorTransferred(address(0), _operator);
    }

    function operator() public view returns (address) {
        return _operator;
    }

    modifier onlyOperator() {
        require(_operator == msg.sender, "operator: caller is not the operator");
        _;
    }

    function isOperator() public view returns (bool) {
        return _msgSender() == _operator;
    }

    function transferOperator(address newOperator_) public onlyOwner {
        _transferOperator(newOperator_);
    }

    function _transferOperator(address newOperator_) internal {
        require(newOperator_ != address(0), "operator: zero address given for new operator");
        emit OperatorTransferred(address(0), newOperator_);
        _operator = newOperator_;
    }
}

// File: TaxOffice.sol

contract TaxOffice is Operator {
    using SafeMath for uint256;

    event HandledMainTokenTax(uint256 _amount);
    event HandledShareTokenTax(uint256 _amount);

    IERC20Taxable public mainToken;
    IERC20Taxable public shareToken;
    IOracle public mainTokenOracle;

    uint256 public constant BASIS_POINTS_DENOM = 10_000;

    uint256[] public mainTokenTaxTwapTiers = [
        0, 5e17, 6e17, 7e17, 8e17, 9e17, 9.5e17, 1e18, 1.05e18, 1.10e18, 1.20e18, 1.30e18, 1.40e18, 1.50e18
    ];
    uint256[] public mainTokenTaxRateTiers = [
        2000, 1900, 1800, 1700, 1600, 1500, 1500, 1500, 1500, 1400, 900, 400, 200, 100
    ];

    uint256[] public shareTokenTaxTwapTiers = [
        0, 5e17, 6e17, 7e17, 8e17, 9e17, 9.5e17, 1e18, 1.05e18, 1.10e18, 1.20e18, 1.30e18, 1.40e18, 1.50e18
    ];
    uint256[] public shareTokenTaxRateTiers = [
        2000, 1900, 1800, 1700, 1600, 1500, 1500, 1500, 1500, 1400, 900, 400, 200, 100
    ];

    mapping(address => mapping(address => uint256)) public taxDiscount;

    constructor(
        address _mainToken,
        address _shareToken,
        address _mainTokenOracle
    ) public {
        mainToken = IERC20Taxable(_mainToken);
        shareToken = IERC20Taxable(_shareToken);
        mainTokenOracle = IOracle(_mainTokenOracle);
    }

    /*
    Uses the oracle to fire the 'consult' method and get the price of tomb.
    */
    function _getMainTokenPrice() internal view returns (uint256) {
        try mainTokenOracle.consult(address(mainToken), 1e18) returns (uint144 _price) {
            return uint256(_price);
        } catch {
            revert("Erro: failed to fetch Main Token price from Oracle");
        }
    }

    function assertMonotonicity(uint256[] memory _monotonicArray) internal pure {
        uint8 endIdx = uint8(_monotonicArray.length.sub(1));
        for (uint8 idx = 0; idx <= endIdx; idx++) {
            if (idx > 0) {
                require(
                    _monotonicArray[idx] > _monotonicArray[idx - 1],
                    "Error: TWAP tiers sequence are not monotonic"
                );
            }
            if (idx < endIdx) {
                require(
                    _monotonicArray[idx] < _monotonicArray[idx + 1],
                    "Error: TWAP tiers sequence are not monotonic"
                );
            }
        }
    }

    function setMainTokenTaxTiers(
        uint256[] calldata _mainTokenTaxTwapTiers,
        uint256[] calldata _mainTokenTaxRateTiers
    ) external onlyOperator {
        require(
            _mainTokenTaxTwapTiers.length == _mainTokenTaxRateTiers.length,
            "Error: vector lengths are not the same."    
        );

        //Require monotonicity of TWAP tiers.
        assertMonotonicity(_mainTokenTaxTwapTiers);

        //Set values.
        mainTokenTaxTwapTiers = _mainTokenTaxTwapTiers;
        mainTokenTaxRateTiers = _mainTokenTaxRateTiers;
    }

    function setShareTokenTaxTiers(
        uint256[] calldata _shareTokenTaxTwapTiers,
        uint256[] calldata _shareTokenTaxRateTiers
    ) external onlyOperator {
        require(
            _shareTokenTaxTwapTiers.length == _shareTokenTaxRateTiers.length,
            "Error: vector lengths are not the same."    
        );

        //Require monotonicity of TWAP tiers.
        assertMonotonicity(_shareTokenTaxTwapTiers);

        //Set values.
        shareTokenTaxTwapTiers = _shareTokenTaxTwapTiers;
        shareTokenTaxRateTiers = _shareTokenTaxRateTiers;
    }

    function searchSorted(uint256[] memory _monotonicArray, uint256 _value) internal pure returns(uint8) {
        uint8 endIdx = uint8(_monotonicArray.length.sub(1));
        for (uint8 tierIdx = endIdx; tierIdx >= 0; --tierIdx) {
            if (_value >= _monotonicArray[tierIdx]) {
                return tierIdx;                
            }
        }
    }

    function calculateMainTokenTax() external view returns(uint256 taxRate){
        uint256 mainTokenPrice = _getMainTokenPrice();
        uint8 taxTierIdx = searchSorted(mainTokenTaxTwapTiers, mainTokenPrice);
        taxRate = mainTokenTaxRateTiers[taxTierIdx];
    }

    function calculateShareTokenTax() external view returns(uint256 taxRate){
        uint256 mainTokenPrice = _getMainTokenPrice();
        uint8 taxTierIdx = searchSorted(shareTokenTaxTwapTiers, mainTokenPrice);
        taxRate = shareTokenTaxRateTiers[taxTierIdx];
    }

    function withdraw(address _token, address _recipient, uint256 _amount) external onlyOperator {
        IERC20(_token).transfer(_recipient, _amount);
    }   

    function handleMainTokenTax(uint256 _amount) external virtual {
        emit HandledMainTokenTax(_amount);
    }

    function handleShareTokenTax(uint256 _amount) external virtual{
        emit HandledShareTokenTax(_amount);
    }

    /* ========== SET VARIABLES ========== */

    function setMainTokenStaticTaxRate(uint256 _taxRate) external onlyOperator {
        mainToken.setStaticTaxRate(_taxRate);
    }

    function setMainTokenEnableDynamicTax(bool _enableDynamicTax) external onlyOperator {
        mainToken.setEnableDynamicTax(_enableDynamicTax);
    }
    
    function setMainTokenWhitelistType(address _account, uint8 _type) external onlyOperator {
        mainToken.setWhitelistType(_account, _type);
    }

    function setShareTokenStaticTaxRate(uint256 _taxRate) external onlyOperator {
        shareToken.setStaticTaxRate(_taxRate);
    }

    function setShareTokenEnableDynamicTax(bool _enableDynamicTax) external onlyOperator {
        shareToken.setEnableDynamicTax(_enableDynamicTax);
    }
    
    function setShareTokenWhitelistType(address _account, uint8 _type) external onlyOperator {
        shareToken.setWhitelistType(_account, _type);
    }

    function setTaxDiscount(address _sender, address _recipient, uint256 _amount) external onlyOwner {
        require(_amount <= BASIS_POINTS_DENOM, "Error: Discount rate too high.");
        taxDiscount[_sender][_recipient] = _amount;
    }

    function setMainTokenOracle(address _mainTokenOracle) external onlyOperator {
        require(_mainTokenOracle != address(0), "Error: Oracle address cannot be 0 address");
        mainTokenOracle = IOracle(_mainTokenOracle);
    }

}