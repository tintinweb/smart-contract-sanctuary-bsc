/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC1155/ERC1155Holder.sol";

pragma experimental ABIEncoderV2;
interface IGiftDApp {
  // Defining a User Reward Claim Data
    struct UserClaimData {
        uint8 bSpinAvlb;
        uint8 bSpinUsed;
        uint8 rSpinAvlb;
        uint8 rSpinUsed;
        uint256 time;
        uint256 pSpin;
    }

    function projectClaims(uint256 _id, address _addr) external view returns(UserClaimData memory _useClaim);
    function eventsCreated(address _creator) external view returns (uint256);
}

contract rigelNFTGiftDAppClaim  {
//  using SafeMath for uint256;

 struct Cards {
    uint256 id; 
    string uri;
    uint256  numOfReferral; 
    uint256  numOfSpin;
    uint256  numOfBuySpin;  
    uint256  numOfEvents;
  }

  struct tokens {
    address[] token;
    address giftProject;
    address giftInfluence;
  }

  struct Price {
    uint256 RGPPrice;
    uint256 BUSDPrice;
    uint256 USDTPrice;
  }
  
  address payable public _owner;
//   IERC20 public rigelToken;
  
  mapping (uint256 => Cards) public cards;
  mapping (uint256 => tokens) public getListedTokens;
  mapping (uint256 => Price) public pricePerToken;

 constructor(
     uint256 _id,
     address[] memory _tokensAddress, 
     address _giftProject, 
     address _giftInfluencer
    ) {
    // _owner = payable(_msgSender());
    tokens storage _token = getListedTokens[_id];
    // rigelToken = IERC20(_tokensAddress[0]);
    _token.token = _tokensAddress;
    _token.giftProject = _giftProject;
    _token.giftInfluence = _giftInfluencer;
  }
}