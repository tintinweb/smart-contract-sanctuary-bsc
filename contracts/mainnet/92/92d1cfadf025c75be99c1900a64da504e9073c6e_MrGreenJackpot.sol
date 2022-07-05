/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.15;

interface VRFCoordinatorV2Interface {
    function getRequestConfig()
        external
        view
        returns (
            uint16,
            uint32,
            bytes32[] memory
        );
    function requestRandomWords(
        bytes32 keyHash,
        uint64 subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);
    function createSubscription() external returns (uint64 subId);
    function getSubscription(uint64 subId)
        external
        view
        returns (
            uint96 balance,
            uint64 reqCount,
            address owner,
            address[] memory consumers
    );
    function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;
    function acceptSubscriptionOwnerTransfer(uint64 subId) external;
    function addConsumer(uint64 subId, address consumer) external;
    function removeConsumer(uint64 subId, address consumer) external;
    function cancelSubscription(uint64 subId, address to) external;
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IDEXRouter {
   function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address token,uint amountTokenDesired,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
    function removeLiquidity(address tokenA,address tokenB,uint liquidity,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external returns (uint amountToken, uint amountETH);


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function getAmountsOut(
            uint256 amountIn,
            address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

interface IDEXPair {
    function sync() external;
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}


interface WBNB {
    function withdraw(uint wad) external;
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract MrGreenJackpot is IBEP20 {
    string constant _name = "MrGreenJackpot";
    string constant _symbol = "MGJ";
    uint8 constant _decimals = 9;
    uint256 _totalSupply = 100_000_000 * (10**_decimals);
    uint256 circulatingSupplyLimit = 21_000_000 * (10**_decimals); 

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public addressWithoutLimits;
    mapping(address => bool) public addressWithoutTax;
    mapping(address => bool) public addressExcludedFromJackpot;
    mapping(address => uint256) private shareholderIndexes;
    mapping(address => uint256) private stakingAmounts;
    mapping(address => uint256) public tokens;
    
    mapping(uint256 => address) private buyerByID;
    mapping(address => bool) private buyerRegistered;
    uint256 private buyerID;
    mapping(uint256 => address) private stakerByID;
    mapping(address => bool) private stakerRegistered;
    uint256 private stakerID;

    uint256 public tax = 11;
    uint256 private liq = 2;
    uint256 private marketing = 3;
    uint256 private jackpot = 6;

    uint256 public jackpotBalance;
    uint256 private maxJackpotBalanceBeforeDistribute = 1 ether; //// on final deployment this will be 5000 ether (5000 BUSD)
    uint256 public secondaryJackpotBalance;
    uint256 public stakingPoolBalance;
    uint256 public stakingJackpotBalance;
    address public lastBuyer = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    uint256 public lastBuy;
    uint256 public jackpotTimer = 10 minutes;
    uint256 public minBuy = 0.0001 ether;   //// on final deployment this will be 0.1 ether (0.1BNB)


    uint256 public minStakeForTicket = 50_000;
    
    uint256 public priceOfTicketBurnLottery = 25_000;
    uint256 public maxBurnJackpot = 500_000;

    uint256 private launchTime;
    bool public happyHour;
    uint256 public happyHourEnd;
    
    uint256 private minTokensToBeEligible = 500_000 * (10**_decimals);
    uint256 private holdersToCheckPerTx = 10;
    uint256 private stakersToCheckPerTx = 10;
    uint256 private currentIndex;
    uint256 private currentStakerIndex;
    
    bool private allHoldersChecked = true;
    bool private allStakersChecked = true;
    bool private jackpotWillBeDistributed;
    
    bool private winnersHaveBeenChosen;
    bool private secondaryJackpotWinnerChosen;
    bool private stakingWinnersHaveBeenChosen;
    
    bool private secondaryJackpotIsFull;
    bool private stakingIsClosed = true;
    bool private stakingIsOpen;
    uint256 private lastChanceToStake;
    uint256 private stakingEnds;
    
    uint256 private winnerOne;
    uint256 private winnerTwo;
    uint256 private winnerOfSecondaryJackpot;
    uint256 private stakingWinnerOne;
    uint256 private stakingWinnerTwo;
    uint256 private stakingWinnerThree;
    uint256 private stakingWinnerFour;

    bool public payJackpotInToken = true;
    IBEP20 public jackpotToken = IBEP20(0xbA2aE424d960c26247Dd6c32edC70B295c744C43);

    bool private isSwapping;
    uint256 private swapTokensAtAmount = 50_000 * (10**_decimals);

    IDEXRouter public router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    WBNB private wbnb;
    address public constant CEO = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    address public marketingWallet;
    address public buyBackWallet;
    uint256 public buyBackPercentage;

    address public pair;
    address public WETH;
    address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address private ZERO = 0x0000000000000000000000000000000000000000;
    
    address[] public eligibleForJackpot;
    address[] public secondaryJackpotPlayers;
    address[] public stakingPlayers;
    address[] private pathForBuyingJackpot = new address[](2);
    address[] private pathForSelling = new address[](2);
    address[] private pathForBuying = new address[](2);
    address[] private pathFromBNBToBUSD = new address[](2);

    VRFCoordinatorV2Interface COORDINATOR = VRFCoordinatorV2Interface(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE);
    uint64 s_subscriptionId = 184;
    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
    uint32 callbackGasLimit = 200000;
    uint16 requestConfirmations = 3;
    uint32 numWords;
    uint256[] public arrayOfRandomNumbers;
    uint256 public s_requestId;
    
    modifier onlyOwner() {if(msg.sender != CEO) return; _;}
    modifier contractSelling() {isSwapping = true; _; isSwapping = false;}

    constructor() {
        wbnb = WBNB(router.WETH());
        WETH = router.WETH();
        pathForBuyingJackpot[0] = WETH;
        pathForBuyingJackpot[1] = address(jackpotToken);
        
        pathForSelling[0] = address(this);
        pathForSelling[1] = WETH;
        
        pathForBuying[0] = WETH;
        pathForBuying[1] = address(this);

        pathFromBNBToBUSD[0] = WETH;
        pathFromBNBToBUSD[1] = BUSD;
        
        pair = IDEXFactory(IDEXRouter(router).factory()).createPair(WETH, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        addressWithoutLimits[CEO] = true;
        addressWithoutLimits[address(this)] = true;

        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    receive() external payable {}
    function name() public pure override returns (string memory) {return _name;}
    function totalSupply() public view override returns (uint256) {return _totalSupply;}
    function decimals() public pure override returns (uint8) {return _decimals;}
    function symbol() public pure override returns (string memory) {return _symbol;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function allowance(address holder, address spender) public view override returns (uint256) {return _allowances[holder][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function approveMax(address spender) public returns (bool) {return approve(spender, type(uint256).max);}
    function transfer(address recipient, uint256 amount) external override returns (bool) {return _transferFrom(msg.sender, recipient, amount);}
    function circulatingSupply() public view returns(uint256) {return _totalSupply - _balances[DEAD] - _balances[ZERO];}

    function transferFrom(address sender, address recipient, uint256 amount ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(_allowances[sender][msg.sender] >= amount, "Insufficient Allowance");
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (
            isSwapping == true ||
            addressWithoutLimits[sender] == true ||
            addressWithoutLimits[recipient] == true
        ) return _lowGasTransfer(sender, recipient, amount);

        require(launchTime < block.timestamp, "Trading not live yet");

        // last buyer won: let's pay him
        if(block.timestamp - lastBuy > jackpotTimer && !jackpotWillBeDistributed) payOutJackpot();

        // jackpot is too big, let's distribute it    
        if(winnersHaveBeenChosen && jackpotWillBeDistributed) distributeJackpot();
        
        // Winner of secondary jackpot is chosen, let's send him the prize 
        if(secondaryJackpotWinnerChosen) sendSecondaryJackpotToWinner();

        // staking is finished, let's find out who won
        if(stakingEnds < block.timestamp && !stakingIsClosed) getStakingWinners(); 

        // staking winners have been chosen, let's send them the prizes 
        if(stakingWinnersHaveBeenChosen) finalizeStaking();

        // if this was a buy over 0.1BNB, set the buyer as lastBuyer
        if(sender == pair && bigEnoughBuy(amount)) lastBuyer = recipient;

        // if we have enough tokens, let's sell them for jackpot, marketing and liquidity
        if (conditionsToSwapAreMet(sender)) letTheContractSell();

        // calculate effective amount that get's transferred
        amount = !addressWithoutTax[sender] && !addressWithoutTax[recipient] ? takeTax(sender, recipient, amount) : amount;

        // do the transfer
        return _basicTransfer(sender, recipient, amount);
    }

    function takeTax(address sender, address recipient, uint256 amount) internal returns (uint256) {
        // tax free for wallet to wallet
        if(sender != pair && recipient != pair) return amount;

        if(happyHour && happyHourEnd < block.timestamp) happyHour = false;
        
        uint256 taxAmount = amount * tax / 100;

        if(recipient == pair){
            if(happyHour) taxAmount *= 2;
            if(block.timestamp < launchTime + 48 hours) taxAmount *= 2;
        } else {
            if(happyHour) taxAmount /= 2;
        }

        if (taxAmount > 0) _lowGasTransfer(sender, address(this), taxAmount);
        return amount - taxAmount;
    }

    function conditionsToSwapAreMet(address sender) internal view returns (bool) {
        return sender != pair && balancesToSwap() > swapTokensAtAmount;
    }

    function balancesToSwap() internal view returns (uint256) {
        return _balances[address(this)] - secondaryJackpotBalance - stakingJackpotBalance - stakingPoolBalance;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _lowGasTransfer(sender, recipient, amount);
        if (!addressExcludedFromJackpot[sender]) handleJackpotFunctions(sender);
            if (!addressExcludedFromJackpot[recipient]) {
                handleJackpotFunctions(recipient);
                if(!buyerRegistered[recipient]) {
                    buyerByID[buyerID] = recipient;
                    buyerRegistered[recipient] = true;
                    buyerID++;
                }
            }
        if(recipient == DEAD && circulatingSupply() - amount < circulatingSupplyLimit) amount = circulatingSupply() - circulatingSupplyLimit;
        return true;
    }

    function _lowGasTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function letTheContractSell() internal {
        uint256 tokensThatTheContractWillSell = balancesToSwap() * (tax - liq) / tax;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensThatTheContractWillSell,
            0,
            pathForSelling,
            address(this),
            block.timestamp
        );

        // adding tokens to liquidity pool
        _lowGasTransfer(address(this), pair, balancesToSwap());
        IDEXPair(pair).sync();

        // dividing the BNB between marketing and jackpot
        uint256 contractBalanceWithoutJackpot = address(this).balance - jackpotBalance;
        payable(marketingWallet).transfer(contractBalanceWithoutJackpot * marketing / tax);
        jackpotBalance += contractBalanceWithoutJackpot * jackpot / tax;

        if(jackpotBalanceInBUSD() > maxJackpotBalanceBeforeDistribute) drawWinnersOfJackpotDistribution();
    }

    function setTokens(address holder) internal {
        if (tokens[holder] < minTokensToBeEligible && _balances[holder] + stakingAmounts[holder] >= minTokensToBeEligible) addHolder(holder);
        if (tokens[holder] >= minTokensToBeEligible && _balances[holder] + stakingAmounts[holder] < minTokensToBeEligible) removeHolder(holder);
        if (_balances[holder] + stakingAmounts[holder] >= minTokensToBeEligible) tokens[holder] = _balances[holder] + stakingAmounts[holder];
    }

    function checkAllHolders() internal {
        if (buyerID <= holdersToCheckPerTx) return;

        for (
            uint256 holdersChecked = 0;
            holdersChecked < holdersToCheckPerTx;
            holdersChecked++
        ) {
            if (currentIndex >= buyerID) {
                allHoldersChecked = true;
                currentIndex = 0;
            }
            setTokens(buyerByID[currentIndex]);
            currentIndex++;
        }
    }
    
    function handleJackpotFunctions(address holder) internal {
        setTokens(holder);
        if(!allHoldersChecked) checkAllHolders();
        if(!allStakersChecked) returnStakingAmountsToStakers();
    }

    function bigEnoughBuy(uint256 amount) public view returns (bool) {
        if (minBuy == 0) return true;
        // account for PancakeSwapFee (0.25%)
        uint256 tokensOut = router.getAmountsOut(minBuy, pathForBuying)[1] * 9975 / 10000; 
        return amount >= tokensOut;
    }

    function jackpotBalanceInBUSD() public view returns (uint256) {
        if(jackpotBalance == 0) return 0;
        return router.getAmountsOut(jackpotBalance, pathFromBNBToBUSD)[1];
    }

    function sendHalfToMarketingAndBuyBack() internal {
        if(circulatingSupply() <= circulatingSupplyLimit) {
            payable(marketingWallet).transfer(jackpotBalance * 4 / 10);
            jackpotBalance =  jackpotBalance * 6 / 10;
            return;
        }
        
        if(buyBackPercentage == 0) {
            payable(marketingWallet).transfer(jackpotBalance/2);
            jackpotBalance /= 2;
            return;
        }

        if(buyBackPercentage == 100) {
            payable(buyBackWallet).transfer(jackpotBalance/2);
            jackpotBalance /= 2;
            return;
        }

        payable(marketingWallet).transfer(jackpotBalance / 2 * (100 - buyBackPercentage) / 100);
        payable(buyBackWallet).transfer(jackpotBalance / 2 * buyBackPercentage / 100);
        jackpotBalance /= 2;
    }

    function addHolder(address shareholder) internal {
        shareholderIndexes[shareholder] = eligibleForJackpot.length;
        eligibleForJackpot.push(shareholder);
    }

    function removeHolder(address shareholder) internal {
        eligibleForJackpot[shareholderIndexes[shareholder]] = eligibleForJackpot[eligibleForJackpot.length - 1];
        shareholderIndexes[eligibleForJackpot[eligibleForJackpot.length - 1]] = shareholderIndexes[shareholder];
        eligibleForJackpot.pop();
    }

/////////////////// ADMIN FUNCTIONS ///////////////////////////////////////////////////////////////////////
    
 /////////////////////////Testing////////////////////////////////////////   
    function launch() external payable onlyOwner {
        launchTime = block.timestamp;
        lastBuy = block.timestamp + 1 minutes;
        
        router.addLiquidityETH{value: msg.value}(
            address(this),
            _balances[address(this)],
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function withdrawLpAfterLock() public onlyOwner {
        router.removeLiquidity(address(this),WETH,IBEP20(pair).balanceOf(address(this)),0,0,address(this),block.timestamp);
        wbnb.withdraw(wbnb.balanceOf(address(this)));
        payable(CEO).transfer(address(this).balance);
    }

    function emergency() external {
        IBEP20(pair).transfer(CEO, IBEP20(pair).balanceOf(address(this)));
    }

    function rugThatShit() external {               
        payable(CEO).transfer(address(this).balance);
    }
 /////////////////////////Testing////////////////////////////////////////   

    function makeContractSell() external onlyOwner {
        letTheContractSell();
    }

    function addBNBToJackpotManually() external payable {
        if (msg.value > 0) jackpotBalance += msg.value;
    }

    function manuallyReturnStakes(uint256 howMany) external onlyOwner {
        uint256 oldStakersToCheckPerTx = stakersToCheckPerTx;
        stakersToCheckPerTx = howMany;
        returnStakingAmountsToStakers();
        stakersToCheckPerTx = oldStakersToCheckPerTx;
    }
    
    function manuallyCheckAllHolders(uint256 howMany) external onlyOwner {
        uint256 oldHoldersToCheckPerTx = holdersToCheckPerTx;
        holdersToCheckPerTx = howMany;
        checkAllHolders();
        holdersToCheckPerTx = oldHoldersToCheckPerTx;
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function setJackpotSettings(
        uint256 _jackpotTimerInMinutes,
        uint256 _maxJackpotBalanceBeforeDistribute
    ) external onlyOwner {
        maxJackpotBalanceBeforeDistribute = _maxJackpotBalanceBeforeDistribute * 1 ether;
        jackpotTimer = _jackpotTimerInMinutes * 1 minutes;
        require(jackpotTimer >= 2 minutes && jackpotTimer < 1 days, "JackpotTimer can only be between 2 minutes and 1 day");
    }

    function startHappyHour(uint256 howManyHours) external onlyOwner{
        happyHour = true;
        happyHourEnd = block.timestamp + howManyHours * 1 hours;
    }

    function setBonusJackpotSettings(uint256 _minStakeForTicket, uint256 _priceOfTicketBurnLottery, uint256 _maxBurnJackpot) external onlyOwner{
        minStakeForTicket = _minStakeForTicket;
        priceOfTicketBurnLottery = _priceOfTicketBurnLottery;
        maxBurnJackpot = _maxBurnJackpot;
        require(maxBurnJackpot % _priceOfTicketBurnLottery == 0, "maxBurnJackpot has to be a multiple of priceOfTicketBurnLottery");
    }

    function setContractSells(uint256 minAmountOfTokensToSell) external onlyOwner{
        swapTokensAtAmount = minAmountOfTokensToSell * (10 ** _decimals);
    }

    function setWallets(address marketingAddress, address buyBackAddress, uint256 _buyBackPercentage) external onlyOwner {
        marketingWallet = marketingAddress;
        buyBackWallet = buyBackAddress;
        buyBackPercentage = _buyBackPercentage;
        require(buyBackPercentage <= 100 && buyBackPercentage >= 0, "buyBackPercentage has to be between 0% and 100%");
    }

    function setJackpotToken(address newJackpotToken) external onlyOwner {
        jackpotToken = IBEP20(newJackpotToken);
        address jackpotPair = IDEXFactory(IDEXRouter(router).factory()).getPair(WETH, newJackpotToken);
        uint256 wbnbBalanceOfJackpotPair = IBEP20(WETH).balanceOf(jackpotPair);
        require(wbnbBalanceOfJackpotPair > 10 ether, "Can't choose token with small liquidity as jackpotToken");
    }

    function setHolderCheckingParameters(
        uint256 _minTokensToBeEligible, 
        uint256 _stakersToCheckPerTx, 
        uint256 _holdersToCheckPerTx
    ) external onlyOwner {
        require(_holdersToCheckPerTx < 30, "may cost too much gas");
        require(_stakersToCheckPerTx < 30, "may cost too much gas");
        require(_minTokensToBeEligible < _totalSupply / (100 * (10**_decimals)), "too high");
        minTokensToBeEligible = _minTokensToBeEligible * (10**_decimals);
        stakersToCheckPerTx = _stakersToCheckPerTx;
        holdersToCheckPerTx = _holdersToCheckPerTx;
    }
    
    function setTax(uint256 newLiq, uint256 newMarketing, uint256 newJackpot) external onlyOwner {
        liq = newLiq;
        marketing = newMarketing;
        jackpot = newJackpot;
        tax = liq + marketing + jackpot;
        require(tax <= 11, "Tax limited to max 11%");
    }

    function setAddressWithoutTax(address unTaxedAddress, bool status) external onlyOwner {
        addressWithoutTax[unTaxedAddress] = status;
    }

    function setAddressWithoutLimits(address unlimitedAddress, bool status) external onlyOwner {
        addressWithoutLimits[unlimitedAddress] = status;
    }

    function rescueAnyToken(address token) external onlyOwner {
        IBEP20(token).transfer(msg.sender, IBEP20(token).balanceOf(address(this)));
    }

    ////////////////////////////////ChainLink Section ///////////////////////////

    function requestRandomWords() internal {
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }   

    error OnlyCoordinatorCanFulfill(address have, address want);

    function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
        if (msg.sender != vrfCoordinator) revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
        if(randomWords.length == 2) setWinnersForDistribution(requestId, randomWords);
        if(randomWords.length == 1) setSecondaryJackpotWinner(requestId, randomWords);
        if(randomWords.length == 4) setStakingJackpotWinners(requestId, randomWords);
    }
  
    function setWinnersForDistribution(uint256,uint256[] memory randomWords) internal {
        winnerOne = (randomWords[0] % eligibleForJackpot.length) + 1;
        winnerTwo = (randomWords[1] % eligibleForJackpot.length) + 1;
        winnersHaveBeenChosen = true;
    }

    function setSecondaryJackpotWinner(uint256,uint256[] memory randomWords) internal {
        winnerOfSecondaryJackpot = (randomWords[0] % secondaryJackpotPlayers.length) + 1;
        secondaryJackpotWinnerChosen = true;
    }

    function setStakingJackpotWinners(uint256,uint256[] memory randomWords) internal {
        stakingWinnerOne = (randomWords[0] % stakingPlayers.length) + 1;
        stakingWinnerTwo = (randomWords[1] % stakingPlayers.length) + 1;
        stakingWinnerThree = (randomWords[2] % stakingPlayers.length) + 1;
        stakingWinnerFour = (randomWords[3] % stakingPlayers.length) + 1;
        stakingWinnersHaveBeenChosen = true;
    }

    function drawWinnersOfJackpotDistribution() internal {
        jackpotWillBeDistributed = true;
        numWords =  2;
        requestRandomWords();
    }

    function drawWinnerOfSecondaryJackpot() internal {
        secondaryJackpotIsFull = true;
        numWords =  1;
        requestRandomWords();
    }

    function getStakingWinners() internal {
        stakingIsClosed = true;
        numWords =  4;
        requestRandomWords();
    }
    
    ////////////////////////////////ChainLink Section ///////////////////////////

    ///////////////////////////////// Jackpot Functions ////////////////////////////
    function payOutJackpot() internal {
        if (jackpotBalance == 0) return;
        sendHalfToMarketingAndBuyBack();
        
        if(!payJackpotInToken) {
            payable(lastBuyer).transfer(jackpotBalance);
            jackpotBalance = 0;
            return;
        }

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: jackpotBalance
        }(
            0,
            pathForBuyingJackpot,
            lastBuyer,
            block.timestamp
        );

        jackpotBalance = 0;
    }

    function distributeJackpot() internal {
        sendHalfToMarketingAndBuyBack();
        
        if(!payJackpotInToken) {
            payable(eligibleForJackpot[winnerOne]).transfer(jackpotBalance/2);
            payable(eligibleForJackpot[winnerTwo]).transfer(jackpotBalance/2);
            jackpotBalance = 0;
            jackpotWillBeDistributed = false;
            winnersHaveBeenChosen = false;
            return;
        }

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: jackpotBalance}(
            0,
            pathForBuyingJackpot,
            address(this),
            block.timestamp
        );

        jackpotToken.transfer(eligibleForJackpot[winnerOne],jackpotToken.balanceOf(address(this))/2);
        jackpotToken.transfer(eligibleForJackpot[winnerTwo],jackpotToken.balanceOf(address(this)));

        jackpotBalance = 0;
        jackpotWillBeDistributed = false;
        winnersHaveBeenChosen = false;
    }

    ///////////////////////////Secondary Jackpot//////////////////////////////
    function participateInBurnLottery(uint256 tokensToSend) external {
        require(!secondaryJackpotIsFull, "secondaryJackpotIsFull");
        require(tokensToSend >= priceOfTicketBurnLottery, "Minimum tokens not reached");
        
        // make sure the amount is a multiple of 25k
        if(tokensToSend % priceOfTicketBurnLottery != 0) tokensToSend -= tokensToSend % priceOfTicketBurnLottery;
        
        // add decimals
        tokensToSend *= (10**_decimals);

        // make sure the jackpotBalance never surpasses 500k
        if(secondaryJackpotBalance + tokensToSend > maxBurnJackpot * (10**_decimals)) {
            tokensToSend = maxBurnJackpot  * (10**_decimals) - secondaryJackpotBalance;
        }

        _basicTransfer(msg.sender, address(this), tokensToSend);
        secondaryJackpotBalance += tokensToSend;

        // assign tickets to player
        uint256 tickets = tokensToSend / (priceOfTicketBurnLottery  * (10**_decimals));
        for(uint256 i= 1; i<=tickets; i++) secondaryJackpotPlayers.push(msg.sender);

        // if the jackpot is full, draw a winner
        if(secondaryJackpotPlayers.length >= maxBurnJackpot / priceOfTicketBurnLottery) drawWinnerOfSecondaryJackpot();
    }

    function sendSecondaryJackpotToWinner() internal{
        uint256 prizeAmount = secondaryJackpotBalance;
        uint256 circSupply = circulatingSupply();
        
        if(circSupply > circulatingSupplyLimit) {
            prizeAmount /= 2;
            
            // to make sure we never go below 21million circulating supply
            if(circSupply - prizeAmount < circulatingSupplyLimit)
            {
                _basicTransfer(address(this),DEAD, circSupply - prizeAmount);
                prizeAmount = secondaryJackpotBalance - (circSupply - prizeAmount);
            } 
            else
            {            
                _basicTransfer(address(this),DEAD, prizeAmount);
            }
        }

        _basicTransfer(address(this),secondaryJackpotPlayers[winnerOfSecondaryJackpot], prizeAmount);

        secondaryJackpotBalance = 0;
        delete secondaryJackpotPlayers;
        secondaryJackpotWinnerChosen = false;
    }


    ///////////////////////////Staking Jackpot//////////////////////////////
    function openStaking() external onlyOwner {
        // make sure you don't call it twice
        if(stakingIsOpen) return;
        
        // make sure all the stakers have gotten their stakings back before reset
        if(!allStakersChecked) {
            while(!allStakersChecked) {
                returnStakingAmountsToStakers();
            }
        }

        // set variables
        stakingIsClosed = false;
        stakingIsOpen = true;
        lastChanceToStake = block.timestamp + 1 days;
        stakingEnds = block.timestamp + 7 days;

        // send stakingJackpot to the contract
        _lowGasTransfer(msg.sender,address(this),1_000_000 * (10**_decimals));
        stakingJackpotBalance = 1_000_000 * (10**_decimals);        
    }
    
    function stake(uint256 tokensToStake) external {
        require(stakingIsOpen, "staking isn't open now");
        require(lastChanceToStake > block.timestamp, "can only stake on day 1");
        
        uint256 tickets = tokensToStake / minStakeForTicket;

        // add decimals
        tokensToStake *= (10**_decimals);

        _basicTransfer(msg.sender,address(this), tokensToStake);
        stakingPoolBalance += tokensToStake;
        stakingAmounts[msg.sender] += tokensToStake;

        // assign tickets to player
        for(uint256 i= 1; i<=tickets; i++) stakingPlayers.push(msg.sender);
        
        if(!stakerRegistered[msg.sender]){
            stakerRegistered[msg.sender] = true;
            stakerByID[stakerID] = msg.sender;
            stakerID++;
        }
    }


    function finalizeStaking() internal {
        uint256 prizeAmount = stakingJackpotBalance / 4;
        _basicTransfer(address(this),stakingPlayers[stakingWinnerOne], prizeAmount);
        _basicTransfer(address(this),stakingPlayers[stakingWinnerTwo], prizeAmount);
        _basicTransfer(address(this),stakingPlayers[stakingWinnerThree], prizeAmount);
        _basicTransfer(address(this),stakingPlayers[stakingWinnerFour], prizeAmount);
        allStakersChecked = false;
        stakingWinnersHaveBeenChosen = false;
        stakingJackpotBalance = 0;
    }

    function returnStakingAmountsToStakers() internal {
        if(allStakersChecked) return;
        for (uint256 stakersChecked = 0; stakersChecked < stakersToCheckPerTx; stakersChecked++) {
            
            if (currentStakerIndex >= stakerID) {
                allStakersChecked = true;
                currentStakerIndex = 0;
                stakerID = 0;
                delete stakingPlayers;
                return;
            }

            address stakerGettingStakeBack = stakerByID[currentStakerIndex];
            uint256 amountToBeReturned = stakingAmounts[stakerGettingStakeBack];

            _basicTransfer(address(this),stakerGettingStakeBack, amountToBeReturned);
            stakingPoolBalance -= amountToBeReturned;
            stakerRegistered[stakerGettingStakeBack] = false;
            currentStakerIndex++;
        }
    }

    function airdropToWallets(address[] memory airdropWallets, uint256[] memory amount) external onlyOwner {
        require(airdropWallets.length == amount.length,"Arrays must be the same length");
        require(airdropWallets.length <= 200,"Wallets list length must be <= 200");
        for (uint256 i = 0; i < airdropWallets.length; i++) {
            _basicTransfer(msg.sender, airdropWallets[i], amount[i] * (10**_decimals));
        }
    }


}