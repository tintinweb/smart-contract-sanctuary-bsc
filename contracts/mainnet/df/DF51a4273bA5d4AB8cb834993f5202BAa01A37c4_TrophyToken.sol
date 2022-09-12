// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPancakeRouter {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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

    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract TrophyToken is ERC20, Ownable {
    uint256 public constant PRECISION_RATE = 100000; // e.g. 5000 = 5%

    mapping(address => bool) public feeTos;
    address[] public feeToList;
    mapping(address => uint256) public feePercents;

    mapping(address => bool) public excludedFromFee;
    address[] public excludedFromFeeList;

    uint256 public burnFeePercent;
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    uint256 public liquidifyPercent;
    address public lpTo;

    // support for other pools
    mapping(address => bool) public pairs;
    // pair => router
    mapping(address => IPancakeRouter) public routers;

    // anti-bot mechanism, these addresses have privilege to buy before any sniper bots out there
    bool public whitelistedEnabled;
    mapping(address => bool) public whitelisteds;
    address[] public whitelistedList;

    receive() external payable {}

    constructor(
        address _router,
        address _lpTo,
        uint256 _liquidifyPercent,
        uint256 _burnFeePercent,
        address[] memory _feeTos,
        uint256[] memory _feePercents
    ) ERC20("Trophy Token", "TRT") {
        IPancakeRouter router = IPancakeRouter(_router);

        // Create a pancakeswap pair for this new token
        address pair = IPancakeFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );

        addPair(pair, _router);
        liquidifyPercent = _liquidifyPercent;
        lpTo = _lpTo;

        burnFeePercent = _burnFeePercent;

        for (uint256 i = 0; i < _feeTos.length; i++) {
            addFeeTo(_feeTos[i], _feePercents[i]);
        }

        addExcludedFromFee(msg.sender);
        addExcludedFromFee(address(this));

        setWhitelistedEnabled(true);
    }

    function addPair(address _pair, address _router) public onlyOwner {
        pairs[_pair] = true;
        routers[_pair] = IPancakeRouter(_router);

        uint256 MAX_UINT = ~uint256(0);
        _approve(address(this), address(_router), MAX_UINT);
    }

    function removePair(address _pair) public onlyOwner {
        pairs[_pair] = false;
    }

    function addFeeTo(address _feeTo, uint256 _feePercent) public onlyOwner {
        require(feeToList.length < 3, "TRT: reached max number of feeTos");
        require(!feeTos[_feeTo], "TRT: feeTo already added");
        payable(_feeTo).transfer(0); // check if address can receive eth
        feeTos[_feeTo] = true;
        feeToList.push(_feeTo);
        feePercents[_feeTo] = _feePercent;
    }

    function removeFeeTo(address _feeTo) public onlyOwner {
        require(feeTos[_feeTo], "TRT: feeTo not added");

        for (uint256 i = 0; i < feeToList.length; i++) {
            if (feeToList[i] == _feeTo) {
                feeToList[i] = feeToList[feeToList.length - 1];
                feeToList.pop();

                feeTos[_feeTo] = false;
                break;
            }
        }
    }

    function getFeeToList() public view returns (address[] memory) {
        return feeToList;
    }

    function addExcludedFromFee(address _account) public onlyOwner {
        require(!excludedFromFee[_account], "TRT: account already excluded");
        excludedFromFee[_account] = true;
        excludedFromFeeList.push(_account);
    }

    function removeExcludedFromFee(address _account) public onlyOwner {
        require(excludedFromFee[_account], "TRT: account not excluded");

        for (uint256 i = 0; i < excludedFromFeeList.length; i++) {
            if (excludedFromFeeList[i] == _account) {
                excludedFromFeeList[i] = excludedFromFeeList[
                    excludedFromFeeList.length - 1
                ];
                excludedFromFeeList.pop();

                excludedFromFee[_account] = false;
                break;
            }
        }
    }

    function getExcludedFromFeeList() public view returns (address[] memory) {
        return excludedFromFeeList;
    }

    function setWhitelistedEnabled(bool _enabled) public onlyOwner {
        whitelistedEnabled = _enabled;
    }

    function addWhitelistedMany(address[] memory _bots) public onlyOwner {
        for (uint256 i = 0; i < _bots.length; i++) {
            addWhitelistedAddress(_bots[i]);
        }
    }

    function addWhitelistedAddress(address _bot) public onlyOwner {
        require(!whitelisteds[_bot], "TRT: bot already added");
        whitelisteds[_bot] = true;
        whitelistedList.push(_bot);
    }

    function removeWhitelistedAddress(address _bot) public onlyOwner {
        require(whitelisteds[_bot], "TRT: bot not added");

        for (uint256 i = 0; i < whitelistedList.length; i++) {
            if (whitelistedList[i] == _bot) {
                whitelistedList[i] = whitelistedList[whitelistedList.length - 1];
                whitelistedList.pop();

                whitelisteds[_bot] = false;
                break;
            }
        }
    }

    function getWhitelistedList() public view returns (address[] memory) {
        return whitelistedList;
    }

    function addLiquidity(
        address pair,
        uint256 tokenAmount,
        uint256 ethAmount
    ) private {
        routers[pair].addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            lpTo,
            block.timestamp
        );
    }

    function swapTokensForEth(address _pair, uint256 _tokenAmount) private {
        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = routers[_pair].WETH();

        // make the swap
        routers[_pair].swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    //
    function calcTotalFeeToPercent() public view returns (uint256) {
        uint256 totalFeePercent = 0;
        for (uint256 i = 0; i < feeToList.length; i++) {
            totalFeePercent = totalFeePercent + feePercents[feeToList[i]];
        }
        return totalFeePercent;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override {        
        // only whitelisted bots can make buy transaction when whitelistedEnabled
        if (whitelistedEnabled && pairs[_from]) {
            require(whitelisteds[_to], "TRT: only whitelisted addresses can buy at this time");
        }

        // safety check for the very unlikely case
        // that someday someone figures out the private key of the burn address
        require(_from != BURN_ADDRESS, "BURN_ADDRESS can't transfer!");

        uint256 totalFeeAmount;
        if (
            pairs[_to] && !excludedFromFee[_from] // transfer to the pancakeswap pair, could be sell or add liquidity transaction // not excluded from fee
        ) {
            address pair = _to;
            uint256 totalFeeToPercent = calcTotalFeeToPercent();
            uint256 totalFeeToAmount = _amount * totalFeeToPercent /
                PRECISION_RATE;

            uint256 totalFeePercent = totalFeeToPercent +
                burnFeePercent +
                liquidifyPercent;
            totalFeeAmount = _amount * totalFeePercent / PRECISION_RATE;

            // scope to avoid stack too deep errors
            {
                uint256 burnFeeAmount = _amount * burnFeePercent /
                    PRECISION_RATE;
                super._transfer(
                    _from,
                    address(this),
                    totalFeeAmount - burnFeeAmount
                );
                super._transfer(_from, BURN_ADDRESS, burnFeeAmount);
            }

            uint256 halfLiquidifyPercent = liquidifyPercent / 2;
            uint256 halfLiquidifyAmount = _amount * halfLiquidifyPercent /
                PRECISION_RATE;

            uint256 otherHalfLiquidifyPercent = liquidifyPercent -
                halfLiquidifyPercent;
            uint256 otherHalfLiquidifyAmount = _amount *
                otherHalfLiquidifyPercent / PRECISION_RATE;

            uint256 tokenAmountForSwap = totalFeeToAmount + halfLiquidifyAmount;
            uint256 initialEth = address(this).balance;
            swapTokensForEth(pair, tokenAmountForSwap);
            uint256 gainedEth = address(this).balance - initialEth;
            uint256 ethForLiquidify = gainedEth * halfLiquidifyPercent /
                (totalFeeToPercent + halfLiquidifyPercent);
            addLiquidity(pair, otherHalfLiquidifyAmount, ethForLiquidify);
            uint256 gainedEthForFeeTos = gainedEth - ethForLiquidify;
            // distribute fee to feeToList
            uint256 distributeSoFar = 0;
            for (uint256 i = 0; i < feeToList.length; i++) {
                if (i == feeToList.length - 1) {
                    payable(feeToList[i]).transfer(
                        gainedEthForFeeTos - distributeSoFar
                    );
                } else {
                    uint256 transferAmount = gainedEthForFeeTos *
                        feePercents[feeToList[i]] / totalFeeToPercent;
                    payable(feeToList[i]).transfer(transferAmount);
                    distributeSoFar = distributeSoFar + transferAmount;
                }
            }
        }
        super._transfer(_from, _to, _amount - totalFeeAmount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }

    function getEthBalance() public view returns (uint256) {
        return payable(address(this)).balance;
    }

    // collect any leftover dust from the contract
    function collectEthDust(address _to) public onlyOwner {
        uint256 ethDust = getEthBalance();
        payable(_to).transfer(ethDust);
    }

    function collectTokenDust(address _token, address _to) public onlyOwner {
        uint256 tokenDust = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(_to, tokenDust);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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