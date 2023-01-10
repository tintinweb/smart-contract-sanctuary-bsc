/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

// contracts/NFT.sol
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.12;

library SafeMath {

 function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
 function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
 function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
    function _msgData() internal view virtual returns (bytes calldata) {this; return msg.data;}
}

abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

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
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface IPancakeV2Router {
    function WBNB() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
}

interface IERC165 {
     function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    struct NFTInfo {
        address user;
        uint256 amount;
        uint8 tie;
        uint256 tokenId;
    }
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function changeDefaultUri(string memory uri, uint8 tie) external;
    function createToken(address recipient, uint8 tie, uint256 amount) external returns (uint256);
    function burnToken(address recipient, uint tie, uint256 tokenId) external;
    function getUserNFTInfo(address user) external view returns(NFTInfo[] memory res, string[] memory uris);
    function updateToken(uint256 tokenId, uint256 amount) external;
    function getUserNFTInfoByTokenId(uint256 id) external view returns(NFTInfo memory);
}

interface IFractionalNFT is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    struct NFTInfo {
        address user;
        uint256 amount;
        uint8 tie;
        uint256 tokenId;
    }
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function changeDefaultUri(string memory uri, uint8 tie) external;
    function getTierInfo(uint tokenId) external view returns(uint);
}

contract Lockup is Ownable {
    using SafeMath for uint256;

    IERC20 public stakingToken;
    IERC721Metadata public NFToken;
    IERC721Metadata public StakeNFT;
    IFractionalNFT FractionalNFT;
    uint256 distributionPeriod = 10;

    uint256 rewardPoolBalance;

    // balance of this contract should be bigger than thresholdMinimum
    uint256 thresholdMinimum;

    // default divisor is 6
    uint8 public divisor = 10;

    uint8 public rewardClaimInterval = 12; // user can claim reward every 12 hours

    uint256 public totalStaked;     // current total staked value

    uint8 public claimFee = 100; // the default claim fee is 10

    address treasureWallet;
    uint256 claimFeeAmount;
    // when cliamFeeAmount arrives at claimFeeAmountLimit, the values of claimFeeAmount will be transfered (for saving gas fee)
    uint256 claimFeeAmountLimit;   

    address deadAddress = 0x000000000000000000000000000000000000dEaD;
    address rewardWallet;

    // this is similar to `claimFeeAmountLimit` (for saving gas fee)
    uint256 irreversibleAmountLimit;
    uint256 irreversibleAmount;

    uint256 minInterval = 4 hours; // rewards is accumulated every 4 hours

    struct StakeInfo {
        int128 duration;  // -1: irreversible, others: reversible (0, 30, 90, 180, 365 days which means lock periods)
        uint256 amount; // staked amount
        uint256 stakedTime; // initial staked time
        uint256 lastClaimed; // last claimed time
        uint256 blockListIndex; // blockList id which is used in calculating rewards
        bool available;     // if diposit, true: if withdraw, false
        string name;    // unique id of the stake
        uint256 NFTId;
        uint256 NFTStakingId;
        address NFToken;
    }

    // this will be updated whenever new stake or lock processes
    struct BlockInfo {
        uint256 blockNumber;      
        uint256 totalStaked;      // this is used for calculating reward.
    }

    mapping(bytes32 => StakeInfo) stakedUserList;
    mapping (address => bytes32[]) userInfoList; // container of user's id
    BlockInfo[] blockList;

    uint256[11] defaultAmountForNFT;

    IPancakeV2Router public router;

    uint256 initialTime;        // it has the block time when first deposit in this contract (used for calculating rewards)

    mapping(address => bool) public whiteList;
    mapping(address => bool) public blackList;

    bool public useWhiteList;
    uint8 unLockBoost = 10;
    uint8 month1 = 15;
    uint8 month3 = 18;
    uint8 month6 = 20;
    uint8 year1 = 25;
    uint8 tieA = 30;
    uint8 tieB = 35;
    uint8 tieC = 38;
    uint8 tieD = 40;

    event Deposit(address indexed user, string name, uint256 amount);
    event DepositNFT(address indexed user, string name, uint256 tokenId);
    event Withdraw(address indexed user, string name, uint256 amount);
    event Compound(address indexed user, string name, uint256 amount);
    event NewDeposit(address indexed user, string name, uint256 amount);
    event SendToken(address indexed token, address indexed sender, uint256 amount);
    event SendTokenMulti(address indexed token, uint256 amount);
    event ClaimReward(address indexed user, uint256 amount);
    event Received(address, uint);
    event CreateNFT(address indexed user, string name, uint256 NFTid);
    event UpdateNFT(address indexed user, string name, uint256 oldNFTid, uint256 newNFTid);

    constructor (address _stakingToken, address _GRI, address _fractionalNFT){
        // this is for main net
        stakingToken = IERC20(_stakingToken);
        NFToken = IERC721Metadata(_GRI);      // // Node NFT address
        treasureWallet = 0x5670bA03FB73D5942e775342142fD9fa04BbcC0F;
        rewardWallet = 0x4261fEBE0263097428D990CDE1C10e171b9D6659;
        // StakeNFT = IERC721Metadata(0x3e66E0FE36Eb981b17B3f519D025f8bdD421bF9e);
        IPancakeV2Router _newPancakeRouter = IPancakeV2Router(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        FractionalNFT = IFractionalNFT(_fractionalNFT);
        router = _newPancakeRouter;
        whiteList[_msgSender()] = true;

        // default is 10000 amount of tokens
        claimFeeAmountLimit = 100_000 * 10 ** IERC20Metadata(address(stakingToken)).decimals();
        irreversibleAmountLimit = 10000 * 10 ** IERC20Metadata(address(stakingToken)).decimals();
        thresholdMinimum = 10 * 10 ** IERC20Metadata(address(stakingToken)).decimals();
        rewardPoolBalance = 100_000_000 * 10 ** IERC20Metadata(address(stakingToken)).decimals();
        defaultAmountForNFT[0] = 100_000_000 * 10 ** 18;
        defaultAmountForNFT[1] = 200_000_000 * 10 ** 18;
        defaultAmountForNFT[2] = 300_000_000 * 10 ** 18;
        defaultAmountForNFT[3] = 400_000_000 * 10 ** 18;
        defaultAmountForNFT[4] = 500_000_000 * 10 ** 18;
        defaultAmountForNFT[5] = 600_000_000 * 10 ** 18;
        defaultAmountForNFT[6] = 700_000_000 * 10 ** 18;
        defaultAmountForNFT[7] = 800_000_000 * 10 ** 18;
        defaultAmountForNFT[8] = 900_000_000 * 10 ** 18;
        defaultAmountForNFT[9] = 1000_000_000 * 10 ** 18;
        defaultAmountForNFT[10] = 100_000_000 * 10 ** 18;
    }
    
    function _string2byte32(string memory name) private view returns(bytes32) {
        return keccak256(abi.encodePacked(name, _msgSender()));
    }

    // check if the given name is unique id
    function isExistStakeId(string memory name) public view returns (bool) {
        return stakedUserList[_string2byte32(name)].available;
    }

    // change Reward Poll Pool Balance but in case of only owner
    function setRewardPoolBalance(uint256 _balance) external onlyOwner {
        rewardPoolBalance = _balance;
    }

    function setStakeNFT(address nftAddr) public onlyOwner {
        StakeNFT = IERC721Metadata(nftAddr);
    }

    function setTreasuryWallet(address walletAddr) external onlyOwner {
        treasureWallet = walletAddr;
    }

    function setStakingToken(address tokenAddr) public onlyOwner{
        stakingToken = IERC20(tokenAddr);
    }

    function setNFToken(IERC721Metadata tokenAddr) public onlyOwner {
        NFToken = tokenAddr;
    }

    function setClaimFeeAmountLimit(uint256 val) external onlyOwner {
        claimFeeAmountLimit = val * 10 ** IERC20Metadata(address(stakingToken)).decimals();
    }

    function setIrreversibleAmountLimit(uint256 val) external onlyOwner {
        irreversibleAmountLimit = val * 10 ** IERC20Metadata(address(stakingToken)).decimals();
    }

    function setDistributionPeriod(uint256 _period) external onlyOwner {
        distributionPeriod = _period;
    }

    function setDivisor (uint8 _divisor) external onlyOwner {
        divisor = _divisor;
    }

    function setMinInterval (uint256 interval) public onlyOwner {
        minInterval = interval * 1 hours;
    }

    function setRewardInterval (uint8 _interval) external onlyOwner {
        rewardClaimInterval = _interval;
    }

    function setClaimFee(uint8 fee) external onlyOwner {
        claimFee = fee;
    }

    function setRewardWallet(address wallet) public onlyOwner {
        rewardWallet = wallet;
    }

    function setDefaultAmountForNFT(uint[] memory list) public onlyOwner {
        for (uint i = 0; i < list.length; i++)
            defaultAmountForNFT[i] = list[i];
    }

    function doable (address user) private view returns(bool) {
        if(blackList[user]) return false;
        if(!useWhiteList) return true;
        if(useWhiteList && whiteList[user]) return true;
        return false;
    }

    function updateWhiteList (address[] memory users, bool flag) public onlyOwner {
        for(uint256 i = 0; i < users.length; i++) {
            whiteList[users[i]] = flag;
        }
    }

    function updateBlackList (address[] memory users, bool flag) public onlyOwner {
        for(uint256 i = 0; i < users.length; i++) {
            blackList[users[i]] = flag;
        }
    }

    function setUseWhiteList(bool flag) public onlyOwner {
        useWhiteList = flag;
    }

    function setBoostConst(uint8 _type, uint8 val) public onlyOwner {
        if(_type == 0) unLockBoost = val;
        else if(_type == 1) month1 = val;
        else if(_type == 2) month3 = val;
        else if(_type == 3) month6 = val;
        else if(_type == 4) year1 = val;
        else if(_type == 5) tieA = val;
        else if(_type == 6) tieB = val;
        else if(_type == 7) tieC = val;
        else if(_type == 8) tieD = val;
    }

    // send tokens out inside this contract into any address. 
    // when the specified token is stake token, the minmum value should be equal or bigger than thresholdMinimum amount.
    function withdrawToken (address token, address sender, uint256 amount) external onlyOwner {
        if(address(stakingToken) == token) {
            require(canWithdrawPrimaryToken(amount), "thresholdMinimum limit");
        }
        IERC20Metadata(token).transfer(sender, amount);
        emit SendToken(token, sender, amount);
    }

    function sendToken (address token, uint256 amount) external {
        IERC20Metadata(token).transferFrom(_msgSender(), address(this), amount);
    }

    function multiWithdrawTokens (address token, uint256 amount, address[] memory recipients ) public onlyOwner {
        if(address(stakingToken) == token) {
            uint totalAmount = amount * recipients.length;
            require(canWithdrawPrimaryToken(totalAmount), "thresholdMinimum limit");
        }
        for (uint256 i = 0; i < recipients.length; i++) {
            IERC20Metadata(token).transfer(recipients[i], amount);
        }
        emit SendTokenMulti(token, amount);
    }

    function canWithdrawPrimaryToken (uint256 amount) public view returns(bool) {
        return stakingToken.balanceOf(address(this)) > amount && stakingToken.balanceOf(address(this)).sub(amount) >= thresholdMinimum;
    }

    // update the blockList table
    // when deposit, totalStaked increases; when withdraw, totalStaked decreases (if isPush is true this is deposit mode, or else withdraw)
    function _updateBlockList(uint256 amount, bool isPush) private {
        uint256 len = blockList.length;
        if(isPush) totalStaked = totalStaked.add(amount);
        else       totalStaked = totalStaked.sub(amount);

        uint256 time = block.timestamp;

        time = time - (time - initialTime) % minInterval;

        if(len == 0) {
            blockList.push(BlockInfo({
                blockNumber : time,
                totalStaked : totalStaked
            }));
        } else {
            // when the reward is not accumulated yet
            if((time - blockList[len-1].blockNumber) / minInterval == 0) { 
                blockList[len-1].totalStaked = totalStaked;
            } else {
                blockList.push(BlockInfo({
                    blockNumber : time,
                    totalStaked : totalStaked
                }));
            }
        }
    }

    // when staked, new StakeInfo is added: when withdraw this stakeInfo is no available anymore (avaliable = false)
    function _updateStakedList(string memory name, int128 duration, uint256 amount, bool available) private {
        bytes32 key = _string2byte32(name); 
        StakeInfo storage info = stakedUserList[key];
        info.available = available;
        if(!available) return; // when withdraw mode

        uint256 time = block.timestamp;

        info.amount = info.amount.add(amount);
        info.blockListIndex = blockList.length - 1;
        info.stakedTime = block.timestamp;
        info.lastClaimed = time;
        info.duration = duration;
        info.name = name;
    }

    // update the user list table
    function _updateUserList(string memory name, bool isPush) private {
        bytes32 key = _string2byte32(name);
        if(isPush)
            userInfoList[_msgSender()].push(key);
        else {
            // remove user id from the userList
            for (uint256 i = 0; i < userInfoList[_msgSender()].length; i++) {
                if (userInfoList[_msgSender()][i] == key) {
                    userInfoList[_msgSender()][i] = userInfoList[_msgSender()][userInfoList[_msgSender()].length - 1];
                    userInfoList[_msgSender()].pop();
                    break;
                }
            }
        }
    }

    function stakeNFT (string memory name, uint256 tokenId,address nftToken, bool isNode)  public {
        require(doable(_msgSender()), "NA");
        require(!isExistStakeId(name), "id existed!");

        if(initialTime == 0) {
            initialTime = block.timestamp;
        }

        if(isNode) {
            IERC721Metadata.NFTInfo memory node;
            node = NFToken.getUserNFTInfoByTokenId(tokenId);
            uint amount = node.amount;
            _updateBlockList(amount, true);
            _updateStakedList(name, -1, amount, true);
            _updateUserList(name, true);
            bytes32 key = _string2byte32(name);
            StakeInfo storage info = stakedUserList[key];
            info.NFTId = tokenId;
            NFToken.transferFrom(_msgSender(), address(this), tokenId);
        } else {
            uint amount;
            IERC721 token;
            if(nftToken == address(FractionalNFT)) {
                uint tier = IFractionalNFT(nftToken).getTierInfo(tokenId);
                amount = defaultAmountForNFT[tier];
                token = IERC721(FractionalNFT);
            } else {
                amount = defaultAmountForNFT[10];
                token = IERC721(StakeNFT);
            }
            _updateBlockList(amount, true);
            _updateStakedList(name, 0, amount, true);
            _updateUserList(name, true);
            bytes32 key = _string2byte32(name);
            StakeInfo storage info = stakedUserList[key];
            info.NFTStakingId = tokenId;
            info.NFToken = nftToken;
            token.transferFrom(_msgSender(), address(this), tokenId);
            emit DepositNFT(_msgSender(), name, tokenId);
        }
    }

    function stake(string memory name, int128 duration, uint256 amount) public {
        require(doable(_msgSender()), "NA");
        require(amount > 0, "no amount");
        require(!isExistStakeId(name), "already existed!");

        if(initialTime == 0) {
            initialTime = block.timestamp;
        }

        _updateBlockList(amount, true);
        _updateStakedList(name, duration, amount, true);
        _updateUserList(name, true);

        IERC20Metadata(address(stakingToken)).transferFrom(_msgSender(), address(this), amount);

        if(duration < 0) {    //irreversible mode
            _dealWithIrreversibleAmount(amount, name);
        }
        emit Deposit(_msgSender(), name, amount);
    }

    function unStakeNFT(string memory name) public {
        require(doable(_msgSender()), "NA");
        require(isExistStakeId(name), "doesn't existed!");
        uint256 amount = stakedUserList[_string2byte32(name)].amount;
        address token = stakedUserList[_string2byte32(name)].NFToken;
        // require(canWithdrawPrimaryToken(amount), "threshold limit");
        require(stakedUserList[_string2byte32(name)].NFTStakingId != 0, "Invalid operatorN");
        (uint a, ) = unClaimedReward(name);
        if(a > 0) _claimReward(name, true);
        _updateBlockList(amount, false);
        _updateStakedList(name, 0, 0, false);
        _updateUserList(name, false);

        IERC721(token).transferFrom(address(this), _msgSender(), stakedUserList[_string2byte32(name)].NFTStakingId);
    }

    function unStake(string memory name) public {
        require(doable(_msgSender()), "NA");
        require(isExistStakeId(name), "doesn't existed!");
        require(isWithdrawable(name), "period not expired!");
        StakeInfo storage stakeInfo = stakedUserList[_string2byte32(name)];
        require(stakeInfo.NFTStakingId == 0, "Invalid operator");
        // when user withdraws the amount, the accumulated reward should be refunded

        uint256 amount = stakeInfo.amount;
        (uint a, ) = unClaimedReward(name);
        if(a > 0) _claimReward(name, true);
        _updateBlockList(amount, false);
        _updateStakedList(name, 0, 0, false);
        _updateUserList(name, false);
        if(stakeInfo.duration >= 0) {
            require(canWithdrawPrimaryToken(amount), "threshold limit!");
            IERC20Metadata(address(stakingToken)).transfer(_msgSender(), amount);
        } else {
            IERC721Metadata(NFToken).transferFrom(address(this), _msgSender(), stakeInfo.NFTId);
        }
        emit Withdraw(_msgSender(), name, amount);
    }

    function getBoost(int128 duration, uint256 amount) internal view returns (uint8) {
        if(duration < 0 && amount < 100 * 10 ** 6 * 10 ** 18) return 0;
        else if (duration < 0 && amount < 500 * 10 ** 6 * 10 ** 18  && amount >= 100 * 10 ** 6 * 10 ** 18) return tieA;      // irreversable
        else if (duration < 0 && amount < 1000 * 10 ** 6 * 10 ** 18) return tieB;      // irreversable
        else if (duration < 0 && amount < 5000 * 10 ** 6 * 10 ** 18) return tieC;      // irreversable
        else if (duration < 0 && amount >= 5000 * 10 ** 6 * 10 ** 18) return tieD;      // irreversable
        else if (duration < 30) return unLockBoost;   // no lock
        else if (duration < 90) return month1;   // more than 1 month
        else if (duration < 180) return month3;   // more than 3 month
        else if (duration < 360) return month6;  // more than 6 month
        else return year1;                      // more than 12 month
    }

    function _dealWithIrreversibleAmount(uint256 amount, string memory name) private {
        require(amount >= 100 * 10 ** 6 * 10 ** 18, "invalid amount for node");
        // for saving gas fee
        swapBack(amount);
        bytes32 key = _string2byte32(name);
        StakeInfo storage info = stakedUserList[key];
        // generate NFT
        uint8 tier;
        if(getBoost(info.duration, amount) == tieA) tier = 0;
        else if (getBoost(info.duration, amount) == tieB) tier = 1;
        else if (getBoost(info.duration, amount) == tieC) tier = 2;
        else if (getBoost(info.duration, amount) == tieD) tier = 3;
        uint256 tokenId = IERC721Metadata(NFToken).createToken(address(this), tier, amount);
       // save NFT id
        info.NFTId = tokenId;
        info.NFToken = address(NFToken);

        emit CreateNFT(address(this), name, tokenId);
    }

    function swapBack(uint256 amount) private {
        if(irreversibleAmount + amount >= irreversibleAmountLimit) {
            require(canWithdrawPrimaryToken(irreversibleAmount + amount), "threshold limit");
            uint256 deadAmount = (irreversibleAmount + amount) / 5;
            IERC20Metadata(address(stakingToken)).transfer(deadAddress, deadAmount);
            // uint256 usdcAmount = (irreversibleAmount + amount) / 5;
            uint256 nativeTokenAmount = (irreversibleAmount + amount) * 3 / 10;
            uint256 rewardAmount = (irreversibleAmount + amount) * 1 / 2;
            // _swapTokensForUSDC(usdcAmount);
            _swapTokensForNative(nativeTokenAmount);
            IERC20Metadata(address(stakingToken)).transfer(treasureWallet, rewardAmount);
            irreversibleAmount = 0;
        } else {
            irreversibleAmount += amount;
        }
    }

    function _swapTokensForNative(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(stakingToken);
        path[1] = router.WBNB();
        IERC20Metadata(address(stakingToken)).approve(address(router), amount);
        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of ETH
            path,
            treasureWallet,
            block.timestamp
        );
    }

    function isWithdrawable(string memory name) public view returns(bool) {
        StakeInfo storage stakeInfo = stakedUserList[_string2byte32(name)];
        // when Irreversible mode
        if (stakeInfo.duration < 0) return true;
        if (uint256(uint128(stakeInfo.duration) * 1 days) <= block.timestamp - stakeInfo.stakedTime) return true;
        else return false;
    }

    function _calculateReward(string memory name) private view returns(uint256) {
        require(isExistStakeId(name), "not exist");
        require(totalStaked != 0, "no staked");
        StakeInfo storage stakeInfo = stakedUserList[_string2byte32(name)];

        uint256 lastClaimed = stakeInfo.lastClaimed;
        uint256 blockIndex = stakeInfo.blockListIndex;
        uint256 stakedAmount = stakeInfo.amount;
        uint256 reward = 0;
        uint256 boost = getBoost(stakeInfo.duration, stakedAmount);

        for (uint256 i = blockIndex + 1; i < blockList.length; i++) {
            uint256 _totalStaked = blockList[i].totalStaked;
            if(_totalStaked == 0) continue;
            reward = reward + ((blockList[i].blockNumber - lastClaimed).div(minInterval) 
                                * (rewardPoolBalance * stakedAmount * boost / distributionPeriod  / _totalStaked / divisor / 10 )  // formula // 10 => boost divisor
                                * (minInterval)  / (24 hours));
            lastClaimed = blockList[i].blockNumber;
            
        }

        reward = reward + ((block.timestamp - lastClaimed).div(minInterval) 
                                * (rewardPoolBalance * stakedAmount * boost / distributionPeriod  / totalStaked / divisor / 10)  // formula
                                * (minInterval)  / (24 hours));
        return reward;
    }

    function unClaimedReward(string memory name) public view returns(uint256, bool) {
        if(!isExistStakeId(name)) return (0, false);
        uint256 reward = _calculateReward(name);
        // default claimFee is 100 so after all claimFee/1000 = 0.1 (10%) (example: claimFee=101 => 101/1000 * 100 = 10.1%)
        return (reward - reward * claimFee / 1000, true);
    }

    function unclaimedAllRewards(address user, int128 period, bool all) public view returns(uint256 resVal) {
        bool exist;
        for (uint256 i = 0; i < userInfoList[user].length; i++) {
            if(!all && getBoost(stakedUserList[userInfoList[user][i]].duration, stakedUserList[userInfoList[user][i]].amount) != getBoost(period, stakedUserList[userInfoList[user][i]].amount)) continue;
            uint256 claimedReward;
            (claimedReward, exist) = unClaimedReward(stakedUserList[userInfoList[user][i]].name);
            if(!exist) continue;
            resVal += claimedReward;
        }
        return (resVal);
    }
    
    function claimReward(string memory name) public {
        require(doable(_msgSender()), "NA");
        _claimReward(name, false);
    }

    function _claimReward(string memory name, bool ignoreClaimInterval) private {
        require(isExistStakeId(name), "not exist");
        if(!ignoreClaimInterval) {
            require(isClaimable(name), "period not expired!");
        }
        uint256 reward = _calculateReward(name);
        bytes32 key = _string2byte32(name);
        // update blockListIndex and lastCliamed value
        StakeInfo storage info = stakedUserList[key];
        info.blockListIndex = blockList.length - 1;
        uint256 time = block.timestamp;
        info.lastClaimed = time;
        require(canWithdrawPrimaryToken(reward - reward * claimFee / 1000), "threshold limit1");
        IERC20Metadata(address(stakingToken)).transfer(_msgSender(), reward - reward * claimFee / 1000);

        // send teasureWallet when the total amount sums up to the limit value
        if(claimFeeAmount + reward * claimFee / 1000 > claimFeeAmountLimit) {
            require(canWithdrawPrimaryToken(claimFeeAmount + reward * claimFee / 1000), "threshold limit2");
            IERC20Metadata(address(stakingToken)).transfer(treasureWallet, claimFeeAmount + reward * claimFee / 1000);
            claimFeeAmount = 0;
        } else {
            claimFeeAmount += reward * claimFee / 1000;
        }

        emit ClaimReward(_msgSender(), reward - reward * claimFee / 1000);
    }

    function isClaimable(string memory name) public view returns(bool) {
        StakeInfo storage stakeInfo = stakedUserList[_string2byte32(name)];
        uint256 lastClaimed = stakeInfo.lastClaimed;
        
        if((block.timestamp - lastClaimed) / rewardClaimInterval * 1 hours > 0) return true;
        // if((block.timestamp - lastClaimed) / rewardClaimInterval * 1 seconds > 0) return true;
        else return false;
    }

    function compound(string memory name) public {
        require(doable(_msgSender()), "NA");
        require(isExistStakeId(name), "not exist");
        require(isClaimable(name), "period not expired");
        uint256 reward = _calculateReward(name);
        _updateBlockList(reward, true);

        // update blockListIndex and lastCliamed value
        stakedUserList[_string2byte32(name)].blockListIndex = blockList.length - 1;
        uint256 time = block.timestamp;
        stakedUserList[_string2byte32(name)].lastClaimed = time;
        stakedUserList[_string2byte32(name)].amount += reward;
        // lock period increases when compound except of irreversible mode
        if(stakedUserList[_string2byte32(name)].duration > 0) {
            stakedUserList[_string2byte32(name)].duration++;
        } else if(stakedUserList[_string2byte32(name)].duration < 0) {        // when irreversible mode
            if(getBoost(stakedUserList[_string2byte32(name)].duration, stakedUserList[_string2byte32(name)].amount - reward) < getBoost(stakedUserList[_string2byte32(name)].duration, stakedUserList[_string2byte32(name)].amount)) {
                uint256 oldId = stakedUserList[_string2byte32(name)].NFTId;
                uint8 tier;
                if(getBoost(stakedUserList[_string2byte32(name)].duration, stakedUserList[_string2byte32(name)].amount) == tieA) tier = 0;
                else if (getBoost(stakedUserList[_string2byte32(name)].duration, stakedUserList[_string2byte32(name)].amount) == tieB) tier = 1;
                else if (getBoost(stakedUserList[_string2byte32(name)].duration, stakedUserList[_string2byte32(name)].amount) == tieC) tier = 2;
                else if (getBoost(stakedUserList[_string2byte32(name)].duration, stakedUserList[_string2byte32(name)].amount) == tieD) tier = 3;
                NFToken.burnToken(_msgSender(), tier, stakedUserList[_string2byte32(name)].NFTId);
                // generate NFT
                uint256 tokenId = IERC721Metadata(NFToken).createToken(_msgSender(), tier, stakedUserList[_string2byte32(name)].amount);
                // save NFT id
                stakedUserList[_string2byte32(name)].NFTId = tokenId;
                emit UpdateNFT(_msgSender(), name, oldId, tokenId);
            } else {
                NFToken.updateToken(stakedUserList[_string2byte32(name)].NFTId, stakedUserList[_string2byte32(name)].amount);
            }

            swapBack(reward);
        }

        emit Compound(_msgSender(), name, reward);
    }

    function getUserStakedInfo(address user) public view returns (uint256 length, StakeInfo[] memory info, uint256[] memory dailyReward) {
        length = userInfoList[user].length;
        dailyReward = new uint256[](length);
        info = new StakeInfo[](length);
        for (uint256 i = 0; i < userInfoList[user].length; i++) {
            info[i] = stakedUserList[userInfoList[user][i]];
            uint256 boost = getBoost(info[i].duration, info[i].amount);
            dailyReward[i] = (rewardPoolBalance * info[i].amount * boost / 10 / distributionPeriod  / totalStaked / divisor ); // 10 => boost divisor
        }

        return (length, info, dailyReward);
    }

    function claimMulti(string[] memory ids) public {
        for (uint256 i = 0; i < ids.length; i++) {
            claimReward(ids[i]);
        }
    }

    function compoundMulti(string[] memory ids) public {
        for (uint256 i = 0; i < ids.length; i++) {
            compound(ids[i]);
        }
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function transferNativeToContract() external payable {  }

    function transferToAddressFromContract(address[] memory recipient, uint256 amount) public onlyOwner {
        require(address(this).balance >= amount * recipient.length, "insufficience balance contract");
        for(uint256 i = 0; i < recipient.length; i++) {
            address payable wallet = payable(recipient[i]);
            wallet.transfer(amount);
        }
    }

    function changeDefaultNFTUri(string memory uri, uint8 tie) public onlyOwner {
        NFToken.changeDefaultUri(uri, tie);
    }

    function getUserNFT(address user) public view returns(IERC721Metadata.NFTInfo[] memory NFTList, string[] memory uris) {
        return NFToken.getUserNFTInfo(user);
    }

    // 
    function getUserStakedNFT(string memory name) public view returns(uint256 tokenId, string memory uri) {
        require(isExistStakeId(name), "not exist");
        return (stakedUserList[_string2byte32(name)].NFTStakingId, StakeNFT.tokenURI(stakedUserList[_string2byte32(name)].NFTStakingId));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }
}