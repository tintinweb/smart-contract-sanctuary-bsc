// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;
import "./USDTInterface.sol";
import "./EventContract.sol";
import "./Strings.sol";

contract ROBN_USDT is EventContract {

    string public name;
    string public symbol;
    address private income_reserve;
    bool private set_income_reserve;
    uint256 private check_last_index_queue = 0;
    uint8 public decimals = 6;

    struct Ini {
        uint256 totalPecent;
        uint256 pecentValue;
        uint256 value_min;
        uint256 value_max;
        address owner;
        address income;
    }

    Ini public ini;

    USDTInterface USDTContract = USDTInterface(0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C); // USDT Contract Production

    struct Queue {
        address destination;
        uint256 value;
        uint256 value_pecent;
        uint256 data;
        uint    blockNumber;
    }

    Queue[] public queues;

    constructor() {
        name = "DEX Robin Hood Community";
        symbol = "ROBN_USDT";
        set_income_reserve = false;
        ini.totalPecent = 0;
        ini.pecentValue = 3;
        ini.value_min = 20000000;
        ini.value_max = 5000000000;
        ini.owner = address(this);
        ini.income = msg.sender;
    }

    function init (address _address) public returns (bool) {
        require(msg.sender == ini.income, "You cannot perform this action");
        require(set_income_reserve == false, "income_reserve is init");
        income_reserve = _address;
        set_income_reserve = true;
        return true;
    }

    function buyToken(uint256 _amount) public returns (bool) {
        require(_amount >= ini.value_min, "Invalid minimum deposit!!");
        require(_amount <= ini.value_max, "Invalid maximum deposit!!");
        require(msg.sender != address(0), "TRC20: mint to the zero address");
        uint256 a = USDTContract.allowance(msg.sender, ini.owner);
        require(a >= _amount, "No withdrawal permission or insufficient balance");
        USDTContract.transferFrom(msg.sender, ini.owner, _amount);
        ini.totalPecent += _amount / 100 * ini.pecentValue;
        _addQueue(msg.sender, _amount, _amount / 10000 * 83);
        emit NewDeposit(block.timestamp, msg.sender, _amount, block.number);
        return true;
    }

    function balanceOfUSDT() public view returns (uint256) {
        return USDTContract.balanceOf(ini.owner);
    }

    function setNewIncome(address destination) public returns (bool) {
        require(set_income_reserve == true, "income_reserve is no init");
        require(msg.sender == income_reserve,"You cannot perform this action");
        ini.income = destination;
        return true;
    }

    function getIncome() public returns (bool) {
        require(
            msg.sender == ini.income,
            "You cannot perform this action"
        );
        USDTContract.transfer(msg.sender, ini.totalPecent);
        ini.totalPecent = 0;
        return true;
    }

    function ckeckQueueOne() public returns (bool) {
        if (queues.length > 0 && block.timestamp > queues[check_last_index_queue].data) {
            _transferQueue(queues[check_last_index_queue].destination, queues[check_last_index_queue].value + queues[check_last_index_queue].value_pecent);
        }
        return true;
    }

    function checkQueueInPay() public view returns(uint256) {
        uint256 count = 0;
        for (uint a = check_last_index_queue; a < queues.length; a++) {
              if (block.timestamp > queues[a].data) {
                 count++;
              } else {
                break;
            }
        }
        return count;
    }

    function getQueueLength() public view returns(uint256) {
        return queues.length - check_last_index_queue;
    }

    function getQueue(uint256 page, uint256 pageSize) public view returns (string memory, uint256){
        require(pageSize > 0, "page size must be positive");
        require(pageSize < 31, "page size must be max 30 element");
        require(page == 0 || page*pageSize <= queues.length + check_last_index_queue, "out of bounds");
        uint256 actualSize = pageSize;
        if ((page+1)*pageSize > queues.length) {
            actualSize = queues.length - page*pageSize;
        }
        string memory output = "{";
        for (uint256 i = check_last_index_queue; i < actualSize + check_last_index_queue; i++){
            if (page*pageSize+i < queues.length) {
            output = string(abi.encodePacked(output,
                "\"",Strings.toString(page*pageSize+i),"\": {",
                    "\"destination\":\"", Strings.toHexString(queues[page*pageSize+i].destination), "\",",
                    "\"value\":", Strings.toString(queues[page*pageSize+i].value), ",",
                    "\"value_pecent\":",Strings.toString(queues[page*pageSize+i].value_pecent), ",",
                    "\"data\":",Strings.toString(queues[page*pageSize+i].data), ","
            ));
            output = string(abi.encodePacked(output,"\"blockNumber\":",Strings.toString(queues[page*pageSize+i].blockNumber)));
            if (i != actualSize + check_last_index_queue - 1 && page*pageSize+i > queues.length) {
              output = string(abi.encodePacked(output,"},"));
            } else {
                output = string(abi.encodePacked(output,"}"));
            }
            }
        }
        output = string(abi.encodePacked(output, "}"));
        return (output, queues.length - check_last_index_queue);
     }



    function _transferQueue (address _from, uint256 _amount) private {
        if (USDTContract.balanceOf(ini.owner) >= _amount) {
                USDTContract.transfer(_from , _amount);
                delete queues[check_last_index_queue];
                check_last_index_queue++;
                emit OutQueueDeposit(block.timestamp, _from , _amount, block.number);
        }
    }

    function _addQueue(address destination, uint256 value, uint256 pecent) private {
        Queue memory queue = Queue(destination, value, pecent, block.timestamp + 5 days, block.number);
        queues.push(queue);
        ckeckQueueOne();
        emit AddQueue(msg.sender, value, pecent, block.number);
    }

}