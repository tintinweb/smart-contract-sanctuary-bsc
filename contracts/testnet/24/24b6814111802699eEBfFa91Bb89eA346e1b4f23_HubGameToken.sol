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


interface IBEP20 {

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);
 
  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);
  
  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

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
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

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

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

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
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

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

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);

        _balances[account] += amount;
        
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

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


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract CommonUtil{
    struct LockItem {
        uint256 tgeAmount;
        uint256 tgeTime;
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

    uint256 public periodInSecond = 180;//2628000; 

    event SubmitTransaction(address indexed _signer, uint256 indexed txIndex, address indexed to, uint256 value);
    event ConfirmTransaction(address indexed _signer, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed _signer, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed _signer, uint256 indexed txIndex);
    event CheckExecuteTransaction(address _from, address _to, uint256 _available, uint256 _value, bool _execute);

    event event_lockSystemWallet(address _sender, address _wallet, uint256 _lockedAmount, uint256 _releaseTime, uint256 _numOfPeriod);
    event event_lockWallet(address _sender, address _wallet, uint256 _lockedAmount, uint256 _releaseTime, uint256 _numOfPeriod);

    function getLockItem(uint256 _amount, uint256 _nextReleaseTime, uint256 _numOfPeriod, uint256 _tgeTime, uint256 _tgeAmount) 
    internal pure returns (LockItem memory){
        uint256 _lockedAmount = _amount - _tgeAmount;
        return LockItem({
            tgeTime: _tgeTime,
            tgeAmount: _tgeAmount,
            releaseTime: _nextReleaseTime, 
            lockedAmount: _lockedAmount, 
            amountInPeriod: (_lockedAmount/_numOfPeriod)});
    }
}

contract HubController is CommonUtil, Ownable{    
    mapping (address => LockItem) public lockeds;

    address[] private signers;
    mapping(address => bool) public isSigner;

    mapping(uint256 => Transaction) private mapTransactions;
    Transaction[] private transactions;
    mapping(uint256 => mapping(address => bool)) private confirms;

    constructor(uint256 _supplyTokenWei, uint256 _releaseDate, address[] memory _wallets, uint256[] memory _percents, address[] memory _signers,
    uint256[] memory _tgePercents, uint256[] memory _numOfPeriods, uint256[] memory _ciffs) {  
        for (uint256 i = 0; i < _wallets.length; i++) {
            uint256 _amount = _supplyTokenWei  * _percents[i]/100;
            uint256 _tgeAmount = _amount * _tgePercents[i]/100;
            uint256 _nextReleaseTime = _releaseDate + (_ciffs[i] * periodInSecond);

            LockItem memory item = getLockItem(_amount, _nextReleaseTime, _numOfPeriods[i], _releaseDate, _tgeAmount);
            lockeds[_wallets[i]] = item;
            emit event_lockSystemWallet(owner, _wallets[i], item.lockedAmount, item.releaseTime, _numOfPeriods[i]);
        }
        for (uint256 i = 0; i < _signers.length; i++){
            isSigner[_signers[i]] = true;
            signers.push(_signers[i]);
        }
    }

    function getSigners() public view returns (address[] memory){
        return signers;
    }

    function addSigner(address[] memory _signers) public onlyOwner returns (bool){
        for (uint256 i = 0; i < _signers.length; i++) {
            address _signer = _signers[i];
            require(_signer != address(0) && !isSigner[_signer], "invalid signer");
            
            isSigner[_signer] = true;
            signers.push(_signer);
        }
        return true;
    }

    function removeSigner(address _signer) public onlyOwner returns(bool){
        uint256 _indexSigner;
        bool exists;
        for (uint256 i=0; i< signers.length; i++){
            if (signers[i] == _signer){
                exists = true;
                break;
            }
        }
        if(exists){
            isSigner[_signer] = false;
            signers[_indexSigner] = signers[signers.length - 1];
            signers.pop();
        }
        return true;
    }

    function getLockedAmount(address lockedAddress) public view returns(uint256) {
        LockItem memory item = lockeds[lockedAddress];
        if(item.tgeAmount > 0 && block.timestamp >= item.tgeTime){
            item.tgeAmount = 0;
        }
        if(item.lockedAmount > 0){
            while(block.timestamp >= item.releaseTime){
                if(item.lockedAmount > item.amountInPeriod){
                    item.lockedAmount = item.lockedAmount - item.amountInPeriod;
                }else{
                    item.lockedAmount = 0;
                }
                item.releaseTime = item.releaseTime + periodInSecond;
            }
        }
	    return item.lockedAmount + item.tgeAmount;
	}

    function getAllTransaction() public view onlyOwner
    returns (Transaction[] memory){
        return transactions;
    }

    function getTransactionById(uint256 _txId) public view onlyOwner
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

    function confirm(address _signer, uint256 _txId) public 
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

        canExecute = (_transaction.numConfirmations >= 3 || _transaction.numConfirmations == signers.length);
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

contract HubGameToken is BEP20, Ownable, CommonUtil {
    uint8 public constant decimals = 8;
    uint256 private totalSupplyAtBirth = 50000000000 * 10 ** uint256(decimals);
    uint256 private totalMinted = 0;
    uint256 private _txIndex = 0;

    mapping(address => bool) private isAdmin;
    address[] private blackList;
    mapping(address => bool) private isBlackList;
    
    mapping(address => LockItem[]) private lockedList;
    mapping(address => bool) private isLocked;

    mapping(string => address) private gameControllers;
    mapping(string => uint256) private gameSupplies;

    mapping(address => bool) private isSystemWallet;
    mapping(address => string) private systemWallets;
    mapping(string => mapping(address => bool)) private signerWallets;

	constructor() BEP20("HubGame Pitchdeck", "HUB2"){
        isAdmin[msg.sender] = true;
    }

    modifier requireDeployed(string memory _gameCode){
        require (isAdmin[msg.sender] == true, "must be admin");
        require (gameControllers[_gameCode] != address(0), "invalid game contract");
        _;
    }

    modifier onlyAdmin() {
        require (isAdmin[msg.sender] == true, "must be admin");
        _;
    }

    modifier requireNotEmptyCode(string memory _gameCode) {
        require(keccak256(abi.encodePacked(_gameCode)) != keccak256(abi.encodePacked("")), "invalid game code");
        _;
    }

    modifier requireSigner(string memory _gameCode) {
        require(signerWallets[_gameCode][msg.sender] == true, "Access denied");
        _;
    }

    modifier requiredTransfer(address _from, address _receiver, uint256 _amount) {
        require(!isSystemWallet[msg.sender], "must be not system wallet");
        require(!isBlackList[msg.sender], "in black list");
        require(_from != _receiver && _receiver != address(0), "invalid address");
        require(_amount > 0 && _amount <= availableBalance(_from), "not enough funds to transfer");
        _;
    }

    function getCurrentTime() public view returns (uint256){
        return block.timestamp;
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

    function getControllers(string memory _gameCode) public view 
    onlyAdmin 
    requireNotEmptyCode(_gameCode)
    returns (address){
        return gameControllers[_gameCode];
    }

    function totalSupply() public view returns (uint256){
        return totalSupplyAtBirth;
    }

    function totalMint() public view returns (uint256){
        return totalMinted;
    }

    function totalSupplyInGame(string memory _gameCode) public view 
    requireNotEmptyCode(_gameCode)
    returns (uint256){
        return gameSupplies[_gameCode];
    }

    function initGame(string memory _gameCode, uint256 _supplyToken, uint256 _listingDate, address[] memory _wallets, uint256[] memory _percents,  
    address[] memory _signers, uint256[] memory _tgePercents, uint256[] memory _numOfPeriods, uint256[] memory _ciffs) 
    public onlyAdmin returns (address gameAddress){
        require(gameControllers[_gameCode] == address(0), "game code is exist");

        uint256 _totalSupplyWei = _supplyToken * 10 ** uint256(decimals);
        require(totalSupplyAtBirth - totalMinted >= _totalSupplyWei, "out of available balance of token");

        require(_signers.length > 0 && _wallets.length == _percents.length 
                && _tgePercents.length == _numOfPeriods.length && _numOfPeriods.length == _ciffs.length, "mismatch locked param");

        for (uint256 i = 0; i < _wallets.length; i++) {
            address _wallet = _wallets[i];
            require(isSystemWallet[_wallet] == false, "system wallet is exist");

            _mint(_wallet, _totalSupplyWei  * _percents[i]/100); 
            isSystemWallet[_wallet] = true;
            systemWallets[_wallet] = _gameCode;
            isLocked[_wallet] = true;
        }

        for (uint256 i = 0; i < _signers.length; i++) {
            signerWallets[_gameCode][_signers[i]] = true;
        }
        //_supplyTokenWei, _releaseDate, _wallets, _percents,_signers,_tgePercents, _numOfPeriods, _ciff
        gameAddress = address(new HubController{salt: keccak256(abi.encode(_gameCode, _supplyToken))}
                                (_totalSupplyWei, _listingDate, _wallets , _percents, _signers, _tgePercents, _numOfPeriods, _ciffs));
        gameControllers[_gameCode] = gameAddress;
        gameSupplies[_gameCode] = _totalSupplyWei;
        totalMinted = totalMinted + _totalSupplyWei;
    }

    function signerAdd(string memory _gameCode, address[] memory _signers) public 
    requireDeployed(_gameCode) returns (bool){
        return HubController(gameControllers[_gameCode]).addSigner(_signers);
    }

    function signerRemove(string memory _gameCode, address _signer) public 
    requireDeployed(_gameCode) returns (bool){
        return HubController(gameControllers[_gameCode]).removeSigner(_signer);
    }

    function getAvailableBalance(address lockedAddress) public view returns(uint256) {
        uint256 bal = balanceOf(lockedAddress);
        uint256 locked = _getLockedAmount(lockedAddress);
        return bal-locked;
	}

    function availableBalance(address lockedAddress) internal returns(uint256) {
        uint256 bal = balanceOf(lockedAddress);
        uint256 locked = _getLockedAmount(lockedAddress);
        if(locked == 0) {
            isLocked[lockedAddress] = false;
        }
        return bal-locked;
	}

    function _getLockedAmount(address lockedAddress) internal view returns(uint256) {
        if(isLocked[lockedAddress] == false) return 0;
        
        address _contract = gameControllers[systemWallets[lockedAddress]];
        if(_contract == address(0)){
            LockItem[] memory items = lockedList[lockedAddress];
	        uint256 lockedAmount = 0;
            for(uint256 j = 0; j < items.length; j++) {
                while(block.timestamp >= items[j].releaseTime){
                    if(items[j].lockedAmount > items[j].amountInPeriod){
                        items[j].lockedAmount = items[j].lockedAmount - items[j].amountInPeriod;
                    }else{
                        items[j].lockedAmount = 0;
                    }
                    items[j].releaseTime = items[j].releaseTime + periodInSecond;
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

    function _verifyGameCode(string memory _gameCode) internal view returns (address _contract){
        _contract = gameControllers[_gameCode];
        require(_contract != address(0), "Access denied");
    }

    function getTransactions(string memory _gameCode) public view 
    requireNotEmptyCode(_gameCode)
    returns (Transaction[] memory){
        if(totalMinted > 0){
            address _contract = _verifyGameCode(_gameCode);
            return HubController(_contract).getAllTransaction();
        }
        return new Transaction[](0);
    }

    function getTransactionById(string memory _gameCode, uint256 _txId) public view 
    requireNotEmptyCode(_gameCode)
    returns (Transaction memory){
        if(totalMinted > 0){
            address _contract = _verifyGameCode(_gameCode);
            return HubController(_contract).getTransactionById(_txId);
        }
        Transaction memory _transaction;
        return _transaction;
    }

    function getConfirmations(string memory _gameCode, uint256 _txId) public view 
    requireNotEmptyCode(_gameCode)
    returns (address[] memory) {
        if(totalMinted > 0){
            address _contract = _verifyGameCode(_gameCode);
            return HubController(_contract).getConfirmations(_txId);
        }
        return new address[](0);
    }

    function transactionSubmit(address _receiver, uint256 _value, uint256[] memory _lockParams) public returns (uint256){
        address _contract = _verifyGameCode(systemWallets[msg.sender]);
        _txIndex += 1;
        require(HubController(_contract).submit(_txIndex, msg.sender, _receiver, _value, _lockParams));
        return _txIndex;
    }

    function transactionConfirm(string memory _gameCode, uint256 _txId) 
    requireNotEmptyCode(_gameCode)
    requireSigner(_gameCode)
    public{
        address _from;
        address _to;
        uint256 _value;
        bool _canExecute;
        uint256[] memory _params;

        address _contract = _verifyGameCode(_gameCode);
        HubController _game = HubController(_contract);
        (_canExecute, _from, _to, _value, _params) = _game.confirm(msg.sender, _txId);
        
        if(_canExecute && availableBalance(_from) >= _value){
            _transfer(_from, _to, _value);
            if(_params.length > 0 && _params[0] > 0){
                //releaseDate, numPeriod
                LockItem memory item = getLockItem(_value, _params[0], _params[1], 0, 0);
                lockedList[_to].push(item);
                emit event_lockWallet(_from, _to, item.lockedAmount, item.releaseTime, _params[1]);
            }
            _game.executed(msg.sender, _txId);
        }
    }

    function transactionRevoke(string memory _gameCode, uint256 _txId) public 
    requireNotEmptyCode(_gameCode)
    requireSigner(_gameCode)
    {
        address _contract = _verifyGameCode(_gameCode);
        require(HubController(_contract).revoke(msg.sender, _txId));
    }

}