/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IRouter {
    function WETH() external pure returns (address);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function getAmountsOut(
        uint amountIn, 
        address[] memory path
    ) external view returns (uint[] memory amounts);
}

contract LMSTracker is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    
    address public tokenContract;

    IRouter public router;

    uint256 public minimumBalanceForRewards;
    uint256 public week;
    uint256 public lastFriday;
    uint256 public weekIndex;
    uint256 public maxUserPerClose;
    uint256 public gasForClose;

    EnumerableSet.AddressSet private _eligibleBalanceHolders;
    EnumerableSet.AddressSet private _proposedTokens;

    struct WeeklyTracker {
        IERC20  lmsToken;

        uint256 totalBNB;
        uint256 totalReward;

        mapping (address => bool) soldOrNewUser;

        address[] eligibleUsers;
        mapping (address => bool) eligibleUser;

        uint256 rewardPerHolder;

        mapping (address => bool) claimed;
        uint256 claims;
        uint256 index;
        bool isDistributed;

        uint256 closeIndex;
        bool isClosed;

        mapping (address => uint256) votes;
        mapping (address => bool) voted;
    }

    struct Summary {
        address token;
        uint256 totalReward;
        uint256 rewardPerHolder;
        uint256 eligibleHolderCount;
        uint256 totalVotes;
    }

    struct Votes {
        address token;
        uint256 votes;
    }

    mapping (uint256 => WeeklyTracker) public weeklyTrackers;

    constructor(){
        router = IRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        tokenContract = 0xd08322Cd0DA5391f9f02c4d403dde87F6F048616;

        minimumBalanceForRewards = 100e18;
        week;
        lastFriday = block.timestamp; //! test;
        weekIndex;
        gasForClose = 1_000_000; //! test
    }

    receive() external payable {}

    modifier onlyToken() {
        require(msg.sender == tokenContract, "LMSTracker: only token");
        _;
    }

    modifier onlyTokenOrOwner() {
        require(msg.sender == tokenContract || msg.sender == owner(), "LMSTracker: only token or owner");
        _;
    }

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), "Owner cannot claim native tokens");
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function getTotalValueDistrubuted() external view returns (uint256) {
        uint256 total;
        for (uint256 i = 0; i < weekIndex; i++) {
            total += weeklyTrackers[i].totalBNB;
        }
        return total;
    }

    function getLastWeekSummary() external view returns (Summary memory) {
        if (weekIndex == 0) {
            return Summary(address(0), 0, 0, 0, 0);
        }

        WeeklyTracker storage tracker = weeklyTrackers[weekIndex];

        uint256 tokens = _proposedTokens.length();
        uint256 totalVotes;
        for (uint256 i = 0; i < tokens; i++) {
            address token = _proposedTokens.at(i);
            totalVotes += tracker.votes[token];
        }

        return Summary({
            token: address(tracker.lmsToken),
            totalReward: tracker.totalReward,
            rewardPerHolder: tracker.rewardPerHolder,
            eligibleHolderCount: tracker.eligibleUsers.length,
            totalVotes: tracker.closeIndex
        });
    }

    function getAllSummary() external view returns (Summary[] memory) {
        Summary[] memory summaries = new Summary[](weekIndex);

        for (uint256 i = 0; i < weekIndex; i++) {
            WeeklyTracker storage tracker = weeklyTrackers[i];

            uint256 tokens = _proposedTokens.length();
            uint256 totalVotes;
            for (uint256 j = 0; j < tokens; j++) {
                address token = _proposedTokens.at(j);
                totalVotes += tracker.votes[token];
            }

            summaries[i] = Summary({
                token: address(tracker.lmsToken),
                totalReward: tracker.totalReward,
                rewardPerHolder: tracker.rewardPerHolder,
                eligibleHolderCount: tracker.eligibleUsers.length,
                totalVotes: totalVotes
            });
        }

        return summaries;
    }

    function getCurrentRewardAndAmount() external view returns (address, uint256) {
        address currentToken = checkLMSToken();
        uint256 currentBNB = weeklyTrackers[week].totalBNB;

        if (currentToken == address(0)) {
            return (address(0), 0);
        }

        if (currentBNB == 0) {
            return (currentToken, 0);
        }

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = currentToken;

        uint256 amountOut = router.getAmountsOut(currentBNB, path)[1];

        return (currentToken, amountOut);
    }
    
    function getEligibleBalanceHolders() public view returns (address[] memory) {
        uint256 lenght = _eligibleBalanceHolders.length();
        address[] memory eligibleBalanceHolders = new address[](lenght);
        for (uint256 i = 0; i < lenght; i++) {
            eligibleBalanceHolders[i] = _eligibleBalanceHolders.at(i);
        }
        return eligibleBalanceHolders;
    }

    function getEligibleUserForWeek(uint256 _week) public view returns (address[] memory) {
        return weeklyTrackers[_week].eligibleUsers;
    }

    function getPendingReward(address user) external view returns (uint256, address) {
        if (weekIndex == week) {
            return (0, address(0));
        } else {
            WeeklyTracker storage tracker = weeklyTrackers[weekIndex];
            if (tracker.claimed[user] || !tracker.eligibleUser[user]) {
                return (0, address(tracker.lmsToken));
            } else {
                return (tracker.rewardPerHolder, address(tracker.lmsToken));
            }
        }
    }

    function userHistory(address user) external view returns (uint256[] memory, address[] memory) {
        uint256[] memory rewards = new uint256[](weekIndex);
        address[] memory tokens = new address[](weekIndex);
        for (uint256 i = 0; i < weekIndex; i++) {
            WeeklyTracker storage tracker = weeklyTrackers[i];
            if (tracker.claimed[user]) {
                rewards[i] = tracker.rewardPerHolder;
                tokens[i] = address(tracker.lmsToken);
            }
        }
        return (rewards, tokens);
    }

    function getProposedTokens() public view returns (address[] memory) {
        uint256 lenght = _proposedTokens.length();
        address[] memory proposedTokens = new address[](lenght);
        for (uint256 i = 0; i < lenght; i++) {
            proposedTokens[i] = _proposedTokens.at(i);
        }
        return proposedTokens;
    }

    function getVotes() public view returns (Votes[] memory) {
        uint256 lenght = _proposedTokens.length();
        Votes[] memory votes = new Votes[](lenght);
        for (uint256 i = 0; i < lenght; i++) {
            votes[i].token = _proposedTokens.at(i);
            votes[i].votes = weeklyTrackers[week].votes[_proposedTokens.at(i)];
        }
        return votes;
    }

    function checkLMSToken() private view returns (address) {
        uint256 lenght = _proposedTokens.length();
        address nextLMSToken = address(0);
        uint256 maxVotes = 0;
        for (uint256 i = 0; i < lenght; i++) {
            if (weeklyTrackers[week].votes[_proposedTokens.at(i)] > maxVotes) {
                maxVotes = weeklyTrackers[week].votes[_proposedTokens.at(i)];
                nextLMSToken = _proposedTokens.at(i);
            }
        }
        return nextLMSToken;
    }

    function isEligible(address _address) public view returns (bool) {
        return (
            _eligibleBalanceHolders.contains(_address) &&
            weeklyTrackers[week].soldOrNewUser[_address] == false
        );
    }

    function checkFriday() public {
        if (block.timestamp >= lastFriday + 10 minutes) {  //! test

            _closeWeek(gasForClose);

            if(weeklyTrackers[week].isClosed == true) {
                lastFriday += 10 minutes; //! test
                
                address lmsToken = checkLMSToken();
                if (lmsToken != address(0)){
                    weeklyTrackers[week].lmsToken = IERC20(lmsToken);
                } else {
                    if (week > 0) {
                        weeklyTrackers[week].lmsToken = weeklyTrackers[week - 1].lmsToken;
                    } else {
                        weeklyTrackers[week].lmsToken = IERC20(0xED36eC71739bc10dcD3E094bA0eE3e9f1253928b);
                    }
                }

                _swapBNBForLMSToken(weeklyTrackers[week].totalBNB);

                if (weeklyTrackers[week].eligibleUsers.length > 0) {
                    weeklyTrackers[week].rewardPerHolder = weeklyTrackers[week].totalReward / weeklyTrackers[week].eligibleUsers.length;
                }
                
                week++;
            }
        }
    }

    function deposit(uint256 amount) external onlyToken {
        weeklyTrackers[week].totalBNB += amount;
    }

    function _swapBNBForLMSToken(uint256 amount) private {
        uint256 initialBalance = weeklyTrackers[week].lmsToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(weeklyTrackers[week].lmsToken);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            address(this),
            block.timestamp);
        
        uint256 newBalance = weeklyTrackers[week].lmsToken.balanceOf(address(this)) - initialBalance;

        weeklyTrackers[week].totalReward += newBalance;
    }

    function updateTracker(
        address user, 
        uint256 balance,
        bool    isSell
    ) external onlyToken {
        checkFriday();

        if(balance >= minimumBalanceForRewards) {
            bool newUser = _eligibleBalanceHolders.add(user);
            if(newUser && week != 0) { //! first week everyone in
                weeklyTrackers[week].soldOrNewUser[user] = true;
            }
        } else {
            _eligibleBalanceHolders.remove(user);
        }

        if (isSell) {
            weeklyTrackers[week].soldOrNewUser[user] = true;
        }
    }

    function removeFromLMS (address account) public onlyTokenOrOwner {
        _eligibleBalanceHolders.remove(account);
    }

    function updateMinimumBalanceForRewards(uint256 _minimumBalanceForRewards) external onlyTokenOrOwner {
        minimumBalanceForRewards = _minimumBalanceForRewards;
    }

    function addProposedToken(address _token) external onlyTokenOrOwner {
        _proposedTokens.add(_token);
    }

    function removeProposedToken(address _token) external onlyTokenOrOwner {
        _proposedTokens.remove(_token);
    }

    function vote(address token) external {
        require(
            token != address(0) &&
            token != 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c,
            "LMSTracker: LMS Token cannot be BNB"
        );
        require(weeklyTrackers[week].voted[msg.sender] == false, "LMSTracker: already voted");
        require(isEligible(msg.sender), "LMSTracker: Caller is not eligible for the week");
        

        if (!_proposedTokens.contains(token)) {
            _proposedTokens.add(token);
        }

        weeklyTrackers[week].voted[msg.sender] = true;
        weeklyTrackers[week].votes[token] += 1;
    }

    function getVotesForWeek(uint256 _week) external view returns (Votes[] memory) {
        WeeklyTracker storage tracker = weeklyTrackers[_week];

        uint256 tokens = _proposedTokens.length();
        Votes[] memory votes = new Votes[](tokens);

        for (uint256 i = 0; i < tokens; i++) {
            address token = _proposedTokens.at(i);
            votes[i] = Votes({
                token: token,
                votes: tracker.votes[token]
            });
        }

        return votes;
    }

    function updateGasForClose(uint256 _gasForClose) external onlyTokenOrOwner {
        gasForClose = _gasForClose;
    }

    function process(uint256 gas) public {
        if (week == weekIndex) {
            return;
        }

        uint256 _lastIndex = weeklyTrackers[weekIndex].index;

        uint256 gasUsed;

        uint256 gasLeft = gasleft();

        while 
        (
            gasUsed < gas && 
            _lastIndex < weeklyTrackers[weekIndex].eligibleUsers.length
        ) {
            address user = weeklyTrackers[weekIndex].eligibleUsers[_lastIndex];
            if (weeklyTrackers[weekIndex].claimed[user] == false) {
                weeklyTrackers[weekIndex].claimed[user] = true;
                weeklyTrackers[weekIndex].lmsToken.transfer(user, weeklyTrackers[weekIndex].rewardPerHolder);
                weeklyTrackers[weekIndex].claims++;
            }
            _lastIndex++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed += gasLeft - newGasLeft;
            }
        }
        
        weeklyTrackers[weekIndex].index = _lastIndex;

        if (weeklyTrackers[weekIndex].claims == weeklyTrackers[weekIndex].eligibleUsers.length) {
            weeklyTrackers[weekIndex].isDistributed = true;
            weekIndex++;
        }
    }

    function closeWeek(uint256 gas) external onlyTokenOrOwner {
        _closeWeek(gas);
    }

    function _closeWeek(uint256 gas) private {
        uint256 gasUsed;

        uint256 gasLeft = gasleft();

        while 
        (
            gasUsed < gas && 
            weeklyTrackers[week].closeIndex < _eligibleBalanceHolders.length()
        ) {
            if (weeklyTrackers[week].soldOrNewUser[_eligibleBalanceHolders.at(weeklyTrackers[week].closeIndex)] == false) {
                weeklyTrackers[week].eligibleUsers.push(_eligibleBalanceHolders.at(weeklyTrackers[week].closeIndex));
                weeklyTrackers[week].eligibleUser[_eligibleBalanceHolders.at(weeklyTrackers[week].closeIndex)] = true;
            } 
            weeklyTrackers[week].closeIndex++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed += gasLeft - newGasLeft;
            }
        }

        if (weeklyTrackers[week].closeIndex >= _eligibleBalanceHolders.length()) {
            weeklyTrackers[week].isClosed = true;
        }
    }

    function manualClaim() public {
        require(week > weekIndex, "No rewards to claim yet");
        require(weeklyTrackers[weekIndex].claimed[msg.sender] == false, "LMSTracker: already claimed");
        require(weeklyTrackers[weekIndex].eligibleUser[msg.sender], "LMSTracker: Caller is not eligible for the week");
        weeklyTrackers[weekIndex].claimed[msg.sender] = true;
        weeklyTrackers[weekIndex].lmsToken.transfer(msg.sender, weeklyTrackers[weekIndex].rewardPerHolder);
        weeklyTrackers[weekIndex].claims++;
        if (weeklyTrackers[weekIndex].claims == weeklyTrackers[weekIndex].eligibleUsers.length) {
            weeklyTrackers[weekIndex].isDistributed = true;
            weekIndex++;
        }
    }

    function claimForUser(address user) external onlyTokenOrOwner {
        require(week > weekIndex, "No rewards to claim yet");
        require(weeklyTrackers[weekIndex].claimed[user] == false, "LMSTracker: already claimed");
        require(weeklyTrackers[weekIndex].eligibleUser[user], "LMSTracker: User is not eligible for the week");
        weeklyTrackers[weekIndex].claimed[user] = true;
        weeklyTrackers[weekIndex].lmsToken.transfer(user, weeklyTrackers[weekIndex].rewardPerHolder);
        weeklyTrackers[weekIndex].claims++;
        if (weeklyTrackers[weekIndex].claims == weeklyTrackers[weekIndex].eligibleUsers.length) {
            weeklyTrackers[weekIndex].isDistributed = true;
            weekIndex++;
        }
    }
}