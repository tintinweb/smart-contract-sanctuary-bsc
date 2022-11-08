// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz/token/ERC20/IERC20.sol";
import {
    IERC20Permit
} from "oz-custom/contracts/oz/token/ERC20/extensions/draft-IERC20Permit.sol";
import {
    IERC721,
    ERC721TokenReceiver
} from "oz-custom/contracts/oz/token/ERC721/ERC721.sol";

interface INotifyGate {
    event Notified(
        address indexed sender,
        bytes indexed message,
        address indexed token,
        uint256 value
    );

    function notifyWithNative(bytes calldata message_) external payable;

    function notifyWithERC20(
        IERC20 token_,
        uint256 value_,
        uint256 deadline_,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes calldata message_
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/internal/FundForwarder.sol";

import "./interfaces/INotifyGate.sol";

contract NotifyGate is INotifyGate, FundForwarder, ERC721TokenReceiver {
    constructor(address vault_) payable FundForwarder(vault_) {}

    function notifyWithNative(bytes calldata message_) external payable {
        _safeNativeTransfer(vault, msg.value);
        emit Notified(_msgSender(), message_, address(0), msg.value);
    }

    function onERC721Received(
        address from_,
        address,
        uint256 tokenId_,
        bytes calldata message_
    ) external override returns (bytes4) {
        address nft = _msgSender();
        IERC721(nft).safeTransferFrom(address(this), vault, tokenId_);

        emit Notified(from_, message_, nft, tokenId_);

        return this.onERC721Received.selector;
    }

    function notifyWithERC20(
        IERC20 token_,
        uint256 value_,
        uint256 deadline_,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes calldata message_
    ) external {
        address user = _msgSender();
        if (token_.allowance(user, address(this)) < value_) {
            IERC20Permit(address(token_)).permit(
                user,
                address(this),
                value_,
                deadline_,
                v,
                r,
                s
            );
        }
        _safeERC20TransferFrom(token_, user, vault, value_);

        emit Notified(user, message_, address(token_), value_);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../oz/utils/Context.sol";

import "./Transferable.sol";

error FundForwarder__ForwardFailed();

abstract contract FundForwarder is Context, Transferable {
    address public vault;

    event VaultUpdated(address indexed from, address indexed to);
    event Forwarded(address indexed from, uint256 indexed amount);

    constructor(address vault_) payable {
        _changeVault(vault_);
    }

    receive() external payable virtual {
        (bool ok, ) = vault.call{value: msg.value}("");
        if (!ok) revert FundForwarder__ForwardFailed();
        emit Forwarded(_msgSender(), msg.value);
    }

    function recoverERC20(IERC20 token_, uint256 amount_) external {
        _safeERC20Transfer(token_, vault, amount_);
    }

    function recoverNative() external {
        _safeNativeTransfer(vault, address(this).balance);
    }

    function _changeVault(address vault_) internal {
        emit VaultUpdated(vault, vault_);
        vault = vault_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../oz/token/ERC20/IERC20.sol";

error Transferable__TransferFailed();
error Transferable__InvalidArguments();

abstract contract Transferable {
    function _safeTransferFrom(
        IERC20 token_,
        address from_,
        address to_,
        uint256 value_
    ) internal virtual {
        __checkValidTransfer(to_, value_);
        bool success;
        if (address(token_) == address(0))
            success = __nativeTransfer(to_, value_);
        else success = __ERC20TransferFrom(token_, from_, to_, value_);

        if (!success) revert Transferable__TransferFailed();
    }

    function _safeTransfer(
        IERC20 token_,
        address to_,
        uint256 value_
    ) internal virtual {
        __checkValidTransfer(to_, value_);
        bool success;
        if (address(token_) == address(0))
            success = __nativeTransfer(to_, value_);
        else success = __ERC20Transfer(token_, to_, value_);

        if (!success) revert Transferable__TransferFailed();
    }

    function _safeNativeTransfer(address to_, uint256 amount_)
        internal
        virtual
    {
        __checkValidTransfer(to_, amount_);
        if (!__nativeTransfer(to_, amount_))
            revert Transferable__TransferFailed();
    }

    function _safeERC20Transfer(
        IERC20 token_,
        address to_,
        uint256 amount_
    ) internal virtual {
        __checkValidTransfer(to_, amount_);
        if (!__ERC20Transfer(token_, to_, amount_))
            revert Transferable__TransferFailed();
    }

    function _safeERC20TransferFrom(
        IERC20 token_,
        address from_,
        address to_,
        uint256 amount_
    ) internal virtual {
        __checkValidTransfer(to_, amount_);

        if (!__ERC20TransferFrom(token_, from_, to_, amount_))
            revert Transferable__TransferFailed();
    }

    function __nativeTransfer(address to_, uint256 amount_)
        private
        returns (bool success)
    {
        assembly {
            success := call(gas(), to_, amount_, 0, 0, 0, 0)
        }
    }

    function __ERC20Transfer(
        IERC20 token_,
        address to_,
        uint256 value_
    ) internal virtual returns (bool success) {
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                freeMemoryPointer,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            )
            mstore(add(freeMemoryPointer, 4), to_) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), value_) // Append the "amount" argument.

            success := and(
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                call(gas(), token_, 0, freeMemoryPointer, 68, 0, 32)
            )
        }
    }

    function __ERC20TransferFrom(
        IERC20 token_,
        address from_,
        address to_,
        uint256 value_
    ) internal virtual returns (bool success) {
        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(
                freeMemoryPointer,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            )
            mstore(add(freeMemoryPointer, 4), from_)
            mstore(add(freeMemoryPointer, 36), to_)
            mstore(add(freeMemoryPointer, 68), value_)

            success := and(
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                call(gas(), token_, 0, freeMemoryPointer, 100, 0, 32)
            )
        }
    }

    function __checkValidTransfer(address to_, uint256 value_) private pure {
        if (value_ == 0 || to_ == address(0))
            revert Transferable__InvalidArguments();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library Bytes32Address {
    function fromFirst20Bytes(bytes32 bytesValue)
        internal
        pure
        returns (address addr)
    {
        assembly {
            addr := bytesValue
        }
    }

    function fillLast12Bytes(address addressValue)
        internal
        pure
        returns (bytes32 value)
    {
        assembly {
            value := addressValue
        }
    }

    function fromFirst160Bits(uint256 uintValue)
        internal
        pure
        returns (address addr)
    {
        assembly {
            addr := uintValue
        }
    }

    function fillLast96Bits(address addressValue)
        internal
        pure
        returns (uint256 value)
    {
        assembly {
            value := addressValue
        }
    }

    function fromLast160Bits(uint256 uintValue)
        internal
        pure
        returns (address addr)
    {
        assembly {
            addr := shr(0x60, uintValue)
        }
    }

    function fillFirst96Bits(address addressValue)
        internal
        pure
        returns (uint256 value)
    {
        assembly {
            value := shl(0x60, addressValue)
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.17;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    error ERC20Permit__Expired();

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
    error ERC20__Expired();
    error ERC20__StringTooLong();
    error ERC20__InvalidSignature();
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.10;

import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";
import "../../utils/structs/BitMaps.sol";
import "./IERC721.sol";
import "./extensions/IERC721Metadata.sol";

import "../../../libraries/Bytes32Address.sol";

/// @notice Modern, minimalist, and gas efficient ERC-721 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Bytes32Address for address;
    using Bytes32Address for bytes32;
    using Bytes32Address for uint256;

    using BitMaps for BitMaps.BitMap;
    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;
    string public symbol;

    function _baseURI() internal view virtual returns (string memory);

    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => bytes32) internal _ownerOf;
    mapping(bytes32 => uint256) internal _balanceOf;

    function ownerOf(uint256 id)
        public
        view
        virtual
        override
        returns (address owner)
    {
        if ((owner = _ownerOf[id].fromFirst20Bytes()) == address(0))
            revert ERC721__NotMinted();
    }

    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if (owner == address(0)) revert ERC721__NonZeroAddress();

        return _balanceOf[owner.fillLast12Bytes()];
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => bytes32) internal _getApproved;

    mapping(bytes32 => BitMaps.BitMap) internal _isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol) payable {
        if (bytes(_name).length > 32 || bytes(_symbol).length > 32)
            revert ERC721__StringTooLong();
        name = _name;
        symbol = _symbol;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual override {
        address owner = _ownerOf[id].fromFirst20Bytes();
        address sender = _msgSender();
        if (
            sender != owner &&
            !_isApprovedForAll[owner.fillLast12Bytes()].get(
                sender.fillLast96Bits()
            )
        ) revert ERC721__Unauthorized();

        _getApproved[id] = spender.fillLast12Bytes();

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        address sender = _msgSender();
        _isApprovedForAll[sender.fillLast12Bytes()].setTo(
            operator.fillLast96Bits(),
            approved
        );

        emit ApprovalForAll(sender, operator, approved);
    }

    function getApproved(uint256 tokenId)
        external
        view
        override
        returns (address operator)
    {
        return _getApproved[tokenId].fromFirst20Bytes();
    }

    function isApprovedForAll(address owner, address operator)
        external
        view
        override
        returns (bool)
    {
        return
            _isApprovedForAll[owner.fillLast12Bytes()].get(
                operator.fillLast96Bits()
            );
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            _isApprovedForAll[owner.fillLast12Bytes()].get(
                spender.fillLast96Bits()
            ) ||
            _getApproved[tokenId] == spender.fillLast12Bytes());
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual override {
        if (from != _ownerOf[id].fromFirst20Bytes()) revert ERC721__WrongFrom();
        if (to == address(0)) revert ERC721__InvalidRecipient();
        _beforeTokenTransfer(from, to, id);

        address sender = _msgSender();
        bytes32 _from = from.fillLast12Bytes();
        if (
            sender != from &&
            !_isApprovedForAll[_from].get(sender.fillLast96Bits()) &&
            sender.fillLast12Bytes() != _getApproved[id]
        ) revert ERC721__Unauthorized();

        bytes32 _to = to.fillLast12Bytes();
        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[_from]--;

            _balanceOf[_to]++;
        }

        _ownerOf[id] = _to;

        delete _getApproved[id];

        emit Transfer(from, to, id);

        _afterTokenTransfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual override {
        transferFrom(from, to, id);

        if (
            to.code.length != 0 &&
            ERC721TokenReceiver(to).onERC721Received(
                _msgSender(),
                from,
                id,
                ""
            ) !=
            ERC721TokenReceiver.onERC721Received.selector
        ) revert ERC721__UnsafeRecipient();
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual override {
        transferFrom(from, to, id);

        if (
            to.code.length != 0 &&
            ERC721TokenReceiver(to).onERC721Received(
                _msgSender(),
                from,
                id,
                data
            ) !=
            ERC721TokenReceiver.onERC721Received.selector
        ) revert ERC721__UnsafeRecipient();
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        if (from != _ownerOf[tokenId].fromFirst20Bytes())
            revert ERC721__WrongFrom();
        if (to == address(0)) revert ERC721__InvalidRecipient();
        _beforeTokenTransfer(from, to, tokenId);

        bytes32 _to = to.fillLast12Bytes();

        unchecked {
            --_balanceOf[from.fillLast12Bytes()];
            ++_balanceOf[_to];
        }
        _ownerOf[tokenId] = _to;

        delete _getApproved[tokenId];

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {
        if (to == address(0)) revert ERC721__InvalidRecipient();
        if (_ownerOf[id] != 0) revert ERC721__AlreadyMinted();

        _beforeTokenTransfer(address(0), to, id);
        bytes32 _to = to.fillLast12Bytes();
        // Counter overflow is incredibly unrealistic.
        unchecked {
            _balanceOf[_to]++;
        }
        _ownerOf[id] = _to;

        emit Transfer(address(0), to, id);

        _afterTokenTransfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id].fromFirst20Bytes();

        if (owner == address(0)) revert ERC721__NotMinted();

        _beforeTokenTransfer(owner, address(0), id);

        // Ownership check above ensures no underflow.
        unchecked {
            _balanceOf[owner.fillLast12Bytes()]--;
        }

        delete _ownerOf[id];
        delete _getApproved[id];

        emit Transfer(owner, address(0), id);

        _afterTokenTransfer(owner, address(0), id);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        if (
            to.code.length != 0 &&
            ERC721TokenReceiver(to).onERC721Received(
                _msgSender(),
                address(0),
                id,
                ""
            ) !=
            ERC721TokenReceiver.onERC721Received.selector
        ) revert ERC721__UnsafeRecipient();
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        if (
            to.code.length != 0 &&
            ERC721TokenReceiver(to).onERC721Received(
                _msgSender(),
                address(0),
                id,
                data
            ) !=
            ERC721TokenReceiver.onERC721Received.selector
        ) revert ERC721__UnsafeRecipient();
    }
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.17;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.17;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    error ERC721__NotMinted();
    error ERC721__WrongFrom();
    error ERC721__Unauthorized();
    error ERC721__StringTooLong();
    error ERC721__AlreadyMinted();
    error ERC721__NonZeroAddress();
    error ERC721__UnsafeRecipient();
    error ERC721__InvalidRecipient();
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.17;

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.17;

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
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.17;

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
// OpenZeppelin Contracts v4.4.1 (utils/structs/BitMaps.sol)
pragma solidity ^0.8.17;

/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, providing the keys are sequential.
 * Largelly inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 */
library BitMaps {
    struct BitMap {
        mapping(uint256 => uint256) map;
    }

    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(BitMap storage bitmap, uint256 index)
        internal
        view
        returns (bool isSet)
    {
        uint256 value = bitmap.map[index >> 8] & (1 << (index & 0xff));

        assembly {
            isSet := value // Assign isSet to whether the value is non zero.
        }
    }

    /**
     * @dev Sets the bit at `index` to the boolean `value`.
     */
    function setTo(
        BitMap storage bitmap,
        uint256 index,
        bool shouldSet
    ) internal {
        uint256 value = bitmap.map[index >> 8];

        assembly {
            // The following sets the bit at `shift` without branching.
            let shift := and(index, 0xff)
            // Isolate the bit at `shift`.
            let x := and(shr(shift, value), 1)
            // Xor it with `shouldSet`. Results in 1 if both are different, else 0.
            x := xor(x, shouldSet)
            // Shifts the bit back. Then, xor with value.
            // Only the bit at `shift` will be flipped if they differ.
            // Every other bit will stay the same, as they are xor'ed with zeroes.
            value := xor(value, shl(shift, x))
        }
        bitmap.map[index >> 8] = value;
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap storage bitmap, uint256 index) internal {
        bitmap.map[index >> 8] |= (1 << (index & 0xff));
    }

    function setBatch(BitMap storage bitmap_, uint256[] memory values_)
        internal
    {
        assembly {
            let length := mload(values_)
            let i := add(values_, 0x20)
            mstore(0x20, bitmap_.slot)
            for {
                let end := add(i, mul(length, 0x20))
            } lt(i, end) {
                i := add(i, 0x20)
            } {
                mstore(0x00, shr(8, mload(i)))
                let key := keccak256(0x00, 0x40)
                sstore(key, or(sload(key), shl(and(mload(i), 0xff), 1)))
            }
        }
    }

    /**
     * @dev Unsets the bit at `index`.
     */
    function unset(BitMap storage bitmap, uint256 index) internal {
        bitmap.map[index >> 8] &= ~(1 << (index & 0xff));
    }
}