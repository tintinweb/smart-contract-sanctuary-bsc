/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

//SPDX-License-Identifier: UNLICENSED

// File: IDividendDistributor.sol


pragma solidity ^0.8.9;

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}
// File: IUniswapV2Router02.sol


pragma solidity ^0.8.9;

interface IUniswapV2Router01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);
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
// File: IUniswapV2Pair.sol


pragma solidity ^0.8.9;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;

}
// File: IUniswapV2Factory.sol


pragma solidity ^0.8.9;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
// File: IBEP20.sol


pragma solidity ^0.8.9;

interface IBEP20 {
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
// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

// File: DividendDistributor.sol


pragma solidity ^0.8.9;





contract DividendDistributor is IDividendDistributor {
    
    using SafeMath for uint256;

    //--------------------------------------
    // Structs
    //--------------------------------------
    
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    //--------------------------------------
    // State variables
    //--------------------------------------
    
    address public TOKEN;

    IBEP20 public BUSD;
    // TESTNET BUSD (KIEMTIEN): 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    // TESTNET BUSD:            0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee
    // MAINNET BUSD:            0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56

    address public WBNB;
    // TESTNET WBNB: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    // MAINNET WBNB: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c

    IUniswapV2Router02 public router;
    // TESTNET ROUTER (KIEMTIEN): 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    // TESTNET ROUTER:            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    // MAINNET ROUTER:            0x10ED43C718714eb63d5aA57B78B54704E256024E

    address[] public shareholders;
    mapping (address => uint256) public shareholderIndexes;
    mapping (address => uint256) public shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 45 minutes;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 public currentIndex;

    bool public initialized;

    //--------------------------------------
    // Events
    //--------------------------------------

    event Deposit(uint256 value);
    event SetShare(address shareholder, uint256 amount);
    event Process();

    //--------------------------------------
    // Modifiers
    //--------------------------------------

    modifier initialization() { require(!initialized); _; initialized = true; }
    modifier onlyToken() { require(msg.sender == TOKEN); _; }

    //--------------------------------------
    // OnInit
    //--------------------------------------

    constructor() {
        router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        BUSD = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
        WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
        TOKEN = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if (shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        } else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);

        emit SetShare(shareholder, amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(BUSD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(0, path, address(this), block.timestamp);

        uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));

        emit Deposit(msg.value);
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    
        emit Process();
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) { return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}
// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: BaseCoin.sol


pragma solidity ^0.8.9;










contract BaseCoin is IBEP20, Ownable {

    using SafeMath for uint256;

    //--------------------------------------
    // Constants
    //--------------------------------------

    // Mainnet Address
    address constant public BUSD = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    // TESTNET BUSD (KIEMTIEN): 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    // TESTNET BUSD:            0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee
    // MAINNET BUSD:            0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56

    address constant public WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    // TESTNET WBNB:            0xae13d989dac2f0debff460ac112a837c89baa7cd
    // MAINNET WBNB:            0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c

    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant public ZERO = 0x0000000000000000000000000000000000000000;

    // Mainnet Name, Symbol, Decimals, Supply
    string constant public _name = "BaseCoin";
    string constant public _symbol = "COIN";
    uint8 constant public _decimals = 9;
    uint256 constant public _totalSupply = 420_000_000_000_000_000 * (10 ** _decimals);

                                            //   5_000_000_000_000 * (10 ** _decimals) == 0.01 BNB // TESTNET
                                            // 500_000_000_000_000 * (10 ** _decimals) ==    1 BNB // MAINNET

    // Fee denominator should always be 100
    uint256 constant public feeDenominator = 100;

    // Max as a variable
    uint256 constant private MAX = type(uint256).max;

    //--------------------------------------
    // State variables
    //--------------------------------------

    // Uniswap
    IUniswapV2Router02 public router;
    address public pair;

    // Generic
    uint256 public maxTxAmount = _totalSupply; // MAXED OUT
    uint256 public maxWalletToken = _totalSupply; // MAXED OUT
    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) public _allowances;

    // Swap-related
    bool public swapEnabled = true;
                                                      //   100  // 5%
                                                      //  1000  // 0.5%
    uint256 public swapThreshold = (_totalSupply * 5) / 100000; // 0.005% of Total Supply
    bool inSwap;

    // Fees
    uint256 public liquidityFee = 4;
    uint256 public reflectionFee = 2;
    uint256 public devFee = 6;
    uint256 public totalFee = 12;

    // Fee Receivers
    address public autoLiquidityReceiver;
    address public devFeeReceiver;

    // Sniper Protection
    mapping (address => bool) public isSniper;
    bool public sniperProtection = true;
    bool public hasLiqBeenAdded = false;
    uint256 public liqAddBlock = 0;

   // Exemption mappings
    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isTimelockExempt;
    mapping (address => bool) public isDividendExempt;
    mapping (address => bool) public isSniperExempt;

    // Reflections (Dividends)
    DividendDistributor public distributor;
    uint256 public distributorGas = 500000;

