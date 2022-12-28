/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

/*

Website: https://ethersystem.tech/
Telegram: https://t.me/EasyETHERofficial
Twitter: https://twitter.com/EasyETHERsystem

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

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

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
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

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}

interface IDEXRouter {
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
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

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

interface IDEXFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface DividendPayingTokenInterface {
    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf(
        address _owner,
        address _rewardToken
    ) external view returns (uint256);

    /// @notice Distributes ether to token holders as dividends.
    /// @dev SHOULD distribute the paid ether to token holders as dividends.
    ///  SHOULD NOT directly transfer ether to token holders in this function.
    ///  MUST emit a `DividendsDistributed` event when the amount of distributed ether is greater than 0.
    function distributeDividends() external payable;

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev SHOULD transfer `dividendOf(msg.sender)` wei to `msg.sender`, and `dividendOf(msg.sender)` SHOULD be 0 after the transfer.
    ///  MUST emit a `DividendWithdrawn` event if the amount of ether transferred is greater than 0.
    function withdrawDividend(address _rewardToken) external;

    /// @dev This event MUST emit when ether is distributed to token holders.
    /// @param from The address which sends ether to this contract.
    /// @param weiAmount The amount of distributed ether in wei.
    event DividendsDistributed(address indexed from, uint256 weiAmount);

    /// @dev This event MUST emit when an address withdraws their dividend.
    /// @param to The address which withdraws ether from this contract.
    /// @param weiAmount The amount of withdrawn ether in wei.
    event DividendWithdrawn(address indexed to, uint256 weiAmount);
}

interface DividendPayingTokenOptionalInterface {
    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableDividendOf(
        address _owner,
        address _rewardToken
    ) external view returns (uint256);

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnDividendOf(
        address _owner,
        address _rewardToken
    ) external view returns (uint256);

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf(
        address _owner,
        address _rewardToken
    ) external view returns (uint256);
}

contract DividendPayingToken is
    DividendPayingTokenInterface,
    DividendPayingTokenOptionalInterface,
    Ownable
{
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    // With `magnitude`, we can properly distribute dividends even if the amount of received ether is small.
    // For more discussion about choosing the value of `magnitude`,
    //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
    uint256 internal constant magnitude = 2 ** 128;

    mapping(address => uint256) internal magnifiedDividendPerShare;
    address[] public rewardTokens;
    address public nextRewardToken;
    uint256 public rewardTokenCounter;

    IDEXRouter public uniswapV2Router;
    address public busdAddress;

    // About dividendCorrection:
    // If the token balance of a `_user` is never changed, the dividend of `_user` can be computed with:
    //   `dividendOf(_user) = dividendPerShare * balanceOf(_user)`.
    // When `balanceOf(_user)` is changed (via minting/burning/transferring tokens),
    //   `dividendOf(_user)` should not be changed,
    //   but the computed value of `dividendPerShare * balanceOf(_user)` is changed.
    // To keep the `dividendOf(_user)` unchanged, we add a correction term:
    //   `dividendOf(_user) = dividendPerShare * balanceOf(_user) + dividendCorrectionOf(_user)`,
    //   where `dividendCorrectionOf(_user)` is updated whenever `balanceOf(_user)` is changed:
    //   `dividendCorrectionOf(_user) = dividendPerShare * (old balanceOf(_user)) - (new balanceOf(_user))`.
    // So now `dividendOf(_user)` returns the same value before and after `balanceOf(_user)` is changed.
    mapping(address => mapping(address => int256))
        internal magnifiedDividendCorrections;
    mapping(address => mapping(address => uint256)) internal withdrawnDividends;

    mapping(address => uint256) public holderBalance;
    uint256 public totalBalance;

    mapping(address => uint256) public totalDividendsDistributed;

    event RewardTokensAdded(address newToken);
    event RewardTokensRemoved(address removedToken);

    constructor() {
        address pancakeSwapRouter;

        // CHANGE: router_testnet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1  | router_mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        if (block.chainid == 56) {
            pancakeSwapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        } else if (block.chainid == 97) {
            pancakeSwapRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        } else revert();

        IDEXRouter _uniswapV2Router = IDEXRouter(pancakeSwapRouter);
        uniswapV2Router = _uniswapV2Router;

        // Mainnet
        address tokenAddress;

        if (block.chainid == 56) {
            tokenAddress = 0x701aE643e39E3d884b11020bF5f86737Ff48c75e; //EtherealDoge
        }else revert();

        rewardTokens.push(address(tokenAddress)); // EtherealDoge - 0

        nextRewardToken = rewardTokens[0];
    }

    /// @dev Distributes dividends whenever ether is paid to this contract.
    receive() external payable {
        distributeDividends();
    }

    function viewRewardToken(uint256 index) public view returns (address) {
        require(index <= totalRewardsToken(), "No Token Found in this index");
        return rewardTokens[index];
    }

    function totalRewardsToken() public view returns (uint256) {
        return rewardTokens.length;
    }

    function addRewardsToken(address _token) external onlyOwner {
        bool alreadySet = findRewardsToken(_token);
        require(!alreadySet, "Token is already set as rewards");
        rewardTokens.push(_token);
        emit RewardTokensAdded(_token);
    }

    function findRewardsToken(address _token) internal view returns (bool) {
        bool inContract = false;
        for (uint256 i = 0; i < rewardTokens.length; i++) {
            if (rewardTokens[i] == _token) {
                inContract = true;
            }
        }
        return inContract;
    }

    function removeRewardToken(address _token) external onlyOwner {
        bool alreadySet = findRewardsToken(_token);
        require(alreadySet, "Token is not set as rewards");
        require(totalRewardsToken() > 1, "Cannot have 0 reward tokens");

        for (uint256 index = 0; index < rewardTokens.length; index++) {
            if (rewardTokens[index] == _token) {
                emit RewardTokensRemoved(rewardTokens[index]);
                rewardTokens[index] = rewardTokens[rewardTokens.length - 1];
                rewardTokens.pop();
            }
        }
    }

    /// @notice Distributes ether to token holders as dividends.
    /// @dev It reverts if the total supply of tokens is 0.
    /// It emits the `DividendsDistributed` event if the amount of received ether is greater than 0.
    /// About undistributed ether:
    ///   In each distribution, there is a small amount of ether not distributed,
    ///     the magnified amount of which is
    ///     `(msg.value * magnitude) % totalSupply()`.
    ///   With a well-chosen `magnitude`, the amount of undistributed ether
    ///     (de-magnified) in a distribution can be less than 1 wei.
    ///   We can actually keep track of the undistributed ether in a distribution
    ///     and try to distribute it in the next distribution,
    ///     but keeping track of such data on-chain costs much more than
    ///     the saved ether, so we don't do that.

    function distributeDividends() public payable override {
        require(totalBalance > 0);
        uint256 initialBalance = IERC20(nextRewardToken).balanceOf(
            address(this)
        );
        buyTokens(msg.value, nextRewardToken);
        uint256 newBalance = IERC20(nextRewardToken)
            .balanceOf(address(this))
            .sub(initialBalance);
        if (newBalance > 0) {
            magnifiedDividendPerShare[
                nextRewardToken
            ] = magnifiedDividendPerShare[nextRewardToken].add(
                (newBalance).mul(magnitude) / totalBalance
            );
            emit DividendsDistributed(msg.sender, newBalance);

            totalDividendsDistributed[
                nextRewardToken
            ] = totalDividendsDistributed[nextRewardToken].add(newBalance);
        }
        rewardTokenCounter = rewardTokenCounter == rewardTokens.length - 1
            ? 0
            : rewardTokenCounter + 1;
        nextRewardToken = rewardTokens[rewardTokenCounter];
    }

    // useful for buybacks or to reclaim any BNB on the contract in a way that helps holders.
    function buyTokens(uint256 bnbAmountInWei, address rewardToken) internal {
        // generate the uniswap pair path of weth -> eth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = rewardToken;

        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: bnbAmountInWei
        }(
            0, // accept any amount of Ethereum
            path,
            address(this),
            block.timestamp
        );
    }

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
    function withdrawDividend(address _rewardToken) external virtual override {
        _withdrawDividendOfUser(payable(msg.sender), _rewardToken);
    }

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
    function _withdrawDividendOfUser(
        address payable user,
        address _rewardToken
    ) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf(
            user,
            _rewardToken
        );
        if (_withdrawableDividend > 0) {
            withdrawnDividends[_rewardToken][user] = withdrawnDividends[user][
                _rewardToken
            ].add(_withdrawableDividend);
            emit DividendWithdrawn(user, _withdrawableDividend);
            IERC20(_rewardToken).transfer(user, _withdrawableDividend);
            return _withdrawableDividend;
        }

        return 0;
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf(
        address _owner,
        address _rewardToken
    ) external view override returns (uint256) {
        return withdrawableDividendOf(_owner, _rewardToken);
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableDividendOf(
        address _owner,
        address _rewardToken
    ) public view override returns (uint256) {
        return
            accumulativeDividendOf(_owner, _rewardToken).sub(
                withdrawnDividends[_rewardToken][_owner]
            );
    }

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnDividendOf(
        address _owner,
        address _rewardToken
    ) external view override returns (uint256) {
        return withdrawnDividends[_rewardToken][_owner];
    }

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    /// = (magnifiedDividendPerShare * balanceOf(_owner) + magnifiedDividendCorrections[_owner]) / magnitude
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf(
        address _owner,
        address _rewardToken
    ) public view override returns (uint256) {
        return
            magnifiedDividendPerShare[_rewardToken]
                .mul(holderBalance[_owner])
                .toInt256Safe()
                .add(magnifiedDividendCorrections[_rewardToken][_owner])
                .toUint256Safe() / magnitude;
    }

    /// @dev Internal function that increases tokens to an account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account that will receive the created tokens.
    /// @param value The amount that will be created.
    function _increase(address account, uint256 value) internal {
        for (uint256 i; i < rewardTokens.length; i++) {
            magnifiedDividendCorrections[rewardTokens[i]][
                account
            ] = magnifiedDividendCorrections[rewardTokens[i]][account].sub(
                (magnifiedDividendPerShare[rewardTokens[i]].mul(value))
                    .toInt256Safe()
            );
        }
    }

    /// @dev Internal function that reduces an amount of the token of a given account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account whose tokens will be burnt.
    /// @param value The amount that will be burnt.
    function _reduce(address account, uint256 value) internal {
        for (uint256 i; i < rewardTokens.length; i++) {
            magnifiedDividendCorrections[rewardTokens[i]][
                account
            ] = magnifiedDividendCorrections[rewardTokens[i]][account].add(
                (magnifiedDividendPerShare[rewardTokens[i]].mul(value))
                    .toInt256Safe()
            );
        }
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = holderBalance[account];
        holderBalance[account] = newBalance;
        if (newBalance > currentBalance) {
            uint256 increaseAmount = newBalance.sub(currentBalance);
            _increase(account, increaseAmount);
            totalBalance += increaseAmount;
        } else if (newBalance < currentBalance) {
            uint256 reduceAmount = currentBalance.sub(newBalance);
            _reduce(account, reduceAmount);
            totalBalance -= reduceAmount;
        }
    }
}

contract DividendTracker is DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(address key) private view returns (uint256) {
        return tokenHoldersMap.values[key];
    }

    function getIndexOfKey(address key) private view returns (int256) {
        if (!tokenHoldersMap.inserted[key]) {
            return -1;
        }
        return int256(tokenHoldersMap.indexOf[key]);
    }

    function getKeyAtIndex(uint256 index) private view returns (address) {
        return tokenHoldersMap.keys[index];
    }

    function size() private view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function set(address key, uint256 val) private {
        if (tokenHoldersMap.inserted[key]) {
            tokenHoldersMap.values[key] = val;
        } else {
            tokenHoldersMap.inserted[key] = true;
            tokenHoldersMap.values[key] = val;
            tokenHoldersMap.indexOf[key] = tokenHoldersMap.keys.length;
            tokenHoldersMap.keys.push(key);
        }
    }

    function remove(address key) private {
        if (!tokenHoldersMap.inserted[key]) {
            return;
        }

        delete tokenHoldersMap.inserted[key];
        delete tokenHoldersMap.values[key];

        uint256 index = tokenHoldersMap.indexOf[key];
        uint256 lastIndex = tokenHoldersMap.keys.length - 1;
        address lastKey = tokenHoldersMap.keys[lastIndex];

        tokenHoldersMap.indexOf[lastKey] = index;
        delete tokenHoldersMap.indexOf[key];

        tokenHoldersMap.keys[index] = lastKey;
        tokenHoldersMap.keys.pop();
    }

    Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping(address => bool) public excludedFromDividends;

    mapping(address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event IncludeInDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(
        address indexed account,
        uint256 amount,
        bool indexed automatic
    );

    constructor() {
        claimWait = 1 hours;
        minimumTokenBalanceForDividends = 1000 * 1e9; //must hold 1000 tokens to receive dividends
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(
            newClaimWait >= 1 hours && newClaimWait <= 24 hours,
            "Dividend_Tracker: claimWait must be updated to between 1 hours and 24 hours"
        );
        require(
            newClaimWait != claimWait,
            "Dividend_Tracker: Cannot update claimWait to same value"
        );
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function excludeFromDividends(address account) external onlyOwner {
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        remove(account);

        emit ExcludeFromDividends(account);
    }

    function includeInDividends(address account) external onlyOwner {
        require(excludedFromDividends[account]);
        excludedFromDividends[account] = false;

        emit IncludeInDividends(account);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(
        address _account,
        address _rewardToken
    )
        public
        view
        returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable
        )
    {
        account = _account;

        index = getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(
                    int256(lastProcessedIndex)
                );
            } else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length >
                    lastProcessedIndex
                    ? tokenHoldersMap.keys.length.sub(lastProcessedIndex)
                    : 0;

                iterationsUntilProcessed = index.add(
                    int256(processesUntilEndOfArray)
                );
            }
        }

        withdrawableDividends = withdrawableDividendOf(account, _rewardToken);
        totalDividends = accumulativeDividendOf(account, _rewardToken);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp
            ? nextClaimTime.sub(block.timestamp)
            : 0;
    }

    function getAccountAtIndex(
        uint256 index,
        address _rewardToken
    )
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (index >= size()) {
            return (
                0x0000000000000000000000000000000000000000,
                -1,
                -1,
                0,
                0,
                0,
                0,
                0
            );
        }

        address account = getKeyAtIndex(index);

        return getAccount(account, _rewardToken);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp) {
            return false;
        }

        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(
        address payable account,
        uint256 newBalance
    ) external onlyOwner {
        if (excludedFromDividends[account]) {
            return;
        }

        if (newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            set(account, newBalance);
        } else {
            _setBalance(account, 0);
            remove(account);
        }

        processAccount(account, true);
    }

    function process(uint256 gas) external returns (uint256, uint256, uint256) {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if (numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if (canAutoClaim(lastClaimTimes[account])) {
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }
            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(
        address payable account,
        bool automatic
    ) public onlyOwner returns (bool) {
        uint256 amount;
        bool paid;
        for (uint256 i; i < rewardTokens.length; i++) {
            amount = _withdrawDividendOfUser(account, rewardTokens[i]);
            if (amount > 0) {
                lastClaimTimes[account] = block.timestamp;
                emit Claim(account, amount, automatic);
                paid = true;
            }
        }
        return paid;
    }
}

contract EasyEther is ERC20, Ownable {
    using SafeMath for uint256;

    bool private swapping;
    bool private limitsActive = true;
    bool public swapEnabled = false;

    DividendTracker public dividendTracker;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    address public ZERO = 0x0000000000000000000000000000000000000000;

    uint256 public maxSellTransactionAmount;
    uint256 public maxBuyTransactionAmount;
    uint256 public swapTokensAtAmount;
    uint256 public maxWallet;

    uint256 public buyLiquidityFee;
    uint256 public buyMarketingFee;
    uint256 public buyRewardFee;

    uint256 public sellLiquidityFee;
    uint256 public sellMarketingFee;
    uint256 public sellRewardFee;

    uint256 public totalSellFees;
    uint256 public totalBuyFees;
    uint256 feeDenominator = 100;

    // uint256 private tokensForRewards;
    // uint256 private tokensForMarketing;
    // uint256 private tokensForLiquidity;
    uint256 private tokensForSale;

    bool public tradingActive = false;
    uint256 public tradingActiveBlock = 0; // when trading was started
    uint256 public sellActiveTime = 0; //when sell will be active
    uint256 public buyActiveTime = 0; //when buy will be active

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public automatedMarketMakerPairs;
    address public marketingWallet;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

    bool public blacklistMode = true;
    mapping(address => bool) public isblacklisted;
    mapping(address => bool) public isWhitelisted;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isTxLimitExempt;

    IDEXRouter public router;
    address public pair;

    event GasForProcessingUpdated(
        uint256 indexed newValue,
        uint256 indexed oldValue
    );

    event UpdateDividendTracker(
        address indexed newAddress,
        address indexed oldAddress
    );

    event UpdateSwapRouter(
        address indexed newAddress,
        address indexed oldAddress
    );

    event marketingWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );

    event SendDividends(uint256 tokensSwapped, uint256 amount);

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    constructor(
        address _owner,
        address _marketingWallet
    ) ERC20("EasyEther", "EasyE", 9) {
        uint256 _totalSupply = 10 * 1e9 * 1e9; //10 billion
        maxBuyTransactionAmount = (_totalSupply * 1) / 100; // 1% maxBuyTransactionAmount
        maxSellTransactionAmount = (_totalSupply * 5) / 1000; // 0.5% maxSellTransactionAmount
        swapTokensAtAmount = (_totalSupply * 8) / 10000; // 0.05% swap tokens amount
        maxWallet = (_totalSupply * 1) / 100; // 1% Max wallet

        buyLiquidityFee = 2;
        buyRewardFee = 5;
        buyMarketingFee = 2;
        totalBuyFees = buyLiquidityFee + buyMarketingFee + buyRewardFee;

        sellLiquidityFee = 2;
        sellRewardFee = 5;
        sellMarketingFee = 2;
        totalSellFees = sellLiquidityFee + sellMarketingFee + sellRewardFee;
        address pancakeSwapRouter;

        if (block.chainid == 56) {
            pancakeSwapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        } else if (block.chainid == 97) {
            pancakeSwapRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        } else revert();
        router = IDEXRouter(pancakeSwapRouter);
        pair = IDEXFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        marketingWallet = _marketingWallet;
        dividendTracker = new DividendTracker();

        _setAutomatedMarketMakerPair(pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(_owner);
        dividendTracker.excludeFromDividends(address(router));
        dividendTracker.excludeFromDividends(address(DEAD));

        // dividendTracker.transferOwnership(_owner);

        //exclude accounts from fee
        isFeeExempt[_owner] = true;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[marketingWallet] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[DEAD] = true;

        //exclude from max transaction
        isTxLimitExempt[marketingWallet] = true;
        isTxLimitExempt[_owner] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[address(router)] = true;

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _approve(address(this), address(router), type(uint256).max);
        _mint(address(_owner), _totalSupply);
        transferOwnership(msg.sender); //
    }

    receive() external payable {}

    //contract functions

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        if (!tradingActive) {
            require(
                isFeeExempt[from] || isFeeExempt[to],
                "Trading is not active yet."
            );
        }

        if (blacklistMode) {
            require(!isblacklisted[from], "blacklisted address");
        }

        if (limitsActive) {
            if (haveLimits(from, to)) {
                checkBuyLimit(from, to, amount);
                checkSellLimit(from, to, amount);
                checkMaxWallet(to, amount);
            }
        }

        if (shouldSwapBack(from, to)) {
            swapping = true;
            swapBack();
            swapping = false;
        }
        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (isFeeExempt[from] || isFeeExempt[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        if (takeFee) {
            if (automatedMarketMakerPairs[to] && totalSellFees > 0) {
                uint256 fee = totalSellFees;
                if (sellActiveTime > block.timestamp) {
                    fee = 45; //TODO change this
                }
                fees = amount.mul(fee).div(feeDenominator);
                tokensForSale += (fees * fee) / fee;
            } else if (automatedMarketMakerPairs[from] && totalBuyFees > 0) {
                uint256 fee = totalBuyFees;
                if (buyActiveTime > block.timestamp) {
                    fee = 90; //TODO change this
                }
                fees = amount.mul(fee).div(feeDenominator);
                tokensForSale += (fees * fee) / fee;
            }
            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);

        try
            dividendTracker.setBalance(payable(from), balanceOf(from))
        {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if (!swapping) {
            uint256 gas = gasForProcessing;

            try dividendTracker.process(gas) returns (
                uint256 iterations,
                uint256 claims,
                uint256 lastProcessedIndex
            ) {
                emit ProcessedDividendTracker(
                    iterations,
                    claims,
                    lastProcessedIndex,
                    true,
                    gas,
                    tx.origin
                );
            } catch {}
        }
    }

    //limits

    function removeLimits() external onlyOwner returns (bool) {
        require(limitsActive == true, "Limits are already removed");
        limitsActive = false;
        return true;
    }

    function addLimitations() external onlyOwner returns (bool) {
        require(limitsActive == false, "Limits are active");
        limitsActive = true;
        return true;
    }

    function shouldSwapBack(
        address from,
        address to
    ) internal view returns (bool) {
        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        return
            canSwap &&
            swapEnabled &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            !isFeeExempt[from] &&
            !isFeeExempt[to];
    }

    function haveLimits(address from, address to) internal view returns (bool) {
        return
            from != owner() &&
            to != owner() &&
            to != address(0) &&
            to != address(DEAD) &&
            !swapping;
    }

    function checkBuyLimit(
        address from,
        address to,
        uint256 amount
    ) internal view {
        if (automatedMarketMakerPairs[from] && !isTxLimitExempt[to]) {
            require(
                amount <= maxBuyTransactionAmount,
                "Buy transfer amount exceeds the maxBuyTransactionAmount."
            );
            require(
                amount + balanceOf(to) <= maxWallet,
                "Unable to exceed Max Wallet"
            );
        }
    }

    function checkMaxWallet(address to, uint256 amount) internal view {
        if (!isTxLimitExempt[to]) {
            require(
                amount + balanceOf(to) <= maxWallet,
                "Unable to exceed Max Wallet"
            );
        }
    }

    function checkSellLimit(
        address from,
        address to,
        uint256 amount
    ) internal view {
        if (automatedMarketMakerPairs[to] && !isTxLimitExempt[from]) {
            require(
                amount <= maxSellTransactionAmount,
                "Sell transfer amount exceeds the maxSellTransactionAmount."
            );
        }
    }

    //swapping function

    function swapBack() private {
        uint256 contractTokenBalance = swapTokensAtAmount;

        uint256 totalFee = totalBuyFees + totalSellFees;
        uint256 liquidityFee = sellLiquidityFee + buyLiquidityFee;
        uint256 marketingFee = sellMarketingFee + buyMarketingFee;
        uint256 rewardFee = sellRewardFee + buyRewardFee;

        uint256 amountToLiquify = contractTokenBalance
            .mul(liquidityFee)
            .div(totalFee)
            .div(2);

        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB
            .mul(liquidityFee)
            .div(totalBNBFee)
            .div(2);
        uint256 amountBNBreward = amountBNB.mul(rewardFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(
            totalBNBFee
        );
        tokensForSale -= contractTokenBalance;

        (bool success, ) = address(marketingWallet).call{
            value: amountBNBMarketing
        }("");

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                owner(),
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }

        amountBNBreward = address(this).balance;
        (success, ) = address(dividendTracker).call{value: amountBNBreward}("");
    }

    //fees management
    function updateBuyFees(
        uint256 _marketingFee,
        uint256 _rewardsFee,
        uint256 _liquidityFee
    ) external onlyOwner {
        buyMarketingFee = _marketingFee;
        buyRewardFee = _rewardsFee;
        buyLiquidityFee = _liquidityFee;
        totalBuyFees = _marketingFee + _rewardsFee + _liquidityFee;
        require(totalBuyFees <= 30, "Must keep fees at 30% or less");
    }

    function updateSellFees(
        uint256 _marketingFee,
        uint256 _rewardsFee,
        uint256 _liquidityFee
    ) external onlyOwner {
        sellMarketingFee = _marketingFee;
        sellRewardFee = _rewardsFee;
        sellLiquidityFee = _liquidityFee;
        totalSellFees = _marketingFee + _rewardsFee + _liquidityFee;
        require(totalSellFees <= 30, "Must keep fees at 30% or less");
    }

    function updateMaxBuyAmount(uint256 newNum) external onlyOwner {
        require(
            newNum >= ((totalSupply() * 1) / 1000) / 1e9,
            "Cannot set maxBuyTransactionAmount lower than 0.1%"
        );
        maxBuyTransactionAmount = newNum * (10 ** 9);
    }

    function updateMaxSellAmount(uint256 newNum) external onlyOwner {
        require(
            newNum >= ((totalSupply() * 1) / 1000) / 1e9,
            "Cannot set maxSellTransactionAmount lower than 0.1%"
        );
        maxSellTransactionAmount = newNum * (10 ** 9);
    }

    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        require(
            newNum >= ((totalSupply() * 5) / 1000) / 1e9,
            "Cannot set maxWallet lower than 0.5%"
        );
        maxWallet = newNum * (10 ** 9);
    }

    //trade management
    function OpenTrading() public onlyOwner {
        tradingActive = true;
        tradingActiveBlock = block.number;
        buyActiveTime = block.timestamp + 1 minutes;
        sellActiveTime = block.timestamp + 5 minutes;
        swapEnabled = true;
    }

    function updateTradingStatus(bool state) external onlyOwner {
        tradingActive = state;
    }

    function updateSwapEnabled(bool enabled) external onlyOwner {
        swapEnabled = enabled;
    }

    function updateSwapTokensAtAmount(uint256 newNum) external onlyOwner {
        require(
            newNum >= ((totalSupply() * 1) / 10000) / 1e9,
            "Cannot set maxWallet lower than 0.01%"
        );
        swapTokensAtAmount = newNum * (10 ** 9);
    }

    //address or holders management
    function setisTxLimitExempt(
        address holder,
        bool exempt
    ) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            isFeeExempt[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function enableBlacklist(bool _status) external onlyOwner {
        blacklistMode = _status;
    }

    function manageBlacklist(
        address[] calldata addresses,
        bool status
    ) external onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isblacklisted[addresses[i]] = status;
        }
    }

    function UpdateBlacklist(address _address, bool _value) public onlyOwner {
        isblacklisted[_address] = _value;
    }

    function manageWhitelist(
        address[] calldata addresses,
        bool status
    ) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            _whiteListAddress(addresses[i], status);
        }
    }

    function _whiteListAddress(address wallet, bool status) internal {
        isWhitelisted[wallet] = status;
        isFeeExempt[wallet] = status;
        isTxLimitExempt[wallet] = status;
    }

    function UpdateWhitelist(address _address, bool _value) public onlyOwner {
        _whiteListAddress(_address, _value);
    }

    function updateMarketingWallet(
        address newMarketingWallet
    ) external onlyOwner {
        isFeeExempt[newMarketingWallet] = true;
        emit marketingWalletUpdated(newMarketingWallet, marketingWallet);
        marketingWallet = newMarketingWallet;
    }

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    function setAutomatedMarketMakerPair(
        address tradePair,
        bool value
    ) public onlyOwner {
        require(
            tradePair != pair,
            "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(
        address tradePair,
        bool value
    ) private {
        automatedMarketMakerPairs[tradePair] = value;

        isTxLimitExempt[tradePair] = true;

        if (value) {
            dividendTracker.excludeFromDividends(tradePair);
        }

        emit SetAutomatedMarketMakerPair(tradePair, value);
    }

    //contract management

    function withdrawStuckEth() external onlyOwner {
        (bool success, ) = address(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "failed to withdraw");
    }

    function withdrawForeignToken(address _token) external onlyOwner {
        require(_token != address(this), "Can't let you take any native token");
        uint256 _contractBalance = ERC20(_token).balanceOf(address(this));
        ERC20(_token).transfer(msg.sender, _contractBalance);
    }

    function getLiquidityBacking(
        uint256 accuracy
    ) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function getCirculatingSupply() public view returns (uint256) {
        return totalSupply().sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function isOverLiquified(
        uint256 target,
        uint256 accuracy
    ) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountToken);

    //dividends function
    // excludes wallets and contracts from dividends (such as CEX hotwallets, etc.)
    function excludeFromDividends(address account) external onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }

    // removes exclusion on wallets and contracts from dividends (such as CEX hotwallets, etc.)
    function includeInDividends(address account) external onlyOwner {
        dividendTracker.includeInDividends(account);
    }

    function viewRewardsToken(
        uint256 indexToView
    ) public view returns (address) {
        return dividendTracker.viewRewardToken(indexToView);
    }

    function getClaimWait() external view returns (uint256) {
        return dividendTracker.claimWait();
    }

    function totalRewardsToken() external view returns (uint256) {
        return dividendTracker.totalRewardsToken();
    }

    function addRewardsToken(address _newToken) external onlyOwner {
        return dividendTracker.addRewardsToken(_newToken);
    }

    function removeRewardsToken(address tokenToRemove) external onlyOwner {
        return dividendTracker.removeRewardToken(tokenToRemove);
    }

    function getTotalDividendsDistributed(
        address rewardToken
    ) external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed(rewardToken);
    }

    function withdrawableDividendOf(
        address account,
        address rewardToken
    ) public view returns (uint256) {
        return dividendTracker.withdrawableDividendOf(account, rewardToken);
    }

    function dividendTokenBalanceOf(
        address account
    ) public view returns (uint256) {
        return dividendTracker.holderBalance(account);
    }

    function getAccountDividendsInfo(
        address account,
        address rewardToken
    )
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccount(account, rewardToken);
    }

    function getAccountDividendsInfoAtIndex(
        uint256 index,
        address rewardToken
    )
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccountAtIndex(index, rewardToken);
    }

    function processDividendTracker(uint256 gas) external {
        (
            uint256 iterations,
            uint256 claims,
            uint256 lastProcessedIndex
        ) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(
            iterations,
            claims,
            lastProcessedIndex,
            false,
            gas,
            tx.origin
        );
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function getNumberOfDividends() external view returns (uint256) {
        return dividendTracker.totalBalance();
    }

    function updateGasForProcessing(uint256 newGasValue) external onlyOwner {
        require(
            newGasValue >= 200000 && newGasValue <= 500000,
            " gasForProcessing must be between 200,000 and 500,000"
        );
        require(
            newGasValue != gasForProcessing,
            "Cannot update gasForProcessing to same value"
        );
        emit GasForProcessingUpdated(newGasValue, gasForProcessing);
        gasForProcessing = newGasValue;
    }
}