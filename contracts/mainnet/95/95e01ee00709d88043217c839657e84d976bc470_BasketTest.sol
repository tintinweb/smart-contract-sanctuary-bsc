// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interface/ILiquidCryptoBridge_v1.sol";

contract BasketTest is Ownable {
  address public bridge;

  string private constant SIGNING_DOMAIN = "LiquidCryptoBridge_v1-Voucher";

  mapping (address => mapping (address => uint256)) public xlpSupply;

  struct Swaper {
    address router;
    address[] path0;
    address[] path1;
    uint256 routertype;
  }

  constructor() {}

  function depositViaBridge(ILiquidCryptoBridge_v1.SwapVoucher memory voucher, uint256 fee) public returns(uint256) {
    uint256 amount = ILiquidCryptoBridge_v1(bridge).withdrawForUser(voucher, fee);
    return amount;
  }

  function withdrawViaBridge(address account, uint256 inChain, uint256 outChain, uint256 price, uint256 rate, uint256 fee) public payable {
    uint256 inAmount = msg.value;
    uint256 outAmount = inAmount * price / rate;
    ILiquidCryptoBridge_v1.SwapVoucher memory voucher = ILiquidCryptoBridge_v1.SwapVoucher(
      account, inChain, inAmount, outChain, outAmount
    );
    ILiquidCryptoBridge_v1.SwapVoucher[] memory vouchers;
    vouchers[0] = voucher;
    
    ILiquidCryptoBridge_v1(bridge).depositForUser{value: msg.value}(vouchers, fee);
  }

  function setBridge(address addr) public onlyOwner {
    bridge = addr;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9 <0.9.0;

interface ILiquidCryptoBridge_v1 {
  struct SwapVoucher {
    address account;
    uint256 inChain;
    uint256 inAmount;
    uint256 outChain;
    uint256 outAmount;
  }

  function depositForUser(SwapVoucher[] calldata voucher, uint256 fee) external payable;
  function withdrawForUser(SwapVoucher calldata voucher, uint256 fee) external returns(uint256);
  function refundFaildVoucher(uint256 index, uint256 amount, uint256 fee) external;
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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