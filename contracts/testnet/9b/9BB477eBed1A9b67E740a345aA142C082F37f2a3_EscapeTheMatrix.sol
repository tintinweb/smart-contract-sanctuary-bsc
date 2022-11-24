/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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

interface IPancakeswapV2Pair {
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

    function permit(
        address owner, 
        address spender, 
        uint value, 
        uint deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external;

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
    function getReserves() external view returns (
        uint112 reserve0, 
        uint112 reserve1, 
        uint32 blockTimestampLast
    );
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

contract EscapeTheMatrix is ERC20, Ownable {
    using Address for address payable;
    using Address for address;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    IUniswapV2Router02 public pancakeV2Router;
    address public pancakeV2Pair;

    struct Refferal{
        bytes32 referrerCode;
        address user;
        uint256 referralBalance;
    }

    struct Top25User{
        address user;
        uint256 amount;
        bytes32 referrerCode;
    }
        
    struct MinRank {
        uint256 minAmount;
        uint256 index;
    }

    mapping(address => Refferal) public addressToRefferals;
    
    mapping(bytes32 => address) public refferalCodestoAddress;
    mapping(bytes32 => address[]) public refferalCodestoAddressTracker;

    mapping (address => bool) public top25ActiveUsers;
    mapping (address => bool) private _isExcludedFromFees;

    Top25User[] public top25Users;

    uint256 public  liquidityFeeOnBuy;
    uint256 public  liquidityFeeOnSell;

    MinRank public minRank;

    uint256 public  projectFeeOnBuy;
    uint256 public  projectFeeOnSell;

    uint256 public  referralFeeOnBuy;

    uint256 public _totalFeesOnBuy;
    uint256 public _totalFeesOnSell;

    uint256 public  walletToWalletTransferFee;

    address public  projectWallet;

    address private DEAD;

    uint256 public  swapTokensAtAmount;
    bool    private swapping;

    uint256 public referralWalletLimit = 50 ether;

    IPancakeswapV2Pair public USDPair;
    IPancakeswapV2Pair public TOKENPair;

    address public USD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address public TOKEN = address(this);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ProjectWalletChanged(address projectWallet);
    event UpdateBuyFees(uint256 liquidityFeeOnBuy, uint256 projectFeeOnBuy, uint256 referralFeeOnBuy);
    event UpdateSellFees(uint256 liquidityFeeOnSell, uint256 projectFeeOnSell);
    event SwapAndLiquify(uint256 tokensSwapped,uint256 bnbReceived,uint256 tokensIntoLiqudity);
    event SwapAndSendProject(uint256 tokensSwapped, uint256 bnbSend);
    event ReferralWalletLimitUpdated(uint256 referralWalletLimit);
    event SwapTokensAtAmountUpdated(uint256 swapTokensAtAmount);

    constructor () ERC20("Escape The Matrix", "ETM") 
    {   
        DEAD = 0x000000000000000000000000000000000000dEaD;

        address router = 0xec1BaEBc438B743e752024DAcA79AC451A9E2c8A; 
        address psRouter =0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair   = _uniswapV2Pair;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        IUniswapV2Router02 _pancakeV2Router = IUniswapV2Router02(psRouter);
    
        pancakeV2Router = _pancakeV2Router;

        // Fetch Price Needy
        address _uniswapV2USDPair = IUniswapV2Factory(_pancakeV2Router.factory()).getPair(address(USD), _pancakeV2Router.WETH());
        USDPair = IPancakeswapV2Pair(_uniswapV2USDPair);

        TOKENPair = IPancakeswapV2Pair(_uniswapV2Pair);
       
        // --------------------------------

        liquidityFeeOnBuy   = 0;
        liquidityFeeOnSell  = 5;
        projectFeeOnBuy     = 0;
        projectFeeOnSell    = 10;

        referralFeeOnBuy  = 10;

        _totalFeesOnBuy    = liquidityFeeOnBuy  + projectFeeOnBuy + referralFeeOnBuy;
        _totalFeesOnSell   = liquidityFeeOnSell + projectFeeOnSell;

        walletToWalletTransferFee = 0;

        projectWallet = 0x68Acb7D164C1F0a49da6D6e80e3b279581Eddf0d;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[projectWallet] = true;

        _mint(owner(), 10_101_010 * (10 ** decimals()));
        swapTokensAtAmount = totalSupply() / 5000;
    }

    receive() external payable {

  	}

    // Router Settings
    function setUSDPair(address _usd) public onlyOwner{
        require(USD != _usd);
        USD = _usd;
        address _uniswapV2USDPair = IUniswapV2Factory(pancakeV2Router.factory())
            .getPair(address(_usd), pancakeV2Router.WETH());
        USDPair = IPancakeswapV2Pair(_uniswapV2USDPair);
    }

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), "Owner cannot claim contract's balance of its own tokens");
        if (token == address(0x0)) {
            payable(msg.sender).sendValue(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

//------------------RefferalSystem------------------//
    function setReferrerWalletLimit(uint256 newAmount) external onlyOwner{
        referralWalletLimit = newAmount;
        emit ReferralWalletLimitUpdated(referralWalletLimit);
    }

    function userRefferalInfo(address _user) public view returns(bytes32,address,uint256) {
        Refferal memory refferalInformation = addressToRefferals[_user];
        return (refferalInformation.referrerCode,refferalInformation.user,refferalInformation.referralBalance);
    }

    function getTop25Users() public view returns(Top25User [] memory) {
        return top25Users;
    }

    function manageTop25(address sender, uint256 _amount) internal{
        
        if(minRank.minAmount == 0){
            minRank.minAmount = _amount;
        }

        if (top25ActiveUsers[sender] == false){
            if (top25Users.length < 25){
                top25Users.push(Top25User(sender, _amount, addressToRefferals[addressToRefferals[sender].user].referrerCode));
                if(_amount < minRank.minAmount){
                    minRank.minAmount = _amount;
                    minRank.index = top25Users.length - 1;
                }
                top25ActiveUsers[sender] = true;
            } 
            else {
                if (_amount > minRank.minAmount){
                        top25ActiveUsers[top25Users[minRank.index].user] = false;
                        top25Users[minRank.index].user = sender;
                        top25Users[minRank.index].amount = _amount;
                        top25Users[minRank.index].referrerCode = addressToRefferals[addressToRefferals[sender].user].referrerCode;
                        top25ActiveUsers[sender] = true;
                        for (uint256 i = 0; i < top25Users.length; i++){
                            if (top25Users[i].user != address(0)){
                                if (top25Users[i].amount < minRank.minAmount){
                                    minRank.minAmount = top25Users[i].amount;
                                    minRank.index = i;
                                }
                            }
                        }
                    }
                }
            }
        else {
            for (uint256 i = 0; i < top25Users.length; i++){
                if (top25Users[i].user == sender){
                    top25Users[i].amount = _amount;
                    if (top25Users[i].amount < minRank.minAmount){
                        minRank.minAmount = top25Users[i].amount;
                        minRank.index = i;
                    }
                }
                
                if(top25Users[i].amount < _amount){
                    minRank.minAmount = top25Users[i].amount;
                    minRank.index = i;
                }
            }
        }
    }

    function generateMyReferral(string memory _referredCode) external{
        bytes32 _result;
        address[] memory addressTracker;
        assembly {
            _result := mload(add(_referredCode, 32))
        }

        require(addressToRefferals[address(msg.sender)].referrerCode != _result, "This code already used by you.");
        require(refferalCodestoAddress[_result] == address(0), "Invalid referrer code.");

        refferalCodestoAddress[addressToRefferals[address(msg.sender)].referrerCode] = address(0);

        addressTracker = refferalCodestoAddressTracker[addressToRefferals[address(msg.sender)].referrerCode];
        for (uint256 i = 0; i < addressTracker.length; i++){
            addressToRefferals[addressTracker[i]].user = address(0);
            delete addressTracker[i];
        }
        
        refferalCodestoAddress[_result] = address(msg.sender);

        addressToRefferals[address(msg.sender)].referrerCode = _result;

    }
    
    function setReferrerToSystem(string memory _referredCode) external{
        
        bytes32 _result;

        assembly {
            _result := mload(add(_referredCode, 32))
        }

        require(addressToRefferals[address(msg.sender)].referrerCode != _result, "Can not use own referrer code.");
        require(refferalCodestoAddress[_result] != address(0), "Invalid referrer code.");

        addressToRefferals[address(msg.sender)].user = refferalCodestoAddress[_result];
        refferalCodestoAddressTracker[_result].push(address(msg.sender));

        for (uint256 i = 0; i < top25Users.length; i++){
            if (top25Users[i].user == address(msg.sender)){
                top25Users[i].referrerCode = addressToRefferals[address(msg.sender)].referrerCode;
                break;
            }
        }
        
    }

//------------------FeeManagement------------------//
    function excludeFromFees(address account, bool excluded) external onlyOwner{
        require(_isExcludedFromFees[account] != excluded,"Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function updateBuyFees(uint256 _liquidityFeeOnBuy, uint256 _projectFeeOnBuy, uint256 _referralFeeOnBuy) external onlyOwner {
        liquidityFeeOnBuy = _liquidityFeeOnBuy;
        projectFeeOnBuy = _projectFeeOnBuy;
        referralFeeOnBuy = _referralFeeOnBuy;

        _totalFeesOnBuy   = liquidityFeeOnBuy + projectFeeOnBuy + referralFeeOnBuy ;

        require(_totalFeesOnBuy  <= 10, "Total Buy Fees cannot be more than 10%");

        emit UpdateBuyFees(liquidityFeeOnBuy, projectFeeOnBuy, referralFeeOnBuy);
    }

    function updateSellFees(uint256 _liquidityFeeOnSell, uint256 _projectFeeOnSell) external onlyOwner {
        liquidityFeeOnSell = _liquidityFeeOnSell;
        projectFeeOnSell = _projectFeeOnSell;
        
        _totalFeesOnSell   = liquidityFeeOnSell + projectFeeOnSell;

        require(_totalFeesOnSell <= 15, "Total Sell Fees cannot be more than 15%");

        emit UpdateSellFees(liquidityFeeOnSell, projectFeeOnSell);
    }

    function changeProjectWallet(address _projectWallet) external onlyOwner{
        require(_projectWallet != projectWallet,"Project wallet is already that address");
        require( _projectWallet != address(0),"Project wallet cannot be the zero address");
        projectWallet = _projectWallet;
        emit ProjectWalletChanged(projectWallet);
    }

    function fetchReferrerBalance(address _user) public view returns(uint256){

        uint256 bnbInUsdPair;
        uint256 usdInUsdPair;
        uint256 BNB;
        uint256 Token;
        
        if(address(USDPair.token0()) == address(USD))
            (usdInUsdPair, bnbInUsdPair,  ) = USDPair.getReserves();
        else
            (bnbInUsdPair, usdInUsdPair, ) = USDPair.getReserves();
        
        uint256 bnbPriceInUsd = usdInUsdPair * 1e18 / bnbInUsdPair;
        
        if(address(TOKENPair.token0()) == TOKEN){
            (Token, BNB,) = TOKENPair.getReserves();
        }else{
            (BNB, Token,) = TOKENPair.getReserves();
        }
        
        require(BNB != 0, "Not BNB Reserves your contract");

        uint256 TokenBNBPrice = (Token * 1e18) / BNB;

        uint256 TokenUsdPrice = ((balanceOf(_user) / 1e18) * bnbPriceInUsd ) / TokenBNBPrice;

        return (TokenUsdPrice);
    }
//------------------Transfer------------------//
    function _transfer(address from,address to,uint256 amount) internal  override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
       
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        
        if (from == uniswapV2Pair){
            require(refferalCodestoAddress[addressToRefferals[addressToRefferals[to].user].referrerCode] != address(0), "You must have a referrer to buy");
            require(fetchReferrerBalance(addressToRefferals[to].user) >= referralWalletLimit, "Error: Insufficient referrer balance!");
        }

		uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (canSwap &&
            !swapping &&
            to == uniswapV2Pair &&
            _totalFeesOnBuy + _totalFeesOnSell > 0
        ) {
            swapping = true;

            uint256 totalFee = _totalFeesOnBuy + _totalFeesOnSell;
            uint256 liquidityShare = liquidityFeeOnBuy + liquidityFeeOnSell;
            uint256 projectShare = projectFeeOnBuy + projectFeeOnSell;

            if (liquidityShare > 0) {
                uint256 liquidityTokens = contractTokenBalance * liquidityShare / totalFee;
                swapAndLiquify(liquidityTokens);
            }
            
            if (projectShare > 0) {
                uint256 projectTokens = contractTokenBalance * projectShare / totalFee;
                swapAndSendProject(projectTokens);
            }          

            swapping = false;
        }

        uint256 _totalFees;
        if (_isExcludedFromFees[from] || 
            _isExcludedFromFees[to]||
            swapping
        ) {
            _totalFees = 0;
        }else if (from == uniswapV2Pair) {
            _totalFees = _totalFeesOnBuy - referralFeeOnBuy;
            uint256 referralTokens = (amount * referralFeeOnBuy) / 100;
            addressToRefferals[addressToRefferals[to].user].referralBalance += referralTokens;
            manageTop25(addressToRefferals[to].user, addressToRefferals[addressToRefferals[to].user].referralBalance);
            super._transfer(from,addressToRefferals[to].user,referralTokens);
            amount -= referralTokens;
        } else if (to == uniswapV2Pair) {
            _totalFees = _totalFeesOnSell;
        } else {
            _totalFees = walletToWalletTransferFee;
        }

        if (_totalFees > 0) {
            uint256 fees = (amount * _totalFees) / 100;
            amount = amount - fees;
            super._transfer(from, address(this), fees);
        }
        super._transfer(from, to, amount);  
    }

//------------------Swap------------------//
    function setSwapTokensAtAmount(uint256 newAmount) external onlyOwner{
        require(newAmount > totalSupply() / 1000000, "SwapTokensAtAmount must be greater than 0.0001% of total supply");
        swapTokensAtAmount = newAmount;
        emit SwapTokensAtAmountUpdated(swapTokensAtAmount);
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            half,
            0,
            path,
            address(this),
            block.timestamp);
        
        uint256 newBalance = address(this).balance - initialBalance;

        uniswapV2Router.addLiquidityETH{value: newBalance}(
            address(this),
            otherHalf,
            0,
            0,
            DEAD,
            block.timestamp
        );

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapAndSendProject(uint256 tokenAmount) private {
        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp);

        uint256 newBalance = address(this).balance - initialBalance;

        payable(projectWallet).sendValue(newBalance);

        emit SwapAndSendProject(tokenAmount, newBalance);
    }
}