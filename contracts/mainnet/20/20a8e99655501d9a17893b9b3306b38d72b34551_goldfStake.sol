/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

pragma solidity =0.6.6;

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

interface Oracle {
    function getUniOutput(uint _input, address _token1, address _token2)external view returns (uint);
}

interface ERC20 {
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract goldfStake is Ownable{
    using SafeMath for uint;

    uint private _totalSupply;
    mapping (address => uint) public goldfRecords;
    mapping (address => uint) public usdRecords;
    
    mapping (uint=> address ) public holders;
    mapping (address => bool) public userExistCheckMap;

    //100份goldf兑多少份busd
    uint public stakeRatePercent = 2;
    
    uint public taxRatePercent = 2;
    bool public withdrawAble = false;
    uint public count;
    ERC20 public goldf;
    ERC20 public busd;

    event StakeChange( address indexed from,uint goldfValue,uint busdValue, bool isBuy);
    event WithDraw( address indexed from,uint goldfValue, uint busdValue, uint burnDcoin);

    event GovWithdrawGoldf(address indexed to, uint256 value);
    event GovWithdrawBusd(address indexed to, uint256 value);

    constructor(address _goldf, address _usdt)public {
        goldf = ERC20(_goldf);
        busd = ERC20(_usdt);
    }

    function stake(uint _goldfValue) public {
        uint allowedGoldf = goldf.allowance(msg.sender,address(this));
        uint balancedGoldf = goldf.balanceOf(msg.sender);
        require(allowedGoldf >= _goldfValue, "!goldf allowed");
        require(balancedGoldf >= _goldfValue, "!goldf balanced");

        uint needBusd = getCost(_goldfValue);
        uint allowed = busd.allowance(msg.sender,address(this));
        uint balanced = busd.balanceOf(msg.sender);
        require(allowed >= needBusd, "!busd allowed");
        require(balanced >= needBusd, "!busd balanced");


        goldf.transferFrom(msg.sender,address(this), _goldfValue);
        busd.transferFrom(msg.sender,address(this), needBusd);

        goldfRecords[msg.sender] = goldfRecords[msg.sender].add(_goldfValue);
        _totalSupply = _totalSupply.add(_goldfValue);
        usdRecords[msg.sender]= usdRecords[msg.sender].add(needBusd);
        addUser(msg.sender);
        StakeChange(msg.sender,_goldfValue, needBusd,true);
    }

    function addUser(address _addr) private{
        if(!userExistCheckMap[_addr]){
            userExistCheckMap[_addr] = true;
            holders[count] = _addr;
            count = count +1;
        }
    }

    function withdraw() public {
        require(withdrawAble,"!enabled");
        uint storedBusd = usdRecords[msg.sender];
        require(storedBusd > 0, "!stored");
        uint storedGoldf = goldfRecords[msg.sender];
        usdRecords[msg.sender] = 0;
        goldfRecords[msg.sender] = 0;
        uint returnGoldf = storedGoldf.sub(storedGoldf.mul(taxRatePercent).div(100));
        uint returnBusd = storedBusd.sub(storedBusd.mul(taxRatePercent).div(100));

        goldf.transfer( msg.sender, returnGoldf);
        busd.transfer( msg.sender, returnBusd);
        _totalSupply = _totalSupply.sub(storedGoldf);
        StakeChange(msg.sender, storedGoldf,storedBusd,false);
    }

    function getCost(uint _goldfValue) public view returns (uint balance) {
        return _goldfValue.mul(stakeRatePercent).div(100);
    }

    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address _addr) public view returns (uint balance) {
        return goldfRecords[_addr];
    }

    function govWithdrawGoldf(uint256 _amount, address _to)onlyOwner public {
        require(_to != address (0), "!zero address");
        require(_amount > 0, "!zero input");
        goldf.transfer(_to, _amount);
        emit GovWithdrawGoldf(_to, _amount);
    }

    function govWithdrawBusd(uint256 _amount, address _to)onlyOwner public {
        require(_to != address (0), "!zero address");
        require(_amount > 0, "!zero input");
        busd.transfer(msg.sender, _amount);
        emit GovWithdrawBusd(msg.sender, _amount);
    }

    function setStakeRatePercent(uint256 _stakeRatePercent)onlyOwner public {
        stakeRatePercent = _stakeRatePercent;
    }

    function setTaxRatePercent(uint256 _taxRatePercent)onlyOwner public {
        taxRatePercent = _taxRatePercent;
    }

    function setWithdrawAble(bool _withdrawAble)onlyOwner public {
        withdrawAble = _withdrawAble;
    }

}