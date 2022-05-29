/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// File: accumulation.sol


pragma solidity ^0.8.9;

contract accumulation {

    mapping(uint => address) addresses;
    address owner;
    
    constructor(address _owner){
        owner = _owner;
        // addresses[1] = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        //  addresses[2] = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
        //  addresses[3] = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
        // addresses[4] = ;
        // addresses[5] = ;
        // addresses[6] = ;
        // addresses[7] = ;
        // addresses[8] = ;
        // addresses[9] = ;
        // addresses[10] = ;
        // addresses[11] = ;
        // addresses[12] = ;
        // addresses[13] = ;
        // addresses[14] = ;
        // addresses[15] = ;
        // addresses[16] = ;
        // addresses[17] = ;
        // addresses[18] = ;
        // addresses[19] = ;
        // addresses[20] = ;
        // addresses[21] = ;
        // addresses[22] = ;
        // addresses[23] = ;
        // addresses[24] = ;
        // addresses[25] = ;
        // addresses[26] = ;
        // addresses[27] = ;
        // addresses[28] = ;
        // addresses[29] = ;
        // addresses[30] = ;
        // addresses[31] = ;
        // addresses[32] = ;
        // addresses[33] = ;
        // addresses[34] = ;
        // addresses[35] = ;
        // addresses[36] = ;
        // addresses[37] = ;
        // addresses[38] = ;
        // addresses[39] = ;
        // addresses[40] = ;

    }

    receive() external payable {
        uint value = msg.value;
        if (value < 5000000000000000) {  
            (bool success, ) = msg.sender.call{value: value}("");
            require(success, "Failed");
        } else {
             transaction(value);
        }
    }

    modifier onlyOwner() {
        require (msg.sender == owner, "you are not owner");
        _;
    }

    function transaction (uint value) internal {
        uint remainder = value % 40;
        for (uint i = 1; i<=40; i++) {
            uint sendValue =value/40;
            if (i <= remainder) {
                sendValue++;
            } 
            (bool success, ) = addresses[i].call{value: sendValue}("");
            require(success, "Failed");
            }
    }

    function withdraw(address _receiver) external onlyOwner {
        (bool success, ) = _receiver.call{value: address(this).balance}("");
        require(success, "Failed");
    }
}