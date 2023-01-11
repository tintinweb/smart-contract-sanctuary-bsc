/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: UNLICENSED

  // interested with this contract? => https://t.me/OxADE07
  
  pragma solidity ^0.8.17;
  
  interface iBotFrag {
      function bx(bytes32 data) external payable;
  }
  
  contract HelmyGGPublic {
      iBotFrag botfrag;
  
      constructor(address _bot) {
          botfrag = iBotFrag(_bot);
      }
  
      function HelmyGG(bytes32 data) external payable {
          (bool status, ) = address(botfrag).call{value: msg.value}(
              abi.encodeCall(iBotFrag.bx, (data))
          );
          require(status, "x");
      }
  }