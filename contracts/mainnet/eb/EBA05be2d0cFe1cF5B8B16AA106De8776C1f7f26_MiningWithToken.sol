/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// SPDX-License-Identifier: MIT

// File contracts/v1contracts/dependencies/SafeMath.sol
// License-Identifier: MIT
pragma solidity =0.6.12;

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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function sub0(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? 0 : sub(a, b);
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

    function mul18(uint256 a) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * (10 ** 18);
        require(c / a == 10 ** 18, "SafeMath: multiplication overflow");

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

    function div18(uint256 a) internal pure returns (uint256) {
        return div(a, (10 ** 18), "SafeMath: division by zero");
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File contracts/v1contracts/dependencies/IERC165.sol
// License-Identifier: MIT
pragma solidity =0.6.12;

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

// File contracts/v1contracts/dependencies/Context.sol
// License-Identifier: MIT

pragma solidity =0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File contracts/v1contracts/dependencies/Ownable.sol
// License-Identifier: MIT
pragma solidity =0.6.12;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() public {
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

// File contracts/v1contracts/dependencies/Mutex.sol
// License-Identifier: MIT
pragma solidity =0.6.12;

abstract contract Mutex {
    uint256 private _guard;
    uint256 private constant GUARD_PASS = 1;
    uint256 private constant GUARD_BLOCK = 2;

    constructor() public {
        _initGuard();
    }

    function guard() internal view returns (uint256) {
        return _guard;
    }

    function _initGuard() internal {
        _guard = GUARD_PASS;
    }

    modifier reGuard() {
        require(_guard == GUARD_PASS, "Mutex: reentrancy guarded");
        _guard = GUARD_BLOCK;
        _;
        _guard = GUARD_PASS;
    }

}

// File contracts/v1contracts/dependencies/Proxiable.sol
// License-Identifier: MIT

pragma solidity =0.6.12;



interface IContractProxiable {
    event ImplementationUpdated(address indexed _implementation);

    function updateImplementation(address _newImplementation) external;

    function getImplementation() external view returns (address);
}

abstract contract Proxiable is Ownable, Mutex, IERC165, IContractProxiable {
    bytes4 internal constant INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;
    bytes4 internal constant INTERFACE_SIGNATURE_ContractProxiable = 0xa8aa2dfe;

    bool public initialized = false;

    function _initialize() internal {
        require(!initialized, "Proxiable: contract already initialized");
        require(owner() == address(0x0), "Proxiable: logic implementation contract cannot be initialized");
        initialized = true;
        _initGuard();
        _transferOwnership(_msgSender());
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function initialize() external virtual {
        _initialize();
    }

    modifier inited() {
        require(initialized, "Proxiable: contract not initialized");
        _;
    }

    function _updateImplementation(address _newImplementation) internal {
        require(IERC165(_newImplementation).supportsInterface(0xa8aa2dfe), "Contract address not proxiable");

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, _newImplementation)
        }

        emit ImplementationUpdated(_newImplementation);
    }

    function updateImplementation(address _newImplementation) external virtual override onlyOwner {
        _updateImplementation(_newImplementation);
    }

    function getImplementation() external view virtual override returns (address _implementation) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            _implementation := sload(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7)
        }
    }

    function supportsInterface(bytes4 _interfaceId) public view virtual override returns (bool) {
        return _interfaceId == INTERFACE_SIGNATURE_ERC165 || _interfaceId == INTERFACE_SIGNATURE_ContractProxiable;
    }
}

// File contracts/v1contracts/dependencies/IERC20.sol
// License-Identifier: MIT
pragma solidity =0.6.12;

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// File contracts/v1contracts/dependencies/IPancakeSwap.sol
// License-Identifier: MIT

pragma solidity =0.6.12;

// Pancake Interfaces
interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

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

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// File contracts/v1contracts/dependencies/UpgradeableMiningBase.sol
// License-Identifier: MIT

pragma solidity =0.6.12;




interface IUpgradeableMiningBase {
    struct UserInfo {
        uint256 currentStaked;
        uint256 rewardDebt;
        uint256 rewardSettled;
        uint256 rewardWithdrawn;
        uint256 lastWithdrawTime;
        uint256 rewardReleased;
    }

