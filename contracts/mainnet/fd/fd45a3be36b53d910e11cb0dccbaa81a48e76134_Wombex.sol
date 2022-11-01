// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
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
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
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

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'solmate/tokens/ERC20.sol';
import 'solmate/utils/SafeTransferLib.sol';

import './lib/Owned.sol';

abstract contract Guardian is Owned {
	using SafeTransferLib for ERC20;

	/// @notice base asset this strategy uses, e.g. USDC
	ERC20 public immutable asset;

	error BelowMinimum(uint256);

	constructor(ERC20 _asset, address _owner) Owned(_owner) {
		asset = _asset;
	}

	/*//////////////////////////
	/      View Functions      /
	//////////////////////////*/

	function freeAssets() public view returns (uint256 _assets) {
		return asset.balanceOf(address(this));
	}

	function stakedAssets() public view virtual returns (uint256 _assets);

	function totalAssets() external view returns (uint256 _assets) {
		return freeAssets() + stakedAssets();
	}

	/*///////////////////////////
	/      Owner Functions      /
	///////////////////////////*/

	/**
	 * @notice Deposits assets and stakes into strategy. Use an ERC20 transfer if you want to deposit
	 * without staking
	 * @param _amount Amount of assets to deposit
	 */
	function deposit(uint256 _amount) external onlyOwner {
		asset.safeTransferFrom(msg.sender, address(this), _amount);
		_stake(_amount);
	}

	/// @notice stake assets into strategy
	/// @dev should handle overflow, i.e. staking type(uint256).max should stake everything
	function stake(uint256 _amount) external onlyOwner {
		_stake(_amount);
	}

	/**
	 * @notice Withdraws assets to owner, first from free assets then from staked assets
	 * @param _amount Withdrawal amount. Handles overflow, so type(uint256).max withdraws everything
	 * @param _min Minimum amount to receive, safeguard against MEV exploits
	 * @return received Amount of assets received by owner
	 */
	function withdraw(uint256 _amount, uint256 _min) external onlyOwner returns (uint256 received) {
		uint256 free = freeAssets();
		uint256 staked = stakedAssets();
		uint256 fromFree;
		uint256 fromStaked;

		// first, withdraw from free assets
		if (free > 0) {
			fromFree = free > _amount ? _amount : free;
			unchecked {
				_amount -= fromFree;
				received += fromFree;
			}
		}

		// next, withdraw from staked assets
		if (_amount > 0 && staked > 0) {
			fromStaked = _amount > staked ? staked : _amount;
			received += _unstake(fromStaked);
		}

		if (received < _min) revert BelowMinimum(received);

		asset.safeTransfer(msg.sender, received);
	}

	/// @notice Claims strategy rewards from strategy and sends to owner
	function claimRewards() external onlyOwner {
		_claimRewards();
	}

	/// @notice Backup withdrawal in case of additional rewards/airdrops/etc uncovered by 'withdraw()'
	function withdrawERC20(ERC20 _token) external onlyOwner {
		uint256 balance = _token.balanceOf(address(this));
		_token.safeTransfer(msg.sender, balance);
	}

	/*////////////////////////////
	/      Worker Functions      /
	////////////////////////////*/

	/// @notice unstake assets from strategy
	/// @dev should handle overflow, i.e. unstaking type(uint256).max should unstake everything
	function unstake(uint256 _amount, uint256 _min) external onlyAuthorized returns (uint256 received) {
		received = _unstake(_amount);
		if (received < _min) revert BelowMinimum(received);
	}

	/*/////////////////////////////
	/      Internal Override      /
	/////////////////////////////*/

	/// @notice stake assets into strategy
	/// @dev should handle overflow, i.e. staking type(uint256).max should stake everything
	function _stake(uint256 _amount) internal virtual;

	/// @notice unstake assets from strategy
	/// @dev should handle overflow, i.e. unstaking type(uint256).max should unstake everything
	function _unstake(uint256 _amount) internal virtual returns (uint256 received);

	/// @notice claim strategy rewards for owner
	function _claimRewards() internal virtual;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'src/interfaces/IERC20.sol';

// @https://github.com/wombex-finance/wombex-contracts/tree/main/contracts

interface IPoolDepositor {
	function lpTokenToPid(address _lpToken) external view returns (uint256 pid);

	function deposit(
		address _lpToken,
		uint256 _amount,
		uint256 _minLiquidity,
		bool _stake
	) external;

	function withdraw(
		address _lpToken,
		uint256 _amount,
		uint256 _minOut,
		address _recipient
	) external;
}

interface IAsset is IERC20 {
	function underlyingToken() external view returns (address);

	function pool() external view returns (address);
}

interface IBaseRewardPool is IERC20 {
	function getReward(address _account, bool _claimExtras) external returns (bool);
}

interface IBooster {
	function poolInfo(uint256 _pid)
		external
		view
		returns (
			address _lpToken,
			address _token,
			address _gauge,
			address _crvRewards,
			bool shutdown
		);
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
pragma solidity ^0.8.13;

abstract contract Owned {
	address public owner;
	address public nominatedOwner;

	mapping(address => bool) public workers;

	error AlreadyRole();
	error NotRole();
	error Unauthorized();

	constructor(address _owner) {
		owner = _owner;
		nominatedOwner = _owner;
		workers[msg.sender] = true;
	}

	function nominateOwner(address _nominatedOwner) external onlyOwner {
		nominatedOwner = _nominatedOwner;
	}

	function acceptOwner() external {
		if (msg.sender != nominatedOwner) revert Unauthorized();
		if (msg.sender == owner) revert AlreadyRole();
		owner = msg.sender;
	}

	function addWorker(address _worker) external {
		if (workers[_worker]) revert AlreadyRole();
		workers[_worker] = true;
	}

	function removeWorker(address _worker) external {
		if (!workers[_worker]) revert NotRole();
		workers[_worker] = false;
	}

	modifier onlyOwner() {
		if (msg.sender != owner) revert Unauthorized();
		_;
	}

	modifier onlyAuthorized() {
		if (msg.sender != owner && !workers[msg.sender]) revert Unauthorized();
		_;
	}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'solmate/utils/SafeTransferLib.sol';
import 'src/external/wombex/interfaces.sol';
import 'src/Guardian.sol';

contract Wombex is Guardian {
	using SafeTransferLib for ERC20;

	/// @notice underlying Wombat LP token, e.g. LP-BUSD for BUSD
	IAsset public immutable lpToken;

	/// @notice Wombex LP token, e.g. wmxLP-BUSD
	IBaseRewardPool public immutable wmxLpToken;

	/// @notice Wombex helper contract to deposit/withdraw + unstake from Wombat in one tx
	IPoolDepositor internal constant poolDepositor = IPoolDepositor(0xd7ae65005E4CFA15551ccc482807D3330E543289);
	/// @notice Wombex booster based off Convex booster
	IBooster internal constant booster = IBooster(0xE62c4454d1dd6B727eB7952888B31a74969086B8);

	address[] public rewards;

	error InvalidAsset();

	constructor(
		IAsset _lpToken,
		address[] memory _rewards,
		ERC20 _asset,
		address _owner
	) Guardian(_asset, _owner) {
		lpToken = _lpToken;
		rewards = _rewards;

		if (address(asset) != lpToken.underlyingToken()) revert InvalidAsset();

		uint256 pid = poolDepositor.lpTokenToPid(address(_lpToken));

		(, , , address crvRewards, ) = IBooster(booster).poolInfo(pid);
		wmxLpToken = IBaseRewardPool(crvRewards);

		asset.safeApprove(address(poolDepositor), type(uint256).max);
		ERC20(address(wmxLpToken)).safeApprove(address(poolDepositor), type(uint256).max);
	}

	function stakedAssets() public view override returns (uint256 _assets) {
		return wmxLpToken.balanceOf(address(this));
	}

	function _stake(uint256 _amount) internal override {
		uint256 balance = asset.balanceOf(address(this));

		uint256 amount = balance > _amount ? _amount : balance;

		_allow(asset, amount, address(poolDepositor));

		uint256 minLiquidity; // TODO

		poolDepositor.deposit(address(lpToken), amount, minLiquidity, true);
	}

	function _unstake(uint256 _amount) internal override returns (uint256 received) {
		uint256 stakedBalance = stakedAssets();

		uint256 amount = stakedBalance > _amount ? _amount : stakedBalance;

		_allow(ERC20(address(wmxLpToken)), amount, address(poolDepositor));

		uint256 balanceBefore = asset.balanceOf(address(this));

		/// minimum is handled by Guardian contract
		poolDepositor.withdraw(address(lpToken), _amount, 0, address(this));
		uint256 balanceAfter = asset.balanceOf(address(this));

		return balanceAfter - balanceBefore;
	}

	function _claimRewards() internal override {
		wmxLpToken.getReward(address(this), false);

		for (uint8 i = 0; i < rewards.length; ++i) {
			ERC20 reward = ERC20(rewards[i]);
			uint256 balance = reward.balanceOf(address(this));
			if (balance > 0) reward.safeTransfer(owner, balance);
		}
	}

	/// @dev helper function to reset allowances
	function _allow(
		ERC20 _token,
		uint256 _amount,
		address _spender
	) internal {
		uint256 allowance = _token.allowance(address(this), _spender);
		if (allowance < _amount) {
			_token.safeApprove(_spender, 0);
			_token.safeApprove(_spender, type(uint256).max);
		}
	}
}