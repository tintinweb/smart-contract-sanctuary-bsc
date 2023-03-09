pragma solidity ^0.8.9;

// imports
import "../interfaces/IStargateRouter.sol";
import "./ProtocolDriver.sol";

// libraries
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StargateDriver is ProtocolDriver{
    using SafeMath for uint256;

    struct VaultDescriptor {
        uint16 chainId;
        address vaultAddress;
    }

    struct StargateDriverConfig {
        address stgRouter;
        address stgLPStaking;
        VaultDescriptor[] vaults;
    }

    bytes32 public constant CONFIG_SLOT = keccak256("StargateDriver.config");
    function configDriver(bytes calldata params) public override onlyOwner returns (bytes memory) {
        // Unpack into _getConfig().stgRouter, stgLPStaking
        (address _stgRouter, address _stgLPStaking) = abi.decode(params, (address, address));
        StargateDriverConfig storage _config = _getConfig();
        _config.stgRouter = _stgRouter;
        _config.stgLPStaking = _stgLPStaking;
    }

    function registerVault(uint16 _chainId, address _vaultAddress) public onlyOwner {
        StargateDriverConfig storage _config = _getConfig();
        bool flagExist = false;
        // if it already exists, update vault address 
        for (uint256 i = 0; i < _config.vaults.length; i++) {
            if (_config.vaults[i].chainId == _chainId) {
                _config.vaults[i].vaultAddress = _vaultAddress;
                flagExist = true;
                break;
            }
        }
        
        if (!flagExist) {   // if new vault, add it.
            VaultDescriptor memory _newVault;
            _newVault.chainId = _chainId;
            _newVault.vaultAddress = _vaultAddress;
            _config.vaults.push(_newVault);
        }
    }

    function _getConfig() internal view returns (StargateDriverConfig storage _config) {
        // pure?
        bytes32 slotAddress = CONFIG_SLOT;
        assembly {
            _config.slot := slotAddress
        }
    }
    function execute(ActionType _actionType, bytes calldata _payload) public override returns (bytes memory response) {
        if (_actionType == ActionType.Stake) {
            _stake(_payload);
        }
        else if (_actionType == ActionType.Unstake) {
            _unstake(_payload);
        }
        else if (_actionType == ActionType.SwapRemote) {
            _swapRemote(_payload);
        }
        else if (_actionType == ActionType.GetStakedAmount) {
            response = _getStakedAmount();
        }
        else {
            revert("Undefined Action");
        }
    }
    function _stake(bytes calldata _payload) private {
        (uint256 _amountLD, address _token) = abi.decode(_payload, (uint256, address));
        require (_amountLD > 0, "Cannot stake zero amount");
        
        // Get pool and poolId
        address _pool = getStargatePoolFromToken(_token);
        (bool _success, bytes memory _response) = _pool.call(abi.encodeWithSignature("poolId()"));
        require(_success, "Failed to call poolId");
        uint256 _poolId = abi.decode(_response, (uint256));
        
        // Approve token transfer from vault to STG.Pool
        address _stgRouter = _getConfig().stgRouter;
        IERC20(_token).approve(_stgRouter, _amountLD);
        
        // Stake token from vault to STG.Pool and get LPToken
        // 1. Pool.LPToken of vault before
        (_success, _response) = _pool.call(abi.encodeWithSignature("balanceOf(address)", address(this)));
        require(_success, "Failed to call balanceOf");
        uint256 balancePre = abi.decode(_response, (uint256));
        // 2. Vault adds liquidity
        IStargateRouter(_stgRouter).addLiquidity(_poolId, _amountLD, address(this));
        // 3. Pool.LPToken of vault after
        (_success, _response) = _pool.call(abi.encodeWithSignature("balanceOf(address)", address(this)));
        require(_success, "Failed to call balanceOf");
        uint256 balanceAfter = abi.decode(_response, (uint256));
        // 4. Increased LPToken of vault
        uint256 amountLPToken = balanceAfter - balancePre;
        
        // Find the Liquidity Pool's index in the Farming Pool.
        (bool found, uint256 stkPoolIndex) = getPoolIndexInFarming(_poolId);
        require(found, "The LP token not acceptable.");
        
        // Approve LPToken transfer from vault to LPStaking
        address _stgLPStaking = _getConfig().stgLPStaking;
        (_success, ) = _pool.call(abi.encodeWithSignature("approve(address,uint256)", _stgLPStaking, amountLPToken));
        require(_success, "Failed to call approve");

        // Stake LPToken from vault to LPStaking
        (_success, ) = _stgLPStaking.call(abi.encodeWithSignature("deposit(uint256,uint256)", stkPoolIndex, amountLPToken));
        require(_success, "Failed to call deposit");
    }

    function _unstake(bytes calldata _payload) private {
        (uint256 _amountLPToken, address _token) = abi.decode(_payload, (uint256, address));
        require (_amountLPToken > 0, "Cannot unstake zero amount");

        // Get pool and poolId
        address _pool = getStargatePoolFromToken(_token);
        (bool _success, bytes memory _response) = _pool.call(abi.encodeWithSignature("poolId()"));
        require(_success, "Failed to call poolId");
        uint256 _poolId = abi.decode(_response, (uint256));

        // Find the Liquidity Pool's index in the Farming Pool.
        (bool found, uint256 stkPoolIndex) = getPoolIndexInFarming(_poolId);
        require(found, "The LP token not acceptable.");

        // Withdraw LPToken from LPStaking to vault
        // 1. Pool.LPToken of vault before
        (_success, _response) = _pool.call(abi.encodeWithSignature("balanceOf(address)", address(this)));
        require(_success, "Failed to call balanceOf");
        uint256 balancePre = abi.decode(_response, (uint256));
        // 2. Withdraw LPToken from LPStaking to vault
        address _stgLPStaking = _getConfig().stgLPStaking;
        (_success, ) = _stgLPStaking.call(abi.encodeWithSignature("withdraw(uint256,uint256)", stkPoolIndex, _amountLPToken));
        require(_success, "Failed to call withdraw");
        // 3. Pool.LPToken of vault after
        (_success, _response) = _pool.call(abi.encodeWithSignature("balanceOf(address)", address(this)));
        require(_success, "Failed to call balanceOf");
        uint256 balanceAfter = abi.decode(_response, (uint256));
        // 4. Increased LPToken of vault
        uint256 _amountLPTokenWithdrawn = balanceAfter - balancePre;

        // Give LPToken and redeem token from STG.Pool to vault
        address _stgRouter = _getConfig().stgRouter;
        IStargateRouter(_stgRouter).instantRedeemLocal(uint16(_poolId), _amountLPTokenWithdrawn, address(this));
    }

    function _swapRemote(bytes calldata _payload) private {
        uint256 _amountLD;
        uint16 _dstChainId;
        uint256 _dstPoolId;
        uint256 _srcPoolId;
        uint256 _nativeFee;
        address _router;
        // To avoid stack deep error
        {
            address _srcToken;
            (_amountLD, _srcToken, _dstChainId, _dstPoolId, _nativeFee) = abi.decode(_payload, (uint256, address, uint16, uint256, uint256));
            require (_amountLD > 0, "Cannot stake zero amount");

            address _srcPool = getStargatePoolFromToken(_srcToken);
            (bool _success, bytes memory _response) = _srcPool.call(abi.encodeWithSignature("poolId()"));
            require(_success, "Failed to call poolId");
            _srcPoolId = abi.decode(_response, (uint256));

            _router = _getConfig().stgRouter;
            IERC20(_srcToken).approve(_router, _amountLD);
        }

        address _to = address(0x0);
        {
            for (uint256 i = 0; i < _getConfig().vaults.length; i++) {
                if (_getConfig().vaults[i].chainId == _dstChainId) {
                    _to = _getConfig().vaults[i].vaultAddress;
                }
            }
            require(_to != address(0x0), "StargateDriver: _to cannot be 0x0");
        }

        // Swap
        IStargateRouter(_router).swap{value:_nativeFee}(_dstChainId, _srcPoolId, _dstPoolId, payable(address(this)), _amountLD, 0, IStargateRouter.lzTxObj(0, 0, "0x"), abi.encodePacked(_to), bytes(""));
    }

    function _getStakedAmount() private returns (bytes memory response) {
        uint256 _amountStaked = 0;
        address _stgLPStaking = _getConfig().stgLPStaking;
        (bool _success, bytes memory _response) = address(_stgLPStaking).call(abi.encodeWithSignature("poolLength()"));
        require(_success, "Failed to get LPStaking.poolLength");
        uint256 _poolLength = abi.decode(_response, (uint256));

        for (uint256 poolIndex = 0; poolIndex < _poolLength; poolIndex++) {
            // 1. Collect pending STG rewards
            (_success, ) = address(_stgLPStaking).call(abi.encodeWithSignature("withdraw(uint256,uint256)", poolIndex, 0));
            require(_success, "Failed to LPStaking.withdraw");

            // 2. Check total staked assets measured as stablecoin
            (_success, _response) = address(_stgLPStaking).call(abi.encodeWithSignature("getPoolInfo(uint256)", poolIndex));
            require(_success, "Failed to LPStaking.getPoolInfo");
            address _pool = abi.decode(_response, (address));
            
            (_success, _response) = address(_pool).call(abi.encodeWithSignature("balanceOf(address)", address(this)));
            require(_success, "Failed to Pool.balanceOf");
            uint256 _amountLPToken = abi.decode(_response, (uint256));
            
            (_success, _response) = address(_pool).call(abi.encodeWithSignature("totalLiquidity()"));
            require(_success, "Failed to Pool.totalLiquidity");
            uint256 _totalLiquidity = abi.decode(_response, (uint256));
            
            (_success, _response) = address(_pool).call(abi.encodeWithSignature("convertRate()"));
            require(_success, "Failed to Pool.convertRate");
            uint256 _convertRate = abi.decode(_response, (uint256));
            
            uint256 _totalLiquidityLD = _totalLiquidity.mul(_convertRate);
            
            (_success, _response) = address(_pool).call(abi.encodeWithSignature("totalSupply()"));
            require(_success, "Failed to Pool.totalSupply");
            uint256 _totalSupply = abi.decode(_response, (uint256));
            
            if (_totalSupply > 0) {
                _amountStaked = _amountStaked.add(_totalLiquidityLD.mul(_amountLPToken).div(_totalSupply));
            }
        }

        response = abi.encode(_amountStaked);
    }

    function getStargatePoolFromToken(address _token) public returns (address) {
        address _router = _getConfig().stgRouter;
        
        (bool _success, bytes memory _response) = address(_router).call(abi.encodeWithSignature("factory()"));
        require(_success, "Failed to get factory in StargateDriver");
        address _factory = abi.decode(_response, (address));

        (_success, _response) = _factory.call(abi.encodeWithSignature("allPoolsLength()"));
        require(_success, "Failed to get allPoolsLength");
        uint256 _allPoolsLength = abi.decode(_response, (uint256));

        for (uint i = 0; i < _allPoolsLength; i++) {
            (_success, _response) = _factory.call(abi.encodeWithSignature("allPools(uint256)", i));
            require(_success, "Failed to get allPools");
            address _pool = abi.decode(_response, (address));

            (_success, _response) = _pool.call(abi.encodeWithSignature("token()"));
            require(_success, "Failed to call token");
            address _poolToken = abi.decode(_response, (address));

            if (_poolToken == _token) {
                return _pool;
            }
        }
        // revert when not found.
        revert("Pool not found for token");
    }

    
    function _getPool(uint256 _poolId) internal returns (address _pool) {
        address _router = _getConfig().stgRouter;

        (bool _success, bytes memory _response) = _router.call(abi.encodeWithSignature("factory()"));
        require(_success, "Failed to get factory in StargateDriver");
        address _factory = abi.decode(_response, (address));

        (_success, _response) = _factory.call(abi.encodeWithSignature("getPool(uint256)", _poolId));
        require(_success, "Failed to get pool in StargateDriver");
        _pool = abi.decode(_response, (address));
    }

    function convertSDtoLD(address _token, uint256 _amountSD) public returns (uint256) {
        // TODO: gas fee optimization by avoiding duplicate calculation.
        address _pool = getStargatePoolFromToken(_token);

        (bool _success, bytes memory _response) = _pool.call(abi.encodeWithSignature("convertRate()"));
        require(_success, "Failed to call convertRate");
        uint256 _convertRate = abi.decode(_response, (uint256));

        return  _amountSD.mul(_convertRate); // pool.amountSDtoLD(_amountSD);
    }

    function convertLDtoSD(address _token, uint256 _amountLD) public returns (uint256) {
        // TODO: gas fee optimization by avoiding duplicate calculation.
        address _pool = getStargatePoolFromToken(_token);

        (bool _success, bytes memory _response) = _pool.call(abi.encodeWithSignature("convertRate()"));
        require(_success, "Failed to call convertRate");
        uint256 _convertRate = abi.decode(_response, (uint256));

        return  _amountLD.div(_convertRate); // pool.amountLDtoSD(_amountLD);
    }

    function getPoolIndexInFarming(uint256 _poolId) public returns (bool, uint256) {
        address _pool = _getPool(_poolId);
        address _lpStaking = _getConfig().stgLPStaking;
        
        (bool _success, bytes memory _response) = address(_lpStaking).call(abi.encodeWithSignature("poolLength()"));
        require(_success, "Failed to get LPStaking.poolLength");
        uint256 _poolLength = abi.decode(_response, (uint256));

        for (uint256 poolIndex = 0; poolIndex < _poolLength; poolIndex++) {
            (_success, _response) = address(_lpStaking).call(abi.encodeWithSignature("getPoolInfo(uint256)", poolIndex));
            require(_success, "Failed to call getPoolInfo");
            address _pool__ = abi.decode(_response, (address));
            if (_pool__ == _pool) {
                return (true, poolIndex);
            }
        }
       
        return (false, 0);
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;
pragma abicoder v2;

interface IStargateRouter {
    struct lzTxObj {
        uint256 dstGasForCall;
        uint256 dstNativeAmount;
        bytes dstNativeAddr;
    }

    function addLiquidity(
        uint256 _poolId,
        uint256 _amountLD,
        address _to
    ) external;

    function swap(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLD,
        uint256 _minAmountLD,
        lzTxObj memory _lzTxParams,
        bytes calldata _to,
        bytes calldata _payload
    ) external payable;

    function redeemRemote(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        uint256 _minAmountLD,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;

    function instantRedeemLocal(
        uint16 _srcPoolId,
        uint256 _amountLP,
        address _to
    ) external returns (uint256);

    function redeemLocal(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;

    function sendCredits(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress
    ) external payable;

    function quoteLayerZeroFee(
        uint16 _dstChainId,
        uint8 _functionType,
        bytes calldata _toAddress,
        bytes calldata _transferAndCallPayload,
        lzTxObj memory _lzTxParams
    ) external view returns (uint256, uint256);
}

pragma solidity ^0.8.9;

// libraries
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract ProtocolDriver is Ownable {
    enum ActionType {
    // data types
        Swap,
        SwapRemote,
        GetPriceMil,
        Stake,
        Unstake,
        GetStakedAmount
    }

    function configDriver(bytes calldata params) public virtual onlyOwner returns (bytes memory) {
    }

    function execute(ActionType _actionType, bytes calldata _payload) public virtual returns (bytes memory) {
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