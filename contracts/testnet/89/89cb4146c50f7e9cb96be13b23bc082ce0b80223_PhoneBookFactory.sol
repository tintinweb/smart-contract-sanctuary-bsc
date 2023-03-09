/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier:MIT
pragma solidity 0.8;

/// @title                  {CRUD action} learn in phone-book (factory pattern) training lesson
/// @author                 Mosi-Sol - @github
/// @notice                 You can use this contract for only the most basic simulation
/// @dev                    All function calls are currently implemented without side effects
/// @custom:experimental    this contract just for learning purposes.
/// @custom:web-three-tips  before add, remove, modify, valid => check by where in backend, then action on contract


interface IPhoneBook {
    function add(address _who, string memory _phone) external /*onlyOwner*/ returns (uint _id);
    function modify(uint _id, address _who, string memory _phone) external /*onlyOwner*/;
    function remove(uint _id) external /*onlyOwner*/;
    function validUser(address _valid) external /*onlyOwner*/ returns (address);
    function unvalidUser(address _valid) external /*onlyOwner*/ returns (address);
    
    function isValidUser(address _valid) external view returns (bool);
    function where(address _who, string memory _phone) external view returns (uint _id);
    function where(string memory _phone) external view returns (uint _id);
    function where(address _who) external view returns (uint _id);
    function viewAddress(uint id) external view returns (address);
    function viewTel(uint id) external view returns (string memory);
    function lastId() external view returns (uint);
    function theOwner() external view returns (address);
}

// not import & use interface ( interface IPhoneBook{...} ) in file
// OR : lib in same folder (internal link) - next line
// import "./IPhoneBook.sol"; 
// OR : import from github (external link) - next line
// import "https://github.com/mosi-sol/Solidity101/blob/main/collection-1/04.IPhoneBook.sol";

interface ISwitch { // helper, custom to add
    function changePhoneBook(address _phoneBook) external /*access*/;
}

contract PhoneBookFactory {
    // ----- declairation ----- //
    IPhoneBook phoneBook; // <-- bsc testnet: 0x97DE9a26690DCDc0312F04E3Be263c157f6c1fb8
    uint id;
    
    // ----- moderat ----- //
    modifier access() {
        require(msg.sender == phoneBook.theOwner(), "only real owner");
        _;
    }
    
    modifier access_(address _valid) {
        require(msg.sender == phoneBook.theOwner() || 
        msg.sender == validUser(_valid), "only valid user");
        _;
    }

    // ----- init ----- //
    constructor(address _phoneBook) {
        phoneBook = IPhoneBook(_phoneBook); // need to deploy PhoneBook, then deploy this factory
    }
    
    // ----- actions ----- //
    function doAdd(address _who, string memory _phone) public access_(msg.sender) returns (uint _id) {
        phoneBook.add(_who, _phone);
        _id = id;
        id += 1;
    }

    function modify(uint _id, address _who, string memory _phone) external access_(msg.sender) {
        phoneBook.modify(_id, _who, _phone);
    }

    function remove(uint _id) external access_(msg.sender) {
        phoneBook.remove(_id);
    }
    
    // ----- read-only ----- //
    function where(address _who, string memory _phone) external view returns (uint _id) {
        return phoneBook.where(_who, _phone);
    }

    function where(string memory _phone) external view returns (uint _id) {
        return phoneBook.where(_phone);
    }

    function where(address _who) external view returns (uint _id) {
        return phoneBook.where(_who);
    }

    function viewAddress(uint _id) external view returns (address) {
        return phoneBook.viewAddress(_id);
    }

    function viewTel(uint _id) external view returns (string memory) {
        return phoneBook.viewTel(_id);
    }

    function lastId() external view returns (uint) {
        return phoneBook.lastId();
    }

    function theOwner() external view returns (address) {
        return phoneBook.theOwner();
    }

    // ----- valid ----- //
    function validUser(address _valid) public access returns (address) {
        return phoneBook.validUser(_valid);
    }
    
    function unvalidUser(address _valid) public access returns (address) {
        return phoneBook.unvalidUser(_valid);
    }
    
    function isValidUser(address _valid) public view returns (bool) {
        return phoneBook.isValidUser(_valid);
    }

    // ----- change factory base ----- //
    // just by owner, & and can switch back
    // if deployer of next phonebook is not same, then switch back not by you!
    function changePhoneBook(address _phoneBook) public access {
        phoneBook = IPhoneBook(_phoneBook); // need to deploy PhoneBook, then deploy this factory
    }
}