// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

/// @notice Helper utility that enables calling multiple local methods in a single call.
/// @author Modified from Uniswap (https://github.com/Uniswap/v3-periphery/blob/main/contracts/base/Multicall.sol)
/// License-Identifier: GPL-2.0-or-later
abstract contract Multicall {
    function multicall(bytes[] calldata data) public payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        
        for (uint256 i; i < data.length;) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                // Next 5 lines from https://ethereum.stackexchange.com/a/83577
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;

            // cannot realistically overflow on human timescales
            unchecked {
                ++i;
            }
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "../../abstract/Multicall.sol";
import "../../abstract/TridentERC721.sol";
import "../../interfaces/IMasterDeployer.sol";
import "../../interfaces/IBentoBoxMinimal.sol";
import "../../interfaces/ITridentRouter.sol";
import "../../interfaces/IConcentratedLiquidityPoolManager.sol";
import "../../interfaces/IConcentratedLiquidityPool.sol";
import "../../interfaces/IPositionManager.sol";
import "../../libraries/FullMath.sol";
import "../../libraries/TickMath.sol";
import "../../libraries/DyDxMath.sol";

/// @notice Trident Concentrated Liquidity Pool periphery contract that combines non-fungible position management and staking.
contract ConcentratedLiquidityPoolManager is IConcentratedLiquidityPoolManagerStruct, IPositionManager, TridentERC721, Multicall {
    event IncreaseLiquidity(address indexed pool, address indexed owner, uint256 indexed positionId, uint128 liquidity);
    event DecreaseLiquidity(address indexed pool, address indexed owner, uint256 indexed positionId, uint128 liquidity);

    address internal cachedMsgSender = address(1);
    address internal cachedPool = address(1);

    address internal immutable wETH;
    IBentoBoxMinimal public immutable bento;
    IMasterDeployer public immutable masterDeployer;

    mapping(uint256 => Position) public positions;

    constructor(address _masterDeployer, address _wETH) {
        masterDeployer = IMasterDeployer(_masterDeployer);
        IBentoBoxMinimal _bento = IBentoBoxMinimal(IMasterDeployer(_masterDeployer).bento());
        _bento.registerProtocol();
        bento = _bento;
        wETH = _wETH;
        mint(address(this));
    }

    function mint(
        IConcentratedLiquidityPool pool,
        int24 lowerOld,
        int24 lower,
        int24 upperOld,
        int24 upper,
        uint128 amount0Desired,
        uint128 amount1Desired,
        bool native,
        uint256 minLiquidity,
        uint256 positionId
    ) external payable returns (uint256 _positionId) {
        require(masterDeployer.pools(address(pool)), "INVALID_POOL");

        cachedMsgSender = msg.sender;
        cachedPool = address(pool);

        uint128 liquidityMinted = uint128(
            pool.mint(
                IConcentratedLiquidityPoolStruct.MintParams({
                    lowerOld: lowerOld,
                    lower: lower,
                    upperOld: upperOld,
                    upper: upper,
                    amount0Desired: amount0Desired,
                    amount1Desired: amount1Desired,
                    native: native
                })
            )
        );

        require(liquidityMinted >= minLiquidity, "TOO_LITTLE_RECEIVED");

        (uint256 feeGrowthInside0, uint256 feeGrowthInside1) = pool.rangeFeeGrowth(lower, upper);

        if (positionId == 0) {
            // We mint a new NFT.
            _positionId = nftCount.minted;
            positions[_positionId] = Position({
                pool: pool,
                liquidity: liquidityMinted,
                lower: lower,
                upper: upper,
                latestAddition: uint32(block.timestamp),
                feeGrowthInside0: feeGrowthInside0,
                feeGrowthInside1: feeGrowthInside1
            });
            mint(msg.sender);
        } else {
            // We increase liquidity for an existing NFT.
            _positionId = positionId;
            Position storage position = positions[_positionId];
            require(address(position.pool) == address(pool), "POOL_MIS_MATCH");
            require(position.lower == lower && position.upper == upper, "RANGE_MIS_MATCH");
            require(ownerOf(positionId) == msg.sender, "NOT_ID_OWNER");
            // Fees should be claimed first.
            position.feeGrowthInside0 = feeGrowthInside0;
            position.feeGrowthInside1 = feeGrowthInside1;
            position.liquidity += liquidityMinted;
            // Incentives should be claimed first.
            position.latestAddition = uint32(block.timestamp);
        }

        emit IncreaseLiquidity(address(pool), msg.sender, _positionId, liquidityMinted);

        cachedMsgSender = address(1);
        cachedPool = address(1);
    }

    function mintCallback(
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1,
        bool native
    ) external override {
        require(msg.sender == cachedPool, "UNAUTHORIZED_CALLBACK");
        if (native) {
            _depositFromUserToBentoBox(token0, cachedMsgSender, msg.sender, amount0);
            _depositFromUserToBentoBox(token1, cachedMsgSender, msg.sender, amount1);
        } else {
            bento.transfer(token0, cachedMsgSender, msg.sender, amount0);
            bento.transfer(token1, cachedMsgSender, msg.sender, amount1);
        }
        cachedMsgSender = address(1);
        cachedPool = address(1);
    }

    function burn(
        uint256 tokenId,
        uint128 amount,
        address recipient,
        bool unwrapBento,
        uint256 minimumOut0,
        uint256 minimumOut1
    ) external returns (uint256 token0Amount, uint256 token1Amount) {
        require(msg.sender == ownerOf(tokenId), "NOT_ID_OWNER");

        Position memory position = positions[tokenId];

        (uint256 token0Fees, uint256 token1Fees, uint256 feeGrowthInside0, uint256 feeGrowthInside1) = positionFees(tokenId);

        if (amount < position.liquidity) {
            (token0Amount, token1Amount, , ) = position.pool.burn(position.lower, position.upper, amount);

            positions[tokenId].feeGrowthInside0 = feeGrowthInside0;
            positions[tokenId].feeGrowthInside1 = feeGrowthInside1;
            positions[tokenId].liquidity -= amount;
        } else {
            amount = position.liquidity;
            (token0Amount, token1Amount, , ) = position.pool.burn(position.lower, position.upper, amount);
            burn(tokenId);
            delete positions[tokenId];
        }

        require(token0Amount >= minimumOut0 && token1Amount >= minimumOut1, "TOO_LITTLE_RECEIVED");

        unchecked {
            token0Amount += token0Fees;
            token1Amount += token1Fees;
        }

        _transferBoth(position.pool, recipient, token0Amount, token1Amount, unwrapBento);

        emit DecreaseLiquidity(address(position.pool), msg.sender, tokenId, amount);
    }

    function collect(
        uint256 tokenId,
        address recipient,
        bool unwrapBento
    ) public returns (uint256 token0amount, uint256 token1amount) {
        require(msg.sender == ownerOf(tokenId), "NOT_ID_OWNER");
        Position storage position = positions[tokenId];

        (, , , , , , address token0, address token1) = position.pool.getImmutables();

        (token0amount, token1amount, position.feeGrowthInside0, position.feeGrowthInside1) = positionFees(tokenId);

        uint256 balance0 = bento.balanceOf(token0, address(this));
        uint256 balance1 = bento.balanceOf(token1, address(this));

        if (balance0 < token0amount || balance1 < token1amount) {
            (uint256 amount0fees, uint256 amount1fees) = position.pool.collect(position.lower, position.upper);

            uint256 newBalance0 = amount0fees + balance0;
            uint256 newBalance1 = amount1fees + balance1;

            // Rounding errors due to frequent claiming of other users in the same position may cost us some wei units.
            if (token0amount > newBalance0) token0amount = newBalance0;
            if (token1amount > newBalance1) token1amount = newBalance1;
        }

        _transferOut(token0, recipient, token0amount, unwrapBento);
        _transferOut(token1, recipient, token1amount, unwrapBento);
    }

    /// @notice Returns the claimable fees and the fee growth accumulators of a given position.
    function positionFees(uint256 tokenId)
        public
        view
        returns (
            uint256 token0amount,
            uint256 token1amount,
            uint256 feeGrowthInside0,
            uint256 feeGrowthInside1
        )
    {
        Position memory position = positions[tokenId];

        (feeGrowthInside0, feeGrowthInside1) = position.pool.rangeFeeGrowth(position.lower, position.upper);

        token0amount = FullMath.mulDiv(
            feeGrowthInside0 - position.feeGrowthInside0,
            position.liquidity,
            0x100000000000000000000000000000000
        );

        token1amount = FullMath.mulDiv(
            feeGrowthInside1 - position.feeGrowthInside1,
            position.liquidity,
            0x100000000000000000000000000000000
        );
    }

    function _transferBoth(
        IConcentratedLiquidityPool pool,
        address to,
        uint256 token0Amount,
        uint256 token1Amount,
        bool unwrapBento
    ) internal {
        (, , , , , , address token0, address token1) = pool.getImmutables();
        _transferOut(token0, to, token0Amount, unwrapBento);
        _transferOut(token1, to, token1Amount, unwrapBento);
    }

    function _transferOut(
        address token,
        address to,
        uint256 shares,
        bool unwrapBento
    ) internal {
        if (unwrapBento) {
            bento.withdraw(token, address(this), to, 0, shares);
        } else {
            bento.transfer(token, address(this), to, shares);
        }
    }

    function _depositFromUserToBentoBox(
        address token,
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        if (token == wETH && address(this).balance > 0) {
            // 'amount' is in BentoBox share units.
            uint256 ethAmount = bento.toAmount(token, amount, true);
            if (address(this).balance >= ethAmount) {
                bento.deposit{value: ethAmount}(address(0), sender, recipient, 0, amount);
                return;
            }
        }
        bento.deposit(token, sender, recipient, 0, amount);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract TridentERC721 is ERC721 {
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)");

    bytes32 public constant PERMIT_ALL_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 nonce,uint256 deadline)");

    bytes32 internal immutable _DOMAIN_SEPARATOR;

    uint256 internal immutable DOMAIN_SEPARATOR_CHAIN_ID;

    struct NFTCounter {
        uint128 minted;
        uint128 burned;
    }

    NFTCounter public nftCount;

    mapping(uint256 => uint256) public nonces;

    mapping(address => uint256) public noncesForAll;

    constructor() ERC721("TridentNFT", "tNFT") {
        DOMAIN_SEPARATOR_CHAIN_ID = block.chainid;
        _DOMAIN_SEPARATOR = _calculateDomainSeparator();
    }

    function _calculateDomainSeparator() internal view returns (bytes32 domainSeperator) {
        domainSeperator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("TridentNFT")),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32 domainSeperator) {
        domainSeperator = block.chainid == DOMAIN_SEPARATOR_CHAIN_ID ? _DOMAIN_SEPARATOR : _calculateDomainSeparator();
    }

    function mint(address recipient) internal {
        _mint(recipient, nftCount.minted++);
    }

    function burn(uint256 tokenId) internal {
        nftCount.burned++;
        _burn(tokenId);
    }

    function totalSupply() public view returns (uint256) {
        return nftCount.minted - nftCount.burned;
    }

    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");
        address owner = ownerOf(tokenId);
        /// @dev This is reasonably safe from overflow - incrementing `nonces` beyond
        // 'type(uint256).max' is exceedingly unlikely compared to optimization benefits.
        unchecked {
            bytes32 digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, spender, tokenId, nonces[tokenId]++, deadline))
                )
            );
            address recoveredAddress = ecrecover(digest, v, r, s);
            require(recoveredAddress != address(0), "INVALID_PERMIT_SIGNATURE");
            require(recoveredAddress == owner || isApprovedForAll(owner, recoveredAddress), "INVALID_SIGNER");
        }
        _approve(spender, tokenId);
    }

    function permitAll(
        address owner,
        address operator,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");
        /// @dev This is reasonably safe from overflow - incrementing `nonces` beyond
        // 'type(uint256).max' is exceedingly unlikely compared to optimization benefits.
        unchecked {
            bytes32 digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_ALL_TYPEHASH, owner, operator, noncesForAll[owner]++, deadline))
                )
            );
            address recoveredAddress = ecrecover(digest, v, r, s);
            require(
                (recoveredAddress != address(0) && recoveredAddress == owner) || isApprovedForAll(owner, recoveredAddress),
                "INVALID_PERMIT_SIGNATURE"
            );
        }
        _setApprovalForAll(owner, operator, true);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

/// @notice Trident pool deployer interface.
interface IMasterDeployer {
    function barFee() external view returns (uint256);

    function barFeeTo() external view returns (address);

    function bento() external view returns (address);

    function migrator() external view returns (address);

    function pools(address pool) external view returns (bool);

    function deployPool(address factory, bytes calldata deployData) external returns (address);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "../libraries/RebaseLibrary.sol";

/// @notice Minimal BentoBox vault interface.
/// @dev `token` is aliased as `address` from `IERC20` for simplicity.
interface IBentoBoxMinimal {
    /// @notice Balance per ERC-20 token per account in shares.
    function balanceOf(address, address) external view returns (uint256);

    /// @dev Helper function to represent an `amount` of `token` in shares.
    /// @param token The ERC-20 token.
    /// @param amount The `token` amount.
    /// @param roundUp If the result `share` should be rounded up.
    /// @return share The token amount represented in shares.
    function toShare(
        address token,
        uint256 amount,
        bool roundUp
    ) external view returns (uint256 share);

    /// @dev Helper function to represent shares back into the `token` amount.
    /// @param token The ERC-20 token.
    /// @param share The amount of shares.
    /// @param roundUp If the result should be rounded up.
    /// @return amount The share amount back into native representation.
    function toAmount(
        address token,
        uint256 share,
        bool roundUp
    ) external view returns (uint256 amount);

    /// @notice Registers this contract so that users can approve it for BentoBox.
    function registerProtocol() external;

