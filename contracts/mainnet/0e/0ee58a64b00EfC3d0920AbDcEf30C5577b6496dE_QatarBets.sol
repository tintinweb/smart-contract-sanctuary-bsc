// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;


abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;
        
        _status = _NOT_ENTERED;
    }
}

interface IERC20 {
    function transfer(address dst, uint wad) external;
    function balanceOf(address account) external view returns (uint);
}

contract QatarBets is ReentrancyGuard{

  uint256 public constant MAX_FEE = 2000; // 20%
  uint256 public constant MAX_PERCENT_SPONSOR = 1000; // 10%
  uint256 public minAmount; //Minimal amount you can bet, in wei
  bool public paused;
  uint256 public fee; // fee rate (e.g. 200 = 2%, 150 = 1.50
  uint8 public lastIdMatch; //Last id  for a match.%)
  uint256 public intervalGettingFees; //Time interval until you can get fees from pool
  uint256 public lastTimeGettingFees; //Last date anyone get fees from pool
  uint256 public feePool;
  mapping(address => Sponsor) public sponsors; 
  address[] private lstSponsors;
  mapping(uint8 => Match) public matches; //List of matches
  mapping(address => mapping(uint8 => BetData)) public betList; //List of bets 
  mapping(address => uint8[]) public userMatches;
  uint8 team1Win = 1; // possible results 
  uint8 team2Win = 2; // possible results 
  uint8 draw = 3; // possible results 

  struct Match {
    uint256 datetime;
    string team1;
    string team2;
    uint8 result;
    bool closed;
    uint256 totalAmount;
    uint256 team1Amount;
    uint256 team2Amount;
    uint256 drawAmount;
    uint256 rewardBaseTotalAmount;
    uint256 rewardAmount;
  }

  struct BetData {
      uint8 choice;
      uint256 amount;
      bool claimed;
      bool refunded;
  }

  struct Sponsor {
      uint256 percent;  // 200 -> 2%
      bool removed;
      uint256 id;
  }

  address public operator;
  address public adminAddress;

  event Bet(address indexed sender, uint8 indexed idMatch, uint256 amount, uint8 choice);
  event Claim(address indexed sender, uint256 indexed idMatch, uint256 amount);
  event Refund(address indexed sender, uint256 indexed idMatch, uint256 amount);
  event EndMatch(uint256 indexed idMatch, uint8 result);
  event NewFee(uint256 indexed idMatch, uint256 fee);
  event NewMinAmount(uint256 indexed newMinAmount);
  event NewInterval(uint256 indexed idMatch, uint256 interval);
  event NewOperator(address indexed newOperator);
  event NewSponsor(address indexed newSponsor);
  event RemoveSponsor(address indexed sponsor);
  event RewardsCalculated(
      uint256 indexed matchId,
      uint256 rewardBaseCalAmount,
      uint256 rewardAmount,
      uint256 feeAmount
  );
  event Pause(uint8 indexed idMatch);
  event Unpause(uint8 indexed idMatch);

  modifier onlyAdmin() {
    require(msg.sender == adminAddress, "Not admin");
    _;
  }

  modifier onlyAdminSponsors() {
    require(msg.sender == adminAddress || 
            (sponsors[msg.sender].percent > 0 && !sponsors[msg.sender].removed), "Not admin neither sponsors");
    _;
  }

  modifier onlyOperator() {
    require(
      msg.sender == operator,
      "Only operator can call this function."
    );
    _;
  }

  modifier whenRunning() {
    require(
      !paused,
      "Bets are paused."
    );
    _;
  }

  modifier whenPaused() {
    require(
      paused,
      "Bets are running."
    );
    _;
  }

  constructor(address _operator, address _admin) {
    operator = _operator;
    adminAddress = _admin;
    fee =  1000; //base 10000
    minAmount = 10_000_000_000_000_000; // 0.01
    createMatch("QAT", "ECU", 1668960000);
    createMatch("ENG", "IRI", 1669035600);
    createMatch("SEN", "NED", 1669046400);
    createMatch("USA", "WAL", 1669057200);
    createMatch("ARG", "KSA", 1669111200);
    createMatch("DEN", "TUN", 1669122000);
    createMatch("MEX", "POL", 1669132800);
    createMatch("FRA", "AUS", 1669143600);
    createMatch("MAR", "CRO", 1669197600);
    createMatch("GER", "JPN", 1669208400);
    createMatch("ESP", "CRC", 1669219200);
    createMatch("BEL", "CAN", 1669230000);
    createMatch("SUI", "CMR", 1669284000);
    createMatch("URU", "KOR", 1669294800);
    createMatch("POR", "GHA", 1669305600);
    createMatch("BRA", "SRB", 1669316400);
    createMatch("WAL", "IRI", 1669370400);
    createMatch("QAT", "SEN", 1669381200);
    createMatch("NED", "ECU", 1669392000);
    createMatch("ENG", "USA", 1669402800);
    createMatch("TUN", "AUS", 1669456800);
    createMatch("POL", "KSA", 1669467600);
    createMatch("FRA", "DEN", 1669478400);
    createMatch("ARG", "MEX", 1669489200);
    createMatch("JPN", "CRC", 1669543200);
    createMatch("BEL", "MAR", 1669554000);
    createMatch("CRO", "CAN", 1669564800);
    createMatch("ESP", "GER", 1669575600);
    createMatch("CMR", "SRB", 1669629600);
    createMatch("KOR", "GHA", 1669640400);
    createMatch("BRA", "SUI", 1669651200);
    createMatch("POR", "URU", 1669662000);
    createMatch("NED", "QAT", 1669734000);
    createMatch("ECU", "SEN", 1669734000);
    createMatch("WAL", "ENG", 1669748400);
    createMatch("IRI", "USA", 1669748400);
    createMatch("TUN", "FRA", 1669820400);
    createMatch("AUS", "DEN", 1669820400);
    createMatch("POL", "ARG", 1669834800);
    createMatch("KSA", "MEX", 1669834800);
    createMatch("CRO", "BEL", 1669906800);
    createMatch("CAN", "MAR", 1669906800);
    createMatch("JPN", "ESP", 1669921200);
    createMatch("CRC", "GER", 1669921200);
    createMatch("KOR", "POR", 1669993200);
    createMatch("GHA", "URU", 1669993200);
    createMatch("CMR", "BRA", 1670007600);
    createMatch("SRB", "SUI", 1670007600);
  }

  function setOperator(address _operator) external whenPaused onlyAdmin {
    require(_operator != address(0), "Cannot be zero address");
    operator = _operator;

    emit NewOperator(_operator);
  }

  function setMinAmount(uint _newAmount) external onlyAdmin {
    require(_newAmount > 0, "Cannot be zero");
    require(_newAmount != minAmount, "Has to be different");
    minAmount = _newAmount;

    emit NewMinAmount(minAmount);
  }

  function setFee(uint256 _fee) external whenPaused onlyAdmin {
    require(_fee <= MAX_FEE, "Fee too high");
    require(_fee != fee, "Fee has to be different to previous one");
    fee = _fee;

    emit NewFee(lastIdMatch, fee);
  }
  
  function setIntervalGettingFees(uint256 _intervalGettingFees) external whenPaused onlyAdmin {
    require(_intervalGettingFees != intervalGettingFees, "Interval has to be different to previous one");
    intervalGettingFees = _intervalGettingFees;

    emit NewInterval(lastIdMatch, intervalGettingFees);
  }
  
  function addSponsor(address _newSponsor, uint256 _percent) external onlyAdmin {
    require( sponsors[_newSponsor].percent == 0, "Sponsor exists");

    sponsors[_newSponsor].percent = _percent;
    sponsors[_newSponsor].id = lstSponsors.length;

    lstSponsors.push(_newSponsor);

    emit NewSponsor(_newSponsor);
  }
  
  function removeSponsor(address _sponsor) external onlyAdmin {
    require( sponsors[_sponsor].percent > 0, "Sponsor doesn't exist");

    sponsors[_sponsor].removed = true;

    address lastSponsor = lstSponsors[lstSponsors.length - 1];
    lstSponsors[sponsors[_sponsor].id] = lastSponsor;
    lstSponsors.pop();

    emit RemoveSponsor(_sponsor);
  }
  
  function pause() external whenRunning onlyAdmin {
    require(!paused, "Bets are paused");
    paused = true;

    emit Pause(lastIdMatch);
  }
  
  function unpause() external whenPaused onlyAdmin {
    require(paused, "Bets aren't paused");
    paused = false;

    emit Unpause(lastIdMatch);
  }

  function getSponsors() public view returns (address[] memory){
    return lstSponsors;
  }

  function getRemovedSponsor(address _address) public view returns (bool){
    return sponsors[_address].removed;
  }

  function getPossibleResults() public view returns (uint8[3] memory){
    return [draw, team1Win, team2Win];
  }

  function getMatchId(string memory _team1, string memory _team2, uint256 _datetime) public view returns (uint8){
    uint8 _matchId = 0;
    for(uint8 i = 0; i < lastIdMatch; i++){
      Match memory _match = matches[i];
      if(keccak256(abi.encodePacked(_match.team1)) == keccak256(abi.encodePacked(_team1)) 
          && keccak256(abi.encodePacked(_match.team2)) == keccak256(abi.encodePacked(_team2))
          && _match.datetime == _datetime ){
        _matchId = i;
        break;
      }
    } 
    return _matchId;    
  }

  function getMatch(uint8 _matchId) public view returns (Match memory _match){
      require(_matchId <= lastIdMatch, "This match doesn't exist");
      return matches[_matchId];
  }

  function getUserBets(address _user) public view returns (BetData[] memory _bets){
    BetData[] memory _lstBets = new BetData[](64);
    for (uint8 i = 0; i < 64; i++) {
        _lstBets[i] = betList[_user][i];
    }
    return _lstBets;
  }

  function getUserBetsByMatch(address _user, uint8 _matchId) public view returns (BetData memory _bet){
    return betList[_user][_matchId];
  }
  
  function _canBet(uint8 _id) internal view returns (bool) {
    return matches[_id].datetime !=0 &&
           block.timestamp >= matches[_id].datetime - 1 days && block.timestamp < matches[_id].datetime &&
           !matches[_id].closed;
  }

  function createMatch(string memory _team1, string memory _team2, uint256 _datetime) public whenRunning onlyOperator {
    // require(!existMatch(_team1, _team2, _datetime), "This match already has exists");
    matches[lastIdMatch].datetime = _datetime;
    matches[lastIdMatch].team1 = _team1;
    matches[lastIdMatch].team2 = _team2;
    lastIdMatch ++;
  }

  function changeMatch(string memory _team1, string memory _team2, uint256 _datetime, uint8 _matchId) public onlyOperator {
    require(_matchId <= lastIdMatch, "This match doesn't exist");
    if(bytes(_team1).length > 0){
      matches[_matchId].team1 = _team1;
    }
    
    if(bytes(_team2).length > 0){
      matches[_matchId].team2 = _team2;
    }
    
    if(_datetime > 0){
      matches[_matchId].datetime = _datetime;
    }
  }  

  function changeResult(string memory _team1, string memory _team2, uint256 _datetime, uint8 result, uint8 _matchId) public whenRunning onlyOperator {
    require(getMatchId(_team1, _team2, _datetime) == _matchId, "This match doesn't exist");
    require(result > 0, "Results has to be 1, 2 or 3");

    if(matches[_matchId].closed){
      matches[_matchId].result = result;
      _calculateRewards(_matchId, result, true);
    }
  }
  
  function _calculateRewards(uint8 _matchId, uint8 result, bool change) internal {
      if(!change){
        require(matches[_matchId].rewardBaseTotalAmount == 0 && matches[_matchId].rewardAmount == 0, "Rewards calculated");
      }

      Match storage _match = matches[_matchId];
      uint256 rewardBaseTotalAmount;
      uint256 feeAmt;
      uint256 rewardAmount;

      if (result == team1Win) {
        rewardBaseTotalAmount = _match.team1Amount;
        feeAmt = (_match.totalAmount * fee) / 10000;
        rewardAmount = _match.totalAmount - feeAmt;
      }
      else if (result == team2Win) {
        rewardBaseTotalAmount = _match.team2Amount;
        feeAmt = (_match.totalAmount * fee) / 10000;
        rewardAmount = _match.totalAmount - feeAmt;
      }
      else if (result == draw) {
        rewardBaseTotalAmount = _match.drawAmount;
        feeAmt = (_match.totalAmount * fee) / 10000;
        rewardAmount = _match.totalAmount - feeAmt;
      }else{
        rewardBaseTotalAmount = 0;
        feeAmt = _match.totalAmount;
        rewardAmount = 0;
      }

      _match.rewardBaseTotalAmount = rewardBaseTotalAmount;
      _match.rewardAmount = rewardAmount;

      // Add to fee
      //_safeTransferBNB(address(operator), feeAmt);
      if(!change){
        feePool += feeAmt;
      }

      emit RewardsCalculated(_matchId, rewardBaseTotalAmount, rewardAmount, feeAmt);
  }

  function endMatch(uint8 _matchId, uint8 result) public whenRunning onlyOperator nonReentrant {
    require(result > 0, "Results has to be 1, 2 or 3");
    
    matches[_matchId].result = result;    
    matches[_matchId].closed = true;   
    _calculateRewards(_matchId, result, false);

    emit EndMatch(_matchId, result);
  }
 
  function bet(uint8 _matchId, uint8 _choice) public payable whenRunning nonReentrant {
    require(msg.value >= minAmount, "You must bid more than minimal amount");
    require(_canBet(_matchId), "Match not bettable");
    require(betList[msg.sender][_matchId].amount == 0, "Can only bet once per match");
    require(_choice > 0, "Results has to be 1, 2 or 3");

    // Update match data
    uint256 amount = msg.value;
    Match storage _match = matches[_matchId];
    _match.totalAmount = _match.totalAmount + amount;

    // Update user data
    BetData storage betInfo = betList[msg.sender][_matchId];
    betInfo.amount = amount;
    betInfo.choice = _choice;

    if(_choice == team1Win){
      _match.team1Amount += amount; 
    }else if(_choice == team2Win){
      _match.team2Amount += amount;
    }else{
      _match.drawAmount += amount;
    }

    userMatches[msg.sender].push(_matchId);

    emit Bet(msg.sender, _matchId, amount, _choice);
  }

  function claimable(uint8 _matchId, address user) public view whenRunning returns (bool)  {
        BetData memory betData = betList[user][_matchId];
        Match memory _match = matches[_matchId];
        return
            _match.closed &&
            betData.amount != 0 &&
            !betData.claimed &&
            _match.result == betData.choice;
    }

  function claim(uint8 _matchId) public whenRunning nonReentrant {
    require(matches[_matchId].datetime !=0 , "Match doesn't exist.");
    require(claimable(_matchId, msg.sender), "Not eligible for claim");

    Match memory _match = matches[_matchId];
    uint256 reward = (betList[msg.sender][_matchId].amount * _match.rewardAmount) / _match.rewardBaseTotalAmount;
    require(reward > 0, "Reward is zero.");

    betList[msg.sender][_matchId].claimed = true;
    _safeTransferBNB(address(msg.sender), reward);
    
    emit Claim(msg.sender, _matchId, reward);       
    
  }

  function refund(uint8 _matchId) public whenRunning nonReentrant {
    uint userAmount = betList[msg.sender][_matchId].amount;
    require(userAmount > 0 , "You haven't bet on this match.");
    require(!betList[msg.sender][_matchId].claimed , "You have already claimed.");
    require(_canBet(_matchId), "Match is closed, you cannot refunded it.");

    
    matches[_matchId].totalAmount -= userAmount;
    if(betList[msg.sender][_matchId].choice == team1Win){
      matches[_matchId].team1Amount -= userAmount; 
    }else if(betList[msg.sender][_matchId].choice == team2Win){
      matches[_matchId].team2Amount -= userAmount;
    }else{
      matches[_matchId].drawAmount -= userAmount;
    }

    betList[msg.sender][_matchId].amount = 0;
    betList[msg.sender][_matchId].choice = 0;
    betList[msg.sender][_matchId].refunded = true;

    feePool += (userAmount * fee) / 10000;
    _safeTransferBNB(address(msg.sender), userAmount  - (userAmount * fee / 10000));    

    emit Refund(msg.sender, _matchId, userAmount  - (userAmount * fee / 10000));

  }
  
  function shareFees() public onlyAdminSponsors nonReentrant{
    require(lastTimeGettingFees == 0 || block.timestamp >= lastTimeGettingFees + intervalGettingFees,"");
    uint256 totalFees = 0;

    for(uint8 i = 0; i < lstSponsors.length; i++ ){
      totalFees += (sponsors[lstSponsors[i]].percent * feePool) / 10000;
      _safeTransferBNB(address(lstSponsors[i]), (sponsors[lstSponsors[i]].percent * feePool) / 10000);
    }

    _safeTransferBNB(address(operator), feePool - totalFees);

    feePool = 0;
  }


  function _safeTransferBNB(address to, uint256 value) internal {
      (bool success, ) = to.call{value: value}("");
      require(success, "TransferHelper: BNB_TRANSFER_FAILED");
  }

  function recoverToken(address token) public onlyAdmin {
      IERC20 Token = IERC20(token);
      Token.transfer(msg.sender, Token.balanceOf(address(this)));
  }
  
}