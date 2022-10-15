/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

pragma solidity ^0.6.0;

interface TokenInterface {
    function approve(address, uint256) external;
    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
    function deposit() external payable;
    function withdraw(uint) external;
    function balanceOf(address) external view returns (uint);
    function decimals() external view returns (uint);
}

interface IUniswapV2Router02 {
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
    
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IUniswapV2Factory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint) external view returns (address pair);
  function allPairsLength() external view returns (uint);

  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);

  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
  function balanceOf(address owner) external view returns (uint);

  function approve(address spender, uint value) external returns (bool);
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint value) external returns (bool);

  function factory() external view returns (address);
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function price0CumulativeLast() external view returns (uint);
  function price1CumulativeLast() external view returns (uint);
}

contract UniswapHelpers {
    /**
     * @dev Return WETH address
     */
    function getAddressWETH() internal pure returns (address) {
        return 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // mainnet
        // return 0xd0A1E359811322d97991E03f863a0C30C2cF029C; // kovan
    }
    
    /**
     * @dev Return ethereum address
     */
    function getEthAddr() internal pure returns (address) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // ETH Address
    }

    /**
     * @dev Return uniswap v2 router02 Address
     */
    function getUniswapAddr() internal pure returns (address) {
        return 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    }

    function getExpectedBuyAmt(
        IUniswapV2Router02 router,
        address[] memory paths,
        uint sellAmt
    ) internal view returns(uint buyAmt) {
        uint[] memory amts = router.getAmountsOut(
            sellAmt,
            paths
        );
        buyAmt = amts[1];
    }

    function getPaths(
        address buyAddr,
        address sellAddr
    ) internal pure returns(address[] memory paths) {
        paths = new address[](2);
        paths[0] = address(sellAddr);
        paths[1] = address(buyAddr);
    }
    
        function checkPair(
        IUniswapV2Router02 router,
        address[] memory paths
    ) internal view {
        address pair = IUniswapV2Factory(router.factory()).getPair(paths[0], paths[1]);
        require(pair != address(0), "No-exchange-address");
    }
    
    
        function changeEthAddress(address buy, address sell) internal pure returns(TokenInterface _buy, TokenInterface _sell){
        _buy = buy == getAddressWETH() ? TokenInterface(getAddressWETH()) : TokenInterface(buy);
        _sell = sell == getAddressWETH() ? TokenInterface(getAddressWETH()) : TokenInterface(sell);
    }

}

contract Scalper is UniswapHelpers {
        event LogCheck(
        address indexed buyToken,
        address indexed sellToken,
        uint256 buyAmt,
        uint256 sellAmt,
        uint256 expectedAmtOut,
        uint256 buyAmtWETH
    );
    
     using SafeERC20 for IBEP20;
     using SafeMath for uint;
     
    address private _owner;

    constructor() public {
        _owner = msg.sender;
    }
  
        modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
      }
     
 function deposit(address erc20, uint tokenAmt) public virtual onlyOwner payable {
        uint amt = tokenAmt;
        if (erc20 != getEthAddr()) {
            IBEP20 token = IBEP20(erc20);
            amt = amt == uint(-1) ? token.balanceOf(msg.sender) : amt;
            token.transferFrom(msg.sender, address(this), amt);
        } else {
            require(msg.value == amt || amt == uint(-1), "invalid-ether-amount");
            amt = msg.value;
        }
    }

   /**
     * @dev Withdraw Assets To Smart Account.
     * @param erc20 Token Address.
     * @param tokenAmt Token Amount.
     * @param to Withdraw token address.
     */
    function withdraw(
        address erc20,
        uint tokenAmt,
        address payable to
    ) public virtual onlyOwner payable {
        // require(AccountInterface(address(this)).isAuth(to), "invalid-to-address");
        uint amt =  tokenAmt;
        if (erc20 == getEthAddr()) {
            amt = amt == uint(-1) ? address(this).balance : amt;
            to.transfer(amt);
        } else {
            IBEP20 token = IBEP20(erc20);
            amt = amt == uint(-1) ? token.balanceOf(address(this)) : amt;
            token.transfer(to, amt);
        }
    }
    
    function buy(
        address buyAddr,
        address sellAddr,
        uint sellAmt,
        uint slippage
    ) external onlyOwner payable {
        (TokenInterface _buyAddr, TokenInterface _sellAddr) = changeEthAddress(buyAddr, sellAddr);
        address[] memory paths = getPaths(address(buyAddr), address(sellAddr));
        
        IUniswapV2Router02 router = IUniswapV2Router02(getUniswapAddr());

        checkPair(router, paths);
    
         _sellAddr.approve(address(router), sellAmt);
        
        uint expectedAmt = getExpectedBuyAmt(router, paths, sellAmt);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            sellAmt,
            expectedAmt.mul(slippage).div(10000),
            paths,
             address(this),
            now + 1
        );
    }
    
        function sell(
        address buyAddr,
        address sellAddr,
        uint slippage
    ) external onlyOwner payable {
        (TokenInterface _buyAddr, TokenInterface _sellAddr) = changeEthAddress(buyAddr, sellAddr);
        address[] memory paths = getPaths(address(buyAddr), address(sellAddr));
        
        IUniswapV2Router02 router = IUniswapV2Router02(getUniswapAddr());

        checkPair(router, paths);
    
        uint _sellAmt = _sellAddr.balanceOf(address(this));
        
        uint expectedAmtOut = getExpectedBuyAmt(router, paths, _sellAmt);
        
        _sellAddr.approve(address(router), _sellAmt);
        
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _sellAmt,
            expectedAmtOut.mul(slippage).div(10000),
            paths,
            address(this),
            now + 1
        );
    }
    
