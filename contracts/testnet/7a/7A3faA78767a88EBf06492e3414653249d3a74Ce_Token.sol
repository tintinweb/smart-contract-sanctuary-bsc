// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20Votes.sol";

contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	/**
	* @dev Initializes the contract setting the deployer as the initial owner.
	*/
	constructor () {
		address msgSender = _msgSender();
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
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
		require(_owner == _msgSender(), "Ownable: caller is not the owner");
		_;
	}

	/**
	* @dev Leaves the contract without owner. It will not be possible to call
	* `onlyOwner` functions anymore. Can only be called by the current owner.
	*
	* NOTE: Renouncing ownership will leave the contract without an owner,
	* thereby removing any functionality that is only available to the owner.
	*/
	function renounceOwnership() public onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
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

contract Token is ERC20Votes, Ownable {

    constructor() ERC20("Strong Tiger Finance", "STF") ERC20Permit("Strong Tiger Finance") {
        _mint(msg.sender, 1333333333 * 10**18);
    }

    // The functions below are overrides required by Solidity.

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal override(ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20Votes)
    {
        super._burn(account, amount);
    }

    function burn(uint256 _amount) external onlyOwner {
        _burn(msg.sender, _amount);
    }

    function mint(uint256 _amount) external onlyOwner {
        _mint(msg.sender, _amount);
    }

    function setMaxSupply(uint224 _amount) external onlyOwner {
        _maxSupplyV = _amount;
    }
}