//SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMVCR {
    function mint(address, uint256) external;
}

contract MVCCHashGame  {
    IERC20 public BUSD;
    IERC20 public MVCC;
    IMVCR public MVCR;
    
    struct GameInfo {
        uint256 premiumFee;
        bool paused;
    }
    // Info of each game pool.
    GameInfo[] private gameInfo;

    struct UserInfo {
        bool gameActive;
        uint256 premiumPurchasedTimestamp;
        uint256 currentGameRound;
        uint256 currentGameAmount;
        bool currentGameChecked;
        uint256 joinGameTimestamp;
        uint256 endGameTimestamp;
    }
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) private userInfo;

    address private marketPoolReceiver = 0x2Db849Ae3bf7A2A60f44C76A52c452bC5804641C;
    address private insurancePoolReceiver = 0x5155375D129170dadeC12385aaA47eaCd4A32716;
    address private superNodeReceiver = 0x32e5C6766Dff390a992DbF31d236EAAA3202E933;
    address private liquidityPoolReceiver = 0xA0c0CF8e9eD2E268185a1A4Cd46d542f90Eb03d9;
    address private mvccBonusReceiver = 0x853ded7A72F12EBdEF27F065201c223529a941bf;

    uint256 private marketPoolPercentage = 60;
    uint256 private insurancePoolPercentage = 30;
    uint256 private superNodePercentage = 5;
    uint256 private liquidityPoolPercentage = 3;
    uint256 private mvccBonusPercentage = 2;

    uint256 private defaultGameMinThreshold = 5 * (10 ** 18);    // Minimum threshold to join default game
    uint256 private defaultGameMaxThreshold = 100000 * (10 ** 18);   // Maximum threshold to join default game
    bool private inDistribution;
    uint256 private premiumDistributionThreshold = 1000 * (10 ** 18);
    uint256 private maxRoundPerGame = 6;


    mapping (address => bool) internal operator;

    modifier lockTheDistribution {
        inDistribution = true;
        _;
        inDistribution = false;
    }

    modifier onlyOperator {
        require(isOperator(msg.sender), "Only operator can perform this action");
        _;
    }

    constructor(address _busd, address _mvcc, address _mvcr) {
        BUSD = IERC20(_busd);
        MVCC = IERC20(_mvcc);
        MVCR = IMVCR(_mvcr);

        // Add default game
        gameInfo.push(GameInfo({
            premiumFee : 0,
            paused : false
        }));

        operator[msg.sender] = true;
    }

    function joinDefaultGame(uint256 _amount) external {
        GameInfo storage _gameInfo = gameInfo[0];
        UserInfo storage _userInfo = userInfo[0][msg.sender];

        require(!_gameInfo.paused, "Contract paused, please try again later");
        require(!_userInfo.gameActive, "Game started, please wait until the game ends");
        require(_amount >= defaultGameMinThreshold, "Below minimum threshold");
        require(_amount <= defaultGameMaxThreshold, "Exceeded maximum threshold");
        require(BUSD.balanceOf(msg.sender) >= _amount, "Insufficient BUSD");

        bool status = BUSD.transferFrom(msg.sender, address(this), _amount);
        require(status, "Failed to transfer the fund. Please try again");

        // Update user info
        _userInfo.gameActive = true;
        _userInfo.currentGameRound = 0;
        _userInfo.currentGameAmount = _amount;
        _userInfo.joinGameTimestamp= block.timestamp;
        _userInfo.endGameTimestamp = 0;

        emit JoinDefaultGame(msg.sender, _amount);
    }

    function processDefaultGame(address _userAddress, bool _result) external onlyOperator {
        UserInfo storage _userInfo = userInfo[0][_userAddress];

        require(_userInfo.gameActive, "No active game found");
        if(_result)            
            require(BUSD.balanceOf(address(this)) >= _userInfo.currentGameAmount * 2, "Insufficient BUSD in contract");

        // Update user info
        _userInfo.gameActive = false;
        _userInfo.endGameTimestamp= block.timestamp;

        // Distribute rewards to user if _result is true
        if(_result) {
            BUSD.transfer(_userAddress, _userInfo.currentGameAmount * 2);
        }

        emit ProcessDefaultGame(_userAddress, _result);
    }

    function joinGame(uint256 _gid) external {
        GameInfo storage _gameInfo = gameInfo[_gid];
        UserInfo storage _userInfo = userInfo[_gid][msg.sender];

        require(!_gameInfo.paused, "Contract paused, please try again later");
        require(_userInfo.currentGameChecked, "Processing previous game, please try again later");
        require(_userInfo.currentGameRound < maxRoundPerGame, "Exceeded max round per game");

        uint256 _amount = getNextRoundFee(_gid, msg.sender);
        require(BUSD.balanceOf(msg.sender) >= _amount, "Insufficient BUSD");

        bool status = BUSD.transferFrom(msg.sender, address(this), _amount);
        require(status, "Failed to transfer the fund. Please try again");

        // Update user info
        _userInfo.gameActive = true;
        _userInfo.currentGameRound += 1;
        _userInfo.currentGameAmount += _amount;
        _userInfo.currentGameChecked = false;
        _userInfo.joinGameTimestamp= block.timestamp;
        _userInfo.endGameTimestamp = 0;

        emit JoinGame(_gid);
    }

    function processGame(uint256 _gid, address _userAddress, bool _result) external onlyOperator {
        UserInfo storage _userInfo = userInfo[_gid][_userAddress];
        require(_userInfo.gameActive, "No active game found");

        // Distribute rewards to user if _result is true
        if(_result) {         
            require(BUSD.balanceOf(address(this)) >= _userInfo.currentGameAmount * 2, "Insufficient BUSD in contract");
            
            // Update user info
            _userInfo.gameActive = false;
            _userInfo.endGameTimestamp= block.timestamp;
            BUSD.transfer(_userAddress, _userInfo.currentGameAmount * 2);
        }
        _userInfo.currentGameChecked = true;

        emit ProcessGame(_gid, _userAddress, _result);
    }

    function purchasePremium(uint256 _gid) external {
        GameInfo storage _gameInfo = gameInfo[_gid];
        UserInfo storage _userInfo = userInfo[_gid][msg.sender];

        require(_gid != 0, "Invalid GID, no premium for this game");
        require(!_gameInfo.paused, "Contract paused, please try again later");
        require(!isPremiumValid(_gid, msg.sender), "Premium already purchased before");
        require(!_userInfo.gameActive, "Cannot purchase premium when game started");
        require(MVCC.balanceOf(msg.sender) >= _gameInfo.premiumFee, "Insufficient MVCC");

        // Transfer the fund into the contract
        bool status = IERC20(MVCC).transferFrom(msg.sender, address(this), _gameInfo.premiumFee);
        require(status, "Failed to transfer the fund. Please try again");

        // Update user info
        _userInfo.premiumPurchasedTimestamp = block.timestamp;

        distributePremium();

        emit PurchasePremium(_gid);
    }

    function distributePremium() internal lockTheDistribution {
        uint256 _balance = MVCC.balanceOf(address(this));

        if(_balance >= premiumDistributionThreshold) {
            MVCC.transfer(marketPoolReceiver, _balance * marketPoolPercentage / 100);
            MVCC.transfer(insurancePoolReceiver, _balance * insurancePoolPercentage / 100);
            MVCC.transfer(superNodeReceiver, _balance * superNodePercentage / 100);
            MVCC.transfer(liquidityPoolReceiver, _balance * liquidityPoolPercentage / 100);
            MVCC.transfer(mvccBonusReceiver, _balance * mvccBonusPercentage / 100);
        }

        emit DistributePremium(_balance);
    }

    function distributePremiumRewards(uint256 _gid, address _userAddress, uint256 _amount) external onlyOperator {
        UserInfo storage _userInfo = userInfo[_gid][msg.sender];
        require(_gid != 0, "Invalid GID, no premium for this game");
        require(isPremiumValid(_gid, msg.sender), "No valid premium found");

        _userInfo.premiumPurchasedTimestamp = 0;
        
        MVCR.mint(_userAddress, _amount);

        emit DistributePremiumRewards(_gid, _userAddress, _amount);
    }

    function isPremiumValid(uint256 _gid, address _userAddress) public view returns(bool) {
        UserInfo storage _userInfo = userInfo[_gid][_userAddress];

        if(_userInfo.premiumPurchasedTimestamp < block.timestamp + 1 days)
            return true;
        
        return false;
    }

    // register a game. Can only be called by the owner.
    function registerGame(uint256 _premium) public onlyOperator {
   
        gameInfo.push(GameInfo({
            premiumFee : _premium,
            paused : false
        }));

        emit RegisterGame(_premium);
    }

    function updateGameInfo(uint256 _gid, uint256 _premiumFee) external onlyOperator {
        
        GameInfo storage _gameInfo = gameInfo[_gid];
        _gameInfo.premiumFee = _premiumFee;

        emit UpdateGameInfo(_gid, _premiumFee);
    }

    function pauseGame(uint256 _gid, bool _bool) external onlyOperator {
        GameInfo storage _gameInfo = gameInfo[_gid];
        _gameInfo.paused = _bool;

        emit PauseGame(_gid, _bool);
    }

    function isOperator(address _userAddress) public view returns(bool) {
        return operator[_userAddress];
    }

    function rescueToken(address _token, address _to) external onlyOperator {
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(_to, _contractBalance);

        emit RescueToken(_token, _to);
    }

    // ===================================================================
    // GETTERS
    // ===================================================================
    function getNextRoundFee(uint256 _gid, address _userAddress) public view returns(uint256) {
        GameInfo storage _gameInfo = gameInfo[_gid];
        UserInfo storage _userInfo = userInfo[_gid][_userAddress];

        uint256 _amount = _gameInfo.premiumFee;
        for(uint i=0; i<_userInfo.currentGameRound; i++) {
            _amount = _amount * 2;
        }

        return _amount;
    }

    function getGameInfo(uint256 _gid) external view returns(GameInfo memory) {
        return gameInfo[_gid];
    }

    function getGamePoolLength() external view returns(uint256) {
        return gameInfo.length;
    }

    function getUserInfo(uint256 _gid, address _userAddress) external view returns(UserInfo memory) {
        return userInfo[_gid][_userAddress];
    }

    function getMarketPoolReceiver() external view returns(address) {
        return marketPoolReceiver;
    }

    function getInsurancePoolReceiver() external view returns(address) {
        return insurancePoolReceiver;
    }

    function getSuperNodeReceiver() external view returns(address) {
        return superNodeReceiver;
    }

    function getLiquidityPoolReceiver() external view returns(address) {
        return liquidityPoolReceiver;
    }

    function getMvccBonusReceiver() external view returns(address) {
        return mvccBonusReceiver;
    }

    function getMarketPoolPercentage() external view returns(uint256) {
        return marketPoolPercentage;
    }

    function getInsurancePoolPercentage() external view returns(uint256) {
        return insurancePoolPercentage;
    }

    function getSuperNodePercentage() external view returns(uint256) {
        return superNodePercentage;
    }

    function getLiquidityPoolPercentage() external view returns(uint256) {
        return liquidityPoolPercentage;
    }

    function getMvccBonusPercentage() external view returns(uint256) {
        return mvccBonusPercentage;
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
    
    // ===================================================================
    // SETTERS
    // ===================================================================
    function setMVCC(address _newAddress) external onlyOperator {
        require(_newAddress != address(0), "Address zero");
        MVCC = IERC20(_newAddress);

        emit SetMVCC(_newAddress);
    }

    function setMVCR(address _newAddress) external onlyOperator {
        require(_newAddress != address(0), "Address zero");
        MVCR = IMVCR(_newAddress);

        emit SetMVCR(_newAddress);
    }

    function setOperator(address _userAddress, bool _bool) external {
        require(_userAddress != address(0), "Address zero");
        operator[_userAddress] = _bool;

        emit SetOperator(_userAddress, _bool);
    }

    function setMarketPoolReceiver(address _newAddress) external onlyOperator {
        require(_newAddress != address(0), "Address zero");
        marketPoolReceiver = _newAddress;
    }

    function setInsurancePoolReceiver(address _newAddress) external onlyOperator {
        require(_newAddress != address(0), "Address zero");
        insurancePoolReceiver = _newAddress;
    }

    function setSuperNodeReceiver(address _newAddress) external onlyOperator {
        require(_newAddress != address(0), "Address zero");
        superNodeReceiver = _newAddress;
    }

    function setLiquidityPoolReceiver(address _newAddress) external onlyOperator {
        require(_newAddress != address(0), "Address zero");
        liquidityPoolReceiver = _newAddress;
    }

    function setMvccBonusReceiver(address _newAddress) external onlyOperator {
        require(_newAddress != address(0), "Address zero");
        mvccBonusReceiver = _newAddress;
    }

    function setPremiumAllocation(
        uint256 _marketPoolPercentage, 
        uint256 _insurancePoolPercentage,
        uint256 _superNodePercentage,
        uint256 _liquidityPoolPercentage,
        uint256 _mvccBonusPercentage
    ) external onlyOperator {
        uint256 totalPercentage = _marketPoolPercentage + _insurancePoolPercentage + _superNodePercentage + _liquidityPoolPercentage + _mvccBonusPercentage;
        require(totalPercentage == 100, "Total percentage must be 100");

        marketPoolPercentage = _marketPoolPercentage;
        insurancePoolPercentage = _marketPoolPercentage;
        superNodePercentage = _superNodePercentage;
        liquidityPoolPercentage = _liquidityPoolPercentage;
        mvccBonusPercentage = _mvccBonusPercentage;

        emit SetPremiumAllocation(_marketPoolPercentage, _insurancePoolPercentage, _superNodePercentage, _liquidityPoolPercentage, _mvccBonusPercentage);
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

    event JoinDefaultGame(address _address, uint256 _amount);
    event ProcessDefaultGame(address _userAddress, bool _result);
    event JoinGame(uint256 _gid);
    event ProcessGame(uint256 _gid, address _userAddress, bool _result);
    event PurchasePremium(uint256 _gid);
    event DistributePremiumRewards(uint256 _gid, address _userAddress, uint256 _amount);

    event RegisterGame(uint256 _premium);
    event UpdateGameInfo(uint256 _gid, uint256 _premiumFee);
    event PauseGame(uint256 _gid, bool _bool);
    event DistributePremium(uint256 _balance);
    event RescueToken(address _token, address _to);

    // SETTERS
    event SetMVCC(address _newAddress);
    event SetMVCR(address _newAddress);
    event SetOperator(address _userAddress, bool _bool);
    event SetMarketPoolReceiver(address _newAddress);
    event SetInsurancePoolReceiver(address _newAddress);
    event SetSuperNodeReceiver(address _newAddress);
    event SetLiquidityPoolReceiver(address _newAddress);
    event SetMvccBonusReceiver(address _newAddress);
    event SetPremiumAllocation(
        uint256 _marketPoolPercentage, 
        uint256 _insurancePoolPercentage,
        uint256 _superNodePercentage,
        uint256 _liquidityPoolPercentage,
        uint256 _mvccBonusPercentage
    );
    event SetDefaultGameThreshold(uint256 _defaultGameMinThreshold, uint256 _defaultGameMaxThreshold);
    event SetPremiumDistributionThreshold(uint256 _premiumDistributionThreshold);
    event SetMaxRoundPerGame(uint256 _maxRoundPerGame);
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