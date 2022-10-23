/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

// File: contracts/bepBridge.sol


pragma solidity ^0.8.0;

interface IERC20{
    function mint(address account,uint256 amount) external;
    function burn(address account,uint256 amount) external;
}

contract BBridge is IERC20{
    IERC20  public token;
    constructor(address _token) {
        token = IERC20(_token);
    }

    function mint(address account, uint256 amount) public{
        token.mint(account, amount);
    }

    function burn(address account, uint256 amount) public{
        token.mint(account, amount);
    }

}