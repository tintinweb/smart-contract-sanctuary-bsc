// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../contracts/interfaces/IGameToken.sol";
import "../contracts/interfaces/ITreasury.sol";

contract GT2HashGame is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public GT;
    IERC20Upgradeable public GT2;
    I_GameToken public IGT1;
    I_GameToken public IGT2;
    
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
    }

    struct UserPremiumInfo {
        bool premiumActive;
        uint256 purchasedTimestamp;
        uint256 claimedTimestamp;
        uint256 purchasedDay;
    }

    // Info of each game pool.
    GameInfo[] private gameInfo;
    mapping (address => UserGameInfo) public userGameInfo;
    mapping (address => UserPremiumInfo) public userPremiumInfo;
    mapping (address => bool) public blacklists;
    mapping (address => bool) public whitelists;
    uint256[] private premiumReimbursement;

    address private deadAddr;
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

    uint256 private gameMinThreshold;    
    uint256 private gameMaxThreshold;   
    uint256 private premiumDistributionThreshold;
    uint256 private maxRoundPerGame;
    uint256 private cooldownInterval;

    mapping (address => bool) private operator;
    uint256 private gameStartTime;

    I_Treasury public ITreasury;

    modifier onlyOperator {
        require(isOperator(msg.sender), "Only operator can perform this action");
        _;
    }

    function initialize(address _gt, address _gt1, address _gt2, address _deadAddr, 
        uint256 _gameMinThreshold, uint256 _gameMaxThreshold, uint256 _premiumDistributionThreshold, 
        uint256 _maxRoundPerGame, uint256 _cooldownInterval, uint256 _gameStartTime
    ) public initializer {

        GT = IERC20Upgradeable(_gt);
        IGT1 = I_GameToken(_gt1);
        GT2 = IERC20Upgradeable(_gt2);
        IGT2 = I_GameToken(_gt2);
        deadAddr = _deadAddr;

        gameMinThreshold = _gameMinThreshold;
        gameMaxThreshold = _gameMaxThreshold;
        premiumDistributionThreshold = _premiumDistributionThreshold;
        maxRoundPerGame = _maxRoundPerGame;
        cooldownInterval = _cooldownInterval;
        gameStartTime = _gameStartTime;

        // Set owner as operator
        operator[msg.sender] = true;

        __ReentrancyGuard_init();
        __Ownable_init();
    }

    function registerHashGame(uint256 _gid, bool _premium) external nonReentrant {
        UserGameInfo storage _userGameInfo = userGameInfo[msg.sender];

        require(!blacklists[msg.sender], "Blacklisted");
        require(!whitelists[msg.sender], "Whitelisted");
        require(_gid != 0, "Invalid game ID");
        require(isValidGameMode(_gid), "Invalid game mode");
        require(
            _userGameInfo.currentGameCheckpoint == _userGameInfo.currentGameRound, 
            "Processing previous game, please try again later"
        );

        // Reset user premium, if user change game mode
        if(_userGameInfo.gameMode != 0 && _userGameInfo.gameMode != _gid)
            voidPremium(msg.sender);

        // Reset and update user game info
        resetGame(msg.sender);
        _userGameInfo.gameMode = _gid;
        _userGameInfo.registerGameTimestamp = block.timestamp;

        if(_premium) {
            purchasePremium(msg.sender, _gid);
        }
   
        emit RegisterHashGame(msg.sender, _gid, _premium);
    }

    function joinGame() external nonReentrant {
        UserGameInfo storage _userInfo = userGameInfo[msg.sender];

        require(!blacklists[msg.sender], "Blacklisted");
        require(!whitelists[msg.sender], "Whitelisted");
        require(isValidPremium(msg.sender), "Require premium to play the game");
        require(_userInfo.gameMode != 0, "No game found, please register first");
        require(_userInfo.currentGameCheckpoint == _userInfo.currentGameRound, "Processing previous game, please try again later");
        
        uint256 _amount = getNextRoundFee(msg.sender);

        // Check balance
        uint256 _balance = GT2.balanceOf(msg.sender);
        require(_balance >= _amount, "Insufficient token");

        // Check allowance 
        uint256 _allowance = GT2.allowance(msg.sender, address(this));
        require(_allowance >= _amount, "Insufficient allowance");

        // Transfer fund
        GT2.safeTransferFrom(msg.sender, address(deadAddr), _amount);

        // Update user info
        _userInfo.gameActive = true;
        _userInfo.currentGameRound ++;
        _userInfo.currentGameRoundAmount = _amount;

        emit JoinGame(msg.sender, _userInfo.gameMode, _userInfo.currentGameRound, _amount);
    }

    function processGame(address _userAddress, bool _result) external nonReentrant onlyOperator {
        UserGameInfo storage _userInfo = userGameInfo[_userAddress];
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
            
            resetGame(_userAddress);
            distributeGameReward(_userInfo.gameMode, _userAddress, _rewards);
            
        } else if(_userInfo.currentGameRound == maxRoundPerGame && _userInfo.currentGameCheckpoint == maxRoundPerGame) {
            // Distribute premium rewards to user if user purchased premium and is valid
            if(isValidPremium(_userAddress)) 
                distributePremiumRewards(_userInfo.gameMode , _userAddress);

            // Reset user's game info if user lost the last round
            resetGame(_userAddress);
        } 

        emit ProcessGame(_userInfo.gameMode, _userAddress, _result, _rewards);
    }

    function purchasePremium(address _userAddress, uint256 _gid) internal {
        UserPremiumInfo storage _userPremiumInfo = userPremiumInfo[_userAddress];
        GameInfo storage _gameInfo = gameInfo[_gid];

        require(!isValidPremium(_userAddress), "Valid premium found, cannot purchase again");
        require(_userPremiumInfo.purchasedDay < getCurrentDay(), "Premium is in cooldown");

        // Check balance
        uint256 _balance = GT.balanceOf(_userAddress);
        require(_balance >= _gameInfo.premiumFee, "Insufficient GT");
        
        // Check allowance
        uint256 _allowance = GT.allowance(_userAddress, address(this));
        require(_allowance >= _gameInfo.premiumFee, "Insufficient allowance");

        // Transfer GT into the contract
        GT.safeTransferFrom(_userAddress, address(this), _gameInfo.premiumFee);

        // Update user info
        _userPremiumInfo.premiumActive = true;
        _userPremiumInfo.purchasedTimestamp = block.timestamp;
        _userPremiumInfo.claimedTimestamp = 0;
        _userPremiumInfo.purchasedDay = getCurrentDay();

        distributePremium();

        emit PurchasePremium(_userAddress, _gid, _gameInfo.premiumFee);
    }

    function distributePremium() internal {
        uint256 _balance = GT.balanceOf(address(this));

        if(_balance >= premiumDistributionThreshold) {
            GT.safeTransfer(genesisNodeReceiver, _balance * genesisNodePercentage / 100);
            GT.safeTransfer(tokenHolderReceiver, _balance * tokenHolderPercentage / 100);
            GT.safeTransfer(liquidityPoolReceiver, _balance * liquidityPoolPercentage / 100);
            GT.safeTransfer(insurancePoolReceiver, _balance * insurancePoolPercentage / 100);
            GT.safeTransfer(marketSystemReceiver, _balance * marketSystemPercentage / 100);
        }

        emit DistributePremium(_balance);
    }

    function distributePremiumRewards(uint256 _gameMode, address _userAddress) internal {
        uint256 _amount = getPremiumReimbursementByIndex(_gameMode);

        // Mint rewards to user, accoring to the premium plan
        IGT2.mint(_userAddress, _amount);
        
        emit DistributePremiumRewards(_gameMode, _userAddress, _amount);
    }

    function voidPremium(address _userAddress) internal {
        UserPremiumInfo storage _userPremiumInfo = userPremiumInfo[_userAddress];

        _userPremiumInfo.premiumActive = false;

        emit VoidPremium(_userAddress); 
    }

    function resetGame(address _userAddress) internal {
        UserGameInfo storage _userInfo = userGameInfo[_userAddress];

        _userInfo.gameActive = false;
        _userInfo.currentGameRound = 0;
        _userInfo.currentGameRoundAmount = 0;
        _userInfo.currentGameCheckpoint = 0;

        emit ResetGame(_userAddress);
    }

    function distributeGameReward(uint256 _gameMode, address _userAddress, uint256 _amount) internal {
        uint256 _mainReward = gameInfo[_gameMode].initialGameFee;
        uint256 _subReward = _amount - _mainReward;

        // Mint main reward 
        if(_mainReward > 0)
            ITreasury.withdraw(_userAddress, _mainReward);

        // Mint sub reward 
        if(_subReward > 0)
            IGT2.mint(_userAddress, _subReward);
        
        emit DistributeGameReward(_gameMode, _userAddress, _mainReward, _subReward);
    }

    function registerGameInfo(uint256 _premiumFee, uint256 _initialGameFee) external onlyOwner {
   
        gameInfo.push(GameInfo({
            premiumFee : _premiumFee,
            initialGameFee : _initialGameFee
        }));

        emit RegisterGameInfo(_premiumFee, _initialGameFee);
    }

    function updateGameInfo(uint256 _gid, uint256 _premiumFee, uint256 _initialGameFee) external onlyOwner {
        
        GameInfo storage _gameInfo = gameInfo[_gid];
        _gameInfo.premiumFee = _premiumFee;
        _gameInfo.initialGameFee = _initialGameFee;

        emit UpdateGameInfo(_gid, _premiumFee, _initialGameFee);
    }

    function rescueToken(address _token, address _to, uint256 _amount) external onlyOwner {
        uint256 _contractBalance = IERC20Upgradeable(_token).balanceOf(address(this));
        require(_amount <= _contractBalance, "Insufficient token");

        IERC20Upgradeable(_token).safeTransfer(_to, _amount);

        emit RescueToken(_token, _to, _amount);
    }

    // ===================================================================
    // GETTERS
    // ===================================================================

    function isOperator(address _userAddress) public view returns(bool) {
        return operator[_userAddress];
    }

    function isValidGameMode(uint256 _gid) internal view returns(bool) {
        if(_gid > 0 && _gid <= getGameInfoLength())
            return true;
        else    
            return false;
    }

    function isValidPremium(address _userAddress) public view returns(bool) {
        if(userPremiumInfo[_userAddress].premiumActive && 
            userPremiumInfo[_userAddress].purchasedDay == getCurrentDay()) {
            return true;
        } 
        return false;
    }

    function canPurchasePremium(address _userAddress) public view returns(bool) {
        if(userPremiumInfo[_userAddress].purchasedDay < getCurrentDay()) {
            return true;
        }

        return false;
    }

    function getNextRoundFee(address _userAddress) public view returns(uint256) {
        UserGameInfo storage _userInfo = userGameInfo[_userAddress];
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

    function getUserGameInfo(address _userAddress) external view returns(UserGameInfo memory) {
        return userGameInfo[_userAddress];
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

    function getGameStartTime() external view returns(uint256) {
        return gameStartTime;
    }

    function getCurrentDay() public view returns(uint256) {
        return ((block.timestamp - gameStartTime) / cooldownInterval) + 1;
    }
    
    // ===================================================================
    // SETTERS
    // ===================================================================
    function setGTAddress(address _newAddress) external onlyOwner {
        require(_newAddress != address(0), "Address zero");
        GT = IERC20Upgradeable(_newAddress);

        emit SetGTAddress(_newAddress);
    }

    function setGT1Address(address _newAddress) external onlyOwner {
        require(_newAddress != address(0), "Address zero");
        IGT1 = I_GameToken(_newAddress);

        emit SetGT1Address(_newAddress);
    }

    function setGT2Address(address _newAddress) external onlyOwner {
        require(_newAddress != address(0), "Address zero");
        IGT2 = I_GameToken(_newAddress);

        emit SetGT2Address(_newAddress);
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

    function setPremiumFee(uint256[] memory _premiumFeeList) external onlyOperator {
        require(_premiumFeeList.length != 0, "premiumFeeList length zero");
       
        for(uint i=0; i<_premiumFeeList.length; i++) {
            GameInfo storage _gameInfo = gameInfo[i];
            _gameInfo.premiumFee = _premiumFeeList[i];
        }

        emit SetPremiumFee(_premiumFeeList);
    }

    function setBlacklist(address[] memory _userAddress, bool _boolValue) external onlyOperator {
        require(_userAddress.length != 0, "_userAddress length zero");
       
        for(uint i=0; i<_userAddress.length; i++) {
            blacklists[_userAddress[i]] = _boolValue;
        }

        emit SetBlacklist(_userAddress, _boolValue);
    }

    function setWhitelist(address[] memory _userAddress, bool _boolValue) external onlyOperator {
        require(_userAddress.length != 0, "_userAddress length zero");
       
        for(uint i=0; i<_userAddress.length; i++) {
            whitelists[_userAddress[i]] = _boolValue;
        }

        emit SetWhitelist(_userAddress, _boolValue);
    }

    function setGameStartTime(uint256 _gameStartTime) external onlyOwner {
        gameStartTime = _gameStartTime;

        emit SetGameStartTime(_gameStartTime);
    }

    // ===================================================================
    // EVENTS
    // ===================================================================

    event RegisterHashGame(address userAddress, uint256 gid, bool premium);
    event JoinGame(address userAddress, uint256 gid, uint256 currentGameRound, uint256 amount);
    event ProcessGame(uint256 gid, address userAddress, bool result, uint256 rewards);

    // Premium
    event PurchasePremium(address userAddress, uint256 gid, uint256 premiumFee);
    event DistributePremiumRewards(uint256 gid, address userAddress, uint256 amount);
    event VoidPremium(address userAddress);
    event ResetGame(address userAddress);
    event DistributeGameReward(uint256 gid, address userAddress, uint256 mainReward, uint256 subReward);
    event RegisterGameInfo(uint256 _premiumFee, uint256 _initialGameFee);
    event UpdateGameInfo(uint256 gid, uint256 _premiumFee, uint256 initialGameFee);
    event DistributePremium(uint256 balance);
    event RescueToken(address token, address to, uint256 amount);

    // SETTERS
    event SetGTAddress(address newAddress);
    event SetGT1Address(address newAddress);
    event SetGT2Address(address newAddress);
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
    event SetPremiumFee(uint256[] premiumFeeList);
    event SetBlacklist(address[] userAddress, bool boolValue);
    event SetWhitelist(address[] userAddress, bool boolValue);
    event SetGameStartTime(uint256 gameStartTime);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

interface I_Treasury {
    function withdraw(address _recipient, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

interface I_GameToken {
    function mint(address, uint256) external;
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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