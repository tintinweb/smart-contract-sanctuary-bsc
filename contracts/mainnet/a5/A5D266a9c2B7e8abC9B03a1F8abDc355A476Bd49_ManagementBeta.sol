// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "../main/Management.sol";

/** 
* @author Formation.Fi.
* @notice Implementation of the contract ManagementBeta.
*/

contract ManagementBeta is Management {
    constructor(address _manager, address _treasury, address _stableToken,
     address _token) Management( _manager,  _treasury,  _stableToken,
     _token){
   }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol"; 
import "./libraries/SafeBEP20.sol";
import "./Token.sol";
/** 
* @author Formation.Fi.
* @notice Implementation of the contract Management.
*/

contract Management is Ownable {
    using SafeBEP20 for IBEP20;
    uint256 public constant FACTOR_FEES_DECIMALS = 1e4; 
    uint256 public constant FACTOR_PRICE_DECIMALS = 1e18;
    uint256 public constant  SECONDES_PER_YEAR = 365 days; 
    uint256 public maxDepositAmount = 1000000 * 1e18;
    uint256 public maxWithdrawalAmount = 1000000 * 1e18;
    uint256 public slippageTolerance = 200;
    uint256 public amountScaleDecimals; 
    uint256 public depositFeeRate = 50;  
    uint256 public minDepositFee;
    uint256 public maxDepositFee = 1000000000000000000000;
    uint256 public managementFeeRate = 200;
    uint256 public performanceFeeRate = 2000;
    uint256 public performanceFee;
    uint256 public managementFee;
    uint256 public managementFeeTime = 1671881867;
    uint256 public tokenPrice =  844836178210626000;
    uint256 public tokenPriceMean = 1220627070255622963;
    uint256 public minAmount= 100 * 1e18;
    uint256 public lockupPeriodUser = 604800; 
    uint256 public netDepositInd;
    uint256 public netAmountEvent;
    address public manager;
    address public treasury;
    address public safeHouse;
    address public investment;
    bool public isCancel;
    mapping(address => bool) public managers;
    Token public token;
    IBEP20 public stableToken;


    constructor( address _manager, address _treasury,  address _stableToken,
     address _token) {
        require(_manager!= address(0),
            "Formation.Fi: zero address");
        require(_treasury!= address(0),
            "Formation.Fi: zero address");
        require(_stableToken!= address(0),
            "Formation.Fi: zero address");
        require(_token!= address(0),
            "Formation.Fi: zero address");
        manager = _manager;
        managers[_manager] = true;
        treasury = _treasury; 
        token = Token(_token);
        stableToken = IBEP20(_stableToken);
        uint8 _stableTokenDecimals = uint8(18) - stableToken.decimals();
        amountScaleDecimals = 10 ** _stableTokenDecimals;
    }

    modifier onlyInvestment() {
        require(investment != address(0),
            "Formation.Fi: zero address");
        require(msg.sender == investment,
            "Formation.Fi: not investment");
        _;
    }

    modifier onlyManager() {
        require(msg.sender == manager , 
            "Formation.Fi: not manager");
        _;
    }

    /**
     * @dev getter functions.
    */
    function getDepositFee(uint256 _value) public view    
        returns (uint256 _fee){
        _fee = Math.max(Math.mulDiv(depositFeeRate, _value, FACTOR_FEES_DECIMALS), minDepositFee);
        _fee = Math.min(_fee, maxDepositFee);    
    }

    function isManager(address _manager) public view returns(bool) {
        require(_manager != address(0),
            "Formation.Fi: zero address");
        return managers[_manager] ;
    }

    /**
     * @dev Setter functions to update the Portfolio Parameters.
    */
    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0),
            "Formation.Fi: zero address");
        treasury = _treasury;
    }

    function setManager(address _manager) external onlyOwner {
        require(_manager != address(0),
            "Formation.Fi: zero address");
        manager = _manager ;
    }

    function updateManagers(address _manager, bool _state) external onlyOwner {
        require(_manager != address(0),
            "Formation.Fi: zero address");
        managers[_manager] = _state ;
    }

    function setStableToken(address _stableTokenAddress) external onlyOwner {
        require(_stableTokenAddress != address(0),
            "Formation.Fi: zero address");
        stableToken = IBEP20(_stableTokenAddress);
        uint8 _stableTokenDecimals = uint8(18) - stableToken.decimals();
        amountScaleDecimals = 10 ** _stableTokenDecimals;
    }

    function setToken(address _token) external onlyOwner {
        require(_token != address(0),
            "Formation.Fi: zero address");
        token = Token(_token);
    }

    function setInvestment(address _investment) external onlyOwner {
        require(_investment!= address(0),
            "Formation.Fi: zero address");
        investment = _investment;
    } 

    function setSafeHouse(address _safeHouse) external onlyOwner {
        require(_safeHouse!= address(0),
            "Formation.Fi: zero address");
        safeHouse = _safeHouse;
    } 

    function setCancel(bool _isCancel) external onlyManager {
        require(_isCancel!= isCancel,
            "Formation.Fi: no change");
        isCancel = _isCancel;
    }
  
    function setLockupPeriodUser(uint256 _lockupPeriodUser) external onlyManager {
        lockupPeriodUser = _lockupPeriodUser;
    }

    function setMaxDepositFee(uint256 _maxDepositFee) 
        external onlyManager {
        maxDepositFee = _maxDepositFee;
    }

    function setMinDepositFee(uint256 _minDepositFee) 
        external onlyManager {
        minDepositFee = _minDepositFee;
    }
 
    function setDepositFeeRate(uint256 _rate) external onlyManager {
        depositFeeRate= _rate;
    }

    function setSlippageTolerance(uint256 _value) external onlyManager {
        slippageTolerance = _value;
    }

    function setManagementFeeRate(uint256 _rate) external onlyManager {
        managementFeeRate = _rate;
    }

    function setPerformanceFeeRate(uint256 _rate) external onlyManager {
        performanceFeeRate  = _rate;
    }
    function setMinAmount(uint256 _minAmount) external onlyManager {
        minAmount= _minAmount;
    }

    function setMaxDepositAmount(uint256 _maxDepositAmount) external 
        onlyManager {
        maxDepositAmount = _maxDepositAmount;

    }
    function setMaxWithdrawalAmount(uint256 _maxWithdrawalAmount) external 
        onlyManager{
         maxWithdrawalAmount = _maxWithdrawalAmount;      
    }

    function updateTokenPrice(uint256 _price) external {
        require (managers[msg.sender] == true,
            "Formation.Fi: no manager");
        require(_price > 0,
            "Formation.Fi: zero price");
        tokenPrice = _price;
    }

    function updateTokenPriceMean(uint256 _price) external onlyInvestment {
        require(_price > 0,
            "Formation.Fi: zero price");
        tokenPriceMean = _price;
    }

    function updateManagementFeeTime(uint256 _time) external onlyInvestment {
        managementFeeTime = _time;
    }
    

    /**
     * @dev Calculate performance Fee.
    */
    function calculateperformanceFee() external {
        require (managers[msg.sender] == true, 
            "Formation.Fi: no manager");
        require(performanceFee == 0, 
            "Formation.Fi: fees on pending");
        uint256 _deltaPrice;
        if (tokenPrice > tokenPriceMean) {
            _deltaPrice = tokenPrice - tokenPriceMean;
            tokenPriceMean = tokenPrice;
            performanceFee = Math.mulDiv(token.totalSupply(),
            (_deltaPrice * performanceFeeRate), (tokenPrice * FACTOR_FEES_DECIMALS)); 
        }
    }

    /**
     * @dev Calculate management Fee.
    */
    function calculatemanagementFee() external {
        require (managers[msg.sender] == true, 
            "Formation.Fi: no manager");
        require(managementFee == 0, 
            "Formation.Fi: fees on pending");
        if (managementFeeTime!= 0){
           uint256 _deltaTime;
           _deltaTime = block.timestamp -  managementFeeTime; 
           managementFee = Math.mulDiv(token.totalSupply(), (managementFeeRate * _deltaTime),
           (FACTOR_FEES_DECIMALS * SECONDES_PER_YEAR));
           managementFeeTime = block.timestamp; 
        }
    }
     
    /**
     * @dev Mint Fees.
    */
    function mintFees() external{
        require (managers[msg.sender] == true, 
            "Formation.Fi: no manager");
        require ((performanceFee + managementFee) > 0, 
            "Formation.Fi: zero fees");
        token.mint(treasury, performanceFee + managementFee);
        performanceFee = 0;
        managementFee = 0;
    }

    /**
     * @dev Calculate net amount Event
     * @param _depositAmountTotal the total requested deposit amount by users.
     * @param  _withdrawalAmountTotal the total requested withdrawal amount by users.
     * @param _maxDepositAmount the maximum accepted deposit amount by event.
     * @param _maxWithdrawalAmount the maximum accepted withdrawal amount by event.
     */
    function calculateNetAmountEvent(uint256 _depositAmountTotal, 
        uint256 _withdrawalAmountTotal, uint256 _maxDepositAmount, 
        uint256 _maxWithdrawalAmount) external onlyInvestment{
        _depositAmountTotal = Math.min(_depositAmountTotal,
         _maxDepositAmount);
        _withdrawalAmountTotal = Math.mulDiv(_withdrawalAmountTotal, tokenPrice, FACTOR_PRICE_DECIMALS);
        _withdrawalAmountTotal= Math.min(_withdrawalAmountTotal,
        _maxWithdrawalAmount);
        if (_depositAmountTotal >= _withdrawalAmountTotal ){
            netDepositInd = 1;
            netAmountEvent = _depositAmountTotal - _withdrawalAmountTotal;
        }
        else {
            netDepositInd = 0;
            netAmountEvent = _withdrawalAmountTotal - _depositAmountTotal;

        }
    }
 
    /**
     * @dev Protect against slippage due to assets sale.
     * @param _withdrawalAmount the value of sold assets in Stablecoin.
     * _withdrawalAmount has to be sent to the contract.
     * treasury has to approve the contract for both Stablecoin and token.
     * @return Missed amount to send to the contract due to slippage.
     */
    function protectAgainstSlippage(uint256 _withdrawalAmount) external  
        returns (uint256) {
        require (managers[msg.sender] == true, 
            "Formation.Fi: no manager");
        require(_withdrawalAmount != 0, 
            "Formation.Fi: zero amount");
        require(netDepositInd == 0, 
            "Formation.Fi: no slippage");
        uint256 _amount; 
        uint256 _deltaAmount;
        uint256 _slippage;
        uint256  _tokenAmount;
        uint256 _balanceTokenTreasury = token.balanceOf(treasury);
        uint256 _balanceStableTreasury = stableToken.balanceOf(treasury) * amountScaleDecimals;
        if (_withdrawalAmount< netAmountEvent){
            _amount = netAmountEvent - _withdrawalAmount;   
            _slippage = Math.mulDiv(_amount, FACTOR_FEES_DECIMALS, netAmountEvent);
            if (_slippage >= slippageTolerance) {
                return netAmountEvent;
            }
            else {
                _deltaAmount = Math.min( _amount, _balanceStableTreasury);
                if (_deltaAmount > 0){
                    stableToken.safeTransferFrom(treasury, investment, _deltaAmount/amountScaleDecimals);
                    _tokenAmount = Math.mulDiv(_deltaAmount, FACTOR_PRICE_DECIMALS, tokenPrice);
                    token.mint(treasury, _tokenAmount);
                    return _amount - _deltaAmount;
                }
                else {
                     return _amount; 
                }  
            }    
        
        }
        else {
            _amount = _withdrawalAmount - netAmountEvent;   
            _tokenAmount = Math.mulDiv(_amount, FACTOR_PRICE_DECIMALS, tokenPrice);
            _tokenAmount = Math.min(_tokenAmount, _balanceTokenTreasury);
            if (_tokenAmount >0){
                _deltaAmount = Math.mulDiv(_tokenAmount, tokenPrice, FACTOR_PRICE_DECIMALS);
                stableToken.safeTransfer(treasury, _deltaAmount/amountScaleDecimals);   
                token.burn( treasury, _tokenAmount);
            }
            if ((_amount - _deltaAmount) > 0) {
                stableToken.safeTransfer(safeHouse, (_amount - _deltaAmount)/amountScaleDecimals); 
            }
        }
        return 0;

    } 
  
}

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
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
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "../IBEP20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BEP20.sol";
//import "./libraries/Math.sol";
import "@openzeppelin/contracts/utils/math/Math.sol"; 

