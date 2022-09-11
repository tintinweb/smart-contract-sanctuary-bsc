/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.15;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface BEP20 {
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    event Authorize_Wallet(address Wallet, bool Status);

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) external onlyOwner {
        authorizations[adr] = true;
        emit Authorize_Wallet(adr,true);
    }

    function unauthorize(address adr) external onlyOwner {
        require(adr != owner, "OWNER cant be unauthorized");
        authorizations[adr] = false;
        emit Authorize_Wallet(adr,false);
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract DolFinance is BEP20, Auth {
    using SafeMath for uint256;

    address immutable WBNB;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    string public constant name = "DolFinance";
    string public constant symbol = "DOLFI";
    uint8 public constant decimals = 18;

    uint256 public constant totalSupply = 1 * 10**decimals;

    uint256 public _maxTxAmount = totalSupply / 200;
    uint256 public _maxWalletToken = totalSupply / 50;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isWalletLimitExempt;

    struct Soldier {
        address payable referrerAddress;
        uint256 nbReservist;
        uint256 nbTroops;
        bool hasBought;
    }

    mapping (address => Soldier) public army;
    mapping (uint8 => uint16) public referrerFees;

    uint256 public totalFee = 10;
    uint256 public constant feeDenominator = 100;

    uint256 multiplier = 100;

    address public marketingFeeReceiver;
    address public buyBackFeeReceiver;
    address public devWallet;

    IDEXRouter public router;
    address public immutable pair;

    bool public tradingOpen = false;
    uint256 public launchedAt;

    bool public swapEnabled = true;
    uint256 public swapThreshold = totalSupply / 1000000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }



    constructor () Auth(msg.sender) {
        router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        WBNB = router.WETH();

        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));

        _allowances[address(this)][address(router)] = type(uint256).max;

        marketingFeeReceiver = 0xFC65c55badf14407F01AC38672AeD6E61723Dd50;
        buyBackFeeReceiver = 0xDc80362cd87A3d52d04d06A6b6Cf6f071D1A8D05;

        // TEST
        devWallet = 0xC3bD6e462F3E2a597230B70B115a0FA94Cd6Bca5;

        isFeeExempt[msg.sender] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[ZERO] = true;

        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[DEAD] = true;
        isWalletLimitExempt[pair] = true;

        Soldier storage devSoldier1 = army[devWallet];
        devSoldier1.referrerAddress = payable(msg.sender);

        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    receive() external payable { }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && totalFee !=0
        && swapEnabled
        && balanceOf[address(this)] >= swapThreshold;
    }

    function getOwner() external view override returns (address) { return owner; }

    function getCirculatingSupply() public view returns (uint256) {
        return (totalSupply - balanceOf[DEAD] - balanceOf[ZERO]);
    }

    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function createSoldier(address soldierAddress, address referrerAddress) external onlyOwner {
        require(army[soldierAddress].referrerAddress == ZERO, "Soldier already exists");
        require(army[referrerAddress].referrerAddress != ZERO, "Referrer does not exist");
        require(
            referrerAddress != soldierAddress
            && referrerAddress != owner
            && referrerAddress != address(this)
            && referrerAddress != address(router)
            && referrerAddress != address(pair)
            && referrerAddress != marketingFeeReceiver
            && referrerAddress != buyBackFeeReceiver
            && referrerAddress != DEAD
            && referrerAddress != ZERO,
            "Invalid referrer"
            // backend: check if address is contract, if no, ok
        );

        // We create the soldier
        Soldier storage soldier = army[soldierAddress];
        soldier.referrerAddress = payable(referrerAddress);
        army[referrerAddress].nbReservist = army[referrerAddress].nbReservist.add(1);
    }

    function getGrade(address soldierAddress) public view returns (uint8) {
        Soldier memory soldier = army[soldierAddress];
        uint256 balance = balanceOf[soldierAddress];
        uint256 nbTroops = soldier.nbTroops;

        if (
            (nbTroops >= 1 && nbTroops < 3) && 
            (balance >= 1 * 10**14)
            ) {
            return 1;
        } else if (
            (nbTroops >= 3 && nbTroops < 5) && 
            (balance >= 3 * 10**14)
        ) {
            return 2;
        } else if (
            (nbTroops >= 5 && nbTroops < 10) &&
            (balance >= 5 * 10**14)
        ) {
            return 3;
        } else if (
            (nbTroops >= 10 && nbTroops < 25) &&
            (balance >= 10 * 10**14)
        ) {
            return 4;
        } else if (
            (nbTroops >= 25 && nbTroops < 50) &&
            (balance >= 25 * 10**14)
        ) {
            return 5;
        } else if (
            (nbTroops >= 50 && nbTroops < 100) &&
            (balance >= 50 * 10**14)
        ) {
            return 6;
        } else if (
            (nbTroops >= 100 && nbTroops < 250) &&
            (balance >= 100 * 10**14)
        ) {
            return 7;
        } else if (
            (nbTroops >= 250 && nbTroops < 500) &&
            (balance >= 250 * 10**14)
        ) {
            return 8;
        } else if (
            (nbTroops >= 500 && nbTroops < 1000) &&
            (balance >= 500 * 10**14)
        ) {
            return 9;
        } else if (
            (nbTroops >= 1000) &&
            (balance >= 1000 * 10**14)
        ) {
            return 10;
        } else {
            return 0;
        }
    }

    function getReferrerFee(uint8 grade) public view returns (uint16) {
        return referrerFees[grade];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(
            (
                recipient == pair
                || recipient == owner
                || recipient == marketingFeeReceiver
                || recipient == buyBackFeeReceiver
                || recipient == DEAD
                || recipient == ZERO
                || recipient == address(this)
            )
            ||
            (
                army[recipient].referrerAddress != ZERO 
                && army[recipient].referrerAddress != DEAD
            ),
            "You must be a soldier"
        );
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
        }

        if (!authorizations[sender] && !isWalletLimitExempt[sender] && !isWalletLimitExempt[recipient] && recipient != pair) {
            require((balanceOf[recipient] + amount) <= _maxWalletToken,"Max wallet limit reached");
        }
    
        // Checks max transaction limit
        require((amount <= _maxTxAmount) || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "Max TX Limit Exceeded");

        if(shouldSwapBack()){ swapBack(); }

        balanceOf[sender] = balanceOf[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = (isFeeExempt[sender] || isFeeExempt[recipient]) ? amount : takeFee(sender, amount, recipient);

        balanceOf[recipient] = balanceOf[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        balanceOf[sender] = balanceOf[sender].sub(amount, "Insufficient Balance");
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(address sender, uint256 amount, address recipient) internal returns (uint256) {
        if(amount == 0){
            return amount;
        }

        // If it's recipient first buy, we update his referrer troops
        if (sender == pair && !army[recipient].hasBought) {
            army[recipient].hasBought = true;
            army[army[recipient].referrerAddress].nbReservist = army[army[recipient].referrerAddress].nbReservist.sub(1);
            army[army[recipient].referrerAddress].nbTroops = army[army[recipient].referrerAddress].nbReservist.add(1);
        }

        uint256 totalFeeAmount = amount.mul(totalFee).mul(multiplier).div(feeDenominator * 100);
        uint256 marketingBuybackFeeAmount = totalFeeAmount;
        uint16 referrerFee = referrerFees[getGrade(army[recipient].referrerAddress)];

        if (referrerFee > 0) {
            uint256 referrerFeeAmount = totalFeeAmount.mul(referrerFee).div(totalFee * 100);
            marketingBuybackFeeAmount = totalFeeAmount.sub(referrerFeeAmount);
            balanceOf[army[recipient].referrerAddress] = balanceOf[army[recipient].referrerAddress].add(referrerFeeAmount);
            emit Transfer(sender, army[recipient].referrerAddress, marketingBuybackFeeAmount);
        }

        balanceOf[address(this)] = balanceOf[address(this)].add(marketingBuybackFeeAmount);
        emit Transfer(sender, address(this), marketingBuybackFeeAmount);

        return amount.sub(totalFeeAmount);
    }

    function clearStuckToken(address tokenAddress, uint256 tokens) external onlyOwner returns (bool success) {
        require(tokenAddress != address(this), "Cannot withdraw native token");

        if(tokens == 0){
            tokens = BEP20(tokenAddress).balanceOf(address(this));
        }

        emit clearToken(tokenAddress, tokens);

        return BEP20(tokenAddress).transfer(msg.sender, tokens);
    }

    // switch Trading
    function tradingEnable() external onlyOwner {
        require(!tradingOpen,"Trading already open");
        tradingOpen = true;
        launchedAt = block.timestamp;
        emit config_TradingStatus(tradingOpen);
    }

    function swapBack() internal swapping {
        uint256 amountToSwap = swapThreshold;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance;
        payable(marketingFeeReceiver).transfer(amountBNB.div(2));
        payable(buyBackFeeReceiver).transfer(address(this).balance);    
    }

    function setReferrerFee_base10(uint8 grade, uint16 feeBase10) external onlyOwner {
        require(grade >= 0 && grade <= 10, "Invalid grade");
        referrerFees[grade] = feeBase10;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        require(_amount < (totalSupply/10), "Amount too high");

        swapEnabled = _enabled;
        swapThreshold = _amount;

        emit config_SwapSettings(swapThreshold, swapEnabled);
    }

    function manage_FeeExempt(address[] calldata addresses, bool status) external authorized {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i=0; i < addresses.length; ++i) {
            isFeeExempt[addresses[i]] = status;
            emit Wallet_feeExempt(addresses[i], status);
        }
    }

    function manage_TxLimitExempt(address[] calldata addresses, bool status) external authorized {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i=0; i < addresses.length; ++i) {
            isTxLimitExempt[addresses[i]] = status;
            emit Wallet_txExempt(addresses[i], status);
        }
    }

    function manage_WalletLimitExempt(address[] calldata addresses, bool status) external authorized {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i=0; i < addresses.length; ++i) {
            isWalletLimitExempt[addresses[i]] = status;
            emit Wallet_holdingExempt(addresses[i], status);
        }
    }

// function multiTransfer(address[] calldata addresses, uint256[] calldata tokens) external {
//     require(isFeeExempt[msg.sender]);
//     address from = msg.sender;

//     require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
//     require(addresses.length == tokens.length,"Mismatch between address and token count");

//     uint256 SCCC = 0;

//     for(uint i=0; i < addresses.length; i++){
//         SCCC = SCCC + tokens[i];
//     }

//     require(balanceOf[from] >= SCCC, "Not enough tokens in wallet");

//     for(uint i=0; i < addresses.length; i++){
//         _basicTransfer(from,addresses[i],tokens[i]);
//     }
// }


event Wallet_feeExempt(address Wallet, bool Status);
event Wallet_txExempt(address Wallet, bool Status);
event Wallet_holdingExempt(address Wallet, bool Status);
event Wallet_blacklist(address Wallet, bool Status);

event BalanceClear(uint256 amount);
event clearToken(address TokenAddressCleared, uint256 Amount);

event config_TradingStatus(bool Status);
event config_BlacklistMode(bool Status);
event config_SwapSettings(uint256 Amount, bool Enabled);

}