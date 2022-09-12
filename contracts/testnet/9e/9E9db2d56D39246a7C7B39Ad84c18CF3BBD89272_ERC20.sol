/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

// SPDX-License-Identifier: MIT

 pragma solidity ^0.8.0;

  interface IERC20 
  {
  
   function totalSupply () external view returns ( uint256 );

   function balanceOf ( address _account ) external view returns ( uint256 ) ;

   function allowance ( address _owner, address _spender ) external view returns ( uint256 );

    function transfer ( address _to, uint256 _value ) external returns ( bool );

    function approve ( address _spender, uint256 _value ) external returns ( bool );

    function transferFrom ( address _from, address _to, uint256 _value ) external returns ( bool );

      event Transfer ( address indexed _from, address indexed _to, uint256 _value );
      event Approval ( address indexed _from, address indexed _to, uint256 _value );

  }

   contract ERC20 is IERC20 
   { 
 
   address Owner ;

    constructor ( string memory name_, string memory symbol_, uint256 totalSupply_, uint8 decimals_) 
    {
        Owner = msg.sender ;

          _name = name_ ;
          _symbol = symbol_ ;
          _totalSupply = totalSupply_ ;
          _decimals = decimals_ ;
         _balances [msg.sender] = totalSupply_ ;

    }    

     string private _name ;

     string private _symbol ;

     uint256 private _totalSupply ;

     uint8 _decimals ;

          mapping ( address => uint256 ) _balances ;
          mapping ( address => mapping (address => uint256 )) _allowance ;

    
          function name () public view returns ( string memory ) {

            return _name ;
          }



          function symbol () public view returns ( string memory ) {

            return _symbol ;
          }



          function decimals () public view returns ( uint8 ) {

            return _decimals ;
          }



          function totalSupply () public view override returns ( uint256 ) {

            return _totalSupply;
          } 
   


          function balanceOf ( address account ) public view override returns ( uint256 ) {

            return _balances [account] ;
          }



          function allowance ( address owner, address spender ) public view override returns ( uint256 ) {

            return _allowance [owner][spender] ;
          }
          


          function approve( address spender, uint256  value) public override returns ( bool ) {
   
             _allowance [msg.sender] [spender] = value ;
             emit Approval (msg.sender, spender, value );

              return true ;
          }



          function transfer ( address to, uint256 value ) public override returns ( bool ) {
            require ( msg.sender != address(0));
             require ( to != address(0));

              _balances [msg.sender] = _balances [msg.sender] - value ;
              _balances [to] = _balances [to] + value ;
             
             emit Transfer ( msg.sender, to, value );
             return true ;
          }


         function transferFrom ( address from, address to, uint256 value ) public override returns ( bool ) {
            require ( from != address(0));
             require (to != address(0));

               _balances [from] = _balances [from] - value ;
               _balances [to] = _balances [to] + value ;
            
             emit Transfer ( from, to, value );
             return true ;
         } 


   }