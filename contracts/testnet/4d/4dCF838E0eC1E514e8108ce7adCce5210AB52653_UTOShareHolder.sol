// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Lockable.sol";

contract UTOShareHolder is Lockable {
    uint8 private constant shareholders_count = 5;
    uint8 private constant require_approve_count = 3;

    address [] private shareholderAddresses;
    address private utoAddress;

    struct SpendData {
        uint256 amount;
        address addr1;
        address addr2;
        address addr3;
    }

    uint256 private index;

    mapping(uint256 => SpendData) mapSpend;

    modifier onlyShareholder {
        require(msg.sender ==  shareholderAddresses[0] ||
        msg.sender ==  shareholderAddresses[1] ||
        msg.sender ==  shareholderAddresses[2] ||
        msg.sender ==  shareholderAddresses[3] ||
        msg.sender ==  shareholderAddresses[4], "shareholder only");
        _;
    }

    constructor(address [] memory _shareholders, address _utoAddress) {
        require(_shareholders.length == shareholders_count, "input error");
        shareholderAddresses = new address[](shareholders_count);
        shareholderAddresses = _shareholders;
        utoAddress = _utoAddress;
    }

    function transfer(uint256 amount, address to) external onlyShareholder lock {
        require(amount > 0 && to == address(to), "input error");
        if(mapSpend[index].amount == 0) {
            mapSpend[++index] = SpendData(amount, msg.sender, address(0), address(0));
        } else {
            SpendData storage sd = mapSpend[index];
            if(sd.addr2 == address(0)) {
                sd.addr2 = msg.sender;
            } else if(sd.addr3 == address(0)) {
                sd.addr3 = msg.sender;
            }

            if(sd.addr3 != address(0)) {
                require(ERC20(utoAddress).balanceOf(address(this)) >= amount, "insufficient balance");
                require(ERC20(utoAddress).transfer(to, amount), "transfer error");
                ++index;
            }
        }
    }

    function cancelTransfer() external onlyShareholder lock {
        if(mapSpend[index].amount > 0 && mapSpend[index].addr3 == address(0)) {
            ++index;
        } else {
            revert("can not cancel");
        }
    }

    function getMaxIndex() external view returns (uint256 res) {
        res = index;
    }

    function getSpendData(uint256 _index) external view returns (bool res, uint256 amount,address addr1,address addr2,address addr3) {
        if(mapSpend[_index].amount > 0) {
            res = true;
            amount = mapSpend[_index].amount;
            addr1 = mapSpend[_index].addr1;
            addr2 = mapSpend[_index].addr2;
            addr3 = mapSpend[_index].addr3;
        }
    }

    function isSpendCanceled(uint256 _index) external view returns (bool res) {
        if(mapSpend[_index].amount > 0 && mapSpend[index].addr3 == address(0) && _index != index) {
            res = true;
        }
    }
}