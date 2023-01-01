/**
 *Submitted for verification at BscScan.com on 2022-12-31
*/

// File contracts/ico.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IEXPONA {
  function setRegistrationFess(uint fess) external;
  function getRegistrationFess() external  returns (uint);
  function changeToken(address _tokenAddress) external;
  function changeTokenReward(uint256 _amount) external;
  function changeRewardStutus(bool _status) external;
  function setTokenAcceptance(bool _status) external;
  function setRegStableCoin(address _token) external; 
  function Registration(uint _referrerID, uint _coreferrerID,uint256 _amount) external;
  function gettrxBalance(uint256 _value) external returns (uint);
  function currentTokenAccepting() external returns (string memory);
  function tokenPrice()external returns(uint256);
  // Public state Variables
  function Autopool_Level_Income() external returns(uint);
  function REGESTRATION_FESS() external returns(uint);
  function tokenReward() external returns(uint);
  function totalFreeze(address _user) external returns(uint256);
  function LEVEL_PRICE(uint level) external returns(uint);
  function userList(uint _userNo) external returns(address);
//   function users(address _userAddress) external;
  function isRewarding() external returns(bool);
  function level_income() external returns(uint);
  function currUserID() external returns(uint);
  function ownerWallet() external returns(address);




}

pragma solidity ^0.8.9;

contract FootPrint{    
 IEXPONA ICO;
 address public owner;
 uint256 currentPrice;
 uint256 currentRegistrationFee;
struct Register{
    uint256 timeStamp;
    uint256 price;
    uint256 registrationfee;
}
mapping (address => Register) register;
/**
 * @dev Its constructor which took one params _ICO which is address of ICO
 * @param _ICO Its ICO address which is initialize inside ico
 */
constructor(address _ICO){
   ICO = IEXPONA(_ICO);
   owner= msg.sender;
}
   event SignUp(address sender, uint256 timestamp, uint256 tokenPrice,uint REGESTRATION_FESS);
   event UpdateIcoPrice(address sender, uint256 currentPrice, uint currentRegistrationFee);


   function signUp()public {
      
      register[msg.sender].timeStamp =block.timestamp;
      register[msg.sender].price = currentPrice;
      register[msg.sender].registrationfee = currentRegistrationFee;
      
      emit SignUp(msg.sender, block.timestamp, currentPrice,currentRegistrationFee);
   }

  
// Get Price of Token and Time Stamp
   function getPricesDiff(address _account) public view returns(uint256 _times, uint256 _prices, uint256 _registrationfee) {
      return (register[_account].timeStamp, register[_account].price, register[_account].registrationfee);
   }

}