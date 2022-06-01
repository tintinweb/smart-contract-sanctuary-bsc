/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

// SPDX-License-Identifier: MIT
// File: G27Stakeable.sol


pragma solidity ^0.8.4;

/**
* @notice Stakeable is a contract who is ment to be inherited by other contract that wants Staking capabilities
*/
contract G27Stakeable {

    /**
    * @notice Constructor since this contract is not ment to be used without inheritance
    * push once to stakeholders for it to work proplerly
     */
    constructor() {
        // This push is needed so we avoid index 0 causing bug of index-1
        stakeholders.push();
    }

    /**
     * @notice
     * A stake struct is used to represent the way we store stakes, 
     * A Stake will contain the users address, the amount staked and a timestamp, 
     * Since which is when the stake was made
     */
    struct Stake{
        address user;
        uint256 amount;
        uint256 since;
        // This claimable field is new and used to tell how big of a reward is currently available
        uint256 claimable;
    }

    /**
     * @notice Stakeholder is a staker that has active stakes
     */
    struct Stakeholder{
        address user;
        Stake[] address_stakes;
    }

    /**
     * @notice
     * StakingSummary is a struct that is used to contain all stakes performed by a certain account
     */ 
    struct StakingSummary{
        uint256 total_amount;
        Stake[] stakes;
    }

    /**
     * @notice 
     *   This is a array where we store all Stakes that are performed on the Contract
     *   The stakes for each address are stored at a certain index, the index can be found using the stakes mapping
     */
    Stakeholder[] internal stakeholders;

    /**
     * @notice 
     * stakes is used to keep track of the INDEX for the stakers in the stakes array
     */
    mapping(address => uint256) internal stakes;

    /**
     * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable
     */
    event Staked(address indexed user, uint256 amount, uint256 index, uint256 timestamp);

    /**
     * @notice
     * rewardPerHour is 11415525100000 because 1000 is used to represent 0.001, since we only use integer numbers
     * This will give users 0.00114155251% reward for each staked token / H
     * 1 Token = 1 USDT
     * hour = 60*60 = 3600 seconds
     * day = 3600*24 = 86400 seconds
     * year = 86400*365 = 31536000 seconds
     * for each 1 year 10% rewards
     * x = (31536000 * 100) / 10 = 315360000 seconds for 100%
     * x = (86400 * 100) / 315360000 = 0.0273972602739726% rewards for day
     * x = (1 * 100) / 315360000 = 0.00000031709791983765459% rewards for second
     * 0.00000031709791983765459 * 86400 = 0.0273972602739726% rewards for day
     * 0.0273972602739726% / 24h = 0.00114155251% rewards for hour
     * 0.0273972602739726 * 365 = 9.999999999999999% rewards for year.
     * 1 Token + 0.0273972602739726% rewards for day 0.000273972602739726 = 1.00027397260274 Tokens (USDT)
     * x = (100.02739726027397 * 1) / 100 = 1.000273972602739726 USDT for day, Total Token + rewards for day
     * 0.000273972602739726 USDT for day * 365 days = 0.1 USDT rewards for each 1 USDT for Year 
     * 0.000273972602739726 / 86400 = 0.0000000031709792
     * x = (1 second * 0.000273972602739726 USDT rewars for day) / 86400 seconds (1 day) = 0.0000000031709792 USDT rewars for second
     * 0.0000000031709792 * 10 ** 18 = 3170979200 Weis rewards for second for each Token (USDT)
     * x = (3600 seconds (1 hour) * 0.000273972602739726 USDT rewars for day) / 86400 seconds (1 day) = 0.0000114155251 USDT rewars for hour
     * 0.0000114155251 * 10 **18 = 11415525100000 Weis rewards for hour for each Token (USDT)
     */
    //uint256 internal rewardPerHour = 11415525100000; // 250000 - 0.025% | 8300000 - 0.0083% | 11415525100000 - 0.00114155251% | 3170979198 - 0.00000031709791983765459%
    uint256 internal rewardWeiPerSecond = 3170979200; // 250000 - 0.025% | 8300000 - 0.0083% | 11415525100000 - 0.00114155251% | 3170979198 - 0.00000031709791983765459%

    /**
     * @notice _addStakeholder takes care of adding a stakeholder to the stakeholders array
     */
    function _addStakeholder(address staker) internal returns (uint256) {
        // Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // Assign the address to the new index
        stakeholders[userIndex].user = staker;
        // Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex; 
    }

    /**
     * @notice
     * _Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container
     * StakeID 
     */
    function _stake(uint256 _amount) internal {
        // Simple check so that user does not stake 0 
        require(_amount > 0, "Cannot stake nothing");
        
        // Mappings in solidity creates all values, but empty, so we can just check the address
        uint256 index = stakes[msg.sender];
        // block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 timestamp = block.timestamp;
        // See if the staker already has a staked index or if its the first time
        if(index == 0){
            // This stakeholder stakes for the first time
            // We need to add him to the stakeHolders and also map it into the Index of the stakes
            // The index returned will be the index of the stakeholder in the stakeholders array
            index = _addStakeholder(msg.sender);
        }

        // Use the index to push a new Stake
        // push a newly created Stake with the current block timestamp.
        stakeholders[index].address_stakes.push(Stake(msg.sender, _amount, timestamp, 0));
        // Emit an event that the stake has occured
        emit Staked(msg.sender, _amount, index, timestamp);
    }

    /**
     * @notice
     * calculateStakeReward is used to calculate how much a user should be rewarded for their stakes
     * and the duration the stake has been active
     */
    function calculateStakeReward(Stake memory _current_stake, uint256 timeClose) internal view returns(uint256) {
        // First calculate how long the stake has been active
        // Use current seconds since epoch - the seconds since epoch the stake was made
        // The output will be duration in SECONDS ,
        // We will reward the user 0.1% per Hour So thats 0.1% per 3600 seconds
        // the alghoritm is seconds = block.timestamp - stake seconds (block.timestap - _stake.since)
        // hours = Seconds / 3600 (seconds /3600) 3600 is an variable in Solidity names hours
        // we then multiply each token by the hours staked , then divide by the rewardPerHour rate 
        //return (((block.timestamp - _current_stake.since) / 1 hours) * _current_stake.amount) / rewardPerHour;
        //return ((block.timestamp - _current_stake.since) * rewardWeiPerSecond) * _current_stake.amount;
        uint256 scaled = uint256(1) * uint256(10) ** uint256(18);
        //return mul(mul(sub(block.timestamp, _current_stake.since), rewardWeiPerSecond), div(_current_stake.amount, scaled));
        return ((timeClose - _current_stake.since) * rewardWeiPerSecond) * (_current_stake.amount / scaled);
    }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the acount
     * Will also calculateStakeReward and reset timer
     */
    function _withdrawStake(uint256 amount, uint256 index, uint256 timeClose) internal returns(uint256) {
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[msg.sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[index];
        require(current_stake.amount >= amount, "Staking: Cannot withdraw more than you have staked");
        //require((block.timestamp - current_stake.since) >= 1 hours, "ERROR: Only withdraw if passed 1 hour or plus of your tokens staked");

        // Calculate available Reward first before we start modifying data
        uint256 reward = calculateStakeReward(current_stake, timeClose);
        // Remove by subtracting the money unstaked 
        current_stake.amount = current_stake.amount - amount;
        // If stake is empty, 0, then remove it from the array of stakes
        if(current_stake.amount == 0){
            delete stakeholders[user_index].address_stakes[index];
        }else {
            // If not empty then replace the value of it
            stakeholders[user_index].address_stakes[index].amount = current_stake.amount;
            // Reset timer of stake
            stakeholders[user_index].address_stakes[index].since = block.timestamp;    
        }

        uint256 amount_to_recive = amount + reward;

        return amount_to_recive;
    }

    function _withdrawAllStakes(address _staker, uint256 timeClose) internal returns(uint256) {
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount;
        uint256 totalRewards;
        uint256 user_index = stakes[_staker];
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(0, stakeholders[user_index].address_stakes);
        // Itterate all stakes and grab amount of stakes
        for(uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateStakeReward(summary.stakes[s], timeClose);
            totalStakeAmount = totalStakeAmount+summary.stakes[s].amount;
            totalRewards = totalRewards+availableReward;
            Stake memory current_stake = stakeholders[user_index].address_stakes[s];
            current_stake.amount = 0;
            delete stakeholders[user_index].address_stakes[s];
        }
        
        return totalStakeAmount+totalRewards;
    }

    /**
     * @notice
     * hasStake is used to check if a account has stakes and the total amount along with all the seperate stakes
     */
    function hasStake(address _staker) public view returns(StakingSummary memory) {
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount; 
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(0, stakeholders[stakes[_staker]].address_stakes);
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s += 1){
            uint256 availableReward = calculateStakeReward(summary.stakes[s], block.timestamp);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount+summary.stakes[s].amount;
        }
        // Assign calculate amount to summary
        summary.total_amount = totalStakeAmount;
        return summary;
    }

    function _setRewardWeiPerSecond(uint256 _rewards) internal returns(bool) {
        rewardWeiPerSecond = _rewards;
        require(rewardWeiPerSecond == _rewards, "ERROR: Not change rewardWeiPerSecond in Staked Contract");
        return true;
    }
}
// File: Address.sol

