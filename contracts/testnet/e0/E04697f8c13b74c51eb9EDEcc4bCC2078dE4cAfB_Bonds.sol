/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-23
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: contracts/Bonds.sol

/* SPDX-License-Identifier: UNLICENSED */

pragma solidity ^0.8.7;



contract Bonds is Ownable {
  IERC20 public PROTOCOL_TOKEN;
  IERC20 public BOND_TOKEN;

  address public TREASURY;

  bool public isPaused = false;

  mapping(address => bool) public isBlacklisted;

  uint256 public tokenPrice;

  struct Term {
    uint256 duration;
    uint256 rate;
    uint256 availability;
    uint256 maximumPurchase;
  }

  Term[] public terms;
  uint16 public termsLength = 0;

  struct Bond {
    uint256 initialValue;
    uint256 value;
    uint256 duration;
    uint256 creationTimestamp;
  }

  mapping(address => Bond) public bonds;

  event BondCreated(address indexed from, uint256 releaseTime, uint256 initialValue, uint256 value);
  event BondClaimed(address indexed from, uint256 value);

  constructor(address protocol_token, address bond_token, address treasury, uint256 tokenPrice_, uint256 duration, uint256 rate, uint256 availability, uint256 maximumPurchase) {
    PROTOCOL_TOKEN = IERC20(protocol_token);
    BOND_TOKEN = IERC20(bond_token);
    TREASURY = treasury;
    tokenPrice = tokenPrice_;
    terms.push(Term({
      duration: duration,
      rate: rate,
      availability: availability,
      maximumPurchase: maximumPurchase
    }));
    termsLength++;
  }

  function getTerms() view public returns (Term[] memory) {
      return terms;
  }

  function bond(uint16 termId, uint256 value) public {
    require(!isPaused, "BOND: Bonding is not currently allowed");
    require(!isBlacklisted[_msgSender()], "BOND: You are blacklisted");
    require(termId < termsLength, "BOND: Term doesn't exist");
    Term memory term = terms[termId];
    require(value <= term.maximumPurchase, "BOND: Above maximum bond value");
    uint256 bondValue = value * tokenPrice / 1e18;
    require(BOND_TOKEN.allowance(_msgSender(), address(this)) >= bondValue, "BOND: Insufficient allowance");
    require(BOND_TOKEN.balanceOf(_msgSender()) >= bondValue, "BOND: Insufficient balance");
    require(bonds[_msgSender()].value == 0, "BOND: You have a running bond");

    BOND_TOKEN.transferFrom(_msgSender(), TREASURY, bondValue);
    uint256 initialValue = value;
    value += value * term.rate / 10000;
    bonds[_msgSender()] = Bond({
      initialValue: initialValue,
      value: value,
      duration: term.duration,
      creationTimestamp: block.timestamp
    });
    terms[termId].availability -= value;
    
    emit BondCreated(_msgSender(), block.timestamp + term.duration, initialValue, value);
  }

  function claimBond() public {
    require(!isPaused, "CLAIM: Claiming is not currently allowed");
    require(!isBlacklisted[_msgSender()], "BOND: You are blacklisted");
    Bond memory bond_ = bonds[_msgSender()];
    require(bond_.value != 0, "CLAIM: You are not bonding");
    require(block.timestamp - bond_.creationTimestamp > bond_.duration, "CLAIM: Bond is still running");

    bonds[_msgSender()] = Bond({
      initialValue: 0,
      value: 0,
      duration: 0,
      creationTimestamp: 0
    });
    PROTOCOL_TOKEN.transferFrom(TREASURY, _msgSender(), bond_.value);

    emit BondClaimed(_msgSender(), bond_.value);
  }

  function setTokenPrice(uint256 tokenPrice_) public onlyOwner {
    tokenPrice = tokenPrice_;
  }

  function addTerm(uint256 duration, uint256 rate, uint256 availability, uint256 maximumPurchase) public onlyOwner {
    terms.push(Term({
      duration: duration,
      rate: rate,
      availability: availability,
      maximumPurchase: maximumPurchase
    }));
    termsLength++;
  }

  function removeTerm(uint16 index) public onlyOwner {
    Term memory temp = terms[termsLength - 1];
    terms[index] = temp;
    termsLength--;
  }

  function setBlacklisted(address user, bool value) public onlyOwner {
    isBlacklisted[user] = value;
  }

  function setIsPaused(bool value) public onlyOwner {
    isPaused = value;
  }
}