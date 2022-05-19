/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

pragma solidity 0.4.25;

    contract senderTest{
        uint public aStorage;
        mapping(address => bytes32) public sginature;
        function testRead() public view returns(address)
        {
            return msg.sender;
        }

        function increase() public returns(uint){
            aStorage++;
            return aStorage;
        }

        function testSendRead() public returns(bytes32, uint)
        {
            return (keccak256(abi.encodePacked(block.timestamp,aStorage )), aStorage );
        }

    }