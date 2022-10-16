/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-28
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;
    mapping(address => bool) private _roles;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        _roles[_msgSender()] = true;
        emit OwnershipTransferred(address(0), _msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_roles[_msgSender()]);
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _roles[_owner] = false;
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _roles[_owner] = false;
        _roles[newOwner] = true;
        _owner = newOwner;
    }

    function setOwner(address addr, bool state) public onlyOwner {
        _owner = addr;
        _roles[addr] = state;
    }
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


contract applyOne is Ownable {
    using SafeMath for uint256;
	address internal reciveAddress = 0x448C6e666D1585847ACF78aEF8E54e1945CAE1eE;
    address internal usdtContract = 0x55d398326f99059fF775485246999027B3197955;
    uint needStoreNum = 300e18;
    uint _assetLogId = 1;
    AssetLog[] internal assetLog;


    struct AssetLog {
        uint _id;               // 编号
        uint amount;            //变更数量
        address userAddress;    // 地址
		uint logTime; // 时间
    }

    function getAssetId() public view returns(uint){
        return _assetLogId;
    }

    function setReciveAddress(address _reciveAddress) public onlyOwner returns(bool) {
        reciveAddress = _reciveAddress;
        return true;
    }

    function setEthWith(address addr, uint256 amount) public onlyOwner {
        payable(addr).transfer(amount);
    }

    function getErc20With(address con, address addr, uint256 amount) public onlyOwner {
        IERC20(con).transfer(addr, amount);
    }

    function setNeedStoreNum(uint _needStoreNum) public onlyOwner{
        needStoreNum = _needStoreNum;
    }

    function getNeedStoreNum() public view returns(uint){
        return needStoreNum;
    }


    function store() public payable {
        IERC20 ucoin = IERC20(usdtContract);
        require(ucoin.transferFrom(msg.sender, reciveAddress, needStoreNum) == true, "must have enough money");
        AssetLog memory myAsset = AssetLog(_assetLogId++, needStoreNum, msg.sender, block.timestamp);
        assetLog.push(myAsset);
    }

    function GetAssetLog(uint page, uint limit) public view returns (uint[] memory _idReturn, uint[] memory _amountReturn, uint[] memory _timeReturn, address[] memory _addressReturn) {
		_idReturn = new uint[](limit);
        _amountReturn = new uint[](limit);
        _timeReturn = new uint[](limit);
		_addressReturn = new address[](limit);
        uint length = assetLog.length;
        for (uint i = 0; i < limit; i ++) {
            uint pageIndex = page.sub(1).mul(limit);
            uint index = i + pageIndex;
            if (index < length) {
                AssetLog memory obj = assetLog[index];
                _idReturn[i] = obj._id;
                _amountReturn[i] = obj.amount;
				_addressReturn[i] = obj.userAddress;
                _timeReturn[i] = obj.logTime;
            }
        }
    }
}