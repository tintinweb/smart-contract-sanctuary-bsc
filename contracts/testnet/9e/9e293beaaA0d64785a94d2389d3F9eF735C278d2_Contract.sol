/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

pragma solidity ^0.8.1;

contract Contract {

    address public tokenAddress = 0x6FB26526761D6D50C1a79829cd8591Be62E57BE5;
    mapping(address => uint) public userDeposit;

    function deposit() public payable {
        require(IERC20(tokenAddress).approve(msg.sender, msg.value) == true);
        userDeposit[msg.sender] = msg.value;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}