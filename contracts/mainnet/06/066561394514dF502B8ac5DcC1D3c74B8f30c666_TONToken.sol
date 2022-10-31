/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


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

    function burn(uint256 amount) external;
}

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

contract ERC20 is Ownable, IERC20, IERC20Metadata {
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
        return 6;
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
     * @dev Moves `amount` of tokens from `from` to `to`.
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


    function burn(uint256 amount) public override {
        _burn(_msgSender(), amount);
    }
}

contract TONToken is ERC20 {
    address public uniswapV2Pair;
    address public USDTAddr = address(0x55d398326f99059fF775485246999027B3197955);
    IUniswapV2Router public uniswapV2Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    uint256 constant public secondsPerDay = 86400;  // 180 For Dev, 86400 For Product

    uint256 total = 2100000 * 1e6;

    // Technical team  5%
    address public techAddress = address(0x17Dd8F31C288c73e7FFB10143B88D836185D1f46);
    uint256 public techAmt = total * 5 / 100;
    uint256 public techDayAmt = techAmt * 3 / 1000;
    uint256 public techReleasedAmt = 0;
    uint256 public techReleasedFrom = block.timestamp + 1095 * secondsPerDay;

    // Organization   15%
    address public orgAddress = address(0x9B2C4a2e1257A2def85D04B6B96CBcB15c2eBADd);
    uint256 public orgAmt = total * 15 / 100;
    uint256 public orgDayAmt = orgAmt * 5 / 1000;
    uint256 public orgReleasedAmt = 0;
    uint256 public orgReleasedFrom = block.timestamp + 1095 * secondsPerDay;

    // Minning   79%
    address public minAddress = address(0x52233E8a683e056F782e506d6aD0ce75bA59843A);
    uint256 public minAmt = total * 79 / 100;
    uint256 public minFirstYearDayAmt = 1000 * 1e6;
    uint256 public minReleasedAmt = 0;
    uint256 public minReleasedFrom = block.timestamp;

    uint256 public startTime;

    uint256 public swapTokensAtAmount = 100 * 1e6; 
    uint256 private minBalance = 1e3;
    address constant private destroyAddress = address(0x000000000000000000000000000000000000dEaD);

    mapping(address => bool) private isExcludedFromFees;

    uint256 public waitLPHolderTokenNum;  
    mapping (address => uint256) public lpHolderTokenNum;
    mapping (address => uint256) public lpHolderTokenWithdrawed;

    address[] public buyUser;
    mapping(address => bool) public havePushBuyUser;

    mapping (address => address) public preInviteMap; // Undetermined Invite User => Parent
    mapping (address => address) public inviteMap; // Invite User => Parent
    address[] public inviteKeys;  //All user with fathers

    uint256 public currentSplitIndex;
    uint8 public splitTimesPerTran = 20;

    constructor() ERC20("TON", "TON") {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), USDTAddr);

        _mint(address(0xeDF58345df5A17378A97C440034F4bcfDE3AeAcd), total * 1 / 100);
        _mint(address(this), total * 99 / 100);

        isExcludedFromFees[address(0xba4f3E2834B6BC696b3a765FEBc9a61751659835)] = true;
    }

    function setExcludeFromFees(address account, bool excluded) public onlyOwner {
        isExcludedFromFees[account] = excluded;
    }

    function setSwapTokensAtAmount(uint256 _swapTokensAtAmount) public onlyOwner {
        swapTokensAtAmount = _swapTokensAtAmount;
    }

    function setAddrParam(address _techAddress, address _orgAddress, address _minAddress) public onlyOwner {
        techAddress = _techAddress;
        orgAddress = _orgAddress;
        minAddress = _minAddress;
    }

    function setFather(address self, address father) private {
        if (preInviteMap[self] != address(0)) {
            return;
        }
        if (isContract(self) || isContract(father)) {
            return;
        }

        preInviteMap[self] = father;
    }

    function sureFather(address self, address father) private {
        if (inviteMap[self] == address(0) && preInviteMap[self] == father) {
            inviteMap[self] = father;
            inviteKeys.push(self);
        }
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function releaseTech() public {
        if (techReleasedAmt >= techAmt) {
            return;
        }
        if (block.timestamp <= techReleasedFrom) {
            return;
        }

        uint256 tmpReleasedAmt = (((block.timestamp - techReleasedFrom) / secondsPerDay) + 1) * techDayAmt;

        if (tmpReleasedAmt > techAmt) {
            tmpReleasedAmt = techAmt;
        }

        if (tmpReleasedAmt <= techReleasedAmt) {
            return;
        }

        super._transfer(address(this), techAddress, tmpReleasedAmt - techReleasedAmt);
        techReleasedAmt = tmpReleasedAmt;
    }

    function releaseOrg() public {
        if (orgReleasedAmt >= orgAmt) {
            return;
        }
        if (block.timestamp <= orgReleasedFrom) {
            return;
        }

        uint256 tmpReleasedAmt = (((block.timestamp - orgReleasedFrom) / secondsPerDay) + 1) * orgDayAmt;

        if (tmpReleasedAmt > orgAmt) {
            tmpReleasedAmt = orgAmt;
        }

        if (tmpReleasedAmt <= orgReleasedAmt) {
            return;
        }

        super._transfer(address(this), orgAddress, tmpReleasedAmt - orgReleasedAmt);
        orgReleasedAmt = tmpReleasedAmt;
    }

    function releaseMin() public {
        if (minReleasedAmt >= minAmt) {
            return;
        }

        uint256 tmpReleasedAmt = 0;
        uint256 tmpDays = (((block.timestamp - minReleasedFrom) / secondsPerDay) + 1);
        uint256 tmpYears = tmpDays / 365;

        uint256 curDayAmt = minFirstYearDayAmt;
        uint256 i = 0;
        for(; i < tmpYears; i++) {
            tmpReleasedAmt += 365 * curDayAmt;
            curDayAmt = curDayAmt / 2;
        }

        tmpReleasedAmt += (tmpDays - i * 365) * curDayAmt;

        if (tmpReleasedAmt > minAmt) {
            tmpReleasedAmt = minAmt;
        }

        if (tmpReleasedAmt <= minReleasedAmt) {
            return;
        }

        super._transfer(address(this), minAddress, tmpReleasedAmt - minReleasedAmt);
        minReleasedAmt = tmpReleasedAmt;
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(amount > 0, "Amount Zero");
        require(balanceOf(from) >= amount, "ERC20: transfer amount exceeds balance");

        if (amount + minBalance >= balanceOf(from)) {
            amount = balanceOf(from) - minBalance;
        }
		
        if(from == address(this) || to == address(this)){
            super._transfer(from, to, amount);
            return;
        }

        if (from == minAddress) {
            releaseMin();
        } else if (from == orgAddress) {
            releaseOrg();
        } else if (from == techAddress) {
            releaseTech();
        }

        if (amount == minBalance) {
            setFather(to, from);
        }
        sureFather(from ,to);

        if(currentSplitIndex > 0 || waitLPHolderTokenNum >= swapTokensAtAmount){
            splitLPHolderToken();
        } else {
            clearBuyUser(3);
        }

        userWithdrawFund();

        if(startTime == 0 && balanceOf(uniswapV2Pair) == 0 && to == uniswapV2Pair){
            startTime = block.timestamp;
        }

        bool takeFee = true;
        if (isExcludedFromFees[from] || isExcludedFromFees[to]) {
            takeFee = false;
        } else {
            if(from == uniswapV2Pair){
                if(startTime + 60 * 5 > block.timestamp){amount = amount / 5;}
            }else if(to == uniswapV2Pair){
            
            }else{
                takeFee = false;
            }
        }


        if (takeFee) {
            // LP 1.8%
            super._transfer(from, address(this), amount * 18 / 1000);
            waitLPHolderTokenNum += amount * 18 / 1000;

            // Burn 2%
            if (totalSupply() <= 210000 * 1e6) {
                super._transfer(from, techAddress, amount * 20 / 1000);
            } else {
                super._burn(from, amount * 20 / 1000);
            }
            

            // Parent 1% Or 0
            uint256 rewardInviteAmt;
            uint256 tmpReward = amount * 10 / 1000;
            if (from == uniswapV2Pair) {
                if(inviteMap[to] != address(0) && balanceOf(inviteMap[to]) >= 5 * 1e6) {
                    super._transfer(from, inviteMap[to], tmpReward);
                    rewardInviteAmt = tmpReward;
                }
            } else {
                if(inviteMap[from] != address(0) && balanceOf(inviteMap[from]) >= 5 * 1e6) {
                    super._transfer(from, inviteMap[from], tmpReward);
                    rewardInviteAmt = tmpReward;
                }
            }

            // Technical 0.2% Or 0.2% + 1%
            super._transfer(from, techAddress, amount * 2  / 1000 + amount * 10 / 1000 - rewardInviteAmt);

            amount = amount * 950 / 1000;
        }
        
        super._transfer(from, to, amount);
        
        if(to == uniswapV2Pair && !havePushBuyUser[from]){
            havePushBuyUser[from] = true;
            buyUser.push(from);
        }
    }

    function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(_msgSender(), tokens);
    }

    function rescueETH() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function splitLPHolderToken() private {
        uint256 thisAmount = waitLPHolderTokenNum;
        
        address user;
        uint256 totalAmount = IERC20(uniswapV2Pair).totalSupply();
        uint256 rate;

        uint256 buySize = buyUser.length;
        uint256 thisTimeSize = currentSplitIndex + splitTimesPerTran > buySize ? buySize : currentSplitIndex + splitTimesPerTran;

        for(uint256 i = currentSplitIndex; i < thisTimeSize; i++){
            user = buyUser[i];

            rate = IERC20(uniswapV2Pair).balanceOf(user) * 1000000 / totalAmount;
            uint256 userAmt = thisAmount * rate / 1000000;

            lpHolderTokenNum[user] += userAmt;
            waitLPHolderTokenNum -= userAmt;  

            currentSplitIndex ++;
        }

        if(currentSplitIndex >= buySize){
            currentSplitIndex = 0;
        }
    }

    function clearBuyUser(uint256 num) public {
        if (buyUser.length <= 0) {
            return;
        }

        uint256 buyUserLen = buyUser.length;
        uint256 toIdx = buyUserLen > num ? buyUserLen - num : 0;
        for(uint256 i = buyUserLen - 1; i >= toIdx; ) {
            address user = buyUser[i];

            if (IERC20(uniswapV2Pair).balanceOf(user) <= 0) {
                buyUser[i] = buyUser[buyUser.length - 1];

                buyUser.pop();
                havePushBuyUser[user] = false;
            }

            if (i > 0) {
                i --;
            } else {
                break;
            }
        }
    }

    function getBuyUsersize() public view returns(uint256) {
        return buyUser.length;
    }
    
    function getRewardInfo(address user) public view returns(uint256 lpCanWithdraw, uint256 lpWithdrawed, uint256 lpAmt, uint256 lpToUSDTAmt) {
        lpCanWithdraw = lpHolderTokenNum[user] - lpHolderTokenWithdrawed[user];
        lpWithdrawed = lpHolderTokenWithdrawed[user];
        lpAmt = IERC20(uniswapV2Pair).balanceOf(user);

        uint256 usdtAmount = IERC20(USDTAddr).balanceOf(uniswapV2Pair);
        uint256 totalAmount = IERC20(uniswapV2Pair).totalSupply();
        uint256 rate = IERC20(uniswapV2Pair).balanceOf(user) * 1000000 / totalAmount;
        lpToUSDTAmt = rate * usdtAmount * 2 / 1000000;
    }

    function userWithdrawFund() public returns (bool) {
        uint256 canWithdraw = lpHolderTokenNum[_msgSender()] - lpHolderTokenWithdrawed[_msgSender()];
        if (canWithdraw <= 0) {
            return true;
        }

        super._transfer(address(this), _msgSender(), canWithdraw);

        lpHolderTokenWithdrawed[_msgSender()] = lpHolderTokenNum[_msgSender()];

        return true;
    }
}