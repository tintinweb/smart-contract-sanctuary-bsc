/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

//import "./pyo.sol"; //to be changed to usdt.sol

contract ABC {

 //   PYO public token; // to be changed to IBEP20
   

    // address private TokenA = 0xb5450ffaf67E289A185C20F643Cd69507617196e; //pyo to be changed to usdt bep20
    // address private Token_ = 0xbc21CCa195c2b9C4E68f84FD951F95040aFD7A6e; //dxly
    uint amountA;
    uint amountx;
    uint amountz;
   



    
    
    // state variables
    address public owner;
    
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => uint) public balances; /// maping of address to wallet balance
    mapping (address => uint) public donutBalances; ///mapping of address to donutbalance
    mapping (address => uint) public poolvalue; ///mapping of address to poolvalue
    mapping (address => uint) public ee_deelian;
  //  mapping (address => uint) public _to;
    mapping (address => uint) public recipient;
    uint public totalSupply = 1000000000000000000;   ///local deelian supply
    string public name = "ABC";
    string public symbol = "ABC";
    uint public decimals = 5;
    uint deelian_price; 
    uint deelianprice;
 

    function setdeelian_price(uint x) public {
      require(msg.sender == owner, "Only the owner can update Deelian Price.");
      deelian_price = x;
   }

               function getdeelian_price() public view returns (uint) {
              
                return deelian_price;
               
               }           
               
               

    
     event Transfer(address indexed from, address indexed to, uint value);
     event Approval(address indexed owner, address indexed spender, uint value);


    constructor() public {
        owner = msg.sender;
        donutBalances[owner] = 1000000000;
        donutBalances[address(this)] = 0;
        balances[msg.sender] = totalSupply;
 //       token = PYO(TokenA);
 }




 ///balance of owner address on contract
 
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




    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
     //   require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }

    
        function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }



///balance ofdonut on contract address itself, address (this) on contract
 function getVendingMachineBalance() public view returns (uint) {
        return donutBalances[address(this)];
    }


     function getVendingMachineBalancePool() public view returns (uint) {
        return donutBalances[address(this)]*deelian_price;
    }


  // Let the owner restock the vending machine
    function restock(uint amount) public {
        require(msg.sender == owner, "Only the owner can restock.");
        donutBalances[address(this)] += amount;
    }



     // Purchase donuts from the vending machine
    function purchase(uint amount) public payable {
       // require(msg.value >= amount * 1, "You must pay at least 2 ETH per donut");
        require (balances[msg.sender]>= amount, "Not enough Balance"); 
        require(donutBalances[owner] >= amount, "Not enough donuts in stock to complete this purchase");
        donutBalances[owner] -= amount;
        donutBalances[msg.sender] += amount;
        balances[msg.sender]-= amount;
    }

///////////////////////////////////////////////////////////////////////////////////////////////////////
  

// Selling doughnut back to  the vending machine
    function sellback(uint amount) public payable {
        //require(donutBalances[msg.sender] >= amount * 2 ether, "You must pay at least 2 ETH per donut");
        require(donutBalances[msg.sender] >= amount, "Not enough donuts in wallet to sell back to machine");
        donutBalances[address(this)] += donutBalances[msg.sender];
      //  donutBalances[msg.sender] -= donutBalances[msg.sender];
        donutBalances[msg.sender] -= amount;
       // ee_deelian[msg.sender] = (((amount* 18/100) + amount)*deelian_price);       
        ee_deelian[msg.sender] = ((amount* 18/100) + amount); 


    //    equire(donutBalances[msg.sender] >= amount, "Not enough donuts in wallet to sell back to machine");

  
    }


/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Selling doughnut back to  the vending machine
    function bot_trader(uint amount) public payable {
        //require(donutBalances[msg.sender] >= amount * 2 ether, "You must pay at least 2 ETH per donut");
        require(donutBalances[msg.sender] >= amount, "Not enough donuts in wallet to sell back to machine");
        donutBalances[address(this)] += donutBalances[msg.sender];
      //  donutBalances[msg.sender] -= donutBalances[msg.sender];
        donutBalances[msg.sender] -= amount;
       // ee_deelian[msg.sender] = (((amount* 18/100) + amount)*deelian_price);       
        ee_deelian[msg.sender] = ((amount* 13/100) + amount); 


    //    equire(donutBalances[msg.sender] >= amount, "Not enough donuts in wallet to sell back to machine");

  
    }




///////////////////////////////////////////////////////////////////////////////////////////////////////////

    function Proposal_Approval() public payable {
           
      
      if (  (donutBalances[address(this)]*deelian_price) / ee_deelian[msg.sender]>= 3)
      
      {
       
        balances[msg.sender] = balances[msg.sender] + (ee_deelian[msg.sender]/deelian_price);
        donutBalances[address(this)] -= ee_deelian[msg.sender];
        balances[owner] - (ee_deelian[msg.sender]/deelian_price);
        ee_deelian[msg.sender] = 0;
       }



      else  {

         return require(donutBalances[address(this)]*deelian_price/ee_deelian[msg.sender] >= 3, "Approval Still Pending");
    }


    }



 




    }