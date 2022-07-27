//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IToken {
    function getOwner() external view returns (address);
}

interface IMAXI {
    function token() external view returns (IERC20);
}

contract RewardDistributor is IERC20 {

    // Token With Governance
    address public immutable ownableToken;

    // MAXI Staking Protocol
    address public immutable MAXI;

    // Internal Token Metrics
    string private constant _name = 'RVL Rewards';
    string private constant _symbol = 'rBUSD';
    uint8 private _decimals;

    // Reward Token Structure
    struct RewardToken {
        bool hasBeenAdded;
        address swapper;
        uint256 totalRewards;
    }
    mapping ( address => RewardToken ) public rewardToken;
    address[] public allRewardTokens;

    // Current Reward Token
    address public currentRewardToken;

    // User -> Share
    struct UserInfo {
        // share in MAXI
        uint256 balance;
        // excluded reward debt
        uint256 totalExcluded;
        // index in allUsers array
        uint256 index;
    }
    mapping ( address => UserInfo ) public userInfo;
    address[] public allUsers;

    // Tracking Info
    uint256 public totalShares;
    uint256 private dividendsPerShare;
    uint256 private constant precision = 10**18;

    // Ownership
    modifier onlyOwner() {
        require(
            msg.sender == IToken(ownableToken).getOwner(),
            'Only Token Owner'
        );
        _;
    }
    
    modifier onlyMAXI() {
        require(
            msg.sender == MAXI,
            'Only MAXI Can Call'
        );
        _;
    }

    constructor(
        address MAXI_,
        address rewardToken_,
        address rewardTokenSwapper_
    ) {
        require(
            MAXI_ != address(0) &&
            rewardToken_ != address(0) &&
            rewardTokenSwapper_ != address(0),
            'Zero Addresses'
        );

        // immutables
        ownableToken = address(IMAXI(MAXI_).token());
        MAXI = MAXI_;

        // current reward token data
        currentRewardToken = rewardToken_;

        // global reward token data
        rewardToken[rewardToken_].swapper = rewardTokenSwapper_;
        rewardToken[rewardToken_].hasBeenAdded = true;
        allRewardTokens.push(rewardToken_);

        // name + symbol
        _decimals = IERC20(rewardToken_).decimals();
    }



    ////////////////////////////////
    /////    TOKEN FUNCTIONS    ////
    ////////////////////////////////

    function name() external pure override returns (string memory) {
        return _name;
    }
    function symbol() external pure override returns (string memory) {
        return _symbol;
    }
    function decimals() external view override returns (uint8) {
        return _decimals;
    }
    function totalSupply() external view override returns (uint256) {
        return IERC20(currentRewardToken).balanceOf(address(this));
    }

    /** Shows The Amount Of Users' Pending Rewards */
    function balanceOf(address account) public view override returns (uint256) {
        return pendingRewards(account);
    }

    function transfer(address recipient, uint256) external override returns (bool) {
        require(
            userInfo[recipient].balance > 0,
            'Zero Balance'
        );
        _sendReward(recipient);
        return true;
    }
    function transferFrom(address, address recipient, uint256) external override returns (bool) {
        require(
            userInfo[recipient].balance > 0,
            'Zero Balance'
        );
        _sendReward(recipient);
        return true;
    }

    /** function has no use in contract */
    function allowance(address, address) external pure override returns (uint256) { 
        return 0;
    }
    /** function has no use in contract */
    function approve(address, uint256) public override returns (bool) {
        emit Approval(msg.sender, msg.sender, 0);
        return true;
    }



    ////////////////////////////////
    /////    OWNER FUNCTIONS    ////
    ////////////////////////////////

    function setRewardTokenSwapper(address newRewardSwapper) external onlyOwner {
        rewardToken[currentRewardToken].swapper = newRewardSwapper;
    }

    function withdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    /**
        MAKE SURE OWNER MASSCLAIMS() FOR ALL USERS PRIOR TO SETTING NEW REWARD TOKEN
    */
    function setRewardToken(address newRewardToken, address newRewardSwapper) external onlyOwner {
        require(
            newRewardToken != address(0) &&
            newRewardSwapper != address(0),
            'Zero Addresses'
        );

        // set global reward token stats
        rewardToken[newRewardToken].swapper = newRewardSwapper;

        // if new reward token
        if (rewardToken[newRewardToken].hasBeenAdded == false) {
            allRewardTokens.push(newRewardToken);
            rewardToken[newRewardToken].hasBeenAdded = true;
        }

        // update state
        currentRewardToken = newRewardToken;

        // update token display stats
        _decimals = IERC20(newRewardToken).decimals();
    }

    function setShare(address user, uint256 newShare) external onlyMAXI {
        if (userInfo[user].balance > 0) {
            _sendReward(user);
        }

        if (userInfo[user].balance == 0 && newShare > 0) {
            // new user
            userInfo[user].index = allUsers.length;
            allUsers.push(user);
        } else if (userInfo[user].balance > 0 && newShare == 0) {
            // user is leaving
            _removeUser(user);
        }

        // update total supply and user tracking info
        totalShares = totalShares - userInfo[user].balance + newShare;
        userInfo[user].balance = newShare;
        userInfo[user].totalExcluded = getTotalExcluded(newShare);
    }



    /////////////////////////////////
    /////   PUBLIC FUNCTIONS    /////
    /////////////////////////////////

    function donateRewards() external payable {
        _donateRewards();
    }

    receive() external payable {
        _donateRewards();
    }

    function donate(uint256 amount) external {
        uint256 received = _transferIn(currentRewardToken, amount);
        _register(received);
    }

    function massClaim() external {
        _massClaim(0, allUsers.length);
    }

    function massClaimFromIndexToIndex(uint256 startIndex, uint256 endIndex) external {
        _massClaim(startIndex, endIndex);
    }

    /////////////////////////////////
    ////   INTERNAL FUNCTIONS    ////
    /////////////////////////////////

    function _donateRewards() internal {

        // Token Before
        uint before = IERC20(currentRewardToken).balanceOf(address(this));

        // Use Reward Token Swapper To Purchase Reward Tokens
        (bool s,) = payable(rewardToken[currentRewardToken].swapper).call{value: address(this).balance}("");
        require(s, 'Failure On Swapper Purchase');

        // Check Amount Received
        uint After = IERC20(currentRewardToken).balanceOf(address(this));
        require(
            After > before,
            'Zero Received'
        );

        // Register Amount Received
        uint received = After - before;
        _register(received);
    }

    function _sendReward(address user) internal {
        if (userInfo[user].balance == 0) {
            return;
        }

        // track pending
        uint pending = pendingRewards(user);

        // avoid overflow
        if (pending > IERC20(currentRewardToken).balanceOf(address(this))) {
            pending = IERC20(currentRewardToken).balanceOf(address(this));
        }

        // update excluded earnings
        userInfo[user].totalExcluded = getTotalExcluded(userInfo[user].balance);
        
        // send reward to user
        if (pending > 0) {
            IERC20(currentRewardToken).transfer(user, pending);
        }
    }

    function _register(uint256 amount) internal {

        // Increment Total Rewards
        rewardToken[currentRewardToken].totalRewards += amount;

        // Add Dividends Per Share
        dividendsPerShare += ( precision * amount ) / totalShares;
    }

    function _transferIn(address token, uint256 amount) internal returns (uint256) {
        uint before = IERC20(token).balanceOf(address(this));
        require(
            IERC20(token).transferFrom(msg.sender, address(this), amount),
            'Failure On TransferFrom'
        );
        uint After = IERC20(token).balanceOf(address(this));
        require(
            After > before,
            'Error On Transfer In'
        );
        return After - before;
    }

    function _removeUser(address user) internal {

        // index to replace
        uint256 replaceIndex = userInfo[user].index;
        if (allUsers[replaceIndex] != user) {
            return;
        }

        // last user in array
        address lastUser = allUsers[allUsers.length - 1];

        // set last user's index to the replace index
        userInfo[lastUser].index = replaceIndex;

        // set replace index in array to last user
        allUsers[replaceIndex] = lastUser;

        // pop last user off the end of the array
        allUsers.pop();
        delete userInfo[user].index;
    }

    function _massClaim(uint256 startIndex, uint256 endIndex) internal {
        require(
            endIndex <= allUsers.length,
            'End Length Too Large'
        );

        for (uint i = startIndex; i < endIndex;) {
            _sendReward(allUsers[i]);
            unchecked { ++i; }
        }
    }

    ////////////////////////////////
    /////    READ FUNCTIONS    /////
    ////////////////////////////////

    function pendingRewards(address user) public view returns (uint256) {
        if(userInfo[user].balance == 0){ return 0; }

        uint256 userTotalExcluded = getTotalExcluded(userInfo[user].balance);
        uint256 userTrackedExcluded = userInfo[user].totalExcluded;

        if(userTotalExcluded <= userTrackedExcluded){ return 0; }

        return userTotalExcluded - userTrackedExcluded;
    }

    function getTotalExcluded(uint256 amount) public view returns (uint256) {
        return ( amount * dividendsPerShare ) / precision;
    }

    function viewAllRewardTokens() external view returns (address[] memory) {
        return allRewardTokens;
    }

    function viewAllUsers() external view returns (address[] memory) {
        return allUsers;
    }

    function holderCount() external view returns (uint256) {
        return allUsers.length;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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