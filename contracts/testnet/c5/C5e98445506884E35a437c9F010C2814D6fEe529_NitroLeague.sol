// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.15 <0.9.0;

// Interfaces.
import "../interfaces/INitroLeague.sol";
import "../interfaces/IRaceEventFactory.sol";
import "../interfaces/IRaceEvent.sol";
import "../interfaces/IRaceFactory.sol";

// Utils.
import "../utils/TokenWithdrawer.sol";

// OpenZeppelin.
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Nitro League contract to create and manage RaceEvents.
/// @dev NitroLeague generates RaceEvent's (1 to many).
/// @dev    Each RaceEvent generates Race's (1 to many).
/// @dev    When RaceEvent is updated, a new NitroLeague should be deployed.
/// @dev    The current NitroLeague's state can be migrated using sendNitroLeague().
/// @author Nitro League.
contract NitroLeague is INitroLeague, Context, Ownable, TokenWithdrawer {
    ////////////
    // ACCESS //
    ////////////
    // See Ownable.

    /// Generates RaceEvent's.
    IRaceEventFactory public raceEventFactory;
    /// Generates Race's.
    IRaceFactory public raceFactory;

    // To generate reward managers
    address public rewardFactory;

    /// Authorized to end race and set results.
    address private _game;

    /////////////////
    // RACE EVENTS //
    /////////////////

    /// Unique ID's of all RaceEvents.
    string[] public raceEventIDsList;
    /// RaceEvent ID is true if it exists.
    mapping(string => bool) public raceEventIDs;
    /// RaceEvent ID and its RaceEvent.
    mapping(string => IRaceEvent) public raceEvents;
    /// Emitted by createRaceEvent().
    event CreateRaceEvent(
        string indexed raceEventID,
        address indexed raceEvent
    );

    ///////////
    // RACES //
    ///////////

    /// Unique ID's of all Races.
    string[] public raceIDsList;
    /// Race ID is true if it exists.
    mapping(string => bool) public raceIDs;
    /// Receiver of Race fees.
    address private _treasuryWallet;

    /////////////////
    // CONSTRUCTOR //
    /////////////////

    /** Create a new NitroLeague.
     * @param config_addrs addresses at the following
     * 0 as address of the game engine account.
     * 1 as address of the _treasuryWallet account.
     * 2 raceEventFactory_ as address of RaceEventFactory.
     * 3 raceFactory_ as address of RaceFactory.
     * 4 rewardFactory_ as address of rewardFactory.
     */
    constructor(address[5] memory config_addrs) {
        _game = config_addrs[0];
        _treasuryWallet = config_addrs[1];
        raceEventFactory = IRaceEventFactory(config_addrs[2]);
        raceFactory = IRaceFactory(config_addrs[3]);
        rewardFactory = config_addrs[4];
    }

    ////////////
    // ACCESS //
    ////////////

    /// Get address of the game engine account.
    /// @return address of game.
    function getGame() external view override returns (address) {
        return _game;
    }

    /// Set address of the game engine account.
    /// @param game_ as address.
    function setGame(address game_) external override onlyOwner {
        _game = game_;
    }

    /////////////////////
    // Reward Manager //
    /////////////////////

    /// Get address of the game engine account.
    /// @return address of game.
    function getrewardFactory() external view override returns (address) {
        return rewardFactory;
    }

    /// Set address of the game engine account.
    /// @param rewardFactory_ as address.
    function setrewardFactory(address rewardFactory_)
        external
        override
        onlyOwner
    {
        rewardFactory = rewardFactory_;
    }

    /////////////////
    // RACE EVENTS //
    /////////////////

    /// Get address of the RaceEventFactory.
    /// @return address of RaceEventFactory.
    function getRaceEventFactory() external view override returns (address) {
        return address(raceEventFactory);
    }

    /// Set address of the RaceEventFactory.
    /// @param raceEventFactory_ as address of RaceEventFactory.
    function setRaceEventFactory(address raceEventFactory_)
        external
        override
        onlyOwner
    {
        raceEventFactory = IRaceEventFactory(raceEventFactory_);
    }

    /** Create a new RaceEvent.
     * @param raceEventID_title_uri strings at the following indices
     * 0 as raceEventID string
     * 1 as race title string.
     * 2 as metadata uri string of the race event.
     * @param raceEventType type of Race Event
     * Pass 0 for PRACTICE.
     * Pass 1 for DAILY.
     * Pass 2 for SPECIAL.
     * Pass 3 for TOURNAMENT.
     * Pass 4 for CHAMPIONSHIP.
     */
    function createRaceEvent(
        string[3] calldata raceEventID_title_uri,
        uint8 raceEventType
    ) external override returns (address) {
        require(
            !raceEventIDs[raceEventID_title_uri[0]],
            "RaceEvent ID already exists"
        );

        IRaceEvent raceEvent = IRaceEvent(
            raceEventFactory.newRaceEvent(
                [address(this), rewardFactory],
                raceEventID_title_uri,
                raceEventType
            )
        );

        raceEvent.transferOwnership_(_msgSender());

        raceEventIDsList.push(raceEventID_title_uri[0]);
        raceEventIDs[raceEventID_title_uri[0]] = true;
        raceEvents[raceEventID_title_uri[0]] = raceEvent;
        emit CreateRaceEvent(raceEventID_title_uri[0], address(raceEvent));

        return address(raceEvent);
    }

    ///////////
    // RACES //
    ///////////

    /// Get address of the RaceFactory.
    /// @return address of RaceFactory.
    function getRaceFactory() external view override returns (address) {
        return address(raceFactory);
    }

    /// Set address of the RaceFactory.
    /// @param raceFactory_ as address of RaceFactory.
    function setRaceFactory(address raceFactory_) external override onlyOwner {
        raceFactory = IRaceFactory(raceFactory_);
    }

    /// Get address of the treasury wallet fee receiver.
    /// @return address of account.
    function getTreasuryWallet() external view override returns (address) {
        return _treasuryWallet;
    }

    /// Set treasury wallet receiver of fee.
    /// @param treasuryWallet_ as address.
    function setTreasuryWallet(address treasuryWallet_)
        external
        override
        onlyOwner
    {
        _treasuryWallet = treasuryWallet_;
    }

    /// Check if a given Race ID exists.
    /// @param raceID as string.
    /// @return bool as true if raceID exists.
    function raceIDExists(string calldata raceID)
        external
        view
        override
        returns (bool)
    {
        return raceIDs[raceID];
    }

    /// Track all Race ID's to prevent collisions.
    /// @param raceID as string of the unique Race ID.
    function addRaceID(string calldata raceID) external override {
        require(
            IRaceEvent(_msgSender()).isRaceEvent(),
            "Caller is not RaceEvent"
        );

        raceIDsList.push(raceID);
        raceIDs[raceID] = true;
    }

    ////////////
    // TOKENS //
    ////////////

    /// Withdraws ETH from this contract using TokenWithdrawer.
    /// @param amount of ETH in Wei to withdraw.
    function withdrawETH(uint256 amount) external onlyOwner {
        _withdrawETH(amount);
    }

    /// Withdraws ERC20 from this contract using TokenWithdrawer.
    /// @param token as address of ERC20 token.
    /// @param amount of token in Wei to withdraw.
    function withdrawERC20(address token, uint256 amount) external onlyOwner {
        _withdrawERC20(token, amount);
    }

    /// Withdraws ERC721 from this contract using TokenWithdrawer.
    /// @param token as address of ERC721 token.
    /// @param tokenID as ID of NFT.
    function withdrawERC721(address token, uint256 tokenID) external onlyOwner {
        _withdrawERC721(token, tokenID);
    }

    /// Withdraws ERC1155 from this contract using TokenWithdrawer.
    /// @param token as address of ERC1155 token.
    /// @param tokenID as ID of NFT.
    /// @param amount of NFT to withdraw.
    function withdrawERC1155(
        address token,
        uint256 tokenID,
        uint256 amount
    ) external onlyOwner {
        _withdrawERC1155(token, tokenID, amount);
    }
}

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.15 <0.9.0;

