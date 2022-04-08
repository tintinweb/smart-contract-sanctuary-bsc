/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

pragma solidity 0.5.16;

pragma experimental ABIEncoderV2;

contract Context {
    constructor () internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {codehash := extcodehash(account)}
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TransferContract is Ownable {

    using Address for address;

    IERC20  filToken = IERC20(0x55d398326f99059fF775485246999027B3197955);

    function transfer(address _to, uint256 _value) internal returns (bool){
        return filToken.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) internal returns (bool) {
        return filToken.transferFrom(_from, _to, _value);
    }

    function setERC20(IERC20 fil) public onlyOwner {
        filToken = fil;
    }
}

contract Minter is TransferContract{

    mapping(address => uint256) public userAmount; 

    mapping(address => string[]) public userMins; 

    uint256 public busBalance;

    uint256 public cost = 6000000000000000000;

    address public constant BUS = address(0xE783d4F0e6758c8c8F46D52535c1B8174E8AEaEf);

    modifier onlyBuser() {
        require(msg.sender == BUS, "Caller is not the Buser");
        _;
    }
    
    function withdrawBus(uint256 amount) external onlyBuser returns (bool) {
        require(busBalance >= amount, "Error Amount");
        busBalance -= amount;
        transfer(msg.sender, amount);
        return true;
    }

    function pledge(uint256 count) external returns (bool) {
        require(count > 0, "count error");
        require(transferFrom(msg.sender,address(this),cost*count), "invalid price");
        userAmount[msg.sender] += cost*count;
        return true;
    }
    

    function profit(address addr ,uint256 amount) external onlyOwner returns (bool){
        require(userAmount[addr] >= amount, "invalid amount");
        userAmount[addr] -= amount;
        busBalance += amount;
        return true;
    }

    function getUser(address addr) external view returns (string[] memory) {
        return userMins[addr];
    }

    function getUserPage(address addr, uint256 pageNo, uint256 pageSize) external view returns(uint ,string[] memory) {
        uint len = userMins[addr].length;
        uint start = pageNo * pageSize;
        if(len == 0  || start >= len){
            return (len,new string[](0));
        }
        uint end = start + pageSize;
        if(end > len){
            end = len;
        }
        uint arrLen = end - start;
        string[] memory list = new string[](arrLen);
        uint index;
        for(;start < end ; start ++){
            list[index++] = userMins[addr][start];
        }
        return (len,list);
    }

    function setUser(address addr,string[] calldata abc) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < abc.length; i++) {
             userMins[addr].push(abc[i]);
        }
        return true;
    }

    function setCost(uint256 newcost) external onlyOwner returns (bool) {
        cost = newcost;
        return true;
    }


}