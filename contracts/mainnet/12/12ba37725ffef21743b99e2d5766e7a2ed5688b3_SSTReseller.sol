/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

pragma solidity 0.5.12;

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

contract Ownable {

    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) internal {
        require(initialOwner != address(0));
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "No access");
        _;
    }

    function isOwner() internal view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function mint(address to, uint256 value) external returns (bool);
    function burnFrom(address from, uint256 value) external;

    function freezeAndTransfer(address recipient, uint256 amount, uint256 period) external;
}

interface IUSDT {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external;
    function transferFrom(address sender, address recipient, uint256 amount) external;
    function decimals() external view returns(uint8);
}

contract SSTReseller is Ownable {

    using SafeMath for uint256;

    IUSDT public USDT;
    IERC20 public SST;

    uint256[] public referralPercents = [10, 7, 7, 8, 8];
    uint256 public feePercent = 5;
    uint256 public PERCENTS_DIVIDER = 100;
    uint256 public RATE_DIVIDER = 10**12; // Required to compatibility with ERC20 reseller contract. Reason is a difference in decimals of USDT in ETH and BSC networks.

    uint256 public rate;
    uint256 public period;
    uint256 public minimum;

    address public boss1 = 0x96f9ED1C9555060da2A04b6250154C9941c1BA5a;	
    address public boss2 = 0x96f9ED1C9555060da2A04b6250154C9941c1BA5a;	
    address public boss3 = 0xAD728555F3608d0e601c92eF66fd2a25C1859a12;	
    address public boss4 = 0xAD728555F3608d0e601c92eF66fd2a25C1859a12;

    bool public active;

    mapping (address => uint256) public interestBalance;

    event OnBuy(address indexed account, uint256 usdt, uint256 sst, uint256 rate);
    event OnPurchase(address indexed account, uint256 usdt, string comment);
    event OnFreezeAndTransfer(address indexed recipient, uint256 amount, uint256 period);
    event OnRefBonus(address indexed account, address indexed referrer, uint256 level, uint256 bonus);
    event OnWithdraw(address indexed account, uint256 value);
    event OnSetRate(address indexed account, uint256 oldValue, uint256 newValue);
    event OnSetFee(address indexed account, uint256 oldValue, uint256 newValue);
    event OnSetPeriod(address indexed account, uint256 oldValue, uint256 newValue);
    event OnSetMinimum(address indexed account, uint256 oldValue, uint256 newValue);
    event OnRefBonusSet(uint256 level1, uint256 level2, uint256 level3, uint256 level4, uint256 level5);
    event OnWithdrawERC20(address indexed account, address indexed erc20, uint256 value);
    event OnSwitchState(address indexed account, bool indexed active);
    event OnBoss1Deposed(address indexed account, address oldBoss1, address newBoss1);
    event OnBoss2Deposed(address indexed account, address oldBoss2, address newBoss2);
    event OnBoss3Deposed(address indexed account, address oldBoss3, address newBoss3);
    event OnBoss4Deposed(address indexed account, address oldBoss4, address newBoss4);

    modifier onlyActive {
        require(active, "Not active");
        _;
    }

    constructor(address USDTAddr, address SSTAddr, uint256 initialRate, uint256 initialPeriod, address initialOwner) public Ownable(initialOwner) {
        require(USDTAddr != address(0) && SSTAddr != address(0));
        require(initialRate > 0);

        USDT = IUSDT(USDTAddr);
        SST = IERC20(SSTAddr);

        rate = initialRate;
        period = initialPeriod;

        active = true;
    }

    function buy(uint256 value, address _ref1, address _ref2, address _ref3, address _ref4, address _ref5) public onlyActive {
        require(value >= minimum, "Less than minimum");
        USDT.transferFrom(msg.sender, address(this), value);

        uint256 total;
        if (_ref1 != address(0) && _ref1 != msg.sender) {
            uint256 bonus = value.mul(referralPercents[0]).div(PERCENTS_DIVIDER);
            interestBalance[_ref1] = interestBalance[_ref1].add(bonus);
            total = total.add(bonus);
            emit OnRefBonus(msg.sender, _ref1, 0, bonus);
        }

        if (_ref2 != address(0) && _ref2 != msg.sender) {
            uint256 bonus = value.mul(referralPercents[1]).div(PERCENTS_DIVIDER);
            interestBalance[_ref2] = interestBalance[_ref2].add(bonus);
            total = total.add(bonus);
            emit OnRefBonus(msg.sender, _ref2, 1, bonus);
        }

        if (_ref3 != address(0) && _ref3 != msg.sender) {
            uint256 bonus = value.mul(referralPercents[2]).div(PERCENTS_DIVIDER);
            interestBalance[_ref3] = interestBalance[_ref3].add(bonus);
            total = total.add(bonus);
            emit OnRefBonus(msg.sender, _ref3, 2, bonus);
        }

        if (_ref4 != address(0) && _ref4 != msg.sender) {
            uint256 bonus = value.mul(referralPercents[3]).div(PERCENTS_DIVIDER);
            interestBalance[_ref4] = interestBalance[_ref4].add(bonus);
            total = total.add(bonus);
            emit OnRefBonus(msg.sender, _ref4, 3, bonus);
        }

        if (_ref5 != address(0) && _ref5 != msg.sender) {
            uint256 bonus = value.mul(referralPercents[4]).div(PERCENTS_DIVIDER);
            interestBalance[_ref5] = interestBalance[_ref5].add(bonus);
            total = total.add(bonus);
            emit OnRefBonus(msg.sender, _ref5, 4, bonus);
        }

        uint256 fee = value.mul(feePercent).div(PERCENTS_DIVIDER);
        interestBalance[boss2] = interestBalance[boss2].add(fee);
        interestBalance[boss1] = interestBalance[boss1].add(value).sub(fee).sub(total);

        uint256 amount = getEstimation(value);

        SST.freezeAndTransfer(msg.sender, amount, period);

        emit OnBuy(msg.sender, value, amount, rate);
    }

    function purchase(uint256 value, address _ref1, address _ref2, address _ref3, address _ref4, address _ref5, string memory comment) public onlyActive {
        require(msg.sender == owner() || msg.sender == boss1 || msg.sender == boss2 || msg.sender == boss3 || msg.sender == boss4, "No access");
        require(value >= minimum, "Less than minimum");
        USDT.transferFrom(msg.sender, address(this), value);

        uint256 total;
        if (_ref1 != address(0) && _ref1 != msg.sender) {
            uint256 bonus = value.mul(referralPercents[0]).div(PERCENTS_DIVIDER);
            interestBalance[_ref1] = interestBalance[_ref1].add(bonus);
            total = total.add(bonus);
            emit OnRefBonus(msg.sender, _ref1, 0, bonus);
        }

        if (_ref2 != address(0) && _ref2 != msg.sender) {
            uint256 bonus = value.mul(referralPercents[1]).div(PERCENTS_DIVIDER);
            interestBalance[_ref2] = interestBalance[_ref2].add(bonus);
            total = total.add(bonus);
            emit OnRefBonus(msg.sender, _ref2, 1, bonus);
        }

        if (_ref3 != address(0) && _ref3 != msg.sender) {
            uint256 bonus = value.mul(referralPercents[2]).div(PERCENTS_DIVIDER);
            interestBalance[_ref3] = interestBalance[_ref3].add(bonus);
            total = total.add(bonus);
            emit OnRefBonus(msg.sender, _ref3, 2, bonus);
        }

        if (_ref4 != address(0) && _ref4 != msg.sender) {
            uint256 bonus = value.mul(referralPercents[3]).div(PERCENTS_DIVIDER);
            interestBalance[_ref4] = interestBalance[_ref4].add(bonus);
            total = total.add(bonus);
            emit OnRefBonus(msg.sender, _ref4, 3, bonus);
        }

        if (_ref5 != address(0) && _ref5 != msg.sender) {
            uint256 bonus = value.mul(referralPercents[4]).div(PERCENTS_DIVIDER);
            interestBalance[_ref5] = interestBalance[_ref5].add(bonus);
            total = total.add(bonus);
            emit OnRefBonus(msg.sender, _ref5, 4, bonus);
        }

        uint256 fee = value.mul(feePercent).div(PERCENTS_DIVIDER);
        interestBalance[boss2] = interestBalance[boss2].add(fee);
        interestBalance[boss1] = interestBalance[boss1].add(value).sub(fee).sub(total);

        emit OnPurchase(msg.sender, value, comment);
    }

    function freezeAndTransfer(address recipient, uint256 amount, uint256 _period) public onlyActive {
        require(msg.sender == owner() || msg.sender == boss1 || msg.sender == boss2 || msg.sender == boss3 || msg.sender == boss4, "No access");

        SST.freezeAndTransfer(recipient, amount, _period);

        emit OnFreezeAndTransfer(recipient, amount, _period);
    }

    function withdraw(uint256 value) public {
        require(value <= interestBalance[msg.sender], "Not enough balance");

        interestBalance[msg.sender] = interestBalance[msg.sender].sub(value);
        USDT.transfer(msg.sender, value);

        emit OnWithdraw(msg.sender, value);
    }

    function setRate(uint256 newRate) public {
        require(msg.sender == owner() || msg.sender == boss1 || msg.sender == boss2 || msg.sender == boss3, "No access");
        require(newRate > 0, "Invalid rate");

        emit OnSetRate(msg.sender, rate, newRate);

        rate = newRate;
    }

    function setMinimum(uint256 newMinimum) public {
        require(msg.sender == owner() || msg.sender == boss1 || msg.sender == boss2 || msg.sender == boss3, "No access");
        require(newMinimum > 0, "Invalid minimum");

        emit OnSetMinimum(msg.sender, minimum, newMinimum);

        minimum = newMinimum;
    }

    function setPeriod(uint256 newPeriod) public {
        require(msg.sender == owner() || msg.sender == boss1 || msg.sender == boss2 || msg.sender == boss3, "No access");
        require(newPeriod > 0, "Invalid period");

        emit OnSetPeriod(msg.sender, period, newPeriod);

        period = newPeriod;
    }

    function setRefBonus(uint256 level1, uint256 level2, uint256 level3, uint256 level4, uint256 level5) public {
        require(msg.sender == owner() || msg.sender == boss1 || msg.sender == boss2 || msg.sender == boss3, "No access");

        referralPercents[0] = level1;
        referralPercents[1] = level2;
        referralPercents[2] = level3;
        referralPercents[3] = level4;
        referralPercents[4] = level5;

        emit OnRefBonusSet(level1, level2, level3, level4, level5);
    }

    function setFee(uint256 newFee) public {
        require(msg.sender == owner() || msg.sender == boss1 || msg.sender == boss2 || msg.sender == boss3, "No access");

        emit OnSetFee(msg.sender, feePercent, newFee);

        feePercent = newFee;
    }

    function withdrawERC20(address ERC20Token, address recipient, uint256 value) external {
        require(msg.sender == boss1 || msg.sender == boss2, "No access");

        if (ERC20Token == address(USDT)) {
            USDT.transfer(recipient, value);
        } else {
            IERC20(ERC20Token).transfer(recipient, value);
        }

        emit OnWithdrawERC20(msg.sender, ERC20Token, value);
    }

    function switchState() public {
        require(msg.sender == owner() || msg.sender == boss1 || msg.sender == boss2 || msg.sender == boss3, "No access");
        active = !active;

        emit OnSwitchState(msg.sender, active);
    }

    function deposeBoss1(address newBoss1) public {
        require(msg.sender == boss1 || msg.sender == boss2, "No access");
        require(newBoss1 != address(0), "Zero address");

        emit OnBoss1Deposed(msg.sender, boss1, newBoss1);

        boss1 = newBoss1;
    }

    function deposeBoss2(address newBoss2) public {
        require(msg.sender == boss1 || msg.sender == boss2, "No access");
        require(newBoss2 != address(0), "Zero address");

        emit OnBoss2Deposed(msg.sender, boss2, newBoss2);

        boss2 = newBoss2;
    }

    function deposeBoss3(address newBoss3) public {
        require(msg.sender == owner() || msg.sender == boss1 || msg.sender == boss2, "No access");
        require(newBoss3 != address(0), "Zero address");

        emit OnBoss3Deposed(msg.sender, boss3, newBoss3);

        boss3 = newBoss3;
    }

    function deposeBoss4(address newBoss4) public {
        require(msg.sender == owner() || msg.sender == boss1 || msg.sender == boss2, "No access");
        require(newBoss4 != address(0), "Zero address");

        emit OnBoss4Deposed(msg.sender, boss4, newBoss4);

        boss4 = newBoss4;
    }

    function getEstimation(uint256 amount) public view returns(uint256) {
        uint256 result = amount.mul(rate).div(RATE_DIVIDER);
        return result;
    }

    function allowanceUSDT(address account) public view returns(uint256) {
        return USDT.allowance(account, address(this));
    }

    function allowanceSST(address account) public view returns(uint256) {
        return SST.allowance(account, address(this));
    }

    function balanceUSDT(address account) public view returns(uint256) {
        return USDT.balanceOf(account);
    }

    function balanceSST(address account) public view returns(uint256) {
        return SST.balanceOf(account);
    }

}