    // Cooldown & timer functionality
    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 45; // In blocks
    mapping (address => uint) public cooldownTimer;

    //--------------------------------------
    // Events
    //--------------------------------------

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event SniperCaught(address sniperAddress);
    event TakeFee(address sender, address contractAddress, uint256 amount);
    event ShouldSwapBack(address sender, bool willSwapBack, bool inSwap);
    event StartSwapBack(address sender, uint256 amountToSwap);
    event DistributorDeposited(address sender, bool success, uint256 amountBNBReflection);
    event DistributorProcessed(address sender, bool success);
    event FeeSent(address sender, address devFeeReceiver, bool success, bytes data);

    //--------------------------------------
    // Modifiers
    //--------------------------------------

    modifier swapping() { inSwap = true; _; inSwap = false; }

    //--------------------------------------
    // OnInit
    //--------------------------------------

    constructor () {

        // Mainnet pancake router address
        router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        // TESTNET ROUTER (KIEMTIEN): 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        // TESTNET ROUTER:            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        // MAINNET ROUTER:            0x10ED43C718714eb63d5aA57B78B54704E256024E

        pair = IUniswapV2Factory(router.factory()).createPair(WBNB, address(this));

        // Distributor
        distributor = new DividendDistributor();

        // Balances Allowances Approvals
        _balances[owner()] = _totalSupply;
        _allowances[address(this)][address(router)] = MAX;
        approveMax(owner());

        // Exempt from fees and tx limit
        isFeeExempt[owner()] = true;
        isTxLimitExempt[owner()] = true;

        // Exempt from dividends 
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        // Exempt owner and router from antisnipe
        isSniperExempt[owner()] = true;
        isSniperExempt[address(router)] = true;

        // No timelock for these people
        isTimelockExempt[owner()] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;

        // Manually do this via excludePresaleAddress
        // ---------------------------------------------
        
        // isFeeExempt[_presaleContract] = true;
        // isTxLimitExempt[_presaleContract] = true;
        // isDividendExempt[_presaleContract] = true;
        // isSniperExempt[presaleAddress] = true;

        // isFeeExempt[_pinkLockAddress] = true;
        // isDividendExempt[_pinkLockAddress] = true;
    
        // ---------------------------------------------

        autoLiquidityReceiver = owner();
        devFeeReceiver = msg.sender;

        emit Transfer(address(0), owner(), _totalSupply);
    }

    function excludePresaleAddress(address presaleAddress) external onlyOwner {
        isFeeExempt[presaleAddress] = true;
        isTxLimitExempt[presaleAddress] = true;
        isDividendExempt[presaleAddress] = true;
        isSniperExempt[presaleAddress] = true;
    }

    //--------------------------------------
    // Getters
    //--------------------------------------

