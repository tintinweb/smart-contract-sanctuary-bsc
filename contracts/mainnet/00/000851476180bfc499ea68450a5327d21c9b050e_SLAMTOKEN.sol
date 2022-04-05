/**
     _____ _       ___  ___  ___
    /  ___| |     / _ \ |  \/  |
    \ `--.| |    / /_\ \| .  . |
     `--. \ |    |  _  || |\/| |
    /\__/ / |____| | | || |  | |
    \____/\_____/\_| |_/\_|  |_/  2.0


    S L A M T O K E N . C O M
        SLAM holders are rewarded with dividends every month, just by holding SLAM in their wallets.

    Prepared for slamtoken.com by Kadabra.      

    Migration Date: April 25th, 2022
    Original Token Launch Date: April 25th, 2021

    This is a much needed migration contract for SLAM Token. LFG!
    - Fees lowered from 10% to 4%. (Max Capped to 10)
    - Reduced supply to 10M from 1T.
    - Added a buyback mechanism
    - Built-in dividend functions
    - Ability to whitelabel wallets (Helps to get listed on CEXs)

    ------------------------------------------------------------------------------
    
    Tokenomics:
        Total Supply: 10.000.000 (10M)
        The consolidation rate for the original SLAM Token to SLAM 2.0 is "/100,000"
        
    Airdrops:
        * Trading will be disabled by default initially.
        * Previous SLAM holders will receive their SLAM with Airdrops within the same day of the migration.
        * Trading will be enabled as the last step of the migration.
            It can never be disabled back again as you can see on the contracts's source code.
    
    ------------------------------------------------------------------------------

    We are proud of how far we've come and excited for what's ahead of us.
    
    Some milestones during the first year of SLAM:
        * Launched many products
            - Slam Crash (A pretty simple gambling game that consists of a line that keeps going up and up, multiplying your bet)
            - Slam Vegas (Licensed live casino played by various cryptos)
            - Jokers by SLAM (First ever truly dynamic NFT (dNFT) collection) launched on ETH network
            - NFT Radar (First ever NFT portfolio tracking app)
            - Slam Royale (Multiplayer live poker platform)
            - Slam Charts (A chart website with companion mobile apps for BSC tokens - Discontinued)
        * Gave out hundreds of thousands of dollars in dividends (slamtoken.com/dividends)
        * Reached $55M market cap
        * Trended on CoinMarketCap
        * Acquired a casino license for Slam Vegas (slamvegas.com)
        * Our first game Slam Crash (slamcrash.com) at total
            - Recorded +2.2M plays, +$100M wagered as of April 2022. 
        * All time high was at 102x of the presale price on August 23rd, 2021.
        * SLAM has been listed as one of the top 6 DeFi projects ever launched on DxSale.app
        
    ------------------------------------------------------------------------------

    Co-Founders: Abra & Kadabra

    Need to contact us?
        Email: [email protected]
        Telegram: https://t.me/SlamToken
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./library.sol";

contract SLAMTOKEN is Context, BEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 10**7 * 10**18; //10 Million SLAM <3
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    address public _buybackFundWallet = address(0);
    address public _marketingWallet = address(0);

    string private constant _name = "SLAM TOKEN";
    string private constant _symbol = "SLAM";
    uint8 private constant _decimals = 18;
    
    uint256 public _reflectionTaxFee = 0;
    uint256 private _previousReflectionTaxFee = _reflectionTaxFee;
    
    uint256 public _liquidityFee = 4;
    uint256 private _previousLiquidityFee = _liquidityFee;

    IPancakeswapV2Router02 public pancakeswapV2Router;
    address public pancakeswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    bool public feesLPEnabled = true;
    bool public feesBuybackEnabled = true;
    bool public feesMarketingEnabled = true;

    uint256 private tradingStart = MAX;
    
    uint256 private numTokensSellToAddToLiquidity = 2500 * 10**18;
    
    // Events
    event TradingEnabled();
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiquidity);
    event ReflectionTaxUpdate(uint256 newReflectionTaxValue);
    event LiquidityTaxUpdate(uint256 newLiquidityTaxValue);
    event PancakeSwapRouterUpdate(address newAddress);
    event TokenSellToLiquidityUpdate(uint256 value);
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor (
        address buybackFundWallet,
        address marketingWallet
    ) public {
        _rOwned[_msgSender()] = _rTotal;
        
        setRouterAddress(0x10ED43C718714eb63d5aA57B78B54704E256024E); 

        //set the wallets to use with fees
        _buybackFundWallet = buybackFundWallet;
        _marketingWallet = marketingWallet;

        // exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    // To receive BNB from pancakeswapV2Router when swapping
    receive() external payable {}

    /*     VIEW FUNCTIONS     */

    // Returns contract name
    function name() public pure returns (string memory) {
        return _name;
    }
    
    // Returns contract symbol
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    
    // Returns total supply
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    
    // Returns balance (includes reflection) of address
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }
    
    // Returns allowance amount between owner and spender
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // Is an address excluded from the reflection rewards?
    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }
    
    // Returns total amount of fees
    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }
    
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }
    
    function isTradingEnabled() public view returns (bool) {
        return tradingStart < block.timestamp;
    }
    
    //Returns true if account is included in excluded fee list
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }







    /*     PUBLIC FUNCTIONS     */

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    // Gives back reflected tokens from a wallet to the rest of non-excluded wallets
    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }
    
    // Transfer SLAM from sender to recipient
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    // Approve transaction
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    // Increase the allowance of a authorized msgSender spender
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    
    // Decrease the allowance of a authorized msgSender spender
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }







    /*     ONLYOWNER FUNCTIONS     */

    // Exclude an address from reflection reward.
    // Cannot exclude pancakeswap router.
    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    // Include an address in reflection reward.
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
    
    // Exclude an address from reflection fee and liquidity fee
    function excludeFromFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = true;
    }
    
    // Remove an address from fee exclusion.
    function includeInFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = false;
    }
    
    function setTradingEnabled() external onlyOwner {
        // Can only be called once
        require(tradingStart == MAX, "Trading has already started");
        setSwapAndLiquifyEnabled(true);
        tradingStart = block.timestamp;
        emit TradingEnabled();
    }

    function setBuybackFundWallet(address buybackFundWallet) external onlyOwner() {
        _buybackFundWallet = buybackFundWallet;
    }
    
    function setMarketingWallet(address marketingWallet) external onlyOwner() {
        _marketingWallet = marketingWallet;
    }

    // Set reflection tax fee percentage.
    function setReflectionTaxFeePercent(uint256 reflectionTaxFee) external onlyOwner() {
        require(_liquidityFee + reflectionTaxFee <= 10, "Total fee cannot be more than 10 percent"); //Hard cap
        _reflectionTaxFee = reflectionTaxFee;
        emit ReflectionTaxUpdate(reflectionTaxFee);
    }
    
    // Set the liquidity fee percentage
    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
        require(_reflectionTaxFee + liquidityFee <= 10, "Total fee cannot be more than 10 percent"); //Hard cap
        _liquidityFee = liquidityFee;
        emit LiquidityTaxUpdate(liquidityFee);
    }

    // Set minimum tokens required in contract to sell for liquidity
    function setNumTokensSellToAddToLiquidity(uint256 amount) external onlyOwner() {
        numTokensSellToAddToLiquidity = amount;
        emit TokenSellToLiquidityUpdate(amount);
    }

    // Set liquidity swap
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner() {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    function setFeesLPEnabled(bool _enabled) public onlyOwner() {
        feesLPEnabled = _enabled;
    }
    function setFeesBuybackEnabled(bool _enabled) public onlyOwner() {
        feesBuybackEnabled = _enabled;
    }
    function setFeesMarketingEnabled(bool _enabled) public onlyOwner() {
        feesMarketingEnabled = _enabled;
    }

    // Set the PancakeSwap router address, if they ever change again..........
    function setRouterAddress(address newRouter) public onlyOwner() {
        IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(newRouter);
         // Create a Pancakeswap pair for this new token
        pancakeswapV2Pair = IPancakeswapV2Factory(_pancakeswapV2Router.factory()).createPair(address(this), _pancakeswapV2Router.WETH());

        // set the rest of the contract variables
        pancakeswapV2Router = _pancakeswapV2Router;

        emit PancakeSwapRouterUpdate(newRouter);
    }

    // Send dividend BNBs from SLAM's contract directly to different accounts at one call and decrease the network fee
    function payDividends(address payable[] memory addrs, uint[] memory amnts) payable public onlyOwner() {        
        // the addresses and amounts should be same in length
        require(addrs.length == amnts.length, "The length of two array should be the same");
        
        for (uint i=0; i < addrs.length; i++) {
            // send the specified amount to the recipient
            payDividends_withdraw(addrs[i], amnts[i]);
        }
    }
    function payDividends_withdraw(address payable receiverAddr, uint receiverAmnt) private {
        //receiverAddr.transfer(receiverAmnt);
        bool sent = receiverAddr.send(receiverAmnt * 10**14);
        require(sent, "Error");
    }

    // To get any BNBs or tokens out of the contract if needed
    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    function withdrawToken(address _tokenContract, uint256 _amount, address _to) external onlyOwner{
        BEP20 tokenContract = BEP20(_tokenContract);
        tokenContract.transfer(_to, _amount);
    }
    function withdrawToken_All(address _tokenContract, address _to) external onlyOwner{
        BEP20 tokenContract = BEP20(_tokenContract);
        uint256 _amount = tokenContract.balanceOf(address(this));
        tokenContract.transfer(_to, _amount);
    }







    /*     PRIVATE FUNCTIONS     */

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    // Returns fee amounts based on transfer from sender to receiver amount
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateFee(_reflectionTaxFee, tAmount);
        uint256 tLiquidity = calculateFee(_liquidityFee, tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    // Returns reflection supply and total supply
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    // Takes liquidity fee from transfer
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    
    //Calculate Reflection Fee and Liquidity Fee
    function calculateFee(uint256 _fee, uint256 _amount) private pure returns (uint256) {
        return _amount.mul(_fee).div(10**2);
    }
    
    // Remove all fees temporarily for excluded wallets
    function removeAllFee() private {
        if (_reflectionTaxFee == 0 && _liquidityFee == 0) return;
        
        _previousReflectionTaxFee = _reflectionTaxFee;
        _previousLiquidityFee = _liquidityFee;
        
        _reflectionTaxFee = 0;
        _liquidityFee = 0;
    }
    
    // Restore fees back
    function restoreAllFee() private {
        _reflectionTaxFee = _previousReflectionTaxFee;
        _liquidityFee = _previousLiquidityFee;
    }

    // Approve transaction from owner
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        address _owner = owner();
        bool isIgnoredAddress = (from == _owner || to == _owner);
        bool _isTradingEnabled = isTradingEnabled();
        address _pair = pancakeswapV2Pair;
        require(_isTradingEnabled || isIgnoredAddress || (from != _pair && to != _pair), "Trading is not enabled");

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is Pancakeswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != pancakeswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            // add liquidity
            swapAndLiquify(contractTokenBalance);
        }
        
        // indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        
        // transfer amount, it will take tax, burn and liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        /*
            The collected fees in SLAM will be sold to be used as follows:
                25% -> LP
                25% -> Buyback fund in BNB
                50% -> Marketing/Operations fund in BNB

            These can be switched on/off by Owner. Non-used BNB or SLAM will stay in the contract for the next swapAndLiquify.

            Steps
                - Divide contractTokenBalance in [8xSLAM]
                - swapTokensForBNB 7xSLAM, keep 1xSLAM for LP
                - Divide received BNB in [7xBNB]
                    - Send 2xBNB to Buyback fund wallet (which will be used to share SLAM for Staking)
                    - Send 4xBNB to Marketing / Operations wallet
                    - Use 1xBNB + 1xSLAM for LP

                    LP (1xSLAM + 1xBNB)
                    Buyback Fund (2xBNB)
                    Marketing/Operations (4xBNB)
        */

        // split the contract balance into 7
        uint256 tokens1x = contractTokenBalance.div(8);
        uint256 tokens7x = contractTokenBalance.sub(tokens1x);

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance; //Total BNB initially

        // swap tokens for BNB
        swapTokensForBNB(tokens7x); // <- this breaks the BNB -> SLAM swap when swap+liquify is triggered

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);
        uint256 bnb1x = newBalance.div(7);

        if(feesLPEnabled){ // add liquidity to pancakeswap
            newBalance = newBalance.sub(bnb1x);
            addLiquidity(tokens1x, bnb1x);
        }

        if(feesBuybackEnabled){ //TRANSFER bnb1x * 2 to buyback wallet
            uint256 bnbForBuyback = bnb1x.mul(2);
            newBalance = newBalance.sub(bnbForBuyback);
            payable(_buybackFundWallet).transfer(bnbForBuyback);
        }

        if(feesMarketingEnabled){ //TRANSFER bnb1x * 4 to marketing/operations
            uint256 bnbForMarketing = bnb1x.mul(4);
            if(bnbForMarketing > newBalance) bnbForMarketing = newBalance;
            //newBalance = newBalance.sub(bnbForMarketing);
            payable(_marketingWallet).transfer(bnbForMarketing);
        }
        //Any non-used BNBs in newBalance will remain in the contract.

        emit SwapAndLiquify(tokens7x, newBalance, tokens1x);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        // generate the Pancakeswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeswapV2Router.WETH();

        _approve(address(this), address(pancakeswapV2Router), tokenAmount);

        // make the swap
        pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(pancakeswapV2Router), tokenAmount);

        // add the liquidity
        pancakeswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(0), //burn LP tokens
            tokenAmount, //                     ----amountTokenDesired
            0, // slippage is unavoidable       ----amountTokenMin
            0, // slippage is unavoidable.      ----amountETHMin
            owner(),
            block.timestamp
        );
        
    }

    //Handle token transfer request from sender to receipient
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee)
            removeAllFee();
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) { // If sender is excluded from fees and recipient isn't
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) { // If recipient is excluded from fees and sender isn't
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) { // If sender and recipient are both excluded from fees
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount); // If both the sender and recipient are fee'd
        }
        
        if (!takeFee)
            restoreAllFee();
    }

    // If both the sender and recipient are fee'd
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        
        _takeFee(tLiquidity, rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    // If recipient is excluded from fees and sender isn't
    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        
        _takeFee(tLiquidity, rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    // If sender is excluded from fees and recipient isn't
    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        
        _takeFee(tLiquidity, rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    // If sender and recipient are both excluded from fees
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        
        _takeFee(tLiquidity, rFee, tFee);
        
        emit Transfer(sender, recipient, tTransferAmount);
    }

    // Handles liquidity fee and reflection fee
    function _takeFee(uint256 tLiquidity, uint256 rFee, uint256 tFee) private {
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
    }
}