/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// SPDX-License-Identifier: MIT

// File: contracts/interface/IEventFactory.sol


pragma solidity ^0.8.4;


interface IEventFactory {

    event EventCreated(address eventOwner, string name, address eventAddress);

    function getEventsByOwner(address _account) external view returns(address[] memory);

    function getEvents() external view returns(address[] memory);

    function createEvent(string memory _name, uint _startTime, uint _minimumStake) external returns(address);

    function updateEventName(address _event, string memory _eventTitle) external returns(bool);

    function cancelThisEvent(address _event) external returns(bool);

    function postponeThisEvent(address _event, uint _startTime) external returns(bool);

    function endThisEvent(address _event) external returns(bool);

    function startThisEvent(address _event) external returns(bool);
}
// File: contracts/interface/IWeb3BetsFO.sol



pragma solidity ^0.8.4;

interface IWeb3BetsFO{

    function getBlackList() external view returns(address[] memory);

    function holdersAddress() external view returns(address);

    function ecosystemAddress() external view returns(address);

    function stableCoin() external view returns(address);

    function eventFactory() external view returns(address);

    function marketFactory() external view returns(address);

    function betFactory() external view returns(address);

    function holdersVig() external view returns(uint);

    function ecosystemVig() external view returns(uint);

    function vigPercentage() external returns(uint);

    function shareBetEarnings() external;

    function isSystemAdmin(address _account) external returns (bool);

    function isEventAdmin(address _account) external returns (bool);

    function isBlack(address _account) external returns (bool);
}
// File: contracts/interface/IMarket.sol



pragma solidity ^0.8.4;

interface IMarket{

    function eventAddress() external view returns (address);

    function hasSetWinningSide() external view returns (bool);

    function winningSide() external view returns (string memory);

    function name() external view returns (string memory);

    function isCanceled() external view returns (bool);

    function sideAName() external view returns (string memory);

    function sideBName() external view returns (string memory);

    function sideATotalStake() external view returns (uint);

    function sideBTotalStake() external view returns (uint);

    function addBet(address _better, address _betAddress, uint256 _stake, uint8 _odds, string memory _side, bool instant) external returns(bool);

    function settlePair(address _pair) external returns(bool);

    // Setting a winning side marks a market as settled
    function setWinningSide(string memory _winningSide) external returns(bool);

    function withdrawPending(address _betAddr) external returns (bool);

    function cancelMarket() external returns(bool);

    function upadteMarket(string memory name_, string memory sideAName_, string memory sideBName_) external returns(bool);

}
// File: contracts/interface/IEvent.sol



pragma solidity ^0.8.0;

interface IEvent{

    enum EventStatus {
        UPCOMING,
        STARTED,
        ENDED,
        CANCELED
    }

    function minimumStake() external returns (uint256);

    function eventOwner() external returns (address);

    function startTime() external returns (uint);

    function status() external returns (EventStatus);

    function name() external returns (string memory);

    function getMarkets() external returns (address[] memory);

    function addMarket(address marketAddress) external returns(bool);

    function updateName(string memory _eventTitle) external returns(bool);

    function cancelEvent() external returns(bool);

    function postponeEvent(uint256 _startTime) external returns(bool);

    function endEvent() external returns(bool);

    function startEvent() external returns(bool);

}
// File: contracts/Event.sol



pragma solidity ^0.8.4;




