/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

/*  
 
 * SPDX-License-Identifier: None
*/
pragma solidity 0.8.17;

interface ICCVRF {
    function requestRandomness(uint256 requestID, uint256 howManyNumbers) external payable;
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
}

contract MTest is IBEP20 {
    string constant _name = "MTest";
    string constant _symbol = "MT";
    uint8 constant _decimals = 9;
    uint256 _totalSupply = 100_000_000 * (10**_decimals);
    uint256 circulatingSupplyLimit = 21_000_000 * (10**_decimals); 

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public addressWithoutLimits;
    mapping(address => bool) public buyerRegistered;
    mapping(address => bool) private _blacklist;

    uint256 public tax = 2;
    uint256 public liq = 1;
    uint256 public marketing = 0;
    uint256 public jackpot = 1;

    uint256 public jackpotBalance;   
    uint256 public maxJackpotBalanceBeforeDistribute = 5 ether;
    address public lastBuyer;
    uint256 public lastBuy;
    uint256 public jackpotTimer = 5 minutes;
    uint256 public minBuy = 0.001 ether;

    uint256 public launchTime = type(uint256).max;
    bool public happyHour;
    uint256 public happyHourEnd;
    
    bool public jackpotWillBeDistributed;
    bool public winnersHaveBeenChosen;

    bool public payJackpotInToken = true;
    IBEP20 public jackpotToken = IBEP20(0xbA2aE424d960c26247Dd6c32edC70B295c744C43);
    uint256 public totalDogePaidFromJackpot;
    uint256 public totalJackpotPayouts;

    bool private isSwapping;
    uint256 public swapTokensAtAmount = 50_000 * (10**_decimals);
    uint256 public maxWallet = 5_000_000 * (10**_decimals);
    
    ICCVRF public randomnessSupplier = ICCVRF(0xC0de0aB6E25cc34FB26dE4617313ca559f78C0dE);
    mapping (uint256 => bool) public nonceProcessed;
    uint256 public vrfCost = 0.002 ether;
    uint256 public nonce;

    IDEXRouter public router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public constant CEO = 0x7299336E094dd0f5a74f6bdCbfE7fECc401b81C4;
    address public marketingWallet = 0x7299336E094dd0f5a74f6bdCbfE7fECc401b81C4;
    address public buyBackWallet = 0x7299336E094dd0f5a74f6bdCbfE7fECc401b81C4;
    uint256 public buyBackPercentage = 0;

    address public pair;
    address public constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public constant ZERO = 0x0000000000000000000000000000000000000000;
    
    address[] public allBuyers;
    address[] public allBuysSinceLastJackpot;
    address[] private pathForBuyingJackpot = new address[](2);
    address[] private pathForSelling = new address[](2);
    address[] private pathForBuying = new address[](2);
    address[] private pathFromBNBToBUSD = new address[](2);

    struct Winners{
        uint256 round;
        address winner;
        uint256 prize;
    }

    Winners[] public winners;
    address[] public winnersOfCurrent;

    modifier onlyOwner() {if(msg.sender != CEO) return; _;}
    modifier contractSelling() {isSwapping = true; _; isSwapping = false;}
    modifier onlyVRF() {if(msg.sender != address(randomnessSupplier)) return; _;}

    event Winner(address winner, uint256 tokensWon);
    event Blacklisted(address account, bool status);

    constructor() {
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
        lastBuyer = marketingWallet;
      
        
        _balances[CEO] = _totalSupply;
        emit Transfer(address(0), CEO, _totalSupply);
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

    function conditionsToSwapAreMet(address sender) internal view returns (bool) {
        return sender != pair && _balances[address(this)] > swapTokensAtAmount;
    }
    
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if(addressWithoutLimits[sender]|| addressWithoutLimits[recipient]) return _basicTransfer(sender, recipient, amount);
        if(recipient != address(this) &&  recipient != address(router) && recipient != address(pair)) {
            uint256 balanceReciver = balanceOf(recipient);
            require(balanceReciver + amount <= maxWallet, "Exceeds maximum wallet token amount." );
        }
        if(isSwapping == true) return _lowGasTransfer(sender, recipient, amount);
        
        require(launchTime < block.timestamp, "Trading not live yet");
        require(!blacklisted(sender) && !blacklisted(recipient), "Error: Blacklisted sender or recipient");


        
        // last buyer won: let's pay him
        if(block.timestamp - lastBuy > jackpotTimer && !jackpotWillBeDistributed) payOutJackpot();

        // jackpot is too big, let's distribute it    
        if(winnersHaveBeenChosen && jackpotWillBeDistributed) distributeJackpot();
        
        if(sender == pair && bigEnoughBuy(amount)){
            lastBuyer = recipient; 
            lastBuy = block.timestamp;
            allBuysSinceLastJackpot.push(recipient);
            if(!buyerRegistered[recipient]) {
                buyerRegistered[recipient] = true;
                allBuyers.push(recipient);
            }
        }

        // if we have enough tokens, let's sell them for jackpot, marketing and liquidity
        if (conditionsToSwapAreMet(sender)) letTheContractSell();
       
       
        
        // calculate effective amount that get's transferred
        uint256 finalamount = takeTax(sender, recipient, amount);
            
             

        // do the transfer
        return _basicTransfer(sender, recipient, finalamount);
    }

    function takeTax(address sender, address recipient, uint256 amount) internal returns (uint256) {
        // tax free for wallet to wallet
        if(sender != pair && recipient != pair) return amount;

        if(happyHour && happyHourEnd < block.timestamp) happyHour = false;
        
        uint256 taxAmount = amount * tax / 100;

        if(recipient == pair){
            if(happyHour) taxAmount *= 2;

        } else {
            if(happyHour) taxAmount /= 2;
        }

        if (taxAmount > 0) _lowGasTransfer(sender, address(this), taxAmount);
        return amount - taxAmount;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if(recipient == DEAD && circulatingSupply() - amount < circulatingSupplyLimit) amount = circulatingSupply() - circulatingSupplyLimit;
        
        return _lowGasTransfer(sender, recipient, amount);
    }

    function _lowGasTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function letTheContractSell() internal {
        uint256 tokensThatTheContractWillSell = _balances[address(this)] * (tax - liq) / tax;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensThatTheContractWillSell,
            0,
            pathForSelling,
            address(this),
            block.timestamp
        );

        // adding tokens to liquidity pool
        if(_balances[address(this)] > 0){
            _lowGasTransfer(address(this), pair, _balances[address(this)]);
            IDEXPair(pair).sync();
        }
       
        // dividing the BNB between marketing and jackpot
        uint256 contractBalanceWithoutJackpot = address(this).balance - jackpotBalance;
        payable(marketingWallet).transfer(contractBalanceWithoutJackpot * marketing / tax);
        jackpotBalance += contractBalanceWithoutJackpot * jackpot / tax;

        if(jackpotBalanceInBUSD() > maxJackpotBalanceBeforeDistribute) drawWinnersOfJackpotDistribution();
    }

    function bigEnoughBuy(uint256 amount) public view returns (bool) {
        if (minBuy == 0) return true;
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

/////////////////// ADMIN FUNCTIONS ///////////////////////////////////////////////////////////////////////
    function launch() external onlyOwner {
        launchTime = block.timestamp;
        lastBuy = block.timestamp;
    }

    // set max wallet, can not be lower than 0.1% of supply
    //function setmaxWallet(uint256 value) external onlyOwner {
        //value = value * (10**9);
        //require(value >= _totalSupply / 1000, "max wallet cannot be set to less than 0.1%");
        //maxWallet = value;
   //}    
    
    function toggleBlacklist(address account) external onlyOwner {
        _blacklist[account] = !_blacklist[account];
        emit Blacklisted(account, _blacklist[account]);
    }    
    
    function blacklisted(address account) public view returns(bool) {
        return _blacklist[account];
    }    
    
    function makeContractSell() external onlyOwner {
        letTheContractSell();
    }

    function addBNBToJackpotManually() external payable {
        if (msg.value > 0) jackpotBalance += msg.value;
    }

    function airdropToWallets(address[] memory airdropWallets, uint256[] memory amount) external onlyOwner {
        for (uint256 i = 0; i < airdropWallets.length; i++) {
            _basicTransfer(msg.sender, airdropWallets[i], amount[i] * (10**_decimals));
        }
    }

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
        pathForBuyingJackpot[1] = newJackpotToken;
        address jackpotPair = IDEXFactory(IDEXRouter(router).factory()).getPair(WETH, newJackpotToken);
        uint256 wbnbBalanceOfJackpotPair = IBEP20(WETH).balanceOf(jackpotPair);
        require(wbnbBalanceOfJackpotPair > 10 ether, "Can't choose token with small liquidity as jackpotToken");
    }

    function setTax(uint256 newLiq, uint256 newMarketing, uint256 newJackpot) external onlyOwner {
        liq = newLiq;
        marketing = newMarketing;
        jackpot = newJackpot;
        tax = liq + marketing + jackpot;
        require(tax <= 11, "Tax limited to max 11%");
    }

    function setAddressWithoutLimits(address unlimitedAddress, bool status) external onlyOwner {
        addressWithoutLimits[unlimitedAddress] = status;
    }

    function rescueAnyToken(address token) external onlyOwner {
        require(token != address(this), "Can't rescue MoonPot");
        IBEP20(token).transfer(msg.sender, IBEP20(token).balanceOf(address(this)));
    }

    function drawWinnersOfJackpotDistribution() internal {
        jackpotWillBeDistributed = true;
        randomnessSupplier.requestRandomness{value: vrfCost}(nonce, 2);
        jackpotBalance -= vrfCost;
    }

    function supplyRandomness(uint256 _nonce, uint256[] memory randomNumbers) external onlyVRF {
        if(nonceProcessed[_nonce]) {
            if(winnersOfCurrent[0] == address(0)) winnersOfCurrent[0] = allBuysSinceLastJackpot[(randomNumbers[0] % allBuysSinceLastJackpot.length)];
            if(winnersOfCurrent[1] == address(0)) winnersOfCurrent[1] = allBuyers[(randomNumbers[1] % allBuyers.length)];
        } else{
            nonceProcessed[_nonce] = true;
            winnersOfCurrent.push(allBuysSinceLastJackpot[(randomNumbers[0] % allBuysSinceLastJackpot.length)]);
            winnersOfCurrent.push(allBuyers[(randomNumbers[1] % allBuyers.length)]);
        }

        if(!bigEnoughBuy(_balances[winnersOfCurrent[0]])) winnersOfCurrent[0] = address(0);
        if(!bigEnoughBuy(_balances[winnersOfCurrent[1]])) winnersOfCurrent[1] = address(0);
        
        if(winnersOfCurrent[0] == address(0) || winnersOfCurrent[1] == address(0)) {
            randomnessSupplier.requestRandomness{value: vrfCost}(_nonce, 2);
            jackpotBalance -= vrfCost;
        } else {
            winnersHaveBeenChosen = true;
            delete allBuysSinceLastJackpot;
        }
    }

    function payOutJackpot() internal {
        if (jackpotBalance == 0) return;
        uint256 carryOver = jackpotBalance / 100;
        jackpotBalance = jackpotBalance - carryOver;
        sendHalfToMarketingAndBuyBack();
        
        if(!payJackpotInToken) {
            payable(lastBuyer).transfer(jackpotBalance);
        } else { 
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: jackpotBalance}(
                0,
                pathForBuyingJackpot,
                address(this),
                block.timestamp
            );
            uint256 dogeBalance = jackpotToken.balanceOf(address(this));
            jackpotToken.transfer(lastBuyer,dogeBalance);
            
            emit Winner(lastBuyer, dogeBalance);
            totalDogePaidFromJackpot += dogeBalance;
            Winners memory currentWinner;
            currentWinner.round = totalJackpotPayouts;
            currentWinner.winner = lastBuyer;
            currentWinner.prize = dogeBalance;
            winners.push(currentWinner);
            totalJackpotPayouts++;
        }
            
        jackpotBalance = carryOver;
    }

    function distributeJackpot() internal {
        uint256 carryOver = jackpotBalance / 100;
        jackpotBalance = jackpotBalance - carryOver;
        sendHalfToMarketingAndBuyBack();
        
        if(!payJackpotInToken) {
            payable(winnersOfCurrent[0]).transfer(jackpotBalance * 3 / 4);
            payable(winnersOfCurrent[1]).transfer(jackpotBalance / 4);
            jackpotBalance = 0;
            jackpotWillBeDistributed = false;
            winnersHaveBeenChosen = false;
        } else {
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: jackpotBalance}(
                0,
                pathForBuyingJackpot,
                address(this),
                block.timestamp
            );
            uint256 dogeBalance = jackpotToken.balanceOf(address(this));
            totalDogePaidFromJackpot += dogeBalance;
            jackpotToken.transfer(winnersOfCurrent[0],dogeBalance * 3 / 4);
            Winners memory currentWinner;
            currentWinner.round = totalJackpotPayouts;
            currentWinner.winner = winnersOfCurrent[0];
            currentWinner.prize = dogeBalance * 3 / 4;
            winners.push(currentWinner);
            emit Winner(winnersOfCurrent[0], dogeBalance * 3 / 4);

            dogeBalance = jackpotToken.balanceOf(address(this));
            jackpotToken.transfer(winnersOfCurrent[1],dogeBalance);
            currentWinner.round = totalJackpotPayouts;
            currentWinner.winner = winnersOfCurrent[1];
            currentWinner.prize = dogeBalance;
            winners.push(currentWinner);
            emit Winner(winnersOfCurrent[0], dogeBalance);

            totalJackpotPayouts++;
            }
        delete winnersOfCurrent;
        jackpotBalance = carryOver;
        jackpotWillBeDistributed = false;
        winnersHaveBeenChosen = false;
        nonce++;
    }
}