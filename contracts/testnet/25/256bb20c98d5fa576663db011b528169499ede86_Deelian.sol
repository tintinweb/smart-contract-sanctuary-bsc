/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;



contract Deelian {


    
    // state variables
    address public owner;
    
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => uint) public balances; /// maping of address to wallet balance
    mapping (address => uint) public Proposal; ///mapping of address to Proposal
    mapping (address => uint) public poolvalue; ///mapping of address to poolvalue
    mapping (address => uint) public nc_loan; ///mapping of address to no_collateral
    mapping (address => uint) public ee_deelian; ////mapping of address to ee_deelian
    mapping (address => uint) public ncl_investment; ////mapping of address to a_investment
    mapping (address => uint) public stk_investment; ////mapping of address to a_investment
    mapping (address => uint) public bot_investment; ////mapping of address to a_investment
  //  mapping (address => uint) public _to;
    mapping (address => uint) public recipient;
    uint public totalSupply = 1000000000000000000;   ///local deelian supply
    string public name = "DEELIAN";
    string public symbol = "DEELIAN";
    uint public decimals = 5;
    uint deelian_price; 
    uint deelianprice;
    uint pool_factor;
    uint nclp;
    uint stkp;
    uint botp;
    uint timelock;
 
////////////////////////////////////////////////////////////////////////////////////////////
///Deelian Price should be multiply by 100000 e.g 0.2567 will be 25670
    function setdeelian_price(uint x) public {
      require(msg.sender == owner, "Only the owner can update Deelian Price.");
      deelian_price = x;
   }

    function getdeelian_price() public view returns (uint) {
              
     return deelian_price;
               
    }           
////////////////////////////////////////////////////////////////////////////////////////////////               
////////////////////////////////////////////////////////////////////////////////////////////
    function setnclp(uint x) public {
      require(msg.sender == owner, "Only the owner can update.");
       nclp = x;
   }

    function getnclp() public view returns (uint) {
              
     return nclp;
               
    }           
//////////////////////////////////////////////////////////////////////////////////////////////// 
////////////////////////////////////////////////////////////////////////////////////////////
    function setstkp(uint x) public {
      require(msg.sender == owner, "Only the owner can update.");
       stkp = x;
   }

    function getstkp() public view returns (uint) {
              
     return stkp;
               
    }           
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
    function setbotp(uint x) public {
      require(msg.sender == owner, "Only the owner can update.");
       botp = x;
   }

    function getbotp() public view returns (uint) {
              
     return botp;
               
    }           
//////////////////////////////////////////////////////////////////////////////////////////////// 
//////////////////////////////////////////////////////////////////////////////////////////////
    function setpool_factor(uint x) public {
      require(msg.sender == owner, "Only the owner can update.");
      pool_factor = x;
   }

               function getpool_factor() public view returns (uint) {
              
                return pool_factor;
               
               }           
////////////////////////////////////////////////////////////////////////////////////////////////               


 
    
     event Transfer(address indexed from, address indexed to, uint value);
     event Approval(address indexed owner, address indexed spender, uint value);
     event No_Collateral_Loan(address indexed owner, address indexed from, uint amount, uint price);
     event Staking(address indexed from, uint amount, uint price);
     event Bot(address indexed from, uint amount, uint ee_deelian);
     event Project_Proposal(address indexed from, uint amount, uint price);
     //emit Staking(msg.sender, amount, deelian_price);


    constructor() public {
        owner = msg.sender;
        Proposal[owner] = 10000000000000;
        Proposal[address(this)] = 0;
        balances[msg.sender] = totalSupply;
    
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




    
        function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }



 //1   function transfer_From(address from, address to, uint value) public returns(bool) {
  //2      require(balanceOf(from) >= value, 'balance too low');
     //   require(allowance[from][msg.sender] >= value, 'allowance too low');
 //3           balances[to] += value;
  //4      balances[from] -= value;
 //5      emit Transfer(from, to, value);
  //6      return true;   
 //7   }



  function transferFrom(address from, address to, uint amount) public returns (bool) {
  require(amount <= balances[from],'allowance too low');
  require(amount <= allowance[from][msg.sender],'allowance too low');
  balances[from] -= amount;
  allowance[from][msg.sender] -=  amount;
  balances[to] = balances[to] + amount;
  emit Transfer(from, to, amount);
  return true;
}






    function mint(uint amount) public {
        require(msg.sender == owner, "Only the owner can mint token.");
        balances[msg.sender] += amount;
       }


       
       function burn(uint256 value) public  {   
         require(msg.sender == owner, "Only the owner can burn token.");         
         transferFrom(address(this), address(0), value);
      
    }



///balance of submitted Proposal & Pool on contract address itself, address (this) on contract
 function get_submitted_proposal_balance() public view returns (uint) {
        return Proposal[address(this)];
    }

//balance of submitted Proposal & Pool on contract address itself, address (this) on contract
     function get_submitted_proposal_balance_pool() public view returns (uint) {
        return Proposal[address(this)]*(deelian_price/100000);
    }


  // Let the contract owner  reload Proposal Forms Purchasable from the contract owner
    function reload_proposal_form(uint amount) public {
        require(msg.sender == owner, "Only the owner can add more.");
        Proposal[msg.sender] += amount;
    }

