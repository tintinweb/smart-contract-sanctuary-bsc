// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IGlobalConfig.sol";
import "./Utils.sol";

library SavingLib {
    using SafeERC20 for IERC20;

    /**
     * Receive the amount of token from msg.sender
     * @param _amount amount of token
     * @param _token token address
     */
    function collectAssets(uint256 _amount, address _token) public {
        if (Utils._isETH(_token)) {
            require(msg.value == _amount, "The amount is not sent from address.");
        } else {
            //When only tokens received, msg.value must be 0
            require(msg.value == 0, "msg.value must be 0 when receiving tokens");
            IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        }
    }

    /**
     * Send the amount of token to an address
     * @param _amount amount of token
     * @param _token token address
     */
    function sendAssets(uint256 _amount, address _token) public {
        if (Utils._isETH(_token)) {
            payable(msg.sender).transfer(_amount);
        } else {
            IERC20(_token).safeTransfer(msg.sender, _amount);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import "./ITokenRegistry.sol";
import "./IBank.sol";
import "./ISavingAccount.sol";
import "./IAccounts.sol";
import "./IConstant.sol";

interface IGlobalConfig {
    function initialize(
        address _gemGlobalConfig,
        address _bank,
        address _savingAccount,
        address _tokenRegistry,
        address _accounts,
        address _poolRegistry
    ) external;

    function tokenRegistry() external view returns (ITokenRegistry);

    function chainLink() external view returns (address);

    function bank() external view returns (IBank);

    function savingAccount() external view returns (ISavingAccount);

    function accounts() external view returns (IAccounts);

    function maxReserveRatio() external view returns (uint256);

    function midReserveRatio() external view returns (uint256);

    function minReserveRatio() external view returns (uint256);

    function rateCurveConstant() external view returns (uint256);

    function compoundSupplyRateWeights() external view returns (uint256);

    function compoundBorrowRateWeights() external view returns (uint256);

    function deFinerRate() external view returns (uint256);

    function liquidationThreshold() external view returns (uint256);

    function liquidationDiscountRatio() external view returns (uint256);

    function governor() external view returns (address);

    function updateMinMaxBorrowAPR(uint256 _minBorrowAPRInPercent, uint256 _maxBorrowAPRInPercent) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import "../interfaces/IGlobalConfig.sol";

library Utils {
    address public constant ETH_ADDR = 0x000000000000000000000000000000000000000E;
    uint256 public constant INT_UNIT = 10**uint256(18);

    function _isETH(address _token) public pure returns (bool) {
        return ETH_ADDR == _token;
    }

    function getDivisor(IGlobalConfig globalConfig, address _token) public view returns (uint256) {
        if (_isETH(_token)) return INT_UNIT;
        return 10**uint256(globalConfig.tokenRegistry().getTokenDecimals(_token));
    }
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

interface ITokenRegistry {
    function initialize(
        address _gemGlobalConfig,
        address _poolRegistry,
        address _globalConfig
    ) external;

    function tokenInfo(address _token)
        external
        view
        returns (
            uint8 index,
            uint8 decimals,
            bool enabled,
            bool _isSupportedOnCompound, // compiler warning
            address cToken,
            address chainLinkOracle,
            uint256 borrowLTV
        );

    function addTokenByPoolRegistry(
        address _token,
        bool _isSupportedOnCompound,
        address _cToken,
        address _chainLinkOracle,
        uint256 _borrowLTV
    ) external;

    function getTokenDecimals(address) external view returns (uint8);

    function getCToken(address) external view returns (address);

    function getCTokens() external view returns (address[] calldata);

    function depositeMiningSpeeds(address _token) external view returns (uint256);

    function borrowMiningSpeeds(address _token) external view returns (uint256);

    function isSupportedOnCompound(address) external view returns (bool);

    function getTokens() external view returns (address[] calldata);

    function getTokenInfoFromAddress(address _token)
        external
        view
        returns (
            uint8,
            uint256,
            uint256,
            uint256
        );

    function getTokenInfoFromIndex(uint256 index)
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256
        );

    function getTokenIndex(address _token) external view returns (uint8);

    function addressFromIndex(uint256 index) external view returns (address);

    function isTokenExist(address _token) external view returns (bool isExist);

    function isTokenEnabled(address _token) external view returns (bool);

    function priceFromAddress(address _token) external view returns (uint256);

    function updateMiningSpeed(
        address _token,
        uint256 _depositeMiningSpeed,
        uint256 _borrowMiningSpeed
    ) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import { ActionType } from "../config/Constant.sol";

interface IBank {
    /* solhint-disable func-name-mixedcase */
    function BLOCKS_PER_YEAR() external view returns (uint256);

    function initialize(address _globalConfig, address _poolRegistry) external;

    function newRateIndexCheckpoint(address) external;

    function deposit(
        address _to,
        address _token,
        uint256 _amount
    ) external;

    function withdraw(
        address _from,
        address _token,
        uint256 _amount
    ) external returns (uint256);

    function borrow(
        address _from,
        address _token,
        uint256 _amount
    ) external;

    function repay(
        address _to,
        address _token,
        uint256 _amount
    ) external returns (uint256);

    function getDepositAccruedRate(address _token, uint256 _depositRateRecordStart) external view returns (uint256);

    function getBorrowAccruedRate(address _token, uint256 _borrowRateRecordStart) external view returns (uint256);

    function depositeRateIndex(address _token, uint256 _blockNum) external view returns (uint256);

    function borrowRateIndex(address _token, uint256 _blockNum) external view returns (uint256);

    function depositeRateIndexNow(address _token) external view returns (uint256);

    function borrowRateIndexNow(address _token) external view returns (uint256);

    function updateMining(address _token) external;

    function updateDepositFINIndex(address _token) external;

    function updateBorrowFINIndex(address _token) external;

    function update(
        address _token,
        uint256 _amount,
        ActionType _action
    ) external returns (uint256 compoundAmount);

    function depositFINRateIndex(address, uint256) external view returns (uint256);

    function borrowFINRateIndex(address, uint256) external view returns (uint256);

    function getTotalDepositStore(address _token) external view returns (uint256);

    function totalLoans(address _token) external view returns (uint256);

    function totalReserve(address _token) external view returns (uint256);

    function totalCompound(address _token) external view returns (uint256);

    function getBorrowRatePerBlock(address _token) external view returns (uint256);

    function getDepositRatePerBlock(address _token) external view returns (uint256);

    function getTokenState(address _token)
        external
        view
        returns (
            uint256 deposits,
            uint256 loans,
            uint256 reserveBalance,
            uint256 remainingAssets
        );

    function configureMaxUtilToCalcBorrowAPR(uint256 _maxBorrowAPR) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

interface ISavingAccount {
    function initialize(
        address[] memory _tokenAddresses,
        address[] memory _cTokenAddresses,
        address _globalConfig,
        address _poolRegistry,
        uint256 _poolId
    ) external;

    function configure(
        address _baseToken,
        address _miningToken,
        uint256 _maturesOn
    ) external;

    function toCompound(address, uint256) external;

    function fromCompound(address, uint256) external;

    function approveAll(address _token) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

interface IAccounts {
    function initialize(address _globalConfig, address _gemGlobalConfig) external;

    function deposit(
        address,
        address,
        uint256
    ) external;

    function borrow(
        address,
        address,
        uint256
    ) external;

    function getBorrowPrincipal(address, address) external view returns (uint256);

    function withdraw(
        address,
        address,
        uint256
    ) external returns (uint256);

    function repay(
        address,
        address,
        uint256
    ) external returns (uint256);

    function getDepositPrincipal(address _accountAddr, address _token) external view returns (uint256);

    function getDepositBalanceCurrent(address _token, address _accountAddr) external view returns (uint256);

    function getDepositInterest(address _account, address _token) external view returns (uint256);

    function getBorrowInterest(address _accountAddr, address _token) external view returns (uint256);

    function getBorrowBalanceCurrent(address _token, address _accountAddr)
        external
        view
        returns (uint256 borrowBalance);

    function getBorrowETH(address _accountAddr) external view returns (uint256 borrowETH);

    function getDepositETH(address _accountAddr) external view returns (uint256 depositETH);

    function getBorrowPower(address _borrower) external view returns (uint256 power);

    function liquidate(
        address _liquidator,
        address _borrower,
        address _borrowedToken,
        address _collateralToken
    ) external returns (uint256, uint256);

    function claim(address _account) external returns (uint256);

    function claimForToken(address _account, address _token) external returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

/* solhint-disable */
interface IConstant {
    function ETH_ADDR() external view returns (address);

    function INT_UNIT() external view returns (uint256);

    function ACCURACY() external view returns (uint256);

    function BLOCKS_PER_YEAR() external view returns (uint256);
}
/* solhint-enable */

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

enum ActionType {
    DepositAction,
    WithdrawAction,
    BorrowAction,
    RepayAction,
    LiquidateRepayAction
}

abstract contract Constant {
    address public constant ETH_ADDR = 0x000000000000000000000000000000000000000E;
    uint256 public constant INT_UNIT = 10**uint256(18);
    uint256 public constant ACCURACY = 10**uint256(18);
}

/**
 * @dev Only some of the contracts uses BLOCKS_PER_YEAR in their code.
 * Hence, only those contracts would have to inherit from BPYConstant.
 * This is done to minimize the argument passing from other contracts.
 */
abstract contract BPYConstant is Constant {
    // solhint-disable-next-line var-name-mixedcase
    uint256 public immutable BLOCKS_PER_YEAR;

    constructor(uint256 _blocksPerYear) {
        BLOCKS_PER_YEAR = _blocksPerYear;
    }
}