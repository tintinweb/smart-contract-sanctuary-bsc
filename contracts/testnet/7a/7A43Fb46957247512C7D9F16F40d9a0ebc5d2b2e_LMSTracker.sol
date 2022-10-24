/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20Upgradeable  {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

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

library EnumerableSetUpgradeable {

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

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
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
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

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
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

contract LMSTracker is Initializable, OwnableUpgradeable {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    
    address public tokenContract;

    IRouter public router;

    uint256 public minimumBalanceForRewards;
    uint256 public week;
    uint256 public lastFriday;
    uint256 public weekIndex;
    bool public allowNewTokens;

    EnumerableSetUpgradeable.AddressSet private _eligibleBalanceHolders;
    EnumerableSetUpgradeable.AddressSet private _proposedTokens;

    mapping (address => bool) public operatorWallets;

    struct WeeklyTracker {
        IERC20Upgradeable lmsToken;
        uint256 totalBNB;
        uint256 totalReward;
        
        mapping (address => bool) soldOrNewUser;
        address[] eligibleUsers;
        mapping (address => bool) claimedUser;
        uint256 rewardPerHolder;
        
        bool isDistributed;
        bool isClosed;
        
        mapping (address => uint256) votes;
        mapping (address => bool) voted;
        address winningToken;
    }

    struct Summary {
        string  tokenSymbol;
        uint256 totalReward;
        uint256 rewardPerHolder;
        uint256 eligibleHolderCount;
        uint256 week;
        uint8   tokenDecimals;
    }

    struct CurrentWinner {
        string  tokenSymbol;
        uint256 amount;
        uint8   tokenDecimals;
    }

    struct UserHistory {
        uint256 amounts;
        string  tokens;
        uint8   decimals;
    }

    struct AllData {
        uint256 week;
        uint256 nextFriday;
        uint256 totalBNB;
        uint256 minBalance;
        Summary[] summaries;
        address[] proposedTokens;
        Votes[] votes;
        CurrentWinner currentWinner;
    }

    struct UserData {
        bool isEligible;
        bool voted;
        UserHistory[] history;
    }

    struct Votes {
        string  tokenSymbol;
        uint256 votes;
    }

    mapping (uint256 => WeeklyTracker) public weeklyTrackers;



    receive() external payable {}

    modifier onlyToken() {
        require(msg.sender == tokenContract, "LMSTracker: only token");
        _;
    }

    modifier onlyOperator() {
        require(operatorWallets[msg.sender], "LMSTracker: only operators");
        _;
    }

    function resetFriday() public { //! test will be deleted
        lastFriday = block.timestamp;
    }

    function setTokenContract(address _tokenContract) public { //! test will be deleted
        tokenContract = _tokenContract;
    }

    function claimStuckTokens(address token) external onlyOwner {
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20Upgradeable ERC20token = IERC20Upgradeable (token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function getTotalValueDistrubuted() public view returns (uint256) {
        uint256 total;
        for (uint256 i = 0; i < weekIndex; i++) {
            total += weeklyTrackers[i].totalBNB;
        }
        return total;
    }

    function getAllSummary() public view returns (Summary[] memory) {
        Summary[] memory summaries = new Summary[](weekIndex);

        for (uint256 i = 1; i < weekIndex; i++) {
            WeeklyTracker storage tracker = weeklyTrackers[i];

            uint256 tokens = _proposedTokens.length();
            uint256 totalVotes;
            for (uint256 j = 0; j < tokens; j++) {
                address token = _proposedTokens.at(j);
                totalVotes += tracker.votes[token];
            }

            summaries[i] = Summary({
                tokenSymbol: tracker.lmsToken.symbol(),
                totalReward: tracker.totalReward,
                rewardPerHolder: tracker.rewardPerHolder,
                eligibleHolderCount: tracker.eligibleUsers.length,
                week: i + 1,
                tokenDecimals: tracker.lmsToken.decimals()
            });
        }

        return summaries;
    }

    function getCurrentRewardAndAmount() public view returns (CurrentWinner memory) {
        address currentToken = weeklyTrackers[week].winningToken;
        uint256 currentBNB = weeklyTrackers[week].totalBNB;

        CurrentWinner memory currentWinner;

        if (currentToken == address(0)) {
            currentWinner = CurrentWinner({
                tokenSymbol: "null",
                amount: 0,
                tokenDecimals: 18
            });
            return currentWinner;
        }

        if (currentBNB == 0) {
            currentWinner = CurrentWinner({
                tokenSymbol: IERC20Upgradeable(currentToken).symbol(),
                amount: 0,
                tokenDecimals: IERC20Upgradeable(currentToken).decimals()
            });
            return currentWinner;

        }

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = currentToken;

        uint256 amountOut = router.getAmountsOut(currentBNB, path)[1];

        currentWinner = CurrentWinner({
            tokenSymbol: IERC20Upgradeable(currentToken).symbol(),
            amount: amountOut,
            tokenDecimals: IERC20Upgradeable(currentToken).decimals()
        });

        return (currentWinner);
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

    function getUserHistory(address user) public view returns (UserHistory[] memory) {
        UserHistory[] memory history = new UserHistory[](weekIndex);
        for (uint256 i = 1; i < weekIndex; i++) {
            if (weeklyTrackers[i].claimedUser[user]) {
                history[i].amounts = weeklyTrackers[i].rewardPerHolder;
            } else {
                history[i].amounts = 0;
            }
            history[i].tokens = weeklyTrackers[i].lmsToken.symbol();
            history[i].decimals = weeklyTrackers[i].lmsToken.decimals();
        }
        return (history);
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
            votes[i].tokenSymbol = IERC20Upgradeable(_proposedTokens.at(i)).symbol();
            votes[i].votes = weeklyTrackers[week].votes[_proposedTokens.at(i)];
        }
        return votes;
    }

    function getVotesForWeek(uint256 _week) public view returns (Votes[] memory) {
        WeeklyTracker storage tracker = weeklyTrackers[_week];

        uint256 tokens = _proposedTokens.length();
        Votes[] memory votes = new Votes[](tokens);

        for (uint256 i = 0; i < tokens; i++) {
            address token = _proposedTokens.at(i);
            votes[i] = Votes({
                tokenSymbol: IERC20Upgradeable(token).symbol(),
                votes: tracker.votes[token]
            });
        }

        return votes;
    }

    function isOperator(address _operator) public view returns (bool) {
        return operatorWallets[_operator];
    }

    function addOperator(address _operator) external onlyOwner {
        require(operatorWallets[_operator] != true, "LMSTracker: User is already set to this status");
        operatorWallets[_operator] = true;
    }

    function removeOperator(address _operator) external onlyOwner {
        require(operatorWallets[_operator] == true, "LMSTracker: User is already set to this status");
        operatorWallets[_operator] = false;
    }

    function isEligible(address _address) public view returns (bool) {
        return (
            _eligibleBalanceHolders.contains(_address) &&
            weeklyTrackers[week].soldOrNewUser[_address] == false
        );
    }

    function addProposedToken(address _token) external onlyOwner {
        _proposedTokens.add(_token);
    }

    function removeProposedToken(address _token) external onlyOwner {
        _proposedTokens.remove(_token);
    }

    function setAllowNewTokens(bool allowed) external onlyOwner { 
        allowNewTokens = allowed;
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
            require(allowNewTokens, "LMSTracker: New tokens are not allowed");
            _proposedTokens.add(token);
        }

        weeklyTrackers[week].voted[msg.sender] = true;
        weeklyTrackers[week].votes[token] += 1;

        if (weeklyTrackers[week].votes[token] > weeklyTrackers[week].votes[weeklyTrackers[week].winningToken]) {
            weeklyTrackers[week].winningToken = token;
        }
    }

    function removeFromLMS (address account) public onlyToken {
        _eligibleBalanceHolders.remove(account);
    }

    function updateMinimumBalanceForRewards(uint256 _minimumBalanceForRewards) external onlyOwner {
        minimumBalanceForRewards = _minimumBalanceForRewards * (10 ** 18);
    }

    function deposit(uint256 amount) external onlyToken {
        if (week == 0) {
            weeklyTrackers[1].totalBNB += amount;
        } else {
            weeklyTrackers[week].totalBNB += amount;
        }
    }

    function updateTracker(
        address user, 
        uint256 balance,
        bool    isSell
    ) external onlyToken {
        if(balance >= minimumBalanceForRewards) {
            bool newUser = _eligibleBalanceHolders.add(user);
            if(newUser) {
                weeklyTrackers[week].soldOrNewUser[user] = true;
            }
        } else {
            _eligibleBalanceHolders.remove(user);
        }

        if (isSell) {
            weeklyTrackers[week].soldOrNewUser[user] = true;
        }
    }

    function canClose() public view returns (bool) {
        if (block.timestamp >= lastFriday + 10 minutes) {  //! test
            return true;
        } else {
            return false;
        }
    }

    function closeWeek() external onlyOperator {
        _closeWeek();
    }

    function _closeWeek() private {
        require(canClose(), "LMSTracker: Too early to close the week");

        if (week == 0) {
            weeklyTrackers[week].isClosed = true;
            lastFriday += 10 minutes; //! test
            week++;
            return;
        }

        uint256 lenght = _eligibleBalanceHolders.length();
        for (uint256 i = 0; i < lenght; i++) {
            address user = _eligibleBalanceHolders.at(i);
            if (weeklyTrackers[week].soldOrNewUser[user] == false) {
                weeklyTrackers[week].eligibleUsers.push(user);
            }
        }
                
        address lmsToken = weeklyTrackers[week].winningToken;
        if (lmsToken != address(0)){
            weeklyTrackers[week].lmsToken = IERC20Upgradeable(lmsToken);
        } else {
            if (week > 0) {
                weeklyTrackers[week].lmsToken = weeklyTrackers[week - 1].lmsToken;
            } else {
                weeklyTrackers[week].lmsToken = IERC20Upgradeable(0xc23583fE07264599068c0229a56dc5B71B6b768d); //! test
            }
        }

        _swapBNBForLMSToken(weeklyTrackers[week].totalBNB);

        if (weeklyTrackers[week].eligibleUsers.length > 0) {
            weeklyTrackers[week].rewardPerHolder = weeklyTrackers[week].totalReward / weeklyTrackers[week].eligibleUsers.length;
        }

        weeklyTrackers[week].isClosed = true;
        lastFriday += 10 minutes; //! test
        week++;
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

    function canDistribute() public view returns (bool) {
        return weeklyTrackers[weekIndex].isClosed;
    }

    function distributeLMSReward() external onlyOperator {
        _distributeLMSReward();
    }

    function _distributeLMSReward() private {
        require(weeklyTrackers[weekIndex].isClosed == true, "LMSTracker: Week is not closed");

        for (uint256 i = 0; i < weeklyTrackers[weekIndex].eligibleUsers.length; i++) {
            address user = weeklyTrackers[weekIndex].eligibleUsers[i];
            weeklyTrackers[weekIndex].lmsToken.transfer(user, weeklyTrackers[weekIndex].rewardPerHolder);
            weeklyTrackers[weekIndex].claimedUser[user] = true;
        }

        weeklyTrackers[weekIndex].isDistributed = true;
        weekIndex++;
    }

    function closeAndDistribute() external onlyOperator {
        _closeWeek();
        _distributeLMSReward();
    }

    function getAllData() external view returns (AllData memory) {
        return AllData({
            week: week,
            nextFriday: lastFriday + 10 minutes, //! test
            totalBNB: getTotalValueDistrubuted(),
            minBalance: minimumBalanceForRewards,
            summaries: getAllSummary(),
            proposedTokens: getProposedTokens(),
            votes: getVotes(),
            currentWinner: getCurrentRewardAndAmount()
        });
    }

    function getUserData(address user) external view returns (UserData memory) {
        return UserData({
            isEligible: isEligible(user),
            voted: weeklyTrackers[week].voted[user], 
            //! deleted update the dapp
            history: getUserHistory(user)
        });
    }
}