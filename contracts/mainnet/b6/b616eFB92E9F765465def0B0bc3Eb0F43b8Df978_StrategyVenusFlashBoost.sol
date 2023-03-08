// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "../tokens/ERC20.sol";
import "../utils/SafeERC20.sol";
import "../utils/SafeMath.sol";
import "../interfaces/IVenusProtocol.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IUniswapV2Router.sol";
import "./StrategyBase.sol";

contract StrategyVenusFlashBoost is StrategyBase {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    address allowedPairAddress = address(1);

    address public vtoken;
    address public want;
    address public borrowPool;
    
    address constant public rewardToken = address(0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63);
    address constant public wrappedNative = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address constant public unitroller = address(0xfD36E2c2a6789Db23113685031d7F16329158384);
    address constant public router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address[] public rewardToWantPath;
    address[] public rewardToWrappedNativePath = [rewardToken, wrappedNative];
    address[] public markets;

    uint256 public depositedBalance;
    uint256 public suppliedBalance;
    uint256 public borrowBasis;

     constructor (
        address newVtoken,
        address newBorrowPool,
        uint256 newBorrowBasis,
        address newManager,
        address newVault,
        address newStrategist,
        address[] memory newMarkets
    ) StrategyBase(newManager, newVault, newStrategist) {
        vtoken = newVtoken;
        want = IVenusToken(vtoken).underlying();
        borrowPool = newBorrowPool;
        borrowBasis = newBorrowBasis;
        markets = newMarkets;
        rewardToWantPath = [rewardToken, wrappedNative, want];
        _giveAllowances();
    }

    struct CallbackData {
        bool minting;
        address pool;
        address vToken;
        address borrowedToken;
        uint256 amount;
    }

    fallback() external {
        (address sender, 
         uint256 amount0, 
         uint256 amount1, 
         bytes memory data) = abi.decode(msg.data[4:], 
            (address, 
             uint256, 
             uint256, 
             bytes));
        _callback(sender, amount0, amount1, data);
    }

    function _callback(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes memory data
    ) internal {
        require(msg.sender == allowedPairAddress, "Not an allowed address");
        require(sender == address(this), "Not from this contract");
        CallbackData memory details = abi.decode(data, (CallbackData));
        uint256 borrowedAmount = amount0 > 0 ? amount0 : amount1;
        uint256 fee = ((borrowedAmount * 3) / 997) + 1;
        uint256 repayAmount = borrowedAmount + fee;
        uint256 mintOrRedeemAmount = borrowedAmount + details.amount - fee;
        if (details.minting) {
            IVenusToken(details.vToken).mint(mintOrRedeemAmount);
            IVenusToken(details.vToken).borrow(borrowedAmount);
        } else {
            IVenusToken(details.vToken).repayBorrow(borrowedAmount);
            IVenusToken(details.vToken).redeemUnderlying(mintOrRedeemAmount);
        }
        IERC20(details.borrowedToken).safeTransfer(details.pool, repayAmount);
        allowedPairAddress = address(1);
    }

    function _doFlashSwap(
        bool minting,
        address pool, 
        address vToken, 
        address borrowedToken, 
        uint256 borrowAmount, 
        uint256 amount) internal {
            allowedPairAddress = pool;
            CallbackData memory callbackData;
            callbackData.minting = minting;
            callbackData.pool = pool;
            callbackData.vToken = vToken;
            callbackData.borrowedToken = borrowedToken;
            callbackData.amount = amount;
            bytes memory flash = abi.encode(callbackData);
            uint256 amount0Out = borrowedToken == IUniswapV2Pair(pool).token0() ? borrowAmount : 0;
            uint256 amount1Out = borrowedToken == IUniswapV2Pair(pool).token1() ? borrowAmount : 0;
            IUniswapV2Pair(pool).swap(
                amount0Out,
                amount1Out,
                address(this),
                flash
            );
    }

    function deposit() public whenNotPaused {
        uint256 wantBal = availableWant();
        if (wantBal > 0) {
            uint256 borrowAmount = wantBal.mul(borrowBasis).div(DIVISOR);
            _doFlashSwap(true, borrowPool, vtoken, want, borrowAmount, wantBal);
            updateBalance();
        }
    }

    function harvest() external whenNotPaused {
        _claimRewardsAndPayFees(); 
        uint256 rewardBal = IERC20(rewardToken).balanceOf(address(this));
        IUniswapV2Router01(router).swapExactTokensForTokens(
            rewardBal,
            0,
            rewardToWantPath,
            address(this),
            block.timestamp
        );      
        deposit();
    }

    function withdraw(uint256 amount) external {
        require(msg.sender == vault, "not vault");
        uint256 wantBal = availableWant();
        if (wantBal < amount) {
            uint256 borrowAmount = amount.mul(borrowBasis).div(DIVISOR);
            _doFlashSwap(false, borrowPool, vtoken, want, borrowAmount, amount);
            wantBal = IERC20(want).balanceOf(address(this));
        }
        if (wantBal > amount) {
            wantBal = amount;
        }
        IERC20(want).safeTransfer(vault, wantBal);
        updateBalance();
    }
    
    function balanceOf() public view returns (uint256) {
        return availableWant().add(depositedBalance);
    }

    function updateBalance() public {
        uint256 supplyBal = IVenusToken(vtoken).balanceOfUnderlying(address(this));
        uint256 borrowBal = IVenusToken(vtoken).borrowBalanceStored(address(this));
        suppliedBalance = supplyBal;
        depositedBalance = supplyBal.sub(borrowBal);
    }

    function supply(uint256 amount) public onlyManager {
        IVenusToken(vtoken).mint(amount);
    }

    function redeem(uint256 shares) public onlyManager {
        IVenusToken(vtoken).redeem(shares);
    }

    function redeemUnderlying(uint256 amount) public onlyManager {
        IVenusToken(vtoken).redeemUnderlying(amount);
    }

    function borrow(uint256 amount) public onlyManager {
        IVenusToken(vtoken).borrow(amount);
    }

    function repayBorrow(uint256 amount) public onlyManager {
        IVenusToken(vtoken).repayBorrow(amount);
    }
    
    /**
     * @return how much {want} the hontract holds
     */
     function availableWant() public view returns (uint256) {
         return IERC20(want).balanceOf(address(this));
     }

     function retireStrategy() external {
        require(msg.sender == vault, "Not vault");
        panic();
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            IERC20(want).safeTransfer(vault, wantBal);
        }
        uint256 nativeBal = IERC20(wrappedNative).balanceOf(address(this));
        if (nativeBal > 0) {
            IERC20(wrappedNative).safeTransfer(strategist, nativeBal);
        }
        IVenusUnitroller(unitroller).exitMarket(vtoken);
    }

    // pauses deposits and withdraws all funds from third party systems.
    function panic() public onlyManager {
        pause();
        uint256 supplyBal = IVenusToken(vtoken).balanceOfUnderlying(address(this));
        uint256 borrowBal = IVenusToken(vtoken).borrowBalanceStored(address(this));
        _doFlashSwap(false, borrowPool, vtoken, want, borrowBal, supplyBal);
        _claimRewardsAndPayFees();
    }

    function pause() public onlyManager {
        _pause();
        _removeAllowances();
    }

    function unpause() external onlyManager {
        _unpause();
        _giveAllowances();
        deposit();
    }

    function setBorrowBasis(uint256 newBorrowBasis) external onlyOwner {
        borrowBasis = newBorrowBasis;
    }

    function migrateTokens(address[] memory tokens, address newContract) public onlyOwner {
        for (uint256 i=0;i<tokens.length;i++) {
            uint256 balance = IERC20(tokens[i]).balanceOf(address(this));
            IERC20(tokens[i]).transfer(newContract, balance);
        }
    }

    function _claimRewardsAndPayFees() internal {
        IVenusUnitroller(unitroller).claimVenus(address(this), markets);
        uint256 toNativeBal = IERC20(rewardToken).balanceOf(address(this)).mul(strategistFee + keeperFee).div(DIVISOR);
        IUniswapV2Router01(router).swapExactTokensForTokens(
            toNativeBal,
            0,
            rewardToWrappedNativePath,
            address(this),
            block.timestamp
        );
        uint256 nativeBal = IERC20(wrappedNative).balanceOf(address(this));
        uint256 keeperAmount = nativeBal.mul(keeperFee).div(DIVISOR);
        IERC20(wrappedNative).safeTransfer(tx.origin, keeperAmount);
        uint256 strategistAmount = IERC20(wrappedNative).balanceOf(address(this));
        IERC20(wrappedNative).safeTransfer(strategist, strategistAmount);
    }

    function _giveAllowances() internal {
        IVenusUnitroller(unitroller).enterMarkets(markets);
        IERC20(want).safeApprove(vtoken, type(uint256).max);
        IERC20(rewardToken).safeApprove(router, type(uint256).max);
    }

    function _removeAllowances() internal {
        IERC20(want).safeApprove(vtoken, 0);
        IERC20(rewardToken).safeApprove(router, 0);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "../interfaces/IERC20.sol";
import "../interfaces/IERC20Metadata.sol";
import "../utils/Context.sol";

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import "../interfaces/IERC20Permit.sol";
import "../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: GPLv3

pragma solidity ^0.8.6;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IVenusToken {
    function underlying() external returns (address);
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function balanceOfUnderlying(address owner) external returns (uint);
    function borrowBalanceStored(address account) external returns (uint);
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);
    function comptroller() external returns (address);
}

