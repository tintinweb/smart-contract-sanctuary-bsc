/**
 *Submitted for verification at BscScan.com on 2022-10-26
*/

pragma solidity ^0.4.26;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    //function allowance(address owner, address spender) external view returns (uint);

    //function approve(address spender, uint amount) external returns (bool);

    /*function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);*/

    event Transfer(address indexed from, address indexed to, uint value);
    event Burn(address indexed from, address indexed to ,uint value);
    event Mint(address indexed from, uint value);
}

contract newToken{

    address[] public tokens;
    function createToken(uint total, string nome, string simbolo, uint decimal, bool queima)public {
        address token = new ERC20(total, nome, simbolo, msg.sender, decimal, queima);
        tokens.push(token);
    }

    function getAllTokens()public view returns(address[]){
        return tokens;
    }

}

contract ERC20 is IERC20{

    address owner;
    uint256 public totalSupply_;
    string public name;
    string public symbol;
    uint public decimals;
    bool public isBurn;

    mapping(address => uint256) balances;

    constructor(uint total, string nome, string simbolo, address creator, uint decimal, bool burn) public{
        totalSupply_ = total * 10**decimal;
        balances[creator] = totalSupply_;
        owner = creator;
        name = nome;
        symbol = simbolo;
        decimals = decimal;
        isBurn = burn;
    }

    function transfer(address recipient, uint value) external returns(bool){
        require(balances[msg.sender] >= value);
        balances[msg.sender] -= value;
        balances[recipient] += value;
        emit Transfer(msg.sender, recipient, value);
        return true;
    }

    function balanceOf(address account) external view returns(uint){
        return balances[account];
    }

    function totalSupply() external view returns(uint256){
        return totalSupply_;
    } 

    function mint(uint value) external {
        balances[msg.sender] += value;
        totalSupply_ += value;
        emit Mint(msg.sender, value);
    }

    function burn(uint value) external{
        require(owner == msg.sender);
        require(balances[msg.sender] >= value);
        require(isBurn == true);
        balances[msg.sender] -= value;
        totalSupply_ -= value;
        emit Burn(msg.sender, address(0) ,value);
        
    }
}