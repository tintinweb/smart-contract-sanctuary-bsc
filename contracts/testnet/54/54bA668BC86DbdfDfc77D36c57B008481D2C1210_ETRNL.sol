// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "openzeppelin/contracts/token/ERC20/ERC20.sol";
import "openzeppelin/contracts/token/ERC20/Token.sol";
import "openzeppelin/contracts/utils/math/SafeMath.sol";
import "openzeppelin/contracts/utils/Context.sol";
import "openzeppelin/contracts/utils/Address.sol";
import "openzeppelin/contracts/access/Ownable.sol";

contract ETRNL is Context, Ownable, Token {
    using SafeMath for uint256;

    uint256 private startTime;
    uint256 private constant percentDivider = 1000;
    uint256 private constant standardDivider = 100;
    uint256 private constant maxPayoutETRNL = 2500;
    uint256 private constant timeStep = 1 days;
    uint256 private constant priceDivider = 1 ether;
    uint256 private constant initialTokenMint = 100000 ether;  

    uint256 private topDepositTimeStep = 2 days;
    uint256 private lastDepositTimeStep = 12 hours;

    bool private topDepositEnabled;
    bool private lastDepositEnabled;

    uint256 private topDepositCurrentRound = 1;
    uint256 private topDepositPoolBalance;
    uint256 private topDepositCurrentAmount;
    address private topDepositPotentialWinner;
    uint256 private topDepositLastDrawAction;

    address private previousTopDepositWinner;
    uint256 private previousTopDepositRewards;

    uint256 private lastBuyCurrentRound = 1;
    uint256 private lastDepositPoolBalance = 500 ether; //last deposit reward will always start at 500 BUSD
    uint256 private lastDepositLastDrawAction;
    address private lastDepositPotentialWinner;

    address private previousPoolWinner;
    uint256 private previousPoolRewards;

    struct Properties {
        uint256 refDepth;
        uint256 refBonus;
        
        // daily payouts
        uint256 busdTokenDailyPayout;
        uint256 eternalTokenDailyPayout;
        
        // limits
        uint256 tokenStakeFactor;
        uint256 sellCooldown;
        uint256 cutOffTimeStep;
        uint256 maxPayoutCap;
        uint256 maxRewards;
        uint256 minInvestAmount;
        uint256 maxInvestAmount;
        bool airdropEnabled;
        uint256 airdropMinAmount;
        
        // taxes
        uint256 BUSDTokenStakeTax;
        uint256 eternalTokenStakeTax;
        uint256 compoundTax;
        uint256 antiDumpRate;
        uint256 antiDumpTax;
        uint256 sellTax;
        uint256 eternalTokenClaimTax;
        uint256 BUSDTokenClaimTax;
        
        // whale tax
        uint256 depositBracketSize;
        uint256 depositBracketMax;
    }

    struct Stats {
        uint256 totalUsers;
        uint256 totalBUSDTokenStaked;
        uint256 totalEternalTokenStaked;
        uint256 totalCompounded;
        uint256 totalAirdropped;
        uint256 totalRefBonuses;
    }

    struct Stake {
        uint256 checkpoint;
        uint256 totalStaked;
        uint256 lastStakeTime;
        uint256 totalClaimedTokens;
        uint256 unClaimedTokens;
    }

    struct User {
        address referrer;
        uint256 totalStructure;
        uint256 referrals; 
        uint256 totalClaimed;
        uint256 lastSale;
        uint256 totalBonus;
        uint256 referralRoundRobinPosition;
        Stake stakeBUSD; 
        Stake stakeEternal;
    }

    struct Airdrop {
        uint256 totalAirdropsReceived;
        uint256 airdropsReceivedCount;
        uint256 lastAirdropReceived;
        uint256 totalAirdropsSent;
        uint256 airdropsSentCount;
        uint256 lastAirdropSent;
    }

    struct UserBonus {
        uint256 lastDepositBonus;
        uint256 topDepositBonus;
    }
    
    Stats public _stats;
    Airdrop public _airdrops;
    UserBonus public _userBonus;

    Properties private _properties;

    mapping(address => User) private _users;
    mapping(address => Airdrop) private airdrops;
    mapping(address => UserBonus) private usersBonus;

    event NewDeposit(address indexed addr, uint256 amount);
    event NewStake(address indexed addr, uint256 amount);
    event NewAirdrop(address indexed from, address indexed to, uint256 amount, uint256 timestamp);
    event SellToken(address indexed addr, uint256 amountTokens, uint256 amountExchange);
    event ClaimToken(address indexed addr, uint256 amount, uint256 timestamp);
    event LastDepositPayout(uint256 indexed round, address indexed addr, uint256 amount, uint256 timestamp);
    event TopDepositPayout(uint256 indexed round, address indexed addr, uint256 amount, uint256 timestamp);
    
    constructor() {
        BUSDToken = IERC20(busd);
        lastDepositEnabled                  = true;
        topDepositEnabled                   = true;
        startTime                           = block.timestamp; //change this to unixtimestamp for mainnet
        lastDepositLastDrawAction           = startTime;
        topDepositLastDrawAction            = startTime;
        
        _properties.airdropEnabled          = true;
        _properties.sellCooldown            = 7 days;
        _properties.cutOffTimeStep          = 10 days;
        _properties.refDepth                = 5;
        _properties.tokenStakeFactor        = 1;
        _properties.refBonus                = 25;
        _properties.busdTokenDailyPayout    = 10;
        _properties.eternalTokenDailyPayout = 20;
        _properties.depositBracketMax       = 10;
        _properties.compoundTax             = 50;
        _properties.eternalTokenStakeTax    = 50;
        _properties.eternalTokenClaimTax    = 100;
        _properties.BUSDTokenClaimTax       = 100;
        _properties.BUSDTokenStakeTax       = 100;
        _properties.antiDumpRate            = 250;
        _properties.antiDumpTax             = 500;
        _properties.sellTax                 = 200;
        
        _properties.airdropMinAmount        = 1 ether;
        _properties.minInvestAmount         = 25 ether;
        _properties.maxInvestAmount         = 100000 ether;
        _properties.depositBracketSize      = 5000 ether;
        _properties.maxRewards              = 2000 ether;
        _properties.maxPayoutCap            = 100000 ether;

        _mint(msg.sender, initialTokenMint);
    }

    function poolLastDeposit(address userAddress, uint256 amount) private {
        if(!lastDepositEnabled) return;

        uint256 poolShare = amount.mul(5).div(percentDivider); //0.5% of each deposit will be put into the prize pool.

        lastDepositPoolBalance = lastDepositPoolBalance.add(poolShare) > _properties.maxRewards ? 
        lastDepositPoolBalance.add(_properties.maxRewards.sub(lastDepositPoolBalance)) : lastDepositPoolBalance.add(poolShare);
        lastDepositPotentialWinner = userAddress;
        lastDepositLastDrawAction  = block.timestamp;
    }  

    function drawLastDepositWinner() public {
        if(lastDepositEnabled && block.timestamp.sub(lastDepositLastDrawAction) >= lastDepositTimeStep && lastDepositPotentialWinner != address(0)) {
            
            if(BUSDToken.balanceOf(address(this)) < lastDepositPoolBalance) lastDepositPoolBalance = BUSDToken.balanceOf(address(this));

            BUSDToken.transfer(lastDepositPotentialWinner, lastDepositPoolBalance); 
            emit LastDepositPayout(lastBuyCurrentRound, lastDepositPotentialWinner, lastDepositPoolBalance, block.timestamp);
            
            usersBonus[lastDepositPotentialWinner].lastDepositBonus += lastDepositPoolBalance;
            previousPoolWinner         = lastDepositPotentialWinner;
            previousPoolRewards        = lastDepositPoolBalance;
            lastDepositPoolBalance     = 500 ether; //reset to the 500 BUSD base reward
            lastDepositPotentialWinner = address(0);
            lastDepositLastDrawAction  = block.timestamp; 
            lastBuyCurrentRound++;
        }
    }

    function poolTopDeposit(address userAddress, uint256 amount) private {
        if(!topDepositEnabled) return;

        if(amount > topDepositCurrentAmount) {
            topDepositCurrentAmount   = amount;
            topDepositPoolBalance     = topDepositCurrentAmount.mul(20).div(percentDivider); //2% of the deposited amount will be put into the pool.
            topDepositPotentialWinner = userAddress;
        }
    } 

    function drawTopDepositWinner() private {
        if(topDepositEnabled && block.timestamp.sub(topDepositLastDrawAction) >= topDepositTimeStep && topDepositPotentialWinner != address(0)) {
            
            if(BUSDToken.balanceOf(address(this)) < topDepositPoolBalance) topDepositPoolBalance = BUSDToken.balanceOf(address(this));

            BUSDToken.transfer(topDepositPotentialWinner, topDepositPoolBalance); 
            emit TopDepositPayout(topDepositCurrentRound, topDepositPotentialWinner, topDepositPoolBalance, block.timestamp);
            
            usersBonus[topDepositPotentialWinner].topDepositBonus += topDepositPoolBalance;
            previousTopDepositWinner  = topDepositPotentialWinner;
            previousTopDepositRewards = topDepositPoolBalance;
            topDepositPotentialWinner = address(0);
            topDepositCurrentAmount   = 0;
            topDepositPoolBalance     = 0;
            topDepositLastDrawAction  = block.timestamp;
            topDepositCurrentRound++;
        }
    }

    function deposit(address referrer, uint256 amount) public payable {
        User storage user = _users[msg.sender];    
        require(block.timestamp > startTime, "Protocol not yet started.");
        require(amount >= _properties.minInvestAmount, "Deposit minimum not met.");
        require(user.stakeBUSD.totalStaked <= _properties.maxInvestAmount, "Max busd staked reached.");

        BUSDToken.transferFrom(msg.sender, address(this), amount);

        uint256 tax = _processFee(amount);
        uint256 adjustedAmount = amount.sub(tax);
        _setUpline(msg.sender, referrer);
        _refPayout(msg.sender, amount, _properties.refBonus);

        if (user.stakeBUSD.totalStaked == 0) {
            user.stakeBUSD.checkpoint = block.timestamp;	
            user.lastSale = block.timestamp; //set the initial last sale timestamp for 1st time deposits.	
            _stats.totalUsers++;	
        } else {
            updateStakeBUSD(msg.sender);	
        }
        _stakeBUSDToken(msg.sender, adjustedAmount);
    }

    function _stakeBUSDToken(address addr, uint256 amount) internal {
        User storage user = _users[addr];
        
        user.stakeBUSD.lastStakeTime = block.timestamp;
        user.stakeBUSD.totalStaked += amount;
        _stats.totalBUSDTokenStaked += amount;

        emit NewDeposit(addr, amount);
        
        if(this.checkDrawEvents()) this.runDrawEvents();
        poolLastDeposit(addr, amount);    
        poolTopDeposit(addr, amount);
        
    }

    function maxStakeFor(address _addr) public view returns (uint256) {
        User storage user = _users[_addr];
        uint256 stake = user.stakeBUSD.totalStaked;
        return stake.mul(_properties.tokenStakeFactor);
    }

    function stakeEternalToken(uint256 amount) public {  
        User storage user = _users[msg.sender];
        require(block.timestamp >= startTime, "Protocol not yet started.");
        require(amount <= balanceOf(msg.sender), "Insufficient Balance.");

        uint256 stakeFee = amount.mul(_properties.eternalTokenStakeTax).div(percentDivider);
        uint256 adjustedAmount = amount.sub(stakeFee);
        require(user.stakeEternal.totalStaked.add(adjustedAmount) <= maxStakeFor(msg.sender), "Cannot exceed stake max");

        if (user.stakeEternal.totalStaked == 0) {
            user.stakeEternal.checkpoint = block.timestamp;
        } else {	
            updateStakeEternal(msg.sender);	
        }

        // burn tokens to balance total supply.
        _burn(msg.sender, amount);
        _stakeEternalToken(msg.sender, adjustedAmount);
    }

    function _stakeEternalToken(address addr, uint256 amount) internal {
        User storage user = _users[addr];
        user.stakeEternal.lastStakeTime = block.timestamp;
        user.stakeEternal.totalStaked += amount;
        _stats.totalEternalTokenStaked += amount;

        emit NewStake(addr, amount);
        
        if(this.checkDrawEvents()) this.runDrawEvents();
    }

    function compoundBUSD() external {
        _compoundBUSD(msg.sender);
    }

    function compoundEternal() external {
        _compoundEternal(msg.sender);
    }

    function _compoundBUSD(address addr) internal {
        uint256 claim = claimFromBUSD(addr);
        
        if(claim > 0) { //avoid reverts
            uint256 amount = tokenToBUSDToken(claim);
            require(getContractBalance() > amount, "Insufficient balance");

            uint256 compoundFee = amount.mul(_properties.compoundTax).div(percentDivider);
            uint256 taxedAmount = amount.sub(compoundFee);

            _refPayout(addr, taxedAmount, _properties.refBonus);
            stakeEternalToken(taxedAmount);
            _stats.totalCompounded += taxedAmount;
        }
        
        if(this.checkDrawEvents()) this.runDrawEvents();
    }

    function _compoundEternal(address addr) internal {
        uint256 claim = claimFromEternal(addr);
        
        if(claim > 0) {  //avoid reverts
            uint256 compoundFee = claim.mul(_properties.compoundTax).div(percentDivider);
            uint256 taxedAmount = claim.sub(compoundFee);

            stakeEternalToken(taxedAmount);
            _stats.totalCompounded += taxedAmount;
        }
        
        if(this.checkDrawEvents()) this.runDrawEvents();
    }

    function _setUpline(address addr, address referrer) internal {
        User storage user = _users[addr];

        if (user.referrer == address(0) && addr != owner()) {
            
            if (_users[referrer].stakeBUSD.totalStaked == 0 || referrer == addr) {
                referrer = owner();
            }

            user.referrer = referrer;
            address upline = user.referrer;
            _users[upline].referrals++;

            for (uint256 i = 0; i < _properties.refDepth; i++) {
                if (upline == address(0)) break;

                _users[upline].totalStructure++;

                upline = _users[upline].referrer;
            }
        }
    }

    function _refPayout(address addr, uint256 amount, uint256 refBonus) internal {
        User storage user = _users[addr];
        address upline = user.referrer;
        uint256 bonus = amount.mul(refBonus).div(percentDivider);

        for (uint256 i = 0; i < _properties.refDepth; i++) {
            // if we have reached the top of the chain
            if (upline == address(0)) {
                // the equivalent of looping through all available
                user.referralRoundRobinPosition = _properties.refDepth;
                break;
            }
            if (user.referralRoundRobinPosition == i) {
                // user can only get ref payout if they have deposited the min investment amount
                // AND total eternal token staked is not more than max minting token deposits
                if (_users[upline].stakeBUSD.totalStaked >= _properties.minInvestAmount && _users[upline].stakeEternal.totalStaked <= maxStakeFor(upline)) {
                    updateStakeBUSD(upline);
                    _users[upline].stakeBUSD.totalStaked += bonus;
                    _users[upline].totalBonus += bonus;
                    _stats.totalBUSDTokenStaked += bonus;
                    _stats.totalRefBonuses += bonus;

                    emit NewDeposit(upline, bonus);

                    if (_users[upline].referrer == address(0)) {
                        user.referralRoundRobinPosition = _properties.refDepth;
                    }

                    break; // no need to keep looping, we've already paid the referrer
                }

                user.referralRoundRobinPosition += 1;
            }

            upline = _users[upline].referrer;
        }

        user.referralRoundRobinPosition += 1;

        if (user.referralRoundRobinPosition >= _properties.refDepth) {
            user.referralRoundRobinPosition = 0;
        }
    }

    function getNextUpline(address _addr) public view returns (address nextUpline, bool minInvest, bool maxStake) {
        address upline = _users[_addr].referrer;

        for (uint8 i = 0; i < _properties.refDepth; i++) {
            if (upline == address(0)) {
                break;
            }
            if (_users[_addr].referralRoundRobinPosition == i) {
                minInvest = _users[upline].stakeBUSD.totalStaked >= _properties.minInvestAmount;
                maxStake = _users[upline].stakeEternal.totalStaked <= maxStakeFor(upline);
                return (upline, minInvest, maxStake);
            }

            upline = _users[upline].referrer;

        }
        return (address(0), false, false);
    }

    function _processFee(uint256 amount) internal returns (uint256) {
        uint256 devTax = amount.mul(_properties.BUSDTokenStakeTax).div(percentDivider);
        BUSDToken.transfer(receiver, devTax);
        return devTax;
    }

    function updateStakeBUSD(address addr) private {
        User storage user = _users[addr];
        uint256 payout = getPayoutBUSD(addr);
        if (payout > 0) {
            user.stakeBUSD.unClaimedTokens += payout;
            user.stakeBUSD.checkpoint = block.timestamp;
        }
    }

    function getPayoutBUSD(address _addr) private view returns (uint256 value) {
        User storage user = _users[_addr];
        
        uint256 timeElapsed = block.timestamp.sub(user.stakeBUSD.checkpoint) > _properties.cutOffTimeStep ? _properties.cutOffTimeStep : block.timestamp.sub(user.stakeBUSD.checkpoint);
        value = (user.stakeBUSD.totalStaked.mul(_properties.busdTokenDailyPayout).div(percentDivider)).mul(timeElapsed).div(timeStep);
        
        return value;
    }

    function updateStakeEternal(address _addr) private {
        User storage user = _users[_addr];
        uint256 amount = getPayoutEternal(_addr);
        if (amount > 0) {
            user.stakeEternal.unClaimedTokens += amount;
            user.stakeEternal.checkpoint = block.timestamp;
        }
    }

    function getPayoutEternal(address _addr) private view returns (uint256 value) {
        User storage user = _users[_addr];
        
        uint256 timeElapsed = block.timestamp.sub(user.stakeEternal.checkpoint) > _properties.cutOffTimeStep ? _properties.cutOffTimeStep : block.timestamp.sub(user.stakeEternal.checkpoint);
        value = (user.stakeEternal.totalStaked.mul(_properties.eternalTokenDailyPayout).div(percentDivider)).mul(timeElapsed).div(timeStep);
        
        return value;
    }

    // 200% apr on token stake
    function maxPayoutFor(address addr) public view returns(uint256) {
        User storage user = _users[addr];
        uint256 amount = user.stakeEternal.totalStaked;
        return amount.mul(maxPayoutETRNL).div(percentDivider); 
    }

    function _payoutFor(address addr, uint256 amount, uint256 tax) internal view returns (uint256) {
        uint256 realizedAmount = payoutFor(addr, amount);
        uint256 claimFee = realizedAmount.mul(tax).div(percentDivider);
        return realizedAmount.sub(claimFee);
    }

    function payoutFor(address addr, uint256 amount) public view returns (uint256) {
        // apply whale tax
        uint256 tax = sustainabilityFee(addr, amount);
        uint256 fee = amount.mul(tax).div(standardDivider);
        return amount.sub(fee);
    }

    function sustainabilityFee(address addr, uint256 pendingDiv) public view returns (uint256) {
        User storage user = _users[addr];
        uint256 bracket = user.totalClaimed.add(pendingDiv).div(_properties.depositBracketSize);
        bracket = bracket > _properties.depositBracketMax ? _properties.depositBracketMax : bracket;
        return bracket.mul(5);
    }

    function claimFromBUSD(address addr) internal returns (uint256) {
        User storage user = _users[addr];
        uint256 maxPayout = _properties.maxPayoutCap;
        require(user.totalClaimed < maxPayout, "Max payout reached.");

        updateStakeBUSD(addr);
        uint256 amount = user.stakeBUSD.unClaimedTokens;
        uint256 adjustedAmount = _payoutFor(addr, amount, _properties.BUSDTokenClaimTax);

        // payout remaining allowable divs if exceeds
        if(user.totalClaimed.add(adjustedAmount) > maxPayout) {
            adjustedAmount = maxPayout.sub(user.totalClaimed);
        }

        user.totalClaimed += amount;
        user.stakeBUSD.totalClaimedTokens += amount;
        user.stakeBUSD.unClaimedTokens = 0;

        return adjustedAmount;
    }

    function claimFromEternal(address addr) internal returns (uint256) {
        User storage user = _users[addr];
        uint256 maxPayout = maxPayoutFor(addr);
        require(user.totalClaimed < _properties.maxPayoutCap, "Max payout reached.");
        require(user.stakeEternal.totalClaimedTokens < maxPayout, "Staking pool Max payout reached.");

        updateStakeEternal(msg.sender);
        uint256 amount = user.stakeEternal.unClaimedTokens;
        uint256 adjustedAmount = _payoutFor(addr, amount, _properties.eternalTokenClaimTax);

        //payout remaining allowable divs if exceeds
        if(user.totalClaimed.add(adjustedAmount) > _properties.maxPayoutCap) {
            adjustedAmount = _properties.maxPayoutCap.sub(user.totalClaimed);
        } else if (user.stakeEternal.totalClaimedTokens.add(adjustedAmount) > maxPayout) {
            adjustedAmount = maxPayout.sub(user.stakeEternal.totalClaimedTokens);
        }

        user.totalClaimed += amount;
        user.stakeEternal.totalClaimedTokens += amount;
        user.stakeEternal.unClaimedTokens = 0;

        return adjustedAmount;
    }

    function claimFromBUSD() public {
        uint256 amount = claimFromBUSD(msg.sender);
        require(amount > 0, "No rewards to claim.");

        _mint(msg.sender, amount);
        emit ClaimToken(msg.sender, amount, block.timestamp);
    }

    function claimFromEternal() public {
        uint256 amount = claimFromEternal(msg.sender);
        require(amount > 0, "No rewards to claim.");

        _mint(msg.sender, amount);
        emit ClaimToken(msg.sender, amount, block.timestamp);
    }

    function claimAll() public {
        uint256 amountM = claimFromBUSD(msg.sender);
        uint256 amountT = claimFromEternal(msg.sender);
        uint256 total = amountM.add(amountT);

        require(total > 0, "No rewards to claim.");

        _mint(msg.sender, total);
        emit ClaimToken(msg.sender, total, block.timestamp);
    }
	
	function compoundAll() public {
        _compoundBUSD(msg.sender);	
        _compoundEternal(msg.sender);	
    }

    function sellToken(uint256 amount) public {
        amount = amount > balanceOf(msg.sender) ? balanceOf(msg.sender) : amount;
        require(amount > 0 ,"User does not have any token to sell.");
        require(!isInCooldown(msg.sender), "Sell cooldown in effect.");

        uint256 sellFee = _sellTaxAmount(msg.sender, amount);
        uint256 realizedAmount = amount.sub(sellFee);
        uint256 exchangeAmount = tokenToBUSDToken(realizedAmount);

        require(getContractBalance() > exchangeAmount);

        _burn(msg.sender, amount); //burn sold tokens.
        _users[msg.sender].lastSale = block.timestamp;
        BUSDToken.transfer(msg.sender, exchangeAmount);

        emit SellToken(msg.sender, realizedAmount, exchangeAmount);
		if(this.checkDrawEvents()) this.runDrawEvents();
    }

    function _sellTaxAmount(address from, uint256 amount) internal view returns (uint256) {
        User storage user = _users[from];
        uint256 taxes = amount.mul(_properties.sellTax).div(percentDivider);
        
        if(amount > user.stakeEternal.totalStaked.mul(_properties.antiDumpRate).div(percentDivider)) {
            uint256 tax = amount.mul(_properties.antiDumpTax).div(percentDivider);
            taxes.add(tax);
        }

        return taxes;
    }

    function isInCooldown(address addr) public view returns (bool) {
        User storage user = _users[addr];
        return user.lastSale >= block.timestamp.sub(_properties.sellCooldown);
    }

    function airdrop(address receiver, uint256 amount) external {
        require(_properties.airdropEnabled, "Airdrop is disabled.");
        require(msg.sender != receiver);
        require(amount >= _properties.airdropMinAmount);

        address sender = msg.sender;
        User storage recipient = _users[receiver];
        //Make sure _to exists in the system
        require(recipient.referrer != address(0), "Airdrop recipient not found.");

        uint256 tax = amount.mul(_properties.eternalTokenStakeTax).div(percentDivider);
        uint256 realizedAmount = amount.sub(tax);
        require(recipient.stakeEternal.totalStaked.add(realizedAmount) <= maxStakeFor(receiver), "Max Stake reached.");
        updateStakeEternal(receiver);
        
        //burn because unclaimed tokens are minted when they are claimed
        _burn(msg.sender, amount);

        //Fund to token stake (with tax applied)
        recipient.stakeEternal.totalStaked += realizedAmount;
        _stats.totalEternalTokenStaked = _stats.totalEternalTokenStaked.add(realizedAmount);
        _stats.totalAirdropped += amount;

        //recipient statistics
        airdrops[receiver].totalAirdropsReceived += realizedAmount;
        airdrops[receiver].airdropsReceivedCount++;
        airdrops[receiver].lastAirdropReceived = block.timestamp;

        //sender statistics
        airdrops[sender].totalAirdropsSent += amount;
        airdrops[sender].airdropsSentCount++;
        airdrops[sender].lastAirdropSent = block.timestamp;

        emit NewStake(receiver, amount);
        emit NewAirdrop(sender, receiver, amount, block.timestamp);
		if(this.checkDrawEvents()) this.runDrawEvents();
    }

    function getUserUnclaimedTokensInfo(address addr) 
        public 
        view 
        returns (
            uint256 busd, 
            uint256 eternal
        ) 
    {
        User storage user = _users[addr];
        return 
        (
            getPayoutBUSD(addr).add(user.stakeBUSD.unClaimedTokens),
            getPayoutEternal(addr).add(user.stakeEternal.unClaimedTokens)
        );
    }

    function getAPY() public view returns (uint256 apym, uint256 apyt) {
        return 
        (
            _properties.busdTokenDailyPayout.mul(365).div(10),
            _properties.eternalTokenDailyPayout.mul(365).div(10)
        );
    }

    function getUserStakeInfo(address addr)
        public
        view
        returns (
            uint256 totalStaked,
            uint256 checkpoint,
            uint256 lastStakeTime,
            uint256 unClaimedTokens,

            uint256 totalStakedEternal,
            uint256 checkpointEternal,
            uint256 lastStakeTimeEternal,
            uint256 totalClaimedTokensEternal,
            uint256 unClaimedTokensEternal
        )
    {
        User storage user = _users[addr];
        totalStaked = user.stakeBUSD.totalStaked;
        checkpoint = user.stakeBUSD.checkpoint;
        lastStakeTime = user.stakeBUSD.lastStakeTime;
        unClaimedTokens = user.stakeBUSD.unClaimedTokens;

        totalStakedEternal = user.stakeEternal.totalStaked;
        checkpointEternal = user.stakeEternal.checkpoint;
        lastStakeTimeEternal = user.stakeEternal.lastStakeTime;
        totalClaimedTokensEternal = user.stakeEternal.totalClaimedTokens;
        unClaimedTokensEternal = user.stakeEternal.unClaimedTokens;
    }

    function getUserInfo(address addr)
        external
        view
        returns (
            address referrer,
            uint256 totalStructure,
            uint256 referrals,
            uint256 totalClaimed,
            uint256 totalBonus,
            uint256 referralRoundRobinPosition,
            uint256 lastSale
        )
    {
        User storage user = _users[addr];
        return (
            user.referrer,
            user.totalStructure,
            user.referrals,
            user.totalClaimed,
            user.totalBonus,
            user.referralRoundRobinPosition,
            user.lastSale
        );
    }

    function getUserAirdropDetails(address addr)
        external
        view
        returns (
            uint256 totalAirdropsReceived,
            uint256 airdropsReceivedCount,
            uint256 lastAirdropReceived,
            uint256 totalAirdropsSent,
            uint256 airdropsSentCount,
            uint256 lastAirdropSent
        )
    {
        Airdrop storage air = airdrops[addr];
        return (
            air.totalAirdropsReceived,
            air.airdropsReceivedCount,
            air.lastAirdropReceived,
            air.totalAirdropsSent,
            air.airdropsSentCount,
            air.lastAirdropSent
        );
    }
    
    function getContractPayouts() 
        external 
        view 
        returns 
        (   
            uint256 busdTokenDailyPayout,
            uint256 eternalTokenDailyPayout
        ) 
    {
        return (
        _properties.busdTokenDailyPayout,
        _properties.eternalTokenDailyPayout);
    }

    function getContractLimits() 
        external 
        view 
        returns 
        (   
            uint256 tokenStakeFactor,
            uint256 sellCooldown,
            uint256 cutOffTimeStep,
            uint256 maxPayoutCap,
            uint256 maxRewards,
            uint256 minInvestAmount,
            uint256 maxInvestAmount,
            bool airdropEnabled,
            uint256 airdropMinAmount
        ) 
    {
        return (
        _properties.tokenStakeFactor,
        _properties.sellCooldown,
        _properties.cutOffTimeStep,
        _properties.maxPayoutCap,
        _properties.maxRewards,
        _properties.minInvestAmount,
        _properties.maxInvestAmount,
        _properties.airdropEnabled,
        _properties.airdropMinAmount);
    }

    function getContractTaxes() 
        external 
        view 
        returns 
        (   
            uint256 BUSDTokenStakeTax,
            uint256 eternalTokenStakeTax,
            uint256 compoundTax,
            uint256 antiDumpRate,
            uint256 antiDumpTax,
            uint256 sellTax,
            uint256 eternalTokenClaimTax,
            uint256 BUSDTokenClaimTax
        ) 
    {
        return (
        _properties.BUSDTokenStakeTax,
        _properties.eternalTokenStakeTax,
        _properties.compoundTax,
        _properties.antiDumpRate,
        _properties.antiDumpTax,
        _properties.sellTax,
        _properties.eternalTokenClaimTax,
        _properties.BUSDTokenClaimTax);
    }

    function getWhaleTax() 
        external 
        view 
        returns 
        (   
            uint256 depositBracketMax,
            uint256 depositBracketSize
        ) 
    {
        return (
        _properties.depositBracketMax,
        _properties.depositBracketSize);
    }
    
    function lastDepositInfo() 
        view 
        external 
        returns(
            bool isLastDepositEnabled, 
            uint256 currentRound, 
            uint256 currentBalance, 
            uint256 currentStartTime, 
            uint256 currentStep, 
            address currentPotentialWinner, 
            uint256 previousReward, 
            address previousWinner
        ) 
    {
        isLastDepositEnabled   = lastDepositEnabled;
        currentRound           = lastBuyCurrentRound;
        currentBalance         = lastDepositPoolBalance;
        currentStartTime       = lastDepositLastDrawAction;  
        currentStep            = lastDepositTimeStep;    
        currentPotentialWinner = lastDepositPotentialWinner;
        previousReward         = previousPoolRewards;
        previousWinner         = previousPoolWinner;
    }

    function topDepositInfo() 
        view 
        external 
        returns(
            bool isTopDepositEnabled, 
            uint256 topDepositRound, 
            uint256 topDepositCurrentTopDeposit, 
            address topDepositCurrentPotentialWinner, 
            uint256 topDepositCurrentBalance, 
            uint256 topDepositCurrentStartTime, 
            uint256 topDepositCurrentStep, 
            uint256 topDepositPreviousReward, 
            address topDepositPreviousWinner
        ) 
    {
        isTopDepositEnabled              = topDepositEnabled;
        topDepositRound                  = topDepositCurrentRound;
        topDepositCurrentTopDeposit      = topDepositCurrentAmount;
        topDepositCurrentPotentialWinner = topDepositPotentialWinner;
        topDepositCurrentBalance         = topDepositPoolBalance;
        topDepositCurrentStartTime       = topDepositLastDrawAction;
        topDepositCurrentStep            = topDepositTimeStep;
        topDepositPreviousReward         = previousTopDepositRewards;
        topDepositPreviousWinner         = previousTopDepositWinner;
    }

    function getUserTokenBalanceInfo(address addr) 
        public 
        view 
        returns (
            uint256 busd, 
            uint256 eternal
        ) 
    {
        return (
            BUSDToken.balanceOf(addr),
            balanceOf(addr)
        );
    }

    function getContractBalance() 
        public 
        view 
        returns (
            uint256
        ) 
    {
        return BUSDToken.balanceOf(address(this));
    }

    function getEternalTokenPrice() 
        public 
        view 
        returns (
            uint256
        ) 
    {
        uint256 balance = getContractBalance().mul(priceDivider);
        uint256 totalSupply = totalSupply().add(1);
        return balance.div(totalSupply);
    }

    function BUSDTokenToToken(uint256 BUSDTokenAmount) 
        public 
        view 
        returns (
            uint256
        ) 
    {
        return BUSDTokenAmount.mul(priceDivider).div(getEternalTokenPrice());
    }

    function tokenToBUSDToken(uint256 tokenAmount) 
        public 
        view 
        returns (
            uint256
        ) 
    {
        return tokenAmount.mul(getEternalTokenPrice()).div(priceDivider);
    }

    function getContractLaunchTime() 
        public 
        view 
        returns (
            uint256
        ) 
    {
        return startTime;
    }

    function getCurrentDay() 
        public 
        view 
        returns (
            uint256
        ) 
    {        
        uint256 t = block.timestamp > startTime ? block.timestamp.sub(startTime) : 0;
        return t.div(timeStep);
    }

    function getTimeToNextDay()    
        public 
        view 
        returns (
            uint256
        ) 
    {
        uint256 t = block.timestamp > startTime ? block.timestamp.sub(startTime) : 0;
        uint256 g = getCurrentDay().mul(timeStep);
        return g.add(timeStep).sub(t);
    }
    
    function checkDrawEvents() 	
        external 	
        view 	
        returns (	
            bool runEvent	
        ) 	
    {	
        if((topDepositEnabled && block.timestamp.sub(topDepositLastDrawAction) >= topDepositTimeStep && topDepositPotentialWinner != address(0)) 	
        || (lastDepositEnabled && block.timestamp.sub(lastDepositLastDrawAction) >= lastDepositTimeStep && lastDepositPotentialWinner != address(0)))	
        runEvent = true;	
        return runEvent;	
    }
    
    function runDrawEvents() external {
        drawTopDepositWinner();
        drawLastDepositWinner();      
    }

    //owner only functions
    function changeAccumulationTimeStep(uint256 accumulationTime) external onlyOwner {
        require(accumulationTime >= 1 days && accumulationTime <= 7 days, "Accumulation time step can only changed to 1 day up to 7 days."); 
        _properties.cutOffTimeStep = accumulationTime;
    }

    function changeLastDepositEventTime(uint256 lastDepoStep) external onlyOwner {
        require(lastDepoStep >= 1 hours && lastDepoStep <= 1 days, "Time step can only changed to 1 hour up to 24 hours.");
        drawLastDepositWinner();   
        lastDepositTimeStep = lastDepoStep;
    }

    //only change this value when the previous round is concluded!
    function changeLastDepositInitialBalance(uint256 balance) external onlyOwner {
        require(balance >= 50 ether && balance <= 1000 ether, "Initial balance should be greater than or equal to 50 BUSD and less than or equal 1,000 BUSD");
        lastDepositPoolBalance = balance;
    }

    function changeTopDepositEventTime(uint256 topDepoStep) external onlyOwner {
        require(topDepoStep >= 1 days && topDepoStep <= 7 days, "Time step can only changed to 1 day up to 7 days.");
        drawTopDepositWinner();   
        topDepositTimeStep = topDepoStep;
    }
    
    function switchNetworkAirdropStatus() external onlyOwner {
        _properties.airdropEnabled  = !_properties.airdropEnabled ? true : false;
    }
    
    function switchTopDepositEventStatus() external onlyOwner {
        drawTopDepositWinner();
        topDepositEnabled = !topDepositEnabled ? true : false;
        if(topDepositEnabled) topDepositLastDrawAction = block.timestamp;
    }
    
    function switchLastDepositEventStatus() external onlyOwner {
        drawLastDepositWinner();
        lastDepositEnabled = !lastDepositEnabled ? true : false;
        if(lastDepositEnabled) lastDepositLastDrawAction = block.timestamp;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./ERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

abstract contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 amount, address token, bytes calldata extraData) external virtual;
}

