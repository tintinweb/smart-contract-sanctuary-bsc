/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

pragma solidity ^0.4.16;
contract ERC20 {
    function transferFrom( address from, address to, uint value) returns (bool ok);
}

contract Staking {
    mapping (address => uint256) public stakingnum;
    uint public allstakingnum;
    string public lastoid;
    
    event stakinglog(address _tokenAddress,address _to, uint256 _value,string _oid);
    
	function staking(address _tokenAddress,address _to, uint256 _value,string _oid) returns (bool) {
        stakinglog(_tokenAddress,_to, _value,_oid);
		ERC20 token = ERC20(_tokenAddress);
			assert(token.transferFrom(msg.sender, _to, _value) == true);//transferFrom approve
            allstakingnum+=_value;
            stakingnum[msg.sender]+=_value;
            lastoid=_oid;
        
		return true;
	}
    
}