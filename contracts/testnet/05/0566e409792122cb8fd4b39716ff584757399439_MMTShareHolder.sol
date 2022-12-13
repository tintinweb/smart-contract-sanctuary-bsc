// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Lockable.sol";

contract MMTShareHolder is Lockable {
    uint8 private constant shareholders_count = 5;
    uint8 private constant require_approve_count = 3;

    address [] private shareholderAddresses;
    address private mmtAddress;

    struct SpendData {
        uint256 index;
        uint256 amount;
        address receiver;
        address addr1;
        address addr2;
        address addr3;
        uint256 date;
        uint8 status;//0-waiting for approve;1-transfered; 2-canceled
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

    constructor(address [] memory _shareholders, address _mmtAddress) {
        require(_shareholders.length == shareholders_count, "input error");
        shareholderAddresses = new address[](shareholders_count);
        shareholderAddresses = _shareholders;
        mmtAddress = _mmtAddress;
    }

    function getHolders() external view returns (address [] memory _holders) {
        _holders = new address[](shareholders_count);
        _holders = shareholderAddresses;
    }

    function transfer(uint256 amount, address to) external onlyShareholder lock {
        require(amount > 0 && to == address(to), "input error");
        require(msg.sender != address(0), "from address error");
        if(mapSpend[index].amount == 0 || mapSpend[index].status > 0) {
            ++index;
            mapSpend[index] = SpendData(index, amount, to, msg.sender, address(0), address(0), block.timestamp, 0);
        } else {
            SpendData storage sd = mapSpend[index];
            require(msg.sender != sd.addr1 && msg.sender != sd.addr2 && msg.sender != sd.addr3, "u'd approved");
            require(amount == sd.amount, "amount error");
            require(to == sd.receiver, "receiver error");
            if(sd.addr2 == address(0)) {
                sd.addr2 = msg.sender;
            } else if(sd.addr3 == address(0)) {
                sd.addr3 = msg.sender;
            }

            if(sd.addr3 != address(0)) {
                require(IERC20(mmtAddress).balanceOf(address(this)) >= amount, "insufficient balance");
                require(IERC20(mmtAddress).transfer(to, amount), "transfer error");
                sd.status = 1;
            }
        }
    }

    function cancelTransfer() external onlyShareholder lock {
        bool canceled = false;
        if(index > 0 && mapSpend[index].amount > 0){
            if(mapSpend[index].addr2 == address(0)) {
                SpendData storage sd = mapSpend[index];
                sd.addr2 = msg.sender;
                sd.status = 2;
                canceled = true;
            } else if(mapSpend[index].addr3 == address(0)) {
                SpendData storage sd = mapSpend[index];
                sd.addr3 = msg.sender;
                sd.status = 2;
                canceled = true;
            }
        }
        if(!canceled) {
            revert("can not cancel");
        }
    }

    function getMaxIndex() external view returns (uint256 res) {
        res = index;
    }

    function getSpendData(uint256 _index) external view returns (bool res, uint256 id, uint256 amount, address receiver, address addr1, address addr2, address addr3, uint256 date, uint8 status) {
        if(mapSpend[_index].amount > 0) {
            res = true;
            id = mapSpend[_index].index;
            amount = mapSpend[_index].amount;
            receiver = mapSpend[_index].receiver;
            addr1 = mapSpend[_index].addr1;
            addr2 = mapSpend[_index].addr2;
            addr3 = mapSpend[_index].addr3;
            date = mapSpend[_index].date;
            status = mapSpend[_index].status;
        }
    }

    function isSpendCanceled(uint256 _index) external view returns (bool res) {
        if(mapSpend[_index].status == 2) {
            res = true;
        }
    }
}