/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

/**
 *  SPDX-License-Identifier: MIT
 *
 *  Website--------TODO.com
 *  [email protected]
 */

pragma solidity ^0.8.11;


interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external pure returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external pure returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external pure returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external pure returns (string memory);
    
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
     * desired value afterward:
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
     *  - an address where a contract lived but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 
        // is returned for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 
            0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer
     * -now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use
     * -the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low-level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables
     * .html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target, 
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], 
     * but with `errorMessage` as a fallback revert reason when `target` reverts.
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
     * - the calling contract must have a BNB balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target, 
        bytes memory data, 
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(
            target, 
            data, 
            value, 
            "Address: low-level call with value failed"
        );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}
     * [`functionCallWithValue`], but with `errorMessage` as a fallback revert reason 
     * when `target` reverts.
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target, 
        bytes memory data, 
        uint256 weiValue, 
        string memory errorMessage
    ) private returns (bytes memory) {
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


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions, the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable (msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode 
              //- see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange, the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


/**
 * @dev Contract module, which provides a basic access control mechanism, where
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
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without an owner. It will not be possible to call
     * `onlyOwner` functions anymore. It can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @dev Default configuration set for the PancakeSwap finance. PancakeSwap is a 
 * leading decentralized exchange on the Binance Smart Chain. 
 * Please refer to the below link for further details.
 * https://docs.pancakeswap.finance/code/smart-contracts/pancakeswap-exchange
 * 
 * WETH returns the canonical address for the WBNB token (ETH = BNB).
 * 
 * @dev Frequent observations to be done by the development team for any unexpected 
 * activities and early mitigation actions.
 */
interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}


interface IPancakePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}


interface IPancakeRouter01 {
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


interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
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
    ) external returns (uint256 amountETH);

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


/**
 * @dev Implementation of the {IBEP20} interface.
 */
