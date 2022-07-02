/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol


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

// File: Supplychain.sol

//SPDX-License-Identifier:MIT

pragma solidity ^0.8.14;


contract itemcontract{

    ItemManager parentcontract;
    uint public index;
    uint public pricepaid;
    uint public priceinwei;

        constructor(ItemManager _parentcontract, uint _priceinwei, uint _index) {
            parentcontract = _parentcontract;
            priceinwei = _priceinwei;
            index = _index;
        }

        receive() external payable {
            require(pricepaid == 0, "Already paid");
            (bool success, ) = address(parentcontract).call{value: msg.value}(abi.encodeWithSignature("setitempaid(uint256)",index));
            require(success, "Transaction wasn't successful");
            pricepaid += msg.value;
        }
}

contract ItemManager is Ownable{

    enum statusofitem{created, paid, delivered}
    uint index;
    event details(uint _index, uint _cost, statusofitem _status, address _itemcontract);

    struct itemsupply{
        itemcontract itemcontract;
        string itemname;
        uint priceinwei;
        statusofitem status;
    }

    mapping(uint => itemsupply) public item;

        function isOwner() public view returns(bool){
            return owner() == _msgSender();
        }

        function createnewitem(string memory _itemname, uint _cost) public onlyOwner{
            itemcontract itemtransaction = new itemcontract(this, _cost, index);
            item[index].itemcontract = itemtransaction;
            item[index].itemname = _itemname;
            item[index].priceinwei = _cost;
            item[index].status = statusofitem.created;
            emit details(index, _cost, item[index].status, address(itemtransaction));
            index++;
        }

        function setitempaid(uint _index) public payable {
            require(item[_index].status == statusofitem.created, "Different in supply chain");
            require(item[_index].priceinwei == msg.value, "Only full payments accepted");
            item[_index].status = statusofitem.paid;
            emit details(_index, item[_index].priceinwei, item[index].status, address(item[_index].itemcontract));
        }

        function setdelivery(uint _index) public onlyOwner{
            require(item[_index].status == statusofitem.paid, "Different in supply chain");
            item[_index].status = statusofitem.delivered;

        }
}