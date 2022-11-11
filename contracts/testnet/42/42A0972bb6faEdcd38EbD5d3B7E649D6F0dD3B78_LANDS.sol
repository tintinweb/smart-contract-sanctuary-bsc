// SPDX-License-Identifier: MIT

/* git rm --cached ignored-folder
    While deploying on mainnet change the following things-
    => Ask and change Rewards/Team/Liquidity fees
    => Change Router Address
    => Ask and change _minTokensBeforeSwap, liquidityreceiver to burnaddress for token lock
    => Change marketing receiver address
    => Check compiler version
 */

/*
    #LANDS features:
    6% fee auto add to the liquidity pool 
    6% fee auto distribute to all holders
    6% fee auto will be sent back to the team for further developments
 */

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./IPancake.sol";

contract LANDS is Context, IERC20, Ownable {
    using Address for address;

    // ERC20 Token Standard
    string private _name = "LANDS Token";

    // ERC20 Token Standard
    string private _symbol = "LANDS";

    // ERC20 Token Standard
    uint256 private _decimals = 18;

    // Keeps track of balances for address that are included in receiving reward.
    mapping(address => uint256) private _reflectionBalances;

    // Keeps track of balances for address that are excluded from receiving reward.
    mapping(address => uint256) private _tokenBalances;

    // ERC20 Token Standard
    mapping(address => mapping(address => uint256)) private _allowances;

    // Keeps track of which address are excluded from fee.
    mapping(address => bool) private _isExcludedFromFee;

    // Keeps track of which address are excluded from reward.
    mapping(address => bool) private _isExcludedFromReward;

    // Keeps track of txLimitExempt
    mapping(address => bool) isTxLimitExempt;

    // An array of addresses that are excluded from reward.
    address[] private _excluded;

    // A number that helps distributing fees to all holders respectively.
    uint256 private _reflectionTotal;

    // ERC20 Token Standard
    uint256 private _totalSupply = 100 * (10**6) * (10**_decimals);

    // Total amount of tokens rewarded / distributing.
    uint256 private _totalRewarded;

    // This percent of a transaction will be redistribute to all holders.
    uint8 public _taxReward = 6;

    /* This percent of a transaction will be added to the liquidity pool. 
    More details at https://github.com/Sheldenshi/ERC20Deflationary.*/
    uint8 public _taxLiquify = 6;

    // This percent of a transaction will be added for further developments
    uint8 public _devTax = 6;

    // A threshold for swap and liquify.
    uint256 public _minTokensBeforeSwap = 5 * (10**5) * (10**_decimals);

    // Max Tx Amount~
    uint256 public _maxTxAmount = 2 * (10**5) * (10**_decimals);

    // Liquidity pool provider router
    IPancakeRouter02 internal _pancakeRouter;

    // This Token and WETH pair contract address.
    address internal _pancakePair;

    // Total amount of tokens locked in the LP (this token and WETH pair).
    uint256 public _totalTokensLockedInLiquidity;

    // Total amount of ETH locked in the LP (this token and WETH pair).
    uint256 public _totalETHLockedInLiquidity;

    // Whether a previous call of SwapAndLiquify process is still in process.
    bool _inSwapAndLiquify;

    // To check if autoSwapAndLiquify is enabled
    bool public _autoSwapAndLiquifyEnabled;

    // To check if reward is enabled
    bool public _rewardEnabled;

    // To check if dev fee is enabled
    bool public _devFeeEnabled;

    // Prevent reentrancy.
    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    // Return values of _getValues function.
    struct ValuesFromAmount {
        // Amount of tokens for to transfer.
        uint256 amount;
        // Amount tokens charged for development.
        uint256 tDevFee;
        // Amount tokens charged to reward.
        uint256 tRewardFee;
        // Amount tokens charged to add to liquidity.
        uint256 tLiquifyFee;
        // Amount tokens after fees.
        uint256 tTransferAmount;
        // Reflection of amount.
        uint256 rAmount;
        // Reflection of dev fee.
        uint256 rDevFee;
        // Reflection of reward fee.
        uint256 rRewardFee;
        // Reflection of liquify fee.
        uint256 rLiquifyFee;
        // Reflection of transfer amount.
        uint256 rTransferAmount;
    }

    /*
        Events
    */
    event MinTokensBeforeSwapUpdated(
        uint256 previousMinTokensBeforeSwap,
        uint256 minTokensBeforeSwap_
    );
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event ExcludeAccountFromFee(address account);
    event IncludeAccountInFee(address account);
    event ExcludeAccountFromReward(address account);
    event IncludeAccountInReward(address account);
    event EnabledDevFee();
    event EnabledReward();
    event EnabledAutoSwapAndLiquify();
    event DevFeeUpdate(uint8 previousTax, uint8 currentTax);
    event TaxRewardUpdate(uint8 previousTax, uint8 currentTax);
    event TaxLiquifyUpdate(uint8 previousTax, uint8 currentTax);
    event SetTxnLimit(uint256 maxTxAmount_);
    event DisabledDevFee();
    event DisabledReward();
    event DisabledAutoSwapAndLiquify();
    event FeeDistributedAmongHolders(uint256 rewardFee);
    event DevFeeTransfer(uint256 devFee);
    event IncludeTxLimit(address holder);
    event ExcludeFromTxLimit(address holder);
    event Airdrop(uint256 amount);

    // Liquidity pool provider router
    address _routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    // Where burnt tokens are sent to. This is an address that no one can have accesses to.
    address private constant burnAccount =
        0x000000000000000000000000000000000000dEaD;

    // Where burnt tokens are sent to. This is an address that no one can have accesses to.
    address private constant zeroAddress =
        0x0000000000000000000000000000000000000000;

    // dev fee receiver
    address private constant marketingReceiver =
        0x3442aB0f13361a3a2D7149D6072eF4d94C34c52e;

    // Liquidity Pool tokens receiver => need to be Burn / Zero address
    address private constant liquidityReceiver =
        0x9Dcd3212FD95dA843D4EE2Ec00BfE71D0d201Db9;

    constructor() {
        // Enable dev fee
        enableDevFee(_devTax);

        // Enable holder's reward
        enableReward(_taxReward);

        // Enable AutoSwapAndLiquify
        enableAutoSwapAndLiquify(
            _taxLiquify,
            _routerAddress,
            _minTokensBeforeSwap
        );

        // Excluding burn and zero addresses from reward
        excludeFromReward(burnAccount);
        excludeFromReward(zeroAddress);

        // exclude this contract from fee.
        excludeFromFee(address(this));
        excludeFromTxLimit(address(this));

        _reflectionTotal = (~uint256(0) - (~uint256(0) % _totalSupply));
        _reflectionBalances[_msgSender()] = _reflectionTotal;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint256) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns whether an account is excluded from reward.
     */
    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcludedFromReward[account];
    }

    /**
     * @dev Returns whether an account is excluded from fee.
     */
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    /**
     Gives total number of tokens rewarded from reward tax
     */
    function totalRewarded() public view returns (uint256) {
        return _totalRewarded;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromReward[account]) return _tokenBalances[account];
        return tokenFromReflection(_reflectionBalances[account]);
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
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
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        checkTxLimit(sender, recipient, amount);

        /*If sender or the recipient is excluded form fee, the fee is not charged */
        ValuesFromAmount memory values = _getValues(
            amount,
            _isExcludedFromFee[sender] || _isExcludedFromFee[recipient]
        );
        if (
            _isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]
        ) {
            _transferFromExcluded(sender, recipient, values);
        } else if (
            !_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]
        ) {
            _transferToExcluded(sender, recipient, values);
        } else if (
            !_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]
        ) {
            _transferStandard(sender, recipient, values);
        } else if (
            _isExcludedFromReward[sender] && _isExcludedFromReward[recipient]
        ) {
            _transferBothExcluded(sender, recipient, values);
        } else {
            _transferStandard(sender, recipient, values);
        }
        emit Transfer(sender, recipient, values.tTransferAmount);

        if ((!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient])) {
            _afterTokenTransfer(values);
        }
    }

    /**
     * @dev Performs transfer from an excluded account to an included account.
     * (included and excluded from receiving reward.)
     */
    function _transferFromExcluded(
        address sender,
        address recipient,
        ValuesFromAmount memory values
    ) private {
        _tokenBalances[sender] = _tokenBalances[sender] - values.amount;
        _reflectionBalances[sender] =
            _reflectionBalances[sender] -
            values.rAmount;
        _reflectionBalances[recipient] =
            _reflectionBalances[recipient] +
            values.rTransferAmount;
    }

    /**
     * @dev Performs transfer from an included account to an excluded account.
     * (included and excluded from receiving reward.)
     */
    function _transferToExcluded(
        address sender,
        address recipient,
        ValuesFromAmount memory values
    ) private {
        _reflectionBalances[sender] =
            _reflectionBalances[sender] -
            values.rAmount;
        _tokenBalances[recipient] =
            _tokenBalances[recipient] +
            values.tTransferAmount;
        _reflectionBalances[recipient] =
            _reflectionBalances[recipient] +
            values.rTransferAmount;
    }

    /**
     * @dev Performs transfer between two accounts that are both included in receiving reward.
     */
    function _transferStandard(
        address sender,
        address recipient,
        ValuesFromAmount memory values
    ) private {
        _reflectionBalances[sender] =
            _reflectionBalances[sender] -
            values.rAmount;
        _reflectionBalances[recipient] =
            _reflectionBalances[recipient] +
            values.rTransferAmount;
    }

    /**
     * @dev Performs transfer between two accounts that are both excluded in receiving reward.
     */
    function _transferBothExcluded(
        address sender,
        address recipient,
        ValuesFromAmount memory values
    ) private {
        _tokenBalances[sender] = _tokenBalances[sender] - values.amount;
        _reflectionBalances[sender] =
            _reflectionBalances[sender] -
            values.rAmount;
        _tokenBalances[recipient] =
            _tokenBalances[recipient] +
            values.tTransferAmount;
        _reflectionBalances[recipient] =
            _reflectionBalances[recipient] +
            values.rTransferAmount;
    }

    /**
     * @dev Performs all the functionalities that are enabled.
     */
    function _afterTokenTransfer(ValuesFromAmount memory values)
        internal
        virtual
    {
        // Dev Fee
        if (_devFeeEnabled) {
            // adding fees to the wallets for development
            _tokenBalances[marketingReceiver] += values.tDevFee;
            _reflectionBalances[marketingReceiver] += values.rDevFee;
            emit DevFeeTransfer(values.tDevFee);
        }
        // Reflect
        if (_rewardEnabled) {
            _distributeFee(values.rRewardFee, values.tRewardFee);
        }

        // Add to liquidity pool
        if (_autoSwapAndLiquifyEnabled) {
            // add liquidity fee to this contract.
            _tokenBalances[address(this)] += values.tLiquifyFee;
            _reflectionBalances[address(this)] += values.rLiquifyFee;
            emit Transfer(_msgSender(), address(this), values.tLiquifyFee);

            uint256 contractBalance = balanceOf(address(this));

            // whether the current contract balances makes the threshold to swap and liquify.
            bool overMinTokensBeforeSwap = contractBalance >=
                _minTokensBeforeSwap;

            if (
                overMinTokensBeforeSwap &&
                !_inSwapAndLiquify &&
                _msgSender() != _pancakePair &&
                _autoSwapAndLiquifyEnabled
            ) {
                contractBalance = _minTokensBeforeSwap;
                swapAndLiquify(contractBalance);
                contractBalance = 0;
            }
        }
    }

    /**
     * @dev Returns fees and transfer amount in both tokens and reflections.
     * tXXXX stands for tokenXXXX
     * rXXXX stands for reflectionXXXX
     * More details can be found at comments for ValuesForAmount Struct.
     */
    function _getValues(uint256 amount, bool deductTransferFee)
        private
        view
        returns (ValuesFromAmount memory)
    {
        ValuesFromAmount memory values;
        values.amount = amount;
        _getTValues(values, deductTransferFee);
        _getRValues(values, _getRate(), deductTransferFee);
        return (values);
    }

    /**
     * @dev Adds fees and transfer amount in tokens to `values`.
     * tXXXX stands for tokenXXXX
     * More details can be found at comments for ValuesForAmount Struct.
     */
    function _getTValues(ValuesFromAmount memory values, bool deductTransferFee)
        private
        view
    {
        if (deductTransferFee) {
            values.tTransferAmount = values.amount;
        } else {
            values.tDevFee = calculateDevFee(values.amount);
            values.tRewardFee = calculateTaxFee(values.amount);
            values.tLiquifyFee = calculateLiquidityFee(values.amount);
            values.tTransferAmount =
                values.amount -
                values.tRewardFee -
                values.tLiquifyFee;
        }
    }

    /**
     * @dev Adds fees and transfer amount in reflection to `values`.
     * rXXXX stands for reflectionXXXX
     * More details can be found at comments for ValuesForAmount Struct.
     */
    function _getRValues(
        ValuesFromAmount memory values,
        uint256 currentRate,
        bool deductTransferFee
    ) private pure {
        values.rAmount = values.amount * currentRate;
        if (deductTransferFee) {
            values.rTransferAmount = values.rAmount;
        } else {
            values.rAmount = values.amount * currentRate;
            values.rDevFee = values.tDevFee * currentRate;
            values.rRewardFee = values.tRewardFee * currentRate;
            values.rLiquifyFee = values.tLiquifyFee * currentRate;
            values.rTransferAmount =
                values.rAmount -
                values.rRewardFee -
                values.rLiquifyFee;
        }
    }

    /**
     * @dev Returns the current reflection rate.
     */
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    /**
     * @dev Returns the current reflection supply and token supply.
     */
    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _reflectionTotal;
        uint256 tSupply = _totalSupply;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _reflectionBalances[_excluded[i]] > rSupply ||
                _tokenBalances[_excluded[i]] > tSupply
            ) return (_reflectionTotal, _totalSupply);
            rSupply = rSupply - _reflectionBalances[_excluded[i]];
            tSupply = tSupply - _tokenBalances[_excluded[i]];
        }
        if (rSupply < _reflectionTotal / _totalSupply)
            return (_reflectionTotal, _totalSupply);
        return (rSupply, tSupply);
    }

    /**
     * @dev Swap half of contract's token balance for ETH,
     * and pair it up with the other half to add to the
     * liquidity pool.
     *
     * Emits {SwapAndLiquify} event indicating the amount of tokens swapped to eth,
     * the amount of ETH added to the LP, and the amount of tokens added to the LP.
     */
    function swapAndLiquify(uint256 contractBalance) private lockTheSwap {
        // Split the contract balance into two halves.
        uint256 tokensToSwap = contractBalance / 2;
        uint256 tokensAddToLiquidity = contractBalance - tokensToSwap;

        // Contract's current ETH balance.
        uint256 initialBalance = address(this).balance;

        // Swap half of the tokens to ETH.
        swapTokensForEth(tokensToSwap);

        // Figure out the exact amount of tokens received from swapping.
        uint256 ethAddToLiquify = address(this).balance - initialBalance;

        // Add to the LP of this token and WETH pair (half ETH and half this token).
        addLiquidity(ethAddToLiquify, tokensAddToLiquidity);

        _totalETHLockedInLiquidity = address(this).balance - initialBalance;
        _totalTokensLockedInLiquidity =
            contractBalance -
            balanceOf(address(this));

        emit SwapAndLiquify(
            tokensToSwap,
            ethAddToLiquify,
            tokensAddToLiquidity
        );
    }

    /**
     * @dev Swap `amount` tokens for ETH.
     *
     * Emits {Transfer} event. From this contract to the token and WETH Pair.
     */
    function swapTokensForEth(uint256 amount) private {
        // Generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _pancakeRouter.WETH();

        _approve(address(this), address(_pancakeRouter), amount);

        // Swap tokens to ETH
        _pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this), // this contract will receive the eth that were swapped from the token
            block.timestamp
        );
    }

    /**
     * @dev Add `ethAmount` of ETH and `tokenAmount` of tokens to the LP.
     * Depends on the current rate for the pair between this token and WETH,
     * `ethAmount` and `tokenAmount` might not match perfectly.
     * Dust(leftover) ETH or token will be refunded to this contract
     * (usually very small quantity).
     *
     * Emits {Transfer} event. From this contract to the token and WETH Pai.
     */
    function addLiquidity(uint256 ethAmount, uint256 tokenAmount) private {
        _approve(address(this), address(_pancakeRouter), tokenAmount);

        _pancakeRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityReceiver, // the LP is sent to burnAccount.
            block.timestamp
        );
    }

    /**
     * @dev Returns the reflected amount of a token.
     *  Requirements:
     * - `amount` must be less than total supply.
     */
    function reflectionFromToken(uint256 amount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        ValuesFromAmount memory values = _getValues(amount, deductTransferFee);
        return values.rTransferAmount;
    }

    /**
     * @dev Used to figure out the balance after reflection.
     * Requirements:
     * - `rAmount` must be less than reflectTotal.
     */
    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _reflectionTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    //to recieve ETH from pancakeSwapV2Router when swaping
    receive() external payable {}

    /**
     * @dev Distribute the `tRewardFee` tokens to all holders that are included in receiving reward.
     * amount received is based on how many token one owns.
     */
    function _distributeFee(uint256 rRewardFee, uint256 tRewardFee) private {
        // This would decrease rate, thus increase amount reward receive based on one's balance.
        _reflectionTotal = _reflectionTotal - rRewardFee;
        _totalRewarded = _totalRewarded + tRewardFee;
        emit FeeDistributedAmongHolders(tRewardFee);
    }

    /**
     * @dev Returns dev fee based on `amount` and `taxRate`
     */
    function calculateDevFee(uint256 _amount) private view returns (uint256) {
        return (_amount * _devTax) / (10**2);
    }

    /**
     * @dev Returns holders fee based on `amount` and `taxRate`
     */
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return (_amount * _taxReward) / (10**2);
    }

    /**
     * @dev Returns liquidity fee based on `amount` and `taxRate`
     */
    function calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return (_amount * _taxLiquify) / (10**2);
    }

    function checkTxLimit(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        require(
            amount <= _maxTxAmount ||
                isTxLimitExempt[sender] ||
                isTxLimitExempt[recipient],
            "Check Tx Limit: TX Limit Exceeded, Must Be Less Than _maxTxAmount"
        );
    }

    function airdrop(uint256 amount) public {
        address sender = _msgSender();
        //require(!_isExcludedFromReward[sender], "Excluded addresses cannot call this function");
        require(
            balanceOf(sender) >= amount,
            "The caller must have balance >= amount."
        );
        ValuesFromAmount memory values = _getValues(amount, false);
        if (_isExcludedFromReward[sender]) {
            _tokenBalances[sender] -= values.amount;
        }
        _reflectionBalances[sender] -= values.rAmount;

        _reflectionTotal = _reflectionTotal - values.rAmount;
        _totalRewarded += amount;
        emit Airdrop(amount);
    }

    /*
        Owner functions
    */

    function excludeFromTxLimit(address holder) public onlyOwner {
        isTxLimitExempt[holder] = true;
        emit ExcludeFromTxLimit(holder);
    }

    function includeInTxLimit(address holder) external onlyOwner {
        isTxLimitExempt[holder] = false;
        emit IncludeTxLimit(holder);
        emit ExcludeFromTxLimit(holder);
    }

    function setTxLimit(uint256 maxTxAmount_) public onlyOwner {
        _maxTxAmount = maxTxAmount_;
        emit SetTxnLimit(maxTxAmount_);
    }

    /**
     * @dev Excludes an account from receiving reward.
     *
     * Emits a {ExcludeAccountFromReward} event.
     *
     * Requirements:
     *
     * - `account` is included in receiving reward.
     */
    function excludeFromReward(address account) public onlyOwner {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcludedFromReward[account], "Account is already excluded");
        if (_reflectionBalances[account] > 0) {
            _tokenBalances[account] = tokenFromReflection(
                _reflectionBalances[account]
            );
        }
        _isExcludedFromReward[account] = true;
        _excluded.push(account);
        emit ExcludeAccountFromReward(account);
    }

    /**
     * @dev Includes an account from receiving reward.
     *
     * Emits a {IncludeAccountInReward} event.
     *
     * Requirements:
     *
     * - `account` is excluded in receiving reward.
     */
    function includeInReward(address account) external onlyOwner {
        require(_isExcludedFromReward[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tokenBalances[account] = 0;
                _isExcludedFromReward[account] = false;
                _excluded.pop();
                break;
            }
        }
        emit IncludeAccountInReward(account);
    }

    /**
     * @dev Excludes an account from fee.
     *
     * Emits a {ExcludeAccountFromFee} event.
     *
     * Requirements:
     *
     * - `account` is included in fee.
     */
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludeAccountFromFee(account);
    }

    /**
     * @dev Includes an account from fee.
     *
     * Emits a {IncludeAccountFromFee} event.
     *
     * Requirements:
     *
     * - `account` is excluded in fee.
     */
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludeAccountInFee(account);
    }

    /**
     * @dev Enables the dev fee feature.
     * Distribute transaction amount * `taxDevTax_` amount of tokens each transaction when enabled.
     *
     * Emits a {EnabledDevFee} event.
     *
     * Requirements:
     *
     * - devFee feature mush be disabled.
     * - tax must be greater than 0.
     * - tax decimals + 2 must be less than token decimals.
     * (because tax rate is in percentage)
     */
    function enableDevFee(uint8 devTax_) public onlyOwner {
        require(!_devFeeEnabled, "Dev Fee feature is already enabled.");
        require(devTax_ > 0, "Tax must be greater than 0.");

        _devFeeEnabled = true;
        setDevFee(devTax_);

        emit EnabledDevFee();
    }

    /**
     * @dev Updates devFee
     *
     * Emits a {devFeeUpdate} event.
     *
     * Requirements:
     *
     * - devFee feature must be enabled.
     * - total tax rate must be less than 30%.
     */
    function setDevFee(uint8 devTax_) public onlyOwner {
        require(
            _devFeeEnabled,
            "Dev feature must be enabled. Try the EnableDevFee function."
        );
        require(_taxReward + _taxLiquify + devTax_ < 30, "Tax fee too high.");

        uint8 previousTax = _devTax;
        _devTax = devTax_;

        emit DevFeeUpdate(previousTax, devTax_);
    }

    /**
     * @dev Disables the defFee feature.
     *
     * Emits a {DisabledDevFee} event.
     *
     * Requirements:
     *
     * - devFee feature mush be enabled.
     */
    function disableDevFee() public onlyOwner {
        require(_devFeeEnabled, "Dev Fee feature is already disabled.");

        setDevFee(0);
        _devFeeEnabled = false;

        emit DisabledDevFee();
    }

    /**
     * @dev Enables the reward feature.
     * Distribute transaction amount * `taxReward_` amount of tokens each transaction when enabled.
     *
     * Emits a {EnabledReward} event.
     *
     * Requirements:
     *
     * - reward feature mush be disabled.
     * - tax must be greater than 0.
     * - tax decimals + 2 must be less than token decimals.
     * (because tax rate is in percentage)
     */
    function enableReward(uint8 taxReward_) public onlyOwner {
        require(!_rewardEnabled, "Reward feature is already enabled.");
        require(taxReward_ > 0, "Tax must be greater than 0.");

        _rewardEnabled = true;
        setTaxReward(taxReward_);

        emit EnabledReward();
    }

    /**
     * @dev Updates taxReward
     *
     * Emits a {TaxRewardUpdate} event.
     *
     * Requirements:
     *
     * - reward feature must be enabled.
     * - total tax rate must be less than 30%.
     */
    function setTaxReward(uint8 taxReward_) public onlyOwner {
        require(
            _rewardEnabled,
            "Reward feature must be enabled. Try the EnableReward function."
        );
        require(taxReward_ + _taxLiquify + _devTax < 30, "Tax fee too high.");

        uint8 previousTax = _taxReward;
        _taxReward = taxReward_;

        emit TaxRewardUpdate(previousTax, taxReward_);
    }

    /**
     * @dev Disables the reward feature.
     *
     * Emits a {DisabledReward} event.
     *
     * Requirements:
     *
     * - reward feature mush be enabled.
     */
    function disableReward() public onlyOwner {
        require(_rewardEnabled, "Reward feature is already disabled.");

        setTaxReward(0);
        _rewardEnabled = false;

        emit DisabledReward();
    }

    /**
     * @dev Enables the auto swap and liquify feature.
     * Swaps half of transaction amount * `taxLiquify_` amount of tokens
     * to ETH and pair with the other half of tokens to the LP each transaction when enabled.
     *
     * Emits a {EnabledAutoSwapAndLiquify} event.
     *
     * Requirements:
     *
     * - auto swap and liquify feature mush be disabled.
     * - tax must be greater than 0.
     * - tax decimals + 2 must be less than token decimals.
     * (because tax rate is in percentage)
     */
    function enableAutoSwapAndLiquify(
        uint8 taxLiquify_,
        address routerAddress,
        uint256 minTokensBeforeSwap_
    ) public onlyOwner {
        require(
            !_autoSwapAndLiquifyEnabled,
            "Auto swap and liquify feature is already enabled."
        );
        require(taxLiquify_ > 0, "Tax must be greater than 0.");

        _minTokensBeforeSwap = minTokensBeforeSwap_;

        // init Router
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        _pancakePair = IPancakeFactory(pancakeRouter.factory()).createPair(
            address(this),
            pancakeRouter.WETH()
        );

        _pancakeRouter = pancakeRouter;

        excludeFromReward(address(pancakeRouter));
        excludeFromReward(_pancakePair);
        excludeFromTxLimit(address(pancakeRouter));
        // excludeFromTxLimit(_pancakePair);
        excludeFromTxLimit(owner());
        excludeFromFee(owner());
        excludeFromFee(marketingReceiver);

        _autoSwapAndLiquifyEnabled = true;
        setTaxLiquify(taxLiquify_);

        emit EnabledAutoSwapAndLiquify();
    }

    /**
     * @dev Updates `_minTokensBeforeSwap`
     *
     * Emits a {MinTokensBeforeSwap} event.
     *
     * Requirements:
     *
     * - `minTokensBeforeSwap_` must be less than _currentSupply.
     */
    function setMinTokensBeforeSwap(uint256 minTokensBeforeSwap_)
        public
        onlyOwner
    {
        require(
            _autoSwapAndLiquifyEnabled,
            "Auto swap and liquify feature must be enabled. Try the EnableAutoSwapAndLiquify function."
        );
        uint256 previousMinTokensBeforeSwap = minTokensBeforeSwap_;
        _minTokensBeforeSwap = minTokensBeforeSwap_;
        emit MinTokensBeforeSwapUpdated(
            previousMinTokensBeforeSwap,
            minTokensBeforeSwap_
        );
    }

    /**
     * @dev Updates taxLiquify
     *
     * Emits a {TaxLiquifyUpdate} event.
     *
     * Requirements:
     *
     * - auto swap and liquify feature must be enabled.
     * - total tax rate must be less than 30%.
     */
    function setTaxLiquify(uint8 taxLiquify_) public onlyOwner {
        require(
            _autoSwapAndLiquifyEnabled,
            "Auto swap and liquify feature must be enabled. Try the EnableAutoSwapAndLiquify function."
        );
        require(_taxReward + taxLiquify_ + _devTax < 30, "Tax fee too high.");
        uint8 previousTax = _taxLiquify;
        _taxLiquify = taxLiquify_;
        emit TaxLiquifyUpdate(previousTax, taxLiquify_);
    }

    /**
     * @dev Disables the auto swap and liquify feature.
     *
     * Emits a {DisabledAutoSwapAndLiquify} event.
     *
     * Requirements:
     *
     * - auto swap and liquify feature mush be enabled.
     */
    function disableAutoSwapAndLiquify() public onlyOwner {
        require(
            _autoSwapAndLiquifyEnabled,
            "Auto swap and liquify feature is already disabled."
        );
        setTaxLiquify(0);
        _autoSwapAndLiquifyEnabled = false;
        emit DisabledAutoSwapAndLiquify();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: MIT

interface IPancakeFactory {
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

interface IPancakePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
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

interface IPancakeRouter02 is IPancakeRouter01 {
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