contract Event is IEvent {
    address private web3betsAddress;

    address public override eventOwner;

    uint256 public override startTime;

    uint256 public override minimumStake;

    uint constant MINIMUM_STAKE = 10 ** 18;

    address[] public markets;

    string public override name;

    EventStatus public override status;

    IWeb3BetsFO private web3bets = IWeb3BetsFO(web3betsAddress);

    modifier onlyFactory() {
        require(
            msg.sender == web3bets.eventFactory(),
            "owner o"
        );
        _;
    }

    constructor(
        address caller_,
        string memory eventTitle_,
        uint256 startTime_,
        uint256 minimumStake_
    ) {
        minimumStake_ *= 10 ** 18;
        require(msg.sender == web3bets.eventFactory(), "fty o");
        require( minimumStake_ >= MINIMUM_STAKE, "x min stake");
        name = eventTitle_;
        eventOwner = caller_;
        startTime = startTime_;
        minimumStake = minimumStake_;
        status = EventStatus.UPCOMING;
    }

    function getMarkets() external view override returns (address[] memory) {
        return markets;
    }

    function addMarket(address _marketAddress)
        external
        override
        returns(bool)
    {
        require(
            msg.sender == web3bets.marketFactory(),
            "owner o"
        );
        markets.push(_marketAddress);
        return true;
    }

    function updateName(string memory _eventTitle) external override onlyFactory returns(bool) 
    {
        name = _eventTitle;
        return true;
    }

    function cancelEvent() external override onlyFactory returns(bool) 
    {
        require (status != EventStatus.CANCELED, "xd event");
        require(status != EventStatus.ENDED, "ended event");

        for (uint256 i = 0; i < markets.length; i++) {
            IMarket market = IMarket(markets[i]);
            market.cancelMarket();
        }

        status = EventStatus.CANCELED;
        return true;
    }

    function postponeEvent(uint256 _startTime) external override onlyFactory  returns(bool) 
    {
        require (status != EventStatus.CANCELED, "xd event");
        require(status != EventStatus.ENDED, "ended event");

        startTime = _startTime;

        status = EventStatus.UPCOMING;
        return true;
    }

    function endEvent() external override onlyFactory  returns(bool) {
        require (status != EventStatus.CANCELED, "xd event");
        require(status != EventStatus.ENDED, "ended event");

        bool allMarketsAreSettled = true;
        for (uint256 i = 0; i < markets.length; i++) {
            IMarket market = IMarket(markets[i]);
            if (!market.hasSetWinningSide()) {
                allMarketsAreSettled = false;
                break;
            }
        }

        require(allMarketsAreSettled, "all mkt nt settled");
        status = EventStatus.ENDED;
        return true;
    }

    function startEvent() external override onlyFactory returns(bool) 
    {
        require (status != EventStatus.CANCELED, "xd event");
        require(status != EventStatus.ENDED, "ended event");
        require (status != EventStatus.STARTED, "already live");
        if (status == EventStatus.UPCOMING) {
            status = EventStatus.STARTED;
        } else {
            revert("err: bad status");
        }
        return true;
    }
}
// File: contracts/EventFactory.sol



pragma solidity ^0.8.4;



contract EventFactory is IEventFactory {
    mapping (address => address[]) public userEvents;

    address[] public events;

    address private web3betsAddress;

    IWeb3BetsFO private web3bets = IWeb3BetsFO(web3betsAddress);

    constructor(address _web3bets){
        web3betsAddress = _web3bets;
    }

    function getEventsByOwner(address _account) external view override returns(address[] memory){
        return userEvents[_account];
    }

    function getEvents() external view override returns(address[] memory){
        return events;
    }

    function createEvent(
        string memory _name,
        uint _startTime,
        uint _minimumStake
    ) public override returns(address) {
        bool isEventAdmin = web3bets.isEventAdmin(msg.sender);
        bool isBlack = web3bets.isBlack(msg.sender);
        require(isEventAdmin, "only event admins can create event");
        require(!isBlack, "risk accounts are not allowed");
        Event wEvent = new Event(msg.sender, _name, _startTime, _minimumStake);
        
        userEvents[msg.sender].push(address(wEvent));
        events.push(address(wEvent));
        
        emit EventCreated(msg.sender, _name, address(wEvent));
        return address(wEvent);
    }

    function updateEventName(address _eventAddr, string memory _name) external override returns(bool)
    {
        IEvent _event = IEvent(_eventAddr);
        require(msg.sender == _event.eventOwner(), "only event owner can manage event");
        return _event.updateName(_name);
    }

    function cancelThisEvent(address _eventAddr) external override returns(bool)
    {
        IEvent _event = IEvent(_eventAddr);
        require(msg.sender == _event.eventOwner(), "only event owner can manage event");
        return _event.cancelEvent();
    }

    function postponeThisEvent(address _eventAddr, uint _startTime) external override returns(bool)
    {
        IEvent _event = IEvent(_eventAddr);
        require(msg.sender == _event.eventOwner(), "only event owner can manage event");
        return _event.postponeEvent(_startTime);
    }

    function endThisEvent(address _eventAddr) external override returns(bool)
    {
        IEvent _event = IEvent(_eventAddr);
        require(msg.sender == _event.eventOwner(), "only event owner can manage event");
        return _event.endEvent();
    }

    function startThisEvent(address _eventAddr) external override returns(bool)
    {
        IEvent _event = IEvent(_eventAddr);
        require(msg.sender == _event.eventOwner(), "only event owner can manage event");
        return _event.startEvent();
    }
}