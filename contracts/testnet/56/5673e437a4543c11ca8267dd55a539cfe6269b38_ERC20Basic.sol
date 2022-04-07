// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";


interface IERC20{

    // Verifica total do supply do token
    function totalSupply() external view returns (uint256);

    // Quantidade de token de uma carteira
    function balanceOf(address account) external view returns (uint256);

    // QUantidade de token que o spender podera gastar
    function allowance(address owner, address sender) external view returns (uint256);

    // Transfere token para uma determinada carteira
    function transfer(address receiver, uint256 ammount) external returns (bool);

    // Aprova transferencia de uma quantidade de token de quem esta enviando
    function appove(address delegate, uint256 ammount)  external returns (bool);

    // Envia Token de uma carteira para outra 
    function transferFrom(address owner, address receiver, uint256 ammount) external returns (bool);

    // Evento que notifica todos sobre transferencia de tokens
    event Transfer(address indexed from, address indexed to, uint256 valor);

    // Evento quando aprova transfrencia 
    event Approval(address indexed owner, address indexed sender, uint256 valor);

}

contract ERC20Basic is IERC20{

    string public constant name     = "BloodHounds";
    string public constant symbol   = "BHoundT1";
    uint8  public constant decimals = 18;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    uint256 totalSupply_;

    event Transfer(address indexed from, address indexed to, uint256 valor);
    event Approval(address indexed owner, address indexed sender, uint256 valor);

    using SafeMath for uint256;

    constructor (uint initialSupply) public {
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }

    // Verifica total do supply do token
    function totalSupply() public override view returns(uint256){
        return totalSupply_;
    }

    function increaseTotalSupply(uint newTokens) public {
        totalSupply_ += newTokens;
        balances[msg.sender] += newTokens;
    }

    // Quantidade de token de uma carteira
    function balanceOf(address account) public override view returns(uint256){
        return balances[account];
    }

    // QUantidade de token que o spender podera gastar
    function allowance(address owner, address sender) public override view returns(uint256){
        return allowed[owner][sender];
    }

    // Transfere token para uma determinada carteira
    function transfer(address receiver, uint256 ammount) public override returns (bool){
        require(ammount <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(ammount);
        balances[receiver] = balances[receiver].add(ammount);
        emit Transfer(msg.sender, receiver, ammount);
        return true;
    }

    // Aprova transferencia de uma quantidade de token de quem esta enviando
    function appove(address delegate, uint256 ammount)  public override returns (bool){
        allowed[msg.sender][delegate] = ammount;
        emit Approval(msg.sender, delegate,ammount);
        return true;
    }

    // Envia Token de uma carteira para outra 
    function transferFrom(address owner, address receiver, uint256 ammount) public override returns (bool){
        require(ammount <= balances[owner]);
        require(ammount <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(ammount);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(ammount);
        balances[receiver] = balances[receiver].add(ammount);
        emit Transfer(owner, receiver, ammount);
        return true;
    }

}