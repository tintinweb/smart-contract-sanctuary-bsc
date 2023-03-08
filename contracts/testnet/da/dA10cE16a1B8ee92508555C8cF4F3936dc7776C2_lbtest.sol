// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/LinkTokenInterface.sol";

import "./VRFRequestIDBase.sol";

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constuctor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator, _link) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash), and have told you the minimum LINK
 * @dev price for VRF service. Make sure your contract has sufficient LINK, and
 * @dev call requestRandomness(keyHash, fee, seed), where seed is the input you
 * @dev want to generate randomness from.
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomness method.
 *
 * @dev The randomness argument to fulfillRandomness is the actual random value
 * @dev generated from your seed.
 *
 * @dev The requestId argument is generated from the keyHash and the seed by
 * @dev makeRequestId(keyHash, seed). If your contract could have concurrent
 * @dev requests open, you can use the requestId to track which seed is
 * @dev associated with which randomness. See VRFRequestIDBase.sol for more
 * @dev details. (See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.)
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ. (Which is critical to making unpredictable randomness! See the
 * @dev next section.)
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the ultimate input to the VRF is mixed with the block hash of the
 * @dev block in which the request is made, user-provided seeds have no impact
 * @dev on its economic security properties. They are only included for API
 * @dev compatability with previous versions of this contract.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request.
 */
abstract contract VRFConsumerBase is VRFRequestIDBase {
  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBase expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomness the VRF output
   */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;

  /**
   * @dev In order to keep backwards compatibility we have kept the user
   * seed field around. We remove the use of it because given that the blockhash
   * enters later, it overrides whatever randomness the used seed provides.
   * Given that it adds no security, and can easily lead to misunderstandings,
   * we have removed it from usage and can now provide a simpler API.
   */
  uint256 private constant USER_SEED_PLACEHOLDER = 0;

  /**
   * @notice requestRandomness initiates a request for VRF output given _seed
   *
   * @dev The fulfillRandomness method receives the output, once it's provided
   * @dev by the Oracle, and verified by the vrfCoordinator.
   *
   * @dev The _keyHash must already be registered with the VRFCoordinator, and
   * @dev the _fee must exceed the fee specified during registration of the
   * @dev _keyHash.
   *
   * @dev The _seed parameter is vestigial, and is kept only for API
   * @dev compatibility with older versions. It can't *hurt* to mix in some of
   * @dev your own randomness, here, but it's not necessary because the VRF
   * @dev oracle will mix the hash of the block containing your request into the
   * @dev VRF seed it ultimately uses.
   *
   * @param _keyHash ID of public key against which randomness is generated
   * @param _fee The amount of LINK to send with the request
   *
   * @return requestId unique ID for this request
   *
   * @dev The returned requestId can be used to distinguish responses to
   * @dev concurrent requests. It is passed as the first argument to
   * @dev fulfillRandomness.
   */
  function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal immutable LINK;
  address private immutable vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 => uint256) /* keyHash */ /* nonce */
    private nonces;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   * @param _link address of LINK token contract
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */
  constructor(address _vrfCoordinator, address _link) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VRFRequestIDBase {
  /**
   * @notice returns the seed which is actually input to the VRF coordinator
   *
   * @dev To prevent repetition of VRF output due to repetition of the
   * @dev user-supplied seed, that seed is combined in a hash with the
   * @dev user-specific nonce, and the address of the consuming contract. The
   * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in
   * @dev the final seed, but the nonce does protect against repetition in
   * @dev requests which are included in a single block.
   *
   * @param _userSeed VRF seed input provided by user
   * @param _requester Address of the requesting contract
   * @param _nonce User-specific nonce at the time of the request
   */
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  ) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  /**
   * @notice Returns the id for this request
   * @param _keyHash The serviceAgreement ID to be used for this request
   * @param _vRFInputSeed The seed to be passed directly to the VRF
   * @return The id for this request
   *
   * @dev Note that _vRFInputSeed is not the seed passed by the consuming
   * @dev contract, but the one generated by makeVRFInputSeed
   */
  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import './utils/Address.sol';
import './utils/Ownable.sol';
// 
// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);
    
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
    using SafeMath for uint256;
    using Address for address;
    using SafeMath for int;

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
abstract contract ReentrancyGuard {
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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
}

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

