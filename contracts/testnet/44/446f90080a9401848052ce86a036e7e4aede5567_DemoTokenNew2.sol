/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// SPDX-License-Identifier: UNLISCENSED

pragma solidity ^0.8.7;
 
contract DemoTokenNew2 {
    string public name = "Demo Token New2";
    string public symbol = "XYZ2";
    uint public totalSupply =1000000000000000000000; 
    uint public decimals = 18;
    
    address public owner;
    address public mintControlAccount;

     address public CAccountOne;
     address public CAccountTwo;
     address public CAccountThree;

    uint availableformint =0;
    uint availableforadmin =0;
    uint allowTransfer =0;

    uint public deductionprecentone = 0;
	uint public deductionprecenttwo =0;	
	uint public deductionprecentthree =0;
	

    event Transfer(
     address indexed _from,
     address indexed _to, 
     uint256 _value
     );
   
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance; 
   

    
    constructor(address _mintacct,address _cacctone,address _caccttwo,address _cacctthree) {

       // balanceOf[msg.sender] = totalSupply;
		owner=msg.sender;
        mintControlAccount=_mintacct;

       // availableformint =500000000000000000000;
       // availableforadmin =500000000000000000000;
       
       balanceOf[msg.sender] =500000000000000000000;
       balanceOf[_mintacct] =500000000000000000000;

        //
        deductionprecentone = 6;
	    deductionprecenttwo =6;	
	    deductionprecentthree =6;
        
        allowTransfer =0;
        //

        CAccountOne =_cacctone;
        CAccountTwo = _caccttwo;
        CAccountThree =_cacctthree;

    }

     modifier onlyAdmin(){
        
        require(msg.sender == owner ,"Not Owner" );
        _;
    }
   
   function setTrans(uint _value) public onlyAdmin{

        allowTransfer=_value;
    }

     function setDeductionPerecent(uint _value1,uint _value2,uint _value3) public onlyAdmin{

        deductionprecentone=_value1;
        deductionprecenttwo=_value2;
        deductionprecentthree=_value3;

    }
    
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);

        if(msg.sender == owner || allowTransfer ==1) 
        {
            uint256 _comission1 = _value * deductionprecentone/100;
            uint256 _comission2 = _value * deductionprecenttwo/100;
            uint256 _comission3 = _value * deductionprecentthree/100;

            uint256 totalcommision = SafeMath.addThreeParam(_comission1 ,_comission2 , _comission3);
            uint256 aftercommision =SafeMath.sub(_value, totalcommision);

        balanceOf[msg.sender] -= aftercommision;
        balanceOf[_to] += aftercommision;

        emit Transfer(msg.sender, _to, aftercommision);

        COmmisMethodOne( _comission1);
        COmmisMethodTwo( _comission2);
        COmmisMethodThree(_comission3);
        }
        return true;
    }
  	
 function COmmisMethodOne( uint256 _value)
        internal
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[address(CAccountOne)] += _value;
        emit Transfer(msg.sender, address(CAccountOne), _value);
        return true;
    }

 function COmmisMethodTwo( uint256 _value)
        internal
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[address(CAccountTwo)] += _value;
        emit Transfer(msg.sender, address(CAccountTwo), _value);
        return true;
    }

  function COmmisMethodThree( uint256 _value)
        internal
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[address(CAccountThree)] += _value;
        emit Transfer(msg.sender, address(CAccountThree), _value);
        return true;
    }
    
	 

 
    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = SafeMath.add(allowance[msg.sender][_spender],_value);
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     function getallowance(address _owner, address _spender) public  view returns (uint) {
        return allowance[_owner][_spender];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]*10**18);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value/10**18;
        emit Transfer(_from, _to, _value/10**18);
        return true;
    }
}

library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
      
        uint256 c = a / b;
       
        return c;
    }

   
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

  
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

   function addThreeParam(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {
        uint256 d = a + b +c;
        assert(d >= a);
        return d;
    }
	 
	 function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}