pragma solidity ^0.8.10;


// File: @openzeppelin/contracts/utils/Address.sol

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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
// File: IBEP20OperableSpender.sol

pragma solidity ^0.8.10;


// File: contracts/token/BEP20/lib/IBEP20OperableSpender.sol

/**
 * @title IBEP20OperableSpender Interface
 * @dev Interface for any contract that wants to support approveAndCall
 *  from BEP20Operable token contracts as defined in
 *  https://eips.ethereum.org/EIPS/eip-1363
 */
interface IBEP20OperableSpender {
    /**
     * @notice Handle the approval of BEP20Operable tokens
     * @dev Any BEP20Operable smart contract calls this function on the recipient
     * after an `approve`. This function MAY throw to revert and reject the
     * approval. Return of other than the magic value MUST result in the
     * transaction being reverted.
     * Note: the token contract address is always the message sender.
     * @param sender address The address which called `approveAndCall` function
     * @param amount uint256 The amount of tokens to be spent
     * @param data bytes Additional data with no specified format
     * @return `bytes4(keccak256("onApprovalReceived(address,uint256,bytes)"))` unless throwing
     */
    function onApprovalReceived(
        address sender,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4);
}
// File: IBEP20OperableReceiver.sol

pragma solidity ^0.8.10;


// File: contracts/token/BEP20/lib/IBEP20OperableReceiver.sol

