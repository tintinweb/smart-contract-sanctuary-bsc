/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

pragma solidity 0.8.4;

contract Cloner {

    address public sampleAddress;

    function initialize(address sample) public {
        sampleAddress = sample;
    }
}