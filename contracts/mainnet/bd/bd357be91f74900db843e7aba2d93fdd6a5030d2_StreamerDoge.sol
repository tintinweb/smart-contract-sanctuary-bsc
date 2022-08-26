/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// BEP20 contract Interface
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

// Dex RouterV2 contract interface
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

contract StreamerDoge is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    // private variables and functions for contract use
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromLimit;
    mapping(address => bool) private _isExcludedFromReward;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 100000000 * 1e9; // 100 Million total supply
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = "StreamerDoge"; // token name
    string private constant _symbol = "$SDOGE"; // token ticker
    uint8 private constant _decimals = 9; // token decimals

    IDexRouter public dexRouter; // Dex router address
    address public dexPair; // LP token address
    address payable public marketWallet; // market wallet address
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 public minTokenToSwap = 1000 * 1e9; // Amount will trigger swapAndliquidity BNB distribution
    uint256 public maxWalletAmount = 1 * 10**8 * 10**9;  // default to 100M
    uint256 private excludedTSupply; 
    uint256 private excludedRSupply; 

    uint256 public constant MAXFEE = 250; // MaxFee buy or Sell set to 25% Max
    uint256 public reflectionFeeOnBuying = 0; // 0% will be distributed among holder as token divideneds
    uint256 public liquidityFeeOnBuying = 30; // 3% will be added to the liquidity pool
    uint256 public marketWalletFeeOnBuying = 60; // 6% will go to the market/dev address
    uint256 public burnFeeOnBuying = 0; // 0% will go to dead address
    uint256 public reflectionFeeOnSelling = 0; // 0% will be distributed among holder as token divideneds
    uint256 public liquidityFeeOnSelling = 30; // 3% will be added to the liquidity pool
    uint256 public marketWalletFeeOnSelling = 60; // 6% will go to the market/dev address 
    uint256 public burnFeeOnSelling = 0; // 0% will go to dead address

    // for smart contract use
    uint256 private _currentReflectionFee;
    uint256 private _currentLiquidityFee;
    uint256 private _currentmarketWalletFee;
    uint256 private _currentBurnFee;

    uint256 private _accumulatedLiquidity;
    uint256 private _accumulatedMarketWallet;

    //Events for blockchain
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
        uint256 burnFee
    );

    event SetBuyFeePercent(
        uint256 reflectionFee,
        uint256 liquidityFee,
        uint256 marketWalletFee,
        uint256 burnFee
    );

    // constructor for initializing the contract
    constructor(address _uniswapRouterAddress, address payable _marketWallet) {
        require(
            _uniswapRouterAddress != address(0),
            "Router Address can not be the Zero Address"
        );
        require(
            _marketWallet != address(0),
            "Market Wallet Address can not be the Zero Address"
        );
        _rOwned[owner()] = _rTotal;
        marketWallet = _marketWallet;

        IDexRouter _dexRouter = IDexRouter(
            _uniswapRouterAddress
            // 0x10ED43C718714eb63d5aA57B78B54704E256024E
            // 0xDE2Db97D54a3c3B008a097B2260633E6cA7DB1AF
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

        //exclude owner from wallet limit
        _isExcludedFromLimit[owner()] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }

    // token standard functions

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

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if (_isExcludedFromReward[_msgSender()]) {
            require(_tOwned[_msgSender()] >= amount, "Not enough tokens");
        } else {
            require(_rOwned[_msgSender()] >= amount, "Not enough tokens");
        }
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), _spender, _amount);
        return true;
    }

    function increaseAllowance(address _spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            _spender,
            _allowances[_msgSender()][_spender].add(addedValue)
        );
        return true;
    }

     function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public override returns (bool) {
        _transfer(_sender, _recipient, _amount);
        _approve(
            _sender,
            _msgSender(),
            _allowances[_sender][_msgSender()].sub(
                _amount,
                "Token: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function decreaseAllowance(address _spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            _spender,
            _allowances[_msgSender()][_spender].sub(
                subtractedValue,
                "Token: decreased allowance below zero"
            )
        );
        return true;
    }

    // to check how much tokens get redistributed among holders till now
    function totalHolderDistribution() public view returns (uint256) {
        return _tFeeTotal;
    }

    // to check wether the address is excluded from reward or not
    function isExcludedFromReward(address _account) public view returns (bool) {
        return _isExcludedFromReward[_account];
    }

    // to check wether the address is excluded from fee or not
    function isExcludedFromFee(address _account) public view returns (bool) {
        return _isExcludedFromFee[_account];
    }

    // Airdrop function to distribute tokens
    function airDrop(address[] memory _address, uint256[] memory _amount) public onlyOwner {
        for(uint i=0; i< _amount.length; i++){
            address adr = _address[i];
            uint amount = _amount[i];
            _transfer(msg.sender, adr, amount);
        }
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

    // include any address in rewards
    function includeInReward(address _account) external onlyOwner {
        require(
            _account != address(0),
            "Address can not be the Zero Address"
        );
        require(
            _isExcludedFromReward[_account],
            "Token: _account is already included"
        );

        excludedTSupply = excludedTSupply.sub(_tOwned[_account]);
        excludedRSupply = excludedRSupply.sub(_rOwned[_account]);
        _rOwned[_account] = _tOwned[_account].mul(_getRate());
        _tOwned[_account] = 0;
        _isExcludedFromReward[_account] = false;
    }

    // exclude any address from rewards
    function excludeFromReward(address _account) public onlyOwner {
        require(
            !_isExcludedFromReward[_account],
            "Token: _account is already excluded"
        );
        require(
            _account != address(0),
            "Address can not be the Zero Address"
        );
        if (_rOwned[_account] > 0) {
            _tOwned[_account] = tokenFromReflection(_rOwned[_account]);
        }
        _isExcludedFromReward[_account] = true;
        excludedTSupply = excludedTSupply.add(_tOwned[_account]);
        excludedRSupply = excludedRSupply.add(_rOwned[_account]);
    }

    // exclude from wallet limit
    function excludeFromLimit(address _account, bool excluded)
        external
        onlyOwner
    {
        require(
            _account != address(0),
            "Address can not be the Zero Address"
        );
        _isExcludedFromLimit[_account] = excluded;
    }

    // to check wether the address is excluded from wallet limit or not
    function isExcludedFromLimit(address _account) public view returns (bool) {
        return _isExcludedFromLimit[_account];
    }

    function claimStuckTokens(address _token) external onlyOwner {
        require(_token != address(this), "No rugs");
        if (_token == address(0x0)) {
            payable(owner()).transfer(address(this).balance);
            return;
        }
        IBEP20 erc20token = IBEP20(_token);
        uint256 balance = erc20token.balanceOf(address(this));
        erc20token.transfer(owner(), balance);
    }

    // Sell Fee setter 
    function setSellFeePercent(
        uint256 _redistributionFee,
        uint256 _liquidityFee,
        uint256 _marketWalletFee,
        uint256 _burnFee
    ) external onlyOwner {
        require((_redistributionFee + _liquidityFee + _marketWalletFee + _burnFee) <= 250, "Max Sell Fee 250 (25%)");
        reflectionFeeOnSelling = _redistributionFee;
        liquidityFeeOnSelling = _liquidityFee;
        marketWalletFeeOnSelling = _marketWalletFee;
        burnFeeOnSelling = _burnFee;
        emit SetSellFeePercent(
            _redistributionFee,
            _liquidityFee,
            _marketWalletFee,
            _burnFee
        );
    }

    // include or exlude any address from Fee
    function includeOrExcludeFromFee(address _account, bool _value)
        public
        onlyOwner
    {
        require(
            _account != address(0),
            "Address can not be the Zero Address"
        );
        _isExcludedFromFee[_account] = _value;
    }

    // MinTokenToSwap Amount to trigger BNB distribution to Marketing/Liquidity
    function setMinTokenToSwap(uint256 _amount) public onlyOwner {
        minTokenToSwap = _amount;
        emit MinTokensBeforeSwapUpdated(_amount);
    }

    // BUY Fee
    function setBuyFeePercent(
        uint256 _redistributionFee,
        uint256 _liquidityFee,
        uint256 _marketWalletFee,
        uint256 _burnFee
    ) external onlyOwner {
        require((_redistributionFee + _liquidityFee + _marketWalletFee + _burnFee) <= 250, "Max Buy Fee 250 (25%)");
        reflectionFeeOnBuying = _redistributionFee;
        liquidityFeeOnBuying = _liquidityFee;
        marketWalletFeeOnBuying = _marketWalletFee;
        burnFeeOnBuying = _burnFee;
        emit SetBuyFeePercent(
            _redistributionFee,
            _liquidityFee,
            _marketWalletFee,
            _burnFee
        );
    }

    // Change Market Wallet Address
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

    // Set Max Wallet token amount
    function setMaxWallet(uint256 value) 
        external 
        onlyOwner 
    {
        require((value >= 1 * 10**6 * 10**9), "Minimum value is 1%");
        maxWalletAmount = value;
    }

    // Change Router and Pair addresses
    function setRoute(IDexRouter _router, address _pair) external onlyOwner {
        require(
            _pair != address(0),
            "Pair Address can not be the Zero Address"
        );
        dexRouter = _router;
        dexPair = _pair;
    }

    // to receive BNB from dexRouter when swapping
    receive() external payable {}

    // internal functions for contract use ONLY
    function totalFeePerTx(uint256 tAmount) internal view returns (uint256) {
        uint256 percentage = tAmount
            .mul(
                _currentReflectionFee.add(_currentLiquidityFee).add(
                    _currentmarketWalletFee.add(_currentBurnFee)
                )
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
        _currentBurnFee = 0;
    }

    function setSellFee() private {
        _currentReflectionFee = reflectionFeeOnSelling;
        _currentLiquidityFee = liquidityFeeOnSelling;
        _currentmarketWalletFee = marketWalletFeeOnSelling;
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
        _currentBurnFee = burnFeeOnBuying; 
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

        // swap and liquify
        swapAndLiquify(from, to);

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any _account belongs to _isExcludedFromFee _account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        if (!_isExcludedFromLimit[from] && !_isExcludedFromLimit[to]) {
            require(
                balanceOf(to) + amount <= maxWalletAmount,
                "Balance would exceed wallet limit"
            );
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) private {
        require(_owner != address(0), "Token: approve from the zero address");
        require(_spender != address(0), "Token: approve to the zero address");

        _allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        // buying handler
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
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        excludedTSupply = excludedTSupply.sub(tAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
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

    // if both sender and receiver are excluded from reward
    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount.sub(totalFeePerTx(tAmount));
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        excludedTSupply = excludedTSupply.sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        excludedTSupply = excludedTSupply.add(tAmount);
        _takeAllFee(sender,tAmount, currentRate);
        _takeBurnFee(sender,tAmount, currentRate);
        _reflectFee(tAmount);

        emit Transfer(sender, recipient, tTransferAmount);
    }

     // take fees for liquidity, market/dev
    function _takeAllFee(address sender,uint256 tAmount, uint256 currentRate) internal {
        uint256 tFee = tAmount
            .mul(_currentLiquidityFee.add(_currentmarketWalletFee))
            .div(1e3);

        if (tFee > 0) {
            _accumulatedLiquidity = _accumulatedLiquidity.add(
                tAmount.mul(_currentLiquidityFee).div(1e3)
            );
            _accumulatedMarketWallet = _accumulatedMarketWallet.add(
                tAmount.mul(_currentmarketWalletFee).div(1e3)
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
            uint256 bnbFormarketWallet = deltaBalance.sub(
                bnbToBeAddedToLiquidity
            );

            // sending bnb to Market Wallet
            if (bnbFormarketWallet > 0)
                marketWallet.transfer(bnbFormarketWallet);

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
        }
    }
}

// Library for swapping on Dex
library Utils {
    using SafeMath for uint256;

    function swapTokensForEth(address routerAddress, uint256 tokenAmount)
        internal
    {
        IDexRouter dexRouter = IDexRouter(routerAddress);

        // Dex pair
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        // swap
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
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
        IDexRouter dexRouter = IDexRouter(routerAddress);

        // add liquidity
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