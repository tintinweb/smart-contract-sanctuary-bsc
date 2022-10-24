/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

pragma solidity ^0.7.4;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() public {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

contract GameRoom is Owner {

    struct User {
        int balance;
        bool exists;
    }
    
    mapping(address => User) internal addressToAccount;
    
    function createUser() external {
        require(getExistance() == false);
        addressToAccount[msg.sender] = User(0, true);
    }
    
    function getBalance() public view returns(int) {
        require(getExistance() == true);
        return addressToAccount[msg.sender].balance;
    }
    
    function getExistance() public view returns(bool) {
        return addressToAccount[msg.sender].exists;
    }
    
    function depositBalance() external payable {
        require(getExistance() == true);
        addressToAccount[msg.sender].balance += int(msg.value);
    }
    
    function withdrawBalance(uint _amount, int _tab) external payable {
        require(getExistance() == true);
        msg.sender.transfer(_amount);
        // Only change balance if tab is smaller than withdraw amount
        if (_tab < int(_amount)) {
            addressToAccount[msg.sender].balance -= int(_amount) - _tab;
        }
    }
    
    function balance() external view returns(int) {
        return int(address(this).balance);
    }
    
    //function withdrawContract() external isOwner {
    //    address owner = getOwner();
    //    owner.transfer(address(this).balance);
    //}
}