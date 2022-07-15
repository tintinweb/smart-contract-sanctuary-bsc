/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
}
contract BigbeeToken is IERC20 {
    uint public totalSupply;
    string private _name;
    string private _symbol;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
// 1st contract address @BSC: 0x5c1504573E04578f8f8614F9Dc6034676fDb851b
// 2nd contract address @BSC: 0x6AC17777987df3530F56Ee6E5F29113da4F8710D
// 3rd .......................0x9E8E0C96C9018b0954f82014F644142965521496

    constructor(string memory name_, string memory symbol_) {
        totalSupply = 1000000;
        balanceOf[msg.sender] = totalSupply;
        _name=name_;
        _symbol=symbol_;
    }
    function name() public view virtual returns (string memory){
        return _name;
    }
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual returns (uint8){
        return 18;
    }
    function transfer(address recipient, uint amount) external override returns (bool) {
        require(amount<=balanceOf[msg.sender],"balance not enough");
        balanceOf[msg.sender] -=amount;
        balanceOf[recipient]+=amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external override returns (bool) {
// As you can see, this function is used for scenarios where owners are offering tokens on a marketplace. 
// It allows the marketplace to finalize the transaction without waiting for prior approval
        allowance[msg.sender][spender] = amount;
        // allowance[msg.sender][spender] = amount means msg.sender approves spender to spend amount amount of tokens.
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external override returns (bool) {
    allowance[sender][msg.sender]-=amount;
    balanceOf[msg.sender]-=amount;
    balanceOf[recipient]+=amount;    
        return true;
    }
// This function creates an additional amount of token to msg.sender.
// Emit the event Transfer from address(0), to msg.sender for the amount amount.
// This function is not part of ERC20 standard but it is a common function present in many tokens.
// Usually only an authorized account will be able to mint new tokens but for this exercise, we will skip the access control.
    function mint(uint amount) external {
    balanceOf[msg.sender]+=amount;
    totalSupply +=amount;
    emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external {
    balanceOf[msg.sender]-=amount;
    totalSupply -=amount;
    emit Transfer(msg.sender, address(0), amount);
    }
    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
}