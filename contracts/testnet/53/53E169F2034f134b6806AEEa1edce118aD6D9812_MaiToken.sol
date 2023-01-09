/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// File: contracts/token.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

interface IMaiDAONFT {
    function getAdmin() external returns(address);
}

abstract contract Administrable {
    IMaiDAONFT public maiDAONFT;

    constructor (address maiDAONFTAddress)
    {
        maiDAONFT = IMaiDAONFT(maiDAONFTAddress);
    }

    modifier onlyAdmin() {
        require(maiDAONFT.getAdmin() == msg.sender, "Administrable: caller is not the admin");
        _;
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    function sync() external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
}

contract MaiToken is Context, IERC20, IERC20Metadata, Administrable {
    // Openzeppelin variables
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    // My variables

    bool private inSwap;
    uint256 internal _walletCFeeCollected;
    uint256 internal _walletBFeeCollected;
    uint256 internal _miningFeeCollected;
    uint256 internal _governanceFeeCollected;

    uint256 public minTokensBeforeSwap;
    
    address public walletCAddress;
    address public walletBAddress;
    address public miningAddress;
    address public governanceAddress;

    IUniswapV2Router01 public router;
    address public pair;

    uint public _feeDecimal = 2;
    // index 0 = buy fee, index 1 = sell fee, index 2 = p2p fee
    uint[] public _walletCFee;
    uint[] public _walletBFee;
    uint[] public _miningFee;
    uint[] public _governanceFee;

    bool public swapEnabled = true;
    bool public isFeeActive = false;

    mapping(address => bool) public isTaxless;
    mapping(address => bool) public isMaxTxExempt;

    mapping(address => uint) public amountBuy;
    mapping(address => uint) public amountSell;
    mapping(address => uint) public amountP2P;

    event Swap(uint totalCollected, uint amountWalletC, uint amountWalletB, uint amountMining, uint amountGoveranance);

    // Openzeppelin functions

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(address pancakeRouterSwapAddress, address busdAddress, address maiDaoNFTAddress)
        Administrable(maiDaoNFTAddress) {
        // Editable
        string memory e_name = "Mai Token";
        string memory e_symbol = "MAI";
        walletCAddress = 0x707e55a12557E89915D121932F83dEeEf09E5d70;
        walletBAddress = 0xbef34f2FCAe62dC3404c3d01AF65a7784c9c4A19;
        miningAddress = 0x08966BfFa14A7d0d7751355C84273Bb2eaF20FC3;
        governanceAddress = 0x08966BfFa14A7d0d7751355C84273Bb2eaF20FC3;
        uint e_totalSupply = 69_000_000_000 ether;
        minTokensBeforeSwap = e_totalSupply;    // Off by default
        // End editable
        
        _name = e_name;
        _symbol = e_symbol;

        IUniswapV2Router01 _uniswapV2Router = IUniswapV2Router01(pancakeRouterSwapAddress);
        pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), busdAddress);
        router = _uniswapV2Router;

        _walletCFee.push(1800);
        _walletCFee.push(1800);
        _walletCFee.push(40);

        _walletBFee.push(900);
        _walletBFee.push(900);
        _walletBFee.push(10);

        _miningFee.push(200);
        _miningFee.push(200);
        _miningFee.push(10);

        _governanceFee.push(100);
        _governanceFee.push(100);
        _governanceFee.push(40);

        isTaxless[msg.sender] = true;
        isTaxless[address(this)] = true;
        isTaxless[walletCAddress] = true;
        isTaxless[walletBAddress] = true;
        isTaxless[miningAddress] = true;
        isTaxless[governanceAddress] = true;
        isTaxless[address(0)] = true;

        _mint(msg.sender, e_totalSupply);
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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
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

        // My implementation
        if (swapEnabled && !inSwap && from != pair) {
            swap();
        }

        uint256 feesCollected;
        if (isFeeActive && !isTaxless[from] && !isTaxless[to] && !inSwap) {
            bool sell = to == pair;
            bool p2p = from != pair && to != pair;
            feesCollected = calculateFee(p2p ? 2 : sell ? 1 : 0, amount);
        }

        if(from == pair)
        {
            amountBuy[to] += amount;
        }
        else if(to == pair)
        {
            amountSell[from] += amount;
        }
        else
        {
            amountP2P[from] += amount;
        }

        amount -= feesCollected;
        _balances[from] -= feesCollected;
        _balances[address(this)] += feesCollected;
        // End my implementation

        uint256 fromBalance = _balances[from];
        //require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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

    // My functions

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    function sendViaCall(address payable _to, uint amount) private {
        (bool sent, bytes memory data) = _to.call{value: amount}("");
        data;
        require(sent, "Failed to send Ether");
    }

    function swap() private lockTheSwap {
        // How much are we swaping?
        uint totalCollected = _walletCFeeCollected + _walletBFeeCollected + _miningFeeCollected + _governanceFeeCollected;

        if(minTokensBeforeSwap > totalCollected) return;

        if(_walletCFeeCollected > 0) this.transfer(walletCAddress, _walletCFeeCollected);
        if(_walletBFeeCollected > 0) this.transfer(walletBAddress, _walletBFeeCollected);
        if(_miningFeeCollected > 0) this.transfer(miningAddress, _miningFeeCollected);
        if(_governanceFeeCollected > 0) this.transfer(governanceAddress, _governanceFeeCollected);
        
        emit Swap(totalCollected, _walletCFeeCollected, _walletBFeeCollected, _miningFeeCollected, _governanceFeeCollected);

        _walletCFeeCollected = 0;
        _walletBFeeCollected = 0;
        _miningFeeCollected = 0;
        _governanceFeeCollected = 0;
    }

    function calculateFee(uint256 feeIndex, uint256 amount) internal returns(uint256) {
        uint256 walletCFee = (amount * _walletCFee[feeIndex]) / (10**(_feeDecimal + 2));
        uint256 walletBFee = (amount * _walletBFee[feeIndex]) / (10**(_feeDecimal + 2));
        uint256 miningFee = (amount * _miningFee[feeIndex]) / (10**(_feeDecimal + 2));
        uint256 governanceFee = (amount * _governanceFee[feeIndex]) / (10**(_feeDecimal + 2));
        
        _walletCFeeCollected += walletCFee;
        _walletBFeeCollected += walletBFee;
        _miningFeeCollected += miningFee;
        _governanceFeeCollected += governanceFee;
        return walletCFee + walletBFee + miningFee + governanceFee;
    }

    function setMinTokensBeforeSwap(uint256 amount) external onlyAdmin {
        minTokensBeforeSwap = amount;
    }

    function setWalletC(address _address)  external onlyAdmin {
        walletCAddress = _address;
    }

    function setWalletB(address _address)  external onlyAdmin {
        walletBAddress = _address;
    }

    function setMiningAddress(address _address)  external onlyAdmin {
        miningAddress = _address;
    }

    function setGovernanceAddress(address _address)  external onlyAdmin {
        governanceAddress = _address;
    }

    function setWalletCFees(uint256 buy, uint256 sell, uint256 p2p) external onlyAdmin {
        _walletCFee[0] = buy;
        _walletCFee[1] = sell;
        _walletCFee[2] = p2p;
    }

    function setWalletBFees(uint256 buy, uint256 sell, uint256 p2p) external onlyAdmin {
        _walletBFee[0] = buy;
        _walletBFee[1] = sell;
        _walletBFee[2] = p2p;
    }

    function setMiningFees(uint256 buy, uint256 sell, uint256 p2p) external onlyAdmin {
        _miningFee[0] = buy;
        _miningFee[1] = sell;
        _miningFee[2] = p2p;
    }

    function setGovernanceFees(uint256 buy, uint256 sell, uint256 p2p) external onlyAdmin {
        _governanceFee[0] = buy;
        _governanceFee[1] = sell;
        _governanceFee[2] = p2p;
    }

    function setSwapEnabled(bool enabled) external onlyAdmin {
        swapEnabled = enabled;
    }

    function setFeeActive(bool value) external onlyAdmin {
        isFeeActive = value;
    }

    function setTaxless(address account, bool value) external onlyAdmin {
        isTaxless[account] = value;
    }

    function setMaxTxExempt(address account, bool value) external onlyAdmin {
        isMaxTxExempt[account] = value;
    }

    fallback() external payable {}
    receive() external payable {}
}