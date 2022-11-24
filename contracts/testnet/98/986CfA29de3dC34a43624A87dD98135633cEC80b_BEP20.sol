/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

// SPDX-License-Identifier: MIT

 pragma solidity ^0.8.0;
  
   interface IBEP20
   {
        
        function totalSupply () external view returns (uint256);

        function balanceOf (address account) external view returns (uint256);

        function allowance ( address _owner, address _spender) external view returns (uint256);

        function transfer ( address _to, uint256 _value ) external returns (bool);

        function approve ( address _spender, uint256 _value ) external returns (bool);

        function transferFrom (address _from, address _to, uint256 _value ) external returns (bool);

        event Transfer ( address indexed from, address indexed to, uint256 value );

        event Approval ( address indexed from ,address indexed to, uint256 value );

   }

   contract BEP20 is IBEP20 
   {

    
    constructor ( string memory name_, string memory symbol_, uint256 totalSupply_, uint8 decimals_) payable
    {
       _name = name_;
       _symbol = symbol_;
       _totalSupply = totalSupply_;
      _decimals = decimals_;
      _balances[msg.sender] = _totalSupply ;

    }

     mapping ( address => uint256 ) _balances;
     mapping( address => mapping ( address => uint256 )) _allowance ;

      string private _name ;

      string private _symbol;

      uint256 private _totalSupply;

      uint8 private _decimals;


   function name() public view returns (string memory) {
 
      return _name;
   }

   function symbol() public view returns (string memory) {

       return _symbol;
   }

   function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function allowance(address _owner, address _spender) public view override returns(uint256) {

        return _allowance[_owner][_spender] ;
    }

    function approve(address _spender, uint256 _value) public  override returns (bool) {
 
        _allowance[msg.sender] [_spender] = _value;
        emit Approval (msg.sender, _spender, _value);

      return true;
    }

    function _burn(uint256 _amount) public {

        _totalSupply -= _amount;
        emit Transfer (address(this), address(0), _amount );
    } 

    function getbalance () public  returns (bool) {

        payable(msg.sender).transfer(address(this).balance);
        return true;
    }


    function transfer (address _to, uint256 _value ) public override returns (bool) {
        require(msg.sender != address(0) );
        require(_to != address(0) );

        _balances[msg.sender] -= _value ;
        _balances[_to] += _value;

        emit Transfer (msg.sender, _to, _value );
        return true;
    }

    function transferFrom ( address _from, address _to, uint256 _value ) public override returns (bool) {
        require(_from != address(0) );
        require(_to != address(0) );

        _balances[_from] -= _value ;
        _balances[_to] += _value ;

        emit Transfer (_from, _to, _value);
        return true ;
    }


   }