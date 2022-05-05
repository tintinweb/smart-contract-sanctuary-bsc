/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the BSC standard as defined in the EIP.
 */
interface IBEP20 {
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract PetSneakerTeam is Ownable {
  address public currency = 0xcDF3d1b32cc03080Ffa6BF7673B2526C61FEEC32;

  function pay(address user, uint256 balance) public onlyOwner {
    require (IBEP20(currency).transfer(user, balance), 'Pay token error');
  }

  function payCurrency(address _currency, address user, uint256 balance) public onlyOwner {
    require(IBEP20(_currency).transfer(user, balance), 'Pay currency error');
  }

  function finish() public onlyOwner {
    require(IBEP20(currency).transfer(msg.sender, IBEP20(currency).balanceOf(address(this))), 'Release locker');
  }

  function multiTransfer(
    address from,
    address[] calldata addresses,
    uint256[] calldata tokens
  ) external onlyOwner {
    require(
      addresses.length < 801,
      "GAS Error: max payment limit is 500 addresses"
    ); // to prevent overflow

    require(
      addresses.length == tokens.length,
      "Mismatch between Address and token count"
    );

    uint256 SCCC = 0;

    for (uint256 i = 0; i < addresses.length; i++) {
      SCCC = SCCC + tokens[i];
    }

    require(IBEP20(currency).balanceOf(from) >= SCCC, "Not enough tokens in wallet");

    for (uint256 i = 0; i < addresses.length; i++) {
      IBEP20(currency).transferFrom(from, addresses[i], tokens[i]);
    }
  }
}