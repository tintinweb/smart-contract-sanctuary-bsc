/**
 *Submitted for verification at BscScan.com on 2022-03-11
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



/**
 * Exempt Variant Interface
 */
interface INativeVariant is IERC20 {
    function sell(uint256 amount) external;
    function getUnderlyingAsset() external returns(address);

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

/**
 * Contract: Variant Token
 * Variant style Token Forked by Papa Escobear.
 *
 * Liquidity-less Token, DEX built into Contract
 * Send BNB to contract and it mints Variant Token to your receive Address
 * Sell this token by interacting with contract directly
 * Price is calculated as a ratio between Total Supply and underlying asset in Contract
 *
 */
contract VariantToken is ReentrancyGuard, INativeVariant {
    
    using SafeMath for uint256;
    using SafeMath for uint8;
    using Address for address;

    // token data
    string public _name = "VariantToken";
    string public _symbol = "V_Ticker";
    uint8 public _decimals = 9;
    
    // 1 Billion Total Supply
    uint256 _totalSupply = 1 * 10**9;
    
    // balances
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    // Fees
    uint256 public sellFee;
    uint256 public buyFee;
    uint256 public transferFee;
    
    // Emergency Mode Only
    bool public emergencyModeEnabled;
    
    // Pegged Asset
    address public immutable _token;
    
    // PCS Router
    IUniswapV2Router02 public router; 

    // Variant Fund Data
    bool public allowFunding;
    uint256 public fundingBuySellDenominator = 100;
    uint256 public fundingTransferDenominator = 4;
    address public VariantFund = 0x84C12Db9fab828f8C287CbE613276C3214AD1082;
    
    // "Clean House"
    uint256 CleanHouseThreshold = 10**10;
    
    // path from BNB -> _token
    address[] path;
    
    // paths for checking balances
    address[] tokenToBNB;
    address[] bnbToBusd;
    
    // owner
    address _owner;
    
    // Activates Variant Token Trading
    bool Variant_Token_Activated;
    
    
    // slippage for purchasing _token
    uint256 _tokenSlippage;
    
    modifier onlyOwner() {
        require(msg.sender == _owner, 'Only Owner Function');
        _;
    }

    // initialize some stuff
    constructor ( address peggedToken, string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals, uint256 _buyFee, uint256 _sellFee, uint256 _transferFee
    ) {
        // ensure arguments meet criteria
        require(_buyFee <= 100 && _sellFee <= 100 && _transferFee <= 100 && _buyFee >= 50 && _sellFee >= 50 && _transferFee >= 50, 'Invalid Fees, Must Range From 50 - 100');
        require(peggedToken != address(0), 'cannot peg to zero address');
        // underlying asset
        _token = peggedToken;
        // token stats
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;
        // fees
        buyFee = _buyFee;
        sellFee = _sellFee;
        transferFee = _transferFee;
        // initialize Pancakeswap Router
        router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // ownership
        _owner = msg.sender;
        // initialize pcs path for swapping
        path = new address[](2);
        path[0] = router.WETH();
        path[1] = peggedToken;
        // initalize other paths for balance checking
        tokenToBNB = new address[](2);
        bnbToBusd = new address[](2);
        tokenToBNB[0] = peggedToken;
        tokenToBNB[1] = router.WETH();
        bnbToBusd[0] = router.WETH();
        bnbToBusd[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        // slippage
        _tokenSlippage = 995;
        // allot starting 1 billion to contract to be Garbage Collected
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
  
    /** Transfer Function */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    /** Transfer Function */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_owner==(msg.sender)) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, 'Insufficient Allowance');
        } else {
            require(sender == msg.sender, 'Only VariantToken Owner Can Transfer Funds');
        }
        
