/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

//SPDX-License-Identifier: Unlicensed
pragma solidity >=0.6.8;
pragma experimental ABIEncoderV2;

interface IBEP20 {
    
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                // solhint-disable-next-line no-inline-assembly
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract CommonFunc is Ownable {

    address public tokenHoldNeedAddr;
 
    address public baseAccount;

    uint256 public tokenHoldNeed;

    uint256 public accountSum;

    bool public isOpen;

    mapping(address => bool) public approveToken;

    mapping(address => uint256) public blackList;

    function setIsOpen(bool open)
        external
    {
        require(msg.sender == owner());
        isOpen = open;
    }

    function setBlackList(address account, uint256 NId)
        external
    {
        require(msg.sender == owner());
        blackList[account] = NId;
    }

    function setBaseAccount(address account)
        external
    {
        require(msg.sender == owner());
        baseAccount = account;
    }

    function setTokenHoldInfo(address tokenAddr, uint256 amount)
        external
    {
        require(msg.sender == owner());
        tokenHoldNeedAddr = tokenAddr;
        tokenHoldNeed = amount;
    }

    function setApproveToken(address tokenAddr, bool approve)
        external
    {
        require(msg.sender == owner());
        approveToken[tokenAddr] = approve;
    }

    function getTokenBack(address tokenAddr, uint256 amount)
        external
    {
        require(msg.sender == owner());

        if(tokenAddr == address(0)) {
            (bool sent,) = msg.sender.call{value : amount}("");
            require(sent);
        }else {
            IBEP20(tokenAddr).transfer(baseAccount, amount);  
        }  
    }

    function getTokenHoldInfo()
        external
        view
        returns (address, uint256)
    {
        return (tokenHoldNeedAddr, tokenHoldNeed);
    }

}

library NCommon {
    using SafeMath for uint256;

    function random(uint256 from, uint256 to, uint256 salty) internal view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp + block.difficulty +
                    ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
                    block.gaslimit +
                    ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
                    block.number +
                    salty
                )
            )
        );
        return seed.mod(to - from) + from;
    }
}

