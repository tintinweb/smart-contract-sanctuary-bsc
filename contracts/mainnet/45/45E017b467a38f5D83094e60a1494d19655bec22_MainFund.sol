/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// Sources flattened with hardhat v2.9.9 https://hardhat.org

/*
    Copyright 2022 Translucent.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    SPDX-License-Identifier: Apache-2.0
*/

// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;


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


// File src/lib/Decimals.sol

pragma solidity ^0.8.12;

/**
 * @title Decimals
 * @author Translucent
 *
 * Library to supoprt a struct that represents decimal numbers.
 */
library Decimals {
    struct Number {
        uint256 value;
        uint8 decimals;
    }

    /**
     * Scale the current value up or down based on the difference
     * between the current decimals and target decimals.
     *
     * @param self - The current number struct.
     * @param targetDecimals - The decimals to scale the current value to.
     * @return - The scaled number struct.
     */
    function scaleDecimals(
        Number memory self,
        uint8 targetDecimals
    ) internal pure returns (Number memory) {
        Number memory output = Number({ value: self.value, decimals: targetDecimals });

        if (self.decimals > targetDecimals) {
            // Scale down
            output.value = self.value / 10**(self.decimals - targetDecimals);
        } else {
            // Scale up
            output .value = self.value * 10**(targetDecimals - self.decimals);
        }

        return output;
    }

    /**
     * Adds two numbers and preserves the first number's decimals.
     *
     * @param self - The current number struct.
     * @param other - The other number struct.
     * @return - The computed number struct.
     */
    function add(
        Number memory self,
        Number memory other
    ) internal pure returns (Number memory) {
        return Number({
            value: self.value + scaleDecimals(other, self.decimals).value,
            decimals: self.decimals
        });
    }

    /**
     * Subtracts two numbers and preserves the first number's decimals.
     *
     * @param self - The current number struct.
     * @param other - The other number struct.
     * @return - The computed number struct.
     */
    function sub(
        Number memory self,
        Number memory other
    ) internal pure returns (Number memory) {
        return Number({
            value: self.value - scaleDecimals(other, self.decimals).value,
            decimals: self.decimals
        });
    }

    /**
     * Multiplies two numbers and preserves the first number's decimals.
     *
     * @param self - The current number struct.
     * @param other - The other number struct.
     * @return - The computed number struct.
     */
    function mul(
        Number memory self,
        Number memory other
    ) internal pure returns (Number memory) {
        return Number({
            value: self.value * other.value / 10**other.decimals,
            decimals: self.decimals
        });
    }

    /**
     * Divides two numbers and preserves the first number's decimals.
     *
     * @param self - The current number struct.
     * @param other - The other number struct.
     * @return - The computed number struct.
     */
    function div(
        Number memory self,
        Number memory other
    ) internal pure returns (Number memory) {
        return Number({
            value: self.value * 10**other.decimals / other.value,
            decimals: self.decimals
        });
    }

    /**
     * Compares if first number is greater than or equal to the second.
     *
     * @param self - The current number struct.
     * @param self - The other number struct.
     * @return - The computed number struct.
     */
    function gte(
        Number memory self,
        Number memory other
    ) internal pure returns (bool) {
        // Compare at the higher decimal precision
        if (self.decimals >= other.decimals)
            return self.value >= scaleDecimals(other, self.decimals).value;
        else
            return scaleDecimals(self, other.decimals).value >= other.value;
    }

    /**
     * Compares if first number is greater than the second.
     *
     * @param self - The current number struct.
     * @param self - The other number struct.
     * @return - The computed number struct.
     */
    function gt(
        Number memory self,
        Number memory other
    ) internal pure returns (bool) {
        // Compare at the higher decimal precision
        if (self.decimals >= other.decimals)
            return self.value > scaleDecimals(other, self.decimals).value;
        else
            return scaleDecimals(self, other.decimals).value > other.value;
    }

    /**
     * Compares if first number is less than or equal to the second.
     *
     * @param self - The current number struct.
     * @param self - The other number struct.
     * @return - The computed number struct.
     */
    function lte(
        Number memory self,
        Number memory other
    ) internal pure returns (bool) {
        // Compare at the higher decimal precision
        if (self.decimals >= other.decimals)
            return self.value <= scaleDecimals(other, self.decimals).value;
        else
            return scaleDecimals(self, other.decimals).value <= other.value;
    }
}


// File src/interfaces/main/cao/helpers/IHumanResources.sol

pragma solidity ^0.8.12;

// Code
/**
 * @title IHumanResources
 * @author Translucent
 *
 * @notice Interface for the CAO's human resources.
 */
interface IHumanResources {
    /********************************************/
    /** Structs to track the employee's details */
    /********************************************/
    struct EmployeeDetails {
        uint256 remunerationPerBlock;
        uint256 remunerationAccrued;
        uint256 lastAccruedBlock;
    }