contract Token is ERC20 {
    mapping (address => bool) private _contracts;

    constructor() {
        _name = "Eternal Token";
        _symbol = "ETRNL";
        _decimals = 18;
        _limitSupply = 1000000e18;
    }

    function approveAndCall(address spender, uint256 amount, bytes memory extraData) public returns (bool) {
        require(approve(spender, amount));
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, amount, address(this), extraData);
        return true;
    }

    function transfer(address to, uint256 value) public override virtual returns (bool) {
        if (_contracts[to]) {
            approveAndCall(to, value, new bytes(0));
        } else {
            super.transfer(to, value);
        }
        return true;
    }
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";
import "openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
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
    using SafeMath for uint256;
    //address busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // live busd
    address busd = 0xc46CCBE42Afdf64cc4DA7e56DCd60eE9bF1B743B; // testnet busd
    address receiver = 0xa12944f02aD45105D0D274004BE30691fc865861;
    IERC20 BUSDToken;
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 internal _limitSupply;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function limitSupply() public view returns (uint256) {
        return _limitSupply;
    }
    
    function availableSupply() public view returns (uint256) {
        return _limitSupply.sub(_totalSupply);
    }    

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0));
        require(recipient != address(0));

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0));
        require(availableSupply() >= amount);

        _totalSupply = _totalSupply.add(amount);
        
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0));

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0));
        require(spender != address(0));

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
}