/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

/**
 * Math operations with safety checks
 */
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


contract SignRecover {
    function splitSignature(bytes memory sig) internal pure returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
        // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
        // second 32 bytes
            s := mload(add(sig, 64))
        // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }
}

interface ERC20 {
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
}

contract KStake is Ownable, SignRecover{
    using SafeMath for uint;

    struct Record {
        uint stake;
        uint expire;
    }

    uint public refundTotal = 0;
    uint public lockTime = 8640000; //100天
    mapping( address => Record[]) public userRecordMap;    //用户的质押记录，显示在页面，加退的时候要用
    mapping (address => uint) public tokenRecords;

    ERC20 public lpToken;
    ERC20 public kToken;
    address public signer;

    event GovWithdrawToken( address indexed to, uint256 value);
    event Stake(address indexed from, uint amount);

    constructor(address _lpToken, address _kToken)public {
        lpToken = ERC20(_lpToken);
        kToken = ERC20(_kToken);
    }

    function stakeFor(address _to,uint _value) public returns (uint){
        uint allowed = lpToken.allowance(msg.sender,address(this));
        uint balanced = lpToken.balanceOf(msg.sender);
        require(allowed >= _value, "!allowed");
        require(balanced >= _value, "!balanced");
        lpToken.transferFrom(msg.sender,address(this), _value);
        uint expire = block.timestamp+lockTime;
        userRecordMap[_to].push(Record( _value,expire));
        emit Stake( _to, _value);
        return _value;
    }
    function stake(uint _value) public returns (uint){
        return stakeFor(msg.sender,_value);
    }

    function withdraw(uint _index) public{
        Record storage record = userRecordMap[msg.sender][_index];
        require(record.expire < block.timestamp, "not expired");
        uint _value = record.stake;
        delete userRecordMap[msg.sender][_index];
        lpToken.transfer( msg.sender, _value);
    }

    function sendToken( uint256  _balance, bytes memory _sig) public {
        require(signer != address(0), "no signer");
        string memory func = "sendToken";
        bytes32 message = keccak256(abi.encodePacked(this, func, msg.sender, address (kToken),_balance));
        require(recoverSigner(message, _sig) == signer,"sign err");
        address _to = msg.sender;
        uint _value = _balance.sub(tokenRecords[msg.sender]);
        tokenRecords[msg.sender] = _balance;
        kToken.transfer(_to, _value);
        refundTotal = refundTotal+_value;
    }

    function getTotalIncome()public view returns (uint){
        uint total = kToken.balanceOf(address (this));
        return total.add(refundTotal);
    }

    function getUserStake(address _addr) public view returns (uint){
        uint rs = 0;
        Record[] memory records = userRecordMap[_addr];
        uint count = records.length;
        for (uint i = 0; i < count; i++) {
            rs = rs + records[i].stake;
        }
        return rs;
    }

    function setTokens(address _lpToken,address _kToken) public onlyOwner {
        lpToken = ERC20(_lpToken);
        kToken = ERC20(_kToken);
    }

//    function govWithdrawToken(address _to,uint256 _amount) public onlyOwner {
//        require(_amount > 0, "!zero input");
//        lpToken.transfer( _to, _amount);
//        emit GovWithdrawToken( _to, _amount);
//    }
}