function checkWithFees(
        address buyAddr,
        address sellAddr,
        uint sellAmt
    ) external onlyOwner payable {
        (TokenInterface _buyAddr, TokenInterface _sellAddr) = changeEthAddress(buyAddr, sellAddr);
        address[] memory paths = getPaths(address(buyAddr), address(sellAddr));
        address[] memory pathsInverse = getPaths(address(sellAddr), address(buyAddr));
        
        IUniswapV2Router02 router = IUniswapV2Router02(getUniswapAddr());

        checkPair(router, paths);
    
         _sellAddr.approve(address(router), sellAmt);
        
        uint expectedAmt = getExpectedBuyAmt(router, paths, sellAmt);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            sellAmt,
            expectedAmt,
            paths,
             address(this),
            now + 1
        );
        
        uint _buyAmt = _buyAddr.balanceOf(address(this));
        
        uint expectedAmtOut = getExpectedBuyAmt(router, pathsInverse, _buyAmt);
        
        _buyAddr.approve(address(router), _buyAmt);
        
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _buyAmt,
            expectedAmtOut,
            pathsInverse,
            address(this),
            now + 1
        );
        
    }
function checkWithFeesIncludingFees(
        address buyAddr,
        address sellAddr,
        uint sellAmt,
        uint slippage
    ) external onlyOwner payable {
        (TokenInterface _buyAddr, TokenInterface _sellAddr) = changeEthAddress(buyAddr, sellAddr);
        address[] memory paths = getPaths(address(buyAddr), address(sellAddr));
        address[] memory pathsInverse = getPaths(address(sellAddr), address(buyAddr));
        
        IUniswapV2Router02 router = IUniswapV2Router02(getUniswapAddr());

        checkPair(router, paths);
    
         _sellAddr.approve(address(router), sellAmt);
        
        uint expectedAmt = getExpectedBuyAmt(router, paths, sellAmt);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            sellAmt,
            expectedAmt.mul(slippage).div(10000),
            paths,
             address(this),
            now + 1
        );
        
        uint _buyAmt = _buyAddr.balanceOf(address(this));
        
        uint expectedAmtOut = getExpectedBuyAmt(router, pathsInverse, _buyAmt);
        
        _buyAddr.approve(address(router), _buyAmt);
        
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _buyAmt,
            expectedAmtOut.mul(slippage).div(10000),
            pathsInverse,
            address(this),
            now + 1
        );
    }    
function check(
        address buyAddr,
        address sellAddr,
        uint sellAmt
    ) external onlyOwner payable {
        (TokenInterface _buyAddr, TokenInterface _sellAddr) = changeEthAddress(buyAddr, sellAddr);
        address[] memory paths = getPaths(address(buyAddr), address(sellAddr));
        address[] memory pathsInverse = getPaths(address(sellAddr), address(buyAddr));
        
        IUniswapV2Router02 router = IUniswapV2Router02(getUniswapAddr());

        checkPair(router, paths);
        
        _sellAddr.approve(address(router), sellAmt);
        
        uint expectedAmt = getExpectedBuyAmt(router, paths, sellAmt);

        uint buyAmt = router.swapExactTokensForTokens(
            sellAmt,
            expectedAmt,
            paths,
            address(this),
            now + 1
        )[1];
        
        uint _buyAmt = _buyAddr.balanceOf(address(this));
        
        uint expectedAmtOut = getExpectedBuyAmt(router, pathsInverse, _buyAmt);
        
        _buyAddr.approve(address(router), _buyAmt);
        
        uint buyAmtWETH = router.swapExactTokensForTokens(
            _buyAmt,
            expectedAmtOut,
            pathsInverse,
            address(this),
            now + 1
        )[1];
        
        emit LogCheck(buyAddr, sellAddr, buyAmt, sellAmt, expectedAmtOut, buyAmtWETH);
    }    
    function checkIgnoringFees(
        address buyAddr,
        address sellAddr,
        uint sellAmt
    ) external onlyOwner payable {
        (TokenInterface _buyAddr, TokenInterface _sellAddr) = changeEthAddress(buyAddr, sellAddr);
        address[] memory paths = getPaths(address(buyAddr), address(sellAddr));
        address[] memory pathsInverse = getPaths(address(sellAddr), address(buyAddr));
        
        IUniswapV2Router02 router = IUniswapV2Router02(getUniswapAddr());

        checkPair(router, paths);
        
        _sellAddr.approve(address(router), sellAmt);
        
        uint expectedAmt = getExpectedBuyAmt(router, paths, sellAmt);

        uint buyAmt = router.swapExactTokensForTokens(
            sellAmt,
            expectedAmt / 2,
            paths,
            address(this),
            now + 1
        )[1];
        
        uint _buyAmt = _buyAddr.balanceOf(address(this));
        
        uint expectedAmtOut = getExpectedBuyAmt(router, pathsInverse, _buyAmt);
        
        _buyAddr.approve(address(router), _buyAmt);
        
        uint buyAmtWETH = router.swapExactTokensForTokens(
            _buyAmt,
            expectedAmtOut / 2,
            pathsInverse,
            address(this),
            now + 1
        )[1];
        
        emit LogCheck(buyAddr, sellAddr, buyAmt, sellAmt, expectedAmtOut, buyAmtWETH);
    }  
    }