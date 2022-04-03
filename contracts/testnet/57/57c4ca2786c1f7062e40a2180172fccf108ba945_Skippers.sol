/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// SPDX-License-Identifier: MIT
//
// Welcome to Skippers-SKR!
//
// https://skippers-skr.com
//
// https://t.me/skippers_SKR        Official Channel
// https://t.me/Skippers_SKR_Chat   Official Chat
//

pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

// IBEP20 Interface
interface IBEP20 {
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

        return c;
    }
}

contract Skippers is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    // Dead Address
    address public immutable burnAddress =
        0x000000000000000000000000000000000000dEaD;

    // private variables and functions are for contract use ONLY!
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromReward;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 990000000 * 1e18; // 990 Millions total supply
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal; // Tokens Distributed

    string private constant _name = "Skippers"; // token name
    string private constant _symbol = "SKR"; // token ticker
    uint8 private constant _decimals = 18; // token decimals

    IDexRouter public dexRouter; // Dex router address
    address public dexPair; // LP token Pair address
    address payable public marketWallet; // market wallet address
    address payable public rewardWallet; // Reward wallet address

    uint256 public minTokenToSwap = 1000 * 1e18; // Amount will trigger the swap and add liquidity
    uint256 private excludedTSupply; // for contract use
    uint256 private excludedRSupply; // for contract use

    bool public swapAndLiquifyEnabled = true; // should be true to turn on to liquidate the pool
    bool public Fees = true;

    uint256 public reflectionFeeOnBuying = 30; // 3% will be distributed among holder as token divideneds
    uint256 public liquidityFeeOnBuying = 20; // 2% will be added to the liquidity pool
    uint256 public marketWalletFeeOnBuying = 20; // 2% in BNB will go to the market/dev address
    uint256 public rewardWalletFeeOnBuying = 20; // 2% will go to the reward address
    uint256 public burnFeeOnBuying = 5; // 0.5% will go to dead address
    uint256 public reflectionFeeOnSelling = 30; // 3% will be distributed among holder as token divideneds
    uint256 public liquidityFeeOnSelling = 20; // 2% will be added to the liquidity pool
    uint256 public marketWalletFeeOnSelling = 20; // 2% in BNB will go to the market/dev address
    uint256 public rewardWalletFeeOnSelling = 20; // 2% will go to the reward address
    uint256 public burnFeeOnSelling = 5; //0.5% will go to dead address

    // for smart contract use
    uint256 private _currentReflectionFee;
    uint256 private _currentLiquidityFee;
    uint256 private _currentmarketWalletFee;
    uint256 private _currentrewardWalletFee;
    uint256 private _currentBurnFee;

    uint256 private _accumulatedLiquidity;
    uint256 private _accumulatedMarketWallet;
    uint256 private _accumulatedRewardWallet;

    //Events for blockchain
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 tokensIntoLiqudity
    );
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SetSellFeePercent(
        uint256 reflectionFee,
        uint256 liquidityFee,
        uint256 marketWalletFee,
        uint256 rewardFee,
        uint256 burnFee
    );
    event SetBuyFeePercent(
        uint256 reflectionFee,
        uint256 liquidityFee,
        uint256 marketWalletFee,
        uint256 rewardFee,
        uint256 burnFee
    );

    // constructor for initializing the SKR contract
    constructor(address payable _marketWallet, address payable _rewardWallet) {
        _rOwned[owner()] = _rTotal;
        marketWallet = _marketWallet;
        rewardWallet = _rewardWallet;

        IDexRouter _dexRouter = IDexRouter(
            // 0x10ED43C718714eb63d5aA57B78B54704E256024E // BSC PancakeRouterV2 mainnet
            0xDE2Db97D54a3c3B008a097B2260633E6cA7DB1AF // PancakeRouterV2 used by PancakeSwap-Testnet
            // 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 // PancakeRouter BSC testnet
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

        emit Transfer(address(0), owner(), _tTotal);
    }

    // token standards by Blockchain

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

    function balanceOf(address _account)
        public
        view
        override
        returns (uint256)
    {
        if (_isExcludedFromReward[_account]) return _tOwned[_account];
        return tokenFromReflection(_rOwned[_account]);
    }

    function transfer(address recipient, uint256 _amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, _amount);
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

    function approve(address _spender, uint256 _amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), _spender, _amount);
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

    // to check how many tokens got redistributed among holders until now
    function totalHolderDistribution() public view returns (uint256) {
        return _tFeeTotal;
    }

    // to check whether the address is excluded from rewards or not
    function isExcludedFromReward(address _account) public view returns (bool) {
        return _isExcludedFromReward[_account];
    }

    // to check whether the address is excluded from ALL fees or not
    function isExcludedFromFee(address _account) public view returns (bool) {
        return _isExcludedFromFee[_account];
    }

    // For manual distribution of SKR Tokens to the Holders ie. rewards/price winning
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

    // Public function to calculate reflections from token amount entered
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

    // set functions for owner ONLY!
    // to include any address in reward
    function includeInReward(address _account) external onlyOwner {
        require(
            _isExcludedFromReward[_account],
            "Token: _Account is already excluded"
        );
        excludedTSupply = excludedTSupply.sub(_tOwned[_account]);
        excludedRSupply = excludedRSupply.sub(_rOwned[_account]);
        _rOwned[_account] = _tOwned[_account].mul(_getRate());
        _tOwned[_account] = 0;
        _isExcludedFromReward[_account] = false;
    }

    //to iexclude any address from reward
    function excludeFromReward(address _account) public onlyOwner {
        require(
            !_isExcludedFromReward[_account],
            "Token: _Account is already excluded"
        );
        if (_rOwned[_account] > 0) {
            _tOwned[_account] = tokenFromReflection(_rOwned[_account]);
        }
        _isExcludedFromReward[_account] = true;
        excludedTSupply = excludedTSupply.add(_tOwned[_account]);
        excludedRSupply = excludedRSupply.add(_rOwned[_account]);
    }

    //change BuyFeePercentages any time after deployment with a max of 10%
    function setBuyFeePercent(
        uint256 _redistributionFee,
        uint256 _liquidityFee,
        uint256 _marketWalletFee,
        uint256 _rewardWalletFee,
        uint256 _burnFee
    ) external onlyOwner {
        reflectionFeeOnBuying = _redistributionFee;
        liquidityFeeOnBuying = _liquidityFee;
        marketWalletFeeOnBuying = _marketWalletFee;
        rewardWalletFeeOnBuying = _rewardWalletFee;
        burnFeeOnBuying = _burnFee;
        emit SetBuyFeePercent(
            _redistributionFee,
            _liquidityFee,
            _marketWalletFee,
            _rewardWalletFee,
            _burnFee
        );
    }

    // change SellFeePercentages any time after deployment
    function setSellFeePercent(
        uint256 _redistributionFee,
        uint256 _liquidityFee,
        uint256 _marketWalletFee,
        uint256 _rewardWalletFee,
        uint256 _burnFee
    ) external onlyOwner {
        reflectionFeeOnSelling = _redistributionFee;
        liquidityFeeOnSelling = _liquidityFee;
        marketWalletFeeOnSelling = _marketWalletFee;
        rewardWalletFeeOnSelling = _rewardWalletFee;
        burnFeeOnSelling = _burnFee;
        emit SetSellFeePercent(
            _redistributionFee,
            _liquidityFee,
            _marketWalletFee,
            _rewardWalletFee,
            _burnFee
        );
    }

    //to include or exlude  any address from fee
    function includeOrExcludeFromFee(address _account, bool _value)
        public
        onlyOwner
    {
        _isExcludedFromFee[_account] = _value;
    }

    //change MinTokenToSwap which triggers BNB swap to Market/Reward wallets
    function setMinTokenToSwap(uint256 _amount) public onlyOwner {
        minTokenToSwap = _amount;
        emit MinTokensBeforeSwapUpdated(_amount);
    }

    //only owner can change state of swapping, he can turn it in to true or false any time after deployment
    function enableOrDisableSwapAndLiquify(bool _state) public onlyOwner {
        swapAndLiquifyEnabled = _state;
        emit SwapAndLiquifyEnabledUpdated(_state);
    }

    //To enable or disable all fees when set it to true fees will be disabled
    function enableOrDisableFees(bool _state) external onlyOwner {
        Fees = _state;
    }

    // owner can change market address
    function setMarketWalletAddress(address payable _newAddress)
        external
        onlyOwner
    {
        require(
            _newAddress != address(0),
            "Market Wallet Address can not be the Zero Address"
        );
        marketWallet = _newAddress;
    }

    // owner can change reward address
    function setrewardWalletAddress(address payable _newAddress)
        external
        onlyOwner
    {
        require(
            _newAddress != address(0),
            "Reward Wallet Address can not be the Zero Address"
        );
        rewardWallet = _newAddress;
    }

    // owner can change router and pair address
    function setRoute(IDexRouter _router, address _pair) external onlyOwner {
        require(
            _router != IDexRouter(address(0)) && _pair != address(0),
            "IDexRouter or IDexPair can not be the Zero Address"
        );
        dexRouter = _router;
        dexPair = _pair;
    }

    //to receive BNB from dexRouter when swapping
    receive() external payable {}

    // internal functions for contract use
    function totalFeePerTx(uint256 tAmount) internal view returns (uint256) {
        uint256 percentage = tAmount
            .mul(
                _currentReflectionFee
                    .add(_currentLiquidityFee)
                    .add(_currentmarketWalletFee)
                    .add(_currentrewardWalletFee)
                    .add(_currentBurnFee)
            )
            .div(1e3);
        return percentage;
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function removeAllFee() private {
        _currentReflectionFee = 0;
        _currentLiquidityFee = 0;
        _currentmarketWalletFee = 0;
        _currentrewardWalletFee = 0;
        _currentBurnFee = 0;
    }

    function setSellFee() private {
        _currentReflectionFee = reflectionFeeOnSelling;
        _currentLiquidityFee = liquidityFeeOnSelling;
        _currentmarketWalletFee = marketWalletFeeOnSelling;
        _currentrewardWalletFee = rewardWalletFeeOnSelling;
        _currentBurnFee = burnFeeOnSelling;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        rSupply = rSupply.sub(excludedRSupply);
        tSupply = tSupply.sub(excludedTSupply);
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function setBuyFee() private {
        _currentReflectionFee = reflectionFeeOnBuying;
        _currentLiquidityFee = liquidityFeeOnBuying;
        _currentmarketWalletFee = marketWalletFeeOnBuying;
        _currentrewardWalletFee = rewardWalletFeeOnBuying;
        _currentBurnFee = burnFeeOnBuying;
    }

    // base function to transafer tokens
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Token: transfer from the zero address");
        require(to != address(0), "Token: transfer to the zero address");
        require(amount > 0, "Token: transfer amount must be greater than zero");

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

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 _amount,
        bool _takeFee
    ) private {
        // buying handler
        if (sender == dexPair && _takeFee) {
            setBuyFee();
        }
        // selling handler
        else if (recipient == dexPair && _takeFee) {
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
            _transferFromExcluded(sender, recipient, _amount);
        } else if (
            !_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]
        ) {
            _transferToExcluded(sender, recipient, _amount);
        } else if (
            _isExcludedFromReward[sender] && _isExcludedFromReward[recipient]
        ) {
            _transferBothExcluded(sender, recipient, _amount);
        } else {
            _transferStandard(sender, recipient, _amount);
        }
    }

    // if both sender and receiver are not excluded from reward
    function _transferStandard(
        address from,
        address to,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount.sub(totalFeePerTx(tAmount));
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(
            totalFeePerTx(tAmount).mul(currentRate)
        );
        _rOwned[from] = _rOwned[from].sub(rAmount);
        _rOwned[to] = _rOwned[to].add(rTransferAmount);
        _takeAllFee(from, tAmount, currentRate);
        _takeBurnFee(from, tAmount, currentRate);
        _reflectFee(tAmount);
        emit Transfer(from, to, tTransferAmount);
    }

    // if sender is excluded from reward
    function _transferFromExcluded(
        address from,
        address to,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount.sub(totalFeePerTx(tAmount));
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(
            totalFeePerTx(tAmount).mul(currentRate)
        );
        _tOwned[from] = _tOwned[from].sub(tAmount);
        excludedTSupply = excludedTSupply.sub(tAmount);
        _rOwned[to] = _rOwned[to].add(rTransferAmount);
        _takeAllFee(from, tAmount, currentRate);
        _takeBurnFee(from, tAmount, currentRate);
        _reflectFee(tAmount);

        emit Transfer(from, to, tTransferAmount);
    }

    // if receiver is excluded from reward
    function _transferToExcluded(
        address from,
        address to,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount.sub(totalFeePerTx(tAmount));
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[from] = _rOwned[from].sub(rAmount);
        _tOwned[to] = _tOwned[to].add(tTransferAmount);
        excludedTSupply = excludedTSupply.add(tAmount);
        _takeAllFee(from, tAmount, currentRate);
        _takeBurnFee(from, tAmount, currentRate);
        _reflectFee(tAmount);

        emit Transfer(from, to, tTransferAmount);
    }

    // for automatic redistribution among all holders on each tx
    function _reflectFee(uint256 tAmount) private {
        uint256 tFee = tAmount.mul(_currentReflectionFee).div(1e3);
        uint256 rFee = tFee.mul(_getRate());
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    // if both sender and receiver are excluded from reward
    function _transferBothExcluded(
        address from,
        address to,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount.sub(totalFeePerTx(tAmount));
        _tOwned[from] = _tOwned[from].sub(tAmount);
        excludedTSupply = excludedTSupply.sub(tAmount);
        _tOwned[to] = _tOwned[to].add(tTransferAmount);
        excludedTSupply = excludedTSupply.add(tAmount);
        _takeAllFee(from, tAmount, currentRate);
        _takeBurnFee(from, tAmount, currentRate);
        _reflectFee(tAmount);

        emit Transfer(from, to, tTransferAmount);
    }

    // take fees for liquidity, market/dev
    function _takeAllFee(
        address from,
        uint256 tAmount,
        uint256 currentRate
    ) internal {
        uint256 tFee = tAmount
            .mul(
                _currentLiquidityFee.add(_currentmarketWalletFee).add(
                    _currentrewardWalletFee
                )
            )
            .div(1e3);

        if (tFee > 0) {
            _accumulatedLiquidity = _accumulatedLiquidity.add(
                tAmount.mul(_currentLiquidityFee).div(1e3)
            );
            _accumulatedMarketWallet = _accumulatedMarketWallet.add(
                tAmount.mul(_currentmarketWalletFee).div(1e3)
            );
            _accumulatedRewardWallet = _accumulatedRewardWallet.add(
                tAmount.mul(_currentrewardWalletFee).div(1e3)
            );
            uint256 rFee = tFee.mul(currentRate);
            if (_isExcludedFromReward[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)].add(tFee);
            else _rOwned[address(this)] = _rOwned[address(this)].add(rFee);

            emit Transfer(from, address(this), tFee);
        }
    }

    function _takeBurnFee(
        address from,
        uint256 tAmount,
        uint256 currentRate
    ) internal {
        uint256 burnFee = tAmount.mul(_currentBurnFee).div(1e3);
        uint256 rBurnFee = burnFee.mul(currentRate);
        _rOwned[burnAddress] = _rOwned[burnAddress].add(rBurnFee);

        emit Transfer(from, burnAddress, burnFee);
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

            // now is to lock into liquidty pool
            Utils.swapTokensForEth(address(dexRouter), tokenAmountToBeSwapped);

            uint256 deltaBalance = address(this).balance;
            uint256 bnbToBeAddedToLiquidity = deltaBalance.mul(halfLiquid).div(
                tokenAmountToBeSwapped
            );

            // calculate percentage of remaining bnb for marketWallet and rewardWallet
            uint256 bnbSubtotal = deltaBalance.sub(bnbToBeAddedToLiquidity);
            uint256 bnbMarketshare = marketWalletFeeOnBuying.add(
                marketWalletFeeOnSelling
            );
            uint256 bnbRewardshare = rewardWalletFeeOnBuying.add(
                rewardWalletFeeOnSelling
            );
            uint256 bnbCombined = bnbMarketshare.add(bnbRewardshare);
            uint256 bnbFormarketWallet = bnbSubtotal.mul(bnbMarketshare).div(
                bnbCombined
            );

            // rewardWallet gets the remainder bnb
            uint256 bnbForrewardWallet = deltaBalance
                .sub(bnbToBeAddedToLiquidity)
                .sub(bnbFormarketWallet);

            // sending bnb to market wallet
            if (bnbFormarketWallet > 0)
                marketWallet.transfer(bnbFormarketWallet);

            // sending bnb to reward wallet
            if (bnbForrewardWallet > 0)
                rewardWallet.transfer(bnbForrewardWallet);

            // add liquidity to Dex
            if (bnbToBeAddedToLiquidity > 0) {
                Utils.addLiquidity(
                    address(dexRouter),
                    owner(),
                    otherHalfLiquid,
                    bnbToBeAddedToLiquidity
                );

                emit SwapAndLiquify(
                    halfLiquid,
                    bnbToBeAddedToLiquidity,
                    otherHalfLiquid
                );
            }

            // Reset current accumulated amount
            _accumulatedLiquidity = 0;
            _accumulatedMarketWallet = 0;
            _accumulatedRewardWallet = 0;
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
            0, // accept any amount of BNB
            path,
            address(this), // SKR Contract
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