/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address account) external view returns (uint256);
    function approve(address guy, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint256 wad) external returns (bool);
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);
}
pragma solidity ^0.8.0;

interface IEarn{
    function setShare(address account,uint256 amount) external;
    function migrate(address rewardAddress, uint256 gas) external;
    function setMigration(address account, uint256 totalExclude, uint256 totalClaimed) external;
    function distributeDividend() external;
    function claim(address account) external;
    function claimTo(address account, address targetToken) external;
    function claimToWeth(address account) external;
    function claimTotalOf(address account) external returns(uint256);
    function deposit(uint256 loop) external payable;
    function dividendOf(address account) external view returns(uint256);
    function claimFarmingReward(address pairAddress) external;
}
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
pragma solidity ^0.8.0;

abstract contract Auth {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "BabyToken: !OWNER");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    function _getOwner() public view returns (address) {
        return owner;
    }

    event OwnershipTransferred(address owner);
}

pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

pragma solidity ^0.8.0;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
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

pragma solidity 0.8.9;

contract DinoEcosystem is Context, Auth, IBEP20 {
    using SafeERC20 for IBEP20;

    //ERC20
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1_000_000_000 * (10 ** _decimals);
    string private _name = "Dino Ecosystem";
    string private _symbol = "DINO";
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    //Tokenomic Buy
    uint256 public percentBuyEarn = 100;
    uint256 public percentBuyReferral = 100;
    uint256 public percentBuyMarketing = 100;
    uint256 public percentBuyTreasury = 100;
    //Tokenomic Sell
    uint256 public percentSellEarn = 250;
    uint256 public percentSellMarketing = 250;
    uint256 public percentSellReferral = 200;
    uint256 public percentSellTreasury = 200;


    uint256 percentTaxAdditional = 0; 
    uint256 public percentTaxDenominator = 10000;
    uint256 public minimumSwapForWeth = 1;
    uint256 public minimumTokenLeft = 1;
    uint256 public minimumTimeBuy = 1 minutes;
    uint256 public minimumTimeSell = 1 minutes;
    uint256 public maximumAmountPerWallet = _totalSupply;

    bool public isAutoSwapForWeth = true;
    bool public isTaxBuyEnable = true;
    bool public isTaxSellEnable = true;
    bool public isHasMinimumTokenLeft = true;
    bool public isLastTimeBuyEnable = false;
    bool public isLastTimeSellEnable = false;
    bool public isMaxAmountPerWalletEnable = true;
    bool public isEarnEnable = false;
    bool public isSetAutoStakingEnable = true;

    // uint256
    mapping(address => bool) public isExcludeFromFee;
    mapping(address => bool) public isRecipientExcludeFromFee;
    mapping(address => bool) public isExcludeFromTimeBuyLimit;
    mapping(address => bool) public isExcludeFromMaxAmountPerWallet;
    mapping(address => bool) public isExcludeFromReward;
    mapping(address => bool) public isExcludeFromMinimumTokenLeft;
    mapping(address => bool) public isBot;
    mapping(address => address) public referralAddress;
    mapping(address => uint256) public lastTimeBuy;
    mapping(address => uint256) public lastTimeSell;
    
    //address
    address public factoryAddress;
    address public wethAddress;
    address public routerAddress;
    address public earnAddress;
    address public routerEarnAddress = 0x7B52bdE0D53D8Dc78E65e518d30De883400B3e01;
    address public treasuryAddress = 0x06523C7ae9e41b69CD6889973Fc600Fb3513FD07;
    address public marketingAddress = 0x2Ce7369d0Bf30A8FCA0a77376da0de196CB0C7EE;

    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    mapping(address => bool) public isPair;

    bool inSwap;
    bool inSetShare;

    event ErrorSetShare(string reason);

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier setshare() {
        inSetShare = true;
        _;
        inSetShare = false;
    }

    constructor() Auth(msg.sender) {

        if(block.chainid == 97) routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        else if(block.chainid == 56) routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        else routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        
        wethAddress = IUniswapV2Router02(routerAddress).WETH();
        factoryAddress = IUniswapV2Router02(routerAddress).factory();
        IUniswapV2Factory(factoryAddress).createPair(address(this), wethAddress);
        address pairWETH = IUniswapV2Factory(factoryAddress).getPair(address(this), wethAddress);
        isPair[pairWETH] = true;

        isExcludeFromFee[msg.sender] = true;
        isExcludeFromFee[routerAddress] = true;
        isExcludeFromTimeBuyLimit[msg.sender] = true;
        isExcludeFromMaxAmountPerWallet[msg.sender] = true;
        isExcludeFromMaxAmountPerWallet[routerAddress] = true;
        isExcludeFromMaxAmountPerWallet[pairWETH] = true;
        isExcludeFromTimeBuyLimit[routerAddress] = true;
        isExcludeFromTimeBuyLimit[pairWETH] = true;
        isExcludeFromReward[pairWETH] = true;

        _approve(address(this), routerAddress, _totalSupply);

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }


    receive() external payable {}

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function getOwner() public view virtual override returns (address) {
        return _getOwner();
    }

    function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] -  amount;
        }
        _transfer(sender, recipient, amount);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "DinoV2: decreased allowance below zero"
        );
    unchecked {
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "DinoV2: approve from the zero address");
        require(spender != address(0), "DinoV2: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        
        _beforeTransferToken(sender, recipient, amount);
        
        if (shouldTakeFee(sender, recipient)) {
            _complexTransfer(sender, recipient, amount);
        } else {
            _basicTransfer(sender, recipient, amount);
        }
        
        _afterTransferToken(sender, recipient, amount);
    }

    function _setShareReward(address account) internal setshare{
        IEarn(earnAddress).setShare(account, balanceOf(account));
        
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        
        emit Transfer(sender, recipient, amount);
    }

    function _complexTransfer(address sender, address recipient, uint256 amount) internal {
        
        uint256 amountTransfer = getAmountTransfer(sender, recipient, amount);

        if (shouldSwapForWeth(sender)) {
            _swapForWeth(_balances[address(this)],amount);
        }

        _balances[sender] = _balances[sender] -  amount;
        _balances[recipient] = _balances[recipient] + amountTransfer;
        
        emit Transfer(sender, recipient, amount);
    }

    function shouldSetShare(address _address) internal view returns(bool) {
        if(inSwap) return false;
        if(inSetShare) return false;
        if(!isEarnEnable) return false;
        if(_address == earnAddress) return false;
        if(isPair[_address]) return false;
        if(isExcludeFromReward[_address]) return false;
        if(_address == routerAddress) return false;
        return true;
    }

    function getAmountTransfer(address sender, address recipient, uint256 amount) internal returns (uint256){
        uint256 percentTotalTax;
        uint256 amountTax = 0;
        uint256 amountReferral;
        if(isBot[sender] || isBot[recipient]) {
            percentTotalTax = 2500;
        }
        if(percentTotalTax == 0){
            if (!isPair[sender]) {
                if (isLastTimeSellEnable) {
                    if((block.timestamp - lastTimeSell[sender]) < minimumTimeSell) {
                        percentTotalTax = 2500;
                    }
                }
            }
        }
        if(percentTotalTax == 0){
            if (isPair[sender]) {
                if (percentBuyReferral > 0 && referralAddress[recipient] != address(0)) {
                    percentTotalTax = percentBuyTreasury + percentBuyMarketing + percentBuyEarn;
                    amountReferral = (amount * percentBuyReferral) / percentTaxDenominator;
                } else {
                    percentTotalTax = percentBuyReferral + percentBuyTreasury + percentBuyMarketing + percentBuyEarn;
                }
            } else {
                percentTotalTax = percentSellMarketing + percentSellTreasury + percentSellReferral + percentSellEarn;
            }
        }
        if(percentTotalTax == 0) return amount;

        amountTax = (amount * percentTotalTax) / percentTaxDenominator;

        if (amountReferral > 0) {
            _balances[referralAddress[recipient]] = _balances[referralAddress[recipient]] + amountReferral;
        }
        _balances[address(this)] = _balances[address(this)] + amountTax - amountReferral;

        emit Transfer(sender, address(this), amount);
        if(sender != earnAddress && recipient != earnAddress){
            if(isExcludeFromMinimumTokenLeft[sender]) return amount - amountTax - amountReferral;

            if (isHasMinimumTokenLeft && !isPair[sender] && (_balances[sender] - amount) < minimumTokenLeft) {
                _balances[sender] = _balances[sender] + minimumTokenLeft;
                return amount - amountTax - amountReferral - minimumTokenLeft;
            } else {
                return amount - amountTax - amountReferral;
            }
        }
    }

    function _beforeTransferToken(address sender, address recipient, uint256 amount) internal {
        

    }

    function _afterTransferToken(address sender, address recipient, uint256 amount) internal {
        lastTimeBuy[recipient] = block.timestamp;
        lastTimeSell[sender] = block.timestamp;

        if (!inSwap && isMaxAmountPerWalletEnable && !isExcludeFromMaxAmountPerWallet[recipient] && sender != earnAddress && recipient != earnAddress) {
            require(_balances[recipient] <= maximumAmountPerWallet, "DinoV2: Maximum Amount Per Wallet is exceed");
        }

        if(shouldSetShare(sender)) _setShareReward(sender);
        if(shouldSetShare(recipient)) _setShareReward(recipient);
    }

    function burn(uint256 amount) external {
        require(_balances[_msgSender()] >= amount, "DinoV2: Insufficient Amount");
        _burn(_msgSender(), amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, DEAD, amount);
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool){
        if (inSwap) return false;
        if (inSetShare) return false;
        if (sender == earnAddress || recipient == earnAddress) return false;
        if (isExcludeFromFee[sender]) return false;
        if (isRecipientExcludeFromFee[recipient]) return false;
        if (isPair[sender] && !isTaxBuyEnable) return false;
        if (isPair[recipient] && !isTaxSellEnable) return false;
        if (isPair[sender] && recipient == earnAddress) {
            return false;
        }
        return true;
    }

    function shouldSwapForWeth(address sender) internal view returns (bool){
        return (isAutoSwapForWeth && sender != earnAddress && !isPair[sender] && !inSwap && _balances[address(this)] >= minimumSwapForWeth);
    }

    function setIsPair(address pairAddress, bool state) external onlyOwner {
        isPair[pairAddress] = state;
    }

    function setIsBot(address _address, bool state) external onlyOwner {
        isBot[_address] = state;
    }

    function setMinimumTokenLeft(bool state, uint256 _minimumTokenLeft) external onlyOwner {
        require(_minimumTokenLeft <= (25000 * (10 ** _decimals)), "DinoV2: Max Amount Exceed");
        isHasMinimumTokenLeft = state;
        minimumTokenLeft = _minimumTokenLeft;
    }

    function setTaxReceiver(address _marketingAddress, address _treasuryAddress) external onlyOwner {
        marketingAddress = _marketingAddress;
        treasuryAddress = _treasuryAddress;
    }

    function setReferral(address parent, address child) external onlyOwner {
        referralAddress[child] = parent;
    }

    function setrouterEarnAddress(address _routerEarnAddress) external onlyOwner {
        routerEarnAddress = _routerEarnAddress;
        isRecipientExcludeFromFee[_routerEarnAddress] = true;
        isExcludeFromFee[_routerEarnAddress] = true;
        isExcludeFromMaxAmountPerWallet[_routerEarnAddress] = true;
        isExcludeFromTimeBuyLimit[_routerEarnAddress] = true;
        isExcludeFromReward[_routerEarnAddress] = true;
    }

    function setIsTaxEnable(bool taxBuy, bool taxSell) external onlyOwner {
        isTaxBuyEnable = taxBuy;
        isTaxSellEnable = taxSell;
    }

    function setIsExcludeFromFee(address account, bool state) external onlyOwner {
        isExcludeFromFee[account] = state;
    }

    function setIsRecipientExcludeFromFee(address account, bool state) external onlyOwner {
        isRecipientExcludeFromFee[account] = state;
    }

    function setAutoSwapForWeth(bool state, uint256 amount) external onlyOwner {
        require(amount <= _totalSupply, "DinoV2: Amount Swap For Weth max total supply");
        isAutoSwapForWeth = state;
        minimumSwapForWeth = amount;
    }

    function setTimeBuy(bool state, uint256 time) external onlyOwner {
        require(time <= 1 hours, "DinoV2: Maximum Time Buy is 1 hours");
        isLastTimeBuyEnable = state;
        minimumTimeBuy = time;
    }

    function setTimeSell(bool state, uint256 time) external onlyOwner {
        require(time <= 24 hours, "DinoV2: Maximum Time Sell is 1 hours");
        isLastTimeSellEnable = state;
        minimumTimeSell = time;
    }

    function setMaxAmountPerWallet(bool state, uint256 amount) external onlyOwner {
        isMaxAmountPerWalletEnable = state;
        maximumAmountPerWallet = amount;
    }

    function setIsExcludeFromMaxAmountPerWallet(bool state, address account) external onlyOwner {
        isExcludeFromMaxAmountPerWallet[account] = state;
    }

    function setIsExcludeTimeBuy(bool state, address _account) external onlyOwner {
        isExcludeFromTimeBuyLimit[_account] = state;
    }

    function setEarnEnable(bool state) external onlyOwner {
        isEarnEnable = state;
    }

    function setPercentBuy(uint256 _percentEarn, uint256 _percentReferral, uint256 _percentMarketing, uint256 _percentTreasury) external onlyOwner {
        percentBuyEarn = _percentEarn;
        percentBuyReferral = _percentReferral;
        percentBuyMarketing = _percentMarketing;
        percentBuyTreasury = _percentTreasury;
        require(percentBuyEarn + 
            percentBuyReferral + 
            percentBuyMarketing + 
            percentBuyTreasury + 
            percentSellEarn + 
            percentSellMarketing + 
            percentSellReferral + 
            percentSellTreasury
            <= 2500, "DinoV2: Maximum 25%"
        );
    }

    function setPercentSell(uint256 _percentEarn, uint256 _percentMarketing, uint256 _percentReferral, uint256 _percentTreasury) external onlyOwner {
        percentSellEarn = _percentEarn;
        percentSellMarketing = _percentMarketing;
        percentSellReferral = _percentReferral;
        percentSellTreasury = _percentTreasury;
        require(percentBuyEarn + 
            percentBuyReferral + 
            percentBuyMarketing + 
            percentBuyTreasury + 
            percentSellEarn + 
            percentSellMarketing + 
            percentSellReferral + 
            percentSellTreasury
            <= 2500, "DinoV2: Maximum 25%"
        );
    }

    function _swapForWeth(uint256 amount,uint256 txAmount) internal swapping {
        if (amount > 0) {
            uint256 totalTax = percentSellMarketing + percentSellTreasury + percentSellMarketing + percentSellEarn;
            //total amount token for liquify

            IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);

            uint256 balanceETHBefore = address(this).balance;

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = wethAddress;

            uint256[] memory estimate = router.getAmountsOut(amount, path);

            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amount,
                estimate[1],
                path,
                address(this),
                block.timestamp
            );

            uint256 balanceETHAfter = address(this).balance - balanceETHBefore;

            // //distribute
            uint256 amountMarketing = getAmountPercent(balanceETHAfter, percentSellMarketing, totalTax);
            uint256 amountEarn = getAmountPercent(balanceETHAfter, percentSellEarn, totalTax);
            uint256 amountTreasury = getAmountPercent(balanceETHAfter, percentSellTreasury, totalTax);
            
            if (isEarnEnable) {
                payable(marketingAddress).transfer(amountMarketing);
                payable(treasuryAddress).transfer(amountTreasury);
                if(isEarnEnable) IEarn(routerEarnAddress).deposit{value : amountEarn}(txAmount);
            } else {
                payable(marketingAddress).transfer(amountMarketing + amountEarn);
                payable(treasuryAddress).transfer(amountTreasury);
            }
        }
    }

    function getAmountPercent(uint256 baseAmount, uint256 taxAmount, uint256 divider) internal view returns (uint256){
        return (baseAmount * (taxAmount * percentTaxDenominator) / divider) / percentTaxDenominator;
    }

    function swapForWeth(uint256 txAmount) external onlyOwner {
        _swapForWeth(_balances[address(this)],txAmount);
    }

    function setIsExcludeFromMinimumTokenLeft(address _account, bool state) external onlyOwner{
        isExcludeFromMinimumTokenLeft[_account] = state;
    }

    function claimWeth(address to, uint256 amount) external onlyOwner {
        payable(to).transfer(amount);
    }

    function claimFromContract(address _tokenAddress, address to, uint256 amount) external onlyOwner {
        IBEP20(_tokenAddress).safeTransfer(to, amount);
    }

    function setEarnAddress(address _address) external onlyOwner {
        earnAddress = _address;
        isExcludeFromFee[_address] = true;
        isRecipientExcludeFromFee[_address] = true;
        isExcludeFromMaxAmountPerWallet[_address] = true;
        isExcludeFromTimeBuyLimit[_address] = true;
        isExcludeFromReward[_address] = true;
    }

    function setIsExcludeFromReward(address _address, bool state) external onlyOwner {
        isExcludeFromReward[_address] = state;
    }
}