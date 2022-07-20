/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

//////////////////////////////
/*
┏┓┏┓┏┓┏┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━
┃┃┃┃┃┃┃┃━━━━┏┛┗┓━━━━━━━━┃┏━┓┃━━━━━━━━━━━━━
┃┃┃┃┃┃┃┗━┓┏┓┗┓┏┛┏━━┓━━━━┃┃━┗┛┏━┓┏━━┓┏┓┏┓┏┓
┃┗┛┗┛┃┃┏┓┃┣┫━┃┃━┃┏┓┃━━━━┃┃━┏┓┃┏┛┃┏┓┃┃┗┛┗┛┃
┗┓┏┓┏┛┃┃┃┃┃┃━┃┗┓┃┃━┫━━━━┃┗━┛┃┃┃━┃┗┛┃┗┓┏┓┏┛
━┗┛┗┛━┗┛┗┛┗┛━┗━┛┗━━┛━━━━┗━━━┛┗┛━┗━━┛━┗┛┗┛━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Date        -->  2022/07/19
white crow  -->  Token BNB 
totalSupply -->  1.000.000.000
*/
//////////////////////////////
pragma solidity ^0.8.2;


contract WhiteCrow{

   

    mapping(address => uint) public balances;
    mapping(address => mapping(address=>uint)) public allownce;

    uint   public totalSupply = 1*10**9 ;
    string public name = "white crow" ;
    string public symbol = "wcw" ; 
    uint decimals = 9 ;

    event Transfer(address indexed from , address indexed to, uint value);
    event Approval(address indexed owner , address indexed spender, uint value);


    constructor() {
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender , totalSupply);
    }

    function balanceOf(address owner) public view returns(uint){
        return balances[owner];
    }

    function transfer(address to , uint value) public returns(bool){
        require(balanceOf(msg.sender) >= value , 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to , value);
        return true;
    }

    function transferFrom(address from , address to , uint value) public returns(bool){
        require(balanceOf(from) >= value, 'Balance not enough');
        require(allownce[from][msg.sender] >= value, 'allownce too low');
        balances[to] += value ;
        balances[from] -= value;
        emit Transfer(from , to , value);
        return true;
    }

    function approve(address spender , uint value) public returns(bool){
        allownce[msg.sender][spender] = value ;
        emit Approval(msg.sender , spender , value);
        return true;
    }

  function burn(uint256 _amount) public returns (bool success) {
      return MainBurn(_amount) ;
    }
    function MainBurn(uint256 _amount) public returns (bool success) {
        require(msg.sender != address(0), "Invalid burn recipient");
        require(balanceOf(msg.sender) >= _amount , 'balance too low');
        balances[msg.sender] -= _amount;
        totalSupply -= _amount;
        emit Transfer(msg.sender, address(0), _amount);
        return true;
    }

}