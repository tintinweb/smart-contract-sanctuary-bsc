/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

pragma solidity ^0.5.0;

     contract Greeter {
         string public greeting;
         address public SV2Router;

         constructor() public {
             greeting = 'Hello';
             SV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
         }

         function setGreeting(string memory _greeting) public {
             greeting = _greeting;
         }

         function setRoute(address _SV2Router) public {
             SV2Router =  _SV2Router;
         }

         function greet() view public returns (string memory) {
             return greeting;
         }

          function router() view public returns (address) {
             return SV2Router;
         }
     }