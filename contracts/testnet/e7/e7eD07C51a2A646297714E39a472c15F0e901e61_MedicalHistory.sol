/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: MIT
// File: manager.sol


pragma solidity ^0.8.2;

contract MedicalHistory {
    mapping (address => Item[]) public items;

// The structs of the Item.
struct Item {
  string name;
  string description;
}


// Emits an event when a new item is added, you can use this to update remote item lists.
event itemAdded(address user, string name, string description);


// Gets the items for the used who called the function
function getItems() public view returns (Item [] memory){
   return items[msg.sender];
}


// Adds an item to the user's Item list who called the function.
function addItem(string memory name, string memory description) public {

    // require the name to not be empty.
    require(bytes(name).length > 0, "name is empty!");

    // require the description to not be empty.
    require(bytes(description).length > 0, "description is empty!");


    // adds the item to the storage.
    Item memory newItem = Item(name,description);
    items[msg.sender].push(newItem);

    // emits item added event.
    emit itemAdded(msg.sender, newItem.name, newItem.description);
}
}