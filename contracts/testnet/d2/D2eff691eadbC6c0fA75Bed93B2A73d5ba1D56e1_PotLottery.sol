// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '../interfaces/IPancakePair.sol';
import '../interfaces/IPancakeFactory.sol';
import '../interfaces/IPancakeRouter.sol';
import '../interfaces/IPRC20.sol';
import '../interfaces/IBNBP.sol';

// File: PotContract.sol

contract PotLottery is ReentrancyGuard {
    /*
     ***Start of function, Enum, Variables, array and mappings to set and edit the Pot State such that accounts can enter the pot
     */

    struct Token {
        address tokenAddress;
        bool swapToBNB;
        bool isStable;
        string tokenSymbol;
        uint256 tokenDecimal;
    }

    enum POT_STATE {
        WAITING,
        STARTED,
        LIVE,
        CALCULATING_WINNER
    }

    address public owner;
    address public admin;

    // This is for bnb testnet
    address public wbnbAddr;
    address public busdAddr;
    address public pancakeswapV2FactoryAddr;
    IPancakeRouter02 public router;

    POT_STATE public pot_state;

    mapping(string => Token) public tokenWhiteList;
    string[] public tokenWhiteListNames;
    uint256 public minEntranceInUsd;
    uint256 public potCount;
    uint256 public potDuration;
    uint256 public percentageFee;
    uint256 public PotEntryCount;
    uint256 public entriesCount;
    address public BNBP_Address;
    uint256 public BNBP_Standard;

    mapping(string => uint256) public tokenLatestPriceFeed;

    uint256 public potLiveTime;
    uint256 public potStartTime;
    uint256 public timeBeforeRefund;
    // uint256 public participantCount;
    // address[] public participants;
    // string[] public tokensInPotNames;
    address[] public entriesAddress;
    // uint256[] public entriesUsdValue;
    string[] public entriesTokenName;
    uint256[] public entriesTokenAmount;
    address public LAST_POT_WINNER;

    // Tokenomics
    uint256 public airdropInterval;
    uint256 public burnInterval;
    uint256 public lotteryInterval;

    uint8 public airdropPercentage;
    uint8 public burnPercentage;
    uint8 public lotteryPercentage;

    uint256 public airdropPool;
    uint256 public burnPool;
    uint256 public lotteryPool;

    uint256 public stakingMinimum;
    uint256 public minimumStakingTime;

    string[] public adminFeeToken;
    mapping(string => uint256) public adminFeeTokenValues;

    // mapping(string => uint256) public tokenTotalEntry;

    address hotWalletAddress;
    uint256 hotWalletMinBalance;
    uint256 hotWalletMaxBalance;

    constructor(address _owner) {
        owner = _owner;
        admin = _owner;
        pot_state = POT_STATE.WAITING;
        potDuration = 300; // 5 minutes
        minEntranceInUsd = 9000000000; //9900000000 cents ~ 1$
        percentageFee = 3;
        potCount = 1;
        timeBeforeRefund = 900; //24 hours
        PotEntryCount = 0;
        entriesCount = 0;

        // Need to change
        airdropInterval = 86400*2;
        burnInterval = 86400;
        lotteryInterval = 86400;

        airdropPercentage = 75;
        burnPercentage = 20;
        lotteryPercentage = 5;

        stakingMinimum = 5 * 10**18; // 5 BNBP
        minimumStakingTime = 100 * 24 * 36; // 100 days

        wbnbAddr = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
        busdAddr = 0xe6A72B05F26e7B12Fc2A0C1f991550B1ec0bF4C1;
        pancakeswapV2FactoryAddr = 0x6725F303b657a9451d8BA641348b6761A6CC7a17;
        router = IPancakeRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

        BNBP_Address = 0x102C5422932D8C8C372Cf7cDae9E713184Ef34db;
        BNBP_Standard = 100;
        hotWalletAddress = 0xCf076007E6C36cFB1eb2cD36AD66405feC7d0B31;
        hotWalletMinBalance = 10**18;
        hotWalletMaxBalance = 2*10**18;
        addToken("BUSD","BUSD",0xe6A72B05F26e7B12Fc2A0C1f991550B1ec0bF4C1,true,true,18);
        addToken("BNB","BNB",0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd,false,false,18);
        addToken("BNBP","BNBP",0x102C5422932D8C8C372Cf7cDae9E713184Ef34db,true,false,18);
        addToken("Cake","CAKE",0x5Ce516480a1A9554eC617a0B1F3460848427EaAD,true,false,18);
        addToken("Cardano Token","ADA",0xDeDCF53473f6497D877FA1Fc5C852028c5C57d6A,true,false,18);
        UpdatePrice();

    }

    modifier onlyAdmin() {
        require(msg.sender == admin || msg.sender == owner, '!admin');
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, '!owner');
        _;
    }

    modifier validBNBP() {
        require(BNBP_Address != address(0), '!BNBP Addr');
        _;
    }

    //-----I added a new event
    event BalanceNotEnough(address indexed userAddress, string tokenName);

    event EnteredPot(
        string tokenName, //
        address indexed userAddress, //
        uint256 indexed potRound,
        uint256 usdValue,
        uint256 amount,
        uint256 indexed enteryCount, //
        bool hasEntryInCurrentPot
    );

    event CalculateWinner(
        address indexed winner,
        uint256 indexed potRound,
        uint256 potValue,
        uint256 amount,
        uint256 amountWon,
        uint256 participants
    );

    event TokenSwapFailedString(string tokenName, string reason);
    event TokenSwapFailedBytes(string tokenName, bytes reason);
    event BurnSuccess(uint256 amount);
    event AirdropSuccess(uint256 amount);
    event LotterySuccess(address indexed winner);
    event HotWalletSupplied(address addr, uint256 amount);

    /**   @dev returns the usd value of a token amount
     * @param _tokenName the name of the token
     * @param _amount the amount of the token
     * @return usdValue usd value of the token amount
     */
    function getTokenUsdValue(string memory _tokenName, uint256 _amount) public view returns (uint256) {
        return ((tokenLatestPriceFeed[_tokenName] * _amount) / 10**tokenWhiteList[_tokenName].tokenDecimal);
    }

    /**   @dev attempt to transfer token from user address to contract address
     * @param _tokenName the name of the token
     * @param _userAddress the user address
     * @param _amount the token amount to transfer
     * @return success status of the TransferFrom call
     */
    function attemptTransferFrom(
        string memory _tokenName,
        address _userAddress,
        uint256 _amount
    ) public returns (bool) {
        try IPRC20(tokenWhiteList[_tokenName].tokenAddress).transferFrom(_userAddress, address(this), _amount) returns (
            bool
        ) {
            return true;
        } catch (
            bytes memory 
        ) {
            return false;
        }
    }

    /**   @dev changes contract owner address
     * @param _owner the new owner
     * @notice only the owner can call this function
     */
    function changeOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    /**   @dev changes contract admin address
     * @param _adminAddress the new admin
     * @notice only the owner can call this function
     */
    function changeAdmin(address _adminAddress) public onlyOwner {
        admin = _adminAddress;
    }

    /**   @dev set the BNBP address
     * @param _address the BNBP address
     * @notice only the admin or owner can call this function
     */
    function setBNBPAddress(address _address) public onlyAdmin {
        BNBP_Address = _address;
    }

    /**   @dev set the BNBP minimum balance to get 50% reduction in fee
     * @param _amount the BNBP minimum balance for 50% reduction in fee
     * @notice only the admin or owner can call this function
     */
    function setBNBP_Standard(uint256 _amount) public onlyAdmin {
        BNBP_Standard = _amount;
    }

    /**   @dev add token to list of white listed token
     * @param _tokenName the name of the token
     * @param _tokenSymbol the symbol of the token
     * @param _tokenAddress the address of the token
     * @param _decimal the token decimal
     * @notice only the admin or owner can call this function
     */
    function addToken(
        string memory _tokenName,
        string memory _tokenSymbol,
        address _tokenAddress,
        bool _swapToBNB,
        bool _isStable,
        uint256 _decimal
    ) public onlyAdmin {
        require(_tokenAddress != address(0), "0x");
        if (tokenWhiteList[_tokenName].tokenAddress == address(0)) {
            tokenWhiteListNames.push(_tokenName);
        }
        tokenWhiteList[_tokenName] = Token(_tokenAddress, _swapToBNB, _isStable, _tokenSymbol, _decimal);
        if(_isStable){
             updateTokenUsdValue(_tokenName, 10**10) ;
        }
    }

    /**   @dev remove token from the list of white listed token
     * @param _tokenName the name of the token
     * @notice only the admin or owner can call this function
     */
    function removeToken(string memory _tokenName) public onlyAdmin {
        for (uint256 index = 0; index < tokenWhiteListNames.length; index++) {
            if (keccak256(bytes(_tokenName)) == keccak256(bytes(tokenWhiteListNames[index]))) {
                delete tokenWhiteList[_tokenName];
                delete tokenLatestPriceFeed[_tokenName];
                tokenWhiteListNames[index] = tokenWhiteListNames[tokenWhiteListNames.length - 1];
                tokenWhiteListNames.pop();
            }
        }
    }

    /**   @dev set token usd value
     * @param _tokenName the name of the token
     * @param _valueInUsd the usd value to set token price to
     * @notice set BNBP price to 30usd when price is below 30usd on dex
     * @notice add extra 10% to price of BNBP when price above 30usd on dex
     */
    function updateTokenUsdValue(string memory _tokenName, uint256 _valueInUsd) internal {
        for (uint256 index = 0; index < tokenWhiteListNames.length; index++) {
            if (keccak256(bytes(tokenWhiteListNames[index])) == keccak256(bytes(_tokenName))) {
                if (keccak256(bytes(_tokenName)) == keccak256(bytes('BNBP'))) {
                    tokenLatestPriceFeed[_tokenName] = _valueInUsd < 30 * 10**10 ? 30 * 10**10 : (_valueInUsd * 11) / 10;
                } else {
                    tokenLatestPriceFeed[_tokenName] = _valueInUsd;
                }
            }
        }
    }

    /**
        @optimized modifier removed
    */
    // modifier tokenInWhiteList(string memory _tokenName) {
    //     bool istokenWhiteListed = false;
    //     for (uint256 index = 0; index < tokenWhiteListNames.length; index++) {
    //         if (keccak256(bytes(tokenWhiteListNames[index])) == keccak256(bytes(_tokenName))) {
    //             istokenWhiteListed = true;
    //         }
    //     }
    //     require(istokenWhiteListed, '!supp');
    //     _;
    // }

    /**   @dev Attempts to enter pot with an array of values
     * @param _tokenNames an array of token names to enter pot with
     * @param _amounts an array of token amount to enter pot with
     * @param _participants an array of participant address to enter pot with
     * @notice attempts to calculate winner firstly if pot duration is over
     * @notice only callable by the admin or owner account
     * @notice entry will not be allowed if contract token balance is not enough or entry is less than minimum usd value
     * @notice entry with native token is not allowed
     */
    ///This is the Centralized enterPot function
    function EnterPot(
        string[] memory _tokenNames,
        uint256[] memory _amounts,
        address[] memory _participants
    ) public onlyAdmin {
        for (uint256 index = 0; index < _tokenNames.length; index++) {
            if ((keccak256(bytes(_tokenNames[index])) == keccak256(bytes('BNB'))) || (getTokenUsdValue(_tokenNames[index], _amounts[index]) < minEntranceInUsd)) {
                continue;
            }
            if (
                IPRC20(tokenWhiteList[(_tokenNames[index])].tokenAddress).balanceOf(address(this)) <
                (_amounts[index] + adminFeeTokenValues[_tokenNames[index]]) + tokenTotalEntry(_tokenNames[index])
            ) {
                emit BalanceNotEnough(_participants[index], _tokenNames[index]);
                continue;
            }
            _EnterPot(_tokenNames[index], _amounts[index], _participants[index]);
        }
    }

    /**   @dev Attempts to enter pot with an array of values
     * @param _tokenNames an array of token names to enter pot with
     * @param _amounts an array of token amount to enter pot with
     * @param _participants an array of participant address to enter pot with
     * @notice attempts to calculate winner firstly if pot duration is over
     * @notice publicly callable by any address
     * @notice entry will not be allowed if approved value is less than _amounts or entry is less than minimum usd value
     * @notice entry with native token is not allowed
     */
    ///This is the Decentralized enterPot function
    function enterPot(
        string  memory _tokenName,
        uint256  _amount,
        address  _participant
    ) external {
        require((keccak256(bytes(_tokenName)) != keccak256(bytes('BNB'))), "BNB");
        require((getTokenUsdValue(_tokenName, _amount) >= minEntranceInUsd), "< min");
        require(attemptTransferFrom(_tokenName, _participant, _amount), "approve !enough");
        _EnterPot(_tokenName, _amount, _participant);
    }

    /**   @dev Attempts to enter a single pot entry
     * @param _tokenName token name to enter pot with
     * @param _amount token amount to enter pot with
     * @param _participant participant address to enter pot with
     */
    function _EnterPot(
        string memory _tokenName,
        uint256 _amount,
        address _participant
    ) internal {
        uint256 _participantCount = participantCount() ;
        if ((potLiveTime + potDuration) <= block.timestamp && (_participantCount > 1) && (potStartTime != 0)) {
            calculateWinner();
        }
        if (_participantCount == 1 && keccak256(bytes(_tokenName)) != keccak256(bytes('BNB'))) {
            UpdatePrice();
        }

        entriesAddress.push(_participant);
        entriesTokenName.push(_tokenName);
        entriesTokenAmount.push(_amount);

        if (_participantCount == 2 && pot_state != POT_STATE.LIVE) {
            potLiveTime = block.timestamp;
            pot_state = POT_STATE.LIVE;
        }
        
        if (PotEntryCount == 0) {
            pot_state = POT_STATE.STARTED;
            potStartTime = block.timestamp;
        }
        PotEntryCount++;
        entriesCount++;
        uint256 _participantsTotalEntryInUsd = participantsTotalEntryInUsd(_participant);
        emit EnteredPot(
            _tokenName,
            _participant,
            potCount,
            getTokenUsdValue(_tokenName, _amount),
            _amount,
            entriesCount,
            _participantsTotalEntryInUsd == 0
        );
    }

    /**   @dev Attempts to calculate pot round winner
     */
    function calculateWinner() public nonReentrant {
        uint256 _participantCount = participantCount() ;
        uint256 _totalPotUsdValue = totalPotUsdValue() ;

        if ((potLiveTime + potDuration) <= block.timestamp && (_participantCount > 1) && (potStartTime != 0)) {
            address pot_winner = determineWinner();
            uint256 _participantsTotalEntryInUsd = participantsTotalEntryInUsd(pot_winner) ;
                bool tokenInFee = false;
                for (uint256 index = 0; index < adminFeeToken.length; index++) {
                    if (keccak256(bytes(getPotTokenWithHighestValue())) == keccak256(bytes(adminFeeToken[index]))) {
                        tokenInFee = true;
                    }
                }
                if (!tokenInFee) {
                    adminFeeToken.push(getPotTokenWithHighestValue());
                }
                adminFeeTokenValues[getPotTokenWithHighestValue()] += getAmountToPayAsFees(pot_winner);
                if (keccak256(bytes(getPotTokenWithHighestValue())) == keccak256(bytes('BNBP'))) {
                    _distributeToTokenomicsPools(getAmountToPayAsFees(pot_winner));
                }
                string[100] memory tokensInPotNames_ = tokensInPotNames(); 
                for (uint256 index = 0; index < tokensInPotNamesLength(); index++) {
                    _payAccount(tokensInPotNames_[index], pot_winner,(keccak256(bytes(getPotTokenWithHighestValue())) == keccak256(bytes(tokensInPotNames_[index]))) ? tokenTotalEntry(tokensInPotNames_[index]) - getAmountToPayAsFees(pot_winner): tokenTotalEntry(tokensInPotNames_[index]));
                } //Transfer all required tokens to the Pot winner
            LAST_POT_WINNER = pot_winner;

            emit CalculateWinner(
                pot_winner,
                potCount,
                _totalPotUsdValue,
                _participantsTotalEntryInUsd,
                (_totalPotUsdValue * (100 - percentageFee)) / 100,
                _participantCount
            );
            startNewPot();
            //Start the new Pot and set calculating winner to true
            //After winner has been sent the token then set calculating winner to false
        }
    }

    /**   @dev Attempts to select a random winner
     */
    function determineWinner() internal view returns (address winner) {
        uint256 _totalPotUsdValue = totalPotUsdValue() ;
        int256 winning_point = int256(fullFillRandomness() % _totalPotUsdValue);
        for (uint256 index = 0; index < PotEntryCount; index++) {
            winning_point -= int256(getTokenUsdValue(entriesTokenName[index], entriesTokenAmount[index]));
            if (winning_point <= 0) {
                //That means that the winner has been found here
                winner = entriesAddress[index];
                return winner;
            }
        }
    }

        /** @dev returns the totalUsd value of an address in the latest pot
            @return usdValue commulative usd value of a particular address in current pot
        */
        function participantsTotalEntryInUsd(address _address) public view returns (uint256 usdValue){
            usdValue = 0;
            for (uint256 index = 0; index < PotEntryCount; index++) {
                if (_address == entriesAddress[index]) {
                usdValue += getTokenUsdValue(entriesTokenName[index], entriesTokenAmount[index]) ;
                }
            }
        }
        function totalPotUsdValue() public view returns (uint256 totalUsd){
            totalUsd = 0;
            for (uint256 index = 0; index < PotEntryCount; index++) {
                totalUsd += getTokenUsdValue(entriesTokenName[index], entriesTokenAmount[index]) ;
            }
        }

        function tokensInPotNames() public view returns (string[100] memory tokens){
            bool tokensPresent ;
            for (uint256 index = 0; index < entriesTokenName.length; index++) {
                tokensPresent = false;
                for (uint256 index2 = 0; index2 < tokens.length; index2++) {
                    if ((keccak256(bytes(entriesTokenName[index])) == keccak256(bytes(tokens[index2])))) {
                        tokensPresent = true;
                    }
                }
                if (!tokensPresent) {
                    tokens[index] = (entriesTokenName[index]) ;
                }
            }
            return tokens ;
        }

        function tokensInPotNamesLength() public view returns (uint256){
            uint256 _length;
            string[100] memory tokens = tokensInPotNames() ;
            for (uint256 index = 0; index < 100; index++) {
                if(bytes(tokens[index]).length > 0){
                    _length++ ;
                }else{
                    break;
                }
            }
            return _length;
        }

        function participants() public view returns (address[100] memory _address){
            for (uint256 index = 0; index < entriesAddress.length; index++) {
                bool addressPresent = false;
                for (uint256 index2 = 0; index2 < _address.length; index2++) {
                    if (entriesAddress[index] == _address[index2] ) {
                        addressPresent = true;
                    }
                }
                if (!addressPresent) {
                    _address[index] = (entriesAddress[index]) ;
                }
            }
            return _address;
        }

        
        function participantCount() public view returns (uint256){
            address[100] memory _address ;
            uint256 _length;
            for (uint256 index = 0; index < entriesAddress.length; index++) {
                bool addressPresent = false;
                for (uint256 index2 = 0; index2 < _address.length; index2++) {
                    if (entriesAddress[index] == _address[index2] ) {
                        addressPresent = true;
                    }
                }
                if (!addressPresent) {
                    _address[index] = (entriesAddress[index]) ;
                    _length++ ;
                }
            }
            return _length;
        }

        /** @dev returns a particular token amount in pot
            @return tokenValue the amount on a particular token in pot
        */
        function tokenTotalEntry(string memory _tokenName) public view returns (uint256 tokenValue){
            tokenValue = 0;
            for (uint256 index = 0; index < PotEntryCount; index++) {
                if (keccak256(bytes(_tokenName)) == keccak256(bytes(entriesTokenName[index]))) {
                    tokenValue += entriesTokenAmount[index] ;
                }
            }
        }

        /**   @dev returns the token name with the highest usd value in pot
            @return tokenWithHighestValue price is only updated when there are no participant in pot
        */
        function getPotTokenWithHighestValue() internal view returns (string memory tokenWithHighestValue) {
            string[100] memory tokensInPotNames_ = tokensInPotNames(); 
            tokenWithHighestValue = tokensInPotNames_[0];
            for (uint256 index = 0; index < tokensInPotNamesLength() - 1; index++) {
                if (
                    tokenTotalEntry(tokensInPotNames_[index + 1]) * tokenLatestPriceFeed[tokensInPotNames_[index + 1]] >=
                    tokenTotalEntry(tokensInPotNames_[index]) * tokenLatestPriceFeed[tokensInPotNames_[index]]
                ) {
                    tokenWithHighestValue = tokensInPotNames_[index + 1];
                }
            }
        }

    /**   @dev process a refund for user if there is just one participant for 24 hrs
     */
    function getRefund() public nonReentrant {
        uint256 _participantCount = participantCount() ;
        if (timeBeforeRefund + potStartTime < block.timestamp && _participantCount == 1 && (potStartTime != 0)) {

                bool tokenInFee = false;
                for (uint256 index = 0; index < adminFeeToken.length; index++) {
                    if (keccak256(bytes(getPotTokenWithHighestValue())) == keccak256(bytes(adminFeeToken[index]))) {
                        tokenInFee = true;
                    }
                }
                if (!tokenInFee) {
                    adminFeeToken.push(getPotTokenWithHighestValue());
                }
                adminFeeTokenValues[getPotTokenWithHighestValue()] += getAmountToPayAsFees(entriesAddress[0]);
                if (keccak256(bytes(getPotTokenWithHighestValue())) == keccak256(bytes('BNBP'))) {
                    _distributeToTokenomicsPools(getAmountToPayAsFees(entriesAddress[0]));
                }
                string[100] memory tokensInPotNames_ = tokensInPotNames(); 
                for (uint256 index = 0; index < tokensInPotNamesLength(); index++) {
                    _payAccount(tokensInPotNames_[index], entriesAddress[0],(keccak256(bytes(getPotTokenWithHighestValue())) == keccak256(bytes(tokensInPotNames_[index]))) ? tokenTotalEntry(tokensInPotNames_[index]) - getAmountToPayAsFees(entriesAddress[0]): tokenTotalEntry(tokensInPotNames_[index]));
                }
                startNewPot();
        }
    }



    // /** @optimized function was removed
    //  * @param _tokenName the name of the token to remove the fee from
    //  * @param _value the amount to remove as fee
    //  */
    // function deductAmountToPayAsFees(string memory _tokenName, uint256 _value) internal {
    //     bool tokenInFee = false;
    //     for (uint256 index = 0; index < adminFeeToken.length; index++) {
    //         if (keccak256(bytes(_tokenName)) == keccak256(bytes(adminFeeToken[index]))) {
    //             tokenInFee = true;
    //         }
    //     }
    //     if (!tokenInFee) {
    //         adminFeeToken.push(_tokenName);
    //     }
    //     adminFeeTokenValues[_tokenName] += _value;
    //     if (keccak256(bytes(_tokenName)) == keccak256(bytes('BNBP'))) {
    //         _distributeToTokenomicsPools(_value);
    //     }
    // }

    /**   @dev remove the amount to pay as fee
     * @param _address the name of the token to remove the fee from
     * @return amountToPay the amount to remove as fee
     * @notice _address current BNBP holding determine how much fee reduction you get
     */
    function getAmountToPayAsFees(address _address) internal view returns (uint256 amountToPay) {
        uint256 _totalPotUsdValue = totalPotUsdValue() ;
        uint256 baseFee = (
            (percentageFee * _totalPotUsdValue * 10**tokenWhiteList[getPotTokenWithHighestValue()].tokenDecimal) /
                (100 * tokenLatestPriceFeed[getPotTokenWithHighestValue()]) >=
                tokenTotalEntry(getPotTokenWithHighestValue())
                ? tokenTotalEntry(getPotTokenWithHighestValue())
                : (percentageFee * _totalPotUsdValue * 10**tokenWhiteList[getPotTokenWithHighestValue()].tokenDecimal) /
                    (100 * tokenLatestPriceFeed[getPotTokenWithHighestValue()])
        );
        amountToPay = ((IPRC20(BNBP_Address).balanceOf(_address) / BNBP_Standard) >= 1)
            ? baseFee / 2
            : (baseFee - ((IPRC20(BNBP_Address).balanceOf(_address) / BNBP_Standard) * baseFee) / 2);
    }

    /**   @dev attempt to update token price from dex
          @notice price is only updated when there are no participant in pot
    */
    function UpdatePrice() public nonReentrant {
        uint256 _participantCount = participantCount() ;
        if (_participantCount == 1 || true ) {
            for (uint256 index = 0; index < tokenWhiteListNames.length; index++) {
                if(tokenWhiteList[tokenWhiteListNames[index]].isStable){
                    continue ;
                }
                (uint256 Res0, uint256 Res1) = _getTokenReserves(
                    tokenWhiteList[tokenWhiteListNames[index]].tokenAddress,
                    busdAddr
                );
                if (Res0 == 0 && Res1 == 0) {
                    (Res0, Res1) = _getTokenReserves(tokenWhiteList[tokenWhiteListNames[index]].tokenAddress, wbnbAddr);
                    uint256 res1 = Res1 * (10**tokenWhiteList[tokenWhiteListNames[index]].tokenDecimal);
                    uint256 price = res1 / Res0;
                    updateTokenUsdValue(
                        tokenWhiteListNames[index],
                        ((price * 10**10) * getBNBPrice()) /
                            10**(tokenWhiteList['BNB'].tokenDecimal + tokenWhiteList['BUSD'].tokenDecimal)
                    );
                } else {
                    uint256 res1 = Res1 * (10**tokenWhiteList[tokenWhiteListNames[index]].tokenDecimal);
                    uint256 price = res1 / Res0;
                    updateTokenUsdValue(
                        tokenWhiteListNames[index],
                        (price * 10**10) / 10**tokenWhiteList['BUSD'].tokenDecimal
                    );
                }
            }
            updateTokenUsdValue('BUSD', 10**10);
        }
    }

    /**
     * @dev gets token reserves for given token pair
     */
    function _getTokenReserves(address token0, address token1) internal view returns (uint256, uint256) {
        IPancakePair pair = IPancakePair(IPancakeFactory(pancakeswapV2FactoryAddr).getPair(token0, token1));

        if (address(pair) == address(0)) {
            return (0, 0);
        }

        (uint256 Res0, uint256 Res1, ) = pair.getReserves();
        if (token0 == pair.token0()) {
            return (Res0, Res1);
        }
        return (Res1, Res0);
    }

    /**   @dev reset the pot round
          @notice should be removed on launch on bsc
    */
    function resetPot() public onlyAdmin {
        startNewPot();
    }

    /**   @dev reset pot state to start a new round
     */
    function startNewPot() internal {
        //@optimize
        // for (uint256 index1 = 0; index1 < tokensInPotNames.length; index1++) {
        //     delete tokenTotalEntry[tokensInPotNames[index1]];
        // }
        //@optimize
        // delete participants;
        // delete participantCount;
        // delete tokensInPotNames;

        // @optimize
        // delete entriesAddress;
        // delete entriesUsdValue;
        delete PotEntryCount;

        
        delete entriesAddress;
        delete entriesTokenName;
        delete entriesTokenAmount;

        pot_state = POT_STATE.WAITING;//might not be needed
        delete potLiveTime;//we dont need to delete this
        delete potStartTime;//we dont need to delete this
        potCount++;
    }

    /**   @dev pays a specify address the specified token
          @param _tokenName name of the token to send
          @param _accountToPay address of the account to send token to
          @param _tokenValue the token value to send
    */
    function _payAccount(
        string memory _tokenName,
        address _accountToPay,
        uint256 _tokenValue
    ) internal returns(bool paid){
        if (_tokenValue <= 0) return paid;
        if (keccak256(bytes(_tokenName)) == keccak256(bytes('BNB'))) {
          paid = payable(_accountToPay).send(_tokenValue);
        } else {
          paid = IPRC20(tokenWhiteList[_tokenName].tokenAddress).transfer(_accountToPay, _tokenValue);
        }
    }

    /**   @dev generates a random number
     */
    function fullFillRandomness() public view returns (uint256) {
        return uint256(uint128(bytes16(keccak256(abi.encodePacked(getBNBPrice(), block.difficulty, block.timestamp)))));
    }

    /** @optimized
     * @dev add new particiant to particiants list, optimzing gas fee
     */
    // function _addToParticipants(address participant) internal {
    //     if (participantCount() == participants.length) {
    //         participants.push(participant);
    //     } else {
    //         participants[participantCount()] = participant;
    //     }
    //     participantCount++;
    // }

    /**
     * @dev Gets current BNB price in comparison with BNB and USDT
     */
    function getBNBPrice() public view returns (uint256 price) {
        (uint256 Res0, uint256 Res1) = _getTokenReserves(wbnbAddr, busdAddr);
        uint256 res1 = Res1 * (10**IPRC20(wbnbAddr).decimals());
        price = res1 / Res0;
    }

