/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;



contract DEF {

    // state variables
    address public owner;
    
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => uint) public balances; /// maping of address to wallet balance
    mapping (address => uint) public donutBalances; ///mapping of address to donutbalance
    mapping (address => uint) public buy_lp; ///mapping of address to donutbalance
    mapping (address => uint) public sell_lp; ///mapping of address to donutbalance
   // mapping (address => uint) public poolfactor; ///mapping of address to donutbalance
     mapping (address => uint) public recipient;
    uint public totalSupply = 1000000000000000000;   ///local deelian supply
    string public name = "DEF";
    string public symbol = "DEF";
    uint public decimals = 4;
    uint pyo_price; 
    uint poolfactor;


               

    
     event Transfer(address indexed from, address indexed to, uint value);
     event Approval(address indexed owner, address indexed spender, uint value);


    constructor() public {
        owner = msg.sender;
       donutBalances[owner] = 1000000000;
        buy_lp[owner] = 1000000000000;
        sell_lp[owner] = 1000000000000;
        donutBalances[address(this)] = 0;
         buy_lp[address(this)] = 0;
          sell_lp[address(this)] = 0;
        balances[msg.sender] = totalSupply;
        
 }


    function setpyo_price(uint x) public {
      require(msg.sender == owner, "Only the owner can update PYO Price.");
      pyo_price = x;
   }

               function getpyo_price() public view returns (uint) {
              
                return pyo_price;
               
               }   


 function getbuy_lp_Balance() public view returns (uint) {
        return buy_lp[address(this)];
    }




 function getsell_lp_Balance() public view returns (uint) {
        return sell_lp[address(this)];
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



 

    }