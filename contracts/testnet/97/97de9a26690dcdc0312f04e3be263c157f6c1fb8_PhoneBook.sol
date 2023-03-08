/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier:MIT
pragma solidity 0.8;

error CanNotFound(string data);

/// @title                  {CRUD action} learn in phone-book training lesson
/// @author                 Mosi-Sol - @github
/// @notice                 You can use this contract for only the most basic simulation
/// @dev                    All function calls are currently implemented without side effects
/// @custom:experimental    this contract just for learning purposes.
/// @custom:which-better    find(...) vs where(...). the true answer = where(...)
/// @custom:owner-info      owner=deployer phone add when deploy, can add 1 time more the owner address by different number
/// @custom:dev-info        this code expermential, no need find() functions --> where() functions are the solution with low gas/time/compute
/// @custom:dev-interface   if inherit "PhoneBook" from "IPhoneBook", then need IERC165...
/// @custom:dev-interface   interface using for/in/on factory pattern or implment
/// @custom:dev-hash        i don't remove old hash in modify() & remove() from peopleHashings, just like git history :)

interface IPhoneBook { // interface using for factory pattern or implment
    function add(address _who, string memory _phone) external returns (uint _id);   // onlyOwner
    function modify(uint _id, address _who, string memory _phone) external;         // onlyOwner
    function remove(uint _id) external;                                             // onlyOwner
    function validUser(address _valid) external /*onlyOwner*/ returns (address);
    function unvalidUser(address _valid) external /*onlyOwner*/ returns (address);
    
    function isValidUser(address _valid) external view returns (bool);    
    function where(address _who, string memory _phone) external view returns (uint _id);
    function where(string memory _phone) external view returns (uint _id);
    function where(address _who) external view returns (uint _id);
    function viewAddress(uint id) external view returns (address);
    function viewTel(uint id) external view returns (string memory);
    function lastId() external view returns (uint);
}

