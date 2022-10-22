/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

pragma solidity ^0.8.7;

contract Token {
    string public name = "TriBIM Token";
    string public symbol = "TBIM";
    uint256 public totalSupply = 1000000 * 10**18;
    uint256 public totalDestroy = 0;
    uint8 public decimals = 18;
    address public admin = 0xba6Dc4b1Cd0606FB895FdBa5119552B7Ae486BBD;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);

    mapping(address => uint256) public balances;
    //mapping(address => uint256) public balances_lock;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() {
        balances[msg.sender] = totalSupply;
        admin = msg.sender;
    }

    function balanceOf(address owner) public returns (uint256) {
        return balances[owner];
    }

    function change_admin(address NewAdmin) public returns (bool) {
        require(msg.sender == admin, "no auth.");
        admin = NewAdmin;
        return true;
    }
    
    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, "balance too low");
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function lock(uint256 value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, "balance too low");
        balances[msg.sender] -= value;
        //一半销毁，一半存入管理钱包
        balances[admin] += value/2;
        totalSupply -= value/2;

        //emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(balanceOf(from) >= value, "balance too low");
        require(allowance[from][msg.sender] >= value, "allowance too low");
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}