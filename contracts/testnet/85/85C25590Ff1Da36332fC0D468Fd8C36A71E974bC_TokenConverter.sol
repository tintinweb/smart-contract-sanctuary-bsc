// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './interfaces/IKeeperRegistry.sol';
import './RegistryHelper.sol';
import './interfaces/IBEP20.sol';
import './interfaces/IUniswapV2Router02.sol';

contract TokenConverter is RegistryHelper {
	uint256 public MIN_BALANCE_MULTIPLIER;
	uint256 public TOP_UP_MULTIPLIER;

	IUniswapV2Router02 router;
	IKeeperRegistry keeperRegistry;

	event TopUpPerformed(uint256 upkeepId, uint256 topUpAmount, uint256 timeStamp);

	constructor(address _mainRegistry) RegistryHelper(_mainRegistry) {
		address routerAddress = registry.getUniswapRouter();
		address keeperRegistryAddress = registry.getKeeperRegistry();
		require(
			routerAddress != address(0) && keeperRegistryAddress != address(0),
			'TokenConverter: INVALID ROUTER OR KEEPER'
		);

		router = IUniswapV2Router02(routerAddress);
		keeperRegistry = IKeeperRegistry(keeperRegistryAddress);

		MIN_BALANCE_MULTIPLIER = 3;
		TOP_UP_MULTIPLIER = 4;
	}

	function isLowBalance(uint256 _upkeepId) public view returns (bool isLow) {
		(, , , uint96 currentUpkeepBalance, , , ) = keeperRegistry.getUpkeep(_upkeepId);

		// Check if balance is above the threshold
		if (
			currentUpkeepBalance <=
			keeperRegistry.getMinBalanceForUpkeep(_upkeepId) * MIN_BALANCE_MULTIPLIER
		) {
			isLow = true;
		}
	}

	function topupUpkeep(uint256 _upkeepId) public returns (bool topupPerform) {
		if (isLowBalance(_upkeepId)) {
			address token = registry.getPMAToken();
			uint256 pmaBalance = IBEP20(token).balanceOf(address(this));
			address LinkToken = keeperRegistry.LINK();
			address[] memory path = new address[](2);
			path[0] = token;
			path[1] = LinkToken;
			uint256 topUpAmount = (pmaBalance * TOP_UP_MULTIPLIER) / 100;

			if (topUpAmount > 0) {
				uint256[] memory amounts = router.swapExactTokensForTokens(
					topUpAmount,
					1,
					path,
					address(this),
					block.timestamp + 30
				);

				topupPerform = true;

				// approve Link tokens to Keeper Registry
				require(IBEP20(LinkToken).approve(address(keeperRegistry), amounts[1]));

				// add funds to upkeep
				keeperRegistry.addFunds(_upkeepId, uint96(amounts[1]));

				emit TopUpPerformed(_upkeepId, amounts[1], block.timestamp);
			}
		}
	}
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './ICoreRegistry.sol';
import './IPullPaymentConfig.sol';

interface IRegistry is ICoreRegistry, IPullPaymentConfig {
	function getPMAToken() external view returns (address);

	function getWBNBToken() external view returns (address);

	function getFreezer() external view returns (address);

	function getExecutor() external view returns (address);

	function getUniswapFactory() external view returns (address);

	function getUniswapPair() external view returns (address);

	function getUniswapRouter() external view returns (address);

	function getPullPaymentRegistry() external view returns (address);

	function getKeeperRegistry() external view returns (address);

	function getTokenConverter() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPullPaymentConfig {
	function getSupportedTokens() external view returns (address[] memory);

	function isSupportedToken(address _tokenAddress) external view returns (bool isExists);

	function executionFeeReceiver() external view returns (address);

	function executionFee() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IKeeperRegistry {
    event ConfigSet(
        uint32 paymentPremiumPPB,
        uint24 blockCountPerTurn,
        uint32 checkGasLimit,
        uint24 stalenessSeconds,
        uint16 gasCeilingMultiplier,
        uint256 fallbackGasPrice,
        uint256 fallbackLinkPrice
    );
    event FlatFeeSet(uint32 flatFeeMicroLink);
    event FundsAdded(uint256 indexed id, address indexed from, uint96 amount);
    event FundsWithdrawn(uint256 indexed id, uint256 amount, address to);
    event KeepersUpdated(address[] keepers, address[] payees);
    event OwnershipTransferRequested(address indexed from, address indexed to);
    event OwnershipTransferred(address indexed from, address indexed to);
    event Paused(address account);
    event PayeeshipTransferRequested(
        address indexed keeper,
        address indexed from,
        address indexed to
    );
    event PayeeshipTransferred(
        address indexed keeper,
        address indexed from,
        address indexed to
    );
    event PaymentWithdrawn(
        address indexed keeper,
        uint256 indexed amount,
        address indexed to,
        address payee
    );
    event RegistrarChanged(address indexed from, address indexed to);
    event Unpaused(address account);
    event UpkeepCanceled(uint256 indexed id, uint64 indexed atBlockHeight);
    event UpkeepPerformed(
        uint256 indexed id,
        bool indexed success,
        address indexed from,
        uint96 payment,
        bytes performData
    );
    event UpkeepRegistered(
        uint256 indexed id,
        uint32 executeGas,
        address admin
    );

    function FAST_GAS_FEED() external view returns (address);

    function LINK() external view returns (address);

    function LINK_ETH_FEED() external view returns (address);

    function acceptOwnership() external;

    function acceptPayeeship(address keeper) external;

    function addFunds(uint256 id, uint96 amount) external;

    function cancelUpkeep(uint256 id) external;

    function checkUpkeep(uint256 id, address from)
        external
        returns (
            bytes memory performData,
            uint256 maxLinkPayment,
            uint256 gasLimit,
            uint256 adjustedGasWei,
            uint256 linkEth
        );

    function getCanceledUpkeepList() external view returns (uint256[] memory);

    function getConfig()
        external
        view
        returns (
            uint32 paymentPremiumPPB,
            uint24 blockCountPerTurn,
            uint32 checkGasLimit,
            uint24 stalenessSeconds,
            uint16 gasCeilingMultiplier,
            uint256 fallbackGasPrice,
            uint256 fallbackLinkPrice
        );

    function getFlatFee() external view returns (uint32);

    function getKeeperInfo(address query)
        external
        view
        returns (
            address payee,
            bool active,
            uint96 balance
        );

    function getKeeperList() external view returns (address[] memory);

    function getMaxPaymentForGas(uint256 gasLimit)
        external
        view
        returns (uint96 maxPayment);

    function getMinBalanceForUpkeep(uint256 id)
        external
        view
        returns (uint96 minBalance);

    function getRegistrar() external view returns (address);

    function getUpkeep(uint256 id)
        external
        view
        returns (
            address target,
            uint32 executeGas,
            bytes memory checkData,
            uint96 balance,
            address lastKeeper,
            address admin,
            uint64 maxValidBlocknumber
        );

    function getUpkeepCount() external view returns (uint256);

    function onTokenTransfer(
        address sender,
        uint256 amount,
        bytes memory data
    ) external;

    function owner() external view returns (address);

    function pause() external;

    function paused() external view returns (bool);

    function performUpkeep(uint256 id, bytes memory performData)
        external
        returns (bool success);

    function recoverFunds() external;

    function registerUpkeep(
        address target,
        uint32 gasLimit,
        address admin,
        bytes memory checkData
    ) external returns (uint256 id);

    function setConfig(
        uint32 paymentPremiumPPB,
        uint32 flatFeeMicroLink,
        uint24 blockCountPerTurn,
        uint32 checkGasLimit,
        uint24 stalenessSeconds,
        uint16 gasCeilingMultiplier,
        uint256 fallbackGasPrice,
        uint256 fallbackLinkPrice
    ) external;

    function setKeepers(address[] memory keepers, address[] memory payees)
        external;

    function setRegistrar(address registrar) external;

    function transferOwnership(address to) external;

    function transferPayeeship(address keeper, address proposed) external;

    function typeAndVersion() external view returns (string memory);

    function unpause() external;

    function withdrawFunds(uint256 id, address to) external;

    function withdrawPayment(address from, address to) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICoreRegistry {
	function setAddressFor(string calldata, address) external;

	function getAddressForOrDie(bytes32) external view returns (address);

	function getAddressFor(bytes32) external view returns (address);

	function isOneOf(bytes32[] calldata, address) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
	/**
	 * @dev Returns the amount of tokens in existence.
	 */
	function totalSupply() external view returns (uint256);

	/**
	 * @dev Returns the token decimals.
	 */
	function decimals() external view returns (uint8);

	/**
	 * @dev Returns the token symbol.
	 */
	function symbol() external view returns (string memory);

	/**
	 * @dev Returns the token name.
	 */
	function name() external view returns (string memory);

	/**
	 * @dev Returns the bep token owner.
	 */
	function getOwner() external view returns (address);

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
	function allowance(address _owner, address spender) external view returns (uint256);

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
	function transferFrom(
		address sender,
		address recipient,
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
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/IRegistry.sol';

/**
 * @title RegistryHelper - initializer for core registry
 * @author The Pumapay Team
 * @notice This contract helps to initialize the core registry contract in parent contracts.
 */
contract RegistryHelper is Ownable {
	/*
   	=======================================================================
   	======================== Public variatibles ===========================
   	=======================================================================
 	*/
	/// @notice The core registry contract
	IRegistry public registry;

	/*
   	=======================================================================
   	======================== Constructor/Initializer ======================
   	=======================================================================
 	*/
	/**
	 * @notice Used in place of the constructor to allow the contract to be upgradable via proxy.
	 * @dev initializes the core registry with registry address
	 */
	constructor(address _registryAddress) {
		setRegistry(_registryAddress);
	}

	/*
   	=======================================================================
   	======================== Events =======================================
 	=======================================================================
 	*/
	event RegistrySet(address indexed registryAddress);

	/*
   	=======================================================================
   	======================== Public Methods ===============================
   	=======================================================================
 	*/

	/**
	 * @notice Updates the address pointing to a Registry contract.
	 * @dev only owner can set the registry address.
	 * @param registryAddress - The address of a registry contract for routing to other contracts.
	 */
	function setRegistry(address registryAddress) public virtual onlyOwner {
		require(registryAddress != address(0), 'RegistryHelper: CANNOT_REGISTER_ZERO_ADDRESS');
		registry = IRegistry(registryAddress);
		emit RegistrySet(registryAddress);
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