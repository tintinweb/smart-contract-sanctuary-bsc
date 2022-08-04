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

contract CommonUtil{
    struct LockItem {
        uint256 releaseTime;
        uint256 lockedAmount;
        uint256 amountInPeriod;
    }

    struct Transaction {
        uint256 id;
        address from;
        address to;
        uint256 value;
        bool isExecuted;
        uint256 numConfirmations;
        uint256[] lockParams;
    }

    uint256 public _periodInSecond = 2628000; //month

    function getLockItem(uint256 _amount, uint256 _releaseDate, uint256 _gpePercent, uint256 _numOfPeriod, uint256 _ciff) 
    public view returns (LockItem memory){
        uint256 _lockedAmount = _amount - (_amount * _gpePercent/100);
        uint256 _releaseTime = _releaseDate + (_ciff * _periodInSecond);
        return LockItem({
            releaseTime: _releaseTime, 
            lockedAmount: _lockedAmount, 
            amountInPeriod: (_lockedAmount/_numOfPeriod)});
    }
}

contract HubController is CommonUtil, Ownable{
    event event_lockSystemWallet(address _sender, address _wallet, uint256 _lockedAmount, uint256 _releaseTime, uint256 _numOfPeriod);
    
    mapping (address => LockItem) public lockeds;

    address[] private signers;
    mapping(address => bool) public isSigner;

    mapping(uint256 => Transaction) private mapTransactions;
    Transaction[] private transactions;
    mapping(uint256 => mapping(address => bool)) private confirms;

    event SubmitTransaction(address indexed _signer, uint256 indexed txIndex, address indexed to, uint256 value);
    event ConfirmTransaction(address indexed _signer, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed _signer, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed _signer, uint256 indexed txIndex);

    constructor(uint256 _supplyTokenWei, uint256 _releaseDate, address[] memory _wallets, uint256[] memory _percents, address[] memory _signers,
    uint256[] memory _gpePercents, uint256[] memory _numOfPeriods, uint256[] memory _ciffs) {    
        for (uint256 i = 0; i < _wallets.length; i++) {
            uint256 _amount = _supplyTokenWei  * _percents[i]/100;
            if(_releaseDate == 0) _releaseDate = block.timestamp;

            LockItem memory item = getLockItem(_amount, _releaseDate, _gpePercents[i], _numOfPeriods[i], _ciffs[i]);
            lockeds[_wallets[i]] = item;
            emit event_lockSystemWallet(owner, _wallets[i], item.lockedAmount, item.releaseTime, _numOfPeriods[i]);
        }
        for (uint256 i = 0; i < _signers.length; i++){
            address _wallet = _signers[i];
            isSigner[_wallet] = true;
            signers.push(_wallet);
        }
    }

    function getSigners() public view returns (address[] memory){
        return signers;
    }

    function addSigner(address[] memory _signers) public onlyOwner{
        for (uint256 i = 0; i < _signers.length; i++) {
            address _signer = _signers[i];
            require(_signer != address(0) && !isSigner[_signer], "invalid signer");
            
            isSigner[_signer] = true;
            signers.push(_signer);
        }
    }

    function indexOfSigner(address _signer)  public view onlyOwner returns(uint256){
        for (uint256 i=0; i< signers.length; i++){
            if (signers[i] == _signer)  return i;
        }
        return 0;
    }

    function removeSigner(uint256 index) public onlyOwner returns(bool){
        require(index < signers.length,"invalid index of signer");

        address _signer = signers[index];
        isSigner[_signer] = false;
        signers[index] = signers[signers.length - 1];
        signers.pop();
        return true;
    }

    function getLockedAmount(address lockedAddress) public view returns(uint256) {
        LockItem memory item = lockeds[lockedAddress];
        if(item.lockedAmount > 0){
            while(block.timestamp >= item.releaseTime){
                uint256 remainLocked = item.lockedAmount - item.amountInPeriod;
                item.lockedAmount = remainLocked > 0 ? remainLocked : 0;
                item.releaseTime = item.releaseTime + _periodInSecond;
            }
        }
	    return item.lockedAmount;
	}

    function getAllTransaction() public view 
    onlyOwner
    returns (Transaction[] memory){
        return transactions;
    }

    function getTransactionById(uint256 _txId) public view 
    onlyOwner
    returns (Transaction memory){
        return mapTransactions[_txId];
    }

    function submit(uint256 _txId, address _sender, address _receiver, uint256 _value, uint256[] memory _lockParams) public onlyOwner
    returns (bool){
        Transaction memory item = Transaction(
            { 
                id: _txId,
                from: _sender, 
                to: _receiver, 
                value: _value, 
                isExecuted: false, 
                numConfirmations: 0, 
                lockParams: _lockParams
            });
        transactions.push(item);
        mapTransactions[_txId] = item;
        emit SubmitTransaction(_sender, _txId, _receiver, _value);
        return true;
    }

    function confirm(address _signer, uint256 _txId, uint256 _available) public 
    onlyOwner
    returns (bool canExecute,
            address from,
            address to,
            uint256 value,
            uint256[] memory lockParams){
        require(!confirms[_txId][_signer], "tx already confirmed");
        Transaction storage _transaction = mapTransactions[_txId];
        _validateBeforeConfirm(_signer, _txId, _transaction.isExecuted);
        
        _transaction.numConfirmations += 1;
        confirms[_txId][_signer] = true;

        canExecute = (_available > _transaction.value
                    && (_transaction.numConfirmations >= 3 || _transaction.numConfirmations == signers.length));
        return (canExecute, _transaction.from, _transaction.to, _transaction.value, _transaction.lockParams);
    }

    function executed(address _signer, uint256 _txId) public 
    onlyOwner{
        Transaction storage _transaction = mapTransactions[_txId];
        _transaction.isExecuted = true;
        emit ExecuteTransaction(_signer, _txId);
    }

    function revoke(address _signer, uint256 _txId) public 
    onlyOwner
    returns (bool){
        require(confirms[_txId][_signer], "tx unconfirmed");
        Transaction storage _transaction = mapTransactions[_txId];
        _validateBeforeConfirm(_signer, _txId, _transaction.isExecuted);

        _transaction.numConfirmations -= 1;
        confirms[_txId][_signer] = false;
        return true;
    }

    function getConfirmations(uint256 _txId) public view 
    onlyOwner
    returns (address[] memory _confirmations) {
        uint256 i;
        uint256 count = 0;
        for (i=0; i<signers.length; i++){
            if (confirms[_txId][signers[i]]) {
                _confirmations[count] = signers[i];
            }
        }     
    }

    function _validateBeforeConfirm(address _signer, uint256 _txId, bool _isExecuted) internal view 
    returns (bool){
        require(mapTransactions[_txId].to != address(0), "tx does not exist");
        require(!_isExecuted, "tx already executed");
        require(isSigner[_signer] == true, "invalid signer for this transaction");

        return true;
    }
}

