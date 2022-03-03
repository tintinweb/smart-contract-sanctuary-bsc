/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

pragma solidity ^0.5.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

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

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract SaleXToken is Ownable {
    // PT = Payed TOKEN e.g BUSD
    // ST = Sold  TOKEN e.g XToken
    using SafeMath for uint; 
    
    uint public SalePrice; //Sold Sold - Editable.
    
    /* for token Owner Start */
    uint public Sold          = 0; //Total Sold Token
    uint public Payed         = 0; //Total Payed Token
    uint public Withdrawn     = 0; //Total Withdrawn Payed Token 
    uint public Withdrawable  = 0; //Withdrawable Payed Token
    /* for token Owner End */ 
    
    bool public EndSale       = false;
    uint public MinSaleAmount;
    address public PTContract; 
    address public STContract; 
    
    
    mapping(address => bool) public authorizeds;
    mapping(address => bool) public ownerToken;  // Wallet having token
    mapping(address => uint) public amountSold; // Total Soled For Wallet
    
    event SoldEvet(address indexed purchaser,uint amount);
    
    constructor () public {
        SalePrice    = 20;
        Sold         = 0;
    }
    
    function setAuthorizeds (address _account,bool _mode) public onlyOwner returns (bool) {
        authorizeds[_account] = _mode;
        return true; 
    } 
     
    function updateSalePrice (uint _newprice) onlyOwner public returns (bool)  {
        SalePrice = _newprice;
        return true;
    } 

    function updateMinSaleAmount (uint _minSaleAmount) onlyOwner public returns (bool)  {
        MinSaleAmount = _minSaleAmount;
        return true;
    } 
    
    function getSTBalanceOf(address _address) public  view returns (uint) {
       return IERC20(STContract).balanceOf(_address);
    }
    
    function getPTBalanceOf(address _address) public  view returns (uint) {
        return IERC20(PTContract).balanceOf(_address);
    }
    
    function calculateTotal (uint _amount) public view returns (uint) {
        uint total     = (_amount * SalePrice) / 100;
        return total;
    }
    
    function updateSTContract (address _address) onlyOwner public returns (bool) {
        STContract = _address;
        return true;
    }
    
    function updatePTContract (address _address) onlyOwner public returns (bool) {
        PTContract = _address;
        return true;
    }
    
     function setEndSale (bool _endSale) onlyOwner public returns (bool) {
        EndSale = _endSale;
        return true;
    }
    
    function buy (uint _amount)  public returns(bool) {
        // 
        validateOrder(_amount);
        uint PTtotal     = setPTtotal(_amount);
        IERC20(PTContract).transferFrom(msg.sender, address(this), PTtotal);
        IERC20(STContract).transfer(msg.sender,_amount);
        emit SoldEvet(msg.sender,_amount);
        Sold += _amount;
        Payed += PTtotal;
        Withdrawable += PTtotal;
        ownerToken[msg.sender]  = true;
        amountSold[msg.sender] += _amount; 
        return true;
    }

    function setPTtotal (uint _amount) public view returns (uint) {
        return _amount * SalePrice / 100;
    }
    
     function validateOrder (uint _amount) public view returns (bool) {
        require(!EndSale, "#1 Token sale finished!");
        uint PTBalance   = getPTBalanceOf(msg.sender);
        require(PTBalance > 0, "#2 No enough balance!");
        require(_amount >= MinSaleAmount , "#3 Total token must be highr from min sale amount!");    

        uint PTtotal = setPTtotal(_amount);
        require(PTtotal <= PTBalance, "#2 No enough balance!");
        
        uint STBalance   = getSTBalanceOf(address(this));
        require(_amount <= STBalance, "#4 insufficient balance in smart contract!");
        
        uint allowance = IERC20(PTContract).allowance(msg.sender, address(this));
        require(allowance >= PTtotal, "#5 allowance error");
        return true;
    }
    
    function withdrawPayedToken (address _address) public returns (bool)  {
        address sender     = msg.sender;
        require(authorizeds[sender], "You not authorized!");
        uint PTBalance   = getPTBalanceOf(address(this));
        require(PTBalance > 0, "No Balance!");
        IERC20(PTContract).transfer(_address,PTBalance);
        Withdrawn     += PTBalance;
        Withdrawable  -= PTBalance;
        return true;
    }
    
    function withdrawToken (address _address) public returns (bool)  {
        address sender     = msg.sender;
        require(authorizeds[sender], "You not authorized!");
        uint STBalance   = getSTBalanceOf(address(this));
        require(STBalance > 0, "No Token!");
        IERC20(STContract).transfer(_address,STBalance);
        return true;
    }
}