    /*********************************/
    /** Functions to read the states */
    /*********************************/
    function getEmployeeCount() external view returns (uint256);
    function getEmployeeByIndex(
        uint256 employeeIndex
    ) external view returns (address, EmployeeDetails memory);
    function getEmployeeByAddress(
        address employeeAddress
    ) external view returns (EmployeeDetails memory);
    function getEmployeeCurrentRemuneration(
        address employeeAddress
    ) external view returns (Decimals.Number memory);
    function getUnredeemedExEmployees() external view returns (
        address[] memory,
        EmployeeDetails[] memory
    );

    /***********************************/
    /** Functions to modify the states */
    /***********************************/
    function addEmployee(
        address employeeAddress,
        uint256 remunerationPerBlock
    ) external;
    function updateEmployee(
        address employeeAddress,
        uint256 remunerationPerBlock
    ) external;
    function removeEmployee(address employeeAddress) external;
    function clearEmployeeRemuneration(address employeeAddress) external;
}


// File src/interfaces/main/cao/ICAOGovernor.sol

pragma solidity ^0.8.12;

/**
 * @title ICAOGovernor
 * @author Translucent
 *
 * @notice Interface for the centralized autonomous organization's governance.
 */
interface ICAOGovernor {
    /*******************************************************/
    /** Functions to get details and references of the CAO */
    /*******************************************************/
    function getName() external view returns (string memory);
    function getCAOTokenAddress() external view returns (address);

    /**********************************/
    /** Functions to act as modifiers */
    /**********************************/
    function requireCAOGovernance(address caller) external view;
    function requireCAOTokenHolder(address caller) external view;

    /**************************************************/
    /** Functions to manage CAO governance parameters */
    /**************************************************/
    function setAdvanceExecutionThreshold(uint256 newThreshold) external;

    /************************************************/
    /** Structs to facilitate governance and voting */
    /************************************************/
    enum Direction { FOR, AGAINST }
    enum Status { PENDING, REJECTED, APPROVED_AND_EXECUTED, APPROVED_BUT_FAILED }
    struct Proposal {
        address proposer;
        string description;
        uint256 startBlock;
        uint256 endBlock;
        address[] callAddresses;
        bytes[] callDatas;
        uint256[] callValues;
        uint256 votesFor;
        uint256 votesAgainst;
        Status status;
        uint256 blockExecuted;
        bytes[] returnDatas;
    }

    /**************************************************/
    /** Functions to facilitate governance and voting */
    /**************************************************/
    function createProposal(
        string memory description,
        uint256 blockDelay,
        uint256 blocksDuration,
        address[] calldata callAddresses,
        bytes[] calldata callDatas,
        uint256[] calldata callValues
    ) external returns (uint256);
    function vote(uint256 proposalId, Direction direction, string memory reason) external;
    function executeProposal(uint256 proposalId) external returns (Status);

    /********************************************/
    /** Functions to read the governance states */
    /********************************************/
    function getNumProposals() external view returns(uint256);
    function getActiveProposalsIds() external view returns (uint256[] memory);
    function getProposal(uint256 proposalId) external view returns (Proposal memory);
    function getIsProposalExecutable(uint256 proposalId) external view returns (bool);
}


// File src/interfaces/main/cao/ICAO.sol

pragma solidity ^0.8.12;

// Code
/**
 * @title ICAO
 * @author Translucent
 *
 * @notice Interface for the centralized autonomous organization.
 */
interface ICAO is ICAOGovernor {
    /***************************************/
    /** Functions to set the CAO's helpers */
    /***************************************/
    function setCAOParameters(address parametersAddress) external;
    function setCAOHelpers(address humanResourcesAddress) external;

    /***************************************/
    /** Functions to get the CAO's helpers */
    /***************************************/
    function getHumanResources() external view returns (IHumanResources);

    /**********************************/
    /** Functions to act as modifiers */
    /**********************************/
    function requireCAO(address caller) external view;
    function requireCAOTaskRunner(address caller) external view;

    /****************************************/
    /** Functions for employees interaction */
    /****************************************/
    function computeTokenRedeemAmount(
        address tokenAddress
    ) external view returns (uint256);
    function redeemRemuneration(address tokenAddress) external;
}


// File src/interfaces/main/helpers/IMainFundToken.sol

pragma solidity ^0.8.12;

// External libraries
/**
 * @title IMainFundToken
 * @author Translucent
 *
 * @notice Interface for the main fund's token.
 */
interface IMainFundToken is IERC20 {
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
}


pragma solidity ^0.8.12;

// Code
/**
 * @title IAccounting
 * @author Translucent
 *
 * @notice Interface for the main fund's accounting department.
 */
interface IAccounting {

    /********************************************/
    /** Functions to manage the fund parameters */
    /********************************************/
    /** Read */
    function getManagementFee() external view returns (uint256);
    function getEvaluationPeriodBlocks() external view returns (uint32);

    /** Write */
    function setMangementFee(uint256 newManagementFee) external;
    function setEvaluationPeriodBlocks(uint32 newEvaluationPeriodBlocks) external;

