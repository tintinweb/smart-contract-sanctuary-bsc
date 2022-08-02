// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";

import "../interfaces/gov/IGovPool.sol";

import "./GovUserKeeperController.sol";

contract GovPool is
    IGovPool,
    GovUserKeeperController,
    ERC721HolderUpgradeable,
    ERC1155HolderUpgradeable
{
    string public descriptionURL;

    function __GovPool_init(
        address govSettingAddress,
        address govUserKeeperAddress,
        address validatorsAddress,
        uint256 _votesLimit,
        uint256 _feePercentage,
        string calldata _descriptionURL
    ) external initializer {
        __GovCreator_init(govSettingAddress, govUserKeeperAddress);
        __GovVote_init(validatorsAddress, _votesLimit);
        __GovFee_init(_feePercentage);
        __ERC721Holder_init();
        __ERC1155Holder_init();

        descriptionURL = _descriptionURL;
    }

    function execute(uint256 proposalId) external override {
        Proposal storage proposal = proposals[proposalId];

        require(
            _getProposalState(proposal.core) == ProposalState.Succeeded,
            "Gov: invalid proposal status"
        );

        proposal.core.executed = true;

        address[] memory executors = proposal.executors;
        uint256[] memory values = proposal.values;
        bytes[] memory data = proposal.data;

        for (uint256 i; i < data.length; i++) {
            (bool status, bytes memory returnedData) = executors[i].call{value: values[i]}(
                data[i]
            );

            if (!status) {
                revert(_getRevertMsg(returnedData));
            }
        }
    }

    receive() external payable {}

    function _getRevertMsg(bytes memory data) internal pure returns (string memory) {
        if (data.length < 68) {
            return "Transaction reverted silently";
        }

        assembly {
            data := add(data, 0x04)
        }

        return abi.decode(data, (string));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {
    function __ERC721Holder_init() internal onlyInitializing {
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {
    function __ERC1155Holder_init() internal onlyInitializing {
    }

    function __ERC1155Holder_init_unchained() internal onlyInitializing {
    }
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the Governance pool contract. This contract is the third contract the user can deploy through
 * the factory. The users can participate in proposal's creation, voting and execution processes
 */
interface IGovPool {
    /// @notice Execute proposal
    /// @param proposalId Proposal ID
    function execute(uint256 proposalId) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/gov/IGovUserKeeperController.sol";

import "@dlsl/dev-modules/libs/arrays/ArrayHelper.sol";

import "./GovFee.sol";

abstract contract GovUserKeeperController is IGovUserKeeperController, GovFee {
    using Math for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using ShrinkableArray for uint256[];
    using ShrinkableArray for ShrinkableArray.UintArray;
    using ArrayHelper for uint256[];
    using GovUserKeeperLocal for *;

    function deposit(
        address receiver,
        uint256 amount,
        uint256[] calldata nftIds
    ) public override {
        require(amount > 0 || nftIds.length > 0, "GovUKC: empty deposit");

        govUserKeeper.depositTokens.exec(receiver, amount);
        govUserKeeper.depositNfts.exec(receiver, nftIds);
    }

    function withdraw(
        address receiver,
        uint256 amount,
        uint256[] calldata nftIds
    ) external override {
        require(amount > 0 || nftIds.length > 0, "GovUKC: empty withdrawal");

        unlock(msg.sender, false);

        govUserKeeper.withdrawTokens.exec(receiver, amount);
        govUserKeeper.withdrawNfts.exec(receiver, nftIds);
    }

    function delegate(
        address delegatee,
        uint256 amount,
        uint256[] calldata nftIds
    ) external override {
        require(amount > 0 || nftIds.length > 0, "GovUKC: empty delegation");

        unlock(msg.sender, false);

        govUserKeeper.delegateTokens.exec(delegatee, amount);
        govUserKeeper.delegateNfts.exec(delegatee, nftIds);
    }

    function undelegate(
        address delegatee,
        uint256 amount,
        uint256[] calldata nftIds
    ) external override {
        require(amount > 0 || nftIds.length > 0, "GovUKC: empty undelegation");

        unlock(delegatee, true);

        govUserKeeper.undelegateTokens.exec(delegatee, amount);
        govUserKeeper.undelegateNfts.exec(delegatee, nftIds);
    }

    function getWithdrawableAssets(address user)
        external
        view
        override
        returns (uint256 withdrawableTokens, ShrinkableArray.UintArray memory withdrawableNfts)
    {
        (
            ShrinkableArray.UintArray memory unlockedIds,
            ShrinkableArray.UintArray memory lockedIds
        ) = getProposals(user, false);
        uint256[] memory unlockedNfts = getUnlockedNfts(unlockedIds, user, false);

        return govUserKeeper.getWithdrawableAssets(user, lockedIds, unlockedNfts);
    }

    function getUndelegateableAssets(address delegator, address delegatee)
        external
        view
        override
        returns (uint256 undelegateableTokens, ShrinkableArray.UintArray memory undelegateableNfts)
    {
        (
            ShrinkableArray.UintArray memory unlockedIds,
            ShrinkableArray.UintArray memory lockedIds
        ) = getProposals(delegatee, true);
        uint256[] memory unlockedNfts = getUnlockedNfts(unlockedIds, delegatee, true);

        return
            govUserKeeper.getUndelegateableAssets(delegator, delegatee, lockedIds, unlockedNfts);
    }

    function getProposals(address user, bool isMicropool)
        public
        view
        returns (
            ShrinkableArray.UintArray memory unlockedIds,
            ShrinkableArray.UintArray memory lockedIds
        )
    {
        uint256 proposalsLength = _votedInProposals[user][isMicropool].length();

        uint256[] memory unlockedProposals = new uint256[](proposalsLength);
        uint256[] memory lockedProposals = new uint256[](proposalsLength);
        uint256 unlockedLength;
        uint256 lockedLength;

        for (uint256 i; i < proposalsLength; i++) {
            uint256 proposalId = _votedInProposals[user][isMicropool].at(i);

            ProposalState state = _getProposalState(proposals[proposalId].core);

            if (
                state == ProposalState.Executed ||
                state == ProposalState.Succeeded ||
                state == ProposalState.Defeated
            ) {
                unlockedProposals[unlockedLength++] = proposalId;
            } else {
                lockedProposals[lockedLength++] = proposalId;
            }
        }

        unlockedIds = unlockedProposals.transform().crop(unlockedLength);
        lockedIds = lockedProposals.transform().crop(lockedLength);
    }

    function getUnlockedNfts(
        ShrinkableArray.UintArray memory unlockedIds,
        address user,
        bool isMicropool
    ) public view returns (uint256[] memory unlockedNfts) {
        uint256 totalLength;

        for (uint256 i; i < unlockedIds.length; i++) {
            totalLength += _voteInfos[unlockedIds.values[i]][user][isMicropool].nftsVoted.length();
        }

        unlockedNfts = new uint256[](totalLength);
        totalLength = 0;

        for (uint256 i; i < unlockedIds.length; i++) {
            VoteInfo storage voteInfo = _voteInfos[unlockedIds.values[i]][user][isMicropool];

            totalLength = unlockedNfts.insert(totalLength, voteInfo.nftsVoted.values());
        }
    }

    function unlock(address user, bool isMicropool) public override {
        unlockInProposals(_votedInProposals[user][isMicropool].values(), user, isMicropool);
    }

    function unlockInProposals(
        uint256[] memory proposalIds,
        address user,
        bool isMicropool
    ) public override {
        IGovUserKeeper userKeeper = govUserKeeper;

        uint256 maxLockedAmount = userKeeper.maxLockedAmount(user, isMicropool);
        uint256 maxUnlocked;

        for (uint256 i; i < proposalIds.length; i++) {
            require(
                _votedInProposals[user][isMicropool].contains(proposalIds[i]),
                "GovUKC: hasn't voted for this proposal"
            );

            ProposalState state = _getProposalState(proposals[proposalIds[i]].core);

            if (
                state != ProposalState.Executed &&
                state != ProposalState.Succeeded &&
                state != ProposalState.Defeated
            ) {
                continue;
            }

            maxUnlocked = userKeeper.unlockTokens(proposalIds[i], user, isMicropool).max(
                maxUnlocked
            );
            userKeeper.unlockNfts(
                _voteInfos[proposalIds[i]][user][isMicropool].nftsVoted.values()
            );

            _votedInProposals[user][isMicropool].remove(proposalIds[i]);
        }

        if (maxLockedAmount <= maxUnlocked) {
            userKeeper.updateMaxTokenLockedAmount(
                _votedInProposals[user][isMicropool].values(),
                user,
                isMicropool
            );
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155ReceiverUpgradeable.sol";
import "../../../utils/introspection/ERC165Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal onlyInitializing {
    }

    function __ERC1155Receiver_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../libs/data-structures/ShrinkableArray.sol";

interface IGovUserKeeperController {
    function deposit(
        address receiver,
        uint256 amount,
        uint256[] calldata nftIds
    ) external;

    function getWithdrawableAssets(address user)
        external
        view
        returns (uint256 withdrawableTokens, ShrinkableArray.UintArray memory withdrawableNfts);

    function withdraw(
        address receiver,
        uint256 amount,
        uint256[] calldata nftIds
    ) external;

    function delegate(
        address delegatee,
        uint256 amount,
        uint256[] calldata nftIds
    ) external;

    function getUndelegateableAssets(address delegator, address delegatee)
        external
        view
        returns (uint256 withdrawableTokens, ShrinkableArray.UintArray memory withdrawableNfts);

    function undelegate(
        address delegatee,
        uint256 amount,
        uint256[] calldata nftIds
    ) external;

    function unlock(address user, bool isMicropool) external;

    function unlockInProposals(
        uint256[] memory proposalIds,
        address user,
        bool isMicropool
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 *  @notice A simple library to reverse common arrays
 */
library ArrayHelper {
    function reverse(uint256[] memory arr) internal pure returns (uint256[] memory reversed) {
        reversed = new uint256[](arr.length);
        uint256 i = arr.length;

        while (i > 0) {
            i--;
            reversed[arr.length - 1 - i] = arr[i];
        }
    }

    function reverse(address[] memory arr) internal pure returns (address[] memory reversed) {
        reversed = new address[](arr.length);
        uint256 i = arr.length;

        while (i > 0) {
            i--;
            reversed[arr.length - 1 - i] = arr[i];
        }
    }

    function insert(
        uint256[] memory to,
        uint256 index,
        uint256[] memory what
    ) internal pure returns (uint256) {
        for (uint256 i = 0; i < what.length; i++) {
            to[index + i] = what[i];
        }

        return index + what.length;
    }

    function insert(
        address[] memory to,
        uint256 index,
        address[] memory what
    ) internal pure returns (uint256) {
        for (uint256 i = 0; i < what.length; i++) {
            to[index + i] = what[i];
        }

        return index + what.length;
    }

    function asArray(uint256 elem) internal pure returns (uint256[] memory array) {
        array = new uint256[](1);
        array[0] = elem;
    }

    function asArray(address elem) internal pure returns (address[] memory array) {
        array = new address[](1);
        array[0] = elem;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../interfaces/gov/IGovFee.sol";

import "./GovVote.sol";

abstract contract GovFee is IGovFee, OwnableUpgradeable, GovVote {
    using SafeERC20 for IERC20;
    using Math for uint256;
    using Math for uint64;
    using MathHelper for uint256;

    uint64 private _deployedAt;

    uint256 public feePercentage;

    /// @dev zero address - native token
    mapping(address => uint64) public lastUpdate; // token address => last update

    function __GovFee_init(uint256 _feePercentage) internal {
        __Ownable_init();

        require(
            _feePercentage <= PERCENTAGE_100,
            "GovFee: `_feePercentage` can't be more than 100%"
        );

        _deployedAt = uint64(block.timestamp);
        feePercentage = _feePercentage;
    }

    function withdrawFee(address tokenAddress, address recipient) external override onlyOwner {
        uint64 _lastUpdate = uint64(lastUpdate[tokenAddress].max(_deployedAt));

        lastUpdate[tokenAddress] = uint64(block.timestamp);

        uint256 balance;
        uint256 toWithdraw;

        if (tokenAddress != address(0)) {
            balance = IERC20(tokenAddress).balanceOf(address(this));
        } else {
            balance = address(this).balance;
        }

        uint256 fee = feePercentage.ratio(block.timestamp - _lastUpdate, 1 days * 365);
        toWithdraw = balance.min(balance.percentage(fee));

        require(toWithdraw > 0, "GFee: nothing to withdraw");

        if (tokenAddress != address(0)) {
            IERC20(tokenAddress).safeTransfer(recipient, toWithdraw);
        } else {
            payable(recipient).transfer(toWithdraw);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library ShrinkableArray {
    struct UintArray {
        uint256[] values;
        uint256 length;
    }

    /**
     * @dev Create `ShrinkableArray` from `uint256[]`, save original array and length
     */
    function transform(uint256[] memory arr) internal pure returns (UintArray memory) {
        return UintArray(arr, arr.length);
    }

    /**
     * @dev Create blank `ShrinkableArray` - empty array with original length
     */
    function create(uint256 length) internal pure returns (UintArray memory) {
        return UintArray(new uint256[](length), length);
    }

    /**
     * @dev Change array length
     */
    function crop(UintArray memory arr, uint256 newLength)
        internal
        pure
        returns (UintArray memory)
    {
        arr.length = newLength;

        return arr;
    }
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This contract is responsible for the owner's fee collection (part of the pool)
 */
interface IGovFee {
    /// @notice Withdraw fee
    /// @param tokenAddress ERC20 token address or zero address for native withdraw
    /// @param recipient Tokens recipient
    function withdrawFee(address tokenAddress, address recipient) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/gov/IGovVote.sol";
import "../interfaces/gov/validators/IGovValidators.sol";

import "../libs/GovUserKeeper/GovUserKeeperLocal.sol";
import "../libs/math/MathHelper.sol";

import "./GovCreator.sol";

import "../core/Globals.sol";

abstract contract GovVote is IGovVote, GovCreator {
    using Math for uint256;
    using MathHelper for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using GovUserKeeperLocal for *;

    /// @dev `Validators` contract address
    IGovValidators public validators;

    uint256 public votesLimit;

    mapping(uint256 => uint256) private _totalVotedInProposal; // proposalId => total voted
    mapping(uint256 => mapping(address => mapping(bool => VoteInfo))) internal _voteInfos; // proposalId => voter => isMicropool => info

    mapping(address => mapping(bool => EnumerableSet.UintSet)) internal _votedInProposals; // voter => isMicropool => active proposal ids

    function __GovVote_init(address validatorsAddress, uint256 _votesLimit) internal {
        require(_votesLimit > 0);

        validators = IGovValidators(validatorsAddress);
        votesLimit = _votesLimit;
    }

    function vote(
        uint256 proposalId,
        uint256 depositAmount,
        uint256[] calldata depositNftIds,
        uint256 voteAmount,
        uint256[] calldata voteNftIds
    ) external override {
        require(voteAmount > 0 || voteNftIds.length > 0, "GovV: empty vote");

        govUserKeeper.depositTokens.exec(msg.sender, depositAmount);
        govUserKeeper.depositNfts.exec(msg.sender, depositNftIds);

        bool useDelegated = !proposals[proposalId].core.settings.delegatedVotingAllowed;
        ProposalCore storage core = _beforeVote(proposalId, false, useDelegated);

        _voteTokens(core, proposalId, voteAmount, false, useDelegated);
        _voteNfts(core, proposalId, voteNftIds, false, useDelegated);
    }

    function voteDelegated(
        uint256 proposalId,
        uint256 voteAmount,
        uint256[] calldata voteNftIds
    ) external override {
        require(voteAmount > 0 || voteNftIds.length > 0, "GovV: empty delegated vote");
        require(
            proposals[proposalId].core.settings.delegatedVotingAllowed,
            "GovV: delegated voting unavailable"
        );

        ProposalCore storage core = _beforeVote(proposalId, true, false);

        _voteTokens(core, proposalId, voteAmount, true, false);
        _voteNfts(core, proposalId, voteNftIds, true, false);
    }

    function _voteTokens(
        ProposalCore storage core,
        uint256 proposalId,
        uint256 amount,
        bool isMicropool,
        bool useDelegated
    ) private {
        VoteInfo storage voteInfo = _voteInfos[proposalId][msg.sender][isMicropool];

        IGovUserKeeper userKeeper = govUserKeeper;

        userKeeper.lockTokens(proposalId, msg.sender, isMicropool, amount);
        uint256 tokenBalance = userKeeper.tokenBalance(msg.sender, isMicropool, useDelegated);

        require(amount <= tokenBalance - voteInfo.tokensVoted, "GovV: wrong vote amount");

        voteInfo.totalVoted += amount;
        voteInfo.tokensVoted += amount;

        _totalVotedInProposal[proposalId] += amount;

        core.votesFor += amount;
    }

    function _voteNfts(
        ProposalCore storage core,
        uint256 proposalId,
        uint256[] calldata nftIds,
        bool isMicropool,
        bool useDelegated
    ) private {
        VoteInfo storage voteInfo = _voteInfos[proposalId][msg.sender][isMicropool];

        for (uint256 i; i < nftIds.length; i++) {
            require(i == 0 || nftIds[i] > nftIds[i - 1], "GovV: wrong NFT order");
            require(!voteInfo.nftsVoted.contains(nftIds[i]), "GovV: NFT already voted");
        }

        IGovUserKeeper userKeeper = govUserKeeper;

        userKeeper.lockNfts(msg.sender, isMicropool, useDelegated, nftIds);
        uint256 voteAmount = userKeeper.getNftsPowerInTokens(nftIds, core.nftPowerSnapshotId);

        for (uint256 i; i < nftIds.length; i++) {
            voteInfo.nftsVoted.add(nftIds[i]);
        }

        voteInfo.totalVoted += voteAmount;

        _totalVotedInProposal[proposalId] += voteAmount;

        core.votesFor += voteAmount;
    }

    function _beforeVote(
        uint256 proposalId,
        bool isMicropool,
        bool useDelegated
    ) private returns (ProposalCore storage) {
        ProposalCore storage core = proposals[proposalId].core;

        _votedInProposals[msg.sender][isMicropool].add(proposalId);

        require(
            _votedInProposals[msg.sender][isMicropool].length() <= votesLimit,
            "GovV: vote limit reached"
        );
        require(_getProposalState(core) == ProposalState.Voting, "GovV: vote unavailable");
        require(
            govUserKeeper.canParticipate(
                msg.sender,
                isMicropool,
                useDelegated,
                core.settings.minTokenBalance,
                core.settings.minNftBalance
            ),
            "GovV: low balance"
        );

        return core;
    }

    function moveProposalToValidators(uint256 proposalId) external override {
        ProposalCore storage core = proposals[proposalId].core;
        ProposalState state = _getProposalState(core);

        require(state == ProposalState.WaitingForVotingTransfer, "GovV: can't be moved");

        validators.createExternalProposal(
            proposalId,
            core.settings.durationValidators,
            core.settings.quorumValidators
        );
    }

    function getTotalVotes(
        uint256 proposalId,
        address voter,
        bool isMicropool
    ) external view override returns (uint256, uint256) {
        return (
            _totalVotedInProposal[proposalId],
            _voteInfos[proposalId][voter][isMicropool].totalVoted
        );
    }

    function getProposalState(uint256 proposalId) external view override returns (ProposalState) {
        return _getProposalState(proposals[proposalId].core);
    }

    function _getProposalState(ProposalCore storage core) internal view returns (ProposalState) {
        uint64 voteEnd = core.voteEnd;

        if (voteEnd == 0) {
            return ProposalState.Undefined;
        }

        if (core.executed) {
            return ProposalState.Executed;
        }

        if (core.settings.earlyCompletion || voteEnd < block.timestamp) {
            if (_quorumReached(core)) {
                if (address(validators) != address(0)) {
                    IGovValidators.ProposalState status = validators.getProposalState(
                        core.proposalId,
                        false
                    );

                    if (status == IGovValidators.ProposalState.Undefined) {
                        return ProposalState.WaitingForVotingTransfer;
                    }

                    if (status == IGovValidators.ProposalState.Voting) {
                        return ProposalState.ValidatorVoting;
                    }

                    if (status == IGovValidators.ProposalState.Succeeded) {
                        return ProposalState.Succeeded;
                    }

                    if (status == IGovValidators.ProposalState.Defeated) {
                        return ProposalState.Defeated;
                    }
                } else {
                    return ProposalState.Succeeded;
                }
            }

            if (voteEnd < block.timestamp) {
                return ProposalState.Defeated;
            }
        }

        return ProposalState.Voting;
    }

    function _quorumReached(ProposalCore storage core) private view returns (bool) {
        uint256 totalVoteWeight = govUserKeeper.getTotalVoteWeight();

        return
            totalVoteWeight == 0
                ? false
                : PERCENTAGE_100.ratio(core.votesFor, totalVoteWeight) >= core.settings.quorum;
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * This is the contract that is responsible for the first stage governance voting process (part of the pool)
 */
interface IGovVote {
    enum ProposalState {
        Voting,
        WaitingForVotingTransfer,
        ValidatorVoting,
        Defeated,
        Succeeded,
        Executed,
        Undefined
    }

    struct VoteInfo {
        uint256 totalVoted;
        uint256 tokensVoted;
        EnumerableSet.UintSet nftsVoted;
    }

    function vote(
        uint256 proposalId,
        uint256 depositAmount,
        uint256[] calldata depositNftIds,
        uint256 voteAmount,
        uint256[] calldata voteNftIds
    ) external;

    function voteDelegated(
        uint256 proposalId,
        uint256 voteAmount,
        uint256[] calldata voteNftIds
    ) external;

    /// @notice Move proposal from internal voting to `Validators` contract
    /// @param proposalId Proposal ID
    function moveProposalToValidators(uint256 proposalId) external;

    function getTotalVotes(
        uint256 proposalId,
        address voter,
        bool isMicropool
    ) external view returns (uint256, uint256);

    /// @param proposalId Proposal ID
    /// @return `ProposalState`:
    /// 0 -`Voting`, proposal where addresses can vote
    /// 1 -`WaitingForVotingTransfer`, approved proposal that waiting `moveProposalToValidators()` call
    /// 2 -`ValidatorVoting`, validators voting
    /// 3 -`Defeated`, proposal where voting time is over and proposal defeated on first or second step
    /// 4 -`Succeeded`, proposal with the required number of votes on each step
    /// 5 -`Executed`, executed proposal
    /// 6 -`Undefined`, nonexistent proposal
    function getProposalState(uint256 proposalId) external view returns (ProposalState);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the voting contract that is queried on the proposal's second voting stage
 */
interface IGovValidators {
    enum ProposalState {
        Voting,
        Defeated,
        Succeeded,
        Executed,
        Undefined
    }

    enum ProposalType {
        ChangeInternalDuration,
        ChangeInternalQuorum,
        ChangeInternalDurationAndQuorum,
        ChangeBalances
    }

    struct InternalProposalSettings {
        uint64 duration;
        uint128 quorum;
    }

    struct ProposalCore {
        bool executed;
        uint64 voteEnd;
        uint128 quorum;
        uint256 votesFor;
        uint256 snapshotId;
    }

    struct InternalProposal {
        ProposalType proposalType;
        ProposalCore core;
        uint256[] newValues;
        address[] userAddresses;
    }

    struct ExternalProposal {
        ProposalCore core;
    }

    /// @notice Create internal proposal for changing validators balances, base quorum, base duration
    /// @param proposalType `ProposalType`
    /// 0 - `ChangeInternalDuration`, change base duration
    /// 1 - `ChangeInternalQuorum`, change base quorum
    /// 2 - `ChangeInternalDurationAndQuorum`, change base duration and quorum
    /// 3 - `ChangeBalances`, change address balance
    /// @param newValues New values (tokens amounts array, quorum or duration or both)
    /// @param userAddresses Validators addresses, set it if `proposalType` == `ChangeBalances`
    function createInternalProposal(
        ProposalType proposalType,
        uint256[] calldata newValues,
        address[] calldata userAddresses
    ) external;

    /// @notice Create external proposal. This function can call only `Gov` contract
    /// @param proposalId Proposal ID from `Gov` contract
    /// @param duration Duration from `Gov` contract
    /// @param quorum Quorum from `Gov` contract
    function createExternalProposal(
        uint256 proposalId,
        uint64 duration,
        uint128 quorum
    ) external;

    /// @notice Vote in proposal
    /// @param proposalId Proposal ID, internal or external
    /// @param amount Amount of tokens to vote
    /// @param isInternal If `true`, you will vote in internal proposal
    function vote(
        uint256 proposalId,
        uint256 amount,
        bool isInternal
    ) external;

    /// @notice Only for internal proposals. External proposals should be executed from governance.
    /// @param proposalId Internal proposal ID
    function execute(uint256 proposalId) external;

    /// @notice Return proposal state
    /// @dev Options:
    /// `Voting` - proposal where addresses can vote.
    /// `Defeated` - proposal where voting time is over and proposal defeated.
    /// `Succeeded` - proposal with the required number of votes.
    /// `Executed` - executed proposal (only for internal proposal).
    /// `Undefined` - nonexistent proposal.
    function getProposalState(uint256 proposalId, bool isInternal)
        external
        view
        returns (ProposalState);

    /// @param proposalId Proposal ID
    /// @param isInternal If `true`, check internal proposal
    /// @return `true` if quorum reached. Return `false` if not or proposal isn't exist.
    function isQuorumReached(uint256 proposalId, bool isInternal) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library GovUserKeeperLocal {
    function exec(
        function(address, address, uint256) external tokenFunc,
        address user,
        uint256 amount
    ) internal {
        if (amount == 0) {
            return;
        }

        tokenFunc(msg.sender, user, amount);
    }

    function exec(
        function(address, address, uint256[] memory) external nftFunc,
        address user,
        uint256[] calldata nftIds
    ) internal {
        if (nftIds.length == 0) {
            return;
        }

        nftFunc(msg.sender, user, nftIds);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../core/Globals.sol";

library MathHelper {
    /// @notice percent has to be multiplied by PRECISION
    function percentage(uint256 num, uint256 percent) internal pure returns (uint256) {
        return (num * percent) / PERCENTAGE_100;
    }

    function ratio(
        uint256 base,
        uint256 num,
        uint256 denom
    ) internal pure returns (uint256) {
        return (base * num) / denom;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "../interfaces/gov/IGovCreator.sol";
import "../interfaces/gov/settings/IGovSettings.sol";
import "../interfaces/gov/user-keeper/IGovUserKeeper.sol";

abstract contract GovCreator is IGovCreator {
    IGovSettings public govSetting;
    IGovUserKeeper public govUserKeeper;

    uint256 private _latestProposalId;

    mapping(uint256 => Proposal) public proposals; // proposalId => info

    function __GovCreator_init(address govSettingAddress, address govUserKeeperAddress) internal {
        require(govSettingAddress != address(0), "GovC: address is zero (1)");
        require(govUserKeeperAddress != address(0), "GovC: address is zero (2)");

        govSetting = IGovSettings(govSettingAddress);
        govUserKeeper = IGovUserKeeper(govUserKeeperAddress);
    }

    function createProposal(
        string calldata descriptionURL,
        address[] memory executors,
        uint256[] calldata values,
        bytes[] calldata data
    ) external override {
        require(
            executors.length > 0 &&
                executors.length == values.length &&
                executors.length == data.length,
            "GovC: invalid array length"
        );

        uint256 proposalId = ++_latestProposalId;

        address mainExecutor = executors[executors.length - 1];
        (, bool isInternal, bool trustedExecutor) = govSetting.executorInfo(mainExecutor);

        bool forceDefaultSettings;
        IGovSettings.ProposalSettings memory settings;

        if (isInternal) {
            executors = _handleExecutorsAndDataForInternalProposal(executors, values, data);
        } else if (trustedExecutor) {
            forceDefaultSettings = _handleDataForExistingSettingsProposal(values, data);
        }

        if (forceDefaultSettings) {
            settings = govSetting.getDefaultSettings();
        } else {
            settings = govSetting.getSettings(mainExecutor);
        }

        require(
            govUserKeeper.canParticipate(
                msg.sender,
                false,
                !settings.delegatedVotingAllowed,
                1,
                1
            ),
            "GovC: low balance"
        );

        proposals[proposalId] = Proposal({
            core: ProposalCore({
                settings: settings,
                executed: false,
                voteEnd: uint64(block.timestamp + settings.duration),
                votesFor: 0,
                nftPowerSnapshotId: govUserKeeper.createNftPowerSnapshot(),
                proposalId: proposalId
            }),
            descriptionURL: descriptionURL,
            executors: executors,
            values: values,
            data: data
        });
    }

    function getProposalInfo(uint256 proposalId)
        external
        view
        override
        returns (address[] memory, bytes[] memory)
    {
        return (proposals[proposalId].executors, proposals[proposalId].data);
    }

    function _handleExecutorsAndDataForInternalProposal(
        address[] memory executors,
        uint256[] calldata values,
        bytes[] calldata data
    ) private pure returns (address[] memory) {
        address mainExecutor = executors[executors.length - 1];

        for (uint256 i; i < data.length; i++) {
            bytes4 selector = _getSelector(data[i]);
            require(
                values[i] == 0 &&
                    (selector == IGovSettings.addSettings.selector ||
                        selector == IGovSettings.editSettings.selector ||
                        selector == IGovSettings.changeExecutors.selector),
                "GovC: invalid internal data"
            );

            executors[i] = mainExecutor;
        }

        return executors;
    }

    function _handleDataForExistingSettingsProposal(
        uint256[] calldata values,
        bytes[] calldata data
    ) private pure returns (bool) {
        for (uint256 i; i < data.length - 1; i++) {
            bytes4 selector = _getSelector(data[i]);

            if (
                values[i] != 0 ||
                (selector != IERC20.approve.selector &&
                    selector != IERC721.approve.selector &&
                    selector != IERC721.setApprovalForAll.selector &&
                    selector != IERC1155.setApprovalForAll.selector)
            ) {
                return true; // should use default settings
            }
        }

        return false;
    }

    function _getSelector(bytes calldata data) private pure returns (bytes4 selector) {
        assembly {
            selector := calldataload(data.offset)
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

uint256 constant PERCENTAGE_100 = 10**27;
uint256 constant PRECISION = 10**25;
uint256 constant DECIMALS = 10**18;

uint256 constant MAX_UINT = type(uint256).max;

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./settings/IGovSettings.sol";

/**
 * This contract is responsible for the creation of new proposals (part of the pool)
 */
interface IGovCreator {
    struct ProposalCore {
        IGovSettings.ProposalSettings settings;
        bool executed;
        uint64 voteEnd;
        uint256 votesFor;
        uint256 nftPowerSnapshotId;
        uint256 proposalId;
    }

    struct Proposal {
        ProposalCore core;
        string descriptionURL;
        address[] executors;
        uint256[] values;
        bytes[] data;
    }

    /// @notice Create proposal
    /// @notice For internal proposal, last executor should be `GovSetting` contract
    /// @notice For typed proposal, last executor should be typed contract
    /// @notice For external proposal, any configuration of addresses and bytes
    /// @param descriptionURL IPFS url to the proposal's description
    /// @param executors Executors addresses
    /// @param values the ether values
    /// @param data data Bytes
    function createProposal(
        string calldata descriptionURL,
        address[] memory executors,
        uint256[] calldata values,
        bytes[] calldata data
    ) external;

    /// @param proposalId Proposal ID
    /// @return Executor addresses
    /// @return Data for each address
    function getProposalInfo(uint256 proposalId)
        external
        view
        returns (address[] memory, bytes[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the contract that stores proposal settings that will be used by the governance pool
 */
interface IGovSettings {
    struct ProposalSettings {
        bool earlyCompletion;
        bool delegatedVotingAllowed;
        uint64 duration;
        uint64 durationValidators;
        uint128 quorum;
        uint128 quorumValidators;
        uint256 minTokenBalance;
        uint256 minNftBalance;
    }

    /// @notice Add new types to contract
    /// @param _settings New settings
    function addSettings(ProposalSettings[] calldata _settings) external;

    /// @notice Edit existed type
    /// @param settingsIds Existed settings IDs
    /// @param _settings New settings
    function editSettings(uint256[] calldata settingsIds, ProposalSettings[] calldata _settings)
        external;

    /// @notice Change executors association
    /// @param executors Addresses
    /// @param settingsIds New types
    function changeExecutors(address[] calldata executors, uint256[] calldata settingsIds)
        external;

    /// @notice The function the get executor's info
    /// @param executor Executor address
    /// @return settings ID for `executor`
    /// @return `true` if `executor` is current address
    /// @return `true` if `executor` has valid `ProposalSettings`
    function executorInfo(address executor)
        external
        view
        returns (
            uint256,
            bool,
            bool
        );

    /// @notice The function to get default settings
    /// @return default setting
    function getDefaultSettings() external view returns (ProposalSettings memory);

    /// @notice The function the get the settings of the executor
    /// @param executor Executor address
    /// @return `ProposalSettings` by `executor` address
    function getSettings(address executor) external view returns (ProposalSettings memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../../../libs/data-structures/ShrinkableArray.sol";

/**
 * This contract is responsible for securely storing user's funds that are used during the voting. This are either
 * ERC20 tokens or NFTs
 */
interface IGovUserKeeper {
    struct BalanceInfo {
        uint256 tokenBalance;
        uint256 maxTokensLocked;
        mapping(uint256 => uint256) lockedInProposals; // proposal id => locked amount
        EnumerableSet.UintSet nftBalance; // array of NFTs
    }

    struct UserInfo {
        BalanceInfo balanceInfo;
        mapping(address => uint256) delegatedTokens; // delegatee => amount
        mapping(address => EnumerableSet.UintSet) delegatedNfts; // delegatee => tokenIds
        EnumerableSet.AddressSet delegatees;
    }

    struct NFTInfo {
        bool isSupportPower;
        bool isSupportTotalSupply;
        uint256 totalPowerInTokens;
        uint256 totalSupply;
    }

    struct NFTSnapshot {
        uint256 totalSupply;
        uint256 totalNftsPower;
        mapping(uint256 => uint256) nftPower;
    }

    function depositTokens(
        address payer,
        address receiver,
        uint256 amount
    ) external;

    function withdrawTokens(
        address payer,
        address receiver,
        uint256 amount
    ) external;

    function delegateTokens(
        address delegator,
        address delegatee,
        uint256 amount
    ) external;

    function undelegateTokens(
        address delegator,
        address delegatee,
        uint256 amount
    ) external;

    function depositNfts(
        address payer,
        address receiver,
        uint256[] calldata nftIds
    ) external;

    function withdrawNfts(
        address payer,
        address receiver,
        uint256[] calldata nftIds
    ) external;

    function delegateNfts(
        address delegator,
        address delegatee,
        uint256[] calldata nftIds
    ) external;

    function undelegateNfts(
        address delegator,
        address delegatee,
        uint256[] calldata nftIds
    ) external;

    function maxLockedAmount(address voter, bool isMicropool) external view returns (uint256);

    function tokenBalance(
        address voter,
        bool isMicropool,
        bool useDelegated
    ) external view returns (uint256 balance);

    function nftBalance(
        address voter,
        bool isMicropool,
        bool useDelegated
    ) external view returns (uint256 balance);

    function nftExactBalance(
        address voter,
        bool isMicropool,
        bool useDelegated
    ) external view returns (uint256[] memory nfts);

    function canParticipate(
        address voter,
        bool isMicropool,
        bool useDelegated,
        uint256 requiredTokens,
        uint256 requiredNfts
    ) external view returns (bool);

    function getTotalVoteWeight() external view returns (uint256);

    function getNftsPowerInTokens(uint256[] calldata nftIds, uint256 snapshotId)
        external
        view
        returns (uint256);

    function createNftPowerSnapshot() external returns (uint256);

    function getUndelegateableAssets(
        address delegator,
        address delegatee,
        ShrinkableArray.UintArray calldata lockedProposals,
        uint256[] calldata unlockedNfts
    )
        external
        view
        returns (
            uint256 undelegateableTokens,
            ShrinkableArray.UintArray memory undelegateableNfts
        );

    function getWithdrawableAssets(
        address voter,
        ShrinkableArray.UintArray calldata lockedProposals,
        uint256[] calldata unlockedNfts
    )
        external
        view
        returns (uint256 withdrawableTokens, ShrinkableArray.UintArray memory withdrawableNfts);

    function updateMaxTokenLockedAmount(
        uint256[] calldata lockedProposals,
        address voter,
        bool isMicropool
    ) external;

    function lockTokens(
        uint256 proposalId,
        address voter,
        bool isMicropool,
        uint256 amount
    ) external;

    function unlockTokens(
        uint256 proposalId,
        address voter,
        bool isMicropool
    ) external returns (uint256 unlockedAmount);

    function lockNfts(
        address voter,
        bool isMicropool,
        bool useDelegated,
        uint256[] calldata nftIds
    ) external;

    function unlockNfts(uint256[] calldata nftIds) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}