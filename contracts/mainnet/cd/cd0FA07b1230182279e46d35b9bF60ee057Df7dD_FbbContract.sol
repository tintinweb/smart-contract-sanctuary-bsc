/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

//SPDX-License-Identifier: MIT

// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.9;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.9;
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
        */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

pragma solidity ^0.8.9;

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

        // By storing the original value once again, a refund is triggered (see
        _status = _NOT_ENTERED;
    }
}

pragma solidity ^0.8.9;
// This is main smart contract code
contract FbbContract is Ownable, Pausable, ReentrancyGuard {

    address public adminAddress; // address of the admin
    address public operatorAddress; // address of the operator

    uint256 public goldPercent;
    uint256 public silverPercent;
    uint256 public bronzePercent;

    uint256 public lastGameID;
    uint256 public betAmount;

    uint256 public lockSeconds; // seconds of lock time before start game
    uint256 public feeAmount;

    mapping(address => uint256[]) public userGames; // address -> [game ids]
    mapping(uint256 => Game) public games; // game id -> Game Object
    mapping(uint256 => GameInfo) public gameInfos; // game id -> GameInfo Object
    mapping(uint256 => mapping(address => Ticket[])) public ledger; // 
    mapping(uint256 => Ticket) public gameTickets; // game id -> game win ticket object
    mapping(uint256 => address[]) public gameUsers; // game id -> [user address list]
    mapping(uint256 => mapping(address => bool)) public claimeds;

    enum GameStatus {
        OnGoing,        
        Finished,        
        Cancelled
    }

    enum Position {
        Horse,
        Hound,
        Turtle
    }

    enum GNumber {
        Zero,
        One,
        Two,
        Three,
        Four,
        Five
    }

    struct Game {
        uint256 id;
        uint256 startTimestamp;
        GameStatus status;
        uint256 ticketCounts;
        uint256 goldCounts;
        uint256 silverCounts;
        uint256 bronzeCounts;
        uint256 gBetAmount;
        uint256 gGoldPercent;
        uint256 gSilverPercent;
        uint256 gBronzePercent;
    }

    struct GameInfo {
        string horseName;
        string houndName;
        string gameName;
    }

    struct Ticket {
        Position firstHit;
        Position winner;
        GNumber horseFirstHit;
        GNumber houndFirstHit;
        GNumber totalHit;
        GNumber diffHit;
        bool hasPenalty;
        uint256 score;        
    }
    
    // events
    event BuyTicket(address user, uint256 gameID);
    event Claim(uint256 gameID, address user, uint256 reward);

    event NewBetAmount(uint256 betAmount);
    event NewPercents(uint256 goldPercent, uint256 silverPercent, uint256 bronzePercent);
    event NewOperatorAddress(address operator);
    event NewAdminAddress(address admin);
    event SetNewGame(uint256 gameID);
    event FeeClaim(uint256 feeAmount);
    event RewardsCalculated(uint256 gameID, uint256 rewardAmount);


    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Not admin");
        _;
    }

    modifier onlyAdminOrOperator() {
        require(msg.sender == adminAddress || msg.sender == operatorAddress, "Not operator/admin");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Not operator");
        _;
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }
    
    /**
     * Contract initialization.
     */
    constructor(
        address _adminAddress,
        address _operatorAddress,
        uint256 _betAmount,
        uint256 _goldPercent,
        uint256 _silverPercent,
        uint256 _bronzePercent,
        uint256 _lockSeconds
    ) {
        require(_goldPercent + _silverPercent + _bronzePercent < 100, "Percents are wrong");
        require(_betAmount * 10 >= 1,  "Bet amount is too low");

        adminAddress = _adminAddress;
        operatorAddress = _operatorAddress;
        betAmount = _betAmount;
        goldPercent = _goldPercent;
        silverPercent = _silverPercent;
        bronzePercent = _bronzePercent;
        lockSeconds = _lockSeconds;
    }

    // buy ticket..
    function buyTicket(uint256 gameID, Position firstHit, Position winner, GNumber horseFirstHit,
        GNumber houndFirstHit, GNumber totalHit, GNumber diffHit, bool hasPenality) 
        external payable whenNotPaused nonReentrant notContract {
        require(gameID > 0 && gameID <= lastGameID, "Game ID is wrong");
        Game storage game = games[gameID];
        require(game.status == GameStatus.OnGoing, "Game already finished or cancelled.");
        uint256 curTimestamp = block.timestamp;
        require(curTimestamp < game.startTimestamp - lockSeconds, "betting is too late");

        require(msg.value == betAmount, "Bet amount is wrong");

        // Update ticket data
        game.ticketCounts = game.ticketCounts + 1;

        Ticket memory ticket = Ticket(firstHit, winner, horseFirstHit, houndFirstHit, totalHit, diffHit, hasPenality, 0);

        // Update user data
        Ticket[] memory tickets = ledger[gameID][msg.sender];                
        if (tickets.length == 0) {
            userGames[msg.sender].push(gameID);
            gameUsers[gameID].push(msg.sender);
        }
        ledger[gameID][msg.sender].push(ticket);

        emit BuyTicket(msg.sender, gameID);
    }

    // claim money
    function claim(uint256[] calldata gameIDs) external nonReentrant notContract {
        uint256 reward; // Initializes reward

        for (uint256 i = 0; i < gameIDs.length; i++) {
            Game memory game = games[gameIDs[i]];
            require(game.status != GameStatus.OnGoing, "Game is ongoing");

            uint256 addedReward = 0;
            Ticket[] memory tickets = ledger[gameIDs[i]][msg.sender];                

            // Finished Game, claim reward
            if (game.status == GameStatus.Finished) {
                require(claimable(gameIDs[i], msg.sender), "Not eligible for claim");
                for(uint256 j = 0; j < tickets.length; j ++) {
                    if (tickets[j].score == 7) {
                        addedReward += game.gBetAmount * game.ticketCounts * game.gGoldPercent / (game.goldCounts * 100);
                    }
                    if (tickets[j].score >= 6) {
                        addedReward += game.gBetAmount * game.ticketCounts * game.gSilverPercent / ((game.goldCounts + game.silverCounts) * 100);
                    }
                    if (tickets[j].score >= 5) {
                        addedReward += game.gBetAmount * game.ticketCounts * game.gBronzePercent / ((game.goldCounts + game.silverCounts + game.bronzeCounts) * 100);
                    }
                }
            }
            // Cancelled Game, refund bet amount
            else {
                require(refundable(gameIDs[i], msg.sender), "Not eligible for refund");
                addedReward = game.gBetAmount * tickets.length;
            }
            
            claimeds[gameIDs[i]][msg.sender] = true;
            reward += addedReward;

            emit Claim(gameIDs[i], msg.sender, addedReward);
        }

        if (reward > 0) {
            _safeTransferBNB(address(msg.sender), reward);
        }
    }

    function userRoundTicketCount(uint256 gameID, address user) public view returns (uint256) {
        return ledger[gameID][user].length;
    }

    function claimable(uint256 gameID, address user) public view returns (bool) {        
        Ticket[] memory tickets = ledger[gameID][user];
        if (claimeds[gameID][user]) {
            return false;
        } else {
            for (uint256 i = 0; i < tickets.length; i++) {
                if (tickets[i].score > 4) {
                    return true;
                }                
            }
            return false;
        }
        
    }

    function refundable(uint256 gameID, address user) public view returns (bool) {
        Game memory game = games[gameID];
        Ticket[] memory tickets = ledger[gameID][user];
        if (claimeds[gameID][user]) {
            return false;
        } else {
            return game.status == GameStatus.Cancelled && tickets.length > 0;
        }
        
    }

    // admin functions .. 
    function setGame(uint256 startTimestamp, string calldata horseName, string calldata houndName, string calldata gameName) external whenNotPaused onlyOperator {
        uint256 curTimestamp = block.timestamp;
        require(curTimestamp < startTimestamp - lockSeconds, "Start time is too earlier");
        require(keccak256(abi.encodePacked(horseName)) != keccak256(abi.encodePacked("")), "Horse name is empty");
        require(keccak256(abi.encodePacked(houndName)) != keccak256(abi.encodePacked("")), "Hound name is empty");
        require(keccak256(abi.encodePacked(gameName)) != keccak256(abi.encodePacked("")), "Game name is empty");
        require(keccak256(abi.encodePacked(horseName)) != keccak256(abi.encodePacked(houndName)), "Horse name and hound name are the same");

        lastGameID = lastGameID + 1;
        GameInfo storage gameInfo = gameInfos[lastGameID];
        gameInfo.horseName = horseName;
        gameInfo.houndName = houndName;
        gameInfo.gameName = gameName;

        Game storage game = games[lastGameID];
        game.id = lastGameID;
        game.startTimestamp = startTimestamp;
        game.status = GameStatus.OnGoing;
        game.gBetAmount = betAmount;
        game.gGoldPercent = goldPercent;
        game.gSilverPercent = silverPercent;
        game.gBronzePercent = bronzePercent;

        emit SetNewGame(lastGameID);
    }

    function updateGameTime(uint256 gameID, uint256 startTimestamp) external whenNotPaused onlyOperator {
        require(gameID <= lastGameID, "Invalid game ID");
        uint256 curTimestamp = block.timestamp;
        require(curTimestamp < startTimestamp - lockSeconds, "Start time is too earlier");        
        Game storage game = games[gameID];
        require(game.status == GameStatus.OnGoing, "Game already finished or cancelled.");
        game.startTimestamp = startTimestamp;
    }

    function cancelGame(uint256 gameID) external whenNotPaused onlyOperator {
        require(gameID <= lastGameID, "Invalid game ID");
        Game storage game = games[gameID];
        require(game.status == GameStatus.OnGoing, "Game already finished or cancelled.");
        game.status = GameStatus.Cancelled;
    }

    function finishGame(uint256 gameID, Position firstHit, Position winner, GNumber horseFirstHit,
        GNumber houndFirstHit, GNumber totalHit, GNumber diffHit, bool hasPenalty) external whenNotPaused onlyOperator {
        require(gameID <= lastGameID, "Invalid game ID");
        Game storage game = games[gameID];
        // require(game.startTimestamp < block.timestamp, "Game did not start");
        require(game.status == GameStatus.OnGoing, "Game already finished or cancelled.");
        game.status = GameStatus.Cancelled;

        Ticket storage ticket = gameTickets[gameID];
        ticket.firstHit = firstHit;
        ticket.winner = winner;
        ticket.horseFirstHit = horseFirstHit;
        ticket.houndFirstHit = houndFirstHit;
        ticket.totalHit = totalHit;
        ticket.diffHit = diffHit;
        ticket.hasPenalty = hasPenalty;

        game.status = GameStatus.Finished;
        _calculateRewards(gameID);
    }

    /**
     * @dev called by the admin or operator to pause
     */
    function pause() external whenNotPaused onlyAdminOrOperator {
        _pause();
    }

    /**
     * @notice called by the admin to unpause, returns to normal state
     * Reset genesis state. Once paused, the rounds would need to be kickstarted by genesis
     */
    function unpause() external whenPaused onlyAdmin {
        _unpause();
    }

    /**
     * @notice Set set bet amount
     * @dev Callable by admin
     */
    function setBetAmount(uint256 _betAmount) external whenPaused onlyAdmin {
        require(_betAmount != 0, "Must be superior to 0");
        betAmount = _betAmount;

        emit NewBetAmount(betAmount);
    }

    function setPercents(uint256 _goldPercent, uint256 _silverPercent, uint256 _bronzePercent) external whenPaused onlyAdmin {
        require(_goldPercent > 0, "Must be superior to 0");
        require(_silverPercent > 0, "Must be superior to 0");
        require(_bronzePercent >= 0, "Must be equal or more than 0");
        require(_goldPercent + _silverPercent + _bronzePercent < 100, "Sum must be lower than 100");

        goldPercent = _goldPercent;
        silverPercent = _silverPercent;
        bronzePercent = _bronzePercent;        

        emit NewPercents(goldPercent, silverPercent, bronzePercent);
    }

    /**
     * @notice Set operator address
     * @dev Callable by admin
     */
    function setOperator(address _operatorAddress) external onlyAdmin {
        require(_operatorAddress != address(0), "Cannot be zero address");
        operatorAddress = _operatorAddress;

        emit NewOperatorAddress(_operatorAddress);
    }

    /**
     * @notice Set admin address
     * @dev Callable by owner
     */
    function setAdmin(address _adminAddress) external onlyOwner {
        require(_adminAddress != address(0), "Cannot be zero address");
        adminAddress = _adminAddress;

        emit NewAdminAddress(_adminAddress);
    }

    function claimFee() external nonReentrant onlyAdmin {
        uint256 currentFeeAmount = feeAmount;
        feeAmount = 0;
        _safeTransferBNB(adminAddress, currentFeeAmount);

        emit FeeClaim(currentFeeAmount);
    }

    // send bnb
    function _safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}("");
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }

    // calculate rewards
    function _calculateRewards(uint256 gameID) internal {        
        Ticket memory winTicket = gameTickets[gameID];
        address[] memory users = gameUsers[gameID];
        for(uint256 i = 0; i < users.length; i++) {
            Ticket[] memory tickets = ledger[gameID][users[i]];            
            for(uint256 j = 0; j < tickets.length; j++) {                
                uint256 score = 0;
                if(winTicket.firstHit == tickets[j].firstHit) {
                    score += 1;
                }
                if(winTicket.horseFirstHit == tickets[j].horseFirstHit) {
                    score += 1;
                }
                if(winTicket.houndFirstHit == tickets[j].houndFirstHit) {
                    score += 1;
                }
                if(winTicket.totalHit == tickets[j].totalHit) {
                    score += 1;
                }
                if(winTicket.diffHit == tickets[j].diffHit) {
                    score += 1;
                }
                if(winTicket.winner == tickets[j].winner) {
                    score += 1;
                }
                if(winTicket.hasPenalty == tickets[j].hasPenalty) {
                    score += 1;
                }
                ledger[gameID][users[i]][j].score = score;
                
                if (score == 7) {
                    games[gameID].goldCounts += 1;
                } else if (score == 6) {
                    games[gameID].silverCounts += 1;
                } else if (score == 5) {
                    games[gameID].bronzeCounts += 1;
                }
            }            
        }
        
        Game memory game = games[gameID];
        uint256 rewardPercent = 100 - game.gGoldPercent - game.gSilverPercent - game.gBronzePercent;
        uint256 totalAmount = game.ticketCounts * game.gBetAmount;
        
        uint256 rewardAmount = (totalAmount * rewardPercent / 100);
        if (games[gameID].goldCounts == 0) {
            rewardAmount += (totalAmount * game.gGoldPercent / 100);
            if (games[gameID].silverCounts == 0) {
                rewardAmount += (totalAmount * game.gSilverPercent / 100);
                if (games[gameID].bronzeCounts == 0) {
                    rewardAmount += (totalAmount * game.gBronzePercent / 100);
                }
            }
        }

        feeAmount += rewardAmount;       
        emit RewardsCalculated(gameID, rewardAmount);
    }


    /**
     * @notice Returns true if `account` is a contract.
     * @param account: account address
     */
    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}