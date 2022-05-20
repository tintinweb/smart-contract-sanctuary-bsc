/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// File: @chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol

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

// File: @chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol


pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
}

// File: @chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol


pragma solidity ^0.8.0;

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
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
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
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

// File: contracts/Ownable.sol


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

// File: contracts/Stakeable.sol


pragma solidity ^0.8.4;

/**
* @notice Stakeable is a contract who is ment to be inherited by other contract that wants Staking capabilities
*/
contract Stakeable {


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
      rewardPerHour is 1000 because it is used to represent 0.001, since we only use integer numbers
      This will give users 0.1% reward for each staked token / H
     */
    uint256 internal rewardPerHour = 1000;

    /**
    * @notice _addStakeholder takes care of adding a stakeholder to the stakeholders array
     */
    function _addStakeholder(address staker) internal returns (uint256){
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
    function _stake(uint256 _amount) internal{
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
        stakeholders[index].address_stakes.push(Stake(msg.sender, _amount, timestamp,0));
        // Emit an event that the stake has occured
        emit Staked(msg.sender, _amount, index,timestamp);
    }

    /**
      * @notice
      * calculateStakeReward is used to calculate how much a user should be rewarded for their stakes
      * and the duration the stake has been active
     */
    function calculateStakeReward(Stake memory _current_stake) internal view returns(uint256){
        // First calculate how long the stake has been active
        // Use current seconds since epoch - the seconds since epoch the stake was made
        // The output will be duration in SECONDS ,
        // We will reward the user 0.1% per Hour So thats 0.1% per 3600 seconds
        // the alghoritm is  seconds = block.timestamp - stake seconds (block.timestap - _stake.since)
        // hours = Seconds / 3600 (seconds /3600) 3600 is an variable in Solidity names hours
        // we then multiply each token by the hours staked , then divide by the rewardPerHour rate
        return (((block.timestamp - _current_stake.since) / 1 hours) * _current_stake.amount) / rewardPerHour;
    }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the acount
     * Will also calculateStakeReward and reset timer
    */
    function _withdrawStake(uint256 amount, uint256 index) internal returns(uint256){
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[msg.sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[index];
        require(current_stake.amount >= amount, "Staking: Cannot withdraw more than you have staked");

        // Calculate available Reward first before we start modifying data
        uint256 reward = calculateStakeReward(current_stake);
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

        return amount+reward;
    }

    /**
    * @notice
     * hasStake is used to check if a account has stakes and the total amount along with all the seperate stakes
     */
    function hasStake(address _staker) public view returns(StakingSummary memory){
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount;
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(0, stakeholders[stakes[_staker]].address_stakes);
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s += 1){
            uint256 availableReward = calculateStakeReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount+summary.stakes[s].amount;
        }
        // Assign calculate amount to summary
        summary.total_amount = totalStakeAmount;
        return summary;
    }
}

// File: contracts/Campaigns.sol


pragma solidity ^0.8.4;

struct Campaigns {
    mapping(int => Campaign) campaigns;
}

struct Campaign {
    int id;
    Milestone[] milestones;
    mapping(address => uint256) tokensLocked;
    uint256 totalTokensLocked;
    uint256 totalRequiredAmount;
    uint256 softCapacity;
    uint256 deadline;
    address[] backers;
    address owner;
    int currentMilestone;
    bool withdrawn;
}

struct Milestone {
    uint256 requiredAmount;
    uint256 deadline;
    mapping(address => int) votes;
    address[] yesVoters;
    address[] noVoters;
    bool randomed;
    bool withdrawn;
}

library Crowdfunding {

    /**
        * @notice below are debug events
    */
    event DebugTimestamp(uint256 time1, uint256 time2);

    event DebugVote(uint256 votes1, uint256 votes2);

    event DebugForWithdraw(address backer, uint backerLocked, uint totalLocked, uint totalRequired, uint toBeDeducted);

    event DebugBool(bool res);

    event DebugUint(uint num);

    /**
        * @notice below are real events
    */
    event Vote(address from, int campaignId, bool consent);

    event Withdraw(address owner, int campaignId, int milestoneIdx, uint total);

    event Back(address from, int campaignId, uint256 amount);

    event Refund(address to, int campaignId, uint256 amount);

    event Random(int campaignId, int milestoneIdx, address[] voters);

    event CreateCampaign(address owner, int campaignId, uint256 totalTokensRequired, uint256 numberOfMilestones);

    function getBackers(
        Campaigns storage campaigns,
        int campaignId
    ) internal view returns (address[] memory) {
        Campaign storage campaign = campaigns.campaigns[campaignId];

        require(campaign.owner != address(0), "campaign not found");

        return campaign.backers;
    }

    function getCurrentMilestone(
        Campaigns storage campaigns,
        int campaignId
    ) internal view returns (int) {
        Campaign storage campaign = campaigns.campaigns[campaignId];

        require(campaign.owner != address(0), "campaign not found");

        return campaign.currentMilestone;
    }

    function getWithdrawInfo(
        Campaigns storage campaigns,
        int campaignId
    ) internal view returns (bool[] memory) {
        Campaign storage campaign = campaigns.campaigns[campaignId];

        require(campaign.owner != address(0), "campaign not found");

        bool[] memory withdrawInfo = new bool[](campaign.milestones.length + 1);

        withdrawInfo[0] = campaign.withdrawn;

        for (uint u = 0; u < campaign.milestones.length; u++) {
            withdrawInfo[u + 1] = campaign.milestones[u].withdrawn;
        }

        return withdrawInfo;
    }

    function getTotalNeeded(
        Campaigns storage campaigns,
        int campaignId
    ) internal view returns (uint256) {
        Campaign storage campaign = campaigns.campaigns[campaignId];
        require(campaign.owner != address(0), "campaign not found");

        return campaign.totalRequiredAmount;
    }

    function getRandomedVoters(
        Campaigns storage campaigns,
        int milestoneIdx,
        int campaignId
    ) internal view returns (address[] memory) {
        Campaign storage campaign = campaigns.campaigns[campaignId];
        require(campaign.owner != address(0), "campaign not found");

        Milestone storage milestone = campaign.milestones[uint256(milestoneIdx)];

        address[] memory randomedVoters = new address[](campaign.backers.length / 2);
        uint randomedVotersIdx = 0;

        for (uint u = 0; u < campaign.backers.length; u++) {
            if (milestone.votes[campaign.backers[u]] != 0) {
                randomedVoters[randomedVotersIdx] = campaign.backers[u];
                randomedVotersIdx += 1;
            }
        }

        return randomedVoters;
    }

    /**
        * @notice below are codes related to campaigns and milestones
    */
    function getTotalLocked(
        Campaigns storage campaigns,
        int campaignId
    ) internal view returns (uint256 tokensLocked) {
        Campaign storage campaign = campaigns.campaigns[campaignId];

        require(campaign.owner != address(0), "campaign not found");

        return campaign.totalTokensLocked;
    }

    function createCampaign(
        Campaigns storage campaigns,
        address account,
        int campaignId,
        uint256 deadline,
        uint256 softCapacity,
        uint256[] memory milestoneDeadlines,
        uint256[] memory milestoneTokens
    ) internal {
        if (milestoneDeadlines.length != milestoneTokens.length) {
            revert("unsync data");
        }

        Campaign storage newCampaign = campaigns.campaigns[campaignId];

        newCampaign.totalRequiredAmount = softCapacity;
        newCampaign.id = campaignId;
        newCampaign.owner = account;
        newCampaign.softCapacity = softCapacity;
        newCampaign.deadline = deadline;

        for (uint u = 0; u < milestoneDeadlines.length; u++) {
            Milestone storage newMilestone = newCampaign.milestones.push();
            newMilestone.deadline = milestoneDeadlines[u];
            newMilestone.requiredAmount = milestoneTokens[u];
            newCampaign.totalRequiredAmount += milestoneTokens[u];
        }

        emit CreateCampaign(account, newCampaign.id, newCampaign.totalRequiredAmount, milestoneDeadlines.length);
    }

    function backCampaign(
        Campaigns storage campaigns,
        address account,
        int campaignId,
        uint256 tokens
    ) internal returns (Campaign storage) {
        Campaign storage campaign = campaigns.campaigns[campaignId];

        require(campaign.owner != address(0), "campaign not found");
        require(block.timestamp <= campaign.deadline, "cannot back campaign that reaches deadline");

        if (campaign.tokensLocked[account] == 0) {
            campaign.backers.push(account);
        }

        campaign.tokensLocked[account] += tokens;
        campaign.totalTokensLocked += tokens;

        emit Back(account, campaignId, tokens);

        return campaign;
    }

    /**
        * @notice below is code related to randoming voters
        * 0 represents an account that has no permission to vote
        * 1 represents an account that has permission to vote but has not voted
        * 2 represents an account that voted
    */
    function startRandomVoters(
        Campaigns storage campaigns,
        address[] memory accounts,
        int milestoneIdx,
        int campaignId
    ) internal {
        Campaign storage campaign = campaigns.campaigns[campaignId];
        require(campaign.owner != address(0), "campaign not found");
        require(campaign.deadline < block.timestamp, "deadline is not reached yet");

        Milestone storage milestone = campaign.milestones[uint256(milestoneIdx)];
        require(milestoneIdx == campaign.currentMilestone, "milestone is not reached");
        require(milestone.randomed == false, "campaign voters are already randomed");

        for (uint u = 0; u < accounts.length; u++) {
            milestone.votes[accounts[u]] = 1;
        }

        campaign.currentMilestone += 1;
        milestone.randomed = true;

        emit Random(campaignId, milestoneIdx, accounts);
    }

    function withdraw(
        Campaigns storage campaigns,
        address account,
        int milestoneIdx,
        int campaignId
    ) internal returns (uint total) {
        Campaign storage campaign = campaigns.campaigns[campaignId];
        require(campaign.owner == account, "you are not the owner of the campaign");
        require(campaign.deadline < block.timestamp, "deadline is not reached yet");

        if (milestoneIdx == -1) {
            require(campaign.currentMilestone == 1, "voters on first milestone need to be randomed first");
            Milestone storage firstMilestone = campaign.milestones[0];
            require(firstMilestone.randomed == true);
            require(campaign.withdrawn == false, "campaign initial tokens are already withdrawn");

            emit Withdraw(account, campaignId, milestoneIdx, uint(campaign.softCapacity));
            campaign.withdrawn = true;

            return uint(campaign.softCapacity);
        }

        Milestone storage milestone = campaign.milestones[uint256(milestoneIdx)];
        (,,bool consensusReached) = getVoteDetails(campaigns, milestoneIdx, campaignId);
        require(consensusReached == true, "consensus is not reached");
        require(milestone.withdrawn == false, "milestone tokens are already withdrawn");

        milestone.withdrawn = true;

        uint totalForWithdrawal = 0;
        if (campaign.currentMilestone == int256(campaign.milestones.length)) {
            totalForWithdrawal = campaign.totalTokensLocked;
            campaign.totalTokensLocked = 0;
            emit Withdraw(account, campaignId, milestoneIdx, totalForWithdrawal);
            return totalForWithdrawal;
        }

        for (uint u = 0; u < campaign.backers.length; u++) {
            address backer = campaign.backers[u];
            uint toBeDeducted = uint(campaign.tokensLocked[backer]) * uint(milestone.requiredAmount) / uint(campaign.totalTokensLocked);
            campaign.tokensLocked[backer] -= toBeDeducted;
            totalForWithdrawal += toBeDeducted;
        }

        campaign.totalTokensLocked -= totalForWithdrawal;

        emit Withdraw(account, campaignId, milestoneIdx, totalForWithdrawal);
        return totalForWithdrawal;
    }

    function vote(
        Campaigns storage campaigns,
        address account,
        int milestoneIdx,
        int campaignId,
        bool consent
    ) internal {
        Campaign storage campaign = campaigns.campaigns[campaignId];
        require(campaign.owner != address(0), "campaign not found");
        require(campaign.deadline < block.timestamp, "campaign deadline is not reached yet");

        Milestone storage milestone = campaign.milestones[uint256(milestoneIdx)];
        require(milestone.randomed == true, "campaign voters are not yet randomed");
        require(milestoneIdx == campaign.currentMilestone - 1, "milestone is not reached");

        int voteStatus = milestone.votes[account];
        require(voteStatus != 0, "you have no permission to vote");
        require(voteStatus != 2, "you already voted");

        if (consent == true) {
            milestone.yesVoters.push(account);
        } else {
            milestone.noVoters.push(account);
        }

        milestone.votes[account] = 2;

        emit Vote(account, campaignId, consent);
    }

    function getVoteDetails(
        Campaigns storage campaigns,
        int milestoneIdx,
        int campaignId
    ) internal view returns (address[] memory, address[] memory, bool) {
        Campaign storage campaign = campaigns.campaigns[campaignId];
        require(campaign.owner != address(0), "campaign not found");
        require(campaign.deadline < block.timestamp, "deadline is not reached yet");

        Milestone storage milestone = campaign.milestones[uint256(milestoneIdx)];
        require(milestone.randomed == true, "campaign voters are not yet randomed");

        bool consensusReached = milestone.yesVoters.length >= uint256(campaign.backers.length / 4);

        return (milestone.yesVoters, milestone.noVoters, consensusReached);
    }

    function requestRefund(
        Campaigns storage campaigns,
        address account,
        int campaignId
    ) internal returns (uint256 refund) {
        Campaign storage campaign = campaigns.campaigns[campaignId];
        isCampaignFailed(campaigns, campaignId);

        require(campaign.tokensLocked[account] > 0, "cannot request refund when no tokens are locked");

        uint256 tokens = campaign.tokensLocked[account];
        campaign.tokensLocked[account] = 0;
        campaign.totalTokensLocked = campaign.totalTokensLocked - tokens;

        emit Refund(account, campaignId, tokens);

        return tokens;
    }

    function isCampaignFailed(
        Campaigns storage campaigns,
        int campaignId
    ) internal view {
        Campaign storage campaign = campaigns.campaigns[campaignId];
        require(campaign.owner != address(0), "campaign not found");

        Milestone[] storage milestones = campaign.milestones;
        if (campaign.deadline < block.timestamp && campaign.totalTokensLocked >= campaign.softCapacity) {
            bool success = true;
            for (uint u = 0; u < milestones.length; u++) {
                if (milestones[u].deadline < block.timestamp && milestones[u].yesVoters.length < uint256(campaign.backers.length / 4)) {
                    success = false;
                    break;
                }
            }

            if (success == true) {
                revert("campaign succeeds");
            }
        }
    }
}

// File: contracts/Glasslink.sol


pragma solidity ^0.8.4;





/**
* @notice GlasslinkToken is a development token that we use for the glasslink website
* and what BEP-20 interface requires
*/
contract Glasslink is Ownable, Stakeable, VRFConsumerBaseV2 {

    /**
    * @notice below is token related to campaigns
    */

    using Crowdfunding for Campaigns;
    Campaigns private campaigns;

    mapping(address => uint) accountNumberOfBacks;
    mapping(address => uint) accountNumberOfTokensBacked;

    function getWithdrawInfo(int campaignId) public view returns (bool[] memory) {
        return campaigns.getWithdrawInfo(campaignId);
    }

    function getCurrentMilestone(int campaignId) public view returns (int) {
        return campaigns.getCurrentMilestone(campaignId);
    }

    function getTotalNeeded(int campaignId) public view returns (uint256) {
        return campaigns.getTotalNeeded(campaignId);
    }

    function getRandomedVoters(int milestoneIdx, int campaignId) public view returns (address[] memory) {
        return campaigns.getRandomedVoters(milestoneIdx, campaignId);
    }

    function createCampaign(int campaignId, uint256 deadline, uint256 softCapacity, uint256[] memory milestoneDeadlines, uint256[] memory milestoneTokens) public {
        return campaigns.createCampaign(msg.sender, campaignId, deadline, softCapacity, milestoneDeadlines, milestoneTokens);
    }

    function backCampaign(int campaignId, uint256 amount) public {
        require(_balances[msg.sender] >= amount, "GlasslinkToken: cant back more than your account holds");
        campaigns.backCampaign(msg.sender, campaignId, amount);
        _balances[msg.sender] = _balances[msg.sender] - amount;

        accountNumberOfBacks[msg.sender] += 1;
        accountNumberOfTokensBacked[msg.sender] += amount;
    }

    function withdraw(int milestoneIdx, int campaignId) public {
        uint totalForWithdrawal = campaigns.withdraw(msg.sender, milestoneIdx, campaignId);
        _balances[msg.sender] = _balances[msg.sender] + totalForWithdrawal;
    }

    function requestRefundFromCampaign(int campaignId) public {
        uint256 amount = campaigns.requestRefund(msg.sender, campaignId);
        _balances[msg.sender] = _balances[msg.sender] + amount;
    }

    function getTotalLockedInCampaign(int campaignId) public view returns (uint256 tokensLocked) {
        return campaigns.getTotalLocked(campaignId);
    }

    function testRandomVoters(address[] memory backers) public view returns (address[] memory) {
        return getRandomVoters(backers, true);
    }

    function testRequestRandomSeed() public returns (uint256 requestId) {
        return requestRandomSeed();
    }

    function startRandomVoters(int milestoneIdx, int campaignId, bool isProduction) public onlyOwner {
        address[] memory backers = campaigns.getBackers(campaignId);
        address[] memory voters = getRandomVoters(backers, isProduction);
        return campaigns.startRandomVoters(voters, milestoneIdx, campaignId);
    }

    function vote(int milestoneIdx, int campaignId, bool consent) public {
        return campaigns.vote(msg.sender, milestoneIdx, campaignId, consent);
    }

    function getVoteDetails(int milestoneIdx, int campaignId) public view returns (address[] memory, address[] memory, bool) {
        return campaigns.getVoteDetails(milestoneIdx, campaignId);
    }

    /**
        * @notice below is code related to CHAIN-LINK
    */

    function getRandomVoters(address[] memory backers, bool isProduction) public view returns (address[] memory) {
        uint256[] memory seeds = getSeeds(uint256(backers.length / 2));
        address[] memory copiedBackers = new address[](backers.length);
        address[] memory votersRandomed = new address[](uint256(backers.length / 2));

        for (uint u = 0; u < uint256(backers.length); u++) {
            copiedBackers[u] = backers[u];
        }

        uint256 copiedBackersLength = copiedBackers.length;
        uint256 votersRandomedLength = 0;
        while(votersRandomedLength < uint256(backers.length / 2)) {
            uint[] memory weights = getWeights(backers, copiedBackersLength);

            uint randomNumber;
            if (isProduction) {
                randomNumber = seeds[votersRandomedLength] % (weights.length - 1) + 1;
            }

            uint chosen = search(weights, randomNumber);
            address chosenVoter = copiedBackers[chosen];
            remove(copiedBackers, chosen);
            votersRandomed[votersRandomedLength] = chosenVoter;

            votersRandomedLength += 1;
            copiedBackersLength -= 1;
        }

        return votersRandomed;
    }

    function search(uint[] memory weights, uint target) internal pure returns (uint) {
        if (target < weights[0]) {
            return 0;
        }

        for (uint u = 1; u < uint256(weights.length); u++) {
            if (weights[u] >= target && weights[u - 1] < target) {
                return u;
            }
        }

        return weights[weights.length - 1];
    }

    /**
    * @notice below is token related to getting weight
    * we calculate weights out of 9
    * 4/10 is from the number of backs
    * 4/10 is from the number of tokens backed
    * 1 is given for free
    */
    function getWeights(address[] memory backers, uint256 backersLength) internal view returns (uint[] memory) {
        uint[] memory weights = new uint[](backersLength);
        uint totalBacks = getTotalBacks(backers, backersLength);
        uint totalTokensBacked = getTotalTokensBacked(backers, backersLength);

        for (uint u = 0; u < backersLength; u++) {
            uint weight = 1;

            uint256 a = 1;
            uint256 b = 2;
            a/b;

            if (totalBacks != 0) {
                weight += uint256(accountNumberOfBacks[backers[u]] / (totalBacks * 4));
            }

            if (totalTokensBacked != 0) {
                weight += (accountNumberOfTokensBacked[backers[u]] / totalTokensBacked) * 4;
            }

            if (u == 0) {
                weights[u] = weight;
            } else {
                weights[u] = weight + weights[u - 1];
            }
        }

        return weights;
    }

    bytes32 keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
    uint64 s_subscriptionId = 281;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    function getSeeds(uint256 n) internal view returns (uint256[] memory) {
        uint256[] memory expandedValues = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            expandedValues[i] = uint256(keccak256(abi.encode(randomSeed, i)));
        }
        return expandedValues;
    }

    function requestRandomSeed() public onlyOwner returns (uint256) {
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        return requestId;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        randomSeed = randomWords[0];
    }

    function getTotalBacks(address[] memory backers, uint256 backersLength) view internal returns (uint) {
        uint total = 0;
        for (uint u = 0; u < backersLength; u++) {
            total += accountNumberOfBacks[backers[u]];
        }
        return total;
    }

    function getTotalTokensBacked(address[] memory backers, uint256 backersLength) internal view returns (uint) {
        uint total = 0;
        for (uint u = 0; u < backersLength; u++) {
            total += accountNumberOfTokensBacked[backers[u]];
        }
        return total;
    }

    function remove(address[] memory arr, uint index) internal pure returns (address[] memory) {
        if (index >= arr.length) return arr;

        for (uint i = index; i < arr.length-1; i++){
            arr[i] = arr[i+1];
        }
        delete arr[arr.length-1];
        return arr;
    }

    /**
    * @notice below is token related to campaigns
    */

    uint private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    /**
    * @notice _balances is a mapping that contains a address as KEY
  * and the balance of the address as the value
  */
    mapping (address => uint256) private _balances;
    /**
    * @notice _allowances is used to manage and control allownace
  * An allowance is the right to use another accounts balance, or part of it
   */
    mapping (address => mapping (address => uint256)) private _allowances;

    /**
    * @notice Events are created below.
  * Transfer event is a event that notify the blockchain that a transfer of assets has taken place
  *
  */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /**
     * @notice Approval is emitted when a new Spender is approved to spend Tokens on
   * the Owners account
   */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINKTOKEN;

    address vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;
    address linkTokenAddress = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;
    uint256 internal vrfFee = 0.005 * 10 ** 18;
    uint256 public randomSeed;

    /**
    * @notice constructor will be triggered when we create the Smart contract
  * _name = name of the token
  * _short_symbol = Short Symbol name for the token
  * token_decimals = The decimal precision of the Token, defaults 18
  * _totalSupply is how much Tokens there are totally
  */
    constructor(string memory token_name, string memory short_symbol, uint8 token_decimals, uint256 token_totalSupply)
    VRFConsumerBaseV2(vrfCoordinator)
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(linkTokenAddress);

        _name = token_name;
        _symbol = short_symbol;
        _decimals = token_decimals;
        _totalSupply = token_totalSupply;

        // Add all the tokens created to the creator of the token
        _balances[msg.sender] = _totalSupply;

        // Emit an Transfer event to notify the blockchain that an Transfer has occured
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    /**
    * @notice decimals will return the number of decimal precision the Token is deployed with
  */
    function decimals() external view returns (uint8) {
        return _decimals;
    }
    /**
    * @notice symbol will return the Token's symbol
  */
    function symbol() external view returns (string memory){
        return _symbol;
    }
    /**
    * @notice name will return the Token's symbol
  */
    function name() external view returns (string memory){
        return _name;
    }
    /**
    * @notice totalSupply will return the tokens total supply of tokens
  */
    function totalSupply() external view returns (uint256){
        return _totalSupply;
    }
    /**
    * @notice balanceOf will return the account balance for the given account
  */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /**
    * @notice _mint will create tokens on the address inputted and then increase the total supply
  *
  * It will also emit an Transfer event, with sender set to zero address (adress(0))
  *
  * Requires that the address that is recieveing the tokens is not zero address
  */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "GlasslinkToken: cannot mint to zero address");

        // Increase total supply
        _totalSupply = _totalSupply + (amount);
        // Add amount to the account balance using the balance mapping
        _balances[account] = _balances[account] + amount;
        // Emit our event to log the action
        emit Transfer(address(0), account, amount);
    }
    /**
    * @notice _burn will destroy tokens from an address inputted and then decrease total supply
  * An Transfer event will emit with receiever set to zero address
  *
  * Requires
  * - Account cannot be zero
  * - Account balance has to be bigger or equal to amount
  */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "GlasslinkToken: cannot burn from zero address");
        require(_balances[account] >= amount, "GlasslinkToken: Cannot burn more than the account owns");

        // Remove the amount from the account balance
        _balances[account] = _balances[account] - amount;
        // Decrease totalSupply
        _totalSupply = _totalSupply - amount;
        // Emit event, use zero address as reciever
        emit Transfer(account, address(0), amount);
    }
    /**
    * @notice burn is used to destroy tokens on an address
  *
  * See {_burn}
  * Requires
  *   - msg.sender must be the token owner
  *
   */
    function burn(address account, uint256 amount) public onlyOwner returns(bool) {
        _burn(account, amount);
        return true;
    }

    /**
  * @notice mint is used to create tokens and assign them to msg.sender
  *
  * See {_mint}
  * Requires
  *   - msg.sender must be the token owner
  *
   */
    function mint(address account, uint256 amount) public onlyOwner returns(bool){
        _mint(account, amount);
        return true;
    }

    /**
    * @notice transfer is used to transfer funds from the sender to the recipient
  * This function is only callable from outside the contract. For internal usage see
  * _transfer
  *
  * Requires
  * - Caller cannot be zero
  * - Caller must have a balance = or bigger than amount
  *
   */
    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    /**
    * @notice _transfer is used for internal transfers
  *
  * Events
  * - Transfer
  *
  * Requires
  *  - Sender cannot be zero
  *  - recipient cannot be zero
  *  - sender balance most be = or bigger than amount
   */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "GlasslinkToken: transfer from zero address");
        require(recipient != address(0), "GlasslinkToken: transfer to zero address");
        require(_balances[sender] >= amount, "GlasslinkToken: cant transfer more than your account holds");

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;

        emit Transfer(sender, recipient, amount);
    }
    /**
    * @notice getOwner just calls Ownables owner function.
  * returns owner of the token
  *
   */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
    * @notice allowance is used view how much allowance an spender has
   */
    function allowance(address owner, address spender) external view returns(uint256){
        return _allowances[owner][spender];
    }

    /**
    * @notice approve will use the senders address and allow the spender to use X amount of tokens on his behalf
  */
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
    * @notice _approve is used to add a new Spender to a Owners account
   *
   * Events
   *   - {Approval}
   *
   * Requires
   *   - owner and spender cannot be zero address
    */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "GlasslinkToken: approve cannot be done from zero address");
        require(spender != address(0), "GlasslinkToken: approve cannot be to zero address");
        // Set the allowance of the spender address at the Owner mapping over accounts to the amount
        _allowances[owner][spender] = amount;

        emit Approval(owner,spender,amount);
    }

    /**
    * @notice transferFrom is uesd to transfer Tokens from a Accounts allowance
    * Spender address should be the token holder
    *
    * Requires
    *   - The caller must have a allowance = or bigger than the amount spending
     */
    function transferFrom(address spender, address recipient, uint256 amount) external returns(bool){
        // Make sure spender is allowed the amount
        require(_allowances[spender][msg.sender] >= amount, "GlasslinkToken: You cannot spend that much on this account");
        // Transfer first
        _transfer(spender, recipient, amount);
        // Reduce current allowance so a user cannot respend
        _approve(spender, msg.sender, _allowances[spender][msg.sender] - amount);
        return true;
    }

    /**
    * @notice increaseAllowance
    * Adds allowance to a account from the function caller address
    */
    function increaseAllowance(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender]+amount);
        return true;
    }

    /**
    * @notice decreaseAllowance
  * Decrease the allowance on the account inputted from the caller address
   */
    function decreaseAllowance(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender]-amount);
        return true;
    }
}