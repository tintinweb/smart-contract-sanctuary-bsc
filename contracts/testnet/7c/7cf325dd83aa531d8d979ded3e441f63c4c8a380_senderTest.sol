/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

pragma solidity 0.4.25;

    contract senderTest{
        uint public aStorage;
        mapping(address => bytes32) public signature;
        function testRead(uint a, uint b) public view returns(address, uint)
        {
            return (msg.sender, a+b);
        }

        function increase() public returns(uint){
            aStorage++;
            return aStorage;
        }

        function testSendRead() public returns(bytes32, uint)
        {
            bytes32 test= keccak256(abi.encodePacked(block.timestamp,aStorage ));
            return (test, aStorage );
            signature[msg.sender] = test;
        }

    }