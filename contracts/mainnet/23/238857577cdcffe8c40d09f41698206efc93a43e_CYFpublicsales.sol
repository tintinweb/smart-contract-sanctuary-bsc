/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

// SPDX-License-Identifier: Unlicensed
    pragma solidity 0.8.17;

    interface BSCYieldFarm {
        function getUserReferrer(address userAddress) external view returns(address);
        function getUserInfo(address userAddress, uint8 tokenID) external view returns(uint256 totalDeposit, uint256 totalHarvested, uint256 totalReferrals);
    }

    interface IUniswapV2Router01 {
       function WETH() external pure returns (address);
    }

    interface IUniswapV2Router02 is IUniswapV2Router01 {
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

    interface IERC20 {
        function balanceOf(address owner) external view returns (uint256);
        function allowance(address owner, address spender) external view returns (uint256);

        function approve(address spender, uint256 value) external returns (bool);
        function transfer(address to, uint256 value) external returns (bool);
        function transferFrom(address from, address to, uint256 value) external returns (bool);

        event Approval(address indexed owner, address indexed spender, uint256 value);
        event Transfer(address indexed from, address indexed to, uint256 value);
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

    contract CYFpublicsales is ReentrancyGuard, PriceConsumerV3{

        BSCYieldFarm public BSCYFv1 = BSCYieldFarm(0xFd6240Ba2174b56E4d7d66231Df1B7CA07417434);
        BSCYieldFarm public BSCYFv2 = BSCYieldFarm(0x1b74FAcC863672294A2A031e20995c9E7d6082cD);
        BSCYieldFarm public BSCYFv3 = BSCYieldFarm(0x23f647304B48ec44477cF8f2C60e3Eab46D6321A);
        BSCYieldFarm public BSCYFv4 = BSCYieldFarm(0xdA95522baC148AFACD69D694FC5132eE97AA3e62);
        // BSCYieldFarm public BSCYFv4 = BSCYieldFarm(0x091f40132eB7D35fdbE678106b8222437EA77533); // testnet

        uint256 public constant MIN_PURCHASE_BNB = 0.1 ether;
        uint256 public constant MIN_PURCHASE_USD = 25 ether; // $25 busd
        uint256 public constant TOKEN_START_PRICE_BNB = 0.000000009 ether; 
        uint256 public constant TOKEN_START_PRICE_USD = 0.0000024122 ether;
        uint256 public constant TOKEN_DECIMALS = 18;
        uint256 public _totalPuchase; // total token purchase
        uint256 public _totalTokenAllocated; // total allocation
        uint256 public _totalBNB;
        uint256 public _totalBUSD;
        uint256 public _totalBNBcapitalized;

        uint256[5] internal CONTEST_REWARDS = [6000 ether, 4000 ether, 2500 ether, 1500 ether, 1000 ether]; // all paid in BUSD
        uint256 internal CONTEST_TARGET = 3000 ether; // in BNB or 8100000 ether in BUSD [ALL BUSD PURCHASED MUST BE TAGGED A BNB VALUE]
        uint256[5] internal CONTEST_QUALIFICATIONS = [500 ether, 350 ether, 150 ether, 90 ether, 75 ether]; // in BNB [ALL BUSD PURCHASED MUST BE TAGGED A BNB VALUE]
        uint256[5] internal CONTEST_REF_QUALIFICATIONS = [30, 20, 15, 10, 10];
        uint256 internal constant CONTESTANT_REQUIRED = 50;
        uint256 internal constant CONTESTANT_ENROLL = 5 ether;

        uint256 internal constant PERCENT_DIVIDER = 1000;
        uint256 internal constant LIQUIDITY = 720;
        uint256 internal constant COMMISSION = 50;
        uint256 internal constant CONTESTRESERVE = 18; // Reserves in BUSD
        uint256 internal constant DEV_FEE = 22;
        uint256 internal constant MARKETING_FEE = 40;
        uint256 internal constant YIELDFARMING = 150;

        address internal dev_;
        address internal immutable marketing_;
        address internal immutable liquidity_;
        address internal immutable yieldfarm_ = address(BSCYFv4);
        IERC20 internal immutable _usdToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        // IERC20 internal immutable _usdToken = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7); // testnet
        IUniswapV2Router02 public immutable uniswapV2Router;

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

        // leaders' board.
        bool[5] public contestWINNERSpicked;

        mapping (address => Players) public players;
        mapping (address => bool) public contestants;
        address[] public contestantsList;
        mapping (uint256 => address) public leadersBoard;
        mapping (address => bool) public accountForThree;
        mapping (address => bool) public accountForFive;

        constructor(address _marketing, address _liquidity) {
            dev_ = msg.sender;
            marketing_ = _marketing;
            liquidity_ = _liquidity;

            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // testnet
            uniswapV2Router = _uniswapV2Router;
        }

        function drawWinner() public {
            require(contestantsList.length >= CONTESTANT_REQUIRED && _totalBNBcapitalized >= CONTEST_TARGET / 1000000, 'CannotPickWinners');
            // condition to be first winner [_refQualified5 >= 20 && _teamVolumeBNB >= CONTEST_QUALIFICATIONS[0]
            for(uint256 i = 0; i < 5; i++){
                if(leadersBoard[i] == address(0)){
                    break;
                }
                if(!contestWINNERSpicked[i] && players[leadersBoard[i]]._teamVolumeBNB >= CONTEST_QUALIFICATIONS[i] && ((i == 0 && players[leadersBoard[i]]._refQualified5 >= CONTEST_REF_QUALIFICATIONS[i]) 
                    || (i > 0 && players[leadersBoard[i]]._refQualified3 >= CONTEST_REF_QUALIFICATIONS[i]))){
                    contestWINNERSpicked[i] = true;
                    // send the reward 
                    require(_usdToken.balanceOf(address(this)) >= CONTEST_REWARDS[i], 'NoSufficientFunds');
                    require(_usdToken.transfer(leadersBoard[i], CONTEST_REWARDS[i]), 'TransferFailed'); 
                }
            }
        }

        function updateLeadersBoard(address _player) private {
            // This function updates the Leaders Board
            // Ranking based on team volume
            if(contestants[_player]){
                for(uint256 i = 0; i < 10; i++){
                    if(leadersBoard[i] == _player){
                        break;
                    }
                    else if(leadersBoard[i] == address(0)){
                        leadersBoard[i] = _player;
                        break;
                    }
                    if(players[_player]._teamVolumeBNB > players[leadersBoard[i]]._teamVolumeBNB){
                        for(uint256 p = i + 1; p < 5; p++){
                            if(leadersBoard[p] == _player){
                                for(uint256 k = p; k <= 5; k++){
                                    leadersBoard[k] = leadersBoard[k + 1];
                                }
                                break;
                            }
                        }

                        for(uint256 p = 4; p > i; p--) {
                            leadersBoard[p] = leadersBoard[p - 1];
                        }

                        leadersBoard[i] = _player;

                        break;
                    }
                }
            }
        }

        function allocateBonus(address _player, uint256 allocation_, uint256 _multipler) private{
            if(_multipler > 0){
                uint256 bonus = allocation_ * _multipler / PERCENT_DIVIDER;
                players[_player]._allocation += bonus * 10 ** TOKEN_DECIMALS;
                players[_player]._allocatedBonus += bonus * 10 ** TOKEN_DECIMALS;
                _totalTokenAllocated += bonus * 10 ** TOKEN_DECIMALS;
            }
        }

        function allocateToken(uint256 allocation_) private{
            players[msg.sender]._allocation += allocation_ * 10 ** TOKEN_DECIMALS;
            _totalPuchase += allocation_ * 10 ** TOKEN_DECIMALS;
            _totalTokenAllocated += allocation_ * 10 ** TOKEN_DECIMALS;
        }

        function updatePlayerVolume(address _player, uint256 _amount, uint256 _allocation) private {
            players[_player]._teamVolumeBNB += _amount;
            (uint256 _multiplier, uint8 l) = bonusPerVolume(_player);
            if(_multiplier > 0 && !players[_player]._volumeBonus[l]){
                players[_player]._volumeBonus[l] = true;
                allocateBonus(_player, _allocation, _multiplier);
            }
            
            address _upline = players[_player]._sponsor;
            for(uint8 i = 0; i < 5; i++){
                if(_upline != address(0)){
                    players[_upline]._teamVolumeBNB += _amount;
                    (uint256 _multiplier2, uint8 i2) = bonusPerVolume(_upline);
                    if(_multiplier2 > 0 && !players[_upline]._volumeBonus[i2]){
                        players[_upline]._volumeBonus[i2] = true;
                        allocateBonus(_upline, _allocation, _multiplier2);
                    }
                    _upline = players[_upline]._sponsor;
                }
            }
        }

        // this function will get the bnb value out of every bsud pruchase 
        // to account for volume and bonuses
        function getBNBvalueFromBUSD(uint256 _amount) private view returns(uint256 _bnbValue){
            (int bnbPrice, uint8 decimals_) = getLatestPrice(); // 1BNB in USD
            _bnbValue = _amount * 10 ** 18 / ((uint256(bnbPrice) / 10 ** decimals_) * 10 ** 18);
        }

        function bonusePerPurchase(uint256 _amount) public pure returns(uint256 _multiplier){
            if(_amount >= 1 ether && _amount <= 5 ether){
                _multiplier = 20;
            }
            else if(_amount >= 5.1 ether && _amount <= 10 ether){
                _multiplier = 40;
            }
            else if(_amount >= 10.1 ether && _amount <= 25 ether){
                _multiplier = 70;
            }
            else if(_amount >= 25.1 ether && _amount <= 50 ether){
                _multiplier = 100;
            }
            else if(_amount >= 50 ether){
                _multiplier = 150;
            }
        }

        function bonusPerVolume(address _player) public view returns(uint256 _multiplier, uint8 i){
            uint256 _playerVolume = players[_player]._teamVolumeBNB;
            if(_playerVolume >= 25 ether && _playerVolume <= 50 ether){
                _multiplier = 10;
                i = 0;
            }
            else if(_playerVolume >= 50.1 ether && _playerVolume <= 100 ether){
                _multiplier = 30;
                i = 1;
            }
            else if(_playerVolume >= 100.1 ether && _playerVolume <= 250 ether){
                _multiplier = 70;
                i = 2;
            }
            else if(_playerVolume >= 250.1 ether){
                _multiplier = 100;
                i = 3;
            }
        }

        function swapAndLiquify(uint256 _amount) private{
            uint256 initialBalance = address(this).balance;
            swapTokensForEth(_amount);

            // how much BNB did we just get from this swap?
            // Send only the Amount Received
            // Remaining BUSD values serves for Contest...
            uint256 amountReceived = address(this).balance - initialBalance;
            
            payable(yieldfarm_).transfer(amountReceived);
        }

        function dispatach(uint256 _amount, bool _bnb) private{
            // liquidity funds 72.5%
            uint256 _liquidityfunds = _amount * LIQUIDITY / PERCENT_DIVIDER;
            // pay devfee 2.2%
            uint256 _devfee = _amount * DEV_FEE / PERCENT_DIVIDER;
            // marketing fee 4%
            uint256 _marketingfunds = _amount * MARKETING_FEE / PERCENT_DIVIDER;
                // swap for bnb & Send BNB to the Farm 15%
            uint256 _yieldfarmsupport = _amount * YIELDFARMING / PERCENT_DIVIDER;
            // Commission 5%
            uint256 _commission = _amount * COMMISSION / PERCENT_DIVIDER;
            // 1.8% for Constest
            uint256 _contestAmount = _amount * CONTESTRESERVE / PERCENT_DIVIDER;
            if(_bnb){
                payable(liquidity_).transfer(_liquidityfunds);
                payable(dev_).transfer(_devfee);
                payable(marketing_).transfer(_marketingfunds);
                payable(yieldfarm_).transfer(_yieldfarmsupport);
                payable(players[msg.sender]._sponsor).transfer(_commission);
                // Swap BNB TO BUSD for contest reward.
                swapEthForTokens(_contestAmount);
            }
            else{
                _usdToken.transfer(liquidity_, _liquidityfunds);
                _usdToken.transfer(dev_, _devfee);
                _usdToken.transfer(marketing_, _marketingfunds);
                _usdToken.transfer(players[msg.sender]._sponsor, _commission);
                swapAndLiquify(_yieldfarmsupport);
            }
            
        }

        function registerPlayer(address _refBy) internal{
            if(players[msg.sender]._sponsor == address(0)){
                address _upline = getUpline();
                // address _upline = _refBy; // testing purpose
                if(_upline == dev_ && _refBy != dev_ && _refBy != msg.sender){
                    // verify if _refBy has purchased 
                    if(players[_refBy]._allocation > 0){
                        _upline = _refBy;
                    }
                    // or is a staker
                    else if(isStaker(_refBy)){
                        _upline = _refBy;
                    }
                }
                else{
                    _upline = dev_;
                }
                Players storage player = players[msg.sender];
                player._sponsor = _upline;
                players[_upline]._refCount++;
            }
        }

        // Buy with BNB
        function buyCYFBNB(address _refBy) public payable{
            uint256 _amount = msg.value;
            require(_amount >= MIN_PURCHASE_BNB, 'MinRequired');
            registerPlayer(_refBy);
            dispatach(_amount, true);
            uint256 allocation_ = _amount / TOKEN_START_PRICE_BNB;
            allocateToken(allocation_);
            uint256 _multiplier = bonusePerPurchase(_amount);
            allocateBonus(msg.sender, allocation_, _multiplier);
            updatePlayerVolume(msg.sender, _amount, allocation_);
            players[msg.sender]._myTotalpurchase += _amount;
            // Most Account only one time....
            if(players[msg.sender]._myTotalpurchase >= 3 ether && !accountForThree[msg.sender]){
                accountForThree[msg.sender] = true;
                players[players[msg.sender]._sponsor]._refQualified3++;
            }
            if(players[msg.sender]._myTotalpurchase >= 5 ether && !accountForFive[msg.sender]){
                accountForFive[msg.sender] = true;
                players[players[msg.sender]._sponsor]._refQualified5++;
            }

            if(players[msg.sender]._myTotalpurchase >= CONTESTANT_ENROLL && !contestants[msg.sender]){
                contestants[msg.sender] = true;
                contestantsList.push(msg.sender);
            }
            _totalBNB += _amount;
            _totalBNBcapitalized += _amount;
            updateLeadersBoard(msg.sender);
            if(contestantsList.length >= CONTESTANT_REQUIRED && _totalBNBcapitalized >= CONTEST_TARGET){
                drawWinner();
            }
        }

        // Buy with BUSD
        function buyCYFUSD(uint256 _amount, address _refBy) public{
            require(_amount >= MIN_PURCHASE_USD, 'MinRequired');
            registerPlayer(_refBy);
            require(_usdToken.transferFrom(msg.sender, address(this), _amount));
            dispatach(_amount, false);
            uint256 allocation_ = _amount / TOKEN_START_PRICE_USD;
            allocateToken(allocation_);
            uint256 bnbValue = getBNBvalueFromBUSD(_amount);
            uint256 _multiplier = bonusePerPurchase(bnbValue);
            allocateBonus(msg.sender, allocation_, _multiplier);
            updatePlayerVolume(msg.sender, bnbValue, allocation_);
            players[msg.sender]._myTotalpurchase += bnbValue;
            if(players[msg.sender]._myTotalpurchase >= CONTESTANT_ENROLL && !contestants[msg.sender]){
                contestants[msg.sender] = true;
                contestantsList.push(msg.sender);
            }
            // Most Account only one time....
            if(players[msg.sender]._myTotalpurchase >= 3 ether && !accountForThree[msg.sender]){
                accountForThree[msg.sender] = true;
                players[players[msg.sender]._sponsor]._refQualified3++;
            }
            if(players[msg.sender]._myTotalpurchase >= 5 ether && !accountForFive[msg.sender]){
                accountForFive[msg.sender] = true;
                players[players[msg.sender]._sponsor]._refQualified5++;
            }

            _totalBUSD += _amount;
            _totalBNBcapitalized += bnbValue;
            updateLeadersBoard(msg.sender);
            if(contestantsList.length >= CONTESTANT_REQUIRED && _totalBNBcapitalized >= CONTEST_TARGET){
                drawWinner();
            }
        }
        
        // check if user is staker then get upline
        function getUpline() internal view returns(address){
            if(isStaker(msg.sender)){
                address _upline = BSCYFv1.getUserReferrer(msg.sender);
                if(_upline == address(0)){
                    _upline = BSCYFv2.getUserReferrer(msg.sender);
                    if(_upline == address(0)){
                        _upline = BSCYFv3.getUserReferrer(msg.sender);
                        if(_upline == address(0)){
                            _upline = BSCYFv4.getUserReferrer(msg.sender);
                        }
                    }
                }
                if(_upline == address(0) || _upline == address(0x493323C1f45caC0ceC5C151347681CA969De71AE)){
                    _upline = dev_;
                }
                return _upline;
            }
            else{
                return dev_;
            }
        }

        function isStaker(address _user) public view returns(bool _staker){
            (uint256 _deposit, , ) = BSCYFv4.getUserInfo(_user, 0);
            if(_deposit > 0){
                return true;
            }
            
            (_deposit, , ) = BSCYFv3.getUserInfo(_user, 0);
            if(_deposit > 0){
                return true;
            }
            
            (_deposit, , ) = BSCYFv2.getUserInfo(_user, 0);
            if(_deposit > 0){
                return true;
            }
                
            (_deposit, , ) = BSCYFv1.getUserInfo(_user, 0);
            if(_deposit > 0){
                return true;
            }            
            else{
                return false;
            }
        }
           
        function swapTokensForEth(uint256 tokenAmount) private {
            _usdToken.approve(address(uniswapV2Router), tokenAmount);

            address[] memory path = new address[](2);
            path[0] = address(_usdToken);
            path[1] = uniswapV2Router.WETH();
    
            // make the swap
            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // accept any amount of ETH
                path,
                address(this),
                block.timestamp
            );
        }

        function swapEthForTokens(uint256 etherAmount) private{
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

        receive() external payable {}
    }