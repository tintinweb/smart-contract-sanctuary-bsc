// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

contract PassMarketplace is Ownable, ERC1155Receiver, ERC1155Holder {
    IERC20 public currency;
    IERC1155 public tokens;
    uint256 private _firstTokenId;
    uint256 private _lastTokenId;
    mapping(address => bool) private _allowedDiscounts;
    mapping(uint256 => uint256) public pricesBNB;
    mapping(uint256 => uint256) public discountedPricesBNB;
    mapping(uint256 => uint256) public pricesIERC20;
    mapping(uint256 => uint256) public discountedPricesIERC20;

    constructor() {
        _firstTokenId = 1;
        _lastTokenId = 8;
    }

    /*** Specify, which currency we accept ***/

    function setCurrency(IERC20 _currency) external onlyOwner {
        currency = _currency;
    }

    /*** Specify, which tokens are sold ***/

    function setTokens(IERC1155 _tokens) external onlyOwner {
        tokens = _tokens;
    }

    /*** Price ***/

    function setPrices(
        uint256[] calldata _pricesBNB,
        uint256[] calldata _discountedPricesBNB,
        uint256[] calldata _pricesIERC20,
        uint256[] calldata _discountedPricesIERC20
    ) external onlyOwner {
        require(
            _pricesBNB.length == _discountedPricesBNB.length &&
                _pricesIERC20.length == _discountedPricesIERC20.length &&
                _pricesBNB.length == _pricesIERC20.length,
            "The prices and discountedPrices arrays must have the same length."
        );
        for (
            uint256 i = _firstTokenId;
            i < _pricesBNB.length + _firstTokenId;
            i++
        ) {
            pricesBNB[i] = _pricesBNB[i - _firstTokenId];
            discountedPricesBNB[i] = _discountedPricesBNB[i - _firstTokenId];
            pricesIERC20[i] = _pricesIERC20[i - _firstTokenId];
            discountedPricesIERC20[i] = _discountedPricesIERC20[
                i - _firstTokenId
            ];
        }
    }

    function getPrice(
        uint256 _tokenId,
        address _address,
        uint256 _howMuchBying
    ) public view returns (uint256 finalPriceBNB, uint256 finalPriceIERC20) {
        require(
            msg.sender == _address ||
                msg.sender == owner() ||
                msg.sender == address(this),
            "Unless you are the owner, you can check the price only for you."
        );
        require(
            pricesBNB[_tokenId] > 0 &&
                discountedPricesBNB[_tokenId] > 0 &&
                pricesIERC20[_tokenId] > 0 &&
                discountedPricesIERC20[_tokenId] > 0,
            "Some prices are not set (zero)."
        );
        require(_howMuchBying > 0, "Buying zero tokens isn't possible.");

        if (hasAllowedDiscount(_address)) {
            return (
                discountedPricesBNB[_tokenId] * _howMuchBying,
                discountedPricesIERC20[_tokenId] * _howMuchBying
            );
        }
        return (
            pricesBNB[_tokenId] * _howMuchBying,
            pricesIERC20[_tokenId] * _howMuchBying
        );
    }

    /*** Set of methods to work with discounts ***/

    function addAllowedDiscount(address _address) external onlyOwner {
        _allowedDiscounts[_address] = true;
    }

    function removeAllowedDiscount(address _address) external onlyOwner {
        _allowedDiscounts[_address] = false;
    }

    function setAllowedDiscount(address[] calldata _addresses)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _addresses.length; i++) {
            _allowedDiscounts[_addresses[i]] = true;
        }
    }

    function hasAllowedDiscount(address _address) public view returns (bool) {
        require(
            msg.sender == _address ||
                msg.sender == owner() ||
                msg.sender == address(this),
            "Unless you are the owner, you can check the discount only for you."
        );
        return _allowedDiscounts[_address];
    }

    /*** Make a purchase ***/

    function buy(
        uint256 _tokenId,
        uint256 _howMuchBuying,
        string calldata _currency
    )
        external
        payable
        tokensAreSet
        correctCurrency(_currency)
        tokenAvailable(_tokenId, _howMuchBuying)
    {
        // Determine price
        (uint256 finalPriceBNB, uint256 finalPriceIERC20) = getPrice(
            _tokenId,
            msg.sender,
            _howMuchBuying
        );

        // Check whether buyer meets the price
        if (
            keccak256(abi.encodePacked((_currency))) ==
            keccak256(abi.encodePacked(("BNB")))
        ) {
            require(finalPriceBNB > 0, "Price is calculated to be zero.");
            require(
                msg.value == finalPriceBNB,
                "Amount sent is not equal to the final price."
            );
        } else if (
            keccak256(abi.encodePacked((_currency))) ==
            keccak256(abi.encodePacked(("IERC20")))
        ) {
            require(finalPriceIERC20 > 0, "Price is calculated to be zero.");
            require(
                msg.value == 0,
                "msg.value should be zero when paying with custom IERC20 token."
            );
            require(
                currency.allowance(msg.sender, address(this)) >=
                    finalPriceIERC20,
                "Allowance too low."
            );

            // Pay in ERC20 tokens
            bool paid = currency.transferFrom(
                msg.sender,
                owner(),
                finalPriceIERC20
            );
            require(paid, "IERC20 currency transfer failed");
        }

        // Transfer tokens to buyer
        tokens.safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId,
            _howMuchBuying,
            "0x00"
        );

        // Transfer BNB to owner
        payable(owner()).transfer(msg.value);
    }

    /*** Make an upgrade ***/
    // Takes a token from buyer and swaps it with another token from a higher category
    function upgradeToken(uint256 _upgradeFromId, string calldata _currency)
        external
        payable
        tokensAreSet
        correctCurrency(_currency)
        tokenAvailable(_upgradeFromId - 1, 1)
    {
        // Check whether marketplace is allowed to take old token from buyer (later to swap it for a better one)
        require(
            tokens.isApprovedForAll(msg.sender, address(this)),
            "Marketplace not allowed to switch tokens."
        );

        // Token price check
        (
            uint256 finalPriceBNBCurrentToken,
            uint256 finalPriceIERC20CurrentToken
        ) = getPrice(_upgradeFromId, msg.sender, 1);
        (
            uint256 finalPriceBNBUpgradedToken,
            uint256 finalPriceIERC20UpgradedToken
        ) = getPrice(_upgradeFromId - 1, msg.sender, 1);

        // Check whether buyer meets the price
        if (
            keccak256(abi.encodePacked((_currency))) ==
            keccak256(abi.encodePacked(("BNB")))
        ) {
            require(
                finalPriceBNBUpgradedToken - finalPriceBNBCurrentToken > 0,
                "Price not set (zero)."
            );
            require(
                msg.value ==
                    finalPriceBNBUpgradedToken - finalPriceBNBCurrentToken,
                "Amount sent is not equal to the final price."
            );
        } else if (
            keccak256(abi.encodePacked((_currency))) ==
            keccak256(abi.encodePacked(("IERC20")))
        ) {
            require(
                msg.value == 0,
                "msg.value should be zero when paying with custom IERC20 token."
            );
            require(
                finalPriceIERC20UpgradedToken - finalPriceIERC20CurrentToken >
                    0,
                "Price not set (zero)."
            );
            require(
                currency.allowance(msg.sender, address(this)) >=
                    finalPriceIERC20UpgradedToken -
                        finalPriceIERC20CurrentToken,
                "Allowance too low."
            );

            // Pay in ERC20 tokens
            bool paid = currency.transferFrom(
                msg.sender,
                owner(),
                finalPriceIERC20UpgradedToken - finalPriceIERC20CurrentToken
            );
            require(paid, "IERC20 currency transfer failed");
        }

        // Take original token from buyer
        tokens.safeTransferFrom(
            msg.sender,
            address(this),
            _upgradeFromId,
            1,
            "0x00"
        );

        // Give new token to buyer
        tokens.safeTransferFrom(
            address(this),
            msg.sender,
            _upgradeFromId - 1,
            1,
            "0x00"
        );

        // Transfer BNB to owner
        payable(owner()).transfer(msg.value);
    }

    /*** Transfer tokens to owner ***/
    function transferTokensToOwner(uint256 _tokenId) external onlyOwner {
        uint256 tokenBalance = tokens.balanceOf(address(this), _tokenId);
        require(
            tokenBalance > 0,
            "The contract doesn't hold any tokens of this ID."
        );
        tokens.safeTransferFrom(
            address(this),
            owner(),
            _tokenId,
            tokenBalance,
            "0x00"
        );
    }

    /*** Transfer tokens to other address ***/
    function transferTokensToAddress(
        uint256 _tokenId,
        uint256 _amount,
        address _address
    ) external onlyOwner {
        uint256 tokenBalance = tokens.balanceOf(address(this), _tokenId);
        require(tokenBalance > _amount, "Not enough tokens of this ID.");
        tokens.safeTransferFrom(
            address(this),
            _address,
            _tokenId,
            _amount,
            "0x00"
        );
    }

    /*** Modifiers ***/

    modifier tokensAreSet() {
        // Did we set what we are selling?
        require(
            address(tokens) != address(0),
            "The tokens haven't been set yet."
        );
        _;
    }

    modifier correctCurrency(string calldata _currency) {
        // Currency check
        require(
            keccak256(abi.encodePacked((_currency))) ==
                keccak256(abi.encodePacked(("BNB"))) ||
                (keccak256(abi.encodePacked((_currency))) ==
                    keccak256(abi.encodePacked(("IERC20"))) &&
                    address(currency) != address(0)),
            "Currency must be either 'BNB' or 'IERC20'. If it's the latter, make sure the contract knows which IERC20 tokens serve as the currency."
        );
        _;
    }

    modifier tokenAvailable(uint256 _tokenId, uint256 _howMuchBuying) {
        // Token stock check
        require(
            tokens.balanceOf(address(this), _tokenId) >= _howMuchBuying,
            "Not enough available tokens."
        );
        _;
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
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