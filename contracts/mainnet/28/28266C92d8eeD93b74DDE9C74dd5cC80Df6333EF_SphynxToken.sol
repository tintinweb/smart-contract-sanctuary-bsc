/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.13;

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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

// File: @openzeppelin\contracts\token\ERC20\extensions\IERC20Metadata.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)


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

// File: @openzeppelin\contracts\utils\Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)


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

// File: @openzeppelin\contracts\access\Ownable.sol

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)



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

// File: @openzeppelin\contracts\utils\Address.sol

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)


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

// File: @uniswap\v2-core\contracts\interfaces\IUniswapV2Factory.sol


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

// File: @uniswap\v2-core\contracts\interfaces\IUniswapV2Pair.sol


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

// File: @uniswap\v2-periphery\contracts\interfaces\IUniswapV2Router01.sol


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

// File: @uniswap\v2-periphery\contracts\interfaces\IUniswapV2Router02.sol


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

// File: contracts\SphynxToken.sol

//  _____     _                             _
// |   __|___| |_ _ _ ___ _ _   ___ ___ ___| |_ ___
// |__   | . |   | | |   |_'_|_|  _| . |  _| '_|_ -|
// |_____|  _|_|_|_  |_|_|_,_|_|_| |___|___|_,_|___|
//       |_|     |___|

// (Uni|Pancake)Swap libs are interchangeable
// Custom IERC721 interface to interact with nft contract
interface IERC721Custom {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function totalSupply() external view returns (uint256);
}

