/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

pragma solidity ^0.8.0;

interface SNS { 
	function transferFrom(address from, address to, uint amount) external returns (bool);
}

contract BatchTransfer {
    function batchTransfer(address coin_address ,address from, address[] memory to, uint[] memory values) 
        public 
        virtual
        returns (bool)
    {
        require(to.length > 0, "Address is null");
        
        SNS sns = SNS(coin_address);    
        for(uint j = 0; j < to.length; j++){
            sns.transferFrom(from, to[j], values[j]);
        }
 
        return true;
    }
}