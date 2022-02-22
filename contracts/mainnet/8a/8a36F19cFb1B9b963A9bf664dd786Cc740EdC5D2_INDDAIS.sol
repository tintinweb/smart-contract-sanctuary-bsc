/**
 *Submitted for verification at BscScan.com on 2022-02-22
*/

// SPDX-License-Identifier: No License
pragma solidity ^0.8.11;
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Bought(address indexed buyer, uint256 token, uint256 value);
    event CapitalTransfer(address indexed owner, uint256 value);
    event SlicePaid(address indexed referrer, uint256 value);
    event AddStock(address indexed owner, uint256 token);
    event Sold(address indexed seller, uint256 value, uint256 token);
    event Slice(address indexed referrer, address buyer, uint256 bought, uint256 earned);
    event Minted(address indexed minter,uint256 token);
    event Sprinkled(address indexed from, address indexed to, uint256 value, uint256 sprinkle);
}
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor () {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}
// OpenZeppelin Contracts (token/ERC20/ERC20.sol) With custom changes
contract ERC20 is ReentrancyGuard, Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => uint256) private _bought;
    mapping(address => uint256) private _sold;
    mapping(address => uint256) private _LastSold;
    mapping(address => uint256) private _sprinkle;
    mapping(address => address) private _ref;
    mapping(address => uint256) private _refcount;
    mapping(address => uint256) private _slice;

    uint256 _totalSupply;
    uint256 _InitialSupply;
    uint256 _totalSprinkle;
    uint256 private _Capital;
    uint256 _CoinToken;
    uint256 _TokenCoin;
    uint256 _BurnRate;
    uint256 _SprinkleRate;
    uint256 _StockAdded;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address private _owner;
    address private _manager;
    address private _promoter;

    constructor (string memory name_, string memory symbol_, uint8 decimals_, uint256 initialBalance_, uint256 CoinToken_, uint256 TokenCoin_, uint256 BurnRate_,uint256 SprinkleRate_,address promoter_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _InitialSupply = initialBalance_*10**uint256(_decimals);
        _CoinToken = CoinToken_;
        _TokenCoin = TokenCoin_;
        _BurnRate = BurnRate_;
        _SprinkleRate = SprinkleRate_;
        _promoter = promoter_;
        _owner = msg.sender;
        _manager = msg.sender;
        _totalSprinkle = 0;
        _StockAdded = 0;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
    function InitialSupply() public view virtual returns (uint256) {
        return _InitialSupply;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function totalSprinkle() public view virtual returns (uint256) {
        return _totalSprinkle;
    }
    function CirculatingSupply() public view virtual returns (uint256) {
        unchecked { return _totalSupply - (_balances[_owner] + _balances[address(this)]); }
    }
    function StockAdded() public view virtual returns (uint256) {
        return _StockAdded;
    }
    function TokenStock() public view virtual returns (uint256) {
        return _balances[address(this)];
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function mysprinkle(address account) public view virtual returns (uint256) {
        return _sprinkle[account];
    }
    function TotalBought(address account) public view virtual returns (uint256) {
        return _bought[account];
    }
    function TotalSold(address account) public view virtual returns (uint256) {
        return _sold[account];
    }
    function Referrer(address account) public view virtual returns (address) {
        return _ref[account];
    }
    function RefCount(address account) public view virtual returns (uint256) {
        return _refcount[account];
    }
    function SliceMade(address account) public view virtual returns (uint256) {
        return _slice[account];
    }
    function AssetBalance() public view returns (uint256) {
        unchecked {
        return address(this).balance < _Capital ? _Capital - address(this).balance : address(this).balance - _Capital;
        }
    }
    function CapitalReserved() public view returns (uint256) {
        return _Capital;
    }
    function BurnRate() public view returns (uint256) {
        return _BurnRate;
    }
    function Coin2Token() public view virtual returns (uint256) {
        return _CoinToken;
    }
    function Token2Coin() public view virtual returns (uint256) {
        return _TokenCoin;
    }
    function SprinkleRate() public view virtual returns (uint256) {
        return _SprinkleRate;
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount + _SprinkleRate);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "new allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
/**
* The implementation of sprinkle ensures a healthy token ecosystem by adding friction 
* to token movement, the sprinkles are burned automatically thus gradually will increase the 
* token demand over time. Will not work if the sprinkle is set to zero. 
*/
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "from zero address");
        require(to != address(0), "to zero address");
        require(to != address(this), "direct transfer to contract");
        require(from != _owner, "direct transfer from owner");
        uint256 fromBalance = _balances[from];
        if (_SprinkleRate > 0) {
            require(fromBalance >= amount + _SprinkleRate, "above balance");
            unchecked {
            _balances[from] = fromBalance - (amount + _SprinkleRate);
            }
            _sprinkle[from] += _SprinkleRate;
            _totalSupply -= _SprinkleRate;
            _totalSprinkle += _SprinkleRate;
            _balances[to] += amount;
            emit Transfer(from, to, amount);
            emit Sprinkled(from, to, amount, _SprinkleRate);
        } else {
            require(fromBalance >= amount, "above balance");
            unchecked {
            _balances[from] = fromBalance - amount;
            }
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        }
    }

    function _mint(uint256 amount) internal virtual {
        _totalSupply += amount;
        _balances[_owner] += amount;
        emit Transfer(address(0), _owner, amount);
        emit Minted(_owner, amount);
        _balances[_owner] -= amount*15/100;
        _balances[_promoter] += amount*15/100;
        emit Transfer(_owner, _promoter, amount*15/100);

    }

/**
* The implementation of token burn process is straight forward and controlled by the pre-defined burn rate. 
* 20 percent of funds received from token sales and 10 percent of company quarterly profits as mentioned 
* in the whitepaper are made available to support burn or sale transactions.
*/
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "burn from zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "exceeds balance");
        uint256 BurnValue = (amount * _BurnRate) / 10**18;
        uint256 CoinBalance = address(this).balance < _Capital ? _Capital - address(this).balance : address(this).balance - _Capital;
        require(CoinBalance >= BurnValue, "above available coins");
        unchecked {
        _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        payable(account).transfer(BurnValue);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "from zero address");
        require(spender != address(0), "to zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

/**
* This implementation facilitates users to buy INIS tokens based on the given WeiPrice. The function triggers 
* whenever the contract receives base coin except when the sender is the Owner. 20 percent of the funds received 
* is maintained in the account to support Burn or Sell transactions.
*/

    function buy(address buyer,uint256 amount,address nref) internal virtual nonReentrant {
        require(amount > 0, "no coin received");
        require(buyer != address(0), "from zero address");
        uint256 cInisBalance = _balances[address(this)];
        uint256 BuyAmount = (amount * _CoinToken) / 10**_decimals;
        require(BuyAmount <= cInisBalance, "above available tokens");
        _balances[address(this)] -= BuyAmount;
        _balances[buyer] += BuyAmount;
        _bought[buyer] +=  BuyAmount;
        _Capital += (amount * 80) / 100;
        emit Transfer(address(this), buyer, BuyAmount);
        emit Bought(buyer, BuyAmount, amount);
        if (_ref[msg.sender] != address(0)) {
            address aref = _ref[msg.sender];
            uint256 sliceamt = (msg.value * 2) / 100;
            _slice[aref] += sliceamt;
            emit Slice(aref, msg.sender, msg.value, sliceamt);
        }
        if(_ref[msg.sender] == address(0) && nref != address(0)) {
                _ref[msg.sender] = nref;
                _refcount[nref] += 1;
                uint256 sliceamt = (msg.value * 2) / 100;
                _slice[nref] += sliceamt;
                emit Slice(nref, msg.sender, msg.value, sliceamt);
        }
    }

/**
* This implementation lets the owner to transfer the reserved amount from sale and utilize it for business 
* ventures as mentioned in the whitepaper. The reserve funds can be transferred only to the Owner wallet.
*/

    function TransferReserve() public virtual nonReentrant {
        require(_Capital > 0, "no reserve balance");
        require(_msgSender() != address(0), "from zero address");
        _TransferReserve(_Capital);
    }

    function _TransferReserve(uint256 amount) internal virtual {
        _Capital = 0;
        emit CapitalTransfer(_owner, amount);
        payable(_owner).transfer(amount);
    }

    function SliceTransfer() public virtual nonReentrant {
        require(_msgSender() != address(0), "from zero address");
        require(_slice[_msgSender()] > 0, "no slice made");
        uint256 amount = _slice[_msgSender()];
        _slice[_msgSender()] = 0;
        emit SlicePaid(_msgSender(),amount);
        payable(_msgSender()).transfer(amount);
    }

/**
* The implementation of sales supply allows the management to streamline the token sales process. The contract 
* by default will not accept direct transfers token transfer from accounts and the tokens available for 
* sales are only from  the management or from a user who sold tokens.
*/

    function SupplyStock(uint256 amount) public virtual nonReentrant {
        require(_msgSender() != address(0), "from zero address");
        require(amount > 0, "no tokens to add");
        uint256 INISBalance = _balances[_msgSender()];
        require(amount <= INISBalance, "above token balance");
        require(_balances[address(this)] <= _InitialSupply*2/100, "stock available");
        require(_balances[address(this)] + amount <= _InitialSupply*10/100, "above level");
        _SupplyStock(amount);
        emit AddStock(_msgSender(), amount);
    }
    function _SupplyStock(uint256 amount) internal virtual {
        _balances[_msgSender()] -= amount;
        _balances[address(this)] += amount;
        _StockAdded += amount;
        emit Transfer(_msgSender(), address(this), amount);
    }

/**
* This Implementation facilitates users to sell INIS tokens they hold based on the pre-defined WeiPrice 
* set by the Owner. Each sale is limited to 10 percent of the total purchase value of the user and 
* waiting period of 30 days between each sale transaction as mentioned in the whitepaper. Only the 
* tokens bought from this contract can be sold here. 
*/

    function sell(uint256 amount) public virtual nonReentrant {
        require(_msgSender() != address(0), "from zero address");
        require(amount > 0, "no tokens received");
        uint256 INISBalance = _balances[_msgSender()];
        require(amount <= INISBalance, "above token balance");
        require(block.timestamp > _LastSold[_msgSender()] + 30 days, "wait period active");
        require((_bought[_msgSender()] * 10) / 100 >= amount, "exceeds allowed level");
        require(_bought[_msgSender()] >= _sold[_msgSender()] + amount, "not bought here");
        uint256 SellAmount = (amount * _TokenCoin) / 10**18;
        uint256 CoinBalance = address(this).balance < _Capital ? _Capital - address(this).balance : address(this).balance - _Capital;
        require(CoinBalance >= SellAmount, "not enough asset balance");
        _sell(amount,SellAmount);
        emit Sold(_msgSender(),SellAmount,amount);
    }

    function _sell(uint256 amount,uint256 SellAmount) internal virtual {
        _balances[_msgSender()] -= amount;
        _balances[address(this)] += amount;
        _sold[_msgSender()] +=  amount;
        _LastSold[_msgSender()] = block.timestamp;
        emit Transfer(_msgSender(), address(this), amount);
        payable(_msgSender()).transfer(SellAmount);
    }
}
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)
abstract contract ERC20Burnable is Context, ERC20 {
    event Burned(address indexed user,uint256 token);
    event BurnedFrom(address indexed spender, address indexed user, uint256 token);
    function burn(uint256 amount) public virtual nonReentrant {
        _burn(_msgSender(), amount);
        emit Burned(_msgSender(),amount);
    }
    function burnFrom(address account, uint256 amount) public virtual nonReentrant {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
        emit BurnedFrom(_msgSender(),account,amount);
    }
}
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1363.sol)
interface IERC1363 is IERC165, IERC20 {
    function transferAndCall(address to, uint256 value) external returns (bool);
    function transferAndCall(address to, uint256 value, bytes memory data) external returns (bool);
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);
    function transferFromAndCall(address from, address to, uint256 value, bytes memory data) external returns (bool);
    function approveAndCall(address spender, uint256 value) external returns (bool);
    function approveAndCall(address spender, uint256 value, bytes memory data) external returns (bool);
}
interface IERC1363Receiver {
    function onTransferReceived(address operator, address sender, uint256 amount, bytes calldata data) external returns (bytes4);
}
interface IERC1363Spender {
    function onApprovalReceived(address sender, uint256 amount, bytes calldata data) external returns (bytes4);
}
/**
 * @title ERC1363
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev Implementation of an ERC1363 interface
 */
