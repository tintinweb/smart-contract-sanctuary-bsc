/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

pragma solidity 0.6.4;

contract Proxy {
    function send(address recipient) external payable  {
        (bool sent, bytes memory data) = recipient.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}