/**
     * @dev Swaps accumulated fees into BNB, or BUSD first, and then to BNBP
     */
    function swapAccumulatedFees() external validBNBP nonReentrant {
        require(tokenWhiteListNames.length > 0, 'whitelisted = 0');

        // Swap each token to BNB
        for (uint256 i = 0; i < adminFeeToken.length; i++) {
            string storage tokenName = adminFeeToken[i];
            Token storage tokenInfo = tokenWhiteList[tokenName];
            ERC20 token = ERC20(tokenInfo.tokenAddress);
            uint256 balance = adminFeeTokenValues[tokenName];
            address[] memory path;

            if (keccak256(bytes(tokenName)) == keccak256(bytes('BNB'))) continue;
            if (tokenInfo.tokenAddress == BNBP_Address) continue;

            if (balance > 0) {
                token.approve(address(router), balance);

                if (tokenInfo.swapToBNB) {
                    path = new address[](2);
                    path[0] = tokenInfo.tokenAddress;
                    path[1] = router.WETH();
                } else {
                    path = new address[](3);
                    path[0] = tokenInfo.tokenAddress;
                    path[1] = busdAddr;
                    path[2] = router.WETH();
                }

                try router.swapExactTokensForETH(balance, 0, path, address(this), block.timestamp) returns (
                    uint256[] memory swappedAmounts
                ) {
                    adminFeeTokenValues[tokenName] -= swappedAmounts[0];
                    adminFeeTokenValues['BNB'] += swappedAmounts[path.length - 1];
                } catch Error(string memory reason) {
                    emit TokenSwapFailedString(tokenName, reason);
                } catch (bytes memory reason) {
                    emit TokenSwapFailedBytes(tokenName, reason);
                }
            }
        }

        // Swap converted BNB to BNBP
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = BNBP_Address;
        uint256 BNBFee = adminFeeTokenValues['BNB'];
        uint256 hotWalletFee;

        if (hotWalletAddress != address(0)) {
            uint256 hotWalletBalance = hotWalletAddress.balance;
            if (hotWalletBalance <= hotWalletMinBalance) {
                hotWalletFee = hotWalletMaxBalance - hotWalletBalance;
                if (hotWalletFee > (BNBFee * 8) / 10) {
                    hotWalletFee = (BNBFee * 8) / 10;
                }
            }
            bool sent = payable(hotWalletAddress).send(hotWalletFee);
            if (!sent) {
                hotWalletFee = 0;
            } else {
                emit HotWalletSupplied(hotWalletAddress, hotWalletFee);
            }
        }

        if (adminFeeTokenValues['BNB'] > 0) {
            path[0] = router.WETH();
            uint256[] memory bnbSwapAmounts = router.swapExactETHForTokens{ value: BNBFee - hotWalletFee }(
                0,
                path,
                address(this),
                block.timestamp
            );
            adminFeeTokenValues['BNB'] -= (bnbSwapAmounts[0] + hotWalletFee);
            adminFeeTokenValues['BNBP'] += bnbSwapAmounts[1];
            _distributeToTokenomicsPools(bnbSwapAmounts[1]);
        }
    }

    /**
     * @dev sets hot wallet address
     */
    function setHotWalletAddress(address addr) external onlyAdmin {
        hotWalletAddress = addr;
    }

    /**
     * @dev sets hot wallet min and max balance
     */
    function setHotWalletSettings(uint256 min, uint256 max) external onlyAdmin {
        require(min < max, 'Min !< Max');
        hotWalletMinBalance = min;
        hotWalletMaxBalance = max;
    }

    /**
     * @dev Burns accumulated BNBP fees
     *
     * NOTE can't burn before the burn interval
     */
    function burnAccumulatedBNBP() external validBNBP {
        IBNBP BNBPToken = IBNBP(BNBP_Address);
        uint256 BNBP_Balance = BNBPToken.balanceOf(address(this));

        require(BNBP_Balance > 0, 'No BNBP');
        require(burnPool > 0, 'No burn amt');
        require(burnPool <= BNBP_Balance, 'Wrong BNBP Fee');

        BNBPToken.performBurn();
        adminFeeTokenValues['BNBP'] -= burnPool;
        burnPool = 0;
        emit BurnSuccess(burnPool);
    }

    /**
     * @dev call for an airdrop on the BNBP token contract
     */
    function airdropAccumulatedBNBP() external validBNBP returns (uint256) {
        IBNBP BNBPToken = IBNBP(BNBP_Address);
        uint256 amount = BNBPToken.performAirdrop();

        airdropPool -= amount;
        adminFeeTokenValues['BNBP'] -= amount;

        emit AirdropSuccess(amount);
        return amount;
    }

    /**
     * @dev call for an airdrop on the BNBP token contract
     */
    function lotteryAccumulatedBNBP() external validBNBP returns (address) {
        IBNBP BNBPToken = IBNBP(BNBP_Address);
        uint256 BNBP_Balance = BNBPToken.balanceOf(address(this));

        require(BNBP_Balance > 0, 'No BNBP');
        require(lotteryPool > 0, 'No lott amt');
        require(lotteryPool <= BNBP_Balance, 'Wrg BNBP Fee');

        address winner = BNBPToken.performLottery();
        adminFeeTokenValues['BNBP'] -= lotteryPool;
        lotteryPool = 0;

        emit LotterySuccess(winner);
        return winner;
    }

    /**
     * @dev updates percentages for airdrop, lottery, and burn
     *
     * NOTE The sum of 3 params should be 100, otherwise it reverts
     */
    function setTokenomicsPercentage(
        uint8 _airdrop,
        uint8 _lottery,
        uint8 _burn
    ) external onlyAdmin {
        require(_airdrop + _lottery + _burn == 100, 'Shld be 100');

        airdropPercentage = _airdrop;
        lotteryPercentage = _lottery;
        burnPercentage = _burn;
    }

    /**
     * @dev distribute BNBP balance changes to tokenomics pools
     *
     */
    function _distributeToTokenomicsPools(uint256 value) internal {
        uint256 deltaAirdropAmount = (value * airdropPercentage) / 100;
        uint256 deltaLotteryAmount = (value * lotteryPercentage) / 100;
        uint256 deltaBurnAmount = value - deltaAirdropAmount - deltaLotteryAmount;

        airdropPool += deltaAirdropAmount;
        lotteryPool += deltaLotteryAmount;
        burnPool += deltaBurnAmount;
    }

    /**
     * @dev Sets Airdrop interval
     *
     */
    function setAirdropInterval(uint256 interval) external onlyAdmin {
        airdropInterval = interval;
    }

    /**
     * @dev Sets Burn interval
     *
     */
    function setBurnInterval(uint256 interval) external onlyAdmin {
        burnInterval = interval;
    }

    /**
     * @dev Sets Lottery interval
     *
     */
    function setLotteryInterval(uint256 interval) external onlyAdmin {
        lotteryInterval = interval;
    }

    /**
     * @dev Sets minimum BNBP value to get airdrop and lottery
     *
     */
    function setStakingMinimum(uint256 value) external onlyAdmin {
        stakingMinimum = value;
    }

    /**
     * @dev Sets minimum BNBP value to get airdrop and lottery
     *
     */
    function setMinimumStakingTime(uint256 value) external onlyAdmin {
        minimumStakingTime = value;
    }

    receive() external payable {
        if (msg.sender == address(router)) return;
        uint256 _participantCount = participantCount() ;
        if (_participantCount == 1) {
            UpdatePrice();
        }
        require((tokenLatestPriceFeed['BNB'] * msg.value) / 10**18 >= minEntranceInUsd, '< min');
        _EnterPot('BNB', msg.value, msg.sender);
    }

    function sendBNBForTransactionFees() public payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;


interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IPRC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

interface IBNBP {
    error AirdropTimeError();

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;

    function isUserAddress(address addr) external view returns (bool);

    function calculatePairAddress() external view returns (address);

    function performAirdrop() external returns (uint256);

    function performBurn() external returns (uint256);

    function performLottery() external returns (address);

    function setPotContractAddress(address addr) external;

    function setAirdropPercentage(uint8 percentage) external;

    function setAirdropInterval(uint256 interval) external;

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}