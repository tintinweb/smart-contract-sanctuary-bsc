// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;



import "./usdt.sol";
import "./deelian.sol";
//import "./pqr.sol";


contract NOVANOVA {

   
    mapping(address => uint) public balances;
    address public owner;
    
    
    BEP20USDT public token;
    //PQR public token_;
    DEELIAN public token_;


  
    mapping(address=>mapping(address=>uint)) public allowance;
    mapping (address => uint) public A_ee_deelian; ////mapping of address to ee_deelian
    mapping (address => uint) public B_ee_deelian; ////mapping of address to ee_deelian
	
	  // address public address2= 0x4513E89E26F192cbE7F45C3127aFBe5Dfb7F97ab; //sample reciever

     address private reserve_address; //reserve address
     address private TokenA = 0x2b926BB1260Ca7e1b435AA3124ca891FE2532096; //usdt
    // address private TokenB = 0x2aB5d989a3FB1A32fbc9de50280EBdbF0E7407f5; //deelian/usdt5
     address private TokenB = 0xD897b2bF9b8BD40C8842155f4632b514788a2F52; //new deelian
    uint amountA;
    uint amountB;
    uint novuxa_price;
    uint tkdA = 10**18; /// token decimal A
    uint tkdB = 10**5; /// token Decimal B
    uint tkdD = tkdA - tkdB; /// token Decimal Difference
 

     event Transfer(address indexed from, address indexed to, uint value);
     event Approval(address indexed owner, address indexed spender, uint value);
     event SWAPABa(uint indexed date, address indexed from, address indexed to , uint value, uint price0, uint price1);
     event SWAPABb(uint  indexed date, address indexed from, address indexed to , uint value, uint price0, uint price1);
     event SWAPBAa(uint indexed date, address indexed from, address indexed to , uint value, uint price0, uint price1);
     event SWAPBAb(uint indexed date, address indexed from, address indexed to , uint value, uint price0, uint price1);
     event ALiquidityProvider(uint indexed date, address indexed from, address indexed to , uint value, uint amount);
    event BLiquidityProvider(uint indexed date, address indexed from, address indexed to , uint value, uint price);
     event RemoveALiquidityProvider(uint indexed date, address indexed from, address indexed to , uint value, uint price);
     event RemoveBLiquidityProvider(uint indexed date, address indexed from, address indexed to , uint value, uint price);
    // event _LP_Balance_Token1(uint value);
    // event _LP_Balance_Token2(uint value);

              
                         
              
    
      constructor() public  {
      owner = msg.sender;
      token = BEP20USDT(TokenA);
     // token_ = PQR(TokenB);
      token_ = DEELIAN(TokenB);
      
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

/////////////////////////////////////////////////////////////////////
  function setreserve_address(address x) public {
      require(msg.sender == owner, "Only Novuxa Contract can perform this action.");
       reserve_address = x;
   }

    function getreserve_address() public view returns (address) {
              
     return reserve_address;
               
    }     

/////////////////////////////////////////////////////////////////////////////////////////





   function  novuxa_Balance_Token1() external view returns(uint) {
      return token.balanceOf(msg.sender)/tkdA;
      
          }



      function  novuxa_Balance_Token2() external view returns(uint) {
      return token_.balanceOf(msg.sender)/tkdB;
      
      
    }


      function  LP_Balance_Token1() external  view returns(uint) {
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
        require(token_.balanceOf(address(this))*tkdA >= amountq/tkdA, "Not Enough Liquidity For this SWAP");
       // token_.transfer(msg.sender, amountq);
      //  token_.transferFrom(reserve_address, msg.sender, amountq);     
        token_.transferFrom(address(this), msg.sender, amountq*tkdD);
        token.approve(TokenA, amountA);
        emit SWAPABa(now, msg.sender, address(this), amountA*tkdA, token.balanceOf(address(this)), token_.balanceOf(address(this)));
        emit SWAPABb(now, address(this), msg.sender,  amountq, token.balanceOf(address(this)), token_.balanceOf(address(this)));
       
           
    }


      function SwapBA(uint amountB) public swap_checkB(amountB) {
           token_.transferFrom(msg.sender, address(this), amountB*tkdB);
           uint256 fee = amountB*tkdB / 1000; // 0.1% swap fee
           uint256 amountq = (amountB*tkdB) - fee;
           require(token.balanceOf(address(this)) >= amountq/tkdB, "Not Enough Liquidity For this SWAP");
           token.transfer(msg.sender, (amountq));
           token_.approve(TokenB, amountB);
           emit SWAPBAa(now, msg.sender, address(this), amountB*tkdA, token.balanceOf(address(this)), token_.balanceOf(address(this)));
           emit SWAPBAb(now, address(this), msg.sender,  amountq, token.balanceOf(address(this)), token_.balanceOf(address(this)));
     
    }



 function AProvide_Liquidity_Novuxa(uint256 value) swap_checkA(value) external  {
            uint256 fee = value*tkdA / 1000; // 0.1% swap fee
            uint256 valueq = (value*tkdA) + fee;
            token.transferFrom(msg.sender, address(this), valueq);
            A_ee_deelian[msg.sender] += valueq;
   emit ALiquidityProvider(now,  msg.sender, address(this), valueq,  A_ee_deelian[msg.sender]);
    }

 


    function BProvide_Liquidity_Novuxa(uint256 value) swap_checkB(value)external  {
            uint256 fee = (value*tkdB) / 1000; // 0.1% swap fee
            uint256 valueq = (value*tkdB) + fee;
            token_.transferFrom(msg.sender, address(this), valueq);
            B_ee_deelian[msg.sender] += valueq;
    emit BLiquidityProvider(now,  msg.sender, address(this), valueq, B_ee_deelian[msg.sender]);
    }

    function Remove_A_Liquidity_Novuxa(uint256 value) external  {
           require(A_ee_deelian[msg.sender] >= value, 'balance too low');
            A_ee_deelian[msg.sender] = A_ee_deelian[msg.sender] - value;
            uint256 fee = (value*tkdA) / 100; // 1% Liquidity removal fee
            uint256 valueq = (value*tkdA) - fee;
            require(block.timestamp >= now + 180 days);
            token.transfer(msg.sender, valueq);
       emit RemoveALiquidityProvider(now,  address(this), msg.sender,  valueq, (token.balanceOf(address(this))/token_.balanceOf(address(this))));
    }


       function Remove_B_Liquidity_Novuxa(uint256 value) external only_novuxa {
            uint256 fee = (value*tkdB)/ 100; // 1% Liquidity removal fee
            uint256 valueq = (value*tkdB) - fee;
            require(block.timestamp >= now + 180 days);
            token_.transferFrom(address(this), msg.sender, valueq);
            emit RemoveBLiquidityProvider(now,  address(this),  msg.sender, valueq, (token.balanceOf(address(this))/token_.balanceOf(address(this))));
      
    }



}