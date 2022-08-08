/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
/**
 * SAFEMATH LIBRARY
 */
library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

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

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
interface ICrycollBank {
    function sendToBondholder(address bondholder, uint256 amount) external;
    function getTokensFromBondholder(address bondholder, uint256 amount) external;
}

interface IBondsFactory {
    function createNewBond(
        string memory bondName, 
        string memory bondSymbol, 
        bool bondFixedAPY, 
        uint256 bondMaxSupply,
        uint256 bondNominalPrice,
        uint256 bondAPY, 
        uint256 bondpaymentInterval,
        uint256 bondDuration,
        bool bondBUSDdenominated
        ) external returns (address bondAddress);
}


interface IDEXRouter {
    function factory() external pure returns (address);
    function getAmountsOut(
        uint amountIn, 
        address[] calldata path
        ) external view returns (uint[] memory amounts);    
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);  
}

interface ICRYCOLL {
    function priceChange(uint256 period) external view returns(uint256);
    function currentPrice() external view returns(uint256);  
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IBOND {
    function maxSupply() external view returns (uint256);
	function mintForBank(uint256 amount) external;
    function fixedAPY() external view returns (bool);
    function nominalPrice() external view returns (uint256);
    function APY() external view returns (uint256);
    function getBankAddress() external view returns (address);
    function paymentInterval() external view returns (uint256);
    function bondDuration() external view returns (uint256);
    function BUSDdenominated() external view returns (bool);
    function redemptionDate() external view returns (uint256); 
    function issuanceDate() external view returns (uint256); 
    function nextPaymentDate() external view returns (uint256); 
    function totalProfit(address account) external view returns (uint256);
    function lastClaimed(address account) external view returns (uint256);
    function lastBalanceChange(address account) external view returns (uint256); 
    function setAPY(uint256 APY_) external;  
    function setTime(uint256 mintTime, uint256 redemptionTime) external;  
    function setMaxSupply(uint256 maxSupply_) external;  
}
contract Bond is IBEP20, IBOND {
    using SafeMath for uint256;
    IBEP20 cryToken;
    ICrycollBank bank;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address bankAddress = 0x01DC6F69630adb22bdE6F5BAc8c1cac76E204D11;
    address cryAddress = 0x71b224F068806d16576df44d3fFc9374F4844026;
    uint256 public bondMintTime = 30 minutes;
    uint256 public bondRedemptionTime = 7 minutes;
    string private _name;
    string private _symbol;
    bool _fixedAPY;
    uint8 constant _decimals = 18;
    uint256 _maxSupply;
    uint256 _totalSupply;
    uint256 _nominalPrice;
    uint256 _APY;
    uint256 _paymentInterval;
    uint256 _bondDuration;
    uint256 _redemptionDate;
    uint256 issuingBondDate;
    bool _BUSDdenominated;

    IDEXRouter public router;
    address public pair;
    address dexRouter_;

    mapping (address => uint256) _balances;
    mapping (address => uint256) _totalProfit;
    mapping (address => uint256) _lastClaimed;
    mapping (address => uint256) _lastBalanceChange;
    mapping (address => mapping (address => uint256)) _allowances;

    constructor (
        string memory bondName, 
        string memory bondSymbol, 
        bool bondFixedAPY, 
        uint256 bondMaxSupply,
        uint256 bondNominalPrice,
        uint256 bondAPY, 
        uint256 bondpaymentInterval,
        uint256 bondDuration_,
        bool bondBUSDdenominated
        ) {
        _name = bondName;
        _symbol = bondSymbol;
        _fixedAPY = bondFixedAPY;
        _maxSupply = bondMaxSupply * 10 **18;
        _nominalPrice = bondNominalPrice * 10 **18;
        _APY = bondAPY;
        _paymentInterval = bondpaymentInterval * 1 minutes; 
        _bondDuration = bondDuration_ * 1 minutes;
        _redemptionDate = block.timestamp.add(_bondDuration);
        _BUSDdenominated = bondBUSDdenominated;
        issuingBondDate = block.timestamp;
        bank = ICrycollBank(bankAddress);
        cryToken = IBEP20(cryAddress);  
        dexRouter_ = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        router = IDEXRouter(dexRouter_);
        pair = IDEXFactory(router.factory()).createPair(address(this), cryAddress);
    }

    modifier onlyBankOwner() {
       require(msg.sender == IBEP20(cryAddress).getOwner(), "!OWNER"); _;
    } 

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function maxSupply() external view override returns (uint256) { return _maxSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return IBEP20(cryAddress).getOwner(); }
    function fixedAPY() external view override returns (bool) { return _fixedAPY; }
    function nominalPrice() external view override returns (uint256) { return _nominalPrice; }
    function APY() public view override returns (uint256) {
        if(!_fixedAPY) { 
            uint256 priceChange = ICRYCOLL(cryAddress).priceChange(30);
            if(priceChange > 1000) { return _APY.add((priceChange.sub(1000)).div(10)); }
            else return _APY;
        }
        else return _APY;
    }
    function paymentInterval() external view override returns (uint256) { return _paymentInterval; }
    function bondDuration() external view override returns (uint256) { return _bondDuration; }
    function BUSDdenominated() external view override returns (bool) { return _BUSDdenominated; }
    function redemptionDate() external view override returns (uint256) { return _redemptionDate; }
    function issuanceDate() external view override returns (uint256) { return issuingBondDate; }
    function getBankAddress() external view override returns (address) { return bankAddress; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function totalProfit(address account) public view override returns (uint256) { return _totalProfit[account]; }
    function lastClaimed(address account) public view override returns (uint256) { return _lastClaimed[account]; }
    function lastBalanceChange(address account) public view override returns (uint256) { return _lastBalanceChange[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function nextPaymentDate() external view override returns (uint256) { 
       uint256 paymentDate = issuingBondDate;
        while (paymentDate <= _redemptionDate && paymentDate >= block.timestamp) { 
            paymentDate += _paymentInterval;  
        }
        return paymentDate;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != _totalSupply && msg.sender != bankAddress){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(block.timestamp > _redemptionDate.add(bondRedemptionTime)) { issuingBond(); }
        if(balanceOf(sender) > 0){ claim(sender); }
        if(balanceOf(recipient) > 0){ claim(recipient); }
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        _lastBalanceChange[sender] = block.timestamp;
        _lastBalanceChange[recipient] = block.timestamp;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function currentPrice() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = cryAddress;
        uint256[] memory amounts = router.getAmountsOut(10**18, path);
        return amounts[1].mul(10**18).div(amounts[0]);
    }

    function issuingBond() internal {
        issuingBondDate = block.timestamp;
        _redemptionDate = block.timestamp.add(_bondDuration);
        emit issuing(issuingBondDate, _redemptionDate);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);    
        emit Transfer(ZERO, account, amount);
    }
	
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, ZERO, amount);
    }

    function mintBond(uint256 amount) external {
        require(issuingBondDate.add(bondMintTime) > block.timestamp, "The time for minting is over");
        require(_maxSupply > _totalSupply, "The maximum supply has been reached");
        if(balanceOf(msg.sender) > 0){ claim(msg.sender); }
        if(_totalSupply.add(amount) > _maxSupply) { amount = _maxSupply.sub(_totalSupply); }
        uint256 amountCRY = amount.mul(_nominalPrice).div(10**18);
        if(_BUSDdenominated) { amountCRY.div(ICRYCOLL(cryAddress).currentPrice()).mul(10**18); }
        bank.getTokensFromBondholder(msg.sender, amountCRY);
        _lastBalanceChange[msg.sender] = block.timestamp;
        _mint(msg.sender, amount);
        emit bondMint(amount);
    }

    function redeemBond() external {
        require(balanceOf(msg.sender) > 0, "No bond");
        require(_redemptionDate < block.timestamp, "Too early to redeem bond");
        claim(msg.sender);
        uint256 amountCRY = balanceOf(msg.sender).mul(_nominalPrice).div(10**18);
        if(_BUSDdenominated) { amountCRY.div(ICRYCOLL(cryAddress).currentPrice()).mul(10**18); }
        bank.sendToBondholder(msg.sender, amountCRY);
        _burn(msg.sender, balanceOf(msg.sender));
        emit bondRedeem(balanceOf(msg.sender));
    }

    function claim(address bondholder) internal {
        uint256 amount = estimateBondholderProfit(bondholder);
        if(amount > 0){
            bank.sendToBondholder(bondholder, amount);
            _lastClaimed[bondholder] = block.timestamp;
            _totalProfit[bondholder] = _totalProfit[bondholder].add(amount);
        }
        emit claimProfit(amount, bondholder);
    }

    function claimBondProfit() external {
        require(balanceOf(msg.sender) > 0, "No bond");
        claim(msg.sender);
    }

    function estimateBondholderProfit(address bondholder) public view returns (uint256) {
        uint256 profitAmount = balanceOf(bondholder).mul(_nominalPrice.div(10**18)).mul(APY()).div(100).mul(_paymentInterval).div(365 days);
        if(_BUSDdenominated) { profitAmount.div(ICRYCOLL(cryAddress).currentPrice()).mul(10**18); } 
        uint256 totalProfitAmount;
        uint256 profitPaymentDate = issuingBondDate.add(_paymentInterval);
        while (profitPaymentDate <= block.timestamp) {
            if(profitPaymentDate > _lastClaimed[bondholder] && profitPaymentDate > _lastBalanceChange[bondholder]){
                totalProfitAmount = totalProfitAmount.add(profitAmount);
            }
            profitPaymentDate += _paymentInterval;    
            }
            return totalProfitAmount;
    }

    function getAvailableMint() public view returns (uint256) {
        if(_totalSupply >= _maxSupply) return 0;
        else return _maxSupply.sub(_totalSupply);     
    }

    function setTime(uint256 mintTime, uint256 redemptionTime) external override onlyBankOwner {
        require(mintTime > 0 && redemptionTime > 0, "Invalid Time");
        bondMintTime = mintTime * 1 days;
        bondRedemptionTime = redemptionTime * 1 days;
    }

    function mintForBank(uint256 amount) external override {
        require(msg.sender == bankAddress, "!BANK");
        _mint(bankAddress, amount);
    }

    function setAPY(uint256 APY_) external override onlyBankOwner  {
       require(APY_ > 0, "Invalid APY");
        _APY = APY_;
    }

    function setMaxSupply(uint256 maxSupply_) external override onlyBankOwner {
        require(maxSupply_ >= _totalSupply, "Total Supply exceeds max supply");
        _maxSupply = maxSupply_;
    }
    event bondMint(uint256 amount);
    event bondRedeem(uint256 amount);
    event claimProfit(uint256 amount, address bondholder);
    event issuing(uint256 newIssuingDate, uint256 newRedemptionDate);
}

contract BondsFactory is IBondsFactory {
    address bankAddress = 0x01DC6F69630adb22bdE6F5BAc8c1cac76E204D11;
    Bond[] private bonds;

    event bondCreated(address newBond);

    function createNewBond( 
        string memory bondName, 
        string memory bondSymbol, 
        bool bondFixedAPY, 
        uint256 bondMaxSupply,
        uint256 bondNominalPrice,
        uint256 bondAPY, 
        uint256 bondpaymentInterval,
        uint256 bondbondDuration,
        bool bondBUSDdenominated
        ) external returns (address bondAddress) {
        require(msg.sender == bankAddress, "Only Crycoll Bank can create bond");       
        uint256 index = bonds.length;
        Bond bond = new Bond(
            bondName, 
            bondSymbol, 
            bondFixedAPY,
            bondMaxSupply,
            bondNominalPrice, 
            bondAPY, 
            bondpaymentInterval, 
            bondbondDuration, 
            bondBUSDdenominated);
        bonds.push(bond);
        bondAddress = address(bonds[index]);
        emit bondCreated(bondAddress);
    }  

}