/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.16;

library Math {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
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

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }
}

contract Context {
    constructor () internal { }
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeERC20: approve from non-zero to non-zero allowance");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
    constructor () internal {
        _guardCounter = 1;
    }
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

interface IStakingRewards {
    // Views
    function lastTimeRewardApplicable() external view returns (uint256);
    function rewardPerToken() external view returns (uint256);
    function earned(address account) external view returns (uint256);
    function getRewardForDuration() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    // Mutative
    function stake(uint256 tokenId) external;
    function withdraw(uint256 tokenId) external;
    function getReward() external;
    function exit() external;
    function stakeFresh(address ownerAdrr,uint256 tokenId) external;
    // EVENTS
    event StakeFresh(address indexed user, uint256 tokenId);
    event Exit(address indexed user);
    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
}

interface IFBX_NFT_Token {
    function safeTransferFrom(address from_, address to_, uint256 tokenId_) external;
    function getHashrateByTokenId(uint256 tokenId_) external view returns(uint256);
    function feedFBXOnlyPrice() external view returns (uint256);
}

interface IERC721Receiver {
    function onERC721Received(address operator,address from,uint256 tokenId,bytes calldata data) view external returns (bytes4);
}

contract ForthBoxNFT_StakingRewards is IStakingRewards, Ownable, ReentrancyGuard,IERC721Receiver {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    string private _name = "ForthBox Ham DeFi";
    string private _symbol = "Ham DeFi";

    IERC20 public rewardsToken;
    IFBX_NFT_Token public stakingToken;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration = 30 days;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public totalReward;
    uint256 public totalStakeTokens=0;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    uint256 public totalRewardAlready;

    struct sNftPropertys {
        uint256 value;
        address owner;
    }
    struct sOwnNftIDs {
        uint256[] NftIDs;
    }
    mapping (uint256 => sNftPropertys) private _stakingNFTs;
    mapping (address => sOwnNftIDs) private _OwnerNFTs;

    mapping (address => bool) private _Is_WhiteContractArr;
    address[] private _WhiteContractArr;
    uint256 public basicDailyReward=100000;
    bool public bFeedReward = true;

    struct sFeedRewardData {
        uint256 sum;
        uint256 startTime;
        uint256 alreadyReward;
    }
    mapping(address => sFeedRewardData) public feedRewardArr;



    constructor() public {
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
    function getFeedReward_dt(address account) internal view returns (uint256) {
        if(feedRewardArr[account].sum==0 && feedRewardArr[account].alreadyReward==0){
            return 0;
        }
        uint256 dt = Math.min(block.timestamp, feedRewardArr[account].startTime.add(rewardsDuration)).sub(feedRewardArr[account].startTime);
        return dt.mul(feedRewardArr[account].sum).div(rewardsDuration);
    }
    function getFeedReward_All(address account) public view returns (uint256) {
        uint256 dtReward = getFeedReward_dt(account);
        return feedRewardArr[account].alreadyReward.add(dtReward);
    }
    function earned(address account) public view returns (uint256) {
        return _balances[account].mul(
          rewardPerToken().sub(userRewardPerTokenPaid[account])
        ).div(1e18).add(rewards[account]).add(getFeedReward_All(account));
    }
    function earned_Stake(address account) internal view returns (uint256) {
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
        return rewardRate.mul(86400).mul(1e18).div(_totalSupply);//result*1e18
    }
    function getAdressRewardPerDay(address account) external view returns (uint256) {
        return rewardRate.mul(86400).mul(_balances[account]).div(_totalSupply);
    }
    function getOwnerStakeTokenIDs(address Owner) external view returns (uint256[] memory){
        uint256 num = _OwnerNFTs[Owner].NftIDs.length;
        uint256[] memory Token_list = new uint256[](uint256(num));
        for(uint256 i=0; i<num; ++i) {
            Token_list[i] =_OwnerNFTs[Owner].NftIDs[i];
        }
        return  Token_list;
    }
    function ownerTokenId(uint256 tokenId) external view returns (address){
        return _stakingNFTs[tokenId].owner;
    }
    function onERC721Received(address,address,uint256,bytes memory) public view returns (bytes4) {
        return this.onERC721Received.selector;
    }
    function isWhiteContract(address account) public view returns (bool) {
        if(!account.isContract()) return true;
        return _Is_WhiteContractArr[account];
    }
    function getWhiteAccountNum() public view returns (uint256){
        return _WhiteContractArr.length;
    }
    function getWhiteAccountIth(uint256 ith) public view returns (address WhiteAddress){
        require(ith <_WhiteContractArr.length, "ForthBox NFT DeFi: no ith White Adress");
        return _WhiteContractArr[ith];
    }
    function getParameters(address account) public view returns (uint256[] memory){
        uint256[] memory paraList = new uint256[](uint256(5));
        paraList[0]=totalRewardAlready;
        paraList[1]=basicDailyReward;
        paraList[2]=_totalSupply;
        paraList[3]=_balances[account];
        paraList[4]= earned(account);
        return paraList;
    }
    //---write---//
    function stakes(uint256[] memory tokenIds) public nonReentrant updateReward(_msgSender()){
        require(tokenIds.length<=100, "ForthBox NFT DeFi: num exceed 100!");
        require(tokenIds.length>0, "ForthBox NFT DeFi: num 0!");
        require(isWhiteContract(_msgSender()), "ForthBox NFT DeFi: Contract not in white list!");
        for(uint256 i=0; i<tokenIds.length; ++i) {
            _stake(tokenIds[i]);
        }
    }
    function stake(uint256 tokenId) public nonReentrant updateReward(_msgSender()){
        require(isWhiteContract(_msgSender()), "ForthBox NFT DeFi: Contract not in white list!");
        _stake(tokenId);
    }
    function _stake(uint256 tokenId) internal {
        require(tokenId >= 0, "Cannot stake ID = 0");
        uint256 amount = stakingToken.getHashrateByTokenId(tokenId);
        require(amount > 0, "Cannot stake 0");

        stakingToken.safeTransferFrom(_msgSender(), address(this), tokenId);

        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        _totalSupply = _totalSupply.add(amount);

        _stakingNFTs[tokenId].value = amount;
        _stakingNFTs[tokenId].owner = _msgSender();

        _OwnerNFTs[_msgSender()].NftIDs.push(tokenId);

        totalStakeTokens = totalStakeTokens + 1;
        emit Staked(_msgSender(), tokenId);
    }
    function stakeFresh(address ownerAdrr,uint256 tokenId) external nonReentrant updateReward(ownerAdrr){
        require(ownerAdrr == _stakingNFTs[tokenId].owner , "ForthBox NFT DeFi: 1 Cannot Fresh not own id");
        require(isWhiteContract(_msgSender()), "ForthBox NFT DeFi: Contract not in white list!");

        if(address(_msgSender())!=address(stakingToken)){
           require(_msgSender() == ownerAdrr , "ForthBox NFT DeFi: 2 Cannot Fresh not own id");
        }
        uint256 amount = stakingToken.getHashrateByTokenId(tokenId);
        require(amount > _stakingNFTs[tokenId].value, "ForthBox NFT DeFi: need token hashrate > old Hashrate ");
        _balances[ownerAdrr] = _balances[ownerAdrr].add(amount.sub(_stakingNFTs[tokenId].value));
        _totalSupply = _totalSupply.add(amount.sub(_stakingNFTs[tokenId].value));
        _stakingNFTs[tokenId].value = amount;
        addFeedReward(ownerAdrr);
        emit StakeFresh(_msgSender(), tokenId);
    }
    function withdraw(uint256 tokenId) public nonReentrant updateReward(_msgSender()){
        require(isWhiteContract(_msgSender()), "ForthBox NFT DeFi: Contract not in white list!");
        _withdrawDel(tokenId);
        emit Withdrawn(_msgSender(), tokenId);
    }
    function _withdraw(uint256 tokenId) internal{
        _totalSupply = _totalSupply.sub(_stakingNFTs[tokenId].value);
        _balances[_msgSender()] = _balances[_msgSender()].sub(_stakingNFTs[tokenId].value);
        stakingToken.safeTransferFrom(address(this),_msgSender(), tokenId);
        totalStakeTokens = totalStakeTokens.sub(1);
    }
    function _withdrawDel(uint256 tokenId) internal {
        require(_msgSender() == _stakingNFTs[tokenId].owner , "ForthBox NFT DeFi: Cannot withdraw not own id");
        _withdraw(tokenId);
        for (uint256 i = 0; i < _OwnerNFTs[_msgSender()].NftIDs.length; i++){
            if (_OwnerNFTs[_msgSender()].NftIDs[i] == tokenId){
                _OwnerNFTs[_msgSender()].NftIDs[i] = _OwnerNFTs[_msgSender()].NftIDs[_OwnerNFTs[_msgSender()].NftIDs.length - 1];
                _OwnerNFTs[_msgSender()].NftIDs.pop();
                break;
            }
        }
        delete _stakingNFTs[tokenId];
    }
    function getReward() public nonReentrant updateReward(_msgSender()){
        require(isWhiteContract(_msgSender()), "ForthBox NFT DeFi: Contract not in white list!");

        uint256 tFeedReward = getFeedReward_All(_msgSender());
        uint256 reward = rewards[_msgSender()].add(tFeedReward);
        require(reward > 0, "ForthBox NFT DeFi: reward zero!");
        if (tFeedReward > 0){
            freshFeedReward(_msgSender());
        }
        if (reward > 0){
            rewards[_msgSender()] = 0;
            rewardsToken.safeTransfer(_msgSender(), reward);
            totalRewardAlready = totalRewardAlready.add(reward);
            emit RewardPaid(_msgSender(), reward);
        }
    }
    function exit() external nonReentrant updateReward(_msgSender()){
        require(isWhiteContract(_msgSender()), "ForthBox NFT DeFi: Contract not in white list!");
        _exit(_OwnerNFTs[_msgSender()].NftIDs.length);
    }
    function exits(uint256 num) external nonReentrant updateReward(_msgSender()){
        require(isWhiteContract(_msgSender()), "ForthBox NFT DeFi: Contract not in white list!");
        _exit(num);
    }
    function _exit(uint256 num) internal {
        require(num>0, "ForthBox NFT DeFi: num 0!");
        if(num>=_OwnerNFTs[_msgSender()].NftIDs.length){
            for (uint256 i = 0; i < _OwnerNFTs[_msgSender()].NftIDs.length; i++){
               _withdraw(_OwnerNFTs[_msgSender()].NftIDs[i]);
               delete _stakingNFTs[_OwnerNFTs[_msgSender()].NftIDs[i]];
            }
            delete _OwnerNFTs[_msgSender()];
        }
        else{
          uint256 LastNum = _OwnerNFTs[_msgSender()].NftIDs.length;
          for (uint256 i = 0; i < num; i++){
            _withdraw(_OwnerNFTs[_msgSender()].NftIDs[LastNum-1-i]);
            delete _stakingNFTs[_OwnerNFTs[_msgSender()].NftIDs[LastNum-1-i]];
          }
          for (uint256 i = 0; i < num; i++){
            _OwnerNFTs[_msgSender()].NftIDs.pop();
          }
        }

        uint256 tFeedReward = getFeedReward_All(_msgSender());
        uint256 reward = rewards[_msgSender()].add(tFeedReward);
        if (tFeedReward > 0){
            freshFeedReward(_msgSender());
        }
        if (reward > 0){
            rewards[_msgSender()] = 0;
            rewardsToken.safeTransfer(_msgSender(), reward);
            totalRewardAlready = totalRewardAlready.add(reward);
        }

        emit Exit(_msgSender());
    }
    modifier updateReward(address account){
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)){
            rewards[account] = earned_Stake(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
    function addFeedReward(address account) internal {
        if(!bFeedReward) return;

        uint256 feedReward=stakingToken.feedFBXOnlyPrice();
        uint256 dtReward = getFeedReward_dt(account);
        feedRewardArr[account].sum = feedRewardArr[account].sum.sub(dtReward).add(feedReward);
        feedRewardArr[account].alreadyReward = feedRewardArr[account].alreadyReward.add(dtReward);
        feedRewardArr[account].startTime = block.timestamp;
        return;
    }
    function freshFeedReward(address account) internal {
        uint256 dtReward = getFeedReward_dt(account);
        feedRewardArr[account].sum = feedRewardArr[account].sum.sub(dtReward);
        feedRewardArr[account].alreadyReward = 0;
        feedRewardArr[account].startTime = block.timestamp;
        return;
    }

    //---write onlyOwner---//
    function setTokens(address _rewardsToken,address _stakingToken,uint256 _rewardsDuration) external onlyOwner {
      rewardsToken = IERC20(_rewardsToken);
      stakingToken = IFBX_NFT_Token(_stakingToken);
      rewardsDuration = _rewardsDuration;
    }
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
        require(rewardRate <= balance.div(rewardsDuration), "ForthBox NFT DeFi:Provided reward too high");
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(reward);
    }
    function setBasicDailyReward (uint256 newBasicDailyReward) onlyOwner public{
        basicDailyReward = newBasicDailyReward ;
    }
    function setFeedReward (bool tFeedReward) onlyOwner public{
        bFeedReward = tFeedReward;
    }
    function addWhiteAccount(address account) external onlyOwner{
        require(!_Is_WhiteContractArr[account], "ForthBox NFT DeFi:Account is already White list");
        require(account.isContract(), "ForthBox NFT DeFi: not Contract Adress");
        _Is_WhiteContractArr[account] = true;
        _WhiteContractArr.push(account);
    }
    function removeWhiteAccount(address account) external onlyOwner{
        require(_Is_WhiteContractArr[account], "ForthBox NFT DeFi:Account is already out White list");
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