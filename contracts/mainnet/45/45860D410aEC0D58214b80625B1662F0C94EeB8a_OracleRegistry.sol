// SPDX-License-Identifier: ISC
pragma solidity ^0.8.9;

import "../interfaces/IOracleRegistry.sol";
import "../interfaces/IOracle.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OracleRegistry is IOracleRegistry, Ownable {
  mapping(address => mapping(address => IOracle)) oracles;
  address[] bases;

  constructor(address[] memory bases_) {
    bases = bases_;
  }

  function setOracle(address oracle, address tokenIn, address tokenOut) external onlyOwner {
    oracles[tokenIn][tokenOut] = IOracle(oracle);
  }

  function convert(address tokenIn, address tokenOut, uint256 amountIn) external view returns (uint256) {
    (bool ok, uint256 amountOut) = convertFallible(tokenIn, tokenOut, amountIn);
    if (ok) {
      return amountOut;
    }

    revert("no oracle found");
  }

  function convertFallible(address tokenIn, address tokenOut, uint256 amountIn) internal view returns (bool, uint256) {
    (bool okDirect, uint256 amountOutDirect) = convertDirect(tokenIn, tokenOut, amountIn);
    if (okDirect) {
      return (true, amountOutDirect);
    }

    for (uint i = 0; i < bases.length; i++) {
      (bool ok, uint256 amountOut) = convertThroughBase(tokenIn, bases[i], tokenOut, amountIn);
      if (ok) {
        return (true, amountOut);
      }
    }
    
    return (false, 0);
  }

  function convertDirect(address tokenIn, address tokenOut, uint256 amountIn) internal view returns (bool, uint256) {
    if (tokenIn == tokenOut) {
      return (true, amountIn);
    }

    IOracle direct = oracles[tokenIn][tokenOut];
    if (address(direct) != address(0)) {
      return (true, direct.price(amountIn));
    }

    IOracle reverse = oracles[tokenOut][tokenIn];
    if (address(reverse) != address(0)) {
      return (true, reverse.reversePrice(amountIn));
    }
    return (false, 0);
  }

  function convertThroughBase(address tokenIn, address tokenBase, address tokenOut, uint256 amountIn) internal view returns (bool, uint256) {
    (bool ok1, uint256 amountBase) = convertDirect(tokenIn, tokenBase, amountIn);
    if (!ok1) {
      return (false, 0);
    }

    (bool ok2, uint256 amountOut) = convertDirect(tokenBase, tokenOut, amountBase);
    if (!ok2) {
      return (false, 0);
    }

    return (true, amountOut);
  }
}

// SPDX-License-Identifier: ISC
pragma solidity ^0.8.9;

interface IOracleRegistry {
  function convert(address tokenIn, address tokenOut, uint256 amountIn) external view returns (uint256 amountOut);
}

// SPDX-License-Identifier: ISC
pragma solidity ^0.8.9;

interface IOracle {
  // token in, USDT out
  function price(uint amount) external view returns (uint256 answer);
  // USDT in, token out
  function reversePrice(uint amount) external view returns (uint256 answer);

  function description() external view returns (string memory);
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