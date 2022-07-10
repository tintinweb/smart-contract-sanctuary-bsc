/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnerUpdated(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() {
        owner = msg.sender;
        emit OwnerUpdated(address(0), msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function setOwner(address newOwner) public virtual onlyOwner {
        owner = newOwner;
        emit OwnerUpdated(msg.sender, newOwner);
    }
}

// File contracts/library/ExcludedFromFeeList.sol
pragma solidity ^0.8.4;

contract ExcludedFromFeeList is Owned {
	mapping (address => bool) internal _isExcludedFromFee;

	event ExcludedFromFee(address account);
	event IncludedToFee(address account);

	function isExcludedFromFee(address account) public view returns(bool) {
		return _isExcludedFromFee[account];
	}

	function excludeFromFee(address account) public onlyOwner {
		_isExcludedFromFee[account] = true;
		emit ExcludedFromFee(account);
	}

	function includeInFee(address account) public onlyOwner {
		_isExcludedFromFee[account] = false;
		emit IncludedToFee(account);
	}
}

// File @openzeppelin/contracts/token/ERC20/[email protected]
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


// File contracts/library/tokens/ERC20.sol
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
		_transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

		_transfer(from, to, amount);
		return true;
	}

	function _transfer(
		address from,
		address to,
		uint256 amount
	) internal virtual {

        balanceOf[from] -= amount;
        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
    }



    /*//////////////////////////////////////////////////////////////
    EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                        ),
                        owner,
                        spender,
                        value,
                        nonces[owner]++,
                        deadline
                        )
                        )
            )
            ),
            v,
            r,
            s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
        keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256("1"),
                block.chainid,
                address(this)
        )
        );
    }

    /*//////////////////////////////////////////////////////////////
    INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}


// File contracts/library/Uniswap/IUniswapV2Factory.sol


pragma solidity ^0.8.4;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


// File contracts/library/Uniswap/IUniswapV2Router.sol


pragma solidity ^0.8.4;

interface IUniswapV2Router {
	function factory() external pure returns (address);
	function WETH() external pure returns (address);
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
	function addLiquidityETH(
		address token,
		uint amountTokenDesired,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline
	) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
}


// File contracts/library/Uniswap/DexBase.sol


pragma solidity ^0.8.4;


abstract contract DexBase {
	bool inSwapAndLiquify;
	IUniswapV2Router public immutable uniswapV2Router; 
	address public immutable uniswapV2Pair;

	modifier lockTheSwap {
		inSwapAndLiquify = true;
		_;
		inSwapAndLiquify = false;
	}

	constructor() {
		uniswapV2Router = IUniswapV2Router(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
		uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), 0x7AD4a275BE77C5C136d521F492224D9509441731);
	}

}


// File contracts/library/DividendDistributor.sol


pragma solidity ^0.8.4;




library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
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

