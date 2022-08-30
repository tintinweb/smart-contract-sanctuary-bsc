// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;



import "./usdt.sol";
import "./pqr.sol";


contract NOVANOVA {

   
    mapping(address => uint) public balances;
    address public owner;
    
    
    IBEP20 public token;
    PQR public token_;


  
    mapping(address=>mapping(address=>uint)) public allowance;
	
	  // address public address2= 0x4513E89E26F192cbE7F45C3127aFBe5Dfb7F97ab; //sample reciever

     address private TokenA = 0xB35Ff1245b9c4b2519Fd9a08963Ed62279E99fB1; //usdt
     address private TokenB = 0x2aB5d989a3FB1A32fbc9de50280EBdbF0E7407f5; //deelian/usdt5
    // address private Token_ = 0xbc21CCa195c2b9C4E68f84FD951F95040aFD7A6e; //dxly
    uint amountA;
    uint amountB;
    uint novuxa_price;
    uint tkdA = 10**18; /// token decimal A
    uint tkdB = 10**5; /// token Decimal B
 

     event Transfer(address indexed from, address indexed to, uint value);
     event Approval(address indexed owner, address indexed spender, uint value);

     constructor() public  {
      owner = msg.sender;
      token = IBEP20(TokenA);
      token_ = PQR(TokenB);
      
      amountB = amountA ;

   
     }

      
    modifier checkAllowance(uint amountA) {
        require(token.allowance(msg.sender, address(this)) >= amountA, "Error");
        _;
    }


    modifier swap_checkA(uint amountA) {
        require(token.balanceOf(msg.sender) >= amountA, "Your Token Balance is too low to perform the SWAP");
        _;
    }

       modifier swap_checkB(uint amountB) {
        require(token_.balanceOf(msg.sender) >= amountB, "Your Token Balance is too low to perform the SWAP");
        _;
    }

           modifier LPswapA_check(uint amountA) {
        require(token.balanceOf(address(this)) >= amountA, "Not Enough Liquidity For this SWAP");
        _;
    }

           modifier LPswapB_check(uint amountB) {
        require(token_.balanceOf(address(this)) >= amountB, "Not Enough Liquidity For this SWAP");
        _;
    }



    modifier only_novuxa {
         require(msg.sender == owner, "Only Novuxa Contract can perform this action");
                _;
    }



     
    modifier checkAllowance_(uint amountB) {
        require(token_.allowance(msg.sender, address(this)) >= amountB, "Error");
        _;
    }


   function  novuxa_Balance_Token1() external view returns(uint) {
      return token.balanceOf(msg.sender)/tkdA;
      
          }



      function  novuxa_Balance_Token2() external view returns(uint) {
      return token_.balanceOf(msg.sender)/tkdB;
      
    }


      function  LP_Balance_Token1() external view returns(uint) {
      return token.balanceOf(address(this))/tkdA; // no of decimal
      
    }

      function  LP_Balance_Token2() external view returns(uint) {
      return token_.balanceOf(address(this))/tkdB; // no of decimal
     
      
    }


    function  nouvaxa_price() external view returns(uint) {


      return token.balanceOf(address(this))/token_.balanceOf(address(this));
      
    }


       function approve(address spender, uint256 value) external returns (bool) {
       allowance[msg.sender][spender]= value;
        token.approve(spender, value );
        token_.approve(spender, value );
         return true;
   

}



     
    function SwapAB(uint amountA) public swap_checkA(amountA) {
      //  uint256 allowance = token.allowance(msg.sender, address(this));
        token.transferFrom(msg.sender, address(this), amountA*tkdA);
        uint256 fee = amountA*tkdA / 1000; // 0.1% swap fee
        uint256 amountq = (amountA*tkdA) - fee;
        require(token_.balanceOf(address(this)) >= amountq, "Not Enough Liquidity For this SWAP");
        token_.transferFrom(address(this), msg.sender, amountq);
        token.approve(TokenA, amountA);
           
    }


      function SwapBA(uint amountB) public swap_checkB(amountB) {
           token_.transferFrom(msg.sender, address(this), amountB*tkdB);
           uint256 fee = amountB*tkdB / 1000; // 0.1% swap fee
           uint256 amountq = (amountB*tkdB) - fee;
          require(token.balanceOf(address(this)) >= amountq, "Not Enough Liquidity For this SWAP");
           token.transferFrom(address(this), msg.sender, amountq);
           token_.approve(TokenB, amountB);
     
    }



 function AProvide_Liquidity_Novuxa(uint256 value) swap_checkA(value) external  {
            uint256 fee = value*tkdA / 1000; // 0.1% swap fee
            uint256 valueq = (value*tkdA) + fee;
        token.transferFrom(msg.sender, address(this), valueq);
  
    }




    function BProvide_Liquidity_Novuxa(uint256 value) swap_checkB(value)external  {
            uint256 fee = (value*tkdB) / 1000; // 0.1% swap fee
            uint256 valueq = (value*tkdB) + fee;
            token_.transferFrom(msg.sender, address(this), valueq);
      //  token.transferFrom(from, to, value);
        //    uint256 fee = value / 100;
        //    uint256 value2 = value - fee;
      //  token_.transfer(msg.sender, value2);
    }

    function Remove_A_Liquidity_Novuxa(uint256 value) external only_novuxa {
            uint256 fee = (value*tkdA) / 100; // 1% Liquidity removal fee
            uint256 valueq = (value*tkdA) - fee;
            require(block.timestamp >= now + 180 days);
            token.transferFrom(address(this), msg.sender, valueq);
      
    }


       function Remove_B_Liquidity_Novuxa(uint256 value) external only_novuxa {
            uint256 fee = (value*tkdB)/ 100; // 1% Liquidity removal fee
            uint256 valueq = (value*tkdB) - fee;
            require(block.timestamp >= now + 180 days);
            token_.transferFrom(address(this), msg.sender, valueq);
      
    }



}