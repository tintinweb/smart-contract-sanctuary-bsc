/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IPOLYCONTRACT {
    function getRingBous(address user) external view returns (uint256);
    function updateRingBous(address user) external returns (bool);
    function placeInRing(address user) external returns (bool);
}

contract VaraGoldRing is IPOLYCONTRACT {

    address public contractOwner;
    uint256 public totalRingIncome;

    //Ring Setting 
    uint public ringWidth = 4;
    uint public rewardRing1 = 1000000000;
    uint public rewardRing2 = 4500000000;
    uint public rewardRing3 = 4500000000;
    uint public rewardRing4 = 22500000000;
    uint public rewardRing5 = 22500000000;
    uint public rewardRing6 = 112500000000;
    uint public rewardRing7 = 112500000000;
    uint public rewardRing8 = 112500000000;
    uint public rewardRing9 = 562500000000;
    uint public rewardRing10 = 10000000000000;

    uint public ring1QueueIndex=0;
    uint public ring2QueueIndex=0;
    uint public ring3QueueIndex=0;
    uint public ring4QueueIndex=0;
    uint public ring5QueueIndex=0;
    uint public ring6QueueIndex=0;
    uint public ring7QueueIndex=0;
    uint public ring8QueueIndex=0;
    uint public ring9QueueIndex=0;
    uint public ring10QueueIndex=0;

    address[] public ring1QualifierList;
    address[] public ring2QualifierList;
    address[] public ring3QualifierList;
    address[] public ring4QualifierList;
    address[] public ring5QualifierList;
    address[] public ring6QualifierList;
    address[] public ring7QualifierList;
    address[] public ring8QualifierList;
    address[] public ring9QualifierList;
    address[] public ring10QualifierList;

    struct UserIncomeDetails {
        uint256 totalBonus;
        uint256 creditedWallet;
        uint256 usedWallet;
        uint256 availableWallet;
    }

    struct UserRingIncomeDetails {
        uint256 totalRing1Bonus;
        uint256 totalRing2Bonus;
        uint256 totalRing3Bonus;
        uint256 totalRing4Bonus;
        uint256 totalRing5Bonus;
        uint256 totalRing6Bonus;
        uint256 totalRing7Bonus;
        uint256 totalRing8Bonus;
        uint256 totalRing9Bonus;
        uint256 totalRing10Bonus;
    }

    mapping (address => UserIncomeDetails) public _UserIncomeDetails;
    mapping (address => UserRingIncomeDetails) public _UserRingIncomeDetails;

    constructor() public {
      address _contractOwner=0x4421Aa95118eF4EE30D9f5B86F6C7443cd0433ED;
      contractOwner =_contractOwner;
      ring1QualifierList.push(_contractOwner);
      ring2QualifierList.push(_contractOwner);
      ring3QualifierList.push(_contractOwner);
      ring4QualifierList.push(_contractOwner);
      ring5QualifierList.push(_contractOwner);
      ring6QualifierList.push(_contractOwner);
      ring7QualifierList.push(_contractOwner);
      ring8QualifierList.push(_contractOwner);
      ring9QualifierList.push(_contractOwner);
      ring10QualifierList.push(_contractOwner);
    }

    //Get Total Ring Bonus
    function getRingBous(address user) public view override returns (uint256) {
        return (_UserIncomeDetails[user].availableWallet);
    }

    //Update Ring Bonus
    function updateRingBous(address user) public override returns (bool) {
      require(user==msg.sender, 'No Rights !');
      _UserIncomeDetails[user].usedWallet += _UserIncomeDetails[user].availableWallet;
      _UserIncomeDetails[user].availableWallet -= _UserIncomeDetails[user].availableWallet; 
      return true;
    }

    //Place In Ring
    function placeInRing(address user) public override returns (bool) {
      require(user==msg.sender, 'No Rights !');
      _PlaceInRing1(msg.sender);
      return true;
    }

    function _PlaceInRing1(address user) private {
      ring1QualifierList.push(user);
      uint Length=ring1QualifierList.length;
      Length -= 1;
      if((Length%ringWidth)==0){
         uint Index=Length/ringWidth;
         Index -= 1;
         address placementId=ring1QualifierList[Index];
         //Comment Distribution Start Here
         _UserRingIncomeDetails[placementId].totalRing1Bonus += rewardRing1;
         _UserIncomeDetails[placementId].totalBonus += rewardRing1;
         _UserIncomeDetails[placementId].creditedWallet += rewardRing1;
         _UserIncomeDetails[placementId].availableWallet += rewardRing1;
         totalRingIncome += rewardRing1;
         //Comment Distribution Start Here
         _PlaceInRing2(placementId);
      }
    }

    function _PlaceInRing2(address user) private {
      ring2QualifierList.push(user);
      uint Length=ring2QualifierList.length;
      Length -= 1;
      if((Length%ringWidth)==0){
         uint Index=Length/ringWidth;
         Index -= 1;
         address placementId=ring2QualifierList[Index];
         //Comment Distribution Start Here
         _UserRingIncomeDetails[placementId].totalRing2Bonus += rewardRing2;
         _UserIncomeDetails[placementId].totalBonus += rewardRing2;
         _UserIncomeDetails[placementId].creditedWallet += rewardRing2;
         _UserIncomeDetails[placementId].availableWallet += rewardRing2;
         totalRingIncome += rewardRing2;
         //Comment Distribution Start Here
         _PlaceInRing3(placementId);
         _PlaceInRing1(placementId);
      }
    }

    function _PlaceInRing3(address user) private {
      ring3QualifierList.push(user);
      uint Length=ring3QualifierList.length;
      Length -= 1;
      if((Length%ringWidth)==0){
         uint Index=Length/ringWidth;
         Index -= 1;
         address placementId=ring3QualifierList[Index];
         //Comment Distribution Start Here
         _UserRingIncomeDetails[placementId].totalRing3Bonus += rewardRing3;
         _UserIncomeDetails[placementId].totalBonus += rewardRing3;
         _UserIncomeDetails[placementId].creditedWallet += rewardRing3;
         _UserIncomeDetails[placementId].availableWallet += rewardRing3;
         totalRingIncome += rewardRing3;
         //Comment Distribution Start Here
         _PlaceInRing4(placementId);
         _PlaceInRing3(placementId);
      }
    }

    function _PlaceInRing4(address user) private {
      ring4QualifierList.push(user);
      uint Length=ring4QualifierList.length;
      Length -= 1;
      if((Length%ringWidth)==0){
         uint Index=Length/ringWidth;
         Index -= 1;
         address placementId=ring4QualifierList[Index];
         //Comment Distribution Start Here
         _UserRingIncomeDetails[placementId].totalRing4Bonus += rewardRing4;
         _UserIncomeDetails[placementId].totalBonus += rewardRing4;
         _UserIncomeDetails[placementId].creditedWallet += rewardRing4;
         _UserIncomeDetails[placementId].availableWallet += rewardRing4;
         totalRingIncome += rewardRing4;
         //Comment Distribution Start Here
         _PlaceInRing5(placementId);
      }
    }

    function _PlaceInRing5(address user) private {
      ring5QualifierList.push(user);
      uint Length=ring5QualifierList.length;
      Length -= 1;
      if((Length%ringWidth)==0){
         uint Index=Length/ringWidth;
         Index -= 1;
         address placementId=ring5QualifierList[Index];
         //Comment Distribution Start Here
         _UserRingIncomeDetails[placementId].totalRing5Bonus += rewardRing5;
         _UserIncomeDetails[placementId].totalBonus += rewardRing5;
         _UserIncomeDetails[placementId].creditedWallet += rewardRing5;
         _UserIncomeDetails[placementId].availableWallet += rewardRing5;
         totalRingIncome += rewardRing5;
         //Comment Distribution Start Here
         _PlaceInRing6(placementId);
         _PlaceInRing5(placementId);
      }
    }

    function _PlaceInRing6(address user) private {
      ring6QualifierList.push(user);
      uint Length=ring6QualifierList.length;
      Length -= 1;
      if((Length%ringWidth)==0){
         uint Index=Length/ringWidth;
         Index -= 1;
         address placementId=ring6QualifierList[Index];
         //Comment Distribution Start Here
         _UserRingIncomeDetails[placementId].totalRing6Bonus += rewardRing6;
         _UserIncomeDetails[placementId].totalBonus += rewardRing6;
         _UserIncomeDetails[placementId].creditedWallet += rewardRing6;
         _UserIncomeDetails[placementId].availableWallet += rewardRing6;
         totalRingIncome += rewardRing6;
         //Comment Distribution Start Here
         _PlaceInRing7(placementId);
      }
    }

    function _PlaceInRing7(address user) private {
      ring7QualifierList.push(user);
      uint Length=ring7QualifierList.length;
      Length -= 1;
      if((Length%ringWidth)==0){
         uint Index=Length/ringWidth;
         Index -= 1;
         address placementId=ring7QualifierList[Index];
         //Comment Distribution Start Here
         _UserRingIncomeDetails[placementId].totalRing7Bonus += rewardRing7;
         _UserIncomeDetails[placementId].totalBonus += rewardRing7;
         _UserIncomeDetails[placementId].creditedWallet += rewardRing7;
         _UserIncomeDetails[placementId].availableWallet += rewardRing7;
         totalRingIncome += rewardRing7;
         //Comment Distribution Start Here
         _PlaceInRing8(placementId);
      }
    }

    function _PlaceInRing8(address user) private {
      ring8QualifierList.push(user);
      uint Length=ring8QualifierList.length;
      Length -= 1;
      if((Length%ringWidth)==0){
         uint Index=Length/ringWidth;
         Index -= 1;
         address placementId=ring8QualifierList[Index];
         //Comment Distribution Start Here
         _UserRingIncomeDetails[placementId].totalRing8Bonus += rewardRing8;
         _UserIncomeDetails[placementId].totalBonus += rewardRing8;
         _UserIncomeDetails[placementId].creditedWallet += rewardRing8;
         _UserIncomeDetails[placementId].availableWallet += rewardRing8;
         totalRingIncome += rewardRing8;
         //Comment Distribution Start Here
         _PlaceInRing9(placementId);
         _PlaceInRing7(placementId);
      }
    }

    function _PlaceInRing9(address user) private {
      ring9QualifierList.push(user);
      uint Length=ring9QualifierList.length;
      Length -= 1;
      if((Length%ringWidth)==0){
         uint Index=Length/ringWidth;
         Index -= 1;
         address placementId=ring9QualifierList[Index];
         //Comment Distribution Start Here
         _UserRingIncomeDetails[placementId].totalRing9Bonus += rewardRing9;
         _UserIncomeDetails[placementId].totalBonus += rewardRing9;
         _UserIncomeDetails[placementId].creditedWallet += rewardRing9;
         _UserIncomeDetails[placementId].availableWallet += rewardRing9;
         totalRingIncome += rewardRing9;
         //Comment Distribution Start Here
         _PlaceInRing10(placementId);
      }
    }

    function _PlaceInRing10(address user) private {
      ring10QualifierList.push(user);
      uint Length=ring10QualifierList.length;
      Length -= 1;
      if((Length%ringWidth)==0){
         uint Index=Length/ringWidth;
         Index -= 1;
         address placementId=ring10QualifierList[Index];
         //Comment Distribution Start Here
         _UserRingIncomeDetails[placementId].totalRing10Bonus += rewardRing10;
         _UserIncomeDetails[placementId].totalBonus += rewardRing10;
         _UserIncomeDetails[placementId].creditedWallet += rewardRing10;
         _UserIncomeDetails[placementId].availableWallet += rewardRing10;
         totalRingIncome += rewardRing10;
         //Comment Distribution Start Here
         _PlaceInRing9(placementId);
      }
    }

}