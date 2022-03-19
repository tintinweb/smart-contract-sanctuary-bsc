// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
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
     * by making the `nonReentrant` function external, and making it call a
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Create2.sol)

pragma solidity ^0.8.0;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) internal returns (address) {
        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address) {
        bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return address(uint160(uint256(_data)));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./interfaces/ISafePool.sol";
import "./interfaces/IGovernance.sol";
import "./interfaces/IStaking.sol";
import "./interfaces/ITokenVesting.sol";
import "./interfaces/ITokenVestingRouter.sol";

contract SafePool is ISafePool, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public constant MAGNITUDE = 1 << 96;
    uint256 public constant MAX_FEE_POLICY_LENGTH = 100;

    State public state;
    Config public config;
    IGovernance public governance;
    ITokenVesting public projectTokenVesting;

    uint256 public totalInvestmentAmount;
    uint256 public totalProjectTokenAmount;
    uint256 public poolStartedAt;

    mapping (address => uint256) public investmentAmountOf;
    mapping (address => uint256) public projectTokenClaimsOf;
    mapping (address => uint256) public poolDepositsOf;

    modifier deployed {
        require(state == State.Deployed, "state: !deployed");
        _;
    }

    modifier started {
        require(state == State.Started, "state: !started");
        _;
    }

    modifier reverted {
        require(state == State.Reverted, "state: !reverted");
        _;
    }

    modifier acomplished {
        require(state == State.Acomplished, "state: !acomplished");
        _;
    }

    modifier acomplishedOrReverted {
        require(
            state == State.Acomplished || state == State.Reverted,
            "state: !acomplished & !reverted"
        );
        _;
    }

    modifier ongoing {
        require(
            block.timestamp <= poolStartedAt + config.poolDuration,
            "!ongoing"
        );
        _;
    }

    modifier timesupOrFullyFunded {
        require(
            block.timestamp > poolStartedAt + config.poolDuration || 
            totalInvestmentAmount == config.targetInvestmentAmount,
            "!(time is up) & !(fully funded)"
        );
        _;
    }

    constructor(Config memory config_, address governance_) {
        _validateConfig(config_);
        config = config_;
        state = State.Deployed;
        governance = IGovernance(governance_);
    }

    function depositProjectTokensAndStartPool() external deployed nonReentrant {
        uint256 length;
        uint256 amount;
        for (uint256 i; i != length; ++i) {
            amount += config.vestingAmounts[i];
        }
        totalProjectTokenAmount = amount;
        poolStartedAt = block.timestamp;
        state = State.Started;
        config.projectToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Started();
    }

    function depositPool(uint256 amount) external started ongoing nonReentrant {
        poolDepositsOf[msg.sender] += amount;
        IERC20(governance.pool()).safeTransferFrom(msg.sender, address(this), amount);
        emit PoolDeposited(msg.sender, amount);
    }

    function makeInvestment(uint256 amount) external started ongoing nonReentrant {
        require(
            totalInvestmentAmount + amount <= config.targetInvestmentAmount,
            "amount is too large"
        );
        require(
            amount <= maxAllowedInvestmentAmountOf(msg.sender),
            "amount is not allowed"
        );
        require(
            investmentAmountOf[msg.sender] == 0,
            "investment already made"
        );
        uint256 fees = calcFees(amount);
        uint256 investmentAmount = amount - fees;
        investmentAmountOf[msg.sender] += investmentAmount;
        totalInvestmentAmount += investmentAmount;
        config.investmentToken.safeTransferFrom(msg.sender, address(this), investmentAmount);
        config.investmentToken.safeTransferFrom(msg.sender, governance.protocolTreasury(), fees);
        emit FeesCharged(msg.sender, fees);
        emit InvestmentMade(msg.sender, investmentAmount);
    }

    function finalizePool() external started timesupOrFullyFunded nonReentrant {
        if (totalInvestmentAmount == config.targetInvestmentAmount) {
            state = State.Acomplished;
            emit Acomplished();
        } else {
            state = State.Reverted;
            emit Reverted();
        }
    }

    function reclaimInvestments() external reverted nonReentrant {
        uint256 amount = investmentAmountOf[msg.sender];
        if (amount != 0) {
            investmentAmountOf[msg.sender] = 0;
            config.investmentToken.safeTransfer(msg.sender, amount);
            emit InvestmentReclaimed(msg.sender);
        }
    }

    function reclaimProjectTokens() external reverted nonReentrant {
        uint256 amount = totalProjectTokenAmount;
        if (amount != 0) {
            totalProjectTokenAmount = 0;
            config.projectToken.safeTransferFrom(msg.sender, address(this), amount);
            emit ProjectTokensReclaimed();
        }
    }

    function reclaimPool() external acomplishedOrReverted nonReentrant {
        uint256 amount = poolDepositsOf[msg.sender];
        if (amount != 0) {
            poolDepositsOf[msg.sender] = 0;
            IERC20(governance.pool()).safeTransfer(msg.sender, amount);
            emit PoolReclaimed(msg.sender);
        }
    }

    function claimInvestments() external acomplished nonReentrant {
        uint256 amount = totalInvestmentAmount;
        if (amount != 0) {
            totalInvestmentAmount = 0;
            config.investmentToken.safeTransfer(config.projectTreasury, amount);
            emit InvestmentsClaimed();
        }
    }

    function configureProjectTokensVesting() external acomplished nonReentrant {
        require(
            address(projectTokenVesting) == address(0),
            "can not be address zero"
        );
        ITokenVestingRouter tokenVestingRouter = ITokenVestingRouter(governance.tokenVestingRouter());
        address tokenVesting_ = tokenVestingRouter.tokenVestingOf(address(config.projectToken));
        if (tokenVesting_ == address(0)) {
            tokenVesting_ = tokenVestingRouter.createTokenVesting(
                address(config.projectToken)
            );
        }
        projectTokenVesting = ITokenVesting(tokenVesting_);
        config.projectToken.approve(address(projectTokenVesting), totalProjectTokenAmount);
        projectTokenVesting.depositAndConfigureVesting(
            config.vestingTimestamps,
            config.vestingAmounts,
            address(this)
        );
    }

    function claimProjectTokens() external acomplished nonReentrant {
        require(
            address(projectTokenVesting) != address(0),
            "can not be address zero"
        );
        projectTokenVesting.claim();
        uint256 amount = claimableAmountOf(msg.sender);
        if (amount != 0) {
            projectTokenClaimsOf[msg.sender] += amount;
            config.projectToken.safeTransfer(msg.sender, amount);
            emit ProjectTokensClaimed(msg.sender, amount);
        }
    }

    function calcFees(uint256 amount) public view returns (uint256) {
        // TODO: binary search
        uint256[] memory feePolicy = config.feePolicy;
        uint256 percentage;
        uint256 i = 1;
        uint256 length = feePolicy.length;
        while (i < length && feePolicy[i] <= amount) {
            i += 2;
        }
        if (feePolicy[i] <= amount) {
            percentage = feePolicy[length - 1];
        } else {
            percentage = feePolicy[i - 1];
        }
        return amount * percentage / 100;
    }

    function maxAllowedInvestmentAmountOf(address target) public view returns (uint256) {
        if (investmentAmountOf[target] != 0) return 0;
        uint256 poolVesting = ITokenVesting(governance.poolVesting()).lockedAmountOf(target);
        uint256 poolStaking = IStaking(governance.poolStaking()).withdrawableAmountOf(target);
        uint256 result = poolVesting + poolStaking + poolDepositsOf[msg.sender];
        uint256 targetAmount = config.targetInvestmentAmount;
        return targetAmount > result ? result : targetAmount;
    }

    function totalUnlockedProjectTokensAmount() public view returns (uint256) {
        return (
            projectTokenVesting.totalClaimsOf(address(this)) + 
            projectTokenVesting.claimableAmountOf(address(this))
        );
    }

    function claimableAmountOf(address target) public view returns (uint256) {
        uint256 magnifiedShares = (
            MAGNITUDE * investmentAmountOf[target] 
            / totalInvestmentAmount
        );
        return (
            (magnifiedShares * totalUnlockedProjectTokensAmount() / MAGNITUDE) - 
            projectTokenClaimsOf[msg.sender]
        );
    }

    function _validateConfig(Config memory config_) internal view {
        bool vestingTimestampsAscendig = true;
        for (uint256 i = 1; i != config_.vestingTimestamps.length; ++i) {
            if (config_.vestingTimestamps[i] <= config_.vestingTimestamps[i - 1]) {
                vestingTimestampsAscendig = false;
                break;
            }
        }
        require(
            config_.vestingTimestamps.length != 0 &&
            config_.vestingTimestamps.length == config_.vestingAmounts.length &&
            vestingTimestampsAscendig,
            "config: vestingTimestamps"
        );
        require(
            governance.isAllowedInvestmentToken(address(config_.investmentToken)),
            "config: investmentToken"
        );
        require(
            _validateFeePolicy(config.feePolicy),
            "config: feePolicy"
        );
    }

    function _validateFeePolicy(uint256[] memory _feePolicy) internal pure returns (bool) {
        // odd elements are amounts, even elements are percentages
        if (_feePolicy.length % 2 != 1 || _feePolicy.length > MAX_FEE_POLICY_LENGTH) {
            return false;
        }
        // amounts must be ascending
        for (uint256 i = 1; i < _feePolicy.length - 1; i += 2) {
            if (_feePolicy[i] <= _feePolicy[i - 1]) {
                return false;
            }
        }
        // percentages must be less then 100
        for (uint256 i; i < _feePolicy.length; i += 2) {
            if (_feePolicy[i] > 100) {
                return false;
            }
        }
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/Create2.sol";

import "./interfaces/IPoolFactory.sol";
import "./interfaces/ISafePool.sol";
import "./interfaces/IPool.sol";
import "./SafePool.sol";

contract SafePoolFactory is IPoolFactory {
    function deploy(bytes calldata options, address governance) external returns (IPool) {
        ISafePool.Config memory config = abi.decode(options, (ISafePool.Config));
        ISafePool safePool = new SafePool(config, governance);
        return IPool(safePool);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IGovernance {
    event PoolChanged(address poolToken);
    event PoolStakingChanged(address poolStaking);
    event PoolVestingChanged(address poolVesting);
    event TokenVestingRouterChanged(address tokenVestingRouter);
    event ProtocolTreasuryChanged(address protocolTreasury);
    event AllowedInvestmentTokenAdded(address token);
    event AllowedInvestmentTokenRemoved(address token);

    function admin() external view returns (address);

    function pool() external view returns (address);

    function poolStaking() external view returns (address);

    function poolVesting() external view returns (address);

    function tokenVestingRouter() external view returns (address);

    function allowedInvestmentTokens() external view returns (address[] memory);

    function protocolTreasury() external view returns (address);

    function isAllowedInvestmentToken(address) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IPool {}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./IPool.sol";

interface IPoolFactory {
    function deploy(bytes calldata options, address governance) external returns (IPool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IPool.sol";
import "./IGovernance.sol";
import "./ITokenVesting.sol";

interface ISafePool is IPool {
    enum State {
        Deployed,
        Started,
        Acomplished,
        Reverted
    }

    struct Config {
        IERC20 investmentToken;
        IERC20 projectToken;
        address projectTreasury;
        uint256 poolDuration;
        uint256 targetInvestmentAmount;
        uint256[] vestingTimestamps;
        uint256[] vestingAmounts;
        uint256[] feePolicy;
    }

    event Started();
    event Acomplished();
    event Reverted();
    event InvestmentMade(address indexed investor, uint256 amount);
    event ProjectTokensClaimed(address indexed investor, uint256 amount);
    event PoolDeposited(address indexed investor, uint256 amount);
    event PoolReclaimed(address indexed investor);
    event InvestmentReclaimed(address indexed investor);
    event FeesCharged(address indexed investor, uint256 amount);
    event ProjectTokensReclaimed();
    event InvestmentsClaimed();

    // public vars
    function MAGNITUDE() external view returns (uint256);

    function state() external view returns (State);

    function governance() external view returns (IGovernance);

    function projectTokenVesting() external view returns (ITokenVesting);

    function totalInvestmentAmount() external view returns (uint256);

    function totalProjectTokenAmount() external view returns (uint256);

    function poolStartedAt() external view returns (uint256);

    function investmentAmountOf(address investor) external returns (uint256);

    function projectTokenClaimsOf(address investor) external view returns (uint256);

    function poolDepositsOf(address investor) external returns (uint256);

    // external functions
    function depositProjectTokensAndStartPool() external;

    function depositPool(uint256 amount) external;

    function makeInvestment(uint256 amount) external;

    function finalizePool() external;

    function reclaimInvestments() external;

    function reclaimProjectTokens() external;

    function reclaimPool() external;

    function claimInvestments() external;

    function configureProjectTokensVesting() external;

    function claimProjectTokens() external;

    // public functions
    function maxAllowedInvestmentAmountOf(address target) external view returns (uint256);

    function totalUnlockedProjectTokensAmount() external view returns (uint256);

    function claimableAmountOf(address target) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IStaking {
    function withdrawableAmountOf(address target) external view returns (uint256);

    function deposit(address from, uint256 amount) external;

    function withdraw(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface ITokenVesting {
    function depositAndConfigureVesting(
        uint256[] memory timestamps,
        uint256[] memory amounts,
        address investor
    ) external;

    function router() external view returns (address);

    function token() external view returns (address);

    function claim() external;

    function breakExpiredLocksOf(address investor) external;

    function claimableAmountOf(address investor) external view returns (uint256);

    function detailedLocksOf(address investor) external view returns (uint256[] memory, uint256[] memory);

    function lockedAmountOf(address investor) external view returns (uint256);

    function totalDepositsOf(address investor) external view returns (uint256);

    function totalClaimsOf(address investor) external view returns (uint256);

    event ConfiguredVesting(address indexed investor, uint256[] timestamps, uint256[] amounts);

    event Claimed(address indexed investor, uint256 amount);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface ITokenVestingRouter {
    function createTokenVesting(address token) external returns (address);

    function tokenVestingOf(address token) external view returns (address);

    function tokenVestingAt(uint256 id) external view returns (address);

    function tokenVestingsCount() external view returns (uint256);

    function tokenVestingFactory() external view returns (address);

    function setTokenVestingFactory(address factory) external;
}