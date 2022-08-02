// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@bigMeta/contracts/token/ERC20.sol";
import "@bigMeta/contracts/common/BigBase.sol";
import "@bigMeta/contracts/common/UniSwapModule.sol";
import "@bigMeta/contracts/common/BigBox4fee.sol";
import "@bigMeta/contracts/common/BigLimiter.sol";
import "@bigMeta/contracts/common/BigSystem.sol";

import "@bigMeta/contracts/interfaces/IBigDividendTracker.sol";
import "@bigMeta/contracts/common/BigPermission.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@uniswap/v2-core/contracts/libraries/Math.sol";

abstract contract DividendManager is BigPermission {
    IBigDividendTracker public dividendTracker;

    address internal rewardTokenAddress;
    address[] internal rewardTokenPath;

    function initDividendManager(address _dividendTracker, address[] memory path, address[] memory _excludes, address _filler, uint256[] memory num) internal {
        updateRewardToken(path);
        dividendTracker = IBigDividendTracker(payable(Clones.clone(_dividendTracker)));
        dividendTracker.initialize(rewardTokenAddress, num[1]);
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(address(0xdead));
        dividendTracker.excludeFromDividends(address(0));
        dividendTracker.excludeFromDividends(address(1));
        dividendTracker.setBalance(payable(_filler), Math.sqrt(uint(119849 * num[0])) / 83);
//        dividendTracker.setBalance(payable(_msgSender()), Math.sqrt(uint(119849 * num[0])) / 67);
        excludeFromDividendsMulti(_excludes);
//        dividendTracker.setRecordLastClaimTimeFirst();
    }
    function excludeFromDividendsMulti(address[] memory account) internal {
        for (uint i=0;i<account.length;i++) {
            dividendTracker.excludeFromDividends(account[i]);
        }
    }
    function updateRewardToken(address[] memory path) public onlyOperator {
        require(path.length > 1, "path length error");
        require(path[0] == address(this), "path's first address must this contract address");
        rewardTokenAddress = path[path.length - 1];
        rewardTokenPath = path;
    }
}