contract HubGameTokenV1 is BEP20, Ownable, CommonUtil {
    uint8 public constant decimals = 8;
    uint256 _totalSupplyAtBirth = 50000000000 * 10 ** uint256(decimals);
    uint256 _totalMinted = 0;
    uint256 _txIndex = 0;

    mapping(string => address) private gameControllers;
    mapping(address => bool) private isAdmin;
    address[] private blackList;
    mapping(address => bool) private isBlackList;
    
    mapping(address => LockItem[]) private lockedList;
    mapping(address => bool) private isLocked;

    mapping(address => bool) private isSystemWallet;
    mapping(address => string) private systemWallets;
    mapping(address => string) private signerWallets;

	constructor() BEP20("HubGame Pitchdeck", "HUD"){}

    modifier requireDeployed(string memory _gameCode) {
        require (isAdmin[msg.sender] == true, "must be admin");
        require (gameControllers[_gameCode] != address(0), "invalid game contract");
        _;
    }

    modifier requiredTransfer(address _from, address _receiver, uint256 _amount) {
        require(!isSystemWallet[msg.sender], "must be not system wallet");
        require(!isBlackList[msg.sender], "in black list");
        require(_from != _receiver && _receiver != address(0), "invalid address");
        require(_amount > 0 && _amount <= availableBalance(_from), "not enough funds to transfer");
        _;
    }

    function adminAdd(address[] memory _addresses) public onlyOwner{
        for (uint256 i = 0; i < _addresses.length; i++) {
            isAdmin[_addresses[i]] = true;
        }
    }

    function adminRemove(address _address) public onlyOwner{
        isAdmin[_address] = false;
    }

    function blackListAdd(address[] memory _addresses) public onlyOwner{
        for (uint256 i = 0; i < _addresses.length; i++) {
            isBlackList[_addresses[i]] = true;
            blackList.push(_addresses[i]);
        }
    }

    function blackListIndexOf(address _address) public view onlyOwner returns(uint256 index){
        require(_address != address(0) && isBlackList[_address],"invalid address");
        for (uint256 i=0; i< blackList.length; i++){
            if (blackList[i] == _address) index = i;
        }
    }

    function blackListRemove(uint256 index) public onlyOwner{
        require(index < blackList.length,"invalid index of address");
        isBlackList[blackList[index]] = false;
        blackList[index] = blackList[blackList.length - 1];
        blackList.pop();
    }

    function initGame(string memory _gameCode, uint256 _supplyToken, uint256 _listingDate, 
    address[] memory _wallets, uint256[] memory _percents,  address[] memory _signers, 
    uint256[] memory _gpePercents, uint256[] memory _numOfPeriods, uint256[] memory _ciffs) public 
    returns (address gameAddress){
        require(isAdmin[msg.sender] == true, "must be admin");
        require(gameControllers[_gameCode] == address(0), "game code is exist");
        uint256 _totalSupplyWei = _supplyToken * 10 ** uint256(decimals);
        require(_totalSupplyAtBirth - _totalMinted >= _totalSupplyWei, "out of available balance of token");
        require(_wallets.length == _percents.length, "mismatch address and percent");
        require(_signers.length > 0, "invalid signer");
        require(_gpePercents.length == _numOfPeriods.length && _numOfPeriods.length == _ciffs.length, "mismatch locked param");
        
        for (uint256 i = 0; i < _wallets.length; i++) {
            address _wallet = _wallets[i];
            _mint(_wallet, _totalSupplyWei  * _percents[i]/100); 
            isSystemWallet[_wallet] = true;
            systemWallets[_wallet] = _gameCode;
            isLocked[_wallet] = true;
        }
        for (uint256 i = 0; i < _signers.length; i++) {
            signerWallets[_signers[i]] = _gameCode;
        }
        //_supplyTokenWei, _releaseDate, _wallets, _percents,_signers,_gpePercents, _numOfPeriods, _ciff
        gameAddress = address(new HubController{salt: keccak256(abi.encode(_gameCode, _supplyToken))}
                                (_totalSupplyWei, _listingDate, _wallets , _percents, _signers, _gpePercents, _numOfPeriods, _ciffs));
        gameControllers[_gameCode] = gameAddress;
        _totalMinted = _totalMinted + _totalSupplyWei;
    }

    function signerAdd(string memory _gameCode, address[] memory _signers) public 
    requireDeployed(_gameCode){
        HubController(gameControllers[_gameCode]).addSigner(_signers);
    }

    function signerIndexOf(string memory _gameCode, address _signer)  public view 
    requireDeployed(_gameCode) 
    returns(uint256){
        return HubController(gameControllers[_gameCode]).indexOfSigner(_signer);
    }

    function signerRemove(string memory _gameCode, uint256 index) public 
    requireDeployed(_gameCode) 
    returns (bool){
        return HubController(gameControllers[_gameCode]).removeSigner(index);
    }

    function getAvailableBalance(address lockedAddress) public view returns(uint256) {
        uint256 bal = balanceOf(lockedAddress);
        uint256 locked = 0;
        if(isLocked[lockedAddress] == true){
            locked = _getLockedAmount(lockedAddress);
        }
        return bal-locked;
	}

    function availableBalance(address lockedAddress) internal returns(uint256) {
        uint256 bal = balanceOf(lockedAddress);
        uint256 locked = 0;
        if(isLocked[lockedAddress] == true){
            locked = _getLockedAmount(lockedAddress);
        }
        if(locked == 0) {
            isLocked[lockedAddress] = false;
        }
        return bal-locked;
	}

    function _getLockedAmount(address lockedAddress) internal view returns(uint256) {
        address _contract = gameControllers[systemWallets[lockedAddress]];
        if(_contract == address(0)){
            LockItem[] memory items = lockedList[lockedAddress];
	        uint256 lockedAmount = 0;
            for(uint256 j = 0; j < items.length; j++) {
                if(items[j].lockedAmount > 0){
                    while(block.timestamp >= items[j].releaseTime){
                        uint256 remainLocked = items[j].lockedAmount - items[j].amountInPeriod;
                        items[j].lockedAmount = remainLocked > 0 ? remainLocked : 0;
                        items[j].releaseTime = items[j].releaseTime + _periodInSecond;
                    }
                }
                lockedAmount += items[j].lockedAmount;
            }
            return lockedAmount;
        }
        return HubController(_contract).getLockedAmount(lockedAddress);
	}

    function transfer(address _receiver, uint256 _amount) public override 
    requiredTransfer(msg.sender, _receiver, _amount) 
    returns (bool) {
        return BEP20.transfer(_receiver, _amount);
	}
	
    function transferFrom(address _from, address _receiver, uint256 _amount)  public override  
    requiredTransfer(_from, _receiver, _amount) 
    returns (bool) {
        return BEP20.transferFrom(_from, _receiver, _amount);
    }

    function getTransactions() public view returns (Transaction[] memory){
        address _contract = gameControllers[signerWallets[msg.sender]];
        if(_contract == address(0)) _contract = gameControllers[systemWallets[msg.sender]];
        require(_contract != address(0), "Must be signer or system");

        return HubController(_contract).getAllTransaction();
    }

    function getTransaction(uint256 _txId) public view 
    returns (Transaction memory){
        address _contract = gameControllers[signerWallets[msg.sender]];
        if(_contract == address(0)) _contract = gameControllers[systemWallets[msg.sender]];
        require(_contract != address(0), "Must be signer or system");

        return HubController(_contract).getTransactionById(_txId);
    }

    function getConfirmations(uint256 _txId) public view returns (address[] memory) {
        address _contract = gameControllers[signerWallets[msg.sender]];
        if(_contract == address(0)) _contract = gameControllers[systemWallets[msg.sender]];
        require(_contract != address(0), "Must be signer or system");

        return HubController(_contract).getConfirmations(_txId);
    }

    function transactionSubmit(address _receiver, uint256 _value, uint256[] memory _lockParams) public
    returns (uint256){
        address _contract = gameControllers[systemWallets[msg.sender]];
        require(_contract != address(0), "Must be system wallet");

        _txIndex += 1;
        require(HubController(_contract).submit(_txIndex, msg.sender, _receiver, _value, _lockParams));
        return _txIndex;
    }

    function transactionConfirm(uint256 _txId) public{
        address _contract = gameControllers[signerWallets[msg.sender]];
        require(_contract != address(0), "Must be signer");

        address _from;
        address _to;
        uint256 _value;
        bool _canExecute;
        uint256[] memory _params;
        HubController _game = HubController(_contract);
        (_canExecute, _from, _to, _value, _params) = _game.confirm(msg.sender, _txId, availableBalance(_from));
        if(_canExecute){
            _transfer(_from, _to, _value);
            //releaseDate, gpePercent, numPeriod, ciff
            LockItem memory item = getLockItem(_value, _params[0], _params[1], _params[2], _params[3]);
            lockedList[_to].push(item);
            _game.executed(msg.sender, _txId);
        }
    }

    function transactionRevoke(uint256 _txId) public{
        address _contract = gameControllers[signerWallets[msg.sender]];
        require(_contract != address(0), "Must be signer");
        require(HubController(_contract).revoke(msg.sender, _txId));
    }

}