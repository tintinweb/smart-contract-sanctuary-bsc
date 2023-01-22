/**
 *Submitted for verification at BscScan.com on 2023-01-22
*/

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 value
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

contract VolatileToken is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(_name, _symbol, _decimals) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

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
interface IERC4626 {
    /*///////////////////////////////////////////////////////////////
                                Events
    //////////////////////////////////////////////////////////////*/

    event Deposit(address indexed from, address indexed to, uint256 amount, uint256 shares);
    event Withdraw(address indexed from, address indexed to, uint256 amount, uint256 shares);


    /*///////////////////////////////////////////////////////////////
                            Mutable Functions
    //////////////////////////////////////////////////////////////*/

    function deposit(uint256 amount, address to) external virtual returns (uint256 shares);

    function mint(uint256 shares, address to) external virtual returns (uint256 underlyingAmount);

    function withdraw(
        uint256 amount,
        address to,
        address from
    ) external virtual returns (uint256 shares);

    function redeem(
        uint256 shares,
        address to,
        address from
    ) external virtual returns (uint256 amount);

    /*///////////////////////////////////////////////////////////////
                            View Functions
    //////////////////////////////////////////////////////////////*/

    function totalAssets() external view virtual returns (uint256);

    function assetsOf(address user) external view virtual returns (uint256);

    function assetsPerShare() external view virtual returns (uint256);

    function maxDeposit(address) external virtual returns (uint256);

    function maxMint(address) external virtual returns (uint256);

    function maxRedeem(address user) external view virtual returns (uint256);

    function maxWithdraw(address user) external view virtual returns (uint256);

    /**
      @notice Returns the amount of vault tokens that would be obtained if depositing a given amount of underlying tokens in a `deposit` call.
      @param underlyingAmount the input amount of underlying tokens
      @return shareAmount the corresponding amount of shares out from a deposit call with `underlyingAmount` in
     */
    function previewDeposit(uint256 underlyingAmount) external view virtual returns (uint256 shareAmount);

    /**
      @notice Returns the amount of underlying tokens that would be deposited if minting a given amount of shares in a `mint` call.
      @param shareAmount the amount of shares from a mint call.
      @return underlyingAmount the amount of underlying tokens corresponding to the mint call
     */
    function previewMint(uint256 shareAmount) external view virtual returns (uint256 underlyingAmount);

    /**
      @notice Returns the amount of vault tokens that would be burned if withdrawing a given amount of underlying tokens in a `withdraw` call.
      @param underlyingAmount the input amount of underlying tokens
      @return shareAmount the corresponding amount of shares out from a withdraw call with `underlyingAmount` in
     */
    function previewWithdraw(uint256 underlyingAmount) external view virtual returns (uint256 shareAmount);

    /**
      @notice Returns the amount of underlying tokens that would be obtained if redeeming a given amount of shares in a `redeem` call.
      @param shareAmount the amount of shares from a redeem call.
      @return underlyingAmount the amount of underlying tokens corresponding to the redeem call
     */
    function previewRedeem(uint256 shareAmount) external view virtual returns (uint256 underlyingAmount);
}

interface AggregatorV3Interface {
    function getRate(
        address srcToken,
        address dstToken,
        bool useWrappers
    ) 
    external view returns (
        uint256 weightedRate
        );
}
interface IWETH9 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function totalSupply() external view returns (uint256);

    function approve(address guy, uint256 wad) external returns (bool);

    function transfer(address dst, uint256 wad) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function balanceOf(address user) external view returns (uint);
}

/// Deposit, Withdraw, Mint, Redeem exists for Stable.
/// Fund & Defund exists for Volatility.
/// All reserve asset accounting (WETH) is done inside of Stable Vault. There is only one accounting.
/// Preserves 4626 expected interface (eg vault mint/burn operating on one underlying).

