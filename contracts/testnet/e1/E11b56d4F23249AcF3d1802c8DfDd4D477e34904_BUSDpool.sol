// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error BUSDpool__EmptyBalance();
error BUSDpool__WithdrawFailed();
error BUSDpool__InsufficentAllowance();
error BUSDPool__Insufficient();

contract BUSDpool is Ownable {
  bytes32 public constant ECOSYSTEM = keccak256("ECOSYSTEM");
  bytes32 public constant MARKETING = keccak256("MARKETING");
  bytes32 public constant TEAM = keccak256("TEAM");
  bytes32 public constant SEVER = keccak256("SEVER");

  struct Partner{
    uint256 rates;
    uint256 balances;
  }

  address private immutable i_BUSD;
 
  mapping (address => Partner) private partners;
  mapping (bytes32 => address ) private roleToPartner;

  event BuyBox(address indexed userAddress,uint256 indexed userId, uint256 orderId, uint256 amount);
  event BuyComboBox(address indexed userAddress,uint256 indexed userId, uint256 orderId,uint256 comboId, uint256 amount);

  event Withdraw(address indexed account,uint256 amount);

  constructor(address _BUSD) {
    i_BUSD = _BUSD;
  }

  function initialize(address marketing, address team, address sever) external onlyOwner{
    partners[address(this)].rates = 70;
    partners[marketing].rates = 15;
    partners[team].rates = 10;
    partners[sever].rates = 5;
    roleToPartner[ECOSYSTEM] = address(this);
    roleToPartner[MARKETING] = marketing;
    roleToPartner[TEAM] = team;
    roleToPartner[SEVER] = sever;
  }
  
  function buyBox(uint256 userId, uint256 orderId, uint256 amount) external {
    bytes32[4] memory groups = [ECOSYSTEM,MARKETING,TEAM,SEVER];
    uint256 allowance = IERC20(i_BUSD).allowance(msg.sender, address(this));
    if(allowance < amount) revert BUSDpool__InsufficentAllowance();
    address partner = address(0);
    for(uint256 i = 0; i < groups.length; i++){
      partner = roleToPartner[groups[i]];
      partners[partner].balances += partners[partner].rates * amount / 100;
    }
    IERC20(i_BUSD).transferFrom(msg.sender, address(this), amount);
    emit BuyBox(msg.sender, userId, orderId, amount);
  }

  function buyComboBox(uint256 userId, uint256 orderId,uint256 comboId, uint256 amount) external {
    bytes32[4] memory groups = [ECOSYSTEM,MARKETING,TEAM,SEVER];
    uint256 allowance = IERC20(i_BUSD).allowance(msg.sender, address(this));
    if(allowance < amount) revert BUSDpool__InsufficentAllowance();
    address partner = address(0);
    for(uint256 i = 0; i < groups.length; i++){
      partner = roleToPartner[groups[i]];
      partners[partner].balances += partners[partner].rates * amount / 100;
    }
    IERC20(i_BUSD).transferFrom(msg.sender, address(this), amount);
    emit BuyComboBox(msg.sender, userId, orderId, comboId, amount);
  }

  function ecoWithdraw() external onlyOwner {
     uint256 ecoPool = partners[address(this)].balances;
     partners[address(this)].balances = 0;
      _withdraw(owner(), ecoPool);
  }

  function partnerWithdraw() external {
    uint256 partnerBalance = partners[msg.sender].balances;
    partners[msg.sender].balances = 0;
    _withdraw(msg.sender, partnerBalance);
  }

  function _withdraw(address account,uint256 amount) internal {
    bool success = IERC20(i_BUSD).transfer(account, amount);
    if(!success) revert BUSDpool__WithdrawFailed();
    emit Withdraw(account, amount);
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