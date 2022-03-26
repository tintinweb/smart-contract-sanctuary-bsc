/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

pragma solidity ^0.5.7;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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
        require(isOwner(), "Caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
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
 }

 /**
  * @title RefStorage interface
  */
 contract RefStorage {
     function getReferrer(address user) external view returns(address);
     function getReferrerInfo(address account) external view returns(address referrer, uint256 rate, uint256 amountOfReferrals, uint256 totalBonuses);
     function getReferralInfo(address account, uint256 from, uint256 to) external view returns(address[] memory referrals, uint256[] memory bonuses);
     function setReferrer(address user, address referrer) external;
     function update(address user, uint256 amount) external;
 }

/**
 * @title Exchange contract
 */
contract Exchange is Ownable {
    using SafeMath for uint256;

    IERC20 public USDT;
    IERC20 public TEST;

    RefStorage public refStorage;

    struct User {
        uint256 rate;
        uint256 totalBonuses;
    }

    mapping (address => User) users;

    address public wallet;
    uint256 public defaultRate;

    event ExchangeUsdtToTest(address indexed account, uint256 usdt, uint256 test);
    event ExchangeTestToUsdt(address indexed account, uint256 test, uint256 usdt);
    event RefBonus(address indexed account, address indexed referrer, uint256 bonus);

    constructor(address USDTAddr, address TESTAddr, address refStorageAddr, address initialOwner, address initialWallet) public Ownable(initialOwner) {
        require(USDTAddr != address(0) && TESTAddr != address(0) && initialWallet != address(0));

        USDT = IERC20(USDTAddr);
        TEST = IERC20(TESTAddr);
        refStorage = RefStorage(refStorageAddr);

        wallet = initialWallet;
        defaultRate = 50;
    }

    function receiveApproval(address from, uint256 amount, address token, bytes calldata extraData) external {
        if (token == address(TEST)) {
            exchangeTestToUsdt(from, amount, _bytesToAddress(extraData));
        } else if (token == address(USDT)) {
            exchangeUsdtToTest(from, amount, _bytesToAddress(extraData));
        }
    }

    function exchangeUsdtToTest(address from, uint256 amount, address referrer) public {
        require(msg.sender == from || msg.sender == address(USDT));

        USDT.transferFrom(from, address(this), amount);

        if (refStorage.getReferrer(msg.sender) == address(0) && referrer != address(0)) {
            refStorage.setReferrer(msg.sender, referrer);
        }

        uint256 refBonus;
        if (refStorage.getReferrer(msg.sender) != address(0)) {
            uint256 rate = users[refStorage.getReferrer(msg.sender)].rate > 0 ? users[refStorage.getReferrer(msg.sender)].rate : defaultRate;
            refBonus = amount * rate / 10000;
            refStorage.update(msg.sender, refBonus);
            USDT.transfer(refStorage.getReferrer(msg.sender), refBonus);

            emit RefBonus(from, refStorage.getReferrer(msg.sender), refBonus);
        }

        uint256 fee = amount * 250 / 10000;
        if (fee - refBonus > 0) {
            USDT.transfer(wallet, fee - refBonus);
        }

        TEST.mint(from, amount - fee);

        emit ExchangeUsdtToTest(from, amount, amount - fee);
    }

    function exchangeTestToUsdt(address from, uint256 amount, address referrer) public {
        require(msg.sender == from || msg.sender == address(TEST));

        TEST.burnFrom(from, amount);

        if (refStorage.getReferrer(msg.sender) == address(0) && referrer != address(0)) {
            refStorage.setReferrer(msg.sender, referrer);
        }

        uint256 refBonus;
        if (refStorage.getReferrer(msg.sender) != address(0)) {
            uint256 rate = users[refStorage.getReferrer(msg.sender)].rate > 0 ? users[refStorage.getReferrer(msg.sender)].rate : defaultRate;
            refBonus = amount * rate / 10000;
            refStorage.update(msg.sender, refBonus);
            USDT.transfer(refStorage.getReferrer(msg.sender), refBonus);

            emit RefBonus(from, refStorage.getReferrer(msg.sender), refBonus);
        }

        uint256 fee = amount * 250 / 10000;
        if (fee - refBonus > 0) {
            USDT.transfer(wallet, fee - refBonus);
        }

        USDT.transfer(from, amount - fee);

        emit ExchangeTestToUsdt(from, amount, amount - fee);
    }

    function setReferrerRate(address account, uint256 rate) public onlyOwner {
        require(account != address(0) && rate <= 250);
        users[account].rate = rate;
    }

    function setDefaultRate(uint256 rate) public onlyOwner {
        require(rate <= 250);
        defaultRate = rate;
    }

    function setWallet(address account) public onlyOwner {
        require(account != address(0));
        wallet = account;
    }

    function getReferrerInfo(address account) public view returns(address referrer, uint256 rate, uint256 amountOfReferrals, uint256 totalBonuses) {
        return (refStorage.getReferrerInfo(account));
    }

    function getReferralInfo(address account, uint256 from, uint256 to) public view returns(address[] memory referrals, uint256[] memory bonuses) {
        return (refStorage.getReferralInfo(account, from, to));
    }

    function _bytesToAddress(bytes memory source) internal pure returns(address parsedreferrer) {
        assembly {
            parsedreferrer := mload(add(source,0x14))
        }
    }

}