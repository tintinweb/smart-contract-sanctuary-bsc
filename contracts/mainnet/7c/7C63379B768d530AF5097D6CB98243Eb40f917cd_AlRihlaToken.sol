// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "./SafeMath.sol";
import "./Address.sol";
import "./Math.sol";
import "./Context.sol";
import "./IERC20.sol";
import "./SafeMath.sol";

import "./SafeOwnable.sol";
import "./IDayOfRightsClub.sol";
import "./IReferral.sol";
import "./IFactory.sol";
import "./IRouter.sol";
import "./console.sol";

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
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
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
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
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
        virtual
        override
        returns (bool)
    {
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
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
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
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
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
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
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
}

contract SmartVault {
    IERC20 public usdtToken;
    IERC20 public AlRihla;

    function initialize(IERC20 _usdtToken, IERC20 _AlRihla) external {
        require(address(usdtToken) == address(0), "has been initialized");
        usdtToken = _usdtToken;
        AlRihla = _AlRihla;

        usdtToken.approve(address(AlRihla), uint256(-1));
    }

    function approve() external {
        usdtToken.approve(address(AlRihla), uint256(-1));
    }
}

contract AlRihlaToken is ERC20, SafeOwnable {
    using SafeMath for uint256;
    using Address for address;

    uint256 public constant BASE_RATIO = 10**18;
    uint256 public constant MAX_FEE = (20 * BASE_RATIO) / 100;
    uint256 public constant SPY = (208 * BASE_RATIO) / 10000 / 1 days;
    uint256 public immutable rewardEndTime;
    mapping(address => bool) private minner;
    mapping(address => bool) public whitelist;
    mapping(address => uint256) public lastUpdateTime;
    mapping(address => bool) public rewardBlacklist;
    uint256 public fundFeePercent = (4 * BASE_RATIO) / 100;
    uint256 public liquidityFeePercent = (1 * BASE_RATIO) / 100;
    uint256 public nftPoolFeePercent = (2 * BASE_RATIO) / 100;
    uint256 public currentAllFee =
        fundFeePercent + liquidityFeePercent + nftPoolFeePercent;

    bool private inSwapAndLiquify;
    uint256 public minSwapAndLiquifyLimit = 100 * 10**18;
    uint256 public minSwapLimit = 100 * 10**18;
    IReferral public referralHandle;
    IERC20 public usdtToken;
    address public liquidity;
    address public fund;
    address public lpReceiver;
    address public nftPool;
    address private smartVault;
    IRouter public router;
    uint256 public extraSupply;
    bool public canTransfer;
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event AddWhitelist(address account);
    event DelWhitelist(address account);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _fund,
        address _lpReceiver,
        address _usdtToken,
        IFactory _factory,
        IRouter _router
    ) ERC20(_name, _symbol) {
        _setupDecimals(_decimals);

        fund = _fund;
        lpReceiver = _lpReceiver;
        usdtToken = IERC20(_usdtToken);

        liquidity = _factory.createPair(_usdtToken, address(this));
        router = _router;

        rewardEndTime = block.timestamp.add(730 days);
        setRewardBlacklist(liquidity, true);
        setRewardBlacklist(address(this), true);

        bytes memory bytecode = type(SmartVault).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(address(this)));
        address _smartVault;
        assembly {
            _smartVault := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        SmartVault(_smartVault).initialize(usdtToken, this);

        smartVault = _smartVault;
    }

    function setMinSwapAndLiquifyLimit(uint256 min) external onlyOwner {
        minSwapAndLiquifyLimit = min;
    }

    function setMinSwapLimit(uint256 min) external onlyOwner {
        minSwapLimit = min;
    }

    function setCanTransfer(bool enable) external onlyOwner {
        canTransfer = enable;
    }

    function setFundFeePercent(uint256 percent)
        external
        onlyOwner
        checkMaxFeeLimit(fundFeePercent, percent)
    {
        fundFeePercent = percent;
    }

    function setLiquidityFeePercent(uint256 percent)
        external
        onlyOwner
        checkMaxFeeLimit(liquidityFeePercent, percent)
    {
        liquidityFeePercent = percent;
    }

    function setNFTPoolFeePercent(uint256 percent)
        external
        onlyOwner
        checkMaxFeeLimit(nftPoolFeePercent, percent)
    {
        nftPoolFeePercent = percent;
    }

    modifier checkMaxFeeLimit(uint256 oldFee, uint256 newFee) {
        _;
        currentAllFee = currentAllFee.sub(oldFee).add(newFee);
        require(currentAllFee > MAX_FEE, "trade fee exceeded maximum limit");
    }

    function setReferralHandle(address _referralContract) external onlyOwner {
        referralHandle = IReferral(_referralContract);
    }

    function setMinner(address _minner, bool enable) external onlyOwner {
        minner[_minner] = enable;
    }

    function isMinner(address account) public view returns (bool) {
        return minner[account];
    }

    modifier onlyMinner() {
        require(isMinner(msg.sender), "caller is not minter");
        _;
    }

    function setRouter(IRouter _router) external onlyOwner {
        router = _router;
    }

    function setNFTPool(address _nftPool) external onlyOwner {
        nftPool = _nftPool;
    }

    function setFund(address _fund) external onlyOwner {
        fund = _fund;
    }

    function setLpReceiver(address _lpReceiver) external onlyOwner {
        lpReceiver = _lpReceiver;
    }

    function addWhitelist(address _addr) external onlyOwner {
        whitelist[_addr] = true;
        emit AddWhitelist(_addr);
    }

    function delWhitelist(address _addr) external onlyOwner {
        delete whitelist[_addr];
        emit DelWhitelist(_addr);
    }

    function mint(address to, uint256 value) external onlyMinner {
        _mint(to, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (!whitelist[from] && !whitelist[to]) {
            amount = calculateFee(from, to, amount);
        }
        super._transfer(from, to, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        require(
            canTransfer || whitelist[sender] || whitelist[recipient],
            "can not transfer"
        );
        return super.transferFrom(sender, recipient, amount);
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        require(
            canTransfer || whitelist[recipient] || whitelist[_msgSender()],
            "can not transfer"
        );
        return super.transfer(recipient, amount);
    }

    function calculateFee(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256) {
        uint256 realAmount = amount;
        address account = from;
        uint256 nftFee = amount.mul(nftPoolFeePercent).div(BASE_RATIO);
        if (nftPool != address(0) && nftFee > 0) {
            realAmount = realAmount.sub(nftFee);
            super._transfer(account, nftPool, nftFee);
        }

        uint256 fundFee = amount.mul(fundFeePercent).div(BASE_RATIO);
        if (fund != address(0) && fundFee > 0) {
            realAmount = realAmount.sub(fundFee);
            super._transfer(account, smartVault, fundFee);
        }
        uint256 liquidityFee = amount.mul(liquidityFeePercent).div(BASE_RATIO);
        if (liquidityFee > 0) {
            realAmount = realAmount.sub(liquidityFee);
            super._transfer(account, address(this), liquidityFee);
        }
        if (
            from != liquidity &&
            to != liquidity &&
            balanceOf(address(this)) > minSwapAndLiquifyLimit &&
            !inSwapAndLiquify
        ) {
            swapAndLiquify();
        }

        uint256 smartVaultBalance = balanceOf(address(smartVault));
        if (
            from != liquidity &&
            to != liquidity &&
            fund != address(0) &&
            smartVaultBalance > minSwapLimit &&
            !inSwapAndLiquify
        ) {
            inSwapAndLiquify = true;
            super._transfer(smartVault, address(this), smartVaultBalance);
            swapTokensForToken(
                smartVaultBalance,
                address(this),
                address(usdtToken),
                fund
            );
            inSwapAndLiquify = false;
        }

        return realAmount;
    }

    function swapAndLiquify() private lockTheSwap {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = usdtToken.balanceOf(smartVault);

        swapTokensForToken(half, address(this), address(usdtToken), smartVault);

        uint256 newBalance = usdtToken.balanceOf(smartVault).sub(
            initialBalance
        );

        addLiquidity(newBalance, otherHalf);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForToken(
        uint256 tokenAmount,
        address path0,
        address path1,
        address to
    ) private {
        address[] memory path = new address[](2);
        path[0] = path0;
        path[1] = path1;

        IERC20(path[0]).approve(address(router), tokenAmount);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function addLiquidity(uint256 usdtAmount, uint256 tokenAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);
        usdtToken.transferFrom(smartVault, address(this), usdtAmount);
        usdtToken.approve(address(router), usdtAmount);
        // add the liquidity
        router.addLiquidity(
            address(usdtToken),
            address(this),
            usdtAmount,
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            lpReceiver,
            block.timestamp
        );
    }

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account].add(getReward(account));
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply.add(extraSupply);
    }

    function setRewardBlacklist(address account, bool enable) public onlyOwner {
        rewardBlacklist[account] = enable;
    }

    function getReward(address account) public view returns (uint256) {
        if (lastUpdateTime[account] == 0 || rewardBlacklist[account]) {
            return 0;
        }
        return
            _balances[account].mul(SPY).div(BASE_RATIO).mul(
                lastTime().sub(lastUpdateTime[account])
            );
    }

    function lastTime() public view returns (uint256) {
        return Math.min(block.timestamp, rewardEndTime);
    }

    modifier calculateReward(address account) {
        if (account != address(0)) {
            uint256 reward = getReward(account);
            if (reward > 0) {
                _balances[account] = _balances[account].add(reward);
                extraSupply = extraSupply.add(reward);
            }
            lastUpdateTime[account] = lastTime();
        }
        _;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override calculateReward(from) calculateReward(to) {}
}