    struct PoolInfo {
        address stakeTokenAddr;
        address rewardTokenAddr;
        IERC20 stakeToken;
        IERC20 rewardToken;
        uint256 rewardPerBlock;
        uint256 lastRewardBlock;
        uint256 accRewardPerStake;
        uint256 currentStaked;
        uint256 rewardSettled;
        uint256 rewardWithdrawn;
        uint256 lockTime;
        uint256 lockNum;
        uint256 minRelease;
        address target;
        address receiver;
    }

    function setRewardPerBlock(uint256 _rewardPerBlock) external;

    function setReceiver(address _receiverAddr) external;

    function stake(uint256 _amount, address[] calldata _path) external;

    function withdraw(address[] calldata _path) external;

    function reinvestTarget(address[] calldata _path) external;

    function withdrawTargetReward(uint256 _amount, address[] calldata _path) external;

    function overview()
        external
        view
        returns (
            address _stakeToken,
            address _rewardToken,
            uint256 _rewardPerBlock,
            uint256 _currentStaked,
            uint256 _rewardTotal,
            uint256 _rewardWithdrawn,
            uint256 _lockTime,
            uint256 _lockNum,
            uint256 _minRelease,
            address _receiverAddr
        );

    function getUserInfo(address _user)
        external
        view
        returns (
            uint256 _currentStaked,
            uint256 _currentPending,
            uint256 _rewardTotal,
            uint256 _rewardWithdrawable,
            uint256 _rewardWithdrawn
        );

    function getTargetReward(address[] calldata _path) external view returns (uint256 _reward);

    event TokenStaked(
        uint256 indexed pool,
        address indexed _user,
        uint256 _amount,
        uint256 _prev,
        uint256 _currentReward,
        uint256 timestamp
    );

    event RewardWithdrawn(
        uint256 indexed pool,
        address indexed _user,
        uint256 _amount,
        uint256 _rewardLeft,
        uint256 timestamp
    );
}

abstract contract UpgradeableMiningBase is Proxiable, IUpgradeableMiningBase {
    using SafeMath for uint256;

    uint256 internal constant shareBase = 1e18;

    mapping(uint256 => PoolInfo) internal pools;
    mapping(address => UserInfo) internal users;

    uint256 internal constant updateDelay = 1 days;
    address internal pendingImplementation;
    uint256 internal pendingActivatableTime;

    event ImplementationPending(
        address indexed _oldImplementation,
        address indexed _newImplementation,
        uint256 _activatable
    );

    address[] internal DAOMembers;
    mapping(address => bool) internal isDAOMember;

    mapping(address => uint256) internal DAOUpdateImplementationCount;
    mapping(address => mapping(address => bool)) internal DAOUpdateImplementationVoted;

    IPancakeRouter02 public router;
    string public migrated;
}

// File contracts/v1contracts/MiningWithToken.sol
// License-Identifier: MIT

pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

interface OldITarget {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function pendingCake(uint256 _pid, address _user) external view returns (uint256);

    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);
}

interface ITarget {
    function deposit(uint256 _amount) external;

    function withdraw(uint256 _amount) external;

    function pendingReward(address _user) external view returns (uint256);

    function hasUserLimit() external view returns (bool);

    function poolLimitPerUser() external view returns (uint256);

    function userInfo(address _user) external view returns (uint256, uint256);

    function rewardToken() external view returns (address);

    function stakedToken() external view returns (address);
}