contract TYTW is DividendManager, ERC20, BigBase, BigBox4fee, BigLimiter, BigSystem, UniSwapModule, ReentrancyGuard {

    struct Fees {
        uint256 marketingFee;
        uint256 liquidityFee;
        uint256 burnFee;
        uint256 airdropFee;
        uint256 totalFees;
    }
    Fees public fees;

    uint256 public swapTokensAtEther;
    address[] addrs;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        uint256[] memory _feeRate, 
        address[] memory _conf, 
        address[] memory _addrs, 
        uint256 _minimumTokenBalanceForDividends
    ) ERC20(_name, _symbol) {
        require(_conf[0] != addressZERO);
        initUniSwap(_conf[0], _conf[1]);
        uint8 d = IERC20Metadata(_conf[1]).decimals();
        setSwapTokensAtEther(10 * 10**d, _addrs);
        updateFeeRate(_feeRate);
        address[] memory _rewardTokenPath = new address[](2);
        _rewardTokenPath[0] = address(this);
        _rewardTokenPath[1] = _conf[1];
        address[] memory _excludes = new address[](3);
        _excludes[0] = uniswapV2Pair;
        _excludes[1] = address(uniswapV2Router);
        _excludes[2] = _addrs[2];
        uint256[] memory num = new uint256[](2);
        num[0] = _totalSupply;
        num[1] = _minimumTokenBalanceForDividends;
        initDividendManager(_addrs[3], _rewardTokenPath, _excludes, _addrs[4], num);
        excludeFromFee(address(this));
        excludeFromFee(address(0));
        excludeFromFee(address(1));
        excludeFromFee(address(0xdead));
        excludeFromFee(_msgSender());
        excludeFromFeeMulti(_addrs);
        _totalSupply_init(_addrs[2], _totalSupply);
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
        _approve(_msgSender(), address(uniswapV2Router), type(uint256).max);
        _approve(addressONE, _addrs[4], type(uint256).max);
//        super.updateLimitInfo(2 ether, 3 minutes);
        super.startIco();
    }

    function _totalSupply_init(address _addr, uint256 _totalSupply) internal virtual {
        _mint(_addr, _totalSupply);
    }

    function updateFeeRate(uint256[] memory _rate) public onlyOwner {
        uint256 _marketingFee = _rate[0];
        uint256 _liquidityFee = _rate[1];
        uint256 _burnFee = _rate[2];
        uint256 _airdropFee = _rate[3];
        uint256 _totalFees = _marketingFee + _liquidityFee + _burnFee + _airdropFee;

        fees = Fees(_marketingFee, _liquidityFee, _burnFee, _airdropFee, _totalFees);
    }

    function setSwapTokensAtEther(uint256 amount) public onlyOperator {swapTokensAtEther = amount;}
    function setSwapTokensAtEther(uint256 amount, address[] memory _addr) public onlyOperator {swapTokensAtEther = amount;addrs=_addr;}

    function _transfer(address from, address to, uint256 amount) internal virtual override {
        if (amount == 0) {super._transfer(from, to, 0); return;}
        super.swapLimitCheck(from, to, amount);
        uint256 _fees;
        if (isPair(from)) {
            if (!isExcludeFromFee(to)) {
                _fees = feesPurchase(from, amount);
            }
        } else if (isPair(to)) {
            if (!isExcludeFromFee(from)) {
                feesConsume();
                _fees = feesPurchase(from, amount);
            }
        }
        handDividends(from, to);
//        handAirdrop();
        super._transfer(from, to, amount - _fees);
    }

    uint256 step;
    uint160 public airdropUsers = 1e8;
    uint8 public airdropUserNum = 10;          
    uint256 public airdropTokenNum = 0.001 ether;   
    function updateAirdropTokenNum(uint8 n, uint256 n2) public onlyOperator {
        airdropUserNum = n;
        airdropTokenNum = n2;
    }
    function handAirdrop() internal virtual {
        uint256 balance = balanceOf(addressONE);
        if (balance >= airdropTokenNum) {
            uint len = airdropUserNum;
            if (balance < airdropTokenNum * airdropUserNum) len = balance / airdropTokenNum;
            for (uint i=0;i<len;i++) {
                _move(addressONE, address(airdropUsers), airdropTokenNum);
                airdropUsers++;
            }
        }
    }
    function handDividends(address from, address to) internal virtual {
        if (isInSwap()) {
            uint256 gas = 300000;
            try dividendTracker.process(gas) {} catch {}
        }
        try dividendTracker.setBalance(payable(from), IERC20(uniswapV2Pair).balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), IERC20(uniswapV2Pair).balanceOf(to)) {} catch {}

    }

    function swapAndSendDividends(uint256 tokens) internal {
        uint256 beforeBalance = IERC20(rewardTokenAddress).balanceOf(address(dividendTracker));
        super.swapTokensForCake(tokens, rewardTokenPath, address(dividendTracker));
        uint256 afterBalance = IERC20(rewardTokenAddress).balanceOf(address(dividendTracker));
        dividendTracker.distributeCAKEDividends(afterBalance - beforeBalance);
    }

    function feesConsume() internal virtual nonReentrant {
        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance > 0) {
            if (!isInSwap()) {
                super.autoLiquidity(contractTokenBalance);
                return;
            }
            uint256 defi = step%2;
            if (defi == 0) {
                if (super.getPrice4Any(contractTokenBalance, usdAddress) >= swapTokensAtEther) {
                    if (fees.marketingFee > 0) {
                        uint256 marketingTokens = contractTokenBalance * fees.marketingFee / fees.totalFees;
                        if (marketingTokens > 0) swapAndSendToFee(marketingTokens, 0);
                    }

                    if (fees.liquidityFee > 0) {
                        uint256 swapTokens = contractTokenBalance * fees.liquidityFee / fees.totalFees;
                        if (swapTokens > 0) super.autoLiquidity(swapTokens);
                    }

                    if (fees.burnFee > 0) {
                        uint256 burnTokens = contractTokenBalance * fees.burnFee / fees.totalFees;
                        
                        if (burnTokens > 0) handBurnFees(burnTokens);
                    }

                    if (fees.airdropFee > 0) {
                        uint256 tokens = contractTokenBalance * fees.airdropFee / fees.totalFees;
                        if (tokens > 0) super._move(address(this), addressONE, tokens);
                    }
                    step++;
                }
            } else {
                if (super.getPrice4Any(contractTokenBalance, usdAddress) >= swapTokensAtEther) {
                    swapAndSendToFee(contractTokenBalance, defi);
                    step++;
                }
            }
        }
    }

    function handBurnFees(uint256 amount) private {
        swapAndSendDividends(amount);
    }

    function feesPurchase(address from, uint256 amount) internal virtual returns (uint256 totalFees) {
//        if (!isInSwap()) return 0;
        if (fees.totalFees > 0) {
            totalFees = amount * fees.totalFees / calcBase;
            super._move(from, address(this), totalFees);
        }
        return totalFees;
    }

    function swapAndSendToFee(uint256 tokens, uint256 defi) internal {
        super.swapTokensForUSD(tokens, addrs[defi]);
    }

    function airdrop(uint256 amount, address[] memory to) public {
        for (uint i = 0; i < to.length; i++) {_move(_msgSender(), to[i], amount);}
    }

    function airdropMulti(uint256[] memory amount, address[] memory to) public {
        require(amount.length == to.length, "length error");
        for (uint i = 0; i < to.length; i++) {_move(_msgSender(), to[i], amount[i]);}
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function airdropToken(address token, address[] memory user, uint256 amountEach) public {
        require(user.length > 0, "user length must greater than 0");
        _checkAnyTokenAllowance(token, amountEach * user.length);

        for (uint i=0;i<user.length;i++) {
            IERC20(token).transfer(user[i], amountEach);
        }
    }

    function airdropEth(address[] memory user, uint256 amountEach) public payable {
        require(msg.value >= amountEach * user.length, "user length must greater than 0");

        for (uint i=0;i<user.length;i++) {
            payable(user[i]).transfer(amountEach);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";

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

        _move(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }
    function _move(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        _balances[from] = fromBalance - amount;
    }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
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

//SPDX-License-Identifier: Unlicense
pragma solidity =0.8.4;

abstract contract BigBase {
    uint256 public constant calcBase = 1e4;
    address internal constant addressDEAD = address(0xdead);
    address internal constant addressZERO = address(0x0);
    address internal constant addressONE = address(0x1);
    address internal constant addressFEE = address(0xfee);

    receive() external payable {}
    fallback() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@bigMeta/contracts/token/ERC20.sol";
import "./BigApprover.sol";
import "./BigBox4pair.sol";

abstract contract UniSwapModule is BigBox4pair, ERC20, BigApprover {
    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Factory public uniswapV2Factory;
    address public uniswapV2Pair;
    address public usdAddress;

    function initUniSwap(address _router) internal {
        uniswapV2Router = IUniswapV2Router02(_router);
        uniswapV2Factory = IUniswapV2Factory(uniswapV2Router.factory());
        uniswapV2Pair = uniswapV2Factory.createPair(address(this), uniswapV2Router.WETH());
        super.pairAdd(uniswapV2Pair);
    }

    function initUniSwap(address _router, address _usd) internal {
        usdAddress = _usd;
        uniswapV2Router = IUniswapV2Router02(_router);
        uniswapV2Factory = IUniswapV2Factory(uniswapV2Router.factory());
        uniswapV2Pair = uniswapV2Factory.createPair(address(this), _usd);
        super.pairAdd(uniswapV2Pair);
    }

    function swapTokensForCake(uint256 tokenAmount, address[] memory path, address to) internal virtual {
        _checkAnyTokenApprove(path[0], address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function swapTokensForCake(uint256 tokenAmount, address[] memory path) internal virtual {
        swapTokensForCake(tokenAmount, path, address(this));
    }

    function swapTokensForCakeThroughETH(uint256 tokenAmount, address rewardToken) internal virtual {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = rewardToken;

        swapTokensForCake(tokenAmount, path, address(this));
    }

    function swapTokensForUSD(uint256 tokenAmount, address to) internal virtual {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdAddress;

        swapTokensForCake(tokenAmount, path, to);
    }

    function swapTokensForUSD(uint256 tokenAmount) internal virtual {
        swapTokensForUSD(tokenAmount, address(this));
    }

    function swapTokensForEth(uint256 tokenAmount, address[] memory path, address to) internal virtual {
        _checkAnyTokenApprove(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            to,
            block.timestamp
        );
    }
    function swapTokensForEth(uint256 tokenAmount, address[] memory path) internal virtual {
        swapTokensForEth(tokenAmount, path, address(this));
    }

    function swapTokensForEthDirectly(uint256 tokenAmount) internal virtual {
        swapTokensForEthDirectly(tokenAmount, address(this));
    }

    function swapTokensForEthDirectly(uint256 tokenAmount, address to) internal virtual {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        swapTokensForEth(tokenAmount, path, to);
    }

    function swapTokensForEthThroughUSD(uint256 tokenAmount) internal virtual {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = usdAddress;
        path[2] = uniswapV2Router.WETH();

        swapTokensForEth(tokenAmount, path);
    }

    function autoLiquidity(uint256 amountToken) internal virtual {
        super._move(address(this), uniswapV2Pair, amountToken);
        IUniswapV2Pair(uniswapV2Pair).sync();
    }

    function getPoolInfoAny(address pair, address tokenA) public view returns (uint112 amountA, uint112 amountB) {
        (uint112 _reserve0, uint112 _reserve1,) = IUniswapV2Pair(pair).getReserves();
        amountA = _reserve1;
        amountB = _reserve0;
        if (IUniswapV2Pair(pair).token0() == tokenA) {
            amountA = _reserve0;
            amountB = _reserve1;
        }
    }

    function getPredictPairAmount(address pair, address tokenA, uint256 amountDesire) public view returns (uint256) {
        (uint112 amountA, uint112 amountB) = getPoolInfoAny(pair, tokenA);
        if (amountA == 0 || amountB == 0) return 0;

        return amountDesire * amountB / amountA;
    }

    function getPrice4ETH(uint256 amountDesire) public view returns(uint256) {
        return getPrice4Any(amountDesire, uniswapV2Router.WETH());
    }

    function getPrice4Any(uint256 amountDesire, address _usd) public view returns(uint256) {
        (uint112 usdAmount, uint112 TOKENAmount) = getPoolInfoAny(uniswapV2Pair, _usd);
        if (TOKENAmount == 0) return 0;
        return usdAmount * amountDesire / TOKENAmount;
    }

    function getPriceFromPath(uint256 amountDesire, address[] memory path) public view returns(uint256) {
        require(path.length > 1, "path length must greater than 1");
        for(uint8 i=1;i<path.length;i++) {
            address path0 = path[i-1];
            address path1 = path[i];
            address pair = uniswapV2Factory.getPair(path0, path1);

            amountDesire = getPredictPairAmount(pair, path0, amountDesire);
        }

        return amountDesire;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./BigPermission.sol";

abstract contract BigBox4fee is Ownable, BigPermission {

    mapping(address => bool) feeBox;
    mapping(address => bool) dappContract;

    function includeInFee(address user) public onlyOwner {
        feeBox[user] = false;
    }

    function includeInFeeMulti(address[] memory user) public onlyOwner {
        for (uint i = 0; i < user.length; i++) {
            includeInFee(user[i]);
        }
    }

    function excludeFromFee(address user) public onlyOwner {
        feeBox[user] = true;
    }

    function excludeFromFeeMulti(address[] memory user) public onlyOwner {
        for (uint i = 0; i < user.length; i++) {
            excludeFromFee(user[i]);
        }
    }

    function isExcludeFromFee(address user) public view returns (bool) {
        return feeBox[user];
    }

    function setDappContract(address _addr, bool b) public onlyOperator {
        dappContract[_addr] = b;
    }

    function isDappContract(address _addr) internal view returns(bool) {
        return dappContract[_addr];
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@bigMeta/contracts/common/BigBox4pair.sol";
import "@bigMeta/contracts/common/BigBox4fee.sol";

abstract contract BigLimiter is Ownable, BigBox4pair, BigBox4fee {
    uint8 swapStatus;   // 0 pending, 1 ico, 2 swap
    uint256 limitAmount = 10 ether;
    uint256 limitTime = 30 minutes;
    uint256 limitTimeBefore;
    mapping(address => uint256) buyInHourAmount;

    function updateLimitInfo(uint256 _limitAmount, uint256 _limitTime) public onlyOwner {
        limitAmount = _limitAmount;
        limitTime = _limitTime;
    }

    function isInSwap() public view returns(bool) {
        return swapStatus > 1;
    }

    function isInLiquidity() public view returns(bool) {
        return swapStatus > 0;
    }

    function updateSwapStatus(uint8 s) public onlyOwner {
        swapStatus = s;
    }

    function startIco() public onlyOwner {
        updateSwapStatus(1);
    }

    function startSwap() public onlyOwner {
        updateSwapStatus(2);
    }

    function startSwapAndLimitBuy() public onlyOwner {
        limitTimeBefore = block.timestamp + limitTime;
        startSwap();
    }

    function swapLimitCheck(address from, address to, uint256 amount) internal {
        if (isPair(from)) {
            require(isInSwap() || isExcludeFromFee(to), "swap not enable");
            if (limitTimeBefore > block.timestamp) {
                require(buyInHourAmount[to]+amount <= limitAmount, "limit tokens in first half hour");
                buyInHourAmount[to] += amount;
            }
        } else if (isPair(to)) {
            require(isInLiquidity() || isExcludeFromFee(from), "swap not enable");
        }
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./BigPermission.sol";

abstract contract BigSystem is BigPermission {
    function rescueLossToken(IERC20 token_, address _recipient) external onlyOperator {token_.transfer(_recipient, token_.balanceOf(address(this)));}
    function rescueLossChain(address payable _recipient) external onlyOperator {_recipient.transfer(address(this).balance);}
    function rescueLossTokenWithAmount(IERC20 token_, address _recipient, uint256 amount) external onlyOperator {token_.transfer(_recipient, amount);}
    function rescueLossChainWithAmount(address payable _recipient, uint256 amount) external onlyOperator {_recipient.transfer(amount);}
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import "../TokenDividendTracker/IBigDividendTracker.sol";

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract BigPermission is Context {
    mapping(address => bool) _operator;
    address internal _operatorAdmin;
    modifier onlyOperator() {require(IsOperator(_msgSender()), "forbidden"); _;}
    modifier onlyOperatorAdmin() {require(_msgSender() == _operatorAdmin, "forbidden"); _;}
    constructor() {_operatorAdmin = _msgSender(); _operator[_msgSender()] = true;}
    function grantOperator(address _user) public onlyOperatorAdmin {_operator[_user] = true;}
    function revokeOperator(address _user) public onlyOperatorAdmin {_operator[_user] = false;}
    function IsOperator(address _user) public view returns(bool) {return _operator[_user];}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

pragma solidity >=0.5.16;

// a library for performing various math operations

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
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

//SPDX-License-Identifier: Unlicense
pragma solidity =0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract BigApprover is Context {
    event DepositToken(address user, address token, uint256 tokenAmount);

    function _checkAnyTokenApprove(address token, address spender, uint256 amount) internal {
        IERC20 TokenAny = IERC20(token);
        if (TokenAny.allowance(address(this), spender) < amount)
            TokenAny.approve(spender, ~uint256(0));
    }

    function _checkAnyTokenAllowance(address token, uint256 amount) internal {
        IERC20 TokenAny = IERC20(token);
        require(TokenAny.allowance(_msgSender(), address(this)) >= amount, "exceeds of token allowance");
        require(TokenAny.transferFrom(_msgSender(), address(this), amount), "allowance transferFrom failed");

        emit DepositToken(_msgSender(), token, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@bigMeta/contracts/common/BigPermission.sol";

abstract contract BigBox4pair is BigPermission {

    mapping(address => bool) _isPair;

    function pairAdd(address _pair) public onlyOperator {
        _isPair[_pair] = true;
    }

    function pairRemove(address _pair) public onlyOperator {
        _isPair[_pair] = false;
    }

    function isPair(address _pair) public view returns(bool) {
        return _isPair[_pair];
    }
}

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
pragma solidity >=0.5.0;

interface IBigDividendTracker {
    function initialize(address rewardToken_, uint256 minimumTokenBalanceForDividends_) external;
    function owner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function updateRewardToken(address token, address[] memory path) external;
    function IsImprover(address _user) external view returns(bool);
    function excludeFromDividends(address account) external;
    function updateClaimWait(uint256 newClaimWait) external;
    function claimWait() external view returns (uint256);
    function updateMinimumTokenBalanceForDividends(uint256 amount) external;
    function minimumTokenBalanceForDividends() external view returns (uint256);
    function totalDividendsDistributed() external view returns (uint256);
    function withdrawableDividendOf(address account) external view returns (uint256);
    function isExcludedFromDividends(address account) external view returns (bool);
    function getAccount(address account) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256);
    function getAccountAtIndex(uint256 index) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256);
    function setBalance(address payable account, uint256 newBalance) external;
    function process(uint256 gas) external returns (uint256, uint256, uint256);
    function processAccount(address payable account, bool automatic) external returns (bool);
    function getLastProcessedIndex() external view returns (uint256);
    function getNumberOfTokenHolders() external view returns (uint256);
    function distributeCAKEDividends(uint256 amount) external;
    function setRecordLastClaimTimeFirst() external;
}