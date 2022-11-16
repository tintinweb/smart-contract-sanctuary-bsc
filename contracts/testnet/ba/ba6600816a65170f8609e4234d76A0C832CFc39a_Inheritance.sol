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
    Owner public owner;
    mapping (address => Owner) public owners;

    //Ensure that only onwer is allowed to interact
    modifier contractOwner{
        require (owners[msg.sender].ownerAddress == msg.sender, "Only the owner can create its inheritance.");
        _;
    }

    //Ensure that owner is dead
    modifier isDead{
        require(owners[msg.sender].alive == false, "You cannot declare someonelse's death");
        _;
    }

    //Add new descendants to will's owner
    function createWill() public payable{
        owner.ownerAddress = msg.sender;
        owner.legacy = msg.value;
        owners[msg.sender] = owner;
    }

    function addWillInheritance(address[] memory _wallet) public contractOwner{
        for(uint i = 0; i < _wallet.length; i++){
            owners[msg.sender].descendant.push(Descendant({walletAddress: _wallet[i], money: 0}));
        }
    }

    function addValue() public payable{
        owners[msg.sender].legacy = msg.value;
    } 

    function shareWill() private isDead {
        uint len = owners[msg.sender].descendant.length;
        uint legacy = owners[msg.sender].legacy / owners[msg.sender].descendant.length;        
        for(uint i=0; i < len; i++){
            payable(owners[msg.sender].descendant[i].walletAddress).transfer(legacy);
        }
    }

    function died() public {
        owners[msg.sender].alive = false;
        shareWill();
    }


}