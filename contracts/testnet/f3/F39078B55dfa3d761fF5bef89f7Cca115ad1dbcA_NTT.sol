//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./console.sol";
import "./ERC4671.sol";
import "./Ownable.sol";
import "./IERC20.sol";


contract NTT is ERC4671, Ownable {
    bool public enableMint = true;
    bool public enableAutoSell = true;
    uint256 public priceBase = 225 ether;
    uint256 public maxNTT = 2222;
    uint256 public percentageTokenByCycle = 8;
    uint256 public percentageUserByCycle = 17;
    uint256 public initDateCycle = 0;
    uint256 public finDateCycle = 0;
    uint8 public maxCycles = 10;
    uint8 public actualCycle = 0;
    IERC20 private USDTContract;

    // Mapping cycle -> sales Tax
    mapping(uint256 => uint256) public salesTaxByCycle;

    // Mapping from owner to numbers of autoRenewal
    mapping(address => uint256) public autoSell;
    mapping(address => uint256) private addressCountPayAutoSell;

    //EVENTS
    event StatusMint(bool status);
    event MintNTT();
    event UpdateAutoSell(address addressOwnerNtt);
    event StatusChangeAutoSell(bool status);
    event PercentageTokenByCycle(uint256 percentage);
    event PercentageUserByCycle(uint256 percentage);
    event MaxCycles(uint8 max);
    event PriceValue(uint256 price);
    event NumberNTT(uint256 maxNTT);
    event SalesTax(uint256 tax, uint256 cycle);

    constructor(
        string memory name,
        string memory symbol,
        address USDTAddress,
        uint256 maxNumberNTT,
        uint256 costNTT,
        uint8 maxCyclesNTT
    ) ERC4671(name, symbol)  {
        USDTContract = IERC20(USDTAddress);
        maxNTT = maxNumberNTT;
        priceBase = costNTT * 1 ether;
        maxCycles = maxCyclesNTT;
        initDefaultSalesTax();
    }

    function numberNTTSold() public view returns (uint256){
        return tokensValid;
    }

    function updateNumberAutoSell(uint256 numberAutoSell) external {
        require(enableAutoSell, "Error: No enable change auto sell");
        require(_numberOfValidTokens[msg.sender] != 0, "Error: No valid NTTs");
        require(_numberOfValidTokens[msg.sender] >= numberAutoSell, "Error: Maximum exceeded NTTs");
        autoSell[msg.sender] = numberAutoSell;
        emit UpdateAutoSell(msg.sender);
    }

    function mintNTT(uint256 numberNTTs) external enabledMint {
        require(
            maxNTT >= (_emittedCount + numberNTTs),
            "Error: Insufficient NTTs"
        );

        uint256 totalPrice = priceBase * numberNTTs;

        require(
            USDTContract.balanceOf(msg.sender) >= totalPrice,
            "Error: insufficient funds"
        );

        require(
            USDTContract.transferFrom(msg.sender, owner(), totalPrice),
            "Error: transferFrom"
        );

        for (uint256 i = 0; i < numberNTTs; i++) {
            _mint(msg.sender);
        }
        emit MintNTT();
    }

    function pay() public onlyOwner {
        payRewards();
        applyAutoSell();
    }


    /* PRIVATE */
    function applyAutoSell() internal {
        for (uint256 i = 0; i < _emittedCount; i++) {
            ERC4671.Token memory token = _tokens[i];
            if (token.valid == true && autoSell[token.owner] != 0 && addressCountPayAutoSell[token.owner] < autoSell[token.owner]) {
                payRewardsNTTInflation(token);
                _revoke(i);
                addressCountPayAutoSell[token.owner] += 1;
            }
        }
        resetAddressCountPayAutoSell();
    }

    function resetAddressCountPayAutoSell() private {
        for (uint256 i = 0; i < _emittedCount; i++) {
            delete addressCountPayAutoSell[_tokens[i].owner];
        }
    }

    function payRewardsNTTInflation(
        ERC4671.Token memory token
    ) internal {
        uint256 currentValueNTT = calculateValueNTT(token);
        uint256 amountToPay = (currentValueNTT - (((currentValueNTT - priceBase) / 100) * salesTaxByCycle[token.cycles])) * 1 ether;
        USDTContract.transfer(token.owner, amountToPay);
    }

    function payRewards() internal {
        for (uint256 i = 0; i < _emittedCount; i++) {
            ERC4671.Token memory token = _tokens[i];
            if (token.valid == true) {
                USDTContract.transfer(token.owner, calculateReward(token));
            }
        }
    }

    function calculateReward(ERC4671.Token memory token)
    internal
    view
    returns (uint256)
    {
        return (calculateValueNTT(token) / 100) * percentageUserByCycle;
    }

    function calculateValueNTT(ERC4671.Token memory token)
    internal
    view
    returns (uint256)
    {
        return priceBase + ((token.cycles * percentageTokenByCycle) * 100);
    }

    function updateCycles() internal view {
        for (uint256 i = 0; i < _emittedCount; i++) {
            ERC4671.Token memory token = _tokens[i];
            if (token.valid == true) {
                token.cycles = 1 + token.cycles;
            }
        }
    }

    //Management
    function airdrop(address addressAirdrop, uint numberNTTs) public onlyOwner {
        for (uint256 i = 0; i < numberNTTs; i++) {
            _mint(addressAirdrop);
        }
    }

    function initCycle(uint256 initDateCycleNTT, uint256 finDateCycleNTT) public onlyOwner {
        //TODO: update cycles
        initDateCycle = initDateCycleNTT;
        finDateCycle = finDateCycleNTT;
        updateCycles();
        enableAutoSell = true;
        enableMint = false;
    }

    function setInitDateCycle(uint256 initDateCycleNTT)
    public onlyOwner
    {
        initDateCycle = initDateCycleNTT;
    }

    function setFinDateCycle(uint256 finDateCycleNTT)
    public onlyOwner
    {
        finDateCycle = finDateCycleNTT;
    }

    function getCurrentTokensByCycle(uint256 cycle)
    public
    onlyOwner
    view
    returns (uint256)
    {
        return validTokensByCycle[cycle];
    }

    function updateStatusEnableMint(bool status) public onlyOwner {
        enableMint = status;
    }

    function updateStatusEnableChangeAutoSell(bool status) public onlyOwner {
        enableAutoSell = status;
    }

    function setPercentageTokenByCycle(uint256 percentage) public onlyOwner {
        percentageTokenByCycle = percentage;
    }

    function setPercentageUserByCycle(uint256 percentage) public onlyOwner {
        percentageUserByCycle = percentage;
    }

    function setMaxCycles(uint8 max) public onlyOwner {
        maxCycles = max;
    }

    function setPriceBase(uint256 priceBaseNTT)
    public
    onlyOwner
    {
        priceBase = priceBaseNTT * 1 ether;
    }

    function setMaxNumberNTT(uint256 maxNumberNTT)
    public
    onlyOwner
    {
        maxNTT = maxNumberNTT;
    }

    function setSellTaxByCycle(uint256 tax, uint256 cycle)
    public
    onlyOwner
    {
        salesTaxByCycle[cycle] = tax;
    }
    /*FIN MANAGEMENT*/

    function initDefaultSalesTax()
    private
    {
        salesTaxByCycle[1] = 50;
        salesTaxByCycle[2] = 45;
        salesTaxByCycle[3] = 40;
        salesTaxByCycle[4] = 35;
        salesTaxByCycle[5] = 30;
        salesTaxByCycle[6] = 25;
        salesTaxByCycle[7] = 20;
        salesTaxByCycle[8] = 15;
        salesTaxByCycle[9] = 10;
        salesTaxByCycle[10] = 0;
    }

    modifier enabledMint() {
        require(enableMint == true, "Enable Mint is not available");
        _;
    }
}