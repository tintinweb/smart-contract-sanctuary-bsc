/**
 *Submitted for verification at BscScan.com on 2022-04-30
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
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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

library Math {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

// Inheritancea
interface IStakingRewards {
    // Views
    function lastTimeRewardApplicable() external view returns (uint256);
    function rewardPerToken() external view returns (uint256);
    function earned(address account) external view returns (uint256);
    function getRewardForDuration() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);

    // Mutative
    function writeComment(string calldata str,uint256 score,bool bPraise,uint256 hamID) external;
    function getReward() external;
    // EVENTS
    event WriteComment(address indexed user, uint256 amount,uint256 score,bool bPraise,uint256 hamID);
    event RewardAdded(uint256 reward);
    event RewardPaid(address indexed user, uint256 reward);
}
interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function getValueByTokenId(uint256 tokenId) external view returns(uint256);
}

interface IStakingRewardNFT {
    function balanceOf(address account) external view returns (uint256);
    function ownerTokenId(uint256 tokenId) external view returns (address);
}

contract CommentManage_StakingRewards is IStakingRewards, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    IERC721 public NFT_Token;
    IStakingRewardNFT public DeFi_Token;

    string private _name = "CommentManage DeFi";
    string private _symbol = "CM DeFi";

    IERC20 public rewardsToken;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration = 30 days;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public totalReward;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    uint256 public totalRewardAlready;

    mapping (address => bool) private _Is_WhiteContractArr;
    address[] private _WhiteContractArr;
    uint256 public basicDailyReward=33333;

    struct sCommentPropertys {
        uint256 id;
        address addr;
        uint256 score;
        string str;
        bool bPraise;
        uint256 updataTime;
    }
    uint256 private _sumCount=0;
    uint256 private _praiseNum;
    uint256 private _sumScore;

    mapping(uint256 => sCommentPropertys) private _CommentPropertys;
    mapping(address => bool) private _bHaveComment;
    mapping(uint256 => bool) private _bCommentHamId;
    mapping(address => uint256) private _CommentIth;

    constructor(){
        NFT_Token = IERC721(0x1F599A0281d024bfeF7e198bDae78B49A6e87049);
        DeFi_Token = IStakingRewardNFT(0x55F2856706872F69E8CfC00C2abDf2d4adf6aE50);
        rewardsToken = IERC20(0xFD57aC98aA8E445C99bc2C41B23997573fAdf795);
        rewardsDuration = 30 days;
    }
    
    /* ========== VIEWS ========== */
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function totalRewardYet() external view returns (uint256) {
        return totalReward.sub(periodFinish.sub(lastTimeRewardApplicable()).mul(rewardRate));
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256){
        if (_totalSupply == 0){
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored.add(
          lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply)
          );
    }

    function earned(address account) public view returns (uint256) {
        return _balances[account].mul(
          rewardPerToken().sub(userRewardPerTokenPaid[account])
        ).div(1e18).add(rewards[account]);
    }

    function getRewardForDuration() external view returns (uint256) {
        return rewardRate.mul(rewardsDuration);
    }

    function getRewardPerDay() external view returns (uint256) {
        return rewardRate.mul(86400);
    }

    function getRewardPerDayPerToken() external view returns (uint256) {
        return rewardRate.mul(86400).mul(1e18).div(_totalSupply);
    }

    function getAdressRewardPerDay(address account) external view returns (uint256) {
        return rewardRate.mul(86400).mul(_balances[account]).mul(1e18).div(_totalSupply);
    }
    function isWhiteContract(address account) public view returns (bool) {
        if(!account.isContract()) return true;
        return _Is_WhiteContractArr[account];
    }
    function getWhiteAccountNum() public view returns (uint256){
        return _WhiteContractArr.length;
    }
    function getWhiteAccountIth(uint256 ith) public view returns (address WhiteAddress){
        require(ith <_WhiteContractArr.length, "ForthBoxcomment: not in White Adress");
        return _WhiteContractArr[ith];
    }
    function getParameters(address account) public view returns (uint256[] memory){
        uint256[] memory paraList = new uint256[](uint256(9));
        paraList[0]=totalRewardAlready;
        paraList[1]=basicDailyReward;
        paraList[2]=_totalSupply;
        paraList[3]=_balances[account];
        paraList[4]= earned(account);
        paraList[5]= _sumCount;
        paraList[6]= _praiseNum;
        paraList[7]= _sumCount.sub(_praiseNum);
        paraList[8]= _sumScore;
        return paraList;
    }

    function sumCount() external view returns(uint256){
        return _sumCount;
    }
    function infos() external view returns(uint256 tPraiseNum,uint256 tBadNum,uint256 tSumScore){
        tPraiseNum = _praiseNum;
        tBadNum = _sumCount.sub(_praiseNum);
        tSumScore = _sumScore;
        return (tPraiseNum,tBadNum,tSumScore);
    }
    //read info
    function commentInfo(uint256 iD) external view returns (
        uint256 id,
        address addr,
        uint256 score,
        string memory str,
        bool bPraise,
        uint256 updataTime
        ) {
        require(iD <= _sumCount, "ForthBoxcomment: exist num!");
        id = _CommentPropertys[iD].id;
        addr = _CommentPropertys[iD].addr;
        score = _CommentPropertys[iD].score;
        str = _CommentPropertys[iD].str;
        updataTime = _CommentPropertys[iD].updataTime;
        bPraise = _CommentPropertys[iD].bPraise;
        return (id,addr,score,str,bPraise,updataTime);
    }
    function commentInfoFromAddress(address addr) external view returns (
        uint256 id,
        address addr2,
        uint256 score,
        string memory str,
        bool bPraise,
        uint256 updataTime
        ) {
        require(_bHaveComment[addr], "ForthBoxcomment: not have comment!");

        uint256 ith =  _CommentIth[addr];
        id = _CommentPropertys[ith].id;
        addr2 = _CommentPropertys[ith].addr;
        score = _CommentPropertys[ith].score;
        str = _CommentPropertys[ith].str;
        updataTime = _CommentPropertys[ith].updataTime;
        bPraise = _CommentPropertys[ith].bPraise;
        return (id,addr,score,str,bPraise,updataTime);
    }
    function bComment(address addr) external view returns (bool){
        return _bHaveComment[addr];
    }
    function bCommentHamId(uint256 hamID) external view returns (bool){
        return _bCommentHamId[hamID];
    }
    function bCommentHamIds(uint256[] calldata tokenIdArr) external view returns(bool[] memory bComHamIds){
        bComHamIds = new bool[](uint256(tokenIdArr.length));
        for(uint256 i=0; i<tokenIdArr.length; ++i) {
            bComHamIds[i] = _bCommentHamId[tokenIdArr[i]];
        }
        return bComHamIds;
    }

    function commentInfos(uint256 fromId,uint256 toId) external view returns (
        uint256[] memory idArr,
        address[] memory addrArr,
        uint256[] memory scoreArr,
        string[] memory strArr,
        bool[] memory bPraiseArr,
        uint256[] memory updataTimeArr
        ) {
        require(toId <= _sumCount, "ForthBoxcomment: exist num!");
        require(fromId <= toId, "ForthBoxcomment: exist num!");
        idArr = new uint256[](toId-fromId+1);
        addrArr = new address[](toId-fromId+1);
        scoreArr = new uint256[](toId-fromId+1);
        strArr = new string[](toId-fromId+1);

        updataTimeArr = new uint256[](toId-fromId+1);
        bPraiseArr = new bool[](toId-fromId+1);
        uint256 i=0;
        for(uint256 ith=fromId; ith<=toId; ith++) {
            idArr[i] = _CommentPropertys[ith].id;
            addrArr[i] = _CommentPropertys[ith].addr;
            scoreArr[i] = _CommentPropertys[ith].score;
            strArr[i] = _CommentPropertys[ith].str;
            updataTimeArr[i] = _CommentPropertys[ith].updataTime;
            bPraiseArr[i] = _CommentPropertys[ith].bPraise;
            i = i+1;
        }
        return (idArr,addrArr,scoreArr,strArr,bPraiseArr,updataTimeArr);
    }

    //---write---//
    modifier updateReward(address account){
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)){
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
    //write
    function writeComment(string calldata str,uint256 score,bool bPraise,uint256 hamID) external nonReentrant updateReward(msg.sender){
        require(!_bHaveComment[_msgSender()], "ForthBoxcomment: already comment!");
        require(!_bCommentHamId[hamID], "ForthBoxcomment: already comment!");
        require(isWhiteContract(_msgSender()), "ForthBoxcomment: Contract not in white list!");
        if(_msgSender() != NFT_Token.ownerOf(hamID)){
            require(_msgSender() == DeFi_Token.ownerTokenId(hamID), "ForthBoxcomment: hamID not owner");
        }
        require(score<=5, "ForthBoxcomment: exceed max score!");

        _bHaveComment[_msgSender()] = true;
        _bCommentHamId[hamID] = true;

        _sumCount = _sumCount.add(1);
        _CommentIth[_msgSender()] = _sumCount;
        _sumScore = _sumScore.add(score);
        _CommentPropertys[_sumCount].id = _sumCount;
        _CommentPropertys[_sumCount].addr = _msgSender();
        _CommentPropertys[_sumCount].score = score;
        _CommentPropertys[_sumCount].str = str;
        _CommentPropertys[_sumCount].bPraise = bPraise;
        _CommentPropertys[_sumCount].updataTime = block.timestamp;
        if(bPraise) _praiseNum = _praiseNum.add(1);
        
        uint256 amount = (bytes(str).length).add(100);
        if(amount>200){
            amount = 200;
        }
        amount = amount.add(NFT_Token.getValueByTokenId(hamID).mul(5));

        _balances[msg.sender] = _balances[msg.sender].add(amount);
        _totalSupply = _totalSupply.add(amount);

        emit WriteComment(msg.sender, amount, score,bPraise,hamID);
    }

    function getReward() public nonReentrant updateReward(msg.sender) {
        require(isWhiteContract(_msgSender()), "ForthBoxcomment: Contract not in white list!");
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            totalRewardAlready = totalRewardAlready.add(reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    //---write onlyOwner---//
    function notifyRewardAmount(uint256 reward) external onlyOwner updateReward(address(0)){
        if (block.timestamp >= periodFinish){
            rewardRate = reward.div(rewardsDuration);
        }
        else{
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(rewardsDuration);
        }
        totalReward = totalReward.add(reward);

        uint256 balance = rewardsToken.balanceOf(address(this));
        require(rewardRate <= balance.div(rewardsDuration), "ForthBoxcomment:Provided reward too high");

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(reward);
    }

    function addWhiteAccount(address account) external onlyOwner{
        require(!_Is_WhiteContractArr[account], "ForthBoxcomment:Account is already White list");
        require(account.isContract(), "ForthBoxcomment: not Contract Adress");
        _Is_WhiteContractArr[account] = true;
        _WhiteContractArr.push(account);
    }
    function removeWhiteAccount(address account) external onlyOwner{
        require(_Is_WhiteContractArr[account], "ForthBoxcomment:Account is already out White list");
        for (uint256 i = 0; i < _WhiteContractArr.length; i++){
            if (_WhiteContractArr[i] == account){
                _WhiteContractArr[i] = _WhiteContractArr[_WhiteContractArr.length - 1];
                _WhiteContractArr.pop();
                _Is_WhiteContractArr[account] = false;
                break;
            }
        }
    }



    
}