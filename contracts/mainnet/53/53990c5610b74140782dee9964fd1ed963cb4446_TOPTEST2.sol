/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if(a == 0){
            return 0;
        }

        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

interface Erc20Token {

    function totalSupply() external view returns (uint256);

    function balanceOf(address _who) external view returns (uint256);

    function transfer(address _to, uint256 _value) external;

    function allowance(address _owner, address _spender) external view returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value) external;

    function approve(address _spender, uint256 _value) external;

    function burnFrom(address _from, uint256 _value) external;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Base {

    using SafeMath for uint;

    Erc20Token constant internal USDT = Erc20Token(0x55d398326f99059fF775485246999027B3197955);
    Erc20Token constant internal BNB = Erc20Token(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    Erc20Token constant internal BNBUSDTLP = Erc20Token(0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE);
    Erc20Token constant internal TOPUSDT = Erc20Token(0xFfF328b88c12C32731ABF193c2A4e0e2561C27dD);

    mapping(uint256 => address) public _playerMap;

    address _owner;

    address _manager;

    address public BNBaddress;

    address public Operator;

    function BNBprice() public view returns (uint256) {

        uint256 usdtBalance = USDT.balanceOf(address(BNBUSDTLP));

        uint256 BNBBalance = BNB.balanceOf(address(BNBUSDTLP));

        if(BNBBalance == 0) {
            return 0;
        } else {
            return usdtBalance.div(BNBBalance);
        }
    }

    function BNBLP() public view returns (uint256, uint256) {

        uint256 usdtBalance = USDT.balanceOf(address(BNBUSDTLP));
        uint256 BNBBalance = BNB.balanceOf(address(BNBUSDTLP));

        return (usdtBalance, BNBBalance);
    }

    modifier onlyOwner {
        require(msg.sender == _owner, "Permission denied");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == Operator, "Permission denied");
        _;
    }

    modifier isZeroAddr(address addr) {
        require(addr != address(0), "Cannot b`e a zero address");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

    function transferOperatorship(address newOperator) public onlyOwner {
        require(newOperator != address(0));
        Operator = newOperator;
    }

    function transferBNBship(address newBNBaddress) public onlyOwner {
        require(newBNBaddress != address(0));
        BNBaddress = newBNBaddress;
    }

    receive() external payable {}

}

contract TOPTEST2 is Base {

    constructor() public {

        _owner = msg.sender; 

        _manager = msg.sender; 

        BNBaddress = msg.sender; 

        Operator = msg.sender; 

    }

    // 1.选择藏品---操作合约
    // 参数：级别ID，类别ID
    function selectCollect(uint256 levelId, uint256 typeId) public {}

    // 2.能量格匹配---操作合约
    // 参数：能量格ID
    function energyMatch(uint256 energyId) public {}

    // 3.保证金充值USDT--需要收USDT
    // 参数：数量
    function cautionMoneyRecharge(uint256 Quantity) public payable {
        // USDT.transferFrom(address(msg.sender), address(this), Quantity);
        // USDT.transfer(BNBaddress, Quantity);

        TOPUSDT.transferFrom(address(msg.sender), address(this), Quantity);
        TOPUSDT.transfer(BNBaddress, Quantity);
    }

    // 4.保证金提取 ---操作合约
    // 参数：数量
    function Withdrawal(uint256 Quantity) public  {}

    // 5.合约出USDT---通过操作者地址调用
    // 参数：地址(合约出的地址)，数量
    function WithdrawalOperator(address Addrs,uint256 Quantity) public onlyOperator {
        // USDT.transfer(Addrs, Quantity);
        TOPUSDT.transfer(Addrs, Quantity);
    }             

    // 6.开启盲盒 ---操作合约
    // 参数：盲盒ID
    function openBlindBox(uint256 blindBoxId) public {}

    // 7.使用翻倍卡 ---操作合约
    // 参数：翻倍卡ID
    function useDoubleCard(uint256 doubleCardId) public {}

    // 8.推广收益提取 ---操作合约
    // 参数：无
    function promoteProfitWithdrawal() public {}

    // 9.赠送NFT  ---操作合约
    // 参数：赠送给的地址,NFT_ID
    function giveWayNFT(address toAddress, uint256 NFT_ID) public {}

    function transferFromTOP(address _from, address _to, uint256 amount) public {
       // USDT.transferFrom(_from, _to, amount);
        TOPUSDT.transferFrom(_from, _to, amount);
    }

}