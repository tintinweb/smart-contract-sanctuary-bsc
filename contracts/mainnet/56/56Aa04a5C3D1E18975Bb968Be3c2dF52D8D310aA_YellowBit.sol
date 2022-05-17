/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// SPDX-License-Identifier: UNLICENSED
// https://yellowbit.eth.limo
/*
 * Y88b   d88P          888 888                        888888b.   d8b 888
 *  Y88b d88P           888 888                        888  "88b  Y8P 888
 *   Y88o88P            888 888                        888  .88P      888
 *    Y888P     .d88b.  888 888  .d88b.  888  888  888 8888888K.  888 888888
 *     888     d8P  Y8b 888 888 d88""88b 888  888  888 888  "Y88b 888 888
 *     888     88888888 888 888 888  888 888  888  888 888    888 888 888
 *     888     Y8b.     888 888 Y88..88P Y88b 888 d88P 888   d88P 888 Y88b.
 *     888      "Y8888  888 888  "Y88P"   "Y8888888P"  8888888P"  888  "Y888
 */

pragma solidity ^0.8.9;

contract YellowBit {
    struct User {
        uint256 id;
        address addr;
        address referrer;
        uint256 earned;
    }

    uint256 public count;
    mapping(address => User) public users;
    mapping(uint256 => address) public addresses;

    event Joined(address indexed addr, uint256 id, uint256 timestamp);
    event Received(address indexed addr, uint256 id, uint256 amount);

    constructor() {
        createUser(address(0));
    }

    function createUser(address referrer) internal {
        count += 1;
        addresses[count] = msg.sender;

        users[msg.sender] = User({
            id: count,
            addr: msg.sender,
            referrer: referrer,
            earned: 0
        });

        // solhint-disable-next-line not-rely-on-time
        emit Joined({addr: msg.sender, id: count, timestamp: block.timestamp});
    }

    function reward(User storage user, uint256 amount) internal {
        user.earned += amount;

        payable(user.addr).transfer(amount);

        emit Received({addr: user.addr, id: user.id, amount: amount});
    }

    function join(uint256 referrerId) external payable {
        require(msg.value == 0.08 ether, "Must be 0.08 BNB to join");
        require(users[msg.sender].id == 0, "The user is already registered");

        address referrer = addresses[referrerId];
        require(referrer != address(0), "The referrer does not exist");

        createUser(referrer);

        uint256 amount = msg.value;
        User storage current = users[referrer];

        for (uint256 i = 0; i < 10; i++) {
            if (current.id == 1 || i == 9) {
                reward(current, amount);
                break;
            }

            amount = amount / 2;

            reward(current, amount);

            current = users[current.referrer];
        }
    }
}