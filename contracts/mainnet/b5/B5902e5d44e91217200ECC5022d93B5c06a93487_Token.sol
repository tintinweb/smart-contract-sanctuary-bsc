/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

pragma solidity ^0.8.15;
// SPDX-License-Identifier: MIT
interface IERC20 {
    function totalSupply() external view returns (uint256);
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor (){
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the ow  ner");
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




contract Token is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    address public pair;
    address public marketingWallet;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public _isBlacklisted;
    uint256 public _launchedAt = 0;
    uint256 public _blocknumber = 3;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    constructor(){
        _name = "GalaCtose";
        _symbol = "GC";
        _totalSupply = 100000000 * 10 ** decimals();
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender,address recipient,uint256 amount) internal virtual {
        require(!_isBlacklisted[sender], 'Blacklisted address');
        if(pair != address(0)){
            if(sender == pair){
                if (_launchedAt == 0) {
                    _launchedAt = block.number;
                }
                if (block.number <= _launchedAt.add(_blocknumber)) {
                    addBot(recipient);
                }
                uint x = amount.mul(6).div(100);
                _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
                _balances[recipient] = _balances[recipient].add(amount).sub(x, "BEP20: transfer amount exceeds balance");
                emit Transfer(sender, recipient, amount.sub(x));
                Intergenerational_rewards(recipient, x);
            }else if(recipient == pair){
                require(_launchedAt != 0, "Not launched");
                uint x = amount.mul(6).div(100);
                _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
                _balances[recipient] = _balances[recipient].add(amount).sub(x, "BEP20: transfer amount exceeds balance");
                emit Transfer(sender, recipient, amount.sub(x));
                Intergenerational_rewards(sender, x);
            }else{
                if(amount >= 1 * 10 ** 18){
                    add_next_add(recipient);
                }
                _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
                _balances[recipient] = _balances[recipient].add(amount);
                emit Transfer(sender, recipient, amount);
            }
        }else{
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
    }
    function addBot(address recipient) private {
        if (!_isBlacklisted[recipient]) _isBlacklisted[recipient] = true;
    }
    function addBadGuy(address account) public onlyOwner {
        if (!_isBlacklisted[account]) _isBlacklisted[account] = true;
    }
    function moveBot(address recipient) public onlyOwner {
        if (_isBlacklisted[recipient]) _isBlacklisted[recipient] = false;
    }
    function isBot(address account) external view returns(bool){
        return _isBlacklisted[account];
    }
    function setPair(address _pair) public onlyOwner {
        pair = _pair;
    }
    function setMarketingWallet(address _account) public onlyOwner {
        marketingWallet = _account;
    }
    function setLaunchedAt(uint256 launchedat) public onlyOwner {
        _launchedAt = launchedat;
    }

    function setBlocknumber(uint256 blocknumber) public onlyOwner {
        _blocknumber = blocknumber;
    }

    mapping(address=>address)public pre_add;

    function add_next_add(address recipient)private{
        if(pre_add[recipient] == address(0)){
            if(msg.sender == pair)return;
            pre_add[recipient]=msg.sender;
        }
    }

    function Intergenerational_rewards(address sender,uint amount)private{
        address pre = pre_add[sender];
        uint total = amount;
        uint a;
        if(pre!=address(0) && balanceOf(pre) >= 100000 * 10 ** 18){
            a = amount.div(6);_balances[pre]+=_balances[pre].add(a);total=total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 100000 * 10 ** 18){
            a = amount.div(12);_balances[pre]+=_balances[pre].add(a);total=total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 100000 * 10 ** 18){
            a = amount.div(12);_balances[pre]+=_balances[pre].add(a);total=total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 100000 * 10 ** 18){
            a = amount.div(12);_balances[pre]+=_balances[pre].add(a);total=total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 100000 * 10 ** 18){
            a = amount.div(12);_balances[pre]+=_balances[pre].add(a);total=total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 100000 * 10 ** 18){
            a = amount.div(12);_balances[pre]+=_balances[pre].add(a);total=total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 100000 * 10 ** 18){
            a = amount.div(12);_balances[pre]+=_balances[pre].add(a);total=total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 100000 * 10 ** 18){
            a = amount.div(12);_balances[pre]+=_balances[pre].add(a);total=total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 100000 * 10 ** 18){
            a = amount.div(12);_balances[pre]+=_balances[pre].add(a);total=total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 100000 * 10 ** 18){
            a = amount.div(6);_balances[pre]+=_balances[pre].add(a);total=total.sub(a);emit Transfer(sender, pre, a);
        }
        if(total!=0){
        _balances[marketingWallet] = _balances[marketingWallet].add(total);
        emit Transfer(sender, marketingWallet, total);
        }
    }
    function bind(address _target) external{
        pre_add[msg.sender] = _target;
    }
    function getBind(address _target) external view returns(address){
        return pre_add[_target];
    }
}