abstract contract ERC1363 is ERC20, IERC1363, ERC165 {
    using Address for address;

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1363).interfaceId || super.supportsInterface(interfaceId);
    }
    function transferAndCall(address to, uint256 amount) public virtual override returns (bool) {
        return transferAndCall(to, amount, "");
    }
    function transferAndCall(address to, uint256 amount, bytes memory data) public virtual override returns (bool) {
        transfer(to, amount);
        require(_checkAndCallTransfer(_msgSender(), to, amount, data), "_checkAndCallTransfer reverts");
        return true;
    }
    function transferFromAndCall(address from, address to, uint256 amount) public virtual override returns (bool) {
        return transferFromAndCall(from, to, amount, "");
    }
    function transferFromAndCall(address from, address to, uint256 amount, bytes memory data) public virtual override returns (bool) {
        transferFrom(from, to, amount);
        require(_checkAndCallTransfer(from, to, amount, data), "_checkAndCallTransfer reverts");
        return true;
    }
    function approveAndCall(address spender, uint256 amount) public virtual override returns (bool) {
        return approveAndCall(spender, amount, "");
    }
    function approveAndCall(address spender, uint256 amount, bytes memory data) public virtual override returns (bool) {
        approve(spender, amount);
        require(_checkAndCallApprove(spender, amount, data), "_checkAndCallApprove reverts");
        return true;
    }
    function _checkAndCallTransfer(address sender, address recipient, uint256 amount, bytes memory data) internal virtual returns (bool) {
        if (!recipient.isContract()) {
            return false;
        }
        bytes4 retval = IERC1363Receiver(recipient).onTransferReceived(_msgSender(), sender, amount, data);
        return (retval == IERC1363Receiver(recipient).onTransferReceived.selector);
    }
    function _checkAndCallApprove(address spender, uint256 amount, bytes memory data) internal virtual returns (bool) {
        if (!spender.isContract()) {
            return false;
        }
        bytes4 retval = IERC1363Spender(spender).onApprovalReceived(_msgSender(), amount, data);
        return (retval == IERC1363Spender(spender).onApprovalReceived.selector);
    }
}
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
abstract contract Ownable is Context {
    address public _owner;
    address public _manager;
    address public _promoter;
    event ManagerChanged(address indexed previousManager, address indexed newManager);
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function manager() public view virtual returns (address) {
        return _manager;
    }
    function promoter() public view virtual returns (address) {
        return _promoter;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "only owner allowed");
        _;
    }
    modifier onlyManager() {
        require(manager() == _msgSender(), "only manager allowed");
        _;
    }
    function ChangeManager(address newManager) public virtual onlyOwner {
        require(newManager != address(0), "zero address");
        emit ManagerChanged(_manager, newManager);
        _manager = newManager;
    }
}
/**
 * @title TokenRecover
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev Allows owner to recover any ERC20 sent into the contract
 */