contract PhoneBook {
    // ----- declare state ----- //
    struct Person {
        address contact;        // anonymous freind
        string phone;           // his/her phone number
        uint id;                // auto generated index
    }
    mapping(address => bool) private editor;            // editor user --> is editor
    mapping(uint => Person) private people;             // id --> anonymous freind
    mapping(bytes => uint) private peopleHash;          // hash --> id of anonymous freind
    mapping(bytes => uint) private peopleHashAddress;   // hash --> check-find address
    mapping(bytes => uint) private peopleHashPhone;     // hash --> check-find phone
    uint iterate = 0;                                   // auto iterate counter for indexing
    address immutable owner;                            // initial in constructor [deploy time], automate. can not change

    // ----- events ----- //
    event Hashing(uint indexed id, bytes hash, address contact, string txt, uint indexed date);
    event Create(uint indexed id, address contact, string txt, uint indexed date);
    event Edit(uint indexed id, address contact, string txt, uint indexed date);
    event Remove(uint indexed id, uint indexed date);

    modifier onlyOwner() {
        require(msg.sender == owner, "not valid user");
        _;
    }

    // ----- init ----- //
    constructor(string memory _ownerPhone) {
        owner = msg.sender;
        add(msg.sender, _ownerPhone);
    }

    // ----- create / edit / remove ----- //
    function add(address _who, string memory _phone) public onlyOwner returns (uint _id) {
        _id = _add(_who, _phone);
    }

    // find by id (index), so before modify, insure about the data
    function modify(uint _id, address _who, string memory _phone) public onlyOwner {
        _modify(_id, _who, _phone);
    }

    // find by id (index), so before modify, insure about the data
    function remove(uint _id) public onlyOwner {
        _remove(_id);
    }

    function validUser(address _valid) public onlyOwner returns (address) {
        require(editor[_valid] != true, "not valid user");
        editor[_valid] = true;
        return _valid;
    }

    function unvalidUser(address _valid) public onlyOwner returns (address) {
        require(editor[_valid] == true, "not valid user");
        editor[_valid] = false;
        return _valid;
    }

    function isValidUser(address _valid) public view returns (bool) {
        return editor[_valid];
    }

    // ----- read-only ----- //
    // where ==> O(1) - Ω(1)
    function where(address _who, string memory _phone) public view returns (uint _id) {
        uint tmp = peopleHash[bytes(abi.encode(_who, _phone))]; // now, call "id" in "people mapping" on the dApp
        if(tmp == 0) {
            revert CanNotFound("not found!"); // id 0 is deployer (owner)
        }
        _id = tmp;
    }

    function where(address _who) public view returns (uint _id) {
        uint tmp = peopleHashAddress[bytes(abi.encode(_who))]; // now, call "id" in "people mapping" on the dApp
        if(tmp == 0) {
            revert CanNotFound("not found!"); // id 0 is deployer (owner)
        }
        _id = tmp;
    }

    function where(string memory _phone) public view returns (uint _id) {
        uint tmp = peopleHashPhone[bytes(abi.encode(_phone))]; // now, call "id" in "people mapping" on the dApp
        if(tmp == 0) {
            revert CanNotFound("not found!"); // id 0 is deployer (owner)
        }
        _id = tmp;
    }

    function theOwner() public view returns (address) {
        return owner;
    }

    function viewFull(uint id) public view returns (Person memory) {
        return people[id];
    }

    function viewAddress(uint id) public view returns (address) {
        return people[id].contact;
    }

    function viewTel(uint id) public view returns (string memory) {
        return people[id].phone;
    }

    // show how much contact-person [include removed accounts in counting]
    function lastId() public view returns (uint) {
        return iterate;
    }

    // find(...) depricated, use where(...)
    // find ==> linear: O(n) - Ω(n)
    function findByAddress(address _person) public view returns (string memory) {
        uint len = iterate;
        for(uint i = 0; i < len; i++){
            if(people[i].contact == _person){
                return people[i].phone;
            }
        }
        revert CanNotFound("not found!");
    }

    function findByTel(string calldata _person) public view returns (address) {
        uint len = iterate;
        bytes32 compaire = assist(_person); // 1 time call to save gas
        for(uint i = 0; i < len; i++){
            if(assist(people[i].phone) == compaire){
                return people[i].contact;
            }
        }
        revert CanNotFound("not found!");
    }
    
    function findId(address _person) public view returns (uint) {
        uint len = iterate;
        for(uint i = 0; i < len; i++){
            if(people[i].contact == _person){
                return people[i].id;
            }
        }
        revert CanNotFound("not found!");
    }

    // ----- logic ----- //
    // string compair - use in findByTel(...)
    function assist(string memory txt) private pure returns (bytes32) { 
        return bytes32(keccak256(abi.encodePacked(txt)));
    }

    // generate hash
    function hash(uint _id, address _who, string memory _phone) private {
        bytes memory genHash = bytes(abi.encode(_who, _phone));
        peopleHash[genHash] = _id;
        emit Hashing(_id, genHash, _who, _phone, block.timestamp);
    }

    function hash(uint _id, address _who) private {
        bytes memory genHash = bytes(abi.encode(_who));
        peopleHashAddress[genHash] = _id;
    }

    function hash(uint _id, string memory _phone) private {
        bytes memory genHash = bytes(abi.encode(_phone));
        peopleHashPhone[genHash] = _id;
    }

    // create
    function _add(address _who, string memory _phone) private returns (uint) {
        require(_who != address(0), "black hole!");
        bytes memory tmp1 = bytes(abi.encode(_phone));
        bytes memory tmp2 = bytes(abi.encode(_who));
        require(peopleHashPhone[tmp1] == 0, "duplicated phone number, check data");
        require(peopleHashAddress[tmp2] == 0, "duplicated recipient, check data");
        people[iterate] = Person(_who, _phone, iterate);
        hash(iterate, _who, _phone);
        hash(iterate, _who);
        hash(iterate, _phone);
        emit Create(iterate, _who, _phone, block.timestamp);
        iterate++;
        return iterate;
    }

    // edit
    function _modify(uint _id, address _who, string memory _phone) private {
        require(_id <= iterate, "not valid id.");
        people[_id] = Person(_who, _phone, _id);
        hash(_id, _who, _phone);
        hash(_id, _who);
        hash(_id, _phone);
        emit Edit(_id, _who, _phone, block.timestamp);
    }

    // delete
    function _remove(uint _id) private {
        require(_id <= iterate, "not valid id.");
        people[_id] = Person(address(0), "", _id);
        hash(_id, address(0), "");
        hash(_id, address(0));
        hash(_id, "");
        emit Remove(_id, block.timestamp);
    }
}