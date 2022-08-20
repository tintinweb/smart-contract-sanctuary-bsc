// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "./interfaces/IVe.sol";
import "./interfaces/IVoterProxy.sol";
import "./interfaces/IVotingSnapshot.sol";
import "./interfaces/IVlUnkwn.sol";
import "./interfaces/IController.sol";
import "./interfaces/IVoter.sol";
import "./libraries/BinarySearch.sol";
import "./libraries/Math.sol";
import "./GovernableImplementation.sol";
import "./ProxyImplementation.sol";

/**
 * @author Unknown
 * @title On-chain voting snapshot for DYST emissions
 * @dev Rules:
 *        - Users vote using their vote locked OXD (vlOXD) balance
 *        - Users can vote and change their votes at any time
 *        - Users can vote for up to `maxVotesPerAccount` pools
 *        - Users do not need to vote every week for their votes to count
 *        - Votes can be positive or negative
 *        - Positive and negative votes of the same value have the same weight in the context of a user
 *        - Voting snapshots are submitted directly before the period epoch (Thursday 00:00+00 UTC)
 *        - Only the top voted `maxPoolsLength` pools will be voted on every week (this is due to a max vote count per NFT in Cone)
 *        - Bribes and fee voting are handled separately
 */
contract VotingSnapshot is
    IVotingSnapshot,
    GovernableImplementation,
    ProxyImplementation
{
    /*******************************************************
     *                     Configuration
     *******************************************************/

    // Set up binary search tree
    using BinarySearch for BinarySearch.Tree;

    // Legacy tree
    BinarySearch.Tree legacyTree;

    // Constants
    uint256 internal tokenId;
    uint256 internal constant week = 86400 * 7;
    uint256 internal constant hour = 3600;

    // Options
    uint256 public window = hour * 4;
    uint256 public maxPoolsLength = 10;
    uint256 public maxVotesPerAccount = 10;

    // Important addresses
    address public vlUnkwnAddress;
    address public veAddress;
    address public voterProxyAddress;

    // Legacy, dirty slots used for Global vote tracking
    mapping(uint256 => uint256) internal legacyVotesLengthByWeight;
    mapping(uint256 => mapping(uint256 => Vote)) public legacyVotesByWeight;
    mapping(address => uint256) internal legacyWeightByPoolUnsigned;
    mapping(address => int256) internal legacyWeightByPoolSigned;
    mapping(address => uint256) internal legacyVoteIndexByPool;
    uint256 internal legacyUniqueVotesLength;
    uint256 internal legacyVotesLength;

    // Legacy, dirty slots used for User vote tracking
    mapping(address => uint256) internal legacyVoteWeightUsedByAccount;
    mapping(address => uint256) internal legacyVotesLengthByAccount;
    mapping(address => mapping(address => Vote))
        internal legacyAccountVoteByPool;
    mapping(address => mapping(uint256 => Vote))
        internal legacyAccountVoteByIndex;
    mapping(address => mapping(address => uint256))
        internal legacyAccountVoteIndexByPool;

    // Vote delegation
    mapping(address => address) public voteDelegateByAccount;

    // Internal helpers
    IVlUnkwn internal vlUnkwn;
    IVe internal ve;
    IVoterProxy internal voterProxy;
    IController internal controller;

    // Timestamps
    uint256 public coneVotesLastCleared;

    // Downvote prevention
    mapping(address => bool) public upOnlyPools;

    // Min allocation
    address[] public ecosystemPools;
    mapping(address => bool) public isEcosystemPool;
    mapping(address => uint256) public ecosystemPoolMinWeight;
    uint256 public totalEcosystemPoolsMinWeight;
    uint256 internal constant basis = 10000;

    // New tree
    BinarySearch.Tree tree;

    // New Global vote tracking
    mapping(uint256 => uint256) public votesLengthByWeight;
    mapping(uint256 => mapping(uint256 => Vote)) public votesByWeight;
    mapping(address => uint256) public weightByPoolUnsigned;
    mapping(address => int256) public weightByPoolSigned;
    mapping(address => uint256) public voteIndexByPool;
    uint256 public uniqueVotesLength;
    uint256 public votesLength;

    // New User vote tracking
    mapping(address => uint256) public voteWeightUsedByAccount;
    mapping(address => uint256) public votesLengthByAccount;
    mapping(address => mapping(address => Vote)) public accountVoteByPool;
    mapping(address => mapping(uint256 => Vote)) public accountVoteByIndex;
    mapping(address => mapping(address => uint256))
        public accountVoteIndexByPool;

    // Modifiers
    modifier onlyVoteDelegateOrOwner(address accountAddress) {
        if (msg.sender != vlUnkwnAddress) {
            bool voteDelegateSet = voteDelegateByAccount[accountAddress] !=
                address(0);
            if (voteDelegateSet) {
                if (accountAddress == msg.sender) {
                    revert(
                        "You have delegated your voting power (you cannot vote)"
                    );
                }
                require(
                    voteDelegateByAccount[accountAddress] == msg.sender,
                    "Only vote delegate can vote"
                );
            } else {
                require(
                    accountAddress == msg.sender,
                    "Only users and delegates can vote"
                );
            }
        }
        _;
    }

    /**
     * @notice Initialize proxy storage
     */
    function initializeProxyStorage(
        address _vlUnkwnAddress,
        address _veAddress,
        address _voterProxyAddress
    ) public checkProxyInitialized {
        vlUnkwnAddress = _vlUnkwnAddress;
        veAddress = _veAddress;
        voterProxyAddress = _voterProxyAddress;
        vlUnkwn = IVlUnkwn(vlUnkwnAddress);
        ve = IVe(_veAddress);
        controller = IController(ve.controller());
        voterProxy = IVoterProxy(voterProxyAddress);
        tokenId = voterProxy.primaryTokenId();
    }

    /*******************************************************
     *                 Pool vote registration
     *******************************************************/

    /**
     * @notice Register a pool vote in our binary search tree given a vote
     * @param vote The new vote to register (includes pool address and vote weight delta)
     * @dev We utilize a binary search tree to allow votes to be sorted with O(log n) efficiency
     * @dev Pool votes can be positive or negative
     * @dev This method is only called by the user `vote(Vote)` method
     */
    function registerVote(Vote memory vote) internal {
        // Find current weight for pool
        address poolAddress = vote.poolAddress;
        int256 currentPoolWeight = weightByPoolSigned[poolAddress];

        // Find new weight for pool based on new weight delta
        int256 newPoolWeight = currentPoolWeight + vote.weight;

        // Fetch absolute pool weights
        uint256 newPoolWeightAbsolute = Math.abs(newPoolWeight);
        uint256 currentPoolWeightAbsolute = Math.abs(currentPoolWeight);

        // Fetch number of votes per weight
        uint256 newVotesLengthPerWeight = votesLengthByWeight[
            newPoolWeightAbsolute
        ];
        uint256 currentVotesLengthPerWeight = votesLengthByWeight[
            currentPoolWeightAbsolute
        ];

        // If pool has no votes
        bool poolHasNoVotes = currentPoolWeight == 0;
        if (poolHasNoVotes) {
            // Check to see if weight exists in tree
            bool newWeightExists = weightExists(newPoolWeightAbsolute);

            // If new pool weight exists
            if (newWeightExists) {
                // Append vote to weight list
                votesByWeight[newPoolWeightAbsolute][
                    newVotesLengthPerWeight
                ] = vote;
                voteIndexByPool[poolAddress] = newVotesLengthPerWeight;
            } else {
                // Otherwise, create a new weight node and append the current vote
                insertWeight(newPoolWeightAbsolute);
                votesByWeight[newPoolWeightAbsolute][0] = vote;
                voteIndexByPool[poolAddress] = 0;
                uniqueVotesLength++;
            }

            // Increase total number of votes
            votesLength++;

            // Increase number of votes for this specific weight
            votesLengthByWeight[newPoolWeightAbsolute]++;

            // Set signed and unsigned weights for this pool
            weightByPoolUnsigned[vote.poolAddress] = Math.abs(vote.weight);
            weightByPoolSigned[vote.poolAddress] = vote.weight;
        } else {
            /**
             * Pool already has a vote, so we need to find and update the existing vote.
             * Iterate through votes for the current weight list to find the vote we need to update.
             */
            for (
                uint256 voteIndex;
                voteIndex < currentVotesLengthPerWeight;
                voteIndex++
            ) {
                Vote memory currentVote = votesByWeight[
                    currentPoolWeightAbsolute
                ][voteIndex];

                // Once we find the vote, update it
                if (currentVote.poolAddress == poolAddress) {
                    /**
                     * If vote has changed, remove the vote and add it again with the new weight.
                     * First delete the existing vote.
                     */
                    unregisterVote(vote, voteIndex);

                    // If the new vote weight is not zero re-register the pool vote using the updated weight
                    bool newVoteIsNotZero = newPoolWeight != 0;
                    if (newVoteIsNotZero) {
                        Vote memory updatedVote = Vote({
                            poolAddress: poolAddress,
                            weight: newPoolWeight
                        });
                        registerVote(updatedVote);
                    }
                    return;
                }
            }
        }
    }

    /**
     * @notice Unregister/delete a vote
     * @param vote The vote object to unregister (includes pool address and vote weight delta)
     * @param voteIndex The position of the vote in the current weight node
     * @dev This is only called by `registerVote(Vote)` when updating votes
     */
    function unregisterVote(Vote memory vote, uint256 voteIndex) internal {
        // Make sure node exists
        address poolAddress = vote.poolAddress;
        uint256 currentPoolWeightAbsolute = weightByPoolUnsigned[poolAddress];
        bool weightExists = weightExists(currentPoolWeightAbsolute);
        require(weightExists, "Weight node does not exist");

        // Find current weight node length
        uint256 votesLengthPerWeight = votesLengthByWeight[
            currentPoolWeightAbsolute
        ];

        // If there is only one item in the weight node, remove the node
        if (votesLengthPerWeight == 1) {
            removeWeight(currentPoolWeightAbsolute);
            uniqueVotesLength--;
        }

        // Find the index of the vote to remove in the weight node
        uint256 indexOfVoteInWeightList = voteIndexByPool[poolAddress];

        // Store the last vote of the weight node
        Vote memory lastVote = votesByWeight[currentPoolWeightAbsolute][
            votesLengthPerWeight - 1
        ];

        // Replace the vote to remove with the last vote
        votesByWeight[currentPoolWeightAbsolute][
            indexOfVoteInWeightList
        ] = lastVote;

        // Update voteIndexByPool
        voteIndexByPool[lastVote.poolAddress] = indexOfVoteInWeightList;

        // Decrement votes length
        votesLength--;
        votesLengthByWeight[currentPoolWeightAbsolute]--;

        // Delete pool weight associations
        delete weightByPoolUnsigned[poolAddress];
        delete weightByPoolSigned[poolAddress];
        delete voteIndexByPool[poolAddress];
    }

    /**
     * @notice Determine current active period for voting epoch
     */
    function nextEpoch() public view returns (uint256) {
        return ((block.timestamp + week) / week) * week;
    }

    /**
     * @notice Determine the next time a vote can be submitted
     */
    function nextVoteSubmission() public view returns (uint256) {
        return nextEpoch() - window;
    }

    /*******************************************************
     *                  User vote tracking
     *******************************************************/

    /**
     * @notice Find the maximum voting power available for an account
     * @param accountAddress The address to check
     */
    function voteWeightTotalByAccount(address accountAddress)
        public
        view
        returns (uint256)
    {
        return vlUnkwn.lockedBalanceOf(accountAddress);
    }

    function voteWeightAvailableByAccount(address accountAddress)
        public
        view
        returns (uint256)
    {
        return
            voteWeightTotalByAccount(accountAddress) -
            voteWeightUsedByAccount[accountAddress];
    }

    /*******************************************************
     *                      User voting
     *******************************************************/

    /**
     * @notice Vote for a pool given a pool address and weight
     * @param poolAddress The pool adress to vote for
     * @param weight The new vote weight (can be positive or negative)
     */
    function vote(address poolAddress, int256 weight) public {
        address accountAddress = msg.sender;
        vote(accountAddress, poolAddress, weight);
    }

    /**
     * @notice Vote for a pool on behalf of a user given a pool address and weight
     * @param poolAddress The pool adress to vote for
     * @param weight The new vote weight (can be positive or negative)
     */
    function vote(
        address accountAddress,
        address poolAddress,
        int256 weight
    ) public onlyVoteDelegateOrOwner(accountAddress) {
        if (upOnlyPools[poolAddress]) {
            require(weight >= 0, "cannot downvote upOnlyPools");
        }
        // Fetch user's vlUnkwn balance and use this as maximum user weight
        uint256 maximumUserWeight = voteWeightTotalByAccount(accountAddress);

        // Initialize vote delta variable
        int256 accountVoteDelta;

        // Find old and new votes
        Vote memory oldVote = accountVoteByPool[accountAddress][poolAddress];
        Vote memory newVote = Vote({poolAddress: poolAddress, weight: weight});

        // Determine whether or not user has voted for this pool yet
        bool accountHasntVotedForPool = oldVote.poolAddress == address(0);

        // If the user has not voted for the pool
        if (accountHasntVotedForPool) {
            // Do nothing if vote weight is zero
            if (weight == 0) {
                return;
            }

            // Add vote the user's vote list
            uint256 votesLength = votesLengthByAccount[accountAddress];
            accountVoteByIndex[accountAddress][votesLength] = newVote;
            accountVoteIndexByPool[accountAddress][poolAddress] = votesLength;
            votesLengthByAccount[accountAddress]++;

            // Store new vote delta
            accountVoteDelta = newVote.weight;

            // Make sure the user has not exceeded their maximum number of votes
            require(
                votesLengthByAccount[accountAddress] <= maxVotesPerAccount,
                "User has exceeded maximum number of votes allowed"
            );

            // Increase used vote weight for account
            voteWeightUsedByAccount[accountAddress] += Math.abs(newVote.weight);
        } else {
            /**
             * The user has already voted for this pool. Update the vote
             */

            // If the new vote weight is zero delete vote
            if (weight == 0) {
                return removeVote(accountAddress, poolAddress);
            }

            // Find the user's vote index and update it
            uint256 voteIndex = accountVoteIndexByPool[accountAddress][
                poolAddress
            ];
            accountVoteByIndex[accountAddress][voteIndex] = newVote;

            // Adjust user's vote weight
            uint256 currentWeightUsed = voteWeightUsedByAccount[accountAddress];
            voteWeightUsedByAccount[accountAddress] =
                currentWeightUsed -
                Math.abs(oldVote.weight) +
                Math.abs(newVote.weight);

            // Calculate vote delta
            accountVoteDelta = newVote.weight - oldVote.weight;
        }

        // Save the new vote
        accountVoteByPool[accountAddress][poolAddress] = newVote;

        // Make sure user has not exceeded their voting capacity
        require(
            voteWeightUsedByAccount[accountAddress] <= maximumUserWeight,
            "Exceeded user voting capacity"
        );

        // Globally register the vote
        registerVote(
            Vote({poolAddress: poolAddress, weight: accountVoteDelta})
        );
    }

    /**
     * @notice Batch voting
     * @param votes Votes
     */
    function vote(Vote[] memory votes) external {
        for (uint256 voteIndex; voteIndex < votes.length; voteIndex++) {
            Vote memory _vote = votes[voteIndex];
            vote(_vote.poolAddress, _vote.weight);
        }
    }

    /**
     * @notice Batch voting
     * @param votes Votes
     */
    function vote(address accountAddress, Vote[] memory votes) external {
        for (uint256 voteIndex; voteIndex < votes.length; voteIndex++) {
            Vote memory _vote = votes[voteIndex];
            vote(accountAddress, _vote.poolAddress, _vote.weight);
        }
    }

    /**
     * @notice Remove a user's vote given a pool address
     * @param poolAddress The address of the pool whose vote will be deleted
     */
    function removeVote(address poolAddress) public {
        address accountAddress = msg.sender;
        removeVote(accountAddress, poolAddress);
    }

    /**
     * @notice Remove a user's vote given a pool address
     * @param poolAddress The address of the pool whose vote will be deleted
     */
    function removeVote(address accountAddress, address poolAddress)
        public
        onlyVoteDelegateOrOwner(accountAddress)
    {
        // Find vote to remove
        Vote memory voteToRemove = accountVoteByPool[accountAddress][
            poolAddress
        ];

        // If user hasn't voted for this pool do nothing (there is nothing to remove)
        bool accountHasntVotedForPool = voteToRemove.poolAddress == address(0);
        if (accountHasntVotedForPool) {
            return;
        }

        // Find the user's last vote
        uint256 votesLength = votesLengthByAccount[accountAddress];
        Vote memory lastVote = accountVoteByIndex[accountAddress][
            votesLength - 1
        ];

        // Find the user's vote index and replace it with the last vote
        uint256 voteIndex = accountVoteIndexByPool[accountAddress][poolAddress];
        accountVoteByIndex[accountAddress][voteIndex] = lastVote;

        // Update accountVoteIndexByPool
        accountVoteIndexByPool[accountAddress][
            lastVote.poolAddress
        ] = voteIndex;

        // Reduce votes length
        votesLengthByAccount[accountAddress]--;

        // Remove vote weight used by account
        voteWeightUsedByAccount[accountAddress] -= Math.abs(
            voteToRemove.weight
        );

        // Remove account vote by pool
        delete accountVoteByPool[accountAddress][poolAddress];

        // Register a negating vote for the user
        registerVote(
            Vote({poolAddress: poolAddress, weight: -voteToRemove.weight})
        );
    }

    /**
     * @notice Delete all vote for a user
     */
    function resetVotes() public {
        address accountAddress = msg.sender;
        resetVotes(accountAddress);
    }

    /**
     * @notice Delete all vote for a user
     * @param accountAddress The address for which to remove votes
     */
    function resetVotes(address accountAddress) public {
        Vote[] memory _votes = votesByAccount(accountAddress);
        for (uint256 voteIndex; voteIndex < _votes.length; voteIndex++) {
            Vote memory vote = _votes[voteIndex];
            removeVote(accountAddress, vote.poolAddress);
        }
    }

    /*******************************************************
     *                    Vote submitting
     *******************************************************/

    /**
     * @notice Prepare Cone vote
     * @return Returns a list of pool addresses and votes
     */
    function prepareVote()
        public
        view
        returns (address[] memory, int256[] memory)
    {
        // Fetch top votes and total weight
        Vote[] memory _topVotes = topVotes();
        uint256 _topVotesWeight = topVotesWeight();

        // total weight before min weights should be <100%
        // (ex. if ecosystem has a min of 10%, this will make totalweight = totalweight/90%)
        _topVotesWeight =
            (_topVotesWeight * basis) /
            (basis - totalEcosystemPoolsMinWeight);

        // Fetch balance of NFT to vote with
        uint256 veBalanceOfNft = totalVoteWeight();

        // Construct vote
        address[] memory poolsAddresses = new address[](_topVotes.length);
        int256[] memory _votes = new int256[](_topVotes.length);
        for (uint256 voteIndex; voteIndex < _topVotes.length; voteIndex++) {
            // Set pool addresses
            Vote memory vote = _topVotes[voteIndex];
            poolsAddresses[voteIndex] = vote.poolAddress;

            // Set pool votes
            int256 poolWeight = vote.weight;
            // add min pool weight if it's an ecosystem pool
            if (isEcosystemPool[poolsAddresses[voteIndex]]) {
                poolWeight += int256(
                    (ecosystemPoolMinWeight[poolsAddresses[voteIndex]] *
                        _topVotesWeight) / basis
                );
            }

            int256 weightRatio = (int256(veBalanceOfNft) * poolWeight) /
                int256(_topVotesWeight);
            _votes[voteIndex] = weightRatio;
        }
        return (poolsAddresses, _votes);
    }

    /**
     * @notice Submit vote to Cone
     */
    function submitVote() external {
        require(
            (block.timestamp >= nextVoteSubmission() &&
                block.timestamp < nextEpoch()) ||
                msg.sender == governanceAddress(),
            "Votes can only be submitted within the allowed timeframe window"
        );
        require(
            IVoter(controller.voter()).usedWeights(tokenId) == 0,
            "Clear votes before submitting"
        );
        (
            address[] memory poolsAddresses,
            int256[] memory votes
        ) = prepareVote();
        voterProxy.vote(poolsAddresses, votes);
    }

    /**
     * @notice Clears votes on Cone for Unknown, only once per epoch
     * @dev if gov wants to clear votes, they can do so with voterProxy directly
     */
    function clearVotesOnCone() external {
        require(
            block.timestamp >= nextVoteSubmission() &&
                block.timestamp < nextEpoch(),
            "Votes can only be cleared within the allowed timeframe window"
        );
        require(
            coneVotesLastCleared + window < nextEpoch(),
            "Epoch vote already cleared"
        );

        // TODO: need to check if bribes are claimed

        coneVotesLastCleared = block.timestamp;

        // Voting with empty weights will reset Unknown's vote on Cone
        int256[] memory emptyWeights = new int256[](0);
        address[] memory emptyAddresses = new address[](0);
        voterProxy.vote(emptyAddresses, emptyWeights);
    }

    /*******************************************************
     *                     Admin methods
     *******************************************************/

    /**
     * @notice Sets ecosystem pools that will receive minimum vote weight
     * @param _ecosystemPools pool addresses
     * @param _ecosystemPoolWeights pool weights at a basis of 10000 (absolute, not relative)
     * @dev Sum of weights should be <100000, each weight represents a percentage of the total vote, not just relative to other ecosystem pools
     */
    function setEcosystemPools(
        address[] calldata _ecosystemPools,
        uint256[] calldata _ecosystemPoolWeights
    ) external onlyGovernance {
        // check if lengths match
        require(
            _ecosystemPools.length == _ecosystemPoolWeights.length,
            "invalid input lengths"
        );

        // clear old pools
        for (uint256 i; i < ecosystemPools.length; i++) {
            isEcosystemPool[ecosystemPools[i]] = false;
            ecosystemPoolMinWeight[ecosystemPools[i]] = 0;
        }

        // prepare new pools
        uint256 _totalEcosystemPoolsMinWeight;
        for (uint256 i; i < _ecosystemPools.length; i++) {
            _totalEcosystemPoolsMinWeight += _ecosystemPoolWeights[i];
            isEcosystemPool[_ecosystemPools[i]] = true;
            ecosystemPoolMinWeight[_ecosystemPools[i]] = _ecosystemPoolWeights[
                i
            ];
        }

        // check if weights valid
        require(_totalEcosystemPoolsMinWeight <= basis, "invalid total weight");

        // record new pools
        ecosystemPools = _ecosystemPools;
    }

    /**
     * @notice prevents certain pools from being downvoted
     * @param poolAddress pool addresses
     * @param status cannot be downvoted
     */
    function setUpOnlyPool(address poolAddress, bool status)
        external
        onlyGovernance
    {
        upOnlyPools[poolAddress] = status;
        emit upOnlyPoolStatus(poolAddress, status);
    }

    /*******************************************************
     *                     View methods
     *******************************************************/

    /**
     * @notice Fetch a sorted list of all votes (may run out of gas, if so use pagination)
     * @return Returns a list of sorted votes
     */
    function votes() external view returns (Vote[] memory) {
        return votes(votesLength);
    }

    /**
     * @notice Fetch a sorted list of votes
     * @param length The number of votes to fetch
     * @return Returns  a list of sorted votes
     */
    function votes(uint256 length) public view returns (Vote[] memory) {
        // Find current highest vote
        uint256 currentWeight = highestWeight();

        // Calculate number of votes to return
        uint256 votesToReturnLength = Math.min(votesLength, length);

        // Create new votes object
        Vote[] memory _votes = new Vote[](votesToReturnLength);

        // Use currentIndex to flatten the list of votes
        uint256 currentIndex;

        // Iterate over weight nodes
        for (
            uint256 weightIndex;
            weightIndex < uniqueVotesLength;
            weightIndex++
        ) {
            // For every vote in the weight node
            uint256 votesLengthForWeight = votesLengthByWeight[currentWeight];
            for (
                uint256 voteIndex;
                voteIndex < votesLengthForWeight;
                voteIndex++
            ) {
                // Add the vote to the votes list and increase currentIndex
                _votes[currentIndex] = votesByWeight[currentWeight][voteIndex];
                currentIndex++;

                if (currentIndex >= votesToReturnLength) {
                    return _votes;
                }
            }

            // Find the next highest vote
            currentWeight = previousWeight(currentWeight);
        }
    }

    /**
     * @notice Fetch the current list of top votes
     * @return Returns a sorted list of top votes
     */
    function topVotes() public view returns (Vote[] memory) {
        return topVotes(maxPoolsLength);
    }

    /**
     * @notice Fetch a sorted list of top votes
     * @param length The number of top votes to fetch (should exceed maxPoolsLength limit)
     * @return Returns a sorted list of top votes
     */
    function topVotes(uint256 length) public view returns (Vote[] memory) {
        uint256 votesToReturnLength = Math.min(length, maxPoolsLength);
        return votes(votesToReturnLength);
    }

    /**
     * @notice Fetch the combined absolute weight of all top votes
     * @return Returns the summation of top weights
     */
    function topVotesWeight() public view returns (uint256) {
        Vote[] memory _topVotes = topVotes();
        uint256 totalWeight;
        for (uint256 voteIndex; voteIndex < _topVotes.length; voteIndex++) {
            Vote memory vote = _topVotes[voteIndex];
            totalWeight += Math.abs(vote.weight);
        }
        return totalWeight;
    }

    /**
     * @notice Fetch a list of all votes for an account
     * @param accountAddress The address to fetch votes for
     * @return Returns a list of votes
     */
    function votesByAccount(address accountAddress)
        public
        view
        returns (Vote[] memory)
    {
        uint256 votesLength = votesLengthByAccount[accountAddress];
        Vote[] memory _votes = new Vote[](votesLength);
        for (uint256 voteIndex; voteIndex < votesLength; voteIndex++) {
            _votes[voteIndex] = accountVoteByIndex[accountAddress][voteIndex];
        }
        return _votes;
    }

    /**
     * @notice Fetch total vote weight available to the protocol
     * @return Returns total vote weight
     */
    function totalVoteWeight() public view returns (uint256) {
        return ve.balanceOfNFT(tokenId);
    }

    /**
     * @notice Length of ecosystem pools with minimum vote weights
     */
    function ecosystemPoolsLength() external view returns (uint256) {
        return ecosystemPools.length;
    }

    /*******************************************************
     *                  Binary tree traversal
     *******************************************************/

    /**
     * @notice Given a weight find the next highest weight
     * @param weight Weight node
     */
    function nextWeight(uint256 weight) public view returns (uint256) {
        return tree.next(weight);
    }

    /**
     * @notice Given a weight find the next lowest weight
     * @param weight Weight node
     */
    function previousWeight(uint256 weight) public view returns (uint256) {
        return tree.prev(weight);
    }

    /**
     * @notice Check to see if a weight node exists
     * @param weight Weight node
     */
    function weightExists(uint256 weight) public view returns (bool) {
        return tree.exists(weight);
    }

    /**
     * @notice Find the highest value weight node
     */
    function highestWeight() public view returns (uint256) {
        return tree.last();
    }

    /**
     * @notice Find the lowest value weight node
     */
    function lowestWeight() public view returns (uint256) {
        return tree.first();
    }

    /**
     * @notice Insert weight node into binary search tree
     */
    function insertWeight(uint256 weight) internal {
        tree.insert(weight);
    }

    /**
     * @notice Remove weight node from binary search tree
     */
    function removeWeight(uint256 weight) internal {
        tree.remove(weight);
    }

    /*******************************************************
     *                       Settings
     *******************************************************/

    /**
     * @notice Set maximum number of pools to be included in the vote
     * @param _maxPoolsLength The maximum number of top pools to be included in the vote
     * @dev This number is important as Cone has intensive gas constraints when voting
     */
    function setMaxPoolsLength(uint256 _maxPoolsLength)
        external
        onlyGovernance
    {
        maxPoolsLength = _maxPoolsLength;
    }

    /**
     * @notice Set maximum number of unique pool votes per account
     * @param _maxVotesPerAccount The maximum number of pool votes allowed per account
     */
    function setMaxVotesPerAccount(uint256 _maxVotesPerAccount)
        external
        onlyGovernance
    {
        maxVotesPerAccount = _maxVotesPerAccount;
    }

    /**
     * @notice Set time window for voting snapshot submission
     */
    function setWindow(uint256 _window) external onlyGovernance {
        window = _window;
    }

    /**
     * @notice Set a vote delegate for an account
     * @param voteDelegateAddress The address of the new vote delegate
     */
    function setVoteDelegate(address voteDelegateAddress) external {
        voteDelegateByAccount[msg.sender] = voteDelegateAddress;
    }

    /**
     * @notice Clear a vote delegate for an account
     */
    function clearVoteDelegate() external {
        delete voteDelegateByAccount[msg.sender];
    }

    /**
     * @notice sync tokenId from voterProxy
     */
    function syncPrimaryTokenID() external onlyGovernance {
        tokenId = voterProxy.primaryTokenId();
    }

    /*******************************************************
     *                       Events
     *******************************************************/
    event upOnlyPoolStatus(address poolAddress, bool status);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVe {
    function safeTransferFrom(
        address,
        address,
        uint256
    ) external;

    function ownerOf(uint256) external view returns (address);

    function balanceOf(address) external view returns (uint256);

    function balanceOfNFT(uint256) external view returns (uint256);

    function balanceOfNFTAt(uint256, uint256) external view returns (uint256);

    function balanceOfAtNFT(uint256, uint256) external view returns (uint256);

    function locked(uint256) external view returns (uint256);

    function createLock(uint256, uint256) external returns (uint256);

    function approve(address, uint256) external;

    function merge(uint256, uint256) external;

    function token() external view returns (address);

    function controller() external view returns (address);

    function voted(uint256) external view returns (bool);

    function tokenOfOwnerByIndex(address, uint256)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVoterProxy {
    function depositInGauge(address, uint256) external;

    function withdrawFromGauge(address, uint256) external;

    function getRewardFromGauge(address _conePool, address[] memory _tokens)
        external;

    function depositNft(uint256) external;

    function veAddress() external returns (address);

    function veDistAddress() external returns (address);

    function lockCone(uint256 amount) external;

    function primaryTokenId() external view returns (uint256);

    function vote(address[] memory, int256[] memory) external;

    function votingSnapshotAddress() external view returns (address);

    function coneInflationSinceInception() external view returns (uint256);

    function getRewardFromBribe(
        address conePoolAddress,
        address[] memory _tokensAddresses
    ) external returns (bool allClaimed, bool[] memory claimed);

    function getFeeTokensFromBribe(address conePoolAddress)
        external
        returns (bool allClaimed);

    function claimCone(address conePoolAddress)
        external
        returns (bool _claimCone);

    function setVoterProxyAssetsAddress(address _voterProxyAssetsAddress)
        external;

    function detachNFT(uint256 startingIndex, uint256 range) external;

    function claim() external;

    function whitelist(address tokenAddress) external;

    function whitelistingFee() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11||0.6.12;
pragma experimental ABIEncoderV2;

interface IVotingSnapshot {
    struct Vote {
        address poolAddress;
        int256 weight;
    }

    function vote(address, int256) external;

    function vote(Vote[] memory) external;

    function removeVote(address) external;

    function resetVotes() external;

    function resetVotes(address) external;

    function setVoteDelegate(address) external;

    function clearVoteDelegate() external;

    function voteDelegateByAccount(address) external view returns (address);

    function votesByAccount(address) external view returns (Vote[] memory);

    function voteWeightTotalByAccount(address) external view returns (uint256);

    function voteWeightUsedByAccount(address) external view returns (uint256);

    function voteWeightAvailableByAccount(address)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVlUnkwn {
    struct LocksData {
        uint256 total;
        uint256 unlockable;
        uint256 locked;
        LockedBalance[] locks;
    }

    struct LockedBalance {
        uint112 amount;
        uint112 boosted;
        uint32 unlockTime;
    }

    struct EarnedData {
        address token;
        uint256 amount;
    }

    struct Reward {
        bool useBoost;
        uint40 periodFinish;
        uint208 rewardRate;
        uint40 lastUpdateTime;
        uint208 rewardPerTokenStored;
        address rewardsDistributor;
    }

    function lock(
        address _account,
        uint256 _amount,
        uint256 _spendRatio
    ) external;

    function processExpiredLocks(
        bool _relock,
        uint256 _spendRatio,
        address _withdrawTo
    ) external;

    function lockedBalanceOf(address) external view returns (uint256 amount);

    function lockedBalances(address)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            LockedBalance[] memory
        );

    function claimableRewards(address _account)
        external
        view
        returns (EarnedData[] memory userRewards);

    function rewardTokensLength() external view returns (uint256);

    function rewardTokens(uint256) external view returns (address);

    function rewardData(address) external view returns (Reward memory);

    function rewardPerToken(address) external view returns (uint256);

    function getRewardForDuration(address) external view returns (uint256);

    function getReward() external;

    function checkpointEpoch() external;

    function updateRewards() external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IController {

  function veDist() external view returns (address);

  function voter() external view returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVoter {
    function listingFee() external view returns (uint);

    function isWhitelisted(address) external view returns (bool);

    function poolsLength() external view returns (uint256);

    function pools(uint256) external view returns (address);

    function gauges(address) external view returns (address);

    function bribes(address) external view returns (address);

    function factory() external view returns (address);

    function gaugeFactory() external view returns (address);

    function vote(
        uint256,
        address[] memory,
        int256[] memory
    ) external;

    function whitelist(address, uint256) external;

    function updateFor(address[] memory _gauges) external;

    function claimRewards(address[] memory _gauges, address[][] memory _tokens)
        external;

    function distribute(address _gauge) external;

    function usedWeights(uint256) external returns (uint256);

    function reset(uint256 _tokenId) external;
}

pragma solidity 0.8.11;

// ----------------------------------------------------------------------------
// BokkyPooBah's Red-Black Tree Library v1.0-pre-release-a
//
// A Solidity Red-Black Tree binary search library to store and access a sorted
// list of unsigned integer data. The Red-Black algorithm rebalances the binary
// search tree, resulting in O(log n) insert, remove and search time (and ~gas)
//
// https://github.com/bokkypoobah/BokkyPooBahsRedBlackTreeLibrary
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2020. The MIT Licence.
// ----------------------------------------------------------------------------
library BinarySearch {
    struct Node {
        uint256 parent;
        uint256 left;
        uint256 right;
        bool red;
    }

    struct Tree {
        uint256 root;
        mapping(uint256 => Node) nodes;
    }

    uint256 private constant EMPTY = 0;

    function first(Tree storage self) internal view returns (uint256 _key) {
        _key = self.root;
        if (_key != EMPTY) {
            while (self.nodes[_key].left != EMPTY) {
                _key = self.nodes[_key].left;
            }
        }
    }

    function last(Tree storage self) internal view returns (uint256 _key) {
        _key = self.root;
        if (_key != EMPTY) {
            while (self.nodes[_key].right != EMPTY) {
                _key = self.nodes[_key].right;
            }
        }
    }

    function next(Tree storage self, uint256 target)
        internal
        view
        returns (uint256 cursor)
    {
        require(target != EMPTY);
        if (self.nodes[target].right != EMPTY) {
            cursor = treeMinimum(self, self.nodes[target].right);
        } else {
            cursor = self.nodes[target].parent;
            while (cursor != EMPTY && target == self.nodes[cursor].right) {
                target = cursor;
                cursor = self.nodes[cursor].parent;
            }
        }
    }

    function prev(Tree storage self, uint256 target)
        internal
        view
        returns (uint256 cursor)
    {
        require(target != EMPTY);
        if (self.nodes[target].left != EMPTY) {
            cursor = treeMaximum(self, self.nodes[target].left);
        } else {
            cursor = self.nodes[target].parent;
            while (cursor != EMPTY && target == self.nodes[cursor].left) {
                target = cursor;
                cursor = self.nodes[cursor].parent;
            }
        }
    }

    function exists(Tree storage self, uint256 key)
        internal
        view
        returns (bool)
    {
        return
            (key != EMPTY) &&
            ((key == self.root) || (self.nodes[key].parent != EMPTY));
    }

    function isEmpty(uint256 key) internal pure returns (bool) {
        return key == EMPTY;
    }

    function getEmpty() internal pure returns (uint256) {
        return EMPTY;
    }

    function getNode(Tree storage self, uint256 key)
        internal
        view
        returns (
            uint256 _returnKey,
            uint256 _parent,
            uint256 _left,
            uint256 _right,
            bool _red
        )
    {
        require(exists(self, key));
        return (
            key,
            self.nodes[key].parent,
            self.nodes[key].left,
            self.nodes[key].right,
            self.nodes[key].red
        );
    }

    function insert(Tree storage self, uint256 key) internal {
        require(key != EMPTY);
        require(!exists(self, key));
        uint256 cursor = EMPTY;
        uint256 probe = self.root;
        while (probe != EMPTY) {
            cursor = probe;
            if (key < probe) {
                probe = self.nodes[probe].left;
            } else {
                probe = self.nodes[probe].right;
            }
        }
        self.nodes[key] = Node({
            parent: cursor,
            left: EMPTY,
            right: EMPTY,
            red: true
        });
        if (cursor == EMPTY) {
            self.root = key;
        } else if (key < cursor) {
            self.nodes[cursor].left = key;
        } else {
            self.nodes[cursor].right = key;
        }
        insertFixup(self, key);
    }

    function remove(Tree storage self, uint256 key) internal {
        require(key != EMPTY);
        require(exists(self, key));
        uint256 probe;
        uint256 cursor;
        if (self.nodes[key].left == EMPTY || self.nodes[key].right == EMPTY) {
            cursor = key;
        } else {
            cursor = self.nodes[key].right;
            while (self.nodes[cursor].left != EMPTY) {
                cursor = self.nodes[cursor].left;
            }
        }
        if (self.nodes[cursor].left != EMPTY) {
            probe = self.nodes[cursor].left;
        } else {
            probe = self.nodes[cursor].right;
        }
        uint256 yParent = self.nodes[cursor].parent;
        self.nodes[probe].parent = yParent;
        if (yParent != EMPTY) {
            if (cursor == self.nodes[yParent].left) {
                self.nodes[yParent].left = probe;
            } else {
                self.nodes[yParent].right = probe;
            }
        } else {
            self.root = probe;
        }
        bool doFixup = !self.nodes[cursor].red;
        if (cursor != key) {
            replaceParent(self, cursor, key);
            self.nodes[cursor].left = self.nodes[key].left;
            self.nodes[self.nodes[cursor].left].parent = cursor;
            self.nodes[cursor].right = self.nodes[key].right;
            self.nodes[self.nodes[cursor].right].parent = cursor;
            self.nodes[cursor].red = self.nodes[key].red;
            (cursor, key) = (key, cursor);
        }
        if (doFixup) {
            removeFixup(self, probe);
        }
        delete self.nodes[cursor];
    }

    function treeMinimum(Tree storage self, uint256 key)
        private
        view
        returns (uint256)
    {
        while (self.nodes[key].left != EMPTY) {
            key = self.nodes[key].left;
        }
        return key;
    }

    function treeMaximum(Tree storage self, uint256 key)
        private
        view
        returns (uint256)
    {
        while (self.nodes[key].right != EMPTY) {
            key = self.nodes[key].right;
        }
        return key;
    }

    function rotateLeft(Tree storage self, uint256 key) private {
        uint256 cursor = self.nodes[key].right;
        uint256 keyParent = self.nodes[key].parent;
        uint256 cursorLeft = self.nodes[cursor].left;
        self.nodes[key].right = cursorLeft;
        if (cursorLeft != EMPTY) {
            self.nodes[cursorLeft].parent = key;
        }
        self.nodes[cursor].parent = keyParent;
        if (keyParent == EMPTY) {
            self.root = cursor;
        } else if (key == self.nodes[keyParent].left) {
            self.nodes[keyParent].left = cursor;
        } else {
            self.nodes[keyParent].right = cursor;
        }
        self.nodes[cursor].left = key;
        self.nodes[key].parent = cursor;
    }

    function rotateRight(Tree storage self, uint256 key) private {
        uint256 cursor = self.nodes[key].left;
        uint256 keyParent = self.nodes[key].parent;
        uint256 cursorRight = self.nodes[cursor].right;
        self.nodes[key].left = cursorRight;
        if (cursorRight != EMPTY) {
            self.nodes[cursorRight].parent = key;
        }
        self.nodes[cursor].parent = keyParent;
        if (keyParent == EMPTY) {
            self.root = cursor;
        } else if (key == self.nodes[keyParent].right) {
            self.nodes[keyParent].right = cursor;
        } else {
            self.nodes[keyParent].left = cursor;
        }
        self.nodes[cursor].right = key;
        self.nodes[key].parent = cursor;
    }

    function insertFixup(Tree storage self, uint256 key) private {
        uint256 cursor;
        while (key != self.root && self.nodes[self.nodes[key].parent].red) {
            uint256 keyParent = self.nodes[key].parent;
            if (keyParent == self.nodes[self.nodes[keyParent].parent].left) {
                cursor = self.nodes[self.nodes[keyParent].parent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[keyParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    key = self.nodes[keyParent].parent;
                } else {
                    if (key == self.nodes[keyParent].right) {
                        key = keyParent;
                        rotateLeft(self, key);
                    }
                    keyParent = self.nodes[key].parent;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    rotateRight(self, self.nodes[keyParent].parent);
                }
            } else {
                cursor = self.nodes[self.nodes[keyParent].parent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[keyParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    key = self.nodes[keyParent].parent;
                } else {
                    if (key == self.nodes[keyParent].left) {
                        key = keyParent;
                        rotateRight(self, key);
                    }
                    keyParent = self.nodes[key].parent;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    rotateLeft(self, self.nodes[keyParent].parent);
                }
            }
        }
        self.nodes[self.root].red = false;
    }

    function replaceParent(
        Tree storage self,
        uint256 a,
        uint256 b
    ) private {
        uint256 bParent = self.nodes[b].parent;
        self.nodes[a].parent = bParent;
        if (bParent == EMPTY) {
            self.root = a;
        } else {
            if (b == self.nodes[bParent].left) {
                self.nodes[bParent].left = a;
            } else {
                self.nodes[bParent].right = a;
            }
        }
    }

    function removeFixup(Tree storage self, uint256 key) private {
        uint256 cursor;
        while (key != self.root && !self.nodes[key].red) {
            uint256 keyParent = self.nodes[key].parent;
            if (key == self.nodes[keyParent].left) {
                cursor = self.nodes[keyParent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[keyParent].red = true;
                    rotateLeft(self, keyParent);
                    cursor = self.nodes[keyParent].right;
                }
                if (
                    !self.nodes[self.nodes[cursor].left].red &&
                    !self.nodes[self.nodes[cursor].right].red
                ) {
                    self.nodes[cursor].red = true;
                    key = keyParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].right].red) {
                        self.nodes[self.nodes[cursor].left].red = false;
                        self.nodes[cursor].red = true;
                        rotateRight(self, cursor);
                        cursor = self.nodes[keyParent].right;
                    }
                    self.nodes[cursor].red = self.nodes[keyParent].red;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[cursor].right].red = false;
                    rotateLeft(self, keyParent);
                    key = self.root;
                }
            } else {
                cursor = self.nodes[keyParent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[keyParent].red = true;
                    rotateRight(self, keyParent);
                    cursor = self.nodes[keyParent].left;
                }
                if (
                    !self.nodes[self.nodes[cursor].right].red &&
                    !self.nodes[self.nodes[cursor].left].red
                ) {
                    self.nodes[cursor].red = true;
                    key = keyParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].left].red) {
                        self.nodes[self.nodes[cursor].right].red = false;
                        self.nodes[cursor].red = true;
                        rotateLeft(self, cursor);
                        cursor = self.nodes[keyParent].left;
                    }
                    self.nodes[cursor].red = self.nodes[keyParent].red;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[cursor].left].red = false;
                    rotateRight(self, keyParent);
                    key = self.root;
                }
            }
        }
        self.nodes[key].red = false;
    }
}
// ----------------------------------------------------------------------------
// End - BokkyPooBah's Red-Black Tree Library
// ----------------------------------------------------------------------------

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

