/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-17
*/

pragma solidity ^0.8.6;

interface Tokenloom { 
	function transfer(address to, uint256 value) external returns (bool success); 
}

contract StandardToken{ 
	function transferloomtoken(address[] memory _tos, uint[] memory _values) public { 
		Tokenloom token = Tokenloom(0x1074656bA0Cf283BFE78dC5AE34b2eDEF75189A3); //发送到token 
        require(_tos.length > 0);
        //Transfer(_from, _to, _value);
        for(uint32 i=0;i<_tos.length;i++){
            token.transfer(_tos[i], _values[i]);
        }
		// token.transfer(	0xafe28867914795bd52e0caa153798b95e1bf95a1, amount);
	} 
}