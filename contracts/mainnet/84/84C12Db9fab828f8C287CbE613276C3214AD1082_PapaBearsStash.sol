/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

//SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.12;


abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}



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



library Address {

    /**
     * @dev Returns true if `account` is a contract.
     *
     * [////IMPORTANT]
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
     * ////IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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


interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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
     * ////IMPORTANT: Beware that changing an allowance with this method brings the risk
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

    contract PapaBearsStash is ReentrancyGuard {
    
    using Address for address;
    using SafeMath for uint256;
  
    /**  CokeBear Stats  **/
    uint256 constant totalSupply = 10 * 10**9 * 10**9;
    address constant _burnWallet = 0x000000000000000000000000000000000000dEaD;
    address constant _token = 0xa7FC34C614B23b5c143ce57169186d4898C2eb0a;
    address constant private _tokenLP = 0xE7637b954eBf69326435b9A12F292eBD104f7A9a;
  
    /** address of wrapped bnb **/ 
    address constant private _bnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    /** Liquidity Pairing Threshold **/
    uint256 constant public pairLiquidityCokeBearThreshold = 5 * 10**16;
  
    /** Expressed as 100 / x **/
    uint256 constant public pullLiquidityRange = 5;
    uint256 constant public buyAndBurnRange = 8;
    uint256 constant public reverseSALRange = 15;
  
    /** BNB Thresholds **/
    uint256 constant public automateThreshold = 2 * 10**17;
    uint256 constant max_bnb_in_call = 50 * 10**18;
  
    /** Pancakeswap Router **/
    IUniswapV2Router02 constant router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  
    /** Flash-Loan Prevention **/
    uint256 lastBlockAutomated;
        
    /** BNB -> Token **/
    address[] private bnbToToken;

    constructor() {
        // BNB -> Token
        bnbToToken = new address[](2);
        bnbToToken[0] = router.WETH();
        bnbToToken[1] = _token;
    }
  
    /** Automate Function */
    function Pablo_Found_The_STASH() external nonReentrant {
        require(address(this).balance >= automateThreshold, 'Not Enough BNB To Trigger Automation');
        require(lastBlockAutomated + 3 < block.number, '4 Blocks Must Pass Until Next Trigger');
        lastBlockAutomated = block.number;
        automate();
    }

    /** Automate Function */
    function automate() private {
        // check CokeBear standing
        checkCokeBearStanding();
        // determine the health of the lp
        uint256 dif = determineLPHealth();
        // check cases
        dif = clamp(dif, 1, 100);
    
        if (dif <= pullLiquidityRange) {
            uint256 percent = uint256(100).div(dif);
            // pull liquidity
            pullLiquidity(percent);
        } else if (dif <= buyAndBurnRange) {
            // if LP is over 12.5% of Supply we buy burn CokeBear
            buyAndBurn();
        } else if (dif <= reverseSALRange) {
            // if LP is between 6.666%-12.5% of Supply we call reverseSAL
            reverseSwapAndLiquify();
        } else {
            // if LP is under 6.666% of Supply we provide a pairing if one exists, else we call reverseSAL
            uint256 tokenBal = IERC20(_token).balanceOf(address(this));
            if (liquidityThresholdReached(tokenBal)) {
                pairLiquidity(tokenBal);
            } else {
                reverseSwapAndLiquify();
            }
        }
    }

    /**
     * Buys CokeBear Tokens and sends them to the burn wallet
     */ 
    function buyAndBurn() private {
        // keep bnb in range
        uint256 bnbToUse = address(this).balance > max_bnb_in_call ? max_bnb_in_call : address(this).balance;
        // buy and burn it
        router.swapExactETHForTokens{value: bnbToUse}(
            0, 
            bnbToToken,
            _burnWallet, // Burn Address
            block.timestamp.add(30)
        );
        // tell blockchain
        emit BuyAndBurn(bnbToUse);
    }
  
   /**
    * Uses BNB in Contract to Purchase CokeBear, pairs with remaining BNB and adds to Liquidity Pool
    * Reversing The Effects Of SwapAndLiquify
    * Price Positive - LP Neutral Operation
    */
    function reverseSwapAndLiquify() private {
        // BNB Balance before the swap
        uint256 initialBalance = address(this).balance > max_bnb_in_call ? max_bnb_in_call : address(this).balance;
        // CokeBear Balance before the Swap
        uint256 contractBalance = IERC20(_token).balanceOf(address(this));
        // Swap 50% of the BNB in Contract for CokeBear Tokens
        uint256 transferAMT = initialBalance.div(2);
        // Swap BNB for CokeBear
        router.swapExactETHForTokens{value: transferAMT}(
            0, // accept any amount of CokeBear
            bnbToToken,
            address(this), // Store in Contract
            block.timestamp.add(30)
        );
        // how many CokeBear Tokens were received
        uint256 diff = IERC20(_token).balanceOf(address(this)).sub(contractBalance);
        // add liquidity to Pancakeswap
        addLiquidity(diff, transferAMT);
        emit ReverseSwapAndLiquify(diff, transferAMT);
    }
   
    /**
     * Pairs BNB and CokeBear in the contract and adds to liquidity if we are above thresholds 
     */
    function pairLiquidity(uint256 CokeBearInContract) private {
        // amount of bnb in the pool
        uint256 bnbLP = IERC20(_bnb).balanceOf(_tokenLP);
        // make sure we have tokens in LP
        bnbLP = bnbLP == 0 ? address(_tokenLP).balance : bnbLP;
        // how much BNB do we need to pair with our CokeBear
        uint256 bnbbal = getTokenInToken(_token, _bnb, CokeBearInContract);
        //if there isn't enough bnb in contract
        if (address(this).balance < bnbbal) {
            // recalculate with bnb we have
            uint256 nCokeBear = CokeBearInContract.mul(address(this).balance).div(bnbbal);
            addLiquidity(nCokeBear, address(this).balance);
            emit LiquidityPairAdded(nCokeBear, address(this).balance);
        } else {
            // pair liquidity as is 
            addLiquidity(CokeBearInContract, bnbbal);
            emit LiquidityPairAdded(CokeBearInContract, bnbbal);
        }
    }
    
    /** Checks Number of Tokens in LP */
    function checkCokeBearStanding() private {
        uint256 threshold = getCirculatingSupply().div(10**4);
        uint256 CokeBearBalance = IERC20(_token).balanceOf(address(this));
        if (CokeBearBalance >= threshold) {
            // burn 1/4 of balance
            try IERC20(_token).transfer(_burnWallet, CokeBearBalance.div(4)) {} catch {}
        }
    }
   
    /** Returns the price of tokenOne in tokenTwo according to Pancakeswap */
    function getTokenInToken(address tokenOne, address tokenTwo, uint256 amtTokenOne) public view returns (uint256){
        address[] memory path = new address[](2);
        path[0] = tokenOne;
        path[1] = tokenTwo;
        return router.getAmountsOut(amtTokenOne, path)[1];
    } 
    
    /**
     * Adds CokeBear and BNB to the CokeBear/BNB Liquidity Pool
     */ 
    function addLiquidity(uint256 CokeBearAmount, uint256 bnbAmount) private {
       
        // approve router to move tokens
        IERC20(_token).approve(address(router), CokeBearAmount);
        // add the liquidity
        try router.addLiquidityETH{value: bnbAmount}(
            _token,
            CokeBearAmount,
            0,
            0,
            address(this),
            block.timestamp.add(30)
        ) {} catch{}
    }

    /**
     * Removes Liquidity from the pool and stores the BNB and CokeBear in the contract
     */
    function pullLiquidity(uint256 percentLiquidity) private returns (bool){
       // Percent of our LP Tokens
       uint256 pLiquidity = IERC20(_tokenLP).balanceOf(address(this)).mul(percentLiquidity).div(10**2);
       // Approve Router 
       IERC20(_tokenLP).approve(address(router), 115792089237316195423570985008687907853269984665640564039457584007913129639935);
       // remove the liquidity
       try router.removeLiquidityETHSupportingFeeOnTransferTokens(
            _token,
            pLiquidity,
            0,
            0,
            address(this),
            block.timestamp.add(30)
        ) {} catch {return false;}
        
        emit LiquidityPulled(percentLiquidity, pLiquidity);
        return true;
    }
    
    /**
     * Determines the Health of the LP
     * returns the percentage of the Circulating Supply that is in the LP
     */ 
    function determineLPHealth() public view returns(uint256) {
        // Find the balance of CokeBear in the liquidity pool
        uint256 lpBalance = IERC20(_token).balanceOf(_tokenLP);
        // lpHealth = Supply / LP Balance
        return lpBalance == 0 ? 6 : getCirculatingSupply().div(lpBalance);
    }
    
    /** Whether or not the Pair Liquidity Threshold has been reached */
    function liquidityThresholdReached(uint256 bal) private view returns (bool) {
        uint256 circulatingSupply = getCirculatingSupply();
        uint256 pow = circulatingSupply < (10**10 * 10**9) ? 5 : 7;
        return bal >= getCirculatingSupply().div(10**pow);
    }
  
    /** Returns the Circulating Supply of Token */
    function getCirculatingSupply() private view returns(uint256) {
        return totalSupply.sub(IERC20(_token).balanceOf(_burnWallet));
    }
  
    /** Amount of LP Tokens in this contract */ 
    function getLPTokenBalance() external view returns (uint256) {
        return IERC20(_tokenLP).balanceOf(address(this));
    }
  
    /** Percentage of LP Tokens In Contract */
    function getPercentageOfLPTokensOwned() external view returns (uint256) {
        return uint256(10**18).mul(IERC20(_tokenLP).balanceOf(address(this))).div(IERC20(_tokenLP).totalSupply());
    }
      
    /** Clamps a variable between a min and a max */
    function clamp(uint256 variable, uint256 min, uint256 max) private pure returns (uint256){
        if (variable <= min) {
            return min;
        } else if (variable >= max) {
            return max;
        } else {
            return variable;
        }
    }
  
    // EVENTS 
    event BuyAndBurn(uint256 amountBNBUsed);
    event ReverseSwapAndLiquify(uint256 CokeBearAmount,uint256 bnbAmount);
    event LiquidityPairAdded(uint256 CokeBearAmount,uint256 bnbAmount);
    event LiquidityPulled(uint256 percentOfLiquidity, uint256 numLPTokens);

    // Receive BNB
    receive() external payable { }

}