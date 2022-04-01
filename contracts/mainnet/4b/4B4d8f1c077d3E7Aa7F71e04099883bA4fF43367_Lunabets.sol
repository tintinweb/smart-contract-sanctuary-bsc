//-----------------------------------------------------------------------------
// Lunabets contract
//
// Developed by Lion Gaming Group
//-----------------------------------------------------------------------------
// SPDX-License-Identifier: MIT

pragma solidity >0.4.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

//-----------------------------------------------------------------------------
// Ownership
//-----------------------------------------------------------------------------

contract owned
{
 address internal owner;
 address internal newOwner;

 event OwnershipTransferred(address indexed _from, address indexed _to);

 constructor() {
 owner = msg.sender;
 }

 modifier onlyOwner {
 require(msg.sender == owner);
 _;
 }

 function transferOwnership(address _newOwner) public onlyOwner {
 newOwner = _newOwner;
 }

 function acceptOwnership() public {
 require(msg.sender == newOwner);
 emit OwnershipTransferred(owner, newOwner);
 owner = newOwner;
 newOwner = address(0);
 }
}

//-----------------------------------------------------------------------------
// Lunabets
//-----------------------------------------------------------------------------

contract Lunabets is owned, ReentrancyGuard
{
 using SafeMath for uint256;

 // Lion Gaming agent
 address public agent;

 // LunaFi treasury wallet
 address public treasurer;

 struct LunaClaim {
 address claimant;
 uint256 unlocksAt;
 uint256 amount;
 }

 // Special coinIndex to represent LFI
 // Used during sync call only
 uint32 constant stakedLunaCoinIndex = 100;

 // Claim counter (arbitrary starting point)
 uint256 currentClaimId = 1000;

 // ERC20 tokens we allow
 mapping(uint32 => IERC20) supportedTokens;

 // Balances owned by users (key is encoded address + coinIndex)
 mapping(uint256 => uint256) userBalance;

 // Balance not owned by users (key is coinIndex)
 mapping(uint32 => uint256) freeBalance;

 // LunaFi tokens allocated to users; claimable after launch
 mapping(address => uint256) lunaBalance;

 // LunaFi tokens which have been claimed but not withdrawn
 mapping(address => uint256) claimedLunaBalance;

 // Claims on LunaFi tokens
 mapping(uint256 => LunaClaim) lunaClaims;

 mapping(uint256 => uint256) withdrawNonce;

 // LunaFi tokens stored
 uint256 lunaContractBalance;

 // The LunaFi contract
 IERC20 lunaContract;

 // Once set to true, users can begin claiming LunaFi tokens
 bool lunaPhaseTwoActive = false;

 // If false, reject any incoming deposits
 bool public depositsEnabled = true;

 modifier onlyAgent {
 require(agent != address(0));
 require(msg.sender == agent);
 _;
 }

 modifier onlyTreasurer {
 require(treasurer != address(0));
 require(msg.sender == treasurer);
 _;
 }

 function setAgent(address newAgent) public onlyOwner {
 agent = newAgent;
 }

 function setTreasurer(address newTreasurer) public onlyOwner {
 treasurer = newTreasurer;
 }

 /**
 * Fallback function to reject direct ETH transfers to the
 * contract (which would get stuck).
 */
 receive() external payable {
 require(false, "Direct transfers not allowed");
 }

 event BalanceIncreased(address indexed user, uint256 change, uint256 balance, uint32 coinIndex, string reason, uint256 spent);
 event BalanceDecreased(address indexed user, uint256 change, uint256 balance, uint32 coinIndex, string reason, uint256 spent, uint256 withdrawn);
 event WithdrawalCancelled(address indexed user, uint256 amount, uint32 coinIndex, uint256 nonce);
 event LunaClaimStarted(address indexed user, uint256 amount, uint256 claimId, uint256 claimedAt, uint256 unlocksAt);
 event LunaWithdrawn(address indexed user, uint256 amount, uint256 claimId, uint256 withdrawnAt);
 event LunaBalanceIncreased(address indexed user, uint256 change, uint256 balance);
 event LunaPhaseTwoActivated();
 event SyncCompleted(uint256 indexed syncId);

 /*- Owner/agent methods --------------------------------------------------*/

 /**
 * Adds a coin to the list of coins we support. Indices, despite the name,
 * need not be sequential.
 */
 function addCoin(uint32 coinIndex, address tokenAddress) public onlyOwner {
 IERC20 token = IERC20(tokenAddress);
 require(coinIndex != 0, "Can't assign coinIndex zero");
 require(coinIndex < 100, "Can't assign reserved coinIndex"); // >= 100 is for internal use
 require(supportedTokens[coinIndex] == IERC20(address(0)), "coinIndex already assigned");
 supportedTokens[coinIndex] = token;
 }

 /**
 * Sets the LunaFi token contract address.
 */
 function setLunaContract(address tokenAddress) public onlyOwner {
 IERC20 token = IERC20(tokenAddress);
 lunaContract = token;
 }

 /**
 * Activates Luna phase 2.
 */
 function activatePhaseTwo() public onlyOwner {
 lunaPhaseTwoActive = true;
 emit LunaPhaseTwoActivated();
 }

 /**
 * Withdraws free balance to the specified address.
 */
 function transferBalance(address payable recipient, uint256 amount, uint32 coinIndex) private onlyTreasurer {
 require(coinIndex == 0 || supportedTokens[coinIndex] != IERC20(address(0)), "Unsupported coin");
 freeBalance[coinIndex] = freeBalance[coinIndex].sub(amount);
 makePayment(recipient, amount, coinIndex);
 }

 /**
 * Withdraws entire free balance to the specified address.
 */
 function transferTotalBalance(address payable recipient, uint32 coinIndex) private onlyTreasurer {
 require(coinIndex == 0 || supportedTokens[coinIndex] != IERC20(address(0)), "Unsupported coin");
 uint256 amount = freeBalance[coinIndex];
 freeBalance[coinIndex] = 0;
 makePayment(recipient, amount, coinIndex);
 }

 /**
 * Withdraws free balance to the treasury address.
 */
 function withdrawContractBalance(uint256 amount, uint32 coinIndex) public onlyTreasurer {
 require(treasurer != address(0), "Treasurer not defined");
 transferBalance(payable(treasurer), amount, coinIndex);
 }

 /**
 * Withdraws entire free balance to the treasury address.
 */
 function withdrawTotalContractBalance(uint32 coinIndex) public onlyTreasurer {
 require(treasurer != address(0), "Treasurer not defined");
 require(coinIndex == 0 || supportedTokens[coinIndex] != IERC20(address(0)), "Unsupported coin");
 uint256 amount = freeBalance[coinIndex];
 freeBalance[coinIndex] = 0;
 makePayment(payable(treasurer), amount, coinIndex);
 }

 /**
 * Funds the contract.
 */
 function fundContract() public payable onlyTreasurer {
 uint32 coinIndex = 0; // Funding the native token

 freeBalance[coinIndex] = freeBalance[coinIndex].add(msg.value);
 }

 /**
 * Funds the contract with tokens.
 */
 function fundContractTokens(uint32 coinIndex, uint256 amount) public onlyTreasurer {
 require(coinIndex != 0, "This method is only for tokens");
 require(supportedTokens[coinIndex] != IERC20(address(0)), "Unsupported coin");

 IERC20 token = IERC20(supportedTokens[coinIndex]);
 require(token.allowance(msg.sender, address(this)) >= amount, "Transfer not approved");
 require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

 freeBalance[coinIndex] = freeBalance[coinIndex].add(amount);
 }

 /**
 * Funds the contract with LunaFi tokens.
 */
 function fundContractLuna(uint256 amount) public onlyTreasurer {
 require(lunaContract != IERC20(address(0)), "Luna contract not yet defined");

 IERC20 token = IERC20(lunaContract);
 require(token.allowance(msg.sender, address(this)) >= amount, "Transfer not approved");
 require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

 lunaContractBalance = lunaContractBalance.add(amount);
 }

 /**
 * Enables or disables new deposits to the contract.
 *
 * @param enabled - New enabled state.
 */
 function enableDeposits(bool enabled) public onlyOwner {
 depositsEnabled = enabled;
 }

 /**
 * Bulk-sync on-chain balances.
 */
 function balanceSync(address payable[] memory users, uint32[] memory coinIndices, uint256[] memory changed, uint256 syncId) public onlyAgent {
 require(coinIndices.length == users.length, "Array size mismatch");
 require(changed.length == users.length, "Array size mismatch");

 for (uint256 i = 0; i < users.length; i++) {
 address payable user = users[i];
 uint32 coinIndex = coinIndices[i];

 require(coinIndex == 0 || coinIndex == stakedLunaCoinIndex || supportedTokens[coinIndex] != IERC20(address(0)), "Unsupported coin");

 if (changed[i] == 0)
 continue;

 if (coinIndex == stakedLunaCoinIndex) {
 uint256 lunaGained = changed[i];

 lunaBalance[user] = lunaBalance[user].add(lunaGained);
 //emit LunaBalanceIncreased(user, lunaGained, lunaBalance[user]);
 } else {
 uint256 spent = changed[i];

 uint256 bal = getBalanceId(user, coinIndex);

 userBalance[bal] = userBalance[bal].sub(spent);
 freeBalance[coinIndex] = freeBalance[coinIndex].add(spent);

 //emit BalanceDecreased(user, spent, userBalance[bal], coinIndex, "Balance sync", spent, 0);
 }
 }

 emit SyncCompleted(syncId);
 }

 /**
 * Sends funds from the user's contract balance to their wallet.
 *
 * @param user - Recipient.
 * @param amount - Amount to send.
 */
 function pushBalance(address payable user, uint256 amount, uint32 coinIndex) public onlyAgent {
 require(coinIndex == 0 || supportedTokens[coinIndex] != IERC20(address(0)), "Unsupported coin");

 uint256 bal = getBalanceId(user, coinIndex);

 userBalance[bal] = userBalance[bal].sub(amount);
 withdrawNonce[bal] = withdrawNonce[bal].add(1);

 emit BalanceDecreased(user, amount, userBalance[bal], coinIndex, "Balance withdrawal", 0, amount);

 makePayment(user, amount, coinIndex);
 }

 /**
 * Allocates LunaFi tokens to the given user.
 *
 * @param user - Recipient.
 * @param amount - Amount to give to the user.
 */
 function addLuna(address user, uint256 amount) public onlyAgent {
 lunaBalance[user] = lunaBalance[user].add(amount);
 emit LunaBalanceIncreased(user, amount, lunaBalance[user]);
 }

 /**
 * Removes funds from a user's balance.
 *
 * @param user - Recipient.
 * @param amount - Amount.
 * @param reason - Reason for operation.
 * @param spent - Current spent delta (for bookkeeping).
 */
 function takeBalance(address payable user, uint256 amount, uint32 coinIndex, string memory reason, uint256 spent) public onlyAgent {
 require(coinIndex == 0 || supportedTokens[coinIndex] != IERC20(address(0)), "Unsupported coin");

 uint256 bal = getBalanceId(user, coinIndex);

 userBalance[bal] = userBalance[bal].sub(amount);
 freeBalance[coinIndex] = freeBalance[coinIndex].add(amount);

 emit BalanceDecreased(user, amount, userBalance[bal], coinIndex, reason, spent, 0);
 }

 /**
 * Update the given user's withdrawal nonce, which has the
 * effect of invalidating the pending withdrawal request (if any).
 */
 function incrementWithdrawalNonce(address payable user, uint32 coinIndex) public onlyAgent {
 require(coinIndex == 0 || supportedTokens[coinIndex] != IERC20(address(0)), "Unsupported coin");

 uint256 bal = getBalanceId(user, coinIndex);

 withdrawNonce[bal] = withdrawNonce[bal].add(1);
 }

 /*- Public methods -------------------------------------------------------*/

 /**
 * Makes a claim for currently available LunaFi. The tokens are locked for five
 * days before being released.
 */
 function claimLFI() public {
 require(lunaPhaseTwoActive == true, "Luna tokens are not yet claimable");

 uint256 amount = lunaBalance[msg.sender];

 require(amount != 0, "No Luna tokens to claim for this user");

 LunaClaim memory claim;
 claim.claimant = msg.sender;
 claim.unlocksAt = block.timestamp + 5 days;
 claim.amount = amount;

 lunaBalance[msg.sender] = 0;
 claimedLunaBalance[msg.sender] = claimedLunaBalance[msg.sender].add(amount);

 lunaClaims[currentClaimId] = claim;

 emit LunaClaimStarted(msg.sender, amount, currentClaimId, block.timestamp, claim.unlocksAt);

 currentClaimId = currentClaimId.add(1);
 }

 /**
 * Transfers the LunaFi tokens associated with a previously made claim
 * to the caller (if the claim is past the lock-up period).
 */
 function withdrawLFI(uint256 claimId, bytes memory signature) public nonReentrant {
 require(lunaContract != IERC20(address(0)), "Luna contract not yet defined");

 LunaClaim memory claim = lunaClaims[claimId];

 require(claim.claimant != address(0), "Invalid claim");
 require(claim.claimant == msg.sender, "Caller/claimant mismatch");
 require(claim.unlocksAt <= block.timestamp, "Claim still locked");
 require(lunaContractBalance >= claim.amount, "Insufficient Luna funds on contract");

 verifyLunaClaimSignature(claimId, signature);

 delete lunaClaims[claimId];

 lunaContractBalance = lunaContractBalance.sub(claim.amount);
 claimedLunaBalance[claim.claimant] = claimedLunaBalance[claim.claimant].sub(claim.amount);

 IERC20 token = IERC20(lunaContract);
 require(token.transfer(claim.claimant, claim.amount), "Transfer failed");

 emit LunaWithdrawn(claim.claimant, claim.amount, claimId, block.timestamp);
 }

 /**
 * Retrieves the free (not owned by users) contract balance.
 */
 function getFreeBalance(uint32 coinIndex) public view returns(uint256) {
 require(coinIndex == 0 || supportedTokens[coinIndex] != IERC20(address(0)), "Unsupported coin");
 return freeBalance[coinIndex];
 }

 /**
 * Retrieves a user's current balance.
 */
 function getBalance(address user, uint32 coinIndex) public view returns(uint256) {
 require(coinIndex == 0 || supportedTokens[coinIndex] != IERC20(address(0)), "Unsupported coin");
 uint256 bal = getBalanceId(user, coinIndex);
 return userBalance[bal];
 }

 /**
 * Retrieves the current phase two activation state.
 */
 function getLunaPhaseTwoActive() public view returns(bool) {
 return lunaPhaseTwoActive;
 }

 /**
 * Retrieves a user's current Luna balance.
 */
 function getLunaBalance(address user) public view returns(uint256) {
 return lunaBalance[user];
 }

 /**
 * Retrieves the time remaining (in secs) until a LunaFi claim unlocks.
 */
 function getLunaClaimSecsRemaining(uint256 claimId) public view returns(uint256) {
 LunaClaim memory claim = lunaClaims[claimId];

 // Verify claim exists
 if (claim.claimant == address(0))
 return 0;

 if (claim.unlocksAt < block.timestamp)
 return 0;

 return claim.unlocksAt - block.timestamp;
 }

 /**
 * Retrieves the current withdrawal nonce for the user.
 */
 function getWithdrawNonce(address user, uint32 coinIndex) public view returns(uint256) {
 require(coinIndex == 0 || supportedTokens[coinIndex] != IERC20(address(0)), "Unsupported coin");

 uint256 bal = getBalanceId(user, coinIndex);

 return withdrawNonce[bal];
 }

 /**
 * Allows a user to deposit coins into their contract balance.
 */
 function deposit() public payable {
 require(depositsEnabled, "Deposits currently disabled");

 uint32 coinIndex = 0; // Depositing the native token

 uint256 bal = getBalanceId(msg.sender, coinIndex);

 userBalance[bal] = userBalance[bal].add(msg.value);

 emit BalanceIncreased(msg.sender, msg.value, userBalance[bal], coinIndex, "User deposit", 0);
 }

 /**
 * Allows a user to deposit supported ERC20 tokens into their contract balance.
 */
 function depositToken(uint32 coinIndex, uint256 amount) public {
 require(depositsEnabled, "Deposits currently disabled");

 require(coinIndex == 0 || supportedTokens[coinIndex] != IERC20(address(0)), "Unsupported coin");

 uint256 bal = getBalanceId(msg.sender, coinIndex);

 userBalance[bal] = userBalance[bal].add(amount);

 require(coinIndex != 0, "This method is only for tokens");

 IERC20 token = IERC20(supportedTokens[coinIndex]);
 require(token.allowance(msg.sender, address(this)) >= amount, "Transfer not approved");
 require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

 emit BalanceIncreased(msg.sender, amount, userBalance[bal], coinIndex, "User deposit", 0);
 }

 /**
 * Withdraw funds.
 *
 * @param amount - Amount to withdraw.
 * @param coinIndex - Requested coin.
 * @param signature - Authorisation for this request.
 */
 function withdraw(uint256 amount, uint32 coinIndex, bytes memory signature) public nonReentrant {
 require(coinIndex == 0 || supportedTokens[coinIndex] != IERC20(address(0)), "Unsupported coin");

 uint256 bal = getBalanceId(msg.sender, coinIndex);

 verifyWithdrawSignature(payable(msg.sender), "withdraw", amount, coinIndex, signature);

 withdrawNonce[bal] = withdrawNonce[bal].add(1);

 userBalance[bal] = userBalance[bal].sub(amount);

 makePayment(payable(msg.sender), amount, coinIndex);

 emit BalanceDecreased(msg.sender, amount, userBalance[bal], coinIndex, "User withdrawal", 0, amount);
 }

 /**
 * Cancel withdraw request.
 */
 function cancelWithdrawal(uint256 amount, uint32 coinIndex, bytes memory signature) public {
 uint256 bal = getBalanceId(msg.sender, coinIndex);
 uint256 nonce = withdrawNonce[bal];
 verifyWithdrawSignature(payable(msg.sender), "cancelWithdrawal", amount, coinIndex, signature);
 withdrawNonce[bal] = withdrawNonce[bal].add(1);
 emit WithdrawalCancelled(msg.sender, amount, coinIndex, nonce);
 }

 /*- Private methods ------------------------------------------------------*/

 function makePayment(address payable recipient, uint256 amount, uint32 coinIndex) private {
 if (coinIndex == 0) {
 //recipient.transfer(amount);
 require(recipient.send(amount));
 } else {
 IERC20 token = IERC20(supportedTokens[coinIndex]);
 require(token.transfer(recipient, amount), "Transfer failed");
 }
 }

 function verifyWithdrawSignature(address payable user, string memory operation, uint256 amount, uint32 coinIndex, bytes memory signature) private view {
 uint256 bal = getBalanceId(user, coinIndex);

 bytes32 message = keccak256(abi.encodePacked(operation, this, block.chainid, user, amount, coinIndex, withdrawNonce[bal]));
 require(recoverSigner(message, signature) == agent, "Invalid signature");
 }

 function verifyLunaClaimSignature(uint256 claimId, bytes memory signature) private view {
 bytes32 message = keccak256(abi.encodePacked("withdrawClaimedLuna", this, block.chainid, claimId));
 require(recoverSigner(message, signature) == agent, "Invalid signature");
 }

 function getBalanceId(address user, uint32 coinIndex) private pure returns (uint256) {
 // Addresses are 160 bits
 return (uint256(uint160(user)) << (256-160)) | uint128(coinIndex);
 }

 function recoverSigner(bytes32 message, bytes memory signature) private pure returns (address) {
 uint8 v;
 bytes32 r;
 bytes32 s;

 (v, r, s) = splitSignature(signature);

 return ecrecover(message, v, r, s);
 }

 function splitSignature(bytes memory signature) private pure returns (uint8, bytes32, bytes32) {
 require(signature.length == 65);
 bytes32 r;
 bytes32 s;
 uint8 v;

 assembly {
 // first 32 bytes, after the length prefix
 r := mload(add(signature, 32))
 // second 32 bytes
 s := mload(add(signature, 64))
 // final byte (first byte of the next 32 bytes)
 v := byte(0, mload(add(signature, 96)))
 }

 return (v, r, s);
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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
     * by making the `nonReentrant` function external, and making it call a
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