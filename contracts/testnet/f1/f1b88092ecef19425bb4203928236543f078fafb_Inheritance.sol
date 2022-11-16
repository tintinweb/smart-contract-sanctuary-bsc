/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.5.0 <0.9.0;

struct Descendant{
    address walletAddress;
    uint money;
}

struct Owner {
    uint id;
    bool alive;
    address ownerAddress;
    uint legacy;
    Descendant[] descendant;
}



contract Inheritance {
    Owner owner;
    uint numberOfOwner = 0;
    mapping (uint => Owner) public owners;

    constructor() public payable{
        numberOfOwner++;
        owner.ownerAddress = msg.sender;
        owner.legacy = msg.value;
        owner.alive = true;
        owner.id = numberOfOwner;
        owners[numberOfOwner] = owner;
    }

    //Ensure that only onwer is allowed to interact
    modifier oneOwner{ 
        require (msg.sender == owner.ownerAddress, "Only the owner can create its inheritance.");
        _;
    }

    //Ensure that owner is dead
    modifier isDead(){
        require(owner.alive == false);
        _;
    }

    //Add new descendants to will's owner
    function createWill(uint ownerId, uint _legacy, address[] memory _wallet) public oneOwner payable{
        owners[ownerId].legacy = _legacy;
        uint i = 0;
        while (_wallet[i] != address(0) ){
            owners[ownerId].descendant.push(Descendant({walletAddress: _wallet[i], money:0}));
            i++;
        }
    }

    function addWillInheritance(address[] memory _wallet) public oneOwner{
        uint i = 0;
        while (_wallet[i] != address(0) ){
            owner.descendant.push(Descendant({walletAddress: _wallet[i], money: 0}));
        }
    } 

    function shareWill(uint ownerId) private isDead {
        uint len = owners[ownerId].descendant.length;
        uint legacy = owners[ownerId].legacy / owners[ownerId].descendant.length;        
        for(uint i=0; i < len; i++){
            payable(owners[ownerId].descendant[i].walletAddress).transfer(legacy);

        }
    }

    function died(uint ownerId) public oneOwner {
        owners[ownerId].alive = false;
        shareWill(ownerId);
    }


}