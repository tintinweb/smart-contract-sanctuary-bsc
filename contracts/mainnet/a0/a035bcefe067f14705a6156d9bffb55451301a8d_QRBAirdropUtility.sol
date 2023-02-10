/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract QRBAirdropUtility {

    mapping (address => bool) public isAuthorized;
    address public _token;

    constructor(address startingToken) {
	    _token = startingToken;

	    isAuthorized[msg.sender] = true;
    }

    modifier onlyAuth {
	    require(isAuthorized[msg.sender], "Caller not authorized");
	    _;
    }

    function distributeTokens(address[] memory _airdropAddresses, uint amtPerAddress) external onlyAuth {
	    for (uint i = 0; i < _airdropAddresses.length; i++) {
	        IERC20(_token).transfer(_airdropAddresses[i], amtPerAddress);
        }
    }

    function addAuthorized(address newAuth) external onlyAuth {
	    isAuthorized[newAuth] = true;
    }

    function changeToken(address newToken) external onlyAuth {
	_token = newToken;
    }

}