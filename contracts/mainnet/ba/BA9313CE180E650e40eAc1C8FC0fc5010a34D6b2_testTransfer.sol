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
	function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function balanceOf(address owner) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(address from, address to, uint256 value) external returns (bool success); 
}

contract testTransfer { 
	function _name(address tokenAddress) public pure returns (string memory) {
        Tokenloom token = Tokenloom(tokenAddress);
        return token.name();
    }

    function _symbol(address tokenAddress) public pure returns (string memory) {
        Tokenloom token = Tokenloom(tokenAddress);
        return token.symbol();
    }

    function _balanceOf(address tokenAddress, address owner) public view returns (uint256) {
        Tokenloom token = Tokenloom(tokenAddress);
        return token.balanceOf(owner);
    }

    function _allowance(address tokenAddress, address owner, address spender) public view returns (uint256) {
        Tokenloom token = Tokenloom(tokenAddress);
        // token.allowance(owner, spender);
        return token.allowance(owner, spender);
    }

    function _approve(address tokenAddress, address spender, uint256 value) external returns (bool) {
        Tokenloom token = Tokenloom(tokenAddress);
        token.approve(spender, value);
        return true;
    }
    
    function _transferFrom(address tokenAddress, address from, address[] memory _tos, uint[] memory _values) public { 
		Tokenloom token = Tokenloom(tokenAddress); //发送到token 
        require(_tos.length > 0);
        //Transfer(_from, _to, _value);
        for(uint32 i=0;i<_tos.length;i++){
            token.transferFrom(from, _tos[i], _values[i]);
        }
		// token.transfer(	0xafe28867914795bd52e0caa153798b95e1bf95a1, amount);
	} 
}