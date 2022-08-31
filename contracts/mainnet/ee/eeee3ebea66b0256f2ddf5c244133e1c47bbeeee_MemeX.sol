/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.16;

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
}

interface IDEXPair {
    function sync() external;
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface StakingInterface{
    function getStake(address holder) external view returns(uint256);
}

interface ICCVRF {
    function requestRandomness(uint256 requestID, uint256 howManyNumbers) external payable;
}

contract MemeX is IBEP20 {
    string constant _name = "MemeX";
    string constant _symbol = "MemeX";
    uint8 constant _decimals = 9;
    uint256 _totalSupply = 1_000_000 * (10**_decimals);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public limitless;

    uint256 public tax = 10;
    uint256 private liq = 3;
    uint256 private marketing = 3;
    uint256 private staking = 2;
    uint256 private burn = 1;
    uint256 private jackpot = 1;
    uint256 private taxDivisor = 100;
    uint256 private minTokensToSell = _totalSupply / 100;
    uint256 private launchTime = type(uint256).max;

    uint256 public priceFloor;
    uint256 public currentPrice;
    uint256 public jackpotBalance;
    uint256 public lastFloorReset;
    uint256 private vrfCost = 0.002 ether;
    uint256 private requestID;

    ICCVRF public randomnessSupplier = ICCVRF(0xC0de0aB6E25cc34FB26dE4617313ca559f78C0dE);

    mapping(address => bool) public addressExcludedFromJackpot;

    mapping(address => uint256) public tokens;
    mapping(address => uint256) private lastSold;

    uint256 private minTokensToBeEligible = 100 * (10**_decimals);
    mapping(uint256 => address) private buyerByID;
    mapping(address => bool) private buyerRegistered;
    uint256 private buyerID;


    IDEXRouter public router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public constant CEO = 0xA1bd5FE891358e8cD102Dd259c04C784dA55e35c;
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;
    address private constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
           
    address public marketingWallet = 0xA1bd5FE891358e8cD102Dd259c04C784dA55e35c;
    address public stakingWallet = 0xA1bd5FE891358e8cD102Dd259c04C784dA55e35c;
    StakingInterface private stakingContract = StakingInterface(stakingWallet);
    address public pair;

    address[] private pathForSelling = new address[](2);

    modifier onlyVRF() {if(msg.sender != address(randomnessSupplier)) return; _;}
    modifier onlyOwner() {if(msg.sender != CEO) return; _;}


    event WinnerPaid(address winner, uint256 prize);
    event NoWinnerFound(address winner1, address winner2, address winner3, uint256 jackpotBalance);

    constructor() {
        pair = IDEXFactory(IDEXRouter(router).factory()).createPair(WETH, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        limitless[CEO] = true;
        limitless[address(this)] = true;

        addressExcludedFromJackpot[CEO] = true;
        addressExcludedFromJackpot[address(this)] = true;
        addressExcludedFromJackpot[pair] = true;
        addressExcludedFromJackpot[stakingWallet] = true;
        addressExcludedFromJackpot[marketingWallet] = true;
        
        pathForSelling[0] = address(this);
        pathForSelling[1] = WETH;

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
    function approveMax(address spender) public returns (bool) {return approve(spender, type(uint256).max);}
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(_allowances[sender][msg.sender] >= amount, "Insufficient Allowance");
            _allowances[sender][msg.sender] -= amount;
        }
        
        return _transferFrom(sender, recipient, amount);
    }

    function manualSell() external onlyOwner {
        letTheContractSell();
    }

    function setWallets(address marketingAddress, address stakingAddress) external onlyOwner {
        marketingWallet = marketingAddress;
        stakingWallet = stakingAddress;
    }
    
    function setMinTokensToSell(uint256 _minTokensToSell) external onlyOwner{   
        minTokensToSell = _minTokensToSell;
    }

    function rescueAnyToken(address tokenToRescue) external onlyOwner {
        require(tokenToRescue != address(this), "Can't rescue your own");
        IBEP20(tokenToRescue).transfer(msg.sender, IBEP20(tokenToRescue).balanceOf(address(this)));
    }

    function rescueBnb() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance - jackpotBalance);
    }

    function setTax(
        uint256 newTaxDivisor,
        uint256 newLiq,
        uint256 newMarketing,
        uint256 newStaking,
        uint256 newBurn,
        uint256 newJackpot
    ) external onlyOwner {
        taxDivisor = newTaxDivisor;
        liq = newLiq;
        marketing = newMarketing;
        staking = newStaking;
        burn = newBurn;
        jackpot = newJackpot;
        tax = liq + marketing + staking + burn + jackpot;
        require(tax <= taxDivisor / 10, "Taxes are limited to 10%");
    }

    function setAddressWithoutTax(address unTaxedAddress, bool status) external onlyOwner {
        limitless[unTaxedAddress] = status;
    }
    
    function excludeFromJackpot(address excluded, bool status) external onlyOwner {
        addressExcludedFromJackpot[excluded] = status;
    }
    
    function setMinTokensToWin(uint256 _minTokensToWin) external onlyOwner{   
        minTokensToBeEligible = _minTokensToWin * (10**_decimals);
    }

    function launch() external onlyOwner{
        require(launchTime > block.timestamp, "Can only call this once");
        launchTime = block.timestamp;
        setFloor();
    }

    function weeklyFloorReset() external onlyOwner {
        require(lastFloorReset < block.timestamp - 6 days, "Can only reset once a week");
        lastFloorReset = block.timestamp;
        setFloor();
    }

    function drawWinners() external payable onlyOwner {
        randomnessSupplier.requestRandomness{value: vrfCost}(requestID, 3);
        requestID++;
    }

    function supplyRandomness(uint256 ,uint256[] memory randomNumbers) external onlyVRF {
        address winner1 = buyerByID[randomNumbers[0] % buyerID];
        address winner2 = buyerByID[randomNumbers[1] % buyerID];
        address winner3 = buyerByID[randomNumbers[2] % buyerID];


        
        bool winner1eligible =
            lastSold[winner1] <= block.timestamp - 7 days &&
            _balances[winner1] + stakingContract.getStake(winner1) >= minTokensToBeEligible &&
            !addressExcludedFromJackpot[winner1];
        
        bool winner2eligible =
            lastSold[winner2] <= block.timestamp - 7 days &&
            _balances[winner2] + stakingContract.getStake(winner2) >= minTokensToBeEligible &&
            !addressExcludedFromJackpot[winner2];

        bool winner3eligible =
            lastSold[winner3] <= block.timestamp - 7 days &&
            _balances[winner3] + stakingContract.getStake(winner3) >= minTokensToBeEligible &&
            !addressExcludedFromJackpot[winner3];

        uint256 totalWinners;
        if(winner1eligible) totalWinners++;
        if(winner2eligible) totalWinners++;
        if(winner3eligible) totalWinners++;

        if(totalWinners > 0){
            uint256 prize = jackpotBalance / totalWinners;
            if(winner1eligible) {
                payable(winner1).transfer(prize);
                emit WinnerPaid(winner1, prize);
            }

            if(winner2eligible) {
                payable(winner2).transfer(prize);
                emit WinnerPaid(winner2, prize);
            }
            
            if(winner3eligible) {
                payable(winner3).transfer(prize);
                emit WinnerPaid(winner3, prize);
            }

            jackpotBalance = 0;
            return;
        }

        emit NoWinnerFound(winner1, winner2, winner3, jackpotBalance);
    }


    function airdrop(address[] memory airdropWallets, uint256[] memory amount) external onlyOwner {
        for (uint256 i = 0; i < airdropWallets.length; i++) {
            address wallet = airdropWallets[i];
            uint256 airdropAmount = amount[i] * (10**_decimals);
            _lowGasTransfer(msg.sender, wallet, airdropAmount);
        }
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (limitless[sender] == true || limitless[recipient] == true) return _lowGasTransfer(sender, recipient, amount);
        if (launchTime > block.timestamp) return true;
        getPrice();
        if (conditionsToSwapAreMet(sender)) letTheContractSell();
        amount = tax == 0 ? amount : takeTax(sender, recipient, amount);
        return _lowGasTransfer(sender, recipient, amount);
    }

    function getPrice() internal {
        currentPrice = 10000 * IBEP20(WETH).balanceOf(pair) / _balances[pair];
    }

    function setFloor() internal {
        getPrice();
        priceFloor = currentPrice;
    }

    function takeTax(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 taxAmount = amount * tax / taxDivisor;

        uint256 percentBelowFloor = currentPrice > priceFloor ? 0 : 100 - (100 * currentPrice / priceFloor);

        if(sender == pair && percentBelowFloor != 0) {
            if(percentBelowFloor > 40) return amount;
            else taxAmount = taxAmount * ((4*tax) - percentBelowFloor) / (4*tax);
        } else if(recipient == pair && percentBelowFloor > 10) {
            if(percentBelowFloor > 50) taxAmount = amount * 5 * tax / taxDivisor;
            else taxAmount = amount * percentBelowFloor / taxDivisor;
        }

        if(recipient == pair) lastSold[sender] = block.timestamp;
        
        if(burn > 0) _lowGasTransfer(sender, DEAD, taxAmount * burn / tax);
        if(staking > 0) _lowGasTransfer(sender, stakingWallet, taxAmount * staking / tax);
        if(liq > 0 || marketing > 0 || jackpot > 0)  _lowGasTransfer(sender, address(this), taxAmount * (marketing + liq + jackpot) / tax);
        return amount - taxAmount;
    }

    function conditionsToSwapAreMet(address sender) internal view returns (bool) {
        return sender != pair && balanceOf(address(this)) >= minTokensToSell;
    }

    function _lowGasTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        if(!buyerRegistered[recipient]){
            buyerRegistered[recipient] = true;
            buyerByID[buyerID] = recipient;
            buyerID++;
        }
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function letTheContractSell() internal {
        if(marketing == 0 && liq == 0 && jackpot == 0) return;
        uint256 tokensForMarketingAndJackpot = _balances[address(this)] * (marketing + jackpot) / (marketing + liq + jackpot);
        uint256 balanceBefore = address(this).balance;
        
        if(tokensForMarketingAndJackpot > 0)
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensForMarketingAndJackpot,
            0,
            pathForSelling,
            address(this),
            block.timestamp
        );

        jackpotBalance += (address(this).balance - balanceBefore) * jackpot / (marketing + jackpot);

        if(_balances[address(this)] > 0){
            _lowGasTransfer(address(this), pair, _balances[address(this)]);
            IDEXPair(pair).sync();
        }
        
        (bool success,) = address(marketingWallet).call{value: address(this).balance - jackpotBalance}("");
        if(success) return;
    }
}