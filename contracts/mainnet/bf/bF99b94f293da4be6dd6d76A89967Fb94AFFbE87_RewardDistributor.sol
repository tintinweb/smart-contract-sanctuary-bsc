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
    address public immutable ownableToken = 0x988ce53ca8d210430d4a9af0DF4b7dD107A50Db6;

    // MAXI Staking Protocol
    address public immutable MAXI;

    // Internal Token Metrics
    string private constant _name = 'PUSD Rewards';
    string private constant _symbol = 'rPUSD';
    uint8 private constant _decimals = 18;

    // Current Reward Token
    address public constant rewardToken = 0x9fE2C7040c4b3a8F08d6a8f271a6d15bDADD52B9;

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
    uint256 public totalRewards;
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
        address MAXI_
    ) {
        require(
            MAXI_ != address(0),
            'Zero Addresses'
        );

        // immutables
        MAXI = MAXI_;
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
    function decimals() external pure override returns (uint8) {
        return _decimals;
    }
    function totalSupply() external view override returns (uint256) {
        return IERC20(rewardToken).balanceOf(address(this));
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

    function withdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
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
        uint256 received = _transferIn(rewardToken, amount);
        _register(received);
    }


    /////////////////////////////////
    ////   INTERNAL FUNCTIONS    ////
    /////////////////////////////////

    function _donateRewards() internal {

        // Token Before
        uint before = IERC20(rewardToken).balanceOf(address(this));

        // Use Reward Token Swapper To Purchase Reward Tokens
        (bool s,) = payable(rewardToken).call{value: address(this).balance}("");
        require(s, 'Failure On Swapper Purchase');

        // Check Amount Received
        uint After = IERC20(rewardToken).balanceOf(address(this));
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
        if (pending > IERC20(rewardToken).balanceOf(address(this))) {
            pending = IERC20(rewardToken).balanceOf(address(this));
        }

        // update excluded earnings
        userInfo[user].totalExcluded = getTotalExcluded(userInfo[user].balance);
        
        // send reward to user
        if (pending > 0) {
            IERC20(rewardToken).transfer(user, pending);
        }
    }

    function _register(uint256 amount) internal {

        // Increment Total Rewards
        unchecked {
            totalRewards += amount;
        }

        if (totalShares > 0) {
            // Add Dividends Per Share
            unchecked {
                dividendsPerShare += ( precision * amount ) / totalShares;
            }
        }
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