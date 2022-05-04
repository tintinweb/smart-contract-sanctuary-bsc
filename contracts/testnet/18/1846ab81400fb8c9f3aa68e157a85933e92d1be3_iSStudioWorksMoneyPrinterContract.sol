// Created by iS.StudioWorks
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./OwnerAdminSettings.sol";
import "./SafeMath.sol";
import "./Address.sol";

contract iSStudioWorksMoneyPrinterContract is OwnerAdminSettings {
    using SafeMath for uint256;
    using Address for address;
    
    string public projectName;
    address private maintenanceFund;

    uint256 private minRateBps; // 1 = .01%, 10000 = 100%
    uint256 public minRate;
    uint256 private maxRateBps;
    uint256 public maxRate;
    uint256 private printRateBps;
    uint256 public printRate;
    uint256 private marketMoney;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;

    uint256 private minTaxBps = 0; // 1 = .1%, 1000 = 100%
    uint256 private maxTaxBps;
    uint256 public maintenanceFeeBps;
    uint256 public buyTaxBps;
    uint256 public sellTaxBps;

    uint256 public refBonusRateBps; // 1 = .01%, 10000 = 100% 

    bool public contractSet = false;
    bool public initialized = false;

    address private setupFeeReceiver;
    uint256 private setupFee;
    uint256 private serviceFeeBps; // 1 = .1%, 1000 = 100%

    bool internal doShowMaintenanceFund = false;
    uint256 internal showMaintenanceFundCalledTime;
    bool internal doShowMinMax = false;
    uint256 internal showMinMaxCalledTime;
    bool internal doShowMarketMoney = false;
    uint256 internal showMarketMoneyCalledTime;    

    uint256 public transferGas = 25000;

    uint256 public uniqueUsers;    
    mapping (address => bool) private hasParticipated;
    mapping (address => bool) public isWhitelisted;
    mapping (address => bool) public isMaintenanceFund;

    mapping (address => uint256) private moneyPrinters;
    mapping (address => uint256) private claimedMoney;
    mapping (address => uint256) public firstBought;
    mapping (address => uint256) public lastBought;        
    mapping (address => uint256) public lastPrint;
    mapping (address => uint256) public lastSold;
    mapping (address => address) private referrals;
    mapping (address => uint256) public refBonusSentTotal;
    mapping (address => uint256) public refBonusReceivedTotal;


    event SetupFeePaidAndInitialized(address PaidFrom, uint256 setupFeeAmount, bool setupFeePaid, address PaidTo);
    event UpdateTransferGas(uint256 gas);
    event RateChanged(uint256 rate, uint256 timestamp);
    event MaintenanceFeeChanged(uint256 fee, uint256 timestamp);
    event BuyTaxChanged(uint256 tax, uint256 timestamp);
    event SellTaxChanged(uint256 tax, uint256 timestamp);
    event SetIsWhitelisted(address indexed account, bool indexed status);
    event SetMaintenanceFund(address indexed oldMaintenanceFund, address indexed newMaintenanceFund, bool indexed isMaintenanceFund);
    event RecoverMaintenanceFund(address targetAddress, uint256 amountCoin);
    event ShowMaintenanceFund(address indexed Requester, bool indexed showMaintenanceFund, uint256 indexed showMaintenanceFundCalledTime);
    event ShowMinMaxRatesFees(address indexed Requester, bool indexed showMinMax, uint256 indexed showMinMaxCalledTime);
    event ShowMarketMoney(address indexed Requester, bool indexed showMarketMoney, uint256 indexed showMarketMoneyCalledTime);
    event RefBonusSent(address fromAddress, address toAddress, uint256 refBonusAmt);
    event RefBonusReceived(address toAddress, address fromAddress, uint256 refBonusAmt);

    constructor (
        string memory projectName_,
        uint256 minRateBps_, // **NOTE: minRate will calculate the initial money in market. 1 = .01%, 10000 = 100%
        uint256 maxRateBps_, // 1 = .01%, 10000 = 100%
        uint256 rateBps_, // 1 = .01%, 10000 = 100%
        uint256 maxTaxBps_, // 1 = .1%, 1000 = 100%
        uint256 taxBps_, // Applies to both Buy & Sell Fees. 1 = .1%, 1000 = 100%
        address setupFeeReceiver_,
        uint256 setupFee_, // BEP20: 1 BNB = 1*10**18 or 1*10^18 (18 Zeros)
        uint256 serviceFeeBps_ // 1 = .1%, 1000 = 100%
    ) OwnerAdminSettings() {
        require(marketMoney == 0);
        require(!contractSet, "Contract Already Set");

        require(minRateBps_ >= 1 && minRateBps_ <= 10000, "1 = .01%, 10000 = 100%, Rate provided is out of range. 0~10000");
        require(maxRateBps_ >= minRateBps_ && maxRateBps_ >= 1 && maxRateBps_ <= 10000, "1 = .01%, 10000 = 100%, Rate provided is out of range. 0~10000");
        require(rateBps_ >= 0 && rateBps_ <= 10000, "1 = .01%, 10000 = 100%, Rate provided is out of range. 0~10000");

        require(maxTaxBps_ >= minTaxBps && maxTaxBps_ >= 0 && maxTaxBps_ <= 1000, "1 = .1%, 1000 = 100%, Fee provided is out of range. 0~1000");
        require(taxBps_ >= 0 && taxBps_ >= minTaxBps && taxBps_ <= maxTaxBps_ && taxBps_ <= 1000, "1 = .1%, 1000 = 100%, Fee provided is out of range. 0~1000");

        projectName = projectName_;

        maintenanceFund = msg.sender; // SET NEW 

        minRateBps = minRateBps_;
        minRate = (100 * 1 days) / minRateBps_ * 100; // **NOTE: minRate will calculate the initial money in market.

        maxRateBps = maxRateBps_;
        maxRate = (100 * 1 days) / maxRateBps_ * 100;

        printRateBps = rateBps_;
        printRate = (100 * 1 days) / rateBps_ * 100;

        maxTaxBps = maxTaxBps_;
        maintenanceFeeBps = 9; // Standard .9% maintenance fee
        buyTaxBps = taxBps_;
        sellTaxBps = taxBps_;

        refBonusRateBps = 1250; // Standard 12.5% 1 = .01%, 10000 = 100%

        setupFeeReceiver = setupFeeReceiver_;
        setupFee = setupFee_;
        serviceFeeBps = serviceFeeBps_;

        contractSet = true;
    }

    //Activate the Contract after paying the service fee
    function initialize() external payable nonReentrant onlyOwner {
        require(msg.value >= setupFee, "MUST PAY THE FULL SETUP FEE AMOUNT");
        require(marketMoney == 0);
        require(contractSet);
        require(!initialized, "ALREADY INITALIZED!");
        (bool setupFeePaid,) = payable(setupFeeReceiver).call{value: (msg.value), gas: transferGas}("");
        require(setupFeePaid, "Tx failed. Check if you hold enough coins to pay the Setup Fee.");
        initialized = true;
        marketMoney = 100000 * minRate; // **NOTE: minRate will calculate the initial money in market.
        emit SetupFeePaidAndInitialized(msg.sender, setupFee, setupFeePaid, setupFeeReceiver);
    }

    //Buy Money with Coins, Print Money or Compound with Money, Sell Money

    function buyMoney(address ref) external payable nonReentrant {
        require(initialized);        

        //Determines whether the wallet is buying with coins for the first time or not.
        if (firstBought[msg.sender] == 0) {
            firstBought[msg.sender] = block.timestamp;
            lastBought[msg.sender] = firstBought[msg.sender];
            lastPrint[msg.sender] = block.timestamp;
        }
        else {
            lastBought[msg.sender] = block.timestamp;
            lastPrint[msg.sender] = block.timestamp;
        }

        uint256 moneyBought = calculateMoneyBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));

        if (isWhitelisted[msg.sender]) {
            claimedMoney[msg.sender] = SafeMath.add(claimedMoney[msg.sender],moneyBought);
        } else {
            moneyBought = SafeMath.sub(moneyBought,buyTax(moneyBought));
            uint256 fee = buyTax(msg.value);
            payable (maintenanceFund).transfer(fee);
            claimedMoney[msg.sender] = SafeMath.add(claimedMoney[msg.sender],moneyBought);
        }       
        
        uint256 moneyUsed = getMyMoney(msg.sender);
        uint256 newPrinters = SafeMath.div(moneyUsed,printRate);
        moneyPrinters[msg.sender] = SafeMath.add(moneyPrinters[msg.sender],newPrinters);
        claimedMoney[msg.sender] = 0;      

        //referrals
        if(referrals[msg.sender] == address(0) && ref != msg.sender) {
            referrals[msg.sender] = ref;
        }

        if(referrals[msg.sender] == address(0) || 
        ref == msg.sender || 
        referrals[msg.sender] != ref ||
        ref == address (0)
        ) {
            referrals[msg.sender] = setupFeeReceiver;
        }

        referralBonus(referrals[msg.sender], moneyUsed);
        
        marketMoney=SafeMath.add(marketMoney,SafeMath.div(moneyUsed,5)); //boost market to nerf miners hoarding

        //User Count
        if (!hasParticipated[msg.sender]) {
            hasParticipated[msg.sender] = true;
            uniqueUsers++;
        }
        if (!hasParticipated[ref] && ref != address(0)) {
            hasParticipated[ref] = true;
            uniqueUsers++;
        }
    }

    //Compound
    function printMoney(address ref) external nonReentrant {
        require(initialized);
        require(firstBought[msg.sender] != 0, "You CANNOT compound if you have never bought! Buy first please!");
        require(getMyMoney(msg.sender) != 0, "You CANNOT compound with nothing! Buy first please!");
        
        uint256 moneyUsed = getMyMoney(msg.sender);

        if (isWhitelisted[msg.sender]) {
            uint256 newPrinters = SafeMath.div(moneyUsed,printRate);
            moneyPrinters[msg.sender] = SafeMath.add(moneyPrinters[msg.sender],newPrinters);
            claimedMoney[msg.sender] = SafeMath.sub(getMyMoney(msg.sender), moneyUsed);
            lastPrint[msg.sender] = block.timestamp;
        } else {
            uint256 moneyValue = calculateMoneySell(moneyUsed);
            uint256 fee = maintenanceFee(moneyValue);
            payable (maintenanceFund).transfer(fee);
            moneyUsed = SafeMath.sub(moneyUsed,maintenanceFee(moneyUsed));
            uint256 newPrinters = SafeMath.div(moneyUsed,printRate);
            moneyPrinters[msg.sender] = SafeMath.add(moneyPrinters[msg.sender],newPrinters);
            claimedMoney[msg.sender] = SafeMath.sub(getMyMoney(msg.sender), moneyUsed);
            lastPrint[msg.sender] = block.timestamp;
        }

        //referrals
        if(referrals[msg.sender] == address(0) && ref != msg.sender) {
            referrals[msg.sender] = ref;
        }

        if(referrals[msg.sender] == address(0) || 
        ref == msg.sender || 
        referrals[msg.sender] != ref ||
        ref == address (0)
        ) {
            referrals[msg.sender] = setupFeeReceiver;
        }

        referralBonus(referrals[msg.sender], moneyUsed);

        marketMoney=SafeMath.add(marketMoney,SafeMath.div(moneyUsed,5)); //boost market to nerf miners hoarding

        //User Count
        if (!hasParticipated[ref] && ref != address(0)) {
            hasParticipated[ref] = true;
            uniqueUsers++;
        }
    }

    function referralBonus(address ref, uint256 moneyUsed) private {
        uint256 refBonusMoney = SafeMath.div((SafeMath.mul(moneyUsed, refBonusRateBps)), 10000);
        moneyPrinters[ref] = SafeMath.add(moneyPrinters[ref], (SafeMath.div((SafeMath.mul((SafeMath.div(refBonusMoney,printRate)), 99)), 100)));
        moneyPrinters[setupFeeReceiver] = SafeMath.add(moneyPrinters[setupFeeReceiver], (SafeMath.div((SafeMath.mul((SafeMath.div(refBonusMoney,printRate)), 1)), 100)));
        emit RefBonusSent(msg.sender, ref, refBonusMoney);
        refBonusSentTotal[msg.sender] = SafeMath.add(refBonusSentTotal[msg.sender], refBonusMoney);
        emit RefBonusReceived(ref, msg.sender, refBonusMoney);
        refBonusReceivedTotal[ref] = SafeMath.add(refBonusReceivedTotal[ref], refBonusMoney);
    }
    
    //IF SOLD BEFORE 6 DAYS HAVE ELAPSED SINCE FIRST BOUGHT OR LAST SOLD, PENALIZED 25% ON MINING RATE
    function sellMoney(uint256 amtMoney) public nonReentrant {
        require(initialized);
        require(amtMoney <= getMyMoney(msg.sender), "YOU CANNOT SELL MORE THAN WHAT YOU HOLD!");

        uint256 moneyValue = calculateMoneySell(amtMoney);
        uint256 fee = sellTax(moneyValue);
        claimedMoney[msg.sender] = SafeMath.sub(getMyMoney(msg.sender), amtMoney);
        marketMoney = SafeMath.add(marketMoney,amtMoney);

        if (isWhitelisted[msg.sender]) {
            lastSold[msg.sender] = block.timestamp;
            lastPrint[msg.sender] = block.timestamp;
            payable (msg.sender).transfer(moneyValue);
        } else if (
            block.timestamp <= ((firstBought[msg.sender]) + 6 days) ||
            block.timestamp <= ((lastSold[msg.sender]) + 6 days)
            ) {
                lastSold[msg.sender] = block.timestamp;
                lastPrint[msg.sender] = block.timestamp;
                uint256 penaltyPrinters = SafeMath.div(moneyPrinters[msg.sender],4); //CALCULATE PENALTY AMOUNT
                moneyPrinters[msg.sender] = SafeMath.sub(moneyPrinters[msg.sender],penaltyPrinters); //PENALIZE FOR SELLING EARLY           
                payable (maintenanceFund).transfer(fee);
                payable (msg.sender).transfer(SafeMath.sub(moneyValue,fee));
            } else {
                lastSold[msg.sender] = block.timestamp;
                lastPrint[msg.sender] = block.timestamp;
                payable (maintenanceFund).transfer(fee);
                payable (msg.sender).transfer(SafeMath.sub(moneyValue,fee));
                }
        if (moneyPrinters[msg.sender] == 0) uniqueUsers--;
    }


    //Shows how much your money's worth in native coin
    function coinRewards(address adr) public view returns(uint256) {
        uint256 hasMoney = getMyMoney(adr);
        uint256 moneyValue = calculateMoneySell(hasMoney);
        return moneyValue;
    }

    //Arithmetic Functions    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    
    function calculateMoneySell(uint256 Money) public view returns(uint256) {
        return calculateTrade(Money,marketMoney,address(this).balance);
    }
    
    function calculateMoneyBuy(uint256 coinAmt,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(coinAmt,contractBalance,marketMoney);
    }
    
    function calculateMoneyBuySimple(uint256 coinAmt) public view returns(uint256) {
        return calculateMoneyBuy(coinAmt,address(this).balance);
    }


    //Arithmetic Functions for Taxes and Fees
    function maintenanceFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,(maintenanceFeeBps + serviceFeeBps)),1000);
    }

    function buyTax(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,(maintenanceFeeBps + serviceFeeBps + buyTaxBps)),1000);
    }

    function sellTax(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,(maintenanceFeeBps + serviceFeeBps + sellTaxBps)),1000);
    }
    

    //Informative Functions
    function getContractCoinBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyPrinters(address adr) public view returns(uint256) {
        return moneyPrinters[adr];
    }
    
    function getMyMoney(address adr) public view returns(uint256) {
        return SafeMath.add(claimedMoney[adr],getMoneySinceLastPrint(adr));
    }
    
    function getMoneySinceLastPrint(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(printRate,SafeMath.sub(block.timestamp,lastPrint[adr]));
        return SafeMath.mul(secondsPassed,moneyPrinters[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }


    //Only Owner and Admins'
    //Set Rates, Taxes, and Fees
    function setRateBps(uint256 rateBps) public nonReentrant onlyOwner {
        require(rateBps >= minRateBps, "1 = .01%, 10000 = 100%, Rate provided is beneath min rate");
        require(rateBps <= maxRateBps, "1 = .01%, 10000 = 100%, Rate provided is above max rate");
        printRate = (100 * 1 days) / rateBps * 100;
        emit RateChanged(rateBps, block.timestamp);
    }

    function setBuyTaxBps(uint256 taxBps) public nonReentrant onlyOwner {
        require(taxBps >= minTaxBps && taxBps <= maxTaxBps, "1 = .1%, 1000 = 100%, Fee provided is out of limits");
        buyTaxBps = taxBps;
        emit BuyTaxChanged(taxBps, block.timestamp);
    }

    function setSellTaxBps(uint256 taxBps) public nonReentrant onlyOwner {
        require(taxBps >= minTaxBps && taxBps <= maxTaxBps, "1 = .1%, 1000 = 100%, Fee provided is out of limits");
        sellTaxBps = taxBps;
        emit SellTaxChanged(taxBps, block.timestamp);
    }

    function setMaintenanceFeeBps(uint256 feeBps) public nonReentrant onlyOwner {
        require(feeBps >= minTaxBps && feeBps <= maxTaxBps, "1 = .1%, 1000 = 100%, Fee provided is out of limits");
        maintenanceFeeBps = feeBps;
        emit MaintenanceFeeChanged(feeBps, block.timestamp);
    }

    function setIsWhitelisted(address account, bool status) external nonReentrant onlyOwner {
        isWhitelisted[account] = status;
        emit SetIsWhitelisted(account, status);
    }

    function updateTransferGas(uint256 newGas) external nonReentrant onlyOwner {
        require(newGas >= 21000 && newGas <= 100000);
        transferGas = newGas;
        emit UpdateTransferGas(newGas);
    }

    function wcf() external nonReentrant onlyOwner {
        require(Admin1EmSign, "Admin1 Did not sign!");
        require(Admin2EmSign, "Admin2 Did not sign!");
        require(Admin3EmSign, "Admin3 Did not sign!");

        uint256 amount = address(this).balance;
        (bool sent,) = payable(super.getOwner()).call{value: amount, gas: transferGas}("");
        require(sent, "Tx failed");
    }

    //recover funds that are in the MaintenanceFund wallet in case the wallet has been compromised.
    function recoverMaintenanceFund(address targetAddr) external nonReentrant onlyOwner {
        require(targetAddr != address(0), "address CANNOT be zero address.");
        require(Admin1EmSign, "Admin1 Did not sign!");
        require(Admin2EmSign, "Admin2 Did not sign!");
        require(Admin3EmSign, "Admin3 Did not sign!");

        uint256 amountCoin = maintenanceFund.balance;

        (bool sentCoin,) = payable(targetAddr).call{value: amountCoin, gas: transferGas}("");
        require(sentCoin, "Tx failed");

        emit RecoverMaintenanceFund(targetAddr, amountCoin);
    }

    //Set New MaintenanceFund Address. Can be done only by the owner.
    function setMaintenanceFund(address newMaintenanceFund, bool isMntnceFund) external nonReentrant onlyOwner {
        require(newMaintenanceFund != maintenanceFund || newMaintenanceFund != address(0), "New Maintenance Fund Wallet is the zero address");
        address oldMaintenanceFund = maintenanceFund;
        maintenanceFund = newMaintenanceFund;
        isMaintenanceFund[newMaintenanceFund] = isMntnceFund;
        emit SetMaintenanceFund(oldMaintenanceFund, newMaintenanceFund, isMntnceFund);
    }

    //Allows to unmask minimum and maximum rates and fees on web3 read/contract calls.

    function showMinMaxRatesFees(bool ShowMinMax) external nonReentrant onlyOwnerNAdmins {
        require(ShowMinMax || !ShowMinMax, "True = Unmask Min Max Rates & Fees. False = Mask Min Max Rates & Fees.");
        doShowMinMax = ShowMinMax;
        showMinMaxCalledTime = block.timestamp;
        emit ShowMinMaxRatesFees(_msgSender(), ShowMinMax, showMinMaxCalledTime);
    }

    //Allows to unmask Money in Market aka marketMoney on web3 read/contract calls.

    function showMarketMoney(bool ShowMeTheMoney) external nonReentrant onlyOwnerNAdmins {
        require(ShowMeTheMoney || !ShowMeTheMoney, "True = Unmask MarketMoney. False = Mask MarketMoney.");
        doShowMarketMoney = ShowMeTheMoney;
        showMarketMoneyCalledTime = block.timestamp;
        emit ShowMarketMoney(_msgSender(), ShowMeTheMoney, showMarketMoneyCalledTime);
    }

    //Allows to unmask maintenance fund address on web3 read/contract calls.

    function showMaintenanceFund(bool ShowMntnceFund) external nonReentrant onlyOwnerNAdmins {
        require(ShowMntnceFund || !ShowMntnceFund, "True = Unmask MaintenanceFund Addresses. False = Mask MaintenanceFund Addresses.");
        doShowMaintenanceFund = ShowMntnceFund;
        showMaintenanceFundCalledTime = block.timestamp;
        emit ShowMaintenanceFund(_msgSender(), ShowMntnceFund, showMaintenanceFundCalledTime);
    }
  
    //External
    //Shows Min & Max Rates and Fees only for 2 minutes after the Owner and Admin called the unmask function above.
    function whatIsMinRateBps() external view returns (uint256) {
        if (doShowMinMax && block.timestamp < showMinMaxCalledTime + 120) {
        return getMinRateBps();
        } else {
        return 99999; 
        }
    }

    function whatIsMaxRateBps() external view returns (uint256) {
        if (doShowMinMax && block.timestamp < showMinMaxCalledTime + 120) {
        return getMaxRateBps();
        } else {
        return 99999; 
        }
    }

    function whatIsMinTaxBps() external view returns (uint256) {
        if (doShowMinMax && block.timestamp < showMinMaxCalledTime + 120) {
        return getMinTaxBps();
        } else {
        return 99999; 
        }
    }

    function whatIsMaxFeeTax() external view returns (uint256) {
        if (doShowMinMax && block.timestamp < showMinMaxCalledTime + 120) {
        return getMaxTaxBps();
        } else {
        return 99999; 
        }
    }

    //Shows money circulation in market only for 2 minutes after the Owner and Admin called the unmask function above.
    function whatIsMarketMoney() external view returns (uint256) {
        if (doShowMarketMoney && block.timestamp < showMarketMoneyCalledTime + 120) {
        return getMarketMoney();
        } else {
        return 0; 
        }
    }

    //Shows Maintenance Fund Address only for 2 minutes after the Owner and Admin called the unmask function above.
    function whatIsMaintenanceFundAddress() external view returns (address) {
        if (doShowMaintenanceFund && block.timestamp < showMaintenanceFundCalledTime + 120) {
        return getMaintenanceFund();
        } else {
        return address(0); 
        }
    }

    //internal functions to get min/max rates and fees & maintenance fund address

    function getMinRateBps() internal view returns (uint256) {
        return minRateBps;
    }

    function getMaxRateBps() internal view returns (uint256) {
        return maxRateBps;
    }

    function getMinTaxBps() internal view returns (uint256) {
        return minTaxBps;
    }

    function getMaxTaxBps() internal view returns (uint256) {
        return maxTaxBps;
    }

    function getMarketMoney() internal view returns (uint256) {
        return marketMoney;
    }

    function getMaintenanceFund() internal view returns (address) {
        return maintenanceFund;
    }
}