/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

// Sources flattened with hardhat v2.9.3 https://hardhat.org

// File contracts/Uniswap/IUniswapV2Factory.sol

// SPDX-License-Identifier: MIT


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


// File contracts/Uniswap/IUniswapV2Pair.sol



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


// File contracts/Uniswap/IUniswapV2Router01.sol


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


// File contracts/Uniswap/IUniswapV2Router02.sol



pragma solidity ^0.8.9;
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


// File contracts/common/Address.sol



pragma solidity ^0.8.9;

library Address {
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

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
        functionCallWithValue(
            target,
            data,
            value,
            "Address: low-level call with value failed"
        );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value : weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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


// File @openzeppelin/contracts/token/ERC20/[email protected]


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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


// File contracts/interface/IERC20Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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


// File contracts/utils/AddressUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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


// File contracts/proxy/Initializable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;
/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}


// File contracts/FeeManager.sol

pragma solidity ^0.8.0;
interface IAloraNode {
  function operatorFee() external view returns(uint32);
  function getAmountOut(uint256) external view returns(uint256);
}

contract FeeManager is Initializable {
  // using SafeMath for uint256;

  IERC20Upgradeable public token;
  IUniswapV2Router02 public router;
  
  address public treasury;
  address[] public operators;
  mapping (address => bool) private isOperator;
  uint256 public countOperator;

  uint32 public rateTransferFee;
  uint32 public rateRewardsPoolFee;
  uint32 public rateTreasuryFee;
  uint32 public rateOperatorFee;

  bool public enabledTransferETH;

  address public owner;
  address public manager;

  mapping(bytes32 => uint32) public rateUpgradeFee;
  uint32 public rateClaimFee;
  
  modifier onlyOwner() {
    require(owner == msg.sender, "FeeManager: caller is not the owner");
    _;
  }

  modifier onlyManager() {
    require(manager == msg.sender, "FeeManager: caller is not the manager");
    _;
  }

  function initialize() public initializer {
    owner = msg.sender;
  
    rateTransferFee = 0;
    rateRewardsPoolFee = 7000;
    rateTreasuryFee = 2000;
    rateOperatorFee = 1000;
    rateClaimFee = 3000;

    enabledTransferETH = true;
    // setRateUpgradeFee("basic", "light", 1000);
    // setRateUpgradeFee("basic", "pro", 1500);
    // setRateUpgradeFee("light", "pro", 1000);
  }

  // receive() external payable {}

  function transferOwnership(address _owner) public onlyOwner {
    require(
        _owner != address(0),
        "FeeManager: new owner is the zero address"
    );
    owner = _owner;
  }

  function bindManager(address _manager) public onlyOwner {
    require(
        _manager != address(0),
        "FeeManager: new manager is the zero address"
    );
    manager = _manager;
  }

  function setTreasury(address account) public onlyOwner {
    require(treasury != account, "The same account!");
    treasury = account;
  }
  
  function setOperator(address account) public onlyOwner {
    if(isOperator[account]==false) {
      operators.push(account);
      isOperator[account] = true;
      countOperator ++;
    }
  }

  function enableTransferETH(bool _enabled) public onlyOwner {
    enabledTransferETH = _enabled;
  }

  function removeOperator(address account) public onlyOwner {
    if(isOperator[account]==true) {
      isOperator[account] = false;
      countOperator --;
    }
  }

  function setRateRewardsPoolFee(uint32 _rateRewardsPoolFee) public onlyOwner {
    require(rateOperatorFee + rateTreasuryFee + _rateRewardsPoolFee == 10000, "Total fee must be 100%");
    rateRewardsPoolFee = _rateRewardsPoolFee;
  }

  function setRateTreasuryFee(uint32 _rateTreasuryFee) public onlyOwner {
    require(rateTreasuryFee != _rateTreasuryFee,"The same value!");
    require(rateOperatorFee + _rateTreasuryFee + rateRewardsPoolFee == 10000, "Total fee must be 100%");
    rateTreasuryFee = _rateTreasuryFee;
  }

  function setRateOperatorFee(uint32 _rateOperatorFee) public onlyOwner {
    require(rateOperatorFee != _rateOperatorFee,"The same value!");
    require(_rateOperatorFee + rateTreasuryFee + rateRewardsPoolFee == 10000, "Total fee must be 100%");
    rateOperatorFee = _rateOperatorFee;
  }
  
  function setRateTransferFee(uint32 _rateTransferFee) public onlyOwner {
    require(rateTransferFee != _rateTransferFee,"The same value!");
    rateTransferFee = _rateTransferFee;
  }

  function setRateClaimFee(uint32 _rateClaimFee) public onlyOwner {
    require(rateClaimFee != _rateClaimFee,"The same value!");
    rateClaimFee = _rateClaimFee;
  }

  function getRateUpgradeFee(string memory tierNameFrom, string memory tierNameTo) public view returns (uint32) {
    bytes32 key = keccak256(abi.encodePacked(tierNameFrom, tierNameTo));
    return rateUpgradeFee[key];
  }

  function setRateUpgradeFee(string memory tierNameFrom, string memory tierNameTo, uint32 value) public onlyOwner {
    bytes32 key = keccak256(abi.encodePacked(tierNameFrom, tierNameTo));
    rateUpgradeFee[key] = value;
  }

  function bindToken(address _token) public onlyOwner {
    token = IERC20Upgradeable(_token);
    bytes4 uniswapV2Router = bytes4(keccak256(bytes('uniswapV2Router()')));
    (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(uniswapV2Router));
    if(success)
      router = IUniswapV2Router02(abi.decode(data, (address)));
    else
      revert('Token address is invalid.');
  }

  function transferTokenToOperator(address _sender, uint256 _fee, address _token) public onlyManager {
    if(countOperator>0) {
      uint256 _feeEach = _fee / countOperator;
      uint32 j = 0;
      for (uint32 i = 0; i < operators.length; i++) {
        if (!isOperator[operators[i]]) continue;
        if (j == countOperator-1) {
          IERC20(_token).transferFrom(_sender, operators[i], _fee);
          break;
        } else {
          IERC20(_token).transferFrom(_sender, operators[i], _feeEach);
          _fee = _fee - _feeEach;
        }
        j ++;
      }
    } else {
      IERC20(_token).transferFrom(_sender, address(this), _fee);
    }
  }

  function transferFeeToOperator(uint256 _fee) public onlyManager {
    if(countOperator>0) {
      uint256 _feeEach = _fee / countOperator;
      uint32 j = 0;
      for (uint32 i = 0; i < operators.length; i++) {
        if (!isOperator[operators[i]]) continue;
        if (j == countOperator-1) {
          transferETH(operators[i], _fee);
          break;
        } else {
          transferETH(operators[i], _feeEach);
          _fee = _fee - _feeEach;
        }
        j ++;
      }
    }
  }

  function transferETHToOperator() public onlyManager payable {
    if(countOperator>0) {
      uint256 _fee = msg.value;
      uint256 _feeEach = _fee / countOperator;
      uint32 j = 0;
      for (uint32 i = 0; i < operators.length; i++) {
        if (!isOperator[operators[i]]) continue;
        if (j == countOperator-1) {
          payable(operators[i]).transfer(_fee);
          break;
        } else {
          payable(operators[i]).transfer(_feeEach);
          _fee = _fee - _feeEach;
        }
        j ++;
      }
    }
  }

  function transferFee(address _sender, uint256 _fee) public onlyManager {
    require(_fee != 0,"Transfer token amount can't zero!");
    require(treasury!=address(0),"Treasury address can't Zero!");
    require(address(router)!=address(0), "Router address must be set!");

    uint256 _feeTreasury = _fee * rateTreasuryFee / 10000;
    token.transferFrom(_sender, address(this), _fee);
    transferETH(treasury, _feeTreasury);
    
    if (countOperator > 0) {
      uint256 _feeRewardPool = _fee * rateRewardsPoolFee / 10000;
      uint256 _feeOperator = _fee - _feeTreasury - _feeRewardPool;
      transferFeeToOperator(_feeOperator);
    }
  }

  function transferETH(address recipient, uint256 amount) public onlyManager {
    if(enabledTransferETH) {
      address[] memory path = new address[](2);
      path[0] = address(token);
      path[1] = router.WETH();
      token.approve(address(router), amount);

      router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        amount,
        0,
        path,
        recipient,
        block.timestamp
      );
    } else
      transfer(recipient, amount);
  }

  function claim(address to, uint256 amount) public onlyManager {
    if(rateClaimFee>0) {
      uint256 fee = amount * rateClaimFee / 10000;
      uint256 feeOperator = fee * IAloraNode(address(token)).operatorFee() / 100;
      transferFeeToOperator(feeOperator);
      token.transfer(address(token), fee - feeOperator); // for liquidity
      token.transfer(to, amount - fee);
    } else
      token.transfer(to, amount);
  }

  function transfer(address to, uint256 amount) public onlyManager {
    token.transfer(to, amount);
  }

  function transferFrom(address from, address to, uint256 amount) public onlyManager {
    token.transferFrom(from, to, amount);
  }

  function withdraw(uint256 amount) public onlyOwner {
    require(
      token.balanceOf(address(this)) >= amount,
      'Withdraw: Insufficent balance.'
    );
    token.transfer(address(msg.sender), amount);
  }

  function withdrawETH() public onlyOwner {
    uint256 amount = address(this).balance;

    (bool success, ) = payable(msg.sender).call{value: amount}("");
    require(success, "Failed to send Ether");
  }

  function getAmountETH1(uint256 _amount) public view returns (uint256) {
    if(address(token)==address(0)) return 0;
    return IAloraNode(address(token)).getAmountOut(_amount);
  }

  function getAmountETH2(uint256 _amount) public view returns (uint256) {
    if(address(router)==address(0)) return 0;
    address[] memory path = new address[](2);
    path[0] = address(token);
    path[1] = router.WETH();
    uint256[] memory amountsOut = router.getAmountsOut(_amount, path);
    return amountsOut[1];
  }

  function getAmountETH(uint256 _amount) public view returns (uint256) {
    if(address(router)==address(0)) return 0;
    uint256 amount1 = getAmountETH1(_amount);
    uint256 amount2 = getAmountETH2(_amount);
    if(amount1 > amount2)
      return amount1;
    return amount2;
  }

  function getTransferFee(uint256 _amount) public view returns (uint256) {
    return _amount * rateTransferFee / 10000;
  }

  function getClaimFee(uint256 _amount) public view returns (uint256) {
    return _amount * rateClaimFee / 10000;
  }
}