/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Token {
    function balanceOf(address who) external view returns (uint256);
    function allowance(address poolReciever, address spender) external  view returns (uint);
    function transfer(address to, uint amount) external  returns (bool ok);
    function transferFrom(address from, address to, uint amount) external returns (bool ok);
    function decimals() external returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
}
interface ERC20Token {
    function balanceOf(address who) external view returns (uint256);
    function allowance(address poolReciever, address spender) external  view returns (uint);
    function transfer(address to, uint amount) external  returns (bool ok);
    function transferFrom(address from, address to, uint amount) external returns (bool ok);
    function decimals() external returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
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


contract AirdropFactory is CloneFactory {
     Child[] public children;
     address masterContract;
     uint256 public deployedAirDrops;
     constructor(address _masterContract){
         masterContract = _masterContract;
     }

    event NewAirdrop(address indexed _from, address indexed _to);
     
     function createNewAirdrop(IERC20Token Token_for_Drop, 
        uint256 _tokenDecimal, 
        uint256 dropTokenAmount,
        uint256 _totalRecievers, 
        uint8 _referralDrop,
        uint256 _referralAmount)internal{
          address factor = address(this);
          _createNewAirdrop(
              Token_for_Drop, 
              _tokenDecimal, 
              dropTokenAmount,
              _totalRecievers, 
              _referralDrop,
              _referralAmount);
          emit NewAirdrop(factor, address(children[deployedAirDrops]));
        }


     function _createNewAirdrop(
        IERC20Token Token_for_Drop, 
        uint256 _tokenDecimal, 
        uint256 dropTokenAmount,
        uint256 _totalRecievers, 
        uint8 _referralDrop,
        uint256 _referralAmount
        ) internal{
        
        Child child = Child(createClone(masterContract));
        child.Contract_Setup(Token_for_Drop, 
        _tokenDecimal, 
        dropTokenAmount,
        _totalRecievers, 
        _referralDrop,
        _referralAmount);
        children.push(child);
        deployedAirDrops ++;
     }
    
    function getChild() external view returns(address child){
         return address(children[deployedAirDrops]);
     }
    
     function getChildren() external view returns(Child[] memory){
         return children;
     }
}

contract Child{
  IERC20Token token;//Ksspad main Token
  bool REFERRAL_DROP; // when true, a referral address is granted benefits
  bool DROP_TYPE; // when true, total claimers are limited otherwise it is unlimited
  uint256 TOKEN_DECIMAL; // demimal of the token available for airdrop
  uint256 TOTAL_RECIEVERS; // total amount of recievers for airdrop
  uint256 DROP_AMOUNT; // amount of tokens earned by each reciever
  uint256 REFERRAL_AMOUNT; // amount of tokens earned by eachc refferer
    
    
 function Contract_Setup( 
        IERC20Token Token_for_Drop, 
        uint256 _tokenDecimal, 
        uint256 dropTokenAmount,
        uint256 _totalRecievers, 
        uint8 _referralDrop,
        uint256 _referralAmount
        ) external{
        token = Token_for_Drop;
        TOKEN_DECIMAL = _tokenDecimal;
        DROP_AMOUNT = dropTokenAmount;
        TOTAL_RECIEVERS = _totalRecievers;
        REFERRAL_DROP = _referralDrop == 1;
        REFERRAL_AMOUNT = _referralAmount;
        address AirdropController = msg.sender;
    }
}