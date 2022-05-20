// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./AccessControlEnumerable.sol";
import "./IERC20.sol";

contract PrivateSale is AccessControlEnumerable {

    IERC20 public parent;

    bool public released = false;
    uint256 public releaseDate = 0;
    uint256 public availableCoinsInPrivateSale = 0;
    uint256 public secondRelease = 14 days;
    uint256 public thirdRelease = 28 days;

    mapping(address => uint256) internal holders;
    mapping(address => bool) internal releaseDateDistributed;
    mapping(address => bool) internal twoWeeksDistributed;
    mapping(address => bool) internal fourWeeksDistributed;

    constructor() {
        parent = IERC20(0x66b20dE23432Fc56F8C980caA3A2A658ecca1544);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Add coins
    function addCoins(uint256 _amount) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Csw Locker: must have admin role to deposit coins");
        parent.transferFrom(msg.sender, address(this), _amount);
        availableCoinsInPrivateSale = availableCoinsInPrivateSale + _amount;
    }

    // My Coins
    function myCoins() public view returns(uint256) {
        uint256 coinsLeft = holders[msg.sender];
        if(releaseDateDistributed[msg.sender]) {
            coinsLeft = coinsLeft - (holders[msg.sender] / 2);
        }
        if(twoWeeksDistributed[msg.sender]) {
            coinsLeft = coinsLeft - (holders[msg.sender] / 4);
        }
        if(fourWeeksDistributed[msg.sender]) {
            coinsLeft = coinsLeft - (holders[msg.sender] / 4);
        }
        return coinsLeft;
    }

    // Get Coins coint by address
    function coinsOf(address _owner) public view returns(uint256) {
        uint256 coinsLeft = holders[_owner];
        if(releaseDateDistributed[_owner]) {
            coinsLeft = coinsLeft - (holders[_owner] / 2);
        }
        if(twoWeeksDistributed[_owner]) {
            coinsLeft = coinsLeft - (holders[_owner] / 4);
        }
        if(fourWeeksDistributed[_owner]) {
            coinsLeft = coinsLeft - (holders[_owner] / 4);
        }
        return coinsLeft;
    }

    // Lock Coins
    function lockCoins(address _owner, uint256 _amount) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Csw Locker: must have admin role to lock coins");
        uint256 existingCoins = holders[_owner];
        if(existingCoins != 0) {
            holders[_owner] = holders[_owner] + _amount;
        } else {
            holders[_owner] = _amount;
        }
        availableCoinsInPrivateSale = availableCoinsInPrivateSale - _amount;
    }

    // Withdraw Coins
    function withdrawCoins() public {
        require(released, "Csw Locker: CSW are not released");

        bool isTwoWeeksAfter = releaseDate + secondRelease <= block.timestamp;
        bool isFourWeeksAfter = releaseDate + thirdRelease <= block.timestamp;

        uint256 coinsToDistribite = 0;
        if (!releaseDateDistributed[msg.sender]) {
            coinsToDistribite = coinsToDistribite + holders[msg.sender] / 2;
            releaseDateDistributed[msg.sender] = true;
        }
        if(isTwoWeeksAfter) {
            if (!twoWeeksDistributed[msg.sender]) {
                coinsToDistribite = coinsToDistribite + (holders[msg.sender] / 4);
                twoWeeksDistributed[msg.sender] = true;
            }
        } 
        if (isFourWeeksAfter) {
            if (!fourWeeksDistributed[msg.sender]) {
                coinsToDistribite = coinsToDistribite + (holders[msg.sender] / 4);
                fourWeeksDistributed[msg.sender] = true;
            }
        }
        if (coinsToDistribite != 0) {
            parent.approve(address(this), coinsToDistribite);
            parent.transferFrom(address(this), msg.sender, coinsToDistribite);
        }
    }

    // Get Available Coins to Withdraw
    function availableToWithdraw(address _address) public view returns (uint256) {
        bool isTwoWeeksAfter = releaseDate + secondRelease <= block.timestamp;
        bool isFourWeeksAfter = releaseDate + thirdRelease <= block.timestamp;
        uint256 available = 0;
        if(released) {
            if (!releaseDateDistributed[_address]) {
                available = available + holders[_address] / 2;
            }
            if(isTwoWeeksAfter) {
                if (!twoWeeksDistributed[_address]) {
                    available = available + (holders[_address] / 4);
                }
            } 
            if (isFourWeeksAfter) {
                if (!fourWeeksDistributed[_address]) {
                    available = available + (holders[_address] / 4);
                }
            }
        }
        return available;
    }

    // Withdraw Not Sold Coins
    function withdrawNotSoldCoins() public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Csw Locker: must have admin role to withdraw not sold coins");
        parent.approve(address(this), availableCoinsInPrivateSale);
        parent.transferFrom(address(this), msg.sender, availableCoinsInPrivateSale);
        availableCoinsInPrivateSale = 0;
    }

    // Release
    function release() public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Csw Locker: must have admin role to enable release");
        releaseDate = block.timestamp;
        released = true;
    }

    // Stop Release
    function stopRelease() public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Csw Locker: must have admin role to stop release");
        released = false;
        releaseDate = 0;
    }

    // Change Parrent
    function changeParent(address _parent) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Csw Locker: must have admin role to change parent");
        parent = IERC20(_parent);
    }
}