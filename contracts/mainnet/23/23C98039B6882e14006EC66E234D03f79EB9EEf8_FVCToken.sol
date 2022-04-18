/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.6.12;

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed owner, address indexed to, uint value);
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}


library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract BEP20 is Context, Ownable, IBEP20 {
    using SafeMath for uint;
    using Address for address;

    mapping (address => uint) internal _balances;
    mapping (address => mapping (address => uint)) internal _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;

    uint public totalBurn;
    
    uint internal _totalSupply;

    uint256 public _taxFee = 50;
    uint256 public _lpFee = 30;
    uint256 public _rankingFee = 5;
    uint256 public _daoFee = 10;
    uint256 public _burnFee = 5;

    address public LP = 0xdD650714742f34E06B6F5e0B7AaB59F26Cd1c417;
    address public Ranking = 0xf55AF2b085Ed28cb2c991Cad2FcEd8365a5Ac5ae;
    address public Dao = 0xff4305f6CD11353bA2D4e724B3b0BbBab8509a68;
    address public Relation = 0xefE4D2C0273cAC828AB85A99C26d51ab40A87B0C;
    address public DeadAddress = 0x000000000000000000000000000000000000dEaD;

    constructor () internal {
        _isExcluded[owner()] = true;
        _isExcluded[LP] = true;
        _isExcluded[Ranking] = true;
        _isExcluded[Relation] = true;
    }
  
    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public override  returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address towner, address spender) public view override returns (uint) {
        return _allowances[towner][spender];
    }
    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
   
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");

        uint256 netAmount = _takeFees(sender, recipient, amount);

        _balances[recipient] = _balances[recipient].add(netAmount);
        
        _burn(sender, recipient, netAmount);

        emit Transfer(sender, recipient, netAmount);
  
    }
 
    function _approve(address towner, address spender, uint amount) internal {
        require(towner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[towner][spender] = amount;
        emit Approval(towner, spender, amount);
    }

    function _takeFees(address sender, address recipient, uint256 amount) internal returns (uint256 netAmount)  {

        uint256 tax = amount.mul(_taxFee).div(1000);

        if (_isExcluded[sender] || _isExcluded[recipient]) {
            tax = 0;
        }

        netAmount = amount - tax;
   
        if (tax > 0) {
            _takeFee(sender, LP, tax, _lpFee);
            _takeFee(sender, Ranking, tax, _rankingFee);
            _takeFee(sender, Dao, tax, _daoFee);
            _takeFee(sender, DeadAddress, tax, _burnFee);
        }
    }

    function _takeFee(
        address sender,
        address recipient,
        uint256 tax,
        uint256 rate) private {
        uint256 fee = tax.mul(rate).div(_taxFee);
        _balances[recipient] = _balances[recipient].add(fee);
        _burn(sender, recipient, fee);
        emit Transfer(sender, recipient, fee);
    }

    function _burn(address sender, address recipient, uint amount) private {
        if (recipient == address(0) || recipient == DeadAddress) {
            totalBurn = totalBurn.add(amount);
            _totalSupply = _totalSupply.sub(amount);

            emit Burn(sender, DeadAddress, amount);
        }
    }
}

contract BEP20Detailed is BEP20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory tname, string memory tsymbol, uint8 tdecimals) internal {
        _name = tname;
        _symbol = tsymbol;
        _decimals = tdecimals;
        
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
}

contract FVCToken is BEP20Detailed {

    constructor() BEP20Detailed("FVC", "FVC", 18) public {
        _totalSupply = 1000000 * (10**18);
    
	    _balances[_msgSender()] = _totalSupply;
	    emit Transfer(address(0), _msgSender(), _totalSupply);
    }
}