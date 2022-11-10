/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IBEP20 {
 
  function totalSupply() external view returns (uint256);
  
  function burnToken() external view returns (uint256);

 
  function decimals() external view returns (uint8);

  
  function symbol() external view returns (string memory);

 
  function name() external view returns (string memory);

  
  function getOwner() external view returns (address);


  function balanceOf(address account) external view returns (uint256);

 
  function transfer(address recipient, uint256 amount) external returns (bool);

 
  function allowance(address _owner, address spender) external view returns (uint256);

 
  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
  constructor ()  { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
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
    // Solidity only automatically asserts when dividing by 0
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

contract GTI is Context, IBEP20, Ownable {
  using SafeMath for uint256;
  
  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    uint256 public deployedTime;
    uint256 public distributeStatus=0;
    uint256 public devDistributeStatus=0;    
    uint256 private _burnToken=0;
    bool public hasDestritubed=false;
    address public prePostSaleWallet = 0x483331225f02296569337698F2222Ee284D18dE4;
    address public marketingWallet = 0x483331225f02296569337698F2222Ee284D18dE4;
    address public devTeamWallet = 0x483331225f02296569337698F2222Ee284D18dE4;
    constructor()  {
        _name =  "Gold Trading Internacional";
        _symbol = "GTI";
        _decimals = 18;
        _totalSupply = 21000000 * 10**18;
        _balances[address(this)] = _totalSupply;
        deployedTime = block.timestamp;
        emit Transfer(address(0), address(this), _totalSupply);
    }

 
  function decimals() override external view returns (uint8) {
    return _decimals;
  }


  function getOwner() override external view returns (address) {
    return owner();
  }  

  function symbol()  override external view returns (string memory) {
    return _symbol;
  }

  
  function name() override external view returns (string memory) {
    return _name;
  }

 
  function totalSupply() override external view returns (uint256) {
    return _totalSupply;
  }
  
  function burnToken() override external view returns (uint256) {
    return _burnToken;
  }

  function balanceOf(address account) override public view returns (uint256) {
    return _balances[account];
  }

 
  function transfer(address recipient, uint256 amount) override external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) override external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) override external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

 
  function transferFrom(address sender, address recipient, uint256 amount) override external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  function burn(uint256 amount) public onlyOwner returns (bool) {
    _burn(_msgSender(), amount);
    _burnToken=amount+_burnToken;
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

    function _burnFrom(address account, uint256 amount) internal {
      _burn(account, amount);
      _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }

    function claimDevTeam() public onlyDevTeam{
        require(msg.sender != address(0),"Invalid address");
        uint256 devTeamShare = _totalSupply.mul(10).div(100);    
        if(deployedTime + 365 days <= block.timestamp && devDistributeStatus == 0){
          _transfer(address(this),devTeamWallet,devTeamShare.mul(20).div(100));        
          devDistributeStatus = 1;
        }else if(deployedTime + 730 days <= block.timestamp && devDistributeStatus == 1){
          _transfer(address(this),devTeamWallet,devTeamShare.mul(30).div(100));        
          devDistributeStatus = 2;     
        }else if(deployedTime + 1095 days <= block.timestamp && devDistributeStatus == 2){
          _transfer(address(this),devTeamWallet,devTeamShare.mul(50).div(100));        
          devDistributeStatus = 3;         
        }else{
          if(devDistributeStatus+1 == 4){
            revert("Token already distributed");
          }else{
            revert("Time period is not met");  
          }
        }   
    }

    modifier onlyDevTeam() {
      require(devTeamWallet == msg.sender, "Ownable: caller is not the DevTeam");
      _;
    }

    function claimByOwner() public onlyOwner{
        uint256 halfSupplyShare =  _totalSupply.mul(50).div(100);  
        if(deployedTime + 365 days <= block.timestamp && distributeStatus == 0){
          _transfer(address(this),owner(),halfSupplyShare.mul(20).div(100));          
          distributeStatus = 1;
        }else if(deployedTime + 730 days <= block.timestamp && distributeStatus == 1){
          _transfer(address(this),owner(),halfSupplyShare.mul(30).div(100));     
          distributeStatus = 2;     
        }else if(deployedTime + 1095 days <= block.timestamp && distributeStatus == 2){
          _transfer(address(this),owner(),halfSupplyShare.mul(50).div(100)); 
          distributeStatus = 3;         
        }else{          
          if(distributeStatus+1 == 4){
            revert("Token already distributed");
          }else{
            revert("Time period is not met");  
          }
        }
    }

    // DISTRIBUTE TOKENS
    function destributeTokens() public onlyOwner{
        require(hasDestritubed == false,"Token already distributed");
        if(hasDestritubed == false){
          _transfer(address(this),prePostSaleWallet, (_totalSupply.mul(30)).div(100));  // pre and post Sale wallet                  
          _transfer(address(this),marketingWallet, (_totalSupply.mul(10)).div(100));  // Marketing team Wallet 
          hasDestritubed=true;         
        } 
    }

    function setPrePostSaleAddress(address _address) public onlyOwner returns (bool){
        prePostSaleWallet = _address;
        return true;
    }

    function setDevelopementAddress(address _address) public onlyOwner returns (bool){
        devTeamWallet = _address;
        return true;
    }

    function setMarketingAddress(address _address) public onlyOwner returns (bool){
        marketingWallet = _address;
        return true;
    }

    // OWNER FUNCTION
    function withdrawToken() public onlyOwner{
      require(balanceOf(address(this))>0,"Insufficent balance");
       _transfer(address(this),owner(),balanceOf(address(this)));        
    }
}