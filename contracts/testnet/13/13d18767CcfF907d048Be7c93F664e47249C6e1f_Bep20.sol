/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

// SPDX-License-Identifier: MIT

 pragma solidity ^ 0.8.2;
  
   contract Bep20 {

  
    string public Name = "Fan Token System" ;

     string public  Symbol =  "FTS" ;

       uint public totalSupply = 1000000 * 10 ** 18;

       uint public  Desimal = 18 ; 

         mapping ( address => uint256 ) balances ;

         mapping ( address => mapping ( address => uint256 )) allowance ;

      event Transfer ( address indexed from , address indexed to , uint256 amount ) ;

      event Approval ( address indexed from , address indexed to , uint256 amount ) ;

         constructor ( ) {
          
          balances [msg.sender] = totalSupply ; 
     }

      function balanceOf ( address account ) public view returns ( uint256 ) {
        
        return balances [account ] ;
     }

      function transfer ( address to , uint amount ) public returns ( bool) {
         require ( amount >= balances [msg.sender] ) ; 
            balances [msg.sender] -= amount ;
          balances [to] += amount ;
          emit Transfer ( msg.sender , to , amount );
       return true ;
     }

      function trasnferFrom ( address from , address to , uint amount ) public returns (bool ) {
           require ( balances [from] >= amount ) ;
         require ( allowance [from] [msg.sender] >= amount );

          balances [from] -= amount ;
          balances [to] += amount ;

         emit Transfer ( from , to , amount ) ;
          return true ;
      }

      function approve ( address spender , uint amount ) public returns ( bool ) {
           allowance [msg.sender] [spender] = amount ;
         emit Approval ( msg.sender , spender, amount );
      
       return true ;
     }
  }