/** 
* @author Formation.Fi.
* @notice  A common Implementation for tokens ALPHA, BETA and GAMMA.
*/

contract Token is BEP20 {
    struct Deposit{
        uint256 amount;
        uint256 time;
    }
    address public proxyInvestement;
    address private proxyAdmin;

    mapping(address => Deposit[]) public depositPerAddress;
    mapping(address => bool) public  whitelist;
    event SetProxyInvestement(address  _address);
    constructor(string memory _name, string memory _symbol) 
    BEP20(_name,  _symbol) {
    }

    modifier onlyProxy() {
        require(
            (proxyInvestement != address(0)) && (proxyAdmin != address(0)),
            "Formation.Fi: zero address"
        );

        require(
            (msg.sender == proxyInvestement) || (msg.sender == proxyAdmin),
             "Formation.Fi: not the proxy"
        );
        _;
    }
    modifier onlyProxyInvestement() {
        require(proxyInvestement != address(0),
            "Formation.Fi: zero address"
        );

        require(msg.sender == proxyInvestement,
             "Formation.Fi: not the proxy"
        );
        _;
    }

     /**
     * @dev Update the proxyInvestement.
     * @param _proxyInvestement.
     * @notice Emits a {SetProxyInvestement} event with `_proxyInvestement`.
     */
    function setProxyInvestement(address _proxyInvestement) external onlyOwner {
        require(
            _proxyInvestement!= address(0),
            "Formation.Fi: zero address"
        );

         proxyInvestement = _proxyInvestement;

        emit SetProxyInvestement( _proxyInvestement);

    } 

    /**
     * @dev Add a contract address to the whitelist
     * @param _contract The address of the contract.
     */
    function addToWhitelist(address _contract) external onlyOwner {
        require(
            _contract!= address(0),
            "Formation.Fi: zero address"
        );

        whitelist[_contract] = true;
    } 

    /**
     * @dev Remove a contract address from the whitelist
     * @param _contract The address of the contract.
     */
    function removeFromWhitelist(address _contract) external onlyOwner {
         require(
            whitelist[_contract] == true,
            "Formation.Fi: no whitelist"
        );
        require(
            _contract!= address(0),
            "Formation.Fi: zero address"
        );

        whitelist[_contract] = false;
    } 

    /**
     * @dev Update the proxyAdmin.
     * @param _proxyAdmin.
     */
    function setAdmin(address _proxyAdmin) external onlyOwner {
        require(
            _proxyAdmin!= address(0),
            "Formation.Fi: zero address"
        );
        
         proxyAdmin = _proxyAdmin;
    } 


    
    /**
     * @dev add user's deposit.
     * @param _account The user's address.
     * @param _amount The user's deposit amount.
     * @param _time The deposit time.
     */
    function addDeposit(address _account, uint256 _amount, uint256 _time) 
        external onlyProxyInvestement {
        require(
            _account!= address(0),
            "Formation.Fi: zero address"
        );

        require(
            _amount!= 0,
            "Formation.Fi: zero amount"
        );

        require(
            _time!= 0,
            "Formation.Fi: zero time"
        );
        Deposit memory _deposit = Deposit(_amount, _time); 
        depositPerAddress[_account].push(_deposit);
    } 

     /**
     * @dev mint the token product for the user.
     * @notice To receive the token product, the user has to deposit 
     * the required StableCoin in this product. 
     * @param _account The user's address.
     * @param _amount The amount to be minted.
     */
    function mint(address _account, uint256 _amount) external onlyProxy {
        require(
          _account!= address(0),
           "Formation.Fi: zero address"
        );

        require(
            _amount!= 0,
            "Formation.Fi: zero amount"
        );

       _mint(_account,  _amount);
   }

    /**
     * @dev burn the token product of the user.
     * @notice When the user withdraws his Stablecoins, his tokens 
     * product are burned. 
     * @param _account The user's address.
     * @param _amount The amount to be burned.
     */
    function burn(address _account, uint256 _amount) external onlyProxy {
        require(
            _account!= address(0),
            "Formation.Fi: zero address"
        );

         require(
            _amount!= 0,
            "Formation.Fi: zero amount"
        );

        _burn( _account, _amount);
    }
    
     /**
     * @dev Verify the lock up condition for a user's withdrawal request.
     * @param _account The user's address.
     * @param _amount The amount to be withdrawn.
     * @param _period The lock up period.
     * @return _success  is true if the lock up condition is satisfied.
     */
    function checklWithdrawalRequest(address _account, uint256 _amount, uint256 _period) 
        external view returns (bool _success){
        require(
            _account!= address(0),
            "Formation.Fi: zero address"
        );

        require(
           _amount!= 0,
            "Formation.Fi: zero amount"
        );

        Deposit[] memory _deposit = depositPerAddress[_account];
        uint256 _amountTotal = 0;
        for (uint256 i = 0; i < _deposit.length; i++) {
             require ((block.timestamp - _deposit[i].time) >= _period, 
            "Formation.Fi:  position locked");
            if (_amount<= (_amountTotal + _deposit[i].amount)){
                break; 
            }
            _amountTotal = _amountTotal + _deposit[i].amount;
        }
        _success= true;
    }


     /**
     * @dev update the user's token data.
     * @notice this function is called after each desposit request 
     * validation by the manager.
     * @param _account The user's address.
     * @param _amount The deposit amount validated by the manager.
     */
    function updateTokenData( address _account,  uint256 _amount) 
        external onlyProxyInvestement {
        _updateTokenData(_account,  _amount);
    }

    function _updateTokenData( address _account,  uint256 _amount) internal {
        require(
            _account!= address(0),
            "Formation.Fi: zero address"
        );

        require(
            _amount!= 0,
            "Formation.Fi: zero amount"
        );

        Deposit[] memory _deposit = depositPerAddress[_account];
        uint256 _amountlocal = 0;
        uint256 _amountTotal = 0;
        uint256 _newAmount;
        uint256 k = 0;
        for (uint256 i = 0; i < _deposit.length; i++) {
            _amountlocal  = Math.min(_deposit[i].amount, _amount -  _amountTotal);
            _amountTotal = _amountTotal + _amountlocal;
            _newAmount = _deposit[i].amount - _amountlocal;
            depositPerAddress[_account][k].amount = _newAmount;
            if (_newAmount == 0){
               _deleteTokenData(_account, k);
            }
            else {
                k = k+1;
            }
            if (_amountTotal == _amount){
               break; 
            }
        }
    }
    
     /**
     * @dev delete the user's token data.
     * @notice This function is called when the user's withdrawal request is  
     * validated by the manager.
     * @param _account The user's address.
     * @param _index The index of the user in 'amountDepositPerAddress'.
     */
    function _deleteTokenData(address _account, uint256 _index) internal {
        require(
            _account!= address(0),
            "Formation.Fi: zero address"
        );
        uint256 _size = depositPerAddress[_account].length - 1;
        
        require( _index <= _size,
            "Formation.Fi: index is out"
        );
        for (uint256 i = _index; i< _size; i++){
            depositPerAddress[ _account][i] = depositPerAddress[ _account][i+1];
        }
        depositPerAddress[ _account].pop();   
    }
   
     /**
     * @dev update the token data of both the sender and the receiver 
       when the product token is transferred.
     * @param from The sender's address.
     * @param to The receiver's address.
     * @param amount The transferred amount.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
      ) internal virtual override{
      
       if ((to != address(0)) && (to != proxyInvestement) 
       && (to != proxyAdmin) && (from != address(0)) && (!whitelist[to])){
          _updateTokenData(from, amount);
          Deposit memory _deposit = Deposit(amount, block.timestamp);
          depositPerAddress[to].push(_deposit);
         
        }
    }

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
pragma solidity ^0.8.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import  "@openzeppelin/contracts/utils/Context.sol";
import './IBEP20.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-BEP20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of BEP20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */
contract BEP20 is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external override view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token name.
     */
    function name() public override view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, 'BEP20: transfer amount exceeds allowance')
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, 'BEP20: decreased allowance below zero')
        );
        return true;
    }


    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 'BEP20: transfer to the zero address');
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount, 'BEP20: transfer amount exceeds balance');
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);   
       _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: mint to the zero address');

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: burn from the zero address');

        _balances[account] = _balances[account].sub(amount, 'BEP20: burn amount exceeds balance');
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, 'BEP20: burn amount exceeds allowance')
        );
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

   
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}