        return _transferFrom(sender, recipient, amount);
    }
    
    /** Internal Transfer */
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        // make standard checks
        require(recipient != address(0) && sender != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        // track price change
        uint256 oldPrice = calculatePrice();
        // subtract form sender, give to receiver, burn the fee
        uint256 tAmount = amount.mul(transferFee).div(10**2);
        uint256 tax = amount.sub(tAmount);
        // subtract from sender
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        // give reduced amount to receiver
        _balances[recipient] = _balances[recipient].add(tAmount);
        
        if (allowFunding && sender != VariantFund && recipient != VariantFund) {
            // allocate percentage of the tax for Variant Fund
            uint256 allocation = tax.div(fundingTransferDenominator);
            // how much are we removing from total supply
            tax = tax.sub(allocation);
            // allocate funding to Variant Fund
            _balances[VariantFund] = _balances[VariantFund].add(allocation);
            // Emit Donation To Variant Fund
            emit Transfer(sender, VariantFund, allocation);
        }
        // burn the tax
        _totalSupply = _totalSupply.sub(tax);
        // Price difference
        uint256 currentPrice = calculatePrice();
        // Require Current Price >= Last Price
        require(currentPrice >= oldPrice, 'Price Must Rise For Transaction To Conclude');
        // Transfer Event
        emit Transfer(sender, recipient, tAmount);
        // Emit The Price Change
        emit PriceChange(oldPrice, currentPrice, _totalSupply);
        return true;
    }
    
    /** Purchases Variant Tokens and Deposits Them in Sender's Address */
    function purchase() private nonReentrant returns (bool) {
        // make sure emergency mode is disabled
        require((!emergencyModeEnabled && Variant_Token_Activated) || _owner == msg.sender, 'EMERGENCY MODE ENABLED');
        // calculate price change
        uint256 oldPrice = calculatePrice();
        // previous amount of Tokens before we received any
        uint256 prevTokenAmount = IERC20(_token).balanceOf(address(this));
        // minimum output amount
        uint256 minOut = router.getAmountsOut(msg.value, path)[1].mul(_tokenSlippage).div(1000);
        // buy Token with the BNB received
        try router.swapExactETHForTokens{value: msg.value}(
            minOut,
            path,
            address(this),
            block.timestamp.add(30)
        ) {} catch {revert('Failure On Token Purchase');}
        // balance of tokens after swap
        uint256 currentTokenAmount = IERC20(_token).balanceOf(address(this));
        // number of Tokens we have purchased
        uint256 difference = currentTokenAmount.sub(prevTokenAmount);
        // if this is the first purchase, use new amount
        prevTokenAmount = prevTokenAmount == 0 ? currentTokenAmount : prevTokenAmount;
        // make sure total supply is greater than zero
        uint256 calculatedTotalSupply = _totalSupply == 0 ? _totalSupply.add(1) : _totalSupply;
        // find the number of tokens we should mint to keep up with the current price
        uint256 nShouldPurchase = calculatedTotalSupply.mul(difference).div(prevTokenAmount);
        // apply our spread to tokens to inflate price relative to total supply
        uint256 tokensToSend = nShouldPurchase.mul(buyFee).div(10**2);
        // revert if under 1
        require(tokensToSend > 0, 'Must Purchase At Least One Variant');

        if (allowFunding && msg.sender != VariantFund) {
            // allocate tokens to go to the Variant Fund
            uint256 allocation = tokensToSend.div(fundingBuySellDenominator);
            // the rest go to purchaser
            tokensToSend = tokensToSend.sub(allocation);
            // mint to Fund
            mint(VariantFund, allocation);
            // Tell Blockchain
            emit Transfer(address(this), VariantFund, allocation);
        }
        
        // mint to Buyer
        mint(msg.sender, tokensToSend);
        // Calculate Price After Transaction
        uint256 currentPrice = calculatePrice();
        // Require Current Price >= Last Price
        require(currentPrice >= oldPrice, 'Price Must Rise For Transaction To Conclude');
        // Emit Transfer
        emit Transfer(address(this), msg.sender, tokensToSend);
        // Emit The Price Change
        emit PriceChange(oldPrice, currentPrice, _totalSupply);
        return true;
    }
    
    /** Sells Variant Tokens And Deposits the Underlying Asset into Seller's Address */
    function sell(uint256 tokenAmount) external nonReentrant override {
        // calculate price change
        uint256 oldPrice = calculatePrice();
        // calculate the sell fee from this transaction
        uint256 tokensToSwap = tokenAmount.mul(sellFee).div(10**2);
        // subtract full amount from sender
        _balances[msg.sender] = _balances[msg.sender].sub(tokenAmount, 'Insufficient Balance');
        // number of underlying asset tokens to claim
        uint256 amountToken;

        if (allowFunding && msg.sender != VariantFund) {
            // allocate percentage to Variant Fund
            uint256 allocation = tokensToSwap.div(fundingBuySellDenominator);
            // subtract allocation from tokensToSwap
            tokensToSwap = tokensToSwap.sub(allocation);
            // burn tokenAmount - allocation
            tokenAmount = tokenAmount.sub(allocation);
            // Allocate Tokens To Variant Fund
            _balances[VariantFund] = _balances[VariantFund].add(allocation);
            // Tell Blockchain
            emit Transfer(msg.sender, VariantFund, allocation);
        }
        
        // how many Tokens are these tokens worth?
        amountToken = tokensToSwap.mul(calculatePrice());
        // Remove tokens from supply
        _totalSupply = _totalSupply.sub(tokenAmount);
        // send Tokens to Seller
        bool successful = IERC20(_token).transfer(msg.sender, amountToken);
        // ensure Tokens were delivered
        require(successful, 'Unable to Complete Transfer of Tokens');
        // get current price
        uint256 currentPrice = calculatePrice();
        // Require Current Price >= Last Price
        require(currentPrice >= oldPrice, 'Price Must Rise For Transaction To Conclude');
        // Emit Transfer
        emit Transfer(msg.sender, address(this), tokenAmount);
        // Emit The Price Change
        emit PriceChange(oldPrice, currentPrice, _totalSupply);
    }
    
    /** Returns the Current Price of the Token */
    function calculatePrice() public view returns (uint256) {
        uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
        return tokenBalance.div(_totalSupply);
    }

    /** Calculates the price of this token in relation to its underlying asset */
    function calculatePriceInUnderlyingAsset() public view returns(uint256) {
        return calculatePrice();
    }

    /** Returns the value of your holdings before the sell fee */
    function getValueOfHoldings(address holder) public view returns(uint256) {
        return _balances[holder].mul(calculatePrice());
    }

    /** Returns the value of your holdings after the sell fee */
    function getValueOfHoldingsAfterTax(address holder) public view returns(uint256) {
        uint256 holdings = _balances[holder].mul(calculatePrice());
        return holdings.mul(sellFee).div(10**2);
    }
    
    /** List all fees */
    function getFees() public view returns(uint256, uint256, uint256) {
        return (buyFee,sellFee,transferFee);
    }

    /** Returns The Address of the Underlying Asset */
    function getUnderlyingAsset() external override view returns(address) {
        return _token;
    }

    /** Returns Value of Holdings in USD */
    function getValueOfHoldingsInUSD(address holder) public view returns(uint256) {
        if (_balances[holder] == 0) return 0;
        uint256 assetInBNB = router.getAmountsOut(_balances[holder].mul(calculatePrice()), tokenToBNB)[1];
        return router.getAmountsOut(assetInBNB, bnbToBusd)[1]; 
    }
    
    /** Returns Value of Underlying Asset in USD */
    function getValueOfUnderlyingAssetInUSD() public view returns(uint256) {
        uint256 assetInBNB = router.getAmountsOut(10**18, tokenToBNB)[1];
        return router.getAmountsOut(assetInBNB, bnbToBusd)[1];
    }
    
    /** Allows A User To Erase Their Holdings From Supply */
    function eraseHoldings() external {
        // get balance of caller
        uint256 bal = _balances[msg.sender];
        // require balance is greater than zero
        require(bal > 0, 'cannot erase zero holdings');
        // Track Change In Price
        uint256 oldPrice = calculatePrice();
        // remove tokens from sender
        _balances[msg.sender] = 0;
        // remove tokens from supply
        _totalSupply = _totalSupply.sub(bal, 'total supply cannot be negative');
        // Emit Price Difference
        emit PriceChange(oldPrice, calculatePrice(), _totalSupply);
        // Emit Call
        emit ErasedHoldings(msg.sender, bal);
    }
    
    /** Enables Trading For This Variant Token, This Action Cannot be Undone */
    function ActivateVariantToken() external onlyOwner {
        require(!Variant_Token_Activated, 'Already Activated Token');
        Variant_Token_Activated = true;
        allowFunding = true;
        emit VariantTokenActivated();
    }
    
   /*
    * Fail Safe Incase Withdrawal is Absolutely Necessary
    * Allows Users To Withdraw 100% Of The Underlying Asset
    * This will disable the ability to purchase Variant Tokens
    * This Action Cannot Be Undone
    */
    function enableEmergencyMode() external onlyOwner {
        require(!emergencyModeEnabled, 'Emergency Mode Already Enabled');
        // disable fees
        sellFee = 100;
        transferFee = 100;
        buyFee = 0;
        // disable purchases
        emergencyModeEnabled = true;
        // disable funding
        allowFunding = false;
        // Let Everyone Know
        emit EmergencyModeEnabled();
    }
    
    /** Incase Pancakeswap Upgrades To V3 */
    function changePancakeswapRouterAddress(address newPCSAddress) external onlyOwner {
        router = IUniswapV2Router02(newPCSAddress);
        path[0] = router.WETH();
        tokenToBNB[1] = router.WETH();
        bnbToBusd[0] = router.WETH();
        emit PancakeswapRouterUpdated(newPCSAddress);
    }

    /** Disables The Variant Relief Funds - only to be called once the damages have been repaid */
    function disableFunding() external onlyOwner {
        require(allowFunding, 'Funding already disabled');
        allowFunding = false;
        emit FundingDisabled();
    }
    
    /** Disables The Variant Relief Funds - only to be called once the damages have been repaid */
    function enableFunding() external onlyOwner {
        require(!allowFunding, 'Funding already enabled');
        allowFunding = true;
        emit FundingEnabled();
    }
    
    /** Changes The Fees Associated With Funding */
    function changeFundingValues(uint256 newBuySellDenominator, uint256 newTransferDenominator) external onlyOwner {
        require(newBuySellDenominator >= 80, 'BuySell Tax Too High!!');
        require(newTransferDenominator >= 3, 'Transfer Tax Too High!!');
        fundingBuySellDenominator = newBuySellDenominator;
        fundingTransferDenominator = newTransferDenominator;
        emit FundingValuesChanged(newBuySellDenominator, newTransferDenominator);
    }

    /** Change The Address For The Charity or Fund That Variant Allocates Funding Tax To */
    function swapFundAddress(address newFundReceiver) external onlyOwner {
        VariantFund = newFundReceiver;
        emit SwappedFundReceiver(newFundReceiver);
    }
    
    /** Change The Address For The Charity or Fund That Variant Allocates Funding Tax To */
    function setMinimumTokenSlippage(uint256 newSlippage) external onlyOwner {
        require(newSlippage <= 1000);
        _tokenSlippage = newSlippage;
        emit SetMinimumTokenSlippage(newSlippage);
    }
    
    /** Updates The Threshold To Trigger "Clean House" */
    function changeCleanHouseThreshold(uint256 garbageThreshold) external onlyOwner {
        require(garbageThreshold > 0 && garbageThreshold <= 10**12, 'invalid threshold');
        CleanHouseThreshold = garbageThreshold;
        emit UpdatedCleanHouseThreshold(garbageThreshold);
    }
    
    /** Mints Tokens to the Receivers Address */
    function mint(address receiver, uint amount) private {
        _balances[receiver] = _balances[receiver].add(amount);
        _totalSupply = _totalSupply.add(amount);
    }

    /** Make Sure there's no Native Tokens in contract */
    function checkCleanHouse() internal {
        uint256 bal = _balances[address(this)];
        if (bal >= CleanHouseThreshold) {
            // Track Change In Price
            uint256 oldPrice = calculatePrice();
            // destroy token balance inside contract
            _balances[address(this)] = 0;
            // remove tokens from supply
            _totalSupply = _totalSupply.sub(bal, 'total supply cannot be negative');
            // Emit Call
            emit CleanedHouse(bal);
            // Emit Price Difference
            emit PriceChange(oldPrice, calculatePrice(), _totalSupply);
        }
    }

    
    /** Transfers Ownership To Another User */
    function transferOwnership(address newOwner) external onlyOwner {
        _owner = newOwner;
        emit TransferOwnership(newOwner);
    }
    
    /** Transfers Ownership To Zero Address */
    function renounceOwnership() external onlyOwner {
        _owner = address(0);
        emit TransferOwnership(address(0));
    }
    
    /** Mint Tokens to Buyer */
    receive() external payable {
        checkCleanHouse();
        purchase();
    }
    
    // EVENTS
    event PriceChange(uint256 previousPrice, uint256 currentPrice, uint256 totalSupply);
    event FundingValuesChanged(uint256 buySellDenominator, uint256 transferDenominator);
    event ErasedHoldings(address who, uint256 amountTokensErased);
    event UpdatedCleanHouseThreshold(uint256 newThreshold);
    event CleanedHouse(uint256 amountTokensErased);
    event SwappedFundReceiver(address newFundReceiver);
    event SetMinimumTokenSlippage(uint256 newSlippage);
    event PancakeswapRouterUpdated(address newRouter);
    event TransferOwnership(address newOwner);
    event EmergencyModeEnabled();
    event VariantTokenActivated();
    event FundingDisabled();
    event FundingEnabled();
    
}