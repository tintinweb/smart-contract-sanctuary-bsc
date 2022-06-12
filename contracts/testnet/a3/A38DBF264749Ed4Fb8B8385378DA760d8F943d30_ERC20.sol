/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract ERC20{
    
    string public constant name = "MEHI MK";
    string public constant symbol = "$$-MK";
    uint8 public constant decimals = 18;
    uint  public totalSupply=1000000000e18;
    address Owner;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
   // mapping (address  => bool) public frozen ;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    constructor()  {
        Owner=msg.sender;

        balanceOf[Owner]=totalSupply;
    }

 
    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    
        function transfer(address to, uint value) external returns (bool) {
        //require(balanceOf>0);
        // require(!frozen[from]);
        balanceOf[msg.sender] = balanceOf[msg.sender]-(value);
        balanceOf[to] = balanceOf[to]+value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    

    function transferFrom(address from, address to, uint value) external returns (bool) {
        if (allowance[from][msg.sender] != uint(int(-1))) {
            allowance[from][msg.sender] = allowance[from][msg.sender]-(value);
        }
         emit Transfer(from, to, value);
        return true;
    }

 
}