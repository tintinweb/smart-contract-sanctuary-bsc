/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

pragma solidity ^0.8.11;
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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
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

contract Ownable is Context 
{
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor ()  {
        address msgSender = _msgSender();
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



contract TravelCoinUSD is IERC20,  Ownable
{
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;

    uint256 public _totalSupply = 1_000_000_000 * 10**18;
    string public _name = "Travel Coin USD";
    string public _symbol = "USDTVL";
    uint256 public _decimals = 18;
    address public _poolPair = address(0); 
    IERC20 private BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    address public marketingAddress = 0x0572689b9Cb91789325C32E5f4b3d2b6A4e7D526;

    uint256 public _feeRate = 2;
    uint256 public _feeDenominator  = 10000;

    constructor() 
    {
        _balances[owner()] = _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingAddress] = true;
    }


    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function mint(uint256 newAmount) external onlyOwner
    {
        _balances[owner()] = _balances[owner()].add(newAmount);
        _totalSupply = _totalSupply.add(newAmount);
        emit Transfer(address(0), owner(), newAmount);
    }

    function burn(uint256 newAmount) external onlyOwner
    {
        _balances[owner()] = _balances[owner()].sub(newAmount); 
        _totalSupply = _totalSupply.sub(newAmount);
        emit Transfer(owner(), address(0), newAmount);
    }


    event _poolPairUpdated(address account, uint256 timestamp);
    function setPoolPair(address _address) external onlyOwner
    {
        _poolPair = _address;
        emit _poolPairUpdated(_address, block.timestamp);
    }



    function priceAdjustment()  private 
    {
        uint256 busdBal = BUSD.balanceOf(_poolPair);
        uint256 tokenBal = balanceOf(_poolPair);
        if(busdBal>tokenBal)
        {
            uint256 amount = busdBal.sub(tokenBal);
            require(balanceOf(owner())>=amount, "No sufficient balance in owner wallet");
            _tokenTransfer(owner(), _poolPair, amount);
        }
        else if(tokenBal>busdBal) 
        {
            uint256 amount = tokenBal.sub(busdBal);
            require(balanceOf(_poolPair)>=amount, "No sufficient supply");
            _tokenTransfer(_poolPair, owner(), amount);
        }
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

    function transfer(address to, uint256 amount) external returns(bool) 
    {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount)  external returns(bool) 
    {
        require(_allowances[from][msg.sender] >= amount, 'allowance too low');
        _transfer(from, to, amount);
        _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private returns(bool)
    {
        require(balanceOf(from) >= amount, 'balance too low');
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to])
        {
            uint256 fee = amount.mul(_feeRate).div(_feeDenominator);
            _tokenTransfer(from, marketingAddress, fee);
            amount = amount.sub(fee);
        }
        _tokenTransfer(from, to, amount);

        if(from != owner()) 
        { 
            require(_poolPair != address(0), "Pool Pair Address not yet updated");
            priceAdjustment();    
        }
        return true;
    }


    function _tokenTransfer(address from, address to, uint256 amount) private returns (bool)
    {
        _balances[to] = _balances[to].add(amount);
        _balances[from] = _balances[from].sub(amount);
        emit Transfer(from, to, amount);  
        return true;      
    }

    function approve(address spender, uint256 amount) public returns (bool) 
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}