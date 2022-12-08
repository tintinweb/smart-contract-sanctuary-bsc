/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: Unlicensed
    pragma solidity 0.8.17;
    // give airdrop of 5000000 => on $5 claim
    // give airdrop of 1000000 => on claim without $5
    // cannot claim airdrop more than 1 time
    // buyers of tokens from private sale
    // buyers of token from presale
    // buyers of token from public sale [various contracts]
    // Enable BSCYFv4 to convert all they have into tokens
    // Enable BSCYFv5 to buy using their account.

    contract PubliccSales {
        struct Players{
            uint256 _id;
            address _sponsor;
            uint256 _refCount; // counts only direct referrals
            uint256 _myTotalpurchase; // use to qualify
            uint256 _allocation; // amount to be claimed.
            uint256 _allocatedBonus; // informative [bonus received]
            uint256 _teamVolumeBNB; // converts busd to bnb and counts up to 5 levels
            uint256 _refQualified3; // counts refs with 3bnb
            uint256 _refQualified5; // counts refs with 5bnb
            bool[4] _volumeBonus; // this account the 4 stages of bonus per volume.
        }
        mapping (address => Players) public players;
    }

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

    contract CYFpreminterclaims is ReentrancyGuard {
        address immutable liquidity_ = 0xefddD31b74c1Fd5615aE25E8d19Fac11913edC41;

        uint256 public constant TOKEN_START_PRICE_USD = 0.000005 ether; // 0.000005 BUSD

        uint256 public constant TOKEN_START_PRICE_BNB = 0.000000045 ether; 

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

        // farming contracts [v4 has presales]
        BSCYieldFarm internal immutable BSCYFv1 = BSCYieldFarm(0xFd6240Ba2174b56E4d7d66231Df1B7CA07417434);
        BSCYieldFarm internal immutable BSCYFv2 = BSCYieldFarm(0x1b74FAcC863672294A2A031e20995c9E7d6082cD);
        BSCYieldFarm internal immutable BSCYFv3 = BSCYieldFarm(0x23f647304B48ec44477cF8f2C60e3Eab46D6321A);
        BSCYieldv4 internal immutable BSCYFv4 = BSCYieldv4(0xdA95522baC148AFACD69D694FC5132eE97AA3e62);
        // public sales contract
        PubliccSales internal PUBLICSALEv1 = PubliccSales(0xc2756a7F5eb4E41c4c3c96C1E98b047E55d10847);
        PubliccSales internal PUBLICSALEv2 = PubliccSales(0xd4A6E51fc325311acC03C3539d4Ea445f755e440);
        PubliccSales internal PUBLICSALEv3 = PubliccSales(0x934Ae02Cd40a767956C9492Dc823c7df6F999E86);

        CYFpreminterclaims1 internal PREVIOUS = CYFpreminterclaims1(0xA4Ec314065AaF7682DadcCa5a09ABa8a2dffc4E1); // claim v1

        CYFpreminterclaims internal PREVIOUS_01 = CYFpreminterclaims(0x2254FFa60a3414123071Ece3FAC9E6fF282Ddf0d); // claim v2

        // private sale participants
        mapping(address => uint256) internal PrivateSaleBuyers;

        mapping(address => Sminters) public minters;
        
        constructor() {
            PrivateSaleBuyers[0xed2De0d597888c669747b6fa19D6d62148F55D57] = 25000 ether;
            PrivateSaleBuyers[0x3411a187F117e52a9b0B921B6F196a0fb970Bb56] = 25000 ether;
            PrivateSaleBuyers[0xf6E6E9d01fDe07B714C386f9535f7A44cD5c897d] = 20000 ether;
            PrivateSaleBuyers[0x898628E7Fbb0C78663d28A8B529B9BcfaF1bA7C6] = 10000 ether;
            PrivateSaleBuyers[0xA2eb0A1Cfbf2a304692f340850a83fD1173Bcc42] = 10000 ether;
            PrivateSaleBuyers[0x0cca22eb63E07D81EF94eAAC3069bC8763893ABD] = 5000 ether;
            PrivateSaleBuyers[0xbdFDaC2c6a8765132d7f0F01aE5182310b700c38] = 5000 ether;
            PrivateSaleBuyers[0x8Db87A79Eed898edaeB10F5576df01844057C60D] = 5000 ether;
            PrivateSaleBuyers[0x90B5412D3dB0a4a5f532F6f742D183239620f2eD] = 5000 ether;
            PrivateSaleBuyers[0xFcdE99ACaFaaF16E4a9af095ceA92eb8Feca17f7] = 5000 ether;
            PrivateSaleBuyers[0x8bd8823bfe782E5BCCFA2Ba449149111D9D0E5B0] = 4200 ether;
            PrivateSaleBuyers[0x6De9f7c9BF6A5833dc8804eC69Fd2688E5805d73] = 4005 ether;
            PrivateSaleBuyers[0xAFb95a58A42434751F5C93B5b8C73e8A3774A9c1] = 4000 ether;
            PrivateSaleBuyers[0x47F0713ca3FaD32020E6a0230d56a6D4CC0C9965] = 2343 ether;
        }

        function getAllocation() private view returns(uint256){
            // check v1 claim 
            (, , , , , , , uint256 _allocation,) = PREVIOUS.minters(msg.sender);
            // check v2 claim
            (, , , , , , uint256 _allocation2,) = PREVIOUS_01.minters(msg.sender);
            return _allocation + _allocation2;
        }

        // Can claim only one time
        function claimMinterPack() public{
            uint256 allocation;
            address _user = msg.sender;

            require(msg.sender != address(0x493323C1f45caC0ceC5C151347681CA969De71AE), 'Banned!');
            // check v1 claim 
            (bool claimed_private, bool claimed_presale, bool claimed_public, bool claimed_farm, bool claimed_one, , , ,) = PREVIOUS.minters(msg.sender);
            // check v2 claim
            (bool claimed_private2, bool claimed_presale2, bool claimed_public2, bool claimed_farm2, bool claimed_one2, , ,) = PREVIOUS_01.minters(msg.sender);

            if(!claimed_private && !claimed_private2 && !minters[_user].claimed_private){
                if(PrivateSaleBuyers[_user] > 0){
                    allocation += ( PrivateSaleBuyers[_user] / (TOKEN_START_PRICE_USD / 5) ) * 10 ** 18;
                }
            }
            // Get allocation from presale
            if(!minters[_user].claimed_presale && !claimed_presale && !claimed_presale2){
                allocation += isPresaleBuyer(_user);
            }
            // Get Allocation from Public Sales
            if(!minters[_user].claimed_public && !claimed_public2 && !claimed_public){
                allocation += isPublicsaleBuyer(_user);
            }

            bool _isStaker = isStaker(_user);

            // prevent this claim after 31st january 
            uint256 _deadline = 1675209599;
            if(_isStaker && !claimed_one && !claimed_one2 && !minters[_user].claimed_one && block.timestamp <= _deadline){
                allocation += 1000000 * 10 ** 18;
                if(!minters[_user].claimed_farm && !claimed_farm && !claimed_farm2){
                    allocation += claimFromStake(_user);
                }
            }

            // get User's allocation
            allocation += getAllocation();

            minters[_user].claimed_presale = true;
            minters[_user].claimed_one = true;
            minters[_user].claimed_public = true;
            minters[_user].claimed_private = true;
            minters[_user].claimed_farm = true;

            minters[_user].dateClaimed = block.timestamp;
            minters[_user].allocation += allocation;
        }

        function specialBuy() external payable {
            // get one time special $5 offre [ 5m CYF minter pack ]
            address _user = msg.sender;
            require(msg.sender != address(0x493323C1f45caC0ceC5C151347681CA969De71AE), 'Banned!');
            (, , , , ,bool claimed_five, , ,) = PREVIOUS.minters(msg.sender);
            require(!claimed_five, 'AlreadyClaimed');
            require(!minters[_user].claimed_five, 'NotAllowed');
            require(msg.value >= 0.019 ether, 'insufficientAmount');
            minters[_user].claimed_five = true;
            minters[_user].dateClaimed = block.timestamp;
            minters[_user].allocation += 5000000 * 10 ** 18;
            payable(liquidity_).transfer(msg.value);
        }

        function claimFromStake(address _user) private view returns(uint256){
            // Prevent Staked from after 1669030892
            uint256 _lastCheckPoint = 1669030892;
            uint256 _checkpoint = checkNewV4De(_user);
            if(_checkpoint > _lastCheckPoint){
                return 0;
            }
            (uint256 _deposit, , ) = BSCYFv4.getUserInfo(_user, 0); // v4
            if(_deposit > 0){
                uint256 totalAmount = 0;
                // Get Active Staked + Available
                for(uint8 i = 0; i < 5; i++){
                    (, uint256 _dividend) = BSCYFv4.getUDividend(_user, 0, i);
                    (, uint256 _active, uint256 _pendingHarvest, , , ,) = BSCYFv4.myStakes(_user, 0, i);
                    totalAmount += _active + _pendingHarvest + _dividend;
                }
                // Add Pending Affiliate Bonus
                uint256 _bonus = BSCYFv4.getUserReferralBonus(_user, 0);
                if(_bonus > 0){
                    totalAmount += _bonus;
                }
                if(totalAmount > 0){
                    return (totalAmount / TOKEN_START_PRICE_BNB) * 10 ** 18;
                }
                return 0;
            }
            else{
                return 0;
            }
        }

        // test Veiwing if user has claimed or not [should claim only from v4]
        function isStaker(address _user) private view returns(bool){
            if(_user == address(0x493323C1f45caC0ceC5C151347681CA969De71AE)){
                return false;
            }

            (uint256 _deposit4, , ) = BSCYFv4.getUserInfo(_user, 0); // v4

            (uint256 _deposit3, , ) = BSCYFv3.getUserInfo(_user, 0); // v3
            
            (uint256 _deposit2, , ) = BSCYFv2.getUserInfo(_user, 0); // v2

            (uint256 _deposit1, , ) = BSCYFv1.getUserInfo(_user, 0); // v1
            
            if(_deposit4 > 0 || _deposit3 > 0 || _deposit2 > 0 || _deposit1 > 0){
                return true;
            }
            
            return false;
        }

        function hasNewDeposits(address _user, uint256 _index) internal view returns(uint256){
            try BSCYFv4.deposits(_user, address(0), _index) returns(uint8, uint256, uint256 _start) {
                return _start;
            }catch (bytes memory){
                return 0;
            }
        }

        function checkNewV4De(address _user) public view returns(uint256){
            uint256 _start;
            for(uint256 i = 100; i >= 0; i--){
                _start = hasNewDeposits(_user, i);
                if(_start > 0){
                    return _start;
                }
            }
            return 0;
        }

        // Get Presale Sales Allocation
        function isPresaleBuyer(address _user) private view returns(uint256){
            uint256 _allocation = BSCYFv4._tokensPurchased(_user);
            return _allocation * 267; // presale buyers have x267 allocation
        }

        // Get Public Sales Allocation
        function isPublicsaleBuyer(address _user) private view returns(uint256 _allocation){
            (, , , ,uint256 _allocation1, , , ,) = PUBLICSALEv1.players(_user);
            (, , , ,uint256 _allocation2, , , ,) = PUBLICSALEv2.players(_user);
            (, , , ,uint256 _allocation3, , , ,) = PUBLICSALEv3.players(_user);
            _allocation = _allocation1 + _allocation2 + _allocation3;
        }
    }
   
    contract BSCYieldFarm {
        using SafeMath for uint256;

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

        struct Deposits {
            uint8 plan;
            uint256 amount;
            uint256 start;
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

        mapping(uint256 => Tokens) public tokens;
        
        mapping(address => mapping(address => toDeposits)) public todeposits;

        mapping(address => mapping(address => Deposits[])) public deposits;

        constructor() {}

        function getUserTotalHarvested(address userAddress, uint256 tokenID) internal view returns (uint256) {
            Tokens memory token = tokens[tokenID];
            return todeposits[userAddress][token.token].harvested;
        }

        function getUserTotalDeposits(address userAddress, uint256 tokenID) internal view returns(uint256 amount) {
            Tokens memory token = tokens[tokenID];
            for (uint256 i = 0; i < deposits[userAddress][token.token].length; i++) {
                amount = amount.add(deposits[userAddress][token.token][i].amount);
            }
        }

        function getUserTotalReferrals(address userAddress) public view returns(uint256) {
            return users[userAddress].levels[0]+users[userAddress].levels[1]+users[userAddress].levels[2]+users[userAddress].levels[3]+users[userAddress].levels[4];
        }

        function getUserInfo(address userAddress, uint256 tokenID) public view returns(uint256 totalDeposit, uint256 totalHarvested, uint256 totalReferrals) {
            return(getUserTotalDeposits(userAddress, tokenID), getUserTotalHarvested(userAddress, tokenID), getUserTotalReferrals(userAddress));
        }
    }

    contract BSCYieldv4 {
        using SafeMath for uint256;

        uint256 constant internal PERCENTS_DIVIDER = 10000;
        uint256 constant internal TIME_STEP = 1 days; // set to seconds only for testing purposes

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

        struct toDeposits{
            uint256 checkpoint;
            uint256 bonus;
            uint256 totalBonus;
            uint256 harvested;
            uint256 pendingFunds;
        }

        struct Deposits {
            uint8 plan;
            uint256 amount;
            uint256 start;
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
        
        mapping(address => mapping(address => toDeposits)) public todeposits;

        mapping(address => mapping(address => Deposits[])) public deposits;

        mapping(address => mapping(uint8 => Farming[5])) public myStakes;

        constructor() {}

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

        function getUserTotalHarvested(address userAddress, uint256 tokenID) internal view returns (uint256) {
            Tokens memory token = tokens[tokenID];
            return todeposits[userAddress][token.token].harvested;
        }

        function getUserReferralBonus(address userAddress, uint256 tokenID) public view returns(uint256) {
            Tokens memory token = tokens[tokenID];
            return todeposits[userAddress][token.token].bonus;
        }

        function getUserTotalReferrals(address userAddress) public view returns(uint256) {
            return users[userAddress].levels[0]+users[userAddress].levels[1]+users[userAddress].levels[2]+users[userAddress].levels[3]+users[userAddress].levels[4];
        }

        function gUserTotalDeposits(address userAddress, uint8 tokenID) internal view returns(uint256 totalDeposits) {
            for(uint8 i = 0; i < 5; i++){
                totalDeposits = totalDeposits.add(myStakes[userAddress][tokenID][i].total);
            }
        }

        function getUserInfo(address userAddress, uint8 tokenID) public view returns(uint256 totalDeposit, uint256 totalHarvested, uint256 totalReferrals) {
            return(gUserTotalDeposits(userAddress, tokenID), getUserTotalHarvested(userAddress, tokenID), getUserTotalReferrals(userAddress));
        }
    }

    contract CYFpreminterclaims1{
        struct Sminters{
            bool claimed_private;
            bool claimed_presale;
            bool claimed_public;
            bool claimed_farm;
            bool claimed_one;
            bool claimed_five;
            uint256 allocation_farm;
            uint256 allocation;
            uint256 dateClaimed;
        }

        mapping(address => Sminters) public minters;
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