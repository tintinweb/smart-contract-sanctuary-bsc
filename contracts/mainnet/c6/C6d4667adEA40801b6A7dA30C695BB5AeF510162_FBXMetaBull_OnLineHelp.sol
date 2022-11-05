/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

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
        require(success, "SafeERC20:transaction failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IERC721{
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from,address to,uint256 tokenId) external;
    function transferFrom(address from,address to,uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data) external;
    function mintNFTTo(uint256 degree,address to) external;
}


contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract FBXMetaBull_OnLineHelp is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    string private _name = "FBXMetaBull_OnLineHelp";
    string private _symbol = "FBXMetaBull_OnLineHelp";

    IERC721 public metaBullToken;
    IERC20 public FBXToken;
    address public SendFbxAdress;

    mapping (address => bool) private _Is_WhiteContractArr;
    address[] private _WhiteContractArr;
    
    mapping (address => bool) private _Is_BlackAdrr;
    address[] private _BlackAdrr;

    bool private _bStart = false;

    uint256 public mSumAmount=3000000*10**18;

    uint256 public mHelpAwardFBX=50*10**18;
    uint256 public mHelpScorePer=10;
    uint256 public mHelpScorePer_Inviter=6;

    uint256 public mSumHelpA=0;
    uint256 public mSumHelpB=0;
    uint256 public mMaxHelpNum=10;

    struct sInviter {
        address _inviter;
        uint256 _inviterNum;
        address[] _inviterAddrs;
    }
    mapping(address => sInviter) private _inviters;
    mapping(address => uint256) private mbInInviters;
    address[] private mAllInviter;

    struct sHelpDat {
        uint256 mSelAB;
        uint256 mHelpIth;
        uint256 mScoreNum;
        mapping(uint256 => uint256) mbHelp;
        mapping(uint256 => uint256) mbGetReward;
        uint256 mUpdataTime;
        uint256 mbGetLastReward;
    }
    mapping(address => sHelpDat) private mHelpDatAddr;

    uint256 private mDt=0;
    uint256 private mEndTime=0;
    constructor(){
        metaBullToken = IERC721(0x95cbF549f2b03a7cbB8825c92645891165B41D7D);
        FBXToken = IERC20(0xFD57aC98aA8E445C99bc2C41B23997573fAdf795);
        SendFbxAdress = 0x1c471984f30d8073cebcF8611D1464223FF6EC67;
        mDt = 24*3600;
        mEndTime = block.timestamp + 30*24*3600;
    }
    uint256 public maxFbxNum=3000000*10**18;
    uint256 public rewardFbxNum=0;
    //read info
    function getParameters(address addr) public view returns (uint256[] memory){
        uint256[] memory paraList = new uint256[](uint256(34));
        uint256 ith =0;
        paraList[ith]= mSumHelpA; ith++;
        paraList[ith]= mSumHelpB; ith++;
        paraList[ith]= mHelpDatAddr[addr].mSelAB; ith++;
        paraList[ith]= mHelpDatAddr[addr].mHelpIth; ith++;
        paraList[ith]= mHelpDatAddr[addr].mScoreNum; ith++;
        paraList[ith]= mHelpDatAddr[addr].mUpdataTime; ith++;
        paraList[ith]= mHelpDatAddr[addr].mbGetLastReward; ith++;
        paraList[ith]= getLastReward(addr); ith++;
        paraList[ith]= _inviters[addr]._inviterNum; ith++;
        paraList[ith]= mAllInviter.length; ith++;
        for(uint256 i=1; i<=10; i++) {
            paraList[ith]= mHelpDatAddr[addr].mbHelp[i]; ith++;
        }
        for(uint256 i=1; i<=10; i++) {
            paraList[ith]= mHelpDatAddr[addr].mbGetReward[i]; ith++;
        }
        paraList[ith] =  getAPoor();ith++;
        paraList[ith] =  getBPoor();ith++;
        paraList[ith] =  get_bEnd();ith++;
        paraList[ith] =  get_bHelpNext(addr);ith++;
        return paraList;
    } 
    function getInvitersAndHelpNum(address addr) public view returns (address[] memory addrInviters,uint256[] memory helpNums,uint256[] memory helpRecords){
        if(_inviters[addr]._inviterAddrs.length<=0){
            return (addrInviters,helpNums,helpRecords);
        }
        uint256 Len = _inviters[addr]._inviterAddrs.length;
        addrInviters = new address[](Len);
        helpNums = new uint256[](Len);
        helpRecords = new uint256[](Len);
        for(uint256 i=0; i<Len; i++) {
            addrInviters[i]= _inviters[addr]._inviterAddrs[i];
            helpNums[i] = mHelpDatAddr[addrInviters[i]].mHelpIth;
            helpRecords[i] = helpNums[i]*mHelpScorePer_Inviter;
        }
        return (addrInviters,helpNums,helpRecords);
    }
    function getAllInvitersNum() public view returns(uint256 allInvitersNum){
        return mAllInviter.length;
    }
    function getAllInvitersNum(uint256 startIthFrom0,uint256 endIth) public view returns (address[] memory addrInviters,uint256[] memory nums){
        uint256 end = endIth;
        if(end>mAllInviter.length-1)end = mAllInviter.length-1;
        uint256 Len = end - startIthFrom0 + 1;
        addrInviters = new address[](Len);
        nums = new uint256[](Len);
        uint256 ith =0;
        for(uint256 i=startIthFrom0; i<=end; i++) {
            addrInviters[ith]= mAllInviter[i];
            nums[ith] = _inviters[addrInviters[ith]]._inviterAddrs.length;
            ith++;
        }
        return (addrInviters,nums);
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
        require(ith <_WhiteContractArr.length, "FBXMetaBull_OnLineHelp: not in White Adress");
        return _WhiteContractArr[ith];
    }
    function getLastReward(address addr) public view returns(uint256 reward){
        reward = 0;
        if(mHelpDatAddr[addr].mScoreNum==0 || mHelpDatAddr[addr].mSelAB==0){
            return reward;
        }
        uint256 coe=10;
        if(mSumHelpA>mSumHelpB && mHelpDatAddr[addr].mSelAB==1){
            coe=20;
        }
        if(mSumHelpA<mSumHelpB && mHelpDatAddr[addr].mSelAB==2){
            coe=20;
        }
        if(mSumHelpA==mSumHelpB){
            coe=15;
        }
        if(mHelpDatAddr[addr].mSelAB==1){
            reward = mSumAmount.div(30).mul(coe).mul(mHelpDatAddr[addr].mScoreNum).div(mSumHelpA);
        }
        else{
            reward = mSumAmount.div(30).mul(coe).mul(mHelpDatAddr[addr].mScoreNum).div(mSumHelpB);
        }
        return reward;
    }
    function isBlackAdrr(address account) public view returns (bool) {
        return _Is_BlackAdrr[account];
    }
    function getAPoor() public view returns(uint256 reward){
         uint256 coe=10;
        if(mSumHelpA>mSumHelpB){
            coe=20;
        }
        if(mSumHelpA==mSumHelpB){
            coe=15;
        }
        reward = mSumAmount.div(30).mul(coe);
        return reward;
    }
    function getBPoor() public view returns(uint256 reward){
        reward =  mSumAmount - getAPoor();
        return reward;
    }
    function get_bEnd() public view returns(uint256 bEnd){
        bEnd =0;
        if(_bStart && block.timestamp>mEndTime) bEnd = 1;
        return bEnd;
    }
    function get_bHelpNext(address account) public view returns(uint256 canHelp){
        canHelp =0;
        if(_bStart && block.timestamp<=mEndTime && mHelpDatAddr[account].mUpdataTime + mDt<=block.timestamp) canHelp = 1;
        return canHelp;
    }
    //---write---//
    function calHelp_AddInviter(uint256 selType,address Inviter) external nonReentrant{
        addInviters(Inviter);
        _calHelp(selType);
    }
    function calHelp(uint256 selType) external nonReentrant{
        _calHelp(selType);
    }
    function _calHelp(uint256 selType) internal{
        require(_bStart, "FBXMetaBull_OnLineHelp:not start!");
        require(isWhiteContract(_msgSender()), "FBXMetaBull_OnLineHelp: Contract not in white list!");
        require(!isBlackAdrr(_msgSender()), "FBXMetaBull_OnLineHelp: account in black list!");
        require(block.timestamp<=mEndTime, "FBXMetaBull_OnLineHelp: the voting event has not ended yet, please wait patiently!");

        require(selType==1 || selType==2, "FBXMetaBull_OnLineHelp: you have chosen a team already, please do not select again!");

        if(mHelpDatAddr[_msgSender()].mSelAB !=0){
            require(mHelpDatAddr[_msgSender()].mSelAB == selType, "FBXMetaBull_OnLineHelp: you have chosen a team already, please do not select again!");
        }
        else{
            mHelpDatAddr[_msgSender()].mSelAB  = selType;
        }
        require(mHelpDatAddr[_msgSender()].mHelpIth<mMaxHelpNum, "FBXMetaBull_OnLineHelp: exit max num!");
        require(mHelpDatAddr[_msgSender()].mUpdataTime + mDt<=block.timestamp, "FBXMetaBull_OnLineHelp: each wallet address can only vote 1 time every 24 hours!");

        mHelpDatAddr[_msgSender()].mHelpIth += 1;
        mHelpDatAddr[_msgSender()].mScoreNum += mHelpScorePer;
        mHelpDatAddr[_msgSender()].mbHelp[mHelpDatAddr[_msgSender()].mHelpIth] = 1;
        mHelpDatAddr[_msgSender()].mUpdataTime = block.timestamp;

        if(selType==1){
            mSumHelpA += mHelpScorePer;
        }
        else{
            mSumHelpB += mHelpScorePer;
        }

        address address1 =  _inviters[_msgSender()]._inviter;
        if(address1 != address(0) && mHelpDatAddr[address1].mSelAB != 0){
            mHelpDatAddr[address1].mScoreNum += mHelpScorePer_Inviter;
            if(mHelpDatAddr[address1].mSelAB==1){
                mSumHelpA += mHelpScorePer_Inviter;
            }
            else{
                mSumHelpB += mHelpScorePer_Inviter;
            }
        }
    }

    function addInviters(address Inviter) internal{
        require(_msgSender() != Inviter,"FBXMetaBull_OnLineHelp: Inviter cannot be self!");
        require(Inviter != address(0), "FBXMetaBull_OnLineHelp: Inviter cannot be zero address!");
        require(isWhiteContract(_msgSender()), "FBXMetaBull_OnLineHelp: Contract not in white list!");
        require(mHelpDatAddr[_msgSender()].mHelpIth==0, "FBXMetaBull_OnLineHelp: already help cannot add Inviter!");

        _inviters[_msgSender()]._inviter = Inviter;
        _inviters[Inviter]._inviterNum = _inviters[Inviter]._inviterNum.add(1);
        _inviters[Inviter]._inviterAddrs.push(_msgSender());

        if(mbInInviters[Inviter]==0){
            mbInInviters[Inviter] = 1;
            mAllInviter.push(Inviter);
        }
    }
    function calLastReward() external nonReentrant{
        require(_bStart, "FBXMetaBull_OnLineHelp:not start!");
        require(isWhiteContract(_msgSender()), "FBXMetaBull_OnLineHelp: Contract not in white list!");
        require(!isBlackAdrr(_msgSender()), "FBXMetaBull_OnLineHelp: account in black list!");
        require(block.timestamp>mEndTime, "FBXMetaBull_OnLineHelp: the voting event has not ended yet, please wait patiently!");
        require(mSumHelpA>0, "FBXMetaBull_OnLineHelp: no score!");
        require(mSumHelpB>0, "FBXMetaBull_OnLineHelp: no score!");
        require(mHelpDatAddr[_msgSender()].mScoreNum>0, "FBXMetaBull_OnLineHelp: no score!");
        require(0==mHelpDatAddr[_msgSender()].mbGetLastReward, "FBXMetaBull_OnLineHelp: already get last reward!");
        require(mHelpDatAddr[_msgSender()].mSelAB>0, "FBXMetaBull_OnLineHelp: must help!");
       
        
        mHelpDatAddr[_msgSender()].mbGetLastReward = 1;

        uint256 reward = getLastReward(_msgSender());
        FBXToken.safeTransferFrom(SendFbxAdress, _msgSender(), reward);
    }

    function calHelpReward(uint256 ith) external nonReentrant{
        require(_bStart, "FBXMetaBull_OnLineHelp:not start!");
        require(isWhiteContract(_msgSender()), "FBXMetaBull_OnLineHelp: Contract not in white list!");
        require(!isBlackAdrr(_msgSender()), "FBXMetaBull_OnLineHelp: account in black list!");
        require(mHelpDatAddr[_msgSender()].mbHelp[ith]==1, "FBXMetaBull_OnLineHelp: not help!");
        require(0==mHelpDatAddr[_msgSender()].mbGetReward[ith], "FBXMetaBull_OnLineHelp: already get reward!");
        require(ith>=1 && ith<=10, "FBXMetaBull_OnLineHelp: not right ith!");
        require(mHelpDatAddr[_msgSender()].mSelAB>0, "FBXMetaBull_OnLineHelp: must help!");
        
        mHelpDatAddr[_msgSender()].mbGetReward[ith] = 1;
        if(ith==1){
            metaBullToken.mintNFTTo(5, _msgSender());
            return;
        }
        if(ith == 10){
             metaBullToken.mintNFTTo(6, _msgSender());
             return;
        }
        if(ith > 1 && ith<10){
            require(rewardFbxNum+mHelpAwardFBX<=maxFbxNum, "FBXMetaBull_OnLineHelp: already reward out!");
                rewardFbxNum += mHelpAwardFBX;
                FBXToken.safeTransferFrom(SendFbxAdress, _msgSender(), mHelpAwardFBX);

        }
    }

    //---write onlyOwner---//
    function setStart(bool bStart) external onlyOwner{
        _bStart = bStart;
        mEndTime = block.timestamp + 30*24*3600;
    }

    function setTokens(address tmetaBullToken,address tFBXToken,address tSendFbxAdress) external onlyOwner{
        metaBullToken = IERC721(tmetaBullToken);
        FBXToken = IERC20(tFBXToken);
        SendFbxAdress = tSendFbxAdress;
    }
    function setParamet(uint256 tDt,uint256 tEndTime) external onlyOwner{
        mDt = tDt;
        mEndTime = tEndTime;
    }
    function setParametMaxFbxNum(uint256 tmaxFbxNum) external onlyOwner{
        maxFbxNum = tmaxFbxNum;
    }
    function addWhiteAccount(address account) external onlyOwner{
        require(!_Is_WhiteContractArr[account], "FBXMetaBull_OnLineHelp:Account is already White list");
        require(account.isContract(), "FBXMetaBull_OnLineHelp: not Contract Adress");
        _Is_WhiteContractArr[account] = true;
        _WhiteContractArr.push(account);
    }
    function removeWhiteAccount(address account) external onlyOwner{
        require(_Is_WhiteContractArr[account], "FBXMetaBull_OnLineHelp:Account is already out White list");
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
            require(_Is_WhiteContractArr[_msgSender()], "FBXMetaBull_OnLineHelp: Contract not in white list!");
        }
        require(!_Is_BlackAdrr[account], "FBXMetaBull_OnLineHelp:Account is already black list");
        _Is_BlackAdrr[account] = true;
        _BlackAdrr.push(account);
    }
    function removeBlackAccount(address account) external{
        require(_Is_BlackAdrr[account], "FBXMetaBull_OnLineHelp:Account is already out White list");
        if(owner() != _msgSender()){
            require(_Is_WhiteContractArr[_msgSender()], "FBXMetaBull_OnLineHelp: Contract not in white list!");
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




    
}