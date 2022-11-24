/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

library SafeMath{
    function mul(uint256 a,uint256 b) internal pure returns(uint256){
        if(a == 0){
            return 0;
        }
        uint256 c =a*b;
        require(c/a==b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256){
        require(b > 0);
        uint256 c = a /b;
        return c;
    }

    function sub(uint256 a,uint256 b) internal pure returns(uint256){
        require(a>=b);
        uint256 c = a-b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256){
        uint256 c =a +b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a,uint256 b) internal pure returns(uint256){
        require(b!=0);
        return a%b;
    }
}

contract IcoToken{
    using SafeMath for uint256;
    mapping(address=>uint256) private _balances;
    mapping(address=>mapping(address=>uint256)) private _allowed;
    uint256 public totalSupplys;
    string public name;
    uint8 public decimals;
    string public symbol;
    address payable private _feeReceiver;
    address private _owner;


    constructor(uint256 totalSupply, address payable feeReceiver) payable{
        require(feeReceiver != address(0));
        name = "CQANT";
        symbol = "cqant";
        _feeReceiver = feeReceiver;
        _owner = msg.sender;
        decimals = 2;
        mint(totalSupply);
    }

    function mint(uint256 value) public payable returns(bool){
        require(value > 0);
        require(_owner == msg.sender);
        totalSupplys = totalSupplys.add(value);
        _balances[_owner] = _balances[_owner].add(value);
        _feeReceiver.transfer(msg.value);
        return true;
    }

    function balanceOf(address owner) public view returns(uint256){
        return _balances[owner];
    }

    function allowed(address owner, address spender) public view returns(uint256){
        return _allowed[owner][spender];
    }

    
    function transfer(address to, uint256 value) public returns(bool){
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns(bool){
        require(value >= _allowed[from][msg.sender]);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns(bool){
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function burn(uint256 value) public returns(bool){
        _burn(msg.sender, value);
        return true;
    }
    function burnFrom(address spender, uint256 value) public returns(bool){
        require(spender != address(0));
        require(_allowed[spender][msg.sender] >= value);
        _allowed[spender][msg.sender] = _allowed[spender][msg.sender].sub(value);
        _burn(spender, value);
        return true;
    }


    function _burn(address account, uint256 value) internal{
        require(account != address(0));
        require(_balances[account] >= value);
        _balances[account] = _balances[account].sub(value);
        totalSupplys = totalSupplys.sub(value);
        emit Transfer(account, address(0), value);
    }



    function _transfer(address from, address to, uint256 value) internal{
        require(_balances[from] >= value);
        require(to != address(0));
        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);
       emit Transfer(from, to, value);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


}