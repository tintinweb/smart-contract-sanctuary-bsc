/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

/**
 * BAPE1 TESTNET
 */

//SPDX-License-Identifier:Unlicensed
pragma solidity ^0.8.1;

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

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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
}


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
abstract  contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
        assembly {
            codehash := extcodehash(account)
        }
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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
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
        return functionCall(target, data, 'Address: low-level call failed');
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

contract BAPE1 is Context, IERC20, IERC20Metadata, Ownable {
    using Address for address;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _burnedBalances;
    mapping(address => uint256) private _lastTrade;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint8 public _liquidityTransactionFee;
    uint8 public _buybackTransactionFee;
    uint8 public _marketingTransactionFee;
    uint8 public _totalTransactionFee;
    
    address public _buybackWallet;
    address public _marketingWallet;
    address public _burnAddress;
    
    uint256 public _maxWalletSize;
    uint8 public _tradeCooldown;

    bool public _swapAndLiquifyEnabled;
    bool public _feeEnabled;
    bool public _antiwhaleEnabled;
    bool public _cooldownEnabled;

    uint32 public _swapAmountDivider;

    IUniswapV2Router02 public pancakeV2Router;
    IUniswapV2Pair public pancakeV2Pair;
    address private _pancakeV2PairAddress;
        
    mapping (address => bool) private _excludedFromFee;
    mapping (address => bool) private _excludedFromAntiWhale;
    
    event BNBSentToBuybackWallet(uint256);    
    event SwappedToBNB(uint256 , uint256);
    event LiquidityAdded(uint256 , uint256);
    event Tokensburned(address, uint256);
    event Buyback(address, uint256);
    event SwapAndLiquifyFlagUpdated(bool enabled);
    event TakeFeeEnabledFlagUpdated(bool enabled);
    event AntiwhaleFlagUpdated(bool enabled);
    event CooldownEnabledFlagUpdated(bool enabled);
  
    bool private inSwapAndLiquify;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () {
        _name = "BAPE1";
        _symbol = "BAPE1";
        _decimals = 9;
        _totalSupply = 1000000000000 * 10**_decimals; 
                       
        _liquidityTransactionFee = 2; // Liquidity pool
        _buybackTransactionFee = 3; // Buyback
        _marketingTransactionFee = 5; // Marketing & Development
        _totalTransactionFee = recalcTotalTransactionFee();        
        
        _buybackWallet = 0xba7b5A3e87E88B734e28D585e3c4a6effA89338f;
        _marketingWallet = 0xEA44016f4AB89a54E51377236c935916942B15a9;
        _burnAddress = 0x000000000000000000000000000000000000dEaD;
                           
        _maxWalletSize = 1000000000000 * 10**_decimals; //No wallet can hold more than 1% of total supply
        _tradeCooldown = 60; //60 seconds cooldown when selling to prevent consecutive sells
        _swapAmountDivider = 10; //Used to determine the minumum swap theshold 

        //Following flags will be enabled after presale (UNXC recommendation)
        _swapAndLiquifyEnabled = false;
        _antiwhaleEnabled = false;
        _cooldownEnabled = false;
        _feeEnabled = false; 

    	pancakeV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        _pancakeV2PairAddress = IUniswapV2Factory(pancakeV2Router.factory()).createPair(address(this), pancakeV2Router.WETH());
        pancakeV2Pair = IUniswapV2Pair(_pancakeV2PairAddress);
        
        _excludedFromFee[owner()] = true;
        _excludedFromFee[address(this)] = true;
        _excludedFromFee[address(0)] = true;
        _excludedFromFee[_buybackWallet] = true;
        _excludedFromFee[_marketingWallet] = true;
        _excludedFromFee[_burnAddress] = true;

        _excludedFromAntiWhale[owner()] = true;
        _excludedFromAntiWhale[address(this)] = true;
        _excludedFromAntiWhale[address(0)] = true;
        _excludedFromAntiWhale[_buybackWallet] = true;
        _excludedFromAntiWhale[_marketingWallet] = true;
        _excludedFromAntiWhale[_burnAddress] = true;
        _excludedFromAntiWhale[address(pancakeV2Pair)] = true;

        //Aprove token in order to liquify
        _approve(address(this), address(pancakeV2Router), type(uint256).max);

        //Set initial supply
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }


    /**
    * @dev Returns the name of the token.
    */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * returns the amount of tokens the specified wallet has burned
     */
    function burnBalanceOf(address account) public view returns (uint256) {
        return _burnedBalances[account];
    }

    /**
    * @dev Destroys `amount` tokens from the caller.
    *
    * See {ERC20-_burn}.
    */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }


    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        _transferStandard(account, _burnAddress, amount, 0);
        _burnedBalances[account] = _burnedBalances[account] + amount;
        
        emit Tokensburned(account, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function addWalletToExcludedFromFee(address account) public onlyOwner() {
        _excludedFromFee[account] = true;
    }

    function removeWalletFromExcludedFromFee(address account) external onlyOwner() {
        _excludedFromFee[account] = false;
    }

    function addWalletToExcludedFromAntiWhale(address account) public onlyOwner() {
        _excludedFromAntiWhale[account] = true;
    }

    function removeWalletFromExcludedFromAntiWhale(address account) external onlyOwner() {
        _excludedFromFee[account] = false;
    }

    function setLiquidityTransactionFee(uint8 liquidityFee) external onlyOwner() {
        require(liquidityFee <= 5, "Liquidity fee cannot exceed 5%");
        _liquidityTransactionFee = liquidityFee;
        recalcTotalTransactionFee();        
    }

    function setBuybackTransactionFee(uint8 buybackfundingFee) external onlyOwner() {
        require(buybackfundingFee <= 10, "Buyback fee cannot exceed 10%");
        _buybackTransactionFee = buybackfundingFee;
        recalcTotalTransactionFee();
    }    

    function setMarketingTransactionFee(uint8 marketingFee) external onlyOwner() {
        require(marketingFee <= 10, "Marketing fee cannot exceed 10%");
        _marketingTransactionFee = marketingFee;
        recalcTotalTransactionFee();
    }    
    
    function recalcTotalTransactionFee() private returns (uint8)  {
        _totalTransactionFee = _liquidityTransactionFee + _buybackTransactionFee + _marketingTransactionFee;
        return _totalTransactionFee;
    }

    function setSwapAmountDivider(uint32 divider) public onlyOwner {
        _swapAmountDivider = divider;
    }

    function toggleSwapAndLiquifyFlag(bool enabled) public onlyOwner {
        _swapAndLiquifyEnabled = enabled;
        emit SwapAndLiquifyFlagUpdated(enabled);
    }

    function toggleFeeFlag(bool enabled) public onlyOwner {
        _feeEnabled = enabled;
        emit TakeFeeEnabledFlagUpdated(enabled);
    }

    function toggleAntiwhaleFlag(bool enabled) public onlyOwner {
        _antiwhaleEnabled = enabled;
        emit AntiwhaleFlagUpdated(enabled);
    }

    function toggleCooldownFlag(bool enabled) public onlyOwner {
        _cooldownEnabled = enabled;
        emit CooldownEnabledFlagUpdated(enabled);
    }        

    /**
    * Move accumulated tokens in contract to marketing wallet. 
    */
    function sendTokensInContractToMarketingWallet() public onlyOwner {
        uint256 tokenBalance = _balances[address(this)];
        if(tokenBalance > 0){
            _transferStandard(address(this), _marketingWallet, tokenBalance, 0);
        }        
    }

    /*
    * Send any unswapped BNB in contract to marketing wallet.
    */
    function sendBNBInContractToBuybackWallet() private {
        if(address(this).balance > 0)
        {
            uint256 bnbBalance = address(this).balance;
            (bool success, ) = _buybackWallet.call{value:(bnbBalance)}("");
            require(success, "Transfer to buyback wallet.");    

            emit BNBSentToBuybackWallet(bnbBalance);
        }
    }

    /**
    * BNB sent to this method will buyback tokens and burn them. 
    * Contract will keep track of wallets who burn. This will later be used for NFT minting.
    */
    function buybackAndBurn() public lockTheSwap payable {
        uint amountIn = msg.value;
        require(amountIn > 0, "Value must be greater than zero");
        
        address sender = _msgSender();

        address[] memory path = new address[](2);
        path[0] = pancakeV2Router.WETH();
        path[1] = address(this);

        uint256 balanceBeforeSwap = _balances[_burnAddress];
        pancakeV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountIn}(0, path, _burnAddress, block.timestamp);
        uint256 balanceAfterSwap = _balances[_burnAddress];

        _burnedBalances[sender] = _burnedBalances[sender] + (balanceAfterSwap - balanceBeforeSwap);
        emit Tokensburned(sender, (balanceAfterSwap - balanceBeforeSwap));
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
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        uint256 totalFeeAmount = (amount*_totalTransactionFee)/100;
        if(!_feeEnabled || (_excludedFromFee[sender] || _excludedFromFee[recipient] || inSwapAndLiquify)){
            totalFeeAmount = 0;
        }

        //Anti-whale: Make sure recipient does not hold more than allowed amount of tokens
        if (_antiwhaleEnabled && !_excludedFromAntiWhale[recipient]) 
        {
            uint256 currentBalanceOfRecipient = _balances[recipient];
            uint256 amountToTransfer = amount - totalFeeAmount;
            require(currentBalanceOfRecipient + amountToTransfer <= _maxWalletSize, "Exceeds maximum wallet size"); 
        }
    
        if(_swapAndLiquifyEnabled && !inSwapAndLiquify && sender != address(pancakeV2Pair) && totalFeeAmount > 0)
        {
            uint256 amountToSwap = totalFeeAmount * 2;
            _swapAndLiquify(amountToSwap);

            if(_cooldownEnabled){
                require(_lastTrade[sender] < (block.timestamp - _tradeCooldown), string("No consecutive sells allowed. Please wait."));
                _lastTrade[sender] = block.timestamp;
            }
        }        

        _transferStandard(sender, recipient, amount, totalFeeAmount);   
    }   

    function _transferStandard(address sender, address recipient, uint256 amount, uint256 feeAmount) private {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        _balances[sender] = _balances[sender] - amount;

        if(feeAmount > 0)
        {            
            //Subtract marketing share
            uint256 marketingAmount = (amount*_marketingTransactionFee)/100;
            _balances[_marketingWallet] = _balances[_marketingWallet] + marketingAmount;

            //Keep remaining tokens in contract for later liquification
            uint256 remainingFeeAmount = feeAmount - marketingAmount;
            _balances[address(this)] = _balances[address(this)] + remainingFeeAmount;
        }

        _balances[recipient] = _balances[recipient] + (amount - feeAmount);
        
        emit Transfer(sender, recipient, amount);
    }

    function _swapAndLiquify(uint256 swapAndLiquifyAmount) private lockTheSwap {   
        //Get reserves and calculate price 
        (uint reserve0, uint reserve1,) = pancakeV2Pair.getReserves();
        (uint token, uint bnb) = pancakeV2Pair.token0() == address(this) ? (reserve0, reserve1) : (reserve1, reserve0);
        bnb = bnb/10**_decimals;

        //Min. amount of tokens to initiate a swap. Default 0.1 BNB worth of tokens
        uint256 minTokenSwapAmount = ((token/bnb) * 10**_decimals)/_swapAmountDivider; 
        
        uint256 contractTokenBalance = _balances[address(this)];
        if(contractTokenBalance == 0 || swapAndLiquifyAmount == 0 || minTokenSwapAmount > swapAndLiquifyAmount)
        {
            return;  
        } 

        if(contractTokenBalance < swapAndLiquifyAmount)
        {
            swapAndLiquifyAmount = contractTokenBalance;
        }

        uint8 liquidityShare = (100/((_totalTransactionFee-_marketingTransactionFee)/_liquidityTransactionFee))/2;     
        uint256 tokenHalf = (swapAndLiquifyAmount*liquidityShare)/100;
        uint256 tokensToSwap = swapAndLiquifyAmount - tokenHalf;
                
        // swap tokens for BNB
        uint256 newBalance = _swapTokensForETH(tokensToSwap); 

        uint256 bnbHalf = (newBalance*liquidityShare)/100;
        
        //add liquidity to pancakeswap
        _addLiquidity(tokenHalf, bnbHalf);

        //Send remaining to Buyback funding wallet
        sendBNBInContractToBuybackWallet();
    }

    function _swapTokensForETH(uint256 tokenAmount) private returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeV2Router.WETH();

        uint256 initialBalance = address(this).balance;
        pancakeV2Router.swapExactTokensForETH(tokenAmount, 0, path, address(this), block.timestamp);
        uint256 balanceAfterSwap = address(this).balance - initialBalance;
        emit SwappedToBNB(tokenAmount, balanceAfterSwap);
        return balanceAfterSwap;
    }
    
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        pancakeV2Router.addLiquidityETH{value: ethAmount}(address(this), tokenAmount, 0, 0, owner(), block.timestamp);
        emit LiquidityAdded(ethAmount, tokenAmount);
    }

    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}