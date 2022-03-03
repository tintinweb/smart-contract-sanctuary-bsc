/**
 * 
 *                                   
                        
█▀▀ █▀█ █▄░█ ▀█▀ █▀█ ▄▀█ █▀▀ ▀█▀
█▄▄ █▄█ █░▀█ ░█░ █▀▄ █▀█ █▄▄ ░█░

 
 */

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.10;

import "./IERC20.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router02.sol";
import "./Address.sol";
import "./Context.sol";
import "./Initializable.sol";
import "./MathLib.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract AidsToken is Context, IERC20, Ownable {
    using MathLib for uint256;
    using SafeMath for uint256;
    using Address for address;

    struct Balance {
        uint256 rewards;
        uint256 tokens;
    }

    struct Fees {
        uint256 reward;
        uint256 primaryLp;
        uint256 redistributionContract;
        uint256 marketingWallet;
    }

    struct ExcludedAccount {
        bool excludeFromReward;
        bool excludeFromRewardFee;
        bool excludeFromPrimaryLpFee;
        bool excludeFromRedistributionContractFee;
        bool excludeFromMarketingWalletFee;
    }

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _tokenLocked;
    mapping(address => ExcludedAccount) private _excludedAccounts;
    mapping(address => Balance) private _accountBalances;
    address payable private _primaryLpAddress;
    address payable private _redistributionContractAddress;
    address payable private _marketingWalletAddress;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tokenTotal = 500000000 * 10**9;
    uint256 private _rewardTotal = (MAX - (MAX % _tokenTotal));
    string private _name = "IAIDS";
    string private _symbol = "IAIDS";
    uint8 private _decimals = 9;
    uint256 public _rewardFeePercent = 3;
    uint256 public _marketingWalletFeePercent = 4;
    uint256 public _primaryLpFeePercent = 3;
    uint256 public _redistributionContractFeePercent = 2;
    IUniswapV2Router02 private _uniswapV2Router;
    address private _uniswapV2Pair;
    uint256 public _maxTxAmount = 500000000 * 10**9;
    uint256 private _numTokensToLiquify = 50000 * 10**9;
    bool _inLiquify;
    bool _liquifyEnabled = true;

    modifier liquifyLock {
        _inLiquify = true;
        _;
        _inLiquify = false;
    }
    event Liquify(uint256 ethToLiquidity, uint256 tokensToLiqudity);
    event LiquifyEnabledChanged(bool enabled);
    event SwapETHForTokens(uint256 amountIn, address[] path);
    event SwapTokensForETH(uint256 amountIn, address[] path);

    constructor(address primaryLpAddress, address redistributionContractAddress, address marketingWalletAddress, address uniswapRouterV2Address) {
        _primaryLpAddress = payable(primaryLpAddress);
        _redistributionContractAddress = payable(redistributionContractAddress);
        _marketingWalletAddress = payable(marketingWalletAddress);        

        _accountBalances[_msgSender()].tokens = _tokenTotal;

        _uniswapV2Router = IUniswapV2Router02(uniswapRouterV2Address);
        _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        _excludedAccounts[_msgSender()].excludeFromReward = true;
        _excludedAccounts[_msgSender()].excludeFromRewardFee = true;
        _excludedAccounts[_msgSender()].excludeFromPrimaryLpFee = true;
        _excludedAccounts[_msgSender()].excludeFromRedistributionContractFee = true;
        _excludedAccounts[_msgSender()].excludeFromMarketingWalletFee = true;
        
        _excludedAccounts[address(this)].excludeFromReward = true;
        _excludedAccounts[address(this)].excludeFromRewardFee = true;
        _excludedAccounts[address(this)].excludeFromPrimaryLpFee = true;
        _excludedAccounts[address(this)].excludeFromRedistributionContractFee = true;
        _excludedAccounts[address(this)].excludeFromMarketingWalletFee = true;

        _excludedAccounts[_primaryLpAddress].excludeFromReward = true;
        _excludedAccounts[_primaryLpAddress].excludeFromRewardFee = true;
        _excludedAccounts[_primaryLpAddress].excludeFromPrimaryLpFee = true;
        _excludedAccounts[_primaryLpAddress].excludeFromRedistributionContractFee = true;
        _excludedAccounts[_primaryLpAddress].excludeFromMarketingWalletFee = true;

        _excludedAccounts[_redistributionContractAddress].excludeFromRewardFee = true;
        _excludedAccounts[_redistributionContractAddress].excludeFromPrimaryLpFee = true;
        _excludedAccounts[_redistributionContractAddress].excludeFromRedistributionContractFee = true;
        _excludedAccounts[_redistributionContractAddress].excludeFromMarketingWalletFee = true;

        _excludedAccounts[_marketingWalletAddress].excludeFromRewardFee = true;
        _excludedAccounts[_marketingWalletAddress].excludeFromPrimaryLpFee = true;
        _excludedAccounts[_marketingWalletAddress].excludeFromRedistributionContractFee = true;
        _excludedAccounts[_marketingWalletAddress].excludeFromMarketingWalletFee = true;

        _excludedAccounts[uniswapRouterV2Address].excludeFromReward = true;
        _excludedAccounts[uniswapRouterV2Address].excludeFromRewardFee = true;
        _excludedAccounts[uniswapRouterV2Address].excludeFromPrimaryLpFee = true;
        _excludedAccounts[uniswapRouterV2Address].excludeFromRedistributionContractFee = true;
        _excludedAccounts[uniswapRouterV2Address].excludeFromMarketingWalletFee = true;    

        _excludedAccounts[_uniswapV2Pair].excludeFromReward = true;
        _excludedAccounts[_uniswapV2Pair].excludeFromRewardFee = true;
        _excludedAccounts[_uniswapV2Pair].excludeFromPrimaryLpFee = true;
        _excludedAccounts[_uniswapV2Pair].excludeFromRedistributionContractFee = true;
        _excludedAccounts[_uniswapV2Pair].excludeFromMarketingWalletFee = true;  

        emit Transfer(address(0), _msgSender(), _tokenTotal);
    }

    receive() external payable {}

    function setNumTokensToLiquify(uint256 amount) public onlyOwner
    {
        _numTokensToLiquify = amount;        
    }

    function lockTimeOfWallet() public view returns (uint256) {
        return _tokenLocked[_msgSender()];
    }

    function lockWallet(uint256 lockTime) public {
        _tokenLocked[_msgSender()] = block.timestamp + lockTime;
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
        return _tokenTotal;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if (_excludedAccounts[account].excludeFromReward)
            return _accountBalances[account].tokens;
        return tokenFromReflection(_accountBalances[account].rewards);
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        require(
            block.timestamp > _tokenLocked[_msgSender()],
            "Wallet is still locked"
        );
        transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        approve(_msgSender(), spender, amount);
        return true;
    }

    function approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        require(
            block.timestamp > _tokenLocked[sender],
            "Wallet is still locked"
        );
        transfer(sender, recipient, amount);
        approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (from != owner() && to != owner())
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        uint256 primaryLpAmount = GetAccountExcludedFromPrimaryLpFee(from)
            ? 0
            : amount.percent(_primaryLpFeePercent);
        uint256 redistributionContractAmount = GetAccountExcludedFromRedistributionContractFee(from)
            ? 0
            : amount.percent(_redistributionContractFeePercent);
        uint256 marketingWalletAmount = GetAccountExcludedFromMarketingWalletFee(from)
            ? 0
            : amount.percent(_marketingWalletFeePercent);
        uint256 rewardAmount = GetAccountExcludedFromRewardFee(from)
            ? 0
            : amount.percent(_rewardFeePercent);

        uint256 remainingAmount = amount
            .sub(primaryLpAmount)
            .sub(redistributionContractAmount)
            .sub(marketingWalletAmount)
            .sub(rewardAmount);
        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance > _numTokensToLiquify && !_inLiquify && from == _uniswapV2Pair && _liquifyEnabled) 
        {
            liquify(_numTokensToLiquify, _primaryLpAddress);
            primaryLpAmount = 0;
        }

        uint256 rewardRate = getRewardRate();
        decreaseBalance(from, amount, rewardRate);
        increaseBalance(address(this), primaryLpAmount, rewardRate);
        increaseBalance(_redistributionContractAddress, redistributionContractAmount, rewardRate);
        increaseBalance(_marketingWalletAddress, marketingWalletAmount, rewardRate);
        increaseBalance(to, remainingAmount, rewardRate);

        _rewardTotal = _rewardTotal.sub(rewardAmount.mul(rewardRate));

        emit Transfer(from, to, remainingAmount);
    }

    function increaseBalance(
        address account,
        uint256 amount,
        uint256 rewardRate
    ) private {
        if (amount <= 0)
            return;

        if (GetAccountExcludedFromReward(account)) {
            _accountBalances[account].tokens = _accountBalances[account]
                .tokens
                .add(amount);
        } else {
            _accountBalances[account].rewards = _accountBalances[account]
                .rewards
                .add(amount.mul(rewardRate));
        }
    }

    function decreaseBalance(
        address account,
        uint256 amount,
        uint256 rewardRate
    ) private {
        if (amount <= 0)
            return;
            
        if (GetAccountExcludedFromReward(account)) {
            _accountBalances[account].tokens = _accountBalances[account]
                .tokens
                .sub(amount);
        } else {
            _accountBalances[account].rewards = _accountBalances[account]
                .rewards
                .sub(amount.mul(rewardRate));
        }
    }

    function setLiquifyEnabled(bool enabled) 
        public onlyOwner() {
        _liquifyEnabled = enabled;
        emit LiquifyEnabledChanged(enabled);
    }

    function liquify(uint256 liquifyAmount, address liquidityTo)
        private
        liquifyLock
    {
        require(liquifyAmount > 0);
        uint256 tokensToLiquidity = liquifyAmount.div(2);
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(tokensToLiquidity);

        // how much ETH did we just swap into?
        uint256 ethToLiquidity = address(this).balance.sub(initialBalance);
        addLiquidity(tokensToLiquidity, ethToLiquidity, liquidityTo);

        // emit event for total liquidity added
        emit Liquify(tokensToLiquidity, ethToLiquidity);
    }

    function addLiquidity(
        uint256 tokenAmount,
        uint256 ethAmount,
        address liquidityTo
    ) private {
        // approve token transfer to cover all possible scenarios
        approve(address(this), address(_uniswapV2Router), tokenAmount);

        // add the liquidity
        _uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityTo,
            block.timestamp.add(300)
        );
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        approve(address(this), address(_uniswapV2Router), tokenAmount);

        // make the swap
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp.add(300)
        );
        emit SwapTokensForETH(tokenAmount, path);
    }

    function swapEthForTokens(
        uint256 ethAmount,
        address tokenAddress,
        address receiver
    ) private {
        // generate the uniswap pair path of weth -> token
        address[] memory path = new address[](2);
        path[0] = _uniswapV2Router.WETH();
        path[1] = tokenAddress;

        // make the swap
        _uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: ethAmount
        }(
            0, // accept any amount of ETH
            path,
            receiver,
            block.timestamp.add(300)
        );
        emit SwapETHForTokens(ethAmount, path);
    }

    function tokenFromReflection(uint256 rewardAmount)
        public
        view
        returns (uint256)
    {
        require(
            rewardAmount <= _rewardTotal,
            "Amount must be less than total reflections"
        );
        uint256 rewardRate = getRewardRate();
        return rewardAmount.div(rewardRate);
    }

    function getRewardRate() private view returns (uint256) {
        return _rewardTotal.div(_tokenTotal);
    }

    function GetAccountExcludedFromPrimaryLpFee(address account)
        public
        view
        returns (bool)
    {
        return _excludedAccounts[account].excludeFromPrimaryLpFee;
    }

    function GetAccountExcludedFromRedistributionContractFee(address account)
        public
        view
        returns (bool)
    {
        return _excludedAccounts[account].excludeFromRedistributionContractFee;
    }

    function GetAccountExcludedFromMarketingWalletFee(address account)
        public
        view
        returns (bool)
    {
        return _excludedAccounts[account].excludeFromMarketingWalletFee;
    }

    function GetAccountExcludedFromReward(address account)
        public
        view
        returns (bool)
    {
        return _excludedAccounts[account].excludeFromReward;
    }

    function GetAccountExcludedFromRewardFee(address account)
        public
        view
        returns (bool)
    {
        return _excludedAccounts[account].excludeFromRewardFee;
    }

    function SetAccountExcludedFromAllFees(address account, bool exclude)
        public
        onlyOwner
    {
        SetAccountExcludedFromReward(account, exclude);
        SetAccountExcludedFromRewardFee(account, exclude);
        SetAccountExcludedFromPrimaryLpFee(account, exclude);
        SetAccountExcludedFromRedistributionContractFee(account, exclude);
        SetAccountExcludedFromMarketingWalletFee(account, exclude);
    }

    function SetAccountExcludedFromReward(address account, bool exclude)
        public
        onlyOwner
    {
        if (_excludedAccounts[account].excludeFromReward && !exclude) {
            _excludedAccounts[account].excludeFromReward = false;
        } else if (!_excludedAccounts[account].excludeFromReward && exclude) {
            _accountBalances[account].tokens = balanceOf(account);
            _accountBalances[account].rewards = 0;
            _excludedAccounts[account].excludeFromReward = true;
        }
    }

    function SetAccountExcludedFromRewardFee(address account, bool exclude)
        public
        onlyOwner
    {
        _excludedAccounts[account].excludeFromRewardFee = exclude;
    }

    function SetAccountExcludedFromPrimaryLpFee(address account, bool exclude)
        public
        onlyOwner
    {
        _excludedAccounts[account].excludeFromPrimaryLpFee = exclude;
    }

    function SetAccountExcludedFromRedistributionContractFee(address account, bool exclude)
        public
        onlyOwner
    {
        _excludedAccounts[account].excludeFromRedistributionContractFee = exclude;
    }

    function SetAccountExcludedFromMarketingWalletFee(address account, bool exclude)
        public
        onlyOwner
    {
        _excludedAccounts[account].excludeFromMarketingWalletFee = exclude;
    }

    function GetPrimaryLpFeePercent() public view returns (uint256) {
        return _primaryLpFeePercent;
    }

    function GetRedistributionContractFeePercent() public view returns (uint256) {
        return _redistributionContractFeePercent;
    }

    function GetMarketingWalletFeePercent() public view returns (uint256) {
        return _marketingWalletFeePercent;
    }

    function GetRewardFeePercent() public view returns (uint256) {
        return _rewardFeePercent;
    }

    function SetPrimaryLpFeePercent(uint256 feePercent) public onlyOwner {
        require(feePercent <= 15, "Fee over 15%");
        require(
            feePercent +
                _marketingWalletFeePercent +
                _redistributionContractFeePercent +
                _rewardFeePercent <=
                15,
            "Total fees over 15%"
        );
        _primaryLpFeePercent = feePercent;
    }

    function SetRedistributionContractFeePercent(uint256 feePercent) public onlyOwner {
        require(feePercent <= 15, "Fee over 15%");
        require(
            feePercent +
                _marketingWalletFeePercent +
                _rewardFeePercent +
                _primaryLpFeePercent <=
                15,
            "Total fees over 15%"
        );
        _redistributionContractFeePercent = feePercent;
    }

    function SetMarketingWalletFeePercent(uint256 feePercent) public onlyOwner {
        require(feePercent <= 15, "Fee over 15%");
        require(
            feePercent +
                _rewardFeePercent +
                _redistributionContractFeePercent +
                _primaryLpFeePercent <=
                15,
            "Total fees over 15%"
        );
        _marketingWalletFeePercent = feePercent;
    }

    function SetRewardFeePercent(uint256 feePercent) public onlyOwner {
        require(feePercent <= 15, "Fee over 15%");
        require(
            feePercent +
                _marketingWalletFeePercent +
                _redistributionContractFeePercent +
                _primaryLpFeePercent <=
                100,
            "Total fees over 15%"
        );
        _rewardFeePercent = feePercent;
    }

    function SetPrimaryLpAddress(address primaryLpAddress) public onlyOwner {
        _primaryLpAddress = payable(primaryLpAddress);
    }

    function SetRedistributionContractAddress(address redistributionContractAddress)
        public
        onlyOwner
    {
        _redistributionContractAddress = payable(redistributionContractAddress);
    }

    function SetMarketingWalletAddress(address marketingWalletAddress) public onlyOwner {
        _marketingWalletAddress = payable(marketingWalletAddress);
    }

    function GetPrimaryLpAddress() public view returns (address) {
        return _primaryLpAddress;
    }

    function GetRedistributionContractAddress() public view returns (address) {
        return _redistributionContractAddress;
    }

    function GetMarketingWalletAddress() public view returns (address) {
        return _marketingWalletAddress;
    }

    function SetUniswapV2Router(address uniswapV2RouterAddress)
        public
        onlyOwner
    {
        _uniswapV2Router = IUniswapV2Router02(uniswapV2RouterAddress);
        _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
    }
}