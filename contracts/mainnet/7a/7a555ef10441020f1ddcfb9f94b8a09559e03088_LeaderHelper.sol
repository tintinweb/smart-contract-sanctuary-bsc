/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;
pragma experimental ABIEncoderV2;

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface structItem {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 rewardDebt2;
    }
}

interface farm is structItem {
    function userInfo(uint256 ,address) external view returns(UserInfo memory);
}

interface rewardPlus {
    function getCustomerAddressList(address _user) external view returns (address[] memory CustomerList, uint256 Num);
}


contract LeaderHelper is Ownable,structItem {
    IERC20 public cot = IERC20(0x0c29fc787e4995F8F1F14ff4C561FB9294f58c4A);
    IERC20 public pair = IERC20(0x97e12Ae9C5baeB1900C24542C2C0bd922B782e35);
    farm public farmAddress = farm(0xF5E42cA46d3C86b54DF1AbCa838Fa2268B1f3740);
    uint256[] public poolList = [0,1,2,3,4,5,6];
    rewardPlus public rewardAddress = rewardPlus(0x4763ed8B1A5fC10e74b7C2F3072af6575FbefCBC);
    
    function config(IERC20 _cot,IERC20 _pair,farm _farmAddress,uint256[] memory _poolList,rewardPlus _rewardAddress) external onlyOwner {
       cot =  _cot;
       pair = _pair;
       farmAddress = _farmAddress;
       poolList = _poolList;
       rewardAddress = _rewardAddress;
    }
    
    struct dataItemStruct {
      address account;
      uint256 cotBalance;
      uint256 pairBalance;
      uint256[] amountList;  
    }
    
    function getAllData(address _account) public view returns(dataItemStruct memory dataItem) {
        dataItem.account = _account;
        dataItem.cotBalance = cot.balanceOf(_account);
        dataItem.pairBalance = pair.balanceOf(_account);
        dataItem.amountList = new uint256[](poolList.length);
        for (uint256 i=0;i<poolList.length;i++) {
            dataItem.amountList[i] = farmAddress.userInfo(poolList[i],_account).amount;
        }
    }
    
    function massGetAllData(address[] memory _accountList) public view returns(uint256 gasLimit,dataItemStruct[] memory dataItemList,uint256 blockNum,uint256 time,uint256 gasUsed,uint256 reserve0, uint256 reserve1) {
       gasLimit = gasleft();
       dataItemList = new dataItemStruct[](_accountList.length);
       for (uint256 i=0;i<_accountList.length;i++) {
           dataItemList[i] = getAllData(_accountList[i]);
       }
       blockNum = block.number;
       time = block.timestamp;
       (reserve0,reserve1,) = pair.getReserves();
       uint256 u1 = gasleft();
       gasUsed = gasLimit-u1;
    }
    
    function getCustomerDataList(address _account) external view returns (uint256 gasLimit,dataItemStruct[] memory dataItemList,uint256 blockNum,uint256 time,uint256 gasUsed,uint256 reserve0, uint256 reserve1) {
       (address[] memory CustomerList,) = rewardAddress.getCustomerAddressList(_account);
       (gasLimit,dataItemList,blockNum,time, gasUsed, reserve0, reserve1) = massGetAllData(CustomerList);
    }
    
}