/**
 *Submitted for verification at BscScan.com on 2022-10-27
*/

pragma solidity ^0.8.7;

contract Token {
    string public name = "kgtdao";
    string public symbol = "KGTDAO";
    uint256 public totalSupply  = 1000000 * 10**18;
    uint256 public totalDestroy = 0;
    uint256 public totalStaking = 0;
    uint8 public decimals = 18;
    address public owner = address(0);


    event Staking (address indexed from, uint256 total_usd,uint256 price_bnb,uint256 price_token,uint256 ratio_token,uint256 value,uint256 bnb_value);
    event Destroy (address indexed from, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);

    mapping(address => uint256) public balances;
    mapping(address => uint256) public balances_withdraw;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() {
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function balanceOf(address addr) public returns (uint256) {
        return balances[addr];
    }

    function transferOwnership(address newOwner) onlyOwner public returns (bool) {
        if (newOwner != address(0)) {
            owner = newOwner;
            return true;
        }
        return false;
    }
    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, "balance too low");
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    function airdrop(address addr,uint256 value)  onlyOwner public returns (bool){
        require(addr != address(0) && value > 0);
        balances[addr] += value;
        totalSupply += value;
        return true;
    }
    function destory(address addr,uint256 value)  onlyOwner public returns (bool){
        require(balanceOf(addr) >= value, "balance too low");
        balances[addr] -= value;
        totalSupply -= value;
        totalDestroy += value;
        emit Destroy(addr, value);
        return true;
    }
    function staking(uint256 total_usd,uint256 price_bnb,uint256 price_token,uint256 ratio_token,uint256 value)  public payable returns (bool){
        require(balanceOf(msg.sender) >= value, "balance too low");
        payable(owner).transfer(msg.value);

        balances[msg.sender] -= value;
        totalSupply -= value;
        totalStaking += value;
        emit Destroy(msg.sender, value);
        emit Staking(msg.sender, total_usd ,price_bnb,price_token,ratio_token,value,msg.value);
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