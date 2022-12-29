/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

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
}

interface Erc20Token {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _who) external view returns (uint256);
    function transfer(address _to, uint256 _value) external;
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) external;
        
    function approve(address _spender, uint256 _value) external; 
    function burnFrom(address _from, uint256 _value) external; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
    
    
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

    

contract MASBS {
    using SafeMath for uint;
    Erc20Token constant internal _usdtIns = Erc20Token(0x55d398326f99059fF775485246999027B3197955); 
    Erc20Token constant internal _MASIns = Erc20Token(0x089AEFab91c5ce2D0534B31C711bA1633C7bf2f6);
    address public _owner;
    bool public _stoped = false; 
    function usdtConvert(uint256 value) internal pure returns(uint256) {
        return value.mul(1000000000000000000);
    }
    function MasConvert(uint256 value) internal pure returns(uint256) {
        return value.mul(1000000000000000000); 
    }
    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied"); _;
    }
    modifier isZeroAddr(address addr) {
        require(addr != address(0), "Cannot be a zero address"); _; 
    }
    function stopContract() public onlyOwner { 
        _stoped = !_stoped; 
    }
    modifier isStoped() {
        require(!_stoped, "The contract has been suspended"); _;
    }


    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            _owner = newOwner;
        }
    }
    receive() external payable {}     
}

contract buyMas is MASBS{
    uint256 public _usdtTotal;  
    uint256 public _MASToUsdtRate = 100000000000;  
    constructor(address owner ) isZeroAddr(owner)  public {
        _owner = owner; 
    }
    
    function buyMass(uint256 uValue) public  isStoped {
        require(uValue >= usdtConvert(1), "Not enough input");
        uint256 pValue = usdtToMAS(uValue);
        uint256 MASBalance = _MASIns.balanceOf(address(this));
        require(MASBalance >= pValue, "balance is not enough");
        _usdtTotal = _usdtTotal.add(uValue);
        _usdtIns.transferFrom(msg.sender, address(this), uValue);
        _usdtIns.transfer(_owner, uValue);
        _MASIns.transfer(msg.sender, pValue);
    }
 
    
   function extractMAS() public onlyOwner isStoped {
        uint256 MASBalance = _MASIns.balanceOf(address(this));
        _MASIns.transfer(_owner, MASBalance);
    }
    function updateMASToUsdtRate(uint256 rate) public onlyOwner isStoped {
        _MASToUsdtRate = rate;
    }

    function getMASToUsdtRate() public view returns(uint256) {
        return _MASToUsdtRate; 
    }

    function usdtToMAS(uint256 uValue) public view returns(uint256) {
        return uValue.div(_MASToUsdtRate.div(1)).mul(1000000000000); 
    }

    function MASToUSDT(uint256 pValue) public view returns(uint256) {
        return pValue.mul(_MASToUsdtRate.div(1)).div(1000000000000); 
    }
 
}