/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract ReportDApp {    

      struct report {
         string text;
         string img_hash;
      }

      mapping (uint => mapping(address => report)) public reports;
      report[] public reportArray;

      function addReport(string memory _text, string memory _img_hash) public returns (bool) {
           reports[reportArray.length][msg.sender] = report(_text, _img_hash);
           reportArray.push(report(_text, _img_hash));
           return true;
      }
      
}