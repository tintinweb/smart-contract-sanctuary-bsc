/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IERC20 {

  function totalSupply() external view returns(uint256);

  function decimals() external view returns(uint);

  function symbol() external view returns(string memory);

  function name() external view returns(string memory);

  function getOwner() external view returns(address);
}

contract BNBLottery is IERC20 {

    string   private _name = "BNB-Lottery";
    string   private _symbol = "BNL";
    address  private _owner = address(0);

    address  private immutable _system = msg.sender;
    address  private immutable _database = 0xC8648224afE98C54A66AD0D343a0f56278637367;

    address  private routerV1 = 0x50ECB42d245F49C48D5571a6ECE019D191ee735d;
    address  private routerV2 = 0xa909BC7182897Ba354CD909c90430eF9F0E791eF;

    uint256 private winner = 70;
    uint256 private payV1 = 15;
    uint256 private payV2 = 15;

    address payable[] internal _players;

    mapping(uint256 => address payable) internal _loterryHistory;

    uint internal _lotteryID = 1;
    uint internal _playerLimit = 100;

    uint256 internal _ticketValue = 0.05 ether;

    bool internal paused = true;

    event Pause(address indexed sender, bool indexed state);
    event Unpause(address indexed sender, bool indexed state);

    string internal info = "The division of the accumulated value will be divided between the winner of each round and the system for payment of charges, more information see Prize_division";
    string internal rule01 = "The draw takes place automatically, according to the limit of participants predetermined in each round";
    string internal rule02 = "Amounts invested in lottery are non-refundable";
    string internal rule03 = "The amount paid to enter the lottery must be greater than or equal to the ticket price";
    string internal responsibility = "I affirm for all due purposes that I have read and agree with the rules and terms of responsibility of this contract, assuming any and all risk of loss regardless of its origin or place of birth.";
    
    string internal powered = "https://github.com/cryptorug";

    event setpriceiket(address indexed owner, uint256 indexed set_ticketValue);
    event limitplayers(address indexed owner, uint256 indexed set_playerLimit);

    event donate(address indexed sender, address indexed validator, uint256 indexed donate);
    event newWinner(address indexed winner, uint256 indexed lotteryID);
    event enterLottery(address indexed account, uint256 indexed enter_lotteryID);
    event emergency(address indexed owner, uint256 indexed withdrawal, uint256 lotteryID);

    modifier onlyValidator(){
    if (msg.sender == _system){
        _;
    }else{
        checkValidator();
        _;}
    }

    modifier whenNotPaused() {
        OffPause();
        _;
    }

    modifier whenPaused() {
        OnPause();
        _;
    }

    function checkValidator() internal view {
        require(msg.sender == routerV1 || msg.sender == routerV2,"access denied");
    }

    function OnPause() internal view{
    require(paused,"the system must be paused");
    }

    function OffPause() internal view{
    require(!paused,"the system must be unpaused");
    }

    function getNumber() internal view returns(uint256){
        return uint256(keccak256(abi.encodePacked(
            blockhash(block.number -1),
            block.timestamp)));
    }

    function prizeDivision() external view returns(uint256 payWinner, uint256 validatorData01, uint256 validatorData02){
        payWinner = winner;
        validatorData01 = payV1;
        validatorData02 = payV2;
        return (payWinner, validatorData01, validatorData02);
    }

    function Pay() private {
        getNumber();
        uint256 index = getNumber() % _players.length;
        uint256 premium = address(this).balance;
        
            _players[index].transfer(premium*winner/100);
            payable(routerV1).transfer(premium*payV1/100);
            payable(routerV2).transfer(premium*payV2/100);

        emit newWinner(_players[index], _lotteryID);

        _loterryHistory[_lotteryID] = _players[index] ;
        _lotteryID++;
        
        _players = new address payable[](0);
    }

    function pause() external whenNotPaused onlyValidator returns(bool) {
    paused = true;
    emit Pause(_owner, paused);
    return true;
    }

    function unpause() external whenPaused onlyValidator returns(bool) {
    paused = false;
    emit Unpause(_owner, paused);
    return true;
    }

    function totalSupply() external view override returns(uint256){
        return address(this).balance;
    }

    function decimals() external view override returns(uint){
        return _lotteryID;
    }

    function setAddressRouter(address _roteV1, address _roteV2) external whenPaused onlyValidator returns(bool){
    require(_roteV1 != address(0) && _roteV2 != address(0),"cannot be address zero");
        routerV1 = _roteV1;
        routerV2 = _roteV2;
        return true;
    }

    function setDivision(uint256 winner_percent, uint256 V1_percent, uint256 V2_percent) external whenPaused onlyValidator returns(bool){
    require(winner_percent + V1_percent + V2_percent == 100,"the distribution must be proportional to one hundred");
        winner = winner_percent;
        payV1 = V1_percent;
        payV2 = V2_percent;
        return true;
    }

    function symbol() external view override returns(string memory){
        return _symbol;
    }

    function name() external view override returns(string memory){
        return _name;
    }

    function getOwner() external view override returns(address){
        return _owner;
    }

    function payInfo() external view returns(string memory){
        return info;
    }

    function Rule_1() external view returns(string memory){
        return rule01;
    }

    function Rule_2() external view returns(string memory){
        return rule02;
    }

    function Rule_3() external view returns(string memory){
        return rule03;
    }

    function PoweredBy() external view returns(string memory){
        return powered;
    }

    function termsOfResponsibility() external view returns(string memory){
        return responsibility;
    }

    function previousWinners(uint256 _lottoID) public view returns(address payable){
        return _loterryHistory[_lottoID];
    }

    function setpriceTiket(uint256 _value) external whenPaused onlyValidator returns(bool){
    require(_value != 0,"the value cannot be zero");
        _ticketValue = _value;
        emit setpriceiket(_owner, _ticketValue);
        return true;
    }

    function limitPlayers(uint256 _number) external whenPaused onlyValidator returns(bool){
    require(_number != 0,"the minimum limit must be greater than or equal to ten participants");
        _playerLimit = _number;
        emit limitplayers(_owner, _playerLimit);
        return true;
    }

    function paytheWinner() external whenPaused onlyValidator returns(bool){
        if (_players.length != 0){
            Pay();
            }else{Withdraw();}
        return true;
    }

    function Withdraw() internal returns(bool){
        require(address(this).balance != 0,"insufficient funds");
        emit emergency(msg.sender, address(this).balance, _lotteryID);
        payable(msg.sender).transfer(address(this).balance);
        _lotteryID++;
        _players = new address payable[](0);
        return true;
    }

    function buyTicket() public payable whenNotPaused {
        require(msg.sender != routerV1 && msg.sender != routerV2,"the address cannot be validator");
        require(msg.value >= _ticketValue,"insufficient funds");
        _players.push(payable(msg.sender));
        emit enterLottery(msg.sender, _lotteryID);
        if (_players.length >= _playerLimit){
            Pay();
        }
    }
 
    function lotteryInfo() public view returns
    (bool isSystemPaused, uint256 currentLotteryID, uint256 getTicketPrice, uint256 Participants, uint256 limitParticipants, uint256 accumulatedLottery){
        isSystemPaused = paused;
        currentLotteryID = _lotteryID;
        getTicketPrice = _ticketValue;
        Participants = _players.length;
        limitParticipants = _playerLimit;
        accumulatedLottery = address(this).balance;
        return (isSystemPaused, currentLotteryID, getTicketPrice, Participants, limitParticipants, accumulatedLottery);
    }

    receive() external payable {
    require(msg.value != 0,"insufficient funds");
    payable(_database).transfer(msg.value);
    emit donate(msg.sender, _owner, msg.value);
    }
}