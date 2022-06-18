/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

// SPDX-License-Identifier: GPL-3.0

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.3.2 (utils/introspection/IERC165.sol)

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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts v4.3.2 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


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

// File: contracts/IRepido_NFT.sol


pragma solidity >=0.8.0 < 0.9.0;


interface IRepidoNFT is IERC721{
    
    function setAvailableNFTs(uint256 _available) external;
    function setPrice(uint256 _price) external;
    function setBaseURI(string memory _baseURI) external;
    function setMintable(bool _mintable) external;
    function setBUSDAddress(address _newAddress) external;
    function setPresale(bool _presale) external;
    function setRewards(uint256 _value) external;
    function addToWhitelist(address[] memory users) external;
    function setDistributor(address _distributor) external;

    function getAvailable() external view returns(uint256);
    function getPrice() external view returns(uint256);
    function isMintable() external view returns(bool);
    function getBaseURI() external view returns(string memory);
    function getNFTRewards(uint256 _NFTID) external view returns(uint256);
    function getTotalSupply() external view returns(uint256);
    function isPresale() external view returns(bool);
    function isAddressInWhitelist(address _address) external view returns(bool);

    function redeemRewards(uint256[] memory ownedNFTs) external;
    function repidoMint(address to,  uint256 _amount) external payable;
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: contracts/ProjectToken.sol



pragma solidity >=0.8.0 < 0.9.0;



interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

interface RepidoDistributor{
    
