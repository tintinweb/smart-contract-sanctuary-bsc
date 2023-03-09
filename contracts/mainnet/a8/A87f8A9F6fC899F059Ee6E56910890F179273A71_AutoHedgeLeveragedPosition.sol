pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "../interfaces/IAutoHedgeLeveragedPosition.sol";
import "../interfaces/IAutoHedgeStableVolatileFactoryUpgradeableV2.sol";
import "../interfaces/IFinisher.sol";
import "../interfaces/IFlashloanWrapper.sol";
import "../interfaces/IMasterPriceOracle.sol";

contract AutoHedgeLeveragedPosition is
	Initializable,
	OwnableUpgradeable,
	ReentrancyGuardUpgradeable,
	IAutoHedgeLeveragedPosition
{
	function initialize(
		IAutoHedgeLeveragedPositionFactory factory_,
		IComptroller comptroller_,
		TokensLev memory tokens_
	) external override initializer {
		__Ownable_init_unchained();
		factory = factory_;
		tokens = tokens_;
		comptroller = comptroller_;

		// Enter the relevant markets on Fuse/Midas

		address[] memory cTokens = new address[](2);
		cTokens[0] = address(tokens.cStable);
		cTokens[1] = address(tokens.cAhlp);

		uint256[] memory results = comptroller.enterMarkets(cTokens);
		require(
			results[0] == 0 && results[1] == 0,
			string(
				abi.encodePacked(
					"AHLevPos: cant enter markets: ",
					Strings.toString(results[0]),
					" ",
					Strings.toString(results[1])
				)
			)
		);

		IERC20Metadata(address(tokens.pair)).approve(address(tokens.cAhlp), MAX_UINT);
		tokens.stable.approve(address(tokens.cStable), MAX_UINT);
	}

	using SafeERC20 for IERC20Metadata;

	uint256 private constant BASE_FACTOR = 1e18;
	uint256 private constant MAX_UINT = type(uint256).max;

	IAutoHedgeLeveragedPositionFactory public factory;

	IComptroller private comptroller;

	TokensLev private tokens;

	uint256 private _tempReturnAmount;

	modifier onlyFlw() {
		require(msg.sender == address(factory.flw()), "AHLev: caller is not flw");
		_;
	}

	/// @dev Estimate flashloan amount for deposit
	/// @param amountStableInit Amount of stable token to deposit
	/// @param leverageRatio Leverage ratio (18 decimals precision)
	/// @param pair Address of the AH pair
	/// @return amountStableToFlashloan Amount of stable token to flashloan
	/// @return amountStableFlashloanFee Amount of stable token flashloan fee
	function estimateFlashloanAmountForDeposit(
		uint256 amountStableInit,
		uint256 leverageRatio,
		address pair
	) private returns (uint256 amountStableToFlashloan, uint256 amountStableFlashloanFee) {
		IFlashloanWrapper flw = IFlashloanWrapper(factory.flw());

		uint256 flashLoanFee = flw.FLASH_LOAN_FEE();
		uint256 flashLoanFeePrecision = flw.FLASH_LOAN_FEE_PRECISION();

		IAutoHedgeStableVolatileFactoryUpgradeableV2 ahFactory = IAutoHedgeStableVolatilePairUpgradeableV2(
				pair
			).factory();

		// 18 decimals precision
		uint256 depositFee = ahFactory.depositFee();

		uint256 ahConvRate = 1 ether - depositFee;

		uint256 q = (amountStableInit * ahConvRate * (leverageRatio - 1 ether)) / 1 ether;

		uint256 r = (leverageRatio *
			(1 ether + (flashLoanFee * 1 ether) / flashLoanFeePrecision - ahConvRate)) /
			1 ether +
			ahConvRate;

		amountStableToFlashloan = q / r;
		amountStableFlashloanFee = (amountStableToFlashloan * flashLoanFee) / flashLoanFeePrecision;
	}

	/**
	 * @param amountStableDeposit   The amount of stables taken from the user
	 * The amount of stables to borrow from a flashloan which
	 *      is used to deposit (along with `amountStableDeposit`) to AH. Since there
	 *      is a fee for taking out a flashloan and depositing to AH, that's paid by
	 *      borrowing more stables, which therefore increases the leverage ratio. In
	 *      order to compensate for this, we need to have a reduced flashloan which
	 *      therefore lowers the total position size. Given `amountStableDeposit` and
	 *      the desired leverage ratio, we can calculate `amountStableFlashloan`
	 *      with these linear equations:
	 *          The flashloan fee is a % of the loan
	 *          (a) amountFlashloanFee = amountStableFlashloan*flashloanFeeRate
	 *
	 *          The value of the AH LP tokens after depositing is the total amount deposited,
	 *          which is the initial collateral and the amount from the flashloan, multiplied by
	 *          the amount that is kept after fees/costs
	 *          (b) amountStableAhlp = (amountStableDeposit + amountStableFlashloan)*ahConvRate
	 *
	 *          The amount being borrowed from Fuse needs to be enough to pay back the flashloan
	 *          and its fee
	 *          (c) amountStableBorrowed = amountStableFlashloan + amountFlashloanFee
	 *
	 *          The leverage ratio is the position size div by the 'collateral', i.e. how
	 *          much the user would be left with after withdrawing everything.
	 *          TODO: 'collateral' currently doesn't account for the flashloan fee when withdrawing
	 *          (d) leverage = amountStableAhlp / (amountStableAhlp - amountStableBorrowed)
	 *
	 *      Subbing (a) into (c):
	 *          (e) amountStableBorrowed = amountStableFlashloan + amountStableFlashloan*flashloanFeeRate
	 *          (f) amountStableBorrowed = amountStableFlashloan*(1 + flashloanFeeRate)
	 *          (g) amountStableFlashloan = amountStableBorrowed/(1 + flashloanFeeRate)
	 *
	 *      Rearranging (d):
	 *          (h) amountStableAhlp - amountStableBorrowed = amountStableAhlp/leverage
	 *          (i) amountStableBorrowed = amountStableAhlp*(1 - (1/leverage))
	 *
	 *      Subbing (i) into (g):
	 *          (j) amountStableFlashloan = (amountStableAhlp * (1 - (1/leverage))) / (1 + flashloanFeeRate)
	 *
	 *      Subbing (b) into (j):
	 *          (k) amountStableFlashloan = (((amountStableDeposit + amountStableFlashloan)*ahConvRate) * (1 - (1/leverage))) / (1 + flashloanFeeRate)
	 *      Rearranging, the general formula for `amountStableFlashloan` is:
	 *          (l) amountStableFlashloan = -(amountStableDeposit * ahConvRate * (leverage - 1)) / (ahConvRate * (leverage - 1) - leverage * (flashloanFeeRate + 1))
	 *
	 *      E.g. if amountStableDeposit = 10, ahConvRate = 0.991, leverage = 5, flashloanFeeRate = 0.0005
	 *          amountStableFlashloan = -(10 * 0.991 * (5 - 1)) / (0.991 * (5 - 1) - 5 * (0.0005 + 1))
	 *          amountStableFlashloan = 37.71646...
	 * @param leverageRatio The leverage ratio scaled to 1e18. Used to check that the leverage
	 *      is what is intended at the end of the fcn. E.g. if wanting 5x leverage, this should
	 *      be 5e18.
	 */
	function depositLev(
		address referrer,
		uint256 amountStableDeposit,
		uint256 leverageRatio,
		bool shouldReturnAmount
	) external onlyOwner nonReentrant returns (uint256 amountAhLp) {
		transferApproveUnapproved(address(tokens.pair), tokens.stable, amountStableDeposit);

		(uint256 amountStableToFlashloan, uint256 flashloanFee) = estimateFlashloanAmountForDeposit(
			amountStableDeposit,
			leverageRatio,
			address(tokens.pair)
		);

		IFlashloanWrapper.FinishRoute memory fr = IFlashloanWrapper.FinishRoute(
			address(this),
			address(this)
		);

		FinishDeposit memory fd = FinishDeposit(
			fr,
			amountStableDeposit,
			amountStableToFlashloan,
			referrer,
			shouldReturnAmount,
			0
		);

		// Take out a flashloan for the amount that needs to be borrowed
		bytes memory data = abi.encodeWithSelector(
			IAutoHedgeLeveragedPosition.finishDeposit.selector,
			abi.encode(fd)
		);
		IFlashloanWrapper flw = factory.flw();
		flw.takeOutFlashLoan(tokens.stable, amountStableToFlashloan, data);

		tokens.stable.safeTransfer(msg.sender, tokens.stable.balanceOf(address(this)));

		if (shouldReturnAmount) {
			amountAhLp = _tempReturnAmount;
		}

		// // TODO: Some checks requiring that the positions are what they should be everywhere
		// // TODO: Check that the collat ratio is above some value
		// // TODO: Do these checks on withdrawLev too
		emit DepositLev(amountStableDeposit, amountStableToFlashloan, flashloanFee, leverageRatio);
	}

	function finishDeposit(bytes calldata data) public override onlyFlw {
		FinishDeposit memory fd = abi.decode(data, (FinishDeposit));

		uint256 repayAmount = fd.amountStableToFlashloan + fd.flashloanFee;
		uint256 amountStable = fd.amountStableDeposit + fd.amountStableToFlashloan;

		approveUnapproved(address(tokens.pair), tokens.stable, amountStable);

		IFlashloanWrapper flw = factory.flw();

		uint256 amountAhLp = tokens.pair.deposit(
			amountStable,
			address(this),
			fd.referrer,
			fd.shouldReturnAmount
		);

		// Put all AHLP tokens as collateral
		uint256 ahlpBal = IERC20Metadata(address(tokens.pair)).balanceOf(address(this));
		uint256 code = tokens.cAhlp.mint(ahlpBal);
		require(
			code == 0,
			string(abi.encodePacked("AHLevPos: fuse mint ", Strings.toString(code)))
		);

		// Borrow the same amount of stables from Fuse/Midas as was borrowed in the flashloan
		// TODO: call approve on cStable
		approveUnapproved(address(tokens.cStable), tokens.stable, repayAmount);
		code = tokens.cStable.borrow(repayAmount);
		require(
			code == 0,
			string(abi.encodePacked("AHLevPos: fuse borrow ", Strings.toString(code)))
		);

		tokens.stable.safeTransfer(address(flw.sushiBentoBox()), repayAmount);

		if (fd.shouldReturnAmount) {
			_tempReturnAmount = amountAhLp;
		}
	}

	function estimateFlashloanAmountForWithdraw(uint256 amountAhlpRedeem)
		private
		returns (uint256 amountStableToFlashloan, uint256 amountStableFlashloanFee)
	{
		IFlashloanWrapper flw = IFlashloanWrapper(factory.flw());

		uint256 amountAhlpUnderlying = tokens.cAhlp.balanceOfUnderlying(address(this));
		uint256 amountStableOwed = tokens.cStable.borrowBalanceCurrent(address(this));
		amountStableToFlashloan = (amountStableOwed * amountAhlpRedeem) / amountAhlpUnderlying;

		uint256 flashLoanFee = flw.FLASH_LOAN_FEE();
		uint256 flashLoanFeePrecision = flw.FLASH_LOAN_FEE_PRECISION();

		amountStableFlashloanFee = (amountStableToFlashloan * flashLoanFee) / flashLoanFeePrecision;
	}

	/**
	 * @param amountAhlpRedeem The amount of stables to borrow from a flashloan and
	 *      repay the Fuse/Midas debt. This needs to account for the flashloan fee in
	 *      order to not increase the overall leverage level of the position. For example
	 *      if leverage is 10x and withdrawing $10 of stables to the user, means
	 *      withdrawing $100 of AHLP tokens, which means needing to flashloan borrow
	 *      $90 of stables - which has a fee of $0.27 if the fee is 0.3%. Therefore
	 *      `amountStableRepay` needs to be $90 / 0.997 = 90.2708... to account for
	 *      paying the $0.27 and then the extra $0.0008... for the fee on the $0.27 etc.
	 */
	function withdrawLev(uint256 amountAhlpRedeem, bool shouldReturnAmount)
		external
		onlyOwner
		nonReentrant
		returns (uint256 amountStableToUser)
	{
		(
			uint256 amountStableToFlashloan,
			uint256 flashloanFee
		) = estimateFlashloanAmountForWithdraw(amountAhlpRedeem);

		IFlashloanWrapper.FinishRoute memory fr = IFlashloanWrapper.FinishRoute(
			address(this),
			address(this)
		);

		FinishWithdraw memory fw = FinishWithdraw(
			fr,
			amountAhlpRedeem,
			amountStableToFlashloan,
			shouldReturnAmount,
			0
		);

		// Take a flashloan for the amount that needs to be borrowed
		bytes memory data = abi.encodeWithSelector(
			IAutoHedgeLeveragedPosition.finishWithdraw.selector,
			abi.encode(fw)
		);
		IFlashloanWrapper flw = factory.flw();
		flw.takeOutFlashLoan(tokens.stable, amountStableToFlashloan, data);

		if (shouldReturnAmount) {
			amountStableToUser = _tempReturnAmount;
		}

		emit WithdrawLev(amountAhlpRedeem, amountStableToFlashloan, flashloanFee);
	}

	function finishWithdraw(bytes calldata data) public override onlyFlw {
		FinishWithdraw memory fw = abi.decode(data, (FinishWithdraw));

		uint256 repayAmount = fw.amountStableToFlashloan + fw.flashloanFee;

		// Repay borrowed stables in Fuse to free up collat
		uint256 code = tokens.cStable.repayBorrow(fw.amountStableToFlashloan);
		require(
			code == 0,
			string(abi.encodePacked("AHLevPos: fuse repayBorrow ", Strings.toString(code)))
		);
		// Take the AHLP collat out of Fuse/Midas
		code = tokens.cAhlp.redeemUnderlying(fw.amountAhlpRedeem);
		require(
			code == 0,
			string(abi.encodePacked("AHLevPos: fuse redeemUnderlying ", Strings.toString(code)))
		);

		tokens.pair.withdraw(fw.amountAhlpRedeem, address(this), fw.shouldReturnAmount);
		uint256 amountStablesFromAhlp = tokens.stable.balanceOf(address(this));
		require(
			amountStablesFromAhlp >= repayAmount,
			"AHLevPos: withdrawal amount is less than flashloan"
		);
		// Repay the flashloan
		IFlashloanWrapper flw = factory.flw();
		tokens.stable.safeTransfer(address(flw.sushiBentoBox()), repayAmount);

		// Send the user their #madgainz
		tokens.stable.safeTransfer(owner(), amountStablesFromAhlp - repayAmount);

		if (fw.shouldReturnAmount) {
			_tempReturnAmount = amountStablesFromAhlp - repayAmount;
		}
	}

	// fcns to withdraw tokens incase of liquidation

	//////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////
	////                                                          ////
	////-------------------------Helpers--------------------------////
	////                                                          ////
	//////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////

	function approveUnapproved(
		address target,
		IERC20Metadata token,
		uint256 amount
	) private {
		if (token.allowance(address(this), address(target)) < amount) {
			token.approve(address(target), MAX_UINT);
		}
	}

	function transferApproveUnapproved(
		address target,
		IERC20Metadata token,
		uint256 amount
	) private {
		approveUnapproved(target, token, amount);
		token.safeTransferFrom(msg.sender, address(this), amount);
	}

	function getFeeFactor() external view returns (uint256) {
		IFlashloanWrapper flw = factory.flw();
		return flw.getFeeFactor();
	}
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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "./IComptroller.sol";
import "./ICErc20.sol";
import "./IAutoHedgeStableVolatilePairUpgradeableV2.sol";
import "./IFlashloanWrapper.sol";
import "./IAutoHedgeLeveragedPositionFactory.sol";

interface IAutoHedgeLeveragedPosition {
	struct TokensLev {
		IERC20Metadata stable;
		ICErc20 cStable;
		IERC20Metadata vol;
		IAutoHedgeStableVolatilePairUpgradeableV2 pair;
		ICErc20 cAhlp;
	}

	struct FinishDeposit {
		IFlashloanWrapper.FinishRoute fr;
		uint256 amountStableDeposit;
		uint256 amountStableToFlashloan;
		address referrer;
		bool shouldReturnAmount;
		uint256 flashloanFee;
	}

	struct FinishWithdraw {
		IFlashloanWrapper.FinishRoute fr;
		uint256 amountAhlpRedeem;
		uint256 amountStableToFlashloan;
		bool shouldReturnAmount;
		uint256 flashloanFee;
	}

	event DepositLev(
		uint256 amountStableDeposit,
		uint256 amountStableFlashloan,
		uint256 amountStableFlashloanFee,
		uint256 leverageRatio
	);

	event WithdrawLev(
		uint256 amountAhlpRedeem,
		uint256 amountStableFlashloan,
		uint256 amountStableFlashloanFee
	);

	function initialize(
		IAutoHedgeLeveragedPositionFactory factory_,
		IComptroller comptroller,
		TokensLev memory tokens_
	) external;

	function finishDeposit(bytes calldata data) external;

	function finishWithdraw(bytes calldata data) external;
}

pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";
import "./IComptroller.sol";
import "./IAutoHedgeStableVolatilePairUpgradeableV2.sol";

interface IAutoHedgeStableVolatileFactoryUpgradeableV2 {
	event PairCreated(
		IERC20Metadata indexed stable,
		IERC20Metadata indexed vol,
		address pair,
		uint256
	);
	event FeeReceiverSet(address indexed receiver);
	event DepositFeeSet(uint256 fee);

	function initialize(
		address beacon_,
		address weth_,
		IUniswapV2Factory uniV2Factory_,
		IUniswapV2Router02 uniV2Router_,
		IComptroller comptroller_,
		address payable registry_,
		address userFeeVeriForwarder_,
		IAutoHedgeStableVolatilePairUpgradeableV2.MmBps memory initMmBps_,
		address feeReceiver_,
		address flw_,
		address wu_
	) external;

	function flw() external view returns (address);

	function getPair(IERC20Metadata stable, IERC20Metadata vol)
		external
		view
		returns (address pair);

	function allPairs(uint256) external view returns (address pair);

	function allPairsLength() external view returns (uint256);

	function createPair(IERC20Metadata stable, IERC20Metadata vol) external returns (address pair);

	function setFeeReceiver(address newReceiver) external;

	function setDepositFee(uint256 newDepositFee) external;

	function uniV2Factory() external view returns (IUniswapV2Factory);

	function uniV2Router() external view returns (IUniswapV2Router02);

	function registry() external view returns (address payable);

	function userFeeVeriForwarder() external view returns (address);

	function feeReceiver() external view returns (address);

	function depositFee() external view returns (uint256);
}

pragma solidity 0.8.6;

interface IFinisher {
    function onFlw(
        uint256 amount,
        uint256 fee,
        bytes memory data
    ) external;
}

pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IBentoBox.sol";

enum FlashloanType {
	Deposit,
	Withdraw
}

interface IFlashloanWrapper {
	event Flashloan(
		address indexed receiver,
		IERC20 token,
		uint256 amount,
		uint256 fee,
		uint256 loanType
	);

	event FlashloanRepaid(address indexed to, uint256 amount);

	struct FinishRoute {
		address flwCaller;
		address target;
	}

	function takeOutFlashLoan(
		IERC20 token,
		uint256 amount,
		bytes calldata data
	) external;

	function repayFlashLoan(IERC20 token, uint256 amount) external;

	function getFeeFactor() external view returns (uint256);

	function sushiBentoBox() external view returns (IBentoBox);

	function FLASH_LOAN_FEE() external view returns (uint256);

	function FLASH_LOAN_FEE_PRECISION() external view returns (uint256);
}

pragma solidity 0.8.6;

interface IMasterPriceOracle {
	function price(address underlying) external returns (uint256);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

pragma solidity 0.8.6;

interface IComptrollerStorage {
	function cTokensByUnderlying(address underlying) external view returns (address);
}

interface IComptroller is IComptrollerStorage {
	/// @notice Indicator that this is a Comptroller contract (for inspection)
	//    bool public constant isComptroller = true; TODO Variables cannot be declared in interfaces.

	/*** Assets You Are In ***/

	function enterMarkets(address[] calldata cTokens) external returns (uint256[] memory);

	function exitMarket(address cToken) external returns (uint256);

	/*** Policy Hooks ***/

	function mintAllowed(
		address cToken,
		address minter,
		uint256 mintAmount
	) external returns (uint256);

	function mintWithinLimits(
		address cToken,
		uint256 exchangeRateMantissa,
		uint256 accountTokens,
		uint256 mintAmount
	) external returns (uint256);

	function mintVerify(
		address cToken,
		address minter,
		uint256 mintAmount,
		uint256 mintTokens
	) external;

	function redeemAllowed(
		address cToken,
		address redeemer,
		uint256 redeemTokens
	) external returns (uint256);

	function redeemVerify(
		address cToken,
		address redeemer,
		uint256 redeemAmount,
		uint256 redeemTokens
	) external;

	function borrowAllowed(
		address cToken,
		address borrower,
		uint256 borrowAmount
	) external returns (uint256);

	function borrowWithinLimits(address cToken, uint256 accountBorrowsNew)
		external
		returns (uint256);

	function borrowVerify(
		address cToken,
		address borrower,
		uint256 borrowAmount
	) external;

	function repayBorrowAllowed(
		address cToken,
		address payer,
		address borrower,
		uint256 repayAmount
	) external returns (uint256);

	function repayBorrowVerify(
		address cToken,
		address payer,
		address borrower,
		uint256 repayAmount,
		uint256 borrowerIndex
	) external;

	function liquidateBorrowAllowed(
		address cTokenBorrowed,
		address cTokenCollateral,
		address liquidator,
		address borrower,
		uint256 repayAmount
	) external returns (uint256);

	function liquidateBorrowVerify(
		address cTokenBorrowed,
		address cTokenCollateral,
		address liquidator,
		address borrower,
		uint256 repayAmount,
		uint256 seizeTokens
	) external;

	function seizeAllowed(
		address cTokenCollateral,
		address cTokenBorrowed,
		address liquidator,
		address borrower,
		uint256 seizeTokens
	) external returns (uint256);

	function seizeVerify(
		address cTokenCollateral,
		address cTokenBorrowed,
		address liquidator,
		address borrower,
		uint256 seizeTokens
	) external;

	function transferAllowed(
		address cToken,
		address src,
		address dst,
		uint256 transferTokens
	) external returns (uint256);

	function transferVerify(
		address cToken,
		address src,
		address dst,
		uint256 transferTokens
	) external;

	/*** Liquidity/Liquidation Calculations ***/

	function liquidateCalculateSeizeTokens(
		address cTokenBorrowed,
		address cTokenCollateral,
		uint256 repayAmount
	) external view returns (uint256, uint256);

	/*** Pool-Wide/Cross-Asset Reentrancy Prevention ***/

	function _beforeNonReentrant() external;

	function _afterNonReentrant() external;

	function _deployMarket(
		bool isCEther,
		bytes memory constructorData,
		uint256 collateralFactorMantissa
	) external;

	function getAccountLiquidity(address account)
		external
		view
		virtual
		returns (
			uint256,
			uint256,
			uint256
		);
}

pragma solidity 0.8.6;

interface CErc20Storage {
	function underlying() external returns (address);
}

interface ICErc20 is CErc20Storage {
	function mint(uint256 mintAmount) external returns (uint256);

	function redeem(uint256 redeemTokens) external returns (uint256);

	function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

	function borrow(uint256 borrowAmount) external returns (uint256);

	function repayBorrow(uint256 repayAmount) external returns (uint256);

	function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);

	function liquidateBorrow(
		address borrower,
		uint256 repayAmount,
		address cTokenCollateral
	) external returns (uint256);

	function transfer(address receiver, uint256 amount) external;

	function balanceOfUnderlying(address account) external returns (uint256);

	function borrowBalanceCurrent(address account) external returns (uint256);

	function exchangeRateCurrent() external returns (uint256);

	function exchangeRateStored() external returns (uint256);

	function accrueInterest() external returns (uint256);

	function balanceOf(address account) external view returns (uint256);

	function getCash() external view returns (uint256);

	function totalSupply() external view returns (uint256);

	function borrowRatePerBlock() external view returns (uint256);

	function supplyRatePerBlock() external view returns (uint256);

	function totalReserves() external view returns (uint256);

	function totalBorrows() external view returns (uint256);

	function totalBorrowsCurrent() external returns (uint256);

	// function getCash() external view returns (uint);
	function comptroller() external view returns (address);

	function isCToken() external view returns (bool);
}

pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";
import "./IComptroller.sol";
import "./ICErc20.sol";
import "./IWETHUnwrapper.sol";
import "./IFlashloanWrapper.sol";
import "./IAutoHedgeStableVolatileFactoryUpgradeableV2.sol";
import "./autonomy/IRegistry.sol";

interface IAutoHedgeStableVolatilePairUpgradeableV2 {
	struct Amounts {
		uint256 stable;
		uint256 vol;
	}

	struct MmBps {
		uint64 min;
		uint64 max;
	}

	struct VolPosition {
		uint256 owned;
		uint256 debt;
		uint256 bps;
	}

	struct Tokens {
		IERC20Metadata stable;
		IERC20Metadata vol;
		ICErc20 cVol;
		IERC20Metadata uniLp;
		ICErc20 cUniLp;
	}

	struct FinishDeposit {
		IFlashloanWrapper.FinishRoute fr;
		address depositor;
		uint256 amountStableInit;
		uint256 amountVolToFlashloan;
		address to;
		address referrer;
		bool shouldReturnAmount;
		uint256 flashloanFee;
	}

	struct FinishWithdraw {
		IFlashloanWrapper.FinishRoute fr;
		address withrawer;
		uint256 liquidity;
		uint256 amountVolToFlashloan;
		address to;
		bool shouldReturnAmount;
		uint256 flashloanFee;
	}

	struct TokenUnderlyingBalances {
		uint256 amountVolBorrow;
		uint256 balanceOfUniLp;
	}

	event Deposited(
		address indexed user,
		uint256 amountStable,
		uint256 amountVol,
		uint256 amountUniLp,
		uint256 amountStableSwap,
		uint256 amountMinted
	);

	event Withdrawn(
		address indexed user,
		uint256 amountStableToUser,
		uint256 amountVolToRepay,
		uint256 amountBurned
	);

	event TokenUnderlyingBalancesUpdated(uint256 cVolBorrowAmount, uint256 cUniLpBalance);

	function initialize(
		IUniswapV2Router02 uniV2Router_,
		Tokens memory tokens,
		IERC20Metadata weth_,
		string memory name_,
		string memory symbol_,
		IRegistry registry_,
		address userFeeVeriForwarder_,
		MmBps memory mmBps_,
		IComptroller _comptroller,
		IAutoHedgeStableVolatileFactoryUpgradeableV2 factory_,
		IWETHUnwrapper wu_
	) external;

	/**
	 * @notice  Deposit stablecoins into this pair and receive back AH LP
	 *          tokens. This fcn:
	 *              1. Swaps half the stables into whatever the volatile
	 *                  token is
	 *              2. LPs both tokens on a DEX
	 *              3. Lends out the DEX LP token on Fuse/Midas (Compound
	 *                  fork platforms) to use as collateral
	 *              4. Borrows an equal amount of vol token that was LP'd with
	 *              5. Swaps it to the stable token
	 *              6. Lends out the stable token
	 *              7. Mints an AH LP token and sends it to the user.
	 *          Note depositing takes a 0.3% fee, either to Autonomy or a
	 *          referrer if there is 1.
	 * @param amountStableInit   The minimum amount of the stable that's
	 *                              accepted to be put into the LP
	 * @param to    The address to send the AH LP tokens to
	 * @param referrer  The addresses that receives the 0.3% protocol fee on
	 *                  deposits. If left as 0x00...00, it goes to Autonomy
	 */
	function deposit(
		uint256 amountStableInit,
		address to,
		address referrer,
		bool shouldReturnAmount
	) external returns (uint256);

	/**
	 * @notice  Withdraws stablecoins from the position by effectively
	 *          doing everything in `deposit` in reverse order. There is
	 *          no protocol or referrer fee for withdrawing. All positions
	 *          are withdrawn proportionally - for example if `liquidity`
	 *          is 10% of the pair's AH LP supply, then it'll withdraw
	 *          10% of the stable lending position, 10% of the DEX LP,
	 *          and be responsible for repaying 10% of the vol debt.
	 * @param liquidity     The amount of AH LP tokens to burn
	 * @param to   address to send stable coins to
	 */
	function withdraw(
		uint256 liquidity,
		address to,
		bool shouldReturnAmount
	) external returns (uint256);

	/**
	 * @notice  This is only callable by Autonomy Network itself and only
	 *          under the condition of the vol debt being more than a set
	 *          difference (1% by default) with the amount of vol owned in
	 *          the DEX LP.
	 *          If there is more debt than in the DEX LP, it
	 *          takes some stables from the lending position, withdraws them,
	 *          swaps them to vol, and repays the debt.
	 *          If there is less debt than in the DEX LP, then more vol is
	 *          borrowed, swapped into stables, and lent out.
	 * @param user  The user who made this automation request. This must
	 *              be address(this) of the pair contract, else it'll revert
	 * @param feeAmount     The amount of fee (in the native token of the chain)
	 *                      that's needed to pay the automation fee
	 */
	function rebalanceAuto(address user, uint256 feeAmount) external;

	function finishDeposit(bytes calldata data) external;

	function finishWithdraw(bytes calldata data) external returns (uint256);

	/**
	 * @notice  Returns information on the positions of the volatile token
	 * @return  The VolPosition struct which specifies what amount of vol
	 *          tokens are owned in the DEX LP, the amount of vol tokens
	 *          in debt, and bps, which is basically debt/owned, scaled
	 *          by 1e18
	 */
	function getDebtBps() external returns (VolPosition memory);

	/**
	 * @notice  Returns the factory that created this pair
	 */
	function factory() external returns (IAutoHedgeStableVolatileFactoryUpgradeableV2);

	/**
	 * @notice  Set the min and max bps that the pool will use to rebalance,
	 *          scaled to 1e18. E.g. the min by default is a 1% difference
	 *          and is therefore 99e16
	 * @param newMmBps  The MmBps struct that specifies the min then the max
	 */
	function setMmBps(MmBps calldata newMmBps) external;

	/**
	 * @notice  Gets the token addresses involved in the pool and their
	 *          corresponding cToken/fToken addresses
	 */
	function getTokens()
		external
		view
		returns (
			IERC20Metadata stable,
			IERC20Metadata vol,
			ICErc20 cVol,
			IERC20Metadata uniLp,
			ICErc20 cUniLp
		);

	function balanceOfVolBorrow() external view returns (uint256);

	function balanceOfUniLp() external view returns (uint256);

	function newPath(IERC20Metadata src, IERC20Metadata dest)
		external
		pure
		returns (address[] memory);

	// function getBalanceOfUnderlyingTokens()
	// 	external
	// 	view
	// 	returns (uint256 amountVolBorrow, uint256 balanceOfUniLp);

	// function refreshBalanceOfUnderlyingTokens() external;
}

pragma solidity 0.8.6;

import "./IComptroller.sol";
import "./IFlashloanWrapper.sol";
import "./IMasterPriceOracle.sol";
import "./IAutoHedgeLeveragedPosition.sol";

interface IAutoHedgeLeveragedPositionFactoryEvents {
	event LeveragedPositionCreated(address indexed creator, address indexed pair, address lvgPos);
	event FlashloanWrapperUpdated(address indexed flw);
	event OracleUpdated(address indexed oracle);
	event ComptrollerUpdated(address indexed comptroller);
}

interface IAutoHedgeLeveragedPositionFactory is IAutoHedgeLeveragedPositionFactoryEvents {
	function flw() external view returns (IFlashloanWrapper);

	function oracle() external view returns (IMasterPriceOracle);

	function comptroller() external view returns (IComptroller);

	function createLeveragedPosition(IAutoHedgeLeveragedPosition.TokensLev memory tokens_)
		external
		returns (address lvgPos);
}

pragma solidity 0.8.6;

// SPDX-License-Identifier: UNLICENSED

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function WETH() external view returns (address);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity 0.8.6;


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

pragma solidity 0.8.6;

interface IWETHUnwrapper {
	function withdraw(uint256 amount, address to) external;
}

pragma solidity 0.8.6;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


/**
* @title    Registry
* @notice   A contract which is essentially a glorified forwarder.
*           It essentially brings together people who want things executed,
*           and people who want to do that execution in return for a fee.
*           Users register the details of what they want executed, which
*           should always revert unless their execution condition is true,
*           and executors execute the request when the condition is true.
*           Only a specific executor is allowed to execute requests at any
*           given time, as determined by the StakeManager, which requires
*           staking AUTO tokens. This is infrastructure, and an integral
*           piece of the future of web3. It also provides the spark of life
*           for a new form of organism - cyber life. We are the gods now.
* @author   Quantaf1re (James Key)
*/
interface IRegistry {
    
    // The address vars are 20b, total 60, calldata is 4b + n*32b usually, which
    // has a factor of 32. uint112 since the current ETH supply of ~115m can fit
    // into that and it's the highest such that 2 * uint112 + 3 * bool is < 256b
    struct Request {
        address payable user;
        address target;
        address payable referer;
        bytes callData;
        uint112 initEthSent;
        uint112 ethForCall;
        bool verifyUser;
        bool insertFeeAmount;
        bool payWithAUTO;
        bool isAlive;
    }


    //////////////////////////////////////////////////////////////
    //                                                          //
    //                      Hashed Requests                     //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /**
     * @notice  Creates a new request, logs the request info in an event, then saves
     *          a hash of it on-chain in `_hashedReqs`. Uses the default for whether
     *          to pay in ETH or AUTO
     * @param target    The contract address that needs to be called
     * @param referer       The referer to get rewarded for referring the sender
     *                      to using Autonomy. Usally the address of a dapp owner
     * @param callData  The calldata of the call that the request is to make, i.e.
     *                  the fcn identifier + inputs, encoded
     * @param ethForCall    The ETH to send with the call
     * @param verifyUser  Whether the 1st input of the calldata equals the sender.
     *                      Needed for dapps to know who the sender is whilst
     *                      ensuring that the sender intended
     *                      that fcn and contract to be called - dapps will
     *                      require that msg.sender is the Verified Forwarder,
     *                      and only requests that have `verifyUser` = true will
     *                      be forwarded via the Verified Forwarder, so any calls
     *                      coming from it are guaranteed to have the 1st argument
     *                      be the sender
     * @param insertFeeAmount     Whether the gas estimate of the executor should be inserted
     *                      into the callData
     * @param isAlive       Whether or not the request should be deleted after it's executed
     *                      for the first time. If `true`, the request will exist permanently
     *                      (tho it can be cancelled any time), therefore executing the same
     *                      request repeatedly aslong as the request is executable,
     *                      and can be used to create fully autonomous contracts - the
     *                      first single-celled cyber life. We are the gods now
     * @return id   The id of the request, equal to the index in `_hashedReqs`
     */
    function newReq(
        address target,
        address payable referer,
        bytes calldata callData,
        uint112 ethForCall,
        bool verifyUser,
        bool insertFeeAmount,
        bool isAlive
    ) external payable returns (uint id);

    /**
     * @notice  Creates a new request, logs the request info in an event, then saves
     *          a hash of it on-chain in `_hashedReqs`
     * @param target    The contract address that needs to be called
     * @param referer       The referer to get rewarded for referring the sender
     *                      to using Autonomy. Usally the address of a dapp owner
     * @param callData  The calldata of the call that the request is to make, i.e.
     *                  the fcn identifier + inputs, encoded
     * @param ethForCall    The ETH to send with the call
     * @param verifyUser  Whether the 1st input of the calldata equals the sender.
     *                      Needed for dapps to know who the sender is whilst
     *                      ensuring that the sender intended
     *                      that fcn and contract to be called - dapps will
     *                      require that msg.sender is the Verified Forwarder,
     *                      and only requests that have `verifyUser` = true will
     *                      be forwarded via the Verified Forwarder, so any calls
     *                      coming from it are guaranteed to have the 1st argument
     *                      be the sender
     * @param insertFeeAmount     Whether the gas estimate of the executor should be inserted
     *                      into the callData
     * @param payWithAUTO   Whether the sender wants to pay for the request in AUTO
     *                      or ETH. Paying in AUTO reduces the fee
     * @param isAlive       Whether or not the request should be deleted after it's executed
     *                      for the first time. If `true`, the request will exist permanently
     *                      (tho it can be cancelled any time), therefore executing the same
     *                      request repeatedly aslong as the request is executable,
     *                      and can be used to create fully autonomous contracts - the
     *                      first single-celled cyber life. We are the gods now
     * @return id   The id of the request, equal to the index in `_hashedReqs`
     */
    function newReqPaySpecific(
        address target,
        address payable referer,
        bytes calldata callData,
        uint112 ethForCall,
        bool verifyUser,
        bool insertFeeAmount,
        bool payWithAUTO,
        bool isAlive
    ) external payable returns (uint id);

    /**
     * @notice  Gets all keccak256 hashes of encoded requests. Completed requests will be 0x00
     * @return  [bytes32[]] An array of all hashes
     */
    function getHashedReqs() external view returns (bytes32[] memory);

    /**
     * @notice  Gets part of the keccak256 hashes of encoded requests. Completed requests will be 0x00.
     *          Needed since the array will quickly grow to cost more gas than the block limit to retrieve.
     *          so it can be viewed in chunks. E.g. for an array of x = [4, 5, 6, 7], x[1, 2] returns [5],
     *          the same as lists in Python
     * @param startIdx  [uint] The starting index from which to start getting the slice (inclusive)
     * @param endIdx    [uint] The ending index from which to start getting the slice (exclusive)
     * @return  [bytes32[]] An array of all hashes
     */
    function getHashedReqsSlice(uint startIdx, uint endIdx) external view returns (bytes32[] memory);

    /**
     * @notice  Gets the total number of requests that have been made, hashed, and stored
     * @return  [uint] The total number of hashed requests
     */
    function getHashedReqsLen() external view returns (uint);
    
    /**
     * @notice      Gets a single hashed request
     * @param id    [uint] The id of the request, which is its index in the array
     * @return      [bytes32] The sha3 hash of the request
     */
    function getHashedReq(uint id) external view returns (bytes32);


    //////////////////////////////////////////////////////////////
    //                                                          //
    //                        Bytes Helpers                     //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /**
     * @notice      Encode a request into bytes
     * @param r     [request] The request to be encoded
     * @return      [bytes] The bytes array of the encoded request
     */
    function getReqBytes(Request memory r) external pure returns (bytes memory);

    function insertToCallData(bytes calldata callData, uint expectedGas, uint startIdx) external pure returns (bytes memory);


    //////////////////////////////////////////////////////////////
    //                                                          //
    //                         Executions                       //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /**
     * @notice      Execute a hashedReq. Calls the `target` with `callData`, then
     *              charges the user the fee, and gives it to the executor
     * @param id    [uint] The index of the request in `_hashedReqs`
     * @param r     [request] The full request struct that fully describes the request.
     *              Typically known by seeing the `HashedReqAdded` event emitted with `newReq`
     * @param expectedGas   [uint] The gas that the executor expects the execution to cost,
     *                      known by simulating the the execution of this tx locally off-chain.
     *                      This can be forwarded as part of the requested call such that the
     *                      receiving contract knows how much gas the whole execution cost and
     *                      can do something to compensate the exact amount (e.g. as part of a trade).
     *                      Cannot be more than 10% above the measured gas cost by the end of execution
     * @return gasUsed      [uint] The gas that was used as part of the execution. Used to know `expectedGas`
     */
    function executeHashedReq(
        uint id,
        Request calldata r,
        uint expectedGas
    ) external returns (uint gasUsed);


    //////////////////////////////////////////////////////////////
    //                                                          //
    //                        Cancellations                     //
    //                                                          //
    //////////////////////////////////////////////////////////////
    
    /**
     * @notice      Execute a hashedReq. Calls the `target` with `callData`, then
     *              charges the user the fee, and gives it to the executor
     * @param id    [uint] The index of the request in `_hashedReqs`
     * @param r     [request] The full request struct that fully describes the request.
     *              Typically known by seeing the `HashedReqAdded` event emitted with `newReq`
     */
    function cancelHashedReq(
        uint id,
        Request memory r
    ) external;
    
    
    //////////////////////////////////////////////////////////////
    //                                                          //
    //                          Getters                         //
    //                                                          //
    //////////////////////////////////////////////////////////////
    
    function getAUTOAddr() external view returns (address);
    
    function getStakeManager() external view returns (address);

    function getOracle() external view returns (address);
    
    function getUserForwarder() external view returns (address);
    
    function getGasForwarder() external view returns (address);
    
    function getUserGasForwarder() external view returns (address);
    
    function getReqCountOf(address addr) external view returns (uint);
    
    function getExecCountOf(address addr) external view returns (uint);
    
    function getReferalCountOf(address addr) external view returns (uint);
}

pragma solidity 0.8.6;


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

pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashBorrower {
    /// @notice The flashloan callback. `amount` + `fee` needs to repayed to msg.sender before this call returns.
    /// @param sender The address of the invoker of this flashloan.
    /// @param token The address of the token that is loaned.
    /// @param amount of the `token` that is loaned.
    /// @param fee The fee that needs to be paid on top for this loan. Needs to be the same as `token`.
    /// @param data Additional data that was passed to the flashloan function.
    function onFlashLoan(
        address sender,
        IERC20 token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external;
}

interface IBentoBox {
    /// @notice Flashloan ability.
    /// @param borrower The address of the contract that implements and conforms to `IFlashBorrower` and handles the flashloan.
    /// @param receiver Address of the token receiver.
    /// @param token The address of the token to receive.
    /// @param amount of the tokens to receive.
    /// @param data The calldata to pass to the `borrower` contract.
    // F5 - Checks-Effects-Interactions pattern followed? (SWC-107)
    // F5: Not possible to follow this here, reentrancy has been reviewed
    // F6 - Check for front-running possibilities, such as the approve function (SWC-114)
    // F6: Slight grieving possible by withdrawing an amount before someone tries to flashloan close to the full amount.
    function flashLoan(
        IFlashBorrower borrower,
        address receiver,
        IERC20 token,
        uint256 amount,
        bytes calldata data
    ) external;
}