contract StableVault is ERC20, IERC4626 {
    using SafeTransferLib for ERC20;
    uint256 public constant depositFee = 100; // 0.1% 
    uint256 public constant withdrawFee = 9000; // 99.0%
    uint256 public constant maxFloatFee = 10000; // 100%
    uint256 public volatilityBuffer;

    VolatileToken public immutable volatile;
    IWETH9 public immutable weth;
    AggregatorV3Interface internal immutable priceFeed;
    constructor() ERC20("Test USD Pay", "USDPAYt", 18) {
        volatile = new VolatileToken("External feeding", "WFOTAt", 18);
        weth = IWETH9(0xA3378bd30f9153aC12AFF64743841f4AFa29bC57);
        priceFeed = AggregatorV3Interface(0xfbD61B037C325b959c0F6A7e69D8f37770C2c550);
    }

    /*///////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Stablecoin
    /// Give WETH amount, get STABLE amount
    function deposit(uint256 wethIn, address to) public override returns (uint256 stableCoinAmount) {
        require((stableCoinAmount = previewDeposit(wethIn)) != 0, "ZERO_SHARES");
        require(weth.transferFrom(to, address(this), wethIn));
        _mint(to, stableCoinAmount);
        emit Deposit(to, address(this), wethIn, stableCoinAmount);
        afterDeposit(wethIn);
    }

    /// @notice Stablecoin
    /// Mint specific AMOUNT OF STABLE by giving WETH
    function mint(uint256 stableCoinAmount, address to) public override returns (uint256 wethIn) {
        require(weth.transferFrom(address(this), to, wethIn = previewMint(stableCoinAmount)));
        _mint(to, stableCoinAmount);
        emit Deposit(address(this), to, wethIn, stableCoinAmount);
        afterDeposit(wethIn);
    }

    /// @notice Stablecoin
    /// Withdraw from Vault underlying. Amount of WETH by burning equivalent amount of STABLECOIN
    function withdraw(
        uint256 amountReserve,
        address to,
        address from
    ) public override returns (uint256 wethOut) {
        uint256 allowed = allowance[from][msg.sender];
        if (msg.sender != from && allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amountReserve;
        wethOut = (previewWithdraw(amountReserve) * withdrawFee) / maxFloatFee;        
        _burn(from, amountReserve);
        emit Withdraw(from, to, amountReserve, wethOut);
        weth.transferFrom(address(this), msg.sender, wethOut);
    }

    /// @notice Stablecoin
    /// Redeem from Vault underlying. (WETH) equivalent to AMOUNTSTABLE
    function redeem(
        uint256 amountStable,
        address to,
        address from
    ) public override returns (uint256 wethOut) {
        uint256 allowed = allowance[from][msg.sender];
        if (msg.sender != from && allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amountStable;
        require((wethOut = previewRedeem(amountStable)) != 0, "ZERO_ASSETS");
        wethOut = (previewRedeem(amountStable) * withdrawFee) / maxFloatFee;
        _burn(from, amountStable);
        emit Withdraw(from, to, wethOut, amountStable);
        weth.transferFrom(address(this), msg.sender, wethOut);
    }

    /// @notice Volatility/Funding token
    /// Give amount of WETH, receive VolatilityToken
    function fund(uint256 volCoinAmount, address to) public returns (uint256 wethIn) {
        require(weth.transferFrom(msg.sender, address(this), wethIn = previewFund(volCoinAmount)));
        volatile.mint(to, volCoinAmount);
        volatilityBuffer += wethIn;
        emit Deposit(msg.sender, to, wethIn, volCoinAmount);
    }

    /// @notice Volatility/Funding token
    /// Redeem number of SHARES (VolToken) for WETH at current price (at loss or profit) + fees accrued
    function defund(
        uint256 volCoinAmount,
        address to,
        address from
    ) public returns (uint256 wethOut) {
        require((wethOut = previewDefund(volCoinAmount)) != 0, "ZERO_ASSETS");
        volatile.burn(to, volCoinAmount);
        volatilityBuffer -= wethOut;
        weth.transferFrom(address(this), msg.sender, wethOut);
        emit Withdraw(from, to, wethOut, volCoinAmount);
    }

    function previewFund(uint256 amount) public view returns (uint256 stableVaultShares) {
        return amount / getLatestPrice(); // AMOUNT / (ETH/USD)
    }

    /// @notice Volatility token
    /// The only function that claims yield from Vault
    /// https://jacob-eliosoff.medium.com/a-cheesy-analogy-for-people-who-find-usm-confusing-1fd5e3d73a79
    function previewDefund(uint256 amount) public view returns (uint256 wethOut) {
        uint256 sharesGrowth = amount * (volatilityBuffer * getLatestPrice()) / volatile.totalSupply();
        wethOut = sharesGrowth / getLatestPrice();
    }

    /// @notice Stablecoin
    /// Return how much STABLECOIN does user receive for AMOUNT of WETH
    function previewDeposit(uint256 amount) public view override returns (uint256 stableCoinAmount) {
        return getLatestPrice() * amount; // (ETH/USD) * AMOUNT
    }

    /// @notice Stablecoin
    /// Return how much WETH is needed to receive AMOUNT of STABLECOIN
    function previewMint(uint256 amount) public view override returns (uint256 stableCoinAmount) {
        return amount / getLatestPrice(); // AMOUNT / (ETH/USD)
    }

    /// @notice Stablecoin
    /// Return how much WETH to transfer by calculating equivalent amount of burn to given AMOUNT of WETH
    function previewWithdraw(uint256 amount) public view override returns (uint256 wethOut) {
        return getLatestPrice() * amount; // AMOUNT * (ETH/USD)
    }

    /// @notice Stablecoin
    /// Return how much WETH to transfer equivalent to given AMOUNT of STABLECOIN
    function previewRedeem(uint256 amount) public view override returns (uint256 wethOut) {
        return amount / getLatestPrice(); // AMOUNT / (ETH/USD)
    }

    /*///////////////////////////////////////////////////////////////
                         INTERNAL HOOKS LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Add fee from user WETH collateral to volatilityBuffer as FUNDers fee
    function afterDeposit(uint256 amount) internal {
        uint256 fee = (amount * depositFee) / maxFloatFee;
        volatilityBuffer += fee;
    }
    function beforeWithdraw(uint256 amount) internal {}

    /*///////////////////////////////////////////////////////////////
                        ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function totalAssets() public view override returns (uint256) {
        return weth.balanceOf(address(this));
    }

    function assetsOf(address user) public view override returns (uint256) {
        return balanceOf[user];
    }

    function volatileAssetsOf(address user) public view returns (uint256) {
        return volatile.balanceOf(user);
    }

    function assetsPerShare() public view override returns (uint256) {
        return previewRedeem(10**decimals);
    }

    function maxDeposit(address) public pure override returns (uint256) {
        return type(uint256).max;
    }

    function maxMint(address) public pure override returns (uint256) {
        return type(uint256).max;
    }

    function maxWithdraw(address user) public view override returns (uint256) {
        return assetsOf(user);
    }

    function maxRedeem(address user) public view override returns (uint256) {
        return balanceOf[user];
    }

    function getLatestPrice() public view returns (uint256) {
        (uint256 weightedRate) = priceFeed
            .getRate(0xA3378bd30f9153aC12AFF64743841f4AFa29bC57, 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56, true);
        return uint256(weightedRate);
    }
}