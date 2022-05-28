// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;



import "./pyo.sol";
import "./dvending.sol";


contract NOVUXA {

    //address public owner;
    mapping(address => uint) public balances;
   // mapping(address => uint) public token;
    address public owner;
    
    
    PYO token;
    Deelian token_;

     address private Token = 0xb5450ffaf67E289A185C20F643Cd69507617196e; //pyo
     address private Token_ = 0x67B9e2984f89f05Ec38c5f83F16D74BcCCb26d4E; //deelian
    // address private Token_ = 0xbc21CCa195c2b9C4E68f84FD951F95040aFD7A6e; //dxly
    
 

     event Transfer(address indexed from, address indexed to, uint value);
     event Approval(address indexed owner, address indexed spender, uint value);

     constructor() public  {
      owner = msg.sender;
      token = PYO(Token);
      token_ = Deelian(Token_);
     // add_1 = 0xA852f76E59a581489fc1fDD2eF92d28507583740;
     }

       // Modifier to check token allowance
    modifier checkAllowance(uint amount) {
        require(token.allowance(msg.sender, address(this)) >= amount, "Error");
        _;
    }


    modifier only_novuxa {
         require(msg.sender == owner, "Only Novuxa Contract can perform this action");
                _;
    }



       // Modifier to check token allowance
    modifier checkAllowance_(uint amount) {
        require(token_.allowance(msg.sender, address(this)) >= amount, "Error");
        _;
    }




  
    // In your case, Account A must to call this function and then deposit an amount of tokens 
    function depositTokens(uint amount) public  {
        token.transferFrom(msg.sender, address(this), amount);
        token_.transferFrom(address(this), msg.sender, amount);
        token.approve(Token, amount);
           //   token_.transferFrom(msg.sender, 0xA852f76E59a581489fc1fDD2eF92d28507583740, _amount);
    }


    // In your case, Account A must to call this function and then deposit an amount of tokens 
     function depositTokens2(uint amount) public  only_novuxa {
           token_.transferFrom(address(this), msg.sender, amount);
        token_.approve(Token, amount);
     //   token.transferFrom(msg.sender, 0xA852f76E59a581489fc1fDD2eF92d28507583740, _amount);
    }



     function approve(address spender, uint256 value) external returns (bool) {
       //  approve(_msgSender(), spender, amount);
        token.approve(spender, value );
        token_.approve(spender, value );
    return true;
   

}


   function  novuxa_Balance_Token1() external view returns(uint) {
      return token.balanceOf(msg.sender);
      
          }



  function  novuxa_Balance_Token2() external view returns(uint) {
      return token_.balanceOf(msg.sender);
      
    }


      function  contract_novuxa_Balance_Token1() external view returns(uint) {
      return token.balanceOf(address(this));
      
    }


          function  contract_novuxa_Balance_Token2() external view returns(uint) {
      return token_.balanceOf(address(this));
      
    }

 function transferfrom_novuxa(uint256 value) external  {
       
        token_.transferFrom(msg.sender, address(this), value);
      //  token.transferFrom(from, to, value);
       // uint256 fee = value / 100;
      //  uint256 value2 = value - fee;
      //  token_.transfer(msg.sender, value2);
    }



}