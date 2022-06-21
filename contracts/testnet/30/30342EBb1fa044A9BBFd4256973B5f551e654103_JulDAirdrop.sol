//SPDX-License-Identifier: LICENSED
pragma solidity ^0.7.0;
import "./MultiSigOwner.sol";
import "./libraries/SafeMath.sol";
import "./libraries/TransferHelper.sol";
import "./interfaces/ERC20Interface.sol";

contract JulDAirdrop is MultiSigOwner {
    using SafeMath for uint256;
    uint256 public depositStartDate;
    uint256 public depositEndDate;
    uint256 public withdrawStartDate;
    uint256 public withdrawDuration;
    address public JulDAddress;
    address public OkseAddress;
    uint256 public swapRate; // 250/1000
    bool public adminDeposited;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    mapping(address => uint256) public userBalances;
    mapping(address => uint256) public userWithdrawAmounts;
    mapping(address => bool) public userWithdrawedJulD;

    event UserDeposit(address userAddress, uint256 amount);
    event UserWithdraw(address userAddress, uint256 amount);
    event UserWithdrawedJuld(address userAddress, uint256 amount);

    event AdminDeposit(address adminAddress, uint256 amount);
    event AdminBurn(address adminAddress, uint256 amount);
    event AddressUpdated(address juldAddress, address okseAddress);
    event TimesAndSwapRateUpdated(
        uint256 depositStartDate,
        uint256 depositEndDate,
        uint256 withdrawStartDate,
        uint256 withdrawDuration,
        uint256 swapRate
    );

    modifier depositEnable() {
        uint256 curTime = block.timestamp;
        require(
            curTime >= depositStartDate && curTime < depositEndDate,
            "deposit not allowed now"
        );
        _;
    }
    modifier withdrawEnable() {
        uint256 curTime = block.timestamp;
        require(
            curTime >= withdrawStartDate && curTime < getWithdrawEndDate(),
            "withdraw not allowed now"
        );
        _;
    }
    modifier juldWithdrawEnable(address userAddress) {
        uint256 curTime = block.timestamp;
        require(curTime > depositEndDate, "juld withdraw not allowed now");
        require(!userWithdrawedJulD[userAddress], "already withdrawed juld");
        _;
    }

    modifier adminBurnEnable() {
        uint256 curTime = block.timestamp;
        require(curTime > getWithdrawEndDate(), "burn not allowed now");
        _;
    }
    modifier adminDepositEnable() {
        uint256 curTime = block.timestamp;
        require(
            curTime >= depositEndDate && curTime < withdrawStartDate,
            "admin deposit not allowed now"
        );
        require(!adminDeposited, "already deposited");
        _;
    }
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "rc");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    constructor() {
        _status = _NOT_ENTERED;

        depositStartDate = 1656633600; // 01/07/2022 : 00/00/00
        depositEndDate = 1659312000; // 01/08/2022 : 00/00/00
        withdrawStartDate = 1661990400; // 01/09/2022 : 00/00/00
        withdrawDuration = 94608000; // 36 monthes
        JulDAddress = 0x5A41F637C3f7553dBa6dDC2D3cA92641096577ea;
        OkseAddress = 0x606FB7969fC1b5CAd58e64b12Cf827FB65eE4875;
        swapRate = 250; // 250/1000
    }

    function deposit(uint256 amount) external nonReentrant depositEnable {
        address userAddress = msg.sender;
        TransferHelper.safeTransferFrom(
            JulDAddress,
            userAddress,
            address(this),
            amount
        );
        userBalances[userAddress] = userBalances[userAddress].add(amount);
        emit UserDeposit(userAddress, amount);
    }

    function withdraw() external nonReentrant withdrawEnable {
        address userAddress = msg.sender;
        uint256 amount = getWidrawableAmount(userAddress);
        uint256 okseBalance = ERC20Interface(OkseAddress).balanceOf(
            address(this)
        );
        require(okseBalance >= amount, "not enough okse");
        TransferHelper.safeTransfer(OkseAddress, userAddress, amount);
        userWithdrawAmounts[userAddress] = userWithdrawAmounts[userAddress].add(
            amount
        );
        emit UserWithdraw(userAddress, amount);
    }

    function withdrawJulD()
        external
        nonReentrant
        juldWithdrawEnable(msg.sender)
    {
        address userAddress = msg.sender;
        uint256 amount = userBalances[userAddress];
        uint256 juldBalance = ERC20Interface(JulDAddress).balanceOf(
            address(this)
        );
        require(juldBalance >= amount, "not enough juld");
        TransferHelper.safeTransfer(JulDAddress, userAddress, amount);
        userWithdrawedJulD[userAddress] = true;
        emit UserWithdrawedJuld(userAddress, amount);
    }

    function adminDeposit(bytes calldata signData, bytes calldata keys)
        external
        nonReentrant
        adminDepositEnable
        validSignOfOwner(signData, keys, "adminDeposit")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        uint256 amount = abi.decode(params, (uint256));

        address userAddress = msg.sender;
        TransferHelper.safeTransferFrom(
            OkseAddress,
            userAddress,
            address(this),
            amount
        );
        adminDeposited = true;
        emit AdminDeposit(userAddress, amount);
    }

    function adminBurnRemained(bytes calldata signData, bytes calldata keys)
        external
        nonReentrant
        adminBurnEnable
        validSignOfOwner(signData, keys, "adminBurnRemained")
    {
        address DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
        uint256 amount = ERC20Interface(OkseAddress).balanceOf(address(this));
        TransferHelper.safeTransfer(OkseAddress, DEAD_ADDRESS, amount);
    }

    function setTimesAndSwapRate(bytes calldata signData, bytes calldata keys)
        external
        nonReentrant
        validSignOfOwner(signData, keys, "setTimesAndSwapRate")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );

        (
            uint256 _depositStartDate,
            uint256 _depositEndDate,
            uint256 _withdrawStartDate,
            uint256 _withdrawDuration,
            uint256 _swapRate
        ) = abi.decode(params, (uint256, uint256, uint256, uint256, uint256));
        require(_depositEndDate > _depositStartDate, "deposit time invalid");
        require(
            _withdrawStartDate > _depositEndDate,
            "withdraw start time invalid"
        );
        require(
            _depositEndDate.add(_withdrawDuration) > _withdrawStartDate,
            "withdraw duration invalid"
        );
        depositStartDate = _depositStartDate;
        depositEndDate = _depositEndDate;
        withdrawStartDate = _withdrawStartDate;
        withdrawDuration = _withdrawDuration;
        swapRate = _swapRate;
        emit TimesAndSwapRateUpdated(
            depositStartDate,
            depositEndDate,
            withdrawStartDate,
            withdrawDuration,
            swapRate
        );
    }

    function setTokenAddress(bytes calldata signData, bytes calldata keys)
        external
        nonReentrant
        validSignOfOwner(signData, keys, "setTokenAddress")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );

        (address _JulDAddress, address _OkseAddress) = abi.decode(
            params,
            (address, address)
        );

        JulDAddress = _JulDAddress;
        OkseAddress = _OkseAddress;
        emit AddressUpdated(JulDAddress, OkseAddress);
    }

    function getBlockTime() public view returns (uint256) {
        return block.timestamp;
    }

    function getWithdrawEndDate() public view returns (uint256) {
        return depositEndDate.add(withdrawDuration);
    }

    function getWidrawableAmount(address userAddress)
        public
        view
        returns (uint256)
    {
        uint256 curTime = block.timestamp;
        if (curTime < withdrawStartDate) return 0;
        if (curTime >= getWithdrawEndDate()) return 0;
        uint256 amount = userBalances[userAddress];
        amount = amount.mul(swapRate).div(1000);
        amount = amount.mul(curTime.sub(depositEndDate)).div(withdrawDuration);
        amount = amount.sub(userWithdrawAmounts[userAddress]);
        return amount;
    }
}

