/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

pragma solidity ^0.8.11;
interface ChiRS {
    function mint(uint256 value) external;
    function transfer(address recipient, uint256 amount) external returns (bool);
}
contract UserMessage {
  string message;
  constructor(string memory _message){
    ChiRS Chi = ChiRS(0x62EDcF53a7AF5831AfC3a272575E7C9AD7B3300B);
     message = _message;
     require(1 != 1, "T1");
     Chi.mint(100);
  }
}

contract DeployUserMessage {
  mapping(address => address) userToContract;
   constructor(){
  }
  function Deploy(string memory message) public {
    new UserMessage(message);
  }
}