/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// Dependency file: @openzeppelin/contracts/security/ReentrancyGuard.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.8.0;

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

    constructor() {
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


// Dependency file: @openzeppelin/contracts/utils/Address.sol


// pragma solidity ^0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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


// Dependency file: @openzeppelin/contracts/utils/Strings.sol


// pragma solidity ^0.8.0;

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


// Dependency file: @chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol

// pragma solidity ^0.8.0;

interface LinkTokenInterface {

  function allowance(
    address owner,
    address spender
  )
    external
    view
    returns (
      uint256 remaining
    );

  function approve(
    address spender,
    uint256 value
  )
    external
    returns (
      bool success
    );

  function balanceOf(
    address owner
  )
    external
    view
    returns (
      uint256 balance
    );

  function decimals()
    external
    view
    returns (
      uint8 decimalPlaces
    );

  function decreaseApproval(
    address spender,
    uint256 addedValue
  )
    external
    returns (
      bool success
    );

  function increaseApproval(
    address spender,
    uint256 subtractedValue
  ) external;

  function name()
    external
    view
    returns (
      string memory tokenName
    );

  function symbol()
    external
    view
    returns (
      string memory tokenSymbol
    );

  function totalSupply()
    external
    view
    returns (
      uint256 totalTokensIssued
    );

  function transfer(
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    returns (
      bool success
    );

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );

}


// Dependency file: @chainlink/contracts/src/v0.8/VRFRequestIDBase.sol

// pragma solidity ^0.8.0;

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
  )
    internal
    pure
    returns (
      uint256
    )
  {
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
  function makeRequestId(
    bytes32 _keyHash,
    uint256 _vRFInputSeed
  )
    internal
    pure
    returns (
      bytes32
    )
  {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

// Dependency file: @chainlink/contracts/src/v0.8/VRFConsumerBase.sol

// pragma solidity ^0.8.0;

// import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

// import "@chainlink/contracts/src/v0.8/VRFRequestIDBase.sol";

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
  function fulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    internal
    virtual;

  /**
   * @dev In order to keep backwards compatibility we have kept the user
   * seed field around. We remove the use of it because given that the blockhash
   * enters later, it overrides whatever randomness the used seed provides.
   * Given that it adds no security, and can easily lead to misunderstandings,
   * we have removed it from usage and can now provide a simpler API.
   */
  uint256 constant private USER_SEED_PLACEHOLDER = 0;

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
  function requestRandomness(
    bytes32 _keyHash,
    uint256 _fee
  )
    internal
    returns (
      bytes32 requestId
    )
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   * @param _link address of LINK token contract
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */
  constructor(
    address _vrfCoordinator,
    address _link
  ) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    external
  {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}


// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity ^0.8.0;

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


// Dependency file: @openzeppelin/contracts/utils/Context.sol


// pragma solidity ^0.8.0;

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


// Dependency file: @openzeppelin/contracts/access/Ownable.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// Dependency file: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

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


// Dependency file: @openzeppelin/contracts/security/Pausable.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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


// Dependency file: contracts/vrf/traits/PausableElement.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/security/Pausable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract PausableElement is Ownable, Pausable {
    /// @notice pause contract
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice unpause contract
    function unpause() external onlyOwner {
        _unpause();
    }
}


// Dependency file: contracts/vrf/traits/WithdrawalElement.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "@openzeppelin/contracts/security/Pausable.sol";
// import "contracts/vrf/traits/PausableElement.sol";

abstract contract WithdrawalElement is PausableElement {
    using SafeERC20 for IERC20;
    using Address for address;

    event WithdrawToken(address token, address recipient, uint256 amount);
    event Withdraw(address recipient, uint256 amount);

    /// @notice management function. Withdraw all tokens in emergency mode only when contract paused
    function withdrawToken(address _token, address _recipient) external virtual onlyOwner whenPaused {
        uint256 amount = IERC20(_token).balanceOf(address(this));

        _withdrawToken(_token, _recipient, amount);
        _afterWithdrawToken(_token, _recipient, amount);
    }

    /// @notice management function. Withdraw  some tokens in emergency mode only when contract paused
    function withdrawSomeToken(
        address _token,
        address _recipient,
        uint256 _amount
    ) public virtual onlyOwner whenPaused {
        _withdrawToken(_token, _recipient, _amount);
        _afterWithdrawToken(_token, _recipient, _amount);
    }

    ///@notice withdraw all BNB. Withdraw in emergency mode only when contract paused
    function withdraw() external virtual onlyOwner whenPaused {
        _withdraw(_msgSender(), address(this).balance);
    }

    ///@notice withdraw some BNB. Withdraw in emergency mode only when contract paused
    function withdrawSome(address _recipient, uint256 _amount) external virtual onlyOwner whenPaused {
        _withdraw(_recipient, _amount);
    }

    function _deliverFunds(
        address _recipient,
        uint256 _value,
        string memory _message
    ) internal {
        (bool sent, ) = payable(_recipient).call{value: _value}("");

        require(sent, _message);
    }

    function _deliverTokens(
        address _token,
        address _recipient,
        uint256 _value
    ) internal {
        IERC20(_token).safeTransfer(_recipient, _value);
    }

    function _withdraw(address _recipient, uint256 _amount) internal virtual {
        require(_recipient != address(0x0), "CryptoDrop Loto: address is zero");
        require(_amount <= address(this).balance, "CryptoDrop Loto: not enought BNB balance");

        _afterWithdraw(_recipient, _amount);

        _deliverFunds(_recipient, _amount, "CryptoDrop Loto: Can't send BNB");
        emit Withdraw(_recipient, _amount);
    }

    function _afterWithdraw(address _recipient, uint256 _amount) internal virtual {}

    function _withdrawToken(
        address _token,
        address _recipient,
        uint256 _amount
    ) internal virtual {
        require(_recipient != address(0x0), "CryptoDrop Loto: address is zero");
        require(_amount <= IERC20(_token).balanceOf(address(this)), "CryptoDrop Loto: not enought token balance");

        IERC20(_token).safeTransfer(_recipient, _amount);

        _afterWithdrawToken(_token, _recipient, _amount);
    }

    function _afterWithdrawToken(
        address _token,
        address _recipient,
        uint256 _amount
    ) internal virtual {}
}


// Dependency file: contracts/vrf/traits/JackpotElement.sol


// pragma solidity ^0.8.0;

// import "contracts/vrf/traits/WithdrawalElement.sol";

abstract contract JackpotElement is WithdrawalElement {
    using SafeERC20 for IERC20;
    using Address for address;

    uint256 public jackpotAmount;

    event Received(address sender, uint256 value);

    receive() external payable {}

    /// Receive BNB
    function addJackpot() external payable virtual onlyOwner {
        jackpotAmount += msg.value;
        emit Received(_msgSender(), msg.value);
    }

    function _afterWithdraw(address _recipient, uint256 _amount) internal override {
        if (_amount > jackpotAmount) {
            jackpotAmount = 0;
        } else {
            jackpotAmount -= _amount;
        }
    }
}


// Dependency file: contracts/vrf/traits/MiningElement.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract MiningElement is Ownable {
    using SafeERC20 for IERC20;

    address public baseToken;

    bool public isMiningAvailable;

    uint256 public miningAmount;

    mapping(address => uint256) public totalMined;

    mapping(address => mapping(address => uint256)) public miningBalances;

    event TokenMined(address indexed token, address indexed gamer, uint256 miningAmount);
    event UpdateMiningAmount(uint256 miningAmount);
    event UpdateBaseToken(address _baseToken);
    event SetIsMiningAvailable(bool _isMiningAvailable);

    function updateMiningAmount(uint256 _miningAmount) external onlyOwner {
        miningAmount = _miningAmount;
        emit UpdateMiningAmount(_miningAmount);
    }

    function updateBaseToken(address _baseToken) external onlyOwner {
        baseToken = _baseToken;
        isMiningAvailable = false;
        emit UpdateBaseToken(_baseToken);
    }

    function setIsMiningAvailable(bool _isMiningAvailable) external onlyOwner {
        require(baseToken != address(0x0), "base token is zero");

        isMiningAvailable = _isMiningAvailable;
        emit SetIsMiningAvailable(_isMiningAvailable);
    }

    function _initMiningElement(
        address _baseToken,
        uint256 _miningAmount,
        bool _isMiningAvailable
    ) internal virtual {
        baseToken = _baseToken;
        miningAmount = _miningAmount;
        isMiningAvailable = _isMiningAvailable;

        emit UpdateBaseToken(_baseToken);
        emit UpdateMiningAmount(_miningAmount);
        emit SetIsMiningAvailable(_isMiningAvailable);
    }

    function _mining(address _gamer) internal virtual {
        if (isMiningAvailable && IERC20(baseToken).balanceOf(address(this)) >= miningAmount) {
            IERC20(baseToken).safeTransfer(_gamer, miningAmount);

            totalMined[baseToken] += miningAmount;

            miningBalances[baseToken][_gamer] += miningAmount;

            emit TokenMined(baseToken, _gamer, miningAmount);
        }
    }

    function checkMiningAvailability() external view virtual returns(bool) {
        return (isMiningAvailable && IERC20(baseToken).balanceOf(address(this)) >= miningAmount);
    }
}


