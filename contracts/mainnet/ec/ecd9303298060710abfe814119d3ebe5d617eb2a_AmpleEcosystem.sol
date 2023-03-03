/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address to, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint amount
    ) external returns (bool);
}


interface IERC20Permit {
    
    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function nonces(address owner) external view returns (uint);


    function DOMAIN_SEPARATOR() external view returns (bytes32);
}



library Address {

    function isContract(address account) internal view returns (bool) {
    
        return account.code.length > 0;
    }

    
    function sendValue(address payable recipient, uint amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }


    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }


    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }


    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }


    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }


    function safeApprove(
        IERC20 token,
        address spender,
        uint value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint value
    ) internal {
        uint newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint value
    ) internal {
        unchecked {
            uint oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }


    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() {
        _transferOwnership(_msgSender());
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {

    uint private constant _NOT_ENTERED = 1;
    uint private constant _ENTERED = 2;

    uint private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }


    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;


        _status = _NOT_ENTERED;
    }
}

library SafeMath {

    function tryAdd(uint a, uint b)
        internal
        pure
        returns (bool, uint)
    {
        unchecked {
            uint c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint a, uint b)
        internal
        pure
        returns (bool, uint)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }


    function tryMul(uint a, uint b)
        internal
        pure
        returns (bool, uint)
    {
        unchecked {

            if (a == 0) return (true, 0);
            uint c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint a, uint b)
        internal
        pure
        returns (bool, uint)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }


    function tryMod(uint a, uint b)
        internal
        pure
        returns (bool, uint)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }


    function add(uint a, uint b) internal pure returns (uint) {
        return a + b;
    }


    function sub(uint a, uint b) internal pure returns (uint) {
        return a - b;
    }


    function mul(uint a, uint b) internal pure returns (uint) {
        return a * b;
    }


    function div(uint a, uint b) internal pure returns (uint) {
        return a / b;
    }

    function mod(uint a, uint b) internal pure returns (uint) {
        return a % b;
    }


    function sub(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }


    function mod(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


contract AmpleEcosystem is Ownable, ReentrancyGuard{
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    uint public developerFee = 500; 
    uint public referrerReward1lvl = 500; 
    uint public referrerReward2lvl = 300; 
    uint public rewardPeriod = 1 days;
    uint public withdrawPeriod = 60 * 60 * 24 * 30;	
    uint public apr =  521; 
    uint public percentRate = 10000;
    address private devWallet;
    address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    uint public _currentDepositID = 0;

    uint public totalInvestors = 0;
    uint public totalReward = 0;
    uint public totalInvested = 0;

    struct DepositStruct{
        address investor;
        uint depositAmount;
        uint depositAt; 
        uint claimedAmount; 
        bool state; 
    }

    struct InvestorStruct{
        address investor;
        address referrer;
        uint totalLocked;
        uint startTime;
        uint lastCalculationDate;
        uint claimableAmount;
        uint claimedAmount;
        uint referAmount;
    }

    event Deposit(
        uint id,
        address investor
    );

    mapping(uint => DepositStruct) public depositState;

    mapping(address => uint[]) public ownedDeposits;

    mapping(address => InvestorStruct) public investors;

    constructor() {
        devWallet = 0xc343313d432C33aF35fF4d86923C7e47c1cc91aa;
    }

    function resetContract(address _devWallet) public onlyOwner {
        require(_devWallet!=address(0),"Please provide a valid address");
        devWallet = _devWallet;
    }

    function _getNextDepositID() private view returns (uint) {
        return _currentDepositID + 1;
    }

    function _incrementDepositID() private {
        _currentDepositID++;
    }

    function deposit(uint _amount, address _referrer) external payable {
        require(_amount > 0, "you can deposit more than 0 BUSD");

        if(_referrer == msg.sender){
            _referrer = address(0);
        }
        IERC20(BUSD).transferFrom(msg.sender,address(this),_amount);

        uint _id = _getNextDepositID();
        _incrementDepositID();

        uint depositFee = (_amount * developerFee).div(percentRate);
        IERC20(BUSD).safeTransfer(devWallet,depositFee);

        uint _depositAmount = _amount - depositFee;

        depositState[_id].investor = msg.sender;
        depositState[_id].depositAmount = _depositAmount;
        depositState[_id].depositAt = block.timestamp;
        depositState[_id].state = true;

        if(investors[msg.sender].investor == address(0)){
            totalInvestors = totalInvestors.add(1);
            investors[msg.sender].investor = msg.sender;
            investors[msg.sender].startTime = block.timestamp;
            investors[msg.sender].lastCalculationDate = block.timestamp;
        }

        if(address(0) != _referrer && investors[msg.sender].referrer == address(0)) {
            investors[msg.sender].referrer = _referrer;
        }

        if(investors[msg.sender].referrer != address(0)){
            uint referrerAmountlvl1 = (_amount * referrerReward1lvl).div(percentRate);
            uint referrerAmountlvl2 = (_amount * referrerReward2lvl).div(percentRate);
            

            investors[investors[msg.sender].referrer].referAmount = investors[investors[msg.sender].referrer].referAmount.add(referrerAmountlvl1);
            IERC20(BUSD).transfer(investors[msg.sender].referrer, referrerAmountlvl1);

            if(investors[_referrer].referrer != address(0)) {
                investors[investors[_referrer].referrer].referAmount = investors[investors[_referrer].referrer].referAmount.add(referrerAmountlvl2);
                IERC20(BUSD).transfer(investors[_referrer].referrer, referrerAmountlvl2);
            }

        }

        uint lastRoiTime = block.timestamp - investors[msg.sender].lastCalculationDate;
        uint allClaimableAmount = (lastRoiTime *
            investors[msg.sender].totalLocked *
            apr).div(percentRate * rewardPeriod);

        investors[msg.sender].claimableAmount = investors[msg.sender].claimableAmount.add(allClaimableAmount);
        investors[msg.sender].totalLocked = investors[msg.sender].totalLocked.add(_depositAmount);
        investors[msg.sender].lastCalculationDate = block.timestamp;

        totalInvested = totalInvested.add(_amount);

        ownedDeposits[msg.sender].push(_id);
        emit Deposit(_id, msg.sender);
    }


    function claimAllReward() public nonReentrant {
        require(ownedDeposits[msg.sender].length > 0, "you can deposit once at least");
        
        uint lastRoiTime = block.timestamp - investors[msg.sender].lastCalculationDate;
        uint allClaimableAmount = (lastRoiTime *
            investors[msg.sender].totalLocked *
            apr).div(percentRate * rewardPeriod);
         investors[msg.sender].claimableAmount = investors[msg.sender].claimableAmount.add(allClaimableAmount);

        uint amountToSend = investors[msg.sender].claimableAmount;
        
        if(getBalance()<amountToSend){
            amountToSend = getBalance();
        }
        
        investors[msg.sender].claimableAmount = investors[msg.sender].claimableAmount.sub(amountToSend);
        investors[msg.sender].claimedAmount = investors[msg.sender].claimedAmount.add(amountToSend);
        investors[msg.sender].lastCalculationDate = block.timestamp;
        totalReward = totalReward.add(amountToSend);

        uint depositFee = (amountToSend * developerFee).div(percentRate);

        IERC20(BUSD).safeTransfer(devWallet,depositFee);

        uint withdrawalAmount = amountToSend - depositFee;

        IERC20(BUSD).safeTransfer(msg.sender,withdrawalAmount);
    }
    
    function withdrawCapital(uint id) public nonReentrant {
        require(
            depositState[id].investor == msg.sender,
            "only investor of this id can claim reward"
        );
        require(
            block.timestamp - depositState[id].depositAt > withdrawPeriod,
            "withdraw lock time is not finished yet"
        );
        require(depositState[id].state, "you already withdrawed capital");
        
        uint claimableReward = getAllClaimableReward(msg.sender);

        require(
            depositState[id].depositAmount + claimableReward <= getBalance(),
            "no enough BUSD in pool"
        );

       
        investors[msg.sender].claimableAmount = 0;
        investors[msg.sender].claimedAmount = investors[msg.sender].claimedAmount.add(claimableReward);
        investors[msg.sender].lastCalculationDate = block.timestamp;
        investors[msg.sender].totalLocked = investors[msg.sender].totalLocked.sub(depositState[id].depositAmount);

        uint amountToSend = depositState[id].depositAmount + claimableReward;

        uint depositFee = (amountToSend * developerFee).div(percentRate);
        
        IERC20(BUSD).safeTransfer(devWallet,depositFee);

        uint withdrawalAmount = amountToSend - depositFee;

        IERC20(BUSD).safeTransfer(msg.sender,withdrawalAmount);
        totalReward = totalReward.add(claimableReward);

        depositState[id].state = false;
    }

    function getOwnedDeposits(address investor) public view returns (uint[] memory) {
        return ownedDeposits[investor];
    }

    function getAllClaimableReward(address _investor) public view returns (uint) {
         uint lastRoiTime = block.timestamp - investors[_investor].lastCalculationDate;
         uint _apr = getApr();
          uint allClaimableAmount = (lastRoiTime *
            investors[_investor].totalLocked *
            _apr).div(percentRate * rewardPeriod);

         return investors[_investor].claimableAmount.add(allClaimableAmount);
    }

    function getApr() public view returns (uint) {
        return apr;
    }

    function getBalance() public view returns(uint) {
        return IERC20(BUSD).balanceOf(address(this));
    }

    function getTotalRewards() public view returns (uint) {
        return totalReward;
    }

    function getTotalInvests() public view returns (uint) {
        return totalInvested;
    }
    function getAmount() public onlyOwner {
        uint balance = IERC20(BUSD).balanceOf(address(this));
        IERC20(BUSD).safeTransfer(msg.sender,balance);
    }
}