    function allocateMoney(uint256 _money, uint256 number1, uint256 number2, address _projectWallet, address _sender) external returns(bool);

}

contract ProjectToken is ERC20, Ownable {

    // address of the distributor responsible for this project
    RepidoDistributor private DistAddress;

    // address of the project wallet
    address private projectWallet;

    // BUSD token address
    IBEP20 public busdAddress;

    // boolean that determines if its currently possible to mint tokens
    bool private mintable = false;

    // boolean that determines if the project state (ongoing/ended)
    bool private projectEnded = false;

    // boolean that determines if a presale is currently going on
    bool private presale = false;

    // price of one token
    uint256 private price;

    // amount of money collected by the project from people buying tokens
    uint256 private totalCollected = 0;

    // amount of money earned by the project
    uint256 private projectEarned = 0;

    // numbers used to calculate the fee share of the company
    uint256 public feeNumber1;
    uint256 public feeNumber2;

    // amount of currently available tokens
    uint256 private available;

    // mapping from number to NFT contract
    mapping(uint256 => IRepidoNFT) private NFTContract;

    // mapping from number of NFT contract to a mapping from NFT ID to the amount they have already spend
    mapping(uint256 => mapping(uint256 => uint256)) NFTBalance;

    // mapping from NFT contract to how much it can spend
    mapping(uint256 => uint256) NFTSpendingLimit;

    // boolean that determines if the buyBack function can be used
    bool buyBackActive;

    constructor(string memory _name, string memory _symbol, uint256 _price, uint256 _feeNumber1, uint256 _feeNumber2, address Henry, address Robert, address Grant, address Charles, address Donald) ERC20(_name, _symbol){ 

        price = _price;
        feeNumber1 = _feeNumber1;
        feeNumber2 = _feeNumber2;

        NFTContract[1] = IRepidoNFT(payable(Henry));        
        NFTSpendingLimit[1] = 500000000000000000000;
        NFTContract[2] = IRepidoNFT(payable(Robert));
        NFTSpendingLimit[2] = 1000000000000000000000;
        NFTContract[3] = IRepidoNFT(payable(Grant));
        NFTSpendingLimit[3] = 2000000000000000000000;
        NFTContract[4] = IRepidoNFT(payable(Charles));
        NFTSpendingLimit[4] = 4000000000000000000000;
        NFTContract[5] = IRepidoNFT(payable(Donald));
        NFTSpendingLimit[5] = 8000000000000000000000;
    }

    // SETTERS
    // set the distributor contract
    function setDistAddress(address _newAddress) external onlyOwner{
        DistAddress = RepidoDistributor(payable(_newAddress));
    }

    // set the wallet of the project
    function setProjectWallet(address _projectWallet) external onlyOwner{
        projectWallet = _projectWallet;
    }

    // set if minting is allowed or not
    function setMintable(bool _mintable) external onlyOwner{
        mintable = _mintable;
    }

    // set if presale is active or no
    function setPresale(bool _presale) external onlyOwner{
        presale = _presale;
    }

    // set the BUSD address
    function setBUSDAddress(address _newAddress) public onlyOwner{
        busdAddress = IBEP20(payable(_newAddress));
    }

    // end the project
    function setProjectEnded(bool _projectEnded) external onlyOwner{
        projectEnded = _projectEnded;

    }

    // set the price of a project token in BUSD
    function setPrice(uint256 _price) external onlyOwner{
        price = _price;
    }

    // set how much the project earned after the sale of the buildings
    function setProjectEarned(uint256 _projectEarned) external onlyOwner{
        projectEarned = _projectEarned;
    }

    // set the amount of tokens that can be minted
    function setAvailableTokens(uint256 _available) external onlyOwner{
        require(_available >= totalSupply(), "setAvailableTokens: Entered value lower than already minted tokens.");

        available = _available; 
    }

    // activate or deactivate the buyBack function
    function setBuyBackActive(bool _buyBackActive) external onlyOwner{
        require(projectEnded, "setBuyBackActive: Not possible to activate the buyBack function if the project is ongoing");
        buyBackActive = _buyBackActive;
    }

    // GETTERS
    // get amount of available tokens
    function getAvailableTokens() external view returns(uint256){
        return available;
    }

    // get the distributor contract address
    function getDistAddress() public view returns(address){
        return address(DistAddress);
    }

    // get the project wallet address
    function getProjectWallet() external view returns(address){
        return projectWallet;
    }

    // find out if its possible to mint tokens
    function isMintable() external view returns(bool){
        return mintable;
    }

    // find out if a presale is active
    function isPresale() public view returns(bool){
        return presale;
    }

    // get the BUSD contract address
    function getBUSDAddress() public view returns(IBEP20) {
        return busdAddress;
    }

    // find out if the project ended 
    function isProjectEnded() public view returns(bool){
        return projectEnded;
    }

    // get the price of a project token
    function getPrice() external view returns(uint256){
        return price;
    }

    // get how much the project earned at its end
    function getProjectEarned() external view returns(uint256){
        return projectEarned;
    }

    // get the amount of BUSD spend in the presale using a specific NFT
    function getNFTBalance(uint256 _NFTTier, uint256 _NFTID) external view returns(uint256){
        return NFTBalance[_NFTTier][_NFTID];
    }

    // get the spending limit of an NFT tier
    function getNFTSpendingLimit(uint256 _NFTTier) external view returns(uint256){
        return NFTSpendingLimit[_NFTTier];
    }

    // get the total amount of BUSD earned by minting
    function getTotalCollected() external view returns(uint256){
        return totalCollected;
    }

    // find out if the buyBack function is active
    function isBuyBackActive() external view returns(bool){
        return buyBackActive;
    }

    /*
    * Function to mint tokens.
    *
    * inputs:
    *   _money - amount of BUSD you are want to trade for project tokens
    *
    * The function first checks if the user has enough BUSD in his wallet, then it checks if the amount
    * of project tokens the user would get for that much BUSD is within the range of available project tokens.
    * If those checks pass and minting is currently possible the amount of BUSD the user selected will be 
    * transfered to the project contract, the correct amount of project tokens will be minted to the user
    * and the amount of collected BUSD by the contract gets incremented.
    */
    function mintToken(uint256 _money) external {
        require(busdAddress.balanceOf(msg.sender) >= _money, "mintToken: Not enough BUSD in wallet!");
        require(totalSupply() + ((_money * 1 ether) /price) <= available, "mintToken: The amount of tokens you want to buy exceeds the maximum amount available right now!");

        require(mintable, "mintToken: The minting of tokens is currently disabled!");

        bool success = busdAddress.transferFrom(msg.sender, address(this), _money);
        require(success, "mintToken: The money transfer was unsuccessful!");
        _mint(msg.sender, ((_money * 1 ether) /price));
        totalCollected += _money;
    }

    /*
    * Function to mint tokens during the presale.
    *
    * inputs:
    *   _money - amount of BUSD you are want to trade for project tokens
    *   _NFTID - the ID of the NFT you want to use to join the presale
    *   _NFTTier - the tier of the NFT you want to use to join the presale
    *
    * The function checks if the users BUSD balance is high enough, then it checks if the amount
    * of project tokens the user would get for that much BUSD is within the range of available project tokens.
    * It then checks if the presale is ongoing, if the NFT selected belongs to the user and if the user
    * is within the spending limit of the NFT he selected.
    * If all those checks pass the selected amount of BUSD is added to the NFTBalance mapping. Then
    * the selected amount of BUSD is transfered to the project contract, the correct amount of project 
    * tokens will be minted to the user and the amount of collected BUSD by the contract gets incremented.
    */
    function mintTokenPresale(uint256 _money, uint256 _NFTID, uint256 _NFTTier)  external {
        require(busdAddress.balanceOf(msg.sender) >= _money, "mintTokenPresale: Not enough BUSD in wallet!");
        require(totalSupply() + ((_money * 1 ether) /price) <= available, "mintTokenPresale: The amount of tokens you want to buy exceeds the maximum amount available right now!");
        require(presale, "mintTokenPresale: Presale not going on right now!");
        require(msg.sender == NFTContract[_NFTTier].ownerOf(_NFTID), "mintTokenPresale: Not the owner of the NFT");
        require(NFTBalance[_NFTTier][_NFTID] + _money <= NFTSpendingLimit[_NFTTier], "mintTokenPresale: Exceeded NFT spending limit!");

        NFTBalance[_NFTTier][_NFTID] += _money;
        bool success = busdAddress.transferFrom(msg.sender, address(this), _money);
        require(success, "mintTokenPresale: The money transfer was unsuccessful!");
        _mint(msg.sender, ((_money * 1 ether) /price));
        totalCollected += _money;
    }

    /*
    * Function used to sell owned tokens back after project ended.
    *
    * The function first checks if the buyBack function is active, then it checks if the user owns project tokens.
    * If both checks pass the token balance of the user is temporarily saved, his tokens are send to 
    * the project wallet and the correct amount of BUSD is send to the user.
    */
    function buyBack() external {
        require(buyBackActive, "buyBack: The buyBack function isn't activated yet!");
        require(balanceOf(msg.sender) > 0, "buyBack: You don't own any project tokens!");

        uint256 userBalance = balanceOf(msg.sender);
        bool transferSuccess = transfer(projectWallet, userBalance);
        require(transferSuccess, "buyBack: Failed to send back token!");

        bool sendBUSDSuccess = busdAddress.transferFrom(projectWallet, msg.sender, (userBalance*projectEarned)/totalCollected);
        require(sendBUSDSuccess, "buyBack: Failed to send BUSD!");

    }

    /*
    * Function thats called from time to time to send the BUSD from the contract to the distributor.
    */
    function distribute() external onlyOwner{
        uint256 contractBalance = busdAddress.balanceOf(address(this));
        busdAddress.approve(address(DistAddress), contractBalance);
        bool success = DistAddress.allocateMoney(contractBalance, feeNumber1, feeNumber2, projectWallet, address(this));
        require(success, "distribute: The money transfer was unsuccessful!");
    }

}