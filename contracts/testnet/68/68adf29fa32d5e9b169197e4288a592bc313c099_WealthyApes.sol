/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: MIT

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint256);
    function getOwner() external view returns (address);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor ()  {
        address msgSender = 0x8A911e1afF89a0A58E224Da43E8E4D8A4d756614; //0x180ec8204eaA2b949C43F6574c903BB475730FE3;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract WealthyApes is IBEP20, Ownable
{
    using SafeMath for uint256;
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    mapping(address => bool) private _excludedFromWhale;
    uint public _totalSupply = 50_000_000_000 * 10**18;
    string public _name = "Wealthy Apes";
    string public _symbol = "$APES";
    uint256 public _decimals = 18;
    address public poolAddress; 
    uint256 public maxWalletLimit = _totalSupply.div(100);
    uint256 public maxSaleTxAmount = _totalSupply.mul(5).div(1000);

    
    
    constructor() 
    {
        _balances[owner()] = _totalSupply;
        _excludedFromWhale[owner()] = true;
        _excludedFromWhale[address(this)] = true;
        emit Transfer(address(0), owner(), _totalSupply);
    }


    function setPoolAddress(address _address) external onlyOwner
    {
        poolAddress = _address;
        _excludedFromWhale[_address] = true;
    }


    function checkForWhale(address from, address to, uint256 amount)  private view
    {
        uint256 newBalance = balanceOf(to).add(amount);

        if(!_excludedFromWhale[from] && !_excludedFromWhale[to]) 
        {
            require(newBalance <= maxWalletLimit, "Exceeding Max Wallet Limit");
        }

        if(from == poolAddress && !_excludedFromWhale[to])
        {
            require(newBalance <= maxWalletLimit, "Exceeding Max Wallet Limit");
        }

        if(to == poolAddress && !_excludedFromWhale[from]) 
        {
            require(amount <= maxSaleTxAmount, "Exceeding Max Sale Limit");
        }
    }

    event MaxWalletLimitUpdated(uint256 _amount, uint256 timestamp);
    function setMaxWalletLimit(uint256 _amount) external onlyOwner
    {  
        maxWalletLimit = _amount;
        emit MaxWalletLimitUpdated(_amount, block.timestamp);
    }

    event MaxSaleTxAmount(uint256 _amount, uint256 timestamp);
    function setMaxSaleTxAmount(uint256 _amount) external onlyOwner
    {  
        maxSaleTxAmount = _amount;
        emit MaxSaleTxAmount(_amount, block.timestamp);
    }

    event WhiteListed(address account, bool enabled, uint256 timestamp);
    function includeToWhiteList(address account, bool _enabled) external onlyOwner 
    {
            _excludedFromWhale[account] = _enabled;
            emit WhiteListed(account, _enabled, block.timestamp);
    }


    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint256) 
    {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function getOwner() external view override returns (address)
    {
        return owner();
    }


    function balanceOf(address _owner) public view returns(uint) {
        return _balances[_owner];
    }

    function transfer(address to, uint value) public returns(bool) 
    {
        require(to != address(0), "Transfer to zero address");
        require(value > 0, "Amount cannot be zero.");
        require(balanceOf(msg.sender) >= value, 'balance too low');
        checkForWhale(msg.sender, to, value);
        _balances[to] = _balances[to].add(value);
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool) 
    {
        require(to != address(0), "Transfer to zero address");
        require(value > 0, "Amount cannot be zero.");
        require(balanceOf(from) >= value, 'balance too low');
        require(_allowances[from][msg.sender] >= value, 'allowance too low');
        checkForWhale(from, to, value);
        _balances[to] = _balances[to].add(value);
        _balances[from] = _balances[from].sub(value);
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }


}