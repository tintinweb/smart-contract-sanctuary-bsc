// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ServiceReceiver is Ownable {
    struct Clone {
        address cAddress;
        string cTemplate;
    }

    mapping(bytes32 => uint256) private _prices;
    mapping(address => bool) private _contracts;
    mapping(address => string) private _templates;
    mapping(address => Clone[]) clones;

    event Created(
        string templateName,
        address indexed contractAddress,
        address contractOwner
    );

    function pay(string memory templateName_, address contractOwner_)
        public
        payable
    {
        require(
            msg.value == _prices[_toBytes32(templateName_)],
            "CC: incorrect price"
        );
        _contracts[_msgSender()] = true;
        _templates[_msgSender()] = templateName_;
        clones[contractOwner_].push(Clone(_msgSender(), templateName_));

        emit Created(templateName_, _msgSender(), contractOwner_);
    }

    function getCloneInfo(address owner_, uint256 index)
        public
        view
        returns (address, string memory)
    {
        return (
            clones[owner_][index].cAddress,
            clones[owner_][index].cTemplate
        );
    }

    function getCloneOwned(address owner_) public view returns (uint256) {
        return clones[owner_].length;
    }

    function getContractTemplate(address contractAddress_)
        public
        view
        returns (string memory)
    {
        return _templates[contractAddress_];
    }

    function getPrice(string memory templateName_)
        public
        view
        returns (uint256)
    {
        return _prices[_toBytes32(templateName_)];
    }

    function setPrice(string memory templateName_, uint256 amount_)
        public
        onlyOwner
    {
        _prices[_toBytes32(templateName_)] = amount_;
    }

    function getAccess(address contractAddress_) public view returns (bool) {
        uint256 cloneOwned = clones[_msgSender()].length;
        require(cloneOwned > 0, "CC: don't have any clones");

        for (uint256 i = 0; i < cloneOwned; i++) {
            if (clones[_msgSender()][i].cAddress == contractAddress_)
                return true;
        }

        return false;
    }

    function isValidAddress(address contractAddress_)
        public
        view
        returns (bool)
    {
        return _contracts[contractAddress_];
    }

    function setBulkPrice(
        string[] memory serviceNames_,
        uint256[] memory amounts_
    ) public onlyOwner {
        require(
            serviceNames_.length == amounts_.length,
            "CC: Length not equal"
        );
        for (uint256 i = 0; i < serviceNames_.length; i++) {
            _prices[_toBytes32(serviceNames_[i])] = amounts_[i];
        }
    }

    function withdraw(uint256 amount_) public onlyOwner {
        payable(owner()).transfer(amount_);
    }

    function withdrawAll() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function _toBytes32(string memory templateName_)
        private
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(templateName_));
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