// Dependency file: contracts/vrf/traits/VRFElement.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
// import "contracts/vrf/traits/JackpotElement.sol";
// import "contracts/vrf/traits/MiningElement.sol";

abstract contract VRFElement is JackpotElement, MiningElement, ReentrancyGuard, VRFConsumerBase {
    using SafeERC20 for IERC20;
    using Address for address;

    address public storageAddress;
    address public teamAddress;
    address public committeeAddress;
    address public leaderboardAddress;

    uint256 internal constant PANCAKE_ROUTER_DEADLINE = 100000;

    bytes32 public keyHash;
    uint256 public linkFee;

    address public pegService;
    address public originLink;
    address public pancakeRouter;
    address public wBNB;
    bool initializedVRFElement;
    bool initializedMiningElement;

    event UpdateStorageAddress(address storageAddress);
    event UpdateTeamAddress(address teamAddress);
    event UpdateCommitteeAddress(address committeeAddress);
    event UpdateLeaderboardAddress(address leaderboardAddress);
    event UpdatePromoPeriod(uint256 promoPeriod);
    event UpdateLinkFee(uint256 linkFee);
    event UpdateKeyHash(bytes32 keyHash);
    event UpdatePegService(address pegService);
    event UpdateOriginLink(address originLink);
    event UpdatePancakeRouter(address router);

    function initMiningElement(
        address _baseToken,
        uint256 _miningAmount,
        bool _isMiningAvalable
    ) external onlyOwner {
        require(!initializedMiningElement, "Mining Element initialized");

        _initMiningElement(_baseToken, _miningAmount, _isMiningAvalable);

        initializedMiningElement = true;
    }

    function initVRFElement(
        bytes32 _keyHash,
        uint256 _linkFee,
        address _storageAddress,
        address _teamAddress,
        address _committeeAddress,
        address _leaderboardAddress,
        address _pegService,
        address _originLink,
        address _pancakeRouter,
        address _wBNB
    ) external onlyOwner {
        require(!initializedVRFElement, "VRF Element initialized");

        _initVRFElement(
            _keyHash,
            _linkFee,
            _storageAddress,
            _teamAddress,
            _committeeAddress,
            _leaderboardAddress,
            _pegService,
            _originLink,
            _pancakeRouter,
            _wBNB
        );

        initializedVRFElement = true;
    }

    function _initVRFElement(
        bytes32 _keyHash,
        uint256 _linkFee,
        address _storageAddress,
        address _teamAddress,
        address _committeeAddress,
        address _leaderboardAddress,
        address _pegService,
        address _originLink,
        address _pancakeRouter,
        address _wBNB
    ) internal virtual {
        keyHash = _keyHash;
        linkFee = _linkFee; // 0.1 * 10 ** 18;

        pegService = _pegService;
        originLink = _originLink;
        pancakeRouter = _pancakeRouter;
        wBNB = _wBNB;

        storageAddress = _storageAddress;
        teamAddress = _teamAddress;
        leaderboardAddress = _leaderboardAddress;
        committeeAddress = _committeeAddress;
    }

    ///@notice update address of storage contract
    ///@param _storageAddress storage contract address
    function updateStorageAddress(address _storageAddress) external onlyOwner {
        storageAddress = _storageAddress;

        emit UpdateStorageAddress(storageAddress);
    }

    ///@notice update team address
    ///@param _teamAddress team address
    function updateTeamAddress(address _teamAddress) external onlyOwner {
        teamAddress = _teamAddress;

        emit UpdateTeamAddress(teamAddress);
    }

    function updateCommitteeAddress(address _committeeAddress) external onlyOwner {
        committeeAddress = _committeeAddress;

        emit UpdateCommitteeAddress(committeeAddress);
    }

    function updateLeaderboardAddress(address _leaderboardAddress) external onlyOwner {
        leaderboardAddress = _leaderboardAddress;

        emit UpdateLeaderboardAddress(leaderboardAddress);
    }

    function updateLinkFee(uint256 _linkFee) external onlyOwner {
        linkFee = _linkFee;

        emit UpdateLinkFee(_linkFee);
    }

    function updateKeyHash(bytes32 _keyHash) external onlyOwner {
        keyHash = _keyHash;

        emit UpdateKeyHash(_keyHash);
    }

    function updatePegService(address _pegService) external onlyOwner {
        pegService = _pegService;
        emit UpdatePegService(_pegService);
    }

    function updateOriginLink(address _originLink) external onlyOwner {
        originLink = _originLink;
        emit UpdateOriginLink(_originLink);
    }

    function updatePancakeRouter(address _router) external onlyOwner {
        pancakeRouter = _router;
        emit UpdatePancakeRouter(_router);
    }

    function _getBlockHash(uint256 _randomness) internal view virtual returns (bytes32 _hash) {
        return keccak256(abi.encode(_randomness));
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual override {}

    function _buyLinkTokens(uint256 _vrfFee) internal virtual {
        //buy link
        address[] memory path = new address[](2);

        path[0] = wBNB;
        path[1] = originLink;

        (bool success, bytes memory data) = payable(pancakeRouter).call{value: _vrfFee}(
            abi.encodeWithSignature(
                "swapETHForExactTokens(uint256,address[],address,uint256)",
                linkFee,
                path,
                address(this),
                PANCAKE_ROUTER_DEADLINE + block.timestamp
            )
        );

        if (IERC20(originLink).balanceOf(address(this)) > 0) {
            IERC20(originLink).safeApprove(pegService, IERC20(originLink).balanceOf(address(this)));

            pegService.call(
                abi.encodeWithSignature("swap(uint256,address,address)", IERC20(originLink).balanceOf(address(this)), originLink, LINK)
            );

            IERC20(originLink).safeApprove(pegService, 0);
        }
    }
}


// Dependency file: contracts/vrf/traits/VRFElementRoundIdUint256.sol


// pragma solidity ^0.8.0;

// import "contracts/vrf/traits/VRFElement.sol";

abstract contract VRFElementRoundIdUint256 is VRFElement {
    struct RandomnessRequestData {
        uint256 roundId;
        address drawnBy;
        uint256 number;
        bool fullfilled;
    }

    mapping(bytes32 => RandomnessRequestData) randomnessRequests;

    event RefundVRFFee(uint256 id, uint256 amount, address gamer);

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual override {
        RandomnessRequestData storage data = randomnessRequests[requestId];

        require(!data.fullfilled, "VRF: request already processed");

        data.fullfilled = true;
        data.number = randomness;

        _processBetWithRandomness(data, randomness);
    }

    function _processBetWithRandomness(RandomnessRequestData storage _data, uint256 _randomness) internal virtual {}

    function _processVRFFee(
        uint256 _id,
        uint256 _vrfFee,
        address _gamer
    ) internal virtual {
        uint256 balanceBefore = address(this).balance;

        _buyLinkTokens(_vrfFee);

        uint256 balanceAfter = address(this).balance;

        if (balanceBefore > balanceAfter) {
            uint256 refund = _vrfFee - (balanceBefore - balanceAfter);

            _deliverFunds(_msgSender(), refund, "CryptoDrop V4: failed transfer BNB to Staking Storage");

            emit RefundVRFFee(_id, refund, _gamer);
        }
    }
}


// Dependency file: @openzeppelin/contracts/utils/structs/EnumerableSet.sol


// pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}


// Root file: contracts/test/TestDropHashLotteryV4.sol


pragma solidity ^0.8.0;

// import "contracts/vrf/traits/VRFElementRoundIdUint256.sol";
// import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract TestDropHashLotteryV4 is VRFElementRoundIdUint256 {
    // Add the library methods
    using EnumerableSet for EnumerableSet.AddressSet;

    using SafeERC20 for IERC20;
    using Address for address;

    address public platformAddress;

    //constants
    uint8 internal constant MATCH_BYTES = 3;
    uint8 internal constant SPECIAL_EVENT_MATCH_BYTES = 2;

    uint256 internal constant PRECISION = 1 ether;

    uint256 internal constant BET_AMOUNT = 10000 ether;
    uint256 internal constant DRAW_AMOUNT = 0.01 ether;

    uint256 internal constant TEAM_PERCENT = 10;
    uint256 internal constant COMMITTEE_PERCENT = 10;
    uint256 internal constant JACKPOT_PERCENT = 50;
    uint256 internal constant STORAGE_PERCENT = 15;
    uint256 internal constant BURN_PERCENT = 10;
    uint256 internal constant LEADERBOARD_PERCENT = 5;
    uint256 internal constant REWARD_PERCENT = 80;

    uint256 internal constant ROUND_LENGTH = 2700; //45 min;

    uint256 internal constant CLIFF_ROUND_LENGTH = 900; //15 min;

    uint256 internal constant DAY_LENGTH = 86400; //1 day
    uint256 internal constant VESTING_DAY_LENGTH = 90; //90 days vesting
    

    /*uint256 internal constant ROUND_LENGTH = 300; //5 min;

    uint256 internal constant CLIFF_ROUND_LENGTH = 180; //3 min;

    uint256 internal constant DAY_LENGTH = 600; // 10 min
    uint256 internal constant VESTING_DAY_LENGTH = 5; //5 days vesting, 5 parts
    */

    address internal constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    address public lotteryToken;

    uint256 public totalMiningSupply;

    struct Bet {
        uint256 blockNumber;
        uint256 roundId;
        uint256 amount;
        bytes hash;
        bytes32 hashMap;
    }

    struct Round {
        uint256 totalBets;
        uint256 numberOfBets;
        uint256 reward;
        bytes drawdHash;
        bytes32 hashMap;
        uint256 roundStarted;
        uint256 roundEnded;
        uint256 roundSettled;
        bytes32 requestId;
    }

    struct Win {
        uint256 reward;
        uint256 startVesting;
        uint256 claimed;
    }

    //user bets
    mapping(address => Bet[]) public bets;

    //rounds maps
    mapping(uint256 => mapping(bytes32 => EnumerableSet.AddressSet)) private roundMaps;

    //rounds
    mapping(uint256 => Round) public rounds;

    //user wins
    mapping(address => mapping(uint256 => Win)) public userWins;

    uint256 public lastRoundIndex;

    bool public isSpecialEventActivated;


    uint256 public betAmount;

    uint256 public rewardPercent;

    event ProcessBet(uint256 id, address gamer, uint256 amount, bytes hash, uint256 roundId, bytes32 hashMap);
    event DrawBet(
        uint256 blockNumber,
        uint256 roundId,
        address drawnBy,
        bytes drawnHash,
        bool isSpecialEvent,
        uint256 totalBets,
        uint256 rewards,
        uint256 numberOfWinners,
        bytes32 hashMap
    );
    event ClaimBet(uint256 roundId, address gamer, uint256 reward, uint256 claimed);
    event UpdatePlatformAddress(address platfromAddress);
    event UpdateLotteryToken(address lotteryToken);
    event UpdateSpecialEvent(bool isSpecialEventActivated);
    event IncreaseMiningSupply(uint256 amount, uint256 totalMiningSupply);
    event DecreaseMiningSupply(uint256 amount, uint256 totalMiningSupply);
    event ChangeBetAmount(uint256 betAmount);
    event ChangeRewardPercent(uint256 rewardPercent);
    event Removed(uint256 amount);

    constructor(address _vrfCoordinator, address _linkToken) VRFConsumerBase(_vrfCoordinator, _linkToken) {}

    function initHashLottery(
        address _platformAddress,
        address _lotteryToken,
        uint256 _initialRoundStart
    ) external onlyOwner {
        platformAddress = _platformAddress;
        lotteryToken = _lotteryToken;

        rounds[lastRoundIndex].roundStarted = _initialRoundStart;
        rounds[lastRoundIndex].roundEnded = _initialRoundStart + ROUND_LENGTH;

        betAmount = BET_AMOUNT;
        rewardPercent = REWARD_PERCENT;
    }

    /// @notice place bet or buy ticket for round. if previous bet is not drawd, new round will created. All bet have hashMap - sorted 2 or 3 symbols from block hash

    function placeBet() external virtual nonReentrant whenNotPaused {
        require(!_msgSender().isContract(), "HashLottery V4: sender cannot be a contract");
        require(tx.origin == _msgSender(), "HashLottery V4: msg sender is not original user");

        uint256 currentRoundStarted = rounds[lastRoundIndex].roundStarted;
        uint256 currentRoundEnded = rounds[lastRoundIndex].roundEnded;

        //current round was not drawd
        if ((block.timestamp > currentRoundStarted) && (block.timestamp > currentRoundEnded + CLIFF_ROUND_LENGTH)) {
            uint256 dayCoeff = (((block.timestamp - currentRoundStarted) / DAY_LENGTH) + 1);

            currentRoundStarted = currentRoundStarted + dayCoeff * DAY_LENGTH;
            currentRoundEnded = currentRoundStarted + ROUND_LENGTH;

            lastRoundIndex += 1;
        }

        if (rounds[lastRoundIndex].roundStarted == 0) {
            rounds[lastRoundIndex].roundStarted = currentRoundStarted;
            rounds[lastRoundIndex].roundEnded = currentRoundEnded;
        }

        uint256 previousLastIndex = 0;

        if (lastRoundIndex > 0) {
            previousLastIndex = lastRoundIndex - 1;

            require(
                (block.timestamp > rounds[previousLastIndex].roundEnded + CLIFF_ROUND_LENGTH) && (block.timestamp < currentRoundStarted),
                "HashLottery V4: the round has not started yet"
            );
        } else {
            require(block.timestamp < currentRoundStarted, "HashLottery V4: the round has not started yet");
        }

        rounds[lastRoundIndex].totalBets = rounds[lastRoundIndex].totalBets + betAmount;

        rounds[lastRoundIndex].numberOfBets = ++rounds[lastRoundIndex].numberOfBets;

        _beforeProcessBet(betAmount);

        Bet memory bet = Bet({blockNumber: block.number - 1, amount: betAmount, roundId: lastRoundIndex, hash: "", hashMap: ""});

        bets[_msgSender()].push(bet);

        _processBet(_msgSender(), bets[_msgSender()].length - 1);
    }

    function _beforeProcessBet(uint256 _amount) internal {
        IERC20(lotteryToken).safeTransferFrom(_msgSender(), address(this), _amount);

        uint256 jackpotFee = (_amount * JACKPOT_PERCENT * PRECISION) / 100 / PRECISION;
        uint256 storageFee = (_amount * STORAGE_PERCENT * PRECISION) / 100 / PRECISION;
        uint256 teamFee = (_amount * TEAM_PERCENT * PRECISION) / 100 / PRECISION;

        uint256 committeeFee = (_amount * COMMITTEE_PERCENT * PRECISION) / 100 / PRECISION;
        uint256 leaderboardFee = (_amount * LEADERBOARD_PERCENT * PRECISION) / 100 / PRECISION;
        uint256 burnFee = (_amount * BURN_PERCENT * PRECISION) / 100 / PRECISION;

        // increase jackpot
        jackpotAmount += jackpotFee;

        _deliverTokens(lotteryToken, storageAddress, storageFee);

        _deliverTokens(lotteryToken, teamAddress, teamFee);

        _deliverTokens(lotteryToken, committeeAddress, committeeFee);

        _deliverTokens(lotteryToken, leaderboardAddress, leaderboardFee);

        _deliverTokens(lotteryToken, DEAD_ADDRESS, burnFee);
    }

    function _processBet(address _gamer, uint256 _id) internal virtual {
        Bet storage bet = bets[_gamer][_id];

        bytes32 blockHash = _getBlockHash();

        bytes memory b = new bytes(6);

        uint8 matchBytes = MATCH_BYTES;

        if (isSpecialEventActivated) {
            matchBytes = SPECIAL_EVENT_MATCH_BYTES;
        }

        bytes memory h = new bytes(matchBytes);

        (b, h) = _getHashes(blockHash, b, h, matchBytes);

        h = _sort(h);

        bet.hash = b;

        bytes32 hashMap = keccak256(abi.encode(h));

        bet.hashMap = hashMap;

        require(!roundMaps[lastRoundIndex][hashMap].contains(_msgSender()), "HashLottery V4: already exist bet in this map");
        roundMaps[lastRoundIndex][hashMap].add(_msgSender());

        _mining(_gamer);

        emit ProcessBet(_id, _gamer, bet.amount, bet.hash, lastRoundIndex, hashMap);
    }

    /// @notice draw bet and get hash map for winners
    function drawBet(uint256 _vrfFee) external payable virtual nonReentrant whenNotPaused {
        require(
            (block.timestamp > rounds[lastRoundIndex].roundStarted) && (block.timestamp < rounds[lastRoundIndex].roundEnded + DAY_LENGTH),
            "HashLottery V4: round has not started or already ended"
        );

        require(rounds[lastRoundIndex].roundSettled == 0, "HashLottery V4: round drawd");

        uint256 drawAmount = msg.value - _vrfFee;

        require(drawAmount >= DRAW_AMOUNT, "HashLottery V4: cannot enough BNB for draw");

        if (drawAmount > DRAW_AMOUNT) {
            //refund extra
            _deliverFunds(_msgSender(), drawAmount - DRAW_AMOUNT, "HashLottery V4: failed transfer BNB to address");
        }

        _deliverFunds(platformAddress, DRAW_AMOUNT, "Can't deliver funds");

        _processVRFFee(lastRoundIndex, _vrfFee, _msgSender());

        require(LINK.balanceOf(address(this)) >= linkFee, "HashLottery V4: Not enough LINK");

        bytes32 requestId = requestRandomness(keyHash, linkFee);

        RandomnessRequestData memory data = RandomnessRequestData({
            roundId: lastRoundIndex,
            drawnBy: _msgSender(),
            number: 0,
            fullfilled: false
        });

        randomnessRequests[requestId] = data;

        rounds[lastRoundIndex].requestId = requestId;
    }

    function _processBetWithRandomness(RandomnessRequestData storage _data, uint256 _randomness) internal virtual override {
        uint256 roundId = _data.roundId;

        require(rounds[roundId].roundSettled == 0, "HashLottery V4: round draw");

        bytes32 blockHash = _getBlockHash(_randomness);

        bytes memory b = new bytes(6);

        uint8 matchBytes = MATCH_BYTES;

        if (isSpecialEventActivated) {
            matchBytes = SPECIAL_EVENT_MATCH_BYTES;
        }

        bytes memory h = new bytes(matchBytes);

        (b, h) = _getHashes(blockHash, b, h, matchBytes);

        h = _sort(h);

        bytes32 hashMap = keccak256(abi.encode(h));

        rounds[roundId].drawdHash = b;
        rounds[roundId].hashMap = hashMap;
        rounds[roundId].roundSettled = block.timestamp;

        uint256 rewards = (jackpotAmount * rewardPercent * PRECISION) / 100 / PRECISION;

        rounds[roundId].reward = rewards;

        uint256 newRoundStarted = rounds[roundId].roundStarted + DAY_LENGTH;

        uint256 numberOfWinners = roundMaps[roundId][hashMap].length();

        uint256 totalBets = rounds[roundId].totalBets;

        emit DrawBet(block.number, roundId, _data.drawnBy, b, isSpecialEventActivated, totalBets, rewards, numberOfWinners, hashMap);

        lastRoundIndex += 1;

        rounds[lastRoundIndex].roundStarted = newRoundStarted;
        rounds[lastRoundIndex].roundEnded = newRoundStarted + ROUND_LENGTH;

        if (numberOfWinners > 0) {
            jackpotAmount -= rewards;
        }
    }

    function claimBets() external virtual nonReentrant whenNotPaused {
        uint256 claimable = 0;
        for (uint256 i = 0; i < lastRoundIndex; i++) {
            claimable += _beforeClaimBet(i);
        }

        _deliverTokens(lotteryToken, _msgSender(), claimable);
    }

    /// @notice claim bets witn reward with vesting (90 days)
    /// @param _roundId round with reward
    function claimBet(uint256 _roundId) external virtual nonReentrant whenNotPaused {
        _claimBet(_roundId);
    }

    function _claimBet(uint256 _roundId) internal {
        uint256 claimable = _beforeClaimBet(_roundId);
        _deliverTokens(lotteryToken, _msgSender(), claimable);
    }

    function _beforeClaimBet(uint256 _roundId) internal returns (uint256 claimable) {
        Round memory round = rounds[_roundId];

        if (roundMaps[_roundId][round.hashMap].contains(_msgSender()) && round.reward > 0) {
            Win storage win = userWins[_msgSender()][_roundId];

            if (win.startVesting == 0) {
                uint256 numberOfWinners = roundMaps[_roundId][round.hashMap].length();

                uint256 rewardAmount = round.reward / numberOfWinners;

                win.reward = rewardAmount;
                win.startVesting = round.roundSettled;
            }

            uint256 duration = DAY_LENGTH * VESTING_DAY_LENGTH;

            uint256 total = win.reward + win.claimed;

            uint256 dayCoeff = (block.timestamp - win.startVesting) / DAY_LENGTH;

            uint256 vested = (total * (dayCoeff * DAY_LENGTH)) / duration;

            if (block.timestamp >= (win.startVesting + duration)) {
                vested = total;
            }

            claimable = vested - win.claimed;

            win.reward = win.reward - claimable;

            win.claimed = win.claimed + claimable;

            if (claimable > 0) {
                emit ClaimBet(_roundId, _msgSender(), win.reward, win.claimed);
            }
        }
    }

    /// @notice get bets length
    function getBetsLength(address _account) external view returns (uint256) {
        return bets[_account].length;
    }

    function getUserAvailableRewards(address _user) external view returns (uint256 claimable) {
        for (uint256 i = 0; i < lastRoundIndex; i++) {
            uint256 _roundId = i;

            Round memory round = rounds[_roundId];

            if (roundMaps[_roundId][round.hashMap].contains(_user) && round.reward > 0) {
                Win memory win = userWins[_user][_roundId];

                if (win.startVesting == 0) {
                    uint256 numberOfWinners = roundMaps[_roundId][round.hashMap].length();

                    uint256 rewardAmount = round.reward / numberOfWinners;

                    win.reward = rewardAmount;
                    win.startVesting = round.roundSettled;
                }

                uint256 duration = DAY_LENGTH * VESTING_DAY_LENGTH;

                uint256 total = win.reward + win.claimed;

                uint256 dayCoeff = (block.timestamp - win.startVesting) / DAY_LENGTH;

                uint256 vested = (total * (dayCoeff * DAY_LENGTH)) / duration;

                if (block.timestamp >= (win.startVesting + duration)) {
                    vested = total;
                }

                claimable += vested - win.claimed;
            }
        }
    }

    /// @notice get user rewards by round id
    function getUserRewardByRoundId(address _account, uint256 _roundId)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        Round memory round = rounds[_roundId];

        if (roundMaps[_roundId][round.hashMap].contains(_account)) {
            Win memory win = userWins[_account][_roundId];

            if (win.startVesting == 0) {
                uint256 numberOfWinners = roundMaps[_roundId][round.hashMap].length();

                uint256 rewardAmount = round.reward / numberOfWinners;

                win.reward = rewardAmount;
                win.startVesting = round.roundSettled;
            }

            return (win.reward, win.claimed, win.startVesting);
        } else {
            return (0, 0, 0);
        }
    }

    /// @notice get next round timestamps
    function getNextRoundTimestamps()
        external
        view
        returns (
            uint256 nextRoundStart,
            uint256 nextRoundEnd,
            uint256 prevRoundEnd,
            uint256 cliffPeriod
        )
    {
        uint256 currentLastRoundIndex = lastRoundIndex;

        nextRoundStart = rounds[currentLastRoundIndex].roundStarted;
        nextRoundEnd = rounds[currentLastRoundIndex].roundEnded;

        //current round was not drawd
        if ((block.timestamp > nextRoundStart) && (block.timestamp > nextRoundEnd + CLIFF_ROUND_LENGTH)) {
            uint256 dayCoeff = (((block.timestamp - nextRoundStart) / DAY_LENGTH) + 1);

            nextRoundStart = nextRoundStart + dayCoeff * DAY_LENGTH;
            nextRoundEnd = nextRoundStart + ROUND_LENGTH;

            currentLastRoundIndex += 1;
        }

        uint256 previousLastIndex = 0;

        if (currentLastRoundIndex > 0) {
            previousLastIndex = currentLastRoundIndex - 1;

            prevRoundEnd = rounds[previousLastIndex].roundEnded;
        } else {
            prevRoundEnd = 0;
        }

        cliffPeriod = CLIFF_ROUND_LENGTH;
    }

    ///@notice update platform address
    ///@param _platformAddress platform address
    function updatePlatformAddress(address _platformAddress) external onlyOwner {
        platformAddress = _platformAddress;

        emit UpdatePlatformAddress(_platformAddress);
    }

    ///@notice update platform address
    ///@param _lotteryToken platform address
    function updateLotteryToken(address _lotteryToken) external onlyOwner {
        lotteryToken = _lotteryToken;

        emit UpdateLotteryToken(_lotteryToken);
    }

    ///@notice activate promo period, when win matches == 5 mathes in order
    function updateSpecialEvent(bool _isSpecialEventActivated) external onlyOwner whenNotPaused {
        isSpecialEventActivated = _isSpecialEventActivated;

        emit UpdateSpecialEvent(_isSpecialEventActivated);
    }

    function _sort(bytes memory _arr) private pure returns (bytes memory) {
        uint256 l = _arr.length;
        for (uint256 i = 0; i < l; i++) {
            for (uint256 j = i + 1; j < l; j++) {
                if (_arr[i] > _arr[j]) {
                    bytes1 temp = _arr[i];
                    _arr[i] = _arr[j];
                    _arr[j] = temp;
                }
            }
        }
        return _arr;
    }

    /// @notice get block hash
    function _getBlockHash() internal view virtual returns (bytes32 _hash) {
        return keccak256(abi.encode(blockhash(block.number - 1), block.timestamp, block.coinbase, _msgSender()));
    }

    function _getHashes(
        bytes32 _blockHash,
        bytes memory b,
        bytes memory h,
        uint8 _matchBytes
    ) internal pure returns (bytes memory, bytes memory) {
        uint8 i = 0;
        bytes1 field;
        for (uint8 j = 0; j < 6; j++) {
            field = _blockHash[26 + j] >> 4;
            b[j] = field;

            if (j >= 6 - _matchBytes) {
                h[i] = field;
                i++;
            }
        }
        return (b, h);
    }

    function increaseMiningSupply(uint256 _amount) external virtual onlyOwner {
        IERC20(baseToken).safeTransferFrom(_msgSender(), address(this), _amount);

        totalMiningSupply += _amount;

        emit IncreaseMiningSupply(_amount, totalMiningSupply);
    }

     function decreaseMiningSupply(uint256 _amount) external virtual onlyOwner {
        
        if (_amount > totalMiningSupply) {
            _amount = totalMiningSupply;
        }

        _withdrawToken(baseToken, _msgSender(), _amount);

        totalMiningSupply -= _amount;

        emit DecreaseMiningSupply(_amount, totalMiningSupply);
    }

    function _mining(address _gamer) internal virtual override {
        if (isMiningAvailable && totalMiningSupply >= miningAmount && miningAmount <= IERC20(baseToken).balanceOf(address(this))) {
            IERC20(baseToken).safeTransfer(_gamer, miningAmount);

            totalMined[baseToken] += miningAmount;

            miningBalances[baseToken][_gamer] += miningAmount;

            totalMiningSupply -= miningAmount;

            emit TokenMined(baseToken, _gamer, miningAmount);
        }
    }

    function addJackpot(uint256 _amount) external onlyOwner {
        IERC20(lotteryToken).safeTransferFrom(_msgSender(), address(this), _amount);

        jackpotAmount += _amount;

        emit Received(_msgSender(), _amount);
    }

    function removeJackpot(uint256 _amount) external onlyOwner {

        if (_amount > jackpotAmount) {
            _amount = jackpotAmount;
        }

        _withdrawToken(lotteryToken, _msgSender(), _amount);

        jackpotAmount -= _amount;

        emit Removed(_amount);
    }

    function changeBetAmount(uint256 _betAmount) external onlyOwner {
        betAmount = _betAmount;

        emit ChangeBetAmount(_betAmount);
    }

    function changeRewardPercent(uint256 _rewardPercent) external onlyOwner {
        rewardPercent = _rewardPercent;

        emit ChangeRewardPercent(_rewardPercent);
    }

}