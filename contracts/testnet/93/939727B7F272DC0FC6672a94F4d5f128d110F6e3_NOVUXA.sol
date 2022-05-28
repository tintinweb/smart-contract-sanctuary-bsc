// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;



import "./pyo.sol";
import "./dxlycontract.sol";


contract NOVUXA {

    //address public owner;
    mapping(address => uint) public balances;
   // mapping(address => uint) public token;
    address public owner;
    
    
    PYO token;
    IBEP20 token_;

     address private Token = 0xb5450ffaf67E289A185C20F643Cd69507617196e; //pyo
     address private Token_ = 0xb3B7d5EEF1f30BBA8A43D585F0525d3EEA204D6e; //dxly
    
 

     event Transfer(address indexed from, address indexed to, uint value);
     event Approval(address indexed owner, address indexed spender, uint value);

     constructor() public  {
      owner = msg.sender;
      token = PYO(Token);
      token_ = IBEP20(Token_);
     // add_1 = 0xA852f76E59a581489fc1fDD2eF92d28507583740;
     }

       // Modifier to check token allowance
    modifier checkAllowance(uint amount) {
        require(token.allowance(msg.sender, address(this)) >= amount, "Error");
        _;
    }


    modifier only_novuxa(uint amount) {
         require(msg.sender == owner, "Only Novuxa Contract can perform this action");
                _;
    }



       // Modifier to check token allowance
    modifier checkAllowance_(uint amount) {
        require(token_.allowance(msg.sender, address(this)) >= amount, "Error");
        _;
    }




  
    // In your case, Account A must to call this function and then deposit an amount of tokens 
    function depositTokens(uint amount) public checkAllowance_(amount) {
        token_.transferFrom(msg.sender, address(this), amount);
        token_.approve(Token, amount);
           //   token_.transferFrom(msg.sender, 0xA852f76E59a581489fc1fDD2eF92d28507583740, _amount);
    }


    // In your case, Account A must to call this function and then deposit an amount of tokens 
     function depositTokens2(uint amount) public only_novuxa (amount) {
           token.transferFrom(address(this), msg.sender,amount);
        token.approve(Token, amount);
     //   token.transferFrom(msg.sender, 0xA852f76E59a581489fc1fDD2eF92d28507583740, _amount);
    }



     function approve(address spender, uint256 value) external returns (bool) {
       //  approve(_msgSender(), spender, amount);
        token.approve(spender, value );
        token_.approve(spender, value );
    return true;
   

}


   function  novuxa_Balance_Token1(address to) external view returns(uint) {
      return token.balanceOf(to);
      
          }



  function  novuxa_Balance_Token2(address to) external view returns(uint) {
      return token_.balanceOf(to);
      
    }


      function  contract_novuxa_Balance_Token2() external view returns(uint) {
      return token.balanceOf(address(this));
      
    }

 function transferfrom_novuxa(uint256 value) external  {
       
        token_.transferFrom(msg.sender, address(this), value);
      //  token.transferFrom(from, to, value);
       // uint256 fee = value / 100;
      //  uint256 value2 = value - fee;
      //  token_.transfer(msg.sender, value2);
    }



}