contract Degen is Context, IBEP20, Ownable, ReentrancyGuard {
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded; // from reflections
    address[] private _excluded;

    struct Fees {
        uint16 taxFee; // reflections
        uint16 liquidityFee;
        uint16 marketingFee;
        uint16 developmentFee;
    }

    Fees private _zeroFees = Fees({
        taxFee: 0,
        liquidityFee: 0,
        marketingFee: 0,
        developmentFee: 0
    });

    Fees public _buyFees = Fees({
        taxFee: 5,
        liquidityFee: 3,
        marketingFee: 5,
        developmentFee: 1
    });

    Fees public _sellFees = Fees({
        taxFee: 5,
        liquidityFee: 2,
        marketingFee: 7,
        developmentFee: 1
    });

    Fees private _currentFees = _zeroFees;
    bool public _feesEnabled = true;

    string private constant _name = "Degen Play";
    string private constant _symbol = "DGNP";
    uint8 private constant _DECIMALS = 9;

    uint256 private constant MAX = type(uint256).max;
    uint256 private constant _tTOTAL = 100000000 * 10**_DECIMALS;
    uint256 private _rTotal = (MAX - (MAX % _tTOTAL));
    uint256 private _tFeeTotal = 0;

    address public _marketingWallet;
    address public _developmentWallet;

    bool inSwapBack = false;
    bool public swapBackEnabled = false;
    bool public tradingOpened = true;
    bool private constant _testnetEnabled = false;
   
    uint256 public _maxTxAmount = _tTOTAL / 2000; // 0.05% of the total supply
    uint256 public _numTokensToSwapBack = 300000 * 10**_DECIMALS;

    IPancakeRouter02 private _router;
    address public pancakeswapV2Pair;
    
    address private _routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant _routerAddressTestnet = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;

    event TradingOpened();
    event MarketingWalletChanged(address indexed from, address indexed to);
    event BuyFeesChanged(uint256 taxFee, uint256 liquidityFee, uint256 marketingFee, uint256 developmentFee);
    event SellFeesChanged(uint256 taxFee, uint256 liquidityFee, uint256 marketingFee, uint256 developmentFee);
    event IncludedInRewards(address indexed account);
    event ExcludedFromRewards(address indexed account);
    event IncludedToFees(address indexed account);
    event ExcludedFromFees(address indexed account);
    event MaxTxAmountChanged(uint256 oldAmount, uint256 newAmount);
    event RouterChanged(address indexed newRouter, address indexed newPair);
    event SwapBackEnabledUpdated(bool enabled);
    event SwapBackAmountChanged(uint256 oldAmount, uint256 newAmount);
    event LiquidityAdded(uint256 tokenAmount, uint256 bnbAmount);
    event SwapToBNBStatus(string status);
    event SwapBack(uint256 BNBForMarketing, uint256 BNBForDevelopment, uint256 BNBForLiquidity);
    event FeesEnabled(bool enabled);

    modifier lockTheSwap {
        inSwapBack = true;
        _;
        inSwapBack = false;
    }

    constructor () {
        _rOwned[_msgSender()] = _rTotal;

        _developmentWallet = _msgSender();
        _marketingWallet = _msgSender();

        if (_testnetEnabled) {
            _routerAddress = _routerAddressTestnet;
        }
        _router = IPancakeRouter02(_routerAddress);

         // Create a pancakeswap pair for this new token
        pancakeswapV2Pair = IPancakeFactory(_router.factory()).createPair(address(this), _router.WETH());

        excludeFromFee(address(this));
        excludeFromReward(address(this));

        excludeFromFee(_deadAddress);
        excludeFromReward(_deadAddress);

        excludeFromReward(pancakeswapV2Pair);

        excludeFromFee(_marketingWallet);
        excludeFromFee(_developmentWallet);

        emit Transfer(address(0), _msgSender(), _tTOTAL);
    }

    // to receive BNB from router when swapping
    receive() external payable {}

    /**
     * @dev See {IBEP20-name}.
     */
    function name() external pure override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IBEP20-symbol}.
     */
    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IBEP20-decimals}.
     */
    function decimals() external pure override returns (uint8) {
        return _DECIMALS;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() external pure override returns (uint256) {
        return _tTOTAL;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) {
            return _tOwned[account];
        }
        return tokenFromReflection(_rOwned[account]);
    }

    /**
     * @dev See {IBEP20-transfer}.
     */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20-approve}.
     */
    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-transferFrom}.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as mitigation for
     * problems described in {IBEP20-approve}.
     */
    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as mitigation for
     * problems described in {IBEP20-approve}.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

     /**
     * @dev Call this function to disable all Fees.
     */
    function disableFees() public onlyOwner {
        require(_feesEnabled, "BEP20: Fees already disabled");
        _disableFees();
    }

    /**
     * @dev Call this function to enable all Fees.
     */
    function enableFees() public onlyOwner {
        require(!_feesEnabled, "BEP20: Fees already enabled");
        _enableFees();
    }

    function setBuyFees(
        uint16 reflectionFee,
        uint16 liquidityFee,
        uint16 marketingFee,
        uint16 developmentFee) external onlyOwner()
    {
        require(reflectionFee + liquidityFee + marketingFee + developmentFee <= 20,
                "BEP20: total fees cannot be greater than 20%");
        if (reflectionFee + liquidityFee + marketingFee > 0) {
            require(developmentFee >= 1, "BEP20: Do not offend the dev disabling the fee for him.");
        }

        _buyFees.taxFee = reflectionFee;
        _buyFees.liquidityFee = liquidityFee;
        _buyFees.marketingFee = marketingFee;
        _buyFees.developmentFee = developmentFee;

        emit BuyFeesChanged(_buyFees.taxFee, _buyFees.liquidityFee, _buyFees.marketingFee, _buyFees.developmentFee);
    }

    function setSellFees(
        uint16 reflectionFee,
        uint16 liquidityFee,
        uint16 marketingFee,
        uint16 developmentFee) external onlyOwner()
    {
        require(reflectionFee + liquidityFee + marketingFee + developmentFee <= 20,
                "BEP20: total fees cannot be greater than 20%");
        if (reflectionFee + liquidityFee + marketingFee > 0) {
            require(developmentFee >= 1, "BEP20: Do not offend the dev disabling the fee for him.");
        }

        _sellFees.taxFee = reflectionFee;
        _sellFees.liquidityFee = liquidityFee;
        _sellFees.marketingFee = marketingFee;
        _sellFees.developmentFee = developmentFee;

        emit SellFeesChanged(_sellFees.taxFee, _sellFees.liquidityFee, _sellFees.marketingFee, _sellFees.developmentFee);
    }

    // Once opened cannot be closed
    function openTrading() external onlyOwner() {
        require(!tradingOpened, "BEP20: Trading is already opened");
        tradingOpened = true;
        emit TradingOpened();
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTOTAL, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    /**
     * @dev limit excluded addresses list to avoid aborting functions with
     * "out-of-gas" exception.
     */
    function includeInReward(address account) public onlyOwner {
        if (!_isExcluded[account]) {
            return;
        }
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                emit IncludedInRewards(account);
                break;
            }
        }
    }

    function excludeFromReward(address account) public onlyOwner {
        if (_isExcluded[account]) {
            return;
        }
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
        emit ExcludedFromRewards(account);
    }

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcluded[account];
    }

    /**
     * @dev The owner can exclude specific accounts from Fees.
     */   
    function excludeFromFee(address account) public onlyOwner {
        if (_isExcludedFromFee[account]) {
            return;
        }
        _isExcludedFromFee[account] = true;
        emit ExcludedFromFees(account);
    }

     /**
     * @dev The owner can include specific accounts in Fees.
     */
    function includeInFee(address account) public onlyOwner {
        if (!_isExcludedFromFee[account]) {
            return;
        }
        _isExcludedFromFee[account] = false;
        emit IncludedToFees(account);
    }

    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account];
    }

    /**
     * @dev Call this function to enable Swap Back.
     * This will stop any contract selling.
     */
    function setSwapBackEnabled(bool _enabled) external onlyOwner() {
        require(swapBackEnabled != _enabled, "BEP20: Already set");
        swapBackEnabled = _enabled;
        emit SwapBackEnabledUpdated(_enabled);
    }

    /**
     * Updates the num of tokens to swap back.
     * @param newAmount The new amount of tokens.
     */
    function setNumTokensToSwapBack(uint256 newAmount) external onlyOwner() {
        require(newAmount != _numTokensToSwapBack, "BEP20: Already set the same amount");
        require(newAmount <= _tTOTAL, "BEP20: incorrect value. Must be less than the total supply");

        uint256 oldAmount = _numTokensToSwapBack;
        _numTokensToSwapBack = newAmount;

        emit SwapBackAmountChanged(oldAmount, _numTokensToSwapBack);
    }

    /**
     * Updates the max transaction.
     * @param newAmount The new amount of max transaction.
     */
    function setMaxTxAmount(uint256 newAmount) external onlyOwner() {
        require(newAmount != _maxTxAmount, "BEP20: Already set the same amount");
        require(newAmount >= _tTOTAL / 2000 && newAmount <= _tTOTAL,
            "BEP20: the amount must be greater than or equal to 0.05% of total supply and less than or equal to total supply."
        );
        uint256 oldAmount = _maxTxAmount;
        _maxTxAmount = newAmount;

        emit MaxTxAmountChanged(oldAmount, _maxTxAmount);
    }

    function setMarketingWallet(address newWallet) external onlyOwner() {
        require(newWallet != address(0) && newWallet != _deadAddress,
            "BEP20: the new wallet cannot be the zero or dead address."
        );
        require(_marketingWallet != newWallet, "BEP20: This address is already set as marketing");
        address _prevMarketingWallet = _marketingWallet;

        includeInFee(_prevMarketingWallet);
        excludeFromFee(_marketingWallet);

        _marketingWallet = newWallet;
        emit MarketingWalletChanged(_prevMarketingWallet, _marketingWallet);
    }

    /**
     * @dev Update the Router address if Pancakeswap upgrades to a newer version.
     */
    function setRouterAddress(address newRouter) external onlyOwner() {
        IPancakeRouter02 _newRouter = IPancakeRouter02(newRouter);
        address oldPancakeswapV2Pair = pancakeswapV2Pair;
        address newPair = IPancakeFactory(_newRouter.factory()).getPair(address(this), _newRouter.WETH());
        //check if pair already exists
        if (newPair == address(0)) {
            pancakeswapV2Pair = IPancakeFactory(_newRouter.factory()).createPair(address(this), _newRouter.WETH());
        }
        else {
            pancakeswapV2Pair = newPair;
        }
        _router = _newRouter;

        excludeFromReward(pancakeswapV2Pair);
        includeInReward(oldPancakeswapV2Pair);

        emit RouterChanged(newRouter, pancakeswapV2Pair);
    }

    function recoverBNB(address payable recipient) external onlyOwner() nonReentrant {
        require(recipient != address(0), "BEP20: recipient cannot be the zero address");
        recipient.transfer(address(this).balance);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve` and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer} and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` / `from` cannot be the zero address.
     * - `recipient` / `to` cannot be the zero address.
     * - `sender` / `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,  // sender
        address to,    // recipient
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "BEP20: Transfer amount must be greater than zero");

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is pancakeswap pair.
        bool canSwapBack = (balanceOf(address(this)) >= _numTokensToSwapBack);
        if (canSwapBack &&
            !inSwapBack &&
            from != pancakeswapV2Pair &&
            swapBackEnabled)
        {
            _swapBack(_numTokensToSwapBack);
        }

        // this will take all fees
        _tokenTransfer(from, to, amount);
    }

    event SwapBackTokens(uint256 totalFee, uint256 tokensForLiquidity, uint256 tokensForSwap);
    event SwapBackInitialBalance(uint256 initialBalance);
    event SwapBackStatus(bool status);
    event TransferredBNB(bool status, address indexed account, uint256 BNBTransferred);
    event BalanceAfterSwap(uint256 bal);

    function swapBackAmount(uint256 amount) external onlyOwner() nonReentrant {
        require(balanceOf(address(this)) >= amount, "BEP20: Not enought tokens on balance");
        _swapBack(amount);
    }

    function _swapBack(uint256 amountToSwapBack) private lockTheSwap {
        // Calculate shares according to buy/sell fees
        Fees memory workingFees = Fees({
            taxFee: 0, // unused
            liquidityFee: _sellFees.liquidityFee + _buyFees.liquidityFee,
            marketingFee: _sellFees.marketingFee + _buyFees.marketingFee,
            developmentFee: _sellFees.developmentFee + _buyFees.developmentFee
        });
        // the case when taxes are zeros. Share everything proportionally
        if (workingFees.liquidityFee + workingFees.marketingFee + workingFees.developmentFee == 0) {
            workingFees.liquidityFee = 1;
            workingFees.marketingFee = 1;
            workingFees.developmentFee = 1;
        }
        uint256 totalFee = workingFees.liquidityFee + workingFees.marketingFee + workingFees.developmentFee;

        // half for swap, half for LP
        uint256 tokensForLiquidity = amountToSwapBack * workingFees.liquidityFee / totalFee / 2;
        uint256 tokensForSwap = amountToSwapBack - tokensForLiquidity;

        emit SwapBackTokens(totalFee, tokensForLiquidity, tokensForSwap);

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates and does not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        emit SwapBackInitialBalance(initialBalance);

        // Swap all tokens for BNB only one time leaving the half amount
        // of liquidity to add to liquidity
        if (!_swapTokensForBnb(tokensForSwap)) {
             return;
        }

        uint256 availableBNB = address(this).balance - initialBalance;

        uint256 BNBForMarketing = availableBNB * workingFees.marketingFee / totalFee;
        uint256 BNBForDevelopment = availableBNB * workingFees.developmentFee / totalFee;
        uint256 BNBForLiquidity = availableBNB - BNBForMarketing - BNBForDevelopment;

        emit SwapBack(BNBForMarketing, BNBForDevelopment, BNBForLiquidity);

        if (BNBForLiquidity > 0 && tokensForLiquidity > 0) {
            _addLiquidity(tokensForLiquidity, BNBForLiquidity);
        }

        // transfer BNB to marketing and development
        if (BNBForMarketing > 0) {
            (bool success,) = address(_marketingWallet).call{value: BNBForMarketing}("");
            emit TransferredBNB(success, _marketingWallet, BNBForMarketing);
        }
        if (BNBForDevelopment > 0) {
            (bool success,) = address(_developmentWallet).call{value: BNBForDevelopment}("");
            emit TransferredBNB(success, _developmentWallet, BNBForDevelopment);
        }
    }

    // @dev The swapBack function uses this for swap to BNB
    function _swapTokensForBnb(uint256 tokenAmount) private returns (bool status) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        _approve(address(this), address(_router), tokenAmount);

        // make the swap
        try _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        ) {
            emit SwapToBNBStatus("Success");
            return true;
        }
        catch Error(string memory _err) {
            emit SwapToBNBStatus(_err);
        }
        catch {
            emit SwapToBNBStatus("Unknown Error");
        }
        return false;
    }

    function _addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(_router), tokenAmount);

        // add liquidity and get LP tokens to contract itself
        _router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
        emit LiquidityAdded(tokenAmount, bnbAmount);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        bool takeFee = true;
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            takeFee = false;
        }
        else {
            require(tradingOpened, "BEP20: Trading is not opened yet");
            require(amount <= _maxTxAmount, "BEP20: Transfer amount exceeds the _maxTxAmount");
        }

        if (!takeFee || !_feesEnabled) {
            _currentFees = _zeroFees;
        }
        // Sell
        else if (recipient == pancakeswapV2Pair) {
            _currentFees = _sellFees;
        }
        // Buy and transfer
        else {
            _currentFees = _buyFees;
        }

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        }
        else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        }
        else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        }
        else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tSwapBack
        ) = _getValues(tAmount);
        _rOwned[sender] -= rAmount;
        _rOwned[recipient] += rTransferAmount;
        _takeSwapBack(tSwapBack);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tSwapBack
        ) = _getValues(tAmount);
        _rOwned[sender] -= rAmount;
        _tOwned[recipient] += tTransferAmount;
        _rOwned[recipient] += rTransferAmount;
        _takeSwapBack(tSwapBack);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tSwapBack
        ) = _getValues(tAmount);
        _tOwned[sender] -= tAmount;
        _rOwned[sender] -= rAmount;
        _rOwned[recipient] += rTransferAmount;
        _takeSwapBack(tSwapBack);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tSwapBack
        ) = _getValues(tAmount);
        _tOwned[sender] -= tAmount;
        _rOwned[sender] -= rAmount;
        _tOwned[recipient] += tTransferAmount;
        _rOwned[recipient] += rTransferAmount;
        _takeSwapBack(tSwapBack);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _getValues(uint256 tAmount) private view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 tTransferAmount, uint256 tFee, uint256 tSwapBack) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tSwapBack, _getRate());
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tSwapBack
        );
    }

    function _getTValues(uint256 tAmount) private view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = _calculateTaxFee(tAmount);
        uint256 tSwapBack = _calculateSwapBackFee(tAmount);
        uint256 tTransferAmount = tAmount - tFee - tSwapBack;
        return (tTransferAmount, tFee, tSwapBack);
    }

    function _calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount * _currentFees.taxFee / 100;
    }

    function _calculateSwapBackFee(uint256 _amount) private view returns (uint256) {
        uint256 totalFee = _currentFees.liquidityFee + _currentFees.marketingFee + _currentFees.developmentFee;
        return _amount * totalFee / 100;
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tSwapBack,
        uint256 currentRate
    ) private pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rSwapBack = tSwapBack * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rSwapBack;
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    /**
     * @dev limit excluded addresses list to avoid aborting functions with 
     * "out-of-gas" exception.
     */
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTOTAL;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply)
            {
                return (_rTotal, _tTOTAL);
            }
            rSupply -= _rOwned[_excluded[i]];
            tSupply -= _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTOTAL) {
            return (_rTotal, _tTOTAL);
        }
        return (rSupply, tSupply);
    }

    function _takeSwapBack(uint256 tSwapBack) private {
        uint256 currentRate = _getRate();
        uint256 rSwapBack = tSwapBack * currentRate;
        _rOwned[address(this)] += rSwapBack;
        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] += tSwapBack;
        }
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal -= rFee;
        _tFeeTotal += tFee;
    }

    function _disableFees() private {
        _feesEnabled = false;
        emit FeesEnabled(_feesEnabled);
    }

    function _enableFees() private {
        _feesEnabled = true;
        emit FeesEnabled(_feesEnabled);
    }
}