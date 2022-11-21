//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IMDBP is IERC20 {
    function sell(uint256 tokenAmount) external returns (uint256);
    function burn(uint256 amount) external;
}

interface IPhoenix is IERC20 {
    function mintWithBacking(uint256 numTokens, address recipient) external returns (uint256);
}

contract PhoenixReinvest {

    // Phoenix+ Contract Address
    IPhoenix private constant phoenix = IPhoenix(0xfc62b18CAC1343bd839CcbEDB9FC3382a84219B9);

    // MDB+ Contract Address
    IMDBP private constant mdbp = IMDBP(0x9f8BB16f49393eeA4331A39B69071759e54e16ea);

    // BUSD Contract Address
    IERC20 public constant BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    // User Info Structure
    struct UserInfo {
        uint256 minAmountToHold; // minimum amount of MDB+ that must be preserved in a users wallet
        uint256 index; // index in the user array
        bool isUser; // true if user wants to be reinvested, false otherwise
    }

    // User => User Info
    mapping ( address => UserInfo ) public userInfo;

    // List Of All Users
    address[] public allUsers;

    // Current index in users list
    uint256 public currentSearchIndex;

    // Loop through all users, triggering their reinvestment if applicable
    function trigger(uint256 iterations) external {

        for (uint i = 0; i < iterations;) {

            if (currentSearchIndex >= allUsers.length) {
                currentSearchIndex = 0;
            }

            if (canTriggerForUser(allUsers[currentSearchIndex])) {
                _reinvest(allUsers[currentSearchIndex]);
            } else {
                if (!hasGivenAllowance(allUsers[currentSearchIndex], amountToRevinest(allUsers[currentSearchIndex]))) {
                    _removeUser(allUsers[currentSearchIndex]);
                }
            }
            unchecked { ++i; currentSearchIndex++; }
        }
    }

    // Loop through user array passed in, triggering their reinvestment if applicable
    function triggerForUsers(address[] calldata users) external {
        uint length = users.length;

        for (uint i = 0; i < length;) {
            if (canTriggerForUser(users[i])) {
                _reinvest(users[i]);
            } else {
                if (!hasGivenAllowance(users[i], amountToRevinest(users[i]))) {
                    _removeUser(users[i]);
                }
            }
            unchecked { ++i; }
        }
    }

    // opts into the system
    function optIn(uint256 minAmountToHold) external {

        // set minimum amount to hold
        userInfo[msg.sender].minAmountToHold = minAmountToHold;

        // add user to list if they have not been added before
        if (userInfo[msg.sender].isUser == false) {
            userInfo[msg.sender].isUser = true;
            userInfo[msg.sender].index = allUsers.length;
            allUsers.push(msg.sender);
        }
    }

    function optOut() external {
        _removeUser(msg.sender);
    }



    function _reinvest(address user) internal {

        // amount to reinvest for user
        uint256 amount = amountToRevinest(user);
        if (amount == 0) {
            return;
        }

        // transfer tokens from user into this contract
        mdbp.transferFrom(user, address(this), amount);

        // fetch new balance of tokens after transfer
        uint256 balance = mdbp.balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        // Burn 0.25%
        uint256 toBurn = ( balance * 25 ) / 10**4;

        // burn mdbp
        mdbp.burn(toBurn);

        // subtract to burn from balance
        balance -= toBurn;
        
        // sell MDBP for BUSD
        mdbp.sell(balance);

        // Fetch Amount Of BUSD Received
        uint256 busdBalance = BUSD.balanceOf(address(this));
        if (busdBalance == 0) {
            return;
        }        

        // Approve BUSD For Phoenix
        BUSD.approve(address(phoenix), busdBalance);

        // Mint Phoenix+ With BUSD For User
        phoenix.mintWithBacking(busdBalance, user);
    }
    
    function _removeUser(address user) internal {

        if (userInfo[user].isUser == false) {
            return;
        }

        // set users index to be last element
        allUsers[
            userInfo[user].index
        ] = allUsers[allUsers.length - 1];

        // set last elements index to be users
        userInfo[
            allUsers[allUsers.length - 1]
        ].index = userInfo[user].index;

        // pop last element off the end of the array
        allUsers.pop();

        // clear user data
        delete userInfo[user];
    }



    function canTriggerForUser(address user) public view returns (bool) {
        return userInfo[user].isUser && hasOverMinimumBalance(user) && hasGivenAllowance(user, amountToRevinest(user));
    }

    function amountToRevinest(address user) public view returns (uint256) {

        uint balanceOfUser = mdbp.balanceOf(user);
        uint minAmount = userInfo[user].minAmountToHold;

        return ( balanceOfUser > minAmount && userInfo[user].isUser ) ? balanceOfUser - minAmount : 0;
    }

    function hasOverMinimumBalance(address user) public view returns (bool) {
        return mdbp.balanceOf(user) > userInfo[user].minAmountToHold;
    }

    function hasGivenAllowance(address user, uint256 amount) public view returns (bool) {
        return mdbp.allowance(user, address(this)) >= amount;
    }

    function nUsers() external view returns (uint256) {
        return allUsers.length;
    }

}