import "./IRaceEvent.sol";

/// @title NitroLeague contract interface.
/// @author Nitro League.
interface INitroLeague {
    // Access.
    function getGame() external view returns (address);

    function setGame(address game_) external;

    // Reward Manager
    function getrewardFactory() external view returns (address);

    function setrewardFactory(address rewardFactory_) external;

    // RaceEvents.
    function getRaceEventFactory() external view returns (address);

    function setRaceEventFactory(address raceEventFactory_) external;

    function createRaceEvent(
        string[3] calldata raceEventID_title_uri,
        uint8 raceEventType
    ) external returns (address);

    // Races.
    function getRaceFactory() external view returns (address);

    function setRaceFactory(address raceEventFactory_) external;

    function getTreasuryWallet() external returns (address);

    function setTreasuryWallet(address treasuryWallet_) external;

    function raceIDExists(string calldata raceID) external returns (bool);

    function addRaceID(string calldata raceID) external;
}

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.15 <0.9.0;

/// @title RaceEventFactory contract interface.
/// @author Nitro League.
interface IRaceEventFactory {
    function newRaceEvent(
        address[2] memory nitro_rewardFactory,
        string[3] memory raceEventID_title_uri,
        uint8 raceEventType_
    ) external returns (address);
}

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.15 <0.9.0;

