/**
 *Submitted for verification at BscScan.com on 2022-07-24
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
    function pow(uint256 a, uint256 b) internal pure returns (uint256) {
        return a ** b;
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

contract TaskanAirdrop{
    
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
        uint tokenDecimal; // decimal of the claim tokens
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
    
    function createAirdrop(IERC20Token Token_for_Drop, uint tokenDecimal, uint claimAmount) public 
        returns (address, address, uint, uint, uint, bool){
            AirdropController = msg.sender;
            token = Token_for_Drop;
            AirdropController = msg.sender;
            DropperInfo[AirdropController].claimerNumber = 1;
            DropData = dropDetails(address(this), msg.sender, tokenDecimal, 0, claimAmount, true);
            return(address(this), msg.sender, tokenDecimal, 0, claimAmount, true);
    }
    
    
    function ClaimAirdrop() public {
        dropReciever storage sender = DropperInfo[msg.sender];
        require(msg.sender != address(0), "the zero address cannot claim tokens");
        require(!sender.claimed, "Already Claimed tokens.");
        require(DropData.airdropActive != true, "This airdrop has already ended");
        uint claimTokenAmount = DropData.claimAmount.mul(10).pow(DropData.tokenDecimal);
        token.transfer(msg.sender, claimTokenAmount);
        DropData.totalUsersClaimed = DropData.totalUsersClaimed++;
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