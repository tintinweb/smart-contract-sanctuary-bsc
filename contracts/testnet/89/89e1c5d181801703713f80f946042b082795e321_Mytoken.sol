/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Mytoken{
    string public name;
    string public symbol;
    uint8 public decimals ;


    event Approval(address indexed tokenowner,address indexed spender,uint tokens);
    event Transfer(address indexed from,address indexed to,uint tokens);



    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed ;

    uint256 totalsupply_;
    address admin;
    
  

    constructor(string memory _name, string memory _symbol,uint8 _decimals,uint _tsupply) {
        name= _name;
        symbol= _symbol;
        decimals= _decimals;
        totalsupply_=_tsupply;
        balances[msg.sender]= totalsupply_;
        admin= msg.sender;
    }
      modifier onlyadmin(){
        require(msg.sender==admin,"onlyadmin can mint");

        _;
    }

    function Totalsupply() public view returns(uint){
        return totalsupply_;
    }
    
    function balanceof(address _tokenowner) public view returns(uint){
        return balances[_tokenowner];
    }

    function transfer(address receiver, uint numbertoken) public  returns(bool){
        require(balances[msg.sender]>=numbertoken,"not suufficient token avaialbel");
        balances[msg.sender]-= numbertoken;
        totalsupply_-= numbertoken;
        balances[receiver]+=numbertoken;
        emit Transfer(msg.sender,receiver,numbertoken);
        return true;
    }

    function mint(uint _qty) public onlyadmin returns(uint){
        totalsupply_+= _qty;
        balances[msg.sender]+=_qty;
        return totalsupply_;
    }
    

    function burn(uint _qty) public onlyadmin returns(uint){
        totalsupply_-= _qty;
        balances[msg.sender]-=_qty;
        return totalsupply_;
    }

    function approve(address _spender, uint _value) public returns(bool){
        allowed[msg.sender][_spender]= _value;
        emit Approval(msg.sender,_spender,_value);
        return true;
       
    }

    function allowance(address owner, address spender) public view  returns(uint remaining){
        return allowed[owner][spender];
       
    }
 
    function transferfrom(address _from, address _to, uint _value) public  returns(bool){
        uint allowance1 =allowed[_from][msg.sender];
        require(balances[_from]>= _value && allowance1>= _value);
        balances[_from]-=_value;
        balances[_to]+=_value;
        allowed[_from][msg.sender]-=_value;
        emit Transfer(_from,_to,_value);

        return true;
    }
    
}