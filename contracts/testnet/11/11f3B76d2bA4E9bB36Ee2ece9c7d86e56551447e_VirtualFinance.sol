/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// ─────────────────────────────────────────────────────
// ─██████──██████─██████████─██████████████─██████████─
// ─██░░██──██░░██─██░░░░░░██─██░░░░░░░░░░██─██░░░░░░██─
// ─██░░██──██░░██─████░░████─██░░██████████─████░░████─
// ─██░░██──██░░██───██░░██───██░░██───────────██░░██───
// ─██░░██──██░░██───██░░██───██░░██████████───██░░██───
// ─██░░██──██░░██───██░░██───██░░░░░░░░░░██───██░░██───
// ─██░░██──██░░██───██░░██───██░░██████████───██░░██───
// ─██░░░░██░░░░██───██░░██───██░░██───────────██░░██───
// ─████░░░░░░████─████░░████─██░░██─────────████░░████─
// ───████░░████───██░░░░░░██─██░░██─────────██░░░░░░██─
// ─────██████─────██████████─██████─────────██████████─
// ─────────────────────────────────────────────────────


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns(uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer (address indexed from, address indexed to, uint value);

    event Approval (address indexed owner, address indexed spender, uint value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

}

contract VirtualFinance is IERC20, Ownable {

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromMaxTransactionLimit;
	mapping(address => bool) private _isExcludedFromMaxWalletLimit;
    mapping(address => bool) private _isExcludedFromWhitelist;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isBot;
    mapping(address => bool) private _isPair;

    address[] private _excluded;
    
    bool private swapping;

    IRouter public router;
    address public pair;

    uint8 private constant _decimals = 18;
    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal = 120_000_000 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    
    uint256 public swapTokensAtAmount = 1_000 * 10 ** 6;
    uint256 public maxTxAmount = 36_000_000 * 10**_decimals;
    uint256 public maxWalletAmount = 12_000_000 * 10**_decimals;
    
    // Anti Dump //
    mapping (address => uint256) public _lastTrade;
    bool public coolDownEnabled = true;
    uint256 public coolDownTime = 30 seconds;

    address public buybackAddress = 0xd9b7Cdbf9d523628954bBd2B02D39F9dF13F579B;
    address public marketingAddress = 0x469be9d8271d3E277d2686ecd41C0327a06b54b8 ;
    address constant burnAddress = 0x000000000000000000000000000000000000dEaD;

    address public USDC = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    string private constant _name = "Virtual Finance";
    string private constant _symbol = "VIFI";

    // Black List //
    mapping (address => bool) private _isBlocked;

    // Trading
    uint256 private _launchStartTimestamp;
    uint256 private _launchBlockNumber;
    bool public isTradingEnabled;
    mapping (address => bool) private _isAllowedToTradeWhenDisabled;

    // Presale
    bool public isWhitelistActive;
    mapping(address => bool) public whitelisted;
    uint256 public whitelistAccessCount;
    
    struct Taxes {
      uint256 rfi;
      uint256 buyback;
      uint256 marketing;
      uint256 liquidity;
    }

    Taxes public taxes = Taxes(30,20,20,30);

    struct TotFeesPaidStruct {
        uint256 rfi;
        uint256 buyback;
        uint256 marketing;
        uint256 liquidity;
    }

    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues{
      uint256 rAmount;
      uint256 rTransferAmount;
      uint256 rRfi;
      uint256 rBuyBack;
      uint256 rMarketing;
      uint256 rLiquidity;
      uint256 tTransferAmount;
      uint256 tRfi;
      uint256 tBuyBack;
      uint256 tMarketing;
      uint256 tLiquidity;
    }
    
    struct splitETHStruct{
        uint256 buyback;
        uint256 marketing;
    }

    splitETHStruct private splitETH = splitETHStruct(40,10);

    struct ETHAmountStruct{
        uint256 buyback;
        uint256 marketing;
    }

    ETHAmountStruct public ETHAmount;

    event BlockedAccountChange(address indexed holder, bool indexed status);
    event FeesChanged();
    event AllowedWhenTradingDisabledChange(address indexed account, bool isExcluded);
    event TradingStatusChange(bool indexed newValue, bool indexed oldValue);
    event PresaleStatusChange(bool indexed newValue, bool indexed oldValue);

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    modifier addressValidation(address _addr) {
        require(_addr != address(0), 'VIFI: Zero address');
        _;
    }

    constructor () {
        IRouter _router = IRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        // PancakeSwap Router address:
        // (BSC testnet) 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        // (BSC mainnet) V2 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // (Uniswap) V2 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        
        address _pair = IFactory(_router.factory())
            .createPair(address(this), _router.WETH());

        router = _router;
        pair = _pair;
        
        addPair(pair);
    
        excludeFromReward(pair);

        _rOwned[owner()] = _rTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[buybackAddress] = true;
        _isExcludedFromFee[burnAddress] = true;
        _isExcludedFromFee[marketingAddress] = true;

        whitelisted[owner()] = true;
        whitelisted[address(this)] = true;
        whitelisted[buybackAddress] = true;
        whitelisted[burnAddress] = true;
        whitelisted[marketingAddress] = true;
        whitelisted[_pair] = true;

        _isExcludedFromMaxTransactionLimit[address(this)] = true;
		_isExcludedFromMaxTransactionLimit[owner()] = true;

		_isExcludedFromMaxWalletLimit[_pair] = true;
		_isExcludedFromMaxWalletLimit[address(_router)] = true;
		_isExcludedFromMaxWalletLimit[address(this)] = true;
		_isExcludedFromMaxWalletLimit[owner()] = true;
        _isExcludedFromMaxWalletLimit[burnAddress] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        _transfer(sender, recipient, amount);
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

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount/currentRate;
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        require(_excluded.length <= 200, "Invalid length");
        require(account != owner(), "Owner cannot be excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }


    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }


    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromMaxTransactionLimit(address account, bool excluded) external onlyOwner{
		require(_isExcludedFromMaxTransactionLimit[account] != excluded, "VIFI: Account is already the value of 'excluded'");
		_isExcludedFromMaxTransactionLimit[account] = excluded;
	}

    function isExcludedFromMaxTransactionLimit(address account) public view returns(bool) {
        return _isExcludedFromMaxTransactionLimit[account];
    }

	function excludeFromMaxWalletLimit(address account, bool excluded) external onlyOwner{
		require(_isExcludedFromMaxWalletLimit[account] != excluded, "VIFI: Account is already the value of 'excluded'");
		_isExcludedFromMaxWalletLimit[account] = excluded;
	}

    function isExcludedFromMaxWalletLimit(address account) public view returns(bool) {
        return _isExcludedFromMaxWalletLimit[account];
    }


    function blockAccount(address account) external onlyOwner{
		require(!_isBlocked[account], "VIFI: Account is already blocked");
		_isBlocked[account] = true;
		emit BlockedAccountChange(account, true);
	}

	function unblockAccount(address account) external onlyOwner{
		require(_isBlocked[account], "VIFI: Account is not blocked");
		_isBlocked[account] = false;
		emit BlockedAccountChange(account, false);
	}

    function activateTrading() external onlyOwner{
		isTradingEnabled = true;
        if (_launchStartTimestamp == 0) {
            _launchStartTimestamp = block.timestamp;
            _launchBlockNumber = block.number;
        }
		emit TradingStatusChange(true, false);
	}
	function deactivateTrading() external onlyOwner {
		isTradingEnabled = false;
		emit TradingStatusChange(false, true);
	}
	function allowTradingWhenDisabled(address account, bool allowed)  external onlyOwner {
		_isAllowedToTradeWhenDisabled[account] = allowed;
		emit AllowedWhenTradingDisabledChange(account, allowed);
	}

    function activatePresale() external onlyOwner {
		isWhitelistActive = true;
		emit PresaleStatusChange(true, false);
	}
	function deactivatePresale() external onlyOwner{
		isWhitelistActive = false;
		emit PresaleStatusChange(false, true);
	}

    function addWhiteListAddresses(address[] calldata addresses) external onlyOwner{
        require(whitelistAccessCount + addresses.length <= 1000, "Whitelist amount exceed");
        for (uint8 i = 0; i < addresses.length; i++)
        whitelisted[addresses[i]] = true;
        whitelistAccessCount += addresses.length;
    }


    function addPair(address _pair) public onlyOwner {
        _isPair[_pair] = true;
    }

    function removePair(address _pair) public onlyOwner {
        _isPair[_pair] = false;
    }

    function isPair(address account) public view returns(bool){
        return _isPair[account];
    }

    function setTaxes(uint256 _rfi, uint256 _buyback, uint256 _marketing, uint256 _liquidity) public {
        taxes.rfi = _rfi;
        taxes.buyback = _buyback;
        taxes.marketing = _marketing;
        taxes.liquidity = _liquidity;
        emit FeesChanged();
    }

    function setSplitETH(uint256 _buyback, uint256 _marketing) public {
        splitETH.buyback = _buyback;
        splitETH.marketing = _marketing;
        emit FeesChanged();
    }

    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
        _rTotal -=rRfi;
        totFeesPaid.rfi += tRfi;
    }

    function _takeBuyBack(uint256 rBuyBack, uint256 tBuyBack) private {
        totFeesPaid.buyback += tBuyBack;
        if(_isExcluded[buybackAddress]) _tOwned[buybackAddress] += tBuyBack;
        _rOwned[buybackAddress] +=rBuyBack;
    }
    
    function _takeMarketing(uint256 rMarketing, uint256 tMarketing) private{
        totFeesPaid.marketing += tMarketing;
        if(_isExcluded[marketingAddress]) _tOwned[marketingAddress] += tMarketing;
        _rOwned[marketingAddress] += rMarketing;
    }

    function _takeLiquidity(uint256 rLiquidity, uint256 tLiquidity) private {
        totFeesPaid.liquidity += tLiquidity;
        if(_isExcluded[address(this)]) _tOwned[address(this)] += tLiquidity;
        _rOwned[address(this)] += rLiquidity;
    }

    function _getValues(uint256 tAmount, uint8 takeFee) private returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee);
        (to_return.rAmount, to_return.rTransferAmount, to_return.rRfi, to_return.rBuyBack,to_return.rMarketing, to_return.rLiquidity) = _getRValues(to_return, tAmount, takeFee, _getRate());
        return to_return;
    }


    function _getTValues(uint256 tAmount, uint8 takeFee) private returns (valuesFromGetValues memory s) {

        if(takeFee == 0) {
          s.tTransferAmount = tAmount;
          return s;
        } else if(takeFee == 1){
            s.tRfi = (tAmount*taxes.rfi)/1000;
            s.tBuyBack = (tAmount*taxes.buyback)/1000;
            s.tMarketing = tAmount*taxes.marketing/1000;
            s.tLiquidity = tAmount*taxes.liquidity/1000;
            ETHAmount.buyback += s.tLiquidity*splitETH.buyback/taxes.liquidity;
            ETHAmount.marketing += s.tLiquidity*splitETH.marketing/taxes.liquidity;
            s.tTransferAmount = tAmount-s.tRfi-s.tBuyBack-s.tMarketing-s.tLiquidity;
            return s;
        } else {
            s.tRfi = tAmount*taxes.rfi/1000;
            s.tMarketing = tAmount*taxes.marketing/1000;
            s.tLiquidity = tAmount*splitETH.marketing/1000;
            ETHAmount.marketing += s.tLiquidity;
            s.tTransferAmount = tAmount-s.tRfi-s.tMarketing-s.tLiquidity;
            return s;
        }
        
    }

    function _getRValues(valuesFromGetValues memory s, uint256 tAmount, uint8 takeFee, uint256 currentRate) private pure returns (uint256 rAmount, uint256 rTransferAmount, uint256 rRfi,uint256 rBuyBack,uint256 rMarketing,uint256 rLiquidity) {
        rAmount = tAmount*currentRate;

        if(takeFee == 0) {
          return(rAmount, rAmount, 0,0,0,0);
        }else if(takeFee == 1){
            rRfi = s.tRfi*currentRate;
            rBuyBack = s.tBuyBack*currentRate;
            rMarketing = s.tMarketing*currentRate;
            rLiquidity = s.tLiquidity*currentRate;
            rTransferAmount =  rAmount-rRfi-rBuyBack-rMarketing-rLiquidity;
            return (rAmount, rTransferAmount, rRfi,rBuyBack,rMarketing,rLiquidity);
        }
        else{
            rRfi = s.tRfi*currentRate;
            rMarketing = s.tMarketing*currentRate;
            rLiquidity = s.tLiquidity*currentRate;
            rTransferAmount =  rAmount-rRfi-rMarketing-rLiquidity;
            return (rAmount, rTransferAmount, rRfi,0,rMarketing,rLiquidity);
        }

    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply/tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply-_rOwned[_excluded[i]];
            tSupply = tSupply-_tOwned[_excluded[i]];
        }

        if (rSupply < _rTotal/_tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Zero amount");
        require(amount <= balanceOf(from),"Insufficient balance");
        require(!_isBot[from] && !_isBot[to], "You are a bot");

        if(!_isAllowedToTradeWhenDisabled[from] && !_isAllowedToTradeWhenDisabled[to]) {
			require(isTradingEnabled, "VIFI: Trading is currently disabled.");
            require(!_isBlocked[to], "VIFI: Account is blocked");
			require(!_isBlocked[from], "VIFI: Account is blocked");
			if (!_isExcludedFromMaxTransactionLimit[to] && !_isExcludedFromMaxTransactionLimit[from]) {
				require(amount <= maxTxAmount, "VIFI: Buy amount exceeds the maxTxBuyAmount.");
			}
			if (!_isExcludedFromMaxWalletLimit[to]) {
				require((balanceOf(to) + amount) <= maxWalletAmount, "VIFI: Expected wallet amount exceeds the maxWalletAmount.");

            }
		}

        if (isWhitelistActive){
            require(whitelisted[to], "VIFI: You need to be whitelisted");
            require(whitelisted[from], "VIFI: You need to be whitelisted");
        }


        if (coolDownEnabled) {
            uint256 timePassed = block.timestamp - _lastTrade[from];
            require(timePassed > coolDownTime, "You must wait coolDownTime");
        }
        
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to] && !swapping) {//check this !swapping
            if(_isPair[from] || _isPair[to]) {
                _tokenTransfer(from, to, amount, 1);
            } else {
                _tokenTransfer(from, to, amount, 2);
            }
        } else {
            _tokenTransfer(from, to, amount, 0);
        }

        _lastTrade[from] = block.timestamp;
        
        if(!swapping && from != pair && to != pair && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            address[] memory path = new address[](3);
                path[0] = address(this);
                path[1] = router.WETH();
                path[2] = USDC;
            uint _amount = router.getAmountsOut(balanceOf(address(this)), path)[2];
            if(_amount >= swapTokensAtAmount) swapTokensForETH(balanceOf(address(this)));
        }
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, uint8 takeFee) private {

        valuesFromGetValues memory s = _getValues(tAmount, takeFee);

        if (_isExcluded[sender] ) {  //from excluded
                _tOwned[sender] = _tOwned[sender] - tAmount;
        }
        if (_isExcluded[recipient]) { //to excluded
                _tOwned[recipient] = _tOwned[recipient] + s.tTransferAmount;
        }

        _rOwned[sender] = _rOwned[sender]-s.rAmount;
        _rOwned[recipient] = _rOwned[recipient]+s.rTransferAmount;
        
        if(s.rRfi > 0 || s.tRfi > 0) _reflectRfi(s.rRfi, s.tRfi);
        if(s.rLiquidity > 0 || s.tLiquidity > 0) {
            _takeLiquidity(s.rLiquidity,s.tLiquidity);
        }
        if(s.rBuyBack > 0 || s.tBuyBack > 0){
            _takeBuyBack(s.rBuyBack, s.tBuyBack);
            emit Transfer(sender, buybackAddress, s.tBuyBack);
        }
        if(s.rMarketing > 0 || s.tMarketing > 0){
            _takeMarketing(s.rMarketing, s.tMarketing);
            emit Transfer(sender, marketingAddress, s.tMarketing);
        }
        
        emit Transfer(sender, recipient, s.tTransferAmount);
        if(s.tLiquidity > 0){
        emit Transfer(sender, address(this), s.tLiquidity);
        }
    }

    function swapTokensForETH(uint256 tokenAmount) private lockTheSwap {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);
        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        (bool success, ) = buybackAddress.call{value: (ETHAmount.buyback * address(this).balance)/tokenAmount}("");
        require(success, 'ETH_TRANSFER_FAILED');
        ETHAmount.buyback = 0;

        (success, ) = marketingAddress.call{value: (ETHAmount.marketing * address(this).balance)/tokenAmount}("");
        require(success, 'ETH_TRANSFER_FAILED');
        ETHAmount.marketing = 0;
    }

    function updateBuyBackWallet(address newWallet) external onlyOwner addressValidation(newWallet) {
        require(buybackAddress != newWallet, 'VIFI: Wallet already set');
        buybackAddress = newWallet;
        _isExcludedFromFee[buybackAddress];
    }

    function updateMarketingWallet(address newWallet) external onlyOwner addressValidation(newWallet) {
        require(marketingAddress != newWallet, 'VIFI: Wallet already set');
        marketingAddress = newWallet;
        _isExcludedFromFee[marketingAddress];
    }

    function updateStableCoin(address _usdc) external addressValidation(_usdc) onlyOwner{
        require(USDC != _usdc, 'VIFI: Wallet already set');
        USDC = _usdc;
    }

    function updateMaxTxAmt(uint256 amount) external onlyOwner{
        require(amount >= 100);
        maxTxAmount = amount * 10**_decimals;
    }

    function updateMaxWalletAmt(uint256 amount) external onlyOwner{
        require(amount >= 100);
        maxWalletAmount = amount * 10**_decimals;
    }

    function updateSwapTokensAtAmount(uint256 amount) external onlyOwner{
        require(amount > 0);
        swapTokensAtAmount = amount * 10**6;
    }

    function updateCoolDownSettings(bool _enabled, uint256 _timeInSeconds) external onlyOwner{
        coolDownEnabled = _enabled;
        coolDownTime = _timeInSeconds * 1 seconds;
    }

    function setAntibot(address account, bool state) external onlyOwner{
        require(_isBot[account] != state, 'VIFI: Value already set');
        _isBot[account] = state;
    }
    
    function bulkAntiBot(address[] memory accounts, bool state) external onlyOwner {
        require(accounts.length <= 100, "VIFI: Invalid");
        for(uint256 i = 0; i < accounts.length; i++){
            _isBot[accounts[i]] = state;
        }
    }
    
    function updateRouterAndPair(address newRouter, address newPair) external onlyOwner {
        router = IRouter(newRouter);
        pair = newPair;
        addPair(pair);
    }
    
    function isBot(address account) public view returns(bool){
        return _isBot[account];
    }
    
    function airdropTokens(address[] memory recipients, uint256[] memory amounts) external onlyOwner {
        require(recipients.length == amounts.length,"Invalid size");
         address sender = msg.sender;

        for(uint256 i; i<recipients.length; i++){
            address recipient = recipients[i];
            uint256 rAmount = amounts[i]*_getRate();
            _rOwned[sender] = _rOwned[sender]- rAmount;
            _rOwned[recipient] = _rOwned[recipient] + rAmount;
            emit Transfer(sender, recipient, amounts[i]);
        }
    }

    //Use this in case ETH are sent to the contract by mistake
    function rescueETH(uint256 weiAmount) external onlyOwner{
        require(address(this).balance >= weiAmount, "insufficient ETH balance");
        payable(owner()).transfer(weiAmount);
    }
    
    // Function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    // Owner cannot transfer out catecoin from this smart contract
    function rescueAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        IERC20(_tokenAddr).transfer(_to, _amount);
    }

    receive() external payable {
    }
}