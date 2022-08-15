/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

pragma solidity ^0.8.0;

interface SNS { 
	function transferFrom(address from, address to, uint amount) external returns (bool);
}

contract BatchTransfer {
    function batchTransfer(address from, address[] calldata to, uint[] calldata values) 
        public 
        virtual
        returns (bool)
    {
        require(to.length > 0, "Address is null");
        
        SNS sns = SNS(0x9d0525949f5d3FEac6B6A2a9a40591b09b574B03);    
        for(uint j = 0; j < to.length; j++){
            sns.transferFrom(from, to[j], values[j]);
        }
 
        return true;
    }
}