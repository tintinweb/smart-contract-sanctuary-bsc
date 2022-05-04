// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.11;

import "./access/Ownable.sol";

abstract contract tokenInterfaceXra {
	function transfer(address _to, uint256 _value) public virtual returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool);
}
abstract contract daoInterface {
	function voted(address _user) public virtual returns (bool);
}

contract XribaDaoVault is Ownable {
    tokenInterfaceXra public xra;
    daoInterface public dao;

    mapping(address => uint256) public balances;

    function balanceOf(address clientAddress) public view returns (uint256) {
        return balances[clientAddress];
    }

    constructor (address _tkn, address _addressDao) {
        xra = tokenInterfaceXra(_tkn);
        setDaoAddress(_addressDao);
    }

    function setDaoAddress(address _addressDao) public onlyOwner {
        dao = daoInterface(_addressDao);
    }
    
    function deposit(uint256 _amount) public {
        require(!dao.voted(msg.sender), "Cant deposit because voted");
        xra.transferFrom(msg.sender, address(this), _amount);
        balances[msg.sender] += _amount;
    }

    function withdraw(uint256 _amount) public {
        require(!dao.voted(msg.sender), "Cant withdrow because voted");
        require(_amount <= balances[msg.sender], "transfer amount exceeds balance");
        balances[msg.sender] -= _amount;
        xra.transfer(msg.sender, _amount);
    }
}

// SPDX-License-Identifier: MIT

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
    address private _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
    function renounceOwnership(string calldata check) public virtual onlyOwner {
        require(keccak256(abi.encodePacked(check)) == keccak256(abi.encodePacked("renounceOwnership")), "security check");
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */

    function transferOwnership(address newOwner) public onlyOwner {
        require(address(0) != newOwner, "ownership cannot be transferred to address 0");
        _newOwner = newOwner;
    }

    function acceptOwnership() public {
        require(_newOwner != address(0), "no new owner has been set up");
        require(msg.sender == _newOwner, "only the new owner can accept ownership");
        _setOwner(_newOwner);
        _newOwner = address(0);
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

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