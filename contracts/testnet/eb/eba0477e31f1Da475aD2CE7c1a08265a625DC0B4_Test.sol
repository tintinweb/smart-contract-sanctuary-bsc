/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

/**

    Ares - God of the Arena

 Telegram: ...
  

Tokenomics: 
  3% auto-liquidity
  2% reflections
  3% bounty
  4% treasury
*/


pragma solidity ^0.8.12;
// SPDX-License-Identifier: MIT

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

abstract contract Authorized {
    address private _owner;
    address private _previousOwner;
    mapping (address => bool) _authorized;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        _authorized[_owner] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
    function owner() public view returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    modifier onlyAuthorized {
        require(_authorized[msg.sender], "Authorization: caller is not the authorized");
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
}



interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router{
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function getAmountsIn(
        uint256 amountOut,
        address[] memory path
    ) external view returns (uint256[] memory amounts);
    
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract Test is IERC20, Authorized {
    
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    mapping (address => bool) public isPair;
   
    string private _name = "Test";
    string private _symbol = "TEST";
    uint8 private _decimals = 9 ;
    uint256 private DECIMALS = 10 ** _decimals;
    
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 10e6 * DECIMALS;   // 10 million tokens, total supply
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    
    uint256 public _taxFee = 2;
    uint256 private _previousTaxFee = _taxFee;   
    
    uint256 public _liquidityFee = 3;
    uint256 public _bountyFee = 3;
    uint256 public _treasuryFee = 4;    
    uint256 public _totalLPFee = 10;
    uint256 private _previousTotalLPFee = _totalLPFee; 
    uint256 public gladiatorBountyPercent = 75;
    
    IUniswapV2Router public uniswapV2Router;    
    address public uniswapV2Pair;
    address public deadAddress = address(0x000000000000000000000000000000000000dEaD);  

    //Testnet     
    address public USDAddress = address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    // Mainnet
    // address public USDAddress = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    // METIS MAINNET
    // 0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000 - MTS
    // 0xEA32A96608495e54156Ae48931A7c20f0dcc1a21 - USDC


    address public treasury;
    
    uint256 public swapTokensAtAmount = 1 * _tTotal / 1000;  // 0.1% of total supply, 10 thousand tokens   
    uint256 public maxTx = 20 * _tTotal / 1000;              // 2.0% of total supply, 200 thousand tokens  
    uint256 public maxWallet = 20 * _tTotal / 1000;          // 2.0% of total supply, 200 thousand tokens
    bool public limitsInEffect = true;
    
    uint256 public nAntiBotBlocks;
    uint256 public launchBlock;
    bool public tradingIsEnabled = false;
    bool public antiBotActive = false;
    bool public swapping = false;
    bool public burning = false;
    bool public accumulatingForBurn = false;
    uint256 public burnAmount = 0;
    uint256 public timeLastWithdraw = 0; 

    address public ares = deadAddress;
    uint256 public aresScore;
    address public gladiator = deadAddress;
    uint256 public gladiatorScore;

    uint256 public timeLastVictor;
    uint256 public timeLastAres;
    uint256 public gladiatorRoundDuration = 1 minutes;
    uint256 public aresRoundDuration = 1 weeks;

    mapping(address => uint256) public timesAsGladiator;
    mapping(address => uint256) public timesAsAres;
    mapping(address => uint256) public timesWinArena;  
    mapping(address => bool) public electedAres;  
    mapping(address => uint256) public individualAresBounty;
    mapping(address => uint256) public individualGladiatorBounty;
    
    uint256 public totalAres;
    uint256 public totalGladiators;

    address public mostFrequentGladiator;
    uint256 public mostTimesAsGladiator;   
    address public mostWinsGladiator;
    uint256 public mostWinsAsGladiator;    
 

    uint256 public totalAresBounty;
    uint256 public totalGladiatorBounty;

    mapping(address => bool) public fallenToGreed; 
    uint256 public totalFallenToGreed; 


    

    
    event Launch(uint256 indexed nAntiBotBlocks);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived
    );  
    
    constructor () {
        _rOwned[msg.sender] = _rTotal; 
        
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[deadAddress] = true;
        _isExcluded[deadAddress];

        treasury = msg.sender;
        
        emit Transfer(address(0), msg.sender, _tTotal);
    }
    
    modifier inSwap{
        swapping = true;
        _; 
        swapping = false;
        
    }
    
    modifier inBurn{
        burning = true;
        _; 
        burning = false;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
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
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        require(_allowances[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        require(_allowances[msg.sender][spender] >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function totalFees() public view returns (uint256) {    
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount - tFee - tLiquidity;
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rLiquidity = tLiquidity * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rLiquidity;
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rLiquidity;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tLiquidity;
    }
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount * _taxFee / 10**2;
    }
    
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount * _totalLPFee / 10**2;
    }
    
    function removeAllFee() private {
        if(_taxFee == 0 && _liquidityFee == 0) return;
        
        _previousTaxFee = _taxFee;
        _previousTotalLPFee = _totalLPFee;
        
        _taxFee = 0;
        _totalLPFee = 0;
    }
     
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _totalLPFee = _previousTotalLPFee;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    // ***  OWNER FUNCTIONS ***
    function createPair() public onlyOwner {

        // IUniswapV2Router _uniswapV2Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);        
        IUniswapV2Router _uniswapV2Router = IUniswapV2Router(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);        
        
        
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        isPair[uniswapV2Pair] = true;
        uniswapV2Router = _uniswapV2Router;
        timeLastAres = block.timestamp;
        timeLastVictor = block.timestamp;
        emit SetAutomatedMarketMakerPair(uniswapV2Pair, true);
    }
    
     function launch(uint256 _nAntiBotBlocks) public onlyOwner {
        require(!tradingIsEnabled, "Project already launched.");
        nAntiBotBlocks = _nAntiBotBlocks;
        launchBlock = block.number;
        tradingIsEnabled = true;
        antiBotActive = true;
        
        emit Launch(nAntiBotBlocks);   
    }

    function changeTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    // * * * END OWNER FUNCTIONS * * *

    // *** OPERATOR FUNCTIONS ***
    function planBurn(uint256 _burnNumerator, uint256 _burnDenominator) public onlyAuthorized {
        burnAmount = _tTotal * _burnNumerator / _burnDenominator;
        accumulatingForBurn = true;
    } 

    function excludeFromFees(address _wallet, bool _exclude) public onlyAuthorized {
        _isExcludedFromFee[_wallet] = _exclude;
    }

    function changeLimitsInEffect(bool inEffect) external onlyAuthorized {
        limitsInEffect = inEffect;
    }

    /*
    This function allows for 
      1. development of long-term utilty such as staking pools and
      2. withdrawing of mistransferred tokens
      Note the time-restriction placed on withdrawals, for the safety of our investors.
    */ 
    function withdrawTokens(address token, uint256 amount) external onlyAuthorized {
        if(token == address(this)){
            require(block.timestamp > timeLastWithdraw + 24 hours && 
            amount <= 2 * balanceOf(address(this)) / 100 , "A maximum of 2% of token supply may be withdrawn every 24 hours.");    
        }
        timeLastWithdraw = block.timestamp;
        IERC20(token).transfer(msg.sender, amount);
    }
    // * * * END OPERATOR FUNCTIONS * * *

    function checkValidTrade(address from, address to, uint256 amount) private view {
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            require(tradingIsEnabled, "Project has yet to launch.");
            require(amount <= maxTx, "Transfer amount exceeds the max allowable."); 
            if (isPair[from]){
                require(balanceOf(address(to)) + amount <= maxWallet, 
                "Token purchase implies violation of max allowable wallet amount restriction.");
            }
        } 
    }

    function _transfer(address from, address to, uint256 amount) private {
        if(amount == 0) {
            return;
        }

        if(limitsInEffect){        
            checkValidTrade(from, to, amount);
        }
        bool takeFee = tradingIsEnabled && !swapping;
        
        
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        if(takeFee){
            if(isPair[from]){
                address[] memory path = new address[](2);
                path[0] = uniswapV2Router.WETH();
                path[1] = address(this);
                uint256 buyAmountBNB = uniswapV2Router.getAmountsIn(amount, path)[0];

                if(block.timestamp > timeLastVictor + gladiatorRoundDuration){
                    timesWinArena[gladiator]++;
                    gladiator = deadAddress;
                    gladiatorScore = 0;
                }
                if(block.timestamp > timeLastAres + aresRoundDuration){
                    electedAres[ares] = true;
                    ares = deadAddress;
                    aresScore = 0;
                }
                if(buyAmountBNB > gladiatorScore && !fallenToGreed[to]){                                    
                    if(timesAsGladiator[to] == 0)
                        totalGladiators++;
                    if(gladiator != to){
                        timesAsGladiator[to]++;
                        gladiator = to;
                    }
                    if(timesAsGladiator[to] > mostTimesAsGladiator){
                        mostFrequentGladiator = to;
                        mostTimesAsGladiator = timesAsGladiator[to];
                    }
                    if(timesWinArena[to] > mostWinsAsGladiator){
                        mostWinsGladiator = to;
                        mostWinsAsGladiator = timesWinArena[to];
                    }
                    gladiatorScore = buyAmountBNB;
                    timeLastVictor = block.timestamp;
                    if(buyAmountBNB > aresScore){
                        if(timesAsAres[to] == 0)
                        totalAres++;
                        if(ares != to){
                            timesAsAres[to]++;
                            ares = to;
                        }
                        aresScore = buyAmountBNB;
                        timeLastAres = block.timestamp;
                    }
                }
            }
            else if(isPair[to]){
                if(from == gladiator){
                    fallenToGreed[from] = true;
                    totalFallenToGreed++;
                    gladiator = deadAddress;
                    gladiatorScore = 0;
                    timeLastVictor = block.timestamp;
                    if(from == ares){
                        ares = deadAddress;
                        aresScore = 0;
                        timeLastAres = block.timestamp;
                    }
                }      
            }

            if(antiBotActive){
                uint256 fees; // check msg.sender == tx.origin
                if(block.number < launchBlock + nAntiBotBlocks){ 
                    fees = amount * 50 / 100;
                    amount = amount - fees;
                    takeFee = false;
                    _tokenTransfer(from, address(this), fees, takeFee);
                }
                else{
                    antiBotActive = false; 
                }
            }
        } 
         
        if(accumulatingForBurn){
            if(shouldBurn()){
                burn(burnAmount);
            }    
        }
        else if(shouldSwap(to)) { 
            swapTokens(swapTokensAtAmount);
        }
        _tokenTransfer(from, to, amount, takeFee);
    }
    
    function shouldBurn() private view returns (bool){
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canBurn = contractTokenBalance >= burnAmount;
        return tradingIsEnabled && canBurn &&
        !burning && !antiBotActive;
    }
    
    function burn(uint256 _burnAmount) private inBurn {
        uint256 currentRate =  _getRate();
        uint256 rBurn = _burnAmount * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] - rBurn;
        _rOwned[deadAddress] = _rOwned[deadAddress] + rBurn;
        _tOwned[deadAddress] = _tOwned[deadAddress] + _burnAmount;
       
        emit Transfer(address(this), deadAddress, _burnAmount);
        if(accumulatingForBurn)
            accumulatingForBurn = false;
    }   
    
    function shouldSwap(address to) private view returns (bool){
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        
        return tradingIsEnabled && canSwap && !swapping &&
        isPair[to] && !antiBotActive;
    }

    function swapTokens(uint256 tokens) inSwap private {
        
        uint256 LPtokens = tokens * _liquidityFee / _totalLPFee;
        uint256 halfLPTokens = LPtokens / 2;
        uint256 treasuryTokens = tokens * _treasuryFee / _totalLPFee;
        uint256 bountyTokens = tokens - LPtokens - treasuryTokens;
        uint256 tokensToSwap = halfLPTokens + treasuryTokens + bountyTokens;
        
        uint256 firepitAmount = 0;
        if(gladiatorScore == 0 || aresScore == 0){
            if(gladiatorScore == 0){
                firepitAmount += gladiatorBountyPercent * bountyTokens / 100;                                
            }
            if(aresScore == 0){
                firepitAmount += (100 - gladiatorBountyPercent) * bountyTokens / 100;                                
            }
            bountyTokens -= firepitAmount;
            burn(firepitAmount);
        }
        
        uint256 initialBalance = address(this).balance;

        swapTokensForEth(tokensToSwap); 
         
        uint256 newBalance = address(this).balance - initialBalance;
        uint256 bnbForLP = newBalance * halfLPTokens / tokensToSwap;
        
        if(gladiatorScore != 0 || aresScore != 0){
            uint256 bnbForBounty = newBalance * bountyTokens / tokensToSwap; 
            if(gladiatorScore != 0 && aresScore != 0){
                uint256 bnbForGladiator = gladiatorBountyPercent * bnbForBounty / 100;
                uint256 bnbForAres = bnbForBounty - bnbForGladiator;
                (bool temp,) = payable(ares).call{value: bnbForAres, gas: 30000}("");                 
                (temp,) = payable(gladiator).call{value: bnbForGladiator, gas: 30000}(""); 
                individualAresBounty[ares] += bnbForAres;
                individualGladiatorBounty[gladiator] += bnbForGladiator;
                totalAresBounty += bnbForAres;
                totalGladiatorBounty += bnbForGladiator;                 
            }
            else if(gladiatorScore != 0){
                (bool temp,) = payable(gladiator).call{value: bnbForBounty, gas: 30000}("");temp; //warning-suppresion                
                individualGladiatorBounty[gladiator] += bnbForBounty;
                totalGladiatorBounty += bnbForBounty;
            }
            else{
                (bool temp,) = payable(ares).call{value: bnbForBounty, gas: 30000}("");temp;                
                individualAresBounty[ares] += bnbForBounty;
                totalAresBounty += bnbForBounty;
            }
        }
        if(halfLPTokens > 0 && bnbForLP > 0){
            addLiquidity(halfLPTokens, bnbForLP);
        }
        ( bool tempo,) = payable(treasury).call{value: address(this).balance, gas: 30000}("");tempo; //warning-suppresion 
        
        emit SwapAndLiquify(halfLPTokens, bnbForLP);   
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0x526f016B5F6cE31bB9c5f93AA45A38C4DBC0E148),
            block.timestamp
        );
    }
    
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        if(!takeFee)
            restoreAllFee(); 
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;           
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;   
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

     function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;        
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function getCirculatingSupply() external view returns (uint256) {
        return totalSupply() - balanceOf(deadAddress);
    }

    struct ArenaOracleDataEstimated{
        address  ares;
        uint256  aresScore;
        address  gladiator;
        uint256  gladiatorScore;

        uint256  timeLastVictor;
        uint256  timeLastAres;
    
        address  mostFrequentGladiator;
        uint256  mostTimesAsGladiator;
        address  mostWinsGladiator;
        uint256  mostWinsAsGladiator;

        uint256  totalGladiators;
        uint256  totalAres;
        uint256  totalAresBounty;
        uint256  totalGladiatorBounty;
        uint256  totalFallenToGreed; 

        uint256 liquidity;
        uint256 treasury;
        uint256 firepit;
    }

    struct ArenaOracleData{
        address  ares;
        uint256  aresScore;
        address  gladiator;
        uint256  gladiatorScore;

        uint256  timeLastVictor;
        uint256  timeLastAres;
    
        address  mostFrequentGladiator;
        uint256  mostTimesAsGladiator;
        address  mostWinsGladiator;
        uint256  mostWinsAsGladiator;

        uint256  totalGladiators;
        uint256  totalAres;
        uint256  totalAresBounty;
        uint256  totalGladiatorBounty;
        uint256  totalFallenToGreed; 
 
    }

    struct ArenaOracleDataWallet{
        uint256 timesGladiator;
        uint256 timesWinArena;
        uint256 timesAsAres;
        bool fallenToGreed;      
        uint256 individualAresBounty;
        uint256 individualGladiatorBounty;
    }  

    function getArenaOracleDataEstimated() external view returns(ArenaOracleDataEstimated memory){
        ArenaOracleDataEstimated memory data = ArenaOracleDataEstimated(
            ares, aresScore, gladiator, gladiatorScore,
            timeLastVictor, timeLastAres, mostFrequentGladiator, mostTimesAsGladiator,
            mostWinsGladiator, mostWinsAsGladiator,
            totalGladiators, totalAres, totalAresBounty, totalGladiatorBounty,
            totalFallenToGreed, getPairValue(), treasury.balance, getFirePitValue());
            return data;
    }

    function getArenaOracleData() external view returns(ArenaOracleData memory){
        ArenaOracleData memory data = ArenaOracleData(
            ares, aresScore, gladiator, gladiatorScore,
            timeLastVictor, timeLastAres, mostFrequentGladiator, mostTimesAsGladiator,
            mostWinsGladiator, mostWinsAsGladiator,
            totalGladiators, totalAres, totalAresBounty, totalGladiatorBounty,
            totalFallenToGreed);
            return data;
    }

     function getArenaOracleDataWallet(address wallet) external view returns (ArenaOracleDataWallet memory){
        ArenaOracleDataWallet memory data = ArenaOracleDataWallet(
            timesAsGladiator[wallet], timesWinArena[wallet], timesAsAres[wallet], 
            fallenToGreed[wallet], individualAresBounty[wallet], individualGladiatorBounty[wallet]);        
             return data;
    }

    function getEstimatedUSD(uint256 amount, bool fromToken) public view returns (uint256){        
        if(fromToken){
            address[] memory path = new address[](3);
            path[0] = USDAddress;        
            path[1] = uniswapV2Router.WETH();
            path[2] = address(this);
            return uniswapV2Router.getAmountsIn(amount, path)[0];
        }else{
            address[] memory path = new address[](2);
            path[0] = USDAddress;        
            path[1] = uniswapV2Router.WETH();            
            return uniswapV2Router.getAmountsIn(amount, path)[0];
        }                
    }

    function getFirePitValue() public view returns (uint256){
        if(balanceOf(deadAddress) == 0){
            return 0;
        }
        else{
            return getEstimatedUSD(balanceOf(deadAddress), true);
        }       
    }

    function getPairValue() public view returns (uint256){               
        return getEstimatedUSD(IERC20(uniswapV2Router.WETH()).balanceOf(uniswapV2Pair), false);
    }

   

    receive() external payable {}

}