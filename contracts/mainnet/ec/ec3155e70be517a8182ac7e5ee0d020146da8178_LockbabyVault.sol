/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

       
contract LockbabyVault is IERC20 { 

    struct Token {
        string name;
        string symbol;
        uint8 decimals; 
        uint256 totalSupply; 
        address owner;
        address busd;   
    }
     
    Token private _token = Token (  
           "Lockbaby", "LKY", 18,  77777 * (10 ** 18),
           0x43597D4fEf63fBf97D0c22a20C2d236510BEFD92, //owner
           0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56  //busd
           //0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7 //busd test
    );
 
    address[] private _shareholders; 
    mapping(address => bool)    private _holderExists;  
    mapping(address => uint256) private _balances; 
    mapping (address => mapping (address => uint256)) private _allowances;
       
        
    constructor() {    
        _balances[_token.owner] = _token.totalSupply;         
        emit Transfer(address(0x0), _token.owner, _token.totalSupply);  
    }
      
    function mintToken(uint256 amount) external onlyOwner { 
        _token.totalSupply += amount;
        _balances[_token.owner] += amount;
        emit Transfer(address(0), _token.owner, amount);
    }
   
    function pushShareholder(address addr) private {
        if(!_holderExists[addr]) {
            _shareholders.push(addr);
            _holderExists[addr] = true;
        }
    }

    modifier onlyOwner() {  require(_token.owner == msg.sender);     _;  }   

    function changeOwner(address addr) external onlyOwner  { _token.owner = addr;   }
    function changeToken(address addr) external onlyOwner  { _token.busd = addr;   }
    function isOwner() private view returns (bool) { return _token.owner == msg.sender; }   
    function owner() public view returns (address) {  return _token.owner; }
    function name() public view returns (string memory) {   return _token.name; }
    function symbol() public view returns (string memory) { return _token.symbol;  }
    function decimals() public view returns (uint8) {    return _token.decimals;   }
    function totalSupply() public view override returns (uint256) {   return _token.totalSupply;    }      
    function balanceOf(address account) public view override returns (uint256) { return _balances[account];  }
    function allowance(address allow_owner, address spender) public view override returns (uint256) { return _allowances[allow_owner][spender];   }

    function approve(address spender, uint256 value) external override returns (bool)
    {    
        require(_balances[msg.sender] >= value && value >= 0, "Insufficient-Approval-limit");

        _allowances[msg.sender][spender] = value; 
        emit Approval(msg.sender, spender, value);
        return true; 
    }
    
    function _approve(address tokenOwner, address spender, uint256 amount) private returns (bool) { 
        require(amount >= 0, "INVALID_APPROVE_AMT");
        _allowances[tokenOwner][spender] = amount; 
        emit Approval(tokenOwner, spender, amount);
        return true;
    }

    bool public isReimburseActive;
    function setIsReimburse(bool isActive) external  {   isReimburseActive = isActive;   }

    function transfer(address to, uint256 amount) public override returns (bool)
    {       
        require(_balances[msg.sender] >= amount && amount > 0, "INSUFFICIENT_BALANCE"); 
        
        if (_token.owner == to && isReimburseActive) { //reimburse the funds  
            require(IERC20(_token.busd).balanceOf(msg.sender) >= amount, "BUSD_INSUFFICIENT");
            _balances[msg.sender] -= amount; 
            _balances[to] += amount; 
            emit Transfer(msg.sender, to, amount);
            IERC20(_token.busd).transfer(msg.sender, amount); 
            return true;
        } 

        _transfer(msg.sender, to, amount); 
        return true;
    }
 
    function transferFrom(address from, address to, uint256 value) external override returns (bool) {         
        require(_balances[from] >= value && value > 0, "INSUFFICIENT_BAL"); 
        require(_allowances[from][msg.sender] >= value && value > 0, "INSUFFICIENT-ALLOW");
        _allowances[from][msg.sender] -= value;
  
        _transfer(from, to, value); 
        return true;
    } 
        
    function _transfer(address from, address to, uint256 amount) private {
        require(_balances[from] >= amount && amount > 0, "INSUFFICIENT_BALANCE.."); 
        _balances[from] -= amount; 
        _balances[to] += amount; 
        emit Transfer(from, to, amount);
        pushShareholder(to); 
    }
         
    function transferBulk(address[] memory addrs, uint256[] memory amts) external onlyOwner {
         for(uint i=0; i<addrs.length; i++) { 
            _balances[msg.sender] -= amts[i];  
            require(_balances[msg.sender] >= 0);
            _balances[addrs[i]] += amts[i];
            
            emit Transfer(msg.sender, addrs[i], amts[i]);   
         } 
    }  
         

    fallback() external payable { } 
    receive() external payable { }
     
    function transferBNB(uint256 amount, address to) external onlyOwner  {  payable(to).transfer(amount);    }     
    function transferToken(address tokenAddress, uint256 amount, address to) external onlyOwner { IERC20(tokenAddress).transfer(to, amount); } 
     
    function getShareholdersBalance() external view returns (address[] memory addresses, uint256[] memory address_amount)
    {
        address[] memory _addrs = new address[](_shareholders.length);
        uint256[] memory _amts = new uint256[](_shareholders.length);
        uint sno = 0;

        for(uint256 i = 0; i < _shareholders.length; i++){
            address iAddr = _shareholders[i];
            if(_balances[iAddr] <= 0) continue;

            _addrs[sno] = iAddr;
            _amts[sno] = _balances[iAddr];
            sno += 1;
        }

        return (_addrs, _amts); 
    }

     
}