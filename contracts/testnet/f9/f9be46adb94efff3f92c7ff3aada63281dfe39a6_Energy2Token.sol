/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

pragma solidity ^0.8.11;
// SPDX-License-Identifier: MIT

interface IPinkAntiBot 
{
  function setTokenOwner(address owner) external;
  function onPreTransferCheck(address from, address to, uint256 amount) external;
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


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0;  }
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

    function includeToWhiteList(address _users, bool _value) external onlyOwner 
    {
        _whiteList[_users] = _value;
    }
}



contract Energy2Token is IBEP20, LockToken
{
    using SafeMath for uint256;
        address public marketingAddress = 0x1043637BfF126656019c9627480f4afBD1926254;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 public _totalSupply = 10_000_000 * 10**18;
    string public _name = "Energy Token";
    string public _symbol = "Energy";
    uint256 public _decimals = 18;
    
    uint256 public _marketingFee = 1;
    uint256 private _previousMarketingFee = _marketingFee;
  
    uint256 _saleMarketingFee = 1;

    address public poolPair; 
    IPinkAntiBot public pinkAntiBot;
    
    constructor() 
    {
        _balances[owner()] = _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);
        pinkAntiBot = IPinkAntiBot(0xbb06F5C7689eA93d9DeACCf4aF8546C4Fe0Bf1E5);
        pinkAntiBot.setTokenOwner(owner());
    }


    function updateIPinkAntiBotAddress(address _address) external onlyOwner
    {
        pinkAntiBot = IPinkAntiBot(_address);
    }

    function burn(uint256 newAmount) external onlyOwner
    {
        _balances[owner()] = _balances[owner()].sub(newAmount); 
        _totalSupply = _totalSupply.sub(newAmount);
        emit Transfer(owner(), address(0), newAmount);
    }


    event poolPairUpdated(address account, uint256 timestamp);
    function setPoolPair(address _address) external onlyOwner
    {
         poolPair = _address;
    }

    mapping(address => bool) public _isBlacklisted;

    event BlackListed(address account, bool _enabled, uint256 timestamp);
    function blacklistAddress(address account, bool _enabled) external onlyOwner
    {
        _isBlacklisted[account] = _enabled;
        emit BlackListed(account, _enabled, block.timestamp);
    }

    
    function checkForBlackList(address from, address to) private view
    {
        require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Blacklisted address');
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


    function balanceOf(address _owner) public view returns(uint256) {
        return _balances[_owner];
    }


    function checkBeforeTransfer(address from, address to, uint256 amount) private 
    {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "BEP20: transfer to the zero address");
        pinkAntiBot.onPreTransferCheck(from, to, amount);
        checkForBlackList(from, to);
    }


    function _transfer(address from, address to, uint256 amount) private
    {
        _balances[to] = _balances[to].add(amount);
        _balances[from] = _balances[from].sub(amount);
        emit Transfer(msg.sender, to, amount);
    }

    function transfer(address to, uint256 amount) public open(msg.sender, to) returns(bool) 
    {
        require(balanceOf(msg.sender) >= amount, 'balance too low');
        checkBeforeTransfer(msg.sender, to, amount);
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public open(from, to)  returns(bool) 
    {
        require(_allowances[from][msg.sender] >= amount, 'allowance too low');
        require(balanceOf(from) >= amount, 'balance too low');
        checkBeforeTransfer(from, to, amount);
        _transfer(from, to, amount);
        _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(amount);
        return true;
    }


    function approve(address spender, uint256 value) public returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

//burn token


    function setSaleFee() private {
        _marketingFee = _saleMarketingFee;
    }
    
    function setAllBuyFeePercent(uint256 marketingFee) external onlyOwner() 
    {


        _marketingFee = marketingFee;
        _previousMarketingFee = marketingFee;

        require((_marketingFee)<=10, "Too High Fee");

    }


    function setAllSaleFeePercent(uint256 marketingFee) 
    external onlyOwner() 
    {
        _saleMarketingFee = marketingFee;
        require((_saleMarketingFee)<=15, "Too High Fee");
    }

}