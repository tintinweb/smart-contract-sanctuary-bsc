/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
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

    /*
     * @dev wei convert
     * @param price
     * @param decimals
     */
    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

}

contract MobiusIdo is Modifier, Util {

    using SafeMath for uint;
    using Counters for Counters.Counter;

    // IDO variable
    bool idoOpenStatus = false;
    Counters.Counter private salesIssue;
    mapping(uint => uint) private salesNumberForIssue;

    mapping(address => address) private invitationMapping; // Invitation relation
    mapping(address => uint) private buyIdoAmount; // Private placement purchase amount
    mapping(address => uint) private buyIdoNumber; // Private placement purchase number
    mapping(address => uint) private receiveIdoNumber; // Private placement receive number

    address private idoReceiveAddress; // Private placement receive address
    address private defaultInviteAddress;

    uint private tokenTotalSupply; // 5000000000000000000000000
    uint private tokenSoldNum; // Number of tokens sold
    uint private tokenPlannedSalesIssue; // Frequency of planned token sales
    uint private idoAmountLimit; // Amount per purchase of IDO  100000000000000000000
    uint private idoLimit; //
    uint private idoTotalLimit;
    uint private swapOnlineTime; // swap online time
    uint private idoReceivePeriod; // Private placement receive period

    ERC20 private buyToken;
    ERC20 private sellToken;

    constructor() {
        salesIssue.increment();
        salesNumberForIssue[salesIssue.current()] = 0;
        tokenTotalSupply = 5000000000000000000000000;
        idoAmountLimit = 100000000000000000000;
        idoLimit = 5;
        idoTotalLimit = 10;
        tokenPlannedSalesIssue = 10;
        swapOnlineTime = 0;
        idoReceivePeriod = 31;
    }

    function setIdoInfo(uint _totalSupply) public onlyOwner {
        tokenTotalSupply = _totalSupply;
    }

    /*
     * @dev Set up | Creator call | Set the token contract address
     * @param _buyToken  Configure the purchase token contract address
     * @param _sellToken Configure the address of the sell token contract
     */
    function setTokenContract(address _buyToken, address _sellToken) public onlyOwner {
        buyToken = ERC20(_buyToken);
        sellToken = ERC20(_sellToken);
    }

    /*
     * @dev Set up | Creator call | Set IDO open status
     * @param _address  Default invite address
     */
    function setIdoOpenStatus(bool _status) public onlyOwner {
        idoOpenStatus = _status;
    }

    /*
     * @dev Set up | Creator call | Set default invite address
     * @param _address  Default invite address
     */
    function setDefaultInviteAddress(address _address) public onlyOwner {
        defaultInviteAddress = _address;
    }

    /*
     * @dev Set up | Creator call | Set default invite address
     * @param _address  IDO receive address
     */
    function setIdoReceiveAddress(address _address) public onlyOwner {
        idoReceiveAddress = _address;
    }

    /*
     * @dev Set up | Creator call | Set swap online time
     */
    function setSwapOnlineTime() public onlyOwner {
        swapOnlineTime = block.timestamp;
    }

    /*
     * @dev Update | All | buyCoin
     * @param amountToWei purchase token amount
     */
    function buyCoin(uint256 amountToWei, address _address) public isRunning nonReentrant returns (bool) {
        if(!idoOpenStatus) {
            _status = _NOT_ENTERED;
            revert("Mobius: IDO not started");
        }
        if(msg.sender == _address) {
            _status = _NOT_ENTERED;
            revert("Mobius: Inviter is invalid");
        }
        if(amountToWei == 0) {
            _status = _NOT_ENTERED;
            revert("Mobius: The purchase amount must be greater than 0");
        }
        if(defaultInviteAddress != _address && buyIdoNumber[_address] == 0) {
            _status = _NOT_ENTERED;
            revert("Mobius: Inviter is invalid");
        }
        if(amountToWei.mod(idoAmountLimit) != 0) {
            _status = _NOT_ENTERED;
            revert("Mobius: The purchase amount is invalid");
        }
        uint buyCopies = amountToWei.div(idoAmountLimit);
        if(buyCopies > idoLimit) {
            _status = _NOT_ENTERED;
            revert("Mobius: The purchase amount exceeds limit");
        }
        if(tokenSoldNum >= tokenTotalSupply) {
            _status = _NOT_ENTERED;
            revert("Mobius: Private placement is insufficient, and the purchase amount exceeds the remaining amount");
        }

        uint buyNum = amountToWei.mul(10);
        uint perSalesNum = tokenTotalSupply.div(tokenPlannedSalesIssue); // Number of sales per round
        uint currentPurchaseableNum = perSalesNum.sub(salesNumberForIssue[salesIssue.current()]);
        if(buyNum > currentPurchaseableNum) {
            _status = _NOT_ENTERED;
            revert("Mobius: Private placement is insufficient, and the purchase amount exceeds the remaining amount");
        }
        if(buyIdoAmount[msg.sender] != 0) {
            uint boughtCopies = buyIdoAmount[msg.sender].div(idoAmountLimit);
            uint totalCopies = buyCopies.add(boughtCopies);
            if(totalCopies > idoTotalLimit) {
                _status = _NOT_ENTERED;
                revert("Mobius: The purchase amount exceeds limit");
            }
        }

        // bind inviter
        if(invitationMapping[msg.sender] == address(0)) {
            if(_address != address(0)) {
                invitationMapping[msg.sender] = _address;
            } else {
                invitationMapping[msg.sender] = defaultInviteAddress;
            }
        }

        uint currentSalesNum = salesNumberForIssue[salesIssue.current()].add(buyNum);
        if(currentSalesNum >= perSalesNum) {
            salesIssue.increment();
            salesNumberForIssue[salesIssue.current()] = 0;
            idoOpenStatus = false;
        }

        salesNumberForIssue[salesIssue.current()] = currentSalesNum;
        tokenSoldNum = tokenSoldNum.add(buyNum);
        buyIdoAmount[msg.sender] = buyIdoAmount[msg.sender].add(amountToWei);
        buyIdoNumber[msg.sender] = buyIdoNumber[msg.sender].add(buyNum);

        buyToken.transferFrom(msg.sender, address(this), amountToWei);

        // compute inviter reward
        uint256 inviterReward = amountToWei.mul(10).div(100);
        buyToken.transfer(invitationMapping[msg.sender], inviterReward);
        buyToken.transfer(idoReceiveAddress, amountToWei.sub(inviterReward));

        return true;
    }

    /*
     * @dev Query | All | Query the remaining purchasable amount of IDO in the current period
     */
    function getIdoOpenStatus() public view returns(bool status) {
        return idoOpenStatus;
    }

    /*
     * @dev Query | All | Query the remaining purchasable amount of IDO in the current period
     */
    function getCurrentPurchasebleNum() public view returns(uint numberToWei) {
        uint perSalesNum = tokenTotalSupply.div(tokenPlannedSalesIssue); // Number of sales per round
        return perSalesNum.sub(salesNumberForIssue[salesIssue.current()]);
    }

    /*
     * @dev Query | All | Query IDO purchase quantity by address
     */
    function getNumberByAddress(address _address) public view returns(uint numberToWei) {
        return buyIdoNumber[_address];
    }

    /*
     * @dev Query | All | Query the available quantity of IDO
     */
    function getNumberForIdo() public view returns(uint number) {
        if(swapOnlineTime == 0 || receiveIdoNumber[msg.sender] > 0) {
            return 0;
        }
        return computeReceiveIdoNumber();
    }

    /*
     * @dev Update | All | Receive token for IDO
     */
    function receiveForIdo() public isRunning nonReentrant returns (bool) {
        if(swapOnlineTime > 0 && receiveIdoNumber[msg.sender] == 0) {
            uint receiveNumber = computeReceiveIdoNumber();
            receiveIdoNumber[msg.sender] = receiveNumber;
            sellToken.transfer(msg.sender, receiveNumber);
            uint notReceiveNumber = buyIdoNumber[msg.sender].sub(receiveNumber);
            if(notReceiveNumber > 0) {
                // transfer to black hole
                sellToken.transfer(0x000000000000000000000000000000000000dEaD, notReceiveNumber);
            }
        }
        return true;
    }

    function computeReceiveIdoNumber() private view returns (uint number) {
        uint secondsOfDay = 24 * 60 * 60;
        uint onlineDay = block.timestamp.sub(swapOnlineTime).div(secondsOfDay);
        if(onlineDay < idoReceivePeriod) {
            return buyIdoNumber[msg.sender].mul(20).div(100);
        }
        uint availableReceivePeriod = onlineDay.div(idoReceivePeriod).add(1);
        if(availableReceivePeriod >= 5) {
            return buyIdoNumber[msg.sender];
        }
        return buyIdoNumber[msg.sender].mul(20).div(100).mul(availableReceivePeriod);
    }

}