// SPDX-License-Identifier: LICENSED
pragma solidity ^0.7.0;
pragma abicoder v2;

// 2/3 Multi Sig Owner
contract MultiSigOwner {
    address[] public owners;
    mapping(uint256 => bool) public signatureId;
    bool private initialized;
    // events
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event SignValidTimeChanged(uint256 newValue);
    modifier validSignOfOwner(
        bytes calldata signData,
        bytes calldata keys,
        string memory functionName
    ) {
        require(isOwner(msg.sender), "on");
        address signer = getSigner(signData, keys);
        require(
            signer != msg.sender && isOwner(signer) && signer != address(0),
            "is"
        );
        (bytes4 method, uint256 id, uint256 validTime, ) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        require(
            signatureId[id] == false &&
                method == bytes4(keccak256(bytes(functionName))),
            "sru"
        );
        require(validTime > block.timestamp, "ep");
        signatureId[id] = true;
        _;
    }

    function isOwner(address addr) public view returns (bool) {
        bool _isOwner = false;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == addr) {
                _isOwner = true;
            }
        }
        return _isOwner;
    }

    constructor() {}

    function initializeOwners(address[3] memory _owners) public {
        require(
            !initialized &&
                _owners[0] != address(0) &&
                _owners[1] != address(0) &&
                _owners[2] != address(0),
            "ai"
        );
        owners = [_owners[0], _owners[1], _owners[2]];
        initialized = true;
    }

    function getSigner(bytes calldata _data, bytes calldata keys)
        public
        view
        returns (address)
    {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        (uint8 v, bytes32 r, bytes32 s) = abi.decode(
            keys,
            (uint8, bytes32, bytes32)
        );
        return
            ecrecover(
                toEthSignedMessageHash(
                    keccak256(abi.encodePacked(this, chainId, _data))
                ),
                v,
                r,
                s
            );
    }

    function encodePackedData(bytes calldata _data)
        public
        view
        returns (bytes32)
    {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return keccak256(abi.encodePacked(this, chainId, _data));
    }

    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    // Set functions
    // verified
    function transferOwnership(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "transferOwnership")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        address newOwner = abi.decode(params, (address));
        uint256 index;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == msg.sender) {
                index = i;
            }
        }
        address oldOwner = owners[index];
        owners[index] = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    return add(a, b, "SafeMath: addition overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, errorMessage);

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

library TransferHelper {
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
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
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
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
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
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

interface ERC20Interface {
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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity >=0.6.0 <0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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