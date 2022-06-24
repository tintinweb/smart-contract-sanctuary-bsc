/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/*
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
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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

        (bool success,) = recipient.call{value : amount}("");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value : value}(data);
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

/**
 * @title Coin2Fish Token
 * @author HeisenDev
 */
contract Coin2FishToken is Context, Ownable {
    using Address for address;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromLimits;
    mapping(address => bool) private _blacklistedAccount;
    address[] private _excluded;

    /**
     * Definition of the token parameters
     */
    uint public _decimals = 18;
    string public _name = "Coin2Fish Reborn Token";
    string public _symbol = "C2FT";
    uint public _totalSupplyInteger = 100000000;
    uint public _totalSupply = _totalSupplyInteger * 10 ** 18;
    address public contractAddress = address(this);

    /**
     * Limits Definitions
     * `_maxTransactionAmount` Represents the maximum value to make a transfer
     * It is initialized with the 5% of total supply
     *
     * `_maxWalletAmount` Represents the maximum value to store in a Wallet
     * It is initialized with the 5% of total supply
     *
     * These limitations can be modified by the methods
     * {setMaxTransactionAmount} and {setMaxWalletAmount}.
     */
    uint public _maxTransactionAmount = _totalSupply / 20;
    uint public _maxWalletAmount = _totalSupply / 20;


    /**
     * Definition of the Project Wallets
     * `developerAddress` Corresponds to the wallet address where the development
     * team will receive the fee per transaction
     *
     * `marketingAddress` Corresponds to the wallet address where the funds
     * for marketing will be received
     *
     * `moderatorAddress` Represents the wallet where moderators and other
     * collaborators will receive transaction fees
     *
     * These addresses can be modified by the methods
     * {setDeveloperAddress}, {setMarketingAddress} and {setModeratorAddress}
     */
    address payable public developerAddress = payable(0x2eA1b74Dc11E3B1AcA391785e1AdD253d8E8aF2b);
    address payable public marketingAddress = payable(0x665b0D2afDdc1Cc91C71B3182d5cc51D0f0eb15F);
    address payable public moderatorAddress = payable(0x4DE1Ae2a22c9612Fe748a4b9cd9357d0Fa2B4c78);


    /**
     * Definition of the taxes fees
     * `developerTaxFee` 2% Initial tax fee
     * This value can be modified by the method {setDeveloperTaxFee}
     *
     * `marketingTaxFee` 2% Initial tax fee
     * This value can be modified by the method {setMarketingTaxFee}
     *
     * `moderatorTaxFee` 1% Initial tax fee
     * This value can be modified by the method {setModeratorTaxFee}
     *
     * `liquidityTaxFee` 0%  Initial tax fee during presale
     * This value can be modified by the method {setLiquidityTaxFee}
     *
     * `burnTaxFee` 2% Initial tax fee
     * This value can be modified by the method {setBurnTaxFee}
     *
     */
    uint public developerTaxFee = 2;
    uint public marketingTaxFee = 2;
    uint public moderatorTaxFee = 1;
    uint public liquidityTaxFee = 0;
    uint public burnTaxFee = 2;

    /**
     * Definition of the liquidity params
     * `liquidityThreshold` Minimum amount of tokens to activate
     *  the {swapAddLiquidity} function
     */
    uint256 private liquidityThreshold = 1500;
    uint256 private numTokensSellToAddToLiquidity = liquidityThreshold * 10 ** 18;

    /**
     * Store the last configuration of tax fees
     * `previousDeveloperTaxFee` store the previous value of `developerTaxFee`
     * `previousMarketingTaxFee` store the previous value of `marketingTaxFee`
     * `previousModeratorTaxFee` store the previous value of `liquidityTaxFee`
     * `previousLiquidityTaxFee` store the previous value of `moderatorTaxFee`
     * `previousBurnTaxFee` store the previous value of `burnTaxFee`
     */
    uint public previousDeveloperTaxFee = developerTaxFee;
    uint public previousMarketingTaxFee = marketingTaxFee;
    uint public previousModeratorTaxFee = moderatorTaxFee;
    uint public previousLiquidityTaxFee = liquidityTaxFee;
    uint public previousBurnTaxFee = burnTaxFee;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool swapping;
    bool public swapAddLiquidityEnabled = false;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndAddLiquidityEnabled(bool enabled);
    event SwapAndAddLiquidity(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }


    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor() {
        balances[owner()] = _totalSupply;
        /**
         * mainNet 0x10ED43C718714eb63d5aA57B78B54704E256024E
         * testNet 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
         */
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[contractAddress] = true;
        _isExcludedFromFee[developerAddress] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[moderatorAddress] = true;

        _isExcludedFromLimits[owner()] = true;
        _isExcludedFromLimits[contractAddress] = true;

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromLimits[uniswapV2Pair] = true;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }


    receive() external payable {}

    function swapAddLiquidity(uint256 tokens) private lockTheSwap {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half);
        uint256 newBalance = address(this).balance - initialBalance;
        addLiquidity(otherHalf, newBalance);
        emit SwapAndAddLiquidity(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value : ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function setSwapAndAddLiquidityEnabled(bool _enabled) public onlyOwner {
        swapAddLiquidityEnabled = _enabled;
        emit SwapAndAddLiquidityEnabled(_enabled);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address value) public view returns (uint256) {
        return balances[value];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function contractBalance() public view returns (uint256) {
        return balances[address(this)];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function totalFees() public view returns (uint256) {
        return burnTaxFee + liquidityTaxFee + developerTaxFee + marketingTaxFee + moderatorTaxFee;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        require(_allowances[sender][_msgSender()] - amount <= amount, "transfer amount exceeds allowance");
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }


    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balanceOf(from) >= amount, 'balance too low');
        require(_blacklistedAccount[from] != true, "Account is blacklisted");


        if (_isExcludedFromLimits[from] == false) {
            require(amount <= _maxTransactionAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        if (_isExcludedFromLimits[to] == false) {
            require(balanceOf(to) + amount <= _maxWalletAmount, 'Transfer amount exceeds the maxWalletAmount.');
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance >= _maxTransactionAmount)
        {
            contractTokenBalance = _maxTransactionAmount;
        }


        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !swapping &&
            from != uniswapV2Pair &&
            swapAddLiquidityEnabled
        ) {
            uint256 tokens = numTokensSellToAddToLiquidity;
            if (tokens > 0) {
                swapAddLiquidity(tokens);
            }
        }

        // indicates if fee should be deducted from transfer
        bool takeFee = true;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        // transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }


    // this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {

        uint256 developerAmount;
        uint256 marketingAmount;
        uint256 moderatorAmount;
        uint256 liquidityAmount;
        uint256 burnAmount;

        if (!takeFee) {
            developerAmount = 0;
            marketingAmount = 0;
            moderatorAmount = 0;
            liquidityAmount = 0;
            burnAmount = 0;
            balances[sender] -= (amount);
            balances[recipient] += (amount);
            emit Transfer(sender, recipient, amount);
        }

        else {

            developerAmount = calculateDeveloperFee(amount);
            marketingAmount = calculateMarketingTax(amount);
            moderatorAmount = calculateModeratorTaxFee(amount);
            liquidityAmount = calculateLiquidityFee(amount);
            burnAmount = calculateBurnFee(amount);

            balances[sender] -= (amount);

            balances[developerAddress] += (developerAmount);
            balances[marketingAddress] += (marketingAmount);
            balances[moderatorAddress] += (moderatorAmount);
            balances[address(this)] += (liquidityAmount);
            _totalSupply -= (burnAmount);

            balances[recipient] += (amount - developerAmount - burnAmount - liquidityAmount - moderatorAmount - marketingAmount);
            emit Transfer(sender, developerAddress, developerAmount);
            emit Transfer(sender, marketingAddress, marketingAmount);
            emit Transfer(sender, moderatorAddress, moderatorAmount);
            emit Transfer(sender, recipient, (amount - developerAmount - burnAmount - liquidityAmount - moderatorAmount - marketingAmount));

        }
    }


    function calculateDeveloperFee(uint256 _amount) private view returns (uint256) {
        return _amount * (developerTaxFee) / (100);
    }

    function calculateMarketingTax(uint256 _amount) private view returns (uint256){
        return _amount * (marketingTaxFee) / (100);
    }

    function calculateModeratorTaxFee(uint256 _amount) private view returns (uint256){
        return _amount * (moderatorTaxFee) / (100);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount * (liquidityTaxFee) / (100);
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount * (burnTaxFee) / (100);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromLimits(address account) public onlyOwner {
        _isExcludedFromLimits[account] = true;
    }

    function includeInLimits(address account) public onlyOwner {
        _isExcludedFromLimits[account] = false;
    }

    function isExcludedFromLimits(address account) public view returns (bool) {
        return _isExcludedFromLimits[account];
    }

    function blacklistWallet(address wallet) external onlyOwner() {
        _blacklistedAccount[wallet] = true;
    }

    function removeFromBlacklistWallet(address wallet) external onlyOwner() {
        _blacklistedAccount[wallet] = false;
    }

    function isBlacklisted(address wallet) public view returns (bool){
        return _blacklistedAccount[wallet];
    }

    function setDeveloperAddress(address _developerAddress) external onlyOwner() {
        developerAddress = payable(_developerAddress);
    }

    function setMarketingAddress(address _marketingAddress) external onlyOwner() {
        marketingAddress = payable(_marketingAddress);
    }

    function setModeratorAddress(address _moderatorAddress) external onlyOwner() {
        moderatorAddress = payable(_moderatorAddress);
    }

    function setDeveloperTaxFee(uint256 _developerTaxFee) external onlyOwner() {
        previousDeveloperTaxFee = developerTaxFee;
        developerTaxFee = _developerTaxFee;
        require(_developerTaxFee <= 5, "Must keep developerTaxFee allowed at 5% or less");
    }

    function setMarketingTaxFee(uint256 _marketingTaxFee) external onlyOwner() {
        previousMarketingTaxFee = marketingTaxFee;
        marketingTaxFee = _marketingTaxFee;
        require(_marketingTaxFee <= 5, "Must keep marketingTaxFee allowed at 5% or less");
    }

    function setModeratorTaxFee(uint256 _moderatorTaxFee) external onlyOwner() {
        previousModeratorTaxFee = moderatorTaxFee;
        moderatorTaxFee = _moderatorTaxFee;
        require(_moderatorTaxFee <= 5, "Must keep moderatorTaxFee allowed at 5% or less");
    }

    function setLiquidityTaxFee(uint256 _liquidityTaxFee) external onlyOwner() {
        previousLiquidityTaxFee = liquidityTaxFee;
        liquidityTaxFee = _liquidityTaxFee;
        require(_liquidityTaxFee <= 5, "Must keep liquidityTaxFee allowed at 5% or less");
    }

    function setBurnTaxFee(uint256 _burnTaxFee) external onlyOwner() {
        previousBurnTaxFee = burnTaxFee;
        burnTaxFee = _burnTaxFee;
        require(_burnTaxFee <= 5, "Must keep burnTaxFee allowed at 5% or less");
    }


    function setMaxTransactionAmount(uint256 _maxTransaction) external onlyOwner() {
        _maxTransactionAmount = _maxTransaction;
        uint256 maxTxAmountAllowed = _totalSupply / 5;
        require(_maxTransaction <= maxTxAmountAllowed, "Must keep maxTX allowed at 5% or less");
    }

    function setMaxWalletAmount(uint256 _maxWallet) external onlyOwner() {
        _maxWalletAmount = _maxWallet;
    }


    function manualBurn(uint256 _amount) external onlyOwner() {
        balances[msg.sender] -= _amount;
        _totalSupply -= _amount;
    }

    function changeLiquidityThreshold(uint256 _number) external onlyOwner() {
        liquidityThreshold = _number;
    }


}