library Math {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11||0.6.12;

/**
 * @title Ownable contract which allows governance to be killed, adapted to be used under a proxy
 * @author Unknown
 */
contract GovernableImplementation {
    address internal doNotUseThisSlot; // used to be governanceAddress, but there's a hash collision with the proxy's governanceAddress
    bool public governanceIsKilled;

    /**
     * @notice legacy
     * @dev public visibility so it compiles for 0.6.12
     */
    constructor() public {
        doNotUseThisSlot = msg.sender;
    }

    /**
     * @notice Only allow governance to perform certain actions
     */
    modifier onlyGovernance() {
        require(msg.sender == governanceAddress(), "Only governance");
        _;
    }

    /**
     * @notice Set governance address
     * @param _governanceAddress The address of new governance
     */
    function setGovernanceAddress(address _governanceAddress)
        public
        onlyGovernance
    {
        require(msg.sender == governanceAddress(), "Only governance");
        assembly {
            sstore(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103,
                _governanceAddress
            ) // keccak256('eip1967.proxy.admin')
        }
    }

    /**
     * @notice Allow governance to be killed
     */
    function killGovernance() external onlyGovernance {
        setGovernanceAddress(address(0));
        governanceIsKilled = true;
    }

    /**
     * @notice Fetch current governance address
     * @return _governanceAddress Returns current governance address
     * @dev directing to the slot that the proxy would use
     */
    function governanceAddress()
        public
        view
        returns (address _governanceAddress)
    {
        assembly {
            _governanceAddress := sload(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103
            ) // keccak256('eip1967.proxy.admin')
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11||0.6.12;

/**
 * @title Implementation meant to be used with a proxy
 * @author Unknown
 */
contract ProxyImplementation {
    bool public proxyStorageInitialized;

    /**
     * @notice Nothing in constructor, since it only affects the logic address, not the storage address
     * @dev public visibility so it compiles for 0.6.12
     */
    constructor() public {}

    /**
     * @notice Only allow proxy's storage to be initialized once
     */
    modifier checkProxyInitialized() {
        require(
            !proxyStorageInitialized,
            "Can only initialize proxy storage once"
        );
        proxyStorageInitialized = true;
        _;
    }
}