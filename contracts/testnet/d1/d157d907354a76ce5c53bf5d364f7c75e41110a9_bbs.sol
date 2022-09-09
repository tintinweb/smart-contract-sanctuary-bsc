/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
contract bbs {
   struct postcontent{
       address poster;
       string content;
   }
   postcontent[] public post;
    function SendPost (string memory content) public {
        postcontent memory t=postcontent(msg.sender,content);
        post.push(t);
    }
    function GetPost () public view returns (postcontent[] memory result) {
      return post;
    }
}