/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

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

interface StandardToken {
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external;

    function transfer(address _to, uint256 _value) external;

    function approve(address _spender, uint256 _value) external;

    function allowance(address _owner, address _spender) external view returns (uint256);

    function balanceOf(address _owner) external returns (uint256);
}

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

abstract contract Pausable {
    bool private _paused = false;

    modifier whileNotPaused() {
        require(!_paused, "Pausable: contract must be paused");
        _;
    }

    modifier whilePaused() {
        require(_paused, "Pausable: contract must not be paused");
        _;
    }

    function pause() public virtual whileNotPaused returns (bool) {
        _paused = true;
        return _paused;
    }

    function unPause() public virtual whileNotPaused returns (bool) {
        _paused = true;
        return _paused;
    }

    function isPaused() public view returns (bool) {
        return _paused;
    }
}

contract DBToken is IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    string private _eventCode;
    string private _teamName;

    /**
     * @dev Next to the regular name and symbol params, constructor takes an event code and team name
     * @param name_ Name of the token. Generally "DBToken"
     * @param symbol_ Symbol of the token. Generally "DBT"
     * @param eventCode_ Event code of the token. Later could be used in the DBTokenSale contract to end the tokens under given event
     * @param teamName_ Name of the team the token is representing
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory eventCode_,
        string memory teamName_
    ) Ownable() {
        _name = name_;
        _symbol = symbol_;
        _eventCode = eventCode_;
        _teamName = teamName_;
        _totalSupply = 0;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function eventCode() external view returns (string memory) {
        return _eventCode;
    }

    function teamName() external view returns (string memory) {
        return _teamName;
    }

    function decimals() external pure override returns (uint8) {
        return 18;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(_allowances[sender][_msgSender()] >= amount, "DBToken: transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);

        unchecked {
            _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        }

        return true;
    }

    function _mint(address account, uint256 amount) external onlyOwner returns (bool) {
        require(account != address(0), "DBToken: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "DBToken: transfer from the zero address");
        require(recipient != address(0), "DBToken: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "DBToken: transfer amount exceeds balance");

        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "DBToken: approve from the zero address");
        require(spender != address(0), "DBToken: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

struct ArrayElRef {
    bool status;
    uint256 arrayIndex;
}

abstract contract SaleFactory is Ownable {
    // Each sale has an entry in the eventCode hash table with start and end time.
    // If both saleStart and saleEnd are 0, sale is not initialized
    struct Sale {
        uint256 saleStart;
        uint256 saleEnd;
    }
    mapping(bytes32 => Sale) private _eventSale;
    bytes32[] private _allSales;

    // Modifier allowing a call if and only if there are no active sales at the moment
    modifier noActiveSale() {
        for (uint256 i; i < _allSales.length; i++) {
            require(saleIsActive(false, _eventSale[_allSales[i]]), "SaleFactory: unavailable while a sale is active");
        }
        _;
    }

    // Modifier allowing a call only if event by eventCode is currently active
    modifier duringSale(string memory eventCode) {
        Sale storage eventSale = getEventSale(eventCode);
        require(saleIsActive(true, eventSale), "SaleFactory: function can only be called during sale");
        _;
        clearExpiredSales();
    }

    // Modifier allowing a call only if event by eventCode is currently inactive
    modifier outsideOfSale(string memory eventCode) {
        // We are fetching the event directly through a hash, since getEventSale reverts if sale is not initialized
        Sale storage eventSale = _eventSale[hashStr(eventCode)];
        require(saleIsActive(false, eventSale), "SaleFactory: function can only be called outside of sale");

        _;
    }

    /**
     * @dev Function returns true if our expectations on status of sale is correct
     * @param expectActive If we expect the sale to be active set to true
     * @param sale Sale that is being inspected
     */
    function saleIsActive(bool expectActive, Sale memory sale) private view returns (bool) {
        if (expectActive) {
            return (time() >= sale.saleStart) && (time() < sale.saleEnd);
        } else {
            return (time() < sale.saleStart) || (time() >= sale.saleEnd);
        }
    }

    // Returns all active or soon-to-be active sales in an array ordered by sale end time
    function getAllSales() public view returns (Sale[] memory) {
        uint256 length = _allSales.length;

        Sale[] memory sales = new Sale[](length);

        for (uint256 i; i < length; i++) {
            sales[i] = _eventSale[_allSales[i]];
        }
        return sales;
    }

    // Clears all sales from the _allSales array who's saleEnd time is in the past
    function clearExpiredSales() private returns (bool) {
        uint256 length = _allSales.length;
        if (length > 0 && _eventSale[_allSales[0]].saleEnd <= time()) {
            uint256 endDelete = 1;

            bytes32[] memory copyAllSales = _allSales;

            uint256 i = 1;
            while (i < length) {
                if (_eventSale[_allSales[i]].saleEnd > time()) {
                    endDelete = i;
                    break;
                }
                i++;
            }

            for (i = 0; i < length; i++) {
                if (i < length - endDelete) {
                    _allSales[i] = copyAllSales[i + endDelete];
                } else {
                    _allSales.pop();
                }
            }
        }
        return true;
    }

    // Return current timestamp
    function time() public view returns (uint256) {
        return block.timestamp;
    }

    function hashStr(string memory str) public pure returns (bytes32) {
        return bytes32(keccak256(bytes(str)));
    }

    /**
     * @dev Function inserts a sale reference in the _allSales array and orders it by saleEnd time
     * in ascending order. This means the first sale in the array will expire first.
     * @param saleHash hash reference to the sale mapping structure
     */
    function insertSale(bytes32 saleHash) private returns (bool) {
        uint256 length = _allSales.length;

        bytes32 unorderedSale = saleHash;
        bytes32 tmpSale;

        for (uint256 i; i <= length; i++) {
            if (i == length) {
                _allSales.push(unorderedSale);
            } else {
                if (_eventSale[_allSales[i]].saleEnd > _eventSale[unorderedSale].saleEnd) {
                    tmpSale = _allSales[i];
                    _allSales[i] = unorderedSale;
                    unorderedSale = tmpSale;
                }
            }
        }
        return true;
    }

    /**
     * @dev Function returns Sale struct with saleEnd and saleStart. Function reverts if event is not initialized
     * @param eventCode string code of event
     */
    function getEventSale(string memory eventCode) private view returns (Sale storage) {
        Sale storage eventSale = _eventSale[hashStr(eventCode)];
        require(eventSale.saleStart > 0 || eventSale.saleEnd > 0, "SaleFactory: sale not initialized");
        return eventSale;
    }

    /**
     * @dev Function to set the start and end time of the next sale.
     * Can only be called if there is currently no active sale and needs to be called by the owner of the contract.
     * @param start Unix time stamp of the start of sale. Needs to be a timestamp in the future. If the start is 0, the sale will start immediately.
     * @param end Unix time stamp of the end of sale. Needs to be a timestamp after the start
     */
    function setSaleStartEnd(
        string memory eventCode,
        uint256 start,
        uint256 end
    ) public onlyOwner outsideOfSale(eventCode) returns (bool) {
        bool initialized;
        bytes32 saleHash = hashStr(eventCode);
        Sale storage eventSale = _eventSale[saleHash];
        if (eventSale.saleStart == 0 && eventSale.saleEnd == 0) {
            initialized = false;
        }

        if (start != 0) {
            require(start > time(), "SaleFactory: given past sale start time");
        } else {
            start = time();
        }
        require(end > start, "SaleFactory: sale end time needs to be greater than start time");

        eventSale.saleStart = start;
        eventSale.saleEnd = end;

        if (!initialized) {
            insertSale(saleHash);
        }

        return true;
    }

    // Function can be called by the owner during a sale to end it prematurely
    function endSaleNow(string memory eventCode) public onlyOwner duringSale(eventCode) returns (bool) {
        Sale storage eventSale = getEventSale(eventCode);

        eventSale.saleEnd = time();
        return true;
    }

    /**
     * @dev Public function which provides info if there is currently any active sale and when the sale status will update.
     * Value saleActive represents if sale is active at the current moment.
     * If sale has been initialized, saleStart and saleEnd will return UNIX timestampts
     * If sale has not been initialized, function will revert.
     * @param eventCode string code of event
     */
    function isSaleOn(string memory eventCode)
        public
        view
        returns (
            bool saleActive,
            uint256 saleStart,
            uint256 saleEnd
        )
    {
        Sale storage eventSale = getEventSale(eventCode);

        if (eventSale.saleStart > time()) {
            return (false, eventSale.saleStart, eventSale.saleEnd);
        } else if (eventSale.saleEnd > time()) {
            return (true, eventSale.saleStart, eventSale.saleEnd);
        } else {
            return (false, eventSale.saleStart, eventSale.saleEnd);
        }
    }
}

