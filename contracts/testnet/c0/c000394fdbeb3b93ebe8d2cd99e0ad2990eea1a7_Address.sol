/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

pragma solidity ^0.5.0;

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

contract EIP20Interface {
    uint public totalSupply;
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

contract ZSTToken is EIP20Interface {

    using SafeMath for uint256;
    using Address for address;

    address owner;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    //address rewardAddress = 0x595735F6D6A6EA15A774D83AEBF3FDB1C532AD41;
    //address protectAddress = 0x92A7CF285F11CD47697EB9322FCFD4A93FDDA079;
    //address totalAddress = 0x39E290D3B366BBA100FF4D6E0960A98DC511E41C;//init
    address rewardAddress = 0x9CCb79621ceb43478f24763425F2C51905157f18;
    address protectAddress = 0x126B13b3146063676Ea6208e71F11a111AC1b3B5;
    address totalAddress = 0x83C0d6B174f1bDFC7E723096d22002332F439EdE;



    //ZST - TRX LP contract address
    address public lpContractAddress;
    // uint256 public stopBurn = 6_621_120e6;
    uint256 public burnTotal = 0;
    uint256 public rewardTotal = 0;
    bool public burnSwitch = true;
    bool public ownerSwitch = false;

    uint256 public totalRate;
    uint256 public secondlyRate;

    string public name ;
    uint8 public decimals;
    string public symbol;

    constructor() public {
        decimals = 18;
        totalSupply = 210000000000000000000000000000;
        balances[totalAddress] = totalSupply;
        owner = msg.sender;
        totalRate=7;
        secondlyRate=40;

        name = 'ZSTToken';
        symbol = 'ZST';
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        _transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (allowed[_from][msg.sender] != uint(-1)) {
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        }
        _transfer(_from, _to, _value);
        return true;
    }
    function _transfer(address _from, address _to, uint256 _value) private {
        bool stopFlag = false;
        if(_from == lpContractAddress){
            stopFlag = true;
        }
        if(_from == owner){
            stopFlag = true;
        }
        if(ownerSwitch){
            stopFlag = burnSwitch;
        }
        if(stopFlag){
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            emit Transfer(_from, _to, _value);
        }else{
            uint256 _fee = _value.div(100).mul(totalRate);
            uint256 _toValue = _value.sub(_fee);
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_toValue);
            emit Transfer(_from, _to, _toValue);
            uint256 _feeReward = _fee.div(100).mul(secondlyRate);
            uint256 _feeProduct = _fee.sub(_feeReward);
            rewardTotal = rewardTotal.add(_feeReward);
            balances[rewardAddress] = balances[rewardAddress].add(_feeReward);
            balances[protectAddress] = balances[protectAddress].add(_feeProduct);
            emit Transfer(_from, rewardAddress, _feeReward);
            emit Transfer(_from, protectAddress, _feeProduct);
        }
    }
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    function getRewardTotal() public view returns (uint256) {
        return rewardTotal;
    }
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    function setownerSwitch(bool _switch) public returns (bool success) {
        require(msg.sender == owner,"ZST:FORBIDDEN");
        ownerSwitch = _switch;
        return true;
    }
    function setzBilv(uint256 _value) public returns (bool success) {
        require(msg.sender == owner,"ZST:FORBIDDEN");
        totalRate = _value;
        return true;
    }
    function setfBilv(uint256 _value) public returns (bool success) {
        require(msg.sender == owner,"ZST:FORBIDDEN");
        secondlyRate = _value;
        return true;
    }
    function setLPContractAddress(address _address) public returns (bool success) {
        require(msg.sender == owner,"ZST:FORBIDDEN");
        lpContractAddress = _address;
        //if add Liquidity
        return true;
    }
}