pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./Context.sol";
import "./Ownable.sol";
import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router02.sol";
import "./IContract.sol";

contract ROSHAMBO_TOKEN is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    string private _name = "Roshambo";
    string private _symbol = "ROS";
    uint8 private _decimals = 18;
    
    mapping(address => uint256) internal _reflectionBalance;
    mapping(address => uint256) internal _tokenBalance;
    mapping(address => mapping(address => uint256)) internal _allowances;
    
    uint256 private constant MAX = ~uint256(0);
    uint256 internal _tokenTotal = 12e27;
    uint256 internal _reflectionTotal = (MAX - (MAX % _tokenTotal));
    
    mapping(address => bool) isExcludedFromFee;
    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public isPair;
    mapping(address => bool) internal _isExcluded;
    mapping(address => bool) isThisContractCanTransfer;
    address[] internal _excluded;

    // @Dev transfer Fees
    uint256 public _taxFee = 1;
    uint256 public _liquidityFee = 2;
    uint256 public _marketingFee = 1;
    uint256 public _rewardsFee = 0;
    uint256 public _burnFee = 1;
    
    // @Dev Buy Fees
    uint256 public _buyTaxFee = 1;
    uint256 public _buyLiquidityFee = 2;
    uint256 public _buyMarketingFee = 1;
    uint256 public _buyRewardsFee = 0;
    uint256 public _buyBurnFee = 1;
    
    // @Dev Sell Fees
    uint256 public _sellTaxFee = 1;
    uint256 public _sellLiquidityFee = 3;
    uint256 public _sellMarketingFee = 2;
    uint256 public _sellRewardsFee = 2;
    uint256 public _sellBurnFee = 1;

    uint256 public swapInterval = 1 days;
    uint256 public lastSwapAt;
    
    uint256 public taxFeeTotal;
    uint256 public liquidityFeeTotal;
    uint256 public marketingFeeTotal;
    uint256 public burnFeeTotal;
    uint256 public rewardsFeeTotal;
    
    bool public tradingEnabled = false;
    bool public swapAndLiquifyEnabled = true;
    
    uint256 public maxBuyAmount = 1e26; // 1% of total supply
    uint256 public maxSellAmount = 1e25; // 0.1% of total supply
    
    IUniswapV2Router02 public  uniswapV2Router;
    address public uniswapV2Pair;
    address public marketingAddress;
    address public rewardsAddress;
    address public lpTokenRecipient;
    
    event TradingEnabled(bool enabled);
    event RewardsDistributed(uint256 amount);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapedTokenForEther(uint256 TokenAmount);
    event SwapAndLiquify(uint256, uint256, uint256);

    constructor(address marketing, address rewards, address lpRecipient) {
        
        marketingAddress = marketing;
        rewardsAddress = rewards;
        lpTokenRecipient = lpRecipient;
        
        lastSwapAt = block.timestamp;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
         //@dev Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
            
        uniswapV2Router = _uniswapV2Router;
        
        //@dev Exclude addresses from fees
        isExcludedFromFee[_msgSender()] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[marketingAddress] = true;
        
        //@dev adding the pair
        addRemovePair(uniswapV2Pair, true);
        
        //@dev Exclude addresses from taking rewards
        _isExcluded[uniswapV2Pair] = true;
        _excluded.push(uniswapV2Pair);

        isThisContractCanTransfer[address(this)] = true;
        
        _reflectionBalance[_msgSender()] = _reflectionTotal;
        emit Transfer(address(0), _msgSender(), _tokenTotal);
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

    function totalSupply() public override view returns (uint256) {
        return _tokenTotal;
    }

    function balanceOf(address account) public override view returns (uint256) {
        if (_isExcluded[account]) return _tokenBalance[account];
        return tokenFromReflection(_reflectionBalance[account]);
    }

    function transfer(address recipient, uint256 amount) public override virtual returns (bool) {
       _transfer(_msgSender(),recipient,amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override virtual returns (bool) {
        _transfer(sender,recipient,amount);
               
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub( amount,"BEP20: transfer amount exceeds allowance"));
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }
    
    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }
    
    function tokenFromReflection(uint256 reflectionAmount) public view returns (uint256) {
        require(reflectionAmount <= _reflectionTotal, "Amount must be less than total reflections");
        
        uint256 currentRate = _getReflectionRate();
        return reflectionAmount.div(currentRate);
    }

    function updateSwapInterval(uint256 sec) public onlyOwner {
        swapInterval = sec;
    }
    
    function updateMarketingAddress(address marketing) public onlyOwner {
        require(marketing != marketingAddress, "ROS: Account is already added.");
        marketingAddress = marketing;
    }
    
    function updateLpTokenRecipient(address recipient) public onlyOwner {
        require(recipient != recipient, "ROS: Account is already added.");
        lpTokenRecipient = recipient;
    }
    
    function addRemovePair(address pairAddress, bool value) public onlyOwner {
        require(isPair[pairAddress] != value, "ROS: Account is already added.");
        isPair[pairAddress] = value;
    }

    function reflectionFromToken(uint256 tokenAmount, bool deductTransferFee) public view returns (uint256) {
        require(tokenAmount <= _tokenTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            return tokenAmount.mul(_getReflectionRate());
        } else {
            return
                tokenAmount.sub(tokenAmount.mul(_taxFee).div(100)).mul(
                    _getReflectionRate()
                );
        }
    }
    
    function excludeFromReward(address account) external onlyOwner {
        require(account != address(uniswapV2Router), "ROS: Uniswap router cannot be excluded.");
        require(account != address(this), "ROS: The contract it self cannot be excluded");
        require(!_isExcluded[account], "ROS: Account is already excluded");
        
        if (_reflectionBalance[account] > 0) {
            _tokenBalance[account] = tokenFromReflection(
                _reflectionBalance[account]
            );
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }
    
    function includeForReward(address account) external onlyOwner {
        require(_isExcluded[account], "ROS: Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tokenBalance[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "ROS: Transfer amount must be greater than zero");
        require(tradingEnabled || isExcludedFromFee[sender] || isExcludedFromFee[recipient], "ROS: Trading is locked before presale..");
        require(!isBlacklisted[sender], "ROS: You are blacklisted..");
                
        uint256 transferAmount = amount;
        uint256 rate = _getReflectionRate();
        
        // @Dev if any bot buying or selling will be blacklisted automatically..
        if (isContract(sender) || isContract(recipient) || isContract(msg.sender)) {
            
            if (isContract(sender) && !isPair[sender] && sender != address(uniswapV2Router) && !isThisContractCanTransfer[sender]) {
                isBlacklisted[sender] = true;
            }

            if (isContract(recipient) && !isPair[recipient] && recipient != address(uniswapV2Router) && !isThisContractCanTransfer[recipient]) {
                isBlacklisted[recipient] = true;
            }

            if (isContract(msg.sender) && !isPair[msg.sender] && msg.sender != address(uniswapV2Router) && !isThisContractCanTransfer[msg.sender]) {
                isBlacklisted[msg.sender] = true;
            }
        }

        if (!isExcludedFromFee[sender] && !isExcludedFromFee[recipient]) {
            
            if (isPair[sender]) {
                require(amount <= maxBuyAmount, "ROS: Buy amount exceeds the maximum buy amount");
                transferAmount = collectFeeOnBuy(sender,amount,rate);
            }
            if (isPair[recipient]) {
                require(amount <= maxSellAmount, "ROS: Sell amount exceeds the maximum sell amount");
                transferAmount = collectFeeOnSell(sender,amount,rate);
            }
            if (!isPair[sender] && !isPair[recipient]) {
                transferAmount = collectFee(sender,amount,rate);
            }
            
            uint256 lastSwapTime = block.timestamp.sub(lastSwapAt);
            
            if (!isPair[sender] && swapAndLiquifyEnabled && lastSwapTime >= swapInterval) {
                uint256 contractBalance = balanceOf(address(this));
                
                if (contractBalance > 0) {
                    swapAndLiquify(contractBalance);
                    lastSwapAt = block.timestamp;
                }
            }
        }

        //@dev Transfer reflection
        _reflectionBalance[sender] = _reflectionBalance[sender].sub(amount.mul(rate));
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(transferAmount.mul(rate));

        //@dev If any account belongs to the excludedAccount transfer token
        if (_isExcluded[sender]) {
            _tokenBalance[sender] = _tokenBalance[sender].sub(amount);
        }
        if (_isExcluded[recipient]) {
            _tokenBalance[recipient] = _tokenBalance[recipient].add(transferAmount);
        }

        emit Transfer(sender, recipient, transferAmount);
    }
    
    function collectFee(address account, uint256 amount, uint256 rate) private returns (uint256) {
        uint256 transferAmount = amount;
        
        //@dev Tax fee
        if(_taxFee != 0){
            uint256 Fee = amount.mul(_taxFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _reflectionTotal = _reflectionTotal.sub(Fee.mul(rate));
            taxFeeTotal = taxFeeTotal.add(Fee);
            emit RewardsDistributed(Fee);
        }

        //@dev Take liquidity fee
        if(_liquidityFee != 0){
            uint256 Fee = amount.mul(_liquidityFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _reflectionBalance[address(this)] = _reflectionBalance[address(this)].add(Fee.mul(rate));
            liquidityFeeTotal = liquidityFeeTotal.add(Fee);
            emit Transfer(account, address(this), Fee);
        }

        //@dev Take marketing fee
        if(_marketingFee != 0){
            uint256 Fee = amount.mul(_marketingFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _reflectionBalance[marketingAddress] = _reflectionBalance[marketingAddress].add(Fee.mul(rate));
            marketingFeeTotal = marketingFeeTotal.add(Fee);
            emit Transfer(account, marketingAddress, Fee);
        }

        //@dev Take rewards fee
        if(_rewardsFee != 0){
            uint256 Fee = amount.mul(_rewardsFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _reflectionBalance[rewardsAddress] = _reflectionBalance[rewardsAddress].add(Fee.mul(rate));
            rewardsFeeTotal = rewardsFeeTotal.add(Fee);
            emit Transfer(account, rewardsAddress, Fee);
        }

        //@dev Take burn fee
        if(_burnFee != 0){
            uint256 Fee = amount.mul(_burnFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _tokenTotal = _tokenTotal.sub(Fee);
            _reflectionTotal = _reflectionTotal.sub(Fee.mul(rate));
            burnFeeTotal = burnFeeTotal.add(Fee);
            emit Transfer(account, address(0), Fee);
        }
        
        return transferAmount;
    }
    
    function collectFeeOnBuy(address account, uint256 amount, uint256 rate) private returns (uint256) {
        uint256 transferAmount = amount;
        
        //@dev Tax fee
        if(_buyTaxFee != 0){
            uint256 Fee = amount.mul(_buyTaxFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _reflectionTotal = _reflectionTotal.sub(Fee.mul(rate));
            taxFeeTotal = taxFeeTotal.add(Fee);
            emit RewardsDistributed(Fee);
        }

        //@dev Take liquidity fee
        if(_buyLiquidityFee != 0){
            uint256 Fee = amount.mul(_buyLiquidityFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _reflectionBalance[address(this)] = _reflectionBalance[address(this)].add(Fee.mul(rate));
            liquidityFeeTotal = liquidityFeeTotal.add(Fee);
            emit Transfer(account, address(this), Fee);
        }

        //@dev Take marketing fee
        if(_buyMarketingFee != 0){
            uint256 Fee = amount.mul(_buyMarketingFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _reflectionBalance[marketingAddress] = _reflectionBalance[marketingAddress].add(Fee.mul(rate));
            marketingFeeTotal = marketingFeeTotal.add(Fee);
            emit Transfer(account, marketingAddress, Fee);
        }

        //@dev Take rewards fee
        if(_buyRewardsFee != 0){
            uint256 Fee = amount.mul(_buyRewardsFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _reflectionBalance[rewardsAddress] = _reflectionBalance[rewardsAddress].add(Fee.mul(rate));
            rewardsFeeTotal = rewardsFeeTotal.add(Fee);
            emit Transfer(account, rewardsAddress, Fee);
        }

        //@dev Take burn fee
        if(_buyBurnFee != 0){
            uint256 Fee = amount.mul(_buyBurnFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _tokenTotal = _tokenTotal.sub(Fee);
            _reflectionTotal = _reflectionTotal.sub(Fee.mul(rate));
            burnFeeTotal = burnFeeTotal.add(Fee);
            emit Transfer(account, address(0), Fee);
        }
        
        return transferAmount;
    }
    
    function collectFeeOnSell(address account, uint256 amount, uint256 rate) private returns (uint256) {
        uint256 transferAmount = amount;
        
        //@dev Tax fee
        if(_sellTaxFee != 0){
            uint256 Fee = amount.mul(_sellTaxFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _reflectionTotal = _reflectionTotal.sub(Fee.mul(rate));
            taxFeeTotal = taxFeeTotal.add(Fee);
            emit RewardsDistributed(Fee);
        }

        //@dev Take liquidity fee
        if(_sellLiquidityFee != 0){
            uint256 Fee = amount.mul(_sellLiquidityFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _reflectionBalance[address(this)] = _reflectionBalance[address(this)].add(Fee.mul(rate));
            liquidityFeeTotal = liquidityFeeTotal.add(Fee);
            emit Transfer(account, address(this), Fee);
        }

        //@dev Take marketing fee
        if(_sellMarketingFee != 0){
            uint256 Fee = amount.mul(_sellMarketingFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _reflectionBalance[marketingAddress] = _reflectionBalance[marketingAddress].add(Fee.mul(rate));
            marketingFeeTotal = marketingFeeTotal.add(Fee);
            emit Transfer(account, marketingAddress, Fee);
        }

        //@dev Take rewards fee
        if(_sellRewardsFee != 0){
            uint256 Fee = amount.mul(_sellRewardsFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _reflectionBalance[rewardsAddress] = _reflectionBalance[rewardsAddress].add(Fee.mul(rate));
            rewardsFeeTotal = rewardsFeeTotal.add(Fee);
            emit Transfer(account, rewardsAddress, Fee);
        }

        //@dev Take burn fee
        if(_sellBurnFee != 0){
            uint256 Fee = amount.mul(_sellBurnFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _tokenTotal = _tokenTotal.sub(Fee);
            _reflectionTotal = _reflectionTotal.sub(Fee.mul(rate));
            burnFeeTotal = burnFeeTotal.add(Fee);
            emit Transfer(account, address(0), Fee);
        }
        
        return transferAmount;
    }

    function _getReflectionRate() private view returns (uint256) {
        uint256 reflectionSupply = _reflectionTotal;
        uint256 tokenSupply = _tokenTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _reflectionBalance[_excluded[i]] > reflectionSupply ||
                _tokenBalance[_excluded[i]] > tokenSupply
            ) return _reflectionTotal.div(_tokenTotal);
            reflectionSupply = reflectionSupply.sub(
                _reflectionBalance[_excluded[i]]
            );
            tokenSupply = tokenSupply.sub(_tokenBalance[_excluded[i]]);
        }
        if (reflectionSupply < _reflectionTotal.div(_tokenTotal))
            return _reflectionTotal.div(_tokenTotal);
        return reflectionSupply.div(tokenSupply);
    }

    // function to allow admin to add an address on blacklist..
    function addRemoveFromBlackList(address botAddress, bool value) public onlyOwner {
        require(isContract(botAddress), "ROS: You can blacklit only bot not an user...");
        isBlacklisted[botAddress] = value;
    }

    // function to allow admin to add contract for transfer tokens..
    function addRemoveContract(address contAdd, bool value) public onlyOwner {
        require(isThisContractCanTransfer[contAdd] != value, "ROS: already same value...");
        isThisContractCanTransfer[contAdd] = value;
    }
    
    function isContract(address address_) private view returns (bool) {
        uint size;
        assembly { size := extcodesize(address_) }
        return size > 0;
    }

    function swapTokensForEther(uint256 amount, address ethRecipient) private {
        
        //@dev Generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), amount);

        //@dev Make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of ETH
            path,
            ethRecipient,
            block.timestamp
        );
        
        emit SwapedTokenForEther(amount);
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            lpTokenRecipient,
            block.timestamp
        );
    }

    function swapAndLiquify(uint256 amount) private {
        // split the contract balance into halves
        uint256 half = amount.div(2);
        uint256 otherHalf = amount.sub(half);

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        swapTokensForEther(half, address(this));

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }
    
    function excludedOrEncludedFromFee(address account, bool value) public onlyOwner {
        require(isExcludedFromFee[account] != value, "ROS: Account is already excluded");
        isExcludedFromFee[account] = value;
    }
    
    function enableDisableSwapAndLiquify(bool value) public onlyOwner {
        swapAndLiquifyEnabled = value;
        emit SwapAndLiquifyEnabledUpdated(value);
    }

    function updateBuySellMaxAmount(uint256 maxBuy, uint256 maxSell) public onlyOwner {
        require(maxBuy >= totalSupply().mul(1).div(10000) && maxSell >= totalSupply().mul(1).div(10000), "ROS: Please enter 0.001% of total supply or more..");
        maxBuyAmount = maxBuy;
        maxSellAmount = maxSell;
    }
    
    function updateTransferFees(uint256 tax, uint256 liquidity, uint256 marketing, uint256 rewards, uint256 burn) public onlyOwner {
        require(tax <= 10 && liquidity <= 10 && marketing <= 10 && rewards <= 10 && burn <= 10, "ROS: Enter a valid number..");
        _taxFee = tax;
        _liquidityFee = liquidity;
        _marketingFee = marketing;
        _rewardsFee = rewards;
        _burnFee = burn;
    }
    
    function updateBuyFees(uint256 tax, uint256 liquidity, uint256 marketing, uint256 rewards, uint256 burn) public onlyOwner {
        require(tax <= 10 && liquidity <= 10 && marketing <= 10 && rewards <= 10 && burn <= 10, "ROS: Enter a valid number..");
        _buyTaxFee = tax;
        _buyLiquidityFee = liquidity;
        _buyMarketingFee = marketing;
        _buyRewardsFee = rewards;
        _buyBurnFee = burn;
    }
    
    function updateSellFees(uint256 tax, uint256 liquidity, uint256 marketing, uint256 rewards, uint256 burn) public onlyOwner {
        require(tax <= 10 && liquidity <= 10 && marketing <= 10 && rewards <= 10 && burn <= 10, "ROS: Enter a valid number..");
        _sellTaxFee = tax;
        _sellLiquidityFee = liquidity;
        _sellMarketingFee = marketing;
        _sellRewardsFee = rewards;
        _sellBurnFee = burn;
    }
    
    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "ROS: Already enabled..");
        tradingEnabled = true;
        emit TradingEnabled(true);
    }
    
    // function to allow admin to transfer *any* BEP20 tokens from this contract..
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "ROS: amount must be greater than 0");
        require(recipient != address(0), "ROS: recipient is the zero address");
        require(tokenAddress != address(this), "ROS: Not possible to transfer ROS");
        IContract(tokenAddress).transfer(recipient, amount);
    }
    
    // function to allow admin to transfer BNB from this contract..
    function transferBNB(uint256 amount, address payable recipient) public onlyOwner {
        recipient.transfer(amount);
    }
    
    receive() external payable {}
}