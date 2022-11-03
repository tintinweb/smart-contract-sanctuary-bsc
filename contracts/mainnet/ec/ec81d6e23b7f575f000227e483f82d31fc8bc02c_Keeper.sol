// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Provides a flexible and updatable auth pattern which is completely separate from application logic.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Auth.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
abstract contract Auth {
    event OwnershipTransferred(address indexed user, address indexed newOwner);

    event AuthorityUpdated(address indexed user, Authority indexed newAuthority);

    address public owner;

    Authority public authority;

    constructor(address _owner, Authority _authority) {
        owner = _owner;
        authority = _authority;

        emit OwnershipTransferred(msg.sender, _owner);
        emit AuthorityUpdated(msg.sender, _authority);
    }

    modifier requiresAuth() virtual {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        _;
    }

    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool) {
        Authority auth = authority; // Memoizing authority saves us a warm SLOAD, around 100 gas.

        // Checking if the caller is the owner only after calling the authority saves gas in most cases, but be
        // aware that this makes protected functions uncallable even to the owner if the authority is out of order.
        return (address(auth) != address(0) && auth.canCall(user, address(this), functionSig)) || user == owner;
    }

    function setAuthority(Authority newAuthority) public virtual {
        // We check if the caller is the owner first because we want to ensure they can
        // always swap out the authority even if it's reverting or using up a lot of gas.
        require(msg.sender == owner || authority.canCall(msg.sender, address(this), msg.sig));

        authority = newAuthority;

        emit AuthorityUpdated(msg.sender, newAuthority);
    }

    function transferOwnership(address newOwner) public virtual requiresAuth {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

/// @notice A generic interface for a contract which provides authorization data to an Auth instance.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Auth.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
interface Authority {
    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {Auth, Authority} from "../Auth.sol";

/// @notice Role based Authority that supports up to 256 roles.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/authorities/RolesAuthority.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-roles/blob/master/src/roles.sol)
contract RolesAuthority is Auth, Authority {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event UserRoleUpdated(address indexed user, uint8 indexed role, bool enabled);

    event PublicCapabilityUpdated(address indexed target, bytes4 indexed functionSig, bool enabled);

    event RoleCapabilityUpdated(uint8 indexed role, address indexed target, bytes4 indexed functionSig, bool enabled);

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner, Authority _authority) Auth(_owner, _authority) {}

    /*//////////////////////////////////////////////////////////////
                            ROLE/USER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => bytes32) public getUserRoles;

    mapping(address => mapping(bytes4 => bool)) public isCapabilityPublic;

    mapping(address => mapping(bytes4 => bytes32)) public getRolesWithCapability;

    function doesUserHaveRole(address user, uint8 role) public view virtual returns (bool) {
        return (uint256(getUserRoles[user]) >> role) & 1 != 0;
    }

    function doesRoleHaveCapability(
        uint8 role,
        address target,
        bytes4 functionSig
    ) public view virtual returns (bool) {
        return (uint256(getRolesWithCapability[target][functionSig]) >> role) & 1 != 0;
    }

    /*//////////////////////////////////////////////////////////////
                           AUTHORIZATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) public view virtual override returns (bool) {
        return
            isCapabilityPublic[target][functionSig] ||
            bytes32(0) != getUserRoles[user] & getRolesWithCapability[target][functionSig];
    }

    /*//////////////////////////////////////////////////////////////
                   ROLE CAPABILITY CONFIGURATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function setPublicCapability(
        address target,
        bytes4 functionSig,
        bool enabled
    ) public virtual requiresAuth {
        isCapabilityPublic[target][functionSig] = enabled;

        emit PublicCapabilityUpdated(target, functionSig, enabled);
    }

    function setRoleCapability(
        uint8 role,
        address target,
        bytes4 functionSig,
        bool enabled
    ) public virtual requiresAuth {
        if (enabled) {
            getRolesWithCapability[target][functionSig] |= bytes32(1 << role);
        } else {
            getRolesWithCapability[target][functionSig] &= ~bytes32(1 << role);
        }

        emit RoleCapabilityUpdated(role, target, functionSig, enabled);
    }

    /*//////////////////////////////////////////////////////////////
                       USER ROLE ASSIGNMENT LOGIC
    //////////////////////////////////////////////////////////////*/

    function setUserRole(
        address user,
        uint8 role,
        bool enabled
    ) public virtual requiresAuth {
        if (enabled) {
            getUserRoles[user] |= bytes32(1 << role);
        } else {
            getUserRoles[user] &= ~bytes32(1 << role);
        }

        emit UserRoleUpdated(user, role, enabled);
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";
import {SafeTransferLib} from "../utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "../utils/FixedPointMathLib.sol";

/// @notice Minimal ERC4626 tokenized Vault implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/mixins/ERC4626.sol)
abstract contract ERC4626 is ERC20 {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /*//////////////////////////////////////////////////////////////
                               IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    ERC20 public immutable asset;

    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, _asset.decimals()) {
        asset = _asset;
    }

    /*//////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
        // Check for rounding error since we round down in previewDeposit.
        require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");

        // Need to transfer before minting or ERC777s could reenter.
        asset.safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {
        assets = previewMint(shares); // No need to check for rounding error, previewMint rounds up.

        // Need to transfer before minting or ERC777s could reenter.
        asset.safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual returns (uint256 shares) {
        shares = previewWithdraw(assets); // No need to check for rounding error, previewWithdraw rounds up.

        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }

        beforeWithdraw(assets, shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        asset.safeTransfer(receiver, assets);
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public virtual returns (uint256 assets) {
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }

        // Check for rounding error since we round down in previewRedeem.
        require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");

        beforeWithdraw(assets, shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        asset.safeTransfer(receiver, assets);
    }

    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function totalAssets() public view virtual returns (uint256);

    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDivDown(supply, totalAssets());
    }

    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivDown(totalAssets(), supply);
    }

    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
    }

    function previewMint(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivUp(totalAssets(), supply);
    }

    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDivUp(supply, totalAssets());
    }

    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(shares);
    }

    /*//////////////////////////////////////////////////////////////
                     DEPOSIT/WITHDRAWAL LIMIT LOGIC
    //////////////////////////////////////////////////////////////*/

    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return convertToAssets(balanceOf[owner]);
    }

    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL HOOKS LOGIC
    //////////////////////////////////////////////////////////////*/

    function beforeWithdraw(uint256 assets, uint256 shares) internal virtual {}

    function afterDeposit(uint256 assets, uint256 shares) internal virtual {}
}

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

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Inspired by USM (https://github.com/usmfum/USM/blob/master/contracts/WadMath.sol)
library FixedPointMathLib {
    /*//////////////////////////////////////////////////////////////
                    SIMPLIFIED FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    uint256 internal constant MAX_UINT256 = 2**256 - 1;

    uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, y, WAD); // Equivalent to (x * y) / WAD rounded down.
    }

    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, y, WAD); // Equivalent to (x * y) / WAD rounded up.
    }

    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, WAD, y); // Equivalent to (x * WAD) / y rounded down.
    }

    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, WAD, y); // Equivalent to (x * WAD) / y rounded up.
    }

    /*//////////////////////////////////////////////////////////////
                    LOW LEVEL FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
                revert(0, 0)
            }

            // Divide x * y by the denominator.
            z := div(mul(x, y), denominator)
        }
    }

    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
                revert(0, 0)
            }

            // If x * y modulo the denominator is strictly greater than 0,
            // 1 is added to round up the division of x * y by the denominator.
            z := add(gt(mod(mul(x, y), denominator), 0), div(mul(x, y), denominator))
        }
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    // 0 ** 0 = 1
                    z := scalar
                }
                default {
                    // 0 ** n = 0
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    // If n is even, store scalar in z for now.
                    z := scalar
                }
                default {
                    // If n is odd, store x in z for now.
                    z := x
                }

                // Shifting right by 1 is like dividing by 2.
                let half := shr(1, scalar)

                for {
                    // Shift n right by 1 before looping to halve it.
                    n := shr(1, n)
                } n {
                    // Shift n right by 1 each iteration to halve it.
                    n := shr(1, n)
                } {
                    // Revert immediately if x ** 2 would overflow.
                    // Equivalent to iszero(eq(div(xx, x), x)) here.
                    if shr(128, x) {
                        revert(0, 0)
                    }

                    // Store x squared.
                    let xx := mul(x, x)

                    // Round to the nearest number.
                    let xxRound := add(xx, half)

                    // Revert if xx + half overflowed.
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }

                    // Set x to scaled xxRound.
                    x := div(xxRound, scalar)

                    // If n is even:
                    if mod(n, 2) {
                        // Compute z * x.
                        let zx := mul(z, x)

                        // If z * x overflowed:
                        if iszero(eq(div(zx, x), z)) {
                            // Revert if x is non-zero.
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }

                        // Round to the nearest number.
                        let zxRound := add(zx, half)

                        // Revert if zx + half overflowed.
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }

                        // Return properly scaled zxRound.
                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                        GENERAL NUMBER UTILITIES
    //////////////////////////////////////////////////////////////*/

    function sqrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            let y := x // We start y at x, which will help us make our initial estimate.

            z := 181 // The "correct" value is 1, but this saves a multiplication later.

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.

            // We check y >= 2^(k + 8) but shift right by k bits
            // each branch to ensure that if x >= 256, then y >= 256.
            if iszero(lt(y, 0x10000000000000000000000000000000000)) {
                y := shr(128, y)
                z := shl(64, z)
            }
            if iszero(lt(y, 0x1000000000000000000)) {
                y := shr(64, y)
                z := shl(32, z)
            }
            if iszero(lt(y, 0x10000000000)) {
                y := shr(32, y)
                z := shl(16, z)
            }
            if iszero(lt(y, 0x1000000)) {
                y := shr(16, y)
                z := shl(8, z)
            }

            // Goal was to get z*z*y within a small factor of x. More iterations could
            // get y in a tighter range. Currently, we will have y in [256, 256*2^16).
            // We ensured y >= 256 so that the relative difference between y and y+1 is small.
            // That's not possible if x < 256 but we can just verify those cases exhaustively.

            // Now, z*z*y <= x < z*z*(y+1), and y <= 2^(16+8), and either y >= 256, or x < 256.
            // Correctness can be checked exhaustively for x < 256, so we assume y >= 256.
            // Then z*sqrt(y) is within sqrt(257)/sqrt(256) of sqrt(x), or about 20bps.

            // For s in the range [1/256, 256], the estimate f(s) = (181/1024) * (s+1) is in the range
            // (1/2.84 * sqrt(s), 2.84 * sqrt(s)), with largest error when s = 1 and when s = 256 or 1/256.

            // Since y is in [256, 256*2^16), let a = y/65536, so that a is in [1/256, 256). Then we can estimate
            // sqrt(y) using sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2^18.

            // There is no overflow risk here since y < 2^136 after the first branch above.
            z := shr(18, mul(z, add(y, 65536))) // A mul() is saved from starting z at 181.

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // If x+1 is a perfect square, the Babylonian method cycles between
            // floor(sqrt(x)) and ceil(sqrt(x)). This statement ensures we return floor.
            // See: https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division
            // Since the ceil is rare, we save gas on the assignment and repeat division in the rare case.
            // If you don't care whether the floor or ceil square root is returned, you can remove this statement.
            z := sub(z, lt(div(x, z), z))
        }
    }

    function unsafeMod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Mod x by y. Note this will return
            // 0 instead of reverting if y is zero.
            z := mod(x, y)
        }
    }

    function unsafeDiv(uint256 x, uint256 y) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Divide x by y. Note this will return
            // 0 instead of reverting if y is zero.
            r := div(x, y)
        }
    }

    function unsafeDivUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Add 1 to x * y if x % y > 0. Note this will
            // return 0 instead of reverting if y is zero.
            z := add(gt(mod(x, y), 0), div(x, y))
        }
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Read and write to persistent storage at a fraction of the cost.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SSTORE2.sol)
/// @author Modified from 0xSequence (https://github.com/0xSequence/sstore2/blob/master/contracts/SSTORE2.sol)
library SSTORE2 {
    uint256 internal constant DATA_OFFSET = 1; // We skip the first byte as it's a STOP opcode to ensure the contract can't be called.

    /*//////////////////////////////////////////////////////////////
                               WRITE LOGIC
    //////////////////////////////////////////////////////////////*/

    function write(bytes memory data) internal returns (address pointer) {
        // Prefix the bytecode with a STOP opcode to ensure it cannot be called.
        bytes memory runtimeCode = abi.encodePacked(hex"00", data);

        bytes memory creationCode = abi.encodePacked(
            //---------------------------------------------------------------------------------------------------------------//
            // Opcode  | Opcode + Arguments  | Description  | Stack View                                                     //
            //---------------------------------------------------------------------------------------------------------------//
            // 0x60    |  0x600B             | PUSH1 11     | codeOffset                                                     //
            // 0x59    |  0x59               | MSIZE        | 0 codeOffset                                                   //
            // 0x81    |  0x81               | DUP2         | codeOffset 0 codeOffset                                        //
            // 0x38    |  0x38               | CODESIZE     | codeSize codeOffset 0 codeOffset                               //
            // 0x03    |  0x03               | SUB          | (codeSize - codeOffset) 0 codeOffset                           //
            // 0x80    |  0x80               | DUP          | (codeSize - codeOffset) (codeSize - codeOffset) 0 codeOffset   //
            // 0x92    |  0x92               | SWAP3        | codeOffset (codeSize - codeOffset) 0 (codeSize - codeOffset)   //
            // 0x59    |  0x59               | MSIZE        | 0 codeOffset (codeSize - codeOffset) 0 (codeSize - codeOffset) //
            // 0x39    |  0x39               | CODECOPY     | 0 (codeSize - codeOffset)                                      //
            // 0xf3    |  0xf3               | RETURN       |                                                                //
            //---------------------------------------------------------------------------------------------------------------//
            hex"60_0B_59_81_38_03_80_92_59_39_F3", // Returns all code in the contract except for the first 11 (0B in hex) bytes.
            runtimeCode // The bytecode we want the contract to have after deployment. Capped at 1 byte less than the code size limit.
        );

        /// @solidity memory-safe-assembly
        assembly {
            // Deploy a new contract with the generated creation code.
            // We start 32 bytes into the code to avoid copying the byte length.
            pointer := create(0, add(creationCode, 32), mload(creationCode))
        }

        require(pointer != address(0), "DEPLOYMENT_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                               READ LOGIC
    //////////////////////////////////////////////////////////////*/

    function read(address pointer) internal view returns (bytes memory) {
        return readBytecode(pointer, DATA_OFFSET, pointer.code.length - DATA_OFFSET);
    }

    function read(address pointer, uint256 start) internal view returns (bytes memory) {
        start += DATA_OFFSET;

        return readBytecode(pointer, start, pointer.code.length - start);
    }

    function read(
        address pointer,
        uint256 start,
        uint256 end
    ) internal view returns (bytes memory) {
        start += DATA_OFFSET;
        end += DATA_OFFSET;

        require(pointer.code.length >= end, "OUT_OF_BOUNDS");

        return readBytecode(pointer, start, end - start);
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL HELPER LOGIC
    //////////////////////////////////////////////////////////////*/

    function readBytecode(
        address pointer,
        uint256 start,
        uint256 size
    ) private view returns (bytes memory data) {
        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            data := mload(0x40)

            // Update the free memory pointer to prevent overriding our data.
            // We use and(x, not(31)) as a cheaper equivalent to sub(x, mod(x, 32)).
            // Adding 31 to size and running the result through the logic above ensures
            // the memory pointer remains word-aligned, following the Solidity convention.
            mstore(0x40, add(data, and(add(add(size, 32), 31), not(31))))

            // Store the size of the data in the first 32 byte chunk of free memory.
            mstore(data, size)

            // Copy the code into memory right after the 32 bytes we used to store the size.
            extcodecopy(pointer, add(data, 32), start, size)
        }
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

        /// @solidity memory-safe-assembly
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

        /// @solidity memory-safe-assembly
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

        /// @solidity memory-safe-assembly
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

        /// @solidity memory-safe-assembly
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

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity >=0.6.2;

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

pragma solidity >=0.6.2;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Authority, Auth} from "solmate/auth/Auth.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {SSTORE2} from "solmate/utils/SSTORE2.sol";

import {StratX4LibEarn, SwapRoute} from "./libraries/StratX4LibEarn.sol";

contract AutofarmFeesController is Auth {
  using SafeTransferLib for ERC20;
  using FixedPointMathLib for uint256;

  address public constant AUTOv2 = 0xa184088a740c695E156F91f5cC086a06bb78b827;
  address public treasury;
  address public SAV;
  uint8 public portionToPlatform;
  // portion to remaining fees after platform fees
  uint8 public portionToAUTOBurn;
  mapping(address => address) public rewardCfgPointers;

  event FeeDistribution(
    address indexed earnedAddress,
    uint256 platformFee,
    uint256 burnFee,
    uint256 savFee
  );

  constructor(
    Authority _authority,
    address _treasury,
    address _sav,
    uint8 _portionToPlatform,
    uint8 _portionToAUTOBurn
  ) Auth(address(0), _authority) {
    treasury = _treasury;
    SAV = _sav;
    portionToPlatform = _portionToPlatform;
    portionToAUTOBurn = _portionToAUTOBurn;
  }

  function forwardFeesBulk(
    address[] calldata rewards,
    uint256[] calldata minAmountOuts
  ) public requiresAuth {
    require(rewards.length == minAmountOuts.length, "lengths must be equal");
    for (uint256 i; i < rewards.length;) {
      forwardFees(rewards[i], minAmountOuts[i]);
      unchecked {
        i++;
      }
    }
  }

  function forwardFees(address earnedAddress, uint256 minAUTOOut)
    public
    requiresAuth
  {
    address rewardCfgPointer = rewardCfgPointers[address(earnedAddress)];
    require(
      rewardCfgPointer != address(0), "FeesController: RewardCfg uninitialized"
    );
    SwapRoute memory swapRoute =
      abi.decode(SSTORE2.read(rewardCfgPointer), (SwapRoute));

    uint256 earnedAmt = ERC20(earnedAddress).balanceOf(address(this));

    // Platform Fees

    uint256 feeToPlatform =
      earnedAmt.mulDivUp(portionToPlatform, uint256(type(uint8).max));
    require(feeToPlatform > 0, "FeesController: No fees to platform");
    require(
      feeToPlatform < earnedAmt, "FeesController: Fees to platform too large"
    );

    earnedAmt -= feeToPlatform;
    ERC20(earnedAddress).safeTransfer(treasury, feeToPlatform);

    earnedAmt = StratX4LibEarn.swapExactTokensForTokens(
      earnedAddress,
      earnedAmt,
      swapRoute.swapFees,
      swapRoute.pairsPath,
      swapRoute.tokensPath
    );

    require(earnedAmt >= minAUTOOut, "FeesController: AUTO min amount not met");

    uint256 burnAmt = earnedAmt.mulDivDown(portionToAUTOBurn, type(uint8).max);
    ERC20(AUTOv2).safeTransfer(address(0), burnAmt);
    earnedAmt -= burnAmt;
    ERC20(AUTOv2).safeTransfer(SAV, earnedAmt);

    emit FeeDistribution(earnedAddress, feeToPlatform, burnAmt, earnedAmt);
  }

  /**
   * Setters
   */

  function setRewardCfg(address reward, SwapRoute calldata route)
    external
    requiresAuth
  {
    require(route.pairsPath.length > 0);
    require(route.tokensPath.length == route.pairsPath.length);
    require(route.tokensPath.length == route.swapFees.length);
    require(route.tokensPath[route.tokensPath.length - 1] == AUTOv2);
    rewardCfgPointers[reward] = SSTORE2.write(abi.encode(route));
  }

  function setPlatformPortion(uint8 platform) external requiresAuth {
    portionToPlatform = platform;
  }

  function setBurnPortion(uint8 burn) external requiresAuth {
    portionToAUTOBurn = burn;
  }

  function setTreasury(address _treasury) external requiresAuth {
    treasury = _treasury;
  }

  function setSAV(address _SAV) external requiresAuth {
    SAV = _SAV;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Auth, Authority} from "solmate/auth/authorities/RolesAuthority.sol";

import {StratX4} from "./StratX4.sol";
import {AutofarmFeesController} from "./FeesController.sol";

contract Keeper is Auth {
  address public immutable feesController;

  constructor(address _feesController, Authority _authority)
    Auth(address(0), _authority)
  {
    feesController = _feesController;
  }

  function batchEarn(
    address[] calldata strats,
    address[] calldata earnedAddresses,
    uint256[] calldata minAmountsOut
  ) external requiresAuth returns (uint256[] memory profits) {
    require(
      strats.length == earnedAddresses.length, "Input arrays length mismatch"
    );
    require(
      strats.length == minAmountsOut.length, "Input arrays length mismatch"
    );

    profits = new uint256[](strats.length);

    for (uint256 i; i < strats.length;) {
      try StratX4(strats[i]).earn(earnedAddresses[i], minAmountsOut[i])
      returns (uint256 profit) {
        profits[i] = profit;
      } catch {}

      unchecked {
        i++;
      }
    }
  }

  function batchCollectFees(
    address[] calldata strats,
    address[] calldata earnedAddresses
  ) external requiresAuth returns (uint256[] memory amounts) {
    require(strats.length == earnedAddresses.length);

    amounts = new uint256[](strats.length);

    for (uint256 i; i < strats.length;) {
      try StratX4(strats[i]).collectFees(earnedAddresses[i]) returns (
        uint256 amount
      ) {
        amounts[i] = amount;
      } catch {}
      i++;
    }
  }

  function batchSetFeeRate(
    address[] calldata strats,
    uint256[] calldata feeRates
  ) external requiresAuth {
    require(strats.length == feeRates.length);

    for (uint256 i; i < strats.length;) {
      try StratX4(strats[i]).setFeeRate(feeRates[i]) {} catch {}
      i++;
    }
  }

  function batchForwardFees(
    address[] calldata earnedAddresses,
    uint256[] calldata minAmountsOut
  ) external requiresAuth {
    require(earnedAddresses.length == minAmountsOut.length);

    for (uint256 i; i < earnedAddresses.length;) {
      try AutofarmFeesController(feesController).forwardFees(
        earnedAddresses[i], minAmountsOut[i]
      ) {} catch {}
      i++;
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";
import {Auth, Authority} from "solmate/auth/authorities/RolesAuthority.sol";
import {Pausable} from "openzeppelin/security/Pausable.sol";
import {FlippedUint256, FlippedUint256Lib} from "./libraries/FlippedUint.sol";

abstract contract StratX4 is ERC4626, Auth, Pausable {
  using SafeTransferLib for ERC20;
  using FixedPointMathLib for uint256;
  using FixedPointMathLib for uint160;

  uint256 public constant FEE_RATE_PRECISION = 1e18;

  address public immutable farmContractAddress;
  address public immutable feesController;
  uint96 public immutable creationBlockNumber;
  mapping(address => FlippedUint256) public feesCollectable;
  uint256 public constant MAX_FEE_RATE = 1e17; // 10%
  uint256 public constant PROFIT_VESTING_PERIOD = 21600; // 6 hours

  uint256 public feeRate;
  ProfitVesting public profitVesting;

  event FeeSetAside(address earnedAddress, uint256 amount);
  event FeeCollected(address indexed earnedAddress, uint256 amount);
  event FeesUpdated(uint256 feeRate);
  event Earn(
    address indexed earnedAddress,
    uint256 assetsIncrease,
    uint256 earnedAmount,
    uint256 fee
  );

  struct ProfitVesting {
    // 96 bits should be enough for > 2500 years of operation,
    // if block time is 1 second
    uint96 lastEarnBlock;
    uint160 amount;
  }

  constructor(
    address _asset,
    address _farmContractAddress,
    address _feesController,
    Authority _authority
  )
    ERC4626(ERC20(_asset), "Autofarm Strategy", "AF-Strat")
    Auth(address(0), _authority)
  {
    farmContractAddress = _farmContractAddress;
    feesController = _feesController;

    uint96 _creationBlockNumber = uint96(block.number);
    profitVesting =
      ProfitVesting({lastEarnBlock: _creationBlockNumber, amount: 0});
    creationBlockNumber = _creationBlockNumber;

    ERC20(_asset).safeApprove(_farmContractAddress, type(uint256).max);
  }

  function depositWithPermit(
    uint256 assets,
    address receiver,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public {
    asset.permit(msg.sender, address(this), assets, deadline, v, r, s);
    deposit(assets, receiver);
  }

  ///// ERC4626 compatibility /////

  function previewDeposit(uint256 assets)
    public
    view
    override
    whenNotPaused
    returns (uint256)
  {
    return super.previewDeposit(assets);
  }

  function previewMint(uint256 shares)
    public
    view
    override
    whenNotPaused
    returns (uint256)
  {
    return super.previewMint(shares);
  }

  // totalAssets is adjusted to vest earned profits over a vesting period
  // to prevent front-running and remove the need for an entrance fee
  function totalAssets() public view override returns (uint256 amount) {
    if (!paused()) {
      amount = lockedAssets();
      uint256 _vestingProfit = vestingProfit();
      if (_vestingProfit > amount) {
        _vestingProfit = amount;
      }
      amount -= _vestingProfit;
    } else {
      amount = asset.balanceOf(address(this));
    }
  }

  function vestingProfit() public view returns (uint256) {
    uint256 blocksSinceLastEarn = block.number - profitVesting.lastEarnBlock;
    if (blocksSinceLastEarn >= PROFIT_VESTING_PERIOD) {
      return 0;
    }
    return profitVesting.amount.mulDivUp(
      PROFIT_VESTING_PERIOD - blocksSinceLastEarn, PROFIT_VESTING_PERIOD
    );
  }

  function lockedAssets() internal view virtual returns (uint256);

  function afterDeposit(uint256 assets, uint256 /*shares*/ )
    internal
    virtual
    override
  {
    if (!paused()) {
      _farm(assets);
    }
  }

  function beforeWithdraw(uint256 assets, uint256 /*shares*/ )
    internal
    virtual
    override
  {
    if (!paused()) {
      _unfarm(assets);
    }
  }

  ///// FARM INTERACTION /////

  function _farm(uint256 wantAmt) internal virtual;
  function _unfarm(uint256 wantAmt) internal virtual;
  function _emergencyUnfarm() internal virtual;

  ///// Compounding /////

  function earn(address earnedAddress, uint256 minAmountOut)
    public
    requiresAuth
    whenNotPaused
    returns (uint256 profit)
  {
    require(minAmountOut > 0, "StratX4: minAmount Outmust be at least 1");
    harvest(earnedAddress);
    (uint256 earnedAmount, uint256 fee) = getEarnedAmountAfterFee(earnedAddress);

    require(earnedAmount > 1, "StratX4: Nothing earned after fees");
    earnedAmount -= 1;

    profit = compound(earnedAddress, earnedAmount);
    require(
      profit >= minAmountOut, "StratX4: Earn produces less than minAmountOut"
    );

    // Gas optimization: leave at least 1 wei in the Strat
    profit -= 1;

    _farm(profit);
    _vestProfit(profit);
    emit Earn(earnedAddress, profit, earnedAmount, fee);
  }

  // Calls external contract to retrieve reward tokens
  function harvest(address earnedAddress) internal virtual;

  // Swaps harvested reward tokens into assets
  function compound(address earnedAddress, uint256 earnedAmount)
    internal
    virtual
    returns (uint256 profit);

  // When earnedAddress == asset, and when the asset is somehow staked in this Strat instead of the farm
  // this will have to be adjusted to exclude the balance of deposits
  function getEarnedAmount(address earnedAddress, uint256 feeCollectable)
    internal
    view
    virtual
    returns (uint256)
  {
    return ERC20(earnedAddress).balanceOf(address(this)) - feeCollectable;
  }

  function getEarnedAmountAfterFee(address earnedAddress)
    internal
    returns (uint256 earnedAmount, uint256 fee)
  {
    uint256 _feeRate = feeRate; // Reduce SLOADs

    uint256 _feeCollectable = feesCollectable[earnedAddress].get();

    earnedAmount = getEarnedAmount(earnedAddress, _feeCollectable);

    if (_feeRate > 0) {
      fee = earnedAmount.mulDivUp(_feeRate, FEE_RATE_PRECISION);

      earnedAmount -= fee;

      feesCollectable[earnedAddress] =
        FlippedUint256Lib.create(_feeCollectable + fee);

      emit FeeSetAside(earnedAddress, fee);
    }
  }

  function minEarnedAmountToHarvest()
    public
    view
    returns (uint256 minEarnedAmount)
  {
    uint256 _feeRate = feeRate;

    if (_feeRate > 0) {
      minEarnedAmount = FEE_RATE_PRECISION / feeRate;
    }
  }

  /* @earnbot
   * Called in batches to decouple fees and compounding.
   * Should calc gas vs fees to decide when it is economical to collect fees
   * Optimize for gas by leaving 1 wei in the Strat
   */
  function collectFees(address earnedAddress)
    public
    whenNotPaused
    requiresAuth
    returns (uint256 amount)
  {
    amount = feesCollectable[earnedAddress].get();
    require(amount > 0, "No fees collectable");
    ERC20(earnedAddress).safeTransfer(feesController, amount);
    feesCollectable[earnedAddress] = FlippedUint256Lib.create(1);
    emit FeeCollected(earnedAddress, amount);
  }

  function collectableFee(address earnedAddress)
    public
    view
    returns (uint256 amount)
  {
    amount = feesCollectable[earnedAddress].get();
  }

  function _vestProfit(uint256 profit) internal {
    uint96 lastEarnBlock = profitVesting.lastEarnBlock;
    uint256 prevVestingEnd = lastEarnBlock + PROFIT_VESTING_PERIOD;

    uint256 vestingAmount = uint160(profit);

    // Carry over unvested profits
    if (block.number < prevVestingEnd && block.number != creationBlockNumber) {
      vestingAmount += profitVesting.amount.mulDivUp(
        prevVestingEnd - block.number, PROFIT_VESTING_PERIOD
      );
    }
    profitVesting.lastEarnBlock = uint96(block.number);
    profitVesting.amount = uint160(vestingAmount);
  }

  ///// KEEPER FUNCTIONALITIES /////

  /*
   * Sets the feeRate.
   * The Keeper adjusts the feeRate periodically according to the vault's APR.
   */
  function setFeeRate(uint256 _feeRate) public requiresAuth {
    require(_feeRate <= MAX_FEE_RATE, "StratX4: feeRate exceeds limit");

    feeRate = _feeRate;
    emit FeesUpdated(_feeRate);
  }

  ///// DEV FUNCTIONALITIES /////

  function deprecate() public whenNotPaused requiresAuth {
    _emergencyUnfarm();
    _pause();
    asset.safeApprove(farmContractAddress, 0);
  }

  function undeprecate() public whenPaused requiresAuth {
    _unpause();
    asset.safeApprove(farmContractAddress, type(uint256).max);
    _farm(asset.balanceOf(address(this)));
  }

  // Farm allowance should be unlikely to run out during the Strat's lifetime
  // given that the asset's fiat value per wei is within reasonable range
  // but if it does, it can be reset here
  function resetFarmAllowance() public requiresAuth whenNotPaused {
    asset.safeApprove(farmContractAddress, type(uint256).max);
  }

  // Emergency calls for funds recovery
  // Use cases:
  // - Refund by farm through a reimbursement contract
  function rescueOperation(address[] calldata targets, bytes[] calldata data)
    public
    requiresAuth
    whenPaused
  {
    require(
      targets.length == data.length, "StratX4: targets data length mismatch"
    );

    for (uint256 i; i < targets.length; i++) {
      // Try to rescue the funds to this contract, and let people
      // withdraw from this contract
      require(
        targets[i] != address(asset) && targets[i] != address(this),
        "StratX4: Illegal target"
      );
      (bool succeeded,) = targets[i].call(data[i]);
      require(succeeded, "!succeeded");
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

type FlippedUint256 is uint256;

type FlippedUint128 is uint128;

/*
 * @example
 *
 * // Write to storage
 * s_myNum = FlippedUint256Lib.create(0);
 * // Reading from storage
 * myNum = s_myNum.get();
 */

library FlippedUint256Lib {
  function create(uint256 val) internal pure returns (FlippedUint256) {
    assembly {
      val := not(val)
    }
    return FlippedUint256.wrap(val);
  }

  function get(FlippedUint256 fuint) internal pure returns (uint256 val) {
    val = FlippedUint256.unwrap(fuint);
    if (val == 0) {
      return 0;
    }
    assembly {
      val := not(val)
    }
  }
}

library FlippedUint128Lib {
  function create(uint128 val) internal pure returns (FlippedUint128) {
    assembly {
      val := not(val)
    }
    return FlippedUint128.wrap(val);
  }

  function get(FlippedUint128 fuint) internal pure returns (uint128 val) {
    val = FlippedUint128.unwrap(fuint);
    if (val == 0) {
      return 0;
    }
    assembly {
      val := not(val)
    }
  }
}

using FlippedUint256Lib for FlippedUint256 global;
using FlippedUint128Lib for FlippedUint128 global;

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {SSTORE2} from "solmate/utils/SSTORE2.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from
  "@uniswap/v2-periphery/interfaces/IUniswapV2Router02.sol";

import {Uniswap} from "./Uniswap.sol";

/*
 * StratX4LibEarn
 * - Swaps reward tokens into asset tokens.
 * - Responsible for all vault earns?
 *
 * LP Strategies
 * -. No swaps: Reward and asset tokens are the same
 * 0. Asset is TOKEN-REWARD LP: do one side swap liquidity
 * 1. Asset is BASE-TOKEN LP: swap token to BASE and do one side liquidity
 * 2. (Optional) Asset is TOKEN-TOKEN: Swap to base(s) and buy tokens separately
 *    (does not pass the asset LP)
 * Steps:
 * Convert reward to some base token
 * if base is one of token0 or token1: convert base token one sided
 * - swap using asset LP
 * - swap using another LP
 * if base is not in LP: convert to token0 and token1
 * - swap using other LPs
 */

struct SwapRoute {
  address[] pairsPath;
  address[] tokensPath;
  uint256[] swapFees; // set to 0 if dynamic
}

struct ZapLiquidityConfig {
  address lpSubtokenIn;
  address lpSubtokenOut;
  uint256 swapFee; // set to 0 if dynamic
}

interface IUniswapV2PairDynamicFee {
  function swapFee() external view returns (uint32);
}

library StratX4LibEarn {
  using SafeTransferLib for ERC20;

  function swapExactTokensForTokens(
    address tokenIn,
    uint256 amountIn,
    uint256[] memory swapFees,
    address[] memory pairsPath,
    address[] memory tokensPath
  ) internal returns (uint256 amountOut) {
    require(pairsPath.length > 0);

    amountOut = amountIn;
    ERC20(tokenIn).safeTransfer(pairsPath[0], amountIn);

    for (uint256 i; i < pairsPath.length;) {
      amountOut = Uniswap._swap(
        pairsPath[i],
        swapFees[i],
        i == 0 ? tokenIn : tokensPath[i - 1],
        tokensPath[i],
        amountOut,
        i == pairsPath.length - 1 ? address(this) : pairsPath[i + 1]
      );
      unchecked {
        i++;
      }
    }
  }

  function swapExactTokensToLiquidity1(
    address tokenIn,
    address tokenOut,
    uint256 amountIn,
    SwapRoute memory swapRoute,
    ZapLiquidityConfig memory zapLiquidityConfig
  ) internal returns (uint256 amountOut) {
    // sanity checks

    // Swap to reserve tokenIn
    if (swapRoute.pairsPath.length > 0) {
      amountOut = swapExactTokensForTokens(
        tokenIn,
        amountIn,
        swapRoute.swapFees,
        swapRoute.pairsPath,
        swapRoute.tokensPath
      );
    } else {
      amountOut = amountIn;
    }

    amountOut -= 1;

    (uint256 swapAmount, uint256 tokenAmountOut) = Uniswap.calcSimpleZap(
      tokenOut,
      zapLiquidityConfig.swapFee,
      amountOut,
      zapLiquidityConfig.lpSubtokenIn,
      zapLiquidityConfig.lpSubtokenOut
    );

    ERC20(zapLiquidityConfig.lpSubtokenIn).safeTransfer(tokenOut, swapAmount);
    if (zapLiquidityConfig.lpSubtokenIn < zapLiquidityConfig.lpSubtokenOut) {
      IUniswapV2Pair(tokenOut).swap(0, tokenAmountOut, address(this), "");
    } else {
      IUniswapV2Pair(tokenOut).swap(tokenAmountOut, 0, address(this), "");
    }
    tokenAmountOut -= 1;
    ERC20(zapLiquidityConfig.lpSubtokenIn).safeTransfer(
      tokenOut, amountOut - swapAmount
    );
    ERC20(zapLiquidityConfig.lpSubtokenOut).safeTransfer(
      tokenOut, tokenAmountOut
    );
    amountOut = IUniswapV2Pair(tokenOut).mint(address(this));
  }

  function swapExactTokensToLiquidity1WithDynamicFees(
    address tokenIn,
    address tokenOut,
    uint256 amountIn,
    SwapRoute memory swapRoute,
    ZapLiquidityConfig memory zapLiquidityConfig,
    function (address) returns (uint256) getPairSwapFee
  ) internal returns (uint256 amountOut) {
    // sanity checks

    // Swap to reserve tokenIn
    if (swapRoute.pairsPath.length > 0) {
      for (uint256 i; i < swapRoute.pairsPath.length;) {
        swapRoute.swapFees[i] = getPairSwapFee(swapRoute.pairsPath[i]);
        unchecked {
          i++;
        }
      }

      amountOut = swapExactTokensForTokens(
        tokenIn,
        amountIn,
        swapRoute.swapFees,
        swapRoute.pairsPath,
        swapRoute.tokensPath
      );
    } else {
      amountOut = amountIn;
    }

    amountOut -= 1;

    (uint256 swapAmount, uint256 tokenAmountOut) = Uniswap.calcSimpleZap(
      tokenOut,
      getPairSwapFee(tokenOut),
      amountOut,
      zapLiquidityConfig.lpSubtokenIn,
      zapLiquidityConfig.lpSubtokenOut
    );

    ERC20(zapLiquidityConfig.lpSubtokenIn).safeTransfer(tokenOut, swapAmount);
    if (zapLiquidityConfig.lpSubtokenIn < zapLiquidityConfig.lpSubtokenOut) {
      IUniswapV2Pair(tokenOut).swap(0, tokenAmountOut, address(this), "");
    } else {
      IUniswapV2Pair(tokenOut).swap(tokenAmountOut, 0, address(this), "");
    }
    tokenAmountOut -= 1;
    ERC20(zapLiquidityConfig.lpSubtokenIn).safeTransfer(
      tokenOut, amountOut - swapAmount
    );
    ERC20(zapLiquidityConfig.lpSubtokenOut).safeTransfer(
      tokenOut, tokenAmountOut
    );
    amountOut = IUniswapV2Pair(tokenOut).mint(address(this));
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "solmate/utils/FixedPointMathLib.sol";
import "solmate/tokens/ERC20.sol";
import "solmate/utils/SafeTransferLib.sol";

import "@uniswap/v2-core/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/interfaces/IUniswapV2Factory.sol";

library Uniswap {
  using SafeTransferLib for ERC20;
  using SafeTransferLib for address;

  /**
   * UniswapV2Library functions **
   */

  function getAmountOut(
    uint256 amountIn,
    uint256 reserve0,
    uint256 reserve1,
    uint256 fee
  ) internal pure returns (uint256) {
    uint256 amountInWithFee = amountIn * fee / 10000;
    uint256 nominator = amountInWithFee * reserve1;
    uint256 denominator = amountInWithFee + reserve0;
    return nominator / denominator;
  }

  // Slightly modified version of getAmountsOut
  function getAmountsOut(
    address factory,
    uint256 swapFee,
    uint256 amountIn,
    address[] memory path
  ) internal view returns (uint256[] memory amounts) {
    require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
    amounts = new uint[](path.length);
    amounts[0] = amountIn;
    for (uint256 i; i < path.length - 1; i++) {
      address pair = IUniswapV2Factory(factory).getPair(path[i], path[i + 1]);
      (uint256 reserveIn, uint256 reserveOut) =
        getReserves(pair, path[i], path[i + 1]);
      amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, swapFee);
    }
  }

  // returns sorted token addresses, used to handle return values from pairs sorted in this order
  function sortTokens(address tokenA, address tokenB)
    internal
    pure
    returns (address token0, address token1)
  {
    require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
  }

  function getReserves(address pair, address tokenA, address tokenB)
    internal
    view
    returns (uint256 reserveA, uint256 reserveB)
  {
    (address token0,) = sortTokens(tokenA, tokenB);
    (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(pair).getReserves();
    (reserveA, reserveB) =
      tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
  }

  // calculates the CREATE2 address for a pair without making any external calls
  function pairFor(
    address factory,
    bytes32 INIT_HASH_CODE,
    address tokenA,
    address tokenB
  ) internal pure returns (address pair) {
    (address token0, address token1) = sortTokens(tokenA, tokenB);
    pair = address(
      uint160(
        uint256(
          keccak256(
            abi.encodePacked(
              hex"ff",
              factory,
              keccak256(abi.encodePacked(token0, token1)),
              INIT_HASH_CODE
            )
          )
        )
      )
    );
  }

  function getPair(
    address factory,
    bytes32 INIT_HASH_CODE,
    address token0,
    address token1
  ) internal view returns (address pair) {
    if (INIT_HASH_CODE != bytes32("")) {
      pair = pairFor(factory, INIT_HASH_CODE, token0, token1);
    } else {
      // Some dexes do not have/use INIT_HASH_CODE
      pair = IUniswapV2Factory(factory).getPair(token0, token1);
    }
  }

  function quote(uint256 amountA, uint256 reserveA, uint256 reserveB)
    internal
    pure
    returns (uint256 amountB)
  {
    require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
    require(
      reserveA > 0 && reserveB > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
    );
    amountB = amountA * reserveB / reserveA;
  }

  function _addLiquidity(
    IUniswapV2Pair pair,
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin
  ) internal view returns (uint256 amountA, uint256 amountB) {
    (uint256 reserve0, uint256 reserve1,) = pair.getReserves();
    (uint256 reserveA, uint256 reserveB) =
      tokenA > tokenB ? (reserve0, reserve1) : (reserve1, reserve0);
    if (reserveA == 0 && reserveB == 0) {
      (amountA, amountB) = (amountADesired, amountBDesired);
    } else {
      uint256 amountBOptimal = quote(amountADesired, reserveA, reserveB);
      if (amountBOptimal <= amountBDesired) {
        require(
          amountBOptimal >= amountBMin, "UniswapV2Router: INSUFFICIENT_B_AMOUNT"
        );
        (amountA, amountB) = (amountADesired, amountBOptimal);
      } else {
        uint256 amountAOptimal = quote(amountBDesired, reserveB, reserveA);
        assert(amountAOptimal <= amountADesired);
        require(
          amountAOptimal >= amountAMin, "UniswapV2Router: INSUFFICIENT_A_AMOUNT"
        );
        (amountA, amountB) = (amountAOptimal, amountBDesired);
      }
    }
  }

  /**
   * Swap helpers **
   */

  function calcSimpleZap(
    address pair,
    uint256 swapFee,
    uint256 amountIn,
    address tokenIn,
    address tokenOut
  ) internal view returns (uint256 swapAmount, uint256 tokenAmountOut) {
    uint112 reserveInput;
    uint112 reserveOutput;
    {
      (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(pair).getReserves();
      (reserveInput, reserveOutput) =
        tokenIn > tokenOut ? (reserve1, reserve0) : (reserve0, reserve1);
    }
    swapAmount = FixedPointMathLib.sqrt(
      reserveInput * (amountIn + reserveInput)
    ) - reserveInput;
    tokenAmountOut =
      Uniswap.getAmountOut(swapAmount, reserveInput, reserveOutput, swapFee);
  }

  /**
   * Autoswap Router methods **
   */

  // Swaps one side of an LP and add liquidity
  function oneSidedSwap(
    address pair,
    uint256 swapAmount,
    uint256 tokenAmountOut,
    address inToken,
    address otherToken,
    uint256 amountIn,
    address to
  ) internal returns (uint256 outAmount) {
    ERC20(inToken).safeTransfer(pair, swapAmount);
    if (inToken < otherToken) {
      IUniswapV2Pair(pair).swap(0, tokenAmountOut, address(this), "");
    } else {
      IUniswapV2Pair(pair).swap(tokenAmountOut, 0, address(this), "");
    }
    ERC20(inToken).safeTransfer(address(pair), amountIn - swapAmount);
    ERC20(otherToken).safeTransfer(address(pair), tokenAmountOut - 1);
    outAmount = IUniswapV2Pair(pair).mint(to);
  }

  function _swap(
    address pair,
    uint256 fee,
    address tokenIn,
    address tokenOut,
    uint256 amountIn,
    address to
  ) internal returns (uint256 amountOut) {
    (uint256 reserve0, uint256 reserve1) = getReserves(pair, tokenIn, tokenOut);
    amountOut = getAmountOut(amountIn, reserve0, reserve1, fee);
    if (tokenIn < tokenOut) {
      IUniswapV2Pair(pair).swap(0, amountOut, to, "");
    } else {
      IUniswapV2Pair(pair).swap(amountOut, 0, to, "");
    }
  }

  function swap(
    address pair,
    uint256 fee,
    address tokenIn,
    address tokenOut,
    uint256 amountIn
  ) internal returns (uint256 amountOut) {
    ERC20(tokenIn).safeTransfer(pair, amountIn);
    (uint256 reserve0, uint256 reserve1) = getReserves(pair, tokenIn, tokenOut);
    amountOut = getAmountOut(amountIn, reserve0, reserve1, fee);
    // TODO: amount is already in pair if linear path
    // TODO: pass to next pair directly if linear path
    if (tokenIn < tokenOut) {
      IUniswapV2Pair(pair).swap(0, amountOut, address(this), "");
    } else {
      IUniswapV2Pair(pair).swap(amountOut, 0, address(this), "");
    }
  }

  function swapSupportingFeeOnTransfer(
    address pair,
    uint256 fee,
    address tokenIn,
    address tokenOut,
    uint256 amountIn
  ) internal returns (uint256 amountOut) {
    (uint256 reserveInput, uint256 reserveOutput) =
      getReserves(pair, tokenIn, tokenOut);
    ERC20(tokenIn).safeTransfer(pair, amountIn);
    amountIn = ERC20(tokenIn).balanceOf(pair) - reserveInput;
    amountOut = getAmountOut(amountIn, reserveInput, reserveOutput, fee);
    // TODO: amount is already in pair if linear path
    // TODO: pass to next pair directly if linear path
    if (tokenIn < tokenOut) {
      IUniswapV2Pair(pair).swap(0, amountOut, address(this), "");
    } else {
      IUniswapV2Pair(pair).swap(amountOut, 0, address(this), "");
    }
  }
}