contract SphynxToken is Context, IERC20, IERC20Metadata, Ownable {
    using Address for address;

    mapping(address => uint256) private _balances;
    mapping (address => bool) private _isExcludedFromFee;
    uint256 private _excludedFromFees = 0;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Token specifics
    string private _name;
    string private _symbol;
		uint256 private  _totalSupply;

    // Uniswap
    IUniswapV2Router02 internal _uniswapV2Router;
		address internal _uniswapV2Pair;
    bool private _isRouterInit;

    // Fee's in 0.01%, max 100%
    uint256 private _maxFee = 10000;
    // Users can add themselfs to _isExcludedFromFee, first few are fee, afterwards payment is required
    uint256 private _noFeeAccounts = 10;
    uint256 private _noFeePrice = 10 ** 18;

    // Marketing - Send tiny amount to randomly selected nft owners.
    IERC721Custom public _NFTProjectAddress;
    bool private _randomNFTProjectOwnerEnabled;
    bool private _hasNFTProject;
    uint256 private _randomNFTProjectOwnerFee;
    uint256 private _randomNFTProjectOwnerCount;

    // Loyalty - Send tiny amount to most recent buyers
    bool private _recentBuyersEnabled;
    uint256 private _recentBuyersFee;
    uint256 private _recentBuyersCount;
    address[] private _recentBuyers;

    // Loyalty - When sold within a certain amount of blocks subtract fee and send to recent buyers
    bool private _fastSellerEnabled;
    uint256 private _fastSellerFee;
    uint256 private _fastSellerBlocks;
    mapping(address => uint256) private _buyTxs;

    // Liquidity - Subtract a tiny amount and add to liquidity pool
    bool private _liquidityEnabled;
    uint256 private _liquidityFee;
    address private _LPholder;

    // Whether a previous call of SwapAndLiquify process is still in process.
    uint256 private _minTokensBeforeSwap;
    bool private _inSwapAndLiquify;
    bool private _autoSwapAndLiquifyEnabled;
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensAddedToLiquidity);

    // Prevent reentrancy.
    modifier lockTheSwap {
        require(!_inSwapAndLiquify, "Currently in swap and liquify.");
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    struct ValuesFromAmount {
        uint256 amount;
        uint256 randomNFTProjectOwnerFee;
        uint256 recentBuyersFee;
        uint256 fastSellerFee;
        uint256 liquidityFee;
        uint256 tAmount;
    }

    constructor(string memory name_, string memory symbol_, uint256 totalSupply_, address _router) {
        _name = name_;
        _symbol = symbol_;

				_mint(msg.sender, totalSupply_);
        _LPholder = msg.sender;

        //Init router
        initRouter(_router);

        //0.02% fee for 5 random nft owners
        enableRandomNFTProjectOwner(2,5);
        //Enable recent buyer 5% to 5 most recent buyers
        enableRecentBuyers(98,5);
        //Fee of 5% when selling within 512 blocks
        enabledFastSeller(500,512);
        //2.5% fee for liquidity
        enableAutoSwapAndLiquify(250, 5000 * (10 ** 18));

        // exclude owner and this contract from fee.
        excludeAccountFromFee(owner());
        excludeAccountFromFee(address(this));
    }

    function name() public view virtual override returns (string memory) {return _name;  }
    function symbol() public view virtual override returns (string memory) {return _symbol;  }
    function decimals() public view virtual override returns (uint8) {return 18;  }
    function totalSupply() public view virtual override returns (uint256) {  return _totalSupply;   }
    function balanceOf(address account) public view virtual override returns (uint256) {return _balances[account];  }
		function uniswapV2Pair() public view virtual returns (address) {return _uniswapV2Pair;		}

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true; }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {return _allowances[owner][spender];}

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(  address from,  address to,uint256 amount  ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;  }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;  }


    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {  _approve(owner, spender, currentAllowance - subtractedValue);        }
        return true;   }

    function _transfer(address from, address to,  uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        ValuesFromAmount memory values = _getValues(amount, from);

        // pair token balance before transfer
        uint256 _pairBalanceBeforeTransfer = _balances[_uniswapV2Pair];

        // subtract tokens from
        unchecked {_balances[from] = fromBalance - amount;}

        // depding on weather the user had to pay fees or not add amount
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
          _balances[to] +=  values.tAmount;
          emit Transfer(from, to, values.tAmount);
          _afterTokenTransfer(from, to, values);
        } else {
          _balances[to] +=  values.amount;
          emit Transfer(from, to, values.amount);
        }

        // When was buy transfer add to recentbuyers
        if (_pairBalanceBeforeTransfer > _balances[_uniswapV2Pair]){
          _recentBuyers.push(to);
          if (_recentBuyers.length > (_recentBuyersCount)){
            for (uint256 i = 0; i < _recentBuyersCount; i++) {
                _recentBuyers[i] = _recentBuyers[i+1];
            }
            _recentBuyers.pop();
          }
          _buyTxs[to] = block.number;
        }

    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {  _balances[account] = accountBalance - amount;     }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner,  address spender,uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(  address owner,  address spender,uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _afterTokenTransfer(address from, address to, ValuesFromAmount memory values) internal virtual {
      //if random over tax is enabled
      if (_randomNFTProjectOwnerEnabled){
        for (uint256 i = 1; i <= _randomNFTProjectOwnerCount; i++){
          address randomOwner = getNFTProjectRandomOwner(i);
          _balances[randomOwner] += values.randomNFTProjectOwnerFee;
          emit Transfer(from, randomOwner, values.randomNFTProjectOwnerFee);
        }
      }

      // when recent buyer tax is enabled
      if (_recentBuyersEnabled){
        for (uint256 i = 0; i < _recentBuyers.length ; i++){
          address recentBuyer = _recentBuyers[i];
          _balances[recentBuyer] += values.recentBuyersFee;
          //emit Transfer(from, recentBuyer, values.recentBuyersFee);
        }
      }

      // equally split the fastSeller over the recent buyers
      if (_fastSellerEnabled && values.fastSellerFee > 0){
        // When there are recents buyers (recent buyers needs to be on); else send to contract
        if( _recentBuyers.length > 0){
          uint256 recentBuyerFastSellerFee = values.fastSellerFee / _recentBuyers.length;
          for (uint256 i = 0; i < _recentBuyers.length ; i++){
            address recentBuyer = _recentBuyers[i];
            _balances[recentBuyer] += recentBuyerFastSellerFee;
            //emit Transfer(from, recentBuyer, recentBuyerFastSellerFee);
          }
        } else {
          _balances[_LPholder] += values.fastSellerFee;
        }

      }

      // add to liquidity
      if (_autoSwapAndLiquifyEnabled) {
          // add liquidity fee to this contract.
          _balances[address(this)] += values.liquidityFee;

          // whether the current contract balances makes the threshold to swap and liquify.
          uint256 contractBalance = _balances[address(this)];
          bool overMinTokensBeforeSwap = contractBalance >= _minTokensBeforeSwap;

          // swap on normal transfer
          if (overMinTokensBeforeSwap && !_inSwapAndLiquify && from != _uniswapV2Pair && to != _uniswapV2Pair) {
              swapAndLiquify(contractBalance);
          }
      }
    }

    function withdrawal() public onlyOwner {
        address payable _owner = payable(msg.sender);
        _owner.transfer(address(this).balance);
    }

    receive() external payable {}

    /**
     * Liquidity related functions
     */
    function addLiquidity(uint256 ethAmount, uint256 tokenAmount) private {
        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        // add the liquidity
        _uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            _LPholder,
            block.timestamp
        );
    }

    function swapAndLiquify(uint256 contractBalance) private lockTheSwap {
        // split the contract balance into two halves.
        uint256 tokensToSwap = contractBalance / 2;
        uint256 tokensAddToLiquidity = contractBalance - tokensToSwap;

        // contract's current ETH balance.
        uint256 initialBalance = address(this).balance;

        // swap half of the tokens to ETH.
        swapTokensForEth(tokensToSwap);
        uint256 ethAddToLiquify = address(this).balance - initialBalance;
        addLiquidity(ethAddToLiquify, tokensAddToLiquidity);

        emit SwapAndLiquify(tokensToSwap,ethAddToLiquify,tokensAddToLiquidity);
    }

    function swapTokensForEth(uint256 amount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _approve(address(this), address(_uniswapV2Router), amount);

        // swap tokens to eth
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    /*
     * Setters
     */
     function setRandomNFTProjectOwner(uint256 randomNFTProjectOwnerFee_, uint256 randomNFTProjectOwnerCount_) public onlyOwner {
         require(_randomNFTProjectOwnerEnabled, "randomNFTProjectOwner feature must be enabled. Try the enableRandomNFTProjectOwner function." );
         require( (randomNFTProjectOwnerFee_ * randomNFTProjectOwnerCount_) + (_recentBuyersFee*_recentBuyersCount) + _fastSellerFee + _liquidityFee < _maxFee, "Total fees too high." );

         _randomNFTProjectOwnerFee = randomNFTProjectOwnerFee_;
        _randomNFTProjectOwnerCount = randomNFTProjectOwnerCount_;
     }

     function setRecentBuyers(uint256 recentBuyersFee_, uint256 recentBuyersCount_) public onlyOwner {
        require(_recentBuyersEnabled, "recentBuyers feature must be enabled. Try the enableRecentBuyers function." );
        require((_randomNFTProjectOwnerFee * _randomNFTProjectOwnerCount) + (recentBuyersFee_*recentBuyersCount_) + _fastSellerFee + _liquidityFee < _maxFee, "Total fees too high." );

        _recentBuyersFee = recentBuyersFee_;
       _recentBuyersCount = recentBuyersCount_;
    }

    function setFastSeller(uint256 fastSellerFee_, uint256 fastSellerBlocks_) public onlyOwner {
        require(_fastSellerEnabled, "fastSeller feature must be enabled. Try the enableFastSeller function." );
        require((_randomNFTProjectOwnerFee * _randomNFTProjectOwnerCount) +  (_recentBuyersFee*_recentBuyersCount) + fastSellerFee_ + _liquidityFee < _maxFee, "Total fees too high." );

        _fastSellerFee = fastSellerFee_;
       _fastSellerBlocks = fastSellerBlocks_;
    }

    function setLiquidityFee(uint256 liquidityFee_) public onlyOwner {
        require(_autoSwapAndLiquifyEnabled,"autoSwapAndLiquify feature must be enabled. Try the enableAutoSwapAndLiquify function.");
        require((_randomNFTProjectOwnerFee * _randomNFTProjectOwnerCount) +  (_recentBuyersFee*_recentBuyersCount) + _fastSellerFee + liquidityFee_ < _maxFee, "Total fees too high." );
        _liquidityFee = liquidityFee_;
    }

    /**
     * Values related functions
     */

    function _getValues(uint256 amount, address sender) private view returns (ValuesFromAmount memory) {
        ValuesFromAmount memory values;
        values.amount = amount;

        // calculate fee
        values.randomNFTProjectOwnerFee = _randomNFTProjectOwnerEnabled ? _calculateFee(values.amount, _randomNFTProjectOwnerFee):0;
        values.recentBuyersFee = _recentBuyersEnabled ? _calculateFee(values.amount, _recentBuyersFee):0;
        values.fastSellerFee = _fastSellerEnabled ? _calculateFastSellerFee(values.amount, _fastSellerFee, sender):0;
        values.liquidityFee =  _calculateFee(values.amount, _liquidityFee);
        values.tAmount = values.amount -
            (values.randomNFTProjectOwnerFee * _randomNFTProjectOwnerCount) -
            (values.recentBuyersFee * _recentBuyersCount) -
            values.fastSellerFee -
            values.liquidityFee;
        return values;
    }



    function enableRandomNFTProjectOwner(uint256 randomNFTProjectOwnerFee_, uint256 randomNFTProjectOwnerCount_) public onlyOwner {
        require(!_randomNFTProjectOwnerEnabled, "randomNFTProjectOwner feature is already enabled.");
        _randomNFTProjectOwnerEnabled = true;
        setRandomNFTProjectOwner(randomNFTProjectOwnerFee_, randomNFTProjectOwnerCount_);
    }

    function disableRandomNFTProjectOwner() public onlyOwner {
      require(_randomNFTProjectOwnerEnabled, "randomNFTProjectOwner feature is already disabled.");
      setRandomNFTProjectOwner(0,0);
      _randomNFTProjectOwnerEnabled = false;
    }

    function enableRecentBuyers(uint256 recentBuyersFee_, uint256 recentBuyersCount_) public onlyOwner {
        require(!_recentBuyersEnabled, "recentBuyers feature is already enabled.");
        _recentBuyersEnabled = true;
        setRecentBuyers(recentBuyersFee_, recentBuyersCount_);
    }
    function disabledRecentBuyers() public onlyOwner {
        require(_recentBuyersEnabled, "recentBuyers feature is already disabled.");
        setRecentBuyers(0,0);
        _recentBuyersEnabled = false;
    }

    function enabledFastSeller(uint256 fastSellerFee_, uint256 fastSellerBlocks_) public onlyOwner {
        require(!_fastSellerEnabled, "fastSeller feature is already enabled.");
        _fastSellerEnabled = true;
        setFastSeller(fastSellerFee_, fastSellerBlocks_);
    }

    function disabledFastSeller() public onlyOwner {
      require(_fastSellerEnabled, "fastSeller feature is already disabled.");
      setFastSeller(0,0);
      _fastSellerEnabled = false;
  }

    function enableAutoSwapAndLiquify(uint256 liquifyFee_, uint256 minTokensBeforeSwap_) public onlyOwner {
      require(_isRouterInit, "Router should be initialized can be done with initRouter");
      require(!_autoSwapAndLiquifyEnabled, "autoSwapAndLiquify feature is already enabled.");
      _minTokensBeforeSwap = minTokensBeforeSwap_;

      // enable
      _autoSwapAndLiquifyEnabled = true;
      setLiquidityFee(liquifyFee_);
    }

    function disableAutoSwapAndLiquify() public onlyOwner {
        require(_autoSwapAndLiquifyEnabled,"autoSwapAndLiquify feature is already disabled.");
        setLiquidityFee(0);
        _autoSwapAndLiquifyEnabled = false;
    }

    /*
     * Utils
     */
    function _calculateFee(uint256 amount, uint256 taxRate) private pure returns (uint256) {
        return (amount * taxRate) / (10**4);
    }
    function _calculateFastSellerFee(uint256 amount, uint256 taxRate, address sender) private view returns (uint256) {
      if ((block.number - _buyTxs[sender]) < _fastSellerBlocks){
        return (amount * taxRate) / (10**4);
      } else {
        return 0;
      }
    }

    function excludeAccountFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
        _excludedFromFees++;
    }
    function includeAccountFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
        _excludedFromFees--;
    }
    function setLPholder(address newLPholder) public onlyOwner {
       includeAccountFromFee(_LPholder);
       _LPholder = newLPholder;
       excludeAccountFromFee(newLPholder);
    }

    function setNoFeePrice(uint256 price) public onlyOwner {
      require(price >= 10 ** 16, "Should be atleast 0.01");
       _noFeePrice = price;
    }
    function noFeesForMe() public payable {
      address sender = _msgSender();
      require(!_isExcludedFromFee[sender], "Already no fees");
      if(_excludedFromFees < _noFeeAccounts) {
        _isExcludedFromFee[sender] = true;
        _excludedFromFees++;
      } else {
        require(msg.value >= _noFeePrice, "Insufficient amount sent for noFees");
        _isExcludedFromFee[sender] = true;
        _excludedFromFees++;
      }
    }

    function initRouter(address routerAddress) public onlyOwner {
      // init Router
      IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(routerAddress);
      _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
      if (_uniswapV2Pair == address(0)) {
          _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
              .createPair(address(this), uniswapV2Router.WETH());
      }
      _uniswapV2Router = uniswapV2Router;
      _isRouterInit = true;
      excludeAccountFromFee(routerAddress);
  }

    function setNFTProjectAddress(address newNFTProjectAddress) public onlyOwner {
      // set to an erc721 nft project. woners will randomly receive a reward
      require(newNFTProjectAddress.isContract(), "Address should be contract");
      require(IERC721Custom(newNFTProjectAddress).supportsInterface(0x80ac58cd), "Contract should support IERC721");
      _NFTProjectAddress = IERC721Custom(newNFTProjectAddress);
      _hasNFTProject = true;
  }

  function getNFTProjectRandomOwner(uint256 nonce) public view returns (address) {
    if (_hasNFTProject){
      uint randomHash = uint(keccak256(abi.encodePacked(nonce, block.difficulty, block.timestamp)));
      uint256 tokenId = randomHash % (_NFTProjectAddress.totalSupply() - 2);
      try _NFTProjectAddress.ownerOf(tokenId+1) returns (address selectedAddress) {
        return selectedAddress;
      } catch (bytes memory){
        return owner();
      }
    } else {
        return owner();
    }

  }
}