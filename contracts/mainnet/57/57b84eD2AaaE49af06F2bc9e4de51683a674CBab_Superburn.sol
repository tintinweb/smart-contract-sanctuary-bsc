/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// Superburn - The Ultimate Super Bowl Crypto Experience
// Twitter:  https://twitter.com/SuperBurnCoin
// Telegram: https://t.me/SuperBurnCoin
// Website:  https://superburncoin.com

// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event. C U ON THE MOON
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if(currentAllowance != type(uint256).max) { 
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }
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
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract Ownable is Context {
    address private _owner;
    uint256 public unlocksAt;
    address public locker;

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

    function lockContract(uint256 _days) external onlyOwner {
        require(locker == address(0), "Contract already locked");
        require(_days > 0, "No lock period specified");
        unlocksAt = block.timestamp + (_days * 1 days);
        locker = owner();
        renounceOwnership();
    }

    function unlockContract() external {
        require(locker != address(0) && msg.sender == locker, "Caller is not authorized");
        require(unlocksAt <= block.timestamp, "Contract still locked");
        emit OwnershipTransferred(address(0), locker);
        _owner = locker;
        locker = address(0);
        unlocksAt = 0;
    }
}

interface ILpPair {
    function sync() external;
}

interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IAntiSnipe {
  function setTokenOwner(address owner, address pair) external;

  function onPreTransferCheck(
    address sender,
    address from,
    address to,
    uint256 amount
  ) external returns (bool checked);
}

