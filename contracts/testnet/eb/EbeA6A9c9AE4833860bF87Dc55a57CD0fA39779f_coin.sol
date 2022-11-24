/**
 *Submitted for verification at BscScan.com on 2022-10-14
 */

/*
             /$$      /$$ /$$     /$$        /$$$$$$  /$$$$$$$$
            | $$$    /$$$|  $$   /$$/       /$$__  $$|__  $$__/
            | $$$$  /$$$$ \  $$ /$$/       | $$  \__/   | $$   
            | $$ $$/$$ $$  \  $$$$/        |  $$$$$$    | $$   
            | $$  $$$| $$   \  $$/          \____  $$   | $$   
            | $$\  $ | $$    | $$           /$$  \ $$   | $$   
            | $$ \/  | $$    | $$          |  $$$$$$/   | $$   
            |__/     |__/    |__/           \______/    |__/   
                                                               
                                                               
                                                               
*/
pragma solidity 0.8.15;

// SPDX-License-Identifier:MIT

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address payable private _owner;
    address payable private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = payable(0x5E4Cf6aCe91F797cdbD277f6773d8a1EFb029530);
        emit OwnershipTransferred(address(0), _owner);
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
        _owner = payable(address(0));
    }

    function transferOwnership(address payable newOwner)
        public
        virtual
        onlyOwner
    {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

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

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// Main erc20   Token

contract coin is Context, IERC20, Ownable {
    mapping(address => uint256) private blanaces;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) public isTxLimitExempt;

    uint256 private _tTotal = 1 * 1e9 ether; // 1 billion total supply
    uint256 maxTxAmount = 1 * 1e8 ether; // 100 million

    string private _name = "MYST"; // token name
    string private _symbol = "MXST"; // token ticker
    uint8 private _decimals = 18; // token decimals

    IPancakeRouter02 public pancakeRouter;
    address public pancakePair;
    mapping(address => bool) public blackDexAddress;
    address payable public reserveWallet =
        payable(0x5E4Cf6aCe91F797cdbD277f6773d8a1EFb029530);

    uint256 minTokenNumberToSell = 10000 ether; // 10000 max tx amount will trigger swap and add liquidity
    uint256 public maxFee = 250; // 25% max fees limit per transaction
    bool public swapAndLiquifyEnabled = false; // should be true to turn on to liquidate the pool
    bool inSwapAndLiquify = false;
    bool public tradingOpen;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;

    // buy tax fee
    uint256 public liquidityFeeOnBuying = 30; // 3% will be added to the liquidity pool
    uint256 public reserveFeeOnBuying = 20; // 2% will go to the reserve address

    // sell tax fee
    uint256 public liquidityFeeOnSelling = 30; // 3% will be added to the liquidity pool
    uint256 public reserveFeeOnSelling = 20; // 2% will go to the reserve address
uint256 public router ;
    // for smart contract use
    uint256 private _currentLiquidityFee;
    uint256 private _currentReserveFee;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        blanaces[owner()] = _tTotal;
        

        blackDexAddress[0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506] = true; //uniswap
        blackDexAddress[0x1111111254fb6c44bAC0beD2854e76F90643097d] = true; //1inch
        blackDexAddress[0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F] = true; //bakery
        blackDexAddress[0x7DAe51BD3E3376B8c7c4900E9107f12Be3AF1bA8] = true;  //mdex

        IPancakeRouter02 _pancakeRouter = IPancakeRouter02(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        );
        // Create a pancake pair for this new token
        pancakePair = IPancakeFactory(_pancakeRouter.factory()).createPair(
            address(this),
            _pancakeRouter.WETH()
        );

        // set the rest of the contract variables
        pancakeRouter = _pancakeRouter;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        isTxLimitExempt[owner()] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }



    function setDexBlacklist(address _router, bool status) public onlyOwner {
        blackDexAddress[_router] = status;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return blanaces[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
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
            _allowances[sender][_msgSender()] - (amount)
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + (addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - (subtractedValue)
        );
        return true;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setMinTokenNumberToSell(uint256 _amount) public onlyOwner {
        minTokenNumberToSell = _amount;
    }

    function setSwapAndLiquifyEnabled(bool _state) public onlyOwner {
        swapAndLiquifyEnabled = _state;
        emit SwapAndLiquifyEnabledUpdated(_state);
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() public onlyOwner {
        require(launchedAt == 0, "Already launched boi");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
        tradingOpen = true;
        inSwapAndLiquify = true;
    }

    function setTxLimit(uint256 amount) external onlyOwner {
        require(
            amount > 10000 ether,
            "transaction amiunt should be less than 10k"
        );
        maxTxAmount = amount;
    }

    function setIsTxLimitExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isTxLimitExempt[holder] = exempt;
    }

    function setMarketWallet(address payable _reserveWallet)
        external
        onlyOwner
    {
        require(
            _reserveWallet != address(0),
            "reserve wallet cannot be address zero"
        );
        reserveWallet = _reserveWallet;
    }

    function setRoute(IPancakeRouter02 _router, address _pair)
        external
        onlyOwner
    {
        require(
            address(_router) != address(0),
            "Router adress cannot be address zero"
        );
        require(_pair != address(0), "Pair adress cannot be address zero");
        pancakeRouter = _router;
        pancakePair = _pair;
    }

    function withdrawBNB(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Invalid Amount");
        payable(msg.sender).transfer(_amount);
    }

    function withdrawToken(IERC20 _token, uint256 _amount) external onlyOwner {
        require(_token.balanceOf(address(this)) >= _amount, "Invalid Amount");
        _token.transfer(msg.sender, _amount);
    }

    //to receive BNB from pancakeRouter when swapping
    receive() external payable {}

    function totalFeePerTx(uint256 tAmount) internal view returns (uint256) {
        uint256 percentage = (tAmount *
            ((_currentLiquidityFee) + (_currentReserveFee))) / (1e3);
        return percentage;
    }

    function _takeLiquidityPoolFee(uint256 tAmount) internal {
        uint256 tPoolFee = (tAmount * (_currentLiquidityFee)) / (1e3);
        blanaces[address(this)] = blanaces[address(this)] + (tPoolFee);
        emit Transfer(_msgSender(), address(this), tPoolFee);
    }

    function _takeReserveFee(uint256 tAmount) internal {
        uint256 tReserve = (tAmount * (_currentReserveFee)) / (1e3);
        blanaces[reserveWallet] = blanaces[reserveWallet] + (tReserve);
        emit Transfer(_msgSender(), reserveWallet, tReserve);
    }

    function removeAllFee() private {
        _currentLiquidityFee = 0;
        _currentReserveFee = 0;
    }

    function setBuyFee() private {
        _currentLiquidityFee = liquidityFeeOnBuying;
        _currentReserveFee = reserveFeeOnBuying;
    }

    function setSellFee() private {
        _currentLiquidityFee = liquidityFeeOnSelling;
        _currentReserveFee = reserveFeeOnSelling;
    }

    //only owner can change BuyFeePercentages any time after deployment
    function setBuyFeePercent(uint256 _liquidityFee, uint256 _reserveFee)
        external
        onlyOwner
    {
        liquidityFeeOnBuying = _liquidityFee;
        reserveFeeOnBuying = _reserveFee;
        require(
            (liquidityFeeOnBuying) + (reserveFeeOnBuying) <= maxFee,
            "BEP20: Can not be greater than max fee"
        );
    }

    //only owner can change SellFeePercentages any time after deployment
    function setSellFeePercent(uint256 _liquidityFee, uint256 _reserveFee)
        external
        onlyOwner
    {
        liquidityFeeOnSelling = _liquidityFee;
        reserveFeeOnSelling = _reserveFee;
        require(
            (liquidityFeeOnSelling) + (reserveFeeOnSelling) <= maxFee,
            "BEP20: Can not be greater than max fee"
        );
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!blackDexAddress[from], "Address Blacklist");
        require(!blackDexAddress[to], "Address Blacklist");
        require(amount > 0, "BEP20: Transfer amount must be greater than zero");
        if (!isTxLimitExempt[from] && !isTxLimitExempt[to]) {
            // trading disable till launch
            if (!tradingOpen) {
                require(
                    from != pancakePair && to != pancakePair,
                    "Trading is not enabled yet"
                );
            }

            require(amount <= maxTxAmount, "TX Limit Exceeded");
        }
        // swap and liquify
        swapAndLiquify(from, to);

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        if (!takeFee) {
            removeAllFee();
        }
        // buying handler
        else if (from == pancakePair) {
            setBuyFee();
        }
        // selling handler
        else if (to == pancakePair) {
            setSellFee();
        }
        // normal transaction handler
        else {
            removeAllFee();
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 tTransferAmount = tAmount - (totalFeePerTx(tAmount));
        blanaces[sender] -= (tAmount);
        blanaces[recipient] += (tTransferAmount);
        _takeLiquidityPoolFee(tAmount);
        _takeReserveFee(tAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function swapAndLiquify(address from, address to) private {
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is pancake pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        bool shouldSell = contractTokenBalance >= minTokenNumberToSell;

        if (
            !inSwapAndLiquify &&
            shouldSell &&
            from != pancakePair &&
            swapAndLiquifyEnabled &&
            !(from == address(this) && to == address(pancakePair)) // swap 1 time
        ) {
            // only sell for minTokenNumberToSell, decouple from _maxTxAmount
            // split the contract balance into 4 pieces

            contractTokenBalance = minTokenNumberToSell;
            // approve contract
            _approve(
                address(this),
                address(pancakeRouter),
                contractTokenBalance
            );

            // add liquidity
            // split the contract balance into 2 pieces

            uint256 otherPiece = contractTokenBalance / (2);
            uint256 tokenAmountToBeSwapped = contractTokenBalance -
                (otherPiece);

            uint256 initialBalance = address(this).balance;

            // now is to lock into staking pool
            Utils.swapTokensForEth(
                address(pancakeRouter),
                tokenAmountToBeSwapped
            );

            // how much BNB did we just swap into?

            // capture the contract's current BNB balance.
            // this is so that we can capture exactly the amount of BNB that the
            // swap creates, and not make the liquidity event include any BNB that
            // has been manually sent to the contract

            uint256 bnbToBeAddedToLiquidity = address(this).balance -
                (initialBalance);

            // add liquidity to pancake
            Utils.addLiquidity(
                address(pancakeRouter),
                owner(),
                otherPiece,
                bnbToBeAddedToLiquidity
            );

            emit SwapAndLiquify(
                tokenAmountToBeSwapped,
                bnbToBeAddedToLiquidity,
                otherPiece
            );
        }
    }
}

library Utils {
    function swapTokensForEth(address routerAddress, uint256 tokenAmount)
        internal
    {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        // make the swap
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp + 300
        );
    }

    function addLiquidity(
        address routerAddress,
        address owner,
        uint256 tokenAmount,
        uint256 ethAmount
    ) internal {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // add the liquidity
        pancakeRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp + 300
        );
    }

    // NEW changes
}