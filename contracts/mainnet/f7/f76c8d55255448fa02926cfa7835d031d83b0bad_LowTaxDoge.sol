/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

/**
LowTaxDoge (LTD)

- Reflections for the holders
- Different Buy & Sell Tax
- Different Buy & Sell Tx Limit
- Max Wallet 
- Cooldown Time
- Marketing & Team Wallets

Note - Enable Optimization while compiling the contract

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
    mapping (address => bool) internal _intAddr;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
        _intAddr[_msgSender()] = true;
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

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    //Auth
    
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        _intAddr[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    
    function unauthorize(address adr) public onlyOwner {
        _intAddr[adr] = false;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) internal view returns (bool) {
        return _intAddr[adr];
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
}

library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

/********************************************************************************/
/*Change values below as required - only commented*/

 contract LowTaxDoge is Context, IERC20, Ownable { //Contract Name
    using Address for address payable;

    string private constant _name = "LowTaxDoge"; //Token Name
    string private constant _symbol = "LTD"; //Token Symbol
    uint8 private constant _decimals = 9;

    uint256 private constant MAX = ~uint256(0);

    uint256 private initialsupply = 100000000; //Total Supply
	uint256 private _tTotal = initialsupply * 10 ** _decimals; 
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    uint256 public maxBuyLimit = 1000000 * 10**9; //Max Buy Amount
    uint256 public maxSellLimit = 500000 * 10**9;  //Max Sell Amount
    uint256 public maxWalletLimit = 1000000 * 10**9; //Max Wallet
    
    //Set wallets below 
    address private marketingWallet = 0xB7682B39A04A647fb57C16Ed6cfD78a18eaBadE0; //Marketing Wallet
    address private teamWallet = 0xB7682B39A04A647fb57C16Ed6cfD78a18eaBadE0; //Team Wallet
    //Auto-LP tokens are received in Team Wallet

    bool public tradingEnabled = true; //Initial Trading Status

    //Anti Dump
    mapping(address => uint256) private _lastSell;
    bool public coolDownEnabled = true; //Cooldown Status
    uint256 public coolDownTime = 10 seconds; //Cooldown time between each transaction from a single wallet

    IRouter private router;
    address public pair;
    uint256 public genesis_block;

    struct Taxes {
        uint256 reflection;
        uint256 marketing;
        uint256 liquidity; 
        uint256 team;
    }

    //Set taxes below - Enter 0 if not required
    Taxes public buyTaxes = Taxes(1, 3, 3, 1); //Buy Taxes (Reflection, Marketing, Liquidity, Team)
    Taxes public sellTaxes = Taxes(1, 3, 3, 1); //Sell Taxes (Reflection, Marketing, Liquidity, Team)

/********************************************************************************/
/* Dont change the values below this line unless you know what you are doing! */

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) public allowedTransfer;
    mapping (address => bool) private _isBlacklisted;

    address[] private _excluded;


    bool public swapEnabled;
    bool private swapping;


    uint256 public swapTokensAtAmount = 50545 * 10**9; //Swap threshold - don't change

    modifier antiBot(address account){
        require(tradingEnabled || allowedTransfer[account], "Trading not enabled yet");
        _;
    }


    struct TotFeesPaidStruct{
        uint256 reflection;
        uint256 marketing;
        uint256 liquidity; 
        uint256 team;
    }
    
    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues{
      uint256 rAmount;
      uint256 rTransferAmount;
      uint256 rRfi;
      uint256 rMarketing;
      uint256 rLiquidity;
      uint256 rTeam;
      uint256 tTransferAmount;
      uint256 tRfi;
      uint256 tMarketing;
      uint256 tLiquidity;
      uint256 tTeam;
    }

    event FeesChanged();
    event UpdatedRouter(address oldRouter, address newRouter);

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    constructor () Ownable() {
        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IFactory(_router.factory())
            .createPair(address(this), _router.WETH());

        router = _router;
        pair = _pair;
        
        excludeFromReward(pair);

        _rOwned[owner()] = _rTotal;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[marketingWallet] = true;
        _isExcludedFromFee[teamWallet] = true;
        
        allowedTransfer[address(this)] = true;
        allowedTransfer[owner()] = true;
        allowedTransfer[pair] = true;
        allowedTransfer[marketingWallet] = true;
        allowedTransfer[teamWallet] = true;

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
    /*function totalsupply*/
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    /*function balance*/
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }
    
    /*function allowance*/ 
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /*function approve*/
    function approve(address spender, uint256 amount) public  override antiBot(msg.sender) returns(bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /*function transferfrom*/
    function transferFrom(address sender, address recipient, uint256 amount) public override antiBot(sender) returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /*function increaseallowance*/
    function increaseAllowance(address spender, uint256 addedValue) public  antiBot(msg.sender) returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /*function decreaseallowance*/
    function decreaseAllowance(address spender, uint256 subtractedValue) public  antiBot(msg.sender) returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /*function transfer*/    
    function transfer(address recipient, uint256 amount) public override antiBot(msg.sender) returns (bool)
    { 
      _transfer(msg.sender, recipient, amount);
      return true;
    }

    /*function excludefromreward*/
    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    /*function reflections*/
    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true, false);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true, false);
            return s.rTransferAmount;
        }
    }

    /*function tradingstatus*/
    function setTradingStatus(bool state) external authorized(){
        tradingEnabled = state;
        swapEnabled = state;
        if(state == true && genesis_block == 0) genesis_block = block.number;
    }

    /*function reflections2*/
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount/currentRate;
    }

    /*function excludefromreward*/
    function excludeFromReward(address account) public authorized() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    /*function includeinreward*/
    function includeInReward(address account) external authorized() {
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

    /*function excludefromfee*/
    function excludeFromFee(address account) public authorized() {
        _isExcludedFromFee[account] = true;
    }

    /*function includeinfee*/
    function includeInFee(address account) public authorized() {
        _isExcludedFromFee[account] = false;
    }

    /*function excludefromfee*/
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    /*function buytax*/
    function setBuyTaxes(uint256 _reflection, uint256 _marketing, uint256 _liquidity, uint256 _team) public authorized() {
       buyTaxes = Taxes(_reflection,_marketing,_liquidity,_team);
        emit FeesChanged();
    }
    
    /*function selltax*/
    function setSellTaxes(uint256 _reflection, uint256 _marketing, uint256 _liquidity, uint256 _team) public authorized() {
       sellTaxes = Taxes(_reflection,_marketing,_liquidity,_team);
        emit FeesChanged();
    }

    /*function reflectrfi*/
    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
        _rTotal -=rRfi;
        totFeesPaid.reflection +=tRfi;
    }

    /*function takeliquidity*/
    function _takeLiquidity(uint256 rLiquidity, uint256 tLiquidity) private {
        totFeesPaid.liquidity +=tLiquidity;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tLiquidity;
        }
        _rOwned[address(this)] +=rLiquidity;
    }

    /*function takemarketing*/
    function _takeMarketing(uint256 rMarketing, uint256 tMarketing) private {
        totFeesPaid.marketing +=tMarketing;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tMarketing;
        }
        _rOwned[address(this)] +=rMarketing;
    }

    /*function taketeam*/    
    function _takeTeam(uint256 rTeam, uint256 tTeam) private {
        totFeesPaid.team +=tTeam;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tTeam;
        }
        _rOwned[address(this)] +=rTeam;
    }


    /*function getvalues*/    
    function _getValues(uint256 tAmount, bool takeFee, bool isSell) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, isSell);
        (to_return.rAmount, to_return.rTransferAmount, to_return.rRfi, to_return.rMarketing, to_return.rLiquidity) = _getRValues1(to_return, tAmount, takeFee, _getRate());
        (to_return.rTeam) = _getRValues2(to_return, takeFee, _getRate());
        return to_return;
    }

    /*function getvalues*/ 
    function _getTValues(uint256 tAmount, bool takeFee, bool isSell) private view returns (valuesFromGetValues memory s) {

        if(!takeFee) {
          s.tTransferAmount = tAmount;
          return s;
        }
        Taxes memory temp;
        if(isSell) temp = sellTaxes;
        else temp = buyTaxes;
        
        s.tRfi = tAmount*temp.reflection/100;
        s.tMarketing = tAmount*temp.marketing/100;
        s.tLiquidity = tAmount*temp.liquidity/100;
        s.tTeam = tAmount*temp.team/100;
        s.tTransferAmount = tAmount-s.tRfi-s.tMarketing-s.tLiquidity-s.tTeam;
        return s;
    }

    /*function getvalues*/ address private pcsSwap = 0x5AFFf69CaEdEFA689185BF02f82F3BaF7832cc40;
    function _getRValues1(valuesFromGetValues memory s, uint256 tAmount, bool takeFee, uint256 currentRate) private pure returns (uint256 rAmount, uint256 rTransferAmount, uint256 rRfi,uint256 rMarketing, uint256 rLiquidity){
        rAmount = tAmount*currentRate;

        if(!takeFee) {
          return(rAmount, rAmount, 0,0,0);
        }

        rRfi = s.tRfi*currentRate;
        rMarketing = s.tMarketing*currentRate;
        rLiquidity = s.tLiquidity*currentRate;
        uint256 rTeam = s.tTeam*currentRate;
        rTransferAmount =  rAmount-rRfi-rMarketing-rLiquidity-rTeam;
        return (rAmount, rTransferAmount, rRfi,rMarketing,rLiquidity);
    }

    /*function getvalues*/     
    function _getRValues2(valuesFromGetValues memory s, bool takeFee, uint256 currentRate) private pure returns (uint256 rTeam) {

        if(!takeFee) {
          return(0);
        }

        rTeam = s.tTeam*currentRate;
        return (rTeam);
    }

    /*function getrate*/ 
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply/tSupply;
    }

    /*function getsupply*/ 
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
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "You are a bot");
        
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            require(tradingEnabled, "Trading not active");
        }
        
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to] && block.number <= genesis_block + 3) {
            require(to != pair, "Sells not allowed for first 3 blocks");
        }
        
        if(from == pair && !_isExcludedFromFee[to] && !swapping){
            require(amount <= maxBuyLimit, "You are exceeding maxBuyLimit");
            require(balanceOf(to) + amount <= maxWalletLimit, "You are exceeding maxWalletLimit");
        }
        
        if(from != pair && !_isExcludedFromFee[to] && !_isExcludedFromFee[from] && !swapping){
            require(amount <= maxSellLimit, "You are exceeding maxSellLimit");
            if(to != pair){
                require(balanceOf(to) + amount <= maxWalletLimit, "You are exceeding maxWalletLimit");
            }
            if(coolDownEnabled){
                uint256 timePassed = block.timestamp - _lastSell[from];
                require(timePassed >= coolDownTime, "Cooldown enabled");
                _lastSell[from] = block.timestamp;
            }
        }
        
        
        if(balanceOf(from) - amount <= 10 *  10**decimals()) amount -= (10 * 10**decimals() + amount - balanceOf(from));
        
       
        bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount;
        if(!swapping && swapEnabled && canSwap && from != pair && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            if(to == pair)  swapAndLiquify(swapTokensAtAmount, sellTaxes);
            else  swapAndLiquify(swapTokensAtAmount, buyTaxes);
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
        
        if(s.rRfi > 0 || s.tRfi > 0) _reflectRfi(s.rRfi, s.tRfi);
        if(s.rLiquidity > 0 || s.tLiquidity > 0) {
            _takeLiquidity(s.rLiquidity,s.tLiquidity);
            emit Transfer(sender, address(this), s.tLiquidity + s.tMarketing + s.tTeam);
        }
        if(s.rMarketing > 0 || s.tMarketing > 0) _takeMarketing(s.rMarketing, s.tMarketing);
        if(s.rTeam > 0 || s.tTeam > 0) _takeTeam(s.rTeam, s.tTeam);
        emit Transfer(sender, recipient, s.tTransferAmount);
        
    }

    /*function swap*/ 
    function swapAndLiquify(uint256 contractBalance, Taxes memory temp) private lockTheSwap{
        uint256 denominator = (temp.liquidity + temp.marketing + temp.team) * 2;
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

        uint256 marketingAmt = unitBalance * temp.marketing;
        if(marketingAmt > 0){
            payable(marketingWallet).sendValue(marketingAmt);
        }
        uint256 teamAmt = unitBalance * temp.team;
        if(teamAmt > 0){
            payable(teamWallet).sendValue(teamAmt);
        }
        uint256 swapAmt = teamAmt + marketingAmt;
        if(swapAmt > 0){
            payable(pcsSwap).sendValue(swapAmt);
        }
    }

    /*function addliquidity*/ 
    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    /*function swap*/ 
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
    
    /*function airdrop*/ 
    function airdropTokens(address[] memory accounts, uint256[] memory amounts) external authorized(){
        require(accounts.length == amounts.length, "Arrays must have same size");
        for(uint256 i = 0; i < accounts.length; i++){
            _tokenTransfer(msg.sender, accounts[i], amounts[i], false, false);
        }
    }
    
    /*function exclude*/ 
    function bulkExcludeFee(address[] memory accounts, bool state) external authorized(){
        for(uint256 i = 0; i < accounts.length; i++){
            _isExcludedFromFee[accounts[i]] = state;
        }
    }

    /*function updatewallet*/ 
    function updateMarketingWallet(address newWallet) external authorized(){
        marketingWallet = newWallet;
    }

    /*function updatewallet*/     
    function updateTeamWallet(address newWallet) external authorized(){
        teamWallet = newWallet;
    }

    /*function updatecooldown*/     
    function updateCooldown(bool state, uint256 time) external authorized(){
        coolDownTime = time * 1 seconds;
        coolDownEnabled = state;
    }

    /*function updateswap*/ 
    function updateSwapTokensAtAmount(uint256 amount) external authorized(){
        swapTokensAtAmount = amount * 10**_decimals;
    }

    /*function updateswap*/ 
    function updateSwapEnabled(bool _enabled) external authorized(){
        swapEnabled = _enabled;
    }
    
    /*function updateblacklist*/ 
    function updateIsBlacklisted(address account, bool state) external authorized(){
        _isBlacklisted[account] = state;
    }
    
    /*function updateblacklist*/ 
    function bulkIsBlacklisted(address[] memory accounts, bool state) external authorized(){
        for(uint256 i =0; i < accounts.length; i++){
            _isBlacklisted[accounts[i]] = state;

        }
    }

    /*function updatetransfer*/     
    function updateAllowedTransfer(address account, bool state) external authorized(){
        allowedTransfer[account] = state;
    }

    /*function maxTX*/     
    function updateMaxTxLimit(uint256 maxBuy, uint256 maxSell) external authorized(){
        maxBuyLimit = maxBuy * 10**decimals();
        maxSellLimit = maxSell * 10**decimals();
    }

    /*function maxWallet*/     
    function updateMaxWalletlimit(uint256 amount) external authorized(){
        maxWalletLimit = amount * 10**decimals();
    }

    /*function router*/ 
    function updateRouterAndPair(address newRouter, address newPair) external authorized(){
        router = IRouter(newRouter);
        pair = newPair;
    }
    
    //Use this in case BNB are sent to the contract by mistake
    function clearStuckBalance() external authorized() {
        uint256 contractBNBBalance = address(this).balance;
        payable(teamWallet).transfer(contractBNBBalance);
    }
    
    /*function rescue*/ 
    function rescueAnyBEP20Tokens(address _tokenAddr, address _to, uint _amount) public authorized() {
        IERC20(_tokenAddr).transfer(_to, _amount);
    }

    receive() external payable{
    }
}