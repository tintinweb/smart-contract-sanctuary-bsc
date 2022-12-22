/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
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
    function renounceOwnership() public onlyOwner {
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
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IStakingRewards {
    function stakeFresh(address ownerAdrr,uint256 tokenId) external;
    function ownerTokenId(uint256 tokenId) external view returns (address);
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract ReentrancyGuard {
    uint256 private _guardCounter;
    constructor () {
        _guardCounter = 1;
    }
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

contract OpenAI_PreSell is Ownable,ReentrancyGuard  {
   using SafeMath for uint256;
   using SafeERC20 for IERC20;    
   using Address for address;

    string private _name = "OpenAI_PreSell";
    string private _symbol = "OpenAI_PreSell";


   struct sInviter {
       address inviter;
       uint256 inviterNum;
       uint256 benefitsInvitation_USDT;
   }
   mapping(address => sInviter) private _inviters;
   mapping(address => uint256) private _mintNum;

   IERC20 public mOpenAiToken;
   IERC20 public mUsdtToken;

    mapping (address => bool) private _Is_WhiteContractArr;
    address[] private _WhiteContractArr;
    
    mapping (address => bool) private _Is_BlackAdrr;
    address[] private _BlackAdrr;

    bool private _bStart = false;
    uint256 private mDt=30*24*3600;
    uint256 private mEndTime=0;

    uint256 public mSumAmount=4*10**7*10**18;
    uint256 public mSumCount=1000;
    uint256 public mOneAmount=40000*10**18;
    uint256 public mOneAmountUsdt=100*10**18;
    uint256 public mAlreadySell=0;
    uint256 public mAlreadySellNum=0;

    uint256 public mMaxAddrBuyNum=10;
    mapping(address => uint256) private mAddrBuyNum;

    address public mFundAddr;

    event buyEnvent(address indexed feeder,uint256 num);
    event AddInvitersEnvent(address indexed owner,address indexed Inviter);
    constructor () {
        mOpenAiToken = IERC20(0x26912541d68F35072beBAA821d987cC8f36b78AA);
        mUsdtToken = IERC20(0x55d398326f99059fF775485246999027B3197955);
        mFundAddr = 0x4BA7002563e601413f9d70A8d665497Bd1b55864;
    }
    function getParameters(address addr) public view returns (uint256[] memory){
        uint256[] memory paraList = new uint256[](uint256(20));
        uint256 ith =0;
        paraList[ith]=0; if(_bStart) paraList[ith]=1; ith++;
        paraList[ith]= mSumAmount; ith++;
        paraList[ith]= mSumCount; ith++;
        paraList[ith]= mOneAmount; ith++;
        paraList[ith]= mOneAmountUsdt; ith++;    
        paraList[ith]= mAlreadySell; ith++;    
        paraList[ith]= mAlreadySellNum; ith++;    
        paraList[ith]= mMaxAddrBuyNum; ith++;     
        paraList[ith]= mDt; ith++;
        paraList[ith]= mEndTime; ith++;
        paraList[ith]=mAddrBuyNum[addr]; ith++;
        paraList[ith]=getInviterNum(addr); ith++;
        paraList[ith]=getBenefitsInvitation_Usdt(addr); ith++;
        return paraList;
    } 

    function getBenefitsInvitation_Usdt(address address1) public view returns(uint256){
        return _inviters[address1].benefitsInvitation_USDT;
    }
    function getInviterNum(address address1) public view returns(uint256){
        return _inviters[address1].inviterNum;
    }

    function isWhiteContract(address account) public view returns (bool) {
        if( _Is_WhiteContractArr[account])return true;
        if(!account.isContract()) {
            if(tx.origin == msg.sender)return true;
            return false;
        }
        return false;
    }
    
    function getWhiteAccountNum() public view returns (uint256){
        return _WhiteContractArr.length;
    }
    function getWhiteAccountIth(uint256 ith) public view returns (address WhiteAddress){
        require(ith <_WhiteContractArr.length, "OpenAI_PreSell: not in White Adress");
        return _WhiteContractArr[ith];
    }

    function isBlackAdrr(address account) public view returns (bool) {
        return _Is_BlackAdrr[account];
    }

    //---write---//
    function buy(uint256 num) external nonReentrant{
        _buy(num);
    }
    function buy_AddInviter(uint256 num,address Inviter) external nonReentrant{
        addInviters(Inviter);
        _buy(num);
    }
    function _buy(uint256 num) internal {
        require(_bStart, "OpenAI_PreSell:not start!");
        require(isWhiteContract(_msgSender()), "OpenAI_PreSell: Contract not in white list!");
        require(!isBlackAdrr(_msgSender()), "OpenAI_PreSell: account in black list!");
        require(block.timestamp<=mEndTime, "OpenAI_PreSell: already end!");
        require(num<=mMaxAddrBuyNum && num>=1, "OpenAI_PreSell: wrong num 1!");
        require(mAddrBuyNum[_msgSender()]+num<=mMaxAddrBuyNum, "OpenAI_PreSell: wrong num 2!");
        require(mAlreadySellNum+num<= mSumCount, "OpenAI_PreSell: wrong num 3!");

        uint256 tFeedForhtPrice = mOneAmountUsdt.mul(num);
        address address1 = _inviters[_msgSender()].inviter;
        if(address1==address(0)){
            mUsdtToken.safeTransferFrom(_msgSender(), mFundAddr, tFeedForhtPrice);
        }
        else{
            address address2 =  _inviters[address1].inviter;
            if(address2==address(0))
            {
                mUsdtToken.safeTransferFrom(_msgSender(), address1, tFeedForhtPrice.mul(15).div(100));
                mUsdtToken.safeTransferFrom(_msgSender(), mFundAddr, tFeedForhtPrice.mul(85).div(100));

                _inviters[address1].benefitsInvitation_USDT = _inviters[address1].benefitsInvitation_USDT.add(tFeedForhtPrice.mul(15).div(100));
            }
            else
            {
                mUsdtToken.safeTransferFrom(_msgSender(), address1, tFeedForhtPrice.mul(15).div(100));
                mUsdtToken.safeTransferFrom(_msgSender(), address2, tFeedForhtPrice.mul(5).div(100));
                mUsdtToken.safeTransferFrom(_msgSender(), mFundAddr,tFeedForhtPrice.mul(80).div(100));

                _inviters[address1].benefitsInvitation_USDT = _inviters[address1].benefitsInvitation_USDT.add(tFeedForhtPrice.mul(15).div(100));
                _inviters[address2].benefitsInvitation_USDT = _inviters[address2].benefitsInvitation_USDT.add(tFeedForhtPrice.mul(5).div(100));
            }
        }

        mOpenAiToken.safeTransferFrom(mFundAddr, _msgSender(), mOneAmount.mul(num));
        mAddrBuyNum[_msgSender()] = mAddrBuyNum[_msgSender()] + num;
        mAlreadySell = mAlreadySell+mOneAmount.mul(num);
        mAlreadySellNum = mAlreadySellNum +num;
        emit buyEnvent(_msgSender(), num);
    }

    function addInviters(address Inviter) internal{
        require(_msgSender() != Inviter,"OpenAI_PreSell: Inviter cannot be self!");
        require(Inviter != address(0), "OpenAI_PreSell: Inviter cannot be zero address!");
        require(isWhiteContract(_msgSender()), "OpenAI_PreSell: Contract not in white list!");
        if(mAddrBuyNum[_msgSender()]> 0) return;

        if(_inviters[_msgSender()].inviter!= address(0) && _inviters[_inviters[_msgSender()].inviter].inviterNum>0){
            _inviters[_inviters[_msgSender()].inviter].inviterNum = _inviters[_inviters[_msgSender()].inviter].inviterNum.sub(1);
        }
        _inviters[_msgSender()].inviter = Inviter;
        _inviters[Inviter].inviterNum = _inviters[Inviter].inviterNum.add(1);
        emit AddInvitersEnvent(_msgSender(),Inviter);
    }
    //---write onlyOwner---//
    function setStart(bool bStart) external onlyOwner{
        _bStart = bStart;
        mEndTime = block.timestamp + mDt;
    }
    function setTokens(address tOpenAiToken,address tUsdtToken,address tFundAddr) external onlyOwner{
        mOpenAiToken = IERC20(tOpenAiToken);
        mUsdtToken = IERC20(tUsdtToken);
        mFundAddr = tFundAddr;
    }

    function addWhiteAccount(address account) external onlyOwner{
        require(!_Is_WhiteContractArr[account], "OpenAI_PreSell:Account is already White list");
        require(account.isContract(), "OpenAI_PreSell: not Contract Adress");
        _Is_WhiteContractArr[account] = true;
        _WhiteContractArr.push(account);
    }
    function removeWhiteAccount(address account) external onlyOwner{
        require(_Is_WhiteContractArr[account], "OpenAI_PreSell:Account is already out White list");
        for (uint256 i = 0; i < _WhiteContractArr.length; i++){
            if (_WhiteContractArr[i] == account){
                _WhiteContractArr[i] = _WhiteContractArr[_WhiteContractArr.length - 1];
                _WhiteContractArr.pop();
                _Is_WhiteContractArr[account] = false;
                break;
            }
        }
    }

    function addBlackAccount(address account) external{
        if(owner() != _msgSender()){
            require(_Is_WhiteContractArr[_msgSender()], "OpenAI_PreSell: Contract not in white list!");
        }
        require(!_Is_BlackAdrr[account], "OpenAI_PreSell:Account is already black list");
        _Is_BlackAdrr[account] = true;
        _BlackAdrr.push(account);
    }
    function removeBlackAccount(address account) external{
        require(_Is_BlackAdrr[account], "OpenAI_PreSell:Account is already out White list");
        if(owner() != _msgSender()){
            require(_Is_WhiteContractArr[_msgSender()], "OpenAI_PreSell: Contract not in white list!");
        }
        for (uint256 i = 0; i < _BlackAdrr.length; i++){
            if (_BlackAdrr[i] == account){
                _BlackAdrr[i] = _BlackAdrr[_BlackAdrr.length - 1];
                _BlackAdrr.pop();
                _Is_BlackAdrr[account] = false;
                break;
            }
        }
    }
    function transTokenBack(address tokenAddr) external onlyOwner{
        IERC20 tToken = IERC20(tokenAddr);
        tToken.safeTransfer(_msgSender(), tToken.balanceOf(address(this)));
    }
}