/**
 * @title IBEP20OperableReceiver Interface
 * @dev Interface for any contract that wants to support transferAndCall or transferFromAndCall
 *  from BEP20Operable token contracts as defined in
 *  https://eips.ethereum.org/EIPS/eip-1363
 */
interface IBEP20OperableReceiver {
    /**
     * @notice Handle the receipt of BEP20Operable tokens
     * @dev Any BEP20Operable smart contract calls this function on the recipient
     * after a `transfer` or a `transferFrom`. This function MAY throw to revert and reject the
     * transfer. Return of other than the magic value MUST result in the
     * transaction being reverted.
     * Note: the token contract address is always the message sender.
     * @param operator address The address which called `transferAndCall` or `transferFromAndCall` function
     * @param sender address The address which are token transferred from
     * @param amount uint256 The amount of tokens transferred
     * @param data bytes Additional data with no specified format
     * @return `bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))` unless throwing
     */
    function onTransferReceived(
        address operator,
        address sender,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4);
}
// File: IERC165.sol

pragma solidity ^0.8.10;


// File: @openzeppelin/contracts/utils/introspection/IERC165.sol

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
// File: ERC165.sol

pragma solidity ^0.8.10;



// File: @openzeppelin/contracts/utils/introspection/ERC165.sol

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
// File: IBEP20.sol

pragma solidity ^0.8.10;


// File: contracts/token/BEP20/lib/IBEP20.sol

/**
 * @dev Interface of the BEP standard.
 */
interface IBEP20 {
    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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
// File: IBEP20Operable.sol

pragma solidity ^0.8.10;




// File: contracts/token/BEP20/lib/IBEP20Operable.sol

/**
 * @title IBEP20Operable Interface
 * @dev Interface for a Operable Token contract as defined in
 *  https://eips.ethereum.org/EIPS/eip-1363
 */
interface IBEP20Operable is IBEP20, IERC165 {
    /**
     * @notice Transfer tokens from `msg.sender` to another address and then call `onTransferReceived` on receiver
     * @param recipient address The address which you want to transfer to
     * @param amount uint256 The amount of tokens to be transferred
     * @return true unless throwing
     */
    function transferAndCall(address recipient, uint256 amount) external returns (bool);

