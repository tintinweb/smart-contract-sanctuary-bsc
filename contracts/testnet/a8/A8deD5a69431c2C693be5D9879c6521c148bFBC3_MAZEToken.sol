/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    /**
        * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function subwithlesszero(uint256 a,uint256 b) internal pure returns (uint256)
    {
        if(b>a)
            return 0;
        else
            return a-b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
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
        require(c / a == b, 'SafeMath: multiplication overflow');

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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
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
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
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
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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


contract MAZEToken is Ownable
{
    using SafeMath for uint256;
    string constant  _name = 'MAZE';
    string constant _symbol = 'MAZE';
    uint8 immutable _decimals = 18;

    address _pancakeAddress;
    address _teama;
    address _teamb;
    address _teamc;
    address _teamd;
    uint256 _totalsupply;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address=>bool) _isExcluded;
    mapping(address=>bool) _banneduser;
    mapping(address=>uint256) _balances;

    /**
 * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);


    constructor( )
    {
        _mint(msg.sender,100000000000 * 1e18);
        _isExcluded[msg.sender]=true;

        _teama=0x1EC2bdB877cB9c2046Ffa2dB7e0456ffF2d4D117;
        _teamb=0x804284D53c8801c680EEBc2d413C3e39342925b9;
        _teamc=0x144570AEc18De6C5e42786d20d690289066df2cb;
        _teamd=0x4DD3D0100a451d9c33eF56C389c6DA8460655721;
    }

    function setTeam(address teama,address teamb,address teamc,address teamd) public onlyOwner
    {
        _teama=teama;
        _teamb=teamb;
        _teamc=teamc;
        _teamd=teamd;
    }

    function BannUser(address user,bool ban) external onlyOwner
    {
        _banneduser[user]=ban;
    }

    function setPancakeAddress(address pancakeAddress) external onlyOwner
    {
        _pancakeAddress=pancakeAddress;
    }

    function name() public  pure returns (string memory) {
        return _name;
    }

    function symbol() public  pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalsupply;
    }

    function AddExcluded(address account,bool a) public  onlyOwner
    {
        _isExcluded[account] =a;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), 'BEP20: mint to the zero address');
        _totalsupply=_totalsupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    function allowance(address owner, address spender) public view  returns (uint256) {
        return _allowances[owner][spender];
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function approve(address spender, uint256 amount) public  returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public  returns (bool) {
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        _transfer(sender, recipient, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public  returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public  returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public  returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function burnFrom(address sender, uint256 amount) public  returns (bool)
    {
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        _burn(sender,amount);
        return true;
    }

    function burn(uint256 amount) public returns (bool)
    {
        _burn(msg.sender,amount);
        return true;
    }

    function _burn(address sender,uint256 tAmount) private
    {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(tAmount > 0, "Transfer amount must be greater than zero");
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[address(0)] = _balances[address(0)].add(tAmount);
        emit Transfer(sender, address(0), tAmount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_banneduser[sender]==false,"banned");
        _balances[sender]= _balances[sender].sub(amount);

        uint256 toamount=amount;
        if(!isExcluded(sender) && !isExcluded(recipient))
        {
            uint256 onepct = amount.div(1000);
            uint256 totalcut = onepct.mul(12);
            if(sender==_pancakeAddress)
            {
                totalcut = onepct.mul(4);

            }else if(recipient==_pancakeAddress)
            {
                totalcut = onepct.mul(8);
            }

            uint256 onepiece= totalcut.div(1200);

            //DESTORY 4/12
            _balances[address(0)]= _balances[address(0)].add(onepiece.mul(400));
            emit Transfer(sender, address(0), onepiece.mul(400));

            //CUT  5/12 TO TEAMA
            _balances[_teama]= _balances[_teama].add(onepiece.mul(500));
            emit Transfer(sender, _teama, onepiece.mul(500));

            //CUT  1.25/12 TO TEAMB
            _balances[_teamb]= _balances[_teamb].add(onepiece.mul(125));
            emit Transfer(sender, _teamb, onepiece.mul(125));

            //CUT  1.25/12 TO TEAMC
            _balances[_teamc]= _balances[_teamc].add(onepiece.mul(125));
            emit Transfer(sender, _teamc, onepiece.mul(125));
            //CUT  0.5/12 TO TEAMC
            _balances[_teamd]= _balances[_teamd].add(totalcut.sub(onepiece.mul(1150)));
            emit Transfer(sender, _teamd, totalcut.sub(onepiece.mul(1150)));
            toamount=amount.sub(totalcut);
        }
        _balances[recipient] = _balances[recipient].add(toamount);
        emit Transfer(sender, recipient, toamount);
    }
}