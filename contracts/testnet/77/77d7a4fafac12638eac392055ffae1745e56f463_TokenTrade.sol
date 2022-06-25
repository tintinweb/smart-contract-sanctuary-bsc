/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function balanceOf(address account) external virtual view returns (uint256);
}

contract Modifier {
    address internal owner; // Constract creater
    address internal approveAddress;
    bool public running = true;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status;

    modifier onlyOwner(){
        require(msg.sender == owner, "Modifier: The caller is not the creator");
        _;
    }

    modifier onlyApprove(){
        require(msg.sender == approveAddress || msg.sender == owner, "Modifier: The caller is not the approveAddress");
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier isRunning {
        require(running, "Modifier: No Running");
        _;
    }

    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
    }

    function setApproveAddress(address externalAddress) public onlyOwner(){
        approveAddress = externalAddress;
    }

    function startStop() public onlyOwner returns (bool success) {
        if (running) { running = false; } else { running = true; }
        return true;
    }

    /*
     * @dev Get approve address
     */
    function getApproveAddress() internal view returns(address){
        return approveAddress;
    }

    fallback () payable external {}
    receive () payable external {}
}

library Counters {
    struct Counter {uint256 _value;}

    function current(Counter storage counter) internal view returns (uint256) {return counter._value;}

    function increment(Counter storage counter) internal {unchecked {counter._value += 1;}}

    function decrement(Counter storage counter) internal {uint256 value = counter._value; require(value > 0, "Counter: decrement overflow"); unchecked {counter._value = value - 1;}}

    function reset(Counter storage counter) internal {counter._value = 0;}
}