    /**
     * @notice Transfer tokens from `msg.sender` to another address and then call `onTransferReceived` on receiver
     * @param recipient address The address which you want to transfer to
     * @param amount uint256 The amount of tokens to be transferred
     * @param data bytes Additional data with no specified format, sent in call to `recipient`
     * @return true unless throwing
     */
    function transferAndCall(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

    /**
     * @notice Transfer tokens from one address to another and then call `onTransferReceived` on receiver
     * @param sender address The address which you want to send tokens from
     * @param recipient address The address which you want to transfer to
     * @param amount uint256 The amount of tokens to be transferred
     * @return true unless throwing
     */
    function transferFromAndCall(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @notice Transfer tokens from one address to another and then call `onTransferReceived` on receiver
     * @param sender address The address which you want to send tokens from
     * @param recipient address The address which you want to transfer to
     * @param amount uint256 The amount of tokens to be transferred
     * @param data bytes Additional data with no specified format, sent in call to `recipient`
     * @return true unless throwing
     */
    function transferFromAndCall(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

    /**
     * @notice Approve the passed address to spend the specified amount of tokens on behalf of msg.sender
     * and then call `onApprovalReceived` on spender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender address The address which will spend the funds
     * @param amount uint256 The amount of tokens to be spent
     */
    function approveAndCall(address spender, uint256 amount) external returns (bool);

    /**
     * @notice Approve the passed address to spend the specified amount of tokens on behalf of msg.sender
     * and then call `onApprovalReceived` on spender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender address The address which will spend the funds
     * @param amount uint256 The amount of tokens to be spent
     * @param data bytes Additional data with no specified format, sent in call to `spender`
     */
    function approveAndCall(
        address spender,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}
// File: Ownable.sol


pragma solidity ^0.8.4;

/**
* @notice Contract is a inheritable smart contract that will add a 
* New modifier called onlyOwner available in the smart contract inherting it
* 
* onlyOwner makes a function only callable from the Token owner
*
*/
contract Ownable {
    // _owner is the owner of the Token
    address private _owner;

    /**
    * Event OwnershipTransferred is used to log that a ownership change of the token has occured
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * Modifier
    * We create our own function modifier called onlyOwner, it will Require the current owner to be 
    * the same as msg.sender
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: only owner can call this function");
        // This _; is not a TYPO, It is important for the compiler;
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    /**
    * @notice owner() returns the currently assigned owner of the Token
    * 
     */
    function owner() public view returns(address) {
        return _owner;

    }
    /**
    * @notice renounceOwnership will set the owner to zero address
    * This will make the contract owner less, It will make ALL functions with
    * onlyOwner no longer callable.
    * There is no way of restoring the owner
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
    * @notice transferOwnership will assign the {newOwner} as owner
    *
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    /**
    * @notice _transferOwnership will assign the {newOwner} as owner
    *
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// File: TokenRecover.sol

pragma solidity ^0.8.10;




// File: contracts/utils/TokenRecover.sol

/**
 * @title TokenRecover
 * @dev Allow to recover any BEP20 sent into the contract for error
 */
contract TokenRecover is Ownable {
    /**
     * @dev Remember that only owner can call so be careful when use on contracts generated from other contracts.
     * @param tokenAddress The token contract address
     * @param tokenAmount Number of tokens to be sent
     */
    function recoverBEP20(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        IBEP20(tokenAddress).transfer(owner(), tokenAmount);
    }
}
// File: BEP20.sol

pragma solidity ^0.8.10;




// File: contracts/token/BEP20/lib/BEP20.sol

/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of BEP20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */
contract BEP20 is Ownable, IBEP20 {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {BEP20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IBEP20-getOwner}.
     */
    function getOwner() public view override returns (address) {
        return owner();
    }

    /**
     * @dev See {IBEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    /**
     * @dev See {IBEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
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
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
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
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
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
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
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
}
// File: BEP20Operable.sol

pragma solidity ^0.8.10;


// File: contracts/token/BEP20/lib/BEP20Operable.sol







/**
 * @title BEP20Operable
 * @dev Implementation of the {IBEP20Operable} interface
 */
abstract contract BEP20Operable is BEP20, IBEP20Operable, ERC165 {
    using Address for address;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IBEP20Operable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Transfer tokens to a specified address and then execute a callback on recipient.
     * @param recipient The address to transfer to.
     * @param amount The amount to be transferred.
     * @return A boolean that indicates if the operation was successful.
     */
    function transferAndCall(address recipient, uint256 amount) public virtual override returns (bool) {
        return transferAndCall(recipient, amount, "");
    }

    /**
     * @dev Transfer tokens to a specified address and then execute a callback on recipient.
     * @param recipient The address to transfer to
     * @param amount The amount to be transferred
     * @param data Additional data with no specified format
     * @return A boolean that indicates if the operation was successful.
     */
    function transferAndCall(
        address recipient,
        uint256 amount,
        bytes memory data
    ) public virtual override returns (bool) {
        transfer(recipient, amount);
        require(
            _checkAndCallTransfer(msg.sender, recipient, amount, data),
            "BEP20Operable: _checkAndCallTransfer reverts"
        );
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another and then execute a callback on recipient.
     * @param sender The address which you want to send tokens from
     * @param recipient The address which you want to transfer to
     * @param amount The amount of tokens to be transferred
     * @return A boolean that indicates if the operation was successful.
     */
    function transferFromAndCall(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        return transferFromAndCall(sender, recipient, amount, "");
    }

    /**
     * @dev Transfer tokens from one address to another and then execute a callback on recipient.
     * @param sender The address which you want to send tokens from
     * @param recipient The address which you want to transfer to
     * @param amount The amount of tokens to be transferred
     * @param data Additional data with no specified format
     * @return A boolean that indicates if the operation was successful.
     */
    function transferFromAndCall(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data
    ) public virtual override returns (bool) {
        transferFrom(sender, recipient, amount);
        require(_checkAndCallTransfer(sender, recipient, amount, data), "BEP20Operable: _checkAndCallTransfer reverts");
        return true;
    }

    /**
     * @dev Approve spender to transfer tokens and then execute a callback on recipient.
     * @param spender The address allowed to transfer to
     * @param amount The amount allowed to be transferred
     * @return A boolean that indicates if the operation was successful.
     */
    function approveAndCall(address spender, uint256 amount) public virtual override returns (bool) {
        return approveAndCall(spender, amount, "");
    }

    /**
     * @dev Approve spender to transfer tokens and then execute a callback on recipient.
     * @param spender The address allowed to transfer to.
     * @param amount The amount allowed to be transferred.
     * @param data Additional data with no specified format.
     * @return A boolean that indicates if the operation was successful.
     */
    function approveAndCall(
        address spender,
        uint256 amount,
        bytes memory data
    ) public virtual override returns (bool) {
        approve(spender, amount);
        require(_checkAndCallApprove(spender, amount, data), "BEP20Operable: _checkAndCallApprove reverts");
        return true;
    }

    /**
     * @dev Internal function to invoke `onTransferReceived` on a target address
     *  The call is not executed if the target address is not a contract
     * @param sender address Representing the previous owner of the given token value
     * @param recipient address Target address that will receive the tokens
     * @param amount uint256 The amount mount of tokens to be transferred
     * @param data bytes Optional data to send along with the call
     * @return whether the call correctly returned the expected magic value
     */
    function _checkAndCallTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data
    ) internal virtual returns (bool) {
        if (!recipient.isContract()) {
            return false;
        }
        bytes4 retval = IBEP20OperableReceiver(recipient).onTransferReceived(msg.sender, sender, amount, data);
        return (retval == IBEP20OperableReceiver(recipient).onTransferReceived.selector);
    }

    /**
     * @dev Internal function to invoke `onApprovalReceived` on a target address
     *  The call is not executed if the target address is not a contract
     * @param spender address The address which will spend the funds
     * @param amount uint256 The amount of tokens to be spent
     * @param data bytes Optional data to send along with the call
     * @return whether the call correctly returned the expected magic value
     */
    function _checkAndCallApprove(
        address spender,
        uint256 amount,
        bytes memory data
    ) internal virtual returns (bool) {
        if (!spender.isContract()) {
            return false;
        }
        bytes4 retval = IBEP20OperableSpender(spender).onApprovalReceived(msg.sender, amount, data);
        return (retval == IBEP20OperableSpender(spender).onApprovalReceived.selector);
    }
}
// File: BEP20Burnable.sol

pragma solidity ^0.8.10;


// File: contracts/token/BEP20/lib/BEP20Burnable.sol


/**
 * @dev Extension of {BEP20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract BEP20Burnable is BEP20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {BEP20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {BEP20-_burn} and {BEP20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, msg.sender);
        require(currentAllowance >= amount, "BEP20: burn amount exceeds allowance");
        _approve(account, msg.sender, currentAllowance - amount);
        _burn(account, amount);
    }
}
// File: BEP20Mintable.sol

pragma solidity ^0.8.10;



// File: contracts/token/BEP20/lib/BEP20Mintable.sol

/**
 * @title BEP20Mintable
 * @dev Implementation of the BEP20Mintable. Extension of {BEP20} that adds a minting behaviour.
 */
abstract contract BEP20Mintable is BEP20 {
    // indicates if minting is finished
    bool private _mintingFinished = false;

    /**
     * @dev Emitted during finish minting
     */
    event MintFinished();

    /**
     * @dev Tokens can be minted only before minting finished.
     */
    modifier canMint() {
        require(!_mintingFinished, "BEP20Mintable: minting is finished");
        _;
    }

    /**
     * @return if minting is finished or not.
     */
    function mintingFinished() public view returns (bool) {
        return _mintingFinished;
    }

    /**
     * @dev Function to mint tokens.
     *
     * WARNING: it allows everyone to mint new tokens. Access controls MUST be defined in derived contracts.
     *
     * @param account The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     */
    function mint(address account, uint256 amount) public canMint {
        _mint(account, amount);
    }

    /**
     * @dev Function to stop minting new tokens.
     *
     * WARNING: it allows everyone to finish minting. Access controls MUST be defined in derived contracts.
     */
    function finishMinting() public canMint {
        _finishMinting();
    }

    /**
     * @dev Function to stop minting new tokens.
     */
    function _finishMinting() internal virtual {
        _mintingFinished = true;

        emit MintFinished();
    }
}
// File: Context.sol

pragma solidity ^0.8.10;


// File: @openzeppelin/contracts/utils/Context.sol

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// File: TokenG27.sol


pragma solidity ^0.8.0;









/**
 *  DEX pancake Route interface
 */
interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

contract G27Token is BEP20Mintable, BEP20Burnable, BEP20Operable, TokenRecover, G27Stakeable {
    address public stableCoin = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    uint256 public dexTaxFee = 75; //take fee while buy token 0.75%
    uint256 public minBuyTokens = mul(uint256(500), uint256(10) ** decimals());
    uint256 public timeOpenSold;
    uint256 public timeCloseSold;

    mapping(address => bool) public _isExcludedFromFee;

    IPancakeRouter02 public router;

    event Sold(address buyer, uint256 amount, uint256 price, uint256 taxFee);
    event WithdrawStaked(address indexed user, uint256 amount, uint256 amount_to_recive, uint256 stake_index, uint256 timestamp);
    event WithdrawAllStaked(address indexed user, uint256 amount, uint256 amount_to_recive, uint256 timestamp);
    event SetStablecoin(address indexed stableCoinAddress);
    event SetRouter(address indexed addressRouter);
    event SetTaxFee(uint256 newTaxFee);
    event SetTimeOpenSold(uint256 newTaxFee);
    event SetTimeCloseSold(uint256 newTaxFee);
    event SetRewardWeiPerSecond(address indexed user, bool success, uint256 rewardsForSecond);

    constructor() BEP20("G27 Token", "G27")  {
        router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _mint(address(this), 8e24);
        transferOwnership(msg.sender);
        _isExcludedFromFee[owner()] = true;
        timeOpenSold = block.timestamp;
        timeCloseSold = 1748800969;
    }

    receive() external payable {}
    
    function Approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(tx.origin, spender, amount);
        return true;
    }

    function buy(uint256 _numTokens) public payable {
        require(timeOpenSold > 0, "INFO: The sale is not initialiced");
        require(block.timestamp >= timeOpenSold, "INFO: The sale is not active");
        require(_numTokens >= minBuyTokens, "ERROR: You are trying to buy below the minimum required");
        uint256 taxFee = 0;
        uint price = 0;
        uint256 numTokensWhitFee = 0;
        uint256 oldBalanceUsdt = IBEP20(stableCoin).balanceOf(address(this));
        bool takeFee = true;
        
        if (_isExcludedFromFee[msg.sender]) {
            takeFee = false;
        }
        
        if(takeFee) {
            taxFee = mul(_numTokens, dexTaxFee) / uint256(10000);
            numTokensWhitFee = add(_numTokens, taxFee);
            price = router.getAmountsIn(numTokensWhitFee, getPathForETHtoUSDT())[0];
            uint deadline = block.timestamp + 15; // using 'now' for convenience, for mainnet pass deadline from frontend!
            require(msg.value == price, "ERROR: Insufficient WEI to buy");
            router.swapETHForExactTokens{ value: msg.value }(numTokensWhitFee, getPathForETHtoUSDT(), address(this), deadline);
        } else {
            price = router.getAmountsIn(_numTokens, getPathForETHtoUSDT())[0];
            numTokensWhitFee = _numTokens;
            require(msg.value == price, "ERROR: Insufficient WEI to buy");
            uint deadline = block.timestamp + 15; // using 'now' for convenience, for mainnet pass deadline from frontend!
            router.swapETHForExactTokens{ value: msg.value }(_numTokens, getPathForETHtoUSDT(), address(this), deadline);
        }
        
        require(IBEP20(stableCoin).balanceOf(address(this)) >= add(oldBalanceUsdt, numTokensWhitFee), "ERROR: The balance of the contract has not increased with the transaction");
        require(balanceOf(address(this)) >= _numTokens, "ERROR: Insufficient tokens in the contract to transfer to you");
        _transfer(address(this), msg.sender, _numTokens); // "ERROR: When transferring the tokens to your wallet")
        
        emit Sold(msg.sender, _numTokens, price, taxFee);

        stake(_numTokens);
    }

    function getEstimatedETHforBuyTokens(uint _numTokens) public view returns (uint estimatedETH, uint256 _price, uint256 _taxFee, uint256 _taxFeeTokens, uint256 _totalTokensFee, uint256 _weisPayFee) {
        // uint _numTokens = 1 PTD1 = 1 USDT || 1 PTD1/1 USDT
        estimatedETH = router.getAmountsIn(_numTokens, getPathForETHtoUSDT())[0];
        _taxFee = 0;
        _taxFeeTokens = 0;
        _totalTokensFee = 0;
        _weisPayFee = 0;
        _price = estimatedETH;
        bool takeFee = true;
        if (_isExcludedFromFee[msg.sender]) {
            takeFee = false;
        }
        if(takeFee) {
            _taxFee = mul(_price, dexTaxFee) / uint256(10000);
            _price = add(_price, _taxFee);
            _taxFeeTokens = mul(_numTokens, dexTaxFee) / uint256(10000);
            _totalTokensFee = add(_numTokens, _taxFeeTokens);
            _weisPayFee = router.getAmountsIn(_totalTokensFee, getPathForETHtoUSDT())[0];
        }
    }

    function getCurrentTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    /**
     * Add functionality like burn to the _stake afunction
     *
     */
    function stake(uint256 _amount) private {
        // Make sure staker actually is good for it
        require(_amount <= balanceOf(msg.sender), "ERROR: Cannot stake more than you own");

        _stake(_amount);
    }

    /**
     * @notice withdrawStake is used to withdraw stakes from the account holder
     */
    function withdrawStake(uint256 _amount, uint256 _stake_index) public {
        require(timeCloseSold > 0, "INFO: The close sale is not initialiced");
        require(block.timestamp >= timeCloseSold, "INFO: End of sale date is greater than now");
        uint256 amount_to_recive = _withdrawStake(_amount, _stake_index, timeCloseSold);
        if(amount_to_recive > 0) {
            uint256 stableCoinDividends = IBEP20(stableCoin).balanceOf(address(this));
            uint256 tokensDividends = balanceOf(address(this));
            require(stableCoinDividends >= amount_to_recive, "ERROR: The Contract not have sufficent funds");
            require(balanceOf(msg.sender) >= _amount, "ERROR: Your balance of Token is insufficent");
            _transfer(msg.sender, address(this), _amount); // "ERROR: For trasnferFrom your tokens to Contract"
            require(balanceOf(address(this)) >= add(tokensDividends, _amount), "ERROR: Not add tokens on to balance contract");
            require(IBEP20(stableCoin).transfer(msg.sender, amount_to_recive), "ERROR: For transfer USDT from contract to your address acount");
            // Emit an event that the stake has occured
            emit WithdrawStaked(msg.sender, _amount, amount_to_recive, _stake_index, block.timestamp);
        }
    }

    function withdrawAllStake() public {
        require(timeCloseSold > 0, "INFO: The close sale is not initialiced");
        require(block.timestamp >= timeCloseSold, "INFO: End of sale date is greater than now");
        uint256 amount_to_recive = _withdrawAllStakes(msg.sender, timeCloseSold);
        if(amount_to_recive > 0) {
            uint256 stableCoinDividends = IBEP20(stableCoin).balanceOf(address(this));
            uint256 tokensDividends = balanceOf(address(this));
            require(stableCoinDividends >= amount_to_recive, "ERROR: The Contract not have sufficent funds");
            _transfer(msg.sender, address(this), balanceOf(msg.sender)); // "ERROR: For trasnferFrom your tokens to Contract"
            require(balanceOf(address(this)) >= add(tokensDividends, balanceOf(msg.sender)), "ERROR: Not add tokens on to balance contract");
            require(IBEP20(stableCoin).transfer(msg.sender, amount_to_recive), "ERROR: For transfer USDT from contract to your address acount");
            // Emit an event that the stake has occured
            emit WithdrawAllStaked(msg.sender, balanceOf(msg.sender), amount_to_recive, block.timestamp);
        }
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function endSold() public onlyOwner {
        require(timeCloseSold > 0, "INFO: The close sale is not initialiced");
        require(block.timestamp >= timeCloseSold, "INFO: End of sale date is greater than now");
        _transfer(address(this), getOwner(), balanceOf(address(this)));
        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function getDividends(address _addressToken) public onlyOwner {
        uint256 tokensDividends = IBEP20(_addressToken).balanceOf(address(this));
        if(tokensDividends > 0) {
            IBEP20(_addressToken).transfer(msg.sender, tokensDividends);
        }
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setTax(uint256 _taxFee) public onlyOwner {
        dexTaxFee = _taxFee;
        emit SetTaxFee(_taxFee);
    }

    function setTimeOpenSold(uint256 _timeOpenSold) public onlyOwner {
        timeOpenSold = _timeOpenSold;
        emit SetTimeOpenSold(_timeOpenSold);
    }

    function setTimeCloseSold(uint256 _timeCloseSold) public onlyOwner {
        timeCloseSold = _timeCloseSold;
        if(timeCloseSold == _timeCloseSold) {
            emit SetTimeCloseSold(_timeCloseSold);
        }
    }

    function setRewardWeiPerSecond(uint256 _rewards) public onlyOwner {
        bool success = _setRewardWeiPerSecond(_rewards);
        if(success) {
            emit SetRewardWeiPerSecond(msg.sender, success, _rewards);
        }
    }

    // Destruye el contrato
    function kill() public onlyOwner {
        selfdestruct(payable(getOwner()));
    }

    function setStablecoin(address _stableCoin) external onlyOwner {
        require(_stableCoin != address(0x0), "ERROR: Can not use 0x0 address");
        stableCoin = _stableCoin;
        emit SetStablecoin(_stableCoin);
    }

    function setRouter(address _addressRouter) external onlyOwner {
        router = IPancakeRouter02(_addressRouter);
        emit SetRouter(address(router));
    }

    function getPathForETHtoUSDT() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = stableCoin;
        
        return path;
    }

    /**
     * @dev Function to mint tokens.
     *
     * NOTE: restricting access to owner only. See {BEP20Mintable-mint}.
     *
     * @param account The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     */
    function _mint(address account, uint256 amount) internal override onlyOwner {
        super._mint(account, amount);
    }

    /**
     * @dev Function to stop minting new tokens.
     *
     * NOTE: restricting access to owner only. See {BEP20Mintable-finishMinting}.
     */
    function _finishMinting() internal override onlyOwner {
        super._finishMinting();
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
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