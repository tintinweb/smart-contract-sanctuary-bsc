/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
contract PropertyDealing{
    address contractOwner;
    uint256 propertyId;
    address[] blackListUsers;
    struct property{
        uint256 propertyID;
        string location;
        uint256 price;
        address owner;  
    }

    mapping (uint256=> property) allProperties;
    mapping(address => uint256) addressCounts;
    mapping(address => bool) blackLists;

    constructor(){
        contractOwner=msg.sender;
    }

    modifier onlyOwner() {
        require(contractOwner == msg.sender, "You are not authorized");
        _;
    }
    modifier isNotBlackListed (){
        require (!blackLists[msg.sender],"Sorry you are black listed");
        _;
    }

    function addProperty(string memory location, uint256 price ) public returns(bool success){
        allProperties[propertyId]=property(propertyId,location,price,msg.sender);
        addressCounts[msg.sender] = addressCounts[msg.sender] + 1;
        propertyId++;
        emit propertyIsCreated(msg.sender,price);
        return true;
    }

    function buyProperty(uint256 id) public isNotBlackListed returns(bool success){
        allProperties[id].owner=msg.sender;
        return true;
    }

    function searchProprtyById(uint256 id) public view returns(property memory) {
        return allProperties[id];
    }

    function addUserToBlackList(address userAddress) public onlyOwner isNotBlackListed{
        blackLists[userAddress] = true;
    }

    function showAllProperties() public view returns(property[] memory allPro) {
        uint256 counter=0;
        property[] memory allProp=new property[](propertyId);
        while(counter<propertyId){
            allProp[counter]=allProperties[counter];
            counter++;
        }
        return allProp;
    }

    function getLength(address user) public view returns(uint256 useRProperties, uint256 totalProperties){
        return (addressCounts[user], propertyId);
    }

    function showSpecificUsersProperties(address userAddress) public view returns(property[] memory){
        uint256  counter =0;
        property[] memory allProp = new property[](addressCounts[userAddress]);
        uint256 userCount = 0; 
        while(counter<propertyId){
            if(allProperties[counter].owner==userAddress){
                allProp[userCount]= allProperties[counter];
                userCount++;
            }
            counter++;
        }

        return allProp;
    }

    function changeOwnerShip(address newOwnerAddress) public onlyOwner returns(bool success){
           contractOwner=newOwnerAddress;
           return true;
    }

    function Owner() public view returns(address){
        return contractOwner;
    }

    event propertyIsCreated(address owner, uint256 price);

}