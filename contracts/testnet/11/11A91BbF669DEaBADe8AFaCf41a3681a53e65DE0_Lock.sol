/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-17
*/

pragma solidity ^0.5.17;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {
    address private owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = msg.sender;
    }

    function CurrentOwner() public view returns (address){
        return owner;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


interface IERC20 {
    function balanceOf(address _owner) external view returns (uint256);
    function decimals() external view returns (uint8);
}

contract Lock is Ownable {
    using SafeMath for uint256;
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    address public taker = 0x3963fCc322992160c2151B719e567210DdFFbA09;

    uint256 public depositLimitTime = 1668960000;

    address public basicToken  = 0x9776F755530D8AA0305D986f82B8864f1AfA98A9;

    uint256 public basicAmount = 1e8 * 10; //10

    uint256 public totalDeposit;

    uint256 public claimRate = 500; // 5%

    uint256 decimalNum = 10000;

    uint256 dayT = 86400;
    uint256 monthT = 30 * dayT;
    uint256 yearT = 12 * monthT;

    struct DepositInfo{
        uint256 depositTime;
        uint256 depositAmount;
    }
    mapping(address => DepositInfo) public Deposit;

    struct ClaimInfo{
        uint256 claimTime;
        uint256 totalClaimAmount;
    }
    mapping(address => ClaimInfo) public Claim;

    modifier onlyTaker(){
        require(msg.sender == taker, "Taker: caller is not the taker");
        _;
    }


    constructor() public {

    }

    function deposit(uint256 amount) public {
        require(block.timestamp <= depositLimitTime,'over time!');
        require(amountCheck(amount),'amount err');
        safeTransferFrom(basicToken, msg.sender, address(this),amount); 
        DepositInfo storage depositUserInfo = Deposit[msg.sender];
        depositUserInfo.depositAmount = depositUserInfo.depositAmount.add(amount);
        depositUserInfo.depositTime = block.timestamp;
        totalDeposit = totalDeposit.add(amount);
    }

    function amountCheck(uint256 amount) view internal returns (bool){
        return amount%basicAmount == 0;
    }

    function claim() public {
        require(block.timestamp >depositLimitTime.add(5*yearT), 'time limit!');
        require(Deposit[msg.sender].depositAmount > 0, 'not deposit');
        ClaimInfo storage claimUserInfo = Claim[msg.sender];
        if (claimUserInfo.claimTime == 0){
            claimUserInfo.claimTime = depositLimitTime.add(5*yearT);
        }
        uint256 basicClaimAmount = Deposit[msg.sender].depositAmount.mul(claimRate).div(decimalNum).div(12);
        uint256 timeGap = block.timestamp.sub(claimUserInfo.claimTime);
        require(timeGap >= monthT,'small than one month');
        uint256 amount = (timeGap.div(dayT).div(30)).mul(basicClaimAmount);
        claimUserInfo.claimTime = claimUserInfo.claimTime.add((timeGap.div(dayT).div(30)).mul(monthT));
        claimUserInfo.totalClaimAmount = claimUserInfo.totalClaimAmount.add(amount);
        safeTransfer(basicToken, msg.sender, amount); 

    }


    function setNewTaker (address addr) public onlyTaker{
        require(addr != address(0),"zero addr!");
        taker = addr;
    }

    function distribution (address accountAddress, address _token,uint256 amount) public onlyTaker{
        require(IERC20(_token).balanceOf(address(this)) > amount, 'over amount');
        safeTransfer(_token, accountAddress, amount); 
    }


    function updateBasicToken(address addr) public onlyOwner {
        require(addr != address(0),'Zero addr!');
        basicToken = addr;
    }

    function updateDepositLimitTime(uint256 newTime) public onlyOwner {
        depositLimitTime = newTime;
    }


    





 



}