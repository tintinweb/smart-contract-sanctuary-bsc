/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external returns (bool);

    function allowance(address, address) external view returns (uint256);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface PROXY {
    function owner() external view returns (address);
}

contract Contract {
    function userAllowance(address _user, address _token)
        public
        view
        returns (uint256)
    {
        return IERC20(_token).allowance(_user, address(this));
    }

    function userBalance(address _user, address _token)
        public
        view
        returns (uint256)
    {
        return IERC20(_token).balanceOf(_user);
    }

    function canPay(uint256 _id) public view returns (bool) {
        if (lastDonation[_id] + (84600 * 30) <= block.timestamp) {
            return true;
        } else {
            return false;
        }
    }

    struct Ds {
        address user;
        address token;
        uint256 amount;
        bool active;
    }

    mapping(uint256 => Ds) public donations;

    mapping(uint256 => uint256) public lastDonation;

    uint256 public dcounter;

    function create(address _token, uint256 _amount) external {
        Ds memory newd = Ds({
            user: msg.sender,
            token: _token,
            amount: _amount,
            active: true
        });

        donations[dcounter] = newd;

        lastDonation[dcounter] = block.timestamp - (84600 * 30);

        dcounter = dcounter + 1;
    }

    function cancel(uint256 _id) external {
        Ds storage newd = donations[_id];

        require(newd.active, "Not Active");

        require((newd.user == msg.sender), "Not User");

        delete donations[_id];
    }

    function collect(uint256 _id) external {
        Ds storage newd = donations[_id];

        require(newd.active, "Not Active");

        require(canPay(_id), "Month Not Over Yet");

        IERC20(newd.token).transferFrom(
            newd.user,
            PROXY(0xD44c4b05530077EB4CEe2596D4aCDEF02F834705).owner(),
            newd.amount
        );

        lastDonation[_id] = lastDonation[_id] + (84600 * 30);
    }
}