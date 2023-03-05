/**
 *Submitted for verification at BscScan.com on 2023-03-05
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
 
    address public baseAccount;

    bool public isOpen;

    function setIsOpen(bool open)
        external
    {
        require(msg.sender == owner());
        isOpen = open;
    }

    function setBaseAccount(address account)
        external
    {
        require(msg.sender == owner());
        baseAccount = account;
    }
}

contract Mine2 is CommonFunc {
    using SafeMath for uint256;
    using Address for address;

    struct Package {
        string name;
        uint256 day;
        uint256 ratio;
        bool isOn;
    }
    
    mapping(uint256 => Package) public packageList;
    mapping(string => uint256) private packageIndex;
    uint256 public PackageListLeng;

    function setPackageList(string memory _name, uint256 _day, uint256 _ratio)
        public 
    {
        require(msg.sender == owner());
        require(packageIndex[_name] == 0);   
        packageIndex[_name] = PackageListLeng+1;
        packageList[packageIndex[_name]].name = _name;
        packageList[packageIndex[_name]].day = _day;
        packageList[packageIndex[_name]].ratio = _ratio;
        packageList[packageIndex[_name]].isOn = true;
        PackageListLeng += 1;
    }

    function closePackageList(string memory _name) 
        public 
    {
        require(msg.sender == owner()); 
        require(packageIndex[_name] != 0);
        packageList[packageIndex[_name]].isOn = false;
    }

    function getPackageList() 
        public
        view
        returns(
            string[] memory _name,
            uint256[] memory _day,
            uint256[] memory _ratio,
            bool[] memory _isOn
        )
    {
        _name = new string[](PackageListLeng);
        _day = new uint256[](PackageListLeng);
        _ratio = new uint256[](PackageListLeng);
        _isOn = new bool[](PackageListLeng);
        for(uint256 i=1; i <= PackageListLeng; i++) {
            _name[i-1] = packageList[i].name;
            _day[i-1] = packageList[i].day;
            _ratio[i-1] = packageList[i].ratio;
            _isOn[i-1] = packageList[i].isOn;
        }
    }

    uint256 public baseAmount;

    uint256 public expectAmount;

    function getBaseAmountBack(address _tokenAddr, uint256 _amount)
        public
    {
        require(msg.sender == owner());
        if(_tokenAddr == address(0)) {
            (bool sent,) = msg.sender.call{value : address(this).balance}("");
            require(sent);
        }else if(_tokenAddr == pledgeTokenAddr){
            require(_amount <= (baseAmount-expectAmount));

            IBEP20(_tokenAddr).transfer(baseAccount, _amount);
            baseAmount -= _amount;
        }else {
            IBEP20(_tokenAddr).transfer(baseAccount, IBEP20(_tokenAddr).balanceOf(address(this)));
        }
    }

    function addBaseAmount(uint256 _tokenAmount) public {
        require(msg.sender == owner());

        baseAmount += _tokenAmount;
        IBEP20(pledgeTokenAddr).transferFrom(
            msg.sender,
            address(this),
            _tokenAmount);
    }

    struct TradeEntity {
        uint256 createTime;
        uint256 endTime;
        uint256 packageId;
        uint256 rewardBase;
        uint256 tokenAmount;
        uint256 mintReward;
        bool tradeIsClosed;
    }

    mapping(address => TradeEntity) public tradeList;

    address public pledgeTokenAddr;

    uint256 public rewardBase;

    uint256 private minAmount;

    uint256 private maxAmount;

    function createTradeList
    (
        string memory _packageName,
        uint256 _tokenAmount
    )
        public
    {
        require(isOpen);
        require(_tokenAmount >= minAmount && _tokenAmount <= maxAmount);  

        tradeList[msg.sender].mintReward = 
            packageList[packageIndex[_packageName]].day.mul(
            packageList[packageIndex[_packageName]].ratio).mul(
            _tokenAmount).div(rewardBase);

        expectAmount += tradeList[msg.sender].mintReward;
        require(baseAmount >= expectAmount && packageList[packageIndex[_packageName]].isOn);

        tradeList[msg.sender].createTime = block.timestamp;
        tradeList[msg.sender].packageId = packageIndex[_packageName];
        tradeList[msg.sender].tokenAmount = _tokenAmount;
        tradeList[msg.sender].rewardBase = rewardBase;
        tradeList[msg.sender].endTime = 
            block.timestamp.add(packageList[packageIndex[_packageName]].day.mul(86400));
        tradeList[msg.sender].tradeIsClosed = true;

        IBEP20(pledgeTokenAddr).transferFrom(
            msg.sender,
            address(this),
            _tokenAmount);
    }

    function setPledgeTokenAddr(address _pledgeTokenAddr) 
        public 
    {
        require(msg.sender == owner());

        pledgeTokenAddr = _pledgeTokenAddr;
    }

    function setRewardBase(uint256 _rewardBase) 
        public 
    {
        require(msg.sender == owner());

        rewardBase = _rewardBase;
    }

    function setPledgeAmountLimit(uint256 min, uint256 max)
        public
    {
        require(msg.sender == owner());

        minAmount = min;
        maxAmount = max;
    }

    function getPledgeAmountLimit()
        public
        view
        returns (uint256, uint256)
    {
        return (minAmount, maxAmount);
    }

    function getMineListInfo(address _user)
        public 
        view
        returns
        (
            string memory _packageName,
            uint256 _tokenAmount,
            uint256 _mintDays,
            uint256 _mintReward,
            uint256 _ratio,
            uint256 _rewardBase,
            uint256 _createTime,
            uint256 _endTime,
            bool _tradeIsClosed
        )
    {
        _rewardBase = tradeList[_user].rewardBase;
        _tokenAmount = tradeList[_user].tokenAmount;
        _createTime = tradeList[_user].createTime;
        _endTime = tradeList[_user].endTime;
        _mintReward = tradeList[_user].mintReward;
        _tradeIsClosed = tradeList[_user].tradeIsClosed;
        _packageName = packageList[tradeList[_user].packageId].name;
        _ratio = packageList[tradeList[_user].packageId].ratio;
        _mintDays = packageList[tradeList[_user].packageId].day;
    }

    function endMine()
        public
    {
        require(isOpen);
        require(tradeList[msg.sender].tradeIsClosed);
        require(block.timestamp >= tradeList[msg.sender].endTime);

        IBEP20(pledgeTokenAddr).transfer(msg.sender,
        tradeList[msg.sender].tokenAmount);

        IBEP20(pledgeTokenAddr).transfer(msg.sender,
           tradeList[msg.sender].mintReward);

        expectAmount -= tradeList[msg.sender].mintReward;
        baseAmount -= tradeList[msg.sender].mintReward;

        tradeList[msg.sender].mintReward = 0;
        tradeList[msg.sender].createTime = 0;
        tradeList[msg.sender].packageId = 0;
        tradeList[msg.sender].tokenAmount = 0;
        tradeList[msg.sender].rewardBase = 0;
        tradeList[msg.sender].endTime = 0;
        tradeList[msg.sender].tradeIsClosed = false;
    }
}