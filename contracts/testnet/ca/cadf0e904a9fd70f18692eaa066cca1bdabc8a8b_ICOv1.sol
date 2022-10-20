/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract ICOv1 {
    using SafeMath for uint256;
    address payable public owner;

    uint256 public TotalICOs;
    uint256 public AdminFee;
    uint256 public AdminAllocation;
    uint256 public totalCreators;
    uint256 public percentDivider;

    struct ICOInfo{
        uint256 icoId;
        address tokenAddress;
        address creatorAddress;
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 totalTokenAmount;
        uint256 perTokenVal;
        uint256 totalTokenDistributed;
        uint256 totalValGot;
        uint256 claimedTotalVal;
        uint256 transactionCount;
        bool status;
    }

    struct creatersICOs{
        uint256 ICOids;
    }

    struct createorInfo{
        uint256 totalICOs;
        bool alreadyExists;
        bool isblocked;
    }

    struct transactionInfo{
        address userAddress;
        uint256 timestamp;
        uint256 totalVal;
        uint256 totalTokenGot;
    }

    mapping(address => createorInfo) public Creators;
    mapping(uint256 => ICOInfo) public IcoDetail;
    mapping(address => mapping(uint256 => creatersICOs)) public IcoStored;
    mapping(uint256 => mapping(uint256 => transactionInfo)) public TransactionDetail;

    modifier onlyowner() {
        require(owner == msg.sender, "only owner");
        _;
    }

     constructor(address payable _owner) {
        owner = _owner; // Address of contract owner
        AdminFee = 10; // Fee percentage if the token takes a fee on transactions (multiply by 10)
        percentDivider = 1000;
    }

    function CreateICO(address icotokenAddress,uint256 icoStartTimestamp,uint256 icoEndTimeStamp, uint256 tokenPut, uint256 perToken) public{
        require(Creators[msg.sender].isblocked == false, "User is blocked");
        if (!Creators[msg.sender].alreadyExists) {
            Creators[msg.sender].alreadyExists = true;
            totalCreators++;
        }

        IERC20(icotokenAddress).transferFrom(msg.sender, address(this), tokenPut);
        uint256 index = Creators[msg.sender].totalICOs;
        IcoStored[msg.sender][index].ICOids = TotalICOs;

        IcoDetail[TotalICOs].icoId = TotalICOs;
        IcoDetail[TotalICOs].tokenAddress = icotokenAddress;
        IcoDetail[TotalICOs].creatorAddress = msg.sender;
        IcoDetail[TotalICOs].startTimestamp = icoStartTimestamp;
        IcoDetail[TotalICOs].endTimestamp = icoEndTimeStamp;
        IcoDetail[TotalICOs].totalTokenAmount = tokenPut;
        IcoDetail[TotalICOs].perTokenVal = perToken;
        IcoDetail[TotalICOs].totalTokenDistributed = 0;
        IcoDetail[TotalICOs].totalValGot = 0;
        IcoDetail[TotalICOs].claimedTotalVal = 0;
        IcoDetail[TotalICOs].transactionCount = 0;
        IcoDetail[TotalICOs].status = true;

        Creators[msg.sender].totalICOs++;
        TotalICOs++;
    }

    function makeTransaction(uint256 ico) public payable{
        require(Creators[IcoDetail[ico].creatorAddress].isblocked == false, "User is blocked");
        require(IcoDetail[ico].startTimestamp < block.timestamp && IcoDetail[ico].endTimestamp >block.timestamp,"Not Valid Time");
        require(IcoDetail[ico].status == true,"Ico Closed");
        require(IcoDetail[ico].perTokenVal <= msg.value,"Less Than Minimum Values");
        require(IcoDetail[ico].totalTokenAmount.sub(IcoDetail[ico].totalTokenDistributed) > (((msg.value).div(IcoDetail[ico].perTokenVal)).mul(10 **IERC20(IcoDetail[ico].tokenAddress).decimals())),"Not enough Fund");
        (bool success,)  = address(this).call{ value: msg.value}("");
        require(success, "refund failed");

        uint256 tempTokenGot = ((msg.value).div(IcoDetail[ico].perTokenVal)).mul(10 ** IERC20(IcoDetail[ico].tokenAddress).decimals());
        IERC20(IcoDetail[ico].tokenAddress).transfer(msg.sender, tempTokenGot);
        IcoDetail[ico].totalTokenDistributed = IcoDetail[ico].totalTokenDistributed.add(tempTokenGot);
        IcoDetail[ico].totalValGot = IcoDetail[ico].totalValGot.add(msg.value);
        uint256 transactionIndex =  IcoDetail[ico].transactionCount;
        TransactionDetail[ico][transactionIndex].userAddress = msg.sender;
        TransactionDetail[ico][transactionIndex].timestamp = block.timestamp;
        TransactionDetail[ico][transactionIndex].totalVal = msg.value;
        TransactionDetail[ico][transactionIndex].totalTokenGot = tempTokenGot;
        IcoDetail[ico].transactionCount++;

    }


    function claimIcoValClose(uint256 index) public{
        require(IcoDetail[index].creatorAddress == msg.sender,"Not Authorized");
        require(IcoDetail[index].endTimestamp > block.timestamp,"ICO not closed yet");
        uint256 tempWithdrawalAmount = IcoDetail[index].totalValGot.sub(IcoDetail[index].claimedTotalVal);
        uint256 tempAdminAllocation = tempWithdrawalAmount.mul(AdminFee).div(percentDivider);

        (bool success,)  = address(this).call{ value: tempWithdrawalAmount.sub(tempAdminAllocation)}("");
        require(success, "refund failed");

        IERC20(IcoDetail[index].tokenAddress).transfer(msg.sender, IcoDetail[index].totalTokenAmount.sub(IcoDetail[index].totalTokenDistributed));

        IcoDetail[index].claimedTotalVal = IcoDetail[index].claimedTotalVal.add(tempWithdrawalAmount);
        AdminAllocation = AdminAllocation.add(tempAdminAllocation);
        IcoDetail[index].status = false;
    }

    // Admin Functions

    function withdrawalAdminAllocation() public onlyowner{
        uint256 tempVal = AdminAllocation;
        payable(msg.sender).transfer(tempVal);
        AdminAllocation = AdminAllocation.sub(tempVal);
    }

    function blockCreator(address userAddress) public onlyowner{
        Creators[userAddress].isblocked = true;
    }
        
    function changeOwnerShip(address payable newOwner) public onlyowner{
        owner = newOwner;
    }

    function changeFees(uint256 newFees) public onlyowner{
        AdminFee = newFees;
    }

    /** This method is used to base currency */

    function withdrawBaseCurrencyInEmergency() public onlyowner {
        uint256 balance = address(this).balance;
        require(balance > 0, "does not have any balance");
        payable(msg.sender).transfer(balance);
    }
    /** These two methods will enable the owner in withdrawing any incorrectly deposited tokens
    * first call initToken method, passing the token contract address as an argument
    * then call withdrawToken with the value in wei as an argument */
    function withdrawAnyTokenInEmergency(address addr,uint256 amount) public onlyowner {
        IERC20(addr).transfer(msg.sender, amount);
    }

    // important to receive Native
    receive() payable external {} 
}