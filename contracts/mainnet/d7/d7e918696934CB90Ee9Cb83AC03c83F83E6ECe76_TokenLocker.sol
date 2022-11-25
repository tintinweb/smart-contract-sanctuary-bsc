/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

/*
          ▄█        ▄██████▄   ▄████████    ▄█   ▄█▄    ▄████████    ▄████████ 
          ███       ███    ███ ███    ███   ███ ▄███▀   ███    ███   ███    ███ 
          ███       ███    ███ ███    █▀    ███▐██▀     ███    █▀    ███    ███ 
          ███       ███    ███ ███         ▄█████▀     ▄███▄▄▄      ▄███▄▄▄▄██▀ 
          ███       ███    ███ ███        ▀▀█████▄    ▀▀███▀▀▀     ▀▀███▀▀▀▀▀   
          ███       ███    ███ ███    █▄    ███▐██▄     ███    █▄  ▀███████████ 
          ███▌    ▄ ███    ███ ███    ███   ███ ▀███▄   ███    ███   ███    ███ 
          █████▄▄██  ▀██████▀  ████████▀    ███   ▀█▀   ██████████   ███    ███ 
          ▀                                 ▀                        ███    ███ 
*/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract TokenLocker {
    struct LockData {
        uint256[] durations;
        uint256[] amounts;
        address[] tokens;
        uint256 counter;
    }
    mapping(address => LockData) public userData;
    mapping(address => bool) public uniqueToken;
    address[] public uniqueTokenAddress;

    function lock(
        address _token,
        uint256 amount,
        uint256 lockduration
    ) external returns (bool) {
        if (uniqueToken[_token] == false) {
            uniqueToken[_token] = true;
            uniqueTokenAddress.push(_token);
        }

        IERC20(_token).transferFrom(msg.sender, address(this), amount);
        userData[msg.sender].amounts.push(amount);
        userData[msg.sender].durations.push(block.timestamp + lockduration);
        userData[msg.sender].tokens.push(_token);
        userData[msg.sender].counter++;
        return true;
    }

    function unlock(uint256 _index) external returns (bool) {
        require(
            _index < userData[msg.sender].amounts.length,
            "Invalid locking index"
        );
        require(
            userData[msg.sender].amounts[_index] > 0,
            "This locking already have been payed!"
        );
        require(
            userData[msg.sender].durations[_index] <= block.timestamp,
            "Time is not reached yet"
        );
        IERC20(userData[msg.sender].tokens[_index]).transfer(
            msg.sender,
            userData[msg.sender].amounts[_index]
        );
        userData[msg.sender].amounts[_index] = 0;
        userData[msg.sender].tokens[_index] = address(0);
        userData[msg.sender].durations[_index] = 0;
        return true;
    }

    function getLockedAmount(address _user,uint256 _index)
        external
        view
        returns (
            uint256 amount,
            uint256 time,
            address token
        )
    {
        amount = userData[_user].amounts[_index];
        time = userData[_user].durations[_index];
        token = userData[_user].tokens[_index];
    }
}