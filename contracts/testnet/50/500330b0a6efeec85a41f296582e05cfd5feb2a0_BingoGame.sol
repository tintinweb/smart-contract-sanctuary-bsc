/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

pragma solidity >=0.4.22 <0.9.0;
// SPDX-License-Identifier: Unlicensed
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
contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}
library IterableSingleSet {
    // Iterable mapping from address to uint;
    struct userInfo{
        uint256 amount;
        uint256 nowtime;
        uint256 deadline;
        uint16 feeType;
    }
    struct Map {
        address[] keys;
        //mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => userInfo) userType;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint256 _amount,uint16 _feeType,uint256 _deadline) {
        return (map.userType[key].amount,map.userType[key].feeType,map.userType[key].deadline);
    }

    function getIndexOfKey(Map storage map, address key)
        public
        view
        returns (int256)
    {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
        public
        view
        returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint256 _amount,
        uint256 _deadline,
        uint16 _feeType
    ) public {
        if (map.inserted[key]) {
            map.userType[key].amount = _amount;
            map.userType[key].feeType=_feeType;
            map.userType[key].deadline=_deadline;
        } else {
            map.inserted[key] = true;
            map.userType[key].amount = _amount;
            map.userType[key].feeType=_feeType;
            map.userType[key].deadline=_deadline;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.userType[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];
        map.keys[index] = lastKey;
        map.keys.pop();
    }
}
contract BingoGame is Ownable {
     using SafeMath for uint256;
    mapping (uint16 => uint256) private _MapFeeType;
    address public betTokenAddress=address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
    uint256 public minBetAmount=50;
    using IterableSingleSet for IterableSingleSet.Map;
    IterableSingleSet.Map private singleBingoMap;//用户数数量
    uint64 public setIndex;
     mapping (uint64 => IterableSingleSet.Map) private _MapAllSet;
     uint8 public feePercent;
    constructor() public {
    }
    function addVipUser(uint256 _betAmount,uint16 _feeType,uint256 _deadline) payable public {
        if(setIndex==0)
        {
            setIndex=1;
        }
        require(_betAmount>=minBetAmount,"Too low");
         bool _success=false;
        IERC20 token = IERC20(betTokenAddress);
        _success=token.transferFrom(msg.sender, address(this), _betAmount);
       IterableSingleSet.Map  storage singleSet= _MapAllSet[setIndex];
       uint256 singleSize=singleSet.size();
        //require(_amount>=vipAmount);
       singleBingoMap.set(msg.sender,_betAmount,_deadline,_feeType);
    }
    function getUserSetInfoBySender(uint64 _setIndex) public view returns (uint256 _amount,uint16 _feeType,uint256 _deadline) {
        IterableSingleSet.Map  storage singleSet= _MapAllSet[_setIndex];
        return singleSet.get(msg.sender);
    }
    function getUserSetInfoBySender(uint64 _setIndex,address _userAdd) public view returns (uint256 _amount,uint16 _feeType,uint256 _deadline) {
        IterableSingleSet.Map  storage singleSet= _MapAllSet[_setIndex];
        return singleSet.get(_userAdd);
    }
    function setFeeType(uint16 _feeType,uint256 _amount) public onlyOwner{
        require(_amount > 0);
        _MapFeeType[_feeType]=_amount;
    }
    function getFeeTypeAmount(uint16 _feeType) public view returns(uint256){
        uint256 _amount=0;
        _amount= _MapFeeType[_feeType];
        if(_amount>0){
            _amount=_amount.mul(feePercent).div(100);
        }
       return _MapFeeType[_feeType];
    }
   function getUserCount() public view returns(uint256){
       return singleBingoMap.keys.length;
    }
    //receive() external payable {}
    function setFeePercent(uint8 _feePercent) public onlyOwner {
        feePercent = _feePercent;
    }
   
    function minFee() public view returns(uint256) {
        return tx.gasprice * gasleft() * feePercent / 100;
    }
    function claim(address _token) public onlyOwner {
        if (_token == owner) {
            payable(owner).transfer(address(this).balance);
            return;
        }
        IERC20 erc20token = IERC20(_token);
        uint256 balance = erc20token.balanceOf(address(this));
        erc20token.transfer(owner, balance);
    }
}