/**
=**************************************************************************************************************************************************************=
#@*============================================================================================[email protected]#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-             .=+***********:                                     -**********+*-                                                                           :@#
#@-               -#@@@@@@@@@@@*.                                 -%@@@@@@@@@@@*:                                                                            :@#
#@-                 -#@@@@@@@@@@@*:                             -%@@@@@@@@@@@*:                                                                              :@#
#@-                   -#@@@@%-=*%@@*.                         -%@@#[email protected]@@@@*:                                                                                :@#
#@-                     -#@@@%.===++#+:                     -**+===:[email protected]@@@*:                                                                                  :@#
#@-                       -#@@#.+***+=-.                   :==+***=:@@@*:                                                                                    :@#
#@-                         =#@*.+*+++***+=:.         .-=+**++++*=.%@*:                                                                                      :@#
#@-                           -#+.+*+++++++**++++++++**++++++++*=.#*:                                                                                        :@#
#@-                             --:+*+++++++++++++++++++++++++*+.=:    =+++++++++++++++*-#++++++++++++++++=: :=++++++++++++++++#*+++++=   .++++++#           :@#
#@-                                :+++++++++++++++++++++++++*+.      -#+++++++++++++++*[email protected]+++++++++++++++++#:%++++++++++++++*%*:+%*+++++.-**+++##-           :@#
#@-                                 =++*****+++++++++********+-       =*+++++++++++++++*-%=++++++++++++++++#-#+++++++++++++#+:   -##++++**+++*#+.            :@#
#@-                                 ++*****+:........++******+:       =*====#=====#++++*-%=+++*:::::::=*+++#-#+++*+--------:      .*#*++++++#%-              :@#
#@-                                 ++*****+.        ---------:       =*+++=%    .%=+++*-%=++++       -*+++#-#+++++++++++++#        =%+++++*#.               :@#
#@-                                 ++*****+.  ***************:       =*+++=%.....%=+++*[email protected]=++++       -*+++#-#++++++++++++=#       :**++++++*+.              :@#
#@-                                 ++*****+.  *+++++*********-       =*++++*******++++*[email protected]=+++#=======+*+++#-#+++*********##     .=**++***++***:             :@#
#@-                                 ++*****+.        :#*******-       =*+++++++++++++++*[email protected]=++++++++++++++++#-#+++++++++++++++=  :******%=##**+**=            :@#
#@-                                 +*******=---------+*******-       :#*++++++++++*+++*[email protected]++++++++++++****##.##**************+*+#****##:  =%******:          :@#
#@-                                -**************************#:     -+=***********+****-+=================. .================+++===++     :+====+-          :@#
#@-                             --:*****************************.::  :#%#*****####******-                                                                    :@#
#@-                           -#*.***********========+***********.#*.  +%#************##:                                                                    :@#
#@-                         -%@*.*******+=-.          .:-=*#******.#@*: -*+++++++++++++-                                                                     :@#
#@-                       -%@@#.**#*=-:.                   .:=+***+:%@@*.                                                                                    :@#
#@-                     -#@@@%:=---=*+:                    .-*[email protected]@@@*:                                                                                  :@#
#@-                   -%@@@@%:-+%@@*:                         -#@@#[email protected]@@@@*.                                                                                :@#
#@-                 -#@@@@@@@@@@@*:                            .=#@@@@@@@@@@@*:                                                                              :@#
#@-               -%@@@@@@@@@@@*:                                 -#@@@@@@@@@@@*.                                                                            :@#
#@-              -++++++++++++:                                    .=++++++++++++.                                                                           :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@-                                                                                                                                                          :@#
#@+::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]#
+%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract GDEXPassportNFTs_1155_bsc is Ownable, ERC1155Holder {

    uint public lockPeriod;

    struct StakedInfo {
        uint amount;
        uint stakedTime;
    }

    mapping(address => mapping(uint => bool)) private _requestedDeposit;
    mapping(address => mapping(uint => bool)) private _allowedDeposit;
    mapping(address => mapping(uint => bool)) private _requestedWithdraw;
    mapping(address => mapping(uint => bool)) private _allowedWithdraw;
    mapping(uint => mapping(address => mapping(uint => StakedInfo))) public userStakedInfo;

    event UpdatedLockPeriod(uint newPeriod);
    event RequestedDeposit(address indexed user, uint gamerId, uint time);
    event AllowedDeposit(address indexed user, uint gamerId);
    event RequestedWithdraw(address indexed user, uint gamerId, uint time);
    event AllowedWithdraw(address indexed user, uint gamerId);
    event Staked(uint gamerId, address indexed tokenAddress, uint tokenId, uint amount);
    event Withdrawn(uint gamerId, address indexed tokenAddress, uint tokenId, uint amount);
    event WithdrawnBatch(uint gamerId, address[] tokenAddresses, uint[] tokenIds, uint[] amounts);

    constructor() {}

    function setLockPeriod(uint newPeriod) external onlyOwner {
        require(lockPeriod != newPeriod, "Already the same period");
        lockPeriod = newPeriod;

        emit UpdatedLockPeriod(newPeriod);
    }

    function requestDeposit(uint gamerId) external {
        require(!_requestedDeposit[msg.sender][gamerId], "Already requested");
        _requestedDeposit[msg.sender][gamerId] = true;

        emit RequestedDeposit(msg.sender, gamerId, block.timestamp);
    }

    function requestWithdraw(uint gamerId) external {
        require(!_requestedWithdraw[msg.sender][gamerId], "Already requested");
        _requestedWithdraw[msg.sender][gamerId] = true;

        emit RequestedWithdraw(msg.sender, gamerId, block.timestamp);
    }

    function allowDeposit(address user, uint gamerId, bool isAllow) external onlyOwner {
        require(_requestedDeposit[user][gamerId], "The user has not requested yet");

        _allowedDeposit[user][gamerId] = isAllow;
        _requestedDeposit[user][gamerId] = false;

        emit AllowedDeposit(user, gamerId);
    }

    function allowWithdraw(address user, uint gamerId, bool isAllow) external onlyOwner {
        require(_requestedWithdraw[user][gamerId], "The user has not requested yet");

        _allowedWithdraw[user][gamerId] = isAllow;
        _requestedWithdraw[user][gamerId] = false;

        emit AllowedWithdraw(user, gamerId);
    }

    function stake(uint gamerId, address tokenAddress, uint tokenId, uint amount) external {
        require(_allowedDeposit[msg.sender][gamerId], "Not allowed to stake");
        _allowedDeposit[msg.sender][gamerId] = false;

        IERC1155(tokenAddress).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");

        StakedInfo memory userInfo = userStakedInfo[gamerId][tokenAddress][tokenId];

        userInfo.amount += amount;
        userInfo.stakedTime = block.timestamp;

        userStakedInfo[gamerId][tokenAddress][tokenId] = userInfo;

        emit Staked(gamerId, tokenAddress, tokenId, amount);
    }

    function withdraw(uint gamerId, address tokenAddress, uint tokenId, uint amount) external {
        require(_allowedWithdraw[msg.sender][gamerId], "Not allowed to withdraw");
        _allowedWithdraw[msg.sender][gamerId] = false;

        StakedInfo memory userInfo = userStakedInfo[gamerId][tokenAddress][tokenId];
        require(userInfo.amount >= amount, "Insufficient staked amount");
        require(block.timestamp >= userInfo.stakedTime + lockPeriod, "Lock period has not passed");

        if (userInfo.amount == amount) {
            delete userStakedInfo[gamerId][tokenAddress][tokenId];
        } else {
            userInfo.amount = userInfo.amount - amount;
            userStakedInfo[gamerId][tokenAddress][tokenId] = userInfo;
        }

        IERC1155(tokenAddress).safeTransferFrom(address(this), msg.sender, tokenId, amount, "");

        emit Withdrawn(gamerId, tokenAddress, tokenId, amount);
    }

    function withdrawBatch(uint gamerId, address[] calldata tokenAddresses, uint[] calldata tokenIds, uint[] calldata amounts) external {
        require(_allowedWithdraw[msg.sender][gamerId], "Not allowed to withdraw");
        _allowedWithdraw[msg.sender][gamerId] = false;
        
        require(tokenAddresses.length == amounts.length, "Must be the same length");
        require(tokenAddresses.length == tokenIds.length, "Must be the same length");

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            StakedInfo memory userInfo = userStakedInfo[gamerId][tokenAddresses[i]][tokenIds[i]];
            require(userInfo.amount >= amounts[i], "Insufficient staked amount");
            require(block.timestamp >= userInfo.stakedTime + lockPeriod, "Lock period has not passed");

            if (userInfo.amount == amounts[i]) {
                delete userStakedInfo[gamerId][tokenAddresses[i]][tokenIds[i]];
            } else {
                userInfo.amount = userInfo.amount - amounts[i];
                userStakedInfo[gamerId][tokenAddresses[i]][tokenIds[i]] = userInfo;
            }

            IERC1155(tokenAddresses[i]).safeTransferFrom(address(this), msg.sender, tokenIds[i], amounts[i], "");
        }

        emit WithdrawnBatch(gamerId, tokenAddresses, tokenIds, amounts);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
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

import "./IERC165.sol";

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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}