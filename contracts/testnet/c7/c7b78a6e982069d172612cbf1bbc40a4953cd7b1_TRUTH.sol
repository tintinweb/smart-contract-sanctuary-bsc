/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
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

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {
    address private owner;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}


interface IUniswapV2Router01 {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}


interface IFeeReceiver {
    function trigger() external;
}

interface ISwapper {
    function buy(address user) external payable;

    function sell(address user) external;
}

interface IPair {
    function sync() external;
}

/**
    Modular Upgradeable Token
    Token System Designed By DeFi Mark
 */
contract TRUTH is IERC20, Ownable {
    // total supply
    uint256 private _totalSupply = 11_200_000 * 10**18;

    // token data
    string private constant _name = "Truth Seekers";
    string private constant _symbol = "TRUTH";
    uint8 private constant _decimals = 18;

    // balances
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Swapper
    address public swapper;

    // Amount Burned
    uint256 public totalBurned;

    // Taxation on transfers
    uint256 public buyFee = 0;
    uint256 public sellFee = 1500;
    uint256 public transferFee = 0;
    uint256 public constant TAX_DENOM = 10000;

    // permissions
    struct Permissions {
        bool isFeeExempt;
        bool isLiquidityPool;
        bool canSellBurn;
        bool isPauseExempt;
        bool isBlacklisted;
    }
    mapping(address => Permissions) public permissions;

    // Fee Recipients
    address public sellFeeRecipient;
    address public buyFeeRecipient;
    address public transferFeeRecipient;

    // Trigger Fee Recipients
    bool public triggerBuyRecipient = false;
    bool public triggerTransferRecipient = true;
    bool public triggerSellRecipient = false;

    // Ownership Functions
    bool public tradingPaused = false;

    // events
    event SetBuyFeeRecipient(address recipient);
    event SetSellFeeRecipient(address recipient);
    event SetTransferFeeRecipient(address recipient);
    event SetFeeExemption(address account, bool isFeeExempt);
    event SetCanSellBurn(address account, bool canSellBurn);
    event SetAutomatedMarketMaker(address account, bool isMarketMaker);
    event SetFees(uint256 buyFee, uint256 sellFee, uint256 transferFee);
    event SetSwapper(address newSwapper);
    event SetAutoTriggers(
        bool triggerBuy,
        bool triggerSell,
        bool triggerTransfer
    );

    constructor() {
        // exempt sender for tax-free initial distribution
        permissions[msg.sender].isFeeExempt = true;
        permissions[msg.sender].isPauseExempt = true;

        // initial supply allocation
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /////////////////////////////////
    /////    ERC20 FUNCTIONS    /////
    /////////////////////////////////

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
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

    function name() public pure override returns (string memory) {
        return _name;
    }

    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return _decimals;
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

    /** Transfer Function */
    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        if (msg.sender == recipient) {
            return _sell(amount, msg.sender);
        } else {
            return _transferFrom(msg.sender, recipient, amount);
        }
    }

    /** Transfer Function */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(
            _allowances[sender][msg.sender] >= amount,
            "Insufficient Allowance"
        );
        _allowances[sender][msg.sender] -= amount;
        return _transferFrom(sender, recipient, amount);
    }

    /////////////////////////////////
    /////   PUBLIC FUNCTIONS    /////
    /////////////////////////////////

    function burn(uint256 amount) external returns (bool) {
        return _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) external returns (bool) {
        require(
            _allowances[account][msg.sender] >= amount,
            "Insufficient Allowance"
        );
        _allowances[account][msg.sender] -= amount;
        return _burn(account, amount);
    }

    function sell(uint256 amount) external returns (bool) {
        return _sell(amount, msg.sender);
    }

    function sellFor(uint256 amount, address recipient)
        external
        returns (bool)
    {
        return _sell(amount, recipient);
    }

    function buyFor(address account) external payable {
        ISwapper(swapper).buy{value: msg.value}(account);
    }

    receive() external payable {
        ISwapper(swapper).buy{value: address(this).balance}(msg.sender);
    }

    function sellBurn(
        uint256 amount,
        address to,
        address router,
        address receiveToken,
        uint256 excess
    ) external {
        require(
            permissions[msg.sender].canSellBurn == true,
            "Invalid Permissions"
        );
        require(to != address(0), "Invalid Params");
        require(_balances[msg.sender] >= amount, "Insufficient Balance");

        // Instantiate Router
        IUniswapV2Router02 _router = IUniswapV2Router02(router);

        if (amount > 0) {
            // allocate balance to address(this)
            _balances[msg.sender] -= amount;
            _balances[address(this)] += amount;
            emit Transfer(msg.sender, address(this), amount);

            // approve tokens for router
            _allowances[address(this)][router] = amount;

            // swap path
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = receiveToken;

            // sell tokens for underlying
            if (receiveToken == _router.WETH()) {
                _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    amount,
                    0,
                    path,
                    to,
                    block.timestamp + 1000
                );
            } else {
                _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    amount,
                    0,
                    path,
                    to,
                    block.timestamp + 1000
                );
            }

            // clear memory
            delete path;
        }

        // calculate amount to burn
        uint256 amountToBurn = amount + excess;

        // fetch pair address
        address pair = IUniswapV2Factory(_router.factory()).getPair(
            address(this),
            receiveToken
        );
        require(pair != address(0), "No Pair");

        // ensure enough balance exists in the pair with at least 1 token extra
        require(
            _balances[pair] >= (amountToBurn + 10**18),
            "Amount Exceeds Pair Balance Plus Min Reserve"
        );

        // burn tokens from the pair
        _burn(pair, amountToBurn);

        // sync the LP with the new values
        IPair(pair).sync();
    }

    /////////////////////////////////
    /////    OWNER FUNCTIONS    /////
    /////////////////////////////////

    function withdraw(address token) external onlyOwner {
        require(token != address(0), "Zero Address");
        bool s = IERC20(token).transfer(
            msg.sender,
            IERC20(token).balanceOf(address(this))
        );
        require(s, "Failure On Token Withdraw");
    }

    function withdrawBNB() external onlyOwner {
        (bool s, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function setTransferFeeRecipient(address recipient) external onlyOwner {
        require(recipient != address(0), "Zero Address");
        transferFeeRecipient = recipient;
        permissions[recipient].isFeeExempt = true;
        emit SetTransferFeeRecipient(recipient);
    }

    function setBuyFeeRecipient(address recipient) external onlyOwner {
        require(recipient != address(0), "Zero Address");
        buyFeeRecipient = recipient;
        permissions[recipient].isFeeExempt = true;
        emit SetBuyFeeRecipient(recipient);
    }

    function setSellFeeRecipient(address recipient) external onlyOwner {
        require(recipient != address(0), "Zero Address");
        sellFeeRecipient = recipient;
        permissions[recipient].isFeeExempt = true;
        emit SetSellFeeRecipient(recipient);
    }

    function registerAutomatedMarketMaker(address account) external onlyOwner {
        require(account != address(0), "Zero Address");
        require(!permissions[account].isLiquidityPool, "Already An AMM");
        permissions[account].isLiquidityPool = true;
        emit SetAutomatedMarketMaker(account, true);
    }

    function unRegisterAutomatedMarketMaker(address account)
        external
        onlyOwner
    {
        require(account != address(0), "Zero Address");
        require(permissions[account].isLiquidityPool, "Not An AMM");
        permissions[account].isLiquidityPool = false;
        emit SetAutomatedMarketMaker(account, false);
    }

    function setAutoTriggers(
        bool autoBuyTrigger,
        bool autoTransferTrigger,
        bool autoSellTrigger
    ) external onlyOwner {
        triggerBuyRecipient = autoBuyTrigger;
        triggerTransferRecipient = autoTransferTrigger;
        triggerSellRecipient = autoSellTrigger;
        emit SetAutoTriggers(
            autoBuyTrigger,
            autoSellTrigger,
            autoTransferTrigger
        );
    }

    function setFees(
        uint256 _buyFee,
        uint256 _sellFee,
        uint256 _transferFee
    ) external onlyOwner {
        require(_buyFee <= 2500, "Buy Fee Too High");
        require(_sellFee <= 2500, "Sell Fee Too High");
        require(_transferFee <= 2500, "Transfer Fee Too High");

        buyFee = _buyFee;
        sellFee = _sellFee;
        transferFee = _transferFee;

        emit SetFees(_buyFee, _sellFee, _transferFee);
    }

    function setFeeExempt(address account, bool isExempt) external onlyOwner {
        require(account != address(0), "Zero Address");
        permissions[account].isFeeExempt = isExempt;
        emit SetFeeExemption(account, isExempt);
    }

    function setCanSellBurn(address account, bool canSellBurn)
        external
        onlyOwner
    {
        require(account != address(0), "Zero Address");
        permissions[account].canSellBurn = canSellBurn;
        emit SetCanSellBurn(account, canSellBurn);
    }

    function pauseTrading() external onlyOwner {
        tradingPaused = true;
    }

    function resumeTrading() external onlyOwner {
        tradingPaused = false;
    }

    function setIsPausedExempt(address user, bool isPauseExempt)
        external
        onlyOwner
    {
        permissions[user].isPauseExempt = isPauseExempt;
    }

    function setIsBlacklisted(address user, bool isBlacklisted)
        external
        onlyOwner
    {
        permissions[user].isBlacklisted = isBlacklisted;
    }

    function setSwapper(address newSwapper) external onlyOwner {
        require(newSwapper != address(0), "Zero Address");
        swapper = newSwapper;
        emit SetSwapper(newSwapper);
    }

    /////////////////////////////////
    /////     READ FUNCTIONS    /////
    /////////////////////////////////

    function getTax(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        view
        returns (
            uint256,
            address,
            bool
        )
    {
        if (
            permissions[sender].isFeeExempt ||
            permissions[recipient].isFeeExempt
        ) {
            return (0, address(0), false);
        }
        return
            permissions[sender].isLiquidityPool
                ? (
                    (amount * buyFee) / TAX_DENOM,
                    buyFeeRecipient,
                    triggerBuyRecipient
                )
                : permissions[recipient].isLiquidityPool
                ? (
                    (amount * sellFee) / TAX_DENOM,
                    sellFeeRecipient,
                    triggerSellRecipient
                )
                : (
                    (amount * transferFee) / TAX_DENOM,
                    transferFeeRecipient,
                    triggerTransferRecipient
                );
    }

    //////////////////////////////////
    /////   INTERNAL FUNCTIONS   /////
    //////////////////////////////////

    /** Internal Transfer */
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(recipient != address(0), "Zero Recipient");
        require(amount > 0, "Zero Amount");
        require(amount <= _balances[sender], "Insufficient Balance");
        require(
            permissions[sender].isBlacklisted == false,
            "Sender Blacklisted"
        );
        if (tradingPaused) {
            require(permissions[sender].isPauseExempt, "Not Pause Exempt");
        }

        // decrement sender balance
        _balances[sender] -= amount;

        // fee for transaction
        (uint256 fee, address feeDestination, bool trigger) = getTax(
            sender,
            recipient,
            amount
        );

        // give amount to recipient less fee
        uint256 sendAmount = amount - fee;
        _balances[recipient] += sendAmount;
        emit Transfer(sender, recipient, sendAmount);

        // allocate fee if any
        if (fee > 0) {
            // if recipient field is valid
            bool isValidRecipient = feeDestination != address(0) &&
                feeDestination != address(this);

            // allocate amount to recipient
            address feeRecipient = isValidRecipient
                ? feeDestination
                : address(this);
            _balances[feeRecipient] += fee;
            emit Transfer(sender, feeRecipient, fee);

            // if valid and trigger is enabled, trigger tokenomics mid transfer
            if (trigger && isValidRecipient) {
                IFeeReceiver(feeRecipient).trigger();
            }
        }

        return true;
    }

    function _burn(address account, uint256 amount) internal returns (bool) {
        require(account != address(0), "Zero Address");
        require(amount > 0, "Zero Amount");
        require(amount <= _balances[account], "Insufficient Balance");

        // delete from balance and supply
        _balances[account] -= amount;
        _totalSupply -= amount;

        // increment total burned
        unchecked {
            totalBurned += amount;
        }

        // emit transfer
        emit Transfer(account, address(0), amount);
        return true;
    }

    function _sell(uint256 amount, address recipient) internal returns (bool) {
        require(amount > 0, "Zero Amount");
        require(
            recipient != address(0) &&
                recipient != address(this) &&
                recipient != swapper,
            "Invalid Recipient"
        );
        require(amount <= _balances[msg.sender], "Insufficient Balance");

        // re-allocate balances
        _balances[msg.sender] -= amount;
        _balances[swapper] += amount;
        emit Transfer(msg.sender, swapper, amount);

        // sell token for user
        ISwapper(swapper).sell(recipient);
        return true;
    }
}