contract TokenRecover is Ownable {
    function recoverERC20(address tokenAddress, uint256 tokenAmount) public virtual onlyOwner {
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }
}

abstract contract ERC20Mintable is ReentrancyGuard, ERC20 {
/**
The implementation of mint process facilitates the management to add fresh supply of INIS. The mint process 
is disabled by default when deploying the contract and can be enabled again only when the total supply of 
the tokens falls below 60 percent of the initial supply.
*/

    bool private _mintingFinished = false;
    event MintEnabled();
    modifier canMint() {
        require(!_mintingFinished, "minting in progress");
        _;
    }
    modifier canStart() {
        require(_totalSupply <= _InitialSupply*60/100, "above mint level");
        _;
    }
    function mintingFinished() external view returns (bool) {
        return _mintingFinished;
    }
    function mint(uint256 amount) public virtual nonReentrant canMint {
        require(_totalSupply + amount <= _InitialSupply, "exceeds initialsupply");
        _mint(amount);
        _mintingFinished = true;
    }

    function EnableMinting() external canStart {
        _EnableMinting();
    }
    function _EnableMinting() internal virtual {
        _mintingFinished = false;
        emit MintEnabled();
    }
}

contract INDDAIS is ERC20Mintable, ERC20Burnable, ERC1363, TokenRecover {

    event TokenRate(uint256 oldrate,uint256 newrate);
    event CoinRate(uint256 oldrate,uint256 newrate);
    event NewBurnRate(uint256 oldrate,uint256 newrate);
    event NewSprinkleRate(uint256 oldSprinkle,uint256 newSprinkle);
    event Income(address indexed sender,uint256 added);

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialBalance_,
        uint256 CoinToken_,
        uint256 TokenCoin_,
        uint256 BurnRate_,
        uint256 SprinkleRate_,
        address promoter_
    ) payable ERC20(name_, symbol_, decimals_, initialBalance_, CoinToken_, TokenCoin_, BurnRate_, SprinkleRate_, promoter_) {
        _owner  = msg.sender;
        _manager = msg.sender;
        _InitialSupply = initialBalance_*10**uint256(decimals_);
        _CoinToken = CoinToken_;
        _TokenCoin = TokenCoin_;
        _BurnRate = BurnRate_;
        _SprinkleRate = SprinkleRate_;
        _promoter = promoter_;
        mint(initialBalance_*10**uint256(decimals_));
    }

    function setCoinToken(uint256 rate) public virtual nonReentrant onlyManager {
        require(rate < _CoinToken, "rate is greater");
        uint256 oldCoinToken = _CoinToken;
        _CoinToken = rate;
        emit TokenRate(oldCoinToken,_CoinToken);
    }

    function setTokenCoin(uint256 rate) public virtual nonReentrant onlyManager {
        require(rate > _TokenCoin, "rate is lesser");
        uint256 oldTokenCoin = _TokenCoin;
        _TokenCoin = rate;
        emit CoinRate(oldTokenCoin,_TokenCoin);
    }

    function setBurnRate(uint256 rate) public virtual nonReentrant onlyManager {
        require(rate > _BurnRate, "rate is lesser");
        uint256 _oldBurnRate = _BurnRate;
        _BurnRate = rate;
        emit NewBurnRate(_oldBurnRate,_BurnRate);
    }

    function setSprinkleRate(uint256 fee) public virtual nonReentrant onlyOwner {
        require(fee < 10**16,"fee limit exceeds");
        uint256 oldSprinkleRate = _SprinkleRate;
        _SprinkleRate = fee;
        emit NewSprinkleRate(oldSprinkleRate,_SprinkleRate);
    }

    function _TransferReserve(uint256 amount) internal override onlyOwner {
        super._TransferReserve(amount);
    }

    function _SupplyStock(uint256 amount) internal override onlyOwner {
        super._SupplyStock(amount);
    } 

    function _mint(uint256 amount) internal override onlyOwner {
        super._mint(amount);
    }

    function _EnableMinting() internal override onlyOwner {
        super._EnableMinting();
    }

    function refbuy(address nref) external payable {
        require(nref != msg.sender, "self referring");
        buy(msg.sender,msg.value,nref);
    }

    receive() external payable {
        if(msg.sender != _owner) {
            buy(msg.sender,msg.value,address(0));
        } else {
            emit Income(_owner,msg.value); 
        }
    }
    
    fallback () external payable {
        if(msg.sender != _owner) {
            buy(msg.sender,msg.value,address(0));
        } else {
            emit Income(_owner,msg.value);
        }
    }
}