contract MiningWithToken is UpgradeableMiningBase {
    string public constant contractName = "MiningWithToken";
    string public constant contractVersion = "1.0";

    function getStakeContractBalance() public view returns (uint256 _stakeBalance) {
        return getBalance(ITarget(pools[0].target).stakedToken());
    }

    function getStakeTargetAmount() public view returns (uint256 _stakeBalance) {
        (_stakeBalance, ) = ITarget(pools[0].target).userInfo(address(this));
    }

    function getStakeTargetPending(address[] calldata _path) public view returns (uint256 _stakeBalance) {
        return estimate(ITarget(pools[0].target).pendingReward(address(this)), _path);
    }

    function getStakeTotalBalance(address[] calldata _path) public view returns (uint256 _stakeBalance) {
        return getStakeContractBalance().add(getStakeTargetAmount()).add(getStakeTargetPending(_path));
    }

    function compareStr(string memory _str1, string memory _str2) private pure returns (bool) {
        return keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2));
    }

    function initOldTarget(address _newTarget, address _router) external onlyOwner {
        require(!compareStr(migrated, "New Mining With Token Contract"), "Can only migrate from old target!!");
        migrated = "New Mining With Token Contract";
        router = IPancakeRouter02(_router);
        (uint256 _stakeBalance, ) = OldITarget(pools[0].target).userInfo(0, address(this));
        OldITarget(pools[0].target).leaveStaking(_stakeBalance);
        pools[0].stakeToken.approve(pools[0].target, 0);
        pools[0].target = _newTarget;
        pools[0].stakeToken.approve(_newTarget, type(uint256).max);
        ITarget(pools[0].target).deposit(getStakeContractBalance());
    }

    modifier doReinvest(address[] calldata _path) {
        ITarget(pools[0].target).withdraw(getStakeTargetAmount());
        swap(_path);
        _;
        ITarget(pools[0].target).deposit(getStakeContractBalance());
    }

    function initialize() external override {
        revert("Use initialize with params instead!!");
    }

    function initialize(
        address _stakeToken,
        address _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _lockTime,
        uint256 _lockNum,
        uint256 _minRelease,
        address _targetAddr,
        address _receiverAddr,
        address[] calldata _DAOMembers,
        address _router
    ) external {
        _initialize();
        migrated = "New Mining With Token Contract";

        pools[0].stakeTokenAddr = _stakeToken;
        pools[0].rewardTokenAddr = _rewardToken;
        pools[0].stakeToken = IERC20(_stakeToken);
        pools[0].rewardToken = IERC20(_rewardToken);
        pools[0].rewardPerBlock = _rewardPerBlock;
        pools[0].lastRewardBlock = block.number;
        pools[0].lockTime = _lockTime;
        pools[0].lockNum = _lockNum;
        pools[0].minRelease = _minRelease;
        pools[0].target = _targetAddr;
        pools[0].receiver = _receiverAddr;

        DAOMembers = _DAOMembers;
        for (uint8 i = 0; i < _DAOMembers.length && i < 200; i++) {
            isDAOMember[_DAOMembers[i]] = true;
        }

        router = IPancakeRouter02(_router);
        IERC20(_stakeToken).approve(_targetAddr, type(uint256).max);
    }

    function updateTarget(address _targetAddr, address[] calldata _path) external doReinvest(_path) onlyOwner {
        pools[0].stakeToken.approve(pools[0].target, 0);
        pools[0].target = _targetAddr;
        pools[0].stakeToken.approve(_targetAddr, type(uint256).max);
    }


    function setRouter(address _router) external onlyOwner {
        router = IPancakeRouter02(_router);
    }

    function getRouter() external view returns (address _router) {
        return address(router);
    }

    function setMinRelease(uint256 _minRelease) external onlyOwner {
        pools[0].minRelease = _minRelease;
    }

    function setDAOMembers(address[] calldata _DAOMembers) external onlyOwner {
        require(DAOMembers.length == 0, "Cannot set DAO Members repeatedly!!");
        DAOMembers = _DAOMembers;
        for (uint8 i = 0; i < _DAOMembers.length && i < 200; i++) {
            isDAOMember[_DAOMembers[i]] = true;
        }
    }

    function getDAOMembers() external view returns (address[] memory _members) {
        _members = DAOMembers;
    }

    function updateImplementation(address _newImplementation) external override {
        require(isDAOMember[msg.sender], "Only DAO members can update implementation!!");

        address currentImplementation;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            currentImplementation := sload(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7)
        }
        require(
            currentImplementation != _newImplementation,
            "New implementation must be different from current implementation!!"
        );
        require(
            pendingImplementation != _newImplementation,
            "New implementation must be different from pending implementation!!"
        );

        if (DAOUpdateImplementationVoted[_newImplementation][msg.sender]) {
            return;
        }

        DAOUpdateImplementationVoted[_newImplementation][msg.sender] = true;
        DAOUpdateImplementationCount[_newImplementation] = DAOUpdateImplementationCount[_newImplementation].add(1);
        if (DAOUpdateImplementationCount[_newImplementation] < DAOMembers.length) {
            return;
        }

        for (uint8 i = 0; i < DAOMembers.length && i < 200; i++) {
            DAOUpdateImplementationVoted[_newImplementation][DAOMembers[i]] = false;
        }
        DAOUpdateImplementationCount[_newImplementation] = 0;

        pendingImplementation = _newImplementation;
        pendingActivatableTime = block.timestamp.add(updateDelay);
        emit ImplementationPending(currentImplementation, _newImplementation, pendingActivatableTime);
    }

    function activateImplementation() external {
        require(
            pendingImplementation != address(0x0) && pendingActivatableTime > 0,
            "Invalid pending implementation!!"
        );
        require(pendingActivatableTime <= block.timestamp, "Cannot activate pending implementation too soon!!");
        _updateImplementation(pendingImplementation);
        pendingImplementation = address(0x0);
        pendingActivatableTime = 0;
    }

    function getPendingImplementation() external view returns (address, uint256) {
        return (pendingImplementation, pendingActivatableTime);
    }

    function setRewardPerBlock(uint256 _rewardPerBlock) external override onlyOwner {
        updatePool();
        pools[0].rewardPerBlock = _rewardPerBlock;
    }

    function setReceiver(address _receiverAddr) external override onlyOwner {
        pools[0].receiver = _receiverAddr;
    }

    function updatePool() private {
        if (block.number > pools[0].lastRewardBlock) {
            uint256 newReward;
            if (pools[0].currentStaked > 0) {
                newReward = block.number.sub(pools[0].lastRewardBlock).mul(pools[0].rewardPerBlock);
                pools[0].accRewardPerStake = pools[0].accRewardPerStake.add(
                    newReward.mul(shareBase).div(pools[0].currentStaked)
                );
            }
            pools[0].rewardSettled = pools[0].rewardSettled.add(newReward);
            pools[0].lastRewardBlock = block.number;
        }
    }

    function stake(uint256 _amount, address[] calldata _path) external override inited reGuard doReinvest(_path) {
        if (users[msg.sender].currentStaked > 0) {
            require(
                pools[0].stakeToken.transfer(msg.sender, users[msg.sender].currentStaked),
                "stake token transfer out failed!!"
            );
        }
        if (_amount > 0) {
            require(
                pools[0].stakeToken.transferFrom(msg.sender, address(this), _amount),
                "stake token transfer in failed!!"
            );
        }
        updatePool();
        uint256 newReward = users[msg.sender].currentStaked.mul(pools[0].accRewardPerStake).div(shareBase).sub(
            users[msg.sender].rewardDebt
        );
        users[msg.sender].rewardSettled = users[msg.sender].rewardSettled.add(newReward);
        if (users[msg.sender].rewardSettled > 0 && users[msg.sender].lastWithdrawTime > 0) {
            uint256 releaseNum = block.timestamp.sub(users[msg.sender].lastWithdrawTime).div(pools[0].lockTime);
            releaseNum = releaseNum > pools[0].lockNum ? pools[0].lockNum : releaseNum;
            uint256 released = users[msg.sender].rewardSettled.mul(releaseNum).div(pools[0].lockNum);
            released = released > 0 && released < pools[0].minRelease ? pools[0].minRelease : released;
            released = released > users[msg.sender].rewardSettled ? users[msg.sender].rewardSettled : released;
            users[msg.sender].rewardReleased = users[msg.sender].rewardReleased.add(released);
            users[msg.sender].rewardSettled = users[msg.sender].rewardSettled.sub(released);
        }
        users[msg.sender].lastWithdrawTime = block.timestamp;
        pools[0].currentStaked = pools[0].currentStaked.sub(users[msg.sender].currentStaked);
        users[msg.sender].rewardDebt = _amount.mul(pools[0].accRewardPerStake).div(shareBase);
        uint256 prevAmount = users[msg.sender].currentStaked;
        users[msg.sender].currentStaked = _amount;
        pools[0].currentStaked = pools[0].currentStaked.add(_amount);

        emit TokenStaked(
            0,
            msg.sender,
            _amount,
            prevAmount,
            users[msg.sender].rewardSettled.add(users[msg.sender].rewardReleased),
            block.timestamp
        );
    }

    function withdraw(address[] calldata _path) external override inited reGuard doReinvest(_path) {
        require(users[msg.sender].lastWithdrawTime > 0, "cannot withdraw without staking!!");
        updatePool();
        uint256 newReward = users[msg.sender].currentStaked.mul(pools[0].accRewardPerStake).div(shareBase).sub(
            users[msg.sender].rewardDebt
        );
        users[msg.sender].rewardSettled = users[msg.sender].rewardSettled.add(newReward);
        users[msg.sender].rewardDebt = users[msg.sender].currentStaked.mul(pools[0].accRewardPerStake).div(shareBase);
        uint256 releaseNum = block.timestamp.sub(users[msg.sender].lastWithdrawTime).div(pools[0].lockTime);
        releaseNum = releaseNum > pools[0].lockNum ? pools[0].lockNum : releaseNum;
        uint256 released = users[msg.sender].rewardSettled.mul(releaseNum).div(pools[0].lockNum);
        released = released > 0 && released < pools[0].minRelease ? pools[0].minRelease : released;
        released = released > users[msg.sender].rewardSettled ? users[msg.sender].rewardSettled : released;
        users[msg.sender].rewardSettled = users[msg.sender].rewardSettled.sub(released);
        released = released.add(users[msg.sender].rewardReleased);
        users[msg.sender].rewardReleased = 0;
        require(pools[0].rewardToken.balanceOf(address(this)) >= released, "not enough reward token in pool!!");
        require(pools[0].rewardToken.transfer(msg.sender, released), "reward token transfer failed!!");
        users[msg.sender].rewardWithdrawn = users[msg.sender].rewardWithdrawn.add(released);
        users[msg.sender].lastWithdrawTime = block.timestamp;
        pools[0].rewardSettled = pools[0].rewardSettled.sub(released);
        pools[0].rewardWithdrawn = pools[0].rewardWithdrawn.add(released);

        emit RewardWithdrawn(0, msg.sender, released, users[msg.sender].rewardSettled, block.timestamp);
    }

    function getUserHold(address _user) private view returns (uint256 _reward) {
        _reward = users[_user].rewardSettled;
        if (block.number > pools[0].lastRewardBlock && pools[0].currentStaked > 0) {
            uint256 poolNewReward = block.number.sub(pools[0].lastRewardBlock).mul(pools[0].rewardPerBlock);
            uint256 accRewardPerStake = pools[0].accRewardPerStake.add(
                poolNewReward.mul(shareBase).div(pools[0].currentStaked)
            );
            uint256 userNewReward = users[_user].currentStaked.mul(accRewardPerStake).div(shareBase).sub(
                users[_user].rewardDebt
            );
            _reward = _reward.add(userNewReward);
        }
    }

    function getUserReward(address _user) public view returns (uint256 _reward) {
        _reward = getUserHold(_user).add(users[_user].rewardReleased);
    }

    function getPoolReward() public view returns (uint256 _reward) {
        _reward = pools[0].rewardSettled;
        if (block.number > pools[0].lastRewardBlock && pools[0].currentStaked > 0) {
            uint256 poolNewReward = block.number.sub(pools[0].lastRewardBlock).mul(pools[0].rewardPerBlock);
            _reward = _reward.add(poolNewReward);
        }
    }

    function getUserWithdrawable(address _user) public view returns (uint256 _withdrawable) {
        if (users[_user].lastWithdrawTime <= 0) {
            return 0;
        }

        uint256 reward = getUserHold(_user);
        uint256 releaseNum = block.timestamp.sub(users[_user].lastWithdrawTime).div(pools[0].lockTime);
        releaseNum = releaseNum > pools[0].lockNum ? pools[0].lockNum : releaseNum;
        uint256 released = reward.mul(releaseNum).div(pools[0].lockNum);
        released = released > 0 && released < pools[0].minRelease ? pools[0].minRelease : released;
        released = released > reward ? reward : released;
        released = released.add(users[_user].rewardReleased);
        return released;
    }

    function overview()
        external
        view
        override
        returns (
            address _stakeToken,
            address _rewardToken,
            uint256 _rewardPerBlock,
            uint256 _currentStaked,
            uint256 _rewardTotal,
            uint256 _rewardWithdrawn,
            uint256 _lockTime,
            uint256 _lockNum,
            uint256 _minRelease,
            address _receiverAddr
        )
    {
        _stakeToken = pools[0].stakeTokenAddr;
        _rewardToken = pools[0].rewardTokenAddr;
        _rewardPerBlock = pools[0].rewardPerBlock;
        _currentStaked = pools[0].currentStaked;
        _rewardTotal = getPoolReward().add(pools[0].rewardWithdrawn);
        _rewardWithdrawn = pools[0].rewardWithdrawn;
        _lockTime = pools[0].lockTime;
        _lockNum = pools[0].lockNum;
        _minRelease = pools[0].minRelease;
        _receiverAddr = pools[0].receiver;
    }

    function getUserInfo(address _user)
        external
        view
        override
        returns (
            uint256 _currentStaked,
            uint256 _currentPending,
            uint256 _rewardTotal,
            uint256 _rewardWithdrawable,
            uint256 _rewardWithdrawn
        )
    {
        _currentStaked = users[_user].currentStaked;
        _currentPending = getUserReward(_user);
        _rewardTotal = _currentPending.add(users[_user].rewardWithdrawn);
        _rewardWithdrawable = getUserWithdrawable(_user);
        _rewardWithdrawn = users[_user].rewardWithdrawn;
    }

    function reinvestTarget(address[] calldata _path) external override onlyOwner doReinvest(_path) {}

    function getTargetReward(address[] calldata _path) public view override returns (uint256 _reward) {
        return getStakeTotalBalance(_path).sub(pools[0].currentStaked);
    }

    function withdrawTargetReward(uint256 _amount, address[] calldata _path)
        external
        override
        onlyOwner
        doReinvest(_path)
    {
        require(getTargetReward(_path) >= _amount, "Not enough target reward to withdraw!!");
        if (_amount <= 0) {
            _amount = getTargetReward(_path);
        }
        require(pools[0].stakeToken.transfer(pools[0].receiver, _amount), "Target reward transfer failed!!");
    }

    function estimate(uint256 _amountIn, address[] calldata _path) public view returns (uint256) {
        address rewardToken = ITarget(pools[0].target).rewardToken();
        address stakedToken = ITarget(pools[0].target).stakedToken();
        if (rewardToken == stakedToken || _amountIn == 0) {
            return _amountIn;
        }
        require(
            _path.length >= 2 && _path[0] == rewardToken && _path[_path.length.sub(1)] == stakedToken,
            "error path"
        );
        uint256[] memory result = router.getAmountsOut(_amountIn, _path);
        return result[result.length - 1];
    }

    function swap(address[] calldata _path) internal returns (uint256 _output) {
        address from = ITarget(pools[0].target).rewardToken();
        address to = ITarget(pools[0].target).stakedToken();
        uint256 amountIn = getBalance(ITarget(pools[0].target).rewardToken());
        if (from == to || amountIn == 0) {
            return amountIn;
        }
        require(_path.length >= 2 && _path[0] == from && _path[_path.length.sub(1)] == to, "error path");
        require(IERC20(from).approve(address(router), amountIn), "token approval failed");
        uint256 beforeBalance = getBalance(to);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            0,
            _path,
            address(this),
            block.timestamp
        );
        _output = getBalance(to).sub(beforeBalance);
        require(IERC20(from).approve(address(router), 0), "token approval removal failed");
    }

    function getBalance(address _addr) public view returns (uint256) {
        return IERC20(_addr).balanceOf(address(this));
    }

    function getTargetInfo() public view returns (address _target, address _stake, address _reward, uint256 _pending) {
        _target = pools[0].target;
        _stake = ITarget(_target).stakedToken();
        _reward = ITarget(_target).rewardToken();
        _pending = ITarget(_target).pendingReward(address(this));
    }
}