/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
contract Marketing{
address public owner;
address public admin;
 struct User {
         address myAddress;
         string sponsorName;
         uint package;
    }
 struct Package{
     uint id;
     string name;
     uint number;
     uint price;
     uint sold_number;
 }
    mapping(address => bool) public userExist;
    mapping(string => User) public UserNameMap;
    mapping(address => string) public userAddressMap;
    mapping(string => uint) public userRegTime;
    mapping(string => address[]) public userDownline;
    mapping (uint => Package) public PackageNumberMap;
    mapping (address => address) public Sponsoraddress;



constructor (address _owner, address _admin){
    owner = _owner;
    admin = _admin;

}
    function registration(string memory sponsorName, string memory _UserName, address sponsor) external{
         require (!doesUserExist(getUserfromAddress(msg.sender)), "User Exits");
         //require(doesUserExist(sponsorName), "Sponsor is not a Registered User" );
         require(!doesUserExist(_UserName), "Sorry, The UserName is already in use");
         require(userExist[msg.sender] == false, "Sorry, The Useraddress is already a user");
         address userAddress = msg.sender;
          User memory users = User ({
            myAddress : userAddress,
            sponsorName : sponsorName,
            package: 0
           });
                 UserNameMap[_UserName] = users;
        userRegTime[_UserName] = block.timestamp;
        userDownline[sponsorName].push(userAddress);
        Sponsoraddress[userAddress] = sponsor;
         }

 function create_pakage(string memory _name, uint index, uint _price) public {
    require(msg.sender == owner);
     Package memory package = Package({
         id : index,
        name : _name,
        number : index,
        price: _price,
        sold_number: 0
     });
     PackageNumberMap[index] = package;
     
 }
    function purchase(uint Package_number) public payable {
     require (PackageNumberMap[Package_number].price==msg.value,"send the correct value");
     require (userExist[msg.sender] == true, "Sorry, The Useraddress not register");
     payable (owner).transfer(msg.value);
     string memory _username =userAddressMap[msg.sender];
     UserNameMap[_username].package = Package_number;
     PackageNumberMap[Package_number].sold_number++;

}

    function doesUserExist (string memory username) public view returns(bool) {
        return UserNameMap[username].myAddress != address(0);
    }
    function getUserfromAddress(address userAddress) public view returns(string memory) {
        return userAddressMap[userAddress];
    }
         function getSponsorName(string memory username) public view returns(string memory) { 
          return UserNameMap[username].sponsorName;
    }
     function getSponsoraddress(string memory username) public view returns(address) { 
          string memory sponsor= UserNameMap[username].sponsorName;
          return UserNameMap[sponsor].myAddress;
    }

}