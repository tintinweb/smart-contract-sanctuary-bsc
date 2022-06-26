/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function decimals() external returns (uint256);
}
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract TaskanAirdropFather{
    
    using SafeMath for uint;
    IERC20Token public token;
    uint index;
    
    struct dropReciever {
        address claimAddress; // address of the claimer
        bool claimed;  // if true, that person has already claimed coins
        uint claimerNumber;   // index of the voted proposal
    }

    struct dropDetails {
        address airdropAddress; // contract address of airdrop
        address airdropOwner; // Owner and controller of airdrop
        uint totalTokens; // total amount of tokens available to claim
        uint claimAmount; // amount of tokens each user can claim 
        uint totalUsersClaimed; // total amount of users that have claimed airdrop tokens
        bool airdropActive; // Is true when airdrop can be claimed, default is false
    }
    
     //fetch dropper information by address
     mapping(address => dropReciever) public DropperInfo;
     
     //fecth dropper info by index
     dropReciever[] public DropperByIndex;

     dropDetails public DropData;
    /**
     * Controller modifier
     **/
    
     address public AirdropController;
     modifier onlyController() {
     require(msg.sender == AirdropController, "You are not the controller of this airdrop");
     _;
    }
    /**
     * End Controller modifier
     **/
    
    function createAirdrop(IERC20Token Token_for_Drop, uint totalDropTokens, uint claimAmount) public returns (address, address, uint, uint, uint, bool){
        AirdropController = msg.sender;
        token = Token_for_Drop;
        AirdropController = msg.sender;
        DropperInfo[AirdropController].claimerNumber = 1;
        DropData = dropDetails(address(this), msg.sender, totalDropTokens, 0, claimAmount, true);
        return(address(this), msg.sender, totalDropTokens, 0, claimAmount, true);
    }
    
    
    function ClaimAirdrop() public {
        dropReciever storage sender = DropperInfo[msg.sender];
        require(msg.sender != address(0), "the zero address cannot claim tokens");
        require(!sender.claimed, "Already Claimed tokens.");
        require(DropData.airdropActive != true, "This airdrop has already ended");
        token.transfer(msg.sender, DropData.claimAmount);
        DropData.totalUsersClaimed = DropData.totalUsersClaimed++;
        DropData.totalTokens = DropData.totalTokens.sub(DropData.claimAmount);
        sender.claimed = true;
        DropperInfo[msg.sender].claimAddress = msg.sender;
        DropperInfo[msg.sender].claimed = true;
        DropperInfo[msg.sender].claimerNumber = 1;
        DropperByIndex.push(dropReciever({
                claimAddress: msg.sender,
                claimed : true,
                claimerNumber: index++}));
    }
    
    
    function DropInfo() external view returns(dropReciever[] memory){
         return DropperByIndex;
     }
    
    //remove Tokens remaining
    function tokenRemover()public onlyController{
         token.transfer(AirdropController,token.balanceOf(address(this)));
    }
    
    function controlAirdrop()public onlyController{
        DropData.airdropActive = !DropData.airdropActive;
    }
    
}

contract CloneFactory { 
 
  function createClone(address target) internal returns (address result) { 
    bytes20 targetBytes = bytes20(target); 
    assembly { 
      let clone := mload(0x40) 
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000) 
      mstore(add(clone, 0x14), targetBytes) 
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000) 
      result := create(0, clone, 0x37) 
    } 
  } 
 
  function isClone(address target, address query) internal view returns (bool result) { 
    bytes20 targetBytes = bytes20(target); 
    assembly { 
      let clone := mload(0x40) 
      mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000) 
      mstore(add(clone, 0xa), targetBytes) 
      mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000) 
 
      let other := add(clone, 0x40) 
      extcodecopy(query, other, 0, 0x2d) 
      result := and( 
        eq(mload(clone), mload(other)), 
        eq(mload(add(clone, 0xd)), mload(add(other, 0xd))) 
      ) 
    } 
  } 
} 

contract TaskanAirdropFactory is CloneFactory{
    address public masterContract;
    TaskanAirdropFather[] public clones;
    uint totalDrops;

    constructor (address _Father) {
        masterContract = _Father;
    }

    function createAirdrop(IERC20Token airdropToken, uint tokensPerClaim, uint claimAmount) external{
        TaskanAirdropFather clone = TaskanAirdropFather(createClone(masterContract));
        clone.createAirdrop(airdropToken, tokensPerClaim, claimAmount);
        clones.push(clone);
        totalDrops++;
    }

    function getNewDrop()public view returns(TaskanAirdropFather){
        return(clones[clones.length - 1]);
    }

    function allClonesAddresses()external view returns(TaskanAirdropFather[] memory){
        TaskanAirdropFather[] memory allTaskanAirdrops = clones;
        return(allTaskanAirdrops);
    }

    function allClonesAmount()public view returns(uint){
        return(totalDrops);
    }

}