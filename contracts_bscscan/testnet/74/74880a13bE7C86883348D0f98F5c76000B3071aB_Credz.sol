// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

//   ______
//   / ____/__  __ _   __ ___   _____ _____ ___
//  / /    / / / /| | / // _ \ / ___// ___// _ \
// / /___ / /_/ / | |/ //  __// /   (__  )/  __/
// \____/ \__, /  |___/ \___//_/   /____/ \___/
//       /____/

//    ______ ____   ______ ____  _____
//   / ____// __ \ / ____// __ \/__  /
//  / /    / /_/ // __/  / / / /  / /
// / /___ / _, _// /___ / /_/ /  / /__
// \____//_/ |_|/_____//_____/  /____/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./swap/IUniswapV2Router.sol";
import "./swap/IUniswapV2Factory.sol";

interface ICAdmin {
    function isMgrContract(address address_) external view returns(bool);
    function isAdmin(address address_) external view returns(bool);
    function isGamer(address walletAddress_) external view returns (bool);
}
/// @dev Basically OpenZeppelin ERC20, Not adding safemath since we using Solidity 0.8.10
contract Credz is ERC20 {
    uint private _maxTokensSellPerTx;
    uint private _maxTokensBuyPerTx;
    uint private _sellCooldown;
    uint private _purchaseCooldown;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
    address private _rewWallet;
    address private _opeWallet;
    address private _liqWallet;
    address private _marWallet;
    ICAdmin private _cyverseAdmin;
    uint8 public transferFee;
    uint8 public liqFee;
    uint8 public _sellingFee;
    uint128 private _minTokensBeforeSwap;

    bool public validPlayer;
    bool private _inSwapAndLiquify;
    bool public checkValidPlayerToSell; ///@dev blocks all sell
    bool public taxToRewardPool; ///@dev if true then the liqFee will go to reward wallet instead of Liq
    bool public tradingEnabled;
    mapping(address => bool) public blacklisted;
    mapping(address => uint) public sellCooldown;
    mapping(address => uint) public purchaseCooldown;
    event FeeUpdated(uint8 liqFee, uint8 transferFee);
    event MinTokensBeforeSwapUpdated(uint128 minTokensBeforeSwap);
    event MaxTokensPerTxUpdated(uint maxTokensBuyPerTx, uint maxTokensSellPerTx);
    event UpdateTradingEnable(bool enabled);
    event SwapAndLiquify(
        uint tokensSwapped,
        uint ethReceived,
        uint tokensIntoLiqudity
    );
    event InGamePayment(address receiver, uint amount, uint reward);
    event InGamePurchase(address payee, uint amount, PurchaseDistribution split);
    event InGamePurchaseToRewards(address payee, uint amount);
    
    event InGameTrade(
        address buyer_,
        address seller_,
        uint amount_,
        uint8 rewardPercentage_,
        uint reward
    );
    event AdminTransfer(address from_, address to_, uint amount_);

    struct PurchaseDistribution {
        uint8 rewardPool;
        uint8 operations;
        uint8 liquidity;
        uint8 marketing;
    }

    modifier lockTheSwap() {
        require(!_inSwapAndLiquify, "SWAP LOCKED");
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    modifier adminOnly() {
        require(_cyverseAdmin.isAdmin(msg.sender), "C1-401");
        _;
    }

    modifier notBlacklisted(address address_) {
        require(!blacklisted[address_], "C2-401");
        _;
    }

    constructor(
        address uniswapV2Router_,
        address cyverseAdmin_,
        address rewardWalletAddress_,
        uint supply,
        uint8 liqFee_,
        uint128 minTokensBeforeSwap_,
        uint8 transferFee_
    ) ERC20("Cyverse Credz", "CREDZ") {
        _mint(rewardWalletAddress_, supply * 10**decimals());
        uniswapV2Router = IUniswapV2Router02(uniswapV2Router_);
        liqFee = liqFee_;
        _minTokensBeforeSwap = minTokensBeforeSwap_;
        _rewWallet = rewardWalletAddress_;
        _cyverseAdmin = ICAdmin(cyverseAdmin_);
        transferFee = transferFee_;
        _inSwapAndLiquify = false;
        taxToRewardPool = false; //False by default
    }

    function setPair(address pairAddress_) external adminOnly {
        uniswapV2Pair = pairAddress_;
    }

    function saveTaxFee(address from_, uint amount_, uint feePercentage_) internal returns (uint) {
        uint lfee = amount_ / 100 * feePercentage_;
        if (taxToRewardPool) { //if tax to reward pull then don't do Liquidity
            super._transfer(from_, _rewWallet, lfee);
        } else {
            super._transfer(from_, address(this), lfee);
        }
        return (amount_ - lfee);
    }

    function _transfer(
        address from,
        address to,
        uint amount
    ) internal override {
        require(from != address(0) || to != address(0), "INVALID");
        require(!blacklisted[from] || !blacklisted[to], "C3-401");
        if ((from == uniswapV2Pair || to == uniswapV2Pair) && !tradingEnabled) {
            revert("C1-405"); //ERC20: trading disabled yet
        }
        

        uint fee = liqFee;
        if (uniswapV2Pair == from) { //purchase
            require(_maxTokensBuyPerTx ==0 || amount <= _maxTokensBuyPerTx,"PURCHASE LIMIT EXCEEDED");
            require(purchaseCooldown[to] + _purchaseCooldown > block.timestamp,
            "SELL COOLDOWN"); 
            purchaseCooldown[to] = block.timestamp;
        } else if (uniswapV2Pair == to) { //sell
            require(_maxTokensSellPerTx ==0 || amount <= _maxTokensSellPerTx,"SELL LIMIT EXCEEDED");
            require(sellCooldown[to] + _sellCooldown > block.timestamp,
            "PURCHASE COOLDOWN"); 
            sellCooldown[to] = block.timestamp;
            if (checkValidPlayerToSell) {
                require(_cyverseAdmin.isGamer(from), "NOT A GAMER");
            }
        } else { //
            fee = transferFee;
        }
        uint balanceAmount = saveTaxFee(from, amount, fee);
        super._transfer(from, to, balanceAmount);
        
        // SWAP AND LIQ
        uint contractTokenBalance = balanceOf(address(this));
        if ( contractTokenBalance >= _minTokensBeforeSwap &&
            !_inSwapAndLiquify && msg.sender != uniswapV2Pair ) {
            swapAndLiquify(contractTokenBalance);
        }
    }

    function transfer(address recipient_, uint256 amount_) public override notBlacklisted(msg.sender) returns (bool) {
        super._transfer(msg.sender, recipient_, amount_);
        return true;
    }

    function approve(address spender_, uint256 amount_) public override notBlacklisted(msg.sender) returns (bool) {
        _approve(msg.sender, spender_, amount_);
        return true;
    }

    function transferFrom(address sender_,address recipient_,uint256 amount_) public override notBlacklisted(recipient_) returns (bool) {
        return super.transferFrom(sender_, recipient_,amount_);
    }

    function swapAndLiquify(uint contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint half = contractTokenBalance / 2;
        uint otherHalf = contractTokenBalance - half;

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint initialBalance = address(this).balance;
        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered
        // how much ETH did we just swap into?
        uint newBalance = address(this).balance - initialBalance;
        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function ebalance(address account) external view returns (uint256) {
        return super.balanceOf(account);
    }

    function swapTokensForEth(uint tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint tokenAmount, uint ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    receive() external payable {}

    function inGamePurchaseToRewards(address payee_, uint amount_)
        external
        returns (bool)
    {
        require(_cyverseAdmin.isMgrContract(msg.sender), "C4-401"); //Unathorized 401
        super._transfer(payee_, _rewWallet, amount_);
        emit InGamePurchaseToRewards(payee_, amount_);
        return true;
    }

    function inGamePurchase(address payee_, uint amount_, PurchaseDistribution memory distSplit_)
        external
        returns (bool)
    {
        require(_cyverseAdmin.isMgrContract(msg.sender), "C1-401"); //Unathorized 401
        // transferWithDist(payee_, amount_, distSplit_);
        uint rewardPool = amount_ / 100 * distSplit_.rewardPool;
        uint operations = amount_ / 100 * distSplit_.operations;
        uint liquidity = amount_ / 100 * distSplit_.liquidity;
        uint marketing = amount_ / 100 * distSplit_.marketing;
        if (rewardPool > 0) super._transfer(payee_, _rewWallet, rewardPool);
        if (operations > 0) super._transfer(payee_, _opeWallet, operations);
        if (liquidity > 0) super._transfer(payee_, _liqWallet, liquidity);
        if (marketing > 0) super._transfer(payee_, _marWallet, marketing);
    
        emit InGamePurchase(payee_, amount_, distSplit_);
        return true;
    }

    /// @dev Game Credz Payout
    function inGamePaymentout(
        address receiver_,
        uint amount_,
        uint8 rewardPercentage_
    ) external {
        require(_cyverseAdmin.isMgrContract(msg.sender), "C2-401"); //Unathorized 401
        uint reward = amount_ / 100 * rewardPercentage_;
        amount_ -= reward;
        super._transfer(_rewWallet, receiver_, amount_);
        emit InGamePayment(receiver_, amount_, rewardPercentage_);
    }

    function inGameTrade(
        address buyer_,
        address seller_,
        uint amount_,
        uint8 rewardPercentage_
    ) external {
        require(_cyverseAdmin.isMgrContract(msg.sender), "C3-401"); //Unathorized 401
        super._transfer(buyer_, _rewWallet, amount_); //pays full credz
        uint reward = amount_ * rewardPercentage_ / 100;
        super._transfer(_rewWallet, seller_, (amount_ - reward));
        emit InGameTrade(buyer_, seller_, amount_, rewardPercentage_, reward);
    }

    /// @dev Admin exchange
    /// Administrator of the game may mediate with a black listed user
    function adminTransfer(address from_, address to_, uint amount_) external adminOnly {
        super._transfer(from_, to_, amount_);
        emit AdminTransfer(from_, to_, amount_);
    }

    function setWallets(address rewWallet_, address opeWallet_, address liqWallet_, address marWallet_) external adminOnly {
        _rewWallet = rewWallet_;
        _opeWallet = opeWallet_;
        _liqWallet = liqWallet_;
        _marWallet = marWallet_;
    }

    ////////////// Trading Rules //////////////////////////////////////////
    function setCoolDown(uint sellCooldown_, uint purchaseCooldown_) external adminOnly {
        _sellCooldown = sellCooldown_;
        _purchaseCooldown = purchaseCooldown_;
    }

    function setValidatePlayerToSell(bool checkValidPlayerToSell_) external adminOnly {
            checkValidPlayerToSell = checkValidPlayerToSell_;
    }

    function addToBlackList(address walletAddress_) external adminOnly {
        blacklisted[walletAddress_] = true;
    }

    function removeFromBlackList(address walletAddress_) external adminOnly {
        delete blacklisted[walletAddress_];
    }

    function updateFee(bool taxToRewardPool_, uint8 liqFee_, uint8 transferFee_) public adminOnly {
        require(liqFee < 31 && transferFee_ < 31, "INVALID"); /// @Dev max tax can be 30
        taxToRewardPool = taxToRewardPool_;
        liqFee = liqFee_;
        transferFee = transferFee_;
        emit FeeUpdated(liqFee_, transferFee_);
    }

    function updateMinTokensBeforeSwap(uint128 minTokensBeforeSwap_) external adminOnly {
        _minTokensBeforeSwap = minTokensBeforeSwap_;
        emit MinTokensBeforeSwapUpdated(_minTokensBeforeSwap);
    }

    function updateMaxTokensPerTx(uint maxTokensBuyPerTx_, uint maxTokensSellPerTx_) external adminOnly {
        _maxTokensSellPerTx = maxTokensSellPerTx_ * 10 ** decimals();
        _maxTokensBuyPerTx = maxTokensBuyPerTx_ * 10 ** decimals();
        emit MaxTokensPerTxUpdated(_maxTokensBuyPerTx, _maxTokensSellPerTx);
    }

    function updateTradingEnable(bool enabled_) external adminOnly {
        tradingEnabled = enabled_;
        emit UpdateTradingEnable(enabled_);
    }
    //////////////End Trading Rules //////////////////////////////////////////////////////////////
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
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

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}