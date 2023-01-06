/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// SPDX-License-Identifier: Unlicensed

    pragma solidity 0.8.17;

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
            // priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526); // testnet
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

    contract WiPayFarm{
        WiPayFarm internal _wipayfarm;

        struct Players{
            uint256 _userId;
            uint256 _dateJoined;
            uint256 _totalStaked;
            uint256 _pendingWithdrawal;
            uint256 _totalWithdrawn;
            uint256 _totalBonus;
            uint256 _unPaidBonus;
            uint256 _lastDeposit; // next minimum must be +15%
            uint256 _dateWithdrawn;
            address _sponsor;
            address[] _referrals;
        }

        mapping(address => Players) public players;

        constructor(){
            _wipayfarm = WiPayFarm(0xa9c4794e41213a3596A82a1086333315Dc66DB5D); // live
            // _wipayfarm = WiPayFarm(0x8AAde1Fb840b323478e8583A586EC7687097d98a);  // testnet
        }

        function refCounts(address _user) public view returns(uint256){
            return(players[_user]._referrals.length);
        }

        function getUserInfo(address _user) public view returns(uint256 _userId, uint256 refCount, uint256 totalStaked){
            (_userId, , totalStaked, , , , , , ,) = _wipayfarm.players(_user);
            refCount = _wipayfarm.refCounts(_user);
        }
    }

    contract BWAXScooper is ReentrancyGuard, PriceConsumerV3, WiPayFarm {
        using SafeERC20 for IERC20;
        using Address for address;

        IERC20 public token;
        IERC20 internal _usdToken;

        struct User {
            uint256 id;
            address sponsor;
            uint256 rank; // 0 to 6
            Finance finance;
            Scoop scooper;
            FarmAirdrop farmdrop;
            bool canEarn; 
            address[] referrals;
            address[] myTeam;
            uint256[6] teamCount;
            Miningrigs[] miningrigs;
            VolumePoints volumepoints;
        }

        struct Finance{
            uint256 spent; // busd
            uint256 earned; // total Earned
            uint256 dcearned; // direct earnd
            uint256 icearned; // indirect earned
            uint256 shearned; // Shares Received
            uint256 earnings; // available 
            uint256 withdrawn; // busd
        }

        struct VolumePoints{
            uint256 personal;
            uint256 direct;
            uint256 team;
            uint256 directAwarded;
            uint256 teamAwarded;
            uint256 shareClaimed; // Time Stamp
            uint256[6] rankSharesl;
        }

        struct Scoop{
            uint256 purchased; // total token purchased + bonus
            uint256 pclaimed; // Pending Token to SmartMint
            uint256 claimed; // SmartMinted Token [total]
            uint256 bonus; // SmartMinted Token [total bonus]
            uint256 pbonus; // SmartMinted Token [total bonus]
            uint256 checkpoint;
        }

        struct Miningrigs{
            uint256 plan;
            uint256 amount;
            uint256 dateStarted;
            uint256 finish;
        }

        struct FarmAirdrop{
            uint256 refClaimed;
            uint256 stakeClaim;
            uint256 farmClaimed;
            uint256 fallocation;
        }

        uint256 internal constant INITIAL_PRICE = 0.00000513 ether; // USD PER 1 TOKEN [find a way to adjust this price later]

        uint256[6] internal VMINT_ROX = [1e20, 1e21, 5e21, 125e20, 25e21, 5e22]; // scooping packs

        uint256[6] internal VMINT_XER = [12500, 15000, 20000, 25000, 30000, 40000]; // multiplier

        uint256[5] internal SALESVOL_TAR = [5e21, 1e22, 5e22, 1e23, 25e22]; // SalesVolume Targets

        uint256[6] internal RANKING_TAR = [5e21, 1e22, 25e21, 5e22, 1e23, 25e22];

        uint256[5] internal SALESVOL_BON = [100, 200, 200, 300, 400];

        uint256[6] internal RANKING_BON = [600, 700, 900, 1200, 1200, 1200];

        uint256[6] internal RANKING_SHA = [25, 35, 50, 100, 150, 200]; // Ranking Shares

        uint256[6] internal COMMISSION = [400, 200, 100, 100, 100, 100]; // 10% Total on 6 levels

        uint256[3] internal VMINT_BON = [200, 200, 100]; // 5% On Mining Bonus

        uint256 internal constant PERSONAL = 500;

        uint256 internal constant DIRECTTG = 2500;

        uint256 internal constant ACTIVATION = 0.251 ether;

        uint256 internal constant INVOLUME = 125000 ether;

        uint256 internal constant SALESBEFOREBUY = 500 ether; // Buy tokens every 500 busd sales
        
        uint256 internal constant EARNINGCAP = 3; // Cap BUSD earnings to reinvest

        uint256 internal constant LIQUIDITY = 3000;

        uint256 internal constant MARKETING = 3000;
        
        uint256 internal constant DIV = 10000;

        uint256 internal DAILY_MINT = 152; // 1.52% daily
        
        uint256 constant internal TIME_STEP = 24 hours; // daily

        uint256 constant internal CLAIMPERIOD = 30 days; // monthly rank shares

        uint256 constant internal VMINT_TERM = 5; // max 5 days [to prevent high gas]

        uint256 internal callBuyFunction; // counter to trigger buy function

        uint256 internal callBuyLiquidity; // counter to trigger buy function

        uint256 public tokenSold; // total Tokens Sold 

        uint256 public tokenClaimed; // Withdrawn/harvested

        uint256 public totalBUSDvolume; // BUSD Global Volume

        uint256 public totalBUSDearned; // BUSD Withdrawn

        address private immutable deadAddress = address(0x000000000000000000000000000000000000dEaD);

        IUniswapV2Router02 public immutable uniswapV2Router;
        
        bool private inSwapAndLiquify;

        address payable private dev_;

        address payable private marketing;

        uint256 public startedAt = 1672952499;

        uint256 public lastUserId = 1;

        bool private started;

        uint256[6] public ranksFunds; // Funds Per Ranks [to distribute every 30 days]

        mapping (uint8 => address[]) public rankedUsers; // Get the Number of People in each rank

        mapping (address => User) public users;

        mapping (address => bool) public isScooper;

        event NewScooper(address user, address _sponsor);

        event onTokenPurchase(address indexed customerAddress, uint256 amount, uint256 tokensSold, address indexed referredBy);

        event onCommissionEarned(address indexed fromRef, uint256 amount, address indexed sponsor);

        event onEarningsWithdrawan(address indexed customerAddress, uint256 amount);

        event TokenWithdrawn(address indexed customerAddress, uint256 amount);

        event MiningCommissionCredited(address indexed customerAddress, uint256 amount);

        event NewRankAchieved(uint256 _newRank, address indexed uscustomerAddresser);

        event volumeTargetCredited(uint256 indexed level, uint256 _bonusEarned, address indexed uscustomerAddresser);

        modifier onlyBuilder(){
            require(users[msg.sender].miningrigs.length > 0, 'No Active Packs!');
            _;
        }

        modifier lockTheSwap {
            inSwapAndLiquify = true;
            _;
            inSwapAndLiquify = false;
        }

        constructor() {
            dev_ = payable(msg.sender);
            marketing = dev_;  // updates at getStarted() function  
            _usdToken = IERC20(address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56));
            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
            uniswapV2Router = _uniswapV2Router;
            // register dev
            registerUser(msg.sender, address(0));
        }

        function checkRanking(address _user) private{
            // Check Direct Volume + Personal
            uint256 _personal = users[_user].volumepoints.personal;
            uint256 _direct = users[_user].volumepoints.direct;
            for(uint8 i = 0; i < RANKING_TAR.length; i++){
                if(!users[_user].canEarn) break;
                uint256 _awarded = users[_user].volumepoints.directAwarded;
                uint256 _award = RANKING_TAR[i] * RANKING_BON[i] / DIV;
                if((_direct + _personal) >= RANKING_TAR[i] && _awarded < _award && _direct >= RANKING_TAR[i] * DIRECTTG / DIV && _personal >= RANKING_TAR[i] * PERSONAL / DIV){
                    // award
                    totalBUSDearned += _award;
                    users[_user].volumepoints.directAwarded += _award;
                    users[_user].finance.earnings += _award;
                    users[_user].finance.earned += _award;
                    users[_user].rank++;
                    // Emit new Rank Achieved
                    emit NewRankAchieved(users[_user].rank, _user);
                    rankedUsers[uint8(users[_user].rank -  1)].push(_user);
                    if(users[_user].finance.earnings >= users[_user].finance.spent * EARNINGCAP){
                        users[_user].canEarn = false;
                    }
                }
            }
        }
        
        function checkVolumePoints(address _user) private{
            // Check Team Volume
            uint256 _team = users[_user].volumepoints.team;
            for(uint8 i = 0; i < SALESVOL_TAR.length; i++){
                if(!users[_user].canEarn) break;
                uint256 _awarded = users[_user].volumepoints.teamAwarded;
                uint256 _award = SALESVOL_TAR[i] * SALESVOL_BON[i] / DIV;
                if(_team >= SALESVOL_TAR[i] && _awarded < _award){
                    // award
                    totalBUSDearned += _award;
                    users[_user].volumepoints.teamAwarded += _award;
                    users[_user].finance.earned += _award;
                    users[_user].finance.earnings += _award;
                    // _usdToken.safeTransfer(_user, _award);
                    // Emit new Volume Target Credited
                    emit volumeTargetCredited(i, _award, _user);
                    if(users[_user].finance.earnings >= users[_user].finance.spent * EARNINGCAP){
                        users[_user].canEarn = false;
                    }
                }
            }
        }

        function creditVolumePoints(address _user, uint256 _amount) private{
            _amount = _amount;
            // Direct Sales Volume
            users[_user].volumepoints.personal += _amount;
            checkRanking(_user);
            // Team Volume
            address _sponsor = users[_user].sponsor;
            if(_sponsor != address(0)){
                users[_sponsor].volumepoints.direct += _amount;
                checkRanking(_sponsor);
            }
            _sponsor = users[_sponsor].sponsor;
            for(uint8 _i = 1; _i < 3; _i++){
                if(_sponsor == address(0)) break;
                users[_sponsor].volumepoints.team += _amount;
                checkVolumePoints(_sponsor);
                _sponsor = users[_sponsor].sponsor;
            }
        }

        function _getToken(uint256 _amount) private view returns(uint256 _tokens){
            if(address(token) == address(0) || totalBUSDvolume < INVOLUME){
                _tokens = (_amount / INITIAL_PRICE) * 10**18;
            }
            uint[] memory _estimates = getTokenAmount(address(_usdToken), address(token), _amount);
            _tokens = _estimates[1];
        }
   
        function addPairLiquidity(uint256 _amount, uint256 tokenAmount) private {
            // approve token transfer to cover all possible scenarios
            _usdToken.approve(address(uniswapV2Router), _amount);
            // add the liquidity
            uniswapV2Router.addLiquidity(
                address(_usdToken), // TokenA
                address(token), // TokenB
                _amount,
                tokenAmount,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                deadAddress,
                block.timestamp
            );
        }
        
        // function salesReward(address _user, uint256 _amount, uint256 _amount2, bool _isBusd) private{
        function salesReward(address _user, uint256 _amount) private{
            address _sponsor = users[_user].sponsor;
            uint256 _marketing = _amount * MARKETING / DIV;

            // uint256 commission_ = 0;
            for(uint8 _int = 0; _int < COMMISSION.length; _int++){
                uint256 commission_ = _amount * COMMISSION[_int] / DIV;
                if(_sponsor == address(0)) break;
                if(users[_sponsor].canEarn){
                    if(_int == 0){
                        users[_sponsor].finance.dcearned += commission_;
                    }
                    else{
                        users[_sponsor].finance.icearned += commission_;
                    }
                    totalBUSDearned += commission_;
                    users[_sponsor].finance.earnings += commission_;
                    users[_sponsor].finance.earned += commission_;
                    if(users[_sponsor].finance.earnings >= users[_sponsor].finance.spent * EARNINGCAP){
                        users[_sponsor].canEarn = false;
                    }
                }
                _sponsor = users[_sponsor].sponsor;
            }

            _usdToken.safeTransfer(marketing, _marketing);
        }

        function rankingFunds(uint256 _amount) private{
            for(uint8 i = 0; i < RANKING_SHA.length; i++){
                ranksFunds[i] += _amount * RANKING_SHA[i] / DIV;
            }
        }

        function registerUser(address _user, address _ref) private{
            User storage user = users[_user];
            user.sponsor = dev_;
            if(_user != dev_ && _ref != _user && _ref != address(0) && users[_ref].scooper.purchased > 0){
                user.sponsor = _ref;
            }
            if(_user == dev_)
                user.sponsor = _ref;

            address _sponsor = user.sponsor;
            for(uint8 i = 0; i < 6; i++){
                if(_sponsor == address(0)) break;
                users[_sponsor].teamCount[i]++;
                users[_sponsor].myTeam.push(_user);
                _sponsor = users[_sponsor].sponsor;
            }
            user.id = lastUserId;
            users[_user].volumepoints.shareClaimed = block.timestamp;
            if(user.sponsor != address(0))
                users[user.sponsor].referrals.push(_user);
            lastUserId++;
            // Emit New User Joined
            emit NewScooper(_user, user.sponsor);
        }

        // function purchase(address _user, address _ref, uint256 _in, uint256 _amount, bool _isBusd) private{
        function purchase(address _user, address _ref, uint256 _in) private{
            require(!address(_user).isContract(), 'NotAllowed');
            require(address(token) != address(0), 'Set Token Address');
            require(isScooper[_user], 'NotScooper');
            // Register User
            if(users[_user].id == 0){
                registerUser(_user, _ref);
            }
            // get Multiplier
            (uint8 _plan) = getXer(_in);
            uint256 _tokenValue = _getToken(_in);
            uint256 _tokenCredited = _tokenValue * VMINT_XER[_plan] / DIV;
            if(_in >= VMINT_ROX[2] && totalBUSDvolume < INVOLUME){
                _tokenCredited = _tokenCredited * 3;
            }
            if(_in >= VMINT_ROX[3] && totalBUSDvolume < INVOLUME){
                _tokenCredited = _tokenCredited * 5;
            }
            tokenSold += _tokenCredited;
            callBuyFunction += _in; // track Value in USD
            totalBUSDvolume += _in; // track total BUSD volume
            users[_user].finance.spent += _in;
            users[_user].scooper.purchased += _tokenCredited;
            users[_user].scooper.pclaimed += _tokenCredited;
            // Update earnings ability
            if(!users[msg.sender].canEarn && users[msg.sender].finance.earnings < users[msg.sender].finance.spent * EARNINGCAP) 
                users[msg.sender].canEarn = true;

            // check if user has airdrop token 
            if(users[_user].farmdrop.fallocation > 0){
                uint256 _fallocation = users[_user].farmdrop.fallocation;
                users[_user].farmdrop.fallocation = 0;
                users[_user].scooper.pclaimed += _fallocation;
            }

            uint256 _start = block.timestamp;
            uint256 _finish = _start + 300 days;
            users[_user].scooper.checkpoint = block.timestamp;
            users[_user].miningrigs.push(Miningrigs(_plan, _tokenCredited, block.timestamp, _finish));
            // Allocate Ranking Shares
            rankingFunds(_in);
            // Award Commissions
            salesReward(_user, _in); // Affiliate commissions
            // Volume Point Distribution
            creditVolumePoints(_user, _in);
            // if(_isBusd){
                uint256 _liquidity = _in * (LIQUIDITY / 2) / DIV;
                callBuyLiquidity += _liquidity;
                // _usdToken.safeTransfer(liquidity, _liquidity);
                addPairLiquidity(_liquidity, (_tokenValue * (LIQUIDITY / 2) / DIV));
            // }
            if(callBuyFunction >= SALESBEFOREBUY){
                uint256 _amountToBuy = callBuyLiquidity; // buy 15% of volume
                callBuyFunction = 0;
                callBuyLiquidity = 0;
                // buy Token here swap usd token for BWAX token
                if(_amountToBuy > 0 && !inSwapAndLiquify){
                    swapAndLiquify(_amountToBuy);
                }
            }
            // Emit Pack Purchased
            emit onTokenPurchase(_user, _in, _tokenCredited, _ref);
        }

        function buyPackBUSD(address _ref, uint256 _amount) external {
            require(_amount >= VMINT_ROX[0], 'MIN 100 BUSD');
            // Must Approve Transaction and contract receives
            require(_usdToken.transferFrom(msg.sender, address(this), _amount));
            // Purchase
            purchase(msg.sender, _ref, _amount);
        }

        function buyPackBNB(address _ref) external payable{
            uint256 _contractBalance = _usdToken.balanceOf(address(this)); // contract balance before selling bnb
            swapEthForTokens(msg.value);
            uint256 _contractBalanceN = _usdToken.balanceOf(address(this)); // contract balance after selling bnb
            uint256 _amount = _contractBalanceN - _contractBalance; // busd received
            require(_amount >= VMINT_ROX[0], 'MIN 10 BUSD');
            // Purchase
            purchase(msg.sender, _ref, _amount);
        }

        // one time activation fees 
        function bScooper() external payable{
            require(!isScooper[msg.sender], 'OneTimeActivation');
            require(msg.value >= ACTIVATION, '0.251BNB_required');
            marketing.transfer(msg.value);
            isScooper[msg.sender] = true;
        }

        function miningBonus(address _user, uint256 _amount) private{
            address _sponsor = users[_user].sponsor;
            for(uint i = 0; i < 3; i++){
                uint256 _commission = _amount * VMINT_BON[i] / DIV;
                if(_sponsor == address(0)) break;
                users[_sponsor].scooper.bonus += _commission;
                users[_sponsor].scooper.pbonus += _commission;
                emit MiningCommissionCredited(_sponsor, _commission);
                _sponsor = users[_sponsor].sponsor;
            }
        }

        function scoopBWAXT() public onlyBuilder(){
            address _user = msg.sender;
            require(!address(_user).isContract(), 'NotAllowed');
            require(users[_user].scooper.pclaimed > 0);

            require(block.timestamp >= users[_user].scooper.checkpoint + TIME_STEP, '24hrsLimit');

            uint256 _scoopAmount = getMintAmount(users[_user].scooper.pclaimed, users[_user].scooper.checkpoint);
            // Get Minting Bonus
            uint _bonus = users[_user].scooper.pbonus;
            if(_bonus > 0){
                users[_user].scooper.pbonus = 0;
                _scoopAmount += _bonus;
            }
            require(_scoopAmount > 0, 'NothingToMint');
            // Mint Token
            uint256 contractBalance = getContractTokenBalance();
            require(contractBalance >= _scoopAmount, 'NotEnoughTokens');
            users[_user].scooper.claimed += _scoopAmount;
            users[_user].scooper.pclaimed -= _scoopAmount;
            users[_user].scooper.checkpoint = block.timestamp;
            tokenClaimed += _scoopAmount;
            token.safeTransfer(_user, _scoopAmount);
            emit TokenWithdrawn(_user, _scoopAmount);
            // Credit Upline [Mining Bonus] 2%, 2%, 1%
            miningBonus(_user, _scoopAmount);
        }

        function withdrawBUSD() public onlyBuilder(){
            require(!address(msg.sender).isContract(), 'NotAllowed');
            uint256 _amount = users[msg.sender].finance.earnings;
            require( _amount >= 10 ether, 'NoEarAva'); // $10 minimum
            // Cannot Withdraw more than spent * EARNINGCAP
            uint256 _spent = users[msg.sender].finance.spent;
            uint256 _withdrawn = users[msg.sender].finance.withdrawn;
            uint256 _earningCap = _spent * EARNINGCAP;

            require(_withdrawn < _earningCap, '3xCap');

            // balance to withdraw 
            if(_amount + _withdrawn > _earningCap){
                uint256 _balance = (_amount + _withdrawn) - _earningCap;
                _amount -= _balance;
            }

            require(getContractUSDBalance() > _amount, 'NoLiquidity');

            users[msg.sender].finance.earnings -= _amount;
            users[msg.sender].finance.withdrawn += _amount;
            _usdToken.transfer(msg.sender, _amount);
            emit onEarningsWithdrawan(msg.sender, _amount);
        }

        // Claim airdrop from farm
        function claimAirdrop() public {
            address _user = msg.sender;
            require(!address(_user).isContract(), 'NotAllowed');
            (uint256 _userId, uint256 _refCount, uint256 _totalStaked) = getUserInfo(_user);
            require(_userId > 0, 'NotEligigle');
            uint256 _refClaimed = users[_user].farmdrop.refClaimed;
            uint256 _stakeClaim = users[_user].farmdrop.stakeClaim;
            require(_refClaimed < _refCount || _stakeClaim < _totalStaked, 'NotAllowed');
            uint256 _allocation = 0;
            if(_refClaimed < _refCount){
                uint256 _addedRef = _refCount - _refClaimed;
                users[_user].farmdrop.refClaimed += _addedRef;
                _allocation += _addedRef * 1e23;
            }
            if(_stakeClaim < _totalStaked){
                uint256 _addedStake = _totalStaked - _stakeClaim;
                users[_user].farmdrop.stakeClaim += _addedStake;
                uint256 _usdReward = getUSDvalueFromBNB(_addedStake * VMINT_BON[0] / DIV); // 2% allocation 
                _allocation += _getToken(_usdReward);
            }
            
            users[_user].farmdrop.farmClaimed += _allocation;
            users[_user].farmdrop.fallocation += _allocation;
        }

        function getRankShares() public onlyBuilder(){
            require(!address(msg.sender).isContract(), 'NotAllowed');
            // Claim this monthly 
            require(block.timestamp >= users[msg.sender].volumepoints.shareClaimed + CLAIMPERIOD, 'MonthlyClaims');
            require(users[msg.sender].rank > 0, 'MustHaveRank');
            uint8 _rank = uint8(users[msg.sender].rank - 1);
            uint256 _rankShare = 0;
            uint256 _newShare = 0;
            // only claim highest Rank Shares
            for(uint8 i = 0; i < 6; i++){
                if(_rank == i){
                    _rankShare = ranksFunds[i];
                    break;
                }
            }
            require(users[msg.sender].volumepoints.rankSharesl[_rank] < _rankShare, 'NothingToClaim');
            _newShare = _rankShare - users[msg.sender].volumepoints.rankSharesl[_rank];
            users[msg.sender].volumepoints.rankSharesl[_rank] += _newShare; 
            uint256 _myShare = _newShare / rankedUsers[_rank].length;
            users[msg.sender].finance.earned += _myShare;
            users[msg.sender].finance.shearned += _myShare;
            require(getContractUSDBalance() >= _myShare * 3, 'NoLiquidity');
            users[msg.sender].finance.withdrawn += _myShare;
            users[msg.sender].volumepoints.shareClaimed = block.timestamp;
            _usdToken.transfer(msg.sender, _myShare);
            emit onEarningsWithdrawan(msg.sender, _myShare);
        }

        function getMintAmount(uint256 _allocation, uint256 _checkpoint) private view returns(uint256 _scoopAmount){
            uint256 _daysPassed = (block.timestamp - _checkpoint) / TIME_STEP >= VMINT_TERM ? VMINT_TERM : (block.timestamp - _checkpoint) / TIME_STEP;
            if(_daysPassed > 0){
                for(uint256 i = 1; i <= _daysPassed; i++){
                    uint256 _amountToMint = _allocation * DAILY_MINT / DIV;
                    _allocation -= _amountToMint;
                    _scoopAmount += _amountToMint;
                }
            }
        }

        function getXer(uint256 _value) private view returns(uint8){
            for(uint8 i = 0; i < 6; i++){
                if((i < 5 && _value >= VMINT_ROX[i] && _value < VMINT_ROX[i+1]) || i == 5 && _value >= VMINT_ROX[i]){
                    return i;
                }
            }
            return 0;
        }

        function getTokenAmount(address _tokenA, address _tokenB, uint _amountIn) private view returns(uint[] memory amounts){
            address[] memory path = new address[](2);
            path[0] = _tokenA;
            path[1] = _tokenB;
            amounts = uniswapV2Router.getAmountsOut(_amountIn, path);
            return amounts;
        }

        function swapEthForTokens(uint256 etherAmount) private lockTheSwap{
            // Swap BNB to BUSD for contest rewards.
            address[] memory path = new address[](2);
            path[0] = uniswapV2Router.WETH();
            path[1] = address(_usdToken);
            // make the swap
            uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: etherAmount }(
                0, // accept any amount of ETH
                path,
                address(this),
                block.timestamp
            );
        }

        function swapAndLiquify(uint256 tokenAmount) private lockTheSwap{
            _usdToken.approve(address(uniswapV2Router), tokenAmount);
            // generate the uniswap pair path of token -> weth
            address[] memory path = new address[](2);
            path[0] = address(_usdToken);
            path[1] = address(token);
            // make the swap
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // accept any amount of ETH
                path,
                address(this),
                block.timestamp
            );
        }

        function getUserAvailable(address userAddress) public view returns (uint256) {
            // returns available amount to scoop
            return getMintAmount(users[userAddress].scooper.pclaimed, users[userAddress].scooper.checkpoint);
        }

        function getContractUSDBalance() public view returns (uint256) {
            return _usdToken.balanceOf(address(this));
        }

        function getContractTokenBalance() public view returns (uint256) {
            return token.balanceOf(address(this));
        }

        function viewUserReferral(address _user) public view returns(address[] memory) {
            return users[_user].referrals;
        }

        function viewUserTeam(address _user) public view returns(address[] memory) {
            return users[_user].myTeam;
        }

        function viewTeamCount(address _user) public view returns(uint256[6] memory) {
            return users[_user].teamCount;
        }

        function viewMyScoops(address _user) public view returns(Miningrigs[] memory) {
            return users[_user].miningrigs;
        }

        function getTokenPriceUSD() public view returns(uint256){
            address[] memory path = new address[](2);
            path[0] = address(token);
            path[1] = address(_usdToken);
            uint[] memory amounts = uniswapV2Router.getAmountsOut(1 ether, path);
            return amounts[1];
        }

        function getStarted(IERC20 _token, address _marketing) public {
            require(msg.sender == dev_ && !started, 'Unauthorized!');
            token = _token;
            marketing = payable(_marketing);
            addPairLiquidity(200 ether, 399346e20); // set initial liquidity in BUSD
            started = true;
        }

        receive() external payable {}

        // to account for volume and bonuses
        function getUSDvalueFromBNB(uint256 _amount) private view returns(uint256 _bsudValue){
            (int bnbPrice, uint8 decimals_) = getLatestPrice(); // 1BNB in USD
            _bsudValue = _amount * uint256(bnbPrice) / 10 ** decimals_;
        }
    }

    library Address {
        function isContract(address account) internal view returns (bool) {
            bytes32 codehash;
            bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
            assembly { codehash := extcodehash(account) }
            return (codehash != 0x0 && codehash != accountHash);
        }
    }

    library SafeERC20 {
        using Address for address;

        function safeTransfer(IERC20 token, address to, uint256 value) internal {
            callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
        }
        /**
        * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
        * on the return value: the return value is optional (but if data is returned, it must not be false).
        * @param token The token targeted by the call.
        * @param data The call data (encoded using abi.encode or one of its variants).
        */
        function callOptionalReturn(IERC20 token, bytes memory data) private {
            // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
            // we're implementing it ourselves.

            // A Solidity high level call has three parts:
            //  1. The target address is checked to verify it contains contract code
            //  2. The call itself is made, and success asserted
            //  3. The return value is decoded, which in turn checks the size of the returned data.
            // solhint-disable-next-line max-line-length
            require(address(token).isContract(), "SafeERC20: call to non-contract");

            // solhint-disable-next-line avoid-low-level-calls
            (bool success, bytes memory returndata) = address(token).call(data);
            require(success, "SafeERC20: low-level call failed");

            if (returndata.length > 0) { // Return data is optional
                // solhint-disable-next-line max-line-length
                require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
            }
        }
    }

    interface IERC20 {
        function balanceOf(address owner) external view returns (uint256);
        function allowance(address owner, address spender) external view returns (uint256);

        function approve(address spender, uint256 value) external returns (bool);
        function transfer(address to, uint256 value) external returns (bool);
        function transferFrom(address from, address to, uint256 value) external returns (bool);

        event Approval(address indexed owner, address indexed spender, uint256 value);
        event Transfer(address indexed from, address indexed to, uint256 value);
    }
   
    interface IUniswapV2Router01 {
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
       function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    }
   
    interface IUniswapV2Router02 is IUniswapV2Router01 {
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