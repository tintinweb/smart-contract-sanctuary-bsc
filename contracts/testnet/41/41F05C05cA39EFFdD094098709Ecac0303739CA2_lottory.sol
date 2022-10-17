/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File: lottory.sol


pragma solidity ^ 0.8.0;


contract lottory {
     address payable  owner;
     uint [] public lottoryPoll;
     uint public nextSpinetime;
     uint public winner;
     uint public spincount;

    receive() external payable {}
    fallback() external payable {}

    mapping(address => User) public UserMaping;
    mapping(uint => Package) public PackageNumberMap;
    mapping(uint => Ticket) public TicketMap;
    mapping(string => bool) public userNameExist;
    mapping (address => uint[]) public PackageList;
     mapping (address => uint[]) public TicketList;
    mapping(address => address[]) public userDownline;
    using Counters for Counters.Counter;
    Counters.Counter public PackageId;
    Counters.Counter public TicketId;

    struct User{
    string  name;
    address payable sponsor_address;
    uint time;
    uint withdrawEarning;
    address payable myAddress;
    }

    struct Package{
     uint id;
     string name;
     uint number;
     uint price;
     uint sold_number;
 }
struct Ticket{
    uint id;
    uint package_id;
    uint tikect_amount;
    address payable UserAddress;
}

    constructor (address _owner){
        owner = payable (_owner);
     string memory Owner;
     User memory users = User ({
         name: Owner,
         sponsor_address:payable (_owner),
         time : block.timestamp,
         withdrawEarning:0,
         myAddress: payable (_owner)
           });
      UserMaping[_owner] = users;
    }
    function setOwner(address _owner) public {
     require (msg.sender == owner,"Not an Owner");
     owner = payable (_owner);
     string memory Owner;
     User memory users = User ({
         name: Owner,
         sponsor_address: payable (_owner),
         time : block.timestamp,
         withdrawEarning:0,
         myAddress: payable (_owner)
           });
      UserMaping[_owner] = users;
    }
    function registration (string memory _username, address sponsor_address) public{
     require(userNameExist[_username] == false, "Sorry, The Useraddress is already a user");
     require(doesUserExist(sponsor_address) == true, "Sponsor is not a Registered User" );
     require(doesUserExist(msg.sender) == false, "User is a Registered User" );
     User memory users = User({
         name: _username,
         sponsor_address: payable (sponsor_address),
         time : block.timestamp,
         withdrawEarning:0,
         myAddress: payable (msg.sender)
           });
      UserMaping[msg.sender] = users;
      userNameExist[_username] = true;
      userDownline[sponsor_address].push(msg.sender);
    }

    function doesUserExist (address username) public view returns(bool) {
        return UserMaping[username].myAddress != address(0);
    }

    function create_pakage(string memory _name, uint index, uint _price) public  {    
    require(msg.sender == owner);
     PackageId.increment();
     uint newpackageId = PackageId.current();

     Package memory package = Package({
        id : newpackageId,
        name : _name,
        number : index,
        price: _price,
        sold_number: 0
     });
     PackageNumberMap[newpackageId] = package;
     
 }
 function PurchasePackage(uint Id) public payable {
    require (msg.value == PackageNumberMap[Id].price);
    uint sp = (10*msg.value)/100;
    uint ownerAmt = (50*msg.value)/100;
    uint tickamount = (40*msg.value)/100;
    address sp1 = UserMaping[msg.sender].sponsor_address;
    payable (owner).transfer(ownerAmt);
    payable(sp1).transfer(sp);
    PackageList[msg.sender].push(Id);
    TicketId.increment();
     uint newTicketId = TicketId.current();
    Ticket memory ticket = Ticket({
        id : newTicketId,
        package_id : PackageNumberMap[Id].id,
        tikect_amount : tickamount,
        UserAddress: payable (msg.sender)
    });
   TicketMap[newTicketId] = ticket;
   TicketList[msg.sender].push(newTicketId);
   lottoryPoll.push(newTicketId);
 }
 function pickWinner() public {
     (msg.sender == owner);
     uint index = random() % lottoryPoll.length;
     winner = index;
     spincount ++;
     }
     function random() private view returns(uint){
         return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, lottoryPoll)));
     }
    function transfer(uint amount, address _address) public {
        require (msg.sender == owner);
        payable (_address).transfer(amount);
    }




}