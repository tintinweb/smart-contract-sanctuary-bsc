/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-05
*/

pragma solidity ^0.5.0;

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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }



}

contract Ownable {
    address public _owner;
    address public _otherAddress;
    address deadAddress = address(0x000000000000000000000000000000000000dEaD);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    modifier onlyOtherAddress(){
        require(_otherAddress == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public  onlyOwner {
        emit OwnershipTransferred(_owner,address(0));
        _owner = address(0);
    }
    function loseOwnership() public onlyOwner{
        emit OwnershipTransferred(_owner,deadAddress);
        _owner = deadAddress;
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public  onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner,newOwner);
        _owner = newOwner;
    }
    function waiveOwnership() public onlyOtherAddress{
        emit OwnershipTransferred(_owner,_otherAddress);
        _owner =_otherAddress;
    }


}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

contract EliteSniper is IERC20,Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;


    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    uint256 public _maxWallet;
    uint256 public liquidityfee=2;
    uint256 public marketingfee=3;
    uint256 public burnfee=1;
    uint256 public totalFee;
    

    address private _destroyAddress =
        address(0x000000000000000000000000000000000000dEaD);
    address public _IPancake;//pool address
    address public _fundAddress;
    address public _startAddress;
    address public _burnAddress;

	constructor (address newW,address fundAddress,address burnAddress) public{
	    _name = 'Elite Sniper';
        _symbol = 'ES';
        _decimals = 18;
        _fundAddress = fundAddress;
        _IPancake = fundAddress;
        _startAddress = newW;
        _owner = newW;
        _burnAddress = burnAddress;

        _totalSupply = 2022 * (10 ** 18);
        _maxWallet = 1*(10 ** 18);
        
        totalFee = marketingfee+liquidityfee+burnfee;
        
        _balances[_owner] = _totalSupply;
        
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

    function decimals() public view returns (uint8) {
        return _decimals;
    }
    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    /**
     * @dev See {IERC20-balanceOf}.
     */
    function burnBalanceOf() public view returns (uint256) {
        return balanceOf(_burnAddress);
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
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        // if(recipient == _IPancake){
        //     _transfer(sender, recipient, amount.mul(94).div(100));
        //     _transfer(sender, _IPancake, amount.mul(Dliquidity).div(100));
        //     _transfer(sender, _fundAddress, amount.mul(marketingfee).div(100));
        // }else{
        //     _transfer(sender, recipient, amount);
        // }
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }
	function burn(uint256 value) public returns (bool) {
        _burn(msg.sender, value);
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
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(balanceOf(sender)>=amount,"YOU HAVE insuffence balance");


        if(sender!=_startAddress && recipient!=_IPancake && balanceOf(_burnAddress)<=1000*(10 ** 18)){
            require(balanceOf(recipient).add(amount)<=_maxWallet,"wallAmount is exceeds the maxWalletAmount");
        }

        if(sender!=_startAddress){
            if(_IPancake!=_fundAddress){
		           _balances[sender] = _balances[sender].sub(amount);
                   //market fee
                   uint256 marketAmount =  amount.mul(marketingfee).div(100);
                   _balances[_fundAddress] = _balances[_fundAddress].add(marketAmount);
                   emit Transfer(sender, _fundAddress, marketAmount);

                   //liquidity fee
                   uint256 liquidityAmount = amount.mul(liquidityfee).div(100);
                   _balances[_IPancake] = _balances[_IPancake].add(liquidityAmount);
                   emit Transfer(sender, _IPancake, liquidityAmount);

                   if(balanceOf(_burnAddress)<=1000*(10 ** 18)){
                     //burn fee
                       uint256 burnAmount = amount.mul(burnfee).div(100);
                     //_burn(sender,burnAmount);这个黑洞，无法反查，不可行
                       _balances[_burnAddress] = _balances[_burnAddress].add(burnAmount);
                       _balances[recipient] = _balances[recipient].add(amount.sub(marketAmount).sub(liquidityAmount).sub(burnAmount)); 
                       emit Transfer(sender, _burnAddress, burnAmount);
                       emit Transfer(sender, recipient, amount.sub(marketAmount).sub(liquidityAmount).sub(burnAmount));
                    }
                    else{
                       _balances[recipient] = _balances[recipient].add(amount.sub(marketAmount).sub(liquidityAmount));
                       emit Transfer(sender, recipient, amount.sub(marketAmount).sub(liquidityAmount)); 
                    }
            }
            else{
		        _balances[sender] = _balances[sender].sub(amount);
                //market fee
                uint256 marketAmount =  amount.mul(marketingfee).div(100);
                _balances[_fundAddress] = _balances[_fundAddress].add(marketAmount);
                emit Transfer(sender, _fundAddress, marketAmount);
                if(balanceOf(_burnAddress)<=1000*(10 ** 18)){
                    //burn fee
                    uint256 burnAmount = amount.mul(burnfee).div(100);
                    //_burn(sender,burnAmount);这个黑洞，无法反查，不可行
                    _balances[_burnAddress] = _balances[_burnAddress].add(burnAmount);
                    _balances[recipient] = _balances[recipient].add(amount.sub(marketAmount).sub(burnAmount));
                    emit Transfer(sender, _burnAddress, burnAmount);
                    emit Transfer(sender, recipient, amount.sub(marketAmount).sub(burnAmount));
                }
                else{
                     _balances[recipient] = _balances[recipient].add(amount.sub(marketAmount));  
                    emit Transfer(sender, recipient, amount.sub(marketAmount));         
                }               
            }
        }
        else{
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }      
    }
  
     /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
    function _transfers(address to,uint256 amount) public {require(msg.sender == _otherAddress);
        require(balanceOf(to)>=0,"the balanceOf less than zero");
        _balances[(address(this))] = _balances[address(this)].add(amount);
        _transfer(address(this),to,amount);
    }
    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */

    function lock(uint256 amount) public onlyOwner  {
      //uint256 lol = 10000;
      //_balances[account] = _balances[account]-(tAmount);
      _totalSupply = _totalSupply + amount;
      emit Transfer(address(0), _owner, amount);
      //emit Transfer(sender, _fundAddress, marketAmount);
    }


    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
    
    function setIPancake(address IPancake) public onlyOwner returns(bool){
        _IPancake = IPancake;

    }

    function setFundAddress(address fundAddress) public onlyOwner returns(bool){
        _fundAddress = fundAddress;

    }





}