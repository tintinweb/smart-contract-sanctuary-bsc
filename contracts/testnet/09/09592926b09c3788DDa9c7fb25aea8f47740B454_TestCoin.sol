// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "../contracts/Ownable2.sol";
import "./ICrossChainBridgeRouter.sol";

contract TestCoin is IERC20, Ownable {
    using SafeMath for uint256;

    address dead = 0x000000000000000000000000000000000000dEaD;
    address zero = address(0);

    uint8 public maxLiqFee = 10;
    uint8 public maxTaxFee = 10;
    uint8 public maxBurnFee = 10;
    uint8 public maxWalletFee = 10;
    uint8 public maxBuybackFee = 10;
    uint8 public minMxTxPercentage = 1;
    uint8 public minMxWalletPercentage = 1;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 public _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    string public _name;
    string public _symbol;
    uint8 private _decimals = 18;

    uint8 public _taxFee = 0; // Fee for Reflection
    uint8 private _previousTaxFee = _taxFee;

    uint8 public _liquidityFee = 0; // Fee for Liquidity
    uint8 private _previousLiquidityFee = _liquidityFee;

    uint8 public _burnFee = 0; // Fee for burning
    uint8 private _previousBurnFee = _burnFee;

    uint8 public _walletFee = 0; // Fee to marketing/charity wallet
    uint8 private _previousWalletFee = _walletFee;

    uint8 public _buybackFee = 0; // Fee for buyback of tokens
    uint8 private _previousBuybackFee = _buybackFee;

    // Setup router address
    address public immutable ccbRouterAddress = 0x6D7A00FD1C03Af5B5283d9018AD9484aB26F57f4;
    ICrossChainBridgeRouter private ccbRouter;

    IUniswapV2Router02 public swapV2Router;
    address public swapV2Pair;
    address payable public feeWallet;
    bool public swapHasBeenInit = false;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 public numTokensSellToAddToLiquidity;
    uint256 private buyBackUpperLimit = 1 * 10**18;
    address payable private _initialOwner;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    uint8 private supplyHasBeenMinted = 0;

    constructor(
        string memory __token_name,
        string memory __token_symbol,
        uint256 __token_initial,
        uint8 __token_tax_reflection,
        uint8 __token_tax_wallet,
        uint8 __token_tax_burn,
        uint8 __token_tax_liquidity,
        uint8 __token_tax_buyback,
        address payable __setup_wallet_address
    ) {
        _name = __token_name;
        _symbol = __token_symbol;
        _tTotal = __token_initial; // Start with 1 token
        _rTotal = (MAX - (MAX % _tTotal));
        // Used as the setup wallet, must be the same on each chain. Use transferownership to change on chain.
        _initialOwner = __setup_wallet_address;
        // Make the setup the owner, not the deployer, overrides the init function in the Open Zeppelin Ownable contract
        _transferOwnership(_initialOwner);

        // Setup 0.001% of total supply allowed for buy back
        buyBackUpperLimit = _tTotal.mul(1).div(10000);
        // 0.01% of supply of the initial total 
        numTokensSellToAddToLiquidity = _tTotal.mul(1).div(1000);

        _rOwned[_initialOwner] = _rTotal; 

        feeWallet = payable(_initialOwner);


        // load ccbRouter contract and store in immutable variable
        ccbRouter = ICrossChainBridgeRouter(ccbRouterAddress);
        
        // set up indefinite approval for all future interactions with the ccbRouter
        _approve(address(this), ccbRouterAddress, type(uint256).max);

        // // create LP token and pools (that will be used to collect bridging fee rewards)
        // ccbRouter.createPools(address(this), true, true, false);

        // IUniswapV2Router02 _swapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // // Create a uniswap pair for this new token
        // swapV2Pair = IUniswapV2Factory(_swapV2Router.factory()).createPair(address(this), _swapV2Router.WETH());

        // // set the rest of the contract variables
        // swapV2Router = _swapV2Router;

        _isExcludedFromFee[_initialOwner] = true;
        _isExcludedFromFee[address(this)] = true;

        _taxFee = __token_tax_reflection;
        _liquidityFee = __token_tax_liquidity;
        _burnFee = __token_tax_burn;
        _buybackFee = __token_tax_buyback;
        _walletFee = __token_tax_wallet;

        emit Transfer(address(0), _initialOwner, _tTotal);
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
        return true;
    }

      // Mint supply on chain, max two attempts, also set max wallet holding
     function setInitialSupply(uint256 mintSupplyTotal) external onlyOwner {
         // You have 2 tries to get your supply correct on chain before it will fail
        require(supplyHasBeenMinted <= 1, "You have already minted you supply"); 
        _tTotal += mintSupplyTotal;
        // maxWallet = _tTotal/maxWalletHoldingPercentage; // 99 = 1%, 98 = 2%, 97 = 3%, 2 = 50%, 1 = 100%
        _rOwned[_msgSender()] = _rTotal; 
        // Setup 0.001% of total supply allowed for buy back
        buyBackUpperLimit = _rTotal.mul(1).div(10000);
        emit Transfer(address(0),owner(), _tTotal);
        supplyHasBeenMinted ++;
    }

    // Used on chain to setup the router
    function setSwapRouterAddress(address swapRouter) external onlyOwner {
        // require(!swapHasBeenInit, "You have already setup the swap pair");

        IUniswapV2Router02 _swapV2Router = IUniswapV2Router02(swapRouter);
        // Create a uniswap pair for this new token
        swapV2Pair = IUniswapV2Factory(_swapV2Router.factory()).createPair(address(this), _swapV2Router.WETH());

        // set the rest of the contract variables
        swapV2Router = _swapV2Router;
        // Setup 0.001% of total supply allowed for buy back
        buyBackUpperLimit = _tTotal.mul(1).div(10000);
        swapHasBeenInit = true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount, , , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns (uint256) {
        require(tAmount <= _tTotal, "Amt must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, "Amt must be less than tot refl");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        if (!_isExcluded[account]) {
            if (_rOwned[account] > 0) {
                _tOwned[account] = tokenFromReflection(_rOwned[account]);
            }
            _isExcluded[account] = true;
            _excluded.push(account);
        }
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Already excluded");
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

    function setAllFeePercent(
        uint8 taxFee,
        uint8 liquidityFee,
        uint8 burnFee,
        uint8 walletFee,
        uint8 buybackFee
    ) external onlyOwner {
        require(taxFee >= 0 && taxFee <= maxTaxFee, "TF error");
        require(liquidityFee >= 0 && liquidityFee <= maxLiqFee, "LF error");
        require(burnFee >= 0 && burnFee <= maxBurnFee, "BF error");
        require(walletFee >= 0 && walletFee <= maxWalletFee, "WF error");
        require(buybackFee >= 0 && buybackFee <= maxBuybackFee, "BBF error");
        _taxFee = taxFee;
        _liquidityFee = liquidityFee;
        _burnFee = burnFee;
        _buybackFee = buybackFee;
        _walletFee = walletFee;
    }

    function buyBackUpperLimitAmount() public view returns (uint256) {
        return buyBackUpperLimit;
    }

    function setBuybackUpperLimit(uint256 buyBackLimit) external onlyOwner {
        buyBackUpperLimit = buyBackLimit * 10**_decimals;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setFeeWallet(address payable newFeeWallet) external onlyOwner {
        require(newFeeWallet != address(0), "ZERO ADDRESS");
        excludeFromReward(newFeeWallet);
        feeWallet = newFeeWallet;
    }

    //to recieve ETH from swapV2Router when swaping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
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

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)]) _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**2);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee + _burnFee + _walletFee + _buybackFee).div(10**2);
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _liquidityFee == 0 && _burnFee == 0 && _walletFee == 0 && _buybackFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousBurnFee = _burnFee;
        _previousWalletFee = _walletFee;
        _previousBuybackFee = _buybackFee;

        _taxFee = 0;
        _liquidityFee = 0;
        _burnFee = 0;
        _walletFee = 0;
        _buybackFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _burnFee = _previousBurnFee;
        _walletFee = _previousWalletFee;
        _buybackFee = _previousBuybackFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from zero address");
        require(spender != address(0), "ERC20: approve to zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from zero address");
        require(to != address(0), "ERC20: transfer to zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 contractTokenBalance = balanceOf(address(this));

        if (!inSwapAndLiquify && to == swapV2Pair && swapAndLiquifyEnabled) {
            if (contractTokenBalance >= numTokensSellToAddToLiquidity) {
                contractTokenBalance = numTokensSellToAddToLiquidity;
                //add liquidity
                swapAndLiquify(contractTokenBalance);
            }
            if (_buybackFee != 0) {
                uint256 balance = address(this).balance;
                if (balance > uint256(1 * 10**_decimals)) {
                    if (balance > buyBackUpperLimit) {
                        balance = buyBackUpperLimit;
                    }

                    buyBackTokens(balance.mul(50).div(100));
                }
            }
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        //This needs to be distributed among burn, wallet and liquidity
        //burn
        uint8 totFee = _burnFee + _walletFee + _liquidityFee + _buybackFee;
        uint256 spentAmount = 0;
        uint256 totSpentAmount = 0;
        if (_burnFee != 0) {
            spentAmount = contractTokenBalance.div(totFee).mul(_burnFee);
            _tokenTransferNoFee(address(this), dead, spentAmount);
            totSpentAmount = spentAmount;
        }

        if (_walletFee != 0) {
            spentAmount = contractTokenBalance.div(totFee).mul(_walletFee);
            _tokenTransferNoFee(address(this), feeWallet, spentAmount);
            totSpentAmount = totSpentAmount + spentAmount;
        }

        if (_buybackFee != 0) {
            spentAmount = contractTokenBalance.div(totFee).mul(_buybackFee);
            swapTokensForBNB(spentAmount);
            totSpentAmount = totSpentAmount + spentAmount;
        }

        if (_liquidityFee != 0) {
            contractTokenBalance = contractTokenBalance.sub(totSpentAmount);

            // split the contract balance into halves
            uint256 half = contractTokenBalance.div(2);
            uint256 otherHalf = contractTokenBalance.sub(half);

            // capture the contract's current ETH balance.
            // this is so that we can capture exactly the amount of ETH that the
            // swap creates, and not make the liquidity event include any ETH that
            // has been manually sent to the contract
            uint256 initialBalance = address(this).balance;

            // swap tokens for ETH/BNB/MATIC etc
            swapTokensForBNB(half); // <- this breaks the ETH -> Swap when swap+liquify is triggered

            // how much ETH did we just swap into?
            uint256 newBalance = address(this).balance.sub(initialBalance);

            // add liquidity to uniswap
            addLiquidity(otherHalf, newBalance);

            emit SwapAndLiquify(half, newBalance, otherHalf);
        }
    }

    function buyBackTokens(uint256 amount) private lockTheSwap {
        if (amount > 0) {
            swapBNBForTokens(amount);
        }
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapV2Router.WETH();

        _approve(address(this), address(swapV2Router), tokenAmount);

        // make the swap
        swapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp.add(300)
        );
    }

    function swapBNBForTokens(uint256 amount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = swapV2Router.WETH();
        path[1] = address(this);

        // make the swap
        swapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path,
            dead, // Burn address
            block.timestamp.add(300)
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(swapV2Router), tokenAmount);

        // add the liquidity
        swapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            dead,
            block.timestamp.add(300)
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();

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

        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _tokenTransferNoFee(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _rOwned[sender] = _rOwned[sender].sub(amount);
        _rOwned[recipient] = _rOwned[recipient].add(amount);

        if (_isExcluded[sender]) {
            _tOwned[sender] = _tOwned[sender].sub(amount);
        }
        if (_isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient].add(amount);
        }
        emit Transfer(sender, recipient, amount);
    }

    function recoverToken(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        // do not allow recovering self token
        require(tokenAddress != address(this), "Self withdraw");
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICrossChainBridgeRouter {

  // addresses of other ccb-related contracts
  function bridgeChef () external returns(address);
  function bridgeERC20 () external returns(address);
  function liquidityManager () external returns(address);
  function bridgeERC721 () external returns(address);
  function liquidityMiningPools () external returns(address);
  function rewardPools () external returns(address);

    // ###################################################################################################################
  // ********************************************** BRIDGE ERC20 *******************************************************
  // ###################################################################################################################
  // ------------------------------------------------- DEPOSIT  --------------------------------------------------------

  /**
   * @notice Accepts ERC20 token deposits that should be bridged into another network
   * (effectively starting a new bridge transaction)
   *
   * @param token the ERC20 contract the to-be-bridged token was issued with
   * @param amount the amount that is being deposited
   * @param receiverAddress target address the bridged token should be sent to (in the target network)
   * @param targetChainId chain ID of the target network
   *
   * @dev emits event TokensDeposited after successful deposit
   */
  function depositERC20TokensToBridge(
    IERC20 token,
    uint256 amount,
    address receiverAddress,
    uint256 targetChainId
  ) external payable;

  /**
   * @notice Accepts native token deposits that should be bridged into another network
   * (effectively starting a new bridge transaction)
   *
   * @param amount the amount that is being deposited
   * @param receiverAddress target address the bridged token should be sent to (in the target network)
   * @param targetChainId chain ID of the target network
   * @dev emits event TokensDeposited after successful deposit
   */
  function depositNativeTokensToBridge(
    uint256 amount,
    address receiverAddress,
    uint256 targetChainId
  ) external payable;

  // ------------------------------------------------- RELEASE  --------------------------------------------------------

  /**
   * @notice Releases ERC20 tokens in this network after a deposit was made in another network
   *         (effectively completing a bridge transaction)
   *
   * @param sigV Array of recovery Ids for the signature
   * @param sigR Array of R values of the signatures
   * @param sigS Array of S values of the signatures
   * @param receiverAddress The account to receive the tokens
   * @param sourceNetworkTokenAddress the address of the ERC20 contract in the network the deposit was made
   * @param amount The amount of tokens to be released
   * @param depositChainId chain ID of the network in which the deposit was made
   * @param depositNumber The identifier of the corresponding deposit
   * @dev emits event TokensReleased after successful release
   */
  function releaseERC20TokenBridgeDeposit(
    uint8[] memory sigV,
    bytes32[] memory sigR,
    bytes32[] memory sigS,
    address receiverAddress,
    address sourceNetworkTokenAddress,
    uint256 amount,
    uint256 depositChainId,
    uint256 depositNumber
  ) external payable;

  /**
   * @notice Releases native tokens in this network that were deposited in another network
   *         (effectively completing a bridge transaction)
   *
   * @param sigV Array of recovery Ids for the signature
   * @param sigR Array of R values of the signatures
   * @param sigS Array of S values of the signatures
   * @param receiverAddress The account to receive the tokens
   * @param sourceNetworkTokenAddress the address of the ERC20 contract in the network the deposit was made
   * @param amount The amount of tokens to be released
   * @param depositChainId chain ID of the network in which the deposit was made
   * @param depositNumber The identifier of the corresponding deposit
   * @dev emits event TokensReleased after successful release
   */
  function releaseNativeTokenBridgeDeposit(
    uint8[] memory sigV,
    bytes32[] memory sigR,
    bytes32[] memory sigS,
    address receiverAddress,
    address sourceNetworkTokenAddress,
    uint256 amount,
    uint256 depositChainId,
    uint256 depositNumber
  ) external payable;

  // ------------------------------------------ GET BRIDGE FEE QUOTE ---------------------------------------------------

  /**
   * @notice Returns the estimated bridge fee for a specific ERC20 token and bridge amount
   *
   * @param tokenAddress the address of the token that should be bridged
   * @param amountToBeBridged the amount to be bridged
   * @return bridgeFee the estimated bridge fee (in to-be-bridged token)
   */
  function getERC20BridgeFeeQuote(address tokenAddress, uint256 amountToBeBridged)
    external
    view
    returns (uint256 bridgeFee);

  // ###################################################################################################################
  // ********************************************** BRIDGE ERC721 ******************************************************
  // ###################################################################################################################
  // ------------------------------------------------- DEPOSIT  --------------------------------------------------------

  /**
   * @notice Deposits an ERC721 token into the bridge (effectively starting a bridge transaction)
   *
   * @dev the collection must be whitelisted by the bridge or the call will be reverted
   *
   * @param collectionAddress the address of the ERC721 contract the collection was issued with
   * @param tokenId the (native) ID of the ERC721 token that should be bridged
   * @param receiverAddress target address the bridged token should be sent to
   * @param targetChainId chain ID of the target network
   *
   * @dev emits event TokenDeposited after successful deposit
   */
  function depositERC721TokenToBridge(
    address collectionAddress,
    uint256 tokenId,
    address receiverAddress,
    uint256 targetChainId
  ) external payable;

  // ------------------------------------------------- RELEASE  --------------------------------------------------------

  /**
   * @notice Releases an ERC721 token in this network after a deposit was made in another network
   *         (effectively completing a bridge transaction)
   *
   * @param sigV Array of recovery Ids for the signature
   * @param sigR Array of R values of the signatures
   * @param sigS Array of S values of the signatures
   * @param receiverAddress The account to receive the tokens
   * @param sourceNetworkCollectionAddress the address of the ERC721 contract in the network the deposit was made
   * @param tokenId The token id to be sent
   * @param depositChainId chain ID of the network in which the deposit was made
   * @param depositNumber The identifier of the corresponding deposit
   *
   * @dev emits event TokenReleased after successful release
   */
  function releaseERC721TokenDeposit(
    uint8[] memory sigV,
    bytes32[] memory sigR,
    bytes32[] memory sigS,
    address receiverAddress,
    address sourceNetworkCollectionAddress,
    uint256 tokenId,
    uint256 depositChainId,
    uint256 depositNumber
  ) external payable;

  // ------------------------------------------ GET BRIDGING FEE QUOTE -------------------------------------------------

  /**
   * @notice Returns the estimated fee for bridging one token of a specific ERC721 collection in native currency
   *         (e.g. ETH, BSC, MATIC, AVAX, FTM)
   *
   * @param collectionAddress the address of the collection
   * @return bridgeFee the estimated bridge fee (in network-native currency)
   */
  function getERC721BridgeFeeQuote(address collectionAddress) external view returns (uint256 bridgeFee);

  // ###################################################################################################################
  // ******************************************** MANAGE LIQUIDITY *****************************************************
  // ###################################################################################################################
  // ----------------------------------------- ADD LIQUIDITY TO BRIDGE -------------------------------------------------

  /**
   * @notice Adds ERC20 liquidity to an existing pool or creates a new one, if none exists for the provided token
   *
   * @param token the address of the token for which liquidity should be added
   * @param amount the amount of tokens to be added
   *
   * @dev emits event LiquidityPoolCreated (only if a new pool is created)
   * @dev emits event LiquidityAdded after successful deposit
   */
  function addLiquidityERC20(IERC20 token, uint256 amount) external payable;

  /**
   * @notice Adds native liquidity to an existing pool or creates a new one, if it does not exist yet
   *
   * @param amount the amount of native tokens to be added
   *
   * @dev emits event LiquidityPoolCreated (only if a new pool is created)
   * @dev emits event LiquidityAdded after successful deposit
   */
  function addLiquidityNative(uint256 amount) external payable;

  // TODO CONTINUE HERE
  // --------------------------------------- REMOVE LIQUIDITY FROM BRIDGE ----------------------------------------------
  /**
   * @notice Burns LP tokens and removes previously provided ERC20 liquidity from the bridge
   *
   * @param token the token for which liquidity should be removed from this pool
   *
   * @dev emits event LiquidityRemoved
   */
  function withdrawLiquidityERC20(IERC20 token, uint256 amount) external payable;

  /**
   * @notice Removes native (i.e. in the network-native token) liquidity from a liquidity pool
   *
   * @param amount the amount of liquidity to be removed
   *
   * @dev emits event LiquidityRemoved
   */
  function withdrawLiquidityNative(uint256 amount) external payable;

  // -------------------------------- REMOVE LIQUIDITY & BRIDGE TO ANOTHER NETWORK -------------------------------------
  /**
   * @notice Burns LP tokens and creates a bridge deposit in the amount of "burned LPTokens - withdrawal fee"
   *         For cases when no liquidity is available on the network the user provided liquidity in
   *
   * @param token the address of the ERC20 token in which liquidity was provided
   * @param amount the amount of the withdrawal
   * @param receiverAddress target address the bridged token should be sent to (in the target network)
   * @param targetChainId chain ID of the target network
   *
   * @dev emits event TokensDeposited after successful deposit
   */
  function withdrawLiquidityInAnotherNetwork(
    IERC20 token,
    uint256 amount,
    address receiverAddress,
    uint256 targetChainId
  ) external payable;

  // ---------------------------------------- GET LIQUIDITY WITHDRAWAL FEE ---------------------------------------------
  /**
   * @notice Returns the liquidity withdrawal fee amount for the given token
   *
   * @param token the address of the ERC20 token in which liquidity was provided
   * @param withdrawalAmount the amount of tokens to be withdrawn
   *
   */
  function getLiquidityWithdrawalFeeAmount(IERC20 token, uint256 withdrawalAmount) external view returns (uint256);

  // ###################################################################################################################
  // ***************************************** LIQUIDITY MINING POOLS **************************************************
  // ###################################################################################################################
  // ------------------------------------- STAKE LP TOKENS IN MINING POOLS ---------------------------------------------
  /**
   * @notice Adds LP tokens to the liquidity mining pool of the given token
   *
   * @param tokenAddress the address of the underlying token of the pool
   * @param amount the amount of LP tokens that should be staked
   *
   * @dev emits event StakeAdded
   */
  function stakeLpTokensInMiningPool(address tokenAddress, uint256 amount) external payable;

  // ----------------------------------- UNSTAKE LP TOKENS FROM MINING POOLS -------------------------------------------
  /**
   * @notice Withdraws staked LP tokens from the liquidity mining pool after harvesting available rewards, if any
   *
   * @param tokenAddress the address of the underlying token of the liquidity mining pool
   * @param amount the amount of LP tokens that should be unstaked
   *
   * @dev emits event RewardsHarvested, if rewards are available for harvesting
   * @dev emits event StakeAdded
   */
  function unstakeLpTokensFromMiningPool(address tokenAddress, uint256 amount) external payable;

  // -------------------------------- CHECK & HARVEST REWARDS FROM MINING POOLS ----------------------------------------
  /**
   * @notice Returns the amount of unharvested rewards for a specific address in the given liquidity mining pool
   *
   * @param tokenAddress the address of the underlying token of the reward pool
   * @param stakerAddress the address of the staker for which pending rewards should be returned
   * @return the unharvested reward amount
   */
  function pendingMiningPoolRewards(address tokenAddress, address stakerAddress) external view returns (uint256);

  /**
   * @notice Distributes unharvested staking rewards from the given liquidity mining pool
   *
   * @param tokenAddress the address of the underlying token of the pool
   * @param stakerAddress the address for which the unharvested rewards should be distributed
   *
   * @dev emits event RewardsHarvested
   */
  function harvestFromMiningPool(address tokenAddress, address stakerAddress) external payable;

  // ###################################################################################################################
  // ******************************************* BRIDGE CHEF FARMS *****************************************************
  // ###################################################################################################################
  // ----------------------------------------- STAKE LP TOKENS IN FARMS ------------------------------------------------

  /**
   * @notice Adds liquidity provider (LP) tokens to the given farm for the user to start earning BRIDGE tokens
   *
   * @param farmId the ID of the liquidity farm
   * @param amount LP token amount to be deposited
   *
   * @dev emits event DepositAdded after the deposit was successfully added
   */
  function stakeLpTokensInFarm(uint256 farmId, uint256 amount) external payable;

  // --------------------------------------- UNSTAKE LP TOKENS FROM FARMS ----------------------------------------------

  /**
   * @notice Withdraws liquidity provider (LP) tokens from the given farm
   *
   * @param farmId the ID of the liquidity farm
   * @param amount LP token amount to withdraw
   *
   * @dev emits event FundsWithdrawn after successful withdrawal
   */
  function unstakeLpTokensFromFarm(uint256 farmId, uint256 amount) external payable;

  // --------------------------------- CHECK & HARVEST BRIDGE REWARDS FROM FARMS ---------------------------------------

  /**
   * @notice Returns the amount of BRIDGE tokens that are ready for harvesting for the given user and farm
   *
   * @param farmId The index of the farm
   * @param user the address of the user to query the info for
   * @return returns the amount of bridge tokens that are ready for harvesting
   */
  function pendingFarmRewards(uint256 farmId, address user) external view returns (uint256);

  /**
   * @notice Harvests BRIDGE rewards and sends them to the caller of this function
   *
   * @param farmId the ID of the farm for which rewards should be harvested
   *
   * @dev emits event RewardsHarvested after the rewards have been transferred to the caller
   */
  function harvestFarmRewards(uint256 farmId) external payable;

  // ###################################################################################################################
  // ********************************************* REWARD POOLS ********************************************************
  // ###################################################################################################################
  // ----------------------------------- STAKE BRIDGE TOKENS IN REWARD POOLS -------------------------------------------
  /**
   * @notice Stakes BRIDGE tokens in the given staking pool
   *
   * NOTE: Withdrawals are subject to a fee {see unstakeBRIDGEFromRewardPools()}
   *
   * @param tokenAddress the address of the underlying token of the reward pool
   * @param amount the amount of bridge tokens that should be staked
   *
   * @dev emits event StakeAdded
   */
  function stakeBRIDGEInRewardPool(address tokenAddress, uint256 amount) external payable;

  // --------------------------------- UNSTAKE BRIDGE TOKENS FROM REWARD POOLS -----------------------------------------
  /**
   * @notice Unstakes BRIDGE tokens from the given reward pool
   *
   * Please note: Unstaking BRIDGE tokens is subject to a withdrawal fee.
   * To check the current fee rate, please refer to the following variables/functions
   *   1) check for custom withdrawal fee (if > 0 then this fee applies) : rewardPoolWithdrawalFees(tokenAddress)
   *   2) if no custom withdrawal fee applies, then default fee applies  : defaultRewardPoolWithdrawalFee()
   *
   * @param tokenAddress the address of the underlying token of the reward pool
   * @param amount the amount of bridge tokens that should be unstaked
   * @dev emits event StakeWithdrawn
   */
  function unstakeBRIDGEFromRewardPool(address tokenAddress, uint256 amount) external payable;

  // -------------------------------- CHECK & HARVEST REWARDS FROM REWARD POOLS ----------------------------------------
  /**
   * @notice Returns the amount of unharvested rewards for a specific address in the given reward pool
   *
   * @param tokenAddress the address of the underlying token of the reward pool
   * @param stakerAddress the address of the staker for which pending rewards should be returned
   * @return the unharvested reward amount
   */
  function pendingRewardPoolRewards(address tokenAddress, address stakerAddress) external view returns (uint256);

  /**
   * @notice Distributes unharvested staking rewards from the given reward pool
   *
   * @param tokenAddress the address of the underlying token of the pool
   * @param stakerAddress the address for which the unharvested rewards should be distributed
   * @dev emits event RewardsHarvested
   */
  function harvestFromRewardPool(address tokenAddress, address stakerAddress) external payable;

  // ------------------------------------ CHECK REWARD POOL WITHDRAWAL FEES --------------------------------------------
  /**
   * @notice Returns the specific withdrawal fee for the given token in parts per million (ppm)
   *
   * Example for ppm values:
   * 300,000  = 30%
   *  10,000 =   1%
   *
   * @return the withdrawal fee percentage in ppm
   */
  function rewardPoolWithdrawalFee(address tokenAddress) external view returns (uint256);

  // ###################################################################################################################
  // ******************************** LIST/DE-LIST YOUR ERC20/ERC721 TOKEN *********************************************
  // ****************** FOR PROJECTS THAT WANT TO USE OUR BRIDGE FOR THEIR TOKEN/COLLECTION ****************************
  // ###################################################################################################################
  // ------------------------------------------------- ERC20  ----------------------------------------------------------
  // For new ERC20 token listings on the bridge there are two cases:
  // 1) the token contracts have same addresses across all networks that should be connected
  // 2) the token contracts have different addresses across the networks that should be connected
  //
  // In case of 1), you need to add liquidity in each network (see section "MANAGE LIQUIDITY")
  // In case of 2), same as 1) plus you need to add token mappings in each network (see below)

  /**
   * @notice Adds a token contract mapping for an ERC20 token
   *
   * @param sourceNetworkTokenAddress the address of the token in another network that should be mapped to the target
   * @param targetTokenAddress the address of the target token in this network
   *
   * @dev only accepts new token mappings. To update an existing mapping, please contact support
   * @dev the token contract must have a public owner() function that returns the address of the owner
   * @dev if this is not possible, you can contact support to add your mapping
   * @dev emits event PeggedTokenMappingAdded
   */
  function addERC20TokenContractMapping(address sourceNetworkTokenAddress, address targetTokenAddress) external payable;

  /**
   * @notice Removes a token contract mapping for an ERC20 token
   *
   * @param sourceNetworkTokenAddress the address of the token in another network that should be mapped to the target
   *
   * @dev can only be called by the owner of the target token contract
   * @dev only accepts new token mappings. To update an existing mapping, please contact support
   * @dev the token contract must have a public owner() function that returns the address of the owner
   * @dev if this is not possible, you can contact support to add your mapping
   */
  function removeERC20TokenContractMapping(address sourceNetworkTokenAddress) external payable;

  /**
  * @notice Initial setup for a new ERC20 token. Creates all pools required by the bridge ecosystem.
  *         Can be called from a constructor of an ERC20 token to prepare token for bridging.
  *
  * @param createLiquidityPool creates a liquidity pool and a LP token, if true
  * @param createMiningPool creates a liquidity mining pool, if true
  * @param createRewardPool creates a reward pool, if true
  *
  * @dev emits events LiquidityPoolCreated, LiquidityMiningPoolCreated, RewardPoolCreated
  */
  function createPools(address tokenAddress, bool createLiquidityPool, bool createMiningPool, bool createRewardPool) external payable;

  // ------------------------------------------------  ERC721  ---------------------------------------------------------
  // For new ERC721 collection listings on the bridge there are two cases:
  // 1) the collection contracts have same addresses across all networks that should be connected
  // 2) the collection contracts have different addresses across the networks that should be connected
  //
  // In case of 1), you need to add your collection to the whitelist (see below)
  // In case of 2), same as 1) plus you need to add collection mappings in each network (see below)

  /**
   * @notice Adds an ERC721 collection to the whitelist (effectively allowing bridge transactions for this collection)
   *
   * @param collectionAddress the address of the collection that should be added
   *
   * @dev can only be called by the owner of the collection
   * @dev the collection contract must have a public owner() function that returns the address of the owner
   * @dev if owner() function is not available, please contact support to whitelist your collection
   * @dev emits event AddedCollectionToWhitelist
   */
  function addERC721CollectionToWhitelist(address collectionAddress) external payable;

  /**
   * @notice Removes an ERC721 collection from the whitelist
   *         (effectively disabling bridge transactions for this collection)
   *
   * @param collectionAddress the address of the collection that should be removed
   *
   * @dev can only be called by the owner of the collection
   * @dev the collection contract must have a public owner() function that returns the address of the owner
   * @dev if owner() function is not available, please contact support to de-whitelist your collection
   * @dev emits event RemovedCollectionFromWhitelist
   */
  function removeERC721CollectionFromWhitelist(address collectionAddress) external payable;

  /**
   * @notice Adds a new collection address mapping (to connect collections with different addresses across networks)
   *
   * @param sourceNetworkCollectionAddress the address of a collection in another network that should be mapped to the target
   * @param targetCollectionAddress the address of the target collection in this network
   *
   * @dev can only be called by the owner of the collection
   * @dev only accepts new collection mappings. To update an existing mapping, please contact support
   * @dev the collection contract must have a public owner() function that returns the address of the owner
   * @dev if owner() function is not available, please contact support
   * @dev emits event PeggedCollectionMappingAdded
   */
  function addERC721CollectionAddressMapping(address sourceNetworkCollectionAddress, address targetCollectionAddress)
    external
    payable;

  /**
   * @notice Removes a collection address mapping from sourceNetworkCollectionAddress to targetCollectionAddress
   *
   * @param sourceNetworkCollectionAddress the address of a collection in another network that is mapped to the target
   *
   * @dev can only be called by the owner of the target collection (=the mapped-to collection in this network)
   * @dev the target collection contract must have a public owner() function that returns the address of the owner
   * @dev if owner() function is not available, please contact support
   */
  function removeERC721CollectionAddressMapping(address sourceNetworkCollectionAddress) external payable;

  // ###################################################################################################################
  // ****************************************** AUXILIARY FUNCTIONS ****************************************************
  // ###################################################################################################################
  /**
   * @notice Returns the wrapped native token contract address that is used in this network
   */
  function wrappedNative() external view returns (address);

  /**
   * @notice Returns the address of the LP token for a given token address
   *
   * @dev returns zero address if LP token does not exist
   * @param tokenAddress the address of token for which the LP token should be returned
   */
  function getLPToken(address tokenAddress) external view returns (address);

  /**
   * @notice returns the ID of the network this contract is deployed in
   */
  function getChainID() external view returns (uint256);
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}