    /// @notice Deposit an amount of `token` represented in either `amount` or `share`.
    /// @param token The ERC-20 token to deposit.
    /// @param from which account to pull the tokens.
    /// @param to which account to push the tokens.
    /// @param amount Token amount in native representation to deposit.
    /// @param share Token amount represented in shares to deposit. Takes precedence over `amount`.
    /// @return amountOut The amount deposited.
    /// @return shareOut The deposited amount represented in shares.
    function deposit(
        address token,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external payable returns (uint256 amountOut, uint256 shareOut);

    /// @notice Withdraws an amount of `token` from a user account.
    /// @param token_ The ERC-20 token to withdraw.
    /// @param from which user to pull the tokens.
    /// @param to which user to push the tokens.
    /// @param amount of tokens. Either one of `amount` or `share` needs to be supplied.
    /// @param share Like above, but `share` takes precedence over `amount`.
    function withdraw(
        address token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountOut, uint256 shareOut);

    /// @notice Transfer shares from a user account to another one.
    /// @param token The ERC-20 token to transfer.
    /// @param from which user to pull the tokens.
    /// @param to which user to push the tokens.
    /// @param share The amount of `token` in shares.
    function transfer(
        address token,
        address from,
        address to,
        uint256 share
    ) external;

    /// @dev Reads the Rebase `totals`from storage for a given token
    function totals(address token) external view returns (Rebase memory total);

    /// @dev Approves users' BentoBox assets to a "master" contract.
    function setMasterContractApproval(
        address user,
        address masterContract,
        bool approved,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function harvest(
        address token,
        bool balance,
        uint256 maxChangeAmount
    ) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

/// @notice Trident pool router interface.
interface ITridentRouter {
    struct Path {
        address pool;
        bytes data;
    }

    struct ExactInputSingleParams {
        uint256 amountIn;
        uint256 amountOutMinimum;
        address pool;
        address tokenIn;
        bytes data;
    }

    struct ExactInputParams {
        address tokenIn;
        uint256 amountIn;
        uint256 amountOutMinimum;
        Path[] path;
    }

    struct TokenInput {
        address token;
        bool native;
        uint256 amount;
    }

    struct InitialPath {
        address tokenIn;
        address pool;
        bool native;
        uint256 amount;
        bytes data;
    }

    struct PercentagePath {
        address tokenIn;
        address pool;
        uint64 balancePercentage; // Multiplied by 10^6. 100% = 100_000_000
        bytes data;
    }

    struct Output {
        address token;
        address to;
        bool unwrapBento;
        uint256 minAmount;
    }

    struct ComplexPathParams {
        InitialPath[] initialPath;
        PercentagePath[] percentagePath;
        Output[] output;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "./IConcentratedLiquidityPool.sol";
import "./ITridentNFT.sol";

/// @notice Trident concentrated liquidity pool manager contract Structs.
interface IConcentratedLiquidityPoolManagerStruct {
    struct Position {
        IConcentratedLiquidityPool pool;
        uint128 liquidity;
        int24 lower;
        int24 upper;
        uint32 latestAddition;
        uint256 feeGrowthInside0; /// @dev Per unit of liquidity.
        uint256 feeGrowthInside1;
    }
}

/// @notice Trident concentrated liquidity manager contract interface.
interface IConcentratedLiquidityPoolManager is IConcentratedLiquidityPoolManagerStruct, ITridentNFT {
    function positions(uint256) external view returns (Position memory);

    function bento() external view returns (IBentoBoxMinimal);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "./IBentoBoxMinimal.sol";
import "./IMasterDeployer.sol";
import "../libraries/Ticks.sol";

/// @notice Trident concentrated liquidity pool contract Structs.
interface IConcentratedLiquidityPoolStruct {
    struct Tick {
        int24 previousTick;
        int24 nextTick;
        uint128 liquidity;
        uint256 feeGrowthOutside0; // Per unit of liquidity.
        uint256 feeGrowthOutside1;
        uint160 secondsGrowthOutside;
    }
    struct Position {
        uint128 liquidity;
        uint256 feeGrowthInside0Last;
        uint256 feeGrowthInside1Last;
    }

    struct MintParams {
        int24 lowerOld;
        int24 lower;
        int24 upperOld;
        int24 upper;
        uint128 amount0Desired;
        uint128 amount1Desired;
        bool native;
    }

    struct SwapCache {
        uint256 feeAmount;
        uint256 totalFeeAmount;
        uint256 protocolFee;
        uint256 feeGrowthGlobalA;
        uint256 feeGrowthGlobalB;
        uint256 currentPrice;
        uint256 currentLiquidity;
        uint256 input;
        int24 nextTickToCross;
    }
}

/// @notice Trident Concentrated Liquidity Pool interface.
interface IConcentratedLiquidityPool is IConcentratedLiquidityPoolStruct {
    function ticks(int24 _tick) external view returns (Tick memory);

    function positions(
        address owner,
        int24 lower,
        int24 upper
    ) external view returns (Position memory);

    function feeGrowthGlobal0() external view returns (uint256);

    function feeGrowthGlobal1() external view returns (uint256);

    function rangeFeeGrowth(int24 lowerTick, int24 upperTick) external view returns (uint256 feeGrowthInside0, uint256 feeGrowthInside1);

    function setPrice(uint160 price) external;

    function collect(int24 lower, int24 upper) external returns (uint256 amount0fees, uint256 amount1fees);

    function mint(MintParams memory data) external returns (uint256 liquidityMinted);

    function burn(
        int24 lower,
        int24 upper,
        uint128 amount
    )
        external
        returns (
            uint256 token0Amount,
            uint256 token1Amount,
            uint256 token0Fees,
            uint256 token1Fees
        );

    function getImmutables()
        external
        view
        returns (
            uint128 _MAX_TICK_LIQUIDITY,
            uint24 _tickSpacing,
            uint24 _swapFee,
            address _barFeeTo,
            IBentoBoxMinimal _bento,
            IMasterDeployer _masterDeployer,
            address _token0,
            address _token1
        );

    function getPriceAndNearestTicks() external view returns (uint160 _price, int24 _nearestTick);

    function getTokenProtocolFees() external view returns (uint128 _token0ProtocolFee, uint128 _token1ProtocolFee);

    function getReserves() external view returns (uint128 _reserve0, uint128 _reserve1);

    function getAssets() external view returns (address[] memory tokens);

    function getSecondsGrowthAndLastObservation() external view returns (uint160 _secondGrowthGlobal, uint32 _lastObservation);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

/// @notice Trident concentrated Liquidity pool mint callback receiver.
interface IPositionManager {
    function mintCallback(
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1,
        bool native
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

/// @notice Math library that facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision.
/// @author Adapted from https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/libraries/FullMath.sol.
/// @dev Handles "phantom overflow", i.e., allows multiplication and division where an intermediate value overflows 256 bits.
library FullMath {
    /// @notice Calculates floor(a×b÷denominator) with full precision - throws if result overflows an uint256 or denominator == 0.
    /// @param a The multiplicand.
    /// @param b The multiplier.
    /// @param denominator The divisor.
    /// @return result The 256-bit result.
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv.
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = a * b.
            // Compute the product mod 2**256 and mod 2**256 - 1,
            // then use the Chinese Remainder Theorem to reconstruct
            // the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2**256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product.
            uint256 prod1; // Most significant 256 bits of the product.
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                require(denominator > 0);
                assembly {
                    result := div(prod0, denominator)
                }
                return result;
            }
            // Make sure the result is less than 2**256 -
            // also prevents denominator == 0.
            require(denominator > prod1);
            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////
            // Make division exact by subtracting the remainder from [prod1 prod0] -
            // compute remainder using mulmod.
            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
            }
            // Subtract 256 bit number from 512 bit number.
            assembly {
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }
            // Factor powers of two out of denominator -
            // compute largest power of two divisor of denominator
            // (always >= 1).
            uint256 twos = uint256(-int256(denominator)) & denominator;
            // Divide denominator by power of two.
            assembly {
                denominator := div(denominator, twos)
            }
            // Divide [prod1 prod0] by the factors of two.
            assembly {
                prod0 := div(prod0, twos)
            }
            // Shift in bits from prod1 into prod0. For this we need
            // to flip `twos` such that it is 2**256 / twos -
            // if twos is zero, then it becomes one.
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;
            // Invert denominator mod 2**256 -
            // now that denominator is an odd number, it has an inverse
            // modulo 2**256 such that denominator * inv = 1 mod 2**256.
            // Compute the inverse by starting with a seed that is correct
            // for four bits. That is, denominator * inv = 1 mod 2**4.
            uint256 inv = (3 * denominator) ^ 2;
            // Now use Newton-Raphson iteration to improve the precision.
            // Thanks to Hensel's lifting lemma, this also works in modular
            // arithmetic, doubling the correct bits in each step.
            inv *= 2 - denominator * inv; // Inverse mod 2**8.
            inv *= 2 - denominator * inv; // Inverse mod 2**16.
            inv *= 2 - denominator * inv; // Inverse mod 2**32.
            inv *= 2 - denominator * inv; // Inverse mod 2**64.
            inv *= 2 - denominator * inv; // Inverse mod 2**128.
            inv *= 2 - denominator * inv; // Inverse mod 2**256.
            // Because the division is now exact we can divide by multiplying
            // with the modular inverse of denominator. This will give us the
            // correct result modulo 2**256. Since the precoditions guarantee
            // that the outcome is less than 2**256, this is the final result.
            // We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inv;
            return result;
        }
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision - throws if result overflows an uint256 or denominator == 0.
    /// @param a The multiplicand.
    /// @param b The multiplier.
    /// @param denominator The divisor.
    /// @return result The 256-bit result.
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        unchecked {
            if (mulmod(a, b, denominator) != 0) {
                require(result < type(uint256).max);
                result++;
            }
        }
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

/// @notice Math library for computing sqrt price for ticks of size 1.0001, i.e., sqrt(1.0001^tick) as fixed point Q64.96 numbers - supports
/// prices between 2**-128 and 2**128 - 1.
/// @author Adapted from https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/libraries/TickMath.sol.
library TickMath {
    /// @dev The minimum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**-128.
    int24 internal constant MIN_TICK = -887272;
    /// @dev The maximum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**128 - 1.
    int24 internal constant MAX_TICK = -MIN_TICK;
    /// @dev The minimum value that can be returned from #getSqrtRatioAtTick - equivalent to getSqrtRatioAtTick(MIN_TICK).
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    /// @dev The maximum value that can be returned from #getSqrtRatioAtTick - equivalent to getSqrtRatioAtTick(MAX_TICK).
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    error TickOutOfBounds();
    error PriceOutOfBounds();

    /// @notice Calculates sqrt(1.0001^tick) * 2^96.
    /// @dev Throws if |tick| > max tick.
    /// @param tick The input tick for the above formula.
    /// @return sqrtPriceX96 Fixed point Q64.96 number representing the sqrt of the ratio of the two assets (token1/token0)
    /// at the given tick.
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        if (absTick > uint256(uint24(MAX_TICK))) revert TickOutOfBounds();
        unchecked {
            uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
            if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
            if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
            if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
            if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
            if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
            if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
            if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
            if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
            if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
            if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
            if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
            if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
            if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
            if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
            if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
            if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
            if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
            if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
            if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

            if (tick > 0) ratio = type(uint256).max / ratio;
            // This divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
            // We then downcast because we know the result always fits within 160 bits due to our tick input constraint.
            // We round up in the division so getTickAtSqrtRatio of the output price is always consistent.
            sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
        }
    }

    function validatePrice(uint160 price) internal pure {
        if (price < MIN_SQRT_RATIO || price >= MAX_SQRT_RATIO) revert PriceOutOfBounds();
    }

    /// @notice Calculates the greatest tick value such that getRatioAtTick(tick) <= ratio.
    /// @dev Throws in case sqrtPriceX96 < MIN_SQRT_RATIO, as MIN_SQRT_RATIO is the lowest value getRatioAtTick may
    /// ever return.
    /// @param sqrtPriceX96 The sqrt ratio for which to compute the tick as a Q64.96.
    /// @return tick The greatest tick for which the ratio is less than or equal to the input ratio.
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        // Second inequality must be < because the price can never reach the price at the max tick.
        if (sqrtPriceX96 < MIN_SQRT_RATIO || sqrtPriceX96 >= MAX_SQRT_RATIO) revert PriceOutOfBounds();
        uint256 ratio = uint256(sqrtPriceX96) << 32;

        uint256 r = ratio;
        uint256 msb;

        assembly {
            let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(5, gt(r, 0xFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(4, gt(r, 0xFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(3, gt(r, 0xFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(2, gt(r, 0xF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(1, gt(r, 0x3))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := gt(r, 0x1)
            msb := or(msb, f)
        }
        unchecked {
            if (msb >= 128) r = ratio >> (msb - 127);
            else r = ratio << (127 - msb);

            int256 log_2 = (int256(msb) - 128) << 64;

            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(63, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(62, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(61, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(60, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(59, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(58, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(57, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(56, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(55, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(54, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(53, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(52, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(51, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(50, f))
            }

            int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number.

            int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
            int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

            tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "./FullMath.sol";
import "./UnsafeMath.sol";
import "./SafeCast.sol";

/// @notice Math library that facilitates ranged liquidity calculations.
library DyDxMath {
    function getDy(
        uint256 liquidity,
        uint256 priceLower,
        uint256 priceUpper,
        bool roundUp
    ) internal pure returns (uint256 dy) {
        unchecked {
            if (roundUp) {
                dy = FullMath.mulDivRoundingUp(liquidity, priceUpper - priceLower, 0x1000000000000000000000000);
            } else {
                dy = FullMath.mulDiv(liquidity, priceUpper - priceLower, 0x1000000000000000000000000);
            }
        }
    }

    function getDx(
        uint256 liquidity,
        uint256 priceLower,
        uint256 priceUpper,
        bool roundUp
    ) internal pure returns (uint256 dx) {
        unchecked {
            if (roundUp) {
                dx = UnsafeMath.divRoundingUp(FullMath.mulDivRoundingUp(liquidity << 96, priceUpper - priceLower, priceUpper), priceLower);
            } else {
                dx = FullMath.mulDiv(liquidity << 96, priceUpper - priceLower, priceUpper) / priceLower;
            }
        }
    }

    function getLiquidityForAmounts(
        uint256 priceLower,
        uint256 priceUpper,
        uint256 currentPrice,
        uint256 dy,
        uint256 dx
    ) public pure returns (uint256 liquidity) {
        unchecked {
            if (priceUpper <= currentPrice) {
                liquidity = FullMath.mulDiv(dy, 0x1000000000000000000000000, priceUpper - priceLower);
            } else if (currentPrice <= priceLower) {
                liquidity = FullMath.mulDiv(
                    dx,
                    FullMath.mulDiv(priceLower, priceUpper, 0x1000000000000000000000000),
                    priceUpper - priceLower
                );
            } else {
                uint256 liquidity0 = FullMath.mulDiv(
                    dx,
                    FullMath.mulDiv(priceUpper, currentPrice, 0x1000000000000000000000000),
                    priceUpper - currentPrice
                );
                uint256 liquidity1 = FullMath.mulDiv(dy, 0x1000000000000000000000000, currentPrice - priceLower);
                liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
            }
        }
    }

    function getAmountsForLiquidity(
        uint256 priceLower,
        uint256 priceUpper,
        uint256 currentPrice,
        uint256 liquidityAmount,
        bool roundUp
    ) internal pure returns (uint128 token0amount, uint128 token1amount) {
        if (priceUpper <= currentPrice) {
            // Only supply `token1` (`token1` is Y).
            token1amount = SafeCast.toUint128(DyDxMath.getDy(liquidityAmount, priceLower, priceUpper, roundUp));
        } else if (currentPrice <= priceLower) {
            // Only supply `token0` (`token0` is X).
            token0amount = SafeCast.toUint128(DyDxMath.getDx(liquidityAmount, priceLower, priceUpper, roundUp));
        } else {
            // Supply both tokens.
            token0amount = SafeCast.toUint128(DyDxMath.getDx(liquidityAmount, currentPrice, priceUpper, roundUp));
            token1amount = SafeCast.toUint128(DyDxMath.getDy(liquidityAmount, priceLower, currentPrice, roundUp));
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8;

struct Rebase {
    uint128 elastic;
    uint128 base;
}

/// @notice A rebasing library
library RebaseLibrary {
    /// @notice Calculates the base value in relationship to `elastic` and `total`.
    function toBase(Rebase memory total, uint256 elastic) internal pure returns (uint256 base) {
        if (total.elastic == 0) {
            base = elastic;
        } else {
            base = (elastic * total.base) / total.elastic;
        }
    }

    /// @notice Calculates the elastic value in relationship to `base` and `total`.
    function toElastic(Rebase memory total, uint256 base) internal pure returns (uint256 elastic) {
        if (total.base == 0) {
            elastic = base;
        } else {
            elastic = (base * total.elastic) / total.base;
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

/// @notice Trident NFT interface.
interface ITridentNFT {
    function ownerOf(uint256) external view returns (address);
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

import "./TickMath.sol";
import "../interfaces/IConcentratedLiquidityPool.sol";

/// @notice Tick management library for ranged liquidity.
library Ticks {
    function getMaxLiquidity(uint24 _tickSpacing) public pure returns (uint128) {
        return type(uint128).max / uint128(uint24(TickMath.MAX_TICK) / (2 * uint24(_tickSpacing)));
    }

    function cross(
        mapping(int24 => IConcentratedLiquidityPoolStruct.Tick) storage ticks,
        int24 nextTickToCross,
        uint160 secondsGrowthGlobal,
        uint256 currentLiquidity,
        uint256 feeGrowthGlobalA,
        uint256 feeGrowthGlobalB,
        bool zeroForOne,
        uint24 tickSpacing
    ) internal returns (uint256, int24) {
        ticks[nextTickToCross].secondsGrowthOutside = secondsGrowthGlobal - ticks[nextTickToCross].secondsGrowthOutside;

        if (zeroForOne) {
            // Moving backwards through the linked list.
            // Liquidity cannot overflow due to the MAX_TICK_LIQUIDITY requirement.
            unchecked {
                if ((nextTickToCross / int24(tickSpacing)) % 2 == 0) {
                    currentLiquidity -= ticks[nextTickToCross].liquidity;
                } else {
                    currentLiquidity += ticks[nextTickToCross].liquidity;
                }
            }
            ticks[nextTickToCross].feeGrowthOutside0 = feeGrowthGlobalB - ticks[nextTickToCross].feeGrowthOutside0;
            ticks[nextTickToCross].feeGrowthOutside1 = feeGrowthGlobalA - ticks[nextTickToCross].feeGrowthOutside1;
            nextTickToCross = ticks[nextTickToCross].previousTick;
        } else {
            // Moving forwards through the linked list.
            unchecked {
                if ((nextTickToCross / int24(tickSpacing)) % 2 == 0) {
                    currentLiquidity += ticks[nextTickToCross].liquidity;
                } else {
                    currentLiquidity -= ticks[nextTickToCross].liquidity;
                }
            }
            ticks[nextTickToCross].feeGrowthOutside1 = feeGrowthGlobalB - ticks[nextTickToCross].feeGrowthOutside1;
            ticks[nextTickToCross].feeGrowthOutside0 = feeGrowthGlobalA - ticks[nextTickToCross].feeGrowthOutside0;
            nextTickToCross = ticks[nextTickToCross].nextTick;
        }
        return (currentLiquidity, nextTickToCross);
    }

    function insert(
        mapping(int24 => IConcentratedLiquidityPoolStruct.Tick) storage ticks,
        uint256 feeGrowthGlobal0,
        uint256 feeGrowthGlobal1,
        uint160 secondsGrowthGlobal,
        int24 lowerOld,
        int24 lower,
        int24 upperOld,
        int24 upper,
        uint128 amount,
        int24 nearestTick,
        uint160 currentPrice
    ) public returns (int24) {
        require(lower < upper, "WRONG_ORDER");
        require(TickMath.MIN_TICK <= lower, "LOWER_RANGE");
        require(upper <= TickMath.MAX_TICK, "UPPER_RANGE");

        {
            // Stack overflow.
            uint128 currentLowerLiquidity = ticks[lower].liquidity;
            if (currentLowerLiquidity != 0 || lower == TickMath.MIN_TICK) {
                // We are adding liquidity to an existing tick.
                ticks[lower].liquidity = currentLowerLiquidity + amount;
            } else {
                // We are inserting a new tick.
                IConcentratedLiquidityPoolStruct.Tick storage old = ticks[lowerOld];
                int24 oldNextTick = old.nextTick;

                require((old.liquidity != 0 || lowerOld == TickMath.MIN_TICK) && lowerOld < lower && lower < oldNextTick, "LOWER_ORDER");

                if (lower <= nearestTick) {
                    ticks[lower] = IConcentratedLiquidityPoolStruct.Tick(
                        lowerOld,
                        oldNextTick,
                        amount,
                        feeGrowthGlobal0,
                        feeGrowthGlobal1,
                        secondsGrowthGlobal
                    );
                } else {
                    ticks[lower] = IConcentratedLiquidityPoolStruct.Tick(lowerOld, oldNextTick, amount, 0, 0, 0);
                }

                old.nextTick = lower;
                ticks[oldNextTick].previousTick = lower;
            }
        }

        uint128 currentUpperLiquidity = ticks[upper].liquidity;
        if (currentUpperLiquidity != 0 || upper == TickMath.MAX_TICK) {
            // We are adding liquidity to an existing tick.
            ticks[upper].liquidity = currentUpperLiquidity + amount;
        } else {
            // Inserting a new tick.
            IConcentratedLiquidityPoolStruct.Tick storage old = ticks[upperOld];
            int24 oldNextTick = old.nextTick;

            require(old.liquidity != 0 && oldNextTick > upper && upperOld < upper, "UPPER_ORDER");

            if (upper <= nearestTick) {
                ticks[upper] = IConcentratedLiquidityPoolStruct.Tick(
                    upperOld,
                    oldNextTick,
                    amount,
                    feeGrowthGlobal0,
                    feeGrowthGlobal1,
                    secondsGrowthGlobal
                );
            } else {
                ticks[upper] = IConcentratedLiquidityPoolStruct.Tick(upperOld, oldNextTick, amount, 0, 0, 0);
            }
            old.nextTick = upper;
            ticks[oldNextTick].previousTick = upper;
        }

        int24 tickAtPrice = TickMath.getTickAtSqrtRatio(currentPrice);

        if (nearestTick < upper && upper <= tickAtPrice) {
            nearestTick = upper;
        } else if (nearestTick < lower && lower <= tickAtPrice) {
            nearestTick = lower;
        }

        return nearestTick;
    }

    function remove(
        mapping(int24 => IConcentratedLiquidityPoolStruct.Tick) storage ticks,
        int24 lower,
        int24 upper,
        uint128 amount,
        int24 nearestTick
    ) public returns (int24) {
        IConcentratedLiquidityPoolStruct.Tick storage current = ticks[lower];

        if (lower != TickMath.MIN_TICK && current.liquidity == amount) {
            // Delete lower tick.
            IConcentratedLiquidityPoolStruct.Tick storage previous = ticks[current.previousTick];
            IConcentratedLiquidityPoolStruct.Tick storage next = ticks[current.nextTick];

            previous.nextTick = current.nextTick;
            next.previousTick = current.previousTick;

            if (nearestTick == lower) nearestTick = current.previousTick;

            delete ticks[lower];
        } else {
            unchecked {
                current.liquidity -= amount;
            }
        }

        current = ticks[upper];

        if (upper != TickMath.MAX_TICK && current.liquidity == amount) {
            // Delete upper tick.
            IConcentratedLiquidityPoolStruct.Tick storage previous = ticks[current.previousTick];
            IConcentratedLiquidityPoolStruct.Tick storage next = ticks[current.nextTick];

            previous.nextTick = current.nextTick;
            next.previousTick = current.previousTick;

            if (nearestTick == upper) nearestTick = current.previousTick;

            delete ticks[upper];
        } else {
            unchecked {
                current.liquidity -= amount;
            }
        }

        return nearestTick;
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.5.0;

/// @notice Math library that contains methods that perform common math functions but do not do any overflow or underflow checks.
/// @author Adapted from https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/libraries/UnsafeMath.sol.
library UnsafeMath {
    /// @notice Returns ceil(x / y).
    /// @dev Division by 0 has unspecified behavior, and must be checked externally.
    /// @param x The dividend.
    /// @param y The divisor.
    /// @return z The quotient, ceil(x / y).
    function divRoundingUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := add(div(x, y), gt(mod(x, y), 0))
        }
    }
}

//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

library SafeCast {
    function toUint160(uint256 y) internal pure returns (uint160 z) {
        require((z = uint160(y)) == y);
    }

    function toUint128(uint256 y) internal pure returns (uint128 z) {
        require((z = uint128(y)) == y);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "../../interfaces/IBentoBoxMinimal.sol";
import "../../interfaces/IMasterDeployer.sol";
import "../../interfaces/ITridentCallee.sol";
import "../../interfaces/ITridentRouter.sol";
import "../../interfaces/IPositionManager.sol";
import "../../interfaces/IConcentratedLiquidityPool.sol";
import "../../libraries/FullMath.sol";
import "../../libraries/TickMath.sol";
import "../../libraries/UnsafeMath.sol";
import "../../libraries/DyDxMath.sol";
import "../../libraries/SwapLib.sol";
import "../../libraries/Ticks.sol";

/// @notice Trident Concentrated liquidity pool implementation.
/// @dev Amounts are considered to be in Bentobox shared
contract ConcentratedLiquidityPool is IConcentratedLiquidityPoolStruct {
    using Ticks for mapping(int24 => Tick);

    event Mint(address indexed owner, uint256 amount0, uint256 amount1);
    event Burn(address indexed owner, uint256 amount0, uint256 amount1);
    event Collect(address indexed sender, uint256 amount0, uint256 amount1);
    event Swap(address indexed recipient, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    uint24 internal constant MAX_FEE = 100000; /// @dev Maximum `swapFee` is 10%.
    /// @dev Reference: tickSpacing of 100 -> 2% between ticks.
    uint24 internal immutable tickSpacing;
    uint24 internal immutable swapFee; /// @dev 1000 corresponds to 0.1% fee. Fee is measured in pips.
    uint128 internal immutable MAX_TICK_LIQUIDITY;

    address internal immutable barFeeTo;
    IBentoBoxMinimal internal immutable bento;
    IMasterDeployer internal immutable masterDeployer;

    address internal immutable token0;
    address internal immutable token1;

    uint128 public liquidity;

    uint160 internal secondsGrowthGlobal; /// @dev Multiplied by 2^128.
    uint32 internal lastObservation;

    uint256 public feeGrowthGlobal0; /// @dev All fee growth counters are multiplied by 2^128.
    uint256 public feeGrowthGlobal1;

    uint256 public barFee;

    uint128 internal token0ProtocolFee;
    uint128 internal token1ProtocolFee;

    uint128 internal reserve0; /// @dev `bento` share balance tracker.
    uint128 internal reserve1;

    uint160 internal price; /// @dev Sqrt of price aka. √(y/x), multiplied by 2^96.
    int24 internal nearestTick; /// @dev Tick that is just below the current price.

    uint256 internal unlocked;

    mapping(int24 => Tick) public ticks;
    mapping(address => mapping(int24 => mapping(int24 => Position))) public positions;

    /// @dev Error list to optimize around pool requirements.
    error Locked();
    error ZeroAddress();
    error InvalidToken();
    error InvalidSwapFee();
    error LiquidityOverflow();
    error Token0Missing();
    error Token1Missing();
    error InvalidTick();
    error LowerEven();
    error UpperOdd();
    error MaxTickLiquidity();
    error Overflow();

    modifier lock() {
        if (unlocked == 2) revert Locked();
        unlocked = 2;
        _;
        unlocked = 1;
    }

    /// @dev Only set immutable variables here - state changes made here will not be used.
    constructor(bytes memory _deployData, IMasterDeployer _masterDeployer) {
        (address _token0, address _token1, uint24 _swapFee, uint24 _tickSpacing) = abi.decode(
            _deployData,
            (address, address, uint24, uint24)
        );

        if (_token0 == address(0)) revert ZeroAddress();
        if (_token0 == address(this)) revert InvalidToken();
        if (_token1 == address(this)) revert InvalidToken();
        if (_swapFee > MAX_FEE) revert InvalidSwapFee();

        token0 = _token0;
        token1 = _token1;
        swapFee = _swapFee;
        tickSpacing = _tickSpacing;
        bento = IBentoBoxMinimal(_masterDeployer.bento());
        barFeeTo = _masterDeployer.barFeeTo();
        barFee = _masterDeployer.barFee();
        masterDeployer = _masterDeployer;
        MAX_TICK_LIQUIDITY = Ticks.getMaxLiquidity(_tickSpacing);
        ticks[TickMath.MIN_TICK] = Tick(TickMath.MIN_TICK, TickMath.MAX_TICK, uint128(0), 0, 0, 0);
        ticks[TickMath.MAX_TICK] = Tick(TickMath.MIN_TICK, TickMath.MAX_TICK, uint128(0), 0, 0, 0);
        nearestTick = TickMath.MIN_TICK;
        unlocked = 1;
        lastObservation = uint32(block.timestamp);
    }

    /// @dev Called only once from the factory.
    /// @dev Price is not a constructor parameter to allow for predictable address calculation.
    function setPrice(uint160 _price) external {
        if (price == 0) {
            TickMath.validatePrice(_price);
            price = _price;
        }
    }

    /// @dev Mints LP tokens - should be called via the CL pool manager contract.
    function mint(MintParams memory mintParams) public lock returns (uint256 liquidityMinted) {
        _ensureTickSpacing(mintParams.lower, mintParams.upper);

        uint256 priceLower = uint256(TickMath.getSqrtRatioAtTick(mintParams.lower));
        uint256 priceUpper = uint256(TickMath.getSqrtRatioAtTick(mintParams.upper));
        uint256 currentPrice = uint256(price);

        liquidityMinted = DyDxMath.getLiquidityForAmounts(
            priceLower,
            priceUpper,
            currentPrice,
            uint256(mintParams.amount1Desired),
            uint256(mintParams.amount0Desired)
        );

        // Ensure no overflow happens when we cast from uint256 to int128.
        if (liquidityMinted > uint128(type(int128).max)) revert Overflow();

        _updateSecondsPerLiquidity(uint256(liquidity));

        unchecked {
            (uint256 amount0Fees, uint256 amount1Fees) = _updatePosition(
                msg.sender,
                mintParams.lower,
                mintParams.upper,
                int128(uint128(liquidityMinted))
            );
            if (amount0Fees > 0) {
                _transfer(token0, amount0Fees, msg.sender, false);
                reserve0 -= uint128(amount0Fees);
            }
            if (amount1Fees > 0) {
                _transfer(token1, amount1Fees, msg.sender, false);
                reserve1 -= uint128(amount1Fees);
            }

            if (priceLower <= currentPrice && currentPrice < priceUpper) liquidity += uint128(liquidityMinted);
        }

        nearestTick = Ticks.insert(
            ticks,
            feeGrowthGlobal0,
            feeGrowthGlobal1,
            secondsGrowthGlobal,
            mintParams.lowerOld,
            mintParams.lower,
            mintParams.upperOld,
            mintParams.upper,
            uint128(liquidityMinted),
            nearestTick,
            uint160(currentPrice)
        );

        (uint128 amount0Actual, uint128 amount1Actual) = DyDxMath.getAmountsForLiquidity(
            priceLower,
            priceUpper,
            currentPrice,
            liquidityMinted,
            true
        );

        IPositionManager(msg.sender).mintCallback(token0, token1, amount0Actual, amount1Actual, mintParams.native);

        if (amount0Actual != 0) {
            reserve0 += amount0Actual;
            if (reserve0 > _balance(token0)) revert Token0Missing();
        }

        if (amount1Actual != 0) {
            reserve1 += amount1Actual;
            if (reserve1 > _balance(token1)) revert Token1Missing();
        }

        emit Mint(msg.sender, amount0Actual, amount1Actual);
    }

    function burn(
        int24 lower,
        int24 upper,
        uint128 amount
    )
        public
        lock
        returns (
            uint256 token0Amount,
            uint256 token1Amount,
            uint256 token0Fees,
            uint256 token1Fees
        )
    {
        uint160 priceLower = TickMath.getSqrtRatioAtTick(lower);
        uint160 priceUpper = TickMath.getSqrtRatioAtTick(upper);
        uint160 currentPrice = price;

        _updateSecondsPerLiquidity(uint256(liquidity));

        unchecked {
            if (priceLower <= currentPrice && currentPrice < priceUpper) liquidity -= amount;
        }

        (token0Amount, token1Amount) = DyDxMath.getAmountsForLiquidity(
            uint256(priceLower),
            uint256(priceUpper),
            uint256(currentPrice),
            uint256(amount),
            false
        );

        // Ensure no overflow happens when we cast from uint128 to int128.
        if (amount > uint128(type(int128).max)) revert Overflow();

        (token0Fees, token1Fees) = _updatePosition(msg.sender, lower, upper, -int128(amount));

        uint256 amount0;
        uint256 amount1;

        unchecked {
            amount0 = token0Amount + token0Fees;
            amount1 = token1Amount + token1Fees;
            reserve0 -= uint128(amount0);
            reserve1 -= uint128(amount1);
        }

        _transferBothTokens(msg.sender, amount0, amount1);

        nearestTick = Ticks.remove(ticks, lower, upper, amount, nearestTick);

        emit Burn(msg.sender, amount0, amount1);
    }

    function collect(int24 lower, int24 upper) public lock returns (uint256 amount0fees, uint256 amount1fees) {
        (amount0fees, amount1fees) = _updatePosition(msg.sender, lower, upper, 0);

        reserve0 -= uint128(amount0fees);
        reserve1 -= uint128(amount1fees);

        _transferBothTokens(msg.sender, amount0fees, amount1fees);

        emit Collect(msg.sender, amount0fees, amount1fees);
    }

    function _updateSecondsPerLiquidity(uint256 currentLiquidity) internal {
        unchecked {
            uint256 diff = block.timestamp - uint256(lastObservation);
            if (diff > 0 && currentLiquidity > 0) {
                lastObservation = uint32(block.timestamp); // Overfyarnlow in 2106. Don't do staking rewards in the year 2106.
                secondsGrowthGlobal += uint160((diff << 128) / currentLiquidity);
            }
        }
    }

    /// @dev Swaps one token for another. The router must prefund this contract and ensure there isn't too much slippage.
    function swap(bytes memory data) public lock returns (uint256 amountOut) {
        (bool zeroForOne, address recipient, bool unwrapBento) = abi.decode(data, (bool, address, bool));

        uint256 inAmount = _balance(zeroForOne ? token0 : token1) - (zeroForOne ? reserve0 : reserve1);

        SwapCache memory cache = SwapCache({
            feeAmount: 0,
            totalFeeAmount: 0,
            protocolFee: 0,
            feeGrowthGlobalA: zeroForOne ? feeGrowthGlobal1 : feeGrowthGlobal0,
            feeGrowthGlobalB: zeroForOne ? feeGrowthGlobal0 : feeGrowthGlobal1,
            currentPrice: uint256(price),
            currentLiquidity: uint256(liquidity),
            input: inAmount,
            nextTickToCross: zeroForOne ? nearestTick : ticks[nearestTick].nextTick
        });

        _updateSecondsPerLiquidity(cache.currentLiquidity);

        while (cache.input != 0) {
            uint256 nextTickPrice = uint256(TickMath.getSqrtRatioAtTick(cache.nextTickToCross));
            uint256 output = 0;
            bool cross = false;

            if (zeroForOne) {
                // Trading token 0 (x) for token 1 (y).
                // Price is decreasing.
                // Maximum input amount within current tick range: Δx = Δ(1/√𝑃) · L.
                uint256 maxDx = DyDxMath.getDx(cache.currentLiquidity, nextTickPrice, cache.currentPrice, false);

                if (cache.input <= maxDx) {
                    // We can swap within the current range.
                    uint256 liquidityPadded = cache.currentLiquidity << 96;
                    // Calculate new price after swap: √𝑃[new] =  L · √𝑃 / (L + Δx · √𝑃)
                    // This is derived from Δ(1/√𝑃) = Δx/L
                    // where Δ(1/√𝑃) is 1/√𝑃[old] - 1/√𝑃[new] and we solve for √𝑃[new].
                    // In case of an overflow we can use: √𝑃[new] = L / (L / √𝑃 + Δx).
                    // This is derived by dividing the original fraction by √𝑃 on both sides.
                    uint256 newPrice = uint256(
                        FullMath.mulDivRoundingUp(liquidityPadded, cache.currentPrice, liquidityPadded + cache.currentPrice * cache.input)
                    );

                    if (!(nextTickPrice <= newPrice && newPrice < cache.currentPrice)) {
                        // Overflow. We use a modified version of the formula.
                        newPrice = uint160(UnsafeMath.divRoundingUp(liquidityPadded, liquidityPadded / cache.currentPrice + cache.input));
                    }
                    // Based on the price difference calculate the output of th swap: Δy = Δ√P · L.
                    output = DyDxMath.getDy(cache.currentLiquidity, newPrice, cache.currentPrice, false);
                    cache.currentPrice = newPrice;
                    cache.input = 0;
                } else {
                    // Execute swap step and cross the tick.
                    output = DyDxMath.getDy(cache.currentLiquidity, nextTickPrice, cache.currentPrice, false);
                    cache.currentPrice = nextTickPrice;
                    cross = true;
                    cache.input -= maxDx;
                }
            } else {
                // Price is increasing.
                // Maximum swap amount within the current tick range: Δy = Δ√P · L.
                uint256 maxDy = DyDxMath.getDy(cache.currentLiquidity, cache.currentPrice, nextTickPrice, false);

                if (cache.input <= maxDy) {
                    // We can swap within the current range.
                    // Calculate new price after swap: ΔP = Δy/L.
                    uint256 newPrice = cache.currentPrice +
                        FullMath.mulDiv(cache.input, 0x1000000000000000000000000, cache.currentLiquidity);
                    // Calculate output of swap
                    // - Δx = Δ(1/√P) · L.
                    output = DyDxMath.getDx(cache.currentLiquidity, cache.currentPrice, newPrice, false);
                    cache.currentPrice = newPrice;
                    cache.input = 0;
                } else {
                    // Swap & cross the tick.
                    output = DyDxMath.getDx(cache.currentLiquidity, cache.currentPrice, nextTickPrice, false);
                    cache.currentPrice = nextTickPrice;
                    cross = true;
                    cache.input -= maxDy;
                }
            }

            // cache.feeGrowthGlobalA is the feeGrowthGlobal counter for the output token.
            // It increases each swap step.
            (cache.totalFeeAmount, amountOut, cache.protocolFee, cache.feeGrowthGlobalA) = SwapLib.handleFees(
                output,
                swapFee,
                barFee,
                cache.currentLiquidity,
                cache.totalFeeAmount,
                amountOut,
                cache.protocolFee,
                cache.feeGrowthGlobalA
            );
            if (cross) {
                (cache.currentLiquidity, cache.nextTickToCross) = Ticks.cross(
                    ticks,
                    cache.nextTickToCross,
                    secondsGrowthGlobal,
                    cache.currentLiquidity,
                    cache.feeGrowthGlobalA,
                    cache.feeGrowthGlobalB,
                    zeroForOne,
                    tickSpacing
                );
                if (cache.currentLiquidity == 0) {
                    // We step into a zone that has liquidity - or we reach the end of the linked list.
                    cache.currentPrice = uint256(TickMath.getSqrtRatioAtTick(cache.nextTickToCross));
                    (cache.currentLiquidity, cache.nextTickToCross) = Ticks.cross(
                        ticks,
                        cache.nextTickToCross,
                        secondsGrowthGlobal,
                        cache.currentLiquidity,
                        cache.feeGrowthGlobalA,
                        cache.feeGrowthGlobalB,
                        zeroForOne,
                        tickSpacing
                    );
                }
            }
        }

        price = uint160(cache.currentPrice);

        int24 newNearestTick = zeroForOne ? cache.nextTickToCross : ticks[cache.nextTickToCross].previousTick;

        if (nearestTick != newNearestTick) {
            nearestTick = newNearestTick;
            liquidity = uint128(cache.currentLiquidity);
        }

        _updateReserves(zeroForOne, uint128(inAmount), amountOut);

        _updateFees(zeroForOne, cache.feeGrowthGlobalA, uint128(cache.protocolFee));

        if (zeroForOne) {
            _transfer(token1, amountOut, recipient, unwrapBento);
            emit Swap(recipient, token0, token1, inAmount, amountOut);
        } else {
            _transfer(token0, amountOut, recipient, unwrapBento);
            emit Swap(recipient, token1, token0, inAmount, amountOut);
        }
    }

    /// @dev Updates `barFee` for Trident protocol.
    function updateBarFee() public {
        barFee = IMasterDeployer(masterDeployer).barFee();
    }

    /// @dev Collects fees for Trident protocol.
    function collectProtocolFee() public lock returns (uint128 amount0, uint128 amount1) {
        if (token0ProtocolFee > 1) {
            amount0 = token0ProtocolFee - 1;
            token0ProtocolFee = 1;
            reserve0 -= amount0;
            _transfer(token0, amount0, barFeeTo, false);
        }
        if (token1ProtocolFee > 1) {
            amount1 = token1ProtocolFee - 1;
            token1ProtocolFee = 1;
            reserve1 -= amount1;
            _transfer(token1, amount1, barFeeTo, false);
        }
    }

    function _ensureTickSpacing(int24 lower, int24 upper) internal view {
        if (lower % int24(tickSpacing) != 0) revert InvalidTick();
        if ((lower / int24(tickSpacing)) % 2 != 0) revert LowerEven();
        if (upper % int24(tickSpacing) != 0) revert InvalidTick();
        if ((upper / int24(tickSpacing)) % 2 == 0) revert UpperOdd();
    }

    function _updateReserves(
        bool zeroForOne,
        uint128 inAmount,
        uint256 amountOut
    ) internal {
        if (zeroForOne) {
            uint256 balance0 = _balance(token0);
            uint128 newBalance = reserve0 + inAmount;
            if (uint256(newBalance) > balance0) revert Token0Missing();
            reserve0 = newBalance;
            unchecked {
                reserve1 -= uint128(amountOut);
            }
        } else {
            uint256 balance1 = _balance(token1);
            uint128 newBalance = reserve1 + inAmount;
            if (uint256(newBalance) > balance1) revert Token1Missing();
            reserve1 = newBalance;
            unchecked {
                reserve0 -= uint128(amountOut);
            }
        }
    }

    function _updateFees(
        bool zeroForOne,
        uint256 feeGrowthGlobal,
        uint128 protocolFee
    ) internal {
        if (zeroForOne) {
            feeGrowthGlobal1 = feeGrowthGlobal;
            token1ProtocolFee += protocolFee;
        } else {
            feeGrowthGlobal0 = feeGrowthGlobal;
            token0ProtocolFee += protocolFee;
        }
    }

    function _updatePosition(
        address owner,
        int24 lower,
        int24 upper,
        int128 amount
    ) internal returns (uint256 amount0Fees, uint256 amount1Fees) {
        Position storage position = positions[owner][lower][upper];

        (uint256 rangeFeeGrowth0, uint256 rangeFeeGrowth1) = rangeFeeGrowth(lower, upper);

        amount0Fees = FullMath.mulDiv(
            rangeFeeGrowth0 - position.feeGrowthInside0Last,
            position.liquidity,
            0x100000000000000000000000000000000
        );

        amount1Fees = FullMath.mulDiv(
            rangeFeeGrowth1 - position.feeGrowthInside1Last,
            position.liquidity,
            0x100000000000000000000000000000000
        );

        if (amount < 0) {
            position.liquidity -= uint128(-amount);
        }

        if (amount > 0) {
            position.liquidity += uint128(amount);
            // Prevents a global liquidity overflow in even if all ticks are initialised.
            if (position.liquidity > MAX_TICK_LIQUIDITY) revert LiquidityOverflow();
        }

        position.feeGrowthInside0Last = rangeFeeGrowth0;
        position.feeGrowthInside1Last = rangeFeeGrowth1;
    }

    function _balance(address token) internal view returns (uint256 balance) {
        balance = bento.balanceOf(token, address(this));
    }

    function _transfer(
        address token,
        uint256 shares,
        address to,
        bool unwrapBento
    ) internal {
        if (unwrapBento) {
            bento.withdraw(token, address(this), to, 0, shares);
        } else {
            bento.transfer(token, address(this), to, shares);
        }
    }

    function _transferBothTokens(
        address to,
        uint256 shares0,
        uint256 shares1
    ) internal {
        bento.transfer(token0, address(this), to, shares0);
        bento.transfer(token1, address(this), to, shares1);
    }

    /// @dev Generic formula for fee growth inside a range: (globalGrowth - growthBelow - growthAbove)
    /// - available counters: global, outside u, outside v.

    ///                  u         ▼         v
    /// ----|----|-------|xxxxxxxxxxxxxxxxxxx|--------|--------- (global - feeGrowthOutside(u) - feeGrowthOutside(v))

    ///             ▼    u                   v
    /// ----|----|-------|xxxxxxxxxxxxxxxxxxx|--------|--------- (global - (global - feeGrowthOutside(u)) - feeGrowthOutside(v))

    ///                  u                   v    ▼
    /// ----|----|-------|xxxxxxxxxxxxxxxxxxx|--------|--------- (global - feeGrowthOutside(u) - (global - feeGrowthOutside(v)))

    /// @notice Calculates the fee growth inside a range (per unit of liquidity).
    /// @dev Multiply `rangeFeeGrowth` delta by the provided liquidity to get accrued fees for some period.
    function rangeFeeGrowth(int24 lowerTick, int24 upperTick) public view returns (uint256 feeGrowthInside0, uint256 feeGrowthInside1) {
        int24 currentTick = nearestTick;

        Tick storage lower = ticks[lowerTick];
        Tick storage upper = ticks[upperTick];

        // Calculate fee growth below & above.
        uint256 _feeGrowthGlobal0 = feeGrowthGlobal0;
        uint256 _feeGrowthGlobal1 = feeGrowthGlobal1;
        uint256 feeGrowthBelow0;
        uint256 feeGrowthBelow1;
        uint256 feeGrowthAbove0;
        uint256 feeGrowthAbove1;

        if (lowerTick <= currentTick) {
            feeGrowthBelow0 = lower.feeGrowthOutside0;
            feeGrowthBelow1 = lower.feeGrowthOutside1;
        } else {
            feeGrowthBelow0 = _feeGrowthGlobal0 - lower.feeGrowthOutside0;
            feeGrowthBelow1 = _feeGrowthGlobal1 - lower.feeGrowthOutside1;
        }

        if (currentTick < upperTick) {
            feeGrowthAbove0 = upper.feeGrowthOutside0;
            feeGrowthAbove1 = upper.feeGrowthOutside1;
        } else {
            feeGrowthAbove0 = _feeGrowthGlobal0 - upper.feeGrowthOutside0;
            feeGrowthAbove1 = _feeGrowthGlobal1 - upper.feeGrowthOutside1;
        }

        feeGrowthInside0 = _feeGrowthGlobal0 - feeGrowthBelow0 - feeGrowthAbove0;
        feeGrowthInside1 = _feeGrowthGlobal1 - feeGrowthBelow1 - feeGrowthAbove1;
    }

    function getAssets() public view returns (address[] memory assets) {
        assets = new address[](2);
        assets[0] = token0;
        assets[1] = token1;
    }

    function getImmutables()
        public
        view
        returns (
            uint128 _MAX_TICK_LIQUIDITY,
            uint24 _tickSpacing,
            uint24 _swapFee,
            address _barFeeTo,
            IBentoBoxMinimal _bento,
            IMasterDeployer _masterDeployer,
            address _token0,
            address _token1
        )
    {
        _MAX_TICK_LIQUIDITY = MAX_TICK_LIQUIDITY;
        _tickSpacing = tickSpacing;
        _swapFee = swapFee; // 1000 corresponds to 0.1% fee.
        _barFeeTo = barFeeTo;
        _bento = bento;
        _masterDeployer = masterDeployer;
        _token0 = token0;
        _token1 = token1;
    }

    function getPriceAndNearestTicks() public view returns (uint160 _price, int24 _nearestTick) {
        _price = price;
        _nearestTick = nearestTick;
    }

    function getTokenProtocolFees() public view returns (uint128 _token0ProtocolFee, uint128 _token1ProtocolFee) {
        _token0ProtocolFee = token0ProtocolFee;
        _token1ProtocolFee = token1ProtocolFee;
    }

    function getReserves() public view returns (uint128 _reserve0, uint128 _reserve1) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    }

    function getSecondsGrowthAndLastObservation() public view returns (uint160 _secondsGrowthGlobal, uint32 _lastObservation) {
        _secondsGrowthGlobal = secondsGrowthGlobal;
        _lastObservation = lastObservation;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

/// @notice Trident pool callback interface.
interface ITridentCallee {
    function tridentSwapCallback(bytes calldata data) external;

    function tridentMintCallback(bytes calldata data) external;
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

import "./FullMath.sol";

/// @notice Math library that facilitates fee handling for Trident Concentrated Liquidity Pools.
library SwapLib {
    function handleFees(
        uint256 output,
        uint24 swapFee,
        uint256 barFee,
        uint256 currentLiquidity,
        uint256 totalFeeAmount,
        uint256 amountOut,
        uint256 protocolFee,
        uint256 feeGrowthGlobal
    )
        internal
        pure
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 feeAmount = FullMath.mulDivRoundingUp(output, swapFee, 1e6);

        totalFeeAmount += feeAmount;

        amountOut += output - feeAmount;

        // Calculate `protocolFee` and convert pips to bips.
        uint256 feeDelta = FullMath.mulDivRoundingUp(feeAmount, barFee, 1e4);

        protocolFee += feeDelta;

        // Updating `feeAmount` based on the protocolFee.
        feeAmount -= feeDelta;

        feeGrowthGlobal += FullMath.mulDiv(feeAmount, 0x100000000000000000000000000000000, currentLiquidity);

        return (totalFeeAmount, amountOut, protocolFee, feeGrowthGlobal);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "./ConcentratedLiquidityPool.sol";
import "../../abstract/PoolDeployer.sol";
import "../../interfaces/IConcentratedLiquidityPool.sol";

/// @notice Contract for deploying Trident exchange Concentrated Liquidity Pool with configurations.
/// @author Mudit Gupta.
contract ConcentratedLiquidityPoolFactory is PoolDeployer {
    constructor(address _masterDeployer) PoolDeployer(_masterDeployer) {}

    error WrongTokenOrder();

    function deployPool(bytes memory _deployData) external returns (address pool) {
        (address tokenA, address tokenB, uint24 swapFee, uint160 price, uint24 tickSpacing) = abi.decode(
            _deployData,
            (address, address, uint24, uint160, uint24)
        );

        // Revert instead of switching tokens and inverting price.
        if (tokenA > tokenB) revert WrongTokenOrder();

        // Strips any extra data.
        // Don't include price in _deployData to enable predictable address calculation.
        _deployData = abi.encode(tokenA, tokenB, swapFee, tickSpacing);

        address[] memory tokens = new address[](2);
        tokens[0] = tokenA;
        tokens[1] = tokenB;

        // Salt is not actually needed since `_deployData` is part of creationCode and already contains the salt.
        bytes32 salt = keccak256(_deployData);
        pool = address(new ConcentratedLiquidityPool{salt: salt}(_deployData, IMasterDeployer(masterDeployer)));
        _registerPool(pool, tokens, salt);

        IConcentratedLiquidityPool(pool).setPrice(price);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later-only

pragma solidity >=0.8.0;

/// @dev Custom Errors
error UnauthorisedDeployer();
error ZeroAddress();
error InvalidTokenOrder();

/// @notice Trident pool deployer for whitelisted template factories.
/// @author Mudit Gupta.
abstract contract PoolDeployer {
    address public immutable masterDeployer;

    mapping(address => mapping(address => address[])) public pools;
    mapping(bytes32 => address) public configAddress;

    modifier onlyMaster() {
        if (msg.sender != masterDeployer) revert UnauthorisedDeployer();
        _;
    }

    constructor(address _masterDeployer) {
        if (_masterDeployer == address(0)) revert ZeroAddress();
        masterDeployer = _masterDeployer;
    }

    function _registerPool(
        address pool,
        address[] memory tokens,
        bytes32 salt
    ) internal onlyMaster {
        // Store the address of the deployed contract.
        configAddress[salt] = pool;
        // Attacker used underflow, it was not very effective. poolimon!
        // null token array would cause deployment to fail via out of bounds memory axis/gas limit.
        unchecked {
            for (uint256 i; i < tokens.length - 1; ++i) {
                if (tokens[i] >= tokens[i + 1]) revert InvalidTokenOrder();
                for (uint256 j = i + 1; j < tokens.length; ++j) {
                    pools[tokens[i]][tokens[j]].push(pool);
                    pools[tokens[j]][tokens[i]].push(pool);
                }
            }
        }
    }

    function poolsCount(address token0, address token1) external view returns (uint256 count) {
        count = pools[token0][token1].length;
    }

    function getPools(
        address token0,
        address token1,
        uint256 startIndex,
        uint256 count
    ) external view returns (address[] memory pairPools) {
        pairPools = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            pairPools[i] = pools[token0][token1][startIndex + i];
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "../../libraries/Ticks.sol";
import "../../interfaces/IBentoBoxMinimal.sol";
import "../../interfaces/IConcentratedLiquidityPool.sol";
import { IConcentratedLiquidityPoolManager as IPoolManager } from "../../interfaces/IConcentratedLiquidityPoolManager.sol";

/// @notice Trident Concentrated Liquidity Pool periphery contract that combines non-fungible position management and staking.
contract ConcentratedLiquidityPoolStaker {
    event AddIncentive(IConcentratedLiquidityPool indexed pool, uint256 indexed incentiveId, address indexed rewardToken);
    event Subscribe(uint256 indexed positionId, uint256 indexed incentiveId);
    event ClaimReward(uint256 indexed positionId, uint256 indexed incentiveId, address indexed recipient, uint96 amount);
    event ReclaimIncentive(IConcentratedLiquidityPool indexed pool, uint256 indexed incentiveId, uint256 amount);

    struct Incentive {
        address owner;
        address token;
        uint32 startTime;
        uint32 endTime;
        uint32 expiry;
        uint160 secondsClaimed; // x128.
        uint96 rewardsUnclaimed;
    }

    struct Stake {
        uint160 secondsGrowthInsideLast; // x128.
        uint32 timestamp;
    }

    IBentoBoxMinimal public immutable bento;
    IPoolManager public poolManager;

    mapping(IConcentratedLiquidityPool => uint256) public incentiveCount;
    mapping(IConcentratedLiquidityPool => mapping(uint256 => Incentive)) public incentives;
    /// @dev When subscribing to an incentive we take a snapshot of the position secondsGrowth accumulator.
    /// @dev positionId to incentiveId to position's secondsGrowth snapshot mapping.
    mapping(uint256 => mapping(uint256 => Stake)) public stakes;

    constructor(IPoolManager _poolManager) {
        poolManager = _poolManager;
        IBentoBoxMinimal _bento = IBentoBoxMinimal(_poolManager.bento());
        _bento.registerProtocol();
        bento = _bento;
    }

    function addIncentive(IConcentratedLiquidityPool pool, Incentive memory incentive) public {
        uint32 current = uint32(block.timestamp);
        require(current <= incentive.startTime, "ALREADY_STARTED");
        require(incentive.startTime < incentive.endTime, "START_PAST_END");
        require(incentive.endTime + 90 days < incentive.expiry, "END_PAST_BUFFER");
        require(incentive.rewardsUnclaimed != 0, "NO_REWARDS");
        incentive.secondsClaimed = 0;
        incentives[pool][incentiveCount[pool]++] = incentive;
        _transfer(incentive.token, msg.sender, address(this), incentive.rewardsUnclaimed, false);
        emit AddIncentive(pool, incentiveCount[pool], incentive.token);
    }

    /// @dev Withdraws any unclaimed incentive rewards.
    function reclaimIncentive(
        IConcentratedLiquidityPool pool,
        uint256 incentiveId,
        address receiver,
        uint96 amount,
        bool unwrapBento
    ) public {
        Incentive storage incentive = incentives[pool][incentiveId];
        require(incentive.owner == msg.sender, "NOT_OWNER");
        require(incentive.expiry < block.timestamp, "EXPIRED");
        require(incentive.rewardsUnclaimed >= amount, "ALREADY_CLAIMED");
        incentive.rewardsUnclaimed -= uint96(amount);
        _transfer(incentive.token, address(this), receiver, amount, unwrapBento);
        emit ReclaimIncentive(pool, incentiveId, amount);
    }

    /// @dev Subscribes a non-fungible position token to an incentive.
    function subscribe(uint256 positionId, uint256[] calldata incentiveId) external {
        require(poolManager.ownerOf(positionId) == msg.sender, "NOT_OWNER");
        IPoolManager.Position memory position = poolManager.positions(positionId);
        IConcentratedLiquidityPool pool = position.pool;
        require(position.liquidity != 0, "INACTIVE");
        Stake memory stakeData = Stake(uint160(rangeSecondsInside(pool, position.lower, position.upper)), uint32(block.timestamp));
        for (uint256 i; i < incentiveId.length; i++) {
            Incentive memory incentive = incentives[pool][incentiveId[i]];
            Stake storage stake = stakes[positionId][incentiveId[i]];
            require(stake.secondsGrowthInsideLast == 0, "SUBSCRIBED");
            require(block.timestamp >= incentive.startTime && block.timestamp < incentive.endTime, "INACTIVE_INCENTIVE");
            stakes[positionId][incentiveId[i]] = stakeData;
            emit Subscribe(positionId, incentiveId[i]);
        }
    }

    function claimRewards(
        uint256 positionId,
        uint256[] memory incentiveIds,
        address recipient,
        bool unwrapBento
    ) public {
        require(poolManager.ownerOf(positionId) == msg.sender, "NOT_OWNER");

        IPoolManager.Position memory position = poolManager.positions(positionId);
        IConcentratedLiquidityPool pool = position.pool;

        uint256 currentSecondsGrowth = rangeSecondsInside(pool, position.lower, position.upper);

        for (uint256 i = 0; i < incentiveIds.length; i++) {
            Incentive storage incentive = incentives[pool][incentiveIds[i]];
            Stake storage stake = stakes[positionId][incentiveIds[i]];

            // After liquidity is increased on an NFT the owner needs to resubscribe to the incentive.
            require(stake.timestamp >= position.latestAddition, "MUST_RESUBSCRIBE");

            uint256 rewards;
            uint256 secondsInside;

            {
                uint256 secondsGrowth = currentSecondsGrowth - stake.secondsGrowthInsideLast;
                uint256 maxTime = block.timestamp < incentive.endTime ? incentive.endTime : block.timestamp;
                uint256 secondsUnclaimed = ((maxTime - incentive.startTime) << 128) - incentive.secondsClaimed;
                secondsInside = secondsGrowth * position.liquidity; // secondsGrowth is multiplied by 2**128
                rewards = (incentive.rewardsUnclaimed * secondsInside) / secondsUnclaimed; // 2**128 cancels out
            }

            stake.secondsGrowthInsideLast = uint160(currentSecondsGrowth);
            incentive.secondsClaimed += uint160(secondsInside);
            incentive.rewardsUnclaimed -= uint96(rewards);

            _transfer(incentive.token, address(this), recipient, rewards, unwrapBento);

            emit ClaimReward(positionId, incentiveIds[i], recipient, uint96(rewards));
        }
    }

    function getReward(uint256 positionId, uint256 incentiveId) public view returns (uint256 rewards, uint256 secondsInside) {
        IPoolManager.Position memory position = poolManager.positions(positionId);
        IConcentratedLiquidityPool pool = position.pool;
        Incentive memory incentive = incentives[pool][positionId];
        Stake memory stake = stakes[positionId][incentiveId];
        if (stake.timestamp > 0) {
            uint256 secondsGrowth = rangeSecondsInside(pool, position.lower, position.upper) - stake.secondsGrowthInsideLast;
            secondsInside = secondsGrowth * position.liquidity;
            uint256 maxTime = block.timestamp < incentive.endTime ? incentive.endTime : block.timestamp;
            uint256 secondsUnclaimed = ((maxTime - incentive.startTime) << 128) - incentive.secondsClaimed;
            rewards = (incentive.rewardsUnclaimed * secondsInside) / secondsUnclaimed;
        }
    }

    /// @dev Calculates the "seconds per liquidity" accumulator for a range.
    function rangeSecondsInside(
        IConcentratedLiquidityPool pool,
        int24 lowerTick,
        int24 upperTick
    ) public view returns (uint256 secondsInside) {
        (, int24 currentTick) = pool.getPriceAndNearestTicks();

        IConcentratedLiquidityPool.Tick memory upper = IConcentratedLiquidityPool(pool).ticks(upperTick);
        IConcentratedLiquidityPool.Tick memory lower = IConcentratedLiquidityPool(pool).ticks(lowerTick);

        (uint256 secondsGrowthGlobal, ) = pool.getSecondsGrowthAndLastObservation();
        uint256 secondsBelow;
        uint256 secondsAbove;

        if (lowerTick <= currentTick) {
            secondsBelow = lower.secondsGrowthOutside;
        } else {
            secondsBelow = secondsGrowthGlobal - lower.secondsGrowthOutside;
        }

        if (currentTick < upperTick) {
            secondsAbove = upper.secondsGrowthOutside;
        } else {
            secondsAbove = secondsGrowthGlobal - upper.secondsGrowthOutside;
        }

        secondsInside = secondsGrowthGlobal - secondsBelow - secondsAbove;
    }

    function _transfer(
        address token,
        address from,
        address to,
        uint256 shares,
        bool unwrapBento
    ) internal {
        if (unwrapBento) {
            bento.withdraw(token, from, to, 0, shares);
        } else {
            bento.transfer(token, from, to, shares);
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "../../interfaces/IBentoBoxMinimal.sol";
import "../../interfaces/IMasterDeployer.sol";
import "../../interfaces/IPool.sol";
import "../../interfaces/ITridentCallee.sol";
import "@rari-capital/solmate/src/tokens/ERC20.sol";
import "@rari-capital/solmate/src/utils/ReentrancyGuard.sol";

/// @notice Trident exchange pool template with constant mean formula for swapping among an array of ERC-20 tokens.
/// @dev The reserves are stored as bento shares.
///      The curve is applied to shares as well. This pool does not care about the underlying amounts.
contract IndexPool is IPool, ERC20, ReentrancyGuard {
    event Mint(address indexed sender, address tokenIn, uint256 amountIn, address indexed recipient);
    event Burn(address indexed sender, address tokenOut, uint256 amountOut, address indexed recipient);

    uint256 public immutable swapFee;

    address public immutable barFeeTo;
    IBentoBoxMinimal public immutable bento;
    IMasterDeployer public immutable masterDeployer;

    uint256 internal constant BASE = 10**18;
    uint256 internal constant MIN_TOKENS = 2;
    uint256 internal constant MAX_TOKENS = 8;
    uint256 internal constant MIN_FEE = BASE / 10**6;
    uint256 internal constant MAX_FEE = BASE / 10;
    uint256 internal constant MIN_WEIGHT = BASE;
    uint256 internal constant MAX_WEIGHT = BASE * 50;
    uint256 internal constant MAX_TOTAL_WEIGHT = BASE * 50;
    uint256 internal constant MIN_BALANCE = BASE / 10**12;
    uint256 internal constant INIT_POOL_SUPPLY = BASE * 100;
    uint256 internal constant MIN_POW_BASE = 1;
    uint256 internal constant MAX_POW_BASE = (2 * BASE) - 1;
    uint256 internal constant POW_PRECISION = BASE / 10**10;
    uint256 internal constant MAX_IN_RATIO = BASE / 2;
    uint256 internal constant MAX_OUT_RATIO = (BASE / 3) + 1;

    uint136 internal totalWeight;
    address[] internal tokens;

    uint256 public barFee;

    bytes32 public constant override poolIdentifier = "Trident:Index";

    mapping(address => Record) public records;
    struct Record {
        uint120 reserve;
        uint136 weight;
    }

    constructor(bytes memory _deployData, address _masterDeployer) ERC20("Sushi LP Token", "SLP", 18) {
        (address[] memory _tokens, uint136[] memory _weights, uint256 _swapFee) = abi.decode(_deployData, (address[], uint136[], uint256));
        // @dev Factory ensures that the tokens are sorted.
        require(_tokens.length == _weights.length, "INVALID_ARRAYS");
        require(MIN_FEE <= _swapFee && _swapFee <= MAX_FEE, "INVALID_SWAP_FEE");
        require(MIN_TOKENS <= _tokens.length && _tokens.length <= MAX_TOKENS, "INVALID_TOKENS_LENGTH");

        for (uint256 i = 0; i < _tokens.length; i++) {
            require(_tokens[i] != address(0), "ZERO_ADDRESS");
            require(MIN_WEIGHT <= _weights[i] && _weights[i] <= MAX_WEIGHT, "INVALID_WEIGHT");
            records[_tokens[i]] = Record({reserve: 0, weight: _weights[i]});
            tokens.push(_tokens[i]);
            totalWeight += _weights[i];
        }

        require(totalWeight <= MAX_TOTAL_WEIGHT, "MAX_TOTAL_WEIGHT");
        // @dev This burns initial LP supply.
        _mint(address(0), INIT_POOL_SUPPLY);

        swapFee = _swapFee;
        barFee = IMasterDeployer(_masterDeployer).barFee();
        barFeeTo = IMasterDeployer(_masterDeployer).barFeeTo();
        bento = IBentoBoxMinimal(IMasterDeployer(_masterDeployer).bento());
        masterDeployer = IMasterDeployer(_masterDeployer);
    }

    /// @dev Mints LP tokens - should be called via the router after transferring `bento` tokens.
    /// The router must ensure that sufficient LP tokens are minted by using the return value.
    function mint(bytes calldata data) public override nonReentrant returns (uint256 liquidity) {
        (address recipient, uint256 toMint) = abi.decode(data, (address, uint256));

        uint120 ratio = uint120(_div(toMint, totalSupply));

        for (uint256 i = 0; i < tokens.length; i++) {
            address tokenIn = tokens[i];
            uint120 reserve = records[tokenIn].reserve;
            // @dev If token balance is '0', initialize with `ratio`.
            uint120 amountIn = reserve != 0 ? uint120(_mul(ratio, reserve)) : ratio;
            require(amountIn >= MIN_BALANCE, "MIN_BALANCE");
            // @dev Check Trident router has sent `amountIn` for skim into pool.
            unchecked {
                // @dev This is safe from overflow - only logged amounts handled.
                require(_balance(tokenIn) >= amountIn + reserve, "NOT_RECEIVED");
                records[tokenIn].reserve += amountIn;
            }
            emit Mint(msg.sender, tokenIn, amountIn, recipient);
        }
        _mint(recipient, toMint);
        liquidity = toMint;
    }

    /// @dev Burns LP tokens sent to this contract. The router must ensure that the user gets sufficient output tokens.
    function burn(bytes calldata data) public override nonReentrant returns (IPool.TokenAmount[] memory withdrawnAmounts) {
        (address recipient, bool unwrapBento, uint256 toBurn) = abi.decode(data, (address, bool, uint256));

        uint256 ratio = _div(toBurn, totalSupply);

        withdrawnAmounts = new TokenAmount[](tokens.length);

        _burn(address(this), toBurn);

        for (uint256 i = 0; i < tokens.length; i++) {
            address tokenOut = tokens[i];
            uint256 balance = records[tokenOut].reserve;
            uint120 amountOut = uint120(_mul(ratio, balance));
            require(amountOut != 0, "ZERO_OUT");
            // @dev This is safe from underflow - only logged amounts handled.
            unchecked {
                records[tokenOut].reserve -= amountOut;
            }
            _transfer(tokenOut, amountOut, recipient, unwrapBento);
            withdrawnAmounts[i] = TokenAmount({token: tokenOut, amount: amountOut});
            emit Burn(msg.sender, tokenOut, amountOut, recipient);
        }
    }

    /// @dev Burns LP tokens sent to this contract and swaps one of the output tokens for another
    /// - i.e., the user gets a single token out by burning LP tokens.
    function burnSingle(bytes calldata data) public override nonReentrant returns (uint256 amountOut) {
        (address tokenOut, address recipient, bool unwrapBento, uint256 toBurn) = abi.decode(data, (address, address, bool, uint256));

        Record storage outRecord = records[tokenOut];

        amountOut = _computeSingleOutGivenPoolIn(outRecord.reserve, outRecord.weight, totalSupply, totalWeight, toBurn, swapFee);

        require(amountOut <= _mul(outRecord.reserve, MAX_OUT_RATIO), "MAX_OUT_RATIO");
        // @dev This is safe from underflow - only logged amounts handled.
        unchecked {
            outRecord.reserve -= uint120(amountOut);
        }
        _burn(address(this), toBurn);
        _transfer(tokenOut, amountOut, recipient, unwrapBento);
        emit Burn(msg.sender, tokenOut, amountOut, recipient);
    }

    /// @dev Swaps one token for another. The router must prefund this contract and ensure there isn't too much slippage.
    function swap(bytes calldata data) public override nonReentrant returns (uint256 amountOut) {
        (address tokenIn, address tokenOut, address recipient, bool unwrapBento, uint256 amountIn) = abi.decode(
            data,
            (address, address, address, bool, uint256)
        );

        Record storage inRecord = records[tokenIn];
        Record storage outRecord = records[tokenOut];

        require(amountIn <= _mul(inRecord.reserve, MAX_IN_RATIO), "MAX_IN_RATIO");

        amountOut = _getAmountOut(amountIn, inRecord.reserve, inRecord.weight, outRecord.reserve, outRecord.weight);
        // @dev Check Trident router has sent `amountIn` for skim into pool.
        unchecked {
            // @dev This is safe from under/overflow - only logged amounts handled.
            require(_balance(tokenIn) >= amountIn + inRecord.reserve, "NOT_RECEIVED");
            inRecord.reserve += uint120(amountIn);
            outRecord.reserve -= uint120(amountOut);
        }
        _transfer(tokenOut, amountOut, recipient, unwrapBento);
        emit Swap(recipient, tokenIn, tokenOut, amountIn, amountOut);
    }

    /// @dev Swaps one token for another. The router must support swap callbacks and ensure there isn't too much slippage.
    function flashSwap(bytes calldata data) public override nonReentrant returns (uint256 amountOut) {
        (address tokenIn, address tokenOut, address recipient, bool unwrapBento, uint256 amountIn, bytes memory context) = abi.decode(
            data,
            (address, address, address, bool, uint256, bytes)
        );

        Record storage inRecord = records[tokenIn];
        Record storage outRecord = records[tokenOut];

        require(amountIn <= _mul(inRecord.reserve, MAX_IN_RATIO), "MAX_IN_RATIO");

        amountOut = _getAmountOut(amountIn, inRecord.reserve, inRecord.weight, outRecord.reserve, outRecord.weight);

        ITridentCallee(msg.sender).tridentSwapCallback(context);
        // @dev Check Trident router has sent `amountIn` for skim into pool.
        unchecked {
            // @dev This is safe from under/overflow - only logged amounts handled.
            require(_balance(tokenIn) >= amountIn + inRecord.reserve, "NOT_RECEIVED");
            inRecord.reserve += uint120(amountIn);
            outRecord.reserve -= uint120(amountOut);
        }
        _transfer(tokenOut, amountOut, recipient, unwrapBento);
        emit Swap(recipient, tokenIn, tokenOut, amountIn, amountOut);
    }

    /// @dev Updates `barFee` for Trident protocol.
    function updateBarFee() public {
        barFee = IMasterDeployer(masterDeployer).barFee();
    }

    function _balance(address token) internal view returns (uint256 balance) {
        balance = bento.balanceOf(token, address(this));
    }

    function _getAmountOut(
        uint256 tokenInAmount,
        uint256 tokenInBalance,
        uint256 tokenInWeight,
        uint256 tokenOutBalance,
        uint256 tokenOutWeight
    ) internal view returns (uint256 amountOut) {
        uint256 weightRatio = _div(tokenInWeight, tokenOutWeight);
        // @dev This is safe from under/overflow - only logged amounts handled.
        unchecked {
            uint256 adjustedIn = _mul(tokenInAmount, (BASE - swapFee));
            uint256 a = _div(tokenInBalance, tokenInBalance + adjustedIn);
            uint256 b = _compute(a, weightRatio);
            uint256 c = BASE - b;
            amountOut = _mul(tokenOutBalance, c);
        }
    }

    function _compute(uint256 base, uint256 exp) internal pure returns (uint256 output) {
        require(MIN_POW_BASE <= base && base <= MAX_POW_BASE, "INVALID_BASE");

        uint256 whole = (exp / BASE) * BASE;
        uint256 remain = exp - whole;
        uint256 wholePow = _pow(base, whole / BASE);

        if (remain == 0) output = wholePow;

        uint256 partialResult = _powApprox(base, remain, POW_PRECISION);
        output = _mul(wholePow, partialResult);
    }

    function _computeSingleOutGivenPoolIn(
        uint256 tokenOutBalance,
        uint256 tokenOutWeight,
        uint256 _totalSupply,
        uint256 _totalWeight,
        uint256 toBurn,
        uint256 _swapFee
    ) internal pure returns (uint256 amountOut) {
        uint256 normalizedWeight = _div(tokenOutWeight, _totalWeight);
        uint256 newPoolSupply = _totalSupply - toBurn;
        uint256 poolRatio = _div(newPoolSupply, _totalSupply);
        uint256 tokenOutRatio = _pow(poolRatio, _div(BASE, normalizedWeight));
        uint256 newBalanceOut = _mul(tokenOutRatio, tokenOutBalance);
        uint256 tokenAmountOutBeforeSwapFee = tokenOutBalance - newBalanceOut;
        uint256 zaz = (BASE - normalizedWeight) * _swapFee;
        amountOut = _mul(tokenAmountOutBeforeSwapFee, (BASE - zaz));
    }

    function _pow(uint256 a, uint256 n) internal pure returns (uint256 output) {
        output = n % 2 != 0 ? a : BASE;
        for (n /= 2; n != 0; n /= 2) a = a * a;
        if (n % 2 != 0) output = output * a;
    }

    function _powApprox(
        uint256 base,
        uint256 exp,
        uint256 precision
    ) internal pure returns (uint256 sum) {
        uint256 a = exp;
        (uint256 x, bool xneg) = _subFlag(base, BASE);
        uint256 term = BASE;
        sum = term;
        bool negative;

        for (uint256 i = 1; term >= precision; i++) {
            uint256 bigK = i * BASE;
            (uint256 c, bool cneg) = _subFlag(a, (bigK - BASE));
            term = _mul(term, _mul(c, x));
            term = _div(term, bigK);
            if (term == 0) break;
            if (xneg) negative = !negative;
            if (cneg) negative = !negative;
            if (negative) {
                sum = sum - term;
            } else {
                sum = sum + term;
            }
        }
    }

    function _subFlag(uint256 a, uint256 b) internal pure returns (uint256 difference, bool flag) {
        // @dev This is safe from underflow - if/else flow performs checks.
        unchecked {
            if (a >= b) {
                (difference, flag) = (a - b, false);
            } else {
                (difference, flag) = (b - a, true);
            }
        }
    }

    function _mul(uint256 a, uint256 b) internal pure returns (uint256 c2) {
        uint256 c0 = a * b;
        uint256 c1 = c0 + (BASE / 2);
        c2 = c1 / BASE;
    }

    function _div(uint256 a, uint256 b) internal pure returns (uint256 c2) {
        uint256 c0 = a * BASE;
        uint256 c1 = c0 + (b / 2);
        c2 = c1 / b;
    }

    function _transfer(
        address token,
        uint256 shares,
        address to,
        bool unwrapBento
    ) internal {
        if (unwrapBento) {
            bento.withdraw(token, address(this), to, 0, shares);
        } else {
            bento.transfer(token, address(this), to, shares);
        }
    }

    function getAssets() public view override returns (address[] memory assets) {
        assets = tokens;
    }

    function getAmountOut(bytes calldata data) public view override returns (uint256 amountOut) {
        (uint256 tokenInAmount, uint256 tokenInBalance, uint256 tokenInWeight, uint256 tokenOutBalance, uint256 tokenOutWeight) = abi
            .decode(data, (uint256, uint256, uint256, uint256, uint256));
        amountOut = _getAmountOut(tokenInAmount, tokenInBalance, tokenInWeight, tokenOutBalance, tokenOutWeight);
    }

    function getAmountIn(bytes calldata) public pure override returns (uint256) {
        revert();
    }

    function getReservesAndWeights() public view returns (uint256[] memory reserves, uint136[] memory weights) {
        uint256 length = tokens.length;
        reserves = new uint256[](length);
        weights = new uint136[](length);
        // @dev This is safe from overflow - `tokens` `length` is bound to '8'.
        unchecked {
            for (uint256 i = 0; i < length; i++) {
                reserves[i] = records[tokens[i]].reserve;
                weights[i] = records[tokens[i]].weight;
            }
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

/// @notice Trident pool interface.
interface IPool {
    /// @notice Executes a swap from one token to another.
    /// @dev The input tokens must've already been sent to the pool.
    /// @param data ABI-encoded params that the pool requires.
    /// @return finalAmountOut The amount of output tokens that were sent to the user.
    function swap(bytes calldata data) external returns (uint256 finalAmountOut);

    /// @notice Executes a swap from one token to another with a callback.
    /// @dev This function allows borrowing the output tokens and sending the input tokens in the callback.
    /// @param data ABI-encoded params that the pool requires.
    /// @return finalAmountOut The amount of output tokens that were sent to the user.
    function flashSwap(bytes calldata data) external returns (uint256 finalAmountOut);

    /// @notice Mints liquidity tokens.
    /// @param data ABI-encoded params that the pool requires.
    /// @return liquidity The amount of liquidity tokens that were minted for the user.
    function mint(bytes calldata data) external returns (uint256 liquidity);

    /// @notice Burns liquidity tokens.
    /// @dev The input LP tokens must've already been sent to the pool.
    /// @param data ABI-encoded params that the pool requires.
    /// @return withdrawnAmounts The amount of various output tokens that were sent to the user.
    function burn(bytes calldata data) external returns (TokenAmount[] memory withdrawnAmounts);

    /// @notice Burns liquidity tokens for a single output token.
    /// @dev The input LP tokens must've already been sent to the pool.
    /// @param data ABI-encoded params that the pool requires.
    /// @return amountOut The amount of output tokens that were sent to the user.
    function burnSingle(bytes calldata data) external returns (uint256 amountOut);

    /// @return A unique identifier for the pool type.
    function poolIdentifier() external pure returns (bytes32);

    /// @return An array of tokens supported by the pool.
    function getAssets() external view returns (address[] memory);

    /// @notice Simulates a trade and returns the expected output.
    /// @dev The pool does not need to include a trade simulator directly in itself - it can use a library.
    /// @param data ABI-encoded params that the pool requires.
    /// @return finalAmountOut The amount of output tokens that will be sent to the user if the trade is executed.
    function getAmountOut(bytes calldata data) external view returns (uint256 finalAmountOut);

    /// @notice Simulates a trade and returns the expected output.
    /// @dev The pool does not need to include a trade simulator directly in itself - it can use a library.
    /// @param data ABI-encoded params that the pool requires.
    /// @return finalAmountIn The amount of input tokens that are required from the user if the trade is executed.
    function getAmountIn(bytes calldata data) external view returns (uint256 finalAmountIn);

    /// @dev This event must be emitted on all swaps.
    event Swap(address indexed recipient, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    /// @dev This struct frames output tokens for burns.
    struct TokenAmount {
        address token;
        uint256 amount;
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*///////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*///////////////////////////////////////////////////////////////
                             EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*///////////////////////////////////////////////////////////////
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

    /*///////////////////////////////////////////////////////////////
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

    /*///////////////////////////////////////////////////////////////
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
            bytes32 digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
                )
            );

            address recoveredAddress = ecrecover(digest, v, r, s);

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

    /*///////////////////////////////////////////////////////////////
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

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/ReentrancyGuard.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private reentrancyStatus = 1;

    modifier nonReentrant() {
        require(reentrancyStatus == 1, "REENTRANCY");

        reentrancyStatus = 2;

        _;

        reentrancyStatus = 1;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "./IndexPool.sol";
import "../../abstract/PoolDeployer.sol";

/// @notice Contract for deploying Trident exchange Index Pool with configurations.
/// @author Mudit Gupta
contract IndexPoolFactory is PoolDeployer {
    constructor(address _masterDeployer) PoolDeployer(_masterDeployer) {}

    function deployPool(bytes memory _deployData) external returns (address pool) {
        (address[] memory tokens, uint136[] memory weights, uint256 swapFee) = abi.decode(_deployData, (address[], uint136[], uint256));

        // @dev Strips any extra data.
        _deployData = abi.encode(tokens, weights, swapFee);

        // @dev Salt is not actually needed since `_deployData` is part of creationCode and already contains the salt.
        bytes32 salt = keccak256(_deployData);
        pool = address(new IndexPool{salt: salt}(_deployData, masterDeployer));
        _registerPool(pool, tokens, salt);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "./HybridPool.sol";
import "../../abstract/PoolDeployer.sol";

/// @notice Contract for deploying Trident exchange Hybrid Pool with configurations.
/// @author Mudit Gupta.
contract HybridPoolFactory is PoolDeployer {
    constructor(address _masterDeployer) PoolDeployer(_masterDeployer) {}

    function deployPool(bytes memory _deployData) external returns (address pool) {
        (address tokenA, address tokenB, uint256 swapFee, uint256 a) = abi.decode(_deployData, (address, address, uint256, uint256));

        if (tokenA > tokenB) {
            (tokenA, tokenB) = (tokenB, tokenA);
        }

        // @dev Strips any extra data.
        _deployData = abi.encode(tokenA, tokenB, swapFee, a);
        address[] memory tokens = new address[](2);
        tokens[0] = tokenA;
        tokens[1] = tokenB;

        // @dev Salt is not actually needed since `_deployData` is part of creationCode and already contains the salt.
        bytes32 salt = keccak256(_deployData);
        pool = address(new HybridPool{salt: salt}(_deployData, masterDeployer));
        _registerPool(pool, tokens, salt);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "@rari-capital/solmate/src/tokens/ERC20.sol";
import "@rari-capital/solmate/src/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/IBentoBoxMinimal.sol";
import "../../interfaces/IMasterDeployer.sol";
import "../../interfaces/IPool.sol";
import "../../interfaces/ITridentCallee.sol";
import "../../libraries/MathUtils.sol";
import "../../libraries/RebaseLibrary.sol";


/// @notice Trident exchange pool template with hybrid like-kind formula for swapping between an ERC-20 token pair.
/// @dev The reserves are stored as bento shares. However, the stableswap invariant is applied to the underlying amounts.
///      The API uses the underlying amounts.
contract HybridPool is IPool, ERC20, ReentrancyGuard {
    using MathUtils for uint256;
    using RebaseLibrary for Rebase;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1, address indexed recipient, uint256 liquidity);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed recipient, uint256 liquidity);
    event Sync(uint256 reserve0, uint256 reserve1);

    uint256 internal constant MINIMUM_LIQUIDITY = 10**3;
    uint8 internal constant PRECISION = 112;

    /// @dev Constant value used as max loop limit.
    uint256 private constant MAX_LOOP_LIMIT = 256;
    uint256 internal constant MAX_FEE = 10000; // @dev 100%.
    uint256 public immutable swapFee;

    IBentoBoxMinimal public immutable bento;
    IMasterDeployer public immutable masterDeployer;
    address public immutable barFeeTo;
    address public immutable token0;
    address public immutable token1;
    uint256 public immutable A;
    uint256 internal immutable N_A; // @dev 2 * A.
    uint256 internal constant A_PRECISION = 100;

    /// @dev Multipliers for each pooled token's precision to get to POOL_PRECISION_DECIMALS.
    /// For example, TBTC has 18 decimals, so the multiplier should be 1. WBTC
    /// has 8, so the multiplier should be 10 ** 18 / 10 ** 8 => 10 ** 10.
    uint256 public immutable token0PrecisionMultiplier;
    uint256 public immutable token1PrecisionMultiplier;

    uint256 public barFee;

    uint128 internal reserve0;
    uint128 internal reserve1;
    uint256 internal dLast;

    bytes32 public constant override poolIdentifier = "Trident:HybridPool";

    constructor(bytes memory _deployData, address _masterDeployer) ERC20("Sushi LP Token", "SLP", 18) {
        (address _token0, address _token1, uint256 _swapFee, uint256 a) = abi.decode(_deployData, (address, address, uint256, uint256));

        // @dev Factory ensures that the tokens are sorted.
        require(_token0 != address(0), "ZERO_ADDRESS");
        require(_token0 != _token1, "IDENTICAL_ADDRESSES");
        require(_swapFee <= MAX_FEE, "INVALID_SWAP_FEE");
        require(a != 0, "ZERO_A");

        token0 = _token0;
        token1 = _token1;
        swapFee = _swapFee;
        barFee = IMasterDeployer(_masterDeployer).barFee();
        barFeeTo = IMasterDeployer(_masterDeployer).barFeeTo();
        bento = IBentoBoxMinimal(IMasterDeployer(_masterDeployer).bento());
        masterDeployer = IMasterDeployer(_masterDeployer);
        A = a;
        N_A = 2 * a;
        token0PrecisionMultiplier = uint256(10)**(18 - ERC20(_token0).decimals());
        token1PrecisionMultiplier = uint256(10)**(18 - ERC20(_token1).decimals());
    }

    /// @dev Mints LP tokens - should be called via the router after transferring `bento` tokens.
    /// The router must ensure that sufficient LP tokens are minted by using the return value.
    function mint(bytes calldata data) public override nonReentrant returns (uint256 liquidity) {
        address recipient = abi.decode(data, (address));
        (uint256 _reserve0, uint256 _reserve1) = _getReserves();
        (uint256 balance0, uint256 balance1) = _balance();

        uint256 newLiq = _computeLiquidity(balance0, balance1);
        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;
        (uint256 fee0, uint256 fee1) = _nonOptimalMintFee(amount0, amount1, _reserve0, _reserve1);
        _reserve0 += uint112(fee0);
        _reserve1 += uint112(fee1);

        (uint256 _totalSupply, uint256 oldLiq) = _mintFee(_reserve0, _reserve1);

        if (_totalSupply == 0) {
            require(amount0 > 0 && amount1 > 0, "INVALID_AMOUNTS");
            liquidity = newLiq - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY);
        } else {
            liquidity = ((newLiq - oldLiq) * _totalSupply) / oldLiq;
        }
        require(liquidity != 0, "INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(recipient, liquidity);
        _updateReserves();

        dLast = newLiq;
        uint256 liquidityForEvent = liquidity;
        emit Mint(msg.sender, amount0, amount1, recipient, liquidityForEvent);
    }

    /// @dev Burns LP tokens sent to this contract. The router must ensure that the user gets sufficient output tokens.
    function burn(bytes calldata data) public override nonReentrant returns (IPool.TokenAmount[] memory withdrawnAmounts) {
        (address recipient, bool unwrapBento) = abi.decode(data, (address, bool));
        (uint256 balance0, uint256 balance1) = _balance();
        uint256 liquidity = balanceOf[address(this)];

        (uint256 _totalSupply, ) = _mintFee(balance0, balance1);

        uint256 amount0 = (liquidity * balance0) / _totalSupply;
        uint256 amount1 = (liquidity * balance1) / _totalSupply;

        _burn(address(this), liquidity);
        _transfer(token0, amount0, recipient, unwrapBento);
        _transfer(token1, amount1, recipient, unwrapBento);

        _updateReserves();

        withdrawnAmounts = new TokenAmount[](2);
        withdrawnAmounts[0] = TokenAmount({token: token0, amount: amount0});
        withdrawnAmounts[1] = TokenAmount({token: token1, amount: amount1});

        dLast = _computeLiquidity(balance0 - amount0, balance1 - amount1);

        emit Burn(msg.sender, amount0, amount1, recipient, liquidity);
    }

    /// @dev Burns LP tokens sent to this contract and swaps one of the output tokens for another
    /// - i.e., the user gets a single token out by burning LP tokens.
    function burnSingle(bytes calldata data) public override nonReentrant returns (uint256 amountOut) {
        (address tokenOut, address recipient, bool unwrapBento) = abi.decode(data, (address, address, bool));
        (uint256 balance0, uint256 balance1) = _balance();
        uint256 liquidity = balanceOf[address(this)];

        (uint256 _totalSupply, ) = _mintFee(balance0, balance1);

        uint256 amount0 = (liquidity * balance0) / _totalSupply;
        uint256 amount1 = (liquidity * balance1) / _totalSupply;

        _burn(address(this), liquidity);
        dLast = _computeLiquidity(balance0 - amount0, balance1 - amount1);

        // Swap tokens
        if (tokenOut == token1) {
            // @dev Swap `token0` for `token1`.
            // @dev Calculate `amountOut` as if the user first withdrew balanced liquidity and then swapped `token0` for `token1`.
            amount1 += _getAmountOut(amount0, balance0 - amount0, balance1 - amount1, true);
            _transfer(token1, amount1, recipient, unwrapBento);
            amountOut = amount1;
            amount0 = 0;
        } else {
            // @dev Swap `token1` for `token0`.
            require(tokenOut == token0, "INVALID_OUTPUT_TOKEN");
            amount0 += _getAmountOut(amount1, balance0 - amount0, balance1 - amount1, false);
            _transfer(token0, amount0, recipient, unwrapBento);
            amountOut = amount0;
            amount1 = 0;
        }
        _updateReserves();
        emit Burn(msg.sender, amount0, amount1, recipient, liquidity);
    }

    /// @dev Swaps one token for another. The router must prefund this contract and ensure there isn't too much slippage.
    function swap(bytes calldata data) public override nonReentrant returns (uint256 amountOut) {
        (address tokenIn, address recipient, bool unwrapBento) = abi.decode(data, (address, address, bool));
        (uint256 _reserve0, uint256 _reserve1, uint256 balance0, uint256 balance1) = _getReservesAndBalances();
        uint256 amountIn;
        address tokenOut;

        if (tokenIn == token0) {
            tokenOut = token1;
            unchecked {
                amountIn = balance0 - _reserve0;
            }
            amountOut = _getAmountOut(amountIn, _reserve0, _reserve1, true);
        } else {
            require(tokenIn == token1, "INVALID_INPUT_TOKEN");
            tokenOut = token0;
            unchecked {
                amountIn = balance1 - _reserve1;
            }
            amountOut = _getAmountOut(amountIn, _reserve0, _reserve1, false);
        }
        _transfer(tokenOut, amountOut, recipient, unwrapBento);
        _updateReserves();
        emit Swap(recipient, tokenIn, tokenOut, amountIn, amountOut);
    }

    /// @dev Swaps one token for another with payload. The router must support swap callbacks and ensure there isn't too much slippage.
    function flashSwap(bytes calldata data) public override nonReentrant returns (uint256 amountOut) {
        (address tokenIn, address recipient, bool unwrapBento, uint256 amountIn, bytes memory context) = abi.decode(
            data,
            (address, address, bool, uint256, bytes)
        );
        (uint256 _reserve0, uint256 _reserve1) = _getReserves();
        address tokenOut;

        if (tokenIn == token0) {
            tokenOut = token1;
            amountIn = bento.toAmount(token0, amountIn, false);
            amountOut = _getAmountOut(amountIn, _reserve0, _reserve1, true);
            _processSwap(token1, recipient, amountOut, context, unwrapBento);
            uint256 balance0 = bento.toAmount(token0, bento.balanceOf(token0, address(this)), false);
            require(balance0 - _reserve0 >= amountIn, "INSUFFICIENT_AMOUNT_IN");
        } else {
            require(tokenIn == token1, "INVALID_INPUT_TOKEN");
            tokenOut = token0;
            amountIn = bento.toAmount(token1, amountIn, false);
            amountOut = _getAmountOut(amountIn, _reserve0, _reserve1, false);
            _processSwap(token0, recipient, amountOut, context, unwrapBento);
            uint256 balance1 = bento.toAmount(token1, bento.balanceOf(token1, address(this)), false);
            require(balance1 - _reserve1 >= amountIn, "INSUFFICIENT_AMOUNT_IN");
        }
        _updateReserves();
        emit Swap(recipient, tokenIn, tokenOut, amountIn, amountOut);
    }

    /// @dev Updates `barFee` for Trident protocol.
    function updateBarFee() public {
        barFee = masterDeployer.barFee();
    }

    function _processSwap(
        address tokenOut,
        address to,
        uint256 amountOut,
        bytes memory data,
        bool unwrapBento
    ) internal {
        _transfer(tokenOut, amountOut, to, unwrapBento);
        if (data.length != 0) ITridentCallee(msg.sender).tridentSwapCallback(data);
    }

    function _getReserves() internal view returns (uint256 _reserve0, uint256 _reserve1) {
        (_reserve0, _reserve1) = (reserve0, reserve1);
        _reserve0 = bento.toAmount(token0, _reserve0, false);
        _reserve1 = bento.toAmount(token1, _reserve1, false);
    }

    function _getReservesAndBalances()
        internal
        view
        returns (
            uint256 _reserve0,
            uint256 _reserve1,
            uint256 balance0,
            uint256 balance1
        )
    {
        (_reserve0, _reserve1) = (reserve0, reserve1);
        balance0 = bento.balanceOf(token0, address(this));
        balance1 = bento.balanceOf(token1, address(this));
        Rebase memory total0 = bento.totals(token0);
        Rebase memory total1 = bento.totals(token1);

        _reserve0 = total0.toElastic(_reserve0);
        _reserve1 = total1.toElastic(_reserve1);
        balance0 = total0.toElastic(balance0);
        balance1 = total1.toElastic(balance1);
    }

    function _updateReserves() internal {
        (uint256 _reserve0, uint256 _reserve1) = _balance();
        require(_reserve0 <= type(uint128).max && _reserve1 <= type(uint128).max, "OVERFLOW");
        reserve0 = uint128(_reserve0);
        reserve1 = uint128(_reserve1);
        emit Sync(_reserve0, _reserve1);
    }

    function _balance() internal view returns (uint256 balance0, uint256 balance1) {
        balance0 = bento.toAmount(token0, bento.balanceOf(token0, address(this)), false);
        balance1 = bento.toAmount(token1, bento.balanceOf(token1, address(this)), false);
    }

    function _getAmountOut(
        uint256 amountIn,
        uint256 _reserve0,
        uint256 _reserve1,
        bool token0In
    ) internal view returns (uint256 dy) {
        unchecked {
            uint256 adjustedReserve0 = _reserve0 * token0PrecisionMultiplier;
            uint256 adjustedReserve1 = _reserve1 * token1PrecisionMultiplier;
            uint256 feeDeductedAmountIn = amountIn - (amountIn * swapFee) / MAX_FEE;
            uint256 d = _computeLiquidityFromAdjustedBalances(adjustedReserve0, adjustedReserve1);

            if (token0In) {
                uint256 x = adjustedReserve0 + (feeDeductedAmountIn * token0PrecisionMultiplier);
                uint256 y = _getY(x, d);
                dy = adjustedReserve1 - y - 1;
                dy /= token1PrecisionMultiplier;
            } else {
                uint256 x = adjustedReserve1 + (feeDeductedAmountIn * token1PrecisionMultiplier);
                uint256 y = _getY(x, d);
                dy = adjustedReserve0 - y - 1;
                dy /= token0PrecisionMultiplier;
            }
        }
    }

    function _transfer(
        address token,
        uint256 amount,
        address to,
        bool unwrapBento
    ) internal {
        if (unwrapBento) {
            bento.withdraw(token, address(this), to, amount, 0);
        } else {
            bento.transfer(token, address(this), to, bento.toShare(token, amount, false));
        }
    }

    /// @notice Get D, the StableSwap invariant, based on a set of balances and a particular A.
    /// See the StableSwap paper for details.
    /// @dev Originally https://github.com/saddle-finance/saddle-contract/blob/0b76f7fb519e34b878aa1d58cffc8d8dc0572c12/contracts/SwapUtils.sol#L319.
    /// @return liquidity The invariant, at the precision of the pool.
    function _computeLiquidity(uint256 _reserve0, uint256 _reserve1) internal view returns (uint256 liquidity) {
        unchecked {
            uint256 adjustedReserve0 = _reserve0 * token0PrecisionMultiplier;
            uint256 adjustedReserve1 = _reserve1 * token1PrecisionMultiplier;
            liquidity = _computeLiquidityFromAdjustedBalances(adjustedReserve0, adjustedReserve1);
        }
    }

    function _computeLiquidityFromAdjustedBalances(uint256 xp0, uint256 xp1) internal view returns (uint256 computed) {
        uint256 s = xp0 + xp1;

        if (s == 0) {
            computed = 0;
        }
        uint256 prevD;
        uint256 D = s;
        for (uint256 i = 0; i < MAX_LOOP_LIMIT; i++) {
            uint256 dP = (((D * D) / xp0) * D) / xp1 / 4;
            prevD = D;
            D = (((N_A * s) / A_PRECISION + 2 * dP) * D) / ((N_A / A_PRECISION - 1) * D + 3 * dP);
            if (D.within1(prevD)) {
                break;
            }
        }
        computed = D;
    }

    /// @notice Calculate the new balances of the tokens given the indexes of the token
    /// that is swapped from (FROM) and the token that is swapped to (TO).
    /// This function is used as a helper function to calculate how much TO token
    /// the user should receive on swap.
    /// @dev Originally https://github.com/saddle-finance/saddle-contract/blob/0b76f7fb519e34b878aa1d58cffc8d8dc0572c12/contracts/SwapUtils.sol#L432.
    /// @param x The new total amount of FROM token.
    /// @return y The amount of TO token that should remain in the pool.
    function _getY(uint256 x, uint256 D) internal view returns (uint256 y) {
        uint256 c = (D * D) / (x * 2);
        c = (c * D) / ((N_A * 2) / A_PRECISION);
        uint256 b = x + ((D * A_PRECISION) / N_A);
        uint256 yPrev;
        y = D;
        // @dev Iterative approximation.
        for (uint256 i = 0; i < MAX_LOOP_LIMIT; i++) {
            yPrev = y;
            y = (y * y + c) / (y * 2 + b - D);
            if (y.within1(yPrev)) {
                break;
            }
        }
    }

    function _mintFee(uint256 _reserve0, uint256 _reserve1) internal returns (uint256 _totalSupply, uint256 d) {
        _totalSupply = totalSupply;
        uint256 _dLast = dLast;
        if (_dLast != 0) {
            d = _computeLiquidity(_reserve0, _reserve1);
            if (d > _dLast) {
                // @dev `barFee` % of increase in liquidity.
                uint256 _barFee = barFee;
                uint256 numerator = _totalSupply * (d - _dLast) * _barFee;
                uint256 denominator = (MAX_FEE - _barFee) * d + _barFee * _dLast;
                uint256 liquidity = numerator / denominator;

                if (liquidity != 0) {
                    _mint(barFeeTo, liquidity);
                    _totalSupply += liquidity;
                }
            }
        }
    }

    /// @dev This fee is charged to cover for `swapFee` when users add unbalanced liquidity.
    function _nonOptimalMintFee(
        uint256 _amount0,
        uint256 _amount1,
        uint256 _reserve0,
        uint256 _reserve1
    ) internal view returns (uint256 token0Fee, uint256 token1Fee) {
        if (_reserve0 == 0 || _reserve1 == 0) return (0, 0);
        uint256 amount1Optimal = (_amount0 * _reserve1) / _reserve0;

        if (amount1Optimal <= _amount1) {
            token1Fee = (swapFee * (_amount1 - amount1Optimal)) / (2 * MAX_FEE);
        } else {
            uint256 amount0Optimal = (_amount1 * _reserve0) / _reserve1;
            token0Fee = (swapFee * (_amount0 - amount0Optimal)) / (2 * MAX_FEE);
        }
    }

    function getAssets() public view override returns (address[] memory assets) {
        assets = new address[](2);
        assets[0] = token0;
        assets[1] = token1;
    }

    function getAmountOut(bytes calldata data) public view override returns (uint256 finalAmountOut) {
        (address tokenIn, uint256 amountIn) = abi.decode(data, (address, uint256));
        (uint256 _reserve0, uint256 _reserve1) = _getReserves();
        amountIn = bento.toAmount(tokenIn, amountIn, false);

        if (tokenIn == token0) {
            finalAmountOut = bento.toShare(token1, _getAmountOut(amountIn, _reserve0, _reserve1, true), false);
        } else {
            require(tokenIn == token1, "INVALID_INPUT_TOKEN");
            finalAmountOut = bento.toShare(token0, _getAmountOut(amountIn, _reserve0, _reserve1, false), false);
        }
    }

    function getAmountIn(bytes calldata) public pure override returns (uint256) {
        revert();
    }

    function getReserves() public view returns (uint256 _reserve0, uint256 _reserve1) {
        (_reserve0, _reserve1) = _getReserves();
    }

    function getVirtualPrice() public view returns (uint256 virtualPrice) {
        (uint256 _reserve0, uint256 _reserve1) = _getReserves();
        uint256 d = _computeLiquidity(_reserve0, _reserve1);
        virtualPrice = (d * (uint256(10)**decimals)) / totalSupply;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

/// @notice A library that contains functions for calculating differences between two uint256.
/// @author Adapted from https://github.com/saddle-finance/saddle-contract/blob/master/contracts/MathUtils.sol.
library MathUtils {
    /// @notice Compares a and b and returns 'true' if the difference between a and b
    /// is less than 1 or equal to each other.
    /// @param a uint256 to compare with.
    /// @param b uint256 to compare with.
    function within1(uint256 a, uint256 b) internal pure returns (bool) {
        unchecked {
            if (a > b) {
                return a - b <= 1;
            }
            return b - a <= 1;
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "../libraries/RebaseLibrary.sol";
import "../libraries/SafeCast.sol";

contract RebasingMock {

    using SafeCast for uint256;
    using RebaseLibrary for Rebase;

    Rebase public total;

    function toBase(uint256  elastic) public view returns (uint256 base) {
        base =  total.toBase(elastic);
    }

    function toElastic(uint256 base) public view returns (uint256 elastic) {
        elastic = total.toElastic(base);
    }

    function set(uint256 elastic, uint256 base) public {
        total.elastic = elastic.toUint128();
        total.base = base.toUint128();
    }
    function reset() public {
        total.elastic = 0;
        total.base = 0;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import {ERC20} from "@rari-capital/solmate/src/tokens/ERC20.sol";
import {ReentrancyGuard} from "@rari-capital/solmate/src/utils/ReentrancyGuard.sol";

import {IBentoBoxMinimal} from "../../interfaces/IBentoBoxMinimal.sol";
import {IPool} from "../../interfaces/IPool.sol";
import {ITridentCallee} from "../../interfaces/ITridentCallee.sol";
import {IConstantProductPoolFactory} from "../../interfaces/IConstantProductPoolFactory.sol";
import {IMasterDeployer} from "../../interfaces/IMasterDeployer.sol";

import {TridentMath} from "../../libraries/TridentMath.sol";

/// @dev Custom Errors
error ZeroAddress();
error IdenticalAddress();
error InvalidSwapFee();
error InvalidAmounts();
error InsufficientLiquidityMinted();
error InvalidOutputToken();
error InvalidInputToken();
error PoolUninitialized();
error InsufficientAmountIn();
error Overflow();

/// @notice Trident exchange pool template with constant product formula for swapping between an ERC-20 token pair.
/// @dev The reserves are stored as bento shares.
///      The curve is applied to shares as well. This pool does not care about the underlying amounts.
contract ConstantProductPool is IPool, ERC20, ReentrancyGuard {
    event Mint(address indexed sender, uint256 amount0, uint256 amount1, address indexed recipient);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed recipient);
    event Sync(uint256 reserve0, uint256 reserve1);

    uint256 internal constant MINIMUM_LIQUIDITY = 1000;

    uint8 internal constant PRECISION = 112;
    uint256 internal constant MAX_FEE = 10000; // @dev 100%.
    uint256 public immutable swapFee;
    uint256 internal immutable MAX_FEE_MINUS_SWAP_FEE;

    IBentoBoxMinimal public immutable bento;
    IMasterDeployer public immutable masterDeployer;
    address public immutable token0;
    address public immutable token1;

    uint256 public barFee;
    address public barFeeTo;
    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint256 public kLast;

    uint112 internal reserve0;
    uint112 internal reserve1;
    uint32 internal blockTimestampLast;

    bytes32 public constant override poolIdentifier = "Trident:ConstantProduct";

    constructor() ERC20("Sushi Constant Product LP Token", "SCPLP", 18) {
        (bytes memory _deployData, IMasterDeployer _masterDeployer) = IConstantProductPoolFactory(msg.sender).getDeployData();

        (address _token0, address _token1, uint256 _swapFee, bool _twapSupport) = abi.decode(
            _deployData,
            (address, address, uint256, bool)
        );

        // Factory ensures that the tokens are sorted.
        if (_token0 == address(0)) revert ZeroAddress();
        if (_token0 == _token1) revert IdenticalAddress();
        if (_swapFee > MAX_FEE) revert InvalidSwapFee();

        token0 = _token0;
        token1 = _token1;
        swapFee = _swapFee;
        // This is safe from underflow - `swapFee` cannot exceed `MAX_FEE` per previous check.
        unchecked {
            MAX_FEE_MINUS_SWAP_FEE = MAX_FEE - _swapFee;
        }
        barFee = _masterDeployer.barFee();
        barFeeTo = _masterDeployer.barFeeTo();
        bento = IBentoBoxMinimal(_masterDeployer.bento());
        masterDeployer = _masterDeployer;
        if (_twapSupport) blockTimestampLast = uint32(block.timestamp);
    }

    /// @dev Mints LP tokens - should be called via the router after transferring `bento` tokens.
    /// The router must ensure that sufficient LP tokens are minted by using the return value.
    function mint(bytes calldata data) public override nonReentrant returns (uint256 liquidity) {
        address recipient = abi.decode(data, (address));
        (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) = _getReserves();
        (uint256 balance0, uint256 balance1) = _balance();

        uint256 computed = TridentMath.sqrt(balance0 * balance1);
        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;

        (uint256 fee0, uint256 fee1) = _nonOptimalMintFee(amount0, amount1, _reserve0, _reserve1);
        _reserve0 += uint112(fee0);
        _reserve1 += uint112(fee1);

        (uint256 _totalSupply, uint256 k) = _mintFee(_reserve0, _reserve1);

        if (_totalSupply == 0) {
            if (amount0 == 0 || amount1 == 0) revert InvalidAmounts();
            liquidity = computed - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY);
        } else {
            uint256 kIncrease;
            unchecked {
                kIncrease = computed - k;
            }
            liquidity = (kIncrease * _totalSupply) / k;
        }
        if (liquidity == 0) revert InsufficientLiquidityMinted();
        _mint(recipient, liquidity);
        _update(balance0, balance1, _reserve0, _reserve1, _blockTimestampLast);
        kLast = computed;
        emit Mint(msg.sender, amount0, amount1, recipient);
    }

    /// @dev Burns LP tokens sent to this contract. The router must ensure that the user gets sufficient output tokens.
    function burn(bytes calldata data) public override nonReentrant returns (IPool.TokenAmount[] memory withdrawnAmounts) {
        (address recipient, bool unwrapBento) = abi.decode(data, (address, bool));
        (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) = _getReserves();
        (uint256 balance0, uint256 balance1) = _balance();
        uint256 liquidity = balanceOf[address(this)];

        (uint256 _totalSupply, ) = _mintFee(_reserve0, _reserve1);

        uint256 amount0 = (liquidity * balance0) / _totalSupply;
        uint256 amount1 = (liquidity * balance1) / _totalSupply;

        _burn(address(this), liquidity);
        _transfer(token0, amount0, recipient, unwrapBento);
        _transfer(token1, amount1, recipient, unwrapBento);
        // This is safe from underflow - amounts are lesser figures derived from balances.
        unchecked {
            balance0 -= amount0;
            balance1 -= amount1;
        }
        _update(balance0, balance1, _reserve0, _reserve1, _blockTimestampLast);
        kLast = TridentMath.sqrt(balance0 * balance1);

        withdrawnAmounts = new TokenAmount[](2);
        withdrawnAmounts[0] = TokenAmount({token: address(token0), amount: amount0});
        withdrawnAmounts[1] = TokenAmount({token: address(token1), amount: amount1});
        emit Burn(msg.sender, amount0, amount1, recipient);
    }

    /// @dev Burns LP tokens sent to this contract and swaps one of the output tokens for another
    /// - i.e., the user gets a single token out by burning LP tokens.
    function burnSingle(bytes calldata data) public override nonReentrant returns (uint256 amountOut) {
        (address tokenOut, address recipient, bool unwrapBento) = abi.decode(data, (address, address, bool));
        (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) = _getReserves();
        uint256 liquidity = balanceOf[address(this)];

        (uint256 _totalSupply, ) = _mintFee(_reserve0, _reserve1);

        uint256 amount0 = (liquidity * _reserve0) / _totalSupply;
        uint256 amount1 = (liquidity * _reserve1) / _totalSupply;

        kLast = TridentMath.sqrt((_reserve0 - amount0) * (_reserve1 - amount1));

        _burn(address(this), liquidity);

        // Swap one token for another
        unchecked {
            if (tokenOut == token1) {
                // Swap `token0` for `token1`
                // - calculate `amountOut` as if the user first withdrew balanced liquidity and then swapped `token0` for `token1`.
                amount1 += _getAmountOut(amount0, _reserve0 - amount0, _reserve1 - amount1);
                _transfer(token1, amount1, recipient, unwrapBento);
                amountOut = amount1;
                amount0 = 0;
            } else {
                // Swap `token1` for `token0`.
                if (tokenOut != token0) revert InvalidOutputToken();
                amount0 += _getAmountOut(amount1, _reserve1 - amount1, _reserve0 - amount0);
                _transfer(token0, amount0, recipient, unwrapBento);
                amountOut = amount0;
                amount1 = 0;
            }
        }

        (uint256 balance0, uint256 balance1) = _balance();
        _update(balance0, balance1, _reserve0, _reserve1, _blockTimestampLast);

        emit Burn(msg.sender, amount0, amount1, recipient);
    }

    /// @dev Swaps one token for another. The router must prefund this contract and ensure there isn't too much slippage.
    function swap(bytes calldata data) public override nonReentrant returns (uint256 amountOut) {
        (address tokenIn, address recipient, bool unwrapBento) = abi.decode(data, (address, address, bool));
        (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) = _getReserves();
        if (_reserve0 == 0) revert PoolUninitialized();
        (uint256 balance0, uint256 balance1) = _balance();
        uint256 amountIn;
        address tokenOut;
        unchecked {
            if (tokenIn == token0) {
                tokenOut = token1;
                amountIn = balance0 - _reserve0;
                amountOut = _getAmountOut(amountIn, _reserve0, _reserve1);
                balance1 -= amountOut;
            } else {
                if (tokenIn != token1) revert InvalidInputToken();
                tokenOut = token0;
                amountIn = balance1 - reserve1;
                amountOut = _getAmountOut(amountIn, _reserve1, _reserve0);
                balance0 -= amountOut;
            }
        }
        _transfer(tokenOut, amountOut, recipient, unwrapBento);
        _update(balance0, balance1, _reserve0, _reserve1, _blockTimestampLast);
        emit Swap(recipient, tokenIn, tokenOut, amountIn, amountOut);
    }

    /// @dev Swaps one token for another. The router must support swap callbacks and ensure there isn't too much slippage.
    function flashSwap(bytes calldata data) public override nonReentrant returns (uint256 amountOut) {
        (address tokenIn, address recipient, bool unwrapBento, uint256 amountIn, bytes memory context) = abi.decode(
            data,
            (address, address, bool, uint256, bytes)
        );
        (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) = _getReserves();
        if (_reserve0 == 0) revert PoolUninitialized();
        unchecked {
            if (tokenIn == token0) {
                amountOut = _getAmountOut(amountIn, _reserve0, _reserve1);
                _transfer(token1, amountOut, recipient, unwrapBento);
                ITridentCallee(msg.sender).tridentSwapCallback(context);
                (uint256 balance0, uint256 balance1) = _balance();
                if (balance0 - _reserve0 < amountIn) revert InsufficientAmountIn();
                _update(balance0, balance1, _reserve0, _reserve1, _blockTimestampLast);
                emit Swap(recipient, tokenIn, token1, amountIn, amountOut);
            } else {
                if (tokenIn != token1) revert InvalidInputToken();
                amountOut = _getAmountOut(amountIn, _reserve1, _reserve0);
                _transfer(token0, amountOut, recipient, unwrapBento);
                ITridentCallee(msg.sender).tridentSwapCallback(context);
                (uint256 balance0, uint256 balance1) = _balance();
                if (balance1 - _reserve1 < amountIn) revert InsufficientAmountIn();
                _update(balance0, balance1, _reserve0, _reserve1, _blockTimestampLast);
                emit Swap(recipient, tokenIn, token0, amountIn, amountOut);
            }
        }
    }

    /// @dev Updates `barFee` and `barFeeTo` for Trident protocol.
    function updateBarParameters() public {
        barFee = masterDeployer.barFee();
        barFeeTo = masterDeployer.barFeeTo();
    }

    function _getReserves()
        internal
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        )
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _balance() internal view returns (uint256 balance0, uint256 balance1) {
        balance0 = bento.balanceOf(token0, address(this));
        balance1 = bento.balanceOf(token1, address(this));
    }

    function _update(
        uint256 balance0,
        uint256 balance1,
        uint112 _reserve0,
        uint112 _reserve1,
        uint32 _blockTimestampLast
    ) internal {
        if (balance0 > type(uint112).max || balance1 > type(uint112).max) revert Overflow();
        if (_blockTimestampLast == 0) {
            // TWAP support is disabled for gas efficiency.
            reserve0 = uint112(balance0);
            reserve1 = uint112(balance1);
        } else {
            uint32 blockTimestamp = uint32(block.timestamp);
            if (blockTimestamp != _blockTimestampLast && _reserve0 != 0 && _reserve1 != 0) {
                unchecked {
                    uint32 timeElapsed = blockTimestamp - _blockTimestampLast;
                    uint256 price0 = (uint256(_reserve1) << PRECISION) / _reserve0;
                    price0CumulativeLast += price0 * timeElapsed;
                    uint256 price1 = (uint256(_reserve0) << PRECISION) / _reserve1;
                    price1CumulativeLast += price1 * timeElapsed;
                }
            }
            reserve0 = uint112(balance0);
            reserve1 = uint112(balance1);
            blockTimestampLast = blockTimestamp;
        }
        emit Sync(balance0, balance1);
    }

    function _mintFee(uint112 _reserve0, uint112 _reserve1) internal returns (uint256 _totalSupply, uint256 computed) {
        _totalSupply = totalSupply;
        uint256 _kLast = kLast;
        if (_kLast != 0) {
            computed = TridentMath.sqrt(uint256(_reserve0) * _reserve1);
            if (computed > _kLast) {
                // `barFee` % of increase in liquidity.
                uint256 _barFee = barFee;
                uint256 numerator = _totalSupply * (computed - _kLast) * _barFee;
                uint256 denominator = (MAX_FEE - _barFee) * computed + _barFee * _kLast;
                uint256 liquidity = numerator / denominator;

                if (liquidity != 0) {
                    _mint(barFeeTo, liquidity);
                    _totalSupply += liquidity;
                }
            }
        }
    }

    function _getAmountOut(
        uint256 amountIn,
        uint256 reserveAmountIn,
        uint256 reserveAmountOut
    ) internal view returns (uint256 amountOut) {
        uint256 amountInWithFee = amountIn * MAX_FEE_MINUS_SWAP_FEE;
        amountOut = (amountInWithFee * reserveAmountOut) / (reserveAmountIn * MAX_FEE + amountInWithFee);
    }

    function _getAmountIn(
        uint256 amountOut,
        uint256 reserveAmountIn,
        uint256 reserveAmountOut
    ) internal view returns (uint256 amountIn) {
        amountIn = (reserveAmountIn * amountOut * MAX_FEE) / ((reserveAmountOut - amountOut) * MAX_FEE_MINUS_SWAP_FEE) + 1;
    }

    function _transfer(
        address token,
        uint256 shares,
        address to,
        bool unwrapBento
    ) internal {
        if (unwrapBento) {
            bento.withdraw(token, address(this), to, 0, shares);
        } else {
            bento.transfer(token, address(this), to, shares);
        }
    }

    /// @dev This fee is charged to cover for `swapFee` when users add unbalanced liquidity.
    function _nonOptimalMintFee(
        uint256 _amount0,
        uint256 _amount1,
        uint256 _reserve0,
        uint256 _reserve1
    ) internal view returns (uint256 token0Fee, uint256 token1Fee) {
        if (_reserve0 == 0 || _reserve1 == 0) return (0, 0);
        uint256 amount1Optimal = (_amount0 * _reserve1) / _reserve0;
        if (amount1Optimal <= _amount1) {
            token1Fee = (swapFee * (_amount1 - amount1Optimal)) / (2 * MAX_FEE);
        } else {
            uint256 amount0Optimal = (_amount1 * _reserve0) / _reserve1;
            token0Fee = (swapFee * (_amount0 - amount0Optimal)) / (2 * MAX_FEE);
        }
    }

    function getAssets() public view override returns (address[] memory assets) {
        assets = new address[](2);
        assets[0] = token0;
        assets[1] = token1;
    }

    function getAmountOut(bytes calldata data) public view override returns (uint256 finalAmountOut) {
        (address tokenIn, uint256 amountIn) = abi.decode(data, (address, uint256));
        (uint112 _reserve0, uint112 _reserve1, ) = _getReserves();
        if (tokenIn == token0) {
            finalAmountOut = _getAmountOut(amountIn, _reserve0, _reserve1);
        } else {
            if (tokenIn != token1) revert InvalidInputToken();
            finalAmountOut = _getAmountOut(amountIn, _reserve1, _reserve0);
        }
    }

    function getAmountIn(bytes calldata data) public view override returns (uint256 finalAmountIn) {
        (address tokenOut, uint256 amountOut) = abi.decode(data, (address, uint256));
        (uint112 _reserve0, uint112 _reserve1, ) = _getReserves();
        if (tokenOut == token1) {
            finalAmountIn = _getAmountIn(amountOut, _reserve0, _reserve1);
        } else {
            if (tokenOut != token0) revert InvalidOutputToken();
            finalAmountIn = _getAmountIn(amountOut, _reserve1, _reserve0);
        }
    }

    /// @dev Returned values are in terms of BentoBox "shares".
    function getReserves()
        public
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        )
    {
        return _getReserves();
    }

    /// @dev Returned values are the native ERC20 token amounts.
    function getNativeReserves()
        public
        view
        returns (
            uint256 _nativeReserve0,
            uint256 _nativeReserve1,
            uint32 _blockTimestampLast
        )
    {
        (uint112 _reserve0, uint112 _reserve1, uint32 __blockTimestampLast) = _getReserves();
        _nativeReserve0 = bento.toAmount(token0, _reserve0, false);
        _nativeReserve1 = bento.toAmount(token1, _reserve1, false);
        _blockTimestampLast = __blockTimestampLast;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "./IMasterDeployer.sol";

interface IConstantProductPoolFactory {
    function getDeployData() external view returns (bytes memory, IMasterDeployer);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

/// @notice Trident sqrt helper library.
library TridentMath {
    /// @dev Modified from Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/FixedPointMathLib.sol)
    function sqrt(uint256 x) internal pure returns (uint256 z) {
        assembly {
            // This segment is to get a reasonable initial estimate for the Babylonian method.
            // If the initial estimate is bad, the number of correct bits increases ~linearly
            // each iteration instead of ~quadratically.
            // The idea is to get z*z*y within a small factor of x.
            // More iterations here gets y in a tighter range. Currently, we will have
            // y in [256, 256*2^16). We ensure y>= 256 so that the relative difference
            // between y and y+1 is small. If x < 256 this is not possible, but those cases
            // are easy enough to verify exhaustively.
            z := 181 // The 'correct' value is 1, but this saves a multiply later
            let y := x
            // Note that we check y>= 2^(k + 8) but shift right by k bits each branch,
            // this is to ensure that if x >= 256, then y >= 256.
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
            // Now, z*z*y <= x < z*z*(y+1), and y <= 2^(16+8),
            // and either y >= 256, or x < 256.
            // Correctness can be checked exhaustively for x < 256, so we assume y >= 256.
            // Then z*sqrt(y) is within sqrt(257)/sqrt(256) of sqrt(x), or about 20bps.

            // For s in the range [1/256, 256], the estimate f(s) = (181/1024) * (s+1)
            // is in the range (1/2.84 * sqrt(s), 2.84 * sqrt(s)), with largest error when s=1
            // and when s = 256 or 1/256. Since y is in [256, 256*2^16), let a = y/65536, so
            // that a is in [1/256, 256). Then we can estimate sqrt(y) as
            // sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2^18
            // There is no overflow risk here since y < 2^136 after the first branch above.
            z := shr(18, mul(z, add(y, 65536))) // A multiply is saved from the initial z := 181

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            // Possibly with a quadratic/cubic polynomial above we could get 4-6.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // See https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division.
            // If x+1 is a perfect square, the Babylonian method cycles between
            // floor(sqrt(x)) and ceil(sqrt(x)). This check ensures we return floor.
            // Since this case is rare, we choose to save gas on the assignment and
            // repeat division in the rare case.
            // If you don't care whether floor or ceil is returned, you can skip this.
            if lt(div(x, z), z) {
                z := div(x, z)
            }
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "./ConstantProductPool.sol";
import "./ConstantProductPoolFactory.sol";

/// @notice Helper Contract for fetching info for several pools
/// @author Ilya Lyalin
contract ConstantProductPoolFactoryHelper {
    struct ConstantProductPoolInfo {
        uint8 tokenA;
        uint8 tokenB;
        uint112 reserve0;
        uint112 reserve1;
        uint16 swapFeeAndTwapSupport;
    }

    // @dev tokens MUST be sorted i < j => token[i] < token[j]
    // @dev tokens.length < 256
    function getPoolsForTokens(address constantProductPoolFactory, address[] calldata tokens)
        external
        view
        returns (ConstantProductPoolInfo[] memory poolInfos, uint256 length)
    {
        ConstantProductPoolFactory factory = ConstantProductPoolFactory(constantProductPoolFactory);
        uint8 tokenNumber = uint8(tokens.length);
        uint256[] memory poolLength = new uint256[]((tokenNumber * (tokenNumber + 1)) / 2);
        uint256 pairNumber = 0;
        for (uint8 i = 0; i < tokenNumber; i++) {
            for (uint8 j = i + 1; j < tokenNumber; j++) {
                uint256 count = factory.poolsCount(tokens[i], tokens[j]);
                poolLength[pairNumber++] = count;
                length += count;
            }
        }
        poolInfos = new ConstantProductPoolInfo[](length);
        pairNumber = 0;
        uint256 poolNumber = 0;
        for (uint8 i = 0; i < tokenNumber; i++) {
            for (uint8 j = i + 1; j < tokenNumber; j++) {
                address[] memory pools = factory.getPools(tokens[i], tokens[j], 0, poolLength[pairNumber++]);
                for (uint256 k = 0; k < pools.length; k++) {
                    ConstantProductPoolInfo memory poolInfo = poolInfos[poolNumber++];
                    poolInfo.tokenA = i;
                    poolInfo.tokenB = j;
                    ConstantProductPool pool = ConstantProductPool(pools[k]);
                    (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = pool.getReserves();
                    poolInfo.reserve0 = reserve0;
                    poolInfo.reserve1 = reserve1;
                    poolInfo.swapFeeAndTwapSupport = uint16(pool.swapFee());
                    if (blockTimestampLast != 0) poolInfo.swapFeeAndTwapSupport += 1 << 15;
                }
            }
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import {PoolDeployer} from "../../abstract/PoolDeployer.sol";
import {ConstantProductPool} from "./ConstantProductPool.sol";
import {IConstantProductPoolFactory} from "../../interfaces/IConstantProductPoolFactory.sol";
import {IMasterDeployer} from "../../interfaces/IMasterDeployer.sol";

/// @notice Contract for deploying Trident exchange Constant Product Pool with configurations.
/// @author Mudit Gupta.
contract ConstantProductPoolFactory is IConstantProductPoolFactory, PoolDeployer {
    bytes32 public constant bytecodeHash = keccak256(type(ConstantProductPool).creationCode);

    bytes private cachedDeployData;

    constructor(address _masterDeployer) PoolDeployer(_masterDeployer) {}

    function deployPool(bytes memory _deployData) external returns (address pool) {
        (address tokenA, address tokenB, uint256 swapFee, bool twapSupport) = abi.decode(_deployData, (address, address, uint256, bool));

        if (tokenA > tokenB) {
            (tokenA, tokenB) = (tokenB, tokenA);
        }

        // Strips any extra data.
        _deployData = abi.encode(tokenA, tokenB, swapFee, twapSupport);

        address[] memory tokens = new address[](2);
        tokens[0] = tokenA;
        tokens[1] = tokenB;

        bytes32 salt = keccak256(_deployData);

        cachedDeployData = _deployData;

        pool = address(new ConstantProductPool{salt: salt}());

        cachedDeployData = "";

        _registerPool(pool, tokens, salt);
    }

    // This called in the ConstantProductPool constructor.
    function getDeployData() external view override returns (bytes memory, IMasterDeployer) {
        return (cachedDeployData, IMasterDeployer(masterDeployer));
    }

    function calculatePoolAddress(
        address token0,
        address token1,
        uint256 swapFee,
        bool twapSupport
    ) external view returns (address) {
        bytes32 salt = keccak256(abi.encode(token0, token1, swapFee, twapSupport));
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, bytecodeHash));
        return address(uint160(uint256(hash)));
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import {Multicall} from "./abstract/Multicall.sol";
import {SelfPermit} from "./abstract/SelfPermit.sol";
import {Transfer} from "./libraries/Transfer.sol";
import {IBentoBoxMinimal} from "./interfaces/IBentoBoxMinimal.sol";
import {IMasterDeployer} from "./interfaces/IMasterDeployer.sol";
import {IPool} from "./interfaces/IPool.sol";
import {ITridentRouter} from "./interfaces/ITridentRouter.sol";
import {IWETH9} from "./interfaces/IWETH9.sol";

/// @dev Custom Errors
error NotWethSender();
error TooLittleReceived();
error NotEnoughLiquidityMinted();
error IncorrectTokenWithdrawn();
error IncorrectSlippageParams();
error InsufficientWETH();
error InvalidPool();

/// @notice Router contract that helps in swapping across Trident pools.
contract TridentRouter is ITridentRouter, SelfPermit, Multicall {
    using Transfer for address;

    /// @notice BentoBox token vault.
    IBentoBoxMinimal public immutable bento;

    /// @notice Master deployer.
    IMasterDeployer public immutable masterDeployer;

    /// @notice ERC-20 token for wrapped ETH (v9).
    address internal immutable wETH;

    /// @notice The user should use 0x0 if they want to use native currency, e.g., ETH.
    address constant USE_NATIVE = address(0);

    constructor(
        IBentoBoxMinimal _bento,
        IMasterDeployer _masterDeployer,
        address _wETH
    ) {
        bento = _bento;
        masterDeployer = _masterDeployer;
        wETH = _wETH;
        _bento.registerProtocol();
    }

    receive() external payable {
        if (msg.sender != wETH) revert NotWethSender();
    }

    /// @notice Swaps token A to token B directly. Swaps are done on `bento` tokens.
    /// @param params This includes the address of token A, pool, amount of token A to swap,
    /// minimum amount of token B after the swap and data required by the pool for the swap.
    /// @dev Ensure that the pool is trusted before calling this function. The pool can steal users' tokens.
    function exactInputSingle(ExactInputSingleParams calldata params) public payable returns (uint256 amountOut) {
        // Prefund the pool with token A.
        bento.transfer(params.tokenIn, msg.sender, params.pool, params.amountIn);
        // Trigger the swap in the pool.
        amountOut = IPool(params.pool).swap(params.data);
        // Ensure that the slippage wasn't too much. This assumes that the pool is honest.
        if (amountOut < params.amountOutMinimum) revert TooLittleReceived();
    }

    /// @notice Swaps token A to token B indirectly by using multiple hops.
    /// @param params This includes the addresses of the tokens, pools, amount of token A to swap,
    /// minimum amount of token B after the swap and data required by the pools for the swaps.
    /// @dev Ensure that the pools are trusted before calling this function. The pools can steal users' tokens.
    function exactInput(ExactInputParams calldata params) public payable returns (uint256 amountOut) {
        // Pay the first pool directly.
        bento.transfer(params.tokenIn, msg.sender, params.path[0].pool, params.amountIn);
        // Call every pool in the path.
        // Pool `N` should transfer its output tokens to pool `N+1` directly.
        // The last pool should transfer its output tokens to the user.
        // If the user wants to unwrap `wETH`, the final destination should be this contract and
        // a batch call should be made to `unwrapWETH`.
        uint256 n = params.path.length;
        for (uint256 i = 0; i < n; i = _increment(i)) {
            amountOut = IPool(params.path[i].pool).swap(params.path[i].data);
        }
        // Ensure that the slippage wasn't too much. This assumes that the pool is honest.
        if (amountOut < params.amountOutMinimum) revert TooLittleReceived();
    }

    /// @notice Swaps token A to token B directly. It's the same as `exactInputSingle` except
    /// it takes raw ERC-20 tokens from the users and deposits them into `bento`.
    /// @param params This includes the address of token A, pool, amount of token A to swap,
    /// minimum amount of token B after the swap and data required by the pool for the swap.
    /// @dev Ensure that the pool is trusted before calling this function. The pool can steal users' tokens.
    function exactInputSingleWithNativeToken(ExactInputSingleParams calldata params) public payable returns (uint256 amountOut) {
        // Deposits the native ERC-20 token from the user into the pool's `bento`.
        _depositToBentoBox(params.tokenIn, params.pool, params.amountIn);
        // Trigger the swap in the pool.
        amountOut = IPool(params.pool).swap(params.data);
        // Ensure that the slippage wasn't too much. This assumes that the pool is honest.
        if (amountOut < params.amountOutMinimum) revert TooLittleReceived();
    }

    /// @notice Swaps token A to token B indirectly by using multiple hops. It's the same as `exactInput` except
    /// it takes raw ERC-20 tokens from the users and deposits them into `bento`.
    /// @param params This includes the addresses of the tokens, pools, amount of token A to swap,
    /// minimum amount of token B after the swap and data required by the pools for the swaps.
    /// @dev Ensure that the pools are trusted before calling this function. The pools can steal users' tokens.
    function exactInputWithNativeToken(ExactInputParams calldata params) public payable returns (uint256 amountOut) {
        // Deposits the native ERC-20 token from the user into the pool's `bento`.
        _depositToBentoBox(params.tokenIn, params.path[0].pool, params.amountIn);
        // Call every pool in the path.
        // Pool `N` should transfer its output tokens to pool `N+1` directly.
        // The last pool should transfer its output tokens to the user.
        uint256 n = params.path.length;
        for (uint256 i = 0; i < n; i = _increment(i)) {
            amountOut = IPool(params.path[i].pool).swap(params.path[i].data);
        }
        // Ensure that the slippage wasn't too much. This assumes that the pool is honest.
        if (amountOut < params.amountOutMinimum) revert TooLittleReceived();
    }

    /// @notice Swaps multiple input tokens to multiple output tokens using multiple paths, in different percentages.
    /// For example, you can swap 50 DAI + 100 USDC into 60% ETH and 40% BTC.
    /// @param params This includes everything needed for the swap. Look at the `ComplexPathParams` struct for more details.
    /// @dev This function is not optimized for single swaps and should only be used in complex cases where
    /// the amounts are large enough that minimizing slippage by using multiple paths is worth the extra gas.
    function complexPath(ComplexPathParams calldata params) public payable {
        // Deposit all initial tokens to respective pools and initiate the swaps.
        // Input tokens come from the user - output goes to following pools.
        uint256 n = params.initialPath.length;
        for (uint256 i = 0; i < n; i = _increment(i)) {
            if (params.initialPath[i].native) {
                _depositToBentoBox(params.initialPath[i].tokenIn, params.initialPath[i].pool, params.initialPath[i].amount);
            } else {
                bento.transfer(params.initialPath[i].tokenIn, msg.sender, params.initialPath[i].pool, params.initialPath[i].amount);
            }
            IPool(params.initialPath[i].pool).swap(params.initialPath[i].data);
        }
        // Do all the middle swaps. Input comes from previous pools.
        n = params.percentagePath.length;
        for (uint256 i = 0; i < n; i = _increment(i)) {
            uint256 balanceShares = bento.balanceOf(params.percentagePath[i].tokenIn, address(this));
            uint256 transferShares = (balanceShares * params.percentagePath[i].balancePercentage) / uint256(10)**8;
            bento.transfer(params.percentagePath[i].tokenIn, address(this), params.percentagePath[i].pool, transferShares);
            IPool(params.percentagePath[i].pool).swap(params.percentagePath[i].data);
        }
        // Ensure enough was received and transfer the ouput to the recipient.
        n = params.output.length;
        for (uint256 i = 0; i < n; i = _increment(i)) {
            uint256 balanceShares = bento.balanceOf(params.output[i].token, address(this));
            if (balanceShares < params.output[i].minAmount) revert TooLittleReceived();
            if (params.output[i].unwrapBento) {
                bento.withdraw(params.output[i].token, address(this), params.output[i].to, 0, balanceShares);
            } else {
                bento.transfer(params.output[i].token, address(this), params.output[i].to, balanceShares);
            }
        }
    }

    /// @notice Add liquidity to a pool.
    /// @param tokenInput Token address and amount to add as liquidity.
    /// @param pool Pool address to add liquidity to.
    /// @param minLiquidity Minimum output liquidity - caps slippage.
    /// @param data Data required by the pool to add liquidity.
    function addLiquidity(
        TokenInput[] calldata tokenInput,
        address pool,
        uint256 minLiquidity,
        bytes calldata data
    ) public payable returns (uint256 liquidity) {
        // Send all input tokens to the pool.
        uint256 n = tokenInput.length;
        for (uint256 i = 0; i < n; i = _increment(i)) {
            if (tokenInput[i].native) {
                _depositToBentoBox(tokenInput[i].token, pool, tokenInput[i].amount);
            } else {
                bento.transfer(tokenInput[i].token, msg.sender, pool, tokenInput[i].amount);
            }
        }
        liquidity = IPool(pool).mint(data);
        if (liquidity < minLiquidity) revert NotEnoughLiquidityMinted();
    }

    /// @notice Burn liquidity tokens to get back `bento` tokens.
    /// @param pool Pool address.
    /// @param liquidity Amount of liquidity tokens to burn.
    /// @param data Data required by the pool to burn liquidity.
    /// @param minWithdrawals Minimum amount of `bento` tokens to be returned.
    function burnLiquidity(
        address pool,
        uint256 liquidity,
        bytes calldata data,
        IPool.TokenAmount[] calldata minWithdrawals
    ) public payable {
        pool.safeTransferFrom(msg.sender, pool, liquidity);
        IPool.TokenAmount[] memory withdrawnLiquidity = IPool(pool).burn(data);
        uint256 n = minWithdrawals.length;
        for (uint256 i = 0; i < n; i = _increment(i)) {
            if (minWithdrawals[i].token != withdrawnLiquidity[i].token) revert IncorrectSlippageParams();
            if (withdrawnLiquidity[i].amount < minWithdrawals[i].amount) revert TooLittleReceived();
        }
    }

    /// @notice Burn liquidity tokens to get back `bento` tokens.
    /// @dev The tokens are swapped automatically and the output is in a single token.
    /// @param pool Pool address.
    /// @param liquidity Amount of liquidity tokens to burn.
    /// @param data Data required by the pool to burn liquidity.
    /// @param minWithdrawal Minimum amount of tokens to be returned.
    function burnLiquiditySingle(
        address pool,
        uint256 liquidity,
        bytes calldata data,
        uint256 minWithdrawal
    ) public payable {
        // Use 'liquidity = 0' for prefunding.
        pool.safeTransferFrom(msg.sender, pool, liquidity);
        uint256 withdrawn = IPool(pool).burnSingle(data);
        if (withdrawn < minWithdrawal) revert TooLittleReceived();
    }

    /// @notice Recover mistakenly sent tokens.
    function sweep(
        address token,
        uint256 amount,
        address recipient,
        bool fromBento
    ) external payable {
        if (fromBento) {
            bento.transfer(token, address(this), recipient, amount);
        } else {
            token == USE_NATIVE ? recipient.safeTransferETH(address(this).balance) : token.safeTransfer(recipient, amount);
        }
    }

    /// @notice Unwrap this contract's wETH into ETH.
    function unwrapWETH(address recipient) external payable {
        uint256 balance = IWETH9(wETH).balanceOf(address(this));
        IWETH9(wETH).withdraw(balance);
        recipient.safeTransferETH(balance);
    }

    /// @notice Wrapper function to allow pool deployment to be batched.
    function deployPool(address factory, bytes calldata deployData) external payable returns (address) {
        return masterDeployer.deployPool(factory, deployData);
    }

    /// @notice Wrapper function to allow bento set master contract approval to be batched, so the first trade can happen in one transaction.
    function approveMasterContract(
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable {
        bento.setMasterContractApproval(msg.sender, address(this), true, v, r, s);
    }

    /// @notice Call BentoBox harvest function to rebalance a BentoBox token strategy and ensure there are enough tokens available to withdraw a swap output.
    /// @dev Should be batched in before a swap.
    function harvest(address token, uint256 maxChangeAmount) external payable {
        bento.harvest(token, true, maxChangeAmount);
    }

    /// @notice Deposit from the user's wallet into BentoBox.
    /// @dev Amount is the native token amount. We let BentoBox do the conversion into shares.
    function _depositToBentoBox(
        address token,
        address recipient,
        uint256 amount
    ) internal {
        bento.deposit{value: token == USE_NATIVE ? amount : 0}(token, msg.sender, recipient, amount, 0);
    }

    function _increment(uint256 i) internal pure returns (uint256) {
        unchecked {
            return i + 1;
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

import "../interfaces/IERC20PermitAllowed.sol";

abstract contract SelfPermit {
    function selfPermit(
        address token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable {
        IERC20Permit(token).permit(msg.sender, address(this), value, deadline, v, r, s);
    }

    function selfPermitIfNecessary(
        address token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable {
        if (IERC20(token).allowance(msg.sender, address(this)) < value) selfPermit(token, value, deadline, v, r, s);
    }

    function selfPermitAllowed(
        address token,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable {
        IERC20PermitAllowed(token).permit(msg.sender, address(this), nonce, expiry, true, v, r, s);
    }

    function selfPermitAllowedIfNecessary(
        address token,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable {
        if (IERC20(token).allowance(msg.sender, address(this)) < type(uint256).max)
            selfPermitAllowed(token, nonce, expiry, v, r, s);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library Transfer {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "STF");
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "ST");
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "SA");
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "STE");
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
interface IWETH9 is IERC20 {
    function deposit() external payable;
    function withdraw(uint256) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

interface IERC20PermitAllowed {
    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "../interfaces/IPool.sol";
import "../interfaces/ITridentCallee.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IBentoBoxMinimal.sol";


contract FlashSwapMock {
    IBentoBoxMinimal public immutable bento;

    constructor(IBentoBoxMinimal _bento) {
        bento = _bento;
    }

    function testFlashSwap(IPool pair, bytes calldata data) external {
        pair.flashSwap(data);
    }

    function tridentSwapCallback(bytes calldata data) external {
        (bool success, address token, bool viaBento) = abi.decode(data, (bool, address, bool));
        if (success) {
            if (viaBento) {
                uint256 tokenBalanceBento = bento.balanceOf(token, address(this));
                bento.transfer(token, address(this), msg.sender, tokenBalanceBento);
            } else {
                uint256 tokenBalance = IERC20(token).balanceOf(address(this));
                IERC20(token).transfer(address(bento), tokenBalance);
                bento.deposit(token, address(bento), msg.sender, tokenBalance, 0);
            }
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "../abstract/SelfPermit.sol";
import "../abstract/Multicall.sol";
import "../interfaces/IUniswapV2Minimal.sol";
import "../interfaces/IBentoBoxMinimal.sol";
import "../interfaces/ITridentRouter.sol";
import "../interfaces/IMasterDeployer.sol";
import "../interfaces/IPoolFactory.sol";
import "../interfaces/IPool.sol";
import "../interfaces/IConstantProductPool.sol";

/// @notice Liquidity migrator from UniV2 style pool to Trident Constant product pool.
contract TridentSushiRollCP is SelfPermit, Multicall {
    error MinimumOutput();

    IBentoBoxMinimal public immutable bentoBox;
    IPoolFactory public immutable poolFactoryCP;
    IMasterDeployer public immutable masterDeployer;

    constructor(
        IBentoBoxMinimal _bentoBox,
        IPoolFactory _poolFactoryCP,
        IMasterDeployer _masterDeployer
    ) {
        bentoBox = _bentoBox;
        poolFactoryCP = _poolFactoryCP;
        masterDeployer = _masterDeployer;
    }

    /** @notice Function to migrate existing Sushiswap or other Uniswap V2 style pools to Trident.
        @param pair Uniswap V2 style liquidity pool address.
        @param amount Liquidity amount (Lp token balance) to be migrated.
        @param swapFee Swap fee of the Trident CP pool we are migrating into.
        @param twapSupport Whether the Trident CP pool we are migrating into supports twap oracles.
        @param minToken0Received Slippage protection for removing liquidity from a UniV2 style pool.
        @param minToken1Received Slippage protection for removing liquidity from a UniV2 style pool.
        @param minLpReceived Slippage protection for minting liquidity on the Trident CP pool.
        @dev If the pool with the current conditions doesn't exist it will be deployed. */
    function migrateLegacyToCP(
        IUniswapV2Minimal pair,
        uint256 amount,
        uint256 swapFee,
        bool twapSupport,
        uint256 minToken0Received,
        uint256 minToken1Received,
        uint256 minLpReceived
    ) external returns (uint256 liquidity) {
        address token0 = pair.token0();
        address token1 = pair.token1();

        bytes memory poolData = abi.encode(token0, token1, swapFee, twapSupport);
        address tridentPool = poolFactoryCP.configAddress(keccak256(poolData));

        if (tridentPool == address(0)) {
            tridentPool = masterDeployer.deployPool(address(poolFactoryCP), poolData);
        }

        pair.transferFrom(msg.sender, address(pair), amount);
        (uint256 amount0, uint256 amount1) = pair.burn(address(bentoBox));

        if (amount0 < minToken0Received || amount1 < minToken1Received) revert MinimumOutput();

        bentoBox.deposit(token0, address(bentoBox), tridentPool, amount0, 0);
        bentoBox.deposit(token1, address(bentoBox), tridentPool, amount1, 0);

        liquidity = IPool(tridentPool).mint(abi.encode(msg.sender));

        if (liquidity < minLpReceived) revert MinimumOutput();
    }

    /** @notice Function to migrate betewwn Trident CP pools with different fee / twap settings.
        @param currentPool Trident CP pool address we want to migrate from. Can be form an outdated CP factory.
        @param amount Liquidity amount (Lp token balance) to be migrated.
        @param swapFee Swap fee of the Trident CP pool we are migrating into.
        @param twapSupport Whether the Trident CP pool we are migrating into supports twap oracles.
        @param minToken0Received Slippage protection for removing liquidity. Values are in BentoBox shares.
        @param minToken1Received Slippage protection for removing liquidity. Values are in BentoBox shares.
        @param minLpReceived Slippage protection for minting liquidity on the Trident CP pool.
        @dev If the pool with the current conditions doesn't exist it will be deployed. */
    function migrateCP(
        IConstantProductPool currentPool,
        uint256 amount,
        uint256 swapFee,
        bool twapSupport,
        uint256 minToken0Received,
        uint256 minToken1Received,
        uint256 minLpReceived
    ) external returns (uint256 liquidity) {
        address[] memory tokens = currentPool.getAssets();

        bytes memory newPoolData = abi.encode(tokens[0], tokens[1], swapFee, twapSupport);

        address newPool = poolFactoryCP.configAddress(keccak256(newPoolData));

        if (newPool == address(0)) {
            newPool = masterDeployer.deployPool(address(poolFactoryCP), newPoolData);
        }

        currentPool.transferFrom(msg.sender, address(currentPool), amount);

        IPool.TokenAmount[] memory tokenAmounts = currentPool.burn(abi.encode(newPool, false));

        (uint256 amount0, uint256 amount1) = (tokenAmounts[0].amount, tokenAmounts[1].amount);

        if (amount0 < minToken0Received || amount1 < minToken1Received) revert MinimumOutput();

        liquidity = IPool(newPool).mint(abi.encode(msg.sender));

        if (liquidity < minLpReceived) revert MinimumOutput();
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Minimal Uniswap V2 LP interface.
interface IUniswapV2Minimal is IERC20 {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

/// @notice Trident pool deployment interface.
interface IPoolFactory {
    function deployPool(bytes calldata _deployData) external returns (address pool);

    function configAddress(bytes32 data) external returns (address pool);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IPool.sol";

interface IConstantProductPool is IPool, IERC20 {
    function getNativeReserves()
        external
        view
        returns (
            uint256 _nativeReserve0,
            uint256 _nativeReserve1,
            uint32
        );
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IntermediaryToken.sol";
import "../interfaces/IMasterDeployer.sol";
import "../interfaces/IBentoBoxMinimal.sol";
import "../interfaces/IPoolFactory.sol";
import "../interfaces/IPool.sol";
import "../interfaces/IConstantProductPool.sol";
import "../interfaces/IUniswapV2Minimal.sol";

/// @notice Trident pool migrator contract for legacy SushiSwap.
/** Sushiswap's master chef contracts which distribute rewards to LP token holders have the option to migrate liquidity.
    We can set this contract as the migrator on the master chef contracts to migrate LP positions from the legacy to the new Trident
    constant product pools. After the migrator is set anyone can call the migrate() function (once per pool) on the master chef contract.
    Used by MasterChef / MasterChefV2 / MiniChef. */
contract Migrator {
    event Migrate(address indexed oldPool, address indexed newPool, address indexed intermediaryToken);

    /// @dev Intermediary token to new LP token mapping.
    /// @dev Used to prevent subsequent calls to masterchef's migrate function with the same PID.
    mapping(address => address) public migrated;

    IBentoBoxMinimal public immutable bento;
    IMasterDeployer public immutable masterDeployer;
    IPoolFactory public immutable constantProductPoolFactory;
    address public immutable masterChef;

    constructor(
        IBentoBoxMinimal _bento,
        IMasterDeployer _masterDeployer,
        IPoolFactory _constantProductPoolFactory,
        address _masterChef
    ) {
        bento = _bento;
        masterDeployer = _masterDeployer;
        constantProductPoolFactory = _constantProductPoolFactory;
        masterChef = _masterChef;
    }

    /// @notice Method to migrate MasterChef's liquidity from the legacy SushiSwap AMM to the Trident constant product pool.
    /// @param oldPool Legacy SushiSwap pool.
    /// @dev Since MasterChef has a requirement to receive the same amount of "LP" tokens back after migration we use an
    /// intermediary token so we can mint the desired balance. After unstaking users can call redeem() on the intermediary
    /// token to receive their share of the LP tokens of the new Trident constant product pool.
    function migrate(IUniswapV2Minimal oldPool) external returns (address) {
        require(msg.sender == address(masterChef), "ONLY_CHEF");
        require(migrated[address(oldPool)] == address(0), "ONLY_ONCE");

        address token0 = oldPool.token0();
        address token1 = oldPool.token1();

        bytes memory deployData = abi.encode(token0, token1, 30, false);

        IConstantProductPool pool = IConstantProductPool(constantProductPoolFactory.configAddress(keccak256(deployData)));

        // We deploy the pool if it doesn't exist yet.
        if (address(pool) == address(0)) {
            pool = IConstantProductPool(masterDeployer.deployPool(address(constantProductPoolFactory), deployData));
        }

        // We are migrating all of master chef's balance.
        uint256 lpBalance = oldPool.balanceOf(address(masterChef));

        if (lpBalance == 0) {
            return address(pool);
        }

        // Remove the liquidity and send assets to BentoBox.
        oldPool.transferFrom(address(masterChef), address(oldPool), lpBalance);
        (uint256 amount0, uint256 amount1) = oldPool.burn(address(bento));

        bento.deposit(token0, address(bento), address(pool), amount0, 0);
        bento.deposit(token1, address(bento), address(pool), amount1, 0);

        if (pool.totalSupply() != 0) {
            // We require the pools' prices to differ by no more than 0.5%.
            (uint256 _nativeReserve0, uint256 _nativeReserve1, ) = pool.getNativeReserves();
            uint256 oldPoolPrice = (1e18 * amount0) / amount1;
            uint256 newPoolPrice = (1e18 * _nativeReserve0) / _nativeReserve1;
            uint256 priceChange = (1e3 * oldPoolPrice) / newPoolPrice;
            require(priceChange < 1005 && priceChange >= 995, "PRICE_DIFFERENCE");
        }

        // We mint the intermediary token to Master Chef.
        address intermediaryToken = address(new IntermediaryToken(address(pool), masterChef, lpBalance));

        // The new Trident pool mints liquidity to the intermediary token.
        pool.mint(abi.encode(intermediaryToken));

        migrated[intermediaryToken] = address(pool);

        emit Migrate(address(oldPool), address(pool), intermediaryToken);

        return intermediaryToken;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "@rari-capital/solmate/src/tokens/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Intermediary token users who are staked in MasterChef will receive after migration.
/// Can be redeemed for the LP token of the new pool.
contract IntermediaryToken is ERC20 {
    /// @dev Liquidity token of the Trident constant product pool.
    IERC20 public immutable lpToken;

    constructor(
        address _lpToken,
        address _recipient,
        uint256 _amount
    ) ERC20("Sushi LP Token", "SLP", 18) {
        lpToken = IERC20(_lpToken);
        _mint(_recipient, _amount);
    }

    /// @dev Since we might be rewarding the intermediary token for some time we allow users to mint it.
    function deposit(uint256 amount) public returns (uint256 minted) {
        uint256 availableLpTokens = lpToken.balanceOf(address(this));
        if (availableLpTokens != 0) {
            minted = (totalSupply * amount) / availableLpTokens;
        } else {
            minted = amount;
        }
        _mint(msg.sender, minted);
        require(lpToken.transferFrom(msg.sender, address(this), amount), "TRANSFER_FROM_FAILED");
    }

    function redeem(uint256 amount) public returns (uint256 claimed) {
        uint256 availableLpTokens = lpToken.balanceOf(address(this));
        claimed = (availableLpTokens * amount) / totalSupply;
        _burn(msg.sender, amount);
        require(lpToken.transfer(msg.sender, claimed), "TRANSFER_FAILED");
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "../interfaces/IPoolFactory.sol";
import "../abstract/PoolDeployer.sol";
import "../TridentRouter.sol";

contract RouterMock is TridentRouter {
    constructor(
        IBentoBoxMinimal bento,
        IMasterDeployer masterDeployer,
        address wETH
    ) TridentRouter(bento, masterDeployer, wETH) {
        //
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >= 0.8.0;

import "../interfaces/IPoolFactory.sol";
import "../abstract/PoolDeployer.sol";
import "./PoolTemplateMock.sol";

contract PoolFactoryMock is PoolDeployer {
    constructor(address _masterDeployer) PoolDeployer(_masterDeployer) {}
    function deployPool(bytes memory _deployData) external onlyMaster returns (address pool) {
        (address tokenA, address tokenB) = abi.decode(_deployData, (address, address));

        // @dev correctly sorts tokens to ensure _register in PoolDeployer does not revert
        if (tokenA > tokenB) {
            (tokenA, tokenB) = (tokenB, tokenA);
        }

        // @dev Strips any extra data.
        _deployData = abi.encode(tokenA, tokenB);

        address[] memory tokens = new address[](2);
        tokens[0] = tokenA;
        tokens[1] = tokenB;

        // @dev Salt is not actually needed since `_deployData` is part of creationCode and already contains the salt.
        bytes32 salt = keccak256(_deployData);
        pool = address(new PoolTemplateMock{salt: salt}(_deployData));
        _registerPool(pool, tokens, salt);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >= 0.8.0;

contract PoolTemplateMock {
    address public immutable token0;
    address public immutable token1;
    constructor(bytes memory _deployData) {
        (address _token0, address _token1) = abi.decode(
            _deployData,
            (address, address)
        );
        token0 = _token0;
        token1 = _token1;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >= 0.8.0;

import "../interfaces/IPoolFactory.sol";
import "../abstract/PoolDeployer.sol";
import "./PoolTemplateMock.sol";

contract PoolDeployerMock is PoolDeployer {
    constructor(address _masterDeployer) PoolDeployer(_masterDeployer) {}
    function deployPool(bytes memory _deployData) external onlyMaster returns (address pool) {
        (address tokenA, address tokenB) = abi.decode(_deployData, (address, address));

        /// @dev incorrect because there is no sort tokens, causing PoolDeployer to revert
        /// we want this for testing

        /// @dev Strips any extra data.
        _deployData = abi.encode(tokenA, tokenB);

        address[] memory tokens = new address[](2);
        tokens[0] = tokenA;
        tokens[1] = tokenB;

        // @dev Salt is not actually needed since `_deployData` is part of creationCode and already contains the salt.
        bytes32 salt = keccak256(_deployData);
        
        pool = address(new PoolTemplateMock{salt: salt}(_deployData));

        _registerPool(pool, tokens, salt);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >= 0.8.0;

import "../interfaces/IPoolFactory.sol";

import "./PoolTemplate.sol";

/**
 * @author Mudit Gupta
 */
abstract contract PoolFactory is IPoolFactory {
    // Consider deploying via an upgradable proxy to allow upgrading pools in the future

    function deployPool(bytes memory _deployData) external override returns (address) {
        return address(new PoolTemplate(_deployData));
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.2;

/**
 * @author Mudit Gupta
 */
contract PoolTemplate {
    uint256 public immutable configValue;
    address public immutable anotherConfigValue;

    constructor(bytes memory _data) {
        (configValue, anotherConfigValue) = abi.decode(_data, (uint256, address));
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/IPoolFactory.sol";

/// @dev Custom Errors
error InvalidBarFee();
error ZeroAddress();
error NotWhitelisted();

/// @notice Trident pool deployer contract with template factory whitelist.
/// @author Mudit Gupta.
contract MasterDeployer is Ownable {
    event DeployPool(address indexed factory, address indexed pool, bytes deployData);
    event AddToWhitelist(address indexed factory);
    event RemoveFromWhitelist(address indexed factory);
    event BarFeeUpdated(uint256 indexed barFee);
    event BarFeeToUpdated(address indexed barFeeTo);

    uint256 public barFee;
    address public barFeeTo;
    address public immutable bento;

    uint256 internal constant MAX_FEE = 10000; // @dev 100%.

    mapping(address => bool) public pools;
    mapping(address => bool) public whitelistedFactories;

    constructor(
        uint256 _barFee,
        address _barFeeTo,
        address _bento
    ) {
        if (_barFee > MAX_FEE) revert InvalidBarFee();
        if (_barFeeTo == address(0)) revert ZeroAddress();
        if (_bento == address(0)) revert ZeroAddress();

        barFee = _barFee;
        barFeeTo = _barFeeTo;
        bento = _bento;
    }

    function deployPool(address _factory, bytes calldata _deployData) external returns (address pool) {
        if (!whitelistedFactories[_factory]) revert NotWhitelisted();
        pool = IPoolFactory(_factory).deployPool(_deployData);
        pools[pool] = true;
        emit DeployPool(_factory, pool, _deployData);
    }

    function addToWhitelist(address _factory) external onlyOwner {
        whitelistedFactories[_factory] = true;
        emit AddToWhitelist(_factory);
    }

    function removeFromWhitelist(address _factory) external onlyOwner {
        whitelistedFactories[_factory] = false;
        emit RemoveFromWhitelist(_factory);
    }

    function setBarFee(uint256 _barFee) external onlyOwner {
        if (_barFee > MAX_FEE) revert InvalidBarFee();
        barFee = _barFee;
        emit BarFeeUpdated(_barFee);
    }

    function setBarFeeTo(address _barFeeTo) external onlyOwner {
        barFeeTo = _barFeeTo;
        emit BarFeeToUpdated(_barFeeTo);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
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

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH9 is ERC20 {

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    constructor() ERC20("Wrapped Ether", "WETH") {
        _mint(msg.sender, type(uint128).max);
    }
    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 wad) public {
        _burn(msg.sender, wad);
        payable(msg.sender).transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-ERC20Permit.sol)

pragma solidity ^0.8.0;

import "./draft-IERC20Permit.sol";
import "../ERC20.sol";
import "../../../utils/cryptography/draft-EIP712.sol";
import "../../../utils/cryptography/ECDSA.sol";
import "../../../utils/Counters.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >= 0.8.0;

import "../abstract/SelfPermit.sol";

contract SelfPermitMock is SelfPermit {}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >= 0.8.0;

import "./ERC20Mock.sol";
import "../interfaces/IERC20PermitAllowed.sol";

contract ERC20PermitAllowedMock is ERC20Mock, IERC20PermitAllowed {
    constructor(uint256 supply) ERC20Mock("Mock", "MOCK", supply) {}

    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        require(this.nonces(holder) == nonce, "ERC20PermitAllowedMock::permit: wrong nonce");
        permit(holder, spender, allowed ? type(uint256).max : 0, expiry, v, r, s);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >= 0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract ERC20Mock is ERC20Permit {
    constructor(string memory name, string memory symbol, uint256 supply) ERC20(name, symbol) ERC20Permit(name) {
        _mint(msg.sender, supply);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >= 0.8.0;

import "../libraries/Transfer.sol";

contract TransferMock {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) external {
        Transfer.safeApprove(token, to, value);
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) external {
        Transfer.safeTransfer(token, to, value);
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) external {
        Transfer.safeTransferFrom(token, from, to, value);
    }

    function safeTransferETH(address to, uint256 value) external {
        Transfer.safeTransferETH(to, value);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.2;

import "../libraries/TridentMath.sol";

contract TridentMathMock {
    function sqrt(uint256 x) public pure returns (uint256) {
        return TridentMath.sqrt(x);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "../../interfaces/IConcentratedLiquidityPool.sol";
import "../../libraries/TickMath.sol";
import "../../libraries/Ticks.sol";

/// @notice Trident Concentrated Liquidity Pool periphery contract to read state.
contract ConcentratedLiquidityPoolHelper {
    struct SimpleTick {
        int24 index;
        uint128 liquidity;
    }

    function getTickState(IConcentratedLiquidityPool pool, uint24 tickCount) external view returns (SimpleTick[] memory) {
        SimpleTick[] memory ticks = new SimpleTick[](tickCount); // todo save tickCount in the core contract

        IConcentratedLiquidityPool.Tick memory tick;
        uint24 i;
        int24 current = TickMath.MIN_TICK;

        while (current != TickMath.MAX_TICK) {
            tick = pool.ticks(current);
            ticks[i++] = SimpleTick({index: current, liquidity: tick.liquidity});
            current = tick.nextTick;
        }

        tick = pool.ticks(current);
        ticks[i] = SimpleTick({index: TickMath.MAX_TICK, liquidity: tick.liquidity});

        return ticks;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "../libraries/TickMath.sol";

contract TickMathMock {
    function getSqrtRatioAtTick(int24 tick) external pure returns (uint160) {
        return TickMath.getSqrtRatioAtTick(tick);
    }

    function getTickAtSqrtRatio(uint160 sqrtPriceX96) external pure returns (int24) {
        return TickMath.getTickAtSqrtRatio(sqrtPriceX96);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import "../abstract/Multicall.sol";

contract MulticallMock is Multicall {
    function functionThatRevertsWithError(string memory error) external pure {
        revert(error);
    }

    function functionThatRevertsWithoutError() external pure {
        revert();
    }

    struct Tuple {
        uint256 a;
        uint256 b;
    }

    function functionThatReturnsTuple(uint256 a, uint256 b) external pure returns (Tuple memory tuple) {
        tuple = Tuple({b: a, a: b});
    }

    uint256 public paid;

    function pays() external payable {
        paid += msg.value;
    }

    function returnSender() external view returns (address) {
        return msg.sender;
    }
}