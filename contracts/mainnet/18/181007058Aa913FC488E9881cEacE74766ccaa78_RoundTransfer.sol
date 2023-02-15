// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../libs/@openzeppelin/contracts/access/Ownable.sol";
import "../libs/@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/ITOKEN.sol";

contract RoundTransfer is Ownable {

  // -------------------------------------------------------------------------------------------------------
  // ------------------------------- ROUND PARAMETERS
  // -------------------------------------------------------------------------------------------------------


  // @notice                            round conditions
  uint256 constant public               ROUND_FUND = 100_000_000 ether;             
  
  // @notice                            token interfaces
  address public                        TokenAddress;
  IToken                                TOKEN;

  // @notice                            round state
  uint256 public                        availableTreasury = ROUND_FUND;
  bool    public                        isActive;



  // -------------------------------------------------------------------------------------------------------
  // ------------------------------- EVENTS
  // -------------------------------------------------------------------------------------------------------

  event                                 TokenPurchased(address indexed user, uint256 amount);

  // FUNCTIONS
  //
  // -------------------------------------------------------------------------------------------------------
  // ------------------------------- Constructor
  // -------------------------------------------------------------------------------------------------------

  // @param                             [address] token => token address
  // @param                             [address] usdt => USDT token address
  constructor(address token) {
    TokenAddress = token;
    TOKEN = IToken(token);
    TOKEN.grantManagerToContractInit(address(this), ROUND_FUND);
    isActive = true;
  }

  // -------------------------------------------------------------------------------------------------------
  // ------------------------------- Modifiers
  // -------------------------------------------------------------------------------------------------------

  // @notice                            checks if tokens could be sold
  // @param                             [uint256] amount => amount of tokens to sell
  modifier                              areTokensAvailable(uint256 amount) {
    require(availableTreasury - amount >= 0,
                      "Not enough tokens left!");
    _;
  }

  // @notice                            checks if round is active
  modifier                              ifActive() {
    if ( availableTreasury == 0) {
      isActive = false;
      revert("Round is not active!");
    }
    isActive = true;
    _;
  }

  // @notice                            checks if round is inactive
  modifier                              ifInactive() {
    if ( availableTreasury > 0) {
      isActive = true;
      revert("Round is still active!");
    }
    isActive = false;
    _;
  }

  // -------------------------------------------------------------------------------------------------------
  // ------------------------------- Admin
  // -------------------------------------------------------------------------------------------------------

  // @notice                            allows admin to issue tokens with vesting rules to address
  // @param                             [uint256] _amount => amount of Token tokens to issue
  // @param                             [address] _to => address to issue tokens to
  function                              issueTokens(uint256 _amount, address _to) public areTokensAvailable(_amount) onlyOwner {
    TOKEN.mint(_to, _amount);
    availableTreasury -= _amount;
    emit TokenPurchased(_to, _amount);
  }

  // @notice                            allows to withdraw remaining tokens after the round end
  // @param                             [address] _reciever => wallet to send tokens to
  function                              withdrawRemainingToken(address _reciever) public onlyOwner ifInactive {
    TOKEN.mint(_reciever, availableTreasury);
    availableTreasury = 0;
  }

  // @notice                            checks if round still active
  function                              checkIfActive() public returns(bool) {
    if (availableTreasury == 0) {
      isActive = false;
    }
    if (availableTreasury > 0) {
      isActive = true;
    }
    return(isActive);
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
//
//--------------------------
// 5F 30 78 30 30 6C 61 62
//--------------------------
//
// Token contract interface

pragma solidity ^0.8.4;

interface IToken {
  function        balanceOf(address account) external view returns (uint256);
  function        transfer(address to, uint256 amount) external returns (bool);
  function        transferFrom(address from,
                               address to,
                               uint256 amount
                               ) external returns (bool);
  function        approve(address spender, uint256 amount) external returns (bool);
  function        allowance(address owner, address spender) external view returns (uint256);
  function        grantManagerToContractInit(address account, uint256 amount) external;
  function        revokeManagerAfterContractInit(address account) external;
  function        mint(address to, uint256 amount) external;
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