// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity 0.8.13;

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
pragma solidity 0.8.13;


abstract contract MultiSign{
    mapping(bytes32 => signerData) public functionSigns;
    address[] public signers;
    uint8 public requiredSigns;
    struct signerData{
        uint8 approvedQuantity;
        bytes32 functionHash;
        address[] approvedAddress;
    }
    event approveFunctionExecution(bytes32 functionName, address signer,bool executionApproved);
    event rejectFunctionExecution(bytes32 functionName, address signer,bool executionApproved);

    function isMultiSigned(bytes32 functionName) public view returns(bool){
        return functionSigns[functionName].approvedQuantity == requiredSigns;
    }

    function hasSigned(bytes32 functionName, address signer) public view returns(bool){
        for(uint8 i = 0;i < functionSigns[functionName].approvedAddress.length; i++){
            if(signer == functionSigns[functionName].approvedAddress[i]){
                return true;
            }
        }
        return false;
    }

    function isSigner(address signer) public view returns(bool){
        for(uint8 i = 0;i < signers.length; i++){
            if(signer == signers[i]){
                return true;
            }
        }
        return false;
    }

    function signFunction(bytes32 functionName, bool executionApproved, bytes32 hash ) public{
        require(!hasSigned(functionName, msg.sender),"MultiSign: You already signed this function execution");
        require(isSigner(msg.sender),"MultiSign: You need to be signer to sign a multi sign function");
        if(functionSigns[functionName].functionHash == bytes32(0)){
            functionSigns[functionName].functionHash = hash;
        }
        require(functionSigns[functionName].functionHash == hash,"MultiSign: You must send the same transaction to approve the sign");
        if(executionApproved){
            functionSigns[functionName].approvedQuantity += 1;
            functionSigns[functionName].approvedAddress.push(msg.sender);
            emit approveFunctionExecution(functionName,msg.sender,executionApproved);
        }else{
            resetFunctionSignatures(functionName);
            emit rejectFunctionExecution(functionName,msg.sender,executionApproved);
        }
    }

    function resetFunctionSignatures(bytes32 functionName) internal{
        functionSigns[functionName].approvedQuantity = 0;
        delete functionSigns[functionName].approvedAddress;
        functionSigns[functionName].functionHash = bytes32(0);
    }

    constructor(address[] memory signersData){
        signers = signersData;
        requiredSigns = uint8(signers.length);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "./openzeppelinV4.5.0/token/ERC20/utils/SafeERC20.sol";
import "./MultiSign.sol";

contract DigCryptoVIP is MultiSign{
    using SafeERC20 for IERC20;
    
    mapping(address => vip) public vipData;
    
    address public TKN = 0xB82BEb6Ee0063Abd5fC8E544c852237aA62CBb14;
    address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    uint256 public timeLocked = 2629800;
    address payable public rewardPool;
    uint256[] public vipPrices;
    IPancakeRouter01 public router;
    IERC20 public token;
    event UpdateTier(uint8 oldTier, uint8 newTier);

    struct vip{
        uint8 tier;
        uint256 staked;
        uint256 stakeTime;
    }

    constructor(IPancakeRouter01 _router,IERC20 _token,address payable _rewardPool,address[] memory signers) MultiSign(signers){
        router = _router;
        token = _token;
        rewardPool = _rewardPool;
        vipPrices.push(0); // The 0 index cannot be bought
        vipPrices.push(100000000000000000000);
        vipPrices.push(200000000000000000000);
        vipPrices.push(500000000000000000000);
        vipPrices.push(800000000000000000000);
        vipPrices.push(1000000000000000000000);
        vipPrices.push(3000000000000000000000);
    }
    function getTKN(uint256 BUSDValue) public view returns(uint256){
        uint256[] memory WBNBValue;
        uint256[] memory TKNValue;
        address[] memory BUSDPair = new address[](2);
        address[] memory TKNPair = new address[](2);
        BUSDPair[0] = WBNB;
        BUSDPair[1] = BUSD;
        TKNPair[0] = TKN;
        TKNPair[1] = WBNB;
        WBNBValue = router.getAmountsOut(BUSDValue,BUSDPair);
        TKNValue = router.getAmountsOut(WBNBValue[0],TKNPair);
        return TKNValue[0];
    }
    function addVipPrice(uint256 busdValue) public {
        bytes32 functionHash = keccak256("addVipPrice");
        signFunction(functionHash,true,keccak256(abi.encodePacked(busdValue)));
        if(isMultiSigned(functionHash)){
            vipPrices.push(busdValue);
            resetFunctionSignatures(functionHash);
        }
    }
    function updateVipPrice(uint256 tier, uint256 busdValue) public{
        bytes32 functionHash = keccak256("updateVipPrice");
        signFunction(functionHash,true,keccak256(abi.encodePacked(tier,busdValue)));
        if(isMultiSigned(functionHash)){
            validateVipPrice(tier);
            vipPrices[tier] = busdValue;
            resetFunctionSignatures(functionHash);
        }
    }
    function getVipPrice(uint256 tier) public view returns(uint256){
        validateVipPrice(tier);
        return getTKN(vipPrices[tier]);
    }
    function getNextTierId() public view returns(uint256 tier){
        return vipPrices.length;
    }
    function getPlayerTier(address player) public view returns(uint256 tier){
        return vipData[player].tier;
    }
    function validateVipPrice(uint256 tier) public view{
        require(vipPrices.length > tier && tier != 0 ,"DCV: Invalid vip tier provided");
    }
    function validateTier(uint256 tier) public view{
        require(vipData[msg.sender].tier < tier,"DCV: Stake tier must be greater than current");
    }
    function stake(uint8 tier) public{
        validateTier(tier);
        uint256 valueToStake = getVipPrice(tier)-vipData[msg.sender].staked;
        token.safeTransferFrom(msg.sender,rewardPool,valueToStake);
        uint8 oldTier = vipData[msg.sender].tier;
        vipData[msg.sender].tier = tier;
        vipData[msg.sender].staked += valueToStake;
        vipData[msg.sender].stakeTime = block.timestamp;
        emit UpdateTier(oldTier,tier);
    }
    function unstake() public{
        validateVipPrice(getPlayerTier(msg.sender));
        require(block.timestamp > vipData[msg.sender].stakeTime + timeLocked,"DCV: You need to wait at least three days to unstake");
        token.safeTransferFrom(rewardPool,msg.sender,vipData[msg.sender].staked);
        uint8 oldTier = vipData[msg.sender].tier;
        uint8 newTier = 0;
        vipData[msg.sender].tier = newTier;
        vipData[msg.sender].staked = 0;
        vipData[msg.sender].stakeTime = 0;
        emit UpdateTier(oldTier,newTier);
    }
    function setRewardPool(address payable _rewardPool) public{
        bytes32 functionHash = keccak256("setRewardPool");
        signFunction(functionHash,true,keccak256(abi.encodePacked(_rewardPool)));
        if(isMultiSigned(functionHash)){
            rewardPool = _rewardPool;
            resetFunctionSignatures(functionHash);
        }
    }
    function setRewardTKN(address tkn) public{
        bytes32 functionHash = keccak256("setRewardTKN");
        signFunction(functionHash,true,keccak256(abi.encodePacked(tkn)));
        if(isMultiSigned(functionHash)){
            TKN = tkn;
            resetFunctionSignatures(functionHash);
        }
    }
    function setRewardBUSD(address busd) public{
        bytes32 functionHash = keccak256("setRewardBUSD");
        signFunction(functionHash,true,keccak256(abi.encodePacked(busd)));
        if(isMultiSigned(functionHash)){
            BUSD = busd;
            resetFunctionSignatures(functionHash);
        }
    }
    function setRewardWbnb(address Wbnb) public{
        bytes32 functionHash = keccak256("setRewardWbnb");
        signFunction(functionHash,true,keccak256(abi.encodePacked(Wbnb)));
        if(isMultiSigned(functionHash)){
            WBNB = Wbnb;
            resetFunctionSignatures(functionHash);
        }
    }
}

interface IPancakeRouter01{
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.13;

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

pragma solidity 0.8.13;

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