library SafeMath {
    /* a + b */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /* a - b */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    /* a * b */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /* a / b */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    /* a / b */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* a % b */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    /* a % b */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Util {

    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

}

contract TokenTrade is Modifier, Util {

    using SafeMath for uint;
    using Counters for Counters.Counter;
    Counters.Counter private orderId;

    uint256 public _pledgeAmount;
    uint256 public _hangPoundage;
    uint256 public _exchangePoundage;

    address private poundageAddress;

    struct Order {
        uint256 id;
        uint256 pledgeAmount;
        address outputAddress;
        address receiveAddress;
        uint256 outputAmount;
        uint256 receiveAmount;
        address sellAdress;
        address buyAddress;
        uint256 status;
        uint256 hangPoundage;
        uint256 exchangePoundage;
    }
    Order order;

    mapping(uint256 => mapping(address => Order)) private orderRecord;
    mapping(uint256 => Order) orderMapping;

    ERC20 private pledgeToken;

    constructor() {
        _hangPoundage = 5;
        _exchangePoundage = 5;
        _pledgeAmount = 100000000000000000000;
        poundageAddress = 0xD9720129c57d7dE1081BEbFce02069e2D0AfBa36;
        pledgeToken = ERC20(0xD4Da02aA780b257D3AB7cD4A9F8E50dDf1B6aFE1); 
    }

    function setTokenContract(address _pledgeToken) public onlyOwner {
        pledgeToken = ERC20(_pledgeToken);
    }

    function setPoundageAddress(address _address) public onlyOwner {
        poundageAddress = _address;
    }

    function setPledgeAmount(uint256 amountToWei) public onlyOwner {
        _pledgeAmount = amountToWei;
    }

    function setHangPoundage(uint256 _poundage) public onlyOwner {
        _hangPoundage = _poundage;
    }

    function setExchangePoundage(uint256 _poundage) public onlyOwner {
        _exchangePoundage = _poundage;
    }

    function hang(address outputAddress, address receiveAddress, uint256 outputAmount, uint256 receiveAmount) public isRunning nonReentrant returns (bool) {
        
        if(outputAmount <= 0 || receiveAmount <= 0) {
            _status = _NOT_ENTERED;
            revert("TokenTrade: Invalid amount");
        }

        uint256 pledgeBalance = pledgeToken.balanceOf(msg.sender);
        if(pledgeBalance < _pledgeAmount) {
            _status = _NOT_ENTERED;
            revert("TokenTrade: Insufficient collateral balance");
        }

        uint256 outputBalance = ERC20(outputAddress).balanceOf(msg.sender);
        uint256 poundage = outputAmount.mul(_hangPoundage).div(1000);
        if(outputBalance < outputAmount.add(poundage)) {
            _status = _NOT_ENTERED;
            revert("TokenTrade: Insufficient balance");
        }

        pledgeToken.transferFrom(msg.sender, address(this), _pledgeAmount);
        ERC20(outputAddress).transferFrom(msg.sender, address(this), outputAmount.add(poundage));

        orderId.increment();
        uint256 tempId = orderId.current();

        order = Order(tempId, _pledgeAmount, outputAddress, receiveAddress, outputAmount, receiveAmount, msg.sender, address(0), 0, poundage, 0);
        
        orderMapping[tempId] = order;
        orderRecord[block.number][msg.sender] = order;

        return true;
    }

    function exchange(uint256 _orderId) public isRunning nonReentrant returns (bool) {
        
        if(orderMapping[_orderId].id == 0) {
            _status = _NOT_ENTERED;
            revert("TokenTrade: Invalid order");
        }

        if(orderMapping[_orderId].sellAdress == msg.sender) {
            _status = _NOT_ENTERED;
            revert("TokenTrade: Invalid operation");
        }

        if(orderMapping[_orderId].status != 0) {
            _status = _NOT_ENTERED;
            revert("TokenTrade: Invalid state");
        }

        address _receiveAddress = orderMapping[_orderId].receiveAddress;
        uint256 receiveBalance = ERC20(_receiveAddress).balanceOf(msg.sender);
        uint256 _receiveAmount = orderMapping[_orderId].receiveAmount;

        uint256 poundage = _receiveAmount.mul(_exchangePoundage).div(1000);
        if(receiveBalance < _receiveAmount.add(poundage)) {
            _status = _NOT_ENTERED;
            revert("TokenTrade: Insufficient balance");
        }

        ERC20(_receiveAddress).transferFrom(msg.sender, address(this), _receiveAmount.add(poundage));
        ERC20(orderMapping[_orderId].outputAddress).transfer(msg.sender, orderMapping[_orderId].outputAmount);
        ERC20(_receiveAddress).transfer(orderMapping[_orderId].sellAdress, _receiveAmount);

        ERC20(orderMapping[_orderId].outputAddress).transfer(poundageAddress, orderMapping[_orderId].hangPoundage);
        ERC20(_receiveAddress).transfer(poundageAddress, poundage);
        
        pledgeToken.transfer(orderMapping[_orderId].sellAdress, orderMapping[_orderId].pledgeAmount);

        orderMapping[_orderId].buyAddress = msg.sender;
        orderMapping[_orderId].exchangePoundage = poundage;
        orderMapping[_orderId].status = 1;

        return true;
    }

    function cancel(uint256 _orderId) public isRunning nonReentrant returns (bool) {
        
        if(orderMapping[_orderId].id == 0) {
            _status = _NOT_ENTERED;
            revert("TokenTrade: Invalid order");
        }

        if(orderMapping[_orderId].sellAdress != msg.sender) {
            _status = _NOT_ENTERED;
            revert("TokenTrade: Invalid operation");
        }

        if(orderMapping[_orderId].status != 0) {
            _status = _NOT_ENTERED;
            revert("TokenTrade: Invalid state");
        }

        orderMapping[_orderId].status = 2;

        return true;
    }

    function cancelOrder(uint256 _orderId) public onlyApprove returns (bool) {
        
        if(orderMapping[_orderId].id == 0) {
            _status = _NOT_ENTERED;
            revert("TokenTrade: Invalid order");
        }

        if(orderMapping[_orderId].status != 0) {
            _status = _NOT_ENTERED;
            revert("TokenTrade: Invalid state");
        }

        orderMapping[_orderId].status = 2;

        return true;
    }

    function getOrderRecord(uint256 _number, address _address) public view returns (uint256) {
        return orderRecord[_number][_address].id;
    }

    function getOrderInfo(uint256 _orderId) public view returns (Order memory _order) {
        return orderMapping[_orderId];
    }

}