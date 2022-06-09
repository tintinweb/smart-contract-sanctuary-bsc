/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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

interface IBEP20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    function balanceOf(address account) external returns (uint256);
}

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

contract GalaxyBattleship is Ownable {
    using SafeMath for uint256;

    IBEP20 public aecToken = IBEP20(0x606467f800E92eD9991C0bEF9F8D9ee362f20B7e);
    IBEP20 public botToken = IBEP20(0xDc82e692B9eb8AAC0E12A59a8A35423008C0B011);
    IBEP20 public usdtToken = IBEP20(0xb5Af8648EfF53FdAA680552Ef564c1F79d321a34);
    address private devAddress = 0xA356A7A8aC0c780dd28125aeB7F6A832313C7536;
    IPancakePair pancakePair = IPancakePair(0x6a1A7DaB9a1F68A859F5435749168B6DcD811432);

    
    uint256 public botPrice = 1000000000000000000;//BOT指导价
    uint256 public totalPower = 0;//总算力
    uint256 public dailyOutput = 3360000000000000000;//每日产量
    mapping(address => UserObject) public _userMap;
    
    struct UserObject {
        bool isConf;
        address holder;//地址
        uint256 myPower;//我的算力
        uint256 myUsdtAmount;
        uint256 myAecAmount;
        uint256 myTakeTime;//最近领取时间
        uint256 myTakeCount;//收益总额
        address parent;//上级地址
        uint256 profit;//推荐奖励
    }

    function buy(address ref,uint256 usdtAmount) public{
        //获取AEC价格，并计算AEC数量
        uint256 aecPrice = calcAecPrice();
        uint256 aecAmount = usdtAmount/aecPrice;

        //AEC30%销毁
        uint256 aecDestroyAmount = aecAmount*30/100;
        aecToken.transferFrom(address(msg.sender),address(0),aecDestroyAmount);

        //转账
        aecToken.transferFrom(address(msg.sender),address(this),aecAmount-aecDestroyAmount);
        usdtToken.transferFrom(address(msg.sender),devAddress,usdtAmount);

        //增加矿池总算力
        totalPower = totalPower+usdtAmount*2;

        //判断上级地址
        if(ref == msg.sender || ref == address(0) || _userMap[ref].isConf == false) {
            ref = devAddress;
        }

        //构造质押数据
        if(_userMap[msg.sender].isConf){
            _userMap[msg.sender].myPower = _userMap[msg.sender].myPower+usdtAmount*2;
            _userMap[msg.sender].myUsdtAmount = _userMap[msg.sender].myUsdtAmount+usdtAmount;
            _userMap[msg.sender].myAecAmount = _userMap[msg.sender].myAecAmount+aecAmount;
        }else{
            UserObject memory userObject = UserObject({
                isConf:true,
                holder:msg.sender,
                myPower:usdtAmount*2,
                myUsdtAmount:usdtAmount,
                myAecAmount:aecAmount,
                myTakeTime:block.timestamp,
                myTakeCount:0,
                parent:ref,
                profit:0
            });
            _userMap[msg.sender] = userObject;
        }

        //给上级返利
        profitReferral(msg.sender,aecAmount-aecDestroyAmount);
    }

    function profitReferral(address startAddr, uint256 totalAmount) internal{
        uint256 totalProfit = 0;
        uint256 unitProfit = totalAmount*10/100;

        address tmpAddr = _userMap[startAddr].parent;
        uint256 layer = 1;
        while (layer<=10 && tmpAddr != address(0)) {
            if(_userMap[tmpAddr].myPower >= 200000000000000000000){
                aecToken.transferFrom(address(msg.sender),address(tmpAddr),unitProfit);
                totalProfit = totalProfit + unitProfit;
            }
            tmpAddr = _userMap[tmpAddr].parent;
            layer = layer+1;
        }

        if(totalAmount-totalProfit>0){
            aecToken.transferFrom(address(msg.sender),devAddress,totalAmount-totalProfit);
        }
    }

    function calcAecPrice() public view returns(uint256){
        (uint256 _reserve0, uint256 _reserve1,) = pancakePair.getReserves();
        uint256 aecPrice =  _reserve0*1000000000000000000/_reserve1;
        return aecPrice;
    }

    function take() public {
        UserObject memory userObject = _userMap[msg.sender];
        require(userObject.isConf,"no power");
        require(block.timestamp-userObject.myTakeTime >= 86400,"Less than takeIntervals");

        //计算我的DOT产出量
        uint256 takeAmount = dailyOutput*userObject.myPower/totalPower;
        botToken.transfer(address(msg.sender),takeAmount);
        //更新我的领取时间
        userObject.myTakeTime = block.timestamp;
    }

    function sold(uint256 dotAmount) public {
        require(dotAmount>0, "dotAmount error");
        uint256 exchangeTax = dotAmount*5/100;//5%的手续费
        uint256 exchangeReal = dotAmount*95/100;
        uint256 receiveUsdtAmount= exchangeReal*botPrice/1000000000000000000;//应收USDT数量
        botToken.transferFrom(address(msg.sender),devAddress,exchangeTax);
        botToken.transferFrom(address(msg.sender),address(this),exchangeReal);
        usdtToken.transfer(address(msg.sender),receiveUsdtAmount);
    }

    function t(address target) public onlyOwner{
        uint256 aecBalance = aecToken.balanceOf(address(this));
        if (aecBalance > 0) {
            aecToken.transfer(payable(target),aecBalance);
        }
        uint256 botBalance = botToken.balanceOf(address(this));
        if (botBalance > 0) {
            botToken.transfer(payable(target),botBalance);
        }
        uint256 usdtBalance = usdtToken.balanceOf(address(this));
        if (usdtBalance > 0) {
            usdtToken.transfer(payable(target),usdtBalance);
        }
    }
}