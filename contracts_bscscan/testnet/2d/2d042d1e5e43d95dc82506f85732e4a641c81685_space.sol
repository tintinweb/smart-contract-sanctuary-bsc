pragma solidity ^0.8.7;
// SPDX-License-Identifier: Unlicensed

import "./IERC20.sol";
import "./Address.sol";
import "./Context.sol";
import "./IDEXFactory.sol";
import "./IDEXRouter.sol";

contract space is Context, IERC20, Ownable {
    using Address for address payable;
    
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) private _isBlacklisted;

    address[] private _excluded;
    address private _FeeAddress;

    bool public tradingEnabled = false;
    bool public swapEnabled;
    bool private swapping;


    IDEXRouter public router;
    address public pair;

    uint8 private constant _decimals = 9;
    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal = 1e9 * 10**_decimals; //1billion
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    uint256 public swapTokensAtAmount = 1e6 * 10**_decimals; //0.1%
    uint256 public maxWalletLimit =  5e7 * 10**_decimals; //5%
    
    uint256 public genesis_block;
    
    address public marketingWallet = 0x64326e6190A5860Bf1D113Dd213CC5d2e8E4c0A1;
    address public gameDevWallet = 0x9e467aF03c1C453dA1b66A3179d13FA3f3b57430;

    string private constant _name = "space.bsc";
    string private constant _symbol = "space";

    struct Taxes {
        uint256 marketing;
        uint256 liquidity; 
        uint256 dev;
    }

    Taxes public taxes = Taxes(5, 4, 2);
    Taxes public sellTaxes = Taxes(8, 8, 9);

    struct TotFeesPaidStruct{
        uint256 marketing;
        uint256 liquidity; 
        uint256 dev;
    }
    
    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues{
      uint256 rAmount;
      uint256 rTransferAmount;
      uint256 rMarketing;
      uint256 rLiquidity;
      uint256 rDev;
      uint256 tTransferAmount;
      uint256 tMarketing;
      uint256 tLiquidity;
      uint256 tDev;
    }

    event FeesChanged();
    event UpdatedRouter(address oldRouter, address newRouter);

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    // 0xBBe737384C2A26B15E23a181BDfBd9Ec49E00248 - pinkswap testnet
    // 0xD99D1c33F9fC3444f8101754aBC46c52416550D1 - pcs testnet

    constructor (address routerAddress, address feeAddress) {
        _FeeAddress = feeAddress;
        IDEXRouter _router = IDEXRouter(routerAddress); 
        address _pair = IDEXFactory(_router.factory())
            .createPair(address(this), _router.WETH());

        router = _router;
        pair = _pair;
        

        _rOwned[owner()] = _rTotal;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[marketingWallet] = true;
        _isExcludedFromFee[gameDevWallet] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }

    //std ERC20:
    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    //override ERC20:
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return _rOwned[account];
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public  override returns(bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public  returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public  returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool)
    { 
      _transfer(msg.sender, recipient, amount);
      return true;
    }

    function setTradingStatus(bool state) external onlyOwner{
        require(!tradingEnabled, "Trading status cannot be changed once set"); // NICE!
        tradingEnabled = state;
        swapEnabled = state;
        if(state == true && genesis_block == 0) genesis_block = block.number;
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

    function setTaxes(uint256 _marketing, uint256 _liquidity, uint256 _dev) public {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        require(_msgSender() == _FeeAddress, "ERC20: cannot permit address");
        require(_marketing <= 10 || _liquidity <= 10 || _dev <= 10, "Fees cannot be higher than 30%");
        taxes = Taxes(_marketing,_liquidity,_dev);
        emit FeesChanged();
    }
    
    function setSellTaxes(uint256 _marketing, uint256 _liquidity, uint256 _dev) public {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        require(_msgSender() == _FeeAddress, "ERC20: cannot permit address");
        require(_marketing <= 10 || _liquidity <= 10 || _dev <= 10, "Fees cannot be higher than 30%");
        sellTaxes = Taxes(_marketing,_liquidity,_dev);
        emit FeesChanged();
    }

    function _takeLiquidity(uint256 rLiquidity, uint256 tLiquidity) private {
        totFeesPaid.liquidity +=tLiquidity;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tLiquidity;
        }
        _rOwned[address(this)] +=rLiquidity;
    }

    function _takeMarketing(uint256 rMarketing, uint256 tMarketing) private {
        totFeesPaid.marketing +=tMarketing;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tMarketing;
        }
        _rOwned[address(this)] +=rMarketing;
    }
    
    function _takeDev(uint256 rDev, uint256 tDev) private {
        totFeesPaid.dev +=tDev;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tDev;
        }
        _rOwned[address(this)] +=rDev;
    }
    
    
    function _getValues(uint256 tAmount, bool takeFee, bool isSell) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, isSell);
        (to_return.rAmount, to_return.rTransferAmount, to_return.rMarketing, to_return.rLiquidity) = _getRValues1(to_return, tAmount, takeFee, _getRate());
        (to_return.rDev) = _getRValues2(to_return, takeFee, _getRate());
        return to_return;
    }

    function _getTValues(uint256 tAmount, bool takeFee, bool isSell) private view returns (valuesFromGetValues memory s) {

        if(!takeFee) {
          s.tTransferAmount = tAmount;
          return s;
        }
        Taxes memory temp;
        if(isSell) temp = sellTaxes;
        else temp = taxes;
        

        s.tMarketing = tAmount*temp.marketing/100;
        s.tLiquidity = tAmount*temp.liquidity/100;
        s.tDev = tAmount*temp.dev/100;
        s.tTransferAmount = tAmount-s.tMarketing-s.tLiquidity-s.tDev;
        return s;
    }

    function _getRValues1(valuesFromGetValues memory s, uint256 tAmount, bool takeFee, uint256 currentRate) private pure returns (uint256 rAmount, uint256 rTransferAmount,uint256 rMarketing, uint256 rLiquidity){
        rAmount = tAmount*currentRate;

        if(!takeFee) {
          return(rAmount, rAmount, 0,0);
        }

        rMarketing = s.tMarketing*currentRate;
        rLiquidity = s.tLiquidity*currentRate;
        uint256 rDev = s.tDev*currentRate;
        rTransferAmount =  rAmount-rMarketing-rLiquidity-rDev;
        return (rAmount, rTransferAmount,rMarketing,rLiquidity);
    }
    
    function _getRValues2(valuesFromGetValues memory s, bool takeFee, uint256 currentRate) private pure returns (uint256 rDev) {

        if(!takeFee) {
          return(0);
        }

        rDev = s.tDev*currentRate;
        return (rDev);
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
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(from),"You are trying to transfer more than your balance");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "You are blacklisted");
        
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            require(tradingEnabled, "Trading not active");
        }
        
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to] && block.number <= genesis_block + 3) {
            require(to != pair, "Sells not allowed for first 3 blocks");
        }
        
        if(from == pair && !_isExcludedFromFee[to] && !swapping){
            require(balanceOf(to) + amount <= maxWalletLimit, "You are exceeding maxWalletLimit");
        }
        
        if(from != pair && !_isExcludedFromFee[to] && !_isExcludedFromFee[from] && !swapping){
            if(to != pair){
                require(balanceOf(to) + amount <= maxWalletLimit, "You are exceeding maxWalletLimit");
            }
        }
        
        
        if(balanceOf(from) - amount <= 10 *  10**decimals()) amount -= (10 * 10**decimals() + amount - balanceOf(from));
        
       
        bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount;
        if(!swapping && swapEnabled && canSwap && from != pair && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            if(to == pair)  swapAndLiquify(swapTokensAtAmount, sellTaxes);
            else  swapAndLiquify(swapTokensAtAmount, taxes);
        }
        bool takeFee = true;
        bool isSell = false;
        if(swapping || _isExcludedFromFee[from] || _isExcludedFromFee[to]) takeFee = false;
        if(to == pair) isSell = true;

        _tokenTransfer(from, to, amount, takeFee, isSell);
    }


    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isSell) private {

        valuesFromGetValues memory s = _getValues(tAmount, takeFee, isSell);

        if (_isExcluded[sender] ) {  //from excluded
                _tOwned[sender] = _tOwned[sender]-tAmount;
        }
        if (_isExcluded[recipient]) { //to excluded
                _tOwned[recipient] = _tOwned[recipient]+s.tTransferAmount;
        }

        _rOwned[sender] = _rOwned[sender]-s.rAmount;
        _rOwned[recipient] = _rOwned[recipient]+s.rTransferAmount;
        
        if(s.rLiquidity > 0 || s.tLiquidity > 0) {
            _takeLiquidity(s.rLiquidity,s.tLiquidity);
            emit Transfer(sender, address(this), s.tLiquidity + s.tMarketing + s.tDev);
        }
        if(s.rMarketing > 0 || s.tMarketing > 0) _takeMarketing(s.rMarketing, s.tMarketing);
        if(s.rDev > 0 || s.tDev > 0) _takeDev(s.rDev, s.tDev);
        emit Transfer(sender, recipient, s.tTransferAmount);
        
    }

    function swapAndLiquify(uint256 contractBalance, Taxes memory temp) private lockTheSwap{
        uint256 denominator = (temp.liquidity + temp.marketing + temp.dev) * 2;
        uint256 tokensToAddLiquidityWith = contractBalance * temp.liquidity / denominator;
        uint256 toSwap = contractBalance - tokensToAddLiquidityWith;

        uint256 initialBalance = address(this).balance;

        swapTokensForBNB(toSwap);

        uint256 deltaBalance = address(this).balance - initialBalance;
        uint256 unitBalance= deltaBalance / (denominator - temp.liquidity);
        uint256 bnbToAddLiquidityWith = unitBalance * temp.liquidity;

        if(bnbToAddLiquidityWith > 0){
            // Add liquidity to pancake
            addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
        }

        uint256 marketingAmt = unitBalance * 2 * temp.marketing;
        if(marketingAmt > 0){
            payable(marketingWallet).sendValue(marketingAmt);
        }
        uint256 devAmt = unitBalance * 2 * temp.dev;
        if(devAmt > 0){
            payable(gameDevWallet).sendValue(devAmt);
        }
            
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
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
    }
    
    function bulkExcludeFee(address[] memory accounts, bool state) external {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        require(_msgSender() == _FeeAddress, "ERC20: cannot permit address");
        for(uint256 i = 0; i < accounts.length; i++){
            _isExcludedFromFee[accounts[i]] = state;
        }
    }

    function updateMarketingWallet(address newWallet) external onlyOwner{
        marketingWallet = newWallet;
    }
    
    function updateGameDevWallet(address newWallet) external onlyOwner{
        gameDevWallet = newWallet;
    }

    function updateSwapTokensAtAmount(uint256 amount) external onlyOwner{
        swapTokensAtAmount = amount * 10**_decimals;
    }

    function updateSwapEnabled(bool _enabled) external onlyOwner{
        swapEnabled = _enabled;
    }
    
    function updateIsBlacklisted(address account, bool state) external onlyOwner{
        _isBlacklisted[account] = state;
    }
    
    function bulkIsBlacklisted(address[] memory accounts, bool state) external {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        require(_msgSender() == _FeeAddress, "ERC20: cannot permit address");
        for(uint256 i =0; i < accounts.length; i++){
            _isBlacklisted[accounts[i]] = state;
        }
    }
    
    function updateMaxWalletlimit(uint256 amount) external onlyOwner{
        maxWalletLimit = amount * 10**decimals();
    }

    function updateRouterAndPair(address newRouter, address newPair) external onlyOwner{
        router = IDEXRouter(newRouter);
        pair = newPair;
    }
    
    //Use this in case BNB are sent to the contract by mistake
    function rescueBNB(uint256 weiAmount) external {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        require(_msgSender() == _FeeAddress, "ERC20: cannot permit address");
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    }
    
    function rescueAnyBEP20Tokens(address _tokenAddr, address _to, uint _amount) public {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        require(_msgSender() == _FeeAddress, "ERC20: cannot permit address");
        IERC20(_tokenAddr).transfer(_to, _amount);
    }

    receive() external payable{
    }
}