/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

// SPDX-License-Identifier: MIT

 pragma solidity ^0.8.0;

 contract ERC20 
 {

  address Owner ;

   constructor ( string memory name_, string memory symbol_, uint256 totalSupply_, uint8 decimals_ ) 
   {
     Owner = msg.sender ;

       _name = name_ ;
       _symbol = symbol_ ;
       _totalSupply = totalSupply_ ;
       _decimals = decimals_ ;

      _balances [msg.sender] = _totalSupply ;
   }

    string private _name ;

    string private _symbol ;

    uint256 private _totalSupply ;

    uint8 private _decimals ;

         mapping ( address => uint256 ) _balances ;
         mapping ( address => mapping ( address => uint256 )) _allowance ;

     event Transfer ( address indexed from, address indexed to, uint256 value );
     event Approval ( address indexed from, address indexed to, uint256 value );

         function name () public view returns ( string memory ) {

            return _name ;
         }


         function symbol () public view returns ( string memory ) {

            return _symbol ;
         }


         function totalSupply () public view returns ( uint256 ) {

            return _totalSupply ;
         }


         function decimals () public view returns ( uint8 ) {

            return _decimals ;
         }


         function balanceOf ( address account ) public view returns ( uint256 ) {

            return _balances [account] ;
         }


         function allowance ( address owner, address spender) public view returns ( uint256 ) {

            return _allowance [owner][spender] ;
         }


         function approve ( address spender, uint256 value ) public  returns ( bool ) {

             _allowance [msg.sender] [spender] = value ;
             emit Approval(msg.sender, spender, value);

           return true ;
         }

         function transfer ( address to, uint256 value ) public returns ( bool ) {
           require ( msg.sender != address(0));
            require ( to != address(0));

            _balances [msg.sender] = _balances [msg.sender] - value ;
            _balances [to] = _balances [to] + value ;

          emit Transfer ( msg.sender , to, value );
          return true ;
         }

         function transferFrom ( address from, address to, uint256 value ) public returns ( bool ) {
           require ( from != address(0));
           require ( to != address(0));

             _balances [from] = _balances [from] - value ;
             _balances [to] = _balances [to] + value ;

             emit Transfer ( from, to, value );
             return true ;
         }

 }