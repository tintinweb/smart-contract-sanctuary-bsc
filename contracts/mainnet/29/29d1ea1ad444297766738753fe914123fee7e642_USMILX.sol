/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
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

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
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

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
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
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }
     
    function _transferBuyingFee(
        address from,
        address to,
        uint256 amount,
        uint256 fee,
        address dist
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        amount = amount - fee;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);

              _beforeTokenTransfer(from, dist, fee);
            _balances[dist] += fee;
             emit Transfer(from, dist, fee);
             _afterTokenTransfer(from, dist, fee);
    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

/**
 *  dex pancake interface
 */
 
interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IPancakeRouter {
     function WETH() external pure returns (address);
     function factory() external pure returns (address);
} 

interface IPancakePair{
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract USMILX is ERC20 {
    uint256 public INITIAL_SUPPLY = 100000000000 * 1 ether;
    address public marketing;
    address public charity;
    address public exchange;
    address public platform;
    uint256 public marketingFee;
    uint256 public charityFee;
    uint256 public exchangeFee;
    uint256 public platformFee;
    uint256 public holdersFee;
    uint256 public currentPayroll = 1;
    uint256 public sellingTaxFee = 20;
    uint256 public buyingTaxFee = 10;
    bool public enabled = true;
    mapping(uint256 => address) public holdersList;
    mapping(address => bool) public isHolder;
    mapping(address => bool) public blacklist;
    mapping(address => bool) public frozen;
    mapping(address => uint256) public blacklistLimit;
    mapping(address => uint256) public holderLastPayroll;
    mapping(address => uint256) public blacklistSentAmount;
    address public immutable pairAddress;
    address public immutable routerAddress;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 public holders = 0;
    event MarketingSet(address wallet);
    event CharitySet(address wallet);
    event ExchangeSet(address wallet);
    event PlatformSet(address wallet);
    event WalletBlackListed(address wallet);
    event WalletActivated(address wallet);
    event WalletFrozen(address wallet);
    event WalletUnFrozen(address wallet);
    event CharityFeeSent(address wallet, uint256 amount);
    event MarketingFeeSent(address wallet, uint256 amount);
    event PlatFormFeeSent(address wallet, uint256 amount);
    event ExchangeFeeSent(address wallet, uint256 amount);
    event HolderFeeSent(address wallet, uint256 amount);
    event PayrollUpdated(uint256 current);
    constructor() ERC20("USMILX", "USMX") {
        _mint(msg.sender, INITIAL_SUPPLY);
        platform = msg.sender;
        marketing = 0xfc4E76A946127A9F92cED527CEb5033D2c6aE0Ce;
        charity   = 0xDd4b377085cb7c8CB8408472f2c8B82Fce0f4C2F;
        exchange  = 0x76E5d9cbD56CCE3256d8C162e4BC3c989C8e853E;
    
        IPancakeRouter _router = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
            
        pairAddress = IPancakeFactory(_router.factory())
            .createPair(address(this), _router.WETH());

        // set the rest of the contract variables
        routerAddress = address(_router);
        
        _isExcludedFromFee[platform] = true;
        _isExcludedFromFee[marketing] = true;
        _isExcludedFromFee[charity] = true;
        _isExcludedFromFee[exchange] = true;

    }

    modifier OnlyPlatform() {
        require(msg.sender == platform, "Platform owner only");
        _;
    }


      modifier isEnabled() {
        require(enabled == true, "Contract turned off");
        _;
    }

    function setEnabled(bool _enabled) public OnlyPlatform {
    enabled = _enabled;
    }


        
    function excludeFromFee(address account) public OnlyPlatform {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public OnlyPlatform {
        _isExcludedFromFee[account] = false;
    }
    
    function setBuyingTax(uint256 _taxFee) public OnlyPlatform{
        buyingTaxFee = _taxFee;
    }

      function setSellingTax(uint256 _taxFee) public OnlyPlatform{
        sellingTaxFee = _taxFee;
    }


    function setMarketing(address wallet) public OnlyPlatform{
        _isExcludedFromFee[marketing] = false;
        marketing = wallet;
        _isExcludedFromFee[marketing] = true;
        emit MarketingSet(wallet);
    }
    function setCharity(address wallet) public OnlyPlatform{
        _isExcludedFromFee[charity] = false;
        charity = wallet;
        _isExcludedFromFee[charity] = true;
        emit CharitySet(wallet);
    }
    function setExchange(address wallet) public OnlyPlatform{
        _isExcludedFromFee[exchange] = false;
        exchange = wallet;
        _isExcludedFromFee[exchange] = true;
        emit ExchangeSet(wallet);
    }
    function setPlatform(address wallet) public OnlyPlatform{
        _isExcludedFromFee[platform] = false;
        platform = wallet;
        _isExcludedFromFee[platform] = true;
        emit PlatformSet(wallet);
    }
    function airdrop(address[] memory wallet, uint256[] memory amount) public OnlyPlatform{
        require(wallet.length == amount.length, "wrong array length");
        for (uint256 index = 0; index < wallet.length; index++) {
            if (balanceOf(wallet[index]) <= 0 && !isHolder[wallet[index]]) {
            holders++;
            holdersList[holders] = wallet[index];
            isHolder[wallet[index]] = true;
        } 
             _transfer(msg.sender, wallet[index], amount[index]);
        }
    }

    function blacklistWallet(address wallet) public OnlyPlatform{
        blacklistLimit[wallet] = (balanceOf(wallet) * 5) / 100;
        blacklist[wallet] = true;
        emit WalletBlackListed(wallet);
    }

    function removeWalletFromBlacklist(address wallet) public OnlyPlatform{
        blacklist[wallet] = false;
        emit WalletActivated(wallet);
    }

    function freezeWallet(address wallet) public OnlyPlatform{
        frozen[wallet] = true;
        emit WalletFrozen(wallet);
    }

    function unFreezeWallet(address wallet) public OnlyPlatform{
        frozen[wallet] = false;
        emit WalletUnFrozen(wallet);
    }

    function sendCharityFee() public OnlyPlatform{
        _transfer(address(this), charity, charityFee);
        emit CharityFeeSent(charity,charityFee);
    }

    function sendMarketingFee() public OnlyPlatform{
        _transfer(address(this), marketing, marketingFee);
        emit MarketingFeeSent(marketing, marketingFee);
    }

    function sendPlatformFee() public OnlyPlatform{
        _transfer(address(this), platform, platformFee);
        emit PlatFormFeeSent(platform, platformFee);
    }

    function sendExchangeFee() public OnlyPlatform{
        _transfer(address(this), exchange, exchangeFee);
        emit ExchangeFeeSent(exchange, exchangeFee);
    }

    function updatePayroll() public OnlyPlatform{
        currentPayroll++;
        emit PayrollUpdated(currentPayroll);
    }

    function claimHolderFee() public isEnabled{
        require(isHolder[msg.sender] && balanceOf(msg.sender) > 0, "user is not holder");
        require(!frozen[msg.sender], "frozen user");
        require(!blacklist[msg.sender], "blacklisted user");
        require(
            holderLastPayroll[msg.sender] < currentPayroll,

            "cannot claim twice"
        );
        holderLastPayroll[msg.sender] = currentPayroll;
        uint256 accountBalance = balanceOf(msg.sender);
        uint256 totalSupplyPercent = (((accountBalance*100)*(100000000000))/INITIAL_SUPPLY);
        uint256 amountToPay = ((totalSupplyPercent*holdersFee)/100) / 100000000000;
        _transfer(address(this), msg.sender, amountToPay);
        emit HolderFeeSent(msg.sender, amountToPay);
    }

    function _transfer(address sender, address recipient, uint256 amount)
        internal
        virtual
        override
        isEnabled {
        require(balanceOf(sender) >= amount, "Not enough funds");
        require(!frozen[sender], "frozen sender");
        require(!frozen[recipient], "frozen frozen recipient");
        require(!blacklist[recipient], "blacklisted recipient");
        if (blacklist[sender]) {
            require(amount <= blacklistLimit[sender], "exceed blacklisted user limit");
            require(
                blacklistSentAmount[sender] <= blacklistLimit[sender],
                "exceed blacklisted user limit"
            );
            blacklistSentAmount[sender] += amount;
        }
         if(sender == pairAddress && _isExcludedFromFee[recipient]){
            super._transfer(sender,recipient, amount);
         }else if(_isExcludedFromFee[sender] && recipient == pairAddress){
            super._transfer(sender,recipient, amount);
         }else if(_isExcludedFromFee[recipient] && _isExcludedFromFee[sender]){
            super._transfer(sender,recipient, amount);
         }else if(sender == pairAddress && !_isExcludedFromFee[recipient]){
         uint256 fee = (amount * buyingTaxFee) / 100;
        if (balanceOf(recipient) <= 0 && !isHolder[recipient]) {
            holders++;
            holdersList[holders] = recipient;
            isHolder[recipient] = true;
        }
         holdersFee += (fee * 2) / 100;
         charityFee += (fee * 5) / 100;
         marketingFee += (fee * 1) / 100;
         platformFee += (fee * 1) / 100;
         exchangeFee += (fee * 1) / 100;
         address dist = address(this);
         _transferBuyingFee(sender,recipient, amount,fee,dist);
         }else if(_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]){
           if (balanceOf(recipient) <= 0 && !isHolder[recipient]) {
            holders++;
            holdersList[holders] = recipient;
            isHolder[recipient] = true;
            }
            super._transfer(sender,recipient, amount);
         }else if(recipient == pairAddress && !_isExcludedFromFee[sender]){
        uint256 fee = (amount * sellingTaxFee) / 100;
        if (balanceOf(recipient) <= 0 && !isHolder[recipient]) {
            holders++;
            holdersList[holders] = recipient;
            isHolder[recipient] = true;
        }
        holdersFee += (fee * 4) / 100;
        charityFee += (fee * 10) / 100;
        marketingFee += (fee * 2) / 100;
        platformFee += (fee * 2) / 100;
        exchangeFee += (fee * 2) / 100;
        super._transfer(sender,recipient, amount - fee);
        super._transfer(sender, address(this), fee);
         }else if(!_isExcludedFromFee[sender] && _isExcludedFromFee[recipient]){
            if (balanceOf(recipient) <= 0 && !isHolder[recipient]) {
            holders++;
            holdersList[holders] = recipient;
            isHolder[recipient] = true;
            }
            super._transfer(sender,recipient, amount);
              if(balanceOf(sender) <= 0){
            isHolder[sender] = false; 
            }
         }else if(!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient] && sender != pairAddress && recipient != pairAddress){
        uint256 fee = (amount * sellingTaxFee) / 100;
        if (balanceOf(recipient) <= 0 && !isHolder[recipient]) {
            holders++;
            holdersList[holders] = recipient;
            isHolder[recipient] = true;
        }
        holdersFee += (fee * 4) / 100;
        charityFee += (fee * 10) / 100;
        marketingFee += (fee * 2) / 100;
        platformFee += (fee * 2) / 100;
        exchangeFee += (fee * 2) / 100;
        super._transfer(sender,recipient, amount);
        super._transfer(sender, address(this), fee);
         }
        if(balanceOf(sender) <= 0){
            isHolder[sender] = false; 
        }
   
    }

     function withdraw(uint256 amount) public {
        payable(platform).transfer(amount);
    }

    receive() external payable {}

}