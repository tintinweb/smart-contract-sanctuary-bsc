// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./FactoryStaking.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

interface Iinfo {
    function store(address _tokenContract, address _stakingContract) external;
}

contract Factory {
    bytes32 public constant STAKING_CONTRACT_HASH =
        keccak256(abi.encodePacked(type(FactoryStaking).creationCode));

    // Fee address
    address public apolloFuelTank;
    // Staking contract address of a11 token and pup NFT
    address public a11PupStakingAddress;
    // Info storing contract address
    address public infoContract;
    address public immutable implementationAddress;

    mapping(address => address) public stakingContracts;

    event StakingContractCreated(
        address indexed rewardToken,
        uint16 baseApy,
        address contractCreated
    );

    constructor(
        address _apolloFuelTank,
        address _a11PupStakingAddress,
        address _infoContract
    ) {
        apolloFuelTank = _apolloFuelTank;
        a11PupStakingAddress = _a11PupStakingAddress;
        infoContract = _infoContract;
        implementationAddress = address(new FactoryStaking());
    }

    // function createContract(address _rewardToken, uint16 _baseApy)
    //     external
    //     returns (address contractCreated)
    // {
    //     require(_rewardToken != address(0), "Factory: ZERO_ADDRESS");
    //     bytes memory bytecode = type(FactoryStaking).creationCode;
    //     bytes32 salt = keccak256(abi.encodePacked(_rewardToken, _baseApy));
    //     assembly {
    //         contractCreated := create2(
    //             0,
    //             add(bytecode, 32),
    //             mload(bytecode),
    //             salt
    //         )
    //     }
    //     IFactoryStaking(contractCreated).initialize(
    //         _rewardToken,
    //         _baseApy,
    //         apolloFuelTank,
    //         a11PupStakingAddress
    //     );

    //     stakingContracts[_rewardToken] = contractCreated;

    //     Iinfo info = Iinfo(infoContract);
    //     info.store(_rewardToken, contractCreated);

    //     emit StakingContractCreated(_rewardToken, _baseApy, contractCreated);
    // }

    function createContractClone(address _rewardToken, uint16 _baseApy)
        external
        returns (address contractCreated)
    {
        require(_rewardToken != address(0), "Factory: ZERO_ADDRESS");

        // bytes32 salt = keccak256(abi.encodePacked(_rewardToken, _baseApy));
        // implementationAddress = address(new FactoryStaking{salt: salt}());

        address factoryStaking = Clones.clone(implementationAddress);
        FactoryStaking(factoryStaking).initialize(
            _rewardToken,
            _baseApy,
            apolloFuelTank,
            a11PupStakingAddress
        );
        stakingContracts[_rewardToken] = factoryStaking;

        Iinfo info = Iinfo(infoContract);
        info.store(_rewardToken, contractCreated);

        emit StakingContractCreated(_rewardToken, _baseApy, contractCreated);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// interface IFactoryStaking {
//     function initialize(
//         address,
//         uint16,
//         address,
//         address
//     ) external;
// }

interface IStaking {
    struct User {
        uint256 tokenStaked;
        uint256 NFTStaked;
        uint256 VIPStaked;
        uint256 pendingForToken;
        uint256 pendingForNFT;
        uint256 pendingForVIP;
        uint256 claimedForToken;
        uint256 claimedForNFT;
        uint256 claimedForVIP;
        uint256 tokenPendingForToken;
        uint256 tokenPendingForNFT;
        uint256 reflectionClaimed;
    }

    function userInfo(address _user) external view returns (User memory);
}

contract FactoryStaking {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount; // The amount user decides to stake.
        uint256 timeAtSWC; // This time is updated everytime a user stakes, withdraws or compounds.
        uint256 rewardDebt; // The amount user has claimed.
    }

    // Info of each pool.
    struct PoolInfo {
        address token; // Address of stake token contract.
        uint16 apy; // Base APY in basis points.
    }

    // Fee constants
    uint256 public nftBoost = 2500;
    uint256 public tokenLevelOneBoost = 12500;
    uint256 public tokenLevelTwoBoost = 15000;
    uint256 public tokenLevelThreeBoost = 17500;
    uint256 public totalStaked;
    uint256 public totalclaimed;

    // Factory address.
    address public factory;
    // Fee address
    address public apolloFuelTank;
    // Enter 0 to view the pool info.
    PoolInfo public poolInfo;
    // Info of each user that stakes tokens.
    mapping(address => UserInfo) public userInfo;
    // Staking contract address of a11 token and pup NFT.
    address public a11PupStakingAddress;

    event Stake(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Harvest(address indexed user, uint256 rewardsReceived);
    event Compound(
        address indexed user,
        uint256 amountBeforeCompound,
        uint256 amountAfterCompound
    );
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor() {
        factory = msg.sender;
    }

    // Called once by the factory at time of deployment.
    function initialize(
        address _rewardToken,
        uint16 _baseAPY,
        address _apolloFuelTank,
        address _a11PupStakingAddress
    ) external {
        // require(msg.sender == factory, "Staking: FORBIDDEN"); // sufficient check

        apolloFuelTank = _apolloFuelTank;
        a11PupStakingAddress = _a11PupStakingAddress;

        PoolInfo({token: _rewardToken, apy: _baseAPY});
    }

    // Function to check if user has staked A11, Pup.
    function checkStakeAmount(address _user)
        internal
        view
        returns (uint256[] memory)
    {
        IStaking sc = IStaking(a11PupStakingAddress);
        IStaking.User memory user = sc.userInfo(_user);

        uint256[] memory array = new uint256[](2);
        array[0] = user.tokenStaked;
        array[1] = user.NFTStaked;

        return array;
    }

    function apyBoost() internal view returns (uint256) {
        uint256[] memory array = checkStakeAmount(msg.sender);
        uint256 tokenStaked = array[0];
        uint256 nftStaked = array[1];

        uint256 apyboost = poolInfo.apy;

        // 9 decimal places for apollo token.
        uint256 thirtyK = 30000000000000;
        uint256 sixtyK = 60000000000000;
        uint256 oneEightyK = 180000000000000;

        if (nftStaked > 0) {
            apyboost = apyboost.add(nftBoost);
        }

        if (tokenStaked >= thirtyK && tokenStaked < sixtyK) {
            apyboost = apyboost.mul(tokenLevelOneBoost);
        }
        if (tokenStaked >= sixtyK && tokenStaked < oneEightyK) {
            apyboost = apyboost.mul(tokenLevelTwoBoost);
        }
        if (tokenStaked >= oneEightyK) {
            apyboost = apyboost.mul(tokenLevelThreeBoost);
        }

        return apyboost;
    }

    function changeLevelOneBoost(uint256 _boost) external {
        tokenLevelOneBoost = _boost;
    }

    function changeLevelTwoBoost(uint256 _boost) external {
        tokenLevelTwoBoost = _boost;
    }

    function changeLevelThreeBoost(uint256 _boost) external {
        tokenLevelThreeBoost = _boost;
    }

    // 1 year = 31536000 seconds.
    function pendingRewards(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        require(user.amount > 0, "staked amount is null");

        uint256 lockPeriod = block.timestamp.sub(user.timeAtSWC);
        uint256 apy = apyBoost();
        uint256 rewards = user.amount.mul(apy).mul(lockPeriod).div(
            uint256(315360000000)
        );

        return rewards;
    }

    function compound() external {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount > 0, "compound: staked amount is null");

        uint256 pending = pendingRewards(msg.sender);
        require(pending > 0, "compound: rewards not accumulated yet");

        user.amount = user.amount.add(pending);
        user.timeAtSWC = block.timestamp;
        totalStaked = totalStaked.add(pending);

        emit Compound(msg.sender, user.amount.sub(pending), user.amount);
    }

    function harvest() external {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount > 0, "harvest: staked amount is null");

        // check pending rewards, if pending > 0, give rewards to user
        uint256 pending = pendingRewards(msg.sender);
        require(pending > 0, "harvest: rewards not accumulated yet");
        IERC20(poolInfo.token).safeTransfer(msg.sender, pending);

        user.rewardDebt = user.rewardDebt.add(pending);

        emit Harvest(msg.sender, pending);
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "stake: amount cannot be null");
        UserInfo storage user = userInfo[msg.sender];

        if (user.amount > 0) {
            uint256 pending = pendingRewards(msg.sender);
            if (pending > 0) {
                IERC20(poolInfo.token).safeTransfer(msg.sender, pending);
            }
        }

        IERC20(poolInfo.token).safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        uint256 depositFee = _amount.mul(5).div(100);
        // 50% fee stays in the pool and 50% goes to fee address
        IERC20(poolInfo.token).safeTransfer(apolloFuelTank, depositFee.div(2));

        user.amount = user.amount.add(_amount).sub(depositFee);
        user.timeAtSWC = block.timestamp;
        totalStaked = totalStaked.add(_amount);

        emit Stake(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external {
        require(_amount > 0, "withdraw: amount cannot be null");
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        uint256 pending = pendingRewards(msg.sender);
        if (pending > 0) {
            IERC20(poolInfo.token).safeTransfer(msg.sender, pending);
        }

        uint256 withdrawFee = _amount.mul(10).div(100);
        IERC20(poolInfo.token).safeTransfer(
            address(msg.sender),
            _amount.sub(withdrawFee)
        );
        // 50% fee stays in the pool and 50% goes to fee address
        IERC20(poolInfo.token).safeTransfer(apolloFuelTank, withdrawFee.div(2));

        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.rewardDebt.add(pending);
        user.timeAtSWC = block.timestamp;
        totalclaimed = totalclaimed.add(_amount);

        emit Withdraw(msg.sender, _amount);
    }

    function emergencyWithdraw() public {
        UserInfo storage user = userInfo[msg.sender];

        require(user.amount > 0, "emergencyWithdraw: not good");

        // Note: transfer can fail or succeed if `amount` is zero.
        uint256 withdrawFee = user.amount.mul(10).div(100);
        IERC20(poolInfo.token).safeTransfer(
            address(msg.sender),
            user.amount.sub(withdrawFee)
        );
        // 50% fee stays in the pool and 50% goes to fee address
        IERC20(poolInfo.token).safeTransfer(apolloFuelTank, withdrawFee.div(2));

        user.amount = 0;
        user.rewardDebt = 0;
        totalclaimed = totalclaimed.add(user.amount);

        emit EmergencyWithdraw(msg.sender, user.amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/Clones.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
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
        return functionCall(target, data, "Address: low-level call failed");
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}