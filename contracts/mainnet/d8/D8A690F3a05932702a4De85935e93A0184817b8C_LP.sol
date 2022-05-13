/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

    library SafeMath {//konwnsec//安全数值运算库
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
                return 0; 
            }
            uint256 c = a * b;
            assert(c / a == b);
            return c; 
        }
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
// assert(b > 0); // Solidity automatically throws when dividing by 0
            uint256 c = a / b;
// assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
    }

    contract LP  {
        using SafeMath for uint;
        string public name; 
        string public symbol; 
        uint256 public decimals;
        uint256 public totalSupply; 
        mapping (address => uint256) public balanceOf;
        mapping (address => mapping (address => uint256)) public allowance;
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Burn(address indexed from, uint256 value);
         constructor( string memory tokenName) public {
            totalSupply = 10000000000000000000000000000;  
            balanceOf[msg.sender] = totalSupply;  
            name = tokenName;  
            symbol = tokenName; 
            decimals = 18; 
        }
 
        function _transfer(address _from, address _to, uint _value) internal { 
            require(_to != address(0)&& _from != _to);
            require(balanceOf[_from] >= _value);
            require(balanceOf[_to].add(_value) > balanceOf[_to]);
            uint previousBalances = balanceOf[_from].add(balanceOf[_to]); balanceOf[_from] = balanceOf[_from].sub(_value); balanceOf[_to] = balanceOf[_to].add(_value);
            emit Transfer(_from, _to, _value);
            assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances); 
        }

 
        function transfer(address _to, uint256 _value) public {
            // require(_to != address(0) && _to != _from); 
            _transfer(msg.sender, _to, _value); 
        }

 
        function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
            require(_value <= allowance[_from][msg.sender]); // Check allowance
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value); _transfer(_from, _to, _value);
            return true; 
        }

 
        function approve(address _spender, uint256 _value) public
            returns (bool success) {
            require(_spender != address(0));
            require((_value == 0) || (allowance[msg.sender][_spender] == 0));
            allowance[msg.sender][_spender] = _value;
            return true; 
        }

 
        function burn(uint256 _value) public returns (bool success) {
            require(balanceOf[msg.sender] >= _value); 
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value); 
            totalSupply = totalSupply.sub(_value); 
            emit Burn(msg.sender, _value);
            return true; 
        }
 
        function burnFrom(address _from, uint256 _value) public returns (bool success) {
            require(balanceOf[_from] >= _value); 
            require(_value <= allowance[_from][msg.sender]); 
            balanceOf[_from] = balanceOf[_from].sub(_value); 
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
             totalSupply = totalSupply.sub(_value); 
            emit Burn(_from, _value);
            return true; 
        }
    }