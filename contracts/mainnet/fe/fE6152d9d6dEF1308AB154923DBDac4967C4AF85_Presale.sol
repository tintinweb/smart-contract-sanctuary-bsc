// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IChest is IERC20 {
    function giveChest(address to, uint amount) external;
    function burnChest(uint256 amount) external;
}

interface IBombHero {
    function mint(address player) external returns (uint256);
}

contract Presale is Pausable, Ownable {

  uint constant public INITIAL_PRICE = 10_000_000_000_000_000_000; // 10 tokens

  uint public currentPrice;
  mapping(address => bool) private _buyers;
  mapping(address => bool) private _whitelist;
  bool public whitelistRequired;
  bool private _bombHeroAddressAlreadySet;
  bool private _chestAddressAlreadySet;

  error chestAddressAlreadySet();
  error bombHeroAddressAlreadySet();

  IChest public chest;
  IERC20 public bombHeroCoin;
  IBombHero public bombHero;

  event ChestBought(address indexed buyer);
  event BoughtChestRedeemed(address indexed receiver);
  event HeroMinted(address indexed receiver, uint256 amount, uint256[] tokenIds);
  event Whitelisted(address indexed _address, bool _status);
  event EnableWhitelist();
  event DisableWhitelist();

  modifier onlyWhitelisted {
    require(!whitelistRequired || _whitelist[msg.sender], "Sender is not whitelisted");
    _;
  }

  constructor(address _bombHeroCoin) {
    whitelistRequired = true;
    currentPrice = INITIAL_PRICE;
    bombHeroCoin = IERC20(_bombHeroCoin);
  }

  function setChestAddress(address _chest) public onlyOwner {
    if (_chestAddressAlreadySet) revert chestAddressAlreadySet();
    chest = IChest(_chest);
    _chestAddressAlreadySet = true;
  }

  function setBombHeroAddress(address _bombHeroNFT) public onlyOwner {
    if (_bombHeroAddressAlreadySet) revert bombHeroAddressAlreadySet();
    bombHero = IBombHero(_bombHeroNFT);
    _bombHeroAddressAlreadySet = true;
  }

  /**
   * @notice 
   * @dev Buy chest with bomb hero coins
   */
  function buyChest(uint256 amount) public onlyWhitelisted whenNotPaused {
    bombHeroCoin.transferFrom(msg.sender, address(this), currentPrice*amount);    
    _buyers[msg.sender] = true;
    chest.giveChest(msg.sender, amount);
    emit ChestBought(msg.sender);
  }

  function openChest(uint256 amount) public whenNotPaused {
    chest.transferFrom(msg.sender, address(this), amount);
    chest.burnChest(amount);
    uint256[] memory ids = new uint256[](amount);
    for (uint256 i = 0; i < amount; i++) {
      ids[i] = bombHero.mint(msg.sender);
    }
    emit HeroMinted(msg.sender, amount, ids);
  }
  /**
   * @dev Transfer all BNB held by the contract to the owner.
   */
  function setPriceInWei(uint256 _price) external onlyOwner {
      currentPrice = _price;
  }

  function withdrawlBNB() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }

  /**
   * @dev Transfer all BEP20 of tokenContract held by contract to the owner.
   */
  function withdrawlBEP20(address _tokenContract) external onlyOwner {
    require(_tokenContract != address(0), "Invalid address");
    IERC20 token = IERC20(_tokenContract);
    uint256 balance = token.balanceOf(address(this));
    token.transfer(payable(owner()), balance);
  }

  /**
   * @dev Set whitelist address status to true or false in bulk
   */
  function setWhitelist(address[] calldata _addresses, bool _status) external onlyOwner {
    for (uint i = 0; i < _addresses.length; i++) {
      _whitelist[_addresses[i]] = _status;
      emit Whitelisted(_addresses[i], _status);
    }
  }

  /**
   * @dev Enable or disable whitelisting filter
   */
  function setWhitelistRequired(bool _isRequired) external onlyOwner {
    whitelistRequired = _isRequired;
    if (_isRequired) {
      emit EnableWhitelist();
    } else {
      emit DisableWhitelist();
    }
  }
  
  /**
   * @notice Check address whitelist status
   */
  function isWhitelisted() public view returns (bool) {
    return _whitelist[msg.sender];
  }

  /**
  *@dev pauses the contract
  */
  function pause() public onlyOwner {
        _pause();
  }

  /**
  *@dev unpauses the contract
  */
  function unpause() public onlyOwner {
      _unpause();
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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