    /********************************************/
    /** Functions to read the accounting states */
    /********************************************/
    struct AccountingState {
        uint256 aumValue;
        uint256 periodBeginningBlock;
        uint256 periodBeginningAum;
        uint256 periodBeginningSupply;
        uint256 theoreticalSupply;
    }

    function getAumValue() external view returns (Decimals.Number memory);
    function getFundTokenPrice() external view returns (Decimals.Number memory);
    function getState() external view returns (AccountingState memory);

    /*******************************************************/
    /** Functions to manage the accounting process (tasks) */
    /*******************************************************/
    function recordDeposits(
        uint256 depositValue,
        uint256 amountMinted
    ) external; // frontOffice task
    function recordWithdrawals(
        uint256 withdrawalValue,
        uint256 amountBurned
    ) external; // frontOffice task
    function recordAumValue(uint256 newAumValue) external; // accounting task
}


// File src/lib/FrontOfficeHelpers.sol

pragma solidity ^0.8.12;

/**
 * @title FrontOfficeHelpers
 * @author Translucent
 *
 * FrontOffice helper for providing the request and queue structs
 * to replicate a queue of deposits and withdrawal requests. 
 */
library FrontOfficeHelpers {
    /*******************/
    /** Request struct */
    /*******************/
    // NOTE: status NULL = 0 as default uninitialized status (do not change)
    //       this is so we can differentitate uninitialized from pending statuses.
    enum RequestStatus {
        NULL,
        PENDING,
        CANCELLED,
        SUCCESSFUL,
        AMOUNT_TOO_LARGE,
        EXPIRED,
        INSUFFICIENT_OUTPUT,
        INCENTIVE_NOT_FOUND,
        INCENTIVE_NOT_QUALIFIED,
        UNHANDLED
    }
    struct Request {
        address user;
        uint256 amountIn;
        uint256 minAmountOut;
        uint256 blockDeadline;
        address incentive; // used only for deposits (ignored for withdrawals)
        RequestStatus status;
        uint256 blockUpdated;
        uint256 computedAmountOut;
        bool isReclaimed;
    }

    /**
     * Helper function to check if a request is in the pending status.
     *
     * @param request - The request struct.
     * @return - Whether the request is pending or not.
     */
    function isPending(Request memory request) internal pure returns (bool) {
        return request.status == RequestStatus.PENDING;
    }

    /**
     * Helper function to check if a request is in the pending status.
     *
     * @param request - The request struct.
     * @return - Whether the request is pending or not.
     */
    function _isPending(Request storage request) internal view returns (bool) {
        return request.status == RequestStatus.PENDING;
    } 

    /**
     * Helper function to check if a request is in a failed status.
     *
     * @param request - The request struct.
     * @return - Whether the request is pending or not.
     */
    function isFailed(Request storage request) internal view returns (bool) {
        RequestStatus status = request.status;
        return status == RequestStatus.EXPIRED
            || status == RequestStatus.INSUFFICIENT_OUTPUT
            || status == RequestStatus.INCENTIVE_NOT_FOUND
            || status == RequestStatus.INCENTIVE_NOT_QUALIFIED
            || status == RequestStatus.UNHANDLED;
    } 

    /**
     * Sets the status of a request to failed.
     *
     * @param request - The request struct.
     */
    function setCancelled(Request storage request) internal {
        require(
            _isPending(request),
            "FrontOfficeLib: cannot set a non-pending request to cancelled"
        );
        request.status = RequestStatus.CANCELLED;
        request.blockUpdated = block.number;
    }

    /**
     * Sets the status of a request to amount too large.
     *
     * @param request - The request struct.
     */
    function setAmountTooLarge(Request storage request) internal {
        require(
            _isPending(request),
            "FrontOfficeLib: cannot set a non-pending request to failed"
        );
        request.status = RequestStatus.AMOUNT_TOO_LARGE;
        request.blockUpdated = block.number;
    }

    /**
     * Sets the status of a request to expired.
     *
     * @param request - The request struct.
     */
    function setExpired(Request storage request) internal {
        require(
            _isPending(request),
            "FrontOfficeLib: cannot set a non-pending request to failed"
        );
        request.status = RequestStatus.EXPIRED;
        request.blockUpdated = block.number;
    }

    /**
     * Sets the status of a request to insufficient output.
     *
     * @param request - The request struct.
     */
    function setInsufficientOutput(
        Request storage request,
        uint256 computedAmountOut
    ) internal {
        require(
            _isPending(request),
            "FrontOfficeLib: cannot set a non-pending request to failed"
        );
        request.status = RequestStatus.INSUFFICIENT_OUTPUT;
        request.blockUpdated = block.number;
        request.computedAmountOut = computedAmountOut;
    }

    /**
     * Sets the status of a request to incentive not found.
     *
     * @param request - The request struct.
     */
    function setIncentiveNotFound(
        Request storage request,
        uint256 computedAmountOut
    ) internal {
        require(
            _isPending(request),
            "FrontOfficeLib: cannot set a non-pending request to failed"
        );
        request.status = RequestStatus.INCENTIVE_NOT_FOUND;
        request.blockUpdated = block.number;
        request.computedAmountOut = computedAmountOut;
    }

    /**
     * Sets the status of a request to incentive not qualified.
     *
     * @param request - The request struct.
     */
    function setIncentiveNotQualified(
        Request storage request,
        uint256 computedAmountOut
    ) internal {
        require(
            _isPending(request),
            "FrontOfficeLib: cannot set a non-pending request to failed"
        );
        request.status = RequestStatus.INCENTIVE_NOT_QUALIFIED;
        request.blockUpdated = block.number;
        request.computedAmountOut = computedAmountOut;
    }

    /**
     * Sets the status of a request to unhandled.
     *
     * @param request - The request struct.
     */
    function setUnhandled(Request storage request) internal {
        require(
            _isPending(request),
            "FrontOfficeLib: cannot set a non-pending request to unhandled"
        );
        request.status = RequestStatus.UNHANDLED;
        request.blockUpdated = block.number;
    }

    /**
     * Sets the status of a request to success.
     *
     * @param request - The request struct.
     */
    function setSuccessful(
        Request storage request,
        uint256 computedAmountOut
    ) internal {
        require(
            _isPending(request),
            "FrontOfficeLib: cannot set a non-pending request to successful"
        );
        request.status = RequestStatus.SUCCESSFUL;
        request.blockUpdated = block.number;
        request.computedAmountOut = computedAmountOut;
    }

    /*****************/
    /** Queue struct */
    /*****************/
    struct Queue {
        mapping(uint256 => Request) requests;
        uint256 readIdx;
        uint256 writeIdx;
    }

    /**
     * Gets the length of the queue.
     *
     * @param queue - The queue struct.
     * @return - The `length` based on the difference between the indexes.
     */
    function length(Queue storage queue) internal view returns (uint256) {
        return queue.writeIdx - queue.readIdx;
    }

    /**
     * Pushes a request into the queue.
     *
     * @param queue - The queue struct.
     * @param userAddress - The address of the user.
     * @param amountIn - The input amount. 
     * @param minAmountOut - The min output amount for the request to succeed.
     * @param blockDeadline - The latest block that the request can be executed
     * @return - The queue number (index) of the request.
     */
    function push(
        Queue storage queue,
        address userAddress,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 blockDeadline,
        address incentive
    ) internal returns (uint256) {
        // Pull the current writeIdx into memory
        uint256 currentWriteIdx = queue.writeIdx;

        // Write into the queue at the current writeIdx
        queue.requests[currentWriteIdx] = Request({
            user: userAddress,
            amountIn: amountIn,
            minAmountOut: minAmountOut,
            blockDeadline: blockDeadline,
            incentive: incentive,
            status: RequestStatus.PENDING,
            blockUpdated: 0,
            computedAmountOut: 0,
            isReclaimed: false
        });

        // Increment the writeIdx
        queue.writeIdx++;

        // Return the current writeIdx
        return currentWriteIdx;
    }

    /**
     * Reads the first request in the queue.
     *
     * @param queue - The queue struct.
     * @return - The reference to the request.
     */
    function front(
        Queue storage queue
    ) internal view returns (Request storage) {
        return queue.requests[queue.readIdx];
    }

    /**
     * Pops a request from the queue.
     *
     * @dev This replicates the interface of a queue's pop op
     *      although we never actually `pop` the request from the map,
     *      merely incrementing the readIdx.
     *
     * @dev We also do not perform checks on the index since it is guaranteed
     *      that we will not pop beyond the write index internally.
     *
     * @param queue - The queue struct.
     */
    function pop(Queue storage queue) internal {
        // Increment the readIdx 
        queue.readIdx++;
    }
}


