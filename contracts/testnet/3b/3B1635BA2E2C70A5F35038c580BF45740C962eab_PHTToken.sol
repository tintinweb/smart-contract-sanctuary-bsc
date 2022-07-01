// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "./SafeMath.sol";
import "./Address.sol";
import "./Math.sol";
import "./Context.sol";
import "./IERC20.sol";

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



contract PHTToken is ERC20, SafeOwnable {
    using SafeMath for uint256;
    using Address for address;
    uint256 public constant BASE_RATIO = 10 ** 18;
    uint256 public constant MAX_FEE = (20 * BASE_RATIO) / 100;
    uint256 public constant SPY = 214470000000000;
    uint256 public interval = 1 minutes;
  
    uint256 public immutable rewardEndTime;
    mapping(address => bool) private minner;
    mapping(address => bool) public whitelist;
    mapping(address => uint256) public lastUpdateTime;
    mapping(address => bool) public rewardBlacklist;
    uint256 public lpFeePercent = (1 * BASE_RATIO) / 100;
    uint256 public mtFeePercent = (2 * BASE_RATIO) / 100;
    uint256 public daoFeePercent = (2 * BASE_RATIO) / 100;
    uint256 public currentAllFee =
        lpFeePercent + mtFeePercent + daoFeePercent;
    address public mtAddr = 0x4570D935E2114b0F0D1f0BD1abBAe69cEFB3859e;
    address public daoAddr = 0x5A8333948dBaB635Bf88919d84a385bDEf3B2F8E;
    bool public canTransfer = true;


    IERC20 public usdtToken;
    address public liquidity;

    IRouter public router;
    uint256 public extraSupply;
    
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event AddWhitelist(address account);
    event DelWhitelist(address account);

    mapping(address => bool) public isDividendExempt;
    address[] public shareholders;
    mapping(address => uint256) public shareholderIndexes;
    uint256 public currentIndex;
    uint256 public currentTotal;
    uint256 public distributorGas = 300000;
    // uint256 public minPeriod = 1 days;
    uint256 public minPeriod = 5 minutes;
    uint256 public LPFeefenhong;
    mapping(address => bool) public _updated;

   /** 0xeAbF3B522dD4A4A368e360561df4f9E4faAFFBC0
    * 0x367eB0AFd414FAfcD76E94Cba4bBC043CF7284af 0xF2338e9aC4ee9d913e9aD8658D373e1c3D17e6fF 0x31A3d4b5db1390bdb6c768985dFCba4352Ee5304
    0x3cEeC23dFc2baE9E3907Dd5B19A09dC9657DE272
    * _usdtToken 0xf5Eacdee153A7247aC93A35FFD7cCF1Aec89fac2
    * _factory 0x6725F303b657a9451d8BA641348b6761A6CC7a17
    * _router 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    
   */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _usdtToken,
        IFactory _factory,
        IRouter _router
    ) ERC20(_name, _symbol) {
        _setupDecimals(_decimals);
        usdtToken = IERC20(_usdtToken);

        liquidity = _factory.createPair(_usdtToken, address(this));
        router = _router;

        rewardEndTime = block.timestamp.add(730 days);

        minner[owner()] = true;
        setRewardBlacklist(owner(), true);
        setRewardBlacklist(liquidity, true);
        setRewardBlacklist(address(this), true);
        setRewardBlacklist(daoAddr, true);
        setRewardBlacklist(mtAddr, true);
        setRewardBlacklist(0xC7D3A19C2535B25fa2cFeEf97225FAd79d408Fae, true);

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[liquidity] = true;

    }

    function setCurrentTotal (uint256 _total) public onlyOwner returns (bool) {
        currentTotal = _total;
        return true;
    }

    function setDividendExempt(address[] calldata _addrs, bool _flag) external onlyOwner {
         for(uint256 i=0; i<_addrs.length; i++){
          address account = _addrs[i];
          isDividendExempt[account]=_flag;
        }
    }

    function setDistributorGas(uint256 _distributorGas) external onlyOwner {
        distributorGas = _distributorGas;
    }

    function setCanTransfer(bool enable) external onlyOwner {
        canTransfer = enable;
    }

    function setLpFeePercent(uint256 percent)
        external
        onlyOwner
        checkMaxFeeLimit(lpFeePercent, percent)
    {
        lpFeePercent = percent;
    }

    function setMtFeePercent(uint256 percent)
        external
        onlyOwner
        checkMaxFeeLimit(mtFeePercent, percent)
    {
        mtFeePercent = percent;
    }

    function setMtAddr(address _addr) external onlyOwner {
        mtAddr = _addr;
    }

    function setDaoFeePercent(uint256 percent)
        external
        onlyOwner
        checkMaxFeeLimit(daoFeePercent, percent) {
        daoFeePercent = percent;
    }
    function setDaoAddr(address _addr) external onlyOwner {
        daoAddr = _addr;
    }

    modifier checkMaxFeeLimit(uint256 oldFee, uint256 newFee) {
        _;
        currentAllFee = currentAllFee.sub(oldFee).add(newFee);
        require(currentAllFee > MAX_FEE, "trade fee exceeded maximum limit");
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
            amount = calculateFee(from, amount);
        }
        if (!isDividendExempt[from] && from != liquidity) setShare(from);
        if (!isDividendExempt[to] && to != liquidity) setShare(to);
        if (from != address(this)) {
            _beforeProcess();
        }
        super._transfer(from, to, amount);
    }

    function _beforeProcess () public {
        if(LPFeefenhong.add(minPeriod) <= block.timestamp) {
            LPFeefenhong = block.timestamp;
            currentIndex = 0;
            currentTotal = balanceOf(address(this));

        }
        process(distributorGas);
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
        uint256 amount
    ) internal returns (uint256) {
        uint256 realAmount = amount;
        address account = from;

        uint256 lpFee = amount.mul(lpFeePercent).div(BASE_RATIO);
        if (lpFee > 0) {
            realAmount = realAmount.sub(lpFee);
            super._transfer(account, address(this), lpFee);
        }
        uint256 mtFee = amount.mul(mtFeePercent).div(BASE_RATIO);
        if (mtFee > 0) {
            realAmount = realAmount.sub(mtFee);
            super._transfer(account, mtAddr, mtFee);
        }
        uint256 daoFee = amount.mul(daoFeePercent).div(BASE_RATIO);
        if (daoFee > 0) {
            realAmount = realAmount.sub(daoFee);
            super._transfer(account, daoAddr, daoFee);
        }
        return realAmount;
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
        uint256 times = getTimes(account);
        uint256 balance =  _balances[account];
        uint256 totalReward = 0;
        for (uint256 i = 0; i < times; i++) {
          uint256 reward = balance.mul(SPY).div(BASE_RATIO); 
          totalReward = totalReward.add(reward);
          balance = balance.add(reward);
        }
        return totalReward;
    }


   function getNextReward(address account) public view returns (uint256) {
        if (lastUpdateTime[account] == 0 || rewardBlacklist[account]) {
            return 0;
        }
        uint256 reward = balanceOf(account).mul(SPY).div(BASE_RATIO);
        return reward;
    }

    function getTimes (address account) public view returns (uint256) { 
        uint256 deltaTime = lastTime().sub(lastUpdateTime[account]);
        uint256 times =  deltaTime.div(interval);
        return times;
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
            lastUpdateTime[account] = lastUpdateTime[account].add(getTimes(account).mul(interval));
        }
        _;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override calculateReward(from) calculateReward(to) {}

    function getShareholdersCount () public view returns (uint256) {
        return shareholders.length;
    }

    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;
        uint256 currentRate = 1;
        if (shareholderCount == 0||currentIndex >= shareholderCount) return;
        
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        while (gasUsed < gas && iterations < shareholderCount && currentIndex < shareholderCount) {
            uint256 amount = currentTotal.mul(IERC20(liquidity).balanceOf(shareholders[currentIndex])).div(IERC20(liquidity).totalSupply());
            if (amount < 1 * 10 ** 18) {
                currentIndex++;
                iterations++;
                return;
            }
            if (currentTotal < amount) return;
            distributeDividend(shareholders[currentIndex], amount, currentRate);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function distributeDividend(address shareholder, uint256 amount, uint256 currentRate) internal {
        uint256 rAmount = amount.mul(currentRate);
        _balances[address(this)] = _balances[address(this)].sub(rAmount);
        _balances[shareholder] = _balances[shareholder].add(rAmount);
        emit Transfer(address(this), shareholder, amount);
    }

    function setShare(address shareholder) public {
        if (_updated[shareholder]) {
            if (IERC20(liquidity).balanceOf(shareholder) == 0) quitShare(shareholder);
            return;
        }
        if (IERC20(liquidity).balanceOf(shareholder) == 0) return;
        addShareholder(shareholder);
        _updated[shareholder] = true;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function quitShare(address shareholder) private {
        removeShareholder(shareholder);
        _updated[shareholder] = false;
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}