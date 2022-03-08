/**
 *Submitted for verification at BscScan.com on 2022-03-08
*/

// SPDX-License-Identifier: GPL-3.0-only AND AGPL-3.0-only
pragma solidity >=0.8.10;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
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

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

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

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

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
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

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

    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
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

        if (allowed != type(uint256).max)
            allowance[from][msg.sender] = allowed - amount;

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
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            spender,
                            value,
                            nonces[owner]++,
                            deadline
                        )
                    )
                )
            );

            address recoveredAddress = ecrecover(digest, v, r, s);

            require(
                recoveredAddress != address(0) && recoveredAddress == owner,
                "INVALID_SIGNER"
            );

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return
            block.chainid == INITIAL_CHAIN_ID
                ? INITIAL_DOMAIN_SEPARATOR
                : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
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

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Gnosis (https://github.com/gnosis/gp-v2-contracts/blob/main/src/contracts/libraries/GPv2SafeERC20.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
library SafeTransferLib {
    /*///////////////////////////////////////////////////////////////
                            ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool callStatus;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            callStatus := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(callStatus, "ETH_TRANSFER_FAILED");
    }

    /*///////////////////////////////////////////////////////////////
                           ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool callStatus;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata to memory piece by piece:
            mstore(
                freeMemoryPointer,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            ) // Begin with the function selector.
            mstore(
                add(freeMemoryPointer, 4),
                and(from, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Mask and append the "from" argument.
            mstore(
                add(freeMemoryPointer, 36),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it succeeded or not.
            // We use 100 because the calldata length is 4 + 32 * 3.
            callStatus := call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)
        }

        require(
            didLastOptionalReturnCallSucceed(callStatus),
            "TRANSFER_FROM_FAILED"
        );
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool callStatus;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata to memory piece by piece:
            mstore(
                freeMemoryPointer,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            ) // Begin with the function selector.
            mstore(
                add(freeMemoryPointer, 4),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it succeeded or not.
            // We use 68 because the calldata length is 4 + 32 * 2.
            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(
            didLastOptionalReturnCallSucceed(callStatus),
            "TRANSFER_FAILED"
        );
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool callStatus;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata to memory piece by piece:
            mstore(
                freeMemoryPointer,
                0x095ea7b300000000000000000000000000000000000000000000000000000000
            ) // Begin with the function selector.
            mstore(
                add(freeMemoryPointer, 4),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it succeeded or not.
            // We use 68 because the calldata length is 4 + 32 * 2.
            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "APPROVE_FAILED");
    }

    /*///////////////////////////////////////////////////////////////
                         INTERNAL HELPER LOGIC
    //////////////////////////////////////////////////////////////*/

    function didLastOptionalReturnCallSucceed(bool callStatus)
        private
        pure
        returns (bool success)
    {
        assembly {
            // Get how many bytes the call returned.
            let returnDataSize := returndatasize()

            // If the call reverted:
            if iszero(callStatus) {
                // Copy the revert message into memory.
                returndatacopy(0, 0, returnDataSize)

                // Revert with the same message.
                revert(0, returnDataSize)
            }

            switch returnDataSize
            case 32 {
                // Copy the return data into memory.
                returndatacopy(0, 0, returnDataSize)

                // Set success to whether it returned true.
                success := iszero(iszero(mload(0)))
            }
            case 0 {
                // There was no return data.
                success := 1
            }
            default {
                // It returned some malformed input.
                success := 0
            }
        }
    }
}

/// @notice Minimalist and modern Wrapped Ether implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/WETH.sol)
/// @author Inspired by WETH9 (https://github.com/dapphub/ds-weth/blob/master/src/weth9.sol)
contract WETH is ERC20("Wrapped Ether", "WETH", 18) {
    using SafeTransferLib for address;

    event Deposit(address indexed from, uint256 amount);

    event Withdrawal(address indexed to, uint256 amount);

    function deposit() public payable virtual {
        _mint(msg.sender, msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public virtual {
        _burn(msg.sender, amount);

        emit Withdrawal(msg.sender, amount);

        msg.sender.safeTransferETH(amount);
    }

    receive() external payable virtual {
        deposit();
    }
}

/// @title AbacusV0. The on-chain logic to trustlessly swap tokens through DEXbot (https://dexbot.io/).
/// @author 0xKitsune (https://github.com/0xKitsune)
/// @notice This contract enables DEXbot and other off-chain automated transaction curators to create swaps trustlessly while extracting a fee for off-chain services.
/// @notice In plain english, DEXbot is an automated way to sell your tokens. This contract allows DEXbot's off-chain logic to create swap transactions and return the payout to the msg.sender trustlessly.
/// @dev The DEXbot client source code is open source. You can check out how it works or read the whitepaper here: (https://github.com/DEXbotLLC/DEXbot_Client).
contract AbacusV0 {
    /// @notice The EOA address that owns the contract. This is set to the msg.sender initially at deployment. In this contract, the _owner can only add/remove custom fees for specific wallets or transfer ownership of the contract.
    address private _owner;

    /// @notice Wrapped native token (WNATO) address for the chain. This address will change depending on the chain the contract is deployed to (Ex. WETH for Ethereum L1, WMATIC for Polygon, WBNB for BSC).
    address public wnatoAddress;

    /// @notice Wrapped ETH contract instance to unwrap WETH to ETH. While this variable is named WETH, it could be any native token depending on the chain the contract is deployed to (Ex. WETH for Ethereum L1, WMATIC for Polygon, WBNB for BSC).
    WETH private _wnato;

    /// @notice Boolean to toggle during function execution to protect against reentrancy
    bool private _entered;

    /// @notice After a swap transaction is completed, a small fee is subtracted from the amountOut. This fee is for the off-chain logic/computations to curate automated swap transactions for an externally owned wallet EOA.
    /// @notice During the fee calculation, this value is divided by 1000 to effectively multiply by a decimal (Ex. If abacusFeeMul1000 is 25, then amountOut*(abacusFeeMul1000/1000) is equivalent to amountOut*.025).
    uint256 public constant ABACUS_FEE_MUL_1000 = 25;

    /// @notice The maximum abacus fee that can be set.
    /// @notice The max fee is 3% and the abacus fee can never be set above this value.
    /// @notice This value is divided by 1000 during calculations so with the maximum fee being 30, it can be expressed during calculations as MAX_ABACUS_FEE_MUL_1000/1000 which equals 30/1000 or .03 or 3%.
    /// @dev In future versions of the contract, the abacus fee will be able to change which is the reason for the max fee. In the V0, it will be set as a constant to 25.
    uint256 constant MAX_ABACUS_FEE_MUL_1000 = 30;

    /// @notice Mapping to hold custom abacus fees for specific externally owned wallets to reduce fees for that wallet. Mapping is abi.encode(msg.sender, tokenAddress) -> custom fee
    mapping(bytes => uint256) public customFees;

    /// @notice Constructor to initialize the contract on deployment.
    /// @param _wnatoAddress The wrapped native token address (Ex. WETH for Ethereum L1, WMATIC for Polygon, WBNB for BSC).
    constructor(address _wnatoAddress) {
        /// @notice Set the owner of the contract to the msg.sender that deployed the contract.
        _owner = msg.sender;

        /// @notice Initialize the wrapped native token address for the chain.
        wnatoAddress = _wnatoAddress;

        /// @notice Initialize the wrapped ETH contract instance with the wrapped native token address for the chain.
        _wnato = WETH(payable(_wnatoAddress));
    }

    /// @notice Modifier that checks if the msg.sender is the owner of the contract. The only functions that are set as onlyOwner() are setAbacusFee, setAbacusWallet and transferOwnership.
    modifier onlyOwner() {
        require(msg.sender == _owner, "!owner");
        _;
    }

    /// @notice Modifier to protect against reentrancy
    modifier reentrancyGuard() {
        require(!_entered, "reentrancy");
        _entered = true;
        _;
        _entered = false;
    }

    receive() external payable {}

    fallback() external payable {}

    /// @notice This function uses a UniV2 compatible router to swap a token for the wrapped native token, unwraps the native token and sends the amountOut minus the abacus fee back to the msg.sender.
    /// @param _lp is the v2 liquidity pool address for the _tokenIn and the wrapped native token for the chain.
    /// @param _amountIn is the exact amount of tokens you want to swap.
    /// @param _amountOutMin is the minimum amount of tokens you want resulting from the swap.
    /// @param _tokenIn is the address of the token that you want to swap from (Ex. When swapping from $LINK to $ETH, _tokenToSwap is the address for $LINK).
    /// @param _customAbacusFee boolean that tells the abacus to check for a custom fee. If false, the abacus will use the global abacus fee set during the deployment of the contract.

    function swapAndTransferUnwrappedNatoWithV2(
        address _lp,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _tokenIn,
        bool _customAbacusFee
    ) external reentrancyGuard {
        /// transfer the tokens to the lp
        ERC20(_tokenIn).transferFrom(msg.sender, _lp, _amountIn);

        //Sort the tokens
        (address token0, ) = sortTokens(_tokenIn, wnatoAddress);

        //Initialize the amount out depending on the token order
        (uint256 amount0Out, uint256 amount1Out) = _tokenIn == token0
            ? (uint256(0), _amountOutMin)
            : (_amountOutMin, uint256(0));

        //Get the wrapped nato token balance
        uint256 balanceBefore = _wnato.balanceOf(address(this));

        /// @notice Swap tokens for wrapped native tokens (nato).
        IUniswapV2Pair(_lp).swap(
            amount0Out,
            amount1Out,
            address(this),
            new bytes(0)
        );

        uint256 amountRecieved = _wnato.balanceOf(address(this)) -
            balanceBefore;

        //require that the amount receieved is >= the amountOutMin, else insufficient output amount
        require(amountRecieved >= _amountOutMin, "IOA");

        /// @notice The contract stores the native tokens so that the msg.sender does not have to pay for gas to unwrap WETH.
        /// @notice If the contract does not have enough of the native token to send the amountRecieved to the msg.sender, the unwrap function will be called on the contract balance.
        /// @dev This functionality is always trustless and will benefit the end user. When the contract has enough native tokens to send the amountRecieved, the end user does not incur the gas fees of unwrapping.
        /// @dev The contract can always send the amountRecieved even when it does not have enough native token balance. The contract will unwrap it's wrapped native tokens and then send the amountRecieved to the user.
        if (amountRecieved > address(this).balance) {
            /// @notice Unwrap the native token balance on the contract to supply the unwrapped native token
            _wnato.withdraw(_wnato.balanceOf(address(this)));
        }

        /// @notice Calculate the payout less abacus fee.
        uint256 payout = calculatePayoutLessAbacusFee(
            amountRecieved,
            _tokenIn,
            _customAbacusFee
        );

        /// @notice Send the payout (amount out less abacus fee) to the msg.sender
        SafeTransferLib.safeTransferETH(msg.sender, payout);
    }

    /// @notice This function uses a UniV2 compatible router to swap a token supporting fee on transfer tokens for the wrapped native token, unwraps the native token and sends the amountOut minus the abacus fee back to the msg.sender.
    /// @param _lp is the v2 liquidity pool address for the _tokenIn and the wrapped native token for the chain.
    /// @param _amountIn is the exact amount of tokens you want to swap.
    /// @param _amountOutMin is the minimum amount of tokens you want resulting from the swap.
    /// @param _tokenIn is the address of the token that you want to swap from (Ex. When swapping from $LINK to $ETH, _tokenToSwap is the address for $LINK).
    /// @param _customAbacusFee boolean that tells the abacus to check for a custom fee. If false, the abacus will use the global abacus fee set during the deployment of the contract.
    function swapAndTransferUnwrappedNatoSupportingFeeOnTransferTokensWithV2(
        address _lp,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _tokenIn,
        bool _customAbacusFee
    ) external reentrancyGuard {
        // transfer the tokens to the lp
        ERC20(_tokenIn).transferFrom(msg.sender, _lp, _amountIn);

        // //Sort the tokens
        (address token0, ) = sortTokens(_tokenIn, wnatoAddress);

        /// @dev It is necessary to get the wrapped native token balance before and after the swap because swapExactTokensForTokensSupportingFeeOnTransferTokens does not return the amountOut from the swap.
        uint256 balanceBefore = _wnato.balanceOf(address(this));

        /// @notice Swap tokens supporting fee on transfer tokens for wrapped native tokens (nato).
        uint256 amountInput;

        IUniswapV2Pair v2Pair = IUniswapV2Pair(_lp);
        {
            // scope to avoid stack too deep errors
            (uint256 reserve0, uint256 reserve1, ) = v2Pair.getReserves();
            (uint256 reserveInput, ) = _tokenIn == token0
                ? (reserve0, reserve1)
                : (reserve1, reserve0);
            amountInput =
                ERC20(_tokenIn).balanceOf(address(_lp)) -
                (reserveInput);
            // amountOutput = getAmountOut(amountInput, reserveInput, reserveOutput);
        }
        (uint256 amount0Out, uint256 amount1Out) = _tokenIn == token0
            ? (uint256(0), _amountOutMin)
            : (_amountOutMin, uint256(0));
        v2Pair.swap(amount0Out, amount1Out, address(this), new bytes(0));

        /// @dev Subtract the new balance of wrapped native tokens from the balance before to get the amountRecieved from the swap.
        uint256 amountRecieved = _wnato.balanceOf(address(this)) -
            balanceBefore;

        require(amountRecieved >= _amountOutMin, "IOA");

        /// @notice The contract stores the native tokens so that the msg.sender does not have to pay for gas to unwrap WETH.
        /// @notice If the contract does not have enough of the native token to send the amountRecieved to the msg.sender, the unwrap function will be called on the contract balance.
        /// @dev This functionality is always trustless and will benefit the end user. When the contract has enough native tokens to send the amountRecieved, the end user does not incur the gas fees of unwrapping.
        /// @dev The contract can always send the amountRecieved even when it does not have enough native token balance. The contract will unwrap it's wrapped native tokens and then send the amountRecieved to the user.
        if (amountRecieved > address(this).balance) {
            /// @notice Unwrap the native token balance on the contract to supply the unwrapped native token
            _wnato.withdraw(_wnato.balanceOf(address(this)));
        }

        /// @notice Calculate the payout less abacus fee.
        uint256 payout = calculatePayoutLessAbacusFee(
            amountRecieved,
            _tokenIn,
            _customAbacusFee
        );

        /// @notice Send the payout (amount out less abacus fee) to the msg.sender
        SafeTransferLib.safeTransferETH(msg.sender, payout);
    }

    /// @notice Function to calculate abacus fee amount.
    /// @dev The abacus fee is divided by 1000 when calculating the fee amount to effectively use float point calculations.
    function calculatePayoutLessAbacusFee(
        uint256 _amountOut,
        address _token,
        bool _customAbacusFee
    ) public view returns (uint256) {
        /// @notice If the address has a custom fee, use the custom fee in the payout calculation, otherwise, use the default abacusFee
        if (_customAbacusFee) {
            /// @notice get the custom fee for the user and calculate the payout
            uint256 customFeeMul1000 = customFees[
                abi.encode(msg.sender, _token)
            ];
            if (customFeeMul1000 == 0) {
                uint256 abacusFee = mulDiv(
                    _amountOut,
                    ABACUS_FEE_MUL_1000,
                    1000
                );
                return ((_amountOut - abacusFee));
            } else {
                uint256 abacusFee = mulDiv(_amountOut, customFeeMul1000, 1000);
                return ((_amountOut - abacusFee));
            }
        } else {
            uint256 abacusFee = mulDiv(_amountOut, ABACUS_FEE_MUL_1000, 1000);
            return ((_amountOut - abacusFee));
        }
    }

    /// @notice Function to set a custom abacus fee for specific wallet
    function setCustomAbacusFeeForEOA(
        address _address,
        address _token,
        uint256 _customFeeMul1000
    ) external onlyOwner {
        require(_customFeeMul1000 <= MAX_ABACUS_FEE_MUL_1000);
        customFees[abi.encode(_address, _token)] = _customFeeMul1000;
    }

    /// @notice Function to check if a wallet has a custom fee for a specific token
    /// @param _wallet The wallet address that the custom fee is for
    /// @param _token The token that the wallet address has a custom fee for.
    function checkForCustomFee(address _wallet, address _token)
        external
        view
        returns (bool)
    {
        uint256 customFeeMul1000 = customFees[abi.encode(_wallet, _token)];

        if (customFeeMul1000 != 0) {
            return true;
        } else {
            return false;
        }
    }

    /// @notice Function to set a custom abacus fee for specific wallet
    function removeCustomAbacusFeeFromEOA(address _address, address _token)
        external
        onlyOwner
    {
        delete customFees[abi.encode(_address, _token)];
    }

    /// @notice Function to withdraw profits in native tokens from the contract.
    /// @notice It is important to mention that this has no effect on the operability of the contract. Even if there is a contract balance of zero, the contract still functions normally, allowing for completely trustless swaps.
    function withdrawAbacusProfits(address _to, uint256 _amount)
        external
        onlyOwner
    {
        require(_amount <= address(this).balance, "amt>bal");
        SafeTransferLib.safeTransferETH(_to, _amount);
    }

    /// @notice Function to transfer ownership of the Abacus contract.
    function transferOwnership(address _newOwner) external onlyOwner {
        _owner = _newOwner;
    }

    ///@notice unwrap  native tokens stored in the contract (ex. WETH -> ETH)
    function unwrapWNATO(uint256 _amt) external onlyOwner {
        _wnato.withdraw(_amt);
    }

    /// @notice Returns sorted token addresses, used to handle return values from pairs sorted in this order. Code from the univ2library.
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    /// @notice Given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset. Code from the univ2library.
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure returns (uint256 amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + (amountInWithFee);
        amountOut = numerator / denominator;
    }

    /// @notice Function to calculate fixed point multiplication (from RariCapital/Solmate)
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            // Store x * y in z for now.
            z := mul(x, y)

            // Equivalent to require(denominator != 0 && (x == 0 || (x * y) / x == y))
            if iszero(
                and(
                    iszero(iszero(denominator)),
                    or(iszero(x), eq(div(z, x), y))
                )
            ) {
                revert(0, 0)
            }

            // Divide z by the denominator.
            z := div(z, denominator)
        }
    }
}

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