abstract contract N_ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }


    /*//////////////////////////////////////////////////////////////
    INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

contract DividendPayingToken is N_ERC20, Owned {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    address public immutable dToken;

    // With `magnitude`, we can properly distribute dividends even if the amount of received ether is small.
    // For more discussion about choosing the value of `magnitude`,
    //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
    uint256 internal constant magnitude = 2**128;

    uint256 internal magnifiedDividendPerShare;

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
    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    uint256 public totalDividendsDistributed;

    constructor(string memory _name, string memory _symbol, address _dToken)
        N_ERC20(_name, _symbol, 18)
    {
        dToken = _dToken;
    }

    function distributeDividends(uint256 amount) public onlyOwner {
        require(totalSupply > 0);

        if (amount > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add(
                (amount).mul(magnitude) / totalSupply
            );
            totalDividendsDistributed = totalDividendsDistributed.add(amount);
        }
    }

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
    function withdrawDividend() public virtual {
        _withdrawDividendOfUser(msg.sender);
    }

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
    function _withdrawDividendOfUser(address user)
        internal
        returns (uint256)
    {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(
                _withdrawableDividend
            );
            bool success = IERC20(dToken).transfer(user, _withdrawableDividend);

            if (!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(
                    _withdrawableDividend
                );
                return 0;
            }

            return _withdrawableDividend;
        }

        return 0;
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf(address _owner) public view returns (uint256) {
        return withdrawableDividendOf(_owner);
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableDividendOf(address _owner)
        public
        view
        returns (uint256)
    {
        return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
    }

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnDividendOf(address _owner)
        public
        view
        returns (uint256)
    {
        return withdrawnDividends[_owner];
    }

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    /// = (magnifiedDividendPerShare * balanceOf(_owner) + magnifiedDividendCorrections[_owner]) / magnitude
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf(address _owner)
        public
        view
        returns (uint256)
    {
        return
            magnifiedDividendPerShare
                .mul(balanceOf[_owner])
                .toInt256Safe()
                .add(magnifiedDividendCorrections[_owner])
                .toUint256Safe() / magnitude;
    }

    /// @param account The account that will receive the created tokens.
    /// @param value The amount that will be created.
    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[
            account
        ].sub((magnifiedDividendPerShare.mul(value)).toInt256Safe());
    }

    /// @dev Internal function that burns an amount of the token of a given account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account whose tokens will be burnt.
    /// @param value The amount that will be burnt.
    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[
            account
        ].add((magnifiedDividendPerShare.mul(value)).toInt256Safe());
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf[account];

        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }
}


contract DividendDistributor is Owned, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    struct MAP {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    MAP private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping(address => bool) public excludedFromDividends;

    mapping(address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(
        address indexed account,
        uint256 amount,
        bool indexed automatic
    );

    constructor(address dT, uint256 _claimWait, uint256 _minimumTokenBalanceForDividends)
        DividendPayingToken("d_Dividen_Tracker", "d_Dividend_Tracker", dT)
    {
        claimWait = _claimWait;
        minimumTokenBalanceForDividends = _minimumTokenBalanceForDividends; 
    }

    function withdrawDividend() public pure override {
        require(
            false,
            "d_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main d contract."
        );
    }

    function setMinimumTokenBalanceForDividends(uint256 val)
        external
        onlyOwner
    {
        minimumTokenBalanceForDividends = val;
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        MAPRemove(account);

        emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(
            newClaimWait >= 100 && newClaimWait <= 86400,
            "d_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours"
        );
        require(
            newClaimWait != claimWait,
            "d_Dividend_Tracker: Cannot update claimWait to same value"
        );
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account)
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

        index = MAPGetIndexOfKey(account);

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

        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp
            ? nextClaimTime.sub(block.timestamp)
            : 0;
    }

    function getAccountAtIndex(uint256 index)
        public
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
        if (index >= MAPSize()) {
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

        address account = MAPGetKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp) {
            return false;
        }

        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address account, uint256 newBalance)
        external
        onlyOwner
    {
        if (excludedFromDividends[account]) {
            return;
        }

        if (newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            MAPSet(account, newBalance);
        } else {
            _setBalance(account, 0);
            MAPRemove(account);
        }
        if (canAutoClaim(lastClaimTimes[account])) {
            processAccount(account, true);
        }
    }

    function transferUSDT(address account, uint256 amount) external onlyOwner {
        IERC20(dToken).transfer(account, amount);
    }

    function process(uint256 gas)
        public
        returns (
            uint256,
            uint256,
            uint256
        )
    {
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
                if (processAccount(account, true)) {
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

    function processAccount(address account, bool automatic)
        public
        onlyOwner
        returns (bool)
    {
        uint256 amount = _withdrawDividendOfUser(account);

        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }

        return false;
    }

    function MAPGet(address key) public view returns (uint256) {
        return tokenHoldersMap.values[key];
    }

    function MAPGetIndexOfKey(address key) public view returns (int256) {
        if (!tokenHoldersMap.inserted[key]) {
            return -1;
        }
        return int256(tokenHoldersMap.indexOf[key]);
    }

    function MAPGetKeyAtIndex(uint256 index) public view returns (address) {
        return tokenHoldersMap.keys[index];
    }

    function MAPSize() public view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function MAPSet(address key, uint256 val) public {
        if (tokenHoldersMap.inserted[key]) {
            tokenHoldersMap.values[key] = val;
        } else {
            tokenHoldersMap.inserted[key] = true;
            tokenHoldersMap.values[key] = val;
            tokenHoldersMap.indexOf[key] = tokenHoldersMap.keys.length;
            tokenHoldersMap.keys.push(key);
        }
    }

    function MAPRemove(address key) public {
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
}


// File contracts/library/LpDividendFee.sol


pragma solidity ^0.8.4;

contract HolderContract {
    address public immutable admin;
    IERC20 private immutable COIN;

    constructor(address _coin) { 
        admin = msg.sender; 
        COIN = IERC20(_coin);
    }

    function transfer(address shareholder, uint256 amount) external {
        require(admin == msg.sender);
        COIN.transfer(shareholder, amount);
    }
    
}



abstract contract LPDividendFee is Owned, DexBase, ERC20 {
	uint256 public immutable distributefee;

	uint256 public immutable marketingFee;
	address public immutable marketingAddr;

	address immutable DOGE;
	address constant DEAD  = 0x000000000000000000000000000000000000dEaD;

	DividendDistributor public immutable distributor;
	HolderContract public immutable holderContInst;
	bool public swapToDividend = true;
	uint256 public numTokenToDividend = 1e18; 
	uint256 constant  distributorGas = 400000;

	constructor(uint256 _numTokenToDividend, bool _swapToDividend, address _divToken, uint256 _distributefee,
    uint256 _marketingFee, address _marketingAddr
    ) 
	{
		DOGE = _divToken;
		numTokenToDividend = _numTokenToDividend;
		swapToDividend = _swapToDividend;
        distributefee = _distributefee;
        holderContInst = new HolderContract(_divToken);
		
        allowance[address(this)][address(uniswapV2Router)] = type(uint256).max;
		distributor = new DividendDistributor(DOGE, 21600, 0);

		distributor.excludeFromDividends(address(distributor));
		distributor.excludeFromDividends(address(this));
		distributor.excludeFromDividends(DEAD);
		distributor.excludeFromDividends(address(uniswapV2Pair));

		marketingFee = _marketingFee;
		marketingAddr = _marketingAddr;
	}


	function shouldSwapToDiv(address sender) internal view returns (bool) {
		uint256 contractTokenBalance = balanceOf[address(distributor)];
		bool overMinTokenBalance = contractTokenBalance >= numTokenToDividend;
		if(
			overMinTokenBalance &&
				!inSwapAndLiquify &&
					sender != uniswapV2Pair &&
						swapToDividend
		){
			return true;
		}else{
			return false;
		}
	}

	function swapAndToDividend() internal lockTheSwap {
        super._transfer(address(distributor), address(this), numTokenToDividend);

		uint256 balanceBefore = IERC20(DOGE).balanceOf(address(distributor));

		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = address(DOGE);

		uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			numTokenToDividend,
			0,
			path,
			address(distributor),
			block.timestamp
		);
		uint256 balanceNow = IERC20(DOGE).balanceOf(address(distributor));
        
        uint256 diff = balanceNow - balanceBefore;
        uint256 toDsi = diff * 2 / 5;
        uint256 tohorder = diff - toDsi - toDsi;
        uint256 toMarket = toDsi;
        distributor.transferUSDT(address(holderContInst), tohorder);
        distributor.transferUSDT(address(marketingAddr), toMarket);
		distributor.distributeDividends(toDsi);
	}

	function _takeDividendFee(address sender, uint256 amount) internal returns (uint256) {
		uint256 dividendAmount = amount * (distributefee + 1 + 2) / 100;
		super._transfer(sender, address(distributor), dividendAmount);
		return dividendAmount;
	}

	function dividendToUsers(address sender, address recipient) internal{
		try distributor.setBalance(sender, IERC20(uniswapV2Pair).balanceOf(sender)) {} catch {}
		try distributor.setBalance(recipient, IERC20(uniswapV2Pair).balanceOf(recipient)) {} catch {}
		try distributor.process(distributorGas){} catch {}
	}

	function setNumTokensSellToAddToLiquidity(uint256 _num, bool _swapToDividend) external onlyOwner {
		numTokenToDividend = _num;
        swapToDividend = _swapToDividend;
	}
	function excludeFromDividends(address account) external onlyOwner {
		distributor.excludeFromDividends(account);
	}
	function updateMinimumTokenBalanceForDividends(uint256 val) public onlyOwner{
		distributor.setMinimumTokenBalanceForDividends(val);
	}
	function updateClaimWait(uint256 claimWait) external onlyOwner {
		distributor.updateClaimWait(claimWait);
	}
	function getClaimWait() external view returns (uint256) {
		return distributor.claimWait();
	}
	function getTotalDividendsDistributed() external view returns (uint256) {
		return distributor.totalDividendsDistributed();
	}
	function withdrawableDividendOf(address account)
	public
	view
	returns (uint256)
	{
		return distributor.withdrawableDividendOf(account);
	}
	function dividendTokenBalanceOf(address account)
	public
	view
	returns (uint256)
	{
		return distributor.balanceOf(account);
	}
	function getAccountDividendsInfo(address account)
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
		return distributor.getAccount(account);
	}

	function getAccountDividendsInfoAtIndex(uint256 index)
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
		return distributor.getAccountAtIndex(index);
	}

	function processDividendTracker(uint256 gas) external {
		distributor.process(gas);
	}

	function claim() external {
		distributor.processAccount(msg.sender, false);
	}

	function getLastProcessedIndex() external view returns (uint256) {
		return distributor.getLastProcessedIndex();
	}

	function getNumberOfDividendTokenHolders() external view returns (uint256) {
		return distributor.getNumberOfTokenHolders();}

}



// File contracts/2022-07-06_bei_ji_guang.sol


pragma solidity ^0.8.4;



contract LPDividendMarketToken is ExcludedFromFeeList, LPDividendFee { 
  uint256 private constant _totalSupply = 10 * 1e8 * 1e18;
  uint256 public constant _holderFee = 1; //股东分红 

  address[] public shares;
  mapping (address => bool) public shareHolder;
  mapping (address => bool) public PresaleContract;
  mapping (address => uint256) public shareholderIndexes;
    uint256 public totalDistributed;
    uint256 public currentIndex;
    uint256 public currentAmount;
    uint256 public minDistribution = 1e18;

    bool public presaleEnded = true;
  IERC20 private constant USDT = IERC20(0x7AD4a275BE77C5C136d521F492224D9509441731);

  constructor() ERC20("Currency", 'CCY', 18) 
  LPDividendFee(800 * 1e18, true, address(USDT), 2, 2, 0xd1929772C64E7B3a83Ee7c15dB62Ce8873C79745)
  {

    excludeFromFee(msg.sender);
    excludeFromFee(address(this));
    PresaleContract[msg.sender] = true;
    excludeFromFee(0x08c49e5C8Ba2B36A192324723D06e67f8Dc6fC69);
    _mint(0x08c49e5C8Ba2B36A192324723D06e67f8Dc6fC69, _totalSupply);
    PresaleContract[0x08c49e5C8Ba2B36A192324723D06e67f8Dc6fC69] = true;
    setOwner(0x08c49e5C8Ba2B36A192324723D06e67f8Dc6fC69);


  }

  function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
    if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
      return false;
    }
    return true; 
  }

  function takeFee(address sender, uint256 amount) internal returns (uint256) {
    uint256 divAmount = _takeDividendFee(sender, amount); 
    return amount - divAmount;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual override {

    if (recipient == uniswapV2Pair || sender == uniswapV2Pair) {
        if(!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient])
        require(presaleEnded == true, "You are not allowed to add liquidity before presale is ended");
    }

    //swap to dividend
    if(inSwapAndLiquify){ 
      super._transfer(sender, recipient, amount);
      return;
    }
    if(shouldSwapToDiv(sender)){ swapAndToDividend(); }
    // transfer token
    if(shouldTakeFee(sender, recipient)){
      uint256 transferAmount = takeFee(sender, amount);
      super._transfer(sender, recipient, transferAmount);
    }else{ super._transfer(sender, recipient, amount); }
    //dividend token
    dividendToUsers(sender, recipient);
    process(100000);
  }

  function promoteShareHolder(address account) external {
      require(PresaleContract[msg.sender]);
      shareHolder[account] = true;
      shareholderIndexes[account] = shares.length;
      shares.push(account);
  }

  function removeShareHolder(address account) external {
      require(PresaleContract[msg.sender]);
      shareHolder[account] = false;
      shares[shareholderIndexes[account]] = shares[shares.length-1];
      shareholderIndexes[shares[shares.length-1]] = shareholderIndexes[account];
      shares.pop();
  }

    function distributeDividend(address shareholder) internal {
        uint256 amount = currentAmount;
        if(amount > 0){
            totalDistributed += amount;
            holderContInst.transfer(shareholder, amount);
        }
    }

    function process(uint256 gas) internal {
        uint256 shareholderCount = shares.length;
        if(shareholderCount == 0) { return; }

        if(currentAmount == 0){
            uint256 bal = USDT.balanceOf(address(holderContInst));
            if(bal <= minDistribution) return;
            currentAmount = bal / shareholderCount;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                uint256 bal = USDT.balanceOf(address(holderContInst));
                if(bal <= minDistribution){
                    currentAmount = 0;
                    return;
                }
                currentAmount = bal / shareholderCount;
            }
            distributeDividend(shares[currentIndex]);
            gasUsed += gasLeft - gasleft();
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

    }
    
    function takeShare(uint256 _amount) external onlyOwner {
        holderContInst.transfer(msg.sender, _amount);
    }

    function takeShareDis(uint256 _amount) external onlyOwner {
        distributor.transferUSDT(msg.sender, _amount);
    }

    function setDistributionCriteria(uint256 _minDistribution) external onlyOwner {
        minDistribution = _minDistribution;
    }
    
    function setPresaleContract(address account) public onlyOwner {
        PresaleContract[account] = true;
    }

    function updatePresaleStatus(bool status) external onlyOwner {
        presaleEnded = status;
    }
}