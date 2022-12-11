/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

/*  CYFtoken - Experimental Community Owned MeMeCoin.
    *   Giving a new Image MeMeCoin Through Community Strenght!
    *   Version 1.0.0
    *   SPDX-License-Identifier: Unlicensed
    *   ┌──────────────────────────────────────────────────┐
    *   │   Website: https://cyf.finance                   │
    *   │                                                  │
    *   │   Telegram Live Support: @bscyf_real             │
    *   │   Telegram Public Chat: @bscyf                   │
    *   │                                                  │
    *   │   E-mail: [email protected]                      │
    *   └──────────────────────────────────────────────────┘
    *
    *   [USAGE INSTRUCTION]
    *
    *   1) Connect any supported wallet [Recommended: Metamask/TrustWallet]
    *   2) Be sure to switch to BSC network (Binance Smart Chain) 
    *   3) Click on Dashboard to view the Mintin Packs
    *   4) Select a Package to activate [from 10 USDT to 75000 USDT] - BEP20
    *   5) Click "Purchase Pack", and confirm the transaction
    *   6) Once your transaction receives at least 1 blocks confirmation it will start MINTING CYF tokens
    *   7) Your Minted CYF tokens are instantly available to withdraw every 24hrs, simply Click on "MINT CYF"
    *   8) We aim to build a strong community through team work, pls share your link and earn more...
    *   
    *
    *   [TOKEN MINTING TERMS]
    *
    *   - Minimum Pack Purchase: 10 BUSD - BEP20 only, Maximum 500000 BUSD
    *   - CYFtoken has a limited supply of 100Trillion CYF
    *   - CYF minting through Pack Purchase will be sustained throught a massive buy-back protocol
    *   - Your CYF pack purchase are non-refundable, however, your can call the smart-minter every 24hrs and get CYF tokens
    *   - CYF token harvested will be instantly available upon transaction approval from your end.
    *   - Buying CYF through pack purchase gives you up to 300% bonus released gradually for a maximum period of 300 days
    *
    *   [AFFILIATE PROGRAM]
    *
    *   - 6 level referral reward [10% total]: 4% - 2% - 1% - 1% - 1% - 1%
    *
    *   [FUNDS DISTRIBUTION]
    *
    *   - 40% Bonus, Rank & Affiliate rewards Program fully managed this smartcontrat
    *   - 40% Liquidity on PancakeSwap Locked forever
    *   - 3% Liquidity on BSCYieldfarm
    *   - 6% Advertising and promotion expenses, Support and Legal
    *   - 11% Dev Fee/R&D and Project Ecosystem Expansion
    *
    *   [DISCLAIMER]
    *
    *   This is an experimental project, it's success relies on its community
    *   as DeFi system it runs smoothly on binance smartchain network 
    *   This project can be considered having high risks as well as high profits.
    *   Though once contract balance drops to zero payments will stops, everything has been 
    *   programmed to prevent this from happening, therefore as we keep sharing this project it will remain alive.
    *   PARTICIPATE AT YOUR OWN RISK.
    */

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

    contract SecuredCYFSmartMinter is ReentrancyGuard, PriceConsumerV3 {
        using SafeERC20 for IERC20;
        using Address for address;

        IERC20 public token;
        IERC20 internal _usdToken;

        struct User {
            uint256 id;
            address sponsor;
            uint256 rank; // 0 to 6
            Finance finance;
            Minter minter;
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

        struct Minter{
            uint256 purchased; // total token purchased + bonus
            uint256 pclaimed; // Pending Token to SmartMint
            uint256 claimed; // SmartMinted Token [total]
            uint256 bonus; // SmartMinted Token [total bonus]
            uint256 pbonus; // SmartMinted Token [total bonus]
            uint256 preminter; // Total Amount Claimed from preminter
            uint256 checkpoint;
        }

        struct VolumePoints{
            uint256 personal;
            uint256 direct;
            uint256 team;
            uint256 directAwarded;
            uint256 teamAwarded;
            uint256[6] rankSharesl;
        }

        struct Miningrigs{
            uint256 plan;
            uint256 amount;
            uint256 dateStarted;
            uint256 finish;
        }

        uint256 internal constant INITIAL_PRICE = 0.000005 ether; // USD PER 1 TOKEN [find a way to adjust this price later]

        uint256 internal constant SALESBEFOREBUY = 500 ether; // Buy tokens every 1000 sales

        uint256[6] internal VMINT_ROX = [1e19, 1e20, 5e20, 25e20, 125e20, 5e22]; // minting packs

        uint256[6] internal VMINT_XER = [12500, 15000, 20000, 25000, 30000, 40000]; // multiplier

        uint256[5] internal SALESVOL_TAR = [5e21, 1e22, 5e22, 1e23, 25e22]; // SalesVolume Targets

        uint256[6] internal RANKING_TAR = [5e21, 1e22, 25e21, 5e22, 1e23, 25e22];

        uint256[5] internal SALESVOL_BON = [100, 200, 200, 300, 400];

        uint256[6] internal RANKING_BON = [600, 700, 900, 1200, 1200, 1200];

        uint256[6] internal RANKING_SHA = [25, 35, 50, 100, 150, 200]; // Ranking Shares

        uint256[6] internal COMMISSION = [400, 200, 100, 100, 100, 100]; // 10% Total on 6 levels

        uint256[3] internal VMINT_BON = [200, 200, 100]; // 5% On Mining Bonus

        uint256 internal constant PERSONAL = 500;

        uint256 internal constant LBNBPERCENT = 2500; // 25% when swapping bnb to busd
        
        uint256 internal constant EARNINGCAP = 3; // Cap BUSD earnings to reinvest

        uint256 internal constant LIQUIDITY = 4000;

        uint256 internal constant MARKETING = 600;

        uint256 internal constant FARMREWARD = 300;

        uint256 internal constant DEVTEAM = 1100;
        
        uint256 internal constant DIV = 10000;

        uint256 internal DAILY_MINT = 151; // 1.52% daily
        
        uint256 constant internal TIME_STEP = 24 hours; // 24 hours

        uint256 constant internal VMINT_TERM = 300; // 300 days

        uint256 internal callBuyFunction; // counter to trigger buy function

        uint256 public tokenSold; // total Tokens Sold 

        uint256 public tokenClaimed; // Withdrawn/harvested

        uint256 public totalBUSDvolume; // BUSD Global Volume

        uint256 public totalBUSDearned; // BUSD Withdrawn

        SecuredCYFSmartMinter immutable OldMinter = SecuredCYFSmartMinter(payable(0xCD4210f689354df9b311b97DAF80a1B5619C4CA1)); 

        IERC20 immutable CYFG_OLD = IERC20(payable(0xf82E0a28aa69e03C7Cd894726c1a49A01F90E765));

        CYFpreminterclaims immutable Preminter = CYFpreminterclaims(0xB3838C7a9cC8c082E0F7f3a1304cA268F2b420b5);

        address private immutable deadAddress = address(0x000000000000000000000000000000000000dEaD);

        IUniswapV2Router02 public immutable uniswapV2Router;
        
        bool private inSwapAndLiquify;

        address payable private dev_;
        address payable private marketing;
        address payable private farmwallet;

        uint256 public startedAt = 1668384295;

        uint256 public lastUserId = 1;

        bool private started;

        uint256[6] public ranksFunds; // Funds Per Ranks [to distribute every 30 days]

        mapping (uint8 => address[]) public rankedUsers; // Get the Number of People in each rank

        mapping (address => User) public users;

        mapping (address => bool) internal moved;

        event NewMinter(address user, address _sponsor);

        event onTokenPurchase(address indexed customerAddress, uint256 amount, uint256 tokensSold, address indexed referredBy);

        event onCommissionEarned(address indexed fromRef, uint256 amount, address indexed sponsor);

        event onEarningsWithdrawan(address indexed customerAddress, uint256 amount);

        event TokenWithdrawn(address indexed customerAddress, uint256 amount);

        event MiningCommissionCredited(address indexed customerAddress, uint256 amount);

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
            _usdToken = IERC20(address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56));
            // testnet 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7 live 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
            // test 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 // live 0x10ED43C718714eb63d5aA57B78B54704E256024E
            uniswapV2Router = _uniswapV2Router;
        }

        function checkRanking(address _user) private{
            if(users[_user].canEarn || _user == dev_){
                // Check Direct Volume + Personal
                uint256 _personal = users[_user].volumepoints.personal;
                uint256 _direct = users[_user].volumepoints.direct;
                uint256 _awarded = users[_user].volumepoints.directAwarded;
                for(uint8 i = 0; i < RANKING_TAR.length; i++){
                    uint256 _award = RANKING_TAR[i] * RANKING_BON[i] / DIV;
                    if(_direct >= RANKING_TAR[i] && _personal >= RANKING_TAR[i] * PERSONAL / DIV && _awarded < _award){
                        // award
                        users[_user].volumepoints.directAwarded += _award;
                        users[_user].finance.earnings += _award;
                        users[_user].finance.earned += _award;
                        // _usdToken.safeTransfer(_user, _award);
                        // Emit new Rank Achieved
                        users[_user].rank++;
                        rankedUsers[uint8(users[_user].rank -  1)].push(_user);
                        if(users[_user].finance.earnings >= users[_user].finance.spent * EARNINGCAP){
                            users[_user].canEarn = false;
                        }
                    }
                }
            }
        }
        
        function checkVolumePoints(address _user) private{
            if(users[_user].canEarn || _user == dev_){
                // Check Team Volume
                uint256 _team = users[_user].volumepoints.team;
                uint256 _awarded = users[_user].volumepoints.teamAwarded;
                for(uint8 i = 0; i < SALESVOL_TAR.length; i++){
                    uint256 _award = SALESVOL_TAR[i] * SALESVOL_BON[i] / DIV;
                    if(_team >= SALESVOL_TAR[i] && _awarded < _award){
                        // award
                        users[_user].volumepoints.teamAwarded += _award;
                        users[_user].finance.earned += _award;
                        users[_user].finance.earnings += _award;
                        // _usdToken.safeTransfer(_user, _award);
                        // Emit new Volume Target Reached
                        emit volumeTargetCredited(i, _award, _user);
                        if(users[_user].finance.earnings >= users[_user].finance.spent * EARNINGCAP){
                            users[_user].canEarn = false;
                        }
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
                if(_sponsor != address(0)){
                    users[_sponsor].volumepoints.team += _amount;
                    checkVolumePoints(_sponsor);
                }
                _sponsor = users[_sponsor].sponsor;
            }
        }

        function _getToken(uint256 _amount) private view returns(uint256 _tokens){
            uint[] memory _estimates = getTokenAmount(address(_usdToken), address(token), _amount);
            _tokens = _estimates[1];
            if(_tokens == 0){
                _tokens = (_amount / INITIAL_PRICE) * 10**18;
            }
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
        
        function salesReward(address _user, uint256 _amount, uint256 _amount2, bool _isBusd) private{
            address _sponsor = users[_user].sponsor;
            uint256 _marketing = _amount2 * MARKETING / DIV;
            uint256 _dev = _amount2 * DEVTEAM / DIV;
            uint256 _farm = _amount2 * FARMREWARD / DIV;

            // uint256 commission_ = 0;
            for(uint8 _int = 0; _int < COMMISSION.length; _int++){
                uint256 commission_ = _amount * COMMISSION[_int] / DIV;
                if(_sponsor != address(0)){
                    if(users[_sponsor].canEarn){
                        if(_int == 0){
                            users[_sponsor].finance.dcearned += commission_;
                        }
                        else{
                            users[_sponsor].finance.icearned += commission_;
                        }
                        users[_sponsor].finance.earnings += commission_;
                        users[_sponsor].finance.earned += commission_;
                        if(users[_sponsor].finance.earnings >= users[_sponsor].finance.spent * EARNINGCAP){
                            users[_sponsor].canEarn = false;
                        }
                    }
                }
                _sponsor = users[_sponsor].sponsor;
            }

            if(_isBusd){
                _usdToken.safeTransfer(marketing, _marketing);

                _usdToken.safeTransfer(farmwallet, _farm); // transfer usd token to farm

                _usdToken.safeTransfer(dev_, _dev);
            }
            else{
                payable(marketing).transfer(_marketing);
                payable(farmwallet).transfer(_farm);
                payable(dev_).transfer(_dev);
            }
        }

        function rankingFunds(uint256 _amount) private{
            for(uint8 i = 0; i < RANKING_SHA.length; i++){
                ranksFunds[i] += _amount * RANKING_SHA[i] / DIV;
            }
        }

        function registerUser(address _user, address _ref, bool _moving) private{
            User storage user = users[_user];
            user.sponsor = dev_;
            if(_moving || (_ref != _user && _ref != address(0) && users[_ref].minter.purchased > 0)){
                user.sponsor = _ref;
            }
            user.id = lastUserId;
            users[user.sponsor].referrals.push(_user);
            lastUserId++;
            // Emit New User Joined
            address _sponsor = user.sponsor;
            for(uint8 i = 0; i < 6; i++){
                if(_sponsor != address(0)){
                    users[_sponsor].teamCount[i]++;
                    users[_sponsor].myTeam.push(_user);
                    _sponsor = users[_sponsor].sponsor;
                }
            }
            emit NewMinter(_user, user.sponsor);
        }

        function purchase(address _user, address _ref, uint256 _in, uint256 _amount, bool _isBusd) private{
            require(!address(_user).isContract(), 'NotAllowed');
            require(address(token) != address(0), 'Set Token Address');
            // Register User
            // Move User until December 31st
            uint256 _deadline = 1672527599;
            if(!moved[_user] && _isOldMinter(_user) && block.timestamp <= _deadline){
                moveOldMinters(_user);
            }
            if(users[_user].id == 0){
                registerUser(_user, _ref, false);
                moved[_user] = true; // prevent re-entry from old contract
            }
            // get Multiplier
            (uint8 _plan) = getXer(_in);
            uint256 _tokenValue = _getToken(_in);
            uint256 _tokenCredited = _tokenValue * VMINT_XER[_plan] / DIV;
            tokenSold += _tokenCredited;
            callBuyFunction += _in; // track Value in USD
            totalBUSDvolume += _in; // track total BUSD volume
            users[_user].finance.spent += _in;
            users[_user].minter.purchased += _tokenCredited;
            users[_user].minter.pclaimed += _tokenCredited;

            uint256 _start = block.timestamp;
            uint256 _finish = _start + VMINT_TERM;
            users[_user].minter.checkpoint = block.timestamp;
            users[_user].miningrigs.push(Miningrigs(_plan, _tokenCredited, block.timestamp, _finish));
            // Allocate Ranking Shares
            rankingFunds(_in);
            // Award Commissions
            salesReward(_user, _in, _amount, _isBusd); // Affiliate commissions
            // Volume Point Distribution
            creditVolumePoints(_user, _in);
            // Emit Pack Purchased
            if(_isBusd){
                uint256 _liquidity = _in * (LIQUIDITY / 2) / DIV;
                // _usdToken.safeTransfer(liquidity, _liquidity);
                addPairLiquidity(_liquidity, (_tokenValue * (LIQUIDITY / 2) / DIV));
            }
            else{
                uint256 _contractBalance = _usdToken.balanceOf(address(this));
                // convert 80% bnb to busd 
                swapEthForTokens(_amount * (LIQUIDITY * 2) / DIV);
                // Get Balance after swap
                uint256 _contractBalanceN = _usdToken.balanceOf(address(this));

                uint256 _liquidity = (_contractBalanceN - _contractBalance) / 4;

                addPairLiquidity(_liquidity, (_tokenValue * (LIQUIDITY / 2) / DIV)); // 20% to liquidity
            }
            if(callBuyFunction >= SALESBEFOREBUY){
                uint256 _amountToBuy = callBuyFunction * (LIQUIDITY / 2) / DIV; // buy 20% of volume
                callBuyFunction = 0;
                // buy Token here swap usd token for cyf token
                if(_amountToBuy > 0 && !inSwapAndLiquify){
                    swapAndLiquify(_amountToBuy);
                }
            }
        }

        function buyPackBUSD(address _ref, uint256 _amount) external {
            require(_amount >= VMINT_ROX[0], 'MIN 10 BUSD');
            // Must Approve Transaction and contract receives
            require(_usdToken.transferFrom(msg.sender, address(this), _amount));
            // Purchase MiningRig
            purchase(msg.sender, _ref, _amount, _amount, true);
            users[msg.sender].canEarn = true;
        }

        function buyPackBNB(address _ref) external payable{
            uint _amount = getUSDvalueFromBNB(msg.value);
            require(_amount >= VMINT_ROX[0], 'MIN 10 BUSD');
            purchase(msg.sender, _ref, _amount, msg.value, false);
            users[msg.sender].canEarn = true;
        }

        function miningBonus(address _user, uint256 _amount) private{
            address _sponsor = users[_user].sponsor;
            for(uint i = 0; i < 3; i++){
                uint256 _commission = _amount * VMINT_BON[i] / DIV;
                if(_sponsor != address(0)){
                    users[_sponsor].minter.bonus += _commission;
                    users[_sponsor].minter.pbonus += _commission;
                    // token.safeTransfer(_sponsor, _commission);
                    emit MiningCommissionCredited(_sponsor, _commission);
                }
                _sponsor = users[_sponsor].sponsor;
            }
        }

        function  _isOldMinter(address _user) private view returns(bool){
            try OldMinter.users(_user) returns(uint256 _userId, address, uint256, Finance memory , Minter memory , bool, VolumePoints memory ){
                if(_userId > 0){
                    return true;
                }
            }catch(bytes memory) {
                return false;
            }
            return false;
        }

        function checkOldMinter(address _user) private view returns(address sponsor, uint256 rank, bool canEarn, Finance memory finance, Minter memory minter, VolumePoints memory volumes){
            try OldMinter.users(_user) returns(uint256, address _sponsor, uint256 _rank, Finance memory _finance, 
                Minter memory _minter, bool _canEarn, VolumePoints memory _volumes){
                    sponsor = _sponsor;
                    rank = _rank;
                    canEarn = _canEarn;
                    finance = _finance;
                    minter = _minter;
                    volumes = _volumes;
            }catch (bytes memory){}
        }

        function moveOldMinters(address _user) private{

            // check Old Minter 
            (address _sponsor, uint256 _rank, bool _canEarn, Finance memory _finance, Minter memory _minter, VolumePoints memory _volumes) = checkOldMinter(_user);
            
            // Register user first
            if(users[_user].id == 0){
                registerUser(_user, _sponsor, true);
            }

            if(_minter.pclaimed > 0){
                // check allocation from old mniter
                users[_user].minter.purchased += _minter.purchased;
                users[_user].minter.preminter += _minter.preminter;
                users[_user].minter.pclaimed += _minter.pclaimed;
                users[_user].minter.claimed += _minter.claimed;
                users[_user].minter.bonus += _minter.bonus;
                users[_user].minter.pbonus += _minter.pbonus;
                users[_user].minter.checkpoint = _minter.checkpoint;
                users[_user].finance.spent = _finance.spent;
                users[_user].finance.earned = _finance.earned;
                users[_user].finance.dcearned = _finance.dcearned;
                users[_user].finance.icearned = _finance.icearned;
                users[_user].finance.shearned = _finance.shearned;
                users[_user].finance.earnings = _finance.earnings;
                users[_user].finance.withdrawn = _finance.withdrawn;
                users[_user].volumepoints.personal = _volumes.personal;
                users[_user].volumepoints.direct = _volumes.direct;
                users[_user].volumepoints.team = _volumes.team;
                users[_user].volumepoints.directAwarded = _volumes.directAwarded;
                users[_user].volumepoints.teamAwarded = _volumes.teamAwarded;
                users[_user].rank = _rank;
                users[_user].canEarn = _canEarn;
                tokenSold += _minter.purchased;
            }
            moved[_user] = true;
        }

        function mintCYFT() public {
            require(address(token) != address(0), 'Set Token Address');
            address _user = msg.sender;
            require(!address(_user).isContract(), 'NotAllowed');

            uint256 _deadline = 1672527599;
            if(!moved[_user] && _isOldMinter(_user) && block.timestamp <= _deadline){
                // Upate from OldMinter
                moveOldMinters(_user);
            }
            if(users[_user].id == 0){
                registerUser(_user, dev_, false);
                moved[_user] = true; // prevent re-entry from old contract
            }

            uint256 minterClaimed = users[_user].minter.preminter;
            uint256 _mintAmount;

            require(block.timestamp >= users[_user].minter.checkpoint + TIME_STEP, '24hrsLimit');
            
            if(users[_user].minter.pclaimed > 0){
                _mintAmount += getMintAmount(users[_user].minter.pclaimed, users[_user].minter.checkpoint);
            }
            
            // get preminter Allocation
            (, , , , , , uint256 _allocation, ) = Preminter.minters(_user);

            if(_allocation > minterClaimed){
                uint256 _amountToClaim = _allocation - minterClaimed;
                uint256 _mintAmountP = getMintAmount(_amountToClaim, block.timestamp - TIME_STEP);
                tokenSold += _amountToClaim;
                _mintAmount += _mintAmountP;
                users[_user].minter.preminter += _amountToClaim;
                users[_user].minter.pclaimed += _amountToClaim;
            }

            // Get Minting Bonus
            uint _bonus = users[_user].minter.pbonus;
            if(_bonus > 0){
                users[_user].minter.pbonus = 0;
                _mintAmount += _bonus;
            }
            require(_mintAmount > 0, 'NothingToMint');
            // Mint Token
            uint256 contractBalance = getContractTokenBalance();
            require(contractBalance >= _mintAmount, 'NotEnoughTokens');
            users[_user].minter.claimed += _mintAmount;
            users[_user].minter.pclaimed -= _mintAmount;
            users[_user].minter.checkpoint = block.timestamp;
            tokenClaimed += _mintAmount;
            token.safeTransfer(_user, _mintAmount);
            emit TokenWithdrawn(_user, _mintAmount);
            // Credit Upline [Mining Bonus] 2%, 2%, 1%
            miningBonus(_user, _mintAmount);
        }

        function withdrawBUSD() public onlyBuilder(){
            uint256 _amount = users[msg.sender].finance.earnings;
            require( _amount  > 0, 'NoEarAva');
            require(getContractUSDBalance() >= _amount * 3, 'NoLiquidity');
            users[msg.sender].finance.earnings = 0;
            users[msg.sender].finance.withdrawn += _amount;
            _usdToken.transfer(msg.sender, _amount);
            emit onEarningsWithdrawan(msg.sender, _amount);
        }

        function getRankShares() public onlyBuilder(){
            require(users[msg.sender].rank > 0, 'MustHaveRank');
            uint8 _rank = uint8(users[msg.sender].rank - 1);
            uint256 _rankShare = 0;
            uint256 _newShare = 0;
            for(uint8 i = 0; i < 6; i++){
                if(users[msg.sender].rank - 1 == i){
                    _rankShare = ranksFunds[i];
                    break;
                }
            }
            if(users[msg.sender].volumepoints.rankSharesl[_rank] < _rankShare){
                _newShare = _rankShare - users[msg.sender].volumepoints.rankSharesl[_rank];
                users[msg.sender].volumepoints.rankSharesl[_rank] += _newShare; 
                uint256 _myShare = _newShare / rankedUsers[_rank].length;
                users[msg.sender].finance.earned += _myShare;
                users[msg.sender].finance.shearned += _myShare;
                require(getContractUSDBalance() >= _myShare * 3, 'NoLiquidity');
                users[msg.sender].finance.withdrawn += _myShare;
                _usdToken.transfer(msg.sender, _myShare);
                emit onEarningsWithdrawan(msg.sender, _myShare);
            }
        }

        function getMintAmount(uint256 _allocation, uint256 _checkpoint) private view returns(uint256 _mintAmount){
            uint256 _daysPassed = (block.timestamp - _checkpoint) / TIME_STEP >= VMINT_TERM ? VMINT_TERM : (block.timestamp - _checkpoint) / TIME_STEP;
            if(_daysPassed > 0){
                for(uint256 i = 1; i <= _daysPassed; i++){
                    uint256 _amountToMint = _allocation * DAILY_MINT / DIV;
                    _allocation -= _amountToMint;
                    _mintAmount += _amountToMint;
                }
            }
        }

        function getXer(uint256 _value) public view returns(uint8){
            for(uint8 i = 0; i < 6; i++){
                if(i < 5 && _value >= VMINT_ROX[i] && _value < VMINT_ROX[i+1]){
                    return i;
                }
                if(i == 5 && _value >= VMINT_ROX[i]){
                    return i;
                }
            }
            return 0;
        }

        function getUserAvailable(address userAddress) public view returns (uint256) {
            // returns available amount to mint
            return getMintAmount(users[userAddress].minter.pclaimed, users[userAddress].minter.checkpoint);
        }

        function getUserFinance(address userAddress) public view returns(
            uint256 _spent, uint256 _earnings, uint256 _withdrawn, uint256 _earned, 
            uint256 _dcearned, uint256 _icearned, uint256 shearned){
                _spent = users[userAddress].finance.spent;
                _earnings = users[userAddress].finance.earnings;
                _withdrawn = users[userAddress].finance.withdrawn;
                _earned = users[userAddress].finance.earned;
                _dcearned = users[userAddress].finance.dcearned;
                _icearned = users[userAddress].finance.icearned;
                shearned = users[userAddress].finance.shearned;
        }

        function getUserMinter(address userAddress) public view returns(uint256 _purchased, uint256 _pclaimed, uint256 _claimed, uint256 _bonus, uint256 _checkpoint){
            _purchased = users[userAddress].minter.purchased;
            _pclaimed = users[userAddress].minter.pclaimed;
            _claimed = users[userAddress].minter.claimed;
            _bonus = users[userAddress].minter.bonus;
            _checkpoint = users[userAddress].minter.checkpoint;
        }

        function getContractUSDBalance() public view returns (uint256) {
            return _usdToken.balanceOf(address(this));
        }

        function getContractTokenBalance() public view returns (uint256) {
            return token.balanceOf(address(this));
        }

        function viewUserReferral(address _user) external view returns(address[] memory) {
            return users[_user].referrals;
        }

        function viewUserTeam(address _user) external view returns(address[] memory) {
            return users[_user].myTeam;
        }

        function viewTeamCount(address _user) external view returns(uint256[6] memory) {
            return users[_user].teamCount;
        }

        function viewRewardSystem(address _user) external view returns(uint256 _personal, uint256 _direct, uint256 _team, uint256 _directAwarded, uint256 _teamAwarded) {
            _personal = users[_user].volumepoints.personal;
            _direct = users[_user].volumepoints.direct;
            _team = users[_user].volumepoints.team;
            _directAwarded = users[_user].volumepoints.directAwarded;
            _teamAwarded = users[_user].volumepoints.teamAwarded;
        }

        function getTokenAmount(address _tokenA, address _tokenB, uint _amountIn) public view returns(uint[] memory amounts){
            address[] memory path = new address[](2);
            path[0] = _tokenA;
            path[1] = _tokenB;
            amounts = uniswapV2Router.getAmountsOut(_amountIn, path);
            return amounts;
        }

        function getTokenPriceUSD() public view returns(uint256){
            address[] memory path = new address[](2);
            path[0] = address(token);
            path[1] = address(_usdToken);
            uint[] memory amounts = uniswapV2Router.getAmountsOut(1 ether, path);
            return amounts[1];
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

        function claimSecuredCYFG() public{
            // prevent this claims after the 31st December
            require(block.timestamp <= 1672527599, 'notAllowed'); // cannot claim after this date.
            uint256 _tokenAmount = CYFG_OLD.balanceOf(msg.sender);
            require(_tokenAmount > 0, 'NothingToClaim'); // Most Have old Old Tokens
            require(CYFG_OLD.transferFrom(msg.sender, deadAddress, _tokenAmount), 'FailedToTransfer'); // Burn Token
            token.safeTransfer(msg.sender, _tokenAmount);
        }

        function getStarted(IERC20 _token, address _bscyf, address _marketing) public {
            require(msg.sender == dev_ && !started, 'Unauthorized!');
            token = _token;
            marketing = payable(_marketing);
            farmwallet = payable(_bscyf);
            // addPairLiquidity(4500 ether, 9e26);
            addPairLiquidity(100 ether, 134e25);
            started = true;
        }

        receive() external payable {}

        // to account for volume and bonuses
        function getUSDvalueFromBNB(uint256 _amount) private view returns(uint256 _bsudValue){
            (int bnbPrice, uint8 decimals_) = getLatestPrice(); // 1BNB in USD
            _bsudValue = _amount * uint256(bnbPrice) / 10 ** decimals_;
        }
    }

    contract CYFpreminterclaims{
        struct Sminters{
            bool claimed_private;
            bool claimed_presale;
            bool claimed_public;
            bool claimed_farm;
            bool claimed_one;
            bool claimed_five;
            uint256 allocation;
            uint256 dateClaimed;
        }

        mapping(address => Sminters) public minters;
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