interface IVenusUnitroller {
    function claimVenus(address holder, address[] memory vTokens) external;
    function enterMarkets(address[] memory vTokens) external;
    function exitMarket(address vToken) external;
    function getAssetsIn(address account) view external returns (address[] memory);
    function getAccountLiquidity(address account) view external returns (uint, uint, uint);
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IUniswapV2Pair {
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

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "../utils/Ownable.sol";
import "../utils/Pausable.sol";

contract StrategyBase is Ownable, Pausable {
    address public manager;
    address public vault;
    address public strategist;

    uint256 public constant DIVISOR = 1000;
    uint256 public strategistFee = 100;
    uint256 public keeperFee = 100;

    constructor(
        address newManager,
        address newVault,
        address newStrategist
    ) {
        manager = newManager;
        vault = newVault;
        strategist = newStrategist;
    }

    // checks that caller is either owner or manager.
    modifier onlyManager() {
        require(msg.sender == owner() || msg.sender == manager, "Only Manager or Owner");
        _;
    }

    /**
     * @dev Updates address of the strat manager.
     * @param newManager new manager address.
     */
    function setManager(address newManager) external onlyManager {
        manager = newManager;
    }

    /**
     * @dev Updates parent vault.
     * @param newVault new vault address.
     */
    function setVault(address newVault) external onlyOwner {
        vault = newVault;
    }

    /**
     * @dev Updates Strategist.
     * @param newStrategist new strategist address.
     */
    function setStrategist(address newStrategist) external onlyOwner {
        strategist = newStrategist;
    }

    /**
     * @dev Updates Strategist Fee.
     * @param newStrategistFee new strategist address.
     */
    function setStrategistFee(uint256 newStrategistFee) external onlyOwner {
        strategistFee = newStrategistFee;
    }

    /**
     * @dev Function to synchronize balances before new user deposit.
     * Can be overridden in the strategy.
     */
    function beforeDeposit() external virtual {}
}

// SPDX-License-Identifier: GPLv3

pragma solidity ^0.8.6;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./IERC20.sol";

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Context.sol";

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);
    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }
    modifier whenPaused() {
        _requirePaused();
        _;
    }
    function paused() public view virtual returns (bool) {
        return _paused;
    }
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}