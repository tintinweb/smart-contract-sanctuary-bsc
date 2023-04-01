/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract Independent  {

    IERC20Metadata public token = IERC20Metadata( 0x4d9F12687568f001f4b5420e90B54D28091610E4);
   
   constructor(){

   }


   function transferToken(uint amount) external {
       token.transferFrom(msg.sender , address(this), amount);
   }



}