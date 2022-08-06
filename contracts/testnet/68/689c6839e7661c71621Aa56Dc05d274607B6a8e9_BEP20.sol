/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: MIT
 
  pragma solidity ^ 0.8.0;
   
    contract BEP20 {

       mapping ( address => uint256 ) _balances ;
       mapping ( address => mapping ( address => uint256 )) _allowend;

        constructor ( string memory name_ , string memory symbol_ , uint8 decimals_ , uint256 totalSupply_ ) {
          
              _name = name_ ;
             _symbol = symbol_ ;
            _decimals = decimals_ ;
          _totalSupply = totalSupply_ ;

         _balances [msg.sender] = _totalSupply ;
         }

          string private _name ;

          string private _symbol ;

          uint8 private _decimals ;

          uint256 private _totalSupply ;


      event Transfer ( address indexed from , address indexed to , uint256 value );

      event Approval ( address indexed from , address indexed to , uint256 alue );

         function name () public view returns (string memory) {

       return _name ;
     } 

         function symbol () public view returns ( string memory ) {

       return _symbol ;
     }
        
         function decimals () public view returns ( uint8 ) {

       return _decimals;
     }

         function totalSupply () public view returns ( uint256 ) {

       return _totalSupply ;
     }

         function allowance ( address _owner , address _spender ) public view returns ( uint256 ) {

       return _allowend [_owner] [_spender] ;
     }

         function balanceOf ( address account ) public view returns ( uint256 ) {

       return _balances [account] ;
     }

       function transfer ( address _to , uint256 _value ) public returns ( bool ) {
        require ( msg.sender != address(0), "This address is Zero");
         require (  _to != address(0) ," This address is Zero ");
            
          _balances [msg.sender] = _balances [msg.sender] - _value ;
          _balances [_to] = _balances [_to] + _value ;
         
         emit Transfer ( msg.sender , _to , _value );
       return true ; 
     }

        function approve ( address _spender , uint _value ) public returns  ( bool ) {

           _allowend [msg.sender] [_spender] = _value ;
           emit Approval ( msg.sender , _spender , _value );

      return true ;
     }
        
       function transefrFrom ( address _from , address _to , uint256 _value ) public returns ( bool ) {
        require ( _from != address(0), "This address is Zero" );
         require ( _to != address(0), " This address is Zero" );

          _balances[_from] = _balances [ _from] - _value ;
          _balances [_to] = _balances [_to ] + _value ;

         emit Transfer ( _from , _to , _value );
      return true ;
    }

 }