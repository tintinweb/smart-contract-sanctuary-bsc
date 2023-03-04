/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

pragma solidity 0.8.16;


// SPDX-License-Identifier: MIT


interface ERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address _account) external view returns (uint256);

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

    /**
     * @dev Emitted when `value` tokens are moved from one _account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// Dex Factory contract interface
interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

// Dex Router02 contract interface
interface IDexRouter {
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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any _account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new _account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    /**
     * @dev set the owner for the first time.
     * Can only be called by the contract or deployer.
     */
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Solar is ERC20, Ownable {
    using SafeMath for uint256;

    // all private variables and functions are only for contract use
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromReward;
    mapping(address => bool) private _isExcludedFromMaxHoldLimit;
    mapping(address => bool) private _isExcludedFromMinBuyLimit;
    

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000000000 * 1e9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "Solar Coin"; // token name
    string private _symbol = "SPX"; // token ticker
    uint8 private _decimals = 9; // token decimals

    IDexRouter public dexRouter; // Dex router address
    address public dexPair; // LP token address
    address payable public marketingWallet; // marketing wallet address
    address public burnAddress = (0x000000000000000000000000000000000000dEaD);

    uint256 public minTokenToSwap = 10000 * 1e9; // will trigger the swap and add liquidity
    uint256 public maxHoldingAmount = 1000000000000000 * 1e9;
    uint256 public minBuyLimit = 1000000000000000 * 1e9;

    uint256 private excludedTSupply; // for contract use
    uint256 private excludedRSupply; // for contract use
    
    uint256 public tradingActiveBlock = 0; // 0 means trading is not active
    
    bool public tradingActive = false;
    bool public swapAndLiquifyEnabled = false; // should be true to turn on to liquidate the pool
    bool public Fees = true;
 
    bool public isMaxHoldLimitValid = true; // max Holding Limit is valid if it's true

    // Anti-bot and anti-whale mappings and variables
    mapping(address => uint256) private _holderLastTransferTimestamp; // to hold last Transfers temporarily during launch
    bool public transferDelayEnabled = true;
   // Anti-bot and anti-whale mappings and variables
    mapping (address => bool) private _blacklist;
    

    // buy tax fee

    uint256 public reflectionFeeOnBuying = 10;
    uint256 public liquidityFeeOnBuying = 20;
    uint256 public marketingWalletFeeOnBuying = 50;
    uint256 public burnFeeOnBuying = 10;

    // sell tax fee
    uint256 public reflectionFeeOnSelling = 10;
    uint256 public liquidityFeeOnSelling = 20;
    uint256 public marketingWalletFeeOnSelling = 50;
    uint256 public burnFeeOnSelling = 10;

    // for smart contract use
    uint256 private _currentReflectionFee;
    uint256 private _currentLiquidityFee;
    uint256 private _currentmarketingWalletFee;
    uint256 private _currentBurnFee;

    uint256 private _accumulatedLiquidity;
    uint256 private _accumulatedMarketingWallet;

    //Events for blockchain
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    // constructor for initializing the contract
    constructor(address payable _marketingWallet) {
        _rOwned[owner()] = _rTotal;
        marketingWallet = _marketingWallet;

        IDexRouter _dexRouter = IDexRouter(
           0xD99D1c33F9fC3444f8101754aBC46c52416550D1
            // router 0x10ED43C718714eb63d5aA57B78B54704E256024E 
        );
        // Create a Dex pair for this new token
        dexPair = IDexFactory(_dexRouter.factory()).createPair(
            address(this),
            _dexRouter.WETH()
        );

        // set the rest of the contract variables
        dexRouter = _dexRouter;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

       // exclude addresses from max holding limit
        _isExcludedFromMaxHoldLimit[owner()] = true;
        _isExcludedFromMaxHoldLimit[address(this)] = true;
        _isExcludedFromMaxHoldLimit[dexPair] = true;
        _isExcludedFromMaxHoldLimit[burnAddress] = true;

        _isExcludedFromMinBuyLimit[owner()] = true;
        _isExcludedFromMinBuyLimit[dexPair] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }

    // token standards by Blockchain

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

    function balanceOf(address _account)
        public
        view
        override
        returns (uint256)
    {
        if (_isExcludedFromReward[_account]) return _tOwned[_account];
        return tokenFromReflection(_rOwned[_account]);
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
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
            _allowances[sender][_msgSender()].sub(
                amount,
                "Token: transfer amount exceeds allowance"
            )
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
            _allowances[_msgSender()][spender].add(addedValue)
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
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "Token: decreased allowance below zero"
            )
        );
        return true;
    }

    // public view able functions

    // function to check if address is a bot
   
         
    // to check wether the address is excluded from reward or not
    function isExcludedFromReward(address _account) public view returns (bool) {
        return _isExcludedFromReward[_account];
    }

    // to check how much tokens get redistributed among holders till now
    function totalHolderDistribution() public view returns (uint256) {
        return _tFeeTotal;
    }

    // to check wether the address is excluded from fee or not
    function isExcludedFromFee(address _account) public view returns (bool) {
        return _isExcludedFromFee[_account];
    }
    // to check wether the address is excluded from max Holding or not
    function isExcludedFromMaxHoldLimit(address _account)
        public
        view
        returns (bool)
    {
        return _isExcludedFromMaxHoldLimit[_account];
    }

    // to check wether the address is excluded from max txn or not
    function isExcludedFromMaxTxnLimit(address _account)
        public
        view
        returns (bool)
    {
        return _isExcludedFromMinBuyLimit[_account];
    }


    // For manual distribution to the holders
    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(
            !_isExcludedFromReward[sender],
            "Token: Excluded addresses cannot call this function"
        );
        uint256 rAmount = tAmount.mul(_getRate());
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "BEP20: Amount must be less than supply");
        if (!deductTransferFee) {
            uint256 rAmount = tAmount.mul(_getRate());
            return rAmount;
        } else {
            uint256 rAmount = tAmount.mul(_getRate());
            uint256 rTransferAmount = rAmount.sub(
                totalFeePerTx(tAmount).mul(_getRate())
            );
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Token: Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    //to include or exludde  any address from max hold limit
    function includeOrExcludeFromMaxHoldLimit(address _address, bool value)
        public
        onlyOwner
    {
        _isExcludedFromMaxHoldLimit[_address] = value;
    }

    //to include or exludde  any address from max hold limit
    function includeOrExcludeFromMaxTxnLimit(address _address, bool value)
        public
        onlyOwner
    {
        _isExcludedFromMinBuyLimit[_address] = value;
    }

    //only owner can change MaxHoldingAmount
    function setMaxHoldingAmount(uint256 _amount) public onlyOwner {
        maxHoldingAmount = _amount;
    }

    //only owner can change MaxHoldingAmount
    function setMinBuyLimit(uint256 _amount) public onlyOwner {
        minBuyLimit = _amount;
    }

    // owner can remove stuck tokens in case of any issue
     function withdrawStuckEth() external onlyOwner {
        (bool success,) = address(msg.sender).call{value: address(this).balance}("");
        require(success, "failed to withdraw");
    }

  function withdrawStuckToken(address _token, address _to) external onlyOwner {
        require(_token != address(0), "_token address cannot be 0");
        uint256 _contractTokenBalance = ERC20(_token).balanceOf(address(this));
        ERC20(_token).transfer(_to, _contractTokenBalance);
    }

    // function to blacklist bot 
      
         function AddBots(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            _blacklist[bots_[i]] = true;
        
       }
      }

      function DelBots(address[] memory notbot) public onlyOwner {
      for (uint i = 0; i < notbot.length; i++) {
          _blacklist[notbot[i]] = false;
      }
    }
     function isBot(address wallet) public view returns (bool){
      return _blacklist[wallet];
    }
    
    
    //only owner can change SellFeePercentages any time after deployment
    function setSellFeePercent(
        uint256 _redistributionFee,
        uint256 _liquidityFee,
        uint256 _marketingWalletFee,
        uint256 _burnFee
    ) external onlyOwner {
        reflectionFeeOnSelling = _redistributionFee;
        liquidityFeeOnSelling = _liquidityFee;
        marketingWalletFeeOnSelling = _marketingWalletFee;
        burnFeeOnSelling = _burnFee;
    }

    //to include or exludde  any address from fee
    function includeOrExcludeFromFee(address _account, bool _value)
        public
        onlyOwner
    {
        _isExcludedFromFee[_account] = _value;
    }

    //only owner can change MinTokenToSwap
    function setMinTokenToSwap(uint256 _amount) public onlyOwner {
        minTokenToSwap = _amount;
    }

    //only owner can change BuyFeePercentages any time after deployment
    function setBuyFeePercent(
        uint256 _redistributionFee,
        uint256 _liquidityFee,
        uint256 _marketingWalletFee,
        uint256 _burnFee
    ) external onlyOwner {
        reflectionFeeOnBuying = _redistributionFee;
        liquidityFeeOnBuying = _liquidityFee;
        marketingWalletFeeOnBuying = _marketingWalletFee;
        burnFeeOnBuying = _burnFee;
    }

      // disable Transfer delay - cannot be reenabled
    function disableTransferDelay(bool _onoff) external onlyOwner {
        transferDelayEnabled = _onoff;
    }
    
      // once enabled, can never be turned off
    function enableTrading() external onlyOwner {
        require(!tradingActive, "Cannot re-enable trading");
        tradingActive = true;
        tradingActiveBlock = block.number;
    }
    
    //only owner can change state of swapping, he can turn it in to true or false any time after deployment
    function enableOrDisableSwapAndLiquify(bool _state) public onlyOwner {
        swapAndLiquifyEnabled = _state;
        emit SwapAndLiquifyEnabledUpdated(_state);
    }

    // owner can change marketing address
    function setmarketingWalletAddress(address payable _newAddress)
        external
        onlyOwner
    {
        marketingWallet = _newAddress;
    }

    //to receive eth from dexRouter when swapping
    receive() external payable {}

    // internal functions for contract use

    function totalFeePerTx(uint256 tAmount) internal view returns (uint256) {
        uint256 percentage = tAmount
            .mul(
                _currentReflectionFee.add(_currentLiquidityFee).add(
                    _currentmarketingWalletFee.add(_currentBurnFee)
                )
            )
            .div(1e3);
        return percentage;
    }

    function _checkMaxWalletAmount(address to, uint256 amount) private view{
        if (
            !_isExcludedFromMaxHoldLimit[to] // by default false
        ) {
            if (isMaxHoldLimitValid) {
                require(
                    balanceOf(to).add(amount) <= maxHoldingAmount,
                    "BEP20: amount exceed max holding limit"
                );
            }
        }
    }


    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function setBuyFee() private {
        _currentReflectionFee = reflectionFeeOnBuying;
        _currentLiquidityFee = liquidityFeeOnBuying;
        _currentmarketingWalletFee = marketingWalletFeeOnBuying;
        _currentBurnFee = burnFeeOnBuying; 
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        rSupply = rSupply.sub(excludedRSupply);
        tSupply = tSupply.sub(excludedTSupply);
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function removeAllFee() private {
        _currentReflectionFee = 0;
        _currentLiquidityFee = 0;
        _currentmarketingWalletFee = 0;
        _currentBurnFee = 0;
    }

    function setSellFee() private {
        _currentReflectionFee = reflectionFeeOnSelling;
        _currentLiquidityFee = liquidityFeeOnSelling;
        _currentmarketingWalletFee = marketingWalletFeeOnSelling;
        _currentBurnFee = burnFeeOnSelling;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "Token: approve from the zero address");
        require(spender != address(0), "Token: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // base function to transfer tokens
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Token: transfer from the zero address");
        require(to != address(0), "Token: transfer to the zero address");
        require(amount > 0, "Token: transfer amount must be greater than zero");
        require(!_blacklist[to] && !_blacklist[from], "You have been blacklisted from transfering tokens");
        
       if (!tradingActive) {
    require(_isExcludedFromFee[from] || _isExcludedFromFee[to], "Trading is not active yet.");
    }
         
           
     // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.  
                if (transferDelayEnabled){
                    if (to != address(dexRouter) && to != address(dexRouter)){
                        require(_holderLastTransferTimestamp[tx.origin] < block.number, "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed.");
                        _holderLastTransferTimestamp[tx.origin] = block.number;
                    }
                }
        // swap and liquify
        swapAndLiquify(from, to);

        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        
        //if any _account belongs to _isExcludedFromFee _account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || !Fees) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        
       // buying handler
           
       if(!_isExcludedFromMinBuyLimit[recipient]){
            require(amount <= minBuyLimit,"Amount must be greater than minimum buy Limit" );
        }
        if (sender == dexPair && takeFee) {
            setBuyFee();
        }
        // selling handler
        else if (recipient == dexPair && takeFee) {
            setSellFee();
        }
        // normal transaction handler
        else {
            removeAllFee();
        }

        // check if sender or reciver excluded from reward then do transfer accordingly
        if (
            _isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]
        ) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (
            !_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]
        ) {
            _transferToExcluded(sender, recipient, amount);
        } else if (
            _isExcludedFromReward[sender] && _isExcludedFromReward[recipient]
        ) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    // if both sender and receiver are not excluded from reward
    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount.sub(totalFeePerTx(tAmount));
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(
            totalFeePerTx(tAmount).mul(currentRate)
        );
        _checkMaxWalletAmount(recipient, tTransferAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeAllFee(sender,tAmount, currentRate);
        _takeBurnFee(sender,tAmount, currentRate);
        _reflectFee(tAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    // if sender is excluded from reward
    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount.sub(totalFeePerTx(tAmount));
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(
            totalFeePerTx(tAmount).mul(currentRate)
        );
        _checkMaxWalletAmount(recipient, tTransferAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        excludedTSupply = excludedTSupply.sub(tAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeAllFee(sender,tAmount, currentRate);
        _takeBurnFee(sender,tAmount, currentRate);
        _reflectFee(tAmount);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    // if both sender and receiver are excluded from reward
    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount.sub(totalFeePerTx(tAmount));
        _checkMaxWalletAmount(recipient, tTransferAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        excludedTSupply = excludedTSupply.sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        excludedTSupply = excludedTSupply.add(tAmount);
        _takeAllFee(sender,tAmount, currentRate);
        _takeBurnFee(sender,tAmount, currentRate);
        _reflectFee(tAmount);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    // if receiver is excluded from reward
    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount.sub(totalFeePerTx(tAmount));
        uint256 rAmount = tAmount.mul(currentRate);
        _checkMaxWalletAmount(recipient, tTransferAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        excludedTSupply = excludedTSupply.add(tAmount);
        _takeAllFee(sender,tAmount, currentRate);
        _takeBurnFee(sender,tAmount, currentRate);
        _reflectFee(tAmount);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    // for automatic redistribution among all holders on each tx
    function _reflectFee(uint256 tAmount) private {
        uint256 tFee = tAmount.mul(_currentReflectionFee).div(1e3);
        uint256 rFee = tFee.mul(_getRate());
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

     // take fees for liquidity, marketing/dev
    function _takeAllFee(address sender,uint256 tAmount, uint256 currentRate) internal {
        uint256 tFee = tAmount
            .mul(_currentLiquidityFee.add(_currentmarketingWalletFee))
            .div(1e3);

        if (tFee > 0) {
            _accumulatedLiquidity = _accumulatedLiquidity.add(
                tAmount.mul(_currentLiquidityFee).div(1e3)
            );
            _accumulatedMarketingWallet = _accumulatedMarketingWallet.add(
                tAmount.mul(_currentmarketingWalletFee).div(1e3)
            );

            uint256 rFee = tFee.mul(currentRate);
            if (_isExcludedFromReward[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)].add(tFee);
            else _rOwned[address(this)] = _rOwned[address(this)].add(rFee);

            emit Transfer(sender, address(this), tFee);
        }
    }
   function _takeBurnFee(address sender,uint256 tAmount, uint256 currentRate) internal {
        uint256 burnFee = tAmount.mul(_currentBurnFee).div(1e3);
        uint256 rBurnFee = burnFee.mul(currentRate);
        _rOwned[burnAddress] = _rOwned[burnAddress].add(rBurnFee);

        emit Transfer(sender, burnAddress, burnFee);
    }

    function swapAndLiquify(address from, address to) private {
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is Dex pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        bool shouldSell = contractTokenBalance >= minTokenToSwap;

        if (
            shouldSell &&
            from != dexPair &&
            swapAndLiquifyEnabled &&
            !(from == address(this) && to == address(dexPair)) // swap 1 time
        ) {
            // approve contract
            _approve(address(this), address(dexRouter), contractTokenBalance);

            uint256 halfLiquid = _accumulatedLiquidity.div(2);
            uint256 otherHalfLiquid = _accumulatedLiquidity.sub(halfLiquid);

            uint256 tokenAmountToBeSwapped = contractTokenBalance.sub(
                otherHalfLiquid
            );

            // now swap into liquidty pool
            Utils.swapTokensForEth(address(dexRouter), tokenAmountToBeSwapped);

            uint256 ethBalance = address(this).balance;
            uint256 ethToBeAddedToLiquidity = ethBalance.mul(halfLiquid).div(tokenAmountToBeSwapped);
            uint256 ethFormarketingWallet = ethBalance.sub(ethToBeAddedToLiquidity);  

            // sending eth to award pool wallet
            if(ethFormarketingWallet > 0)
                marketingWallet.transfer(ethFormarketingWallet); 

            // add liquidity to Dex
            if(ethToBeAddedToLiquidity > 0){
                Utils.addLiquidity(
                    address(dexRouter),
                    owner(),
                    otherHalfLiquid,
                    ethToBeAddedToLiquidity
                );

                emit SwapAndLiquify(
                    halfLiquid,
                    ethToBeAddedToLiquidity,
                    otherHalfLiquid
                );
            }

            // Reset current accumulated amount
            _accumulatedLiquidity = 0; 
            _accumulatedMarketingWallet = 0;
        }
    }
}

// Library for doing a swap on Dex
library Utils {
    using SafeMath for uint256;

    function swapTokensForEth(address routerAddress, uint256 tokenAmount)
        internal
    {
        IDexRouter dexRouter = IDexRouter(routerAddress);

        // generate the Dex pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        // make the swap
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of eth
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
        IDexRouter dexRouter = IDexRouter(routerAddress);

        // add the liquidity
        dexRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp + 300
        );
    }
}