// File src/interfaces/main/helpers/IFrontOffice.sol

pragma solidity ^0.8.12;

// Code
/**
 * @title IFrontOffice
 * @author Translucent
 *
 * @notice Interface for the main fund's front office department.
 */
interface IFrontOffice {
    /****************************************************/
    /** Function to get the parameters contract address */
    /****************************************************/
    function getParametersAddress() external view returns (address);

    /******************************************/
    /** Functions to facilitate user requests */
    /******************************************/
    /** Structs */
    /**
     * Lookup struct to invert the mapping to facilitate searching of
     * a user's latest request by tracking the accessors.
     */
    struct RequestAccessor {
        bool isDeposit;
        address token;
        uint256 queueNumber;
    }

    /** Read */
    function getUserRequestCount(
        address userAddress
    ) external view returns (uint256);
    function getUserRequestByIndex(
        address userAddress,
        uint256 index
    ) external view returns (
        RequestAccessor memory,
        FrontOfficeHelpers.Request memory
    );
    function getDepositsQueueLength(
        address tokenAddress
    ) external view returns (uint256);

    function getWithdrawalsQueueLength(
        address tokenAddress
    ) external view returns (uint256);

    /** Write */
    function requestDeposit(
        address tokenAddress,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 blockDeadline,
        address incentive
    ) external;
    function requestWithdrawal(
        address tokenAddress,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 blockDeadline
    ) external;
    function cancelLatestRequest() external;
    function reclaimFromFailedRequest(uint256 index) external;

