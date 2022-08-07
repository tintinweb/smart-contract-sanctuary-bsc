/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IToken {
    function bindInvitor(address account, address invitor) external;

    function _inviter(address account) external view returns (address);

    function getBinderLength(address account) external view returns (uint256);

    function _binders(address account, uint256 index) external view returns (address);
}

interface INFT {
    function batchMint(address to, uint256 property, uint256 num) external;
}

contract HYPresale is Ownable {
    using SafeMath for uint256;
    struct UserInfo {
        //买入的数量
        uint256 buyToken;
        //邀请释放的代币
        uint256 inviteReleaseToken;
        //已领取代币
        uint256 claimedToken;
        //预售有效用户
        uint256 saleInviteAccount;

        uint256 claimTime;
        //是否领取NFT
        bool ZSNFT;
        //是否已领取高级NFT
        bool ZZNFT;

        uint256 nextTime;
    }

    //usdt合约地址
    address private _usdtAddress;
    //代币合约地址
    address private _tokenAddress;
    //收款地址
    address public _cash;

    bool public _freeNFT;
    uint256 public _inviteFee = 10;
    mapping(address => UserInfo) private _userInfo;
    //用户列表
    address[] private userList;
    mapping(address => bool) private getFree;

   
    bool public _pauseBuy;
    bool public _endSale;
    bool public _pauseClaim = true;

    uint256 public HYPrice;

    mapping(address => address) public invitors;

    mapping(uint256 => uint256) public NFTPrice;

    //邀请购买释放比例
    uint256 public _inviteReleaseRate = 10;


    uint256 public claimTime = 6;

    uint256 public minUSDT;
    uint256 public maxUSDT;
    uint256 public tokenUnit;
    uint256 public usdtUnit;
    uint256 public claimPerid;

    

    INFT public _nft;

    uint256 public selled;

    constructor(
        address USDTAddress, address TokenAddress, address NFTAddress,
        address CashAddress
    ){
        _usdtAddress = USDTAddress;
        _tokenAddress = TokenAddress;
        _nft = INFT(NFTAddress);
        _cash = CashAddress;

         usdtUnit = 10 ** IERC20(USDTAddress).decimals();
        maxUSDT= 200*usdtUnit;
        minUSDT = 5*usdtUnit;
        HYPrice = 5;
        tokenUnit =  10 ** IERC20(TokenAddress).decimals();
    }

    function buy(uint256 amount) external {
        //暂停购买
        require(!_pauseBuy, "pauseBuy");
        //已经停止预售
        require(!_endSale, "endSale");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        //必须满足最小额度
        require(amount >= minUSDT, "min error");
        require(amount <= maxUSDT, "max error");
        address invitor = invitors[account];
        //第一次购买，加入地址列表
        uint256 TokenAmount = amount.mul(HYPrice).mul(tokenUnit).div(usdtUnit); 
        if (address(0) == invitor) {
            userList.push(account);
            invitor = _cash;
        }
            if (invitor!=_cash) {
                UserInfo storage invitorInfo = _userInfo[invitor];
                uint256 intitorNum = invitorInfo.saleInviteAccount;
                if(intitorNum>=10 && !invitorInfo.ZZNFT){
                    _nft.batchMint(invitor, 2, 1);
                    invitorInfo.ZSNFT = true;
                }
                if(intitorNum>=40 && !invitorInfo.ZZNFT){
                    _nft.batchMint(invitor, 3, 1);
                    invitorInfo.ZZNFT = true;
                }
                invitorInfo.inviteReleaseToken += TokenAmount.mul(_inviteReleaseRate).div(100);
            
        }
        uint256 targetAmount = amount.mul(_inviteFee).div(100);
                
        if(targetAmount>0){
            address cur = msg.sender;
            for (int256 i = 0; i < 2; i++) {
            uint256 rate;
            if(i == 0) {
                rate = 70;
            }
            if(i == 1) {
                rate = 30;
            }
           
            cur = invitors[cur];
            if (cur == address(0)) {
                _takeUSDT(_usdtAddress,account , _cash, targetAmount.mul(rate).div(100));
                
            }else{
                _takeUSDT(_usdtAddress,account, cur, targetAmount.mul(rate).div(100));
            }   
                }
            }
        //增加地址购买数量
        userInfo.buyToken += TokenAmount;
        selled += TokenAmount;
 
        //扣 usdt
        _takeToken(_usdtAddress, account, amount-targetAmount);

        userInfo.nextTime = block.timestamp+claimPerid;
    }

   

    
    //领取预售释放的代币
    function claimToken() external {
        require(!_pauseClaim,"can not claim");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        require(block.timestamp > userInfo.nextTime, "error time");
        uint256 pendingToken = getPendingToken(account);
        _userInfo[account].claimedToken += pendingToken;
        userInfo.claimTime += 1;
        _giveToken(_tokenAddress, account, pendingToken);
    }


    //领取预售释放的代币
    function buyNFT(uint256 count,uint256 mode) external {
        require(count > 0,"count error");
        address account = msg.sender;
        uint256 price = NFTPrice[mode];
        uint256 amount = count.mul(price);
        _takeToken(_usdtAddress, account, amount);
        _nft.batchMint(account, mode, count); 
    }

    //领取免费黄金NFT
    function getFreeNFT() external {
        require(_freeNFT,"can not get");
        address account = msg.sender;
        address invitor = invitors[msg.sender];
        require(!getFree[account],"can not get");
        require(invitor != address(0),"not bind");
        _nft.batchMint(account, 1, 1); 
        getFree[account] = true;
    }
    function bindInvitor(address account) public {
        address invitor = invitors[msg.sender];
        require(invitor == address(0),"had bind");
        invitors[msg.sender] = account;
    }
    //待领取的已释放的代币
    function getPendingToken(address account) public view returns (uint256){
        UserInfo storage userInfo = _userInfo[account];
        uint256 leftclaimNum = claimTime.sub(userInfo.claimTime);
        uint256 amount = (userInfo.buyToken).sub(userInfo.claimedToken);
        if(leftclaimNum <= 0){
            return 0;
        }
        uint256 targetAmount = amount.div(leftclaimNum).add(userInfo.inviteReleaseToken);
        if(targetAmount>amount){
            targetAmount = amount;
        }
        return targetAmount;
    }

    function _giveToken(address tokenAddress, address account, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) > tokenNum, "shop token balance not enough");
        token.transfer(account, tokenNum);
    }

    function _takeToken(address tokenAddress, address account, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(account)) > tokenNum, "token balance not enough");
        token.transferFrom(account, address(this), tokenNum);
    }

    function _takeUSDT(address tokenAddress, address from,address to, uint256 tokenNum) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(from)) > tokenNum, "token balance not enough");
        token.transferFrom(from, to, tokenNum);
    }

    //设置NFT价格
    function setNFTPrice(uint256 mode,uint256 price) external onlyOwner {
        uint256 Price = price*usdtUnit;
        NFTPrice[mode] = Price;
    }
    //设置领取间隔时间
    function setPerid(uint256 perid) external onlyOwner {
        claimPerid = perid;
    }
    //设置HYPrice 1U= ?
    function setHYPrice(uint256 count) external onlyOwner {
        HYPrice = count;
    }



    

    


    //暂停购买
    function setPauseBuy(bool pause) external onlyOwner {
        _pauseBuy = pause;
    }

    //暂停购买
    function setFreeNFT(bool free) external onlyOwner {
        _freeNFT = free;
    }

    //结束预售
    function endSale() external onlyOwner {
        _endSale = true;
    }

    //暂停提币
    function setPauseClaim(bool pause) external onlyOwner {
        _pauseClaim = pause;
    }

    



    

    //修改最小额度
    function setMin(uint256 _min) external onlyOwner {
        minUSDT = _min * 10 ** IERC20(_usdtAddress).decimals();
    }

    //修改最大额度
    function setMax(uint256 max) external onlyOwner {
        maxUSDT = max * 10 ** IERC20(_usdtAddress).decimals();
    }
    //设置邀请奖励USDT额度
    function setInviteFee(uint256 fee) external onlyOwner {
        _inviteFee = fee;
    }
    //设置邀请释放Token额度
    function setInviteReleaseRate(uint256 inviteReleaseRate) external onlyOwner {
        _inviteReleaseRate = inviteReleaseRate;
    }

    function setTokenAddress(address adr) external onlyOwner {
        _tokenAddress = adr;
    }

    function setUSDTAddress(address adr) external onlyOwner {
        _usdtAddress = adr;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || _cash == msg.sender, "!Funder");
        _;
    }

    function setCash(address cash) external onlyFunder {
        _cash = cash;
    }

    function claimBalance(address to, uint256 amount) external onlyFunder {
        payable(to).transfer(amount);
    }

    function claimToken(address token, address to, uint256 amount) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

   

    

    function getUserListLength() external view returns (uint256){
        return userList.length;
    }

    function getUserInfo(address account) external view returns ( UserInfo memory){
        UserInfo memory userInfo = _userInfo[account];
        return userInfo;
    }
}