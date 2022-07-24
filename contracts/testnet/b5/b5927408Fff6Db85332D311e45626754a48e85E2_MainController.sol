// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./MainControllerInterface.sol";
import "./MainControllerStorageV1.sol";
import "./MatchInterface.sol";
import "./MatchContract.sol";
import "./ITickets.sol";

/**
 * @title Main Controller Contract
 * @dev Main controller is in charge of global configuration and storage.
 */
contract MainController is MainControllerStorageV1, MainControllerInterface, Initializable, UUPSUpgradeable, OwnableUpgradeable {

    /// @notice initialize only run once
    function initialize (address _usdtAddress) public initializer {
      __Ownable_init();
      __UUPSUpgradeable_init();
      usdt = _usdtAddress;
      first_ref_fee = 40;
      second_ref_fee = 10;
      admin = owner();
      feeSetter = owner();
      uplineAdmin = owner();
      techFee = owner();
      communityFee = owner();
      uplineDict[uplineAdmin] = uplineAdmin;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function _authorizeUpgrade(address) internal override onlyOwner {}

    /**
     * get functions
     */
    /**
     * @notice Return all of the matches 
     * @dev The automatic getter may be used to access an individual match.
     * @return The list of match addresses
     */
    function getAllMatches() public override view returns (address[] memory) {
        return matchesList;
    }

    // return the number of all matches
    function allMatchesLength() external override view returns (uint)
    {
    	return matchesList.length;
    }

    // retrun specific math by an index
    function getMatchByIndex(uint index) external override view returns (address matchAddress)
    {
    	matchAddress = matchesList[index];
    }

    // get a match by date and team number
    function getMatch(string memory date, uint8 teamA, uint8 teamB) external override view returns (address matchAddress)
    {
    	if(teamA < teamB)
    		return matches[date][teamA][teamB];
	else
    		return matches[date][teamB][teamA];
    }
    // get team name by an team index
    function getTeamName(uint8 teamNo) external override view returns (string memory)
    {
    	return teamNamesDict[teamNo];
    }
    // get admin
    function Admin() external override view returns (address)
    {
    	return admin;
    }
    // get upline admin
    function getUplineAdmin() external override view returns (address)
    {
    	return uplineAdmin;
    }

    /**
     * write functions
     */
    // common vote 
    function commonVote(address matchAddress, uint8 team, uint8 flag, uint amount, address referer) external override returns (bool) //team: 0,1; flag:win,lose,even; amount: amount of USDT
    {
	require(MatchInterface(matchAddress).isMatchController() == true, "match address is not valid");
	//split 
	IERC20(usdt).transferFrom(msg.sender, address(this), amount);
	address upline = referer;
	if(referer == address(0))
		upline = uplineAdmin;
	address uplineRecord = getUpline(msg.sender);
	if(uplineRecord == address(0))
	{
		setUpline(msg.sender, upline);
	}
	else if(uplineRecord != referer)
	{
		upline = uplineRecord;
	}

	address upline2 = getUpline(upline);
	IERC20(usdt).transfer(upline, amount * first_ref_fee / PERCENT_DIVIDER);
	IERC20(usdt).transfer(upline2, amount * second_ref_fee / PERCENT_DIVIDER);
	IERC20(usdt).transfer(communityFee, amount * COMMUNITY_FEE_RATIO / PERCENT_DIVIDER);
	IERC20(usdt).transfer(techFee, amount * TECH_FEE_RATIO / PERCENT_DIVIDER);
	IERC20(usdt).transfer(matchAddress, amount * (PERCENT_DIVIDER - COMMUNITY_FEE_RATIO - TECH_FEE_RATIO - first_ref_fee - second_ref_fee)  / PERCENT_DIVIDER);
	MatchInterface(matchAddress).commonVote(msg.sender, team, flag, amount);
    	emit CommonVoted(msg.sender, matchAddress, team, flag, amount);
	return true;
    }
    // score vote
    function scoreVote(address matchAddress, uint8 _teamAScore, uint8 _teamBScore, uint amount, address referer) external override returns (bool) 
    {
	require(MatchInterface(matchAddress).isMatchController() == true, "match address is not valid");
	//split 
	IERC20(usdt).transferFrom(msg.sender, address(this), amount);
	address upline = referer;
	if(referer == address(0))
		upline = uplineAdmin;
	address uplineRecord = getUpline(msg.sender);
	if(uplineRecord == address(0))
	{
		setUpline(msg.sender, upline);
	}
	else if(uplineRecord != referer)
	{
		upline = uplineRecord;
	}

	address upline2 = getUpline(upline);
	IERC20(usdt).transfer(upline, amount * first_ref_fee / PERCENT_DIVIDER);
	IERC20(usdt).transfer(upline2, amount * second_ref_fee / PERCENT_DIVIDER);
	IERC20(usdt).transfer(communityFee, amount * COMMUNITY_FEE_RATIO / PERCENT_DIVIDER);
	IERC20(usdt).transfer(techFee, amount * TECH_FEE_RATIO / PERCENT_DIVIDER);
	IERC20(usdt).transfer(matchAddress, amount * (PERCENT_DIVIDER - COMMUNITY_FEE_RATIO - TECH_FEE_RATIO - first_ref_fee - second_ref_fee)  / PERCENT_DIVIDER);
	MatchInterface(matchAddress).scoreVote(msg.sender, _teamAScore, _teamBScore, amount);
    	emit ScoreVoted(msg.sender, matchAddress, _teamAScore, _teamBScore, amount);
	return true;
    }
    // set tech fee wallet
    function setTechFeeTo(address wallet) external override
    {
    	require(msg.sender == feeSetter, "no privilege");
    	require(wallet != address(0));
	techFee = wallet;
    }

    // set community fee wallet
    function setCommunityFeeTo(address wallet) external override
    {
    	require(msg.sender == feeSetter, "no privilege");
    	require(wallet != address(0));
	communityFee = wallet;
    }

    // set the operator, we do not check 0x0 address here, in case of abandon the privileges.
    function setFeeToSetter(address operator) external override onlyOwner
    {    
    	feeSetter = operator;
    }

    // set admin of operation
    function setAdmin(address operator) external override
    {
    	require(operator != address(0), "invalid admin address");
    	admin = operator;
    }

    // set upline admin of operation
    function setUplineAdmin(address operator) external override
    {
    	require(operator != address(0), "invalid admin address");
    	uplineAdmin = operator;
    }

    function getUpline(address account) public view returns (address)
    {
    	return uplineDict[account];
    }

    function getUplineFee() public override view returns (uint)
    {
    	return first_ref_fee;
    }

    function getUpline2Fee() public override view returns (uint)
    {
    	return second_ref_fee;
    }

    function setUplineFee(uint fee) external onlyOwner
    {
	first_ref_fee = fee;
    }

    function setUpline2Fee(uint fee) external onlyOwner
    {
	second_ref_fee = fee;
    }

    function setUpline(address userAddress, address uplineAddress) internal 
    {
    	uplineDict[userAddress] = uplineAddress;		
    }

    // set usdt address
    function setUsdtAddress(address _usdtAddress) override external
    {
    	require(msg.sender == admin, "only admin can set usdt");
	require(_usdtAddress != address(0), "invalid usdt address");
	usdt = _usdtAddress;
    }
    // set ticket nft address
    function setTicketNFTAddress(address _nftAddress) override external
    {
    	require(msg.sender == admin, "only admin can set");
	require(_nftAddress != address(0), "invalid nft address");
	ticketNFT = _nftAddress;
    }


    // create a new match
    function createMatch(string memory date, uint8 teamA, uint8 teamB, uint startTime, uint endTime) external override returns (address matchAddress)
    {
    	require(msg.sender == admin, "invalid admin account");
	require(teamA != teamB, "teamA and teamB are identical");
	(uint8 a, uint8 b) = teamA < teamB ? (teamA, teamB) : (teamB, teamA);
	require(matches[date][a][b] == address(0), "Match exists");
	bytes memory bytecode = type(MatchContract).creationCode;
	bytes32 salt = keccak256(abi.encodePacked(a,b));
	assembly {
		matchAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
	}
	MatchInterface(matchAddress).initialize(a, b, startTime, endTime, usdt);
 
 	matchesList.push(matchAddress);
	matches[date][a][b] = matchAddress;
	matchInfos[matchAddress] = Match(true, a, b, startTime, endTime);

	ITickets(ticketNFT).addMinters(matchAddress);	

    	emit MatchCreated(date, a, b, startTime, endTime, matchAddress);
	return matchAddress;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

abstract contract MatchInterface {
    struct VoteRecord{
        bool isCommon;
	uint8 flag; //0-even,1-win,2-lose
	uint8 scoreA;
	uint8 scoreB;
	uint256 voteAmount;
	uint256 timestamp;
    }
    /// @notice Indicator that this is a MainController contract (for inspection)
    bool public constant isMatchController = true;

    /*** get functions ***/
    function teamNames() external virtual view returns (string memory teamAName, string memory teamBName);
    function score(uint8 teamNo) external virtual view returns (uint8);
    function minVoteAmount() external virtual view returns (uint);
    function commonVotePool() external virtual view returns (uint winAmount, uint loseAmount, uint evenAmount, uint winUserAmount, uint loseUserAmount, uint evenUserAmount);
    function scoreVotePool(uint8 scoreA, uint8 scoreB) external virtual view returns (uint amount);
    function getAvailableReward(address account) public virtual view returns (uint);
    function getVoteRecords(address account) public virtual view returns (VoteRecord[] memory);

    /*** write functions ***/
    function initialize(uint8 _teamA, uint8 _teamB, uint _startTime, uint _endTime, address _usdtAddress) virtual external; 
    function commonVote(address account, uint8 team, uint8 flag, uint amount) external virtual returns (bool); //team: 0,1; flag:win,lose,even; amount: amount of USDT
    function scoreVote(address account, uint8 _teamAScore, uint8 _teamBScore, uint amount) external virtual returns (bool); //amount: amount of USDT, create the pool of this ratio if pool not exists
    function claimReward() external virtual returns (uint); 
    function createScorePool(uint8 _teamAScore, uint8 _teamBScore) external virtual returns (bool); //create sustomized pool, fail if pool exists
    function _setMatchScore(uint8 _teamA, uint8 _teamAScore, uint8 _teamB, uint8 _teamBScore) external virtual returns (bool); //only adminController can set 
    function _setMatchTimeStamp(uint startTimeStamp, uint endTimeStamp) external virtual returns (bool); //only adminController can set 

    /*** Events ***/
    // winner is one of teamA or teamB, 0 refers to even
    event MatchScoreSet(uint8 indexed teamA, uint8 indexed teamB, address indexed matchAddress, uint8 winner, uint8 scoreA, uint8 scoreB); 
    // Win, lose or even bet occurs
    event CommonVoted(address indexed player, address indexed matchAddress, uint8 winner);
    // customized bet occurs
    event ScoreVoted(address indexed player, address indexed matchAddress, uint8 scoreA, uint8 scoreB);
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MainControllerInterface.sol";
import "./MatchInterface.sol";

/**
 * @title Main Controller Contract
 * @dev Main controller is in charge of global configuration and storage.
 */
contract MatchContract is MatchInterface{ 

    address public mainController; //main controller's proxy address

    address public usdt; // vote token

    uint8 public teamA;
    uint8 public teamB;
    
    uint256 public startTime; //UNIX timestamp, in seconds
    uint256 public endTime;   //UNIX timestamp, in seconds

    uint256 public totalCommonRewardPoolAmount; // win, lose, even pool will be shared in total
    uint256 public totalScoreRewardPoolAmount;  // custom ratio pool will be shared in total

    // result score, defualt is 0
    uint8 public teamAScore;
    uint8 public teamBScore;
    uint8 public commonIndex; // 0-even, 1- teamA win, 2-teamA lose

    //min vote amount, defualt is 0
    uint public minVoteLimit;

    // result is set or not, default is false
    bool public resultSetted;

    // even-0, win-1, lose-2 => pool amount
    uint[3] public commonRewardPoolAmount;
    // even-0, win-1, lose-2 => user amount
    uint[3] public commonPoolUserAmount;
    // teamA:teamB ratio => pool amount
    mapping(uint8 => mapping(uint8 => uint)) public scoreRewardPoolAmount;
    // teamA:teamB ratio => user amount
    mapping(uint8 => mapping(uint8 => uint)) public scorePoolUserAmount;

    struct User{
    	uint[3] commonVoteAmount;
	mapping(uint8 => mapping(uint8 => uint)) scoreVoteAmount;
	uint amountPayout;
    }
    mapping (address => User) public users;

    struct MatchScore {
	uint8 scoreA;
	uint8 scoreB;
    }
    MatchScore[] public scorePools;

    struct MatchInfo{
	uint8 scoreA;
	uint8 scoreB;
	uint poolAmount;
	uint userAmount;
    }

    mapping(address => VoteRecord[]) public voteRecords;

    constructor() {
        mainController = msg.sender;
    }

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    /*** get functions ***/
    function teamNames() external override view returns (string memory teamAName, string memory teamBName)
    {
    	MainControllerInterface mainCtrl = MainControllerInterface(mainController);
	teamAName = mainCtrl.getTeamName(teamA);
	teamBName = mainCtrl.getTeamName(teamB);
    }

    // query the result score of a team
    function score(uint8 teamNo) external override view returns (uint8)
    {
    	if(teamNo == teamA)
		return teamAScore;
	if(teamNo == teamB)
		return teamBScore;
	return 0;
    }

    // bet minimum amount  
    function minVoteAmount() external override view returns (uint)
    {
    	return minVoteLimit;
    }

    // amount of win&lose&even reward pool
    function commonVotePool() external override view returns (uint winAmount, uint loseAmount, uint evenAmount, uint winUserAmount, uint loseUserAmount, uint evenUserAmount)
    {
    	winAmount = commonRewardPoolAmount[1];
	loseAmount = commonRewardPoolAmount[2];
	evenAmount = commonRewardPoolAmount[0];
    	winUserAmount = commonPoolUserAmount[1];
	loseUserAmount = commonPoolUserAmount[2];
	evenUserAmount = commonPoolUserAmount[0];
    }

    // amount of custm ratio pool
    function scoreVotePool(uint8 scoreA, uint8 scoreB) external override view returns (uint amount)
    {
    	return scoreRewardPoolAmount[scoreA][scoreB];
    }

    // get reward of a user can claim after the match
    function getAvailableReward(address account) public override view returns (uint)
    {
    	require(block.timestamp > endTime, "match is not end");
    	require(resultSetted == true, "match result is not revealed");
	// query beting records of msg.sender, and return the reward available 
	User storage user = users[account];
	uint commonRwardAmount = 0;
	if(commonRewardPoolAmount[commonIndex] > 0)
		commonRwardAmount = totalCommonRewardPoolAmount * user.commonVoteAmount[commonIndex] / commonRewardPoolAmount[commonIndex];
	uint scoreRewardAmount = 0;
	if(scoreRewardPoolAmount[teamAScore][teamBScore] > 0)
		scoreRewardAmount = totalScoreRewardPoolAmount * user.scoreVoteAmount[teamAScore][teamBScore] / scoreRewardPoolAmount[teamAScore][teamBScore];
	return commonRwardAmount + scoreRewardAmount - user.amountPayout;
    }
    // get score pools info
    function getMatchScorePoolsInfo() external view returns (MatchInfo[] memory)
    {
    	uint len = scorePools.length; 
	MatchInfo[] memory matchScorePool = new MatchInfo[](len);
	for(uint i = 0; i < len; i++)
	{
		matchScorePool[i].scoreA = scorePools[i].scoreA;
		matchScorePool[i].scoreB = scorePools[i].scoreB;
		matchScorePool[i].poolAmount = scoreRewardPoolAmount[scorePools[i].scoreA][scorePools[i].scoreB];
		matchScorePool[i].userAmount= scorePoolUserAmount[scorePools[i].scoreA][scorePools[i].scoreB];
	}
	return matchScorePool;
    }
    // get records of a user voting history 
    function getVoteRecords(address account) override public view returns (VoteRecord[] memory)
    {
    	return voteRecords[account];
    }


    /*** write functions ***/
    function initialize(uint8 _teamA, uint8 _teamB, uint _startTime, uint _endTime, address _usdtAddress) override external {
    	require(msg.sender == mainController, "no privilege to create new match");
	teamA = _teamA;
	teamB = _teamB;
	startTime = _startTime;
	endTime = _endTime;
	usdt = _usdtAddress;
    }

    //team: 0 for teamA,1 for teamB; flag:1-win,2-lose,0-even; amount: amount of USDT
    function commonVote(address account, uint8 teamNo, uint8 flag, uint amount) override external lock  returns (bool) 
    {
    	require(msg.sender == mainController, "only maincontroller has privilege to call this method");
	require(teamNo == teamA || teamNo == teamB, "invalid teamNo");
	User storage user = users[account];
	uint8 winner = 0;
	if(teamNo == teamA)
	{
		commonRewardPoolAmount[flag] += amount;
		user.commonVoteAmount[flag] += amount;
		commonPoolUserAmount[flag] += 1;
		if(flag == 1)
			winner = teamA;
		else if(flag == 2)
			winner = teamB;
	}else if(teamNo == teamB)
	{
		uint8 newFlag = flag;
		if(flag == 1)
		{
			newFlag == 2;
			winner = teamB;
		}
		else if(flag == 2)
		{
			newFlag = 1;
			winner = teamB;
		}
		commonRewardPoolAmount[newFlag] += amount;
		user.commonVoteAmount[newFlag] += amount;
		commonPoolUserAmount[newFlag] += 1;
	}

	uint uplineFee = MainControllerInterface(mainController).getUplineFee();
	uint upline2Fee = MainControllerInterface(mainController).getUpline2Fee();
	uint PERCENT_DIVIDER = MainControllerInterface(mainController).PERCENT_DIVIDER();
	uint COMMUNITY_FEE_RATIO = MainControllerInterface(mainController).COMMUNITY_FEE_RATIO();
	uint TECH_FEE_RATIO = MainControllerInterface(mainController).TECH_FEE_RATIO();
	totalCommonRewardPoolAmount += amount * (PERCENT_DIVIDER - COMMUNITY_FEE_RATIO - TECH_FEE_RATIO - uplineFee - upline2Fee) / PERCENT_DIVIDER;
	VoteRecord[] storage userVoteRecords = voteRecords[account];
	userVoteRecords.push(VoteRecord(true, flag, 0, 0, amount, block.timestamp));

	// TODO: issue NFT ticket to account

    	return true;
    }

    // teamA < teamB
    function scoreVote(address account, uint8 _teamAScore, uint8 _teamBScore, uint amount) external override returns (bool) //amount: amount of USDT, create the pool of this ratio if pool not exists
    {
    	require(msg.sender == mainController, "only maincontroller has privilege to call this method");
	User storage user = users[account];
	user.scoreVoteAmount[_teamAScore][_teamBScore] += amount;
	scoreRewardPoolAmount[_teamAScore][_teamBScore] += amount;
	scorePoolUserAmount[_teamAScore][_teamBScore] += 1;

	uint uplineFee = MainControllerInterface(mainController).getUplineFee();
	uint upline2Fee = MainControllerInterface(mainController).getUpline2Fee();
	uint PERCENT_DIVIDER = MainControllerInterface(mainController).PERCENT_DIVIDER();
	uint COMMUNITY_FEE_RATIO = MainControllerInterface(mainController).COMMUNITY_FEE_RATIO();
	uint TECH_FEE_RATIO = MainControllerInterface(mainController).TECH_FEE_RATIO();
	totalScoreRewardPoolAmount += amount * (PERCENT_DIVIDER - COMMUNITY_FEE_RATIO - TECH_FEE_RATIO - uplineFee - upline2Fee) / PERCENT_DIVIDER;
	VoteRecord[] storage userVoteRecords = voteRecords[account];
	userVoteRecords.push(VoteRecord(false, 0, _teamAScore, _teamBScore, amount, block.timestamp));
	
	// TODO: issue NFT ticket to account

    	return true;
    }

    function claimReward() override external lock returns (uint)
    {
    	require(block.timestamp > endTime, "match is not end");
    	require(resultSetted == true, "match result is not revealed");

	User storage user = users[msg.sender];
	uint amount = getAvailableReward(msg.sender);
	if(amount > 0)
	{
		user.amountPayout += amount;
		IERC20(usdt).transfer(msg.sender, amount);
	}
    	return amount;
    }

    // create ratio list for querying
    function createScorePool(uint8 _teamAScore, uint8 _teamBScore) override external lock returns (bool) 
    {
    	//create a new ratio pool to accept voting if not exists	
	for(uint i=0; i<scorePools.length; i++)
	{
		MatchScore memory m = scorePools[i];
		if(m.scoreA == _teamAScore && m.scoreB == _teamBScore)
			return false;
	}
	scorePools.push(MatchScore(_teamAScore, _teamBScore));
    	return true;
    }
    
    // admin set the result
    function _setMatchScore(uint8 _teamA, uint8 _teamAScore, uint8 _teamB, uint8 _teamBScore) override  external returns (bool) 
    {
    	require(msg.sender == MainControllerInterface(mainController).Admin(), "only maincontroller has privilege to set the match result");
	require((_teamA == teamA && _teamB == teamB) || (_teamA == teamB && _teamB == teamA), "wrong team number");

	uint8 winner = 0;
	if(_teamA == teamA)
	{
		teamAScore = _teamAScore;
		teamBScore = _teamBScore;
	}else if(_teamA == teamB)
	{
		teamAScore = _teamBScore;
		teamBScore = _teamAScore;
	}
	if(teamAScore == teamBScore)
		commonIndex = 0;
	else if(teamAScore > teamBScore)
	{
		commonIndex = 1;
		winner = teamA;
	}
	else if(teamAScore < teamBScore)
	{
		commonIndex = 2;
		winner = teamB;
	}
	resultSetted = true;
    	emit MatchScoreSet(teamA, teamB, address(this), winner, teamAScore, teamBScore); 
    	return true;
    }

    // admin update startTme and endTime
    function _setMatchTimeStamp(uint startTimeStamp, uint endTimeStamp) external override returns (bool) 
    {
    	require(msg.sender == MainControllerInterface(mainController).Admin(), "only maincontroller has privilege to set the match result");
	startTime = startTimeStamp;
	endTime = endTimeStamp;
	return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;


contract MainControllerStorageV1 {

    /**
     * @notice split fee ratio of tech team 
     */
    address public techFee;

    /**
     * @notice split fee ratio of community team 
     */
    address public communityFee;

    /**
     * @notice operator of fee setting 
     */
    address public feeSetter;

    /**
     * @notice administrator of operations, such as create a new match
     */
     address public admin;

    /**
     * @notice administrator of upline
     */
     address public uplineAdmin;

    /**
     * @notice split fee ratio of direct referor 
     */
    uint public first_ref_fee;

    /**
     * @notice split fee ratio of second referor 
     */
    uint public second_ref_fee;

    /**
     * @notice USDT address 
     */
    address public usdt;

    /**
     * @notice Tickets NFT address 
     */
    address public ticketNFT;

    struct Match {
	/// @notice isUsed
	bool isUsed;

	/// @notice Team number of first team
        uint teamA;
	/// @notice Team number of second team
	uint teamB;

	/// @notice start time in UNIX timestamp
	uint startTime;

	/// @notice close time in UNIX timestamp
	uint endTime;
    }

    /// @notice index date and team a and team b to match address 
    mapping (string =>mapping (uint8 => mapping (uint8 => address))) matches;

    /// @notice A list of all matches
    address[] public matchesList;

    /**
     * @notice Official mapping of match address -> Match metadata
     * @dev Used e.g. to determine if a match is supported
     */
    mapping(address => Match) public matchInfos;

    /**
     * Team name dictonary
     */
    mapping(uint8 => string) public teamNamesDict;

    /**
     * upline dictonary
     */
    mapping(address => address) public uplineDict;
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

abstract contract MainControllerInterface {
    /// @notice Indicator that this is a MainController contract (for inspection)
    bool public constant isMainController = true;
    uint public constant PERCENT_DIVIDER = 1000;
    uint public constant TECH_FEE_RATIO = 100;
    uint public constant COMMUNITY_FEE_RATIO = 100;

    /*** get functions ***/
    function Admin() external virtual view returns (address);
    function getUplineAdmin() external virtual view returns (address);
    function getUplineFee() external virtual view returns (uint);
    function getUpline2Fee() external virtual view returns (uint);

    function getTeamName(uint8 teamNo) external virtual view returns (string memory);
    function getAllMatches() public virtual view returns (address[] memory);
    function getMatch(string memory date, uint8 teamA, uint8 teamB) external virtual view returns (address matchAddress);
    function getMatchByIndex(uint) external virtual view returns (address matchAddress);
    function allMatchesLength() external virtual view returns (uint);

    /*** write functions ***/
    function createMatch(string memory date, uint8 teamA, uint8 teamB, uint startTime, uint endTime) virtual external returns (address matchAddress);

    function setTechFeeTo(address wallet) external virtual;
    function setCommunityFeeTo(address wallet) external virtual;
    function setFeeToSetter(address operator) external virtual; 
    function setAdmin(address operator) external virtual; 
    function setUplineAdmin(address operator) external virtual; 
    function setUsdtAddress(address _usdtAddress) virtual external;
    function setTicketNFTAddress(address _nftAddress) virtual external;
    function commonVote(address matchAddress, uint8 team, uint8 flag, uint amount, address referer) external virtual returns (bool); //team: 0,1; flag:win,lose,even; amount: amount of USDT
    function scoreVote(address matchAddress, uint8 _teamAScore, uint8 _teamBScore, uint amount, address referer) external virtual returns (bool); //amount: amount of USDT, create the pool of this ratio if pool not exists

    /*** Events ***/
    event MatchCreated(string indexed date, uint8 indexed teamA, uint8 indexed teamB, uint startTime, uint endTime, address matchAddress);
    event CommonVoted(address indexed account, address indexed matchAddress, uint8 teamNo, uint8 flag, uint256 amount);
    event ScoreVoted(address indexed account, address indexed matchAddress, uint8 teamAScore, uint8 teamBScore, uint256 amount);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @dev External interface of Tickets declared to support ERC165 detection.
 */
interface ITickets {

    /**
     * @dev Returns `tokenId` if success
     */
    function newTicket(address voter, address matchAddress, uint8 teamA, uint8 teamB, uint256 amount) external returns (uint256); 
    function checkoutTicket(uint256 tokenId) external returns (bool); 
    function getTicketInfo(uint256 tokenId) external view returns(address, address, uint8, uint8, uint256, uint256, bool);
    function addMinters(address minter) external;
    function addMintersAdmin(address admin) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}