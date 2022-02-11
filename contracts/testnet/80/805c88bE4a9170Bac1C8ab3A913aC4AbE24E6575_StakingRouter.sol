// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
pragma abicoder v2;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./IPancakeRouter.sol";

contract StakingPool {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    StakingRouter router;
    address public collection; // Lick or Theive
    address public rewardToken; // dGold or Affinity
    string public tier; // common ...

    uint256 public minApr; // minApr of this staking pool
    uint256 public maxApr; // maxApr of this staking pool
    uint256 public lockDuration = 30; // days
    uint256 public minToken = 0; // user should have more than minToken of dGold
    modifier onlyRouter() {
        require(
            msg.sender == address(router),
            "only Router can call this function"
        );
        _;
    }

    struct StakeHolder {
        EnumerableSet.UintSet stakedTokenIds;
        uint256 lastClaimedTime;
        uint256 totalClaimedRewards;
    }
    mapping(address => StakeHolder) stakeHolders;
    mapping(uint256 => uint256) tokenId2StakedTime;
    EnumerableSet.AddressSet holders;
    EnumerableSet.UintSet totalStakedTokenIds;
    uint256 public totalNftCount;

    constructor(
        address _collection,
        address _rewardToken,
        string memory _tier,
        uint256 _min,
        uint256 _max,
        uint256 _counter,
        address payable _router
    ) {
        router = StakingRouter(_router);
        collection = _collection;
        rewardToken = _rewardToken;
        tier = _tier;
        minApr = _min;
        maxApr = _max;
        totalNftCount = _counter;
    }

    function getTotalStakedCount() external view returns (uint256) {
        return totalStakedTokenIds.length();
    }

    function setAprs(uint256 _min, uint256 _max) external onlyRouter {
        minApr = _min;
        maxApr = _max;
    }

    // maximum - (maximum - minimum) * 200 / 1000
    function getApr() public view returns (uint256) {
        require(totalNftCount != 0, "can't divide by zero");
        uint256 count = totalStakedTokenIds.length();
        uint256 apr = maxApr - ((maxApr - minApr) * count) / totalNftCount;
        return apr;
    }

    function setNftCount(uint256 _count) external onlyRouter {
        totalNftCount = _count;
    }

    function stakedTokenIdsOf(address account)
        external
        view
        returns (uint256[] memory)
    {
        uint256 length = stakeHolders[account].stakedTokenIds.length();
        uint256[] memory tokenIds = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            tokenIds[i] = stakeHolders[account].stakedTokenIds.at(i);
        }
        return tokenIds;
    }

    function stakeTokenTimes(address account)
        external
        view
        returns (uint256[] memory)
    {
        uint256 length = stakeHolders[account].stakedTokenIds.length();
        uint256[] memory times = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            times[i] = tokenId2StakedTime[
                stakeHolders[account].stakedTokenIds.at(i)
            ];
        }
        return times;
    }

    function getStakeHolders()
        external
        view
        onlyRouter
        returns (address[] memory _holders)
    {
        uint256 _count = holders.length();
        _holders = new address[](_count);
        for (uint256 i = 0; i < _count; i++) _holders[i] = holders.at(i);
    }

    function totalClaimedRewardsOf(address account)
        external
        view
        onlyRouter
        returns (uint256)
    {
        return stakeHolders[account].totalClaimedRewards;
    }

    function unclaimedBNBRewardsOf(address account)
        external
        view
        onlyRouter
        returns (uint256)
    {
        return _unclaimedBNBRewardsOf(account);
    }

    /**  BNB reward
     * Rewards Calculation:
     * rewards = Σ 0.45 * (block.timestamp - lastClaimedTime) / (365 * 24 * 3600) * APRi
     */
    function _unclaimedBNBRewardsOf(address account)
        private
        view
        returns (uint256)
    {
        uint256 Apr = getApr();
        uint256[] memory stakedTokenIds = this.stakedTokenIdsOf(account);
        if (stakedTokenIds.length == 0) return 0;
        // lastClaimedTime calculation
        uint256 lastClaimedTime = stakeHolders[account].lastClaimedTime;

        // rewards calculation
        uint256 bnbRewards = 0;
        for (uint256 i = 0; i < stakedTokenIds.length; i++) {
            uint256 bnbReward = (45 *
                1e14 *
                Apr *
                (block.timestamp - lastClaimedTime)) / (365 * 24 * 3600);
            bnbRewards += bnbReward;
        }
        return bnbRewards;
    }

    // updated
    function stake(address user, uint256[] memory tokenIds)
        external
        onlyRouter
    {
        if (stakeHolders[user].stakedTokenIds.length() > 0) {
            uint256 bnbRewards = _getRewards(user);
            if (bnbRewards > 0)
                // updated
                router.transferRewards(
                    collection,
                    rewardToken,
                    tier,
                    user,
                    bnbRewards
                );
        } else {
            stakeHolders[user].lastClaimedTime = block.timestamp;
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            stakeHolders[user].stakedTokenIds.add(tokenIds[i]);
            totalStakedTokenIds.add(tokenIds[i]);
            tokenId2StakedTime[tokenIds[i]] = block.timestamp;
        }
        if (!holders.contains(user)) holders.add(user);
        emit Staked(user, tokenIds);
    }

    function isLocked(address user, uint256[] memory tokenIds)
        public
        view
        returns (uint256)
    {
        uint256 locked = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                stakeHolders[user].stakedTokenIds.contains(tokenIds[i]),
                "You can't unstake these tokenIds"
            );
            if (
                (block.timestamp - tokenId2StakedTime[tokenIds[i]]) <
                lockDuration * 1 days
            ) locked += 1;
        }

        return locked;
    }

    function unstake(address user, uint256[] memory tokenIds)
        external
        onlyRouter
    {
        uint256 bnbRewards = _getRewards(user); // bnb reward
        if (bnbRewards > 0)
            router.transferRewards(
                collection,
                rewardToken,
                tier,
                user,
                bnbRewards
            );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            stakeHolders[user].stakedTokenIds.remove(tokenIds[i]);
            totalStakedTokenIds.remove(tokenIds[i]);
            IERC721(collection).transferFrom(address(this), user, tokenIds[i]);
        }
        if (stakeHolders[user].stakedTokenIds.length() == 0)
            holders.remove(user);
        emit UnStaked(user, tokenIds);
    }

    function claimRewards(address user) external onlyRouter {
        uint256 bnbRewards = _getRewards(user);
        require(bnbRewards > 0, "No rewards to claim");
        router.transferRewards(collection, rewardToken, tier, user, bnbRewards);
    }

    function _getRewards(address user) private returns (uint256) {
        uint256 bnbRewards = _unclaimedBNBRewardsOf(user);
        if (bnbRewards == 0) return 0;
        stakeHolders[user].lastClaimedTime = block.timestamp;
        uint256 unclaimedRewards = router.changeBnbToRewardToken(
            rewardToken,
            bnbRewards
        );
        stakeHolders[user].totalClaimedRewards += unclaimedRewards;
        return bnbRewards;
    }

    function setLockDurationForPool(uint256 _day) external onlyRouter {
        lockDuration = _day;
    }

    function setMinToken(uint256 _min) external onlyRouter {
        minToken = _min;
    }

    event Staked(address account, uint256[] tokenIds);
    event UnStaked(address account, uint256[] tokenIds);
}