/// @title RaceEvent contract interface.
/// @author Nitro League.
interface IRaceEvent {
    // RaceEvent.
    function isRaceEvent() external returns (bool);

    function endRaceEvent(address payable[] memory results_) external;

    function cancelRaceEvent() external;

    function transferOwnership_(address newOwner) external;

    function depositRewards(
        uint256[] memory positions,
        uint8[] calldata tokenTypes,
        address[] memory tokens,
        uint256[] calldata tokenIDs,
        uint256[] calldata amounts,
        string[] calldata descriptions
    ) external;

    // Races.
    function createRace(
        address feeToken_,
        string[3] memory raceID_title_uri,
        uint256[6] memory int_settings
    ) external returns (address);

    function setWinningPositions(uint winningPositions_) external;
}

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.15 <0.9.0;

/// @title RaceFactory contract interface.
/// @author Nitro League.
interface IRaceFactory {
    function newRace(
        address[3] memory addrs,
        string[3] memory raceID_title_uri,
        uint256[6] memory int_settings
    ) external returns (address);
}

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.15 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/// @title Utility contract to allow Owner to withdraw value from contracts.
/// @author Nitro League.
contract TokenWithdrawer is Ownable {
    constructor() {}

    /// Withdraw ETH to owner.
    /// Used for recovering value sent to contract.
    /// @param amount of ETH, in Wei, to withdraw.
    function _withdrawETH(uint256 amount) internal {
        (bool success, ) = payable(_msgSender()).call{value: amount}("");
        require(success, "Transfer failed");
    }

    /// Withdraw ERC-20 token to owner.
    /// @param token as address.
    /// @param amount of tokens including decimals.
    function _withdrawERC20(address token, uint256 amount) internal {
        IERC20(token).transfer(_msgSender(), amount);
    }

    /// Withdraw ERC-721 token to owner.
    /// @param token as address.
    /// @param tokenID of NFT.
    function _withdrawERC721(address token, uint256 tokenID) internal {
        IERC721(token).transferFrom(address(this), owner(), tokenID);
    }

    /// Withdraw ERC1155 token to owner.
    /// @param token as address.
    /// @param tokenID of NFT.
    /// @param amount of NFT.
    function _withdrawERC1155(
        address token,
        uint256 tokenID,
        uint256 amount
    ) internal {
        IERC1155(token).safeTransferFrom(
            address(this),
            owner(),
            tokenID,
            amount,
            ""
        );
    }
}

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

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
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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