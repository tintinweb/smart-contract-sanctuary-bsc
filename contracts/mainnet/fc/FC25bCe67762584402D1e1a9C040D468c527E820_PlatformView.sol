// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IAccountToken {

    enum LiquidationStatus {
        NOT_REQUESTED,
        IN_PROGRESS,
        AVAILABLE
    }

    struct LiquidationInfo {
        LiquidationStatus status;
        uint256 requestTime;
        uint256 availableTime;
        uint256 expirationTime;
    }

    event AccountCreated(address indexed to, uint256 indexed tokenId, uint256 indexed directUplink, uint256 apy, string referralLink);
    event ReferralLinkChanged(uint256 indexed tokenId, string oldLink, string newLink);
    event AccountLiquidated(uint256 indexed nftId);
    event AccountLiquidationStarted(uint256 indexed nftId);
    event AccountLiquidationCanceled(uint256 indexed nftId);
    event AccountUpgraded(uint256 indexed nftId, uint256 indexed level, uint256 apy);

    function createAccount(address to, uint256 directUplink, uint256 level, string calldata newReferralLink) external returns (uint256);

    function setReferralLink(uint256 tokenId, string calldata referralLink) external;

    function accountLiquidated(uint256 tokenId) external view returns (bool);

    function getAddressNFTs(address userAddress) external view returns (uint256[] memory NFTs, uint256 numberOfActive);

    function balanceOf(address owner) external view returns (uint256 balance);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function upgradeAccountToLevel(uint256 tokenId, uint256 level) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function getAccountLevel(uint256 tokenId) external view returns (uint256);

    function getAccountDirectlyEnrolledMembers(uint256 tokenId) external view returns (uint256);

    function getAccountReferralLink(uint256 tokenId) external view returns (string memory);

    function getAccountByReferral(string calldata referralLink) external view returns (uint256);

    function referralLinkExists(string calldata referralCode) external view returns (bool);

    function getLevelMatrixParent(uint256, uint256) external view returns (uint256 newParent, uint256[] memory overtakenUsers);

    function getDirectUplink(uint256) external view returns (uint256);

    function getAverageAPY() external view returns (uint256);

    function totalMembers() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function getLiquidationInfo(uint256 tokenId) external view returns (LiquidationInfo memory);

    function requestLiquidation(uint256 tokenId) external returns (bool);

    function liquidateAccount(uint256 tokenId) external;

    function cancelLiquidation(uint256 tokenId) external;

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBuybackController {

    event BoughtBackMFI(address indexed token, uint256 tokenAmount, uint256 mfiReceived);

    function buyBackMFI(address token, uint256 tokenAmount, uint256 minMFIOut) external;

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IMatrix.sol";
import "./ILiquidityController.sol";
import "./IBuybackController.sol";

interface IContractRegistry {

    function contractAddressExists(bytes32 nameHash) external view returns (bool);
    function matrixExists(uint256 level) external view returns (bool);
    function liquidityControllerExists(string calldata name) external view returns (bool);
    function buybackControllerExists(string calldata name) external view returns (bool);
    function priceCalculatorExists(address currency) external view returns (bool);

    function getContractAddress(bytes32 nameHash) external view returns (address);
    function getMatrix(uint256 level) external view returns (IMatrix);
    function getLiquidityController(string calldata name) external view returns (ILiquidityController);
    function getBuybackController(string calldata name) external view returns (IBuybackController);
    function getPriceCalculator(address currency) external view returns (address);
    function isRealmGuardian(address guardianAddress) external view returns (bool);
    function isCoinMaster(address masterAddress) external view returns (bool);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDestroyableContract {
    function destroyContract(address payable to) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILiquidityController {

    event LiquidityProvided(address indexed tokenUsed, uint256 mfiProvided, uint256 liquidityTokensProvided, uint256 lpTokensReceived);
    event LiquidityRemoved(address indexed tokenUsed, uint256 lpTokensRedeemed, uint256 mfiReceived, uint256 liquidityTokensReceived);

    function getLPTokenAddress(address tokenToUse) external view returns (address);
    function claimableTokensFromTreasuryLPTokens(address tokenToUse) external view returns (uint256);
    function mfiRequiredForProvidingLiquidity(address tokenToUse, uint256 amount, uint256 MFIMin) external view returns (uint256);
    function provideLiquidity(address tokenToUse, uint256 amount, uint256 MFIMin) external;
    function removeLiquidity(address tokenToUse, uint256 lpTokenAmount, uint256 tokenMin) external;

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILostTokenProvider {
    function getLostTokens(address tokenAddress) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMatrix {

    event NodeAdded(uint256 indexed nftId, uint256 indexed parentId, uint256 indexed parentLeg);
    event SubtreeNodeAdded(uint256 indexed nftId, uint256 indexed offset, uint256 indexed level);

    struct Node {
        uint256 ID;
        uint256 ParentID;
        uint256 L0;
        uint256 L1;
        uint256 L2;
        uint256 parentLeg;
    }

    function addNode(uint256 nodeId, uint256 parentId) external;
    function getDistributionNodes(uint256 nodeId) external view returns (uint256[] memory distributionNodes);
    function getUsersInLevels(uint256 nodeId, uint256 numberOfLevels) external view returns (uint256[] memory levels, uint256 totalUsers);
    function getSubNodesToLevel(uint256 nodeId, uint256 toDepthLevel) external view returns (Node memory parentNode, Node[] memory subNodes);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ITokenCollector.sol";
import "./IMatrix.sol";
import "./IRewardDistributor.sol";
import "./IUserConfig.sol";

interface IPlatformView {

    struct NFTData {
        uint256 ID;
        uint256 level;
        string referralLink;
        uint256 directUplink;
        uint256 stakedTokens;
        IRewardDistributor.RewardAccountInfo rewardingInfo;
        uint256[][] usersInLevel;
        uint256[] totalUsersInMatrix;
        uint256 directlyEnrolledMembers;
        uint256 liquidationRequestTime;
        uint256 liquidationAvailableTime;
        uint256 liquidationExpiredTime;
        bool liquidated;
        IUserConfig.UserConfigValues userConfigValues;
    }

    struct TreeNodeData {
        NFTData nftData;
        IMatrix.Node node;
    }

    struct PlatformData {
        uint256 MFIPrice;
        uint256 totalMembers;
        uint256 averageAPY;
        uint256 treasuryValue;
        uint256 treasuryRiskFreeValue;
        uint256 stakedTokens;
        uint256 valuePerToken;
        uint256 backingPerToken;
        uint256 nextRebaseAt;
        uint256 totalRewardsPaid;
        ITokenCollector.CollectionType tokenCollectionType;
        ITokenCollector.PriceCalculationType priceCalculationType;
        uint256 tokenCollectionPercentage;
        uint256 mfiLiquidityReserve;
        uint256 busdLiquidityReserve;
    }

    function getWalletData(address wallet) external view returns (NFTData[] memory);
    function getNFTData(uint256 nftId) external view returns (NFTData memory NFT);
    function getReferralCodeData(string calldata referralCode) external view returns (NFTData memory);
    function referralLinkExists(string calldata referralCode) external view returns (bool);

    function getMFIPrice() external view returns (uint256);
    function getPlatformData() external view returns (PlatformData memory);

    function getTreeData(uint256 nftId, uint256 matrixLevel, uint256 toDepthLevel) external view returns (TreeNodeData memory selectedNFT, TreeNodeData[] memory subNFTs);

    function stakedTokens(uint256 nftId) external view returns (uint256);
    function stakedTokensForAddress(address wallet) external view returns (uint256);
    function getUsersInLevels(uint256 nodeId, uint256 level) external view returns (uint256[] memory levels, uint256 totalUsers);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPriceCalculator {

    function exchangePairSet() external view returns (bool);
    function getReserves() external view returns (uint256 calculatedTokenReserve, uint256 reserveTokenReserve);
    function getPriceInUSD() external view returns (uint256);
    function tokensForPrice(uint256 reserveTokenAmount) external view returns (uint256);
    function priceForTokens(uint256 numberOfTokens) external view returns (uint256);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IMatrix.sol";

interface IRewardDistributor {

    event AccountCreated(uint256 indexed nftId, uint256 indexed parentId);
    event AccountUpgraded(uint256 indexed nftId, uint256 indexed level);
    event BonusActivated(uint256 indexed nftId);
    event AccountLiquidated(uint256 indexed nftId);

    event RewardSent(uint256 indexed nftId, uint256 indexed from, uint256 indexed rewardType, uint256 level, uint256 matrixLevel, uint256 amount);
    event MatchingBonusSent(uint256 indexed nftId, uint256 indexed from, uint256 amount);
    event FastStartBonusReceived(uint256 indexed nftId, uint256 indexed from, uint256 amount, bool autoClaimed);

    struct RewardAccountInfo {
        uint256 ID;
        uint256 directUplink;
        uint256 fastStartBonus;
        uint256 receivedMatchingBonus;
        uint256 receivedMatrixBonus;
        uint64 bonusDeadline;
        uint64 activeBonusUsers;
        bool bonusActive;
        bool accountLiquidated;
    }

    function getAccountInfo(uint256 nftId) external view returns (RewardAccountInfo memory);
    function createAccount(uint256 nftId, uint256 parentId) external;
    function accountUpgraded(uint256 nftId, uint256 level) external;
    function liquidateAccount(uint256 nftId) external;
    function distributeRewards(uint256 distributionValue, uint256 rewardType, uint256 nftId, uint256 level) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IStakingManager {

    event StakingAccountCreated(uint256 indexed nftId, uint256 indexed level, uint256 numberOfTokens);
    event StakingAccountLiquidated(uint256 indexed nftId, uint256 unstakedTokens);
    event TokensAddedToStaking(uint256 indexed nftId, uint256 numberOfTokens);
    event StakingAccountUpgraded(uint256 indexed nftId, uint256 indexed level, uint256 numberOfTokens);
    event StakingLevelRebased(uint256 indexed level, uint256 lockedTokens);
    event StakingRebased(uint256 totalTokens);

    function getAccountTokens(uint256 tokenId) external view returns(uint256);
    function createStakingAccount(uint256 tokenId, uint256 tokenAmount, uint256 level) external;
    function liquidateAccount(uint256 tokenId, address owner) external;
    function addTokensToStaking(uint256 tokenId, uint256 numberOfTokens) external;
    function upgradeStakingAccountToLevel(uint256 tokenId, uint256 level) external;
    function timeToNextRebase() external view returns (uint256);
    function nextRebaseAt() external view returns (uint256);
    function rebase() external;

    function enterLiquidation() external returns (uint256 totalMFIStaked);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ITokenCollector {

    event CollectedBonusTokens(uint256 busdPrice, uint256 numberOfTokens);
    event CollectedTokens(uint256 busdPrice, uint256 numberOfTokens, uint256 collectionType, uint256 slippageCalculationType);
    event CollectionTypeChanged(uint256 collectionType);
    event PriceCalculationTypeChanged(uint256 priceCalculationType);

    enum CollectionType {
        MINTING,
        SWAP
    }

    enum PriceCalculationType {
        TOKEN_PRICE_BASED,
        POOL_BASED
    }

    function getBonusTokens(uint256 busdPrice) external returns (uint256);
    function getTokens(uint256 busdPrice, uint256 minTokensOut) external returns (uint256);
    function getCollectionType() external view returns (CollectionType);
    function getPriceCalculationType() external view returns (PriceCalculationType);
    function getAdditionalTokensPercentage() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ITreasuryAllocator.sol";

interface ITreasury {

    event StakingRewardsDistributed(uint256 indexed amount);
    event RewardsSent(uint256 nftId, uint256 amount);

    function distributeStakingRewards(uint256 amount) external;
    function sendReward(uint256 nftId, uint256 amount) external;

    function getValue() external view returns (uint256 totalValue, uint256 riskFreeValue);
    function getTotalRewardsPaid() external view returns (uint256);

    function getTokensForCollector(address token, uint256 amount, address to) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ITreasuryAllocator {

    function setAllocatorId(uint256 id) external;
    function requestReturn() external;
    function returnAvailableTokens() external;
    function returnNumberOfTokens(uint256 amount) external;
    function getAllocationStatus() external view returns (uint256 riskFreeValue, uint256 totalValue, uint256 immediatelyClaimable);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUserConfig {

    event UserConfigUintValueUpdated(address indexed user, string indexed key, uint256 old_value, uint256 new_value);
    event UserConfigStringValueUpdated(address indexed user, string indexed key, string old_value, string new_value);
    event AllowedStringKeyAdded(string key);
    event AllowedUintKeyAdded(string key);

    struct UserConfigUintValue {
        string key;
        uint256 value;
    }

    struct UserConfigStringValue {
        string key;
        string value;
    }

    struct UserConfigValues {
        UserConfigUintValue[] uintValues;
        UserConfigStringValue[] stringValues;
    }

    function getAllUserConfigValues(uint256 nftId) external view returns (UserConfigValues memory values);
    function getUserConfigUintValue(uint256 nftId, string memory key) external view returns (uint256 value);
    function getUserConfigStringValue(uint256 nftId, string memory key) external view returns (string memory value);

    function setUserConfigUintValue(uint256 nftId, string memory key, uint256 value) external;
    function setUserConfigStringValue(uint256 nftId, string memory key, string memory value) external;

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IPlatformView.sol";
import "./interfaces/IAccountToken.sol";
import "./interfaces/IPriceCalculator.sol";
import "./interfaces/ITreasury.sol";
import "./interfaces/IStakingManager.sol";
import "./interfaces/IContractRegistry.sol";
import "./interfaces/ILostTokenProvider.sol";
import "./interfaces/IDestroyableContract.sol";

contract PlatformView is IPlatformView, ILostTokenProvider, IDestroyableContract {

    using SafeERC20 for IERC20;

    IContractRegistry contractRegistry;

    uint256 numberOfLevels = 10;

    bytes32 constant MFI_HASH = keccak256(abi.encodePacked('mfi'));
    bytes32 constant TREASURY_HASH = keccak256(abi.encodePacked('treasury'));
    bytes32 constant STAKING_MANAGER_HASH = keccak256(abi.encodePacked('staking_manager'));
    bytes32 constant TOKEN_COLLECTOR_HASH = keccak256(abi.encodePacked('token_collector'));
    bytes32 constant REWARD_DISTRIBUTOR_HASH = keccak256(abi.encodePacked('reward_distributor'));
    bytes32 constant ACCOUNT_TOKEN_HASH = keccak256(abi.encodePacked('account_token'));
    bytes32 constant USER_CONFIG_HASH = keccak256(abi.encodePacked('user_config'));

    modifier onlyTreasury() {
        require(msg.sender == contractRegistry.getContractAddress(TREASURY_HASH));
        _;
    }

    constructor(
        IContractRegistry _contractRegistry
    ) {
        contractRegistry = _contractRegistry;
    }

    function getNFTData(uint256 nftId) public view override returns (NFTData memory NFT) {

        IRewardDistributor rewardDistributor = IRewardDistributor(contractRegistry.getContractAddress(REWARD_DISTRIBUTOR_HASH));
        IAccountToken accountTokens = IAccountToken(contractRegistry.getContractAddress(ACCOUNT_TOKEN_HASH));
        IUserConfig userConfig = IUserConfig(contractRegistry.getContractAddress(USER_CONFIG_HASH));

        NFT.ID = nftId;
        NFT.level = accountTokens.getAccountLevel(nftId);
        NFT.referralLink = accountTokens.getAccountReferralLink(nftId);
        NFT.directUplink = accountTokens.getDirectUplink(nftId);
        NFT.stakedTokens = stakedTokens(nftId);
        NFT.rewardingInfo = rewardDistributor.getAccountInfo(nftId);
        NFT.directlyEnrolledMembers = accountTokens.getAccountDirectlyEnrolledMembers(nftId);
        NFT.userConfigValues = userConfig.getAllUserConfigValues(nftId);

        IAccountToken.LiquidationInfo memory liquidationInfo = accountTokens.getLiquidationInfo(nftId);
        NFT.liquidationRequestTime = liquidationInfo.requestTime;
        NFT.liquidationAvailableTime = liquidationInfo.availableTime;
        NFT.liquidationExpiredTime = liquidationInfo.expirationTime;
        NFT.liquidated = accountTokens.accountLiquidated(nftId);

        if (NFT.liquidated) {
            NFT.referralLink = "LIQUIDATED TOKEN";
        }

        NFT.usersInLevel = new uint256[][](numberOfLevels);
        NFT.totalUsersInMatrix = new uint256[](numberOfLevels);

        for (uint256 x; x < NFT.level + 1; x++) {
            NFT.usersInLevel[x] = new uint256[](10);
        }

        for (uint256 x = 0; x < NFT.level + 1; x++) {
            (NFT.usersInLevel[x], NFT.totalUsersInMatrix[x]) = getUsersInLevels(nftId, x);
        }

        return NFT;
    }

    function getWalletData(address wallet) public view override returns (NFTData[] memory NFTs) {

        IAccountToken accountTokens = IAccountToken(contractRegistry.getContractAddress(ACCOUNT_TOKEN_HASH));
        (uint256[] memory activeNFTs, uint256 numberOfTokens) = accountTokens.getAddressNFTs(wallet);

        NFTs = new NFTData[](numberOfTokens);
        for (uint256 x = 0; x < numberOfTokens; x++) {
            NFTs[x] = getNFTData(activeNFTs[x]);
        }

        return NFTs;
    }

    function getReferralCodeData(string calldata referralCode) public view override returns (NFTData memory) {
        IAccountToken accountTokens = IAccountToken(contractRegistry.getContractAddress(ACCOUNT_TOKEN_HASH));
        return getNFTData(accountTokens.getAccountByReferral(referralCode));
    }

    function referralLinkExists(string calldata referralCode) public view override returns (bool) {
        IAccountToken accountTokens = IAccountToken(contractRegistry.getContractAddress(ACCOUNT_TOKEN_HASH));
        return accountTokens.referralLinkExists(referralCode);
    }

    function getMFIPrice() public view override returns (uint256){
        IPriceCalculator priceCalculator = IPriceCalculator(contractRegistry.getPriceCalculator(contractRegistry.getContractAddress(MFI_HASH)));
        return priceCalculator.getPriceInUSD();
    }

    function getPlatformData() public view override returns (PlatformData memory data) {

        ITreasury treasury = ITreasury(contractRegistry.getContractAddress(TREASURY_HASH));
        IPriceCalculator priceCalculator = IPriceCalculator(contractRegistry.getPriceCalculator(contractRegistry.getContractAddress(MFI_HASH)));
        ITokenCollector tokenCollector = ITokenCollector(contractRegistry.getContractAddress(TOKEN_COLLECTOR_HASH));
        IAccountToken accountTokens = IAccountToken(contractRegistry.getContractAddress(ACCOUNT_TOKEN_HASH));
        IStakingManager stakingManager = IStakingManager(contractRegistry.getContractAddress(STAKING_MANAGER_HASH));

        data.MFIPrice = priceCalculator.getPriceInUSD();
        data.totalMembers = accountTokens.totalMembers();
        data.averageAPY = accountTokens.getAverageAPY();
        (data.treasuryValue, data.treasuryRiskFreeValue) = treasury.getValue();
        data.stakedTokens = IERC20(contractRegistry.getContractAddress(MFI_HASH)).balanceOf(address(stakingManager));
        data.tokenCollectionType = tokenCollector.getCollectionType();
        data.priceCalculationType = tokenCollector.getPriceCalculationType();
        data.tokenCollectionPercentage = tokenCollector.getAdditionalTokensPercentage();
        data.totalRewardsPaid = treasury.getTotalRewardsPaid();

        if (data.stakedTokens > 0) {
            data.valuePerToken = data.treasuryValue / data.stakedTokens;
            data.backingPerToken = data.treasuryRiskFreeValue / data.stakedTokens;
        }

        data.nextRebaseAt = stakingManager.nextRebaseAt();

        (data.mfiLiquidityReserve, data.busdLiquidityReserve) = priceCalculator.getReserves();

        return data;
    }

    function getTreeData(uint256 nftId, uint256 matrixLevel, uint256 toDepthLevel) public view override returns (TreeNodeData memory selectedNFT, TreeNodeData[] memory subNFTs) {


        selectedNFT.nftData = getNFTData(nftId);
        IMatrix.Node[] memory subNodes;

        (selectedNFT.node, subNodes) = contractRegistry.getMatrix(matrixLevel).getSubNodesToLevel(nftId, toDepthLevel);
        subNFTs = new TreeNodeData[](subNodes.length);

        for (uint256 x = 0; x < subNodes.length; x++) {
            if (subNodes[x].ID > 0) {
                subNFTs[x].nftData = getNFTData(subNodes[x].ID);
                subNFTs[x].node = subNodes[x];
            }
        }

        return (selectedNFT, subNFTs);
    }

    function getUsersInLevels(uint256 nodeId, uint256 level) public view override returns (uint256[] memory levels, uint256 totalUsers) {
        return contractRegistry.getMatrix(level).getUsersInLevels(nodeId, 10);
    }

    function stakedTokens(uint256 nftId) public view override returns (uint256) {
        IStakingManager stakingManager = IStakingManager(contractRegistry.getContractAddress(STAKING_MANAGER_HASH));
        return stakingManager.getAccountTokens(nftId);
    }

    function stakedTokensForAddress(address wallet) public view override returns (uint256) {

        uint256 totalTokens = 0;

        IAccountToken accountTokens = IAccountToken(contractRegistry.getContractAddress(ACCOUNT_TOKEN_HASH));
        uint256 numberOfTokens = accountTokens.balanceOf(wallet);

        for (uint256 x = 0; x < numberOfTokens; x++) {
            totalTokens += stakedTokens(accountTokens.tokenOfOwnerByIndex(wallet, x));
        }

        return totalTokens;
    }

    function getLostTokens(address tokenAddress) public override onlyTreasury {

        IERC20 token = IERC20(tokenAddress);
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }

    function destroyContract(address payable to) public override onlyTreasury {
        selfdestruct(to);
    }
}