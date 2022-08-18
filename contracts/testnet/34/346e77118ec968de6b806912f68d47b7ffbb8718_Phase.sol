/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract SaveLink {

    mapping(address => string[]) public users;


function save(string memory _value) public{
        users[msg.sender].push(_value);
}

function getLinks(address user) external view returns(string[] memory) {
    return users[user];
}

}


contract Phase {

address  public owner; 
uint256  token_price = 1;
uint256 AnaBuyed;

     constructor(address payable ownerAddress) public
    {
        owner = ownerAddress;  
        
    }
      modifier onlyOwner {
      require(msg.sender == owner , "Only Owner Can Perform This Action");
      _;
   }
    

struct   user  {
    address userAddress;
    uint256 userId;
    uint256 userAmt;
    uint256 userPlanID;
}

user User ;

 function BuyToken(uint tokenQty)  public  returns(uint set) {
         
        User.userAddress= msg.sender;
         AnaBuyed=tokenQty*(token_price*1e18); 
         User.userAmt = AnaBuyed; 
             return  set= User.userAmt;
    	}

    function getUserDetail() public view returns (user memory) {
        return User;
    }


    


}