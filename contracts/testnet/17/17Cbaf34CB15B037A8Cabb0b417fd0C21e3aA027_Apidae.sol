/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

/**
 * SPDX-License-Identifier: MIT
 *
 * Tokenomics:
 *  Max Supply: 32,000,000
 *  Decimals: 18
 *  Token Name: Apidae Token
 *  Symbol: APT
 * 
 * 
 * Buy Tax 3% :            Sell Tax 7% :
 *  Development      3%      Liquidity      2%
 *                           Buyback        5% 
 */

 pragma solidity ^0.8.11;

 abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return (msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
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

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

 /*
 * This contract is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    mapping (address => bool) internal authorizations;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        authorizations[_owner] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided (seconds)
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp> _lockTime , "Contract is still locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }

    //Modifier to require caller to be authorized
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    //Authorize address.
    function authorize(address account) public onlyOwner {
        authorizations[account] = true;
    }

    // Remove address authorization.
    function unauthorize(address account) public onlyOwner {
        authorizations[account] = false;
    }

    // Return address authorization status
    function isAuthorized(address account) public view returns (bool) {
        return authorizations[account];
    }
}



library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

contract Apidae is Context, Ownable, ERC20  {
    using Address for address payable;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcludedFromMaxSellTxLimit;
    mapping (address=>bool) private _isBlacklisted;

    address payable public devWallet = payable(0xb3257f377ba4F843Bd369250353fFDbee450B13A);
    address payable public buybackWallet = payable(0x4Ccf267f6780f567652e8a46a3cF95D728f763de);
    address public liquidityWallet;
    address constant private  DEAD = 0x000000000000000000000000000000000000dEaD;

    // Buying fees
    uint8 public buyDevFee = 3;

    // Selling fees
    uint8 public sellBuybackFee = 5;
    uint8 public sellLiquidityFee = 2;

    uint256 public totalSellFees;
    uint256 public totalBuyFees;

    // Limits
    uint256 public maxSellLimit =  100_000 * 10**18; // 100k
    


    // Before this date, only certain addresses can send tokens
    uint256 public tradingEnabledTimestamp = 1657393200; // Sat Jul 09 2022 19:00:00 GMT+0000
    // Only these addresses will be able to send token before the launch.
    // Generally it is the owner and the address of the presale which are added
    mapping (address => bool) private _canSendTokensBeforeTradingIsEnabled;


    // Any transfer to these addresses could be subject to some sell/buy taxes
    mapping (address => bool) public automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeFromMaxSellTxLimit(address indexed account, bool isExcluded);
    event BlackList(address indexed account, bool isBlacklisted);

    event AddAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event UniswapV2RouterUpdated(address indexed newAddress, address indexed oldAddress);
    event UniswapV2MainPairUpdated(address indexed newAddress, address indexed oldAddress);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
    event DevWalletUpdated(address indexed newDevWallet, address indexed oldDevWallet);
    event BuybackWalletUpdated(address indexed newBuybackWallet, address indexed oldBuybackWallet);

    event Burn(uint256 amount);

    event SellFeesUpdated(uint8 liquidityFee, uint8 buybackFee);
    event BuyFeesUpdated(uint8 devFee);

    event MaxSellLimitUpdated(uint256 amount);

    event SwapAndLiquify(uint256 tokensSwapped,uint256 ethReceived,uint256 tokensIntoLiquidity);

    constructor() ERC20("Apidae Token", "APT") {
        // Create supply
        _mint(msg.sender, 32_000_000 * 10**18);

    }

    function burn(uint256 amount) external returns (bool) {
        _transfer(_msgSender(), DEAD, amount);
        emit Burn(amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "APT: Transfer from the zero address");
        require(to != address(0), "APT: Transfer to the zero address");
        require(amount >= 0, "APT: Transfer amount must be greater or equals to zero");

        super._transfer(from, to, amount);

    }

    receive() external payable {
  	}

}