    /***************************************************************/
    /** Functions to facilitate the processing of requests (tasks) */
    /***************************************************************/
    function processDeposits(
        address tokenAddress,
        uint256 maxRequestsToProcess // Limits txn size and allows batching
    ) external;
    function processWithdrawals(
        address tokenAddress,
        uint256 maxRequestsToProcess // Limits txn size and allows batching
    ) external;
}


// File src/interfaces/main/helpers/incentives/IIncentive.sol

pragma solidity ^0.8.12;

// Code
/**
 * @title IIncentive
 * @author Translucent
 *
 * @notice Interface for an instance of the main fund's incentives.
 */
interface IIncentive {
    /** Events */
    event UserQualified(address indexed userAddress);

    /*******************************/
    /** Functions to read metadata */
    /*******************************/
    function getName() external pure returns (string memory);

    /************************************/
    /** Functions to serve as modifiers */
    /************************************/
    function checkUserQualifies(address userAddress) external view returns (bool);

    /************************************/
    /** Functions for users to interact */
    /************************************/
    function getBalance(address userAddress) external view returns (uint256);
    function deposit(uint256 depositAmount) external;
    function withdraw(uint256 withdrawalAmount) external;

    /*****************************************/
    /** Functions for the incentives manager */
    /*****************************************/
    /** Computes the dilution weight for the incentive */
    function getDilutionWeight(
        Decimals.Number memory periodBeginningSupply,
        Decimals.Number memory returnsFactor
    ) external view returns (Decimals.Number memory);
    /** To be called before actual minting to update internal states */
    function recordDirectDeposit(address userAddress, uint256 amount) external;
    /** To be called before actual disbursement to update internal states */
    function recordDisbursement(uint256 amount) external;
}


// File src/interfaces/main/helpers/IIncentivesManager.sol

pragma solidity ^0.8.12;

// Code
/**
 * @title IIncentivesManager
 * @author Translucent
 *
 * @notice Interface for the main fund's incentives manager.
 */
interface IIncentivesManager {
    /************************************************/
    /** Functions to read and modify the parameters */
    /************************************************/
    function getIncentives() external view returns (address[] memory);
    function addIncentive(address incentiveAddress) external;
    function removeIncentive(address incentiveAddress) external;

    /*********************************************************/
    /** Functions to aggregate the incentives for accounting */
    /*********************************************************/
    function getDilutionDetails(
        Decimals.Number memory periodBeginningSupply,
        Decimals.Number memory returnsFactor
    ) external returns (
        Decimals.Number memory,
        address[] memory,
        Decimals.Number[] memory
    );

    /******************************************/
    /** Functions for use by the front office */
    /******************************************/
    enum ValidityCode { VALID, NOT_APPLICABLE, NOT_FOUND, NOT_QUALIFIED }
    function checkValidity(
        address incentiveAddress,
        address userAddress
    ) external returns (ValidityCode);
}


// File src/interfaces/main/IMainFund.sol

pragma solidity ^0.8.12;

// Code
/**
 * @title IMainFund
 * @author Translucent
 *
 * @notice Interface for the centralized autonomous organization's token.
 */
interface IMainFund {
    /****************************************/
    /** Functions to set the fund's helpers */
    /****************************************/
    function setMainFundHelpers(
        address caoAddress,
        address tokenAddress,
        address accountingAddress,
        address frontOfficeAddress,
        address incentivesManagerAddress
    ) external;

    /****************************************/
    /** Functions to get the fund's helpers */
    /****************************************/
    function getCAO() external view returns (ICAO);
    function getFundToken() external view returns (IMainFundToken);
    function getAccounting() external view returns (IAccounting);
    function getFrontOffice() external view returns (IFrontOffice);
    function getIncentivesManager() external view returns (IIncentivesManager);

    /****************************************/
    /** Functions to facilitate withdrawals */
    /****************************************/
    function approveFrontOfficeForWithdrawals(
        address[] calldata tokensAddresses,
        uint256[] calldata amounts
    ) external;
}


// File src/lib/LowLevelHelpers.sol

pragma solidity ^0.8.12;

// Disable linting for low-level calls
// solhint-disable avoid-low-level-calls
// solhint-disable no-inline-assembly

/**
 * @title LowLevelHelpers
 * @author Translucent
 *
 * Low-level helper for performing low-level calls.
 */