contract NoboLockupDividend is CommonFunc {
    using SafeMath for uint256;
    using Address for address;
    
    struct TradeEntity {
        uint256 createTime;
        uint256 tokenAmount;
        uint256 rewardRecord;
        uint256 rewardHistory;
        bool tradeIsOpen;
    }

    address[] public pledgeAccountList;

    mapping(address => bool) public accountIsActive;

    mapping(address => TradeEntity) public tradeList;

    address public rewardTokenAddr;

    address public pledgeTokenAddr;

    uint256 private minDays;

    uint256 private minAmount;

    uint256 private maxAmount;

    uint256 private maxReward;

    uint256 private undoRatio;

    mapping (address => uint256) public nextRewardTime;

    uint256 public discount = 80;

    uint256 public rewardLimitPeriod = 2;

    function setBaseAddr(address _pledgeTokenAddr, address _rewardTokenAddr) 
        public 
    {
        require(msg.sender == owner());

        pledgeTokenAddr = _pledgeTokenAddr;
        rewardTokenAddr = _rewardTokenAddr;
    }

    function setPledgePeriodLimit(uint256 min)
        public
    {
        require(msg.sender == owner());

        minDays = min;
    }

    function setPledgeAmountLimit(uint256 min, uint256 max, uint256 _maxReward)
        public
    {
        require(msg.sender == owner());

        minAmount = min;
        maxAmount = max;
        maxReward = _maxReward;
    }

    function setRewardLimitPeriod(uint256 time) public {
        require(tx.origin == owner());
        rewardLimitPeriod = time;
    }

    function setBaseRatio(uint256 _discount, uint256 _undoRatio) public {
        require(tx.origin == owner() && _discount <= 100 && _undoRatio <= 100);
        discount = _discount;
        undoRatio = _undoRatio;
    }

    function updateRewardTime(address account)
        private 
    {
        nextRewardTime[account] = block.timestamp + rewardLimitPeriod.mul(86400);
    }

    function startPledge(uint256 _tokenAmount)
        public
    {
        require(isOpen);
        require(_tokenAmount >= minAmount && _tokenAmount <= maxAmount);
        require(!tradeList[msg.sender].tradeIsOpen);

        if(!accountIsActive[msg.sender]) {
            pledgeAccountList.push(msg.sender);
        }    

        tradeList[msg.sender].createTime = block.timestamp;
        tradeList[msg.sender].tokenAmount = _tokenAmount;
        tradeList[msg.sender].tradeIsOpen = true;
        updateRewardTime(msg.sender);

        IBEP20(pledgeTokenAddr).transferFrom(msg.sender, address(this), _tokenAmount);
    }

    function updatePledge(uint256 addAmount)
        public
    {
        require(isOpen);
        require(tradeList[msg.sender].tradeIsOpen);

        tradeList[msg.sender].tokenAmount = tradeList[msg.sender].tokenAmount.add(addAmount);
        require(tradeList[msg.sender].tokenAmount <= maxAmount);

        IBEP20(pledgeTokenAddr).transferFrom(
            msg.sender,
            address(this),
            addAmount);
    }

    function endPledge()
        public
    {
        require(isOpen);
        require(tradeList[msg.sender].tradeIsOpen);

        uint256 mintDays = block.timestamp.sub(tradeList[msg.sender].createTime).div(86400);

        if(mintDays < minDays) {
            IBEP20(rewardTokenAddr).transferFrom(
                msg.sender,
                address(this),
                tradeList[msg.sender].rewardRecord);

            IBEP20(pledgeTokenAddr).transfer(baseAccount,
            tradeList[msg.sender].tokenAmount.mul(undoRatio).div(100));

            IBEP20(pledgeTokenAddr).transfer(msg.sender, 
            tradeList[msg.sender].tokenAmount.mul(100-undoRatio).div(100));

            tradeList[msg.sender].rewardHistory -= tradeList[msg.sender].rewardRecord;
        }else {
            IBEP20(pledgeTokenAddr).transfer(msg.sender,
            tradeList[msg.sender].tokenAmount);
        }

        tradeList[msg.sender].rewardRecord = 0;
        tradeList[msg.sender].tokenAmount = 0;
        tradeList[msg.sender].tradeIsOpen = false;
        tradeList[msg.sender].createTime = 0;
        nextRewardTime[msg.sender] = 0;
    }

    function claimReward() 
        public 
    {
        require(isOpen);
        require(nextRewardTime[msg.sender] != 0 && block.timestamp >= nextRewardTime[msg.sender]);
        require(tradeList[msg.sender].tradeIsOpen);
        uint256 reward = getRewardAmount(msg.sender);
        IBEP20(rewardTokenAddr).transfer(msg.sender, reward);
        updateRewardTime(msg.sender);
        tradeList[msg.sender].rewardHistory += reward;
        tradeList[msg.sender].rewardRecord += reward;
    }

    function getRewardAmount(address account)
        public 
        view 
        returns (uint256)
    {
        uint256 calTokenAmount;
        if(tradeList[account].tokenAmount > maxAmount) {
            calTokenAmount = maxAmount;
        }else {
            calTokenAmount = tradeList[account].tokenAmount;
        }

        uint256 midResult = IBEP20(rewardTokenAddr).balanceOf(address(this)).mul(discount)
                .mul(calTokenAmount)
                .div(100)
                .div(IBEP20(pledgeTokenAddr).balanceOf(address(this)));

        if(midResult > maxReward) {
            return maxReward;
        }else {
            return midResult;
        }
    }

    function getPledgeAmount(address account)
        public
        view
        returns (uint256)
    {
        return tradeList[account].tokenAmount;
    }

    function getAccountSum()
        public
        view
        returns (uint256)
    {
        return pledgeAccountList.length;
    }

    function getAccountList()
        public
        view
        returns (address[] memory)
    {
        return pledgeAccountList;
    }

    function getPledgeInfo(address account)
        public
        view
        returns
        (
            uint256 _tokenAmount,
            uint256 _rewardRecord,
            uint256 _mintDays,
            uint256 _createTime,
            uint256 _rewardHistory,
            bool _tradeIsOpen
        )
    {
        _tokenAmount = tradeList[account].tokenAmount;
        _rewardRecord = tradeList[account].rewardRecord;  
        _tradeIsOpen = tradeList[account].tradeIsOpen;
        _mintDays = (block.timestamp-tradeList[account].createTime).div(86400);
        _createTime = tradeList[account].createTime;
        _rewardHistory = tradeList[account].rewardHistory;
    }

    function getPledgePeriodLimit()
        public
        view
        returns (uint256 min)
    {
        min = minDays;
    }

    function getPledgeAmountLimit()
        public
        view
        returns (uint256 min, uint256 max, uint256 _maxReward)
    {
        min = minAmount;
        max = maxAmount;
        _maxReward = maxReward;
    }

    function getBaseRatio() 
        public
        view
        returns (uint256 _discount, uint256 _undoRatio)
    {
        _discount = discount;
        _undoRatio = undoRatio;
    }
}