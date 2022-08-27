// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

import "./w-IERC20.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./mathFunclib.sol";

//TODO: Change back to WandInvestments
contract WandInvestmentsdev is ReentrancyGuard, Ownable {
    //TODO: update
    uint256 public constant SEED_AMOUNT_1 = 9411764706 * 10**12;
    uint256 public constant SEED_AMOUNT_2 = 4470588235 * 10**13;
    uint256 public constant SEED_AMOUNT_3 = 4705882353 * 10**13;
    uint256 public constant SEED_AMOUNT = SEED_AMOUNT_1 + SEED_AMOUNT_2 + SEED_AMOUNT_3;

    uint256 constant DECIMALS = 10**18;
    uint256 constant SECONDS_IN_A_DAY = 60 * 60 * 24;

    // The contract attempts to transfer the stable coins from the SCEPTER_TREASURY_ADDR
    // and the BATON_TREASURY_ADDR address. Therefore, these addresses need to approve
    // this contract spending those coins. Call the `approve` function on the stable
    // coins and supply them with the address of this contract as the `spender` and
    // 115792089237316195423570985008687907853269984665640564039457584007913129639935
    // as the `amount`.
    //TODO: update to correct addresses
    address public constant SCEPTER_TREASURY_ADDR = 0xBDEd6A9580900154597e3aFcEDe38f92D132638e;
    address public constant BATON_TREASURY_ADDR = 0x9D48c6D5823bb5e73798F07d577A1F36D973722a;
    address public constant DEV_WALLET_ADDR = 0x25f9860e2c422c67498806aDD2fDA39809C7bd1f;

    // This contract needs to be allowed to mint and burn the Scepter, Wand, and Baton tokens
    // to and from any address.
    //TODO: update
    IERC20 public constant SPTR = IERC20(0x70CCc0AA6C114527bFB771C37224d8d220306039);
    IERC20 public constant WAND = IERC20(0xE4CD53870C81F4339bECc48fC397c66CEed5d409);
    IERC20 public constant BTON = IERC20(0xceBB185d0749eC90EC9f7fE7488Cd314cCfafb3d);

    address public adminDelegator;

    bool public tradingEnabled = false;

    struct WLData {
        uint256 buyLimit;
        uint256 SPTRBought;
    }
    mapping(address => WLData) public whiteListees;

    uint256 public timeLaunched = 0;
    uint256 public daysInCalculation;

    struct ScepterData {
        uint256 sptrGrowthFactor;
        uint256 sptrSellFactor;
        uint256 sptrBackingPrice;
        uint256 sptrSellPrice;
        uint256 sptrBuyPrice;
        uint256 sptrTreasuryBal;
    }
    ScepterData public scepterData;

    struct BatonData {
        uint256 btonBackingPrice;
        uint256 btonRedeemingPrice;
        uint256 btonTreasuryBal;
    }
    BatonData public batonData;

    mapping(uint256 => uint256) public tokensBoughtXDays;
    mapping(uint256 => uint256) public tokensSoldXDays;
    mapping(uint256 => uint256) public circulatingSupplyXDays;
    mapping(uint256 => bool) private setCircSupplyToPreviousDay;

    struct stableTokensParams {
        address contractAddress;
        uint256 tokenDecimals;
    }
    mapping (string => stableTokensParams) public stableERC20Info;

    struct lockedamounts {
        uint256 timeUnlocked;
        uint256 amounts;
    }
    mapping(address => lockedamounts) public withheldWithdrawals;

    mapping(address => uint256) public initialTimeHeld;
    mapping(address => uint256) public timeSold;

    struct btonsLocked {
        uint256 timeInit;
        uint256 amounts;
    }
    mapping(address => btonsLocked) public btonHoldings;

    event sceptersBought(address indexed _from, uint256 _amount);
    event sceptersSold(address indexed _from, uint256 _amount);

    constructor() {
        // Multisig address is the contract owner.
        //TODO: update owner and adminDelegator
        _transferOwnership(0x4a55c1181B4aeC55cF8e71377e8518E742F9Ae72);
        adminDelegator = 0xE913aaBdcCc107f2157ABDa2077C753D021616CC; 

        stableERC20Info["BUSD"].contractAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        stableERC20Info["BUSD"].tokenDecimals = 18;

        //TODO: update USDC contract address to 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d
        stableERC20Info["USDC"].contractAddress = 0x233406c3e4dc19B2F08341A1e77485b9e4B3936d;
        stableERC20Info["USDC"].tokenDecimals = 18;

        stableERC20Info["DAI"].contractAddress = 0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3;
        stableERC20Info["DAI"].tokenDecimals = 18;

        stableERC20Info["FRAX"].contractAddress = 0x90C97F71E18723b0Cf0dfa30ee176Ab653E89F40;
        stableERC20Info["FRAX"].tokenDecimals = 18;
    }

    function setCirculatingSupplyXDaysToPrevious(uint256 dInArray) private returns (uint256) {
        if (setCircSupplyToPreviousDay[dInArray]) {
            return circulatingSupplyXDays[dInArray];
        }
        setCircSupplyToPreviousDay[dInArray] = true;
        circulatingSupplyXDays[dInArray] = setCirculatingSupplyXDaysToPrevious(dInArray - 1);
        return circulatingSupplyXDays[dInArray];
    }

    function cashOutScepter(
        uint256 amountSPTRtoSell,
        uint256 daysChosenLocked,
        string calldata stableChosen
    )
        external nonReentrant
    {
        require(tradingEnabled, "Disabled");
        require(SPTR.balanceOf(msg.sender) >= amountSPTRtoSell, "You dont have that amount!");
        require(daysChosenLocked < 10, "You can only lock for a max of 9 days");

        uint256 usdAmt = mathFuncs.decMul18(
            mathFuncs.decMul18(scepterData.sptrSellPrice, amountSPTRtoSell),
            mathFuncs.decDiv18((daysChosenLocked + 1) * 10, 100)
        );

        require(usdAmt > 0, "Not enough tokens swapped");

        uint256 dInArray = (block.timestamp - timeLaunched) / SECONDS_IN_A_DAY;
        tokensSoldXDays[dInArray] += amountSPTRtoSell;
        setCirculatingSupplyXDaysToPrevious(dInArray);
        circulatingSupplyXDays[dInArray] -= amountSPTRtoSell;

        WAND.burn(SCEPTER_TREASURY_ADDR, amountSPTRtoSell);
        SPTR.burn(msg.sender, amountSPTRtoSell);

        if (daysChosenLocked == 0) {
            require(stableERC20Info[stableChosen].contractAddress != address(0), "Unsupported stable coin");
            IERC20 tokenStable = IERC20(stableERC20Info[stableChosen].contractAddress);

            uint256 usdAmtTrf = usdAmt / 10**(18 - stableERC20Info[stableChosen].tokenDecimals);
            uint256 usdAmtToUser = mathFuncs.decMul18(usdAmtTrf, mathFuncs.decDiv18(95, 100));

            require(usdAmtToUser > 0, "Not enough tokens swapped");

            scepterData.sptrTreasuryBal -= usdAmt;

            _safeTransferFrom(tokenStable, SCEPTER_TREASURY_ADDR, msg.sender, usdAmtToUser);
            _safeTransferFrom(tokenStable, SCEPTER_TREASURY_ADDR, DEV_WALLET_ADDR, usdAmtTrf - usdAmtToUser);
        } else {
            if (withheldWithdrawals[msg.sender].timeUnlocked == 0) {
                withheldWithdrawals[msg.sender].amounts = usdAmt;
                withheldWithdrawals[msg.sender].timeUnlocked =
                    block.timestamp + (daysChosenLocked * SECONDS_IN_A_DAY);
            } else {
                withheldWithdrawals[msg.sender].amounts += usdAmt;
                if (block.timestamp < withheldWithdrawals[msg.sender].timeUnlocked) {
                    withheldWithdrawals[msg.sender].timeUnlocked += (daysChosenLocked * SECONDS_IN_A_DAY);
                } else {
                    withheldWithdrawals[msg.sender].timeUnlocked =
                        block.timestamp + (daysChosenLocked * SECONDS_IN_A_DAY);
                }
            }
        }

        calcSPTRData();

        timeSold[msg.sender] = block.timestamp;
        if (SPTR.balanceOf(msg.sender) == 0 && BTON.balanceOf(msg.sender) == 0) {
            initialTimeHeld[msg.sender] = 0;
        }

        emit sceptersSold(msg.sender, amountSPTRtoSell);
    }

    function cashOutBaton(uint256 amountBTONtoSell, string calldata stableChosen) external nonReentrant {
        require(tradingEnabled, "Disabled");
        require(BTON.balanceOf(msg.sender) >= amountBTONtoSell, "You dont have that amount!");
        require(stableERC20Info[stableChosen].contractAddress != address(0), "Unsupported stable coin");

        IERC20 tokenStable = IERC20(stableERC20Info[stableChosen].contractAddress);
        uint256 usdAmt = mathFuncs.decMul18(batonData.btonRedeemingPrice, amountBTONtoSell);
        uint256 usdAmtTrf = usdAmt / 10**(18 - stableERC20Info[stableChosen].tokenDecimals);

        require(usdAmtTrf > 0, "Not enough tokens swapped");

        batonData.btonTreasuryBal -= usdAmt;

        btonHoldings[msg.sender].timeInit = block.timestamp;
        btonHoldings[msg.sender].amounts -= amountBTONtoSell;

        BTON.burn(msg.sender, amountBTONtoSell);
        _safeTransferFrom(tokenStable, BATON_TREASURY_ADDR, msg.sender, usdAmtTrf);

        calcBTONData();

        timeSold[msg.sender] = block.timestamp;
        if (SPTR.balanceOf(msg.sender) == 0 && BTON.balanceOf(msg.sender) == 0) {
            initialTimeHeld[msg.sender] = 0;
        }
    }

    function transformScepterToBaton(uint256 amountSPTRtoSwap, string calldata stableChosen) external nonReentrant {
        require(tradingEnabled, "Disabled");
        require(SPTR.balanceOf(msg.sender) >= amountSPTRtoSwap, "You dont have that amount!");
        require(stableERC20Info[stableChosen].contractAddress != address(0), "Unsupported stable coin");

        uint256 btonTreaAmtTrf = mathFuncs.decMul18(
            mathFuncs.decMul18(scepterData.sptrBackingPrice, amountSPTRtoSwap),
            mathFuncs.decDiv18(9, 10)
        );

        uint256 toTrf = btonTreaAmtTrf / 10**(18 - stableERC20Info[stableChosen].tokenDecimals);

        require(toTrf > 0, "Not enough tokens swapped");

        IERC20 tokenStable = IERC20(stableERC20Info[stableChosen].contractAddress);

        uint256 dInArray = (block.timestamp - timeLaunched) / SECONDS_IN_A_DAY;
        tokensSoldXDays[dInArray] += amountSPTRtoSwap;
        setCirculatingSupplyXDaysToPrevious(dInArray);
        circulatingSupplyXDays[dInArray] -= amountSPTRtoSwap;

        scepterData.sptrTreasuryBal -= btonTreaAmtTrf;

        batonData.btonTreasuryBal += btonTreaAmtTrf;

        btonHoldings[msg.sender].timeInit = block.timestamp;
        btonHoldings[msg.sender].amounts += amountSPTRtoSwap;

        WAND.burn(SCEPTER_TREASURY_ADDR, amountSPTRtoSwap);
        SPTR.burn(msg.sender, amountSPTRtoSwap);
        BTON.mint(msg.sender, amountSPTRtoSwap);
        calcSPTRData();
        _safeTransferFrom(tokenStable, SCEPTER_TREASURY_ADDR, BATON_TREASURY_ADDR, toTrf);
    }

    function buyScepter(uint256 amountSPTRtoBuy, string calldata stableChosen) external nonReentrant {
        require(tradingEnabled, "Disabled");
        require(timeLaunched != 0 && block.timestamp > timeLaunched + 172800, "Not launched for public.");
        require(amountSPTRtoBuy <= 250000 * DECIMALS , "Per transaction limit");
        require(stableERC20Info[stableChosen].contractAddress != address(0), "Unsupported stable coin");

        IERC20 tokenStable = IERC20(stableERC20Info[stableChosen].contractAddress);

        uint256 usdAmt = mathFuncs.decMul18(amountSPTRtoBuy, scepterData.sptrBuyPrice);
        uint256 usdAmtToPay = usdAmt / 10**(18 - stableERC20Info[stableChosen].tokenDecimals);

        require(tokenStable.balanceOf(msg.sender) >= usdAmtToPay, "You dont have that amount!");

        uint256 dInArray = (block.timestamp - timeLaunched) / SECONDS_IN_A_DAY;
        tokensBoughtXDays[dInArray] += amountSPTRtoBuy;
        setCirculatingSupplyXDaysToPrevious(dInArray);
        circulatingSupplyXDays[dInArray] += amountSPTRtoBuy;

        scepterData.sptrTreasuryBal += mathFuncs.decMul18(usdAmt, mathFuncs.decDiv18(95, 100));

        uint256 usdAmtToTreasury = mathFuncs.decMul18(usdAmtToPay, mathFuncs.decDiv18(95, 100));

        require(usdAmtToTreasury > 0, "Not enough tokens swapped");

        _safeTransferFrom(tokenStable, msg.sender, SCEPTER_TREASURY_ADDR, usdAmtToTreasury);
        _safeTransferFrom(tokenStable, msg.sender, DEV_WALLET_ADDR, usdAmtToPay - usdAmtToTreasury);

        SPTR.mint(msg.sender, amountSPTRtoBuy);
        WAND.mint(SCEPTER_TREASURY_ADDR, amountSPTRtoBuy);
        calcSPTRData();

        if (initialTimeHeld[msg.sender] == 0) {
            initialTimeHeld[msg.sender] = block.timestamp;
        }

        emit sceptersBought(msg.sender, amountSPTRtoBuy);
    }

    function wlBuyScepter(uint256 amountSPTRtoBuy, string calldata stableChosen) external nonReentrant {
        require(tradingEnabled, "Disabled");
        require(block.timestamp <= timeLaunched + 172800, "WL Sale closed");
        require(whiteListees[msg.sender].SPTRBought + amountSPTRtoBuy <= whiteListees[msg.sender].buyLimit, "Hit Limit");
        require(stableERC20Info[stableChosen].contractAddress != address(0), "Unsupported stable coin");

        IERC20 tokenStable = IERC20(stableERC20Info[stableChosen].contractAddress);

        uint256 usdAmt = amountSPTRtoBuy;
        uint256 usdAmtToPay = usdAmt / 10**(18 - stableERC20Info[stableChosen].tokenDecimals);
        require(tokenStable.balanceOf(msg.sender) >= usdAmtToPay, "You dont have that amount!");

        uint256 dInArray = (block.timestamp - timeLaunched) / SECONDS_IN_A_DAY;
        tokensBoughtXDays[dInArray] += amountSPTRtoBuy;
        setCirculatingSupplyXDaysToPrevious(dInArray);
        circulatingSupplyXDays[dInArray] += amountSPTRtoBuy;

        scepterData.sptrTreasuryBal += mathFuncs.decMul18(usdAmt, mathFuncs.decDiv18(95, 100));

        uint256 usdAmtToTreasury = mathFuncs.decMul18(usdAmtToPay, mathFuncs.decDiv18(95, 100));

        require(usdAmtToTreasury > 0, "Not enough tokens swapped");

        _safeTransferFrom(tokenStable, msg.sender, SCEPTER_TREASURY_ADDR, usdAmtToTreasury);
        _safeTransferFrom(tokenStable, msg.sender, DEV_WALLET_ADDR, usdAmtToPay - usdAmtToTreasury);

        whiteListees[msg.sender].SPTRBought += amountSPTRtoBuy;

        SPTR.mint(msg.sender, amountSPTRtoBuy);
        WAND.mint(SCEPTER_TREASURY_ADDR, amountSPTRtoBuy);
        calcSPTRData();

        if (initialTimeHeld[msg.sender] == 0) {
            initialTimeHeld[msg.sender] = block.timestamp;
        }

        emit sceptersBought(msg.sender, amountSPTRtoBuy);
    }

    function claimLockedUSD(string calldata stableChosen) external nonReentrant {
        require(tradingEnabled, "Disabled");
        require(withheldWithdrawals[msg.sender].timeUnlocked != 0, "No locked funds to claim");
        require(block.timestamp >= withheldWithdrawals[msg.sender].timeUnlocked, "Not unlocked");
        require(stableERC20Info[stableChosen].contractAddress != address(0), "Unsupported stable coin");

        IERC20 tokenStable = IERC20(stableERC20Info[stableChosen].contractAddress);

        uint256 claimAmts =
            withheldWithdrawals[msg.sender].amounts /
            10**(18 - stableERC20Info[stableChosen].tokenDecimals);
        uint256 amtToUser = mathFuncs.decMul18(claimAmts, mathFuncs.decDiv18(95, 100));

        scepterData.sptrTreasuryBal -= withheldWithdrawals[msg.sender].amounts;
        calcSPTRData();

        delete withheldWithdrawals[msg.sender];
        _safeTransferFrom(tokenStable, SCEPTER_TREASURY_ADDR, msg.sender, amtToUser);
        _safeTransferFrom(tokenStable, SCEPTER_TREASURY_ADDR, DEV_WALLET_ADDR, claimAmts - amtToUser);
    }

    function getCircSupplyXDays() public view returns (uint256) {
        if (timeLaunched == 0) return 0;
        uint256 daySinceLaunched = (block.timestamp - timeLaunched) / SECONDS_IN_A_DAY;
        uint256 numdays = daysInCalculation / SECONDS_IN_A_DAY;
        if (daySinceLaunched < numdays) {
            return SEED_AMOUNT;
        }
        for (uint d = daySinceLaunched - numdays; d > 0; d--) {
            if (setCircSupplyToPreviousDay[d]) {
                return circulatingSupplyXDays[d];
            }
        }
        return circulatingSupplyXDays[0];
    }

    function calcBTONData() private {
        // Total supply will be guaranteed to not fall to 0 by sending Baton tokens
        // to a dead address. Initially before any Baton tokens are minted, the values
        // produced by this function are irrelevant.
        if (BTON.totalSupply() == 0) { 
            batonData.btonBackingPrice = DECIMALS;
        } else {
            batonData.btonBackingPrice = mathFuncs.decDiv18(batonData.btonTreasuryBal, BTON.totalSupply());
        }
        uint256 btonPrice = mathFuncs.decMul18(batonData.btonBackingPrice, mathFuncs.decDiv18(30, 100));
        uint256 sptrPriceHalf = scepterData.sptrBackingPrice / 2;
        if (btonPrice > sptrPriceHalf) {
            batonData.btonRedeemingPrice = sptrPriceHalf;
        } else {
            batonData.btonRedeemingPrice = btonPrice;
        }
    }

    function calcSPTRData() private {
        if (getCircSupplyXDays() == 0) {
            scepterData.sptrGrowthFactor = 3 * 10**17;
        } else {
            scepterData.sptrGrowthFactor =
                2 * (mathFuncs.decDiv18(getTokensBoughtXDays(), getCircSupplyXDays()));
        }
        if (scepterData.sptrGrowthFactor > 3 * 10**17) {
            scepterData.sptrGrowthFactor = 3 * 10**17;
        }

        if (getCircSupplyXDays() == 0) {
            scepterData.sptrSellFactor = 3 * 10**17;
        } else {
            scepterData.sptrSellFactor =
                2 * (mathFuncs.decDiv18(getTokensSoldXDays(), getCircSupplyXDays()));
        }
        if (scepterData.sptrSellFactor > 3 * 10**17) {
           scepterData.sptrSellFactor = 3 * 10**17;
        }

        // Total supply will be guaranteed to not fall to 0 by sending Scepter tokens
        // to a dead address.
        if (SPTR.totalSupply() == 0) {
            scepterData.sptrBackingPrice = DECIMALS;
        } else {
            scepterData.sptrBackingPrice =
                mathFuncs.decDiv18(scepterData.sptrTreasuryBal, SPTR.totalSupply());
        }

        scepterData.sptrBuyPrice = mathFuncs.decMul18(
            scepterData.sptrBackingPrice,
            12 * 10**17 + scepterData.sptrGrowthFactor
        );
        scepterData.sptrSellPrice = mathFuncs.decMul18(
            scepterData.sptrBackingPrice,
            9 * 10**17 - scepterData.sptrSellFactor
        );
        calcBTONData();
    }

    function getTokensBoughtXDays() public view returns (uint256) {
        if (timeLaunched == 0) return tokensBoughtXDays[0];

        uint256 boughtCount = 0;
        uint d = 0;
        uint256 numdays = daysInCalculation / SECONDS_IN_A_DAY;
        uint256 daySinceLaunched = (block.timestamp - timeLaunched) / SECONDS_IN_A_DAY;

        if (daySinceLaunched > numdays) {
            d = daySinceLaunched - numdays;
        }
        for (; d <= daySinceLaunched; d++) {
            boughtCount += tokensBoughtXDays[d];
        }
        return boughtCount;
    }

    function getTokensSoldXDays() public view returns (uint256) {
        if (timeLaunched == 0) return tokensSoldXDays[0];

        uint256 soldCount = 0;
        uint256 d;
        uint256 numdays = daysInCalculation / SECONDS_IN_A_DAY;
        uint256 daySinceLaunched = (block.timestamp - timeLaunched) / SECONDS_IN_A_DAY;

        if (daySinceLaunched > numdays) {
            d = daySinceLaunched - numdays;
        }
        for (; d <= daySinceLaunched; d++) {  
            soldCount += tokensSoldXDays[d];
        }
        return soldCount;
    }

    function turnOnOffTrading(bool value) external onlyOwner {
        tradingEnabled = value;
    }

    function updateSPTRTreasuryBal(uint256 totalAmt) external {
        require(msg.sender == adminDelegator, "Not Delegated to call."); 
        scepterData.sptrTreasuryBal = totalAmt * DECIMALS;
        calcSPTRData();
    }

    function updateDelegator(address newAddress) external onlyOwner {
        adminDelegator = newAddress;
    }

    function addOrSubFromSPTRTreasuryBal(int256 amount) external onlyOwner {
        if (amount < 0) {
            scepterData.sptrTreasuryBal -= uint256(-amount) * DECIMALS;
        } else {
            scepterData.sptrTreasuryBal += uint256(amount) * DECIMALS;
        }
        calcSPTRData();
    }

    function updateBTONTreasuryBal(uint256 totalAmt) external {
        require(msg.sender == adminDelegator, "Not Delegated to call."); 
        batonData.btonTreasuryBal = totalAmt * DECIMALS;
        calcBTONData();
    }

    function Launch() external onlyOwner {
        require(timeLaunched == 0, "Already Launched");
        timeLaunched = block.timestamp;
        daysInCalculation = 5 days;
        //TODO: update
        SPTR.mint(0x1f174b307FB42B221454328EDE7bcA7De841a991, SEED_AMOUNT_1); //seed 1
        SPTR.mint(0xEF4503dD3768CB4CE1Be12F56b3ee4c7E6a5E3ec, SEED_AMOUNT_2); //seed 2
        SPTR.mint(0x90C66d0401d75A6d3b4f46cbA5F4230EE00D7f71, SEED_AMOUNT_3); //seed 3

        WAND.mint(SCEPTER_TREASURY_ADDR, SEED_AMOUNT);

        tokensBoughtXDays[0] = SEED_AMOUNT;
        circulatingSupplyXDays[0] = SEED_AMOUNT;
        setCircSupplyToPreviousDay[0] = true;
        scepterData.sptrTreasuryBal = 86000 * DECIMALS; //TODO: update
        batonData.btonTreasuryBal = 0;
        calcSPTRData();
        tradingEnabled = true;
    }

    function setDaysUsedInFactors(uint256 numDays) external onlyOwner {
        daysInCalculation = numDays * SECONDS_IN_A_DAY;
    }

    function addWhitelistee(uint listNum, address[] memory addr) external {
        require(msg.sender == adminDelegator, "Not Delegated to call.");
        require(listNum >= 1 && listNum <= 3, "listNum has to be 1, 2, or 3.");
        if (listNum == 1) {
            listNum = 2000 * DECIMALS;
        } else if (listNum == 2) {
            listNum = 1500 * DECIMALS;
        } else {
            listNum = 1000 * DECIMALS;
        }
        for (uint256 i = 0; i < addr.length; i++) {
            whiteListees[addr[i]].buyLimit = listNum;
        }
    }

    function addStable(string calldata ticker, address addr, uint256 dec) external onlyOwner {
        stableERC20Info[ticker].contractAddress = addr;
        stableERC20Info[ticker].tokenDecimals = dec;
    }

    function _safeTransferFrom(
        IERC20 token,
        address sender,
        address recipient,
        uint256 amount
    )
        private
    {
        require(token.transferFrom(sender, recipient, amount), "Token transfer failed");
    }
}