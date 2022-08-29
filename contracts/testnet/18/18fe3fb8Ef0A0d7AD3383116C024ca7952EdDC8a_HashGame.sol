//SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface I_MVCR {
    function mint(address, uint256) external;
}

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

contract HashGame is ReentrancyGuard {
    IERC20 public BUSD;
    IERC20 public MVCC;
    IERC20 public MVCR;
    I_MVCR public IMVCR;
    I_Jackpot public IJackpot;
    
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
    mapping (address => UserGameInfo) public userMvccGameInfo;
    mapping (address => UserGameInfo) public userMvcrGameInfo;
    mapping (address => UserPremiumInfo) public userPremiumInfo;
    uint256[] private premiumReimbursement;

    address private genesisNodeReceiver = 0xAb3817D9A2712412E00F731eDEb9c5332898d907;
    address private bonusReceiver = 0x2C80Cc48c4029d967061a5841C5B8687ee8e53c4;

    uint256 private genesisNodePercentage = 5;
    uint256 private bonusPercentage = 95;

    uint256 private defaultGameMinThreshold = 5 * (10 ** 18);    // Minimum threshold to join default game
    uint256 private defaultGameMaxThreshold = 100000 * (10 ** 18);   // Maximum threshold to join default game
    bool private inDistribution;
    uint256 private premiumDistributionThreshold = 1000 * (10 ** 18);
    uint256 private maxRoundPerGame = 6;
    uint256 private cooldownInterval = 300;

    mapping (address => bool) private operator;

    modifier onlyOperator {
        require(isOperator(msg.sender), "Only operator can perform this action");
        _;
    }

    constructor(address _busd, address _mvcc, address _mvcr) {
        BUSD = IERC20(_busd);
        MVCC = IERC20(_mvcc);
        MVCR = IERC20(_mvcr);
        IMVCR = I_MVCR(_mvcr);

        // Set owner as operator
        operator[msg.sender] = true;
    }

    function joinDefaultGame(uint256 _amount) external nonReentrant {
        UserGameInfo storage _userInfo = userDefaultGameInfo[msg.sender];

        require(!_userInfo.gameActive, "Processing previous game, please try again later");
        require(_amount >= defaultGameMinThreshold, "Below minimum threshold");
        require(_amount <= defaultGameMaxThreshold, "Exceeded maximum threshold");
        require(BUSD.balanceOf(msg.sender) >= _amount, "Insufficient BUSD");

        // Check allowance
        uint256 _allowance = BUSD.allowance(msg.sender, address(this));
        require(_allowance >= _amount, "Insufficient allowance");

        // Transfer BUSD into the contract
        bool status = BUSD.transferFrom(msg.sender, address(this), _amount);
        require(status, "Failed to transfer the fund. Please try again");

        // Update user info
        _userInfo.gameActive = true;
        _userInfo.currentGameRoundAmount = _amount;

        emit JoinDefaultGame(msg.sender, _amount);
    }

    function processDefaultGame(address _userAddress, bool _result) external onlyOperator {
        UserGameInfo storage _userInfo = userDefaultGameInfo[_userAddress];
        require(_userInfo.gameActive, "No active game found");

        uint256 _rewards = 0;
        if(_result) {
            _rewards = _userInfo.currentGameRoundAmount * 2;
            require(BUSD.balanceOf(address(this)) >= _rewards, "Insufficient BUSD in contract");
        }            
            
        // Update user info
        _userInfo.gameActive = false;
        _userInfo.currentGameRoundAmount = 0;

        // Distribute rewards to user if _result is true
        if(_result) {
            BUSD.transfer(_userAddress, _rewards);
        }

        emit ProcessDefaultGame(_userAddress, _result, _rewards);
    }

    function registerHashGame(uint256 _gid, bool _premium, bool _jackpot) external nonReentrant {
        UserGameInfo storage _userMvccGameInfo = userMvccGameInfo[msg.sender];
        UserGameInfo storage _userMvcrGameInfo = userMvcrGameInfo[msg.sender];

        require(_gid != 0, "Invalid game ID");
        require(isValidGameMode(_gid), "Invalid game mode");
        require(!_userMvccGameInfo.gameActive, "Cannot register when MVCC game is still active");
        require(!_userMvcrGameInfo.gameActive, "Cannot register when MVCR game is still active");

        // check whether any pending claim jackpot & grand jackpot
        bool _wonJackpot = IJackpot.wonJackpot(msg.sender);
        bool _wonGrandJackpot = IJackpot.wonGrandJackpot(msg.sender);

        require(!_wonGrandJackpot, "Please claim your grand jackpot");
        require(!_wonJackpot, "Please claim your jackpot");

        // Reset and update user Mvcc game info
        resetMvccGame(msg.sender);
        _userMvccGameInfo.gameMode = _gid;
        _userMvccGameInfo.registerGameTimestamp = block.timestamp;
        _userMvccGameInfo.consecutiveBurstCount = 0;

        // Reset and update user Mvcr game info
        resetMvcrGame(msg.sender);
        _userMvcrGameInfo.gameMode = _gid;
        _userMvcrGameInfo.registerGameTimestamp = block.timestamp;
        _userMvcrGameInfo.consecutiveBurstCount = 0;

        // Reset user premium and jackpot
        voidPremiumAndJackpot(msg.sender);

        if(_premium) {
            purchasePremium(_gid, msg.sender);
        }
            
        if(_jackpot) {
            IJackpot.purchaseJackpot(_gid, msg.sender);
        }
            
        emit RegisterHashGame(_gid, _premium, _jackpot, msg.sender);
    }

    function joinMvccGame(uint256 _amount) external nonReentrant {
        UserGameInfo storage _userInfo = userMvccGameInfo[msg.sender];
        require(_userInfo.gameMode != 0, "No game found, please register first");
        require(_userInfo.currentGameCheckpoint == _userInfo.currentGameRound, "Processing previous game, please try again later");
        require(BUSD.balanceOf(msg.sender) >= _amount, "Insufficient BUSD");

        // Check allowance
        uint256 _allowance = BUSD.allowance(msg.sender, address(this));
        require(_allowance >= _amount, "Insufficient allowance");

        // Transfer BUSD into the contract
        bool status = BUSD.transferFrom(msg.sender, address(this), _amount);
        require(status, "Failed to transfer the fund. Please try again");

        // Trick play
        if(_amount != getMvccNextRoundFee(msg.sender)) {
            voidPremiumAndJackpot(msg.sender);
        }

        // Update user info
        _userInfo.gameActive = true;
        _userInfo.currentGameRound ++;
        _userInfo.currentGameRoundAmount = _amount;

        emit JoinMvccGame(_userInfo.gameMode, msg.sender, _userInfo.currentGameRound, _amount);
    }

    function processMvccGame(address _userAddress, bool _result) external onlyOperator {
        UserGameInfo storage _userInfo = userMvccGameInfo[_userAddress];
        require(_userInfo.gameActive, "No active game found");
        require(_userInfo.currentGameRound > _userInfo.currentGameCheckpoint, "No new game round to process");

        // Increment the checkpoint
        _userInfo.currentGameCheckpoint ++;
        uint256 _rewards = 0;

        if(_result) {    
            // Distribute rewards + invested amount, and reset user's game info if user won    
            require(BUSD.balanceOf(address(this)) >= _userInfo.currentGameRoundAmount * 2, "Insufficient BUSD in contract");
            _rewards = _userInfo.currentGameRoundAmount * 2;

            // Set premium to false when user won
            if(userPremiumInfo[_userAddress].premiumActive) {
                UserPremiumInfo storage _userPremiumInfo = userPremiumInfo[_userAddress];
                _userPremiumInfo.premiumActive = false;
                _userPremiumInfo.claimedTimestamp = block.timestamp;
            }
            
            // Reset game 
            resetMvccGame(_userAddress);

            // Distribute rewards to user
            BUSD.transfer(_userAddress, _rewards);
            
        } else if(_userInfo.currentGameRound == maxRoundPerGame && _userInfo.currentGameCheckpoint == maxRoundPerGame) {
            // Distribute premium rewards to user if user purchased premium and is valid
            if(isValidPremium(_userAddress)) 
                distributePremiumRewards(_userInfo.gameMode , _userAddress);

            // Reset user's game info if user lost the last round
            resetMvccGame(_userAddress);
        } 

        emit ProcessMvccGame(_userInfo.gameMode, _userAddress, _result, _rewards);
    }

    function joinMvcrGame(uint256 _amount) external nonReentrant {
        UserGameInfo storage _userInfo = userMvcrGameInfo[msg.sender];
        require(_userInfo.gameMode != 0, "No game found, please register first");
        require(isValidGameMode(_userInfo.gameMode), "No valid game found, failed to join game");
        require(_userInfo.currentGameCheckpoint == _userInfo.currentGameRound, "Processing previous game, please try again later");
        require(MVCR.balanceOf(msg.sender) >= _amount, "Insufficient MVCR");

        // Validate whether user won any jackpot
        validateUserJackpot(msg.sender);

        // Check allowance
        uint256 _allowance = MVCR.allowance(msg.sender, address(this));
        require(_allowance >= _amount, "Insufficient allowance");

        // Transfer MVCR into the contract
        bool status = MVCR.transferFrom(msg.sender, address(this), _amount);
        require(status, "Failed to transfer the fund. Please try again");

        // Trick play
        if(_amount != getMvcrNextRoundFee(msg.sender)) {
            voidPremiumAndJackpot(msg.sender);
        }

        // Update user info
        _userInfo.gameActive = true;
        _userInfo.currentGameRound ++;
        _userInfo.currentGameRoundAmount = _amount;

        emit JoinMvcrGame(_userInfo.gameMode, msg.sender, _userInfo.currentGameRound, _amount);
    }

    function processMvcrGame(address _userAddress, bool _result) external onlyOperator {
        UserGameInfo storage _userInfo = userMvcrGameInfo[_userAddress];
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
            resetMvcrGame(_userAddress);

            // Transfer rewards to user
            distributeMvcrGameRewards(_userInfo.gameMode, _userAddress, _rewards);

            // Reset user's burst count
            _userInfo.consecutiveBurstCount = 0;
            
        } else if(_userInfo.currentGameRound == maxRoundPerGame && _userInfo.currentGameCheckpoint == maxRoundPerGame) {
            
            // Mint MVCR & BUSD to user everytime they burst
            if(isValidPremium(_userAddress)) 
                distributePremiumRewards(_userInfo.gameMode, _userAddress);

            // Reset user's game info 
            resetMvcrGame(_userAddress);

            // Increment user's burst count
            _userInfo.consecutiveBurstCount++;

            triggerJackpot(_userAddress);
        } 

        emit ProcessMvcrGame(_userInfo.gameMode, _userAddress, _result, _rewards);
    }

    function triggerJackpot(address _userAddress) internal {
        bool _isValidJackpot = IJackpot.isValidJackpot(_userAddress);
        bool _isValidGrandJackpot = IJackpot.isValidGrandJackpot(_userAddress);

        if(_isValidJackpot && userMvcrGameInfo[_userAddress].consecutiveBurstCount == 1) {
            IJackpot.setWonJackpot(_userAddress);
        } else if(_isValidGrandJackpot && userMvcrGameInfo[_userAddress].consecutiveBurstCount == 2) {
            IJackpot.setWonGrandJackpot(_userAddress);
        }
    }

    function distributeMvcrGameRewards(uint256 _gameMode, address _userAddress, uint256 _amount) internal nonReentrant {
        uint256 _busdRewards = gameInfo[_gameMode].initialGameFee;
        uint256 _mvcrRewards = (_amount * 2) - _busdRewards;

        require(BUSD.balanceOf(address(this)) >= _busdRewards, "Insufficient BUSD in contract");

        // Transfer BUSD rewards
        BUSD.transfer(_userAddress, _busdRewards);

        // Mint MVCR rewards 
        if(_mvcrRewards > 0)
            IMVCR.mint(_userAddress, _mvcrRewards);
        
        emit DistributeMvcrGameRewards(_gameMode, _userAddress, _busdRewards, _mvcrRewards);
    }

    function purchasePremium(uint256 _gid, address _userAddress) internal {
        UserPremiumInfo storage _userPremiumInfo = userPremiumInfo[_userAddress];
        GameInfo storage _gameInfo = gameInfo[_gid];

        require(!isValidPremium(_userAddress), "Valid premium found, cannot purchase again");
        require(_userPremiumInfo.purchasedTimestamp + cooldownInterval <= block.timestamp, "Premium is in cooldown");
        require(MVCC.balanceOf(_userAddress) >= _gameInfo.premiumFee, "Insufficient MVCC");

        // Check allowance
        uint256 _allowance = MVCC.allowance(_userAddress, address(this));
        require(_allowance >= _gameInfo.premiumFee, "Insufficient allowance");

        // Transfer MVCC into the contract
        bool _status = MVCC.transferFrom(_userAddress, address(this), _gameInfo.premiumFee);
        require(_status, "Failed to transfer the fund. Please try again");

        // Update user info
        _userPremiumInfo.premiumActive = true;
        _userPremiumInfo.purchasedTimestamp = block.timestamp;
        _userPremiumInfo.claimedTimestamp = 0;

        distributePremium();

        emit PurchasePremium(_gid, _userAddress, _gameInfo.premiumFee);
    }

    function distributePremium() internal {
        uint256 _balance = MVCC.balanceOf(address(this));

        if(_balance >= premiumDistributionThreshold) {
            MVCC.transfer(genesisNodeReceiver, _balance * genesisNodePercentage / 100);
            MVCC.transfer(bonusReceiver, _balance * bonusPercentage / 100);
        }

        emit DistributePremium(_balance);
    }

    function distributePremiumRewards(uint256 _gameMode, address _userAddress) internal nonReentrant {
        uint256 _amount = getPremiumReimbursementByIndex(_gameMode);

        // Mint MVCR rewards to user, accoring to the premium plan
        IMVCR.mint(_userAddress, _amount);
        
        emit DistributePremiumRewards(_gameMode, _userAddress, _amount);
    }

    function voidPremiumAndJackpot(address _userAddress) internal {
        UserPremiumInfo storage _userPremiumInfo = userPremiumInfo[_userAddress];

        _userPremiumInfo.premiumActive = false;
        IJackpot.voidJackpot(_userAddress);

        emit VoidPremiumAndJackpot(_userAddress); 
    }

    function resetMvccGame(address _userAddress) internal {
        UserGameInfo storage _userInfo = userMvccGameInfo[_userAddress];

        _userInfo.gameActive = false;
        _userInfo.currentGameRound = 0;
        _userInfo.currentGameRoundAmount = 0;
        _userInfo.currentGameCheckpoint = 0;

        emit ResetMvccGame(_userAddress);
    }

    function resetMvcrGame(address _userAddress) internal {
        UserGameInfo storage _userInfo = userMvcrGameInfo[_userAddress];

        _userInfo.gameActive = false;
        _userInfo.currentGameRound = 0;
        _userInfo.currentGameRoundAmount = 0;
        _userInfo.currentGameCheckpoint = 0;

        emit ResetMvcrGame(_userAddress);
    }

    function resetUserMvcrBurstCount(address _userAddress) external onlyOperator {
        UserGameInfo storage _userInfo = userMvcrGameInfo[_userAddress];
        _userInfo.consecutiveBurstCount = 0;

        emit ResetUserMvcrBurstCount(_userInfo.gameMode, _userAddress);
    }

    function registerGameInfo(uint256 _premium, uint256 _initialGameFee) external onlyOperator {
   
        gameInfo.push(GameInfo({
            premiumFee : _premium,
            initialGameFee : _initialGameFee
        }));

        emit RegisterGameInfo(_premium, _initialGameFee);
    }

    function updateGameInfo(uint256 _gid, uint256 _premiumFee, uint256 _initialGameFee) external onlyOperator {
        
        GameInfo storage _gameInfo = gameInfo[_gid];
        _gameInfo.premiumFee = _premiumFee;
        _gameInfo.initialGameFee = _initialGameFee;

        emit UpdateGameInfo(_gid, _premiumFee, _initialGameFee);
    }

    function rescueToken(address _token, address _to, uint256 _amount) external onlyOperator {
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

    function getMvccNextRoundFee(address _userAddress) public view returns(uint256) {
        UserGameInfo storage _userInfo = userMvccGameInfo[_userAddress];
        GameInfo storage _gameInfo = gameInfo[_userInfo.gameMode];

        uint256 _amount = _gameInfo.initialGameFee;
        for(uint i=0; i<_userInfo.currentGameRound; i++) {
            _amount = _amount * 2;
        }

        return _amount;
    }

    function getMvcrNextRoundFee(address _userAddress) public view returns(uint256) {
        UserGameInfo storage _userInfo = userMvcrGameInfo[_userAddress];
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

    function getUserMvccGameInfo(address _userAddress) external view returns(UserGameInfo memory) {
        return userMvccGameInfo[_userAddress];
    }

    function getUserMvcrGameInfo(address _userAddress) external view returns(UserGameInfo memory) {
        return userMvcrGameInfo[_userAddress];
    }

    function getPremiumReimbursement() external view returns(uint256[] memory) {
        return premiumReimbursement;
    }

    function getPremiumReimbursementByIndex(uint256 _index) public view returns(uint256) {
        return premiumReimbursement[_index];
    }

    function getGenesisNodeReceiver() external view returns(address) {
        return genesisNodeReceiver;
    }

    function getBonusReceiver() external view returns(address) {
        return bonusReceiver;
    }

    function getGenesisNodePercentage() external view returns(uint256) {
        return genesisNodePercentage;
    }

    function getBonusPercentage() external view returns(uint256) {
        return bonusPercentage;
    }

    function getDefaultGameMinThreshold() external view returns(uint256) {
        return defaultGameMinThreshold;
    }

    function getDefaultGameMaxThreshold() external view returns(uint256) {
        return defaultGameMaxThreshold;
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
    function isUserMvcrGameActive(address _userAddress) external view returns(bool) {
        return userMvcrGameInfo[_userAddress].gameActive;
    }

    function getUserMvcrBurstCount(address _userAddress) external view returns(uint256) {
        return userMvcrGameInfo[_userAddress].consecutiveBurstCount;
    }
    
    // ===================================================================
    // SETTERS
    // ===================================================================
    function setMvccAddress(address _newAddress) external onlyOperator {
        require(_newAddress != address(0), "Address zero");
        MVCC = IERC20(_newAddress);

        emit SetMvccAddress(_newAddress);
    }

    function setMvcrAddress(address _newAddress) external onlyOperator {
        require(_newAddress != address(0), "Address zero");
        MVCR = IERC20(_newAddress);
        IMVCR = I_MVCR(_newAddress);

        emit SetMvcrAddress(_newAddress);
    }

    function setJackpotAddress(address _newAddress) external onlyOperator {
        require(_newAddress != address(0), "Address zero");
        IJackpot = I_Jackpot(_newAddress);
        operator[_newAddress] = true;

        emit SetJackpotAddress(_newAddress);
    }

    function setOperator(address _userAddress, bool _bool) external onlyOperator {
        require(_userAddress != address(0), "Address zero");
        operator[_userAddress] = _bool;

        emit SetOperator(_userAddress, _bool);
    }

    function setPremiumReimbursement(uint256[] memory _premiumReimbursement) external onlyOperator {
        require(_premiumReimbursement.length > 0, "Empty array");
        premiumReimbursement = _premiumReimbursement;

        emit SetPremiumReimbursement(_premiumReimbursement);
    }

    function setGenesisNodeReceiver(address _newAddress) external onlyOperator {
        require(_newAddress != address(0), "Address zero");
        genesisNodeReceiver = _newAddress;

        emit SetGenesisNodeReceiver(_newAddress);
    }

    function setBonusReceiver(address _newAddress) external onlyOperator {
        require(_newAddress != address(0), "Address zero");
        bonusReceiver = _newAddress;

        emit SetBonusReceiver(_newAddress);
    }

    function setPremiumAllocation(uint256 _genesisNodePercentage, uint256 _bonusPercentage) external onlyOperator {
        genesisNodePercentage = _genesisNodePercentage;
        bonusPercentage = _bonusPercentage;

        emit SetPremiumAllocation(_genesisNodePercentage, _bonusPercentage);
    }

    function setDefaultGameThreshold(uint256 _defaultGameMinThreshold, uint256 _defaultGameMaxThreshold) external onlyOperator {
        require(_defaultGameMinThreshold > 0, "value must be larger than zero");
        require(_defaultGameMaxThreshold > 0, "value must be larger than zero");

        defaultGameMinThreshold = _defaultGameMinThreshold;
        defaultGameMaxThreshold = _defaultGameMaxThreshold;

        emit SetDefaultGameThreshold(_defaultGameMinThreshold, _defaultGameMaxThreshold);
    }

    function setPremiumDistributionThreshold(uint256 _premiumDistributionThreshold) external onlyOperator {
        require(_premiumDistributionThreshold > 0, "value must be larger than zero");

        premiumDistributionThreshold = _premiumDistributionThreshold;

        emit SetPremiumDistributionThreshold(_premiumDistributionThreshold);
    }

    function setMaxRoundPerGame(uint256 _maxRoundPerGame) external onlyOperator {
        require(_maxRoundPerGame > 0, "value must be larger than zero");

        maxRoundPerGame = _maxRoundPerGame;

        emit SetMaxRoundPerGame(_maxRoundPerGame);
    }

    function setCooldownInterval(uint256 _cooldownInterval) external onlyOperator {
        cooldownInterval = _cooldownInterval;

        emit SetCooldownInterval(_cooldownInterval);
    }

    // ===================================================================
    // EVENTS
    // ===================================================================

    event JoinDefaultGame(address userAddress, uint256 amount);
    event ProcessDefaultGame(address userAddress, bool result, uint256 rewards);
    event RegisterHashGame(uint256 gid, bool premium, bool jackpot, address userAddress);
    event JoinMvccGame(uint256 gid, address userAddress, uint256 currentGameRound, uint256 amount);
    event ProcessMvccGame(uint256 gid, address userAddress, bool result, uint256 rewards);
    event JoinMvcrGame(uint256 gid, address userAddress, uint256 currentGameRound, uint256 amount);
    event ProcessMvcrGame(uint256 gid, address userAddress, bool result, uint256 rewards);
    event DistributeMvcrGameRewards(uint256 gid, address userAddress, uint256 busdReward, uint256 mvcrReward);

    // Premium
    event PurchasePremium(uint256 gid, address userAddress, uint256 premiumFee);
    event DistributePremiumRewards(uint256 gid, address userAddress, uint256 amount);
    event VoidPremiumAndJackpot(address userAddress);

    event ResetMvccGame(address userAddress);
    event ResetMvcrGame(address userAddress);
    event ResetUserMvcrBurstCount(uint256 gid, address userAddress);
    event RegisterGameInfo(uint256 premium, uint256 initialGameFee);
    event UpdateGameInfo(uint256 gid, uint256 premiumFee, uint256 initialGameFee);
    event DistributePremium(uint256 balance);
    event RescueToken(address token, address to, uint256 amount);

    // SETTERS
    event SetMvccAddress(address newAddress);
    event SetMvcrAddress(address newAddress);
    event SetJackpotAddress(address newAddress);
    event SetOperator(address userAddress, bool _bool);
    event SetPremiumReimbursement(uint256[] premiumReimbursement);
    event SetGenesisNodeReceiver(address newAddress);
    event SetBonusReceiver(address newAddress);
    event SetPremiumAllocation(uint256 genesisNodePercentage, uint256 bonusPercentage);
    event SetDefaultGameThreshold(uint256 defaultGameMinThreshold, uint256 defaultGameMaxThreshold);
    event SetPremiumDistributionThreshold(uint256 premiumDistributionThreshold);
    event SetMaxRoundPerGame(uint256 maxRoundPerGame);
    event SetCooldownInterval(uint256 cooldownInterval);
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}