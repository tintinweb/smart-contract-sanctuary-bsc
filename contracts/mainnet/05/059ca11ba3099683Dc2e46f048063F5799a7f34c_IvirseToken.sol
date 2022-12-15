// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./AutomaticOwnershipManagement.sol";
import "./interfaces/IvirseTokenInterface.sol";

contract IvirseToken is
  IvirseTokenInterface,
  ERC20,
  AutomaticOwnershipManagement
{
  /**
   *@dev Storage
   */
  uint256 public mintCount;

  mapping(uint256 => MintData) mints;

  mapping(uint256 => mapping(address => bool)) public mintVotes;
  uint256 private immutable _maxSupply;

  /**
   *@dev Constructor
   */
  constructor(address[] memory initialOwners_)
    ERC20("IVIE", "IVI")
    AutomaticOwnershipManagement(initialOwners_)
  {
    uint256 fractions = 10**uint256(18);
    _maxSupply = 888888888 * fractions;
  }

  /**
   *@dev require total vote for pause or unpause > 50% minter.
   */
  modifier mintEnoughVotes(uint256 id) {
    require(
      _getMintVoteCount(id) >= _getRequired(),
      "IvirseToken Contract: Not enough votes!"
    );
    _;
  }
  /**
   *@dev require sender accept for mint request.
   */
  modifier mintAccepted(uint256 id) {
    address sender = _msgSender();
    require(mintVotes[id][sender], "IvirseToken Contract: Rejected!");
    _;
  }
  /**
   *@dev require sender does not accept for mint request.
   */
  modifier mintRejected(uint256 id) {
    address sender = _msgSender();
    require(!mintVotes[id][sender], "IvirseToken Contract: Accepted!");
    _;
  }
  /**
   *@dev require mint request actived.
   */
  modifier notMint(uint256 id) {
    require(!mints[id].used, "IvirseToken Contract: Minted!");
    _;
  }

  /**
   *@dev minter create mint request for multisign.
   */
  function createMintRequest(address to, uint256 amount)
    public
    override
    onlyOwner
  {
    address sender = _msgSender();
    MintData memory data = MintData(
      mintCount,
      block.timestamp,
      sender,
      to,
      amount,
      false
    );
    mints[mintCount] = data;
    mintCount++;
    emit NewMintRequest(sender, data.id);
  }

  /**
   *@dev minter accept mint request.
   */
  function acceptMint(uint256 id)
    public
    override
    onlyOwner
    notMint(id)
    mintRejected(id)
  {
    address sender = _msgSender();
    mintVotes[id][sender] = true;
    emit AcceptMint(sender, id);
  }

  /**
   *@dev minter reject mint request.
   */
  function rejectMint(uint256 id)
    public
    override
    onlyOwner
    notMint(id)
    mintAccepted(id)
  {
    address sender = _msgSender();
    mintVotes[id][sender] = false;
    emit RejectMint(sender, id);
  }

  /**
   *@dev minter active mint request when enough consensus.
   */
  function mintConsensus(uint256 id)
    public
    override
    onlyOwner
    notMint(id)
    mintEnoughVotes(id)
  {
    MintData storage transaction = mints[id];
    require(
      totalSupply() + transaction.amount <= _maxSupply,
      "IvirseToken Contract: mint amount exceeds max supply"
    );
    transaction.used = true;
    _mint(transaction.to, transaction.amount);
    emit MintConsensus(_msgSender(), id);
  }

  /**
   *@dev get total accept of mint request.
   */
  function getMintVoteCount(uint256 id) public view override returns (uint256) {
    return _getMintVoteCount(id);
  }

  /**
   *@dev get vote of mint request.
   */
  function getMintVote(address minter, uint256 id)
    public
    view
    override
    returns (bool)
  {
    return mintVotes[id][minter];
  }

  /**
   *@dev get all mint request.
   */
  function getMintRequests()
    public
    view
    override
    returns (MintData[] memory results)
  {
    results = new MintData[](mintCount);
    for (uint256 i = 0; i < mintCount; i++) {
      results[i] = mints[i];
    }
  }

  /**
   *@dev Private function
   */

  function _getMintVoteCount(uint256 _id) private view returns (uint256 count) {
    for (uint256 index = 0; index < owners.length; index++) {
      address minter = owners[index];
      bool vote = mintVotes[_id][minter];
      if (vote && isOwner[minter] == Status.ACTIVE) {
        count++;
      }
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @author tuan.dq.
 * @title Interface for MultiSig contract.
 */
interface IvirseTokenInterface {
  /**
   *@dev Structs
   */
  struct MintData {
    uint256 id;
    uint256 createdAt;
    address requestBy;
    address to;
    uint256 amount;
    bool used;
  }
  /**
   *@dev Events
   */

  event AcceptMint(address indexed minter, uint256 id);
  event RejectMint(address indexed minter, uint256 id);
  event MintConsensus(address indexed minter, uint256 id);
  event NewMintRequest(address indexed minter, uint256 id);

  /**
   *@dev Functions
   */

  function createMintRequest(address to, uint256 amount) external;

  function acceptMint(uint256 id) external;

  function rejectMint(uint256 id) external;

  function mintConsensus(uint256 id) external;

  function getMintVoteCount(uint256 id) external view returns (uint256);

  function getMintVote(address minter, uint256 id) external view returns (bool);

  function getMintRequests() external view returns (MintData[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @author tuan.dq.
 * @title Interface for MultiSig contract.
 */
interface IAutomaticOwnershipManagement {
  /**
   *@dev Enums
   */

  enum Status {
    DEFAULT,
    ACTIVE,
    INACTIVE
  }

  /**
   *@dev Events
   */

  event NewAccount(address indexed account);
  event GrantOwnership(address indexed account);
  event RevokeOwnership(address indexed owner);
  event AcceptGrant(address indexed from, address indexed to);
  event RejectGrant(address indexed from, address indexed to);
  event RemoveAccount(address indexed from, address indexed to);

  /**
   *@dev Functions
   */

  function requestNewOwner(address account) external;

  function acceptAccount(address account) external;

  function rejectAccount(address account) external;

  function grantOwnership(address account) external;

  function revokeOwnership(address newOwner) external;

  function renounceOwnership() external;

  function removeAccount(address account) external;

  function getRequired() external view returns (uint256);

  function getVote(address account, address owner) external view returns (bool);

  function getNumberVote(address account) external view returns (uint256);

  function getAllOwner() external view returns (address[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IAutomaticOwnershipManagement.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @author tuan.dq.
 * @title Allow automatic management of administrative rights.
 */
contract AutomaticOwnershipManagement is
  IAutomaticOwnershipManagement,
  Context
{
  /**
   *  Constants
   */
  uint256 public constant MAX_OWNER_COUNT = 50;

  /**
   *  Storage
   */
  address[] public owners;
  mapping(address => bool) public isExist;
  mapping(address => Status) public isOwner;
  mapping(address => mapping(address => bool)) public votes;

  /**
   *  Modifiers
   */

  modifier onlyOwner() {
    require(
      isOwner[_msgSender()] == Status.ACTIVE,
      "MultiSig Contract: Sender is not owner!"
    );
    _;
  }
  modifier doesNotHaveOwnership(address owner) {
    require(
      isOwner[owner] == Status.DEFAULT || isOwner[owner] == Status.INACTIVE,
      "MultiSig Contract: Already owner!"
    );
    _;
  }

  modifier hasOwnership(address owner) {
    require(isOwner[owner] == Status.ACTIVE, "MultiSig Contract: Not owner!");
    _;
  }

  modifier validMaxOwner() {
    require(
      owners.length + 1 <= MAX_OWNER_COUNT,
      "MultiSig Contract: Limit reached!"
    );
    _;
  }

  modifier accountDoesNotExist(address account) {
    require(!isExist[account], "MultiSig Contract: Account existed!");
    _;
  }

  modifier accountExist(address account) {
    require(isExist[account], "MultiSig Contract: Not exist!");
    _;
  }

  modifier accepted(address account) {
    require(votes[account][_msgSender()], "MultiSig Contract: Not accept!");
    _;
  }

  modifier notAccept(address account) {
    require(!votes[account][_msgSender()], "MultiSig Contract: Accepted!");
    _;
  }

  constructor(address[] memory initialOwners_) {
    for (uint256 index = 0; index < initialOwners_.length; index++) {
      address account = initialOwners_[index];
      owners.push(account);
      isOwner[account] = Status.ACTIVE;
      isExist[account] = true;
    }
  }

  /**
   *  Public functions
   */

  function requestNewOwner(address account)
    public
    override
    onlyOwner
    accountDoesNotExist(account)
    validMaxOwner
  {
    _requestNewOwner(account);
  }

  function acceptAccount(address account)
    public
    override
    accountExist(account)
    notAccept(account)
    onlyOwner
  {
    _acceptAccount(account);
  }

  function rejectAccount(address account)
    public
    override
    accountExist(account)
    accepted(account)
    onlyOwner
  {
    _rejectAccount(account);
  }

  function grantOwnership(address account)
    public
    override
    onlyOwner
    doesNotHaveOwnership(account)
    accountExist(account)
  {
    require(
      _getNumberVote(account) >= _getRequired(),
      "MultiSig Contract: Not enough votes!"
    );
    _grantOwnership(account);
  }

  function revokeOwnership(address owner)
    public
    override
    onlyOwner
    hasOwnership(owner)
  {
    require(
      _getNumberVote(owner) >= _getRequired() && owners.length > 2,
      "MultiSig Contract: Not enough votes!"
    );
    _revokeOwnership(owner);
  }

  function renounceOwnership() public override onlyOwner {
    require(owners.length > 1, "MultiSig Contract: Last administrator!");
    _revokeOwnership(_msgSender());
  }

  function removeAccount(address account)
    public
    override
    onlyOwner
    doesNotHaveOwnership(account)
  {
    _removeAccount(account);
  }

  /**
   *  View functions
   */
  function getRequired() public view override returns (uint256) {
    return _getRequired();
  }

  function getVote(address account, address owner)
    public
    view
    override
    returns (bool)
  {
    return votes[account][owner];
  }

  function getNumberVote(address account)
    public
    view
    override
    returns (uint256)
  {
    return _getNumberVote(account);
  }

  function getAllOwner() public view override returns (address[] memory) {
    return owners;
  }

  /**
   *  Private functions
   */

  function _addForce(address _newOwner) private {
    owners.push(_newOwner);
    isOwner[_newOwner] = Status.ACTIVE;
    isExist[_newOwner] = true;
  }

  function _requestNewOwner(address _account) private {
    owners.push(_account);
    isExist[_account] = true;
    emit NewAccount(_account);
  }

  function _acceptAccount(address _account) private {
    address sender = _msgSender();
    votes[_account][sender] = true;
    emit AcceptGrant(sender, _account);
  }

  function _rejectAccount(address _account) private {
    address sender = _msgSender();
    votes[_account][sender] = false;
    emit RejectGrant(sender, _account);
  }

  function _grantOwnership(address _newOwner) private {
    isOwner[_newOwner] = Status.ACTIVE;
    _resetVotes(_newOwner);
    emit GrantOwnership(_newOwner);
  }

  function _revokeOwnership(address _owner) private {
    isOwner[_owner] = Status.INACTIVE;
    _resetVotes(_owner);
    emit RevokeOwnership(_owner);
  }

  function _removeAccount(address _account) private {
    require(
      _getNumberVote(_account) == 0,
      "MultiSig Contract: Have more than one vote!"
    );
    uint256 numOfOwner = owners.length;
    for (uint256 index = 0; index < numOfOwner; index++) {
      if (owners[index] == _account) {
        owners[index] = owners[numOfOwner - 1];
        owners.pop();
        break;
      }
    }
    isOwner[_account] = Status.DEFAULT;
    isExist[_account] = false;
    emit RemoveAccount(_msgSender(), _account);
  }

  function _resetVotes(address _account) private {
    for (uint256 index = 0; index < owners.length; index++) {
      votes[_account][owners[index]] = false;
    }
  }

  function _getRequired() internal view returns (uint256) {
    uint256 numOwner = 0;

    for (uint256 index = 0; index < owners.length; index++) {
      address owner = owners[index];
      if (isOwner[owner] == Status.ACTIVE) {
        numOwner++;
      }
    }

    if (numOwner <= 2) {
      return numOwner;
    } else {
      return numOwner / 2 + 1;
    }
  }

  function _getNumberVote(address _account)
    internal
    view
    returns (uint256 count)
  {
    for (uint256 index = 0; index < owners.length; index++) {
      address owner = owners[index];
      bool vote = votes[_account][owner];
      if (vote && isOwner[owner] == Status.ACTIVE) {
        count++;
      }
    }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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