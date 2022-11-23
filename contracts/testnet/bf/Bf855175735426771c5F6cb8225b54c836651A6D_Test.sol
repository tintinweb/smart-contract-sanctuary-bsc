/**
 *Submitted for verification at Etherscan.io on 2022-09-26
 */

/**
 * 
                               
                                                                              
                                                                                                    
                                                                                  
*/
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17;

library Address {
    /**
     *
     */
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Test is IERC20, Ownable {
    using Address for address;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Test";
    string constant _symbol = "TEST";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 1_000_000_000 * (10**_decimals);
    uint256  _maxBuyTxAmount = (_totalSupply ) / 50;
    uint256  _maxSellTxAmount = (_totalSupply ) / 100;
    uint256 _maxWallet = (_totalSupply) / 50;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) _isExcludedFromFees;
    mapping(address => bool) _isExcludedFromMaxTx;
    mapping(address => bool) _isExcludedFromMaxWallet;

    uint256 buyMarketingFee = 50;
    uint256 buyLiquidityFee = 20;
    uint256 buyTotalFee = buyMarketingFee + buyLiquidityFee;
    uint256 sellMarketingFee = 50;
    uint256 sellLiquidityFee = 20;
    uint256 sellTotalFee = sellMarketingFee + sellLiquidityFee;

    uint256 constant feeDenominator = 1000;

    address payable public liquidityFeeWallet =
        payable(DEAD);
    address payable public marketingWallet =
        payable(ZERO);

    IUniswapRouter public router;
    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    mapping(address => bool) automatedMarketMakerPairs;

    address public pair;

    uint256 public launchedAt;
    uint256 public launchedTime;
    uint256 public deadBlocks;
    bool tradingEnabled = false;

    bool public swapEnabled = false;
    uint256 public swapThreshold = _totalSupply / 200;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event UpdateFees(uint256 buyMarketingFee, uint256 buyLiquidityFee, uint256 sellMarketingFee, uint256 sellLiquidityFee);
    event UpdateFeeReceivers(address indexed newMarketingWallet, address newLiquditiyFeeWallet);
    event UpdateRouter(address indexed newRouterAddress);
    event UpdateMaxTx(uint256 newMaxBuyTxAmount, uint256 newMaxSellTxAmount);
    event UpdateMaxWallet(uint256 newMaxWallet);
    event UpdateAMM(address indexed newAutomatedMarketMaker, bool status);
    event UpdateSwapBackSettings(bool enabled, uint256 denominator);
    event UpdateExcludedFromFees(address indexed holder, bool exempt);
    event UpdateExcludedFromMaxWallet(address indexed holder, bool exempt);
    event UpdateExcludedFromMaxTx(address indexed holder, bool exempt);
    event FundsDistributed(
        uint256 marketingETH,
        uint256 liquidityETH,
        uint256 liquidityTokens
    );
    error InvalidTransfer(string erroString);
    error InvalidTransferAmount(string errorString);
    error InsufficientBalance();
    error InvalidSwapBackSettings(string errorString);
    error InvalidFees(string errorString);
    error InvalidMaxWallet(string errorString);
    error InvalidMaxTxAmount(string errorString);
    error InvalidOpenTrading();

    constructor() {
        router = IUniswapRouter(routerAddress);
        pair = IUniswapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        automatedMarketMakerPairs[pair] = true;
        _allowances[owner()][routerAddress] = type(uint256).max;
        _allowances[address(this)][routerAddress] = type(uint256).max;

        _isExcludedFromFees[owner()] = true;

        _isExcludedFromMaxTx[address(this)] = true;
        _isExcludedFromMaxTx[owner()] = true;
        _isExcludedFromMaxTx[routerAddress] = true;
        _isExcludedFromMaxTx[DEAD] = true;

        _balances[owner()] = _totalSupply;
        
        emit Transfer(address(0), owner(), _totalSupply);
    }

    receive() external payable {}

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {


        if(sender == address(0))
            revert InvalidTransfer("ERC20: transfer from 0x0");
        if( amount <= 0)
            revert InvalidTransferAmount("Amount must be more than 0");
        if(_balances[sender] < amount)
            revert InsufficientBalance();
               
        checkTxLimit(sender, recipient, amount);

        bool isSell = automatedMarketMakerPairs[recipient];
        bool isBuy = automatedMarketMakerPairs[sender];

        if (inSwap ) 
            return _basicTransfer(sender, recipient, amount);
        
        if(isBuy) {
   
            if (!tradingEnabled) {
                if(
                    sender != owner()
                )
                    revert InvalidTransfer("Trading not open yet.");
            }
            checkWalletLimit(recipient, amount);    
              
        }
        else if(!isSell){ 
            // zero tax on wallet-to-wallet transfers
            checkWalletLimit(recipient, amount);    
            return _basicTransfer(sender, recipient, amount);
        }

        _balances[sender] = _balances[sender] - amount;


        uint256 amountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(isSell, amount)
            : amount;

        if (shouldSwapBack(isSell)) {
                swapBack();
            }
        _balances[recipient] = _balances[recipient] + amountReceived;            



        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    /*
    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }
    
    function launch() internal {
        launchedAt = block.number;
        launchedTime = block.timestamp;
        swapEnabled = true;
    }
    */
    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkWalletLimit(address recipient, uint256 amount) internal view {

        if (!_isExcludedFromMaxWallet[recipient]) {

            uint256 walletLimit = _maxWallet;
            if(
                _balances[recipient] + amount > walletLimit     
            )
                revert InvalidTransfer("Max Wallet exceeded");
        }

    }

    function checkTxLimit(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {

        if( !_isExcludedFromMaxTx[sender])
        {
            if(  
                amount > _maxBuyTxAmount &&
                automatedMarketMakerPairs[sender]
            )     
                revert InvalidTransfer("Buy TX Limit Exceeded");

            else if(
                amount > _maxSellTxAmount && 
                automatedMarketMakerPairs[recipient] 
            )
                revert InvalidTransfer( "Sell TX Litimt Exceeded");  
        }
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !_isExcludedFromFees[sender] || !_isExcludedFromFees[recipient];
    }

    function getTotalFee(bool isSell) public view returns (uint256) {
        if (launchedAt + deadBlocks >= block.number) {
            return feeDenominator - 1;
        }
        if(isSell)
            return sellTotalFee;

        return buyTotalFee;
    }

    function takeFee( bool isSell, uint256 amount)
        internal
        returns (uint256)
    {
        uint256 feeAmount = (amount * getTotalFee(isSell)) / feeDenominator;

        _balances[address(this)] += feeAmount;

        return amount - feeAmount;
    }

    function shouldSwapBack(bool isSell) internal view returns (bool) {
        return
            !automatedMarketMakerPairs[msg.sender] &&
            !inSwap &&
            swapEnabled &&
            isSell &&
            _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 amountToSwap = swapThreshold;
        if (_balances[address(this)] < amountToSwap)
            amountToSwap = _balances[address(this)];

        uint256 amountToLiquify = ((amountToSwap * sellLiquidityFee) / 2) /
            sellTotalFee;
        amountToSwap -= amountToLiquify;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance - balanceBefore;
        uint256 totalETHFee = sellTotalFee - (sellLiquidityFee / 2);

        uint256 amountETHLiquidity = ((amountETH * sellLiquidityFee) / 2) /
            totalETHFee;
        uint256 amountETHMarketing = amountETH - amountETHLiquidity;

        if (amountETHMarketing > 0)
            marketingWallet.transfer(amountETHMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquidityFeeWallet,
                block.timestamp
            );
        }

        emit FundsDistributed(
            amountETHMarketing,
            amountETHLiquidity,
            amountToLiquify
        );
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function getMaxTxs() external view returns (uint256 maxBuyTxAmount, uint256 maxSellTxAmount ) {
        return (_maxBuyTxAmount / (10**_decimals), _maxSellTxAmount / (10**_decimals)) ;
    }

    function getMaxWallet() external view returns (uint256) {
        return _maxWallet / (10**_decimals);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function sweep(uint256 amountPercentage, address adr)
        external
        onlyOwner
    {
        uint256 amountETH = address(this).balance;
        payable(adr).transfer((amountETH * amountPercentage) / 100);
    }

    function sweepTokens(address trappedToken)
        external
        onlyOwner
    {
        IERC20 tokenIERC20 = IERC20(trappedToken);
        uint256 amountToken = tokenIERC20.balanceOf(address(this));
        tokenIERC20.transfer(marketingWallet, amountToken);    
    }

    function openTrading(
        uint256 _deadBlocks
    ) external onlyOwner {

        if(tradingEnabled || _deadBlocks > 10)
            revert InvalidOpenTrading();
        
        swapEnabled = true;
        deadBlocks = _deadBlocks;
        tradingEnabled = true;
        launchedAt = block.number;
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function manualSwapBack() external onlyOwner(){
        swapBack();
    }
    

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function addAutomatedMarketMaker(address lp, bool isPool) external onlyOwner {
        automatedMarketMakerPairs[lp] = isPool;
        emit UpdateAMM(lp, isPool);
    }

    function setMaxTxAmount(
        uint256 divisorBuy,
        uint256 divisorSell
    ) external 
      onlyOwner 
    {
        if( divisorSell <= 0 || divisorBuy > 200 || divisorBuy <= 0 || divisorSell > 200)
            revert InvalidMaxTxAmount("Max Tx must be > 0.5% total supply");
        _maxBuyTxAmount = _totalSupply / divisorBuy;
        _maxSellTxAmount = _totalSupply / divisorSell;
        emit UpdateMaxTx(_maxBuyTxAmount, _maxSellTxAmount);

    }

    function setMaxWallet(uint256 divisor)
        external
        onlyOwner
    {
        if( divisor <= 0 || divisor > 200)
            revert InvalidMaxWallet("Max wallet must be > 0.5% total supply");
        _maxWallet = _totalSupply / divisor;
        emit UpdateMaxWallet(_maxWallet);

    }

    function setIsExcludedFromFees(address holder, bool exempt) external onlyOwner {
        _isExcludedFromFees[holder] = exempt;
        emit UpdateExcludedFromFees(holder, exempt);
    }

    function setIsExcludedFromMaxTx(address holder, bool exempt)
        external
        onlyOwner
    {
        _isExcludedFromMaxTx[holder] = exempt;
        emit UpdateExcludedFromMaxTx(holder, exempt);

    }

        function setIsExcludedFromMaxWallet(address holder, bool exempt)
        external
        onlyOwner
    {
        _isExcludedFromMaxWallet[holder] = exempt;
        emit UpdateExcludedFromMaxWallet(holder, exempt);
    }

    function setFees(
        uint256 _buyMarketingFee,
        uint256 _buyLiquidityFee,
        uint256 _sellMarketingFee,
        uint256 _sellLiquidityFee
    ) external onlyOwner {
        buyLiquidityFee = _buyLiquidityFee;
        buyMarketingFee = _buyMarketingFee;
        buyTotalFee = _buyMarketingFee + _buyLiquidityFee;
        sellLiquidityFee = _sellLiquidityFee;
        sellMarketingFee = _buyMarketingFee;
        sellTotalFee = _sellMarketingFee + _sellLiquidityFee;
        if(buyTotalFee + sellTotalFee > 250 )
            revert InvalidFees("Total fees must be lower than 25");
        emit UpdateFees( buyMarketingFee, buyLiquidityFee, sellMarketingFee, sellLiquidityFee);
    }

    function setFeeReceivers(
        address _liquidityFeeWallet,
        address _marketingWallet
    ) external onlyOwner {
        liquidityFeeWallet = payable(_liquidityFeeWallet);
        marketingWallet = payable(_marketingWallet);
        emit UpdateFeeReceivers(liquidityFeeWallet, marketingWallet);
    }

    function setSwapBackSettings(
        bool _enabled,
        uint256 _denominator
    ) external onlyOwner {

        if( _denominator < 100 || _denominator > 10000)
            revert InvalidSwapBackSettings("Max threshod 1% , mininum 0.01%");
        swapEnabled = _enabled;
        swapThreshold = _totalSupply / _denominator;
    }

    function updateRouter( address newRouterAddress) external onlyOwner {
        router = IUniswapRouter(newRouterAddress);
        emit UpdateRouter(newRouterAddress);
    }

    function getCirculatingSupply() external view returns (uint256) {
        return _totalSupply - (balanceOf(DEAD) + balanceOf(ZERO));
    }

    function getFees() external view returns (
        uint256 _buyMarketingFee, 
        uint256 _buyLiquidityFee, 
        uint256 _sellMarketingFee, 
        uint256 _sellLiquidityFee, 
        uint256 _feeDenominator
    ) {
        return ( buyMarketingFee, buyLiquidityFee, 
                 sellMarketingFee, sellLiquidityFee,  
                 feeDenominator
                );
    }


}