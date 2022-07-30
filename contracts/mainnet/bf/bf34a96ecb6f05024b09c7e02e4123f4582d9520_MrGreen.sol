/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.15;

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

interface IDEXFactory {function createPair(address tokenA, address tokenB) external returns (address pair);}
interface IDEXPair {function sync() external;}

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

contract MrGreen is IBEP20 {
    string constant _name = "KingTest";
    string constant _symbol = "KTest";
    uint8 constant _decimals = 9;
    uint256 _totalSupply = 1_000_000_000 * (10**_decimals);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public limitless;

    uint256 public tax = 10;
    uint256 private liq = 5;
    uint256 private marketing = 5;
    uint256 private token = 0;
    uint256 private burn = 0;
    uint256 private taxDivisor = 100;
    bool public happyHour;
    uint256 public happyHourEnd;
    uint256 private minTokensToSell = _totalSupply / 100;
    uint256 private launchTime = type(uint256).max;

    IDEXRouter public router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public constant CEO = 0xd3D750C0C5F19433a8684cfe0d96780410BeD3B3;
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;
    address private constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
           
    address public marketingWallet = 0x3a8D55eBE6120A7cd5127F2C3dAa0419BBA087Ba;
    address public tokenWallet = 0x3a8D55eBE6120A7cd5127F2C3dAa0419BBA087Ba;
    address public pair;

    mapping(address => bool) public isVested;
    mapping(address => uint256) private vestedAmount;
    mapping(address => uint256) private percentageAtLaunch;
    mapping(address => uint256) private percentageEveryMonth;

    address[] private pathForSelling = new address[](2);

    modifier onlyOwner() {if(msg.sender != CEO) return; _;}

    constructor() {
        pair = IDEXFactory(IDEXRouter(router).factory()).createPair(WETH, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        limitless[CEO] = true;
        limitless[address(this)] = true;

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

    function setWallets(address marketingAddress, address tokenAddress) external onlyOwner {
        marketingWallet = marketingAddress;
        tokenWallet = tokenAddress;
    }
    
    function setMinTokensToSell(uint256 _minTokensToSell) external onlyOwner{   
        minTokensToSell = _minTokensToSell;
    }

    function rescueAnyToken(address tokenToRescue) external onlyOwner {
        require(tokenToRescue != address(this), "Can't rescue your own");
        IBEP20(tokenToRescue).transfer(msg.sender, IBEP20(tokenToRescue).balanceOf(address(this)));
    }

    function rescueBnb() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function startHappyHour(uint256 howManyHours) external onlyOwner{
        require(howManyHours <= 24 && !happyHour && happyHourEnd < block.timestamp - 24 hours && block.timestamp > launchTime + 5 hours, 
        "HappyHour can only be called once every 24 hours and has a minimum cooldown of 24 hours and can't be activated within 5 hours of launch");
        happyHour = true;
        happyHourEnd = block.timestamp + howManyHours * 1 hours;
    }

    function setTax(
        uint256 newTaxDivisor,
        uint256 newLiq,
        uint256 newMarketing,
        uint256 newToken,
        uint256 newBurn
    ) external onlyOwner {
        taxDivisor = newTaxDivisor;
        liq = newLiq;
        marketing = newMarketing;
        token = newToken;
        burn = newBurn;
        tax = liq + marketing + token + burn;
        require(tax <= taxDivisor / 10, "Taxes are limited to max. 10%");
    }

    function setAddressWithoutTax(address unTaxedAddress, bool status) external onlyOwner {
        limitless[unTaxedAddress] = status;
    }
    
    function launch() external onlyOwner{
        launchTime = block.timestamp;
    }

    function airdropToWalletsAndVest(address[] memory airdropWallets, uint256[] memory amount, uint256 unlockAtLaunch, uint256 unlockPerMonth) external onlyOwner {
        require(airdropWallets.length == amount.length,"Arrays must be the same length");
        require(airdropWallets.length <= 200,"Wallets list length must be <= 200");
        for (uint256 i = 0; i < airdropWallets.length; i++) {
            address wallet = airdropWallets[i];
            uint256 airdropAmount = amount[i] * (10**_decimals);
            _lowGasTransfer(msg.sender, wallet, airdropAmount);
            
            if(unlockAtLaunch<100){
                vestedAmount[wallet] += airdropAmount;
                isVested[wallet] = true;
                if(percentageAtLaunch[wallet] < unlockAtLaunch) percentageAtLaunch[wallet] = unlockAtLaunch;
                if(percentageEveryMonth[wallet] < unlockPerMonth) percentageEveryMonth[wallet] = unlockPerMonth;
            }
        }
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (limitless[sender] == true || limitless[recipient] == true
        ) return _lowGasTransfer(sender, recipient, amount);

        if (launchTime > block.timestamp) return true;

        if(isVested[sender]){
            uint256 lockedAmount = 
            (
                vestedAmount[sender] *
                (100 - percentageAtLaunch[sender]) -
                (
                    vestedAmount[sender] *
                    percentageEveryMonth[sender] *
                    (block.timestamp - launchTime)
                    / 30 days
                )
            )
            / 100;
            
            require(balanceOf(sender) - amount >= lockedAmount,"Tokens are still vested");
        }

        if (conditionsToSwapAreMet(sender)) letTheContractSell();
        amount = tax == 0 ? amount : takeTax(sender, recipient, amount);
        return _lowGasTransfer(sender, recipient, amount);
    }

    
    function takeTax(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 taxAmount = amount * tax / taxDivisor;
        if(block.timestamp > happyHourEnd) happyHour = false;

        if(sender == pair) {
            if(happyHour) return amount;
        } else if(recipient == pair) {
            if(happyHour) taxAmount *= 2;
            if(block.timestamp < launchTime + 5 hours) taxAmount = taxAmount * (2 - (block.timestamp - launchTime) / 5 hours);
        }
        
        if(burn > 0) _lowGasTransfer(sender, DEAD, taxAmount * burn / tax);
        if(token > 0) _lowGasTransfer(sender, tokenWallet, taxAmount * token / tax);
        if(liq > 0 || marketing > 0) _lowGasTransfer(sender, address(this), taxAmount * (marketing + liq) / tax);
        return amount - taxAmount;
    }

    function conditionsToSwapAreMet(address sender) internal view returns (bool) {
        return sender != pair && balanceOf(address(this)) >= minTokensToSell;
    }

    function _lowGasTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function letTheContractSell() internal {
        if(marketing == 0 && liq == 0) return;
        uint256 tokensForMarketing = _balances[address(this)] * marketing / (marketing + liq);
        
        if(tokensForMarketing > 0)
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensForMarketing,
            0,
            pathForSelling,
            address(this),
            block.timestamp
        );

        if(_balances[address(this)] > 0){
            _lowGasTransfer(address(this), pair, _balances[address(this)]);
            IDEXPair(pair).sync();
        }

        (bool success,) = address(marketingWallet).call{value: address(this).balance}("");
        if(success) return;
    }
}