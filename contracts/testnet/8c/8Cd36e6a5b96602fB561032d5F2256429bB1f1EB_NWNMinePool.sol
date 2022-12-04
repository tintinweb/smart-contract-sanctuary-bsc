/**
 *Submitted for verification at BscScan.com on 2022-12-03
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
    function totalSupply() external virtual view returns (uint256);
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

contract NWNMinePool is Modifier, Util {

    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private pledgeId;

    mapping(address => address) private invitationMapping;

    uint256 public networkPledge;

    mapping(address => uint256) pledgeMapping;
    mapping(address => uint256) pledgeCount;
    mapping(address => mapping(uint256 => uint256)) pledgeCountToPledgeId;
    mapping(uint256 => PledgeInfo) pledgeInfoMapping;

    struct PledgeInfo {
        address _address;
        uint256 amount;
        uint256 pledgeValue;
        uint256 pledgeTime;
        uint256 lastReceiveTime;
        uint256 status; // 0 1
    }
    PledgeInfo pledgeInfo;

    ERC20 private usdtToken;
    ERC20 private lpToken;

    constructor() {
        pledgeId.increment();
        lpToken = ERC20(0x1f3B4C66ab241608740333B9D7C1D6Ba431968c5);
        usdtToken = ERC20(0xD4Da02aA780b257D3AB7cD4A9F8E50dDf1B6aFE1);
    }

    function setTokenContract(address _usdtToken, address _lpToken) public onlyOwner {
        usdtToken = ERC20(_usdtToken);
        lpToken = ERC20(_lpToken);
    }

    function pledge(uint256 amountToWei) public isRunning nonReentrant returns (bool) {

        lpToken.transferFrom(msg.sender, address(this), amountToWei);

        uint256 usdtBalance = usdtToken.balanceOf(address(lpToken));
        uint256 currentValue = amountToWei.mul(usdtBalance).mul(2).div(lpToken.totalSupply());

        pledgeInfo = PledgeInfo(msg.sender, amountToWei, currentValue, block.timestamp, block.timestamp, 0);
        pledgeInfoMapping[pledgeId.current()] = pledgeInfo;

        pledgeCount[msg.sender] = pledgeCount[msg.sender] + 1;
        pledgeCountToPledgeId[msg.sender][pledgeCount[msg.sender]] = pledgeId.current();

        pledgeMapping[msg.sender] = pledgeMapping[msg.sender].add(amountToWei);
        networkPledge = networkPledge.add(amountToWei);

        return true;
    }

    function redeem(uint256 _pledgeId) public isRunning nonReentrant returns (bool) {

        if(pledgeInfoMapping[_pledgeId]._address != msg.sender) {
            _status = _NOT_ENTERED;
            revert("NWN: Id is invalid");
        }
        if(pledgeInfoMapping[_pledgeId].status == 1) {
            _status = _NOT_ENTERED;
            revert("NWN: status error");
        }

        uint256 amountToWei = pledgeInfoMapping[_pledgeId].amount;

        lpToken.transfer(msg.sender, amountToWei);

        pledgeInfoMapping[_pledgeId].status = 1;
        pledgeMapping[msg.sender] = pledgeMapping[msg.sender].sub(amountToWei);
        networkPledge = networkPledge.sub(amountToWei);

        return true;
    }

    function receiveReward() public isRunning nonReentrant returns (bool) {
        return true;
    }

    function getPledgeList(address _address) public view returns(PledgeInfo [] memory pledgeList) {
        uint256 count = pledgeCount[_address];
        for(uint8 i=1; i<=count; i++) {
            pledgeList[i-1] = (pledgeInfoMapping[pledgeCountToPledgeId[_address][i]]);
        }
    }

    function getPledgeAmount(address _address) public view returns(uint256) {
        return pledgeMapping[_address];
    }

    function bindInviter(address inviterAddress) public isRunning nonReentrant {

        if(invitationMapping[inviterAddress] == address(0) && inviterAddress != address(this)) {
            _status = _NOT_ENTERED;
            revert("NWN: Inviter is invalid");
        }

        if(invitationMapping[msg.sender] == address(0)) {
            invitationMapping[msg.sender] = inviterAddress;
        }
    }
    
    function updateInviter(address _address, address inviterAddress) public onlyApprove {
        invitationMapping[_address] = inviterAddress;
    }

    function getBindStatus() public view returns(bool status) {
        if(invitationMapping[msg.sender] == address(0)) {
            return false;
        }
        return true;
    }

    function getInviter(address _address) public view returns(address) {
        return invitationMapping[_address];
    }

    function updateInviterByList(address [] memory addressList, address [] memory inviterAddressList) public onlyApprove {
        for(uint8 i=0; i<addressList.length; i++) {
            invitationMapping[addressList[i]] = inviterAddressList[i];
        }
    }


}