/////////////////////////////////////////////////////////////////////////////////////

// Free Loan without Collateral
  
    function no_collateral_loan(uint amount) public payable {
              nc_loan[msg.sender] += amount;
       }

////////////////////////////////////////////////////////////////////////////////////

     // Purchase Proposal from the Contract owner
    function proposal_purchase(uint amount) public  {
        require (balances[msg.sender]>= amount, "Not enough Balance to Purchase Proposal"); 
        require(Proposal[owner] >= amount, "No Proposal Form from the contract owner again");
        Proposal[owner] -= amount;
        Proposal[msg.sender] += amount;
        balances[msg.sender]-= amount;
        emit Project_Proposal(msg.sender, amount, deelian_price/100000);
    }

///////////////////////////////////////////////////////////////////////////////////////////////////////
  

//   Stacking your deelian to  the Contract Address for reward.
     function staking(uint amount) public  {
        require(Proposal[msg.sender] >= amount, "Your proposal balance must be higher than the amount you are submitting");
        Proposal[address(this)] += amount;
        Proposal[msg.sender] -= amount;  
        stk_investment[msg.sender] += amount;         
        ee_deelian[msg.sender] = ((((amount* stkp/100) + amount)*deelian_price)/100000);
        uint timelock = block.timestamp  + 2 days ; 
        emit Staking(msg.sender, amount, deelian_price/100000);
    
    }


/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Allowing BOT Trader to trade your deelian  for reward.
    function bot_trader(uint amount) public  {
        require(Proposal[msg.sender] >= amount, "Your proposal balance must be higher than the amount you are sending to bot");
        Proposal[address(this)] += amount;
        Proposal[msg.sender] -= amount;
        bot_investment[msg.sender] += amount; 
        ee_deelian[msg.sender] = ((((amount* botp/100) + amount)*deelian_price)/100000); 
        uint timelock = block.timestamp  + 2 days ;
        emit Bot(msg.sender, amount, deelian_price/100000);
    //    

  
    }

///////////////////////////////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////////////////////////////////
// No Colateral Loan Approval Payment
    function nc_loan_approval_payment(uint amount) public payable {
        require(nc_loan[msg.sender] <= amount,"Not up to  borrowed amount, kindly add more");
        require(balances[msg.sender] >= nc_loan[msg.sender], "Not enough Deelian Balance for quick loan repayment submission");
        Proposal[address(this)] += amount;
        balances[msg.sender] -= amount;
        nc_loan[msg.sender] -= amount;
        ncl_investment[msg.sender] += amount; 
        ee_deelian[msg.sender] = ((((amount* nclp/100) + amount)*deelian_price)/100000);
        emit  No_Collateral_Loan(address(this), msg.sender, amount, deelian_price/100000);  
   
    }

///////////////////////////////////////////////////////////////////////////////////////////////////////////
  
   
  
    function proposal_final_approval() public  {           
       require(pool_factor >=0,"Pool Factor Not Set");
      if (  ((Proposal[address(this)]*deelian_price)/100000) / ee_deelian[msg.sender]>= pool_factor/1000)
      
      {

        balances[msg.sender] = balances[msg.sender] + ((ee_deelian[msg.sender]/deelian_price)*100000);
        Proposal[address(this)] -= ee_deelian[msg.sender];
        balances[owner] - ((ee_deelian[msg.sender]/deelian_price)*100000);
        ee_deelian[msg.sender] = 0;
        ncl_investment[msg.sender] = 0;
        bot_investment[msg.sender] = 0; 
        stk_investment[msg.sender] = 0;  
       
   

       }

      else  {

         return require(Proposal[address(this)]*deelian_price/ee_deelian[msg.sender] >= pool_factor/1000, "Approval Still Pending");
    }


    }




  ////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
    function terminate_ncl_proposal() public payable {
        require(block.timestamp - timelock >= 7 days,"You have to wait for 168 hours to terminate proposal");
        uint256 fee = ncl_investment[msg.sender] / 100; // 1% termination fee
        balances[msg.sender] = balances[msg.sender] + ncl_investment[msg.sender] - fee;
        balances[owner] -= ncl_investment[msg.sender];
        ee_deelian[msg.sender] = 0;
        ncl_investment[msg.sender] = 0;
    }


    function terminate_stk_proposal() public payable {
        require(block.timestamp - timelock >= 7 days,"You have to wait for 168 hours to terminate proposal");
        uint256 fee = stk_investment[msg.sender] / 100; // 1% termination fee
        balances[msg.sender] = balances[msg.sender] + stk_investment[msg.sender] - fee;
        balances[owner] -= stk_investment[msg.sender];
        ee_deelian[msg.sender] = 0;
        stk_investment[msg.sender] = 0;
   
    }



function terminate_bot_proposal() public payable {
        require(block.timestamp - timelock >= 7 days,"You have to wait for 168 hours to terminate proposal");
        uint256 fee = bot_investment[msg.sender] / 100; // 1% termination fee
        balances[msg.sender] = balances[msg.sender] + bot_investment[msg.sender] - fee;
        balances[owner] -=bot_investment[msg.sender];
        ee_deelian[msg.sender] = 0;
        bot_investment[msg.sender] = 0;
    }


    

    


    }