//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IToken {
    function getOwner() external view returns (address);
}

contract RewardDistributor is IERC20 {

    // Token With Governance
    address public immutable token;

    // Internal Token Metrics
    string private constant _name = 'OpRise Rewards';
    string private constant _symbol = 'opBNB';
    uint8 private constant _decimals = 18;

    // User -> Share
    struct UserInfo {
        // token share
        uint256 balance;
        // excluded reward debt
        uint256 totalExcluded;
        // index in allUsers array
        uint256 index;
        // manually opt out of getting rewards
        bool hasOptedOut;
    }
    mapping ( address => UserInfo ) public userInfo;
    address[] public allUsers;

    // Tracking Info
    uint256 public totalShares;
    uint256 public totalRewards;
    uint256 private dividendsPerShare;
    uint256 private constant precision = 10**18;

    // Ownership
    modifier onlyOwner() {
        require(
            msg.sender == IToken(token).getOwner(),
            'Only Token Owner'
        );
        _;
    }
    
    modifier onlyToken() {
        require(
            msg.sender == token,
            'Only Token Can Call'
        );
        _;
    }

    constructor(
        address token_
    ) {
        token = token_;
    }

    event FailedToSendReward(address user, uint256 amount);

    ////////////////////////////////
    /////    TOKEN FUNCTIONS    ////
    ////////////////////////////////

    function name() external pure override returns (string memory) {
        return _name;
    }
    function symbol() external pure override returns (string memory) {
        return _symbol;
    }
    function decimals() external pure override returns (uint8) {
        return _decimals;
    }
    function totalSupply() external view override returns (uint256) {
        return address(this).balance;
    }

    /** Shows The Amount Of Users' Pending Rewards */
    function balanceOf(address account) public view override returns (uint256) {
        return pendingRewards(account);
    }

    function transfer(address recipient, uint256) external override returns (bool) {
        _sendReward(recipient);
        return true;
    }
    function transferFrom(address, address recipient, uint256) external override returns (bool) {
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

    function withdraw(address _token, uint256 amount) external onlyOwner {
        IERC20(_token).transfer(msg.sender, amount);
    }

    function withdrawBNB(uint256 amount) external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: amount}("");
        require(s);
    }

    function setShare(address user, uint256 newShare) external onlyToken {
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
        totalShares = totalShares + newShare - userInfo[user].balance;
        userInfo[user].balance = newShare;
        userInfo[user].totalExcluded = getTotalExcluded(newShare);
    }

    /////////////////////////////////
    /////   PUBLIC FUNCTIONS    /////
    /////////////////////////////////

    function donateRewards() external payable {
        _register(msg.value);
    }

    receive() external payable {
        _register(msg.value);
    }

    function massClaim() external {
        _massClaim(0, allUsers.length);
    }

    function massClaimFromIndexToIndex(uint256 startIndex, uint256 endIndex) external {
        _massClaim(startIndex, endIndex);
    }

    function claim() external {
        _sendReward(msg.sender);
    }

    function optOut() external {
        userInfo[msg.sender].hasOptedOut = true;
    }

    function optIn() external {
        userInfo[msg.sender].hasOptedOut = false;
    }

    /////////////////////////////////
    ////   INTERNAL FUNCTIONS    ////
    /////////////////////////////////


    function _sendReward(address user) internal {
        if (userInfo[user].balance == 0) {
            return;
        }

        // track pending
        uint pending = pendingRewards(user);

        // avoid overflow
        if (pending > address(this).balance) {
            pending = address(this).balance;
        }

        // update excluded earnings
        userInfo[user].totalExcluded = getTotalExcluded(userInfo[user].balance);
        
        // send reward to user
        if (pending > 0 && !userInfo[user].hasOptedOut) {
            (bool s,) = payable(user).call{value: pending, gas: 2300}("");
            if (!s) {
                emit FailedToSendReward(user, pending);
            }
        }
    }

    function _register(uint256 amount) internal {

        // Increment Total Rewards
        totalRewards += amount;

        // Add Dividends Per Share
        if (totalShares > 0) {
            dividendsPerShare += ( precision * amount ) / totalShares;
        }
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