// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ITokenarium {

  function balanceOf(address account) external view returns (uint256);

  function transfer(address to, uint256 amount) external returns (bool);

}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
 * behavior.
 */
contract TokenariumPrivateSale is Ownable {

  // constrains
  uint256 constant cap = 2 ether;
  uint256 constant min = 1 ether;
  uint256 constant max = 2 ether;

  // The token being sold
  ITokenarium public token;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per wei
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;

  mapping(address => uint256) public balances;

  mapping(address => bool) public claimed;

  // presale state
  uint8 public state = 0;

  event Started();

  event Finalized();

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value
  );

  /**
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  constructor(address _wallet, address _token)
  {
    require(_wallet != address(0));
    require(_token != address(0));
    wallet = _wallet;
    token = ITokenarium(_token);
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  receive() external payable {
    buyTokens(msg.sender);
  }

  function rescueBNB() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) public payable {
    require(_beneficiary != address(0));
    require(msg.value != 0);
    require(state == 1, "Sale is not active");
    require(weiRaised < cap, "Sale has ended");
    require(balances[_beneficiary] + msg.value >= min, "Invalid investment amount");
    require(balances[_beneficiary] <= max, "You have invested max value");

    uint256 weiAmount = msg.value;

    if (weiAmount > max - balances[_beneficiary]) {
      weiAmount = max - balances[_beneficiary];
    }

    if (weiAmount > cap - weiRaised) {
      weiAmount = cap - weiRaised;
    }

    // update state
    weiRaised += weiAmount;
    balances[_beneficiary] += weiAmount;

    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount
    );

    // forward funds
    _forwardFunds(weiAmount);

    // refund excess
    if (weiAmount < msg.value) {
      payable(msg.sender).transfer(msg.value - weiAmount);
    }
  }

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public {
    require(state != 2);
    state = 2;
    emit Finalized();
  }

  function start() onlyOwner public {
    require(state != 1);
    state = 1;
    emit Started();
  }

  function setRate(uint256 _rate) onlyOwner public {
    require(_rate > 100);
    rate = _rate;
  }

  function balanceOf(address _addr) external view returns (uint256) {
    return balances[_addr];
  }

  function hasClaimed(address _addr) external view returns (bool) {
    return claimed[_addr];
  }

  function tokenBalanceOf(address _addr) public view returns (uint256) {
    return balances[_addr] > 0 ? (balances[_addr] * rate) / 100 : 0;
  }

  /**
   * @dev Withdraw tokens only after crowdsale ends.
   */
  function withdrawTokens() public {
    require(state == 2, "Sale has not ended");
    require(rate > 0, "Rate is not set");
    uint256 amount = tokenBalanceOf(msg.sender);
    require(amount > 0, "Balance is empty");
    token.transfer(msg.sender, amount);
    claimed[msg.sender] = true;
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds(uint256 weiAmount) internal {
    payable(wallet).transfer(weiAmount);
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