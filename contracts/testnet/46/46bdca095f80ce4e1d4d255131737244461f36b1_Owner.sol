/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

pragma solidity >=0.7.0 <0.9.0;

contract Owner{

    address private owner ;

    constructor(){
        owner=msg.sender;
    }

    event changeOwnerLog(address new_owner,address old_ownder, string  message);
    
    modifier isOwner (){
        require(msg.sender==owner ,"not owner");
        _;
    }

    function changeOwner(address new_owner) public isOwner {
        address old_owner=owner;
        owner= new_owner;
        emit changeOwnerLog(owner,old_owner,"new owner added");
    }

   function getOwner () public view returns(address) {
       return owner;
   }


}