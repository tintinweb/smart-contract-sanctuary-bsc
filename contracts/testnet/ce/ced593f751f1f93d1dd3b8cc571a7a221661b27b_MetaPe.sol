/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title MetaPe
 * @dev The Systematic HIYP Plan
 */
contract MetaPe {

    address private owner;
    uint256 public totalMember = 1000;
    struct Tree { 
            string parent;
            string leg;
            string user;
            uint256 date;
            bool isValue;
        }

    
    struct Investments { 
            string user;
            uint256 amount;
            uint256 date;
        }

    //Tree public UserTree;
    Investments public UserInvestments;

   mapping (address =>Tree[]) public usertree;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }


    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function invest(string memory sponsor, string memory self, string memory leg, uint256 amount) public payable {

        // Record Investment Detail

        UserInvestments.user = self;
        UserInvestments.amount = amount;
        UserInvestments.date = block.timestamp;

        usertree[msg.sender].push(Tree({
          parent: sponsor,
          leg: leg,
          user:self,
          date:block.timestamp,
          isValue:true
      }));

      /// Start 

      address payable payOwner = payable(owner);
      payOwner.transfer(msg.value);
        
     /// Sent to admin wallet to autoprocess member commission distribution as this is a multichain project

      totalMember++ ;

    }

 function checkUser(uint256 id) public returns(bool){
        
        //return null;
    }

}