// SPDX-License-Identifier: MIT
// File: FUNTAP/Ownable.sol
pragma solidity ^0.8.11;

contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}

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


interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


contract BEP20 is Context, IBEP20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _symbol;
    string private _name;
    address private _owner;

    constructor(string memory name_, string memory symbol_){
        _name = name_;
        _symbol = symbol_;
        _owner = _msgSender();
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function getOwner() public view virtual override returns (address) {
        return _owner;
    }


    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
}


contract HubGameToken is BEP20, Ownable {
    event event_lockSystemWallet(address _wallet, uint256 _remainingAmount, uint256 _releaseTime, uint8 _numOfPeriod, uint256 _amountInPeriod);

    uint8 public constant decimals = 8;
    uint256 _totalSupplyAtBirth = 50000000000 * 10 ** uint256(decimals);
    uint256 _totalMinted = 0;

    struct LockItem {
        uint256 releaseTime;
        uint256 remainingAmount;
        uint8 numOfPeriod;
        uint256 amountInPeriod;
        uint256 periodInSecond;
    }
    mapping (address => LockItem[]) public lockList;
    mapping(address => bool) private isLocked;
    struct Transaction {
        address from;
        address to;
        uint256 value;
        bool executed;
        uint256 numConfirmations;
        string gameCode;
    }
    
    Transaction[] private transactions;
    mapping(address => bool) private isAdmin;

    mapping(string => address[]) private signers;
    mapping(string => mapping(address => bool)) private isSigner;

    mapping(address => bool) private isSysWallet;
    mapping(address => string) private wallets;

    address[] private blackList;
    mapping(address => bool) private isBlackList;

    uint256 public numConfirmationsRequired = 3;
    mapping(uint256 => mapping(address => bool)) private confirms;

    event SubmitTransaction(address indexed _signer, uint256 indexed txIndex, address indexed to, uint256 value);
    event ConfirmTransaction(address indexed _signer, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed _signer, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed _signer, uint256 indexed txIndex);

    function destroyContract() public onlyOwner {
        selfdestruct(payable(owner));
    }

	constructor() BEP20("HubGame Pitchdeck", "HUD"){

    }


    function initGame(string memory _gameCode, uint256 _supplyToken, address[] memory _wallets, uint256[] memory _percents, address[] memory _signers) 
    public onlyOwner{
        uint256 _totalSupplyWei = _supplyToken * 10 ** uint256(decimals);
        require(_totalSupplyAtBirth - _totalMinted >= _totalSupplyWei, "out of available balance of token");
        require(_wallets.length == _percents.length, "mismatch address and percent");
        require(_signers.length > 0, "invalid signer");

        for (uint256 i = 0; i < _wallets.length; i++) {
            _mint(_wallets[i], _totalSupplyWei  * _percents[i]/100); 
            
            address _wallet = _wallets[i];
            isSysWallet[_wallet] = true;
            wallets[_wallet] = _gameCode;
        }
        for (uint256 i = 0; i < _signers.length; i++){
            address _wallet = _signers[i];
            isSigner[_gameCode][_wallet] = true;
            signers[_gameCode].push(_wallet);
        }

        _totalMinted = _totalMinted + _totalSupplyWei;
    }
	
    receive () payable external {   
        revert();
    }
    
    fallback () external {   
        revert();
    }

    modifier notInBlackList() {
        require(!isBlackList[msg.sender], "in black list");
        _;
    }

    modifier onlySystem() {
        require(isSysWallet[msg.sender], "not system wallet");
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin[msg.sender] || msg.sender == owner, "not admin wallet");
        _;
    }

    modifier requiredTransfer(address _from, address _receiver, uint256 _amount) {
        require(!isSysWallet[msg.sender], "must be not system wallet");
        require(_amount > 0, "amount must be larger than 0");
        require(_receiver != address(0), "cannot send to the zero address");
        require(_from != _receiver, "receiver cannot be the same as sender");
        require(_amount <= availableBalance(_from), "not enough enough fund to transfer");
        _;
    }

    function addAdmin(address[] memory _addresses) public onlyOwner{
        for (uint256 i = 0; i < _addresses.length; i++) {
            isAdmin[_addresses[i]] = true;
        }
    }

    function removeAdmin(address[] memory _addresses) public onlyOwner{
        for (uint256 i = 0; i < _addresses.length; i++) {
            isAdmin[_addresses[i]] = false;
        }
    }

    function addToBlackList(address[] memory _addresses) public onlyOwner{
        for (uint256 i = 0; i < _addresses.length; i++) {
            isBlackList[_addresses[i]] = true;
            blackList.push(_addresses[i]);
        }
    }

    function indexInBlackList(address _address) public view onlyOwner returns(uint256){
        require(_address != address(0) && isBlackList[_address],"invalid address");
        for (uint256 i=0; i< blackList.length; i++){
            if (blackList[i] == _address) return i;
        }
        return 0;
    }

    function removeFromBlackList(uint256 index) public onlyOwner{
        require(index < blackList.length,"invalid index of address");
        address _addr = blackList[index];
        isBlackList[_addr] = false;
        blackList[index] = blackList[blackList.length - 1];
        blackList.pop();
    }

    function addSigner(string memory _gameCode, address[] memory _signers) public onlyOwner {
        require(_signers.length > 0, "signers required");

        for (uint256 i = 0; i < _signers.length; i++) {
            address _signer = _signers[i];
            require(_signer != address(0) && !isSigner[_gameCode][_signer], "invalid signer");
            isSigner[_gameCode][_signer] = true;
            signers[_gameCode].push(_signer);
        }
    }

    function indexOfSigner(string memory _gameCode, address _signer)  public view onlyOwner returns(uint256){
        require(_signer != address(0) && isSigner[_gameCode][_signer],"invalid signer");
        for (uint256 i=0; i< signers[_gameCode].length; i++){
            if (signers[_gameCode][i] == _signer)  return i;
        }
        return 0;
    }

    function removeSigner(string memory _gameCode, uint256 index) public onlyOwner {
        require(index < signers[_gameCode].length,"invalid index of signer");

        address _signer = signers[_gameCode][index];
        isSigner[_gameCode][_signer] = false;
        signers[_gameCode][index] = signers[_gameCode][signers[_gameCode].length - 1];
        signers[_gameCode].pop();
    }

    function getAvailableBalance(address lockedAddress) public view notInBlackList returns(uint256) {
        uint256 bal = balanceOf(lockedAddress);
	    uint256 locked = getLockedAmount(lockedAddress);
        if (bal <= locked) return 0;
	    return bal-locked;
	}

    function availableBalance(address lockedAddress) internal view notInBlackList returns(uint256) {
        uint256 bal = balanceOf(lockedAddress);
        if(!isLocked[lockedAddress]){
            return bal;
        }
	    uint256 locked = getLockedAmount(lockedAddress);
        if(locked == 0){
            isLocked[lockedAddress] == false;
        }
        if (bal <= locked) return 0;
	    return bal-locked;
	}

    function getLockedAmount(address lockedAddress) internal view notInBlackList returns(uint256) {
	    uint256 lockedAmount = 0;
        LockItem[] memory items = lockList[lockedAddress];
        for(uint256 j = 0; j < items.length; j++) {
            if(block.timestamp >= items[j].releaseTime){
                uint256 remaining = items[j].remainingAmount - items[j].amountInPeriod;
                items[j].remainingAmount = remaining > 0 ? remaining : 0;
                items[j].releaseTime = items[j].releaseTime + items[j].periodInSecond;
            }
            if(block.timestamp < items[j].releaseTime) {
                uint256 temp = items[j].remainingAmount;
                lockedAmount += temp;
            }
        }
	    return lockedAmount;
	}

    function multiTransfer(address[] memory _receivers, uint256[] memory _amounts) public notInBlackList returns(bool){
        require(!isSysWallet[msg.sender], "must be not system wallet");
        require(_receivers.length == _amounts.length, "mismatch receiver and amount");

        uint256 startBalance = balanceOf(msg.sender);
        uint256 totalTransfer = 0;
        for (uint256 i = 0; i < _receivers.length; i++) {
            if(_receivers[i] == address(0)) continue;
            
            BEP20.transfer(_receivers[i], _amounts[i]);
            totalTransfer = totalTransfer + _amounts[i];
        }
        require(startBalance - totalTransfer == balanceOf(msg.sender), "transfer amount exceeds balance");
        return true;
    }

    function multiTransferFrom(address _from, address[] memory _receivers, uint256[] memory _amounts) public notInBlackList returns(bool){
        require(!isSysWallet[msg.sender], "must be not system wallet");
        require(_receivers.length == _amounts.length, "mismatch receiver and amount");

        uint256 startBalance = balanceOf(_from);
        uint256 totalTransfer = 0;
        for (uint256 i = 0; i < _receivers.length; i++) {
            if(_receivers[i] == address(0)) continue;

            BEP20.transferFrom(_from, _receivers[i], _amounts[i]);
            totalTransfer = totalTransfer + _amounts[i];
        }
        require(startBalance - totalTransfer == balanceOf(_from));
        return true;
    }

	function transfer(address _receiver, uint256 _amount) public override 
    notInBlackList 
    requiredTransfer(msg.sender, _receiver, _amount) 
    returns (bool) {
        BEP20.transfer(_receiver, _amount);
        return true;
	}
	
    function transferFrom(address _from, address _receiver, uint256 _amount)  public override  
    notInBlackList 
    requiredTransfer(_from, _receiver, _amount) 
    returns (bool) {
        BEP20.transferFrom(_from, _receiver, _amount);
        return true;
    }

    function transferAndLock(address _from, address _receiver, uint256 _amount, uint256 _releaseTime, uint8 _numOfPeriod, uint256 _periodInSecond) public
    onlyAdmin returns (bool){
        BEP20.transferFrom(_from, _receiver, _amount);

        uint256 _amountInPeriod = _amount/_numOfPeriod;
        LockItem memory item = LockItem({releaseTime: _releaseTime, remainingAmount: _amount, numOfPeriod: _numOfPeriod, 
        amountInPeriod: _amountInPeriod, periodInSecond: _periodInSecond});

        lockList[_receiver].push(item);
        isLocked[_receiver] = true;

        return true;
	}

    function submitTransaction(address _to, uint256 _value) public onlySystem 
    returns (uint256 _txIndex){
        _txIndex = transactions.length;
        Transaction memory item = Transaction(
            { 
                from: msg.sender, 
                to: _to, 
                value: _value, 
                executed: false, 
                numConfirmations: 0, 
                gameCode: wallets[msg.sender]
            });
        transactions.push(item);
        emit SubmitTransaction(msg.sender, _txIndex, _to, _value);
        return _txIndex;
    }

    function confirmTransaction(uint256 _txIndex) public{
        Transaction storage transaction = transactions[_txIndex];
        require(validateBeforeConfirm(_txIndex, transaction));
        require(!confirms[_txIndex][msg.sender], "tx already confirmed");
        
        transaction.numConfirmations += 1;
        confirms[_txIndex][msg.sender] = true;
        emit ConfirmTransaction(msg.sender, _txIndex);
        
        address[] memory _signers = signers[transaction.gameCode];
        if((transaction.numConfirmations >= numConfirmationsRequired || transaction.numConfirmations == _signers.length) 
        && availableBalance(transaction.from) > transaction.value){
            _transfer(transaction.from, transaction.to, transaction.value);
            transaction.executed = true;
            emit ExecuteTransaction(msg.sender, _txIndex);
        }
    }

    function revokeConfirmation(uint256 _txIndex) public{
        Transaction storage transaction = transactions[_txIndex];
        require(validateBeforeConfirm(_txIndex, transaction)) ;
        require(confirms[_txIndex][msg.sender], "tx unconfirmed");

        transaction.numConfirmations -= 1;
        confirms[_txIndex][msg.sender] = false;
        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function validateBeforeConfirm(uint256 _txIndex, Transaction memory transaction) internal view returns (bool){
        require(_txIndex < transactions.length, "tx does not exist");

        require(isSigner[transaction.gameCode][msg.sender] == true, "invalid signer for this transaction");
        require(!transaction.executed, "tx already executed");

        return true;
    }

    function getConfirmations(uint256 _txIndex) public view returns (address[] memory _confirmations) {
        Transaction storage transaction = transactions[_txIndex];
        address[] memory _signers = signers[transaction.gameCode];

        uint256 i;
        uint256 count = 0;
        for (i=0; i<_signers.length; i++){
            if (confirms[_txIndex][_signers[i]]) {
                _confirmations[count] = _signers[i];
            }
        }     
    }

    function getTransactionCount() public virtual view returns (uint) {
        return transactions.length;
    }

    function getTransaction(uint256 _txIndex) public view returns (
            address from,
            address to,
            uint256 value,
            bool executed,
            uint256 numConfirmations,
            string memory gameCode
        ){
        Transaction storage _transaction = transactions[_txIndex];
        return (
            _transaction.from, 
            _transaction.to, 
            _transaction.value, 
            _transaction.executed, 
            _transaction.numConfirmations, 
            _transaction.gameCode
            );
    }
}