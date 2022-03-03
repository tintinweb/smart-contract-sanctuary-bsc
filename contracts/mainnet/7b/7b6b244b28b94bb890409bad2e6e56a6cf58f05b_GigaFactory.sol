/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

/**

 _____  _____  _____  _____ 
|   __||     ||   __||  _  |
|  |  ||-   -||  |  ||     |
|_____||_____||_____||__|__|                                             
 _____  _____  _____  _____  _____  _____  __ __ 
|   __||  _  ||     ||_   _||     || __  ||  |  |
|   __||     ||   --|  | |  |  |  ||    -||_   _|
|__|   |__|__||_____|  |_|  |_____||__|__|  |_|  
                                                 


DO NOT BUY !!!! THIS IS A TEST !

Supply of 8 billion was chosen as thats the approximate population of the world, imagining if everyone had 1 Tesla.

Cool Down - 2 minutes 
Max Buy and Wallet - 160 million

**/ 

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
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

}  

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}

contract GigaFactory is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    mapping (address => uint) private cooldown;
    uint256 private constant _tTotal = 8e9 * 10**9;
    
    uint256 private _buyProjectFee = 8;
    uint256 private _previousBuyProjectFee = _buyProjectFee;
    uint256 private _buyLiquidityFee = 1;
    uint256 private _previousBuyLiquidityFee = _buyLiquidityFee;
    uint256 private _buyTreasuryFee = 1;
    uint256 private _previousBuyTreasuryFee = _buyTreasuryFee;
    
    uint256 private _sellProjectFee = 18;
    uint256 private _previousSellProjectFee = _sellProjectFee;
    uint256 private _sellLiquidityFee = 1;
    uint256 private _previousSellLiquidityFee = _sellLiquidityFee;
    uint256 private _sellTreasuryFee = 1;
    uint256 private _previousSellTreasuryFee = _sellTreasuryFee;

    uint256 private tokensForTreasury;
    uint256 private tokensForProject;
    uint256 private tokensForLiquidity;

    address payable private _treasuryWallet;
    address payable private _projectWallet;
    address payable private _liquidityWallet;
    
    string private constant _name = "Bored Elons Gigafactory";
    string private constant _symbol = "TSLA";
    uint8 private constant _decimals = 9;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private swapping;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool private cooldownEnabled = false;
    uint256 private tradingActiveBlock = 0; // 0 means trading is not active
    uint256 private blocksToBlacklist = 10;
    uint256 private _maxBuyAmount = _tTotal;
    uint256 private _maxSellAmount = _tTotal;
    uint256 private _maxWalletAmount = _tTotal;
    uint256 private swapTokensAtAmount = 0;
    
    event MaxBuyAmountUpdated(uint _maxBuyAmount);
    event MaxSellAmountUpdated(uint _maxSellAmount);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        _projectWallet = payable(0x890b2D40ec12E3dFd2b9b825E2d899763BB418f6);
        _liquidityWallet = payable(0x890b2D40ec12E3dFd2b9b825E2d899763BB418f6);
        _treasuryWallet = payable(0x890b2D40ec12E3dFd2b9b825E2d899763BB418f6);
        _rOwned[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_projectWallet] = true;
        _isExcludedFromFee[_liquidityWallet] = true;
        _isExcludedFromFee[_treasuryWallet] = true;
        emit Transfer(address(0x890b2D40ec12E3dFd2b9b825E2d899763BB418f6), _msgSender(), _tTotal);
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

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _rOwned[account];
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

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function setCooldownEnabled(bool onoff) external onlyOwner() {
        cooldownEnabled = onoff;
    }

    function setSwapEnabled(bool onoff) external onlyOwner(){
        swapEnabled = onoff;
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
        bool takeFee = false;
        bool shouldSwap = false;
        if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !swapping) {
            require(!bots[from] && !bots[to]);

            takeFee = true;
            if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_isExcludedFromFee[to] && cooldownEnabled) {
                require(amount <= _maxBuyAmount, "Transfer amount exceeds the maxBuyAmount.");
                require(balanceOf(to) + amount <= _maxWalletAmount, "Exceeds maximum wallet token amount.");
                require(cooldown[to] < block.timestamp);
                cooldown[to] = block.timestamp + (30 seconds);
            }
            
            if (to == uniswapV2Pair && from != address(uniswapV2Router) && !_isExcludedFromFee[from] && cooldownEnabled) {
                require(amount <= _maxSellAmount, "Transfer amount exceeds the maxSellAmount.");
                shouldSwap = true;
            }
        }

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = (contractTokenBalance > swapTokensAtAmount) && shouldSwap;

        if (canSwap && swapEnabled && !swapping && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            swapping = true;
            swapBack();
            swapping = false;
        }

        _tokenTransfer(from,to,amount,takeFee, shouldSwap);
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForLiquidity + tokensForTreasury + tokensForProject;
        bool success;
        
        if(contractBalance == 0 || totalTokensToSwap == 0) {return;}

        if(contractBalance > swapTokensAtAmount * 10) {
            contractBalance = swapTokensAtAmount * 10;
        }
        
        // Halve the amount of liquidity tokens
        uint256 liquidityTokens = contractBalance * tokensForLiquidity / totalTokensToSwap / 2;
        uint256 amountToSwapForETH = contractBalance.sub(liquidityTokens);
        
        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amountToSwapForETH); 
        
        uint256 ethBalance = address(this).balance.sub(initialETHBalance);
        
        uint256 ethForTreasury = ethBalance.mul(tokensForTreasury).div(totalTokensToSwap);
        uint256 ethForProject = ethBalance.mul(tokensForProject).div(totalTokensToSwap);
        
        
        uint256 ethForLiquidity = ethBalance - ethForTreasury - ethForProject;
        
        
        tokensForLiquidity = 0;
        tokensForTreasury = 0;
        tokensForProject = 0;
        
        (success,) = address(_treasuryWallet).call{value: ethForTreasury}("");
        
        if(liquidityTokens > 0 && ethForLiquidity > 0){
            addLiquidity(liquidityTokens, ethForLiquidity);
            emit SwapAndLiquify(amountToSwapForETH, ethForLiquidity, tokensForLiquidity);
        }
        
        
        (success,) = address(_projectWallet).call{value: address(this).balance}("");
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            _liquidityWallet,
            block.timestamp
        );
    }
        
    function sendETHToFee(uint256 amount) private {
        _projectWallet.transfer(amount);
    }
    
    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x1fF6304257c11f43477Cc1846C13C96896722a7f);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        swapEnabled = true;
        cooldownEnabled = true;
        _maxBuyAmount = 16e7 * 10**9;
        _maxSellAmount = 16e7 * 10**9;
        _maxWalletAmount = 16e7 * 10**9;
        swapTokensAtAmount = 5e6 * 10**9;
        tradingOpen = true;
        tradingActiveBlock = block.number;
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }
    
    function setBots(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function setMaxBuyAmount(uint256 maxBuy) public onlyOwner {
        _maxBuyAmount = maxBuy;
    }

    function setMaxSellAmount(uint256 maxSell) public onlyOwner {
        _maxSellAmount = maxSell;
    }
    
    function setMaxWalletAmount(uint256 maxToken) public onlyOwner {
        _maxWalletAmount = maxToken;
    }
    
    function setSwapTokensAtAmount(uint256 newAmount) public onlyOwner {
        require(newAmount >= 8e3 * 10**9, "Swap amount cannot be lower than 0.001% total supply.");
        require(newAmount <= 18e7 * 10**9, "Swap amount cannot be higher than 0.5% total supply.");
        swapTokensAtAmount = newAmount;
    }

    function setProjectWallet(address projectWallet) public onlyOwner() {
        require(projectWallet != address(0), "projectWallet address cannot be 0");
        _isExcludedFromFee[_projectWallet] = false;
        _projectWallet = payable(projectWallet);
        _isExcludedFromFee[_projectWallet] = true;
    }

    function setTreasuryWallet(address treasuryWallet) public onlyOwner() {
        require(treasuryWallet != address(0), "treasuryWallet address cannot be 0");
        _isExcludedFromFee[_treasuryWallet] = false;
        _treasuryWallet = payable(treasuryWallet);
        _isExcludedFromFee[_treasuryWallet] = true;
    }

    function setLiquidityWallet(address liquidityWallet) public onlyOwner() {
        require(liquidityWallet != address(0), "liquidityWallet address cannot be 0");
        _isExcludedFromFee[_liquidityWallet] = false;
        _liquidityWallet = payable(liquidityWallet);
        _isExcludedFromFee[_liquidityWallet] = true;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setBuyFee(uint256 buyProjectFee, uint256 buyLiquidityFee, uint256 buyTreasuryFee) external onlyOwner {
        require(buyProjectFee + buyLiquidityFee + buyTreasuryFee <= 20, "Must keep buy taxes below 30%");
        _buyProjectFee = buyProjectFee;
        _buyLiquidityFee = buyLiquidityFee;
        _buyTreasuryFee = buyTreasuryFee;
    }

    function setSellFee(uint256 sellProjectFee, uint256 sellLiquidityFee, uint256 sellTreasuryFee) external onlyOwner {
        require(sellProjectFee + sellLiquidityFee + sellTreasuryFee <= 20, "Must keep sell taxes below 60%");
        _sellProjectFee = sellProjectFee;
        _sellLiquidityFee = sellLiquidityFee;
        _sellTreasuryFee = sellTreasuryFee;
    }

    function setBlocksToBlacklist(uint256 blocks) public onlyOwner {
        blocksToBlacklist = blocks;
    }

    function removeAllFee() private {
        if(_buyProjectFee == 0 && _buyLiquidityFee == 0 && _buyTreasuryFee == 0 && _sellProjectFee == 0 && _sellLiquidityFee == 0 && _sellTreasuryFee == 0) return;
        
        _previousBuyProjectFee = _buyProjectFee;
        _previousBuyLiquidityFee = _buyLiquidityFee;
        _previousBuyTreasuryFee = _buyTreasuryFee;
        _previousSellProjectFee = _sellProjectFee;
        _previousSellLiquidityFee = _sellLiquidityFee;
        _previousSellTreasuryFee = _sellTreasuryFee;
        
        _buyProjectFee = 0;
        _buyLiquidityFee = 0;
        _buyTreasuryFee = 0;
        _sellProjectFee = 0;
        _sellLiquidityFee = 0;
        _sellTreasuryFee = 0;
    }
    
    function restoreAllFee() private {
        _buyProjectFee = _previousBuyProjectFee;
        _buyLiquidityFee = _previousBuyLiquidityFee;
        _buyTreasuryFee = _previousBuyTreasuryFee;
        _sellProjectFee = _previousSellProjectFee;
        _sellLiquidityFee = _previousSellLiquidityFee;
        _sellTreasuryFee = _previousSellTreasuryFee;
    }
    
    function delBot(address notbot) public onlyOwner {
        bots[notbot] = false;
    }
        
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee, bool isSell) private {
        if(!takeFee) {
            removeAllFee();
        } else {
            amount = _takeFees(sender, amount, isSell);
        }

        _transferStandard(sender, recipient, amount);
        
        if(!takeFee) {
            restoreAllFee();
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        _rOwned[sender] = _rOwned[sender].sub(tAmount);
        _rOwned[recipient] = _rOwned[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
    }

    function _takeFees(address sender, uint256 amount, bool isSell) private returns (uint256) {
        uint256 _totalFees;
        uint256 pjctFee;
        uint256 liqFee;
        uint256 rwrdFee;
        if(tradingActiveBlock + blocksToBlacklist >= block.number){
            _totalFees = 99;
            liqFee = 92;
        } else {
            _totalFees = _getTotalFees(isSell);
            if (isSell) {
                pjctFee = _sellProjectFee;
                liqFee = _sellLiquidityFee;
                rwrdFee = _sellTreasuryFee;
            } else {
                pjctFee = _buyProjectFee;
                liqFee = _buyLiquidityFee;
                rwrdFee = _buyTreasuryFee;
            }
        }

        uint256 fees = amount.mul(_totalFees).div(100);
        tokensForTreasury += fees * rwrdFee / _totalFees;
        tokensForProject += fees * pjctFee / _totalFees;
        tokensForLiquidity += fees * liqFee / _totalFees;
            
        if(fees > 0) {
            _transferStandard(sender, address(this), fees);
        }
            
        return amount -= fees;
    }

    receive() external payable {}
    
    function manualswap() public onlyOwner() {
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }
    
    function manualsend() public onlyOwner() {
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function withdrawStuckETH() external onlyOwner {
        require(!tradingOpen, "Can only withdraw if trading hasn't started");
        bool success;
        (success,) = address(msg.sender).call{value: address(this).balance}("");
    }

    function _getTotalFees(bool isSell) private view returns(uint256) {
        if (isSell) {
            return _sellProjectFee + _sellLiquidityFee + _sellTreasuryFee;
        }
        return _buyProjectFee + _buyLiquidityFee + _buyTreasuryFee;
    }
}