contract StakingRouter is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    // bsc testnet
    IPancakeRouter pancakeRouter =
        IPancakeRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    // bsc mainnet
    // IPancakeRouter pancakeRouter = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // primary rewardToken i.e. dGold
    address public primaryRewardToken =
        0x4DDEdd740bA7A6E5f90c8698CBAa461AA2a7F70a;
    uint256 public feeForLockedNFT = 1e17;
    address public feeWallet = 0xAAFc265fA07b76e7cFfc6d6Ef7E6399eB4497b4f;
    // collection -> tokenId -> tier
    mapping(address => mapping(uint256 => string)) public tokenId2Tier;
    // collection -> rewardToken -> tier -> StakingPool
    mapping(address => mapping(address => mapping(string => StakingPool)))
        public pools;
    uint256 totalGivenRewards;
    struct UserData {
        EnumerableSet.AddressSet stakedCollections;
        mapping(address => uint256) earnedRewards;
        mapping(address => uint256) stakedTokens;
    }
    mapping(address => UserData) users;
    modifier hasMoreToken(
        address _c,
        address _r,
        string memory _t
    ) {
        uint256 min = pools[_c][_r][_t].minToken();
        require(
            ERC20(primaryRewardToken).balanceOf(msg.sender) >= min,
            "user has insufficient amount of PM Token"
        );
        _;
    }

    receive() external payable {}

    function getPoolAddress(
        address _c,
        address _r,
        string memory _t
    ) external view returns (address) {
        address to = address(pools[_c][_r][_t]);
        return to;
    }

    function getStakeHolders(
        address _c,
        address _r,
        string memory _t
    ) external view returns (address[] memory) {
        return pools[_c][_r][_t].getStakeHolders();
    }

    function totalClaimedRewardsOf(
        address _c,
        address _r,
        string memory _t,
        address user
    ) external view returns (uint256) {
        return pools[_c][_r][_t].totalClaimedRewardsOf(user);
    }

    function unclaimedRewardsOf(
        address _c,
        address _r,
        string memory _t,
        address user
    ) external view returns (uint256) {
        uint256 bnb = pools[_c][_r][_t].unclaimedBNBRewardsOf(user);
        uint256 unclaimedRewards = bnb;
        unclaimedRewards = changeBnbToRewardToken(_r, bnb);
        return unclaimedRewards;
    }

    function stake(
        address _c,
        address _r,
        string memory _t,
        uint256[] memory _ids
    ) external hasMoreToken(_c, _r, _t) {
        require(address(pools[_c][_r][_t]) != address(0), "not exist pool");
        for (uint256 i = 0; i < _ids.length; i++) {
            require(
                keccak256(abi.encodePacked(tokenId2Tier[_c][_ids[i]])) ==
                    keccak256(abi.encodePacked(_t)),
                "Invalid token ids!"
            );

            IERC721(_c).transferFrom(
                msg.sender,
                address(pools[_c][_r][_t]),
                _ids[i]
            );
        }
        pools[_c][_r][_t].stake(msg.sender, _ids);
        if (!users[msg.sender].stakedCollections.contains(_c))
            users[msg.sender].stakedCollections.add(_c);
        users[msg.sender].stakedTokens[_c] += 1;
    }

    // to test
    function unstake(
        address _c,
        address _r,
        string memory _t,
        uint256[] memory _ids
    ) public payable hasMoreToken(_c, _r, _t) {
        uint256 locked = pools[_c][_r][_t].isLocked(msg.sender, _ids);
        if (locked != 0) {
            require(
                msg.value >= feeForLockedNFT * locked,
                "insufficient amount BNB"
            );
            payable(feeWallet).transfer(msg.value);
        }
        pools[_c][_r][_t].unstake(msg.sender, _ids);
        users[msg.sender].stakedTokens[_c] -= 1;
        if (users[msg.sender].stakedTokens[_c] == 0)
            users[msg.sender].stakedCollections.remove(_c);
    }

    function claimRewards(
        address _c,
        address _r,
        string memory _t
    ) external hasMoreToken(_c, _r, _t) {
        pools[_c][_r][_t].claimRewards(msg.sender);
    }

    function createPool(
        address _c,
        address _r,
        string memory _t,
        uint256 _min_a,
        uint256 _max_a,
        uint256 _nft_count
    ) external onlyOwner returns (bool) {
        if (pools[_c][_r][_t] == StakingPool(address(0)))
            pools[_c][_r][_t] = new StakingPool(
                _c,
                _r,
                _t,
                _min_a,
                _max_a,
                _nft_count,
                payable(address(this))
            );
        return true;
    }

    function changeBnbToRewardToken(address _r, uint256 amount)
        public
        view
        returns (uint256)
    {
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = _r;
        uint256 rewards = amount;
        if (amount > 0) rewards = pancakeRouter.getAmountsOut(amount, path)[1];
        // if (amount > 0) rewards = pancakeRouter.getAmountsOut(10, path)[1];
        return rewards;
        // return 0;
    }

    function transferRewards(
        address _c,
        address _r,
        string memory _t,
        address user,
        uint256 amount
    ) public {
        require(
            address(pools[_c][_r][_t]) == msg.sender,
            "StakingRouter: Invalid permission"
        );
        uint256 rewards = changeBnbToRewardToken(primaryRewardToken, amount);
        uint256 temp = rewards;
        if (_r != primaryRewardToken && rewards > 0) {
            uint256 initialBalance = ERC20(_r).balanceOf(address(this));
            address[] memory path = new address[](3);
            path[0] = primaryRewardToken;
            path[1] = pancakeRouter.WETH();
            path[2] = _r;

            ERC20(primaryRewardToken).approve(address(pancakeRouter), rewards);

            pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    rewards,
                    0,
                    path,
                    address(this),
                    block.timestamp + 300
                );
            rewards = ERC20(_r).balanceOf(address(this)) - initialBalance;
        }
        if (rewards > 0) IERC20(_r).transfer(user, rewards);
        users[msg.sender].earnedRewards[_c] += temp;
        totalGivenRewards += temp;
    }

    function setAprsForPool(
        address _c,
        address _r,
        string memory _t,
        uint256 _min_a,
        uint256 _max_a
    ) external onlyOwner {
        pools[_c][_r][_t].setAprs(_min_a, _max_a);
    }

    function getAprOfPool(
        address _c,
        address _r,
        string memory _t
    ) external view returns (uint256) {
        return pools[_c][_r][_t].getApr();
    }

    function setNftCountForPool(
        address _c,
        address _r,
        string memory _t,
        uint256 _nft_count
    ) external onlyOwner {
        pools[_c][_r][_t].setNftCount(_nft_count);
    }

    function setPrimaryRewardToken(address token) external onlyOwner {
        primaryRewardToken = token;
    }

    function setFeeForLockedNFT(uint256 fee) external onlyOwner {
        feeForLockedNFT = fee;
    }

    function setFeeWallet(address wallet) external onlyOwner {
        feeWallet = wallet;
    }

    function availableRewards() external view returns (uint256) {
        return ERC20(primaryRewardToken).balanceOf(address(this));
    }

    // required to equal both of length
    function setTokenId2Tier(
        address _c,
        string memory tier,
        uint256[] memory tokenIds
    ) external onlyOwner {
        uint256 length = tokenIds.length;
        for (uint256 i = 0; i < length; i++) {
            tokenId2Tier[_c][tokenIds[i]] = tier;
        }
    }

    function getTokenId2Tier(address _c, uint256 tokenId)
        external
        view
        returns (string memory)
    {
        return tokenId2Tier[_c][tokenId];
    }

    function setLockDurationForPool(
        address _c,
        address _r,
        string memory _t,
        uint256 _day
    ) external onlyOwner {
        pools[_c][_r][_t].setLockDurationForPool(_day);
    }

    function getLockDurationForPool(
        address _c,
        address _r,
        string memory _t
    ) external view returns (uint256) {
        return pools[_c][_r][_t].lockDuration();
    }

    function setMinToken(
        address _c,
        address _r,
        string memory _t,
        uint256 _min
    ) external onlyOwner {
        pools[_c][_r][_t].setMinToken(_min);
    }

    function getMinToken(
        address _c,
        address _r,
        string memory _t
    ) external view onlyOwner returns (uint256) {
        return pools[_c][_r][_t].minToken();
    }

    // api for frontend
    function getInfoOfUser(address user)
        external
        view
        returns (
            address[] memory collections,
            uint256[] memory rewards,
            uint256[] memory tokens
        )
    {
        uint256 count = users[user].stakedCollections.length();
        collections = new address[](count);
        rewards = new uint256[](count);
        tokens = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            address c = users[user].stakedCollections.at(i);
            collections[i] = c;
            rewards[i] = users[user].earnedRewards[c];
            tokens[i] = users[user].stakedTokens[c];
        }
    }

    function getTotalGivenRewards() external view returns (uint256) {
        return totalGivenRewards;
    }

    function getPoolInfo(
        address _c,
        address _r,
        string memory _t,
        address user
    )
        external
        view
        returns (
            uint256 totalStaked,
            uint256 userStaked,
            uint256 apr,
            uint256 unclaimedReward
        )
    {
        totalStaked = pools[_c][_r][_t].getTotalStakedCount();
        uint256[] memory stakedTokenIds = pools[_c][_r][_t].stakedTokenIdsOf(
            user
        );
        userStaked = stakedTokenIds.length;
        apr = pools[_c][_r][_t].getApr();
        unclaimedReward = this.unclaimedRewardsOf(_c, _r, _t, user);
    }

    function stakedTokenIdsOf(
        address _c,
        address _r,
        string memory _t,
        address user
    ) external view returns (uint256[] memory tokenIds) {
        tokenIds = pools[_c][_r][_t].stakedTokenIdsOf(user);
    }

    function getLockedNFT(
        address _c,
        address _r,
        string memory _t,
        uint256[] memory _ids
    ) external view returns (uint256) {
        return pools[_c][_r][_t].isLocked(msg.sender, _ids);
    }

    function emergencyWithDraw() public onlyOwner {
        ERC20(primaryRewardToken).transfer(
            msg.sender,
            ERC20(primaryRewardToken).balanceOf(address(this))
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface IPancakeRouter {
    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    // to test
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

    function factory() external pure returns (address);

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
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
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
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

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}