    // Generic
    function totalSupply() external pure override returns (uint256) { return _totalSupply; }
    function decimals() external pure returns (uint8) { return _decimals; }
    function symbol() external pure returns (string memory) { return _symbol; }
    function name() external pure returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function getOwner() external view override returns (address) { return owner(); }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    
    // Special
    function shouldTakeFee(address sender) public view returns (bool) { return !isFeeExempt[sender]; }
    function getCirculatingSupply() public view returns (uint256) { return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO)); }
    
    function shouldCheckMaxWallet(address recipient) public view returns (bool) {
        return recipient != address(this)  &&  
            recipient != address(DEAD) && 
            recipient != pair && 
            recipient != devFeeReceiver && 
            recipient != autoLiquidityReceiver;
    }

    function shouldSwapBack(address sender) public returns (bool) {
        bool willSwapBack = sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
        emit ShouldSwapBack(sender, willSwapBack, inSwap);
        return willSwapBack;
    }

    //--------------------------------------
    // Setters
    //--------------------------------------

    // Generic
    function setMaxWalletAmount(uint256 amount) public onlyOwner { maxWalletToken = amount; }
    function setTxLimit(uint256 amount) external onlyOwner { maxTxAmount = amount; }
    function setSniperProtection(bool _sniperProtection) external onlyOwner { sniperProtection = _sniperProtection; }

    function setCooldownEnabled(bool _status, uint8 _interval) external onlyOwner { 
        buyCooldownEnabled = _status; 
        cooldownTimerInterval = _interval; 
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _devFeeReceiver) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        devFeeReceiver = _devFeeReceiver;
    }

    function setFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256 _devFee) external onlyOwner {
        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        devFee = _devFee;
        totalFee = _liquidityFee.add(_reflectionFee).add(_devFee);
    }
    
    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner { swapEnabled = _enabled; swapThreshold = _amount; }

    // Distributor
    function setDistributorSettings(uint256 gas) external onlyOwner { require(gas < 750000); distributorGas = gas; }
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner { 
        distributor.setDistributionCriteria(_minPeriod, _minDistribution); 
    }

    // Exemptions
    function setIsFeeExempt(address holder, bool exempt) external onlyOwner { isFeeExempt[holder] = exempt; }
    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner { isTxLimitExempt[holder] = exempt; }
    function setIsTimelockExempt(address holder, bool exempt) external onlyOwner { isTimelockExempt[holder] = exempt; }
    function setIsSniperExempt(address holder, bool exempt) external onlyOwner { isSniperExempt[holder] = exempt; }
    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if (exempt) { distributor.setShare(holder, 0); } 
        else { distributor.setShare(holder, _balances[holder]); }
    }

    //--------------------------------------
    // Approvals
    //--------------------------------------

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) public returns (bool) {
        return approve(spender, type(uint256).max);
    }

    //--------------------------------------
    // AntiSniper
    //--------------------------------------

    function checkLiquidityAdd(address from, address to) private {
        require(!hasLiqBeenAdded, "Liquidity already added and marked.");
        if (isSniperExempt[from] && to == address(pair)) {
            hasLiqBeenAdded = true;
            liqAddBlock = block.number;
        }
    }

    function catchSniper(address sender, address recipient) internal {
        // Failsafe, disable the whole system if needed.
        if (sniperProtection) {

            // If sender is a sniper address, reject the sell.
            if (isSniper[sender] == true) { revert("Sniper transactions rejected!"); }

            // Check if this is the liquidity adding tx to startup.
            if (!hasLiqBeenAdded) { checkLiquidityAdd(sender, recipient); } 
            else if (liqAddBlock > 0 && sender == address(pair) && !isSniperExempt[sender] && !isSniperExempt[recipient]) {
                if (block.number - liqAddBlock < 2) {
                    isSniper[recipient] = true;
                    emit SniperCaught(recipient);
                }
            }
        }
    }

    //--------------------------------------
    // Transfer
    //--------------------------------------

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        // if(_allowances[sender][msg.sender] != uint256(-1))
        if(_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        catchSniper(sender, recipient);

        if (inSwap) { return _basicTransfer(sender, recipient, amount); }

        // Check Max Wallet
        if (shouldCheckMaxWallet(recipient)) {
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= maxWalletToken, "Total Holding is currently limited, you can not buy that much.");
        }
        
        // Cooldown timer, so a bot doesnt do quick trades
        if (sender == pair && buyCooldownEnabled && isTimelockExempt[recipient] == false) {
            require(cooldownTimer[recipient] < block.timestamp, "Please wait for cooldown between buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }

        // Checks max transaction limit
        require(amount <= maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");

        // Liquidity
        if (shouldSwapBack(sender) == true) { swapBack(sender); }

        // Remove tokens from sender
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        // Add tokens to recipient after taking fees
        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Dividend tracker
        if (!isDividendExempt[sender]) { try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if (!isDividendExempt[recipient]) { try distributor.setShare(recipient, _balances[recipient]) {} catch {} }
        try distributor.process(distributorGas) { emit DistributorProcessed(sender, true); }
        catch { emit DistributorProcessed(sender, false); }

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    //--------------------------------------
    // Fees and Swap
    //--------------------------------------

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit TakeFee(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function swapBack(address sender) internal swapping {

        uint256 amountToLiquify = swapThreshold.mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        emit StartSwapBack(sender, amountToSwap);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        // BNB: 0.5*Liquidity + Reflections + Dev 
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap, 0, path, address(this), block.timestamp);

        uint256 amountBNB = address(this).balance.sub(balanceBefore); // What was the amount swapped?

        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));
        
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
        uint256 amountBNBDev = amountBNB.mul(devFee).div(totalBNBFee);

        // Reflections
        try distributor.deposit{value: amountBNBReflection}() { emit DistributorDeposited(sender, false, amountBNBReflection); } 
        catch { emit DistributorDeposited(sender, false, amountBNBReflection); }

        // Send Dev Fee
        (bool success, bytes memory data) = payable(devFeeReceiver).call{value: amountBNBDev, gas: 30000}(""); 
        emit FeeSent(sender, devFeeReceiver, success, data);

        if (amountToLiquify > 0) {
            // Add Liquidity with the half converted to BNB (amountBNBLiquidity) and half staying as token (amountToLiquify)
            router.addLiquidityETH {value: amountBNBLiquidity} (address(this), amountToLiquify, 0, 0, autoLiquidityReceiver, block.timestamp); 
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }


    //--------------------------------------
    // Misc
    //--------------------------------------

    receive() external payable { }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(devFeeReceiver).transfer(amountBNB * amountPercentage / 100);
    }

    function airdrop(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {
        require(addresses.length == tokens.length, "Mismatch between Address and token count");
        uint256 tokensRequired = 0;
        for (uint i=0; i < addresses.length; i++) { tokensRequired = tokensRequired + tokens[i]; }
        require(balanceOf(from) >= tokensRequired, "Not enough tokens to airdrop");
        if (!isDividendExempt[from]) { try distributor.setShare(from, _balances[from]) {} catch {}}
        for (uint i=0; i < addresses.length; i++) {
            _basicTransfer(from, addresses[i], tokens[i]);
            if (!isDividendExempt[addresses[i]]) {
                try distributor.setShare(addresses[i], _balances[addresses[i]]) {} catch {} 
            }
        }
    }

}