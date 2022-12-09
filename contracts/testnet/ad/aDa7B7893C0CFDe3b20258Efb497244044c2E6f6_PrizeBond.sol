/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

pragma solidity ^0.8.17;
// SPDX-License-Identifier: MIT
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function _msgsender() external view returns (address);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor(){
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract PrizeBond is Ownable{
    using SafeMath for uint256;


    IERC20  public BToken;
    uint256 public startCardNo_25; 
    uint256 public startCardNo_50; 
    uint256 public startCardNo_100; 
    uint256 public endCardNo_25; 
    uint256 public endCardNo_50; 
    uint256 public endCardNo_100; 
    uint256 public bondPrice25 = 25 ether;
    uint256 public bondPrice50 = 50 ether;
    uint256 public bondPrice100 = 100 ether;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public winRandomNumber;
    uint256 public day = 10 minutes;

    // address:bondNo_25_50_100 to check card number
    mapping(address => mapping(uint256 => uint256)) private bondnumber;
    // bondNo_25_50_100 : card number to check card number have any owner.
    mapping(uint256 => mapping(uint256 => bool)) public bondN0Verification;
    // card number : bondNo_25_50_100 to check bond ownership
    mapping(uint256 => mapping(uint256 => address)) public bondOwner;
    // card number : bondNo_25_50_100 to check buying payments
    mapping(uint256 => mapping(uint256 =>uint256)) public bondpayment;
    // bondNo_25_50_100 : card number to check is it a winning number?
    mapping(uint256 => mapping(uint256 => bool)) public checkRandomCardNO;

    event Number(uint256 _winRandomNumber);

    constructor(IERC20 _BToken) 
    { 
        BToken = _BToken;
        startCardNo_25 = 1; 
        startCardNo_50 = 6; 
        startCardNo_100 = 11;
        endCardNo_25 =  5;
        endCardNo_50 =  10;
        endCardNo_100 =  15;
        startTime = block.timestamp;
        endTime = startTime + 10 minutes;
    } 
    function buy(uint256 _amount, uint256 _bondNo) public 
    {
        require(startTime <= endTime, "Time end");
        require(_amount == bondPrice25 ||_amount == bondPrice50 || _amount == bondPrice100, "Amount Error! " );
        if(_amount == bondPrice25)
        {
            require(_bondNo >= startCardNo_25 && _bondNo <= endCardNo_25, "25 Card Error!");
            require(!bondN0Verification[25][_bondNo], " Already issued"); 
            bondnumber[msg.sender][25] = _bondNo;
            bondOwner[_bondNo][25] = msg.sender;
            bondpayment[_bondNo][25] = _amount;
            bondN0Verification[25][_bondNo] = true;
            BToken.transferFrom(msg.sender,address(this),_amount);
        }
        else if(_amount == bondPrice50)
        {
            require(_bondNo >= startCardNo_50 && _bondNo <= endCardNo_50, "50 Card Error!");
            require(!bondN0Verification[50][_bondNo], " Already issued");
            bondnumber[msg.sender][50] = _bondNo;
            bondOwner[_bondNo][50] = msg.sender;
            bondpayment[_bondNo][50] = _amount;
            bondN0Verification[50][_bondNo] = true;
            BToken.transferFrom(msg.sender,address(this),_amount);
        }
        else if(_amount == bondPrice100)
        {
            require(_bondNo >= startCardNo_100 && _bondNo <= endCardNo_100, "100 Card Error!");
            require(!bondN0Verification[100][_bondNo], " Already issued ");
            bondnumber[msg.sender][100] = _bondNo;
            bondOwner[_bondNo][100] = msg.sender;
            bondpayment[_bondNo][100] = _amount;
            bondN0Verification[100][_bondNo] = true;
            BToken.transferFrom(msg.sender,address(this),_amount);
        }
    }

    function setTime(uint256 _startTime, uint256  _endTime) 
    public 
    onlyOwner
    {
        startTime = _startTime;
        endTime = _endTime;
    }

    function setCardNo_25(uint256 _startCardNo, uint256 _endCardNo) 
    public 
    onlyOwner
    {
        startCardNo_25 = _startCardNo;
        endCardNo_25 = _endCardNo;
    }

    function setCardNo_50(uint256 _startCardNo, uint256 _endCardNo) 
    public 
    onlyOwner
    {
        startCardNo_50 = _startCardNo;
        endCardNo_50 = _endCardNo;
    }

    function setCardNo_100(uint256 _startCardNo, uint256 _endCardNo)
    public 
    onlyOwner
    {
        startCardNo_100 = _startCardNo;
        endCardNo_100 = _endCardNo;
    }

    function setPriceBond25(uint256 _price) 
    public 
    onlyOwner
    { bondPrice25 = _price; }

    function setPriceBond50(uint256 _price) 
    public 
    onlyOwner
    { bondPrice50 = _price; }

    function setPriceBond100(uint256 _price) 
    public 
    onlyOwner
    { bondPrice100 = _price; }
    
    function sellBond(uint256 _bondNo, uint256 _bondpkg) 
    public 
    {
        require(msg.sender == bondOwner[_bondNo][_bondpkg],"Owner Error");
        BToken.transfer(msg.sender,bondpayment[_bondNo][_bondpkg]);
        bondOwner[_bondNo][_bondpkg] = address(this);
        bondN0Verification[_bondpkg][_bondNo] = false;
    }
   
    function win_25() public onlyOwner
    {
        require(block.timestamp > endTime,"Time not completed! ");
        winRandomNumber = random(endCardNo_25,startCardNo_25,25);
        checkRandomCardNO[25][winRandomNumber] = true;
        if(bondN0Verification[25][winRandomNumber] == checkRandomCardNO[25][winRandomNumber])
        {
            uint256 reward = bondPrice25.mul(3);
            BToken.transfer(bondOwner[winRandomNumber][25], reward);
        }
        emit Number(winRandomNumber);
    }

    function win_50() public onlyOwner
    {
        require(block.timestamp > endTime,"Time not completed! ");
        winRandomNumber = random(endCardNo_50,startCardNo_50,50);
        checkRandomCardNO[50][winRandomNumber] = true;
        if(bondN0Verification[50][winRandomNumber] == checkRandomCardNO[50][winRandomNumber])
        {
        uint256 reward = bondPrice50.mul(4);
        BToken.transfer(bondOwner[winRandomNumber][50], reward);
        }
        emit Number(winRandomNumber);
    }

    function win_100() public onlyOwner
    {
        require(block.timestamp > endTime,"Time not completed! ");
        winRandomNumber = random(endCardNo_100,startCardNo_100,100);
        checkRandomCardNO[100][winRandomNumber] = true;
        if(bondN0Verification[100][winRandomNumber] == checkRandomCardNO[100][winRandomNumber])
        {
        uint256 reward = bondPrice100.mul(5);
        BToken.transfer(bondOwner[winRandomNumber][100], reward);
        }
        emit Number(winRandomNumber);
    }

    function random(uint256 maxNumber,uint256 minNumber, uint256 _bondNo) 
    internal 
    view 
    returns (uint256 amount) 
    {
        amount = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.number))) % (maxNumber-minNumber);
        amount = amount + minNumber;
        if(!checkRandomCardNO[_bondNo][amount])
        {  
            return amount;
        }
        else
        { 
            random(endCardNo_25,startCardNo_25,25); 
        }
    }

 
}