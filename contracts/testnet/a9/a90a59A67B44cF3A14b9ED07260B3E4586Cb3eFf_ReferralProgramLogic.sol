/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed to);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Ownable: Caller is not the owner");
        _;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transferOwnership(address transferOwner) external onlyOwner {
        require(transferOwner != newOwner);
        newOwner = transferOwner;
    }

    function acceptOwnership() virtual external {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

interface IReferralProgram {
    function userSponsor(uint user) external view returns (uint);
    function userSponsorByAddress(address user) external view returns (uint);
    function userIdByAddress(address user) external view returns (uint);
    function userAddressById(uint id) external view returns (address);
    function userSponsorAddressByAddress(address user) external view returns (address);
}

contract ReferralProgramLogic is Ownable { 
    IWBNB public WBNB;

    uint[] public levels;
    uint public maxLevel;
    uint256 public totalFeePercent;

    mapping(address => mapping(uint => uint)) private _undistributedFees;
    mapping(address => uint) private _recordedBalances;

    address public specialReserveFund;

    event DistributeFees(address indexed token, uint indexed userId, uint amount);
    event DistributeFeesForUser(address indexed token, uint indexed recipientId, uint amount);
    event ClaimEarnedFunds(address indexed token, uint indexed userId, uint unclaimedAmount);
    event TransferToSpecialReserveFund(address indexed token, uint indexed fromUserId, uint undistributedAmount);
    event UpdateLevels(uint totalFeePercent, uint[] newLevels);
    event UpdateSpecialReserveFund(address newSpecialReserveFund);
    event Rescue(address indexed to, uint amount);

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, ' Referral: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor(address wbnb)  {
        require(Address.isContract(wbnb), " Referral: Address is not contract");
        levels = [600, 300, 200, 150, 150, 100];   // amount * levels[line] / totalFeePercent
        totalFeePercent = 1500;
        maxLevel = levels.length;
        WBNB = IWBNB(wbnb);
    }

    function undistributedFees(address token, uint userId) external view returns (uint) {
        return _undistributedFees[token][userId];
    }

    receive() external payable {
            
    }

    function recordFee(address token, address recipient, uint amount) external lock { 
        uint actualBalance = IBEP20(token).balanceOf(address(this));
        require(actualBalance - amount >= _recordedBalances[token], " Referral: Balance check failed");
        if (Address.isContract(recipient)) recipient = tx.origin;
        uint uiserId = 0;
        _undistributedFees[token][uiserId] += amount;
        _recordedBalances[token] = actualBalance;
    }
    
    function distributeFees(address token, uint userId) private {
        require(_undistributedFees[token][userId] > 0, " Referral: Undistributed fee is 0");
        uint amount = _undistributedFees[token][userId];
        if (token == address(WBNB) && IBEP20(address(WBNB)).balanceOf(address(this)) >= amount) {
            WBNB.withdraw(amount);
            _recordedBalances[token] = _recordedBalances[token] - amount;
        }
        uint level = 0; 

        if (level < maxLevel) {
            uint undistributedPercentage;
            for (uint ii = level; ii < maxLevel; ii++) {
                undistributedPercentage += levels[ii];
            }
            uint undistributedAmount = amount * undistributedPercentage / totalFeePercent;
            _undistributedFees[token][0] += undistributedAmount;
            emit TransferToSpecialReserveFund(token, userId, undistributedAmount);
        }

        emit DistributeFees(token, userId, amount);
        _undistributedFees[token][userId] = 0;
    }

    function calculateRewardsDistribution(address token, uint userId) public view returns(uint[] memory) {
        uint[] memory rewards = new uint[](levels.length);
        uint amount = _undistributedFees[token][userId];
        for (uint i; i < levels.length; i++) {
            rewards[i] = amount * levels[i] / totalFeePercent;
        }
        return rewards;
    }

    function claimSpecialReserveFundBatch(address[] memory tokens) external onlyOwner {
        for (uint i; i < tokens.length; i++) {
            claimSpecialReserveFund(tokens[i]);
        }
    }

    function claimSpecialReserveFund(address token) public onlyOwner {
        uint amount = _undistributedFees[token][0]; 
        require(amount > 0, " Referral: No unclaimed funds for selected token");
        TransferHelper.safeTransfer(token, specialReserveFund, amount);
        _recordedBalances[token] -= amount;
        _undistributedFees[token][0] = 0;
    }

    function updateWBNB(address newWBNB) external onlyOwner {
        require(newWBNB != address(0) && Address.isContract(newWBNB), " Referral: Address is zero or not contract");
        WBNB = IWBNB(newWBNB);
    }
    
    function updateSpecialReserveFund(address newSpecialReserveFund) external onlyOwner {
        require(newSpecialReserveFund != address(0), " Referral: Address is zero");
        specialReserveFund = newSpecialReserveFund;
        emit UpdateSpecialReserveFund(newSpecialReserveFund);
    }

    function updateLevels(uint[] memory newLevels, uint newTotalFeePercent) external onlyOwner {
        uint checkSum;
        for (uint i; i < newLevels.length; i++) {
            checkSum += newLevels[i];
        }
        require(checkSum == newTotalFeePercent, " Referral: Wrong levels amounts");
        levels = newLevels;
        maxLevel = newLevels.length;
        totalFeePercent = newTotalFeePercent;
        emit UpdateLevels(newTotalFeePercent, newLevels);
    }

    function rescueBNB(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), " Referral: Cannot rescue to the zero address");
        require(amount > 0, " Referral: Cannot rescue 0");

        to.transfer(amount);
        emit Rescue(to, amount);
    }
}

//helper methods for interacting with BEP20 tokens and sending BNB that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        //bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        //bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        //bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferBNB(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}