//SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../contracts/interfaces/ILVGR.sol";
import "../contracts/interfaces/IJackpot.sol";
import "../contracts/interfaces/ITreasury.sol";

contract HashGame is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    IERC20 public USDT;
    IERC20 public LVGC;
    IERC20 public LVGR;
    I_LVGR public ILVGR;
    I_Jackpot public IJackpot;
    I_Treasury public ITreasury;
    
    struct GameInfo {
        uint256 premiumFee;
        uint256 initialGameFee;
    }

    struct UserGameInfo {
        bool gameActive;
        uint256 gameMode;
        uint256 currentGameRound;
        uint256 currentGameRoundAmount;
        uint256 currentGameCheckpoint;
        uint256 registerGameTimestamp;
        uint256 consecutiveBurstCount;
    }

    struct UserPremiumInfo {
        bool premiumActive;
        uint256 purchasedTimestamp;
        uint256 claimedTimestamp;
    }

    // Info of each game pool.
    GameInfo[] private gameInfo;
    mapping (address => UserGameInfo) public userDefaultGameInfo;
    mapping (address => UserGameInfo) public userLvgcGameInfo;
    mapping (address => UserGameInfo) public userLvgrGameInfo;
    mapping (address => UserPremiumInfo) public userPremiumInfo;
    uint256[] private premiumReimbursement;

    address private DEAD_ADDR;
    address private genesisNodeReceiver;
    address private tokenHolderReceiver;
    address private liquidityPoolReceiver;
    address private insurancePoolReceiver;
    address private marketSystemReceiver;

    uint256 private genesisNodePercentage;
    uint256 private tokenHolderPercentage;
    uint256 private liquidityPoolPercentage;
    uint256 private insurancePoolPercentage;
    uint256 private marketSystemPercentage;

    uint256 private gameMinThreshold;    // Minimum threshold to join default game
    uint256 private gameMaxThreshold;   // Maximum threshold to join default game
    uint256 private premiumDistributionThreshold;
    uint256 private maxRoundPerGame;
    uint256 private cooldownInterval;

    mapping (address => bool) private operator;

    modifier onlyOperator {
        require(isOperator(msg.sender), "Only operator can perform this action");
        _;
    }

    function initialize(address _usdt, address _lvgc, address _lvgr, address _treasury, address _deadAddr,
        uint256 _gameMinThreshold, uint256 _gameMaxThreshold, uint256 _premiumDistributionThreshold, 
        uint256 _maxRoundPerGame, uint256 _cooldownInterval
    ) public initializer {

        USDT = IERC20(_usdt);
        LVGC = IERC20(_lvgc);
        LVGR = IERC20(_lvgr);
        ILVGR = I_LVGR(_lvgr);
        ITreasury = I_Treasury(_treasury);
        DEAD_ADDR = _deadAddr;

        gameMinThreshold = _gameMinThreshold;
        gameMaxThreshold = _gameMaxThreshold;
        premiumDistributionThreshold = _premiumDistributionThreshold;
        maxRoundPerGame = _maxRoundPerGame;
        cooldownInterval = _cooldownInterval;

        // Set owner as operator
        operator[msg.sender] = true;

        __ReentrancyGuard_init();
        __Ownable_init();
    }

    function joinDefaultGame(uint256 _amount) external nonReentrant {
        UserGameInfo storage _userInfo = userDefaultGameInfo[msg.sender];

        require(!_userInfo.gameActive, "Processing previous game, please try again later");
        require(_amount >= gameMinThreshold, "Below minimum threshold");
        require(_amount <= gameMaxThreshold, "Exceeded maximum threshold");
        require(USDT.balanceOf(msg.sender) >= _amount, "Insufficient USDT");

        // Check allowance and transfer USDT into the contract
        uint256 _allowance = USDT.allowance(msg.sender, address(this));
        require(_allowance >= _amount, "Insufficient allowance");
        bool status = USDT.transferFrom(msg.sender, address(ITreasury), _amount);
        require(status, "Failed to transfer the fund. Please try again");

        // Update user info
        _userInfo.gameActive = true;
        _userInfo.currentGameRoundAmount = _amount;

        emit JoinDefaultGame(msg.sender, _amount);
    }

    function processDefaultGame(address _userAddress, bool _result) external nonReentrant onlyOperator {
        UserGameInfo storage _userInfo = userDefaultGameInfo[_userAddress];
        require(_userInfo.gameActive, "No active game found");

        uint256 _rewards = 0;
        if(_result) {
            _rewards = _userInfo.currentGameRoundAmount * 2;
            ITreasury.withdraw(_userAddress, _rewards);
        }            
            
        // Update user info
        _userInfo.gameActive = false;
        _userInfo.currentGameRoundAmount = 0;

        emit ProcessDefaultGame(_userAddress, _result, _rewards);
    }

    function registerHashGame(uint256 _gid, bool _premium, bool _jackpot) external nonReentrant {
        UserGameInfo storage _userLvgcGameInfo = userLvgcGameInfo[msg.sender];
        UserGameInfo storage _userLvgrGameInfo = userLvgrGameInfo[msg.sender];

        require(_gid != 0, "Invalid game ID");
        require(isValidGameMode(_gid), "Invalid game mode");
        require(
            _userLvgcGameInfo.currentGameCheckpoint == _userLvgcGameInfo.currentGameRound, 
            "Processing previous LVGC game, please try again later"
        );
        require(
            _userLvgrGameInfo.currentGameCheckpoint == _userLvgrGameInfo.currentGameRound, 
            "Processing previous LVGR game, please try again later"
        );

        // check whether any pending claim jackpot & grand jackpot
        bool _wonJackpot = IJackpot.wonJackpot(msg.sender);
        bool _wonGrandJackpot = IJackpot.wonGrandJackpot(msg.sender);

        require(!_wonGrandJackpot, "Please claim your grand jackpot");
        require(!_wonJackpot, "Please claim your jackpot");

        // Reset user premium and jackpot, if user change game mode
        if(_userLvgcGameInfo.gameMode != 0 && _userLvgcGameInfo.gameMode != _gid && _userLvgrGameInfo.gameMode != _gid)
            voidPremiumAndJackpot(msg.sender);

        // Reset and update user Lvgc game info
        resetLvgcGame(msg.sender);
        _userLvgcGameInfo.gameMode = _gid;
        _userLvgcGameInfo.registerGameTimestamp = block.timestamp;
        _userLvgcGameInfo.consecutiveBurstCount = 0;

        // Reset and update user Lvgr game info
        resetLvgrGame(msg.sender);
        _userLvgrGameInfo.gameMode = _gid;
        _userLvgrGameInfo.registerGameTimestamp = block.timestamp;
        _userLvgrGameInfo.consecutiveBurstCount = 0;

        if(_premium) {
            purchasePremium(_gid, msg.sender);

            if(_jackpot) {
                IJackpot.purchaseJackpot(_gid, msg.sender);
            }
        }
   
        emit RegisterHashGame(_gid, _premium, _jackpot, msg.sender);
    }

    function joinLvgcGame(uint256 _amount) external nonReentrant {
        UserGameInfo storage _userInfo = userLvgcGameInfo[msg.sender];
        require(_amount >= gameMinThreshold, "Below minimum threshold");
        require(_amount <= gameMaxThreshold, "Exceeded maximum threshold");
        require(_userInfo.gameMode != 0, "No game found, please register first");
        require(_userInfo.currentGameCheckpoint == _userInfo.currentGameRound, "Processing previous game, please try again later");
        require(USDT.balanceOf(msg.sender) >= _amount, "Insufficient USDT");

        // Check allowance and transfer fund
        uint256 _allowance = USDT.allowance(msg.sender, address(this));
        require(_allowance >= _amount, "Insufficient allowance");
        bool status = USDT.transferFrom(msg.sender, address(ITreasury), _amount);
        require(status, "Failed to transfer the fund. Please try again");

        // Trick play
        if(_amount != getLvgcNextRoundFee(msg.sender)) {
            voidPremiumAndJackpot(msg.sender);
        }

        // Update user info
        _userInfo.gameActive = true;
        _userInfo.currentGameRound ++;
        _userInfo.currentGameRoundAmount = _amount;

        emit JoinLvgcGame(_userInfo.gameMode, msg.sender, _userInfo.currentGameRound, _amount);
    }

    function processLvgcGame(address _userAddress, bool _result) external nonReentrant onlyOperator {
        UserGameInfo storage _userInfo = userLvgcGameInfo[_userAddress];
        require(_userInfo.gameActive, "No active game found");
        require(_userInfo.currentGameRound > _userInfo.currentGameCheckpoint, "No new game round to process");

        // Increment the checkpoint
        _userInfo.currentGameCheckpoint ++;
        uint256 _rewards = 0;

        if(_result) {    
            // Distribute rewards + invested amount, and reset user's game info if user won    
            _rewards = _userInfo.currentGameRoundAmount * 2;

            // Set premium to false when user won
            if(userPremiumInfo[_userAddress].premiumActive) {
                UserPremiumInfo storage _userPremiumInfo = userPremiumInfo[_userAddress];
                _userPremiumInfo.premiumActive = false;
                _userPremiumInfo.claimedTimestamp = block.timestamp;
            }
            
            resetLvgcGame(_userAddress);
            ITreasury.withdraw(_userAddress, _rewards);
            
        } else if(_userInfo.currentGameRound == maxRoundPerGame && _userInfo.currentGameCheckpoint == maxRoundPerGame) {
            // Distribute premium rewards to user if user purchased premium and is valid
            if(isValidPremium(_userAddress)) 
                distributePremiumRewards(_userInfo.gameMode , _userAddress);

            // Reset user's game info if user lost the last round
            resetLvgcGame(_userAddress);
        } 

        emit ProcessLvgcGame(_userInfo.gameMode, _userAddress, _result, _rewards);
    }

    function joinLvgrGame(uint256 _amount) external nonReentrant {
        UserGameInfo storage _userInfo = userLvgrGameInfo[msg.sender];
        uint256 _userGameMode = _userInfo.gameMode;
        require(_amount >= gameInfo[_userGameMode].initialGameFee, "Amount must be larger than the initial game fee");
        require(_amount <= gameMaxThreshold, "Exceeded maximum threshold");
        require(_userGameMode != 0, "No game found, please register first");
        require(isValidGameMode(_userGameMode), "No valid game found, failed to join game");
        require(_userInfo.currentGameCheckpoint == _userInfo.currentGameRound, "Processing previous game, please try again later");
        require(LVGR.balanceOf(msg.sender) >= _amount, "Insufficient LVGR");
        
        // Validate whether user won any jackpot
        validateUserJackpot(msg.sender);

        // Check allowance and transfer LVGR
        uint256 _allowance = LVGR.allowance(msg.sender, address(this));
        require(_allowance >= _amount, "Insufficient allowance");
        bool status = LVGR.transferFrom(msg.sender, DEAD_ADDR, _amount);
        require(status, "Failed to transfer the fund. Please try again");

        // Trick play
        if(_amount != getLvgrNextRoundFee(msg.sender)) {
            voidPremiumAndJackpot(msg.sender);
        }

        // Update user info
        _userInfo.gameActive = true;
        _userInfo.currentGameRound ++;
        _userInfo.currentGameRoundAmount = _amount;

        emit JoinLvgrGame(_userGameMode, msg.sender, _userInfo.currentGameRound, _amount);
    }

    function processLvgrGame(address _userAddress, bool _result) external nonReentrant onlyOperator {
        UserGameInfo storage _userInfo = userLvgrGameInfo[_userAddress];
        require(_userInfo.gameActive, "No active game found");
        require(_userInfo.currentGameRound > _userInfo.currentGameCheckpoint, "No new game round to process");

        // Increment the checkpoint
        _userInfo.currentGameCheckpoint ++;
        uint256 _rewards = 0;

        if(_result) {    
            // Distribute rewards and reset user's game info if user won    
            _rewards = _userInfo.currentGameRoundAmount;

            // Set premium to false when user won
            if(userPremiumInfo[_userAddress].premiumActive) {
                UserPremiumInfo storage _userPremiumInfo = userPremiumInfo[_userAddress];
                _userPremiumInfo.premiumActive = false;
                _userPremiumInfo.claimedTimestamp = block.timestamp;
            }
            
            // Reset Game
            resetLvgrGame(_userAddress);

            // Transfer rewards to user
            distributeLvgrGameRewards(_userInfo.gameMode, _userAddress, _rewards);

            // Reset user's burst count
            _userInfo.consecutiveBurstCount = 0;
            
        } else if(_userInfo.currentGameRound == maxRoundPerGame && _userInfo.currentGameCheckpoint == maxRoundPerGame) {
            // User game burst
            // Mint LVGR to user if with valid premium
            if(isValidPremium(_userAddress)) 
                distributePremiumRewards(_userInfo.gameMode, _userAddress);

            // Reset user's game info 
            resetLvgrGame(_userAddress);

            // Increment user's burst count
            _userInfo.consecutiveBurstCount++;

            triggerJackpot(_userAddress);
        } 

        emit ProcessLvgrGame(_userInfo.gameMode, _userAddress, _result, _rewards);
    }

    function triggerJackpot(address _userAddress) internal {
        bool _isValidJackpot = IJackpot.isValidJackpot(_userAddress);
        bool _isValidGrandJackpot = IJackpot.isValidGrandJackpot(_userAddress);
        uint256 _burstCount = userLvgrGameInfo[_userAddress].consecutiveBurstCount;

        if(_isValidJackpot && _burstCount == 1) {
            IJackpot.setWonJackpot(_userAddress);
        } else if(_isValidGrandJackpot && _burstCount == 2) {
            IJackpot.setWonGrandJackpot(_userAddress);
        }

        emit TriggerJackpot(_userAddress, _isValidJackpot, _isValidGrandJackpot, _burstCount);
    }

    function purchasePremium(uint256 _gid, address _userAddress) internal {
        UserPremiumInfo storage _userPremiumInfo = userPremiumInfo[_userAddress];
        GameInfo storage _gameInfo = gameInfo[_gid];

        require(!isValidPremium(_userAddress), "Valid premium found, cannot purchase again");
        require(_userPremiumInfo.purchasedTimestamp + cooldownInterval <= block.timestamp, "Premium is in cooldown");
        require(LVGC.balanceOf(_userAddress) >= _gameInfo.premiumFee, "Insufficient LVGC");

        // Check allowance
        uint256 _allowance = LVGC.allowance(_userAddress, address(this));
        require(_allowance >= _gameInfo.premiumFee, "Insufficient allowance");

        // Transfer LVGC into the contract
        bool _status = LVGC.transferFrom(_userAddress, address(this), _gameInfo.premiumFee);
        require(_status, "Failed to transfer the fund. Please try again");

        // Update user info
        _userPremiumInfo.premiumActive = true;
        _userPremiumInfo.purchasedTimestamp = block.timestamp;
        _userPremiumInfo.claimedTimestamp = 0;

        distributePremium();

        emit PurchasePremium(_gid, _userAddress, _gameInfo.premiumFee);
    }

    function distributePremium() internal {
        uint256 _balance = LVGC.balanceOf(address(this));

        if(_balance >= premiumDistributionThreshold) {
            LVGC.transfer(genesisNodeReceiver, _balance * genesisNodePercentage / 100);
            LVGC.transfer(tokenHolderReceiver, _balance * tokenHolderPercentage / 100);
            LVGC.transfer(liquidityPoolReceiver, _balance * liquidityPoolPercentage / 100);
            LVGC.transfer(insurancePoolReceiver, _balance * insurancePoolPercentage / 100);
            LVGC.transfer(marketSystemReceiver, _balance * marketSystemPercentage / 100);
        }

        emit DistributePremium(_balance);
    }

    function distributePremiumRewards(uint256 _gameMode, address _userAddress) internal {
        uint256 _amount = getPremiumReimbursementByIndex(_gameMode);

        // Mint LVGR rewards to user, accoring to the premium plan
        ILVGR.mint(_userAddress, _amount);
        
        emit DistributePremiumRewards(_gameMode, _userAddress, _amount);
    }

    function distributeLvgrGameRewards(uint256 _gameMode, address _userAddress, uint256 _amount) internal {
        uint256 _usdtRewards = gameInfo[_gameMode].initialGameFee;
        uint256 _lvgrRewards = (_amount * 2) - _usdtRewards;

        ITreasury.withdraw(_userAddress, _usdtRewards);

        // Mint LVGR rewards 
        if(_lvgrRewards > 0)
            ILVGR.mint(_userAddress, _lvgrRewards);
        
        emit DistributeLvgrGameRewards(_gameMode, _userAddress, _usdtRewards, _lvgrRewards);
    }

    function voidPremiumAndJackpot(address _userAddress) internal {
        UserPremiumInfo storage _userPremiumInfo = userPremiumInfo[_userAddress];

        _userPremiumInfo.premiumActive = false;
        IJackpot.voidJackpot(_userAddress);

        emit VoidPremiumAndJackpot(_userAddress); 
    }

    function resetLvgcGame(address _userAddress) internal {
        UserGameInfo storage _userInfo = userLvgcGameInfo[_userAddress];

        _userInfo.gameActive = false;
        _userInfo.currentGameRound = 0;
        _userInfo.currentGameRoundAmount = 0;
        _userInfo.currentGameCheckpoint = 0;

        emit ResetLvgcGame(_userAddress);
    }

    function resetLvgrGame(address _userAddress) internal {
        UserGameInfo storage _userInfo = userLvgrGameInfo[_userAddress];

        _userInfo.gameActive = false;
        _userInfo.currentGameRound = 0;
        _userInfo.currentGameRoundAmount = 0;
        _userInfo.currentGameCheckpoint = 0;

        emit ResetLvgrGame(_userAddress);
    }

    function resetUserLvgrBurstCount(address _userAddress) external onlyOperator {
        UserGameInfo storage _userInfo = userLvgrGameInfo[_userAddress];
        _userInfo.consecutiveBurstCount = 0;

        emit ResetUserLvgrBurstCount(_userInfo.gameMode, _userAddress);
    }

    function registerGameInfo(uint256 _premium, uint256 _initialGameFee) external onlyOwner {
   
        gameInfo.push(GameInfo({
            premiumFee : _premium,
            initialGameFee : _initialGameFee
        }));

        emit RegisterGameInfo(_premium, _initialGameFee);
    }

    function updateGameInfo(uint256 _gid, uint256 _premiumFee, uint256 _initialGameFee) external onlyOwner {
        
        GameInfo storage _gameInfo = gameInfo[_gid];
        _gameInfo.premiumFee = _premiumFee;
        _gameInfo.initialGameFee = _initialGameFee;

        emit UpdateGameInfo(_gid, _premiumFee, _initialGameFee);
    }

    function rescueToken(address _token, address _to, uint256 _amount) external onlyOwner {
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        require(_amount <= _contractBalance, "Insufficient token");

        IERC20(_token).transfer(_to, _amount);

        emit RescueToken(_token, _to, _amount);
    }

    // ===================================================================
    // GETTERS
    // ===================================================================

    function validateUserJackpot(address _userAddress) internal view {
        bool _wonJackpot = IJackpot.wonJackpot(_userAddress);
        bool _wonGrandJackpot = IJackpot.wonGrandJackpot(_userAddress);
        bool _canPurchaseGrandJackpot = IJackpot.getPurchaseGrandJackpotFlag(_userAddress);

        require(!_wonGrandJackpot, "Please claim your grand jackpot");

        if(_wonJackpot)
            require(!_canPurchaseGrandJackpot, "Please claim your jackpot, or upgrade to grand jackpot");
    }

    function isOperator(address _userAddress) public view returns(bool) {
        return operator[_userAddress];
    }

    function isValidGameMode(uint256 _gid) internal view returns(bool) {
        if(gameInfo[_gid].initialGameFee > 0 && gameInfo[_gid].premiumFee > 0)
            return true;
        else    
            return false;
    }

    function isValidPremium(address _userAddress) public view returns(bool) {
        if(userPremiumInfo[_userAddress].premiumActive && 
            userPremiumInfo[_userAddress].purchasedTimestamp + cooldownInterval > block.timestamp) {
            return true;
        } 
        return false;
    }

    function getLvgcNextRoundFee(address _userAddress) public view returns(uint256) {
        UserGameInfo storage _userInfo = userLvgcGameInfo[_userAddress];
        GameInfo storage _gameInfo = gameInfo[_userInfo.gameMode];

        uint256 _amount = _gameInfo.initialGameFee;
        for(uint i=0; i<_userInfo.currentGameRound; i++) {
            _amount = _amount * 2;
        }

        return _amount;
    }

    function getLvgrNextRoundFee(address _userAddress) public view returns(uint256) {
        UserGameInfo storage _userInfo = userLvgrGameInfo[_userAddress];
        GameInfo storage _gameInfo = gameInfo[_userInfo.gameMode];

        uint256 _amount = _gameInfo.initialGameFee;
        for(uint i=0; i<_userInfo.currentGameRound; i++) {
            _amount = _amount * 2;
        }

        return _amount;
    }

    function getGameInfo(uint256 _gid) external view returns(GameInfo memory) {
        return gameInfo[_gid];
    }

    function getGameInfoLength() public view returns(uint256) {
        return gameInfo.length;
    }

    function getUserPremiumInfo(address _userAddress) external view returns(UserPremiumInfo memory) {
        return userPremiumInfo[_userAddress];
    }

    function getUserDefaultGameInfo(address _userAddress) external view returns(bool, uint256) {
        UserGameInfo storage _userInfo = userDefaultGameInfo[_userAddress];

        return (
            _userInfo.gameActive, 
            _userInfo.currentGameRoundAmount
        );
    }

    function getUserLvgcGameInfo(address _userAddress) external view returns(UserGameInfo memory) {
        return userLvgcGameInfo[_userAddress];
    }

    function getUserLvgrGameInfo(address _userAddress) external view returns(UserGameInfo memory) {
        return userLvgrGameInfo[_userAddress];
    }

    function getPremiumReimbursement() external view returns(uint256[] memory) {
        return premiumReimbursement;
    }

    function getPremiumReimbursementByIndex(uint256 _index) public view returns(uint256) {
        return premiumReimbursement[_index];
    }

    function getPremiumReceiver() external view returns(address, address, address, address, address) {
        return (
            genesisNodeReceiver, 
            tokenHolderReceiver, 
            liquidityPoolReceiver, 
            insurancePoolReceiver, 
            marketSystemReceiver
        );
    }

    function getPremiumDistributionPercentage() external view returns(uint256, uint256, uint256, uint256, uint256) {
        return (
            genesisNodePercentage, 
            tokenHolderPercentage, 
            liquidityPoolPercentage, 
            insurancePoolPercentage, 
            marketSystemPercentage
        );
    }

    function getGameMinThreshold() external view returns(uint256) {
        return gameMinThreshold;
    }

    function getGameMaxThreshold() external view returns(uint256) {
        return gameMaxThreshold;
    }

    function getPremiumDistributionThreshold() external view returns(uint256) {
        return premiumDistributionThreshold;
    }

    function getMaxRoundPerGame() external view returns(uint256) {
        return maxRoundPerGame;
    }

    function getCooldownInterval() external view returns(uint256) {
        return cooldownInterval;
    }
    
    // Used by jackpot interface
    function isUserLvgrGameActive(address _userAddress) external view returns(bool) {
        return userLvgrGameInfo[_userAddress].gameActive;
    }

    function getUserLvgrBurstCount(address _userAddress) external view returns(uint256) {
        return userLvgrGameInfo[_userAddress].consecutiveBurstCount;
    }
    
    // ===================================================================
    // SETTERS
    // ===================================================================
    function setLvgcAddress(address _newAddress) external onlyOwner {
        require(_newAddress != address(0), "Address zero");
        LVGC = IERC20(_newAddress);

        emit SetLvgcAddress(_newAddress);
    }

    function setLvgrAddress(address _newAddress) external onlyOwner {
        require(_newAddress != address(0), "Address zero");
        LVGR = IERC20(_newAddress);
        ILVGR = I_LVGR(_newAddress);

        emit SetLvgrAddress(_newAddress);
    }

    function setJackpotAddress(address _newAddress) external onlyOwner {
        require(_newAddress != address(0), "Address zero");
        IJackpot = I_Jackpot(_newAddress);
        operator[_newAddress] = true;

        emit SetJackpotAddress(_newAddress);
    }

    function setTreasuryAddress(address _newAddress) external onlyOwner {
        require(_newAddress != address(0), "Address zero");
        ITreasury = I_Treasury(_newAddress);

        emit SetTreasuryAddress(_newAddress);
    }

    function setOperator(address _userAddress, bool _bool) external onlyOwner {
        require(_userAddress != address(0), "Address zero");
        operator[_userAddress] = _bool;

        emit SetOperator(_userAddress, _bool);
    }

    function setPremiumReimbursement(uint256[] memory _premiumReimbursement) external onlyOwner {
        require(_premiumReimbursement.length > 0, "Empty array");
        premiumReimbursement = _premiumReimbursement;

        emit SetPremiumReimbursement(_premiumReimbursement);
    }

    function setPremiumReceiver(
        address _genesisNodeReceiver, 
        address _tokenHolderReceiver, 
        address _liquidityPoolReceiver, 
        address _insurancePoolReceiver, 
        address _marketSystemReceiver
    ) external onlyOwner {
        genesisNodeReceiver = _genesisNodeReceiver;
        tokenHolderReceiver = _tokenHolderReceiver;
        liquidityPoolReceiver = _liquidityPoolReceiver;
        insurancePoolReceiver = _insurancePoolReceiver;
        marketSystemReceiver = _marketSystemReceiver;

        emit SetPremiumReceiver(_genesisNodeReceiver, _tokenHolderReceiver, _liquidityPoolReceiver, _insurancePoolReceiver, _marketSystemReceiver);
    }

    function setPremiumAllocation(
        uint256 _genesisNodePercentage, 
        uint256 _tokenHolderPercentage, 
        uint256 _liquidityPoolPercentage, 
        uint256 _insurancePoolPercentage, 
        uint256 _marketSystemPercentage) external onlyOwner 
    {
        genesisNodePercentage = _genesisNodePercentage;
        tokenHolderPercentage = _tokenHolderPercentage;
        liquidityPoolPercentage = _liquidityPoolPercentage;
        insurancePoolPercentage = _insurancePoolPercentage;
        marketSystemPercentage = _marketSystemPercentage;

        emit SetPremiumAllocation(_genesisNodePercentage, tokenHolderPercentage, liquidityPoolPercentage, insurancePoolPercentage, marketSystemPercentage);
    }

    function setGameThreshold(uint256 _gameMinThreshold, uint256 _gameMaxThreshold) external onlyOwner {
        require(_gameMinThreshold > 0, "value must be larger than zero");
        require(_gameMaxThreshold > 0, "value must be larger than zero");

        gameMinThreshold = _gameMinThreshold;
        gameMaxThreshold = _gameMaxThreshold;

        emit SetGameThreshold(_gameMinThreshold, _gameMaxThreshold);
    }

    function setPremiumDistributionThreshold(uint256 _premiumDistributionThreshold) external onlyOwner {
        require(_premiumDistributionThreshold > 0, "value must be larger than zero");

        premiumDistributionThreshold = _premiumDistributionThreshold;

        emit SetPremiumDistributionThreshold(_premiumDistributionThreshold);
    }

    function setMaxRoundPerGame(uint256 _maxRoundPerGame) external onlyOwner {
        require(_maxRoundPerGame > 0, "value must be larger than zero");

        maxRoundPerGame = _maxRoundPerGame;

        emit SetMaxRoundPerGame(_maxRoundPerGame);
    }

    function setCooldownInterval(uint256 _cooldownInterval) external onlyOwner {
        cooldownInterval = _cooldownInterval;

        emit SetCooldownInterval(_cooldownInterval);
    }

    function setPremiumFee(uint256[] memory _premiumFeeList) external onlyOwner {
        require(_premiumFeeList.length != 0, "premiumFeeList length zero");
       
        for(uint i=0; i<_premiumFeeList.length; i++) {
            GameInfo storage _gameInfo = gameInfo[i];
            _gameInfo.premiumFee = _premiumFeeList[i];
        }

        emit SetPremiumFee(_premiumFeeList);
    }

    // ===================================================================
    // EVENTS
    // ===================================================================

    event JoinDefaultGame(address userAddress, uint256 amount);
    event ProcessDefaultGame(address userAddress, bool result, uint256 rewards);
    event RegisterHashGame(uint256 gid, bool premium, bool jackpot, address userAddress);
    event JoinLvgcGame(uint256 gid, address userAddress, uint256 currentGameRound, uint256 amount);
    event ProcessLvgcGame(uint256 gid, address userAddress, bool result, uint256 rewards);
    event JoinLvgrGame(uint256 gid, address userAddress, uint256 currentGameRound, uint256 amount);
    event ProcessLvgrGame(uint256 gid, address userAddress, bool result, uint256 rewards);
    event TriggerJackpot(address userAddress, bool isValidJackpot, bool isValidGrandJackpot, uint256 burstCount);
    event DistributeLvgrGameRewards(uint256 gid, address userAddress, uint256 usdtReward, uint256 lvgrReward);
    event DistributeUsdtRewards(address userAddress, uint256 amount);
    // Premium
    event PurchasePremium(uint256 gid, address userAddress, uint256 premiumFee);
    event DistributePremiumRewards(uint256 gid, address userAddress, uint256 amount);
    event VoidPremiumAndJackpot(address userAddress);

    event ResetLvgcGame(address userAddress);
    event ResetLvgrGame(address userAddress);
    event ResetUserLvgrBurstCount(uint256 gid, address userAddress);
    event RegisterGameInfo(uint256 premium, uint256 initialGameFee);
    event UpdateGameInfo(uint256 gid, uint256 premiumFee, uint256 initialGameFee);
    event DistributePremium(uint256 balance);
    event RescueToken(address token, address to, uint256 amount);

    // SETTERS
    event SetLvgcAddress(address newAddress);
    event SetLvgrAddress(address newAddress);
    event SetJackpotAddress(address newAddress);
    event SetTreasuryAddress(address newAddress);
    event SetOperator(address userAddress, bool _bool);
    event SetPremiumReimbursement(uint256[] premiumReimbursement);
    event SetPremiumReceiver(
        address genesisNodeReceiver, 
        address tokenHolderReceiver, 
        address liquidityPoolReceiver, 
        address insurancePoolReceiver, 
        address marketSystemReceiver);
    event SetPremiumAllocation(
        uint256 genesisNodePercentage, 
        uint256 tokenHolderPercentage, 
        uint256 liquidityPoolPercentage, 
        uint256 insurancePoolPercentage, 
        uint256 marketSystemPercentage);
    event SetGameThreshold(uint256 gameMinThreshold, uint256 gameMaxThreshold);
    event SetPremiumDistributionThreshold(uint256 premiumDistributionThreshold);
    event SetMaxRoundPerGame(uint256 maxRoundPerGame);
    event SetCooldownInterval(uint256 cooldownInterval);
    event SetPremiumFee(uint256[] _premiumFeeList);
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

interface I_Treasury {
    function withdraw(address _recipient, uint256 _amount) external;
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

interface I_LVGR {
    function mint(address, uint256) external;
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

interface I_Jackpot {
    function wonJackpot(address _userAddress) external view returns(bool);
    function wonGrandJackpot(address _userAddress) external view returns(bool);
    function isValidJackpot(address _userAddress) external view returns(bool);
    function isValidGrandJackpot(address _userAddress) external view returns(bool);

    function setWonJackpot(address _userAddress) external;
    function setWonGrandJackpot(address _userAddress) external;
    function getPurchaseGrandJackpotFlag(address _userAddress) external view returns(bool);
    function purchaseJackpot(uint256 _gid, address _userAddress) external;
    function voidJackpot(address _userAddress) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.0;

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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

abstract contract Initializable {

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
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
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
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
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
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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