abstract contract TokenHash is Ownable {
    function getTokenHash(string memory _eventCode, string memory _teamName) internal pure returns (bytes32) {
        return keccak256(bytes(abi.encodePacked(_eventCode, _teamName)));
    }
}

/***********************************************************************
 ***********************************************************************
 *****************        DB TOKEN SIDE BET       **********************
 ***********************************************************************
 **********************************************************************/

contract DBTokenSideBet is SaleFactory {
    DBToken private firstTeamToken;
    DBToken private secondTeamToken;
    StandardToken private standardToken;

    mapping(bytes32 => mapping(address => uint256)) private userStakedFirstTokenPerEvent;
    mapping(bytes32 => uint256) private totalStakedFirstTokenPerEvent;

    mapping(bytes32 => mapping(address => uint256)) private userStakedSecondTokenPerEvent;
    mapping(bytes32 => uint256) private totalStakedSecondTokenPerEvent;

    struct UsersStaked {
        address[] stakedForFirstTeam;
        address[] stakedForSecondTeam;
    }
    mapping(bytes32 => UsersStaked) private eventStakingUsers;

    mapping(bytes32 => mapping(address => uint256)) private userEventReward;
    mapping(bytes32 => uint256) private totalEventReward;
    mapping(bytes32 => bool) private rewardDistributed;

    constructor(
        DBToken firstTeamToken_,
        DBToken secondTeamToken_,
        StandardToken standardToken_
    ) {
        firstTeamToken = firstTeamToken_;
        secondTeamToken = secondTeamToken_;
        standardToken = standardToken_;
    }

    modifier oneOfTeamTokens(DBToken teamToken) {
        require(
            isFirstTeamToken(teamToken) || isSecondTeamToken(teamToken),
            "DBTokenSideBet: unknown team token selected"
        );
        _;
    }

    modifier rewardIsDistributed(string memory eventCode) {
        require(isRewardDistributed(eventCode), "DBTokenSideBet: reward is not distributed");
        _;
    }

    modifier rewardNotDistributed(string memory eventCode) {
        require(!isRewardDistributed(eventCode), "DBTokenSideBet: reward is already distributed");
        _;
    }

    function isFirstTeamToken(DBToken teamToken) private view returns (bool) {
        return address(teamToken) == address(firstTeamToken);
    }

    function isSecondTeamToken(DBToken teamToken) private view returns (bool) {
        return address(teamToken) == address(secondTeamToken);
    }

    function getTotalStaked(string memory eventCode, DBToken teamToken)
        public
        view
        oneOfTeamTokens(teamToken)
        returns (uint256)
    {
        if (isFirstTeamToken(teamToken)) return totalStakedFirstTokenPerEvent[hashStr(eventCode)];
        return totalStakedSecondTokenPerEvent[hashStr(eventCode)];
    }

    function setTotalStaked(
        string memory eventCode,
        DBToken teamToken,
        uint256 amount
    ) private {
        if (isFirstTeamToken(teamToken)) {
            totalStakedFirstTokenPerEvent[hashStr(eventCode)] = amount;
            return;
        }
        totalStakedSecondTokenPerEvent[hashStr(eventCode)] = amount;
    }

    function getUserStaked(
        string memory eventCode,
        address user,
        DBToken teamToken
    ) public view oneOfTeamTokens(teamToken) returns (uint256) {
        if (isFirstTeamToken(teamToken)) return userStakedFirstTokenPerEvent[hashStr(eventCode)][user];
        return userStakedSecondTokenPerEvent[hashStr(eventCode)][user];
    }

    function getTotalReward(string memory eventCode) public view returns (uint256) {
        return totalEventReward[hashStr(eventCode)];
    }

    function setTotalReward(string memory eventCode, uint256 amount) private {
        totalEventReward[hashStr(eventCode)] = amount;
    }

    function getEventStakingUsers(string memory eventCode, DBToken teamToken)
        public
        view
        oneOfTeamTokens(teamToken)
        returns (address[] memory)
    {
        UsersStaked memory usersStaked = eventStakingUsers[hashStr(eventCode)];
        if (isFirstTeamToken(teamToken)) return usersStaked.stakedForFirstTeam;
        return usersStaked.stakedForSecondTeam;
    }

    function userHasStaked(
        string memory eventCode,
        DBToken teamToken,
        address user
    ) public view returns (bool) {
        address[] memory _eventStakingUsers = getEventStakingUsers(eventCode, teamToken);
        for (uint256 i = 0; i < _eventStakingUsers.length; i++) {
            if (_eventStakingUsers[i] == user) return true;
        }
        return false;
    }

    function addEventStakingUser(
        string memory eventCode,
        DBToken teamToken,
        address user
    ) private {
        if (isFirstTeamToken(teamToken)) {
            eventStakingUsers[hashStr(eventCode)].stakedForFirstTeam.push(user);
            return;
        }
        eventStakingUsers[hashStr(eventCode)].stakedForSecondTeam.push(user);
    }

    function isRewardDistributed(string memory eventCode) public view returns (bool) {
        return rewardDistributed[hashStr(eventCode)];
    }

    function setRewardDistributed(string memory eventCode, bool distributed) private {
        rewardDistributed[hashStr(eventCode)] = distributed;
    }

    function getUserReward(string memory eventCode, address user) public view returns (uint256) {
        return userEventReward[hashStr(eventCode)][user];
    }

    function setUserReward(
        string memory eventCode,
        address user,
        uint256 amount
    ) private {
        userEventReward[hashStr(eventCode)][user] = amount;
    }

    function setUserStaked(
        string memory eventCode,
        address user,
        DBToken teamToken,
        uint256 amount
    ) private {
        if (isFirstTeamToken(teamToken)) {
            userStakedFirstTokenPerEvent[hashStr(eventCode)][user] = amount;
            return;
        }
        userStakedSecondTokenPerEvent[hashStr(eventCode)][user] = amount;
    }

    function addStakedTokens(
        string memory eventCode,
        DBToken teamToken,
        address user,
        uint256 amount
    ) private {
        uint256 eventStakedTokens = getTotalStaked(eventCode, teamToken);
        uint256 userStakedTokens = getUserStaked(eventCode, user, teamToken);
        setTotalStaked(eventCode, teamToken, eventStakedTokens + amount);
        setUserStaked(eventCode, user, teamToken, userStakedTokens + amount);
    }

    function removeStakedTokens(
        string memory eventCode,
        DBToken teamToken,
        address user,
        uint256 amount
    ) private {
        uint256 eventStakedTokens = getTotalStaked(eventCode, teamToken);
        uint256 userStakedTokens = getUserStaked(eventCode, user, teamToken);
        unchecked {
            eventStakedTokens -= amount;
            userStakedTokens -= amount;
        }
        setTotalStaked(eventCode, teamToken, eventStakedTokens);
        setUserStaked(eventCode, user, teamToken, userStakedTokens);
    }

    /**
     * Distributes the left over reward after dividing by total staked
     * The algorithm favors the earlier users in the array, but the amounts will
     * usually be very small to be inconsiderable
     * @param eventCode of the sale for which the reward is being distributed
     * @param leftOverReward to distribute
     * @param users to which the left overs will be distributed
     */
    function distributeLeftOverReward(
        string memory eventCode,
        uint256 leftOverReward,
        address[] memory users
    ) private {
        uint256 userIndex = 0;
        for (uint256 i = 0; i < leftOverReward; i++) {
            uint256 userReward = getUserReward(eventCode, users[userIndex]);
            setUserReward(eventCode, users[userIndex], userReward + 1);
            userIndex = userIndex == users.length - 1 ? 0 : userIndex + 1;
        }
    }

    /**
     * Allows owner to deposit the standard token reward for the sale.
     * Reward can be deposited multiple times as long as the winner has not been selected
     * @param eventCode of the sale you want to deposit for
     * @param amount of standard token you want to deposit
     */
    function depositReward(string memory eventCode, uint256 amount) public onlyOwner rewardNotDistributed(eventCode) {
        isSaleOn(eventCode);
        uint256 allowance = standardToken.allowance(_msgSender(), address(this));
        require(allowance >= amount, "DBTokenSideBet: insufficient allowance for transfer");
        standardToken.transferFrom(_msgSender(), address(this), amount);
        uint256 totalReward = getTotalReward(eventCode);
        setTotalReward(eventCode, totalReward + amount);
    }

    /**
     * Allows owner to refund all the rewards deposited for the event and allow users to unstake
     * @param eventCode of the sale you finilize
     */
    function refundReward(string memory eventCode)
        public
        onlyOwner
        outsideOfSale(eventCode)
        rewardNotDistributed(eventCode)
    {
        uint256 totalReward = getTotalReward(eventCode);
        standardToken.transfer(_msgSender(), totalReward);
        setRewardDistributed(eventCode, true);
    }

    /**
     * Allows owner to select a winning team only once after the sale ends
     * @param eventCode of the sale you finilize
     * @param winningTeam address of the DBToken proclaimed as a winner
     */
    function selectWinningTeam(string memory eventCode, DBToken winningTeam)
        public
        onlyOwner
        outsideOfSale(eventCode)
        rewardNotDistributed(eventCode)
        oneOfTeamTokens(winningTeam)
    {
        address[] memory _eventStakingUsers = getEventStakingUsers(eventCode, winningTeam);
        uint256 totalReward = getTotalReward(eventCode);
        uint256 totalStaked = getTotalStaked(eventCode, winningTeam);
        uint256 totalRewardDistributed = 0;

        for (uint256 i = 0; i < _eventStakingUsers.length; i++) {
            uint256 userStaked = getUserStaked(eventCode, _eventStakingUsers[i], winningTeam);
            uint256 userReward = (userStaked * totalReward) / totalStaked;
            totalRewardDistributed += userReward;
            setUserReward(eventCode, _eventStakingUsers[i], userReward);
        }
        distributeLeftOverReward(eventCode, totalReward - totalRewardDistributed, _eventStakingUsers);

        setRewardDistributed(eventCode, true);
    }

    /**
     * Allows users to stake during a sale from one of the 2 given teamTokens
     * @param eventCode of the sale you want to stake for
     * @param teamToken address of the DBToken you are staking
     * @param amount of DBTokens you want to stake
     */
    function stake(
        string memory eventCode,
        DBToken teamToken,
        uint256 amount
    ) public duringSale(eventCode) oneOfTeamTokens(teamToken) {
        uint256 allowance = teamToken.allowance(_msgSender(), address(this));
        require(allowance >= amount, "DBTokenSideBet: insufficient allowance for transfer");

        if (!userHasStaked(eventCode, teamToken, _msgSender())) addEventStakingUser(eventCode, teamToken, _msgSender());
        addStakedTokens(eventCode, teamToken, _msgSender(), amount);
        teamToken.transferFrom(_msgSender(), address(this), amount);
    }

    /**
     * Allows users unstake their DBTokens only once the reward has been distributed.
     * The users which staked towards the winning team will receive rewards
     * @param eventCode of the sale you want to unstake from
     * @param teamToken address of the DBToken you want to unstake
     */
    function unstake(string memory eventCode, DBToken teamToken)
        public
        rewardIsDistributed(eventCode)
        oneOfTeamTokens(teamToken)
    {
        uint256 userStakedTokens = getUserStaked(eventCode, _msgSender(), teamToken);
        require(userStakedTokens != 0, "DBTokenSideBet: user has not staked this token in this event");

        uint256 reward = getUserReward(eventCode, _msgSender());
        if (reward != 0) standardToken.transfer(_msgSender(), reward);
        removeStakedTokens(eventCode, teamToken, _msgSender(), userStakedTokens);
        teamToken.transfer(_msgSender(), userStakedTokens);
    }
}