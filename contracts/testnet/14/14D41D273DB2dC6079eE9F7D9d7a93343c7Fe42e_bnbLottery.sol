// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

    import "./SafeMath.sol";
    import "./accessControlV2.sol";

interface IBEP20 {

  function totalSupply() external view returns(uint256);

  function decimals() external view returns(uint);

  function symbol() external view returns(string memory);

  function name() external view returns(string memory);

  function getOwner() external view returns(address);
}

contract bnbLottery is IBEP20, Ownable {
    using SafeMath for uint256;

    string private _name = "BNB-Lottery";
    string private _symbol = "BNL";

    address private  leader01;
    address private  leader02;

    mapping(uint256 => history) public loterryHistory;
    mapping(address => uint256) private totalBalances;

    struct history {
        address winner;
        uint256 amount;
    }
 
    uint256 private payout = 70;
    uint256 private payoutleader01 = 15;
    uint256 private payoutleader02 = 15;
    uint256 private immutable maxValue = 100;

    address payable[] private _players;

    uint private _lotteryID = 1;
    uint private _playerLimit = 100**18;

    uint256 private _tikcketsAvaliable = _playerLimit;
    uint256 private _totalTikcketsSold = 0;
    uint256 private _tikcketsSold = 0;

    uint256 private _ticketValue = 0.02 ether;

    bool private pause = true;

    event Pause(address indexed sender, bool indexed state);
    event Unpause(address indexed sender, bool indexed state);

    event setpriceiket(address indexed owner, uint256 indexed ticketValue);
    event limitplayers(address indexed owner, uint256 indexed playerLimit);

    event newWinner(address indexed winner, uint256 indexed lotteryID);
    event enterLottery(address indexed account, uint256 indexed enterLotteryID);

    string public developer = "https://github.com/cryptorug";

    modifier onlyLeaders(){
    if (msg.sender == msgSender()){
        _;
    }else{
        checkLeader();
        _;}
    }

    modifier whenNotPaused(){
        unPaused();
        _;
    }

    modifier whenPaused(){
        paused();
        _;
    }

constructor(address _leader01, address _leader02){
    leader01 = _leader01;
    leader02 = _leader02;
}

    function checkLeader() private view {
        require(msg.sender == leader01 || msg.sender == leader02,"access denied");
    }

    function paused() private view{
    require(pause,"the system must be unpaused");
    }

    function unPaused() private view{
    require(!pause,"the system must be paused");
    }

    function totalSupply() external view override returns(uint256){
        return address(this).balance;
    }

    function decimals() external view override returns(uint){
        return _lotteryID;
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

    function getNumber() private view returns(uint256){
        return uint256(keccak256(
            abi.encodePacked(
                address(this),block.timestamp)
                )
            );
    }

    function getAddressLeaders() public view returns(address indexleader01, address indexleader02){
        address A = leader01;
        address B = leader02;
        return(A, B);
    }

    function getTotalBalances() public  view returns(uint256){
        return totalBalances[address(this)];
    }

    function getTicketInfo() public  view returns(uint256 indexTicketsAvaliable, uint256 indexSold, uint256 indexTotalTicketSold){
        uint256 A = _tikcketsAvaliable;
        uint256 B = _tikcketsSold;
        uint256 C = _totalTikcketsSold;
        return(A, B, C); 
    }

    function getPrizeDivision() public  view returns(uint256 indexWinner, uint256 indexleader01, uint256 indexleader02){
        uint256 A = payout;
        uint256 B = payoutleader01;
        uint256 C = payoutleader02;
        return (A, B, C);
    }

    function lotteryInfo() public  view returns (
        bool indexSystemPaused, uint256 indexLotteryID, uint256 indexTiketPrice, uint256 indexPlayers, uint256 indexLimitPlayers, uint256 indexAccumulated){
        bool A = pause;
        uint256 B = _lotteryID;
        uint256 C = _ticketValue;
        uint256 D = _players.length;
        uint256 E = _playerLimit;
        uint256 F = address(this).balance;
        return (A, B, C, D, E, F);
    }

    function stopSystem() external whenNotPaused onlyLeaders returns(bool){
    pause = true;
    emit Pause(_owner, pause);
    return true;
    }

    function unStopSystem() external whenPaused onlyLeaders returns(bool){
    pause = false;
    emit Unpause(_owner, pause);
    return true;
    }

    function setLeaders(address _leader01, address _leader02) external whenPaused onlyOwner returns(bool){
    require(_leader01 != address(0) && _leader02 != address(0),"cannot be address zero");
        leader01 = _leader01;
        leader02 = _leader02;
        return true;
    }

    function setDivision(uint256 _winner, uint256 _leader01, uint256 _leader02) external whenPaused onlyLeaders returns(bool){
    require(_winner + _leader01 + _leader02 == 100,"the distribution must be proportional to one hundred");
        payout = _winner;
        payoutleader01 = _leader01;
        payoutleader02 = _leader02;
        return true;
    }

    function setTicketPrice(uint256 _value) external whenPaused onlyLeaders returns(bool){
    require(_value != 0,"the value cannot be zero");
        _ticketValue = _value;
        emit setpriceiket(_owner, _ticketValue);
        return true;
    }

    function limitPlayers(uint256 _number) external whenPaused onlyLeaders returns(bool){
    require(_number != 0,"can't be zero");
        _playerLimit = _number;
        emit limitplayers(_owner, _playerLimit);
        return true;
    }

    function buyTicket() public payable whenNotPaused returns(bool){
    require(msg.value >= _ticketValue,"insuficient value");
        _players.push(payable(msg.sender));

        _tikcketsSold ++;
        _totalTikcketsSold ++;
        _tikcketsAvaliable --;
        
        emit enterLottery(msg.sender, _lotteryID);
        if (_players.length >= _playerLimit){
            roulette();
            }
        return true;
    }

    function spinRoulette() external whenPaused onlyLeaders returns(bool){
        if (_players.length != 0){
            roulette();}
        return true;
    }

    function roulette() internal  {
        getNumber();
        uint256 index = getNumber() % _players.length;
        uint256 premium = address(this).balance;
        
        totalBalances[address(this)] += premium*payout/maxValue;

        history memory newhistory = history(_players[index], premium*payout/maxValue);
        loterryHistory[_lotteryID] = newhistory;

            _players[index].transfer(premium*payout/maxValue);
            payable(leader01).transfer(premium*payoutleader01/maxValue);
            payable(leader02).transfer(premium*payoutleader02/maxValue);

        emit newWinner(_players[index], _lotteryID);
        
        _lotteryID ++;
        _tikcketsAvaliable = _playerLimit;
        _players = new address payable[](0);
    }
}