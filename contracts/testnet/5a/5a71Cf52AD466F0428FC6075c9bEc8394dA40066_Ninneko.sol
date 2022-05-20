// SPDX-License-Identifier: MIT

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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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

pragma solidity ^0.8.0;

import "./IERC721Upgradeable.sol";
import "./IERC721ReceiverUpgradeable.sol";
import "./extensions/IERC721MetadataUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/StringsUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
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

pragma solidity ^0.8.0;

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
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

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
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./NinnekoLib.sol";

interface IRecordVolume {
   // function setVolumeTrade(address _user, uint256 _volume) external;
}

interface IPrivateRandom {
    //function rand(uint256 _modulus) external returns (uint256);
}

contract Ninneko is Initializable, ERC721Upgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct Auction {
        address seller;
        uint256 startingPrice;
        uint256 endingPrice;
        uint64 duration;
        uint64 startedAt;
    }

    struct Pet {
        uint8 generation;
        uint16 breedCount;
        uint32 birthTime;
        uint256 matronId;
        uint256 sireId;
        uint256 geneId;
    }

    IERC20Upgradeable public NINOToken;
    IERC20Upgradeable public MATAToken;

    uint256 private constant FEE_RATIO = 10_000;

    string private _uri;

    uint256 public serviceFee;
    uint256 public breedNINOFee;
    uint256 public minPriceSalePet;

    uint8 public constant MAX_BREED_COUNT = 6;

    Pet[] public pets;
    mapping(uint256 => uint256) public petsOnSale;

    bool public allowBreed;
    uint256 public adulthoodTime;
    address public operator;
    address public ninoReceiver;
    address public tradingFeeReceiver; // mainnet
    bool public paused;
    bool public pausedBreed;
    uint256[6] public breedCosts;
    uint256 private counter;
    mapping(uint256 => bool) public blackList;
    // address public tradingFeeReceiver; // testnet
    mapping(uint256 => Auction) public auctions;
    uint256 public rebornFee;
    bool public pausedReborn;
    uint256 public requestExpire;
    address public validator;
    mapping(address => uint256) public nonceUsed;
    bool public isRecordVolumeTrade;
    mapping(address => uint256) public userVolumeTrade; // useless
    uint256 public minDurationAuction;
    uint256 public maxDurationAuction;
    uint256 public maxPriceAuction;
    IRecordVolume public addressRecordVolume;
    uint256 public mataRebornFee;
    IPrivateRandom private privateRandom;
    mapping(uint256 => uint256) public petReborn; //petId => amount reborn
    uint256 public constant MAX_NUMBER_REBORN = 3;
    uint256 public ninoFuseFee;
    uint256 public mataFuseFee;
    uint256 public mataUpgradeFee;

    event PetCreated(address indexed owner, uint256 indexed petId, uint256 matronId, uint256 sireId, uint8 generation, uint256 geneId);
    event PetListed(uint256 indexed petId, address indexed seller, uint256 price);
    event PetDelisted(uint256 indexed petId);
    event PetBought(uint256 indexed petId, address indexed buyer, address indexed seller, uint256 price);
    event BlackList(uint256 nftId, bool isInBlackList);
    event AuctionCreated(address indexed seller, uint256 indexed petId, uint256 startingPrice, uint256 endingPrice, uint256 startedAt, uint256 duration);
    event AuctionBid(uint256 indexed petId, address indexed buyer, address indexed seller, uint256 price);
    event AuctionCancelled(uint256 indexed petId);
    event Reborn(uint256 indexed petId, uint256 newGeneId);
    event Fuse(uint256 indexed pet1Id, uint256 indexed pet2Id , uint256 indexed newPetId);
    event PetUpgrade(uint256 indexed petId, uint256 indexed petMaterialId);

    function initialize(
        string memory baseUri,
        address addNINOToken,
        address addMATAToken
    ) public initializer {
        __Ownable_init_unchained();
        __ReentrancyGuard_init_unchained();
        __ERC721_init("Ninneko Contract", "NEKO");

        _uri = baseUri;
        _setAcceptedTokenContract(addNINOToken, addMATAToken);

        pets.push(Pet(0, 0, 0, 0, 0, 0)); // Pet #0 belongs to none
        serviceFee = 500;
        rebornFee = 100 * 10**18;
        breedNINOFee = 350 * 10**18;
        minPriceSalePet = 1 * 10**16;
        breedCosts = [3600 * 10**18, 5500 * 10**18, 9400 * 10**18, 15000 * 10**18, 24000 * 10**18, 38000 * 10**18];
        allowBreed = false;
        adulthoodTime = 6 days;
        ninoReceiver = owner();
        operator = owner();
        tradingFeeReceiver = owner();
        pausedReborn = true;
        minDurationAuction = 24 hours;
        maxDurationAuction = 72 hours;
        maxPriceAuction = 10 * 10**18;
        mataRebornFee = 10000 * 10**18;
        validator = owner();
        requestExpire = 5 minutes;
        ninoFuseFee =  100 * 10**18;
        mataFuseFee = 10000 * 10**18;
        mataUpgradeFee = 10000 * 10**18;
    }

    modifier onlyOperator() {
        require(msg.sender == operator || msg.sender == owner(), "Not the operator or owner");
        _;
    }

    modifier onlyPetOwner(uint256 _petId) {
        require(ownerOf(_petId) == msg.sender, "Not the owner of this one");
        _;
    }

    modifier notInBlackList(uint256 _petId) {
        require(!blackList[_petId], "blacklisted pet");
        _;
    }

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenNotPausedBreed() {
        require(!pausedBreed);
        _;
    }

    modifier whenNotPausedReborn() {
        require(!pausedReborn);
        _;
    }

    modifier validateBreed(uint256 _pet1Id, uint256 _pet2Id) {
        require(ownerOf(_pet1Id) == msg.sender && ownerOf(_pet2Id) == msg.sender, "Not the owner of this one");
        require(_pet1Id != _pet2Id, "Use 2 to breed");
        require(pets[_pet1Id].breedCount < MAX_BREED_COUNT && pets[_pet2Id].breedCount < MAX_BREED_COUNT, "Breed reached limit");

        require(block.timestamp >= adulthoodTime + uint256(pets[_pet1Id].birthTime), "pet1 is not mature enough to breed");
        require(block.timestamp >= adulthoodTime + uint256(pets[_pet2Id].birthTime), "pet2 is not mature enough to breed");

        require(pets[_pet1Id].matronId != _pet2Id && pets[_pet1Id].sireId != _pet2Id && pets[_pet2Id].matronId != _pet1Id && pets[_pet2Id].sireId != _pet1Id, "Can't breed between parent and child");

        if (pets[_pet1Id].matronId > 0 || pets[_pet1Id].sireId > 0 || pets[_pet2Id].matronId > 0 || pets[_pet2Id].sireId > 0) {
            // NOT minted one
            require(
                pets[_pet1Id].matronId != pets[_pet2Id].matronId && pets[_pet1Id].matronId != pets[_pet2Id].sireId && pets[_pet2Id].matronId != pets[_pet1Id].sireId,
                "can't breed between ones that have the same parent"
            );
        }
        _;
    }

    function totalSupply() public view returns (uint256) {
        return pets.length;
    }

    function _baseURI() internal view override returns (string memory) {
        return _uri;
    }

    function _setAcceptedTokenContract(address addNINO, address addMATA) private {
        NINOToken = IERC20Upgradeable(addNINO);
        MATAToken = IERC20Upgradeable(addMATA);
    }

    function setMinPricePetSale(uint256 _minPrice) external onlyOwner {
        minPriceSalePet = _minPrice;
    }

    // function setAcceptedTokenContract(address addNINO, address addMATA) external onlyOwner {
    //     _setAcceptedTokenContract(addNINO, addMATA);
    // }

    function setBreedCosts(uint256[6] memory _newBreedCosts) external onlyOwner {
        breedCosts = _newBreedCosts;
    }

    function setBreedNINOFee(uint256 _newFee) external onlyOwner {
        breedNINOFee = _newFee;
    }

    function setServiceFee(uint256 _value) external onlyOwner {
        serviceFee = _value;
    }

    function calculateServiceFee(uint256 _price) private view returns (uint256) {
        return (_price * serviceFee) / FEE_RATIO;
    }

    function setBaseUri(string memory _baseUri) external onlyOwner {
        _uri = _baseUri;
    }

    function setAllowBreed(bool _allowBreed) external onlyOperator {
        allowBreed = _allowBreed;
    }

    function setTimeBreedAfter(uint256 _timer) external onlyOperator {
        adulthoodTime = _timer;
    }

    function setNINOReceiver(address _address) external onlyOwner {
        ninoReceiver = _address;
    }

    function setTradingFeeReceiver(address _address) external onlyOwner {
        tradingFeeReceiver = _address;
    }

    function setOperator(address _address) public onlyOwner {
        operator = _address;
    }

    function setPause(bool _pause) external onlyOwner {
        paused = _pause;
    }

    function setPauseBreed(bool _pauseBreed) external onlyOwner {
        pausedBreed = _pauseBreed;
    }

    function setPauseReborn(bool _pauseReborn) external onlyOwner {
        pausedReborn = _pauseReborn;
    }

    function setRebornFee(uint256 _ninoRebornFee, uint256 _mataRebornFee) external onlyOwner {
        mataRebornFee = _mataRebornFee;
        rebornFee = _ninoRebornFee;
    }

    function setMataUpgradeFee(uint256 _fee) external onlyOwner {
        mataUpgradeFee = _fee;
    }

    function setParameterAuction(
        uint256 _minDuration,
        uint256 _maxDuration,
        uint256 _maxPrice
    ) external onlyOwner {
        minDurationAuction = _minDuration;
        maxDurationAuction = _maxDuration;
        maxPriceAuction = _maxPrice;
    }

    function setBlackList(uint256[] memory _listId) external onlyOwner {
        for (uint256 i = 0; i < _listId.length; i++) {
            uint256 nftId = _listId[i];
            blackList[nftId] = true;
            emit BlackList(nftId, true);
        }
    }

    function removeFromBlackList(uint256[] memory _listId) external onlyOwner {
        for (uint256 i = 0; i < _listId.length; i++) {
            uint256 nftId = _listId[i];
            blackList[nftId] = false;
            emit BlackList(nftId, false);
        }
    }

    function setFuseFee(uint256 _ninoFee, uint256 _mataFee) external onlyOwner {
        ninoFuseFee = _ninoFee;
        mataFuseFee = _mataFee;
    }

    function breed(uint256 _pet1Id, uint256 _pet2Id) external whenNotPausedBreed nonReentrant validateBreed(_pet1Id, _pet2Id) notInBlackList(_pet1Id) notInBlackList(_pet2Id) {
        require(allowBreed, "Breed is not allowed");
        uint256 fee1 = _getBreedPrice(pets[_pet1Id]);
        uint256 fee2 = _getBreedPrice(pets[_pet2Id]);
        uint256 breedMATAFee = fee1 + fee2;
        // require(NINOToken.balanceOf(msg.sender) >= breedNINOFee, "Insufficient NINO");
        // require(MATAToken.balanceOf(msg.sender) >= breedMATAFee, "Insufficient MATA");

        // uint256 allowanceNino = NINOToken.allowance(msg.sender, address(this));
        // require(allowanceNino >= breedNINOFee, "Check the token NiNo allowance");

        // uint256 allowanceMata = MATAToken.allowance(msg.sender, address(this));
        // require(allowanceMata >= breedMATAFee, "Check the token Mata allowance");

        NINOToken.safeTransferFrom(msg.sender, ninoReceiver, breedNINOFee);
        MATAToken.safeTransferFrom(msg.sender, address(0xdEaD), breedMATAFee);
        pets[_pet1Id].breedCount++;
        pets[_pet2Id].breedCount++;
        uint256 childGenes = 0 ; //Genes.mix(counter++ + privateRandom.rand(1_000_000), pets[_pet1Id].geneId, pets[_pet2Id].geneId);
        uint256 petId = _createPet(_pet1Id, _pet2Id, 2, childGenes); // generation is always = 2
        _safeMint(msg.sender, petId);
    }

    function putOnSale(uint256 _petId, uint256 _price) external whenNotPaused onlyPetOwner(_petId) notInBlackList(_petId) {
        require(_price >= minPriceSalePet, "Invalid price!");
        _putOnSale(_petId, _price);
    }

    function _putOnSale(uint256 _petId, uint256 _price) private {
        //
        Auction memory auction = auctions[_petId];
        if (_isOnAuction(auction)) {
            _deleteAuction(_petId);
        }
        //
        petsOnSale[_petId] = _price;
        emit PetListed(_petId, msg.sender, _price);
    }

    function cancelSale(uint256 _petId) external whenNotPaused nonReentrant onlyPetOwner(_petId) {
        require(petsOnSale[_petId] > 0, "This one is not on sale already!");
        _cancelSale(_petId);
    }

    function _cancelSale(uint256 _petId) private {
        petsOnSale[_petId] = 0;
        emit PetDelisted(_petId);
    }

    function _getBreedPrice(Pet memory _pet) private view returns (uint256) {
        if (_pet.generation == 1) {
            return 0;
        } else {
            return breedCosts[_pet.breedCount];
        }
    }

    function buyPet(uint256 _petId) external payable whenNotPaused nonReentrant notInBlackList(_petId) {
        uint256 price = petsOnSale[_petId];
        address buyer = msg.sender;
        address seller = ownerOf(_petId);

        require(price > 0, "This one is not for sale!");
        require(buyer != seller, "This one is yours already!");
        require(price == msg.value, "The amount is insufficient!");
        _makeTransaction(_petId, seller, buyer, price);

        emit PetBought(_petId, buyer, seller, price);
    }

    // function batchMint(uint8 generation, uint256[] memory listGenId) external onlyOperator {
    //     for (uint8 i = 0; i < listGenId.length; i++) {
    //         uint256 petId = _createPet(0, 0, generation, listGenId[i]);
    //         _safeMint(msg.sender, petId);
    //     }
    // }

    function batchMintToAddress(
        uint8 generation,
        address addTo,
        uint256[] memory listGenId
    ) external onlyOperator {
        for (uint8 i = 0; i < listGenId.length; i++) {
            uint256 petId = _createPet(0, 0, generation, listGenId[i]);
            _safeMint(addTo, petId);
        }
    }

    function burn(uint256 _petId) public whenNotPaused onlyPetOwner(_petId) {
        if (petsOnSale[_petId] > 0) {
            _cancelSale(_petId);
        }
        _burn(_petId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        if (petsOnSale[tokenId] > 0) {
            _cancelSale(tokenId);
        }
        //
        Auction memory auction = auctions[tokenId];
        if (_isOnAuction(auction)) {
            _deleteAuction(tokenId);
        }
        //
        super._transfer(from, to, tokenId);
    }

    function _createPet(
        uint256 matronId,
        uint256 sireId,
        uint8 generation,
        uint256 geneId
    ) private returns (uint256 _petId) {
        pets.push(Pet(generation, 0, uint32(block.timestamp), matronId, sireId, geneId));
        _petId = pets.length - 1;
        emit PetCreated(msg.sender, _petId, matronId, sireId, generation, geneId);
    }

    function _makeTransaction(
        uint256 _petId,
        address _seller,
        address _buyer,
        uint256 _price
    ) private {
        // if (isRecordVolumeTrade) {
        //     addressRecordVolume.setVolumeTrade(_buyer, _price);
        // }
        uint256 fee = calculateServiceFee(_price);
        _transfer(_seller, _buyer, _petId);

        (bool transferToSeller, ) = _seller.call{value: _price - fee}("");
        require(transferToSeller, "Make Transaction: transfer to seller error");

        (bool transferToTreasury, ) = tradingFeeReceiver.call{value: fee}("");
        require(transferToTreasury, "Make Transaction: transfer to treasury error");
    }

    function createAuction(
        uint256 _petId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    ) external whenNotPaused nonReentrant onlyPetOwner(_petId) notInBlackList(_petId) {
        require(_startingPrice >= minPriceSalePet && _startingPrice <= maxPriceAuction, "Staring price:Invalid!");
        require(_endingPrice >= minPriceSalePet && _endingPrice <= maxPriceAuction, "Ending price:Invalid!");
        require(_duration >= minDurationAuction && _duration <= maxDurationAuction, "Duration time invalid!");
        require(_startingPrice > _endingPrice, "Ending price must be lower than starting price");
        Auction memory auction = Auction(msg.sender, _startingPrice, _endingPrice, uint64(_duration), uint64(block.timestamp));
        _addAuction(_petId, auction, msg.sender);
    }

    function _addAuction(
        uint256 _petId,
        Auction memory _auction,
        address _seller
    ) private {
        require(_auction.duration >= 1 minutes, "Add auction: duration error");
        //
        if (petsOnSale[_petId] > 0) {
            _cancelSale(_petId);
        }
        //
        auctions[_petId] = _auction;
        emit AuctionCreated(_seller, _petId, _auction.startingPrice, uint256(_auction.endingPrice), uint256(_auction.startedAt), uint256(_auction.duration));
    }

    function cancelAuction(uint256 _petId) external whenNotPaused nonReentrant onlyPetOwner(_petId) notInBlackList(_petId) {
        Auction memory auction = auctions[_petId];
        require(_isOnAuction(auction), "This one is not on auction already!");
        _deleteAuction(_petId);
    }

    function _deleteAuction(uint256 _petId) private {
        delete auctions[_petId];
        emit AuctionCancelled(_petId);
    }

    function _isOnAuction(Auction memory _auction) private pure returns (bool) {
        return (_auction.startedAt > 0);
    }

    function bid(uint256 _petId) external payable whenNotPaused nonReentrant notInBlackList(_petId) {
        _bid(_petId, msg.value);
    }

    function _bid(uint256 _petId, uint256 _bidAmount) private {
        Auction memory _auction = auctions[_petId];
        require(_isOnAuction(_auction));
        uint256 price = _getCurrentPrice(_auction);
        require(_bidAmount >= price, "Not enough bnb");

        address seller = _auction.seller;
        _makeTransaction(_petId, seller, msg.sender, price);

        uint256 _bidExcess = _bidAmount - price;

        (bool bidExcessToBuyer, ) = msg.sender.call{value: _bidExcess}("");
        require(bidExcessToBuyer, "Bid: transfer bid excess to buyer error");

        emit AuctionBid(_petId, msg.sender, seller, price);
    }

    function getCurrentPrice(uint256 _petId) external view returns (uint256) {
        Auction memory _auction = auctions[_petId];
        require(_isOnAuction(_auction));
        return _getCurrentPrice(_auction);
    }

    function _getCurrentPrice(Auction memory _auction) internal view returns (uint256) {
        uint256 _secondsPassed = 0;
        if (block.timestamp > _auction.startedAt) {
            _secondsPassed = block.timestamp - _auction.startedAt;
        }

        return NinnekoLib._computeCurrentPrice(_auction.startingPrice, _auction.endingPrice, _auction.duration, _secondsPassed);
    }


    function setValidator(address _validator) external onlyOwner {
        validator = _validator;
    }

    function setRequestExpire(uint256 _timer) external onlyOwner {
        requestExpire = _timer;
    }

    function reborn(
        string memory _petId,
        string memory _geneId,
        uint256 _nonce,
        bytes memory _sign
    ) external whenNotPaused whenNotPausedReborn nonReentrant {
        // require(NINOToken.balanceOf(msg.sender) >= rebornFee, "Insufficient NINO");
        // require(MATAToken.balanceOf(msg.sender) >= mataRebornFee, "Insufficient MATA");

        // uint256 allowanceNino = NINOToken.allowance(msg.sender, address(this));
        // require(allowanceNino >= rebornFee, "Check the token NiNo allowance");

        // uint256 allowanceMata = MATAToken.allowance(msg.sender, address(this));
        // require(allowanceMata >= mataRebornFee, "Check the token Mata allowance");

        require(_nonce <= block.timestamp && block.timestamp <= _nonce + requestExpire, "Request expired");
        require(nonceUsed[msg.sender] < _nonce, "nonce used");
        require(NinnekoLib.validSign(msg.sender, _petId, _geneId, _nonce, _sign, validator), "Invalid sign");
        //
        uint256 petIdInt = NinnekoLib.stringToUint(_petId);
        //
        require(ownerOf(petIdInt) == msg.sender, "Not the owner of this one");
        require(!blackList[petIdInt], "blacklisted pet");
        require(petReborn[petIdInt] < MAX_NUMBER_REBORN, "Reborn: exceed the allowed number of times");
        //
        NINOToken.safeTransferFrom(msg.sender, ninoReceiver, rebornFee);
        MATAToken.safeTransferFrom(msg.sender, address(0xdEaD), mataRebornFee);
        //
        petReborn[petIdInt] = petReborn[petIdInt] + 1;
        nonceUsed[msg.sender] = _nonce;
        uint256 geneIdInt = NinnekoLib.stringToUint(_geneId);
        pets[petIdInt].geneId = geneIdInt;

        emit Reborn(petIdInt, geneIdInt);
    }

    function fuse(uint256 _pet1Id, uint256 _pet2Id) external whenNotPaused nonReentrant onlyPetOwner(_pet1Id) onlyPetOwner(_pet2Id) notInBlackList(_pet1Id) notInBlackList(_pet2Id) {

        // require(NINOToken.balanceOf(msg.sender) >= ninoFuseFee, "Insufficient NINO");
        // require(MATAToken.balanceOf(msg.sender) >= mataFuseFee, "Insufficient MATA");

        // uint256 allowanceNino = NINOToken.allowance(msg.sender, address(this));
        // require(allowanceNino >= ninoFuseFee, "Check the token NiNo allowance");

        // uint256 allowanceMata = MATAToken.allowance(msg.sender, address(this));
        // require(allowanceMata >= mataFuseFee, "Check the token Mata allowance");

        burn(_pet1Id);
        burn(_pet2Id);
        NINOToken.safeTransferFrom(msg.sender, ninoReceiver, ninoFuseFee);
        MATAToken.safeTransferFrom(msg.sender, address(0xdEaD), mataFuseFee);

        uint256 petId = _createPet(0, 0, 2, 0); // generation is always = 2
        _safeMint(msg.sender, petId);
        emit Fuse(_pet1Id,_pet2Id ,petId);
    }

    function upgradePet(uint256 _petId, uint256 _petMaterial) external whenNotPaused nonReentrant onlyPetOwner(_petId) onlyPetOwner(_petMaterial) notInBlackList(_petId) notInBlackList(_petMaterial) {
        burn(_petMaterial);
        MATAToken.safeTransferFrom(msg.sender, address(0xdEaD), mataUpgradeFee);
        emit PetUpgrade(_petId,_petMaterial);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

library NinnekoLib {
    using ECDSA for bytes32;

    function _computeCurrentPrice(
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _secondsPassed
    ) public pure returns (uint256) {
        if (_secondsPassed >= _duration) {
            return _endingPrice;
        } else {
            int256 _totalPriceChange = int256(_endingPrice) - int256(_startingPrice);
            int256 _currentPriceChange = (_totalPriceChange * int256(_secondsPassed)) / int256(_duration);
            int256 _currentPrice = int256(_startingPrice) + _currentPriceChange;

            return uint256(_currentPrice);
        }
    }

    function stringToUint(string memory s) public pure returns (uint256 result) {
        bytes memory b = bytes(s);
        uint256 i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }

    function validSign(
        address user,
        string memory petId,
        string memory geneId,
        uint256 nonce,
        bytes memory sign,
        address validator
    ) public pure returns (bool) {
        bytes32 _hash = keccak256(abi.encodePacked(user, petId, geneId, nonce));
        _hash = _hash.toEthSignedMessageHash();
        address _signer = _hash.recover(sign);
        return _signer == validator;
    }
}