contract Superburn is ERC20, Ownable {
    IDexRouter public dexRouter;
    address public lpPair;

    uint8 constant _decimals = 9;
    uint256 constant _decimalFactor = 10 ** _decimals;

    bool private swapping;
    uint256 public swapTokensAtAmount;

    address public taxAddress;
    address public lpAddress;
    address public teamAddress = 0xFdC6DD4358400BBb422D8340663E37fAE9F7689F;

    bool public swapEnabled = true;

    bool public marketingBuyFees = true;
    bool public liquidityBuyFees = true;
    bool public teamBuyFees = true;
    bool public marketingSellFees = true;
    bool public liquiditySellFees = true;
    bool public teamSellFees = true;
    uint256 targetLiquidity = 10;
    uint256 targetLiquidityDenominator = 100;
    uint256 public maxWalletSize;
    uint256 _maxTxAmount = 10;

    uint256 public tradingActiveTime;
    IAntiSnipe public antisnipe;
    bool public protectionEnabled = false;
    bool public protectionDisabled = false;

    mapping(address => bool) private _isExcludedFromFees;
    mapping (address => bool) isTxLimitExempt;
    mapping(address => bool) public pairs;

    event SetPair(address indexed pair, bool indexed value);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event TargetLiquiditySet(uint256 percent);
    event ProtectionToggle(bool isEnabled);
    event ProtectionDisabled();
    event TransactionLimitSet(uint256 limit);
    event T_T_TOUCHDOWN(uint256 priceImpact);

    constructor(address newOwner, address marketing, address team) ERC20("Superburn", "SB") payable {
        // initialize router
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        dexRouter = IDexRouter(routerAddress);

        _approve(newOwner, routerAddress, type(uint256).max);
        _approve(address(this), routerAddress, type(uint256).max);

        uint256 totalSupply = 1_000_000_000_000 * _decimalFactor;
        maxWalletSize = totalSupply / 50;

        swapTokensAtAmount = (totalSupply * 5) / 10000; // 0.05 %

        taxAddress = marketing;
        teamAddress = team;
        lpAddress = team;

        excludeFromFees(newOwner, true);
        excludeFromFees(marketing, true);
        excludeFromFees(team, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);

        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[routerAddress] = true;

        _balances[address(this)] = totalSupply;
        _totalSupply = totalSupply;
        emit Transfer(address(0), address(this), totalSupply);

        transferOwnership(msg.sender);
    }

    receive() external payable {}

    function decimals() public pure override returns (uint8) {
        return 9;
    }

    function toggleSwap() external onlyOwner {
        swapEnabled = !swapEnabled;
    }

    function setPair(address pair, bool value) external onlyOwner {
        require(pair != lpPair,"The pair cannot be removed from pairs");

        pairs[pair] = value;
        emit SetPair(pair, value);
    }

    function toggleMarketingFees(bool sellFee) external onlyOwner {
        if(sellFee)
            marketingSellFees = !marketingSellFees;
        else
            marketingBuyFees = !marketingBuyFees;
    }

    function toggleLiquidityFees(bool sellFee) external onlyOwner {
        if(sellFee)
            liquiditySellFees = !liquiditySellFees;
        else
            liquidityBuyFees = !liquidityBuyFees;
    }

    function toggleTeamFees(bool sellFee) external onlyOwner {
        if(sellFee)
            teamSellFees = !teamSellFees;
        else
            teamBuyFees = !teamBuyFees;
    }

    function getSellFees() public view returns (uint256) {
        uint256 _sf = 0;
        if(marketingSellFees) _sf += 2;
        if(liquiditySellFees) _sf += 1;
        if(teamSellFees) _sf += 2;
        return _sf;
    }

    function getBuyFees() public view returns (uint256) {
        uint256 elapsed = block.timestamp - tradingActiveTime;
        if(protectionEnabled && elapsed < 1 minutes) {
            uint256 taxReduced = (elapsed / 10) * 10;
            if (taxReduced < 60) 
                return 60 - taxReduced;
        }

        uint256 _bf = 0;
        if(marketingBuyFees) _bf += 2;
        if(liquidityBuyFees) _bf += 1;
        if(teamBuyFees) _bf += 2;
        return _bf;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function txLimitExempt(address account, bool exempt) external onlyOwner {
        require(account != address(0), "Invalid address");
        isTxLimitExempt[account] = exempt;
    }

    function checkWalletLimit(address recipient, uint256 amount) internal view {
        require(balanceOf(recipient) + amount <= maxWalletSize || isTxLimitExempt[recipient], "Transfer amount exceeds the bag size.");
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= getTransactionLimit() || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function getTransactionLimit() public view returns (uint256) {
        return getCirculatingSupply() * _maxTxAmount / 1000;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "amount must be greater than 0");

        if (tradingActiveTime > 0 && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            if (!pairs[to] && to != address(0xdead)) {
                checkWalletLimit(to, amount);
            }

            uint256 fees = 0;
            uint256 _sf = getSellFees();
            uint256 _bf = getBuyFees();

            if (swapEnabled && !swapping && pairs[to] && _bf + _sf > 0) {
                swapping = true;
                swapBack(amount);
                swapping = false;
            }

            if (pairs[to] &&_sf > 0) {
                fees = (amount * _sf) / 100;
            }
            else if (_bf > 0 && pairs[from]) {
                fees = (amount * _bf) / 100;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;

            if (protectionEnabled)
                antisnipe.onPreTransferCheck(msg.sender, from, to, amount);
        }

        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        // make the swap
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack(uint256 amount) private {
        uint256 amountToSwap = balanceOf(address(this));
        if (amountToSwap < swapTokensAtAmount) return;
        if (amountToSwap > swapTokensAtAmount * 10) amountToSwap = swapTokensAtAmount * 10;
        if (amountToSwap > amount) amountToSwap = amount;
        if (amountToSwap == 0) return;

        uint256 _lpFee = (liquidityBuyFees ? 2 : 0) + (liquiditySellFees ? 2 : 0);
        uint256 _mkFee = (marketingBuyFees ? 4 : 0) + (marketingSellFees ? 4 : 0);
        uint256 _tmFee = (teamBuyFees ? 4 : 0) + (teamSellFees ? 4 : 0);
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : _lpFee;
        uint256 _totalFees = dynamicLiquidityFee + _mkFee + _tmFee;
        uint256 amountToLiquify = ((amountToSwap * dynamicLiquidityFee) / _totalFees) / 2;
        amountToSwap -= amountToLiquify;

        bool success;
        swapTokensForEth(amountToSwap);

        uint256 ethBalance = address(this).balance;

        _totalFees -= dynamicLiquidityFee / 2;
        uint256 amountLiquidity = (ethBalance * dynamicLiquidityFee) / _totalFees / 2;
        uint256 amountTeam = (ethBalance * _tmFee) / _totalFees;

        if(amountLiquidity > 0) {
            //Guaranteed swap desired to prevent trade blockages, return values ignored
            dexRouter.addLiquidityETH{value: amountLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                lpAddress,
                block.timestamp
            );
        }

        if(amountTeam > 0)
            (success, ) = teamAddress.call{value: amountTeam}("");

        (success, ) = taxAddress.call{value: address(this).balance}("");
    }

    function TOUCHDOWN(uint256 tokens) external onlyOwner {
        uint256 percentImpact = checkImpactEstimate(tokens * _decimalFactor) / 10000;
        require(percentImpact <= 25, "Too much price impact");
   
        super._transfer(lpPair, address(0xdead), tokens * _decimalFactor);
        ILpPair(lpPair).sync();
        emit T_T_TOUCHDOWN(percentImpact);
    }

    function checkImpactEstimate(uint256 amount) public view returns (uint256) {
        return amount * 1000000 / (balanceOf(lpPair) - amount);
    }

    function withdrawStuckETH() external onlyOwner {
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}("");
    }

    function setTaxAddress(address _taxAddress) external onlyOwner {
        require(_taxAddress != address(0), "_taxAddress address cannot be 0");
        taxAddress = _taxAddress;
    }

    function setLPAddress(address _lpAddress) external onlyOwner {
        require(_lpAddress != address(0), "_lpAddress address cannot be 0");
        require(lpAddress != address(0xdead), "LP is getting burnt");
        lpAddress = _lpAddress;
    }

    function setTeamAddress(address _teamAddress) external onlyOwner {
        require(_teamAddress != address(0), "_teamAddress address cannot be 0");
        teamAddress = _teamAddress;
    }

    function launch(address lpOwner, IAntiSnipe ans) external payable onlyOwner {
        require(tradingActiveTime == 0);

        lpPair = IDexFactory(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        pairs[lpPair] = true;
        antisnipe = ans;
        antisnipe.setTokenOwner(address(this), lpPair);

        dexRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,lpOwner,block.timestamp);

        tradingActiveTime = block.timestamp;
    }

    function setProtectionEnabled(bool _protect) external onlyOwner {
        if (_protect)
            require(!protectionDisabled, "Protection disabled");
        protectionEnabled = _protect;
        emit ProtectionToggle(_protect);
    }
    
    function disableProtection() external onlyOwner {
        protectionDisabled = true;
        emit ProtectionDisabled();
    }

    function setTxLimit(uint256 thousandths) external onlyOwner {
        require(thousandths > 0 , "Transaction limits too low");
        _maxTxAmount = thousandths;
        emit TransactionLimitSet(getTransactionLimit());
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyOwner {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
        emit TargetLiquiditySet(_target * 100 / _denominator);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return totalSupply() - (balanceOf(address(0xdead)) + balanceOf(address(0)));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return (accuracy * balanceOf(lpPair)) / getCirculatingSupply();
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function setMaxWallet(uint256 percent) external onlyOwner() {
        require(percent > 0);
        maxWalletSize = (getCirculatingSupply() * percent) / 100;
    }

    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
        require(newAmount >= getCirculatingSupply() / 100000, "Swap amount cannot be lower than 0.001% total supply.");
        require(newAmount <= getCirculatingSupply() / 1000, "Swap amount cannot be higher than 0.1% total supply.");
        swapTokensAtAmount = newAmount;
    }
}