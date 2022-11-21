/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

// Sources flattened with hardhat v2.12.2 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts-upgradeable/utils/[email protected]


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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


// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]


// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;
    event Initialized(uint8 version);
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }
    
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}


// File contracts/lib/Janitable.sol


pragma solidity ^0.8.0;


contract Janitable is Context, Initializable {
    address private _janitor;
    address private _previousJanitor;
    uint256 private _lockTimeJanitor;

    event JanitorTransferred(
        address indexed previousJanitor,
        address indexed newJanitor
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial janitor.
     */
    function initialize(address new_janitor) public virtual onlyInitializing {
        _janitor = new_janitor;
        emit JanitorTransferred(address(0), new_janitor);
    }

    /**
     * @dev Returns the address of the current janitor.
     */
    function janitor() public view returns (address) {
        return _janitor;
    }

    /**
     * @dev Throws if called by any account other than the janitor.
     */
    modifier onlyJanitor() {
        require(
            _janitor == _msgSender(),
            "Janitable: caller is not the janitor"
        );
        _;
    }

    /**
     * @dev Leaves the contract without janitor. It will not be possible to call
     * `onlyJanitor` functions anymore. Can only be called by the current janitor.
     */
    function renounceJanitorship() public virtual onlyJanitor {
        emit JanitorTransferred(_janitor, address(0));
        _janitor = address(0);
    }

    /**
     * @dev Transfers janitorship of the contract to a new account (`newJanitor`).
     * Can only be called by the current janitor.
     */
    function transferJanitorship(address newJanitor)
        public
        virtual
        onlyJanitor
    {
        require(
            newJanitor != address(0),
            "Janitable: new janitor is the zero address"
        );
        emit JanitorTransferred(_janitor, newJanitor);
        _janitor = newJanitor;
    }

    function getUnlockTimeJanitor() public view returns (uint256) {
        return _lockTimeJanitor;
    }

    function lockJanitor(uint256 time) public virtual onlyJanitor {
        // Locks the contract for janitor for the amount of time provided
        _previousJanitor = _janitor;
        _janitor = address(0);
        _lockTimeJanitor = block.timestamp + time;
        emit JanitorTransferred(_janitor, address(0));
    }

    function unlockJanitor() public virtual {
        // Unlocks the contract for janitor when _lockTime is exceeds
        require(
            _previousJanitor == msg.sender,
            "You don't have permission to unlock"
        );
        require(
            block.timestamp > _lockTimeJanitor,
            "Contract is locked until 7 days"
        );
        emit JanitorTransferred(_janitor, _previousJanitor);
        _janitor = _previousJanitor;
    }
}


// File contracts/lib/Ownable.sol


pragma solidity ^0.8.0;


contract Ownable is Context, Initializable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize(address new_owner) public virtual onlyInitializing {
        _owner = new_owner;
        emit OwnershipTransferred(address(0), new_owner);
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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function lock(uint256 time) public virtual onlyOwner {
        // Locks the contract for owner for the amount of time provided
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        // Unlocks the contract for owner when _lockTime is exceeds
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}


// File contracts/lib/Address.sol


pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
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
     * https://eips.ETHereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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


// File @uniswap/v2-periphery/contracts/interfaces/[email protected]

pragma solidity >=0.6.2;

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


// File @uniswap/v2-periphery/contracts/interfaces/[email protected]

pragma solidity >=0.6.2;

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


// File @openzeppelin/contracts/token/ERC20/[email protected]


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/token/ERC20/[email protected]


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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
        return 18;
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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


// File @uniswap/v2-core/contracts/interfaces/[email protected]

pragma solidity >=0.5.0;

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


// File contracts/StratosphereV2.sol


pragma solidity ^0.8.0;







contract StratosphereV2 is Context, IERC20, Ownable, Janitable {
    // Settings for the contract (supply, taxes, ...)

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    uint256 private _totalClaimed;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _taxFee;
    uint256 private _previousTaxFee;

    uint256 public _liquidityFee;
    uint256 private _previousLiquidityFee;

    uint256 public _rewardFee;
    uint256 private _previousRewardFee;

    uint256 public _incineratorFee;
    uint256 private _previousIncineratorFee;

    address payable public _incineratorAddress;

    uint256 public _maxSellTransactionAmount;
    uint256 public _maxWalletToken;
    uint256 public _numTokensSellToAddToLiquidity;

    mapping(address => uint256) private _bought;
    uint256 private _boughtTotal;
    uint256 private _BSCRewards;

    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private _claimed;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isCleaned;
    mapping(address => bool) private _isExcludedFromMaxWalletToken;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    mapping(address => bool) public _blacklist;

    IUniswapV2Router02 public uniswapV2Router; // Formerly immutable
    address public uniswapV2Pair; // Formerly immutable
    address public _routerAddress;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled;
    bool public tradingEnabled;
    bool public whaleProtectionEnabled;
    bool public progressiveFeeEnabled;
    bool public doSwapForRouter;
    bool public _transferClaimedEnabled;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokens, uint256 bsc);
    event AddedBSCReward(uint256 bsc);
    event ProgressiveFeeEnabled(bool enabled);
    event DoSwapForRouterEnabled(bool enabled);
    event TradingEnabled(bool eanbled);
    event WhaleProtectionEnabled(bool enabled);
    event AddBSCToRewardpPool(uint256 bsc);
    event ExcludeMaxWalletToken(address indexed account, bool isExcluded);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    /**
     * @dev Throws if called by any account other than the janitor or the owner.
     */
    modifier onlyJanitorOrOwner() {
        require(
            janitor() == _msgSender() || owner() == _msgSender(),
            "Caller is not the janitor or the owner."
        );
        _;
    }

    function initialize(address routerAddress)
        public
        override(Ownable, Janitable)
        initializer
    {
        Ownable.initialize(_msgSender());
        Janitable.initialize(_msgSender());
        // token vars
        _tTotal = 2000 * 10**6 * 10**9;
        _rTotal = (MAX - (MAX % _tTotal));
        _name = "Stratosphere BSC V2";
        _symbol = "STRAT";
        _decimals = 9;

        _taxFee = 0;
        _previousTaxFee = _taxFee;

        _liquidityFee = 5;
        _previousLiquidityFee = _liquidityFee;
        _rewardFee = 5;
        _previousRewardFee = _rewardFee;
        _maxSellTransactionAmount = 2000 * 10**6 * 10**9; // can't sell more than this
        _maxWalletToken = 2000 * 10**6 * 10**9; // can't buy or accumulate more than this
        _numTokensSellToAddToLiquidity = 20000 * 10**9;
        _boughtTotal = 0;
        _BSCRewards = 0;

        swapAndLiquifyEnabled = true; // Toggle swap & liquify on and off
        tradingEnabled = true; // To avoid snipers
        whaleProtectionEnabled = false; // To avoid whales
        progressiveFeeEnabled = false; // The default is a fixed tax scheme
        doSwapForRouter = true; // Toggle swap & liquify on and off for transactions to / from the router
        _transferClaimedEnabled = true; // Transfer claim rights upon transfer of tokens

        // create a uniswap pair for this new token
        _routerAddress = routerAddress;
        _rOwned[_msgSender()] = _rTotal;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            _routerAddress
        ); // Initialize router
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[owner()] = true; // Owner doesn't pay fees (e.g. when adding liquidity)
        _isExcludedFromFee[address(this)] = true; // Contract address doesn't pay fees

        _isExcludedFromMaxWalletToken[owner()] = true;
        _isExcludedFromMaxWalletToken[address(this)] = true;
        _isExcludedFromMaxWalletToken[uniswapV2Pair] = true;

        _incineratorFee = 50;
        _previousIncineratorFee = _incineratorFee;
        _incineratorAddress = payable(
            0xa40F28B04E2387E3d7197Dd4A9A2558AF297a042
        );

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function boughtBy(address account) public view returns (uint256) {
        return _bought[account];
    }

    function boughtTotal() public view returns (uint256) {
        return _boughtTotal;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        require(!_blacklist[_msgSender()], "You are blacklisted from transfer");
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
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
    ) public override returns (bool) {
        require(!_blacklist[sender], "Sender is blacklisted from transfer");
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
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
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function isCleaned(address account) public view returns (bool) {
        return _isCleaned[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        (uint256 rAmount, , , , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rTotal = _rTotal - rAmount;
        _tFeeTotal = _tFeeTotal + tAmount;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function excludeFromReward(address account) public onlyOwner {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
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
            uint256 tLiquidityAndRewards,
            uint256 tIncinerator
        ) = _getValues(tAmount);
        _transferClaimed(sender, recipient, tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidityAndRewards(tLiquidityAndRewards);
        _takeIncinerator(tIncinerator, sender);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function excludeFromMaxWalletToken(address account, bool excluded)
        public
        onlyOwner
    {
        require(
            _isExcludedFromMaxWalletToken[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        _isExcludedFromMaxWalletToken[account] = excluded;
        emit ExcludeMaxWalletToken(account, excluded);
    }

    function clean(address account) public onlyOwner {
        _isCleaned[account] = true;
    }

    function unclean(address account) public onlyOwner {
        _isCleaned[account] = false;
    }

    function addToBlacklist(address account) public onlyOwner {
        _blacklist[account] = true;
    }

    function removeFromBlacklist(address account) public onlyOwner {
        _blacklist[account] = false;
    }

    function setIncineratorAddress(address account) public onlyOwner {
        _incineratorAddress = payable(account);
    }

    function setIncineratorFeePromille(uint256 incineratorFee)
        external
        onlyOwner
    {
        _incineratorFee = incineratorFee;
    }

    function setTaxFeePromille(uint256 taxFee) external onlyOwner {
        _taxFee = taxFee;
    }

    function setRewardFeePromille(uint256 rewardFee) external onlyOwner {
        _rewardFee = rewardFee;
    }

    function setLiquidityFeePromille(uint256 liquidityFee) external onlyOwner {
        _liquidityFee = liquidityFee;
    }

    function setMaxSellPercent(uint256 maxTxPercent)
        external
        onlyJanitorOrOwner
    {
        _maxSellTransactionAmount = (_tTotal * maxTxPercent) / 10**2;
    }

    function setNumTokensSellToAddToLiquidity(
        uint256 numTokensSellToAddToLiquidity
    ) external onlyJanitorOrOwner {
        _numTokensSellToAddToLiquidity = numTokensSellToAddToLiquidity;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyJanitorOrOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setTransferClaimedEnabled(bool _enabled)
        public
        onlyJanitorOrOwner
    {
        _transferClaimedEnabled = _enabled;
    }

    function setProgressiveFeeEnabled(bool _enabled) public onlyJanitorOrOwner {
        progressiveFeeEnabled = _enabled;
        emit ProgressiveFeeEnabled(_enabled);
    }

    function setTradingEnabled(bool _enabled) public onlyOwner {
        tradingEnabled = _enabled;
        emit TradingEnabled(_enabled);
    }

    function setMaxSellTransactionAmount(uint256 amount) public onlyOwner {
        _maxSellTransactionAmount = amount;
    }

    function setMaxWalletToken(uint256 amount) public onlyOwner {
        _maxWalletToken = amount;
    }

    function setWhaleProtectionEnabled(bool _enabled)
        public
        onlyJanitorOrOwner
    {
        whaleProtectionEnabled = _enabled;
        emit WhaleProtectionEnabled(_enabled);
    }

    function enableTrading() public onlyJanitorOrOwner {
        tradingEnabled = true;
        emit TradingEnabled(true);
    }

    function setDoSwapForRouter(bool _enabled) public onlyJanitorOrOwner {
        doSwapForRouter = _enabled;
        emit DoSwapForRouterEnabled(_enabled);
    }

    function setRouterAddress(address routerAddress) public onlyJanitorOrOwner {
        _routerAddress = routerAddress;
    }

    function setPairAddress(address pairAddress) public onlyJanitorOrOwner {
        uniswapV2Pair = pairAddress;
    }

    function migrateRouter(address routerAddress) external onlyJanitorOrOwner {
        setRouterAddress(routerAddress);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            _routerAddress
        ); // Initialize router
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(
            address(this),
            _uniswapV2Router.WETH()
        );
        if (uniswapV2Pair == address(0))
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidityAndRewards,
            uint256 tIncinerator
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidityAndRewards,
            tIncinerator,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tLiquidityAndRewards,
            tIncinerator
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidityAndRewards = calculateLiquidityAndRewards(tAmount);
        uint256 tIncinerator = calculateIncineratorFee(tAmount);
        uint256 tTransferAmount = tAmount -
            tFee -
            tLiquidityAndRewards -
            tIncinerator;
        return (tTransferAmount, tFee, tLiquidityAndRewards, tIncinerator);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidityAndRewards,
        uint256 tIncinerator,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rLiquidityAndRewards = tLiquidityAndRewards * currentRate;
        uint256 rIncinerator = tIncinerator * currentRate;
        uint256 rTransferAmount = rAmount -
            rFee -
            rLiquidityAndRewards -
            rIncinerator;
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeIncinerator(uint256 tIncinerator, address from) private {
        uint256 currentRate = _getRate();
        uint256 rIncinerator = tIncinerator * currentRate;
        _rOwned[_incineratorAddress] =
            _rOwned[_incineratorAddress] +
            rIncinerator;
        if (_isExcluded[_incineratorAddress])
            _tOwned[_incineratorAddress] =
                _tOwned[_incineratorAddress] +
                tIncinerator;
        emit Transfer(from, _incineratorAddress, tIncinerator);
    }

    function _takeLiquidityAndRewards(uint256 tLiquidityAndRewards) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidityAndRewards = tLiquidityAndRewards * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rLiquidityAndRewards;
        if (_isExcluded[address(this)])
            _tOwned[address(this)] =
                _tOwned[address(this)] +
                tLiquidityAndRewards;
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return (_amount * _taxFee) / 10**3;
    }

    function calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return (_amount * _liquidityFee) / (10**3);
    }

    function calculateIncineratorFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return (_amount * _incineratorFee) / (10**3);
    }

    function calculateLiquidityAndRewards(uint256 _amount)
        private
        view
        returns (uint256)
    {
        uint256 fee = _liquidityFee + _rewardFee;
        return (_amount * fee) / 10**3;
    }

    function calculateProgressiveFee(uint256 amount)
        private
        view
        returns (uint256)
    {
        // Punish whales
        uint256 currentSupply = _tTotal -
            balanceOf(0x000000000000000000000000000000000000dEaD);
        uint256 fee;
        uint256 txSize = (amount * 10**6) / currentSupply;
        if (txSize <= 100) {
            fee = 2;
        } else if (txSize <= 250) {
            fee = 4;
        } else if (txSize <= 500) {
            fee = 6;
        } else if (txSize <= 1000) {
            fee = 8;
        } else if (txSize <= 2500) {
            fee = 10;
        } else if (txSize <= 5000) {
            fee = 12;
        } else if (txSize <= 10000) {
            fee = 16;
        } else {
            fee = 20;
        }
        return (fee / 2) * 10;
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _liquidityFee == 0 && _rewardFee == 0) return;
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousIncineratorFee = _incineratorFee;
        _previousRewardFee = _rewardFee;
        _taxFee = 0;
        _liquidityFee = 0;
        _incineratorFee = 0;
        _rewardFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _rewardFee = _previousRewardFee;
        _incineratorFee = _previousIncineratorFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isExcludedFromMaxWalletToken(address account)
        public
        view
        returns (bool)
    {
        return _isExcludedFromMaxWalletToken[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function sweep(address payable recipient) public onlyJanitorOrOwner {
        (bool success, ) = recipient.call{value: address(this).balance}("");
        require(success, "Clean failed.");
        _BSCRewards = 0;
    }

    function addBSCToReward() public payable onlyJanitorOrOwner {
        require(msg.value >= 0, "Just making sure ...");
        _BSCRewards = _BSCRewards + msg.value;
        emit AddBSCToRewardpPool(msg.value);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isCleaned[from], "Jannniiieeeeeeeeeeeeeeeeeees!");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (
            from != owner() &&
            to != owner() &&
            from != janitor() &&
            to != janitor()
        ) {
            require(tradingEnabled, "Trading is not enabled");
            if (
                to != address(0) &&
                to != address(0xdead) &&
                from != address(this) &&
                to != address(this)
            ) {
                if (to != uniswapV2Pair && !_isExcludedFromMaxWalletToken[to])
                    require(
                        balanceOf(to) + amount <= _maxWalletToken,
                        "Exceeds maximum wallet token amount."
                    );
                else
                    require(
                        amount <= _maxSellTransactionAmount,
                        "Transfer amount exceeds the maxTxAmount."
                    );
            }
        }
        if (from == uniswapV2Pair) {
            _boughtTotal = _boughtTotal + amount;
            _bought[to] = _bought[to] + amount;
        } else if (to == uniswapV2Pair) {
            _boughtTotal = _boughtTotal - _bought[from];
            _bought[from] = 0;
        }
        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance >= _maxSellTransactionAmount)
            contractTokenBalance = _maxSellTransactionAmount;
        bool overMinTokenBalance = contractTokenBalance >=
            _numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            (doSwapForRouter ||
                (from != _routerAddress && to != _routerAddress)) &&
            swapAndLiquifyEnabled
        ) {
            swap(contractTokenBalance); // add liquidity
        }
        bool takeFee = true;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        _tokenTransfer(from, to, amount, takeFee);
    }

    function swap(uint256 contractTokenBalance) private lockTheSwap {
        uint256 totalFee = _liquidityFee + _rewardFee;
        uint256 tokensForLiquidity = (contractTokenBalance * _liquidityFee) /
            totalFee /
            2;
        if (tokensForLiquidity < contractTokenBalance) {
            // sell tokens
            uint256 tokensToSell = contractTokenBalance - tokensForLiquidity;
            uint256 initialBalance = address(this).balance;
            swapTokensForBSC(tokensToSell);
            uint256 acquiredBSC = address(this).balance - initialBalance;
            // calculate share for liquidity or rewards
            uint256 bscForLiquidity = (acquiredBSC * tokensForLiquidity) /
                tokensToSell;
            uint256 bscForRewards = acquiredBSC - bscForLiquidity;
            // update rewards
            _BSCRewards = _BSCRewards + bscForRewards;
            // add liquidity
            addLiquidity(tokensForLiquidity, bscForLiquidity);
            emit SwapAndLiquify(tokensForLiquidity, bscForLiquidity);
        }
    }

    function swapTokensForBSC(uint256 tokenAmount) private {
        // Generate the bscswap pair path of token -> BSC
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens( // Make the swap
            tokenAmount,
            0, // accept any amount of BSC
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBSCForToken(
        uint256 bscAmount,
        address recipient,
        address token
    ) internal returns (uint256) {
        require(!_blacklist[recipient], "You are blacklisted from swaping");

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(token);

        uint256 balanceBefore = IERC20(token).balanceOf(recipient);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: bscAmount
        }(0, path, recipient, block.timestamp);

        uint256 tokenAmount = IERC20(token).balanceOf(recipient) -
            balanceBefore;
        return tokenAmount;
    }

    function addLiquidity(uint256 tokenAmount, uint256 bscAmount) private {
        // Approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: bscAmount}( // Add liqudity
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            janitor(),
            block.timestamp
        );
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        uint256 oldTaxFee = _taxFee;
        uint256 oldLiquidityFee = _liquidityFee;
        if (!takeFee) {
            removeAllFee();
        } else {
            if (progressiveFeeEnabled) {
                _taxFee = calculateProgressiveFee(amount);
                _liquidityFee = _taxFee;
            }
        }
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        if (!takeFee) restoreAllFee();
        _taxFee = oldTaxFee;
        _liquidityFee = oldLiquidityFee;
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
            uint256 tLiquidityAndRewards,
            uint256 tIncinerator
        ) = _getValues(tAmount);
        _transferClaimed(sender, recipient, tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidityAndRewards(tLiquidityAndRewards);
        _takeIncinerator(tIncinerator, sender);
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
            uint256 tLiquidityAndRewards,
            uint256 tIncinerator
        ) = _getValues(tAmount);
        _transferClaimed(sender, recipient, tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidityAndRewards(tLiquidityAndRewards);
        _takeIncinerator(tIncinerator, sender);
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
            uint256 tLiquidityAndRewards,
            uint256 tIncinerator
        ) = _getValues(tAmount);
        _transferClaimed(sender, recipient, tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidityAndRewards(tLiquidityAndRewards);
        _takeIncinerator(tIncinerator, sender);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function totalRewards() public view returns (uint256) {
        return _BSCRewards;
    }

    function rewards(address recipient) public view returns (uint256) {
        uint256 total = _tTotal -
            balanceOf(0x000000000000000000000000000000000000dEaD);
        uint256 brut = (_BSCRewards * balanceOf(recipient)) / total;
        if (brut > _claimed[recipient]) return brut - _claimed[recipient];
        return 0;
    }

    function claimed(address recipient) public view returns (uint256) {
        return _claimed[recipient];
    }

    function _transferClaimed(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (_transferClaimedEnabled) {
            require(balanceOf(sender) > 0, "Just making sure ...");
            uint256 proportionClaimed = (_claimed[sender] * (tAmount)) /
                balanceOf(sender);
            if (_claimed[sender] > proportionClaimed)
                _claimed[sender] = _claimed[sender] - proportionClaimed;
            else _claimed[sender] = 0;
            _claimed[recipient] = _claimed[recipient] + proportionClaimed;
        }
    }

    function claim(address payable recipient) public {
        require(!_blacklist[_msgSender()], "You are blacklisted from claiming");
        if (_boughtTotal > 0) {
            uint256 total = _tTotal -
                balanceOf(0x000000000000000000000000000000000000dEaD);
            uint256 brut = (_BSCRewards * balanceOf(recipient)) / total;
            require(brut > _claimed[recipient], "Not enough to claim.");
            uint256 toclaim = brut - _claimed[recipient];
            _claimed[recipient] = _claimed[recipient] + toclaim;
            (bool success, ) = recipient.call{value: toclaim}("");
            require(success, "Claim failed.");
            _totalClaimed = _totalClaimed + toclaim;
        }
    }

    function claimToken(address token) public {
        require(!_blacklist[_msgSender()], "You are blacklisted from claiming");
        if (_boughtTotal > 0) {
            uint256 total = _tTotal -
                balanceOf(0x000000000000000000000000000000000000dEaD);
            uint256 brut = (_BSCRewards * balanceOf(msg.sender)) / (total);
            require(brut > _claimed[msg.sender], "Not enough to claim.");
            uint256 toclaim = brut - _claimed[msg.sender];
            _claimed[msg.sender] = _claimed[msg.sender] + toclaim;
            uint256 tokenAmount = swapBSCForToken(toclaim, msg.sender, token);
            require(tokenAmount != 0, "Claim failed.");
            _totalClaimed = _totalClaimed + toclaim;
        }
    }

    function reinvest() public {
        require(!_blacklist[_msgSender()], "You are blacklisted from claiming");
        if (_boughtTotal > 0) {
            uint256 total = _tTotal -
                balanceOf(0x000000000000000000000000000000000000dEaD);
            uint256 brut = (_BSCRewards * balanceOf(msg.sender)) / total;
            require(brut > _claimed[msg.sender], "Not enough to claim.");
            uint256 toclaim = brut - _claimed[msg.sender];
            _claimed[msg.sender] = _claimed[msg.sender] + toclaim;
            uint256 tokenAmount = swapBSCForToken(
                toclaim,
                msg.sender,
                address(this)
            );
            require(tokenAmount != 0, "Claim failed.");
            _totalClaimed = _totalClaimed + toclaim;
        }
    }

    function totalClaimed() public view returns (uint256) {
        return _totalClaimed;
    }
}