/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
pragma experimental ABIEncoderV2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        require(owner() == _msgSender(), "Ownable: Caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: New owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
}

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "SafeMath: ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "SafeMath: ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(
            y == 0 || (z = x * y) / y == x,
            "SafeMath: ds-math-mul-overflow"
        );
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

abstract contract EthReceiver {
    receive() external payable {
        // solhint-disable-next-line avoid-tx-origin
        require(msg.sender != tx.origin, "ETH deposit rejected");
    }
}

/// @notice Interface for get fee from partner
interface PartnerSuperLink {
    function PARTNER_FEE() external view returns (uint256);
}

/// @title Super Link for interact with AMM Pools with a best return value
/// @notice Any user can swap if meet requirements
contract SuperLink is Ownable, EthReceiver {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /// @notice Partner fee local pay for each swap (Use for C98 Finance only)
    uint256 public PARTNER_FEE = 80;
    /// @notice Protocol fee local pay for each swap
    uint256 public PROTOCOL_FEE = 10;
    uint256 private Percent = 10000;

    /// @notice constant variable for assembly code
    uint256 private constant _WETH =
        0x0000000000000000000000005545153CCFcA01fbd7Dd11C0b23ba694D9509A6F;
    uint256 private constant _WETH_DEPOSIT_CALL_SELECTOR_32 =
        0xd0e30db000000000000000000000000000000000000000000000000000000000;
    uint256 private constant _WETH_WITHDRAW_CALL_SELECTOR_32 =
        0x2e1a7d4d00000000000000000000000000000000000000000000000000000000;
    uint256 private constant _ERC20_TRANSFER_CALL_SELECTOR_32 =
        0xa9059cbb00000000000000000000000000000000000000000000000000000000;
    uint256 private constant _TRANSFER_FROM_CALL_SELECTOR_32 =
        0x23b872dd00000000000000000000000000000000000000000000000000000000;
    uint256 private constant _UNISWAP_PAIR_SWAP_CALL_SELECTOR_32 =
        0x022c0d9f00000000000000000000000000000000000000000000000000000000;

    /// @notice Set default C98 Finance as partner
    constructor(string memory _name) {
        setPartner(address(this), _name, true);
    }

    /// @notice Swap event for notice when user swap in SuperLink
    event Swap(
        address sender,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        uint256 protocolFee
    );

    /// @notice Set new partner into SuperLink
    event SetPartner(string name, address partner);
    /// @notice Notice when deactive old partner
    event DeactivePartner(string name, address partner);
    /// @notice Set partner fee event for notice when change partner fee
    event SetPartnerFee(uint256 _partnerFee);
    /// @notice Set protocol fe event for notice when change protocol fee
    event SetProtocolFee(uint256 _protocolFee);

    /// @notice Claim Partner Fee event for notice to the partner when user swap and using partner UI
    event ClaimPartnerFee(
        address partner,
        address tokenOut,
        uint256 partnerFee
    );

    /// @notice Swap Parameters required for swap in SuperLink
    /// `pools` Pool address used for swaps.
    /// `amountIn` First come amount to swap
    /// `tokenInOut` Use to determine in and out token in pools.
    /// `amountOut` Exact amount to return in each pools must matching with pool index.
    struct SwapParameter {
        address[] pools;
        uint256 amountIn;
        bool[] tokenInOut;
        uint256[] amountOut;
    }

    /// @notice Partner registration in SuperLink system
    /// `isActive` Active or Deactive partner.
    /// `name` Partner's name.
    /// `registrationTime` Partner's registration time
    struct Partner {
        bool isActive;
        string name;
        uint256 registrationTime;
    }

    mapping(address => Partner) public Partners;

    /// @notice Setting partner for SuperLink
    /// @param _partner Address partner
    /// @param _name Partner's name.
    /// @param _isActive Status of partner
    function setPartner(
        address _partner,
        string memory _name,
        bool _isActive
    ) public onlyOwner {
        Partner storage partner = Partners[_partner];

        if (!_isActive) {
            require(partner.isActive, "SuperLink: Partner already deactive");
            partner.isActive = false;
            emit DeactivePartner(_name, _partner);
        } else {
            // Update information
            partner.isActive = _isActive;
            partner.name = _name;
            partner.registrationTime = block.timestamp;
            emit SetPartner(_name, _partner);
        }
    }

    /// @notice Set protocol fee pay for each swap
    /// @param _protocolFee Fee system pay for each swap
    function setProtocolFee(uint256 _protocolFee) public onlyOwner {
        require(
            _protocolFee > 0,
            "SuperLink: Fee must be a positive number and greater than zero"
        );
        PROTOCOL_FEE = _protocolFee;
        emit SetProtocolFee(_protocolFee);
    }

    /// @notice Set partner fee pay for each swap
    /// @param _partnerFee Fee partner local pay for each swap (Use for C98 Finance only)
    function setPartnerFee(uint256 _partnerFee) public onlyOwner {
        require(
            _partnerFee > 0,
            "SuperLink: Fee must be a positive number and greater than zero"
        );
        PARTNER_FEE = _partnerFee;
        emit SetPartnerFee(_partnerFee);
    }

    /// @notice Claim protocol fee for each swap
    /// @param _amount Protocol fee pay for each swap
    /// @return Amount received after deducting protocol fee
    function claimProtocol(uint256 _amount) internal view returns (uint256) {
        require(
            _amount > 0,
            "SuperLink: Amount must be a positive number and greater than zero"
        );
        return _amount.sub(_amount.mul(PROTOCOL_FEE).div(Percent));
    }

    /// @notice Charge partner fee for each swap in SuperLink
    /// Use local variable PARTNER_FEE when same address with SuperLink (C98 Finance use this)
    /// Another partner address will use variable from PartnerSuperLink contract address
    /// @param _partner Partner address for charge fee (Must registration in SuperLink)
    /// @param _tokenOut Use this token for charge partner fee
    /// @param _amount Swap amount received from sender
    /// @return Amount to return to user after deducting fee
    function claimPartner(
        address _partner,
        address _tokenOut,
        uint256 _amount
    ) internal returns (uint256) {
        require(
            _amount > 0,
            "SuperLink: Amount must be a positive number and greater than zero"
        );

        if (Partners[_partner].isActive) {
            bool isSystemFee = _partner == address(this);

            uint256 claimPartnerFee = _amount
                .mul(
                    isSystemFee
                        ? PARTNER_FEE
                        : PartnerSuperLink(_partner).PARTNER_FEE()
                )
                .div(Percent);

            // Transfer fee to partner
            if (!isSystemFee) {
                transferMoney(_tokenOut, claimPartnerFee, _partner);
            }
            emit ClaimPartnerFee(_partner, _tokenOut, claimPartnerFee);
            return _amount.sub(claimPartnerFee);
        }
        return _amount;
    }

    /// @notice Transfer ERC20 token and Wrapped token like WETH or WBNB using assembly code
    /// @param _token Use this token for transfer
    /// @param _amount Amount to transfer
    /// @param _receiver Address to receive
    function transferMoney(
        address _token,
        uint256 _amount,
        address _receiver
    ) internal {
        assembly {
            let emptyPtr := mload(0x40)
            mstore(0x40, add(emptyPtr, 0xc0))

            function reRevert() {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }

            switch eq(_token, _WETH)
            case 0 {
                mstore(emptyPtr, _ERC20_TRANSFER_CALL_SELECTOR_32)
                mstore(add(emptyPtr, 0x4), _receiver)
                mstore(add(emptyPtr, 0x24), _amount)
                if iszero(call(gas(), _token, 0, emptyPtr, 0x44, 0, 0)) {
                    reRevert()
                }
            }
            default {
                mstore(emptyPtr, _WETH_WITHDRAW_CALL_SELECTOR_32)
                mstore(add(emptyPtr, 0x04), _amount)
                if iszero(call(gas(), _WETH, 0, emptyPtr, 0x24, 0, 0)) {
                    reRevert()
                }

                if iszero(call(gas(), _receiver, _amount, 0, 0, 0, 0)) {
                    reRevert()
                }
            }
        }
    }

    /// @notice Transfer from ERC20 token and Wrapped token like WETH or WBNB using assembly code
    /// @param _token Use this token for transfer from
    /// @param _amount Amount to transfer from
    /// @param _receiver Address to receive transfer from
    function onTransferFrom(
        address _token,
        uint256 _amount,
        address _receiver
    ) internal {
        assembly {
            function reRevert() {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }

            function revertWithReason(m, len) {
                mstore(
                    0,
                    0x08c379a000000000000000000000000000000000000000000000000000000000
                )
                mstore(
                    0x20,
                    0x0000002000000000000000000000000000000000000000000000000000000000
                )
                mstore(0x40, m)
                revert(0, len)
            }

            let emptyPtr := mload(0x40)
            mstore(0x40, add(emptyPtr, 0xc0))

            switch eq(_token, _WETH)
            case 0 {
                if callvalue() {
                    revertWithReason(
                        0x00000011696e76616c6964206d73672e76616c75650000000000000000000000,
                        0x55
                    ) // "Invalid sender msg.value"
                }

                mstore(emptyPtr, _TRANSFER_FROM_CALL_SELECTOR_32)
                mstore(add(emptyPtr, 0x4), caller())
                mstore(add(emptyPtr, 0x24), _receiver)
                mstore(add(emptyPtr, 0x44), _amount)
                if iszero(call(gas(), _token, 0, emptyPtr, 0x64, 0, 0)) {
                    reRevert()
                }
            }
            default {
                if iszero(eq(_amount, callvalue())) {
                    revertWithReason(
                        0x00000011696e76616c6964206d73672e76616c75650000000000000000000000,
                        0x55
                    ) // "Invalid sender msg.value"
                }

                mstore(emptyPtr, _WETH_DEPOSIT_CALL_SELECTOR_32)
                if iszero(call(gas(), _WETH, _amount, emptyPtr, 0x4, 0, 0)) {
                    reRevert()
                }

                mstore(emptyPtr, _ERC20_TRANSFER_CALL_SELECTOR_32)
                mstore(add(emptyPtr, 0x4), _receiver)
                mstore(add(emptyPtr, 0x24), _amount)
                if iszero(call(gas(), _WETH, 0, emptyPtr, 0x44, 0, 0)) {
                    reRevert()
                }
            }
        }
    }

    /// @notice Interaction with pool address to swap using assembly code
    /// @param _amount Amount to swap in pool.
    /// @param _pool Pool address used for swaps.
    /// @param _tokenInOut Use to determine in and out token in pools.
    /// @param _receiver Address to receive token after swap.
    function poolSwap(
        uint256 _amount,
        address _pool,
        bool _tokenInOut,
        address _receiver
    ) internal {
        assembly {
            let emptyPtr := mload(0x40)
            mstore(0x40, add(emptyPtr, 0xc0))

            function reRevert() {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
            mstore(emptyPtr, _UNISWAP_PAIR_SWAP_CALL_SELECTOR_32)

            switch iszero(_tokenInOut)
            case 0 {
                mstore(add(emptyPtr, 0x04), 0)
                mstore(add(emptyPtr, 0x24), _amount)
            }
            default {
                mstore(add(emptyPtr, 0x04), _amount)
                mstore(add(emptyPtr, 0x24), 0)
            }
            mstore(add(emptyPtr, 0x44), _receiver)
            mstore(add(emptyPtr, 0x64), 0x80)
            mstore(add(emptyPtr, 0x84), 0)
            if iszero(call(gas(), _pool, 0, emptyPtr, 0xa4, 0, 0)) {
                reRevert()
            }
        }
    }

    /// @notice Link swap in AMM protocol pair address using SmartRouter.
    /// @param _partner Partner address for charge fee (Must registration in SuperLink).
    /// @param _tokenIn Use this token for swap in.
    /// @param _tokenOut Use this token for receive out.
    /// @param swapList List Swap Parameters required for swap in SuperLink
    function swap(
        address _partner,
        address _tokenIn,
        address _tokenOut,
        SwapParameter[] calldata swapList
    ) public payable {
        uint256 sizeSwap = swapList.length;
        uint256 totalOutputAmount = 0;
        uint256 totalInAmount = 0;

        // Check current balance of SuperLink before swap
        uint256 currentBalance = IERC20(_tokenOut).balanceOf(address(this));

        for (uint256 i = 0; i < sizeSwap; i++) {
            SwapParameter calldata swapSelected = swapList[i];
            uint256 sizePool = swapSelected.pools.length;

            totalOutputAmount = totalOutputAmount.add(
                swapSelected.amountOut[sizePool - 1]
            );

            for (uint256 k = 0; k < sizePool; k++) {
                bool isLastPool = k == (sizePool - 1);
                address pool = swapSelected.pools[k];

                if (k == 0) {
                    onTransferFrom(_tokenIn, swapSelected.amountIn, pool);
                    totalInAmount = totalInAmount.add(swapSelected.amountIn);
                }

                poolSwap(
                    swapSelected.amountOut[k],
                    pool,
                    swapSelected.tokenInOut[k],
                    isLastPool ? address(this) : swapSelected.pools[k + 1]
                );
            }
        }

        uint256 currentBalanceAfter = IERC20(_tokenOut).balanceOf(
            address(this)
        );

        // Double check for security check
        require(
            currentBalanceAfter.sub(currentBalance) >= totalOutputAmount,
            "SuperLink: Amount must be matching with total output amount"
        );

        // Claim system fee for each swap
        uint256 protocolFee = claimProtocol(totalOutputAmount);
        uint256 returnAmount = claimPartner(_partner, _tokenOut, protocolFee);

        // Return claim amount to user
        transferMoney(_tokenOut, returnAmount, msg.sender);
        emit Swap(
            msg.sender,
            _tokenIn,
            _tokenOut,
            totalInAmount,
            returnAmount,
            protocolFee
        );
    }

    /// @notice Withdraw all token and main token
    /// @param tokens The token contract that want to withdraw
    function withdrawMultiple(address[] calldata tokens) public onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == address(0)) {
                payable(msg.sender).transfer(address(this).balance);
            } else {
                IERC20 token = IERC20(tokens[i]);

                uint256 tokenBalance = token.balanceOf(address(this));
                if (tokenBalance > 0) {
                    token.safeTransfer(msg.sender, tokenBalance);
                }
            }
        }
    }
}