/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: MIT
// File: contracts/Paragon.sol


pragma solidity >=0.4.22 <0.9.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

}

contract Paragon is Context, IERC20, Ownable {
	using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 private _indexSupply;
    uint256 private _divisor;

    string private constant _name   = "Paragon";
    string private constant _symbol = "XPG";
    
    constructor() {
        
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
        return _totalSupply.div(divisor());
    }

    /**
     * @dev Used for rebase calculation and setting the divisor.
     */
    function indexSupply() public view returns (uint256) {
        return _indexSupply;
    }

    function divisor() public view returns (uint256) {
        return _divisor;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account].div(divisor());
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

    function _setIndexSupply(uint256 toSupply) internal virtual {
        _indexSupply = toSupply;
    }

    function _setDivisor(uint256 toDivisor) internal virtual {
        _divisor = toDivisor;
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
    function _mint(address account, address liquidity, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply         += amount;
        _balances[account]   += amount;
        _balances[liquidity] += amount;
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}
// File: contracts/ParagonSwap.sol


pragma solidity >=0.4.22 <0.9.0;


contract ParagonSwap is Paragon {
	using SafeMath for uint256;

    //reserve
    uint256 public constant EXC_RATE   = ~uint128(0);
    uint256 public constant MAX_SUPPLY = EXC_RATE * 10 ** 18;
    uint256 public minReserve          = 6000; //<-------------------- 60 percent (no denominator)

    //fees
	uint256 public constant FEE_DENOMINATOR = 1000;
    uint256 public constant MAX_FEE_BUY     = 75; //<----------------- 7.5 percent
    uint256 public constant MAX_FEE_SELL    = 75; //<----------------- 7.5 percent
    uint256 public constant DEV_FEE         = 15; //<----------------- 1.5 percent
    uint256 public feeBuy  = 75;
    uint256 public feeSell = 75;

    //rebases
    uint256 public rewardYield           = 1000; //<------------------ 10 percent
    uint256 public rewardYieldDenominator= 10000;
    uint256 public rebaseFrequency       = 1 days; //<---------------- 1 day
    uint256 public nextRebase;
    uint256 public epoch;

    //buy cap
    uint256 public spendPerEpoch = 500 ether; //<--------------------- 500 BUSD
    uint256 public spent;

    //contract state
    bool public enableSwap = true;
    bool public autoRebase = true;
    uint256 public pegRate = 100; //<--------------------------------- n tokens per 1 BUSD (backing price)

    //mappings
    mapping(uint256 => uint256) public historicalPeg; //<------------- stores pegRate at every epoch
    mapping(address => bool) public taxExemptions; //<---------------- wallets exempt from taxation
    mapping(address => address) public userReferrer; //<-------------- stores user referrer

    //addresses
    address public dev;
    address public ops;
    address public liquidityXPG;
    address public liquidityBUSD;
    address public marketing;
    address public admin;
    address public busdAddress;

    constructor(address _busdAddress) {
        dev          = msg.sender;
        ops          = msg.sender; //<------------------------------------ should be _ops wallet in production build
        liquidityXPG = msg.sender; //<------------------------------------ should be _liquidityXPG wallet in production build
        liquidityBUSD= msg.sender; //<------------------------------------ should be _liquidityBUSD wallet in production build
        marketing    = msg.sender; //<------------------------------------ should be _marketing wallet in production build
        admin        = msg.sender; //<------------------------------------ should be _admin wallet in production build

        busdAddress= _busdAddress; //<-------------------------------- set BUSD address
        nextRebase = block.timestamp + rebaseFrequency; //<----------- set first rebase
        _setIndexSupply(1 ether); //<--------------------------------- initialize index supply
        _setDivisor(EXC_RATE); //<------------------------------------ initialize divisor
        setHistoricalPeg(epoch, pegRate); //<------------------------- store peg rate (at epoch 0)
    }

    modifier onlyAdmin() {
        require(msg.sender == dev || msg.sender == admin, "Not authorized.");
        _;
    }

    function buyTokens(uint256 amount, address referrer) external {
        require(enableSwap, "swap is disabled");
        require(spent.add(amount) <= spendPerEpoch, "Sold Out");
        
        address buyer = msg.sender;
        IERC20(busdAddress).transferFrom(buyer, address(this), amount);
        spent = spent.add(amount);

        uint256 devFee  = amount.mul(DEV_FEE).div(FEE_DENOMINATOR);
        uint256 fees    = amount.mul(feeBuy).div(FEE_DENOMINATOR);
        uint256 sumFees = devFee.add(fees);

        if(isTaxExempt(buyer)) {
            devFee = 0;
            fees   = 0;
            sumFees= 0;
        }

        uint256 tokens= amount.sub(sumFees).mul(EXC_RATE).mul(pegRate);
        _mint(buyer, liquidityXPG, tokens);

        if(isTaxExempt(buyer) == false) {
            (uint256 opsFee, uint256 liquidityFee, uint256 marketingFee, uint256 referralBonus) = distribute(fees);
            IERC20(busdAddress).transfer(payable(dev), devFee);
            IERC20(busdAddress).transfer(payable(ops), opsFee);
            IERC20(busdAddress).transfer(payable(liquidityBUSD), liquidityFee);
            IERC20(busdAddress).transfer(payable(marketing), marketingFee);

            if(referrer == buyer) {
                setUserReferrer(buyer, liquidityBUSD);
            } else {
                setUserReferrer(buyer, referrer);
            }
            IERC20(busdAddress).transfer(payable(getUserReferrer(buyer)), referralBonus);
        }

        if(rebaseDue() && minimumRatio() && autoRebase) {
            rebase();
        }
    }

    function sellTokens(uint256 amount) external {
        require(enableSwap, "Swap is disabled");
        require(minimumRatio(), "Reserve ratio is below minimum");

        uint256 tokens = amount.mul(divisor());
        address seller = msg.sender;
        _burn(seller, tokens);

        uint256 busdAmount = amount.div(pegRate);
        uint256 devFee     = busdAmount.mul(DEV_FEE).div(FEE_DENOMINATOR);
        uint256 fees       = busdAmount.mul(feeSell).div(FEE_DENOMINATOR);
        uint256 sumFees    = devFee.add(fees);

        if(isTaxExempt(seller)) {
            devFee = 0;
            fees   = 0;
            sumFees= 0;
        }

        if(isTaxExempt(seller) == false) {
            (uint256 opsFee, uint256 liquidityFee, uint256 marketingFee, uint256 referralBonus) = distribute(fees);
            IERC20(busdAddress).transfer(payable(dev), devFee);
            IERC20(busdAddress).transfer(payable(ops), opsFee);
            IERC20(busdAddress).transfer(payable(liquidityBUSD), liquidityFee);
            IERC20(busdAddress).transfer(payable(marketing), marketingFee);
            IERC20(busdAddress).transfer(payable(getUserReferrer(seller)), referralBonus);
        }

        if(rebaseDue() && minimumRatio() && autoRebase) {
            rebase();
        }
        
        IERC20(busdAddress).transfer(payable(seller), busdAmount.sub(sumFees));
    }

	function distribute(uint256 fees) public pure returns (uint256 opsFee, uint256 liquidityFee, uint256 marketingFee, uint256 referralBonus) {
        opsFee       = fees.mul(200).div(FEE_DENOMINATOR);
        liquidityFee = fees.mul(200).div(FEE_DENOMINATOR);
        marketingFee = fees.mul(400).div(FEE_DENOMINATOR);
        referralBonus= fees.mul(200).div(FEE_DENOMINATOR);
	}

    function rebase() private {
        uint256 supply      = indexSupply();
        uint256 supplyDelta = supply.mul(rewardYield).div(rewardYieldDenominator);

        coreRebase(supplyDelta);
    }

    function coreRebase(uint256 supplyDelta) private {
        uint256 old_supply = indexSupply();
        uint256 new_supply;

        if(old_supply < MAX_SUPPLY) {
            new_supply = old_supply.add(supplyDelta);
        } else {
            new_supply = MAX_SUPPLY;
        }
        //set index supply
        _setIndexSupply(new_supply);

        //set divisor
        _setDivisor(MAX_SUPPLY.div(new_supply));

        //reset spent
        spent = 0;
        
        //set next rebase
        nextRebase = block.timestamp + rebaseFrequency;

        //set epoch
        epoch++;

        //store historical peg rate
        setHistoricalPeg(epoch, pegRate);
    }

    function rebaseDue() public view returns (bool) {
        return nextRebase <= block.timestamp;
    }

    function manualRebase() external {
        if(rebaseDue() && minimumRatio()) {
            rebase();
        }
    }

    function reserveRatio() public view returns (uint256) {
        uint256 precision = 5;
        uint256 reserve   = IERC20(busdAddress).balanceOf(address(this)) * 10 ** precision;    //numerator
        uint256 supply    = totalSupply().div(pegRate);                                        //denominator
        uint256 ratio     = (reserve.div(supply) + 5).div(10);                                 //quotient

        return ratio;
    }

    function minimumRatio() public view returns (bool) {
        return reserveRatio() > minReserve;
    }

    function setHistoricalPeg(uint256 atEpoch, uint256 toValue) private {
        historicalPeg[atEpoch] = toValue;
    }

    function getHistoricalPeg(uint256 atEpoch) public view returns (uint256) {
        return historicalPeg[atEpoch];
    }

    function isTaxExempt(address atAddress) public view returns (bool) {
        return taxExemptions[atAddress];
    }

    function getUserReferrer(address atAddress) public view returns (address) {
        return userReferrer[atAddress];
    }

    function setUserReferrer(address atAddress, address toReferrer) private {
        userReferrer[atAddress] = toReferrer;
    }

    //admin panel //////////////////////////////////////////////////////////
    function setEnableSwap(bool enabled) external onlyAdmin {
        enableSwap = enabled;
    }
    function setAutoRebase(bool enabled) external onlyAdmin {
        autoRebase = enabled;
    }
    function setRewardYield(uint256 _rewardYield) external onlyAdmin {
        rewardYield = _rewardYield;
    }
    function setFees(uint256 _feeBuy, uint256 _feeSell) external onlyAdmin {
        require(_feeBuy  <= MAX_FEE_BUY);
        require(_feeSell <= MAX_FEE_SELL);
        feeBuy  = _feeBuy;
        feeSell = _feeSell;
    }
    function setSpendPerEpoch(uint256 spend) external onlyAdmin {
        spendPerEpoch = spend;
    }
    function setPegRate(uint256 rate) external onlyAdmin {
        pegRate = rate;
    }
    function setExemption(address atAddress, bool toValue) external onlyAdmin {
        taxExemptions[atAddress] = toValue;
    }
    function setMinReserve(uint256 toPercent) external onlyAdmin {
        minReserve = toPercent;
    }
    ////////////////////////////////////////////////////////////////////////
}