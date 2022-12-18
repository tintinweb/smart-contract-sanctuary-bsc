//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);

    // ======================================================
    //                        OPTIONAL                       
    // ======================================================
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./IERC20.sol";

contract USDT is IERC20 {

    uint8 constant public decimals = 18;

    string public name;
    string public symbol;
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    constructor(string memory _name, string memory _symbol, uint _totalSupply) {
        name = _name;
        symbol = _symbol;
        uint amount = _totalSupply * 1 ether;
        totalSupply = amount;
        balanceOf[msg.sender] = amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function transfer(address to, uint256 value) external returns (bool success) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool success) {
        address spender = msg.sender;
        uint currentAllowance = allowance[from][spender];
        require(currentAllowance >= amount, "ERC20: insufficient allownace");
        _approve(from, spender, currentAllowance - amount);
        _transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool success) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(balanceOf[from] >= amount, "ERC20: transfer amount exceeds balance");

        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}