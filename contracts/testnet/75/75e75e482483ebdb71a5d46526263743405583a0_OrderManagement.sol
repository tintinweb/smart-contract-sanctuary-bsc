/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

pragma solidity ^0.8.16;
// SPDX-License-Identifier: MIT

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *u
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

contract OrderManagement is Ownable{
    struct Order {
        string id;
        string name;
        uint256 amount;
        uint status;
        uint256 index;
    }

    mapping (uint256 => Order) orders; // index based
    mapping (string => uint256) orderIndex; // save indexes w.r.t ids

    address payable public beneficiary;

    uint256 public totalOrders;

    constructor(){
        beneficiary = payable(msg.sender);
    }

    function CreateOrder(string memory _id, string memory _name, uint256 _amount) external onlyOwner{
        require(orderIndex[_id] == 0, "Order with id already exist");
        totalOrders++;

        orders[totalOrders].id = _id;
        orders[totalOrders].name = _name;
        orders[totalOrders].amount = _amount;
        orders[totalOrders].status = 0; // pending
        orders[totalOrders].index = totalOrders;

        orderIndex[_id] = totalOrders;

        
    }

     modifier OrderExists(string memory _id){
        require(orderIndex[_id] != 0, "Order with id does not exist");
        _;
    }

    modifier ValidAmount(uint256 _amount, string memory _id){
        require(_amount == orders[orderIndex[_id]].amount, "Please send sufficient amount");
        _;
    }

    modifier NotPaid(string memory _id){
        require(0 == orders[orderIndex[_id]].status, "Already Paid");
        _;
    }

    function PayFees(string memory _id) external payable OrderExists(_id) NotPaid(_id) ValidAmount(msg.value, _id){
        orders[orderIndex[_id]].status = 1; // paid
        beneficiary.transfer(orders[orderIndex[_id]].amount);
    }

    function QueryByIndex(uint256 _index) external view returns(string memory id,
        string memory name,
        uint256 amount,
        uint status,
        uint256 index
        ){
        return (orders[_index].id, orders[_index].name, orders[_index].amount, orders[_index].status, orders[_index].index);
    }

    function QueryById(string memory _id) external view returns(string memory id,
        string memory name,
        uint256 amount,
        uint status,
        uint256 index){
        return (orders[orderIndex[_id]].id, orders[orderIndex[_id]].name, orders[orderIndex[_id]].amount, orders[orderIndex[_id]].status, orders[orderIndex[_id]].index);
    }

    function ChangeBeneficiary(address payable _newBeneficiary) external onlyOwner{
        require(_newBeneficiary != address(0), "Invalid address");
        beneficiary = _newBeneficiary;
    }
}