interface IluckblocksNodes {
    function updateNodeInfoB(address caller, uint256 reward, uint weekly) external returns (bool);
    function getUserActivation(address _caller) external returns (bool);
    function activateNodes(address caller, uint256[] calldata _nodes , uint lottery,uint weekly) external;
    function resetQueue(uint lottery, uint weekly) external;
}

interface IluckblocksWeekly {
    function registerTickets(uint256 quantity,address player, uint256 amountInUSD,uint256 amountInToken) external returns (bool);
    function fillJackpot(uint256 amount) external returns (bool);
    function ForfeitTicket(address user) external returns (bool);

}

contract lbtest is VRFConsumerBase,ReentrancyGuard,Ownable {
	using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    uint256 contractBalance;
    uint256 nftnodeBalance;

    AggregatorV3Interface internal priceFeed;
     
    IluckblocksNodes internal lbNodes;
    IluckblocksWeekly internal lottoWeekly;

	// WBTC 	// USDC 
    IUniswapV2Router02 public uniswapRouter;
    
    uint256 stableDecimals = 6;

    // toggle to reset queue
    bool reset;

	IERC20 usd = IERC20(0x96F7e7fd1e17fe3a18d8B8b9CE6961fE7285baaB); // USDC
	IERC20 btc = IERC20(0x8BaBbB98678facC7342735486C851ABD7A0d17Ca); // BTC
    IERC20 krstm = IERC20(0x8a9424745056Eb399FD19a0EC26A14316684e274); // KRSTM

    address usdTrading = 0x96F7e7fd1e17fe3a18d8B8b9CE6961fE7285baaB;
    address btcTrading = 0x8BaBbB98678facC7342735486C851ABD7A0d17Ca;

    address platformAddress = 0x580a13BDdF2F29963C8E544D894569E4cA8f8FEe;
    address stakingContract = 0xb011909aB0eb93388DB35C339d11EcBC66CDA4A2;
    address weeklyContract;

    uint256 minimumPot = 20 * 10**stableDecimals;

    uint256 minimumPrize;

    bytes32 internal keyHash;
    uint256 internal fee; // (Varies by network);
    address internal VRFCoordinator;
    // 0.0001 * 10 ** 18

    mapping(uint256 => bytes32) public requestNumberIndexToRequestId;
    mapping(bytes32 => uint256) public requestIdToRequestNumberIndex;
    mapping(uint256 => uint256) public requestNumberIndexToRandomNumber;
    uint256 public requestCounter;

    mapping (uint => Ticket) public jackpotWinHistory;
    mapping (uint => uint) public numberOfPlayers;

    uint256 internal TICKET_VAL = 1 * 10**stableDecimals; //minimum amount (in wei) for getting registered on list
    uint256 internal KrstmPremium = 5 * 10**18; // Amount in KRSTM for discount

    uint256 prizeValueJackpot = 0; // 47.5% of ticket bought - added every new buy - filled by prizeValue
   

    uint256 lastAutoSpin;
    uint256 public houseTickets = 20;


	uint internal raffle; //number which picks the winner from registered List

    address internal lastWinner;

    struct Ticket {
        uint drawId;
        uint id;
        address owner;
        bool winner;
    }


    // Tickets mapping draw ID -> ticket ID -> ticket info 
    mapping (uint256 => mapping(uint256 => Ticket)) public ticketsHistory;

    // User Tickets mapping by draw - draw ID -> user address -> tickets IDs 
    mapping (uint256 => mapping(address => uint256[])) public userTickets;

    uint256[] public registeredsAccts;

    mapping(address => bool) gelatoWhitelist; //for gelato auto bets

	event LotteryLog(uint256 timestamp,address adrs, string message, uint256 amount);


    constructor() 
        VRFConsumerBase(0xa555fC018435bef5A13C6c6870a9d4C11DEC329C, // VRF Coordinator
        0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06 // LINK Token
        )
    {
		keyHash = 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186; // 0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da;
		fee = 0.10 * 10 ** 18; // 0.0001 * 10 ** 18;
        VRFCoordinator = 0xa555fC018435bef5A13C6c6870a9d4C11DEC329C; // 0x3d2341ADb2D31f1c5530cDC622016af293177AE0;

        IUniswapV2Router02 _uniswapRouter = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // (0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);
        
        uniswapRouter = _uniswapRouter;
        
        priceFeed = AggregatorV3Interface(0x5741306c21795FdCBb9b265Ea0255F499DFe515C); // (0xc907E116054Ad103354f2D350FD2514433D57F6f); // BTC/USD Price feed
        
        lottoWeekly = IluckblocksWeekly(0xc7A852A78dbaD037EaEa62C04b3216a2f1491cD5);
        weeklyContract = 0xc7A852A78dbaD037EaEa62C04b3216a2f1491cD5;

    }

    /**
     * Returns the latest price from chainlink oracle
     */
    function getLatestPrice() public view returns (uint256) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        require(timeStamp > 0, "Round not complete");
        return uint256(price) * 1e10;
    } 

    function getJackpotinUSD() public view returns (uint256) {
       uint256 tprice = getLatestPrice();

       uint256 result = ((prizeValueJackpot * 10**8) * tprice) / 10**18;

       return result / 10**12;
    } 

    function getJackpot() public view returns (uint256) {
 
       return prizeValueJackpot;

    } 

    function setStableAddress(address _usdAddress) public onlyOwner() {
        usd = IERC20(_usdAddress);
        usdTrading = _usdAddress;
        stableDecimals = IERC20(_usdAddress).decimals();
    }

    function setPlatform(address _platform) external onlyOwner() {
        platformAddress = _platform;
    }
    
    function setStaking(address _staking) external onlyOwner() {
        stakingContract = _staking;
    }
   
    function setNFTNode(address _contract) public onlyOwner() {
        lbNodes = IluckblocksNodes(_contract);
    }

    function setParentContract(address _weeklyContract) public onlyOwner() {
        weeklyContract = _weeklyContract;
    }

    function withdrawExcessBalance (uint256 amount) public onlyOwner() {
        require(amount <= contractBalance,"can't withdraw more than reserved balance");

        btc.safeTransfer(msg.sender,contractBalance);

        contractBalance -= contractBalance;

    }

    /**
     * @notice Change the fee
     * @param _fee: new fee (in LINK)
     */
    function setFee(uint256 _fee) external onlyOwner() {
        fee = _fee;
    }

    /**
     * @notice Change the keyHash
     * @param _keyHash: new keyHash
     */
    function setKeyHash(bytes32 _keyHash) external onlyOwner() {
        keyHash = _keyHash;
    }

    /**
     * @notice Change coordinator
     * @param _coordinator: new coordinator     */
    function setCoordinator(address _coordinator) external onlyOwner() {
        VRFCoordinator = _coordinator;
    }

    //In case of new router version
    function changeRouter(address _routerAddress) public onlyOwner() {
        
        IUniswapV2Router02 _uniswapRouter = IUniswapV2Router02(_routerAddress);
        
        uniswapRouter = _uniswapRouter;

    }

    /**
     * @notice Change the priceFeed
     * @param _priceFeed: new priceFeed
     */
    function setPriceFeed(address _priceFeed) external onlyOwner() {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // Decided by KRSTM DAO
    function setKRSTMPremium(uint256 _amountNeeded) public onlyOwner() {
        KrstmPremium = _amountNeeded;
    }

    // External && Internal Minimum Prize Raise
    function fillJackpot(uint256 amount) external {
        
        uint256 tprice = getLatestPrice();

        uint256 amountInToken = ((20 * 10**18 / tprice) * 10**18);  // 20 usd in token

        minimumPrize = amountInToken / 10**8;

        require(amount >= minimumPrize,"not enough amount - below 20 usd");
        require(btc.balanceOf(msg.sender) >= amount,"not enough balance");
        
        btc.safeTransferFrom(msg.sender,address(this),amount);
        contractBalance += amount;

        prizeValueJackpot += minimumPrize;
        contractBalance -= minimumPrize;
               
    }

    function accumulateJackpot(uint256 amount) internal {
        
        if(amount > minimumPrize){
         
         contractBalance += amount.mul(30).div(100);
         
         prizeValueJackpot = amount.mul(50).div(100);
        
         btc.safeTransfer(weeklyContract,amount.mul(20).div(100));
         
         lottoWeekly.fillJackpot(amount.mul(20).div(100));

        } else{
            if(contractBalance >= minimumPrize){
                prizeValueJackpot += minimumPrize;
                contractBalance -= minimumPrize;
            }
        }
               
    }

    //toggle if bets from gelato can be made
    function toggleGelato() public {
        if(gelatoWhitelist[msg.sender] == false){
          gelatoWhitelist[msg.sender] = true;
        }else{
          gelatoWhitelist[msg.sender] = false;
        }
    }
    
    function swapTokens(uint256 tokenAmount) private {
        // generate the swap pair path of tokens
        address[] memory path = new address[](2);
        path[0] = usdTrading;
        path[1] = btcTrading;

        usd.approve(address(uniswapRouter), tokenAmount);

        // make the swap
        uniswapRouter.swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount of Tokens out
            path,
            address(this), // The contract
            block.timestamp + 300
        );
    }

    function swapTokensToUSD(uint256 tokenAmount) private {
        // generate the swap pair path of tokens
        address[] memory path = new address[](2);
        path[0] = btcTrading;
        path[1] = usdTrading;

        btc.approve(address(uniswapRouter), tokenAmount);

        // make the swap
        uniswapRouter.swapTokensForExactTokens(
            tokenAmount,
            100000000000000000000, // to garantee the trade - 100 tokens
            path,
            address(this), // The contract
            block.timestamp + 300
        );
    }

    // Move the last element to the deleted spot.
    // Remove the last element.
    function clearRegisteredElement(uint index) internal {
        require(index < registeredsAccts.length);
        registeredsAccts[index] = registeredsAccts[registeredsAccts.length-1];
        registeredsAccts.pop();
    }

    function clearUserTicket(address user,uint256 drawId,uint256 ticketId) internal returns (bool) {
        for (uint256 i = 0; i < userTickets[drawId][user].length; i++) {
            if (userTickets[drawId][user][i] == ticketId) {
                // Found the value to delete, shift the rest of the array down
                for (uint256 j = i; j < userTickets[drawId][user].length - 1; j++) {
                    userTickets[drawId][user][j] = userTickets[drawId][user][j+1];
                }
                // Delete the last element, which is now a duplicate of the second-to-last element
                delete userTickets[drawId][user][userTickets[drawId][user].length - 1];
                // Reduce the length of the array by 1
                userTickets[drawId][user].pop();
                // Return true to indicate success
                return true;
            }
        }
        // Value not found, return false to indicate failure
        return false;
    }

    // Auto Spin
    function autoSpin(address _caller, uint256[] calldata _nodes) public nonReentrant {

        require(block.timestamp > lastAutoSpin + 86400);

         uint256 botReward = nftnodeBalance;


         if(getJackpotinUSD() >= minimumPot && registeredsAccts.length >= 25){ 

            if(lbNodes.getUserActivation(_caller) == false){
                lbNodes.activateNodes(_caller,_nodes,1,0);
            }

            if(block.timestamp > lastAutoSpin + 86700 && reset == false){    // if no node activates in 5 minutes period queue resets
                lbNodes.resetQueue(1,0);
                reset == true;
            } else if(lbNodes.updateNodeInfoB(_caller,botReward,0) == true){

                // Reward user that activates the function using NFTNode with rewards in usd
        
                usd.safeTransfer(_caller,botReward);
                reset == false;
                nftnodeBalance = 0;

                // Fires a new Draw
                getRandomNumber();  

                lastAutoSpin = block.timestamp;

            }

        } else{
            lastAutoSpin = block.timestamp;
        }
    }

    /** 
     * Requests randomness 
     */
    function getRandomNumber() internal returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract");
		requestId = requestRandomness(keyHash, fee);
        requestNumberIndexToRequestId[requestCounter] = requestId;
        requestIdToRequestNumberIndex[requestId] = requestCounter;
        requestCounter += 1;

        uint256 tprice = getLatestPrice();

        uint256 amountInToken = ((20 * 10**18 / tprice) * 10**18);  // 20 usd in token
        minimumPrize = amountInToken / 10**8;

    }


	 /** 
     * @notice Modifier to only allow updates by the VRFCoordinator contract
     */
    modifier onlyVRFCoordinator {
        require(msg.sender == VRFCoordinator, 'Fulfillment only allowed by VRFCoordinator');
        _;
    }


    // For multiple randomness
    function expand(uint256 randomValue, uint256 n) public pure returns (uint256[] memory expandedValues) {
        expandedValues = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            expandedValues[i] = uint256(keccak256(abi.encode(randomValue, i)));
        }
        return expandedValues;
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override onlyVRFCoordinator {
         
        uint256 randomNumbers = randomness;
        
        uint256 requestNumber = requestIdToRequestNumberIndex[requestId];
        requestNumberIndexToRandomNumber[requestNumber] = randomness;

        // number of players at the request - for provably fair
        numberOfPlayers[requestNumber] = registeredsAccts.length;

        raffle = randomNumbers % registeredsAccts.length;
	
        // Getting Raffle Winner Infos
        uint256 idInPosition = registeredsAccts[raffle];

        Ticket memory winnerTicket = ticketsHistory[requestNumber][idInPosition];

        address userWallet = winnerTicket.owner;
         
        lastWinner = userWallet;
        

        // Send Raffle Prize and reset tickets        
        if(raffle < 20){

            //Contract Wins - accumulate prize
            accumulateJackpot(prizeValueJackpot);
            
            emit LotteryLog(block.timestamp,lastWinner, "Contract Wins Prize Accumulate",prizeValueJackpot);

        } else { 
            
             btc.safeTransfer(lastWinner,prizeValueJackpot);


            emit LotteryLog(block.timestamp,lastWinner, "We have a new raffle Winner",prizeValueJackpot);
            
            prizeValueJackpot = 0;

        }
        // update ticket info
        winnerTicket.winner = true;
        ticketsHistory[requestNumber][idInPosition] = winnerTicket;    
        jackpotWinHistory[requestNumber] = winnerTicket;

        delete registeredsAccts;

        // Add 20 contract tickets
        for(uint index = 0; index < 20; index++){
        
            uint256 indexCheck = registeredsAccts.length;

            Ticket memory ticket = Ticket(requestCounter,indexCheck,address(this),false);
            
            ticketsHistory[requestCounter][indexCheck] = ticket;

            if (userTickets[requestCounter][address(this)].length == 0) {
                userTickets[requestCounter][address(this)] = new uint256[](0);
            }

            registeredsAccts.push(indexCheck);
            userTickets[requestCounter][address(this)].push(indexCheck);

        }

        // minimum prize value fill
        if(contractBalance >= minimumPrize){
            prizeValueJackpot += minimumPrize;
            contractBalance -= minimumPrize;
        }

    }

    // Play Function
    function BuyTicket(address player,uint quantity) public nonReentrant {
    
        require(player == msg.sender || msg.sender == 0x527a819db1eb0e34426297b03bae11F2f8B3A19E,"You can't buy ticket for other players");
            
        if(msg.sender == 0x527a819db1eb0e34426297b03bae11F2f8B3A19E){
            require(gelatoWhitelist[player] = true,"You have to whitelist gelato bets in the smart contract");
        }

        // > total allocation is 47.50% to dailly raffle () 5.00% to fee () 47.50% to jackpot weekly raffle -- discounts take out of weekly feed
        uint256 totalCost;
        uint256 dailyFeed; //47.5% of ticket value to pay raffle prize
        uint256 weeklyFeed;
        uint256 sustainingFee; // 5% of sustaining fee + ecosystem rewards + node rewards

        if(krstm.balanceOf(player) >= KrstmPremium){
            if(quantity > 10){
             totalCost = (TICKET_VAL.mul(75).div(100)).mul(quantity);
             weeklyFeed = totalCost.mul(225).div(1000); // 22.5%
            } else{
             totalCost = (TICKET_VAL.mul(80).div(100)).mul(quantity);    
             weeklyFeed = totalCost.mul(275).div(1000); // 27.5%
            }
        } else{
            if(quantity > 10){
             totalCost = (TICKET_VAL.mul(95).div(100)).mul(quantity);
             weeklyFeed = totalCost.mul(425).div(1000); // 42.5%
            } else{
             totalCost = TICKET_VAL.mul(quantity);
             weeklyFeed = totalCost.mul(475).div(1000); // 47.5%
            }
        }

        dailyFeed = totalCost.mul(475).div(1000);
        sustainingFee = totalCost.mul(5).div(100);
        uint256 nftnodeFee = sustainingFee.mul(2).div(100); // 2% of 5% - of sustainingFee - added every new buy, accumulated amount paid for the NFT owner on the draw
        uint256 platformFee = sustainingFee.mul(1).div(100); // 1% of 5% - platform fee
        uint256 lpstakingFee = sustainingFee.mul(2).div(100); // 2% of 5% - amount that goes for KRSTM-MATIC LP stakers

        require(usd.balanceOf(player) >= totalCost,"You don't have enough USD in the wallet!");   
                    

        usd.transferFrom(payable(player),address(this),totalCost - sustainingFee.mul(3).div(100));

        for(uint i = 0; i < quantity; i++){
       
            // Create Id based on position entry Daily
            uint256 indexCheck = registeredsAccts.length;

            Ticket memory ticket = Ticket(requestCounter,indexCheck,msg.sender,false);
            ticketsHistory[requestCounter][indexCheck] = ticket; 
            
            if (userTickets[requestCounter][msg.sender].length == 0) {
                userTickets[requestCounter][msg.sender] = new uint256[](0);
            }

            registeredsAccts.push(indexCheck);
            userTickets[requestCounter][msg.sender].push(indexCheck);

       }

        // update balances
         uint256 tprice = getLatestPrice();

         // register the weekly tickets
         usd.transferFrom(payable(player),weeklyContract,weeklyFeed);
         lottoWeekly.registerTickets(quantity,msg.sender,weeklyFeed,((weeklyFeed * 10**18 / tprice) * 10**18) / 10**10);

         swapTokens(totalCost - sustainingFee);
         
         usd.transferFrom(payable(player),stakingContract,lpstakingFee);
         usd.transferFrom(payable(player),platformAddress,platformFee);
         
         nftnodeBalance += nftnodeFee; 
         prizeValueJackpot += ((dailyFeed * 10**18 / tprice) * 10**18) / 10**10;

         emit LotteryLog(block.timestamp,player, "Ticket's Bought, Good luck!",totalCost);

    }
	
    // Data Fetch Functions
	function amountOfRegisters() public view returns(uint) {
		return registeredsAccts.length;
	}
	

    function getTicketPositions() external view returns(uint256[] memory) {
		
        return registeredsAccts;

	}

    function getUserTicketsByDraw(uint256 drawId,address userWallet) external view returns(uint256[] memory) {
		
        return userTickets[drawId][userWallet];

	}

	function currentJackpotInWei() public view returns(uint256) {
		return prizeValueJackpot * 10**10;
	}

	function autoSpinTimestamp() public view returns(uint256) {
		return lastAutoSpin;
	}


    // it will show winner address in that lottery id if the user has hit jackpot.
    function getJackpotWinnerByLotteryId(uint256 _requestCounter) public view returns (Ticket memory) {
        return jackpotWinHistory[_requestCounter];
    }
    
    function ourLastWinner() public view returns(address) {
        return lastWinner;
    }
	   
    // Users Forfeit Withdraw function get Back a % of ticket value
    function ForfeitTicket(uint256 index) public nonReentrant {
    
        Ticket memory trackedTicket = ticketsHistory[requestCounter][index];
        address owner = trackedTicket.owner;
        require(owner == msg.sender,"You are not the owner of that ticket!");
        require(getJackpotinUSD() >= 5 * 10**stableDecimals, "Contract need to have atleast 5 USD in value.");

        uint256 ticketPosition;

        for(uint i = 0; i < registeredsAccts.length; i++){
          
          uint256 idInPosition = registeredsAccts[i];
           
           if(idInPosition == index){
            ticketPosition = i;

            uint256 drawId = requestCounter;

            // Getting Registered user Info and Value
            uint256 refundValue;
                            
            refundValue = TICKET_VAL.mul(95).div(100);

            // Delete ticket from list   
            if(clearUserTicket(owner,drawId,trackedTicket.id)){       
            
                clearRegisteredElement(ticketPosition);
                lottoWeekly.ForfeitTicket(owner);
                // Refund user
                swapTokensToUSD(refundValue);
                usd.safeTransfer(payable(msg.sender),refundValue);
            
            }


          }  
        }            
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
        return functionCall(target, data, 'Address: low-level call failed');
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.4.0;

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
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}