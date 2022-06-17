// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;



import "./pyo.sol";
import "./dvending.sol";


contract NOVUXA {

   
    mapping(address => uint) public balances;
    address public owner;
    
    
    PYO public token;
    Deelian public token_;

     address private TokenA = 0xb5450ffaf67E289A185C20F643Cd69507617196e; //pyo4/usdt
     address private TokenB = 0x67B9e2984f89f05Ec38c5f83F16D74BcCCb26d4E; //deelian
    // address private Token_ = 0xbc21CCa195c2b9C4E68f84FD951F95040aFD7A6e; //dxly
    uint amountA;
    uint amountB;
   // uint novuxa_price;

 

     event Transfer(address indexed from, address indexed to, uint value);
     event Approval(address indexed owner, address indexed spender, uint value);

     constructor() public  {
      owner = msg.sender;
      token = PYO(TokenA);
      token_ = Deelian(TokenB);
      
      // amountB =  amountA * (10**(5-4));

   
     }

      
    modifier checkAllowance(uint amount) {
        require(token.allowance(msg.sender, address(this)) >= amount, "Error");
        _;
    }


    modifier swap_checkA(uint amount) {
        require(token.balanceOf(msg.sender) >= amount, "Your Token Balance is too low to perform the SWAP");
        _;
    }

       modifier swap_checkB(uint amount) {
        require(token_.balanceOf(msg.sender) >= amount, "Your Token Balance is too low to perform the SWAP");
        _;
    }

           modifier lpswapA_check(uint amount) {
        require(token.balanceOf(address(this)) >= amount, "Not Enough Liquidity For this SWAP");
        _;
    }

           modifier lpswapB_check(uint amount) {
        require(token_.balanceOf(address(this)) >= amount, "Not Enough Liquidity For this SWAP");
        _;
    }



    modifier only_novuxa {
         require(msg.sender == owner, "Only Novuxa Contract can perform this action");
                _;
    }



     
    modifier checkAllowance_(uint amount) {
        require(token_.allowance(msg.sender, address(this)) >= amount, "Error");
        _;
    }

////Balance of Token 1 for this address on novuxa exchange
   function  novuxa_balance_token1() external view returns(uint) {
      return token.balanceOf(msg.sender);
      
          }


///Balance of Token2 for this address on novuxa exchange
      function  novuxa_balance_token2() external view returns(uint) {
      return token_.balanceOf(msg.sender);
      
    }


      function  lp_balance_token1() external view returns(uint) {
      return token.balanceOf(address(this))/10000; // no of decimal
      
    }

      function  lp_balance_token2() external view returns(uint) {
      return token_.balanceOf(address(this))/100000; // no of decimal
     
      
    }


    function  novuxa_price() external view returns(uint) {


       uint deelian_price = token.balanceOf(address(this))/token_.balanceOf(address(this));
      
    }



     
    function swap_ab(uint amount) public swap_checkA(amount) {
        token.transferFrom(msg.sender, address(this), amount);
        uint256 fee = amount / 1000; // 0.1% swap fee
        uint256 amountq = amount- fee;
        require(token_.balanceOf(address(this)) >= amountq, "Not Enough Liquidity For this SWAP");
        token_.transferFrom(address(this), msg.sender, amountq);
     //   token.approve(TokenA, amount);
           
    }


      function swap_ba(uint amount) public swap_checkB(amount) {
           token_.transferFrom(msg.sender, address(this), amount);
           uint256 fee = amount / 1000; // 0.1% swap fee
           uint256 amountq = amount - fee;
           require(token.balanceOf(address(this)) >= amountq, "Not Enough Liquidity For this SWAP");
           token.transferFrom(address(this), msg.sender, amountq);
         //  token_.approve(TokenB, amount);
     
    }



     function approve(address spender, uint256 value) external returns (bool) {
        token.approve(spender, value );
        token_.approve(spender, value );
         return true;
   

}




 function aprovide_liquidity_novuxa(uint256 value) external  {
            uint256 fee = value / 1000; // 0.1% swap fee
            uint256 valueq = value + fee;
        token.transferFrom(msg.sender, address(this), valueq);
  
    }




    function bprovide_liquidity_novuxa(uint256 value) external  {
            uint256 fee = value / 1000; // 0.1% swap fee
            uint256 valueq = value + fee;
            token_.transferFrom(msg.sender, address(this), valueq);
      //  token.transferFrom(from, to, value);
        //    uint256 fee = value / 100;
        //    uint256 value2 = value - fee;
      //  token_.transfer(msg.sender, value2);
    }

    function remove_a_liquidity_novuxa(uint256 value) external only_novuxa {
            uint256 fee = value / 100; // 1% Liquidity removal fee
            uint256 valueq = value - fee;
            require(block.timestamp >= now + 180 days);
            token.transferFrom(address(this), msg.sender, valueq);
      
    }


       function remove_b_liquidity_novuxa(uint256 value) external only_novuxa {
            uint256 fee = value / 100; // 1% Liquidity removal fee
            uint256 valueq = value - fee;
            require(block.timestamp >= now + 180 days);
            token_.transferFrom(address(this), msg.sender, valueq);
      
    }


       function burn(uint256 value) external only_novuxa {            
            token_.transferFrom(address(this), address(0), value);
      
    }







}