library LowLevelHelpers {
    /**
     * Handler to revert with returnData's revert string if it exists
     *
     * @param returnData - The return data from the call.
     */
    function handleRevert(bytes memory returnData)
        internal
        pure
    {
        // Log the return data message if any
        if (returnData.length > 0) {
            assembly {
                let returnDataSize := mload(returnData)
                revert(add(32, returnData), returnDataSize)
            }
        } else {
            revert("Function call reverted");
        }
    }

    /**
     * Slice the bytes to return a sub-array of bytes
     *
     * @param bytesData - The input bytes data to slice.
     * @param start - The index to start slicing.
     * @param length - The length of the sub-array to slice.
     * @return bytes memory - The sliced sub-array of bytes.
     */
    function sliceBytes(bytes memory bytesData, uint256 start, uint256 length)
        internal
        pure
        returns (bytes memory)
    {
        require(
            bytesData.length >= (start + length),
            "sliceBytes: input bytes length must be >= start + length"
        );

        bytes memory tempBytes;

        assembly {
            switch iszero(length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(bytesData, lengthmod), mul(0x20, iszero(lengthmod))), start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    /**
     * Casts bytes into address by evaluating the first 20 bytes
     *
     * @param bytesData - The input bytes data to cast into address.
     * @return address - The casted address.
     */
    function bytesToAddress(bytes memory bytesData) internal pure returns (address) {
        require(
            bytesData.length >= 20,
            "bytesToAddress: input bytes length must be at least 20"
        );

        address addr;
        assembly {
            addr := mload(add(bytesData, 20))
        }
        return addr;
    }

    /**
     * Performs a low-level call without ETH
     *
     * @param callAddress - The address to call.
     * @param callData - The data to make the call with.
     */
    function performCall(
        address callAddress,
        bytes memory callData
    ) internal returns (bytes memory) {
        // Perform the call
        bool success;
        bytes memory returnData;

        // Call without eth value sent
        (success, returnData) = callAddress.call(callData);

        // Revert any potential low-level failures/reverts
        if (!success) handleRevert(returnData);

        return returnData;
    }

    /**
     * Performs a low-level call with ETH (although can be 0)
     *
     * @param callAddress - The address to call.
     * @param callData - The data to make the call with.
     * @param value - The amount of ETH to send as msg.value.
     */
    function performCall(
        address callAddress,
        bytes memory callData,
        uint256 value
    ) internal returns (bytes memory) {
        // Perform the call
        bool success;
        bytes memory returnData;

        // Call with eth value sent if input deems a need for it
        (success, returnData) = callAddress.call{value: value}(callData);

        // Revert any potential low-level failures/reverts
        if (!success) handleRevert(returnData);

        return returnData;
    }

    /**
     * Performs a delegate call with the bytes data
     *
     * @param callAddress - The address to call.
     * @param callData - The data to make the call with.
     */
    function performDelegateCall(
        address callAddress,
        bytes memory callData
    ) internal returns (bytes memory) {
        // Perform the call
        bool success;
        bytes memory returnData;

        // No ETH to be sent for delegate calls
        // Any such requirement should be done on the impleemntation side
        (success, returnData) = callAddress.delegatecall(callData);

        // Revert any potential low-level failures/reverts
        if (!success) handleRevert(returnData);

        return returnData;
    }
}


// File src/interfaces/base/helpers/IOpsGovernor.sol

pragma solidity ^0.8.12;

/**
 * @title IOpsGovernor
 * @author Translucent
 *
 * @notice Interface for managing and governing operations.
 * @notice Governance is solely based on managers that voted.
 *         Non-voting is abstained by default.
 */
interface IOpsGovernor {
    /**********************************/
    /** Functions to act as modifiers */
    /**********************************/
    function requireManagers(address caller) external view;
    function requireOperators(address caller) external view;
    function requireTokenRegistered(address tokenAddress) external view;
    function requireProtocolRegistered(address protocolAddress) external view;
    function requireUtilRegistered(address utilAddress) external view;

    /*********************************/
    /** Functions to read the states */
    /*********************************/
    function getManagers() external view returns (address[] memory);
    function getOperators() external view returns (address[] memory);
    function getNumRegisteredTokens() external view returns (uint256);
    function getNumRegisteredProtocols() external view returns (uint256);
    function getNumRegisteredUtils() external view returns (uint256);
    function getRegisteredTokens(
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory);
    function getRegisteredProtocols(
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory);
    function getRegisteredUtils(
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory);

    /***********************************/
    /** Functions to modify the states */
    /***********************************/
    function addManager(address managerAddress) external;
    function removeManager(address managerAddress) external;
    function addOperator(address operatorAddress) external;
    function removeOperator(address operatorAddress) external;
    function registerTokens(address[] memory tokensAddresses) external;
    function unregisterTokens(address[] memory tokensAddresses) external;
    function registerProtocols(address[] memory protocolsAddresses) external;
    function unregisterProtocols(address[] memory protocolsAddresses) external;
    function registerUtils(address[] memory utilsAddresses) external;
    function unregisterUtils(address[] memory utilsAddresses) external;

    /*******************************************************/
    /** Function to migrate to a new ops governor contract */
    /*******************************************************/
    function migrate(address newOpsGovernorAddress) external;

    /************************************************/
    /** Structs to facilitate governance and voting */
    /************************************************/
    enum Direction { FOR, AGAINST }
    enum Status { PENDING, REJECTED, APPROVED_AND_EXECUTED, APPROVED_BUT_FAILED }

    struct Proposal {
        address proposer;
        string description;
        uint256 startBlock;
        uint256 endBlock;
        bytes callData;
        uint256 votesFor;
        uint256 votesAgainst;
        Status status;
        uint256 blockExecuted;
    }
    /**************************************************/
    /** Functions to facilitate governance and voting */
    /**************************************************/
    function createProposal(
        string memory description,
        uint256 duration,
        bytes calldata callData
    ) external returns (uint256);
    function vote(uint256 proposalId, Direction direction) external;
    function executeProposal(uint256 proposalId) external returns (Status);

    /********************************************/
    /** Functions to read the governance states */
    /********************************************/
    function getNumProposals() external view returns (uint256);
    function getActiveProposalsIds() external view returns (uint256[] memory);
    function getProposal(uint256 proposalId) external view returns (Proposal memory);
    function getIsProposalExecutable(uint256 proposalId) external view returns (bool);
}


// File src/interfaces/base/IBaseFund.sol

pragma solidity ^0.8.12;

// Code
/**
 * @title IBaseFund
 * @author Translucent
 *
 * @notice Interface for the base fund.
 */
interface IBaseFund {    
    /****************************************/
    /** Functions to set the fund's helpers */
    /****************************************/
    function setBaseFundHelpers(address opsGovernorAddress) external;

    /*********************************************/
    /** Structs to facilitate making transactions*/
    /*********************************************/
    enum CallType {
        TOKEN,
        PROTOCOL,
        UTIL
    }
    struct CallInput {
        CallType callType;
        address callAddress;
        bytes callData;
        uint256 value;
    }

    /***********************************/
    /** Functions to make transactions */
    /***********************************/
    function call(CallInput calldata callInput) external;
    function multiCall(CallInput[] calldata callInputs) external;
}


// File src/contracts/base/BaseFund.sol

pragma solidity ^0.8.12;

// External libraries
// Code
// Temporary
/**
 * @title BaseFund
 * @author Translucent
 *
 * @notice The basic fund contract that allows transacting with protocols.
 */
contract BaseFund is Context, IBaseFund {
    /** Helpers */
    IOpsGovernor private _opsGovernor;

    /** Events */
    event TransactCall(address indexed callAddress, bytes4 indexed selector);

    /** Receive function to allow receiving eth */
    receive() external payable {}

    /****************************************/
    /** Functions to set the fund's helpers */
    /****************************************/
    /**
     * Sets the helpers for the base fund.
     *
     * @param opsGovernorAddress - The address of the ops governor to set.
     */
    function setBaseFundHelpers(address opsGovernorAddress) external override {
        // If already set, run checks first
        if (address(_opsGovernor) != address(0)) {
            require(
                _msgSender() == address(_opsGovernor),
                "BaseFund: can only be migrated from the current ops governor"
            );
            require(
                opsGovernorAddress != address(0),
                "BaseFund: cannot migrate opsGovernor to the 0x0 address"
            );
        }

        // Set the helpers
        _opsGovernor = IOpsGovernor(opsGovernorAddress);
    }

    /******************************************************/
    /********* Functions to facilitate transactions *******/
    /******************************************************/
    /**
     * Performs a single call
     *
     * @notice Only operators can call this.
     * @param callInput - The inputs to make the call with.
     */
    function call(CallInput calldata callInput) external {
        _opsGovernor.requireOperators(_msgSender());
        _call(callInput);
    }

    /**
     * Performs multiple calls atomically
     *
     * @notice Only operators can call this.
     * @param callInputs - The array of inptus to make the calls with.
     */
    function multiCall(CallInput[] calldata callInputs) external {
        _opsGovernor.requireOperators(_msgSender());

        for (uint256 i = 0; i < callInputs.length; i++) {
            _call(callInputs[i]);
        }
    }

    /**
     * Performs checks based on call type and perform the call
     *
     * @param callInput - The inputs to call with.
     */
    function _call(CallInput memory callInput) internal {
        bytes4 selector = bytes4(
            LowLevelHelpers.sliceBytes(callInput.callData, 0, 4)
        );

        // Transact with a token (e.g. approve/increaseAllowance)
        if (callInput.callType == CallType.TOKEN) {
            // Require that the address is a registered token
            _opsGovernor.requireTokenRegistered(callInput.callAddress);
            
            // Run checks on the call data before executing
            _checkSelector(selector, callInput.callData);
            LowLevelHelpers.performCall(
                callInput.callAddress,
                callInput.callData,
                callInput.value
            );
        }

        // Transact directly with protocol
        else if (callInput.callType == CallType.PROTOCOL) {
            // Require that the address is a registered protocol
            _opsGovernor.requireProtocolRegistered(callInput.callAddress);

            // Run checks on the selector before executing
            _checkSelector(selector, callInput.callData);
            LowLevelHelpers.performCall(
                callInput.callAddress,
                callInput.callData,
                callInput.value
            );
        }

        // Transact via utils
        else if (callInput.callType == CallType.UTIL) {
            // Require that the address is a registered util
            _opsGovernor.requireUtilRegistered(callInput.callAddress);

            // Execute the delegate call
            LowLevelHelpers.performDelegateCall(
                callInput.callAddress,
                callInput.callData
            );
        }

        // Emit the event
        emit TransactCall(callInput.callAddress, selector);
    }

    /**
     * Checks the selector
     *
     * @param selector - The selector to check.
     * @param callData - The encoded call data to check.
     */
    function _checkSelector(bytes4 selector, bytes memory callData) internal view {
        require(
            // bytes4(keccak("transfer(address,uint256)")) --> 0xa9059cbb
            selector != bytes4(0xa9059cbb),
            "BaseFund: cannot call transfer function"
        );
        require(
            // bytes4(keccak("transferFrom(address,address,uint256)")) --> 0x23b872dd
            selector != bytes4(0x23b872dd),
            "BaseFund: cannot call transferFrom function"
        );
        require(
            // bytes4(keccak("mintBehalf(address,uint256)")) --> 0x23323e03
            selector != bytes4(0x23323e03),
            "BaseFund: cannot call mintBehalf function"
        );

        // Check the address in increaseAllowance and approve calls
        // that they are called only for protocols
        if (
            // bytes4(keccak("increaseAllowance(address,uint256)")) --> 0x39509351
            selector == bytes4(0x39509351)
            // bytes4(keccak("approve(address,uint256") --> 0x095ea7b3
            || selector == bytes4(0x095ea7b3)
        ) {
            address inputAddress = LowLevelHelpers.bytesToAddress(
                LowLevelHelpers.sliceBytes(callData, 16, 20)
            );
            _opsGovernor.requireProtocolRegistered(inputAddress);
        }
    }
}


// File src/contracts/main/MainFund.sol

pragma solidity ^0.8.12;

// External libraries
// Code
/**
 * @title MainFund
 * @author Translucent
 *
 * @notice The main fund contract that facilitates front-facing features.
 */
contract MainFund is Context, BaseFund, IMainFund {
    /** Libraries */
    using SafeERC20 for IERC20;

    /** References */
    ICAO private _cao;
    IMainFundToken private _token;
    IAccounting private _accounting;
    IFrontOffice private _frontOffice;
    IIncentivesManager private _incentivesManager;

    /**
     * Sets the helpers for the main fund.
     *
     * @param caoAddress - The address of the cao to set.
     * @param tokenAddress - The address of the fund token to set.
     * @param accountingAddress - The address of the accounting to set.
     * @param frontOfficeAddress - The address of the front office to set.
     * @param incentivesManagerAddress - The address of the incentives manager to set.
     */
    function setMainFundHelpers(
        address caoAddress,
        address tokenAddress,
        address accountingAddress,
        address frontOfficeAddress,
        address incentivesManagerAddress
    ) external override {
        // If already set, run checks first
        if (address(_cao) != address(0)) {
            _cao.requireCAOGovernance(_msgSender());
            require(
                caoAddress != address(0)
                    && tokenAddress != address(0)
                    && accountingAddress != address(0)
                    && frontOfficeAddress != address(0)
                    && incentivesManagerAddress != address(0),
                "MainFund: cannot migrate any of the helpers to the 0x0 address"
            );
        }

        // Set the helpers
        _cao = ICAO(caoAddress);
        _token = IMainFundToken(tokenAddress);
        _accounting = IAccounting(accountingAddress);
        _frontOffice = IFrontOffice(frontOfficeAddress);
        _incentivesManager = IIncentivesManager(incentivesManagerAddress);
    }

    /****************************************/
    /** Functions to get the fund's helpers */
    /****************************************/
    function getCAO() external view override returns (ICAO) {
        return _cao;
    }
    function getFundToken() external view override returns (IMainFundToken) {
        return _token;
    }
    function getAccounting() external view override returns (IAccounting) {
        return _accounting;
    }
    function getFrontOffice() external view override returns (IFrontOffice) {
        return _frontOffice;
    }
    function getIncentivesManager() external view override returns (IIncentivesManager) {
        return _incentivesManager;
    }

    /************************************************/
    /** Functions to facilitate withdrawals (tasks) */
    /************************************************/
    /**
     * Approves the front office to spend tokens for withdrawals.
     *
     * @dev No need to check if token is allowed since Front Office
     *      can only process withdrawals on allowed tokens.
     *
     * @param tokensAddresses - The addresses of the tokens to approve.
     * @param amounts - The amounts to approve for each token.
     */
    function approveFrontOfficeForWithdrawals(
        address[] calldata tokensAddresses,
        uint256[] calldata amounts
    ) external override {
        // Only callable by the CAO's task runner
        _cao.requireCAOTaskRunner(_msgSender());

        // Require valid input array lengths
        require(
            tokensAddresses.length == amounts.length,
            "MainFund: invalid array lengths"
        );

        // Approve each input token to be spent by front office for withdrawals
        address frontOfficeAddress = address(_frontOffice);
        for (uint256 i = 0; i < tokensAddresses.length; i++)
            IERC20(tokensAddresses[i]).approve(frontOfficeAddress, amounts[i]);
    }
}