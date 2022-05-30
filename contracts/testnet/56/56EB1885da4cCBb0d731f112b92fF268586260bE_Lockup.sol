// contracts/NFT.sol
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }


    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

 
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) { 
        uint256 size; assembly { size := extcodesize(account) } return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");(bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
        
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
        
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
        
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) { return returndata; } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {revert(errorMessage);}
        }
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

interface IPancakeV2Factory {
       event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IPancakeV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
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

interface IERC165 {
     function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    struct NFTInfo {
        address user;
        uint256 amount;
        uint8 tie;
        uint256 tokenId;
    }

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

    function changeDefaultUri(string memory uri, uint8 tie) external;
    function createToken(address recipient, uint8 tie, uint256 amount) external returns (uint256);
    function burnToken(address recipient, uint tie, uint256 tokenId) external;
    function getUserNFTInfo(address user) external view returns(NFTInfo[] memory);
    function updateToken(uint256 tokenId, uint256 amount) external;
}

interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


contract Lockup is Ownable {
    using SafeMath for uint256;
    using Address for address;

    IERC20 public stakingToken;
    IERC721Metadata public NFToken;
    IERC20 public USDC;
    uint256 public distributionPeriod = 10;

    uint256 public rewardPoolBalance;

    // balance of this contract should be bigger than thresholdMinimum
    uint256 public thresholdMinimum;

    // default divisor is 6
    uint8 public divisor = 6;

    uint8 public rewardClaimInterval = 6;

    uint256 public totalStaked;     // current total staked value

    uint8 public claimFee = 100; // the default claim fee is 10

    address treasureWallet;
    uint256 public claimFeeAmount;
    // when cliamFeeAmount arrives at claimFeeAmountLimit, the values of claimFeeAmount will be transfered (for saving gas fee)
    uint256 public claimFeeAmountLimit;   

    address deadAddress = 0x000000000000000000000000000000000000dEaD;
    address rewardWallet;

    // this is similar to `claimFeeAmountLimit` (for saving gas fee)
    uint256 public irreversibleAmountLimit;
    uint256 public irreversibleAmount;

    uint256 minInterval = 15 minutes;

    struct StakeInfo {
        int128 duration;  // -1: irreversible, others: reversible (0, 30, 90, 180, 365 days which means lock periods)
        uint256 amount; // staked amount
        uint256 stakedTime; // initial staked time
        uint256 lastClaimed; // last claimed time
        uint256 blockListIndex; // blockList id which is used in calculating rewards
        bool available;     // if diposit, true: if withdraw, false
        string name;    // unique id of the stake
        uint256 NFTId;
    }

    // this will be updated whenever new stake or lock processes
    struct BlockInfo {
        uint256 blockNumber;      
        uint256 totalStaked;      // this is used for calculating reward.
    }

    mapping(bytes32 => StakeInfo) public stakedUserList;
    mapping (address => bytes32[]) public userInfoList; // container of user's id
    BlockInfo[] public blockList;

    IPancakeV2Router public router;
    address public pair;

    uint256 initialTime;        // it has the block time when first deposit in this contract (used for calculating rewards)

    event Deposit(address indexed user, string name, uint256 amount);
    event Withdraw(address indexed user, string name, uint256 amount);
    event Compound(address indexed user, string name, uint256 amount);
    event NewDeposit(address indexed user, string name, uint256 amount);
    event SendToken(address indexed token, address indexed sender, uint256 amount);
    event ClaimReward(address indexed user, uint256 amount);
    event Received(address, uint);

    constructor () {
        // this is for main net
        // stakingToken = IERC20(0x159B64aF8Fc5d860B3f669D94658fD61F46254dC);
        // NFToken = IGuarantNFT(0xD28B6408d3571B12812cDD6b2b3DcD8B007e3345);      // // NFT token address
        // treasureWallet = 0xF0b6C436dd743DaAd19Fd1e87CBe86EEd9F122Df;
        // rewardWallet = 0xe829d447711b5ef456693A27855637B8C6E9168B;
        // IPancakeV2Router _newPancakeRouter = IPancakeV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // router = _newPancakeRouter;

        // // default is 10000 amount of tokens
        // claimFeeAmountLimit = 100_000_000 * 10 ** IERC20Metadata(address(stakingToken)).decimals();
        // irreversibleAmountLimit = 1_000_000_000_000 * 10 ** IERC20Metadata(address(stakingToken)).decimals();
        // thresholdMinimum = 10 ** 11 * 10 ** IERC20Metadata(address(stakingToken)).decimals();
        // rewardPoolBalance = 10_000_000_000 * 10 ** IERC20Metadata(address(stakingToken)).decimals();
        // USDC = IERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);

        // IERC20Metadata(address(stakingToken)).approve(address(router), 999999999999999999999999);
        // USDC.approve(address(router), 999999999999999999999999); // USDC
        // IERC20Metadata(address(_newPancakeRouter.WETH())).approve(address(router), 999999999999999999999999); // Native token

        // this is for main net
        stakingToken = IERC20(0x17BFD5aA2e734d22f6A3ac2d5953fb9720B245E5);
        NFToken = IERC721Metadata(0xc4Aa90aa516f01887C27d1E69175826eD4B704B3);      // // NFT token address
        treasureWallet = 0xF0b6C436dd743DaAd19Fd1e87CBe86EEd9F122Df;
        rewardWallet = 0xe829d447711b5ef456693A27855637B8C6E9168B;
        USDC = IERC20(0x45e3Cb753F5D4F176ECb45C72969004CC21bDEE9);
        IPancakeV2Router _newPancakeRouter = IPancakeV2Router(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        router = _newPancakeRouter;

        // default is 10000 amount of tokens
        claimFeeAmountLimit = 100_000_000 * 10 ** IERC20Metadata(address(stakingToken)).decimals();
        irreversibleAmountLimit = 1_000_000_000_000 * 10 ** IERC20Metadata(address(stakingToken)).decimals();
        thresholdMinimum = 10 ** 11 * 10 ** IERC20Metadata(address(stakingToken)).decimals();
        rewardPoolBalance = 10_000_000_000 * 10 ** IERC20Metadata(address(stakingToken)).decimals();

        IERC20Metadata(address(stakingToken)).approve(address(router), 999999999999999999999999);
        USDC.approve(address(router), 999999999999999999999999); // USDC
        IERC20Metadata(address(_newPancakeRouter.WETH())).approve(address(router), 999999999999999999999999); // Native token
    }
    
    function _string2byte32(string memory name) private pure returns(bytes32) {
        return keccak256(abi.encodePacked(name));
    }

    // check if the given name is unique id
    function isExistStakeId(string memory name) public view returns (bool) {
        return stakedUserList[_string2byte32(name)].available;
    }

    // change Reward Poll Pool Balance but in case of only owner
    function setRewardPoolBalance(uint256 _balance) external onlyOwner {
        rewardPoolBalance = _balance;
    }

    function setTreasuryWallet(address walletAddr) external onlyOwner {
        treasureWallet = walletAddr;
    }

    function setStakingToken(IERC20 tokenAddr) public onlyOwner{
        stakingToken = tokenAddr;
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
        minInterval = interval * 1 minutes;
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

    // send tokens out inside this contract into any address. 
    // when the specified token is stake token, the minmum value should be equal or bigger than thresholdMinimum amount.
    function withdrawToken (address token, address sender, uint256 amount) external onlyOwner {
        if(address(stakingToken) == token) {
            require(canWithdrawPrimaryToken(amount), "Token balance should be bigger than thresholdMinimum");
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
            require(canWithdrawPrimaryToken(totalAmount), "Token balance should be bigger than thresholdMinimum");
        }
        for (uint256 i = 0; i < recipients.length; i++) {
            IERC20Metadata(token).transfer(recipients[i], amount);
        }
    }

    function canWithdrawPrimaryToken (uint256 amount) public view returns(bool) {
        return uint256(stakingToken.balanceOf(address(this))) - amount >= thresholdMinimum;
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
        time = time - (time - initialTime) % minInterval;

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

    function stake(string memory name, int128 duration, uint256 amount) public {
        require(amount > 0, "amount should be bigger than zero!");
        require(!isExistStakeId(name), "This id is already existed!");

        if(initialTime == 0) {
            initialTime = block.timestamp;
        }

        _updateBlockList(amount, true);
        _updateStakedList(name, duration, amount, true);
        _updateUserList(name, true);

        IERC20Metadata(address(stakingToken)).transferFrom(_msgSender(), address(this), amount);

        if(duration == -1) {    //irreversible mode
            _dealWithIrreversibleAmount(amount, name);
        }
        emit Deposit(_msgSender(), name, amount);
    }

    function unStake(string memory name) public {
        require(isExistStakeId(name), "This doesn't existed!");
        require(isWithdrawable(name), "Lock period is not expired!");

        // when user withdraws the amount, the accumulated reward should be refunded
        _claimReward(name, true);
        uint256 amount = stakedUserList[_string2byte32(name)].amount;
        _updateBlockList(amount, false);
        _updateStakedList(name, 0, 0, false);
        _updateUserList(name, false);
        IERC20Metadata(address(stakingToken)).transfer(_msgSender(), amount);
        emit Withdraw(_msgSender(), name, amount);
    }

    function unStakeAll() public {
        for (uint256 i = 0; i < userInfoList[_msgSender()].length; i++) {
            StakeInfo memory info = stakedUserList[userInfoList[_msgSender()][i]];
            if(!isWithdrawable(info.name)) continue;
            unStake(info.name);
        }
    }

    function getBoost(int128 duration, uint256 amount) internal pure returns (uint8) {
        if (duration < 0 && amount < 500 * 10 ** 9 * 10 ** 18) return 8;      // irreversable
        else if (duration < 0 && amount <= 1000 * 10 ** 9 * 10 ** 18) return 10;      // irreversable
        else if (duration < 0 && amount <= 5000 * 10 ** 9 * 10 ** 18) return 12;      // irreversable
        else if (duration < 0 && amount > 5000 * 10 ** 9 * 10 ** 18) return 14;      // irreversable
        else if (duration < 30) return 1;   // no lock
        else if (duration < 90) return 2;   // more than 1 month
        else if (duration < 180) return 3;   // more than 3 month
        else if (duration < 360) return 4;  // more than 6 month
        else return 5;                      // more than 12 month
    }

    function _dealWithIrreversibleAmount(uint256 amount, string memory name) private {

        // for saving gas fee
        swapBack(amount);
        bytes32 key = _string2byte32(name);
        StakeInfo storage info = stakedUserList[key];
        // generate NFT
        uint256 tokenId = IERC721Metadata(NFToken).createToken(_msgSender(), (getBoost(info.duration, amount) - 8) / 2, amount);
       // save NFT id
        info.NFTId = tokenId;
    }

    function swapBack(uint256 amount) private {
        if(irreversibleAmount + amount > irreversibleAmountLimit) {
            uint256 deadAmount = (irreversibleAmount + amount) / 5;
            IERC20Metadata(address(stakingToken)).transfer(deadAddress, deadAmount);
            uint256 usdcAmount = (irreversibleAmount + amount) / 5;
            uint256 nativeTokenAmount = (irreversibleAmount + amount) * 3 / 10;
            uint256 rewardAmount = (irreversibleAmount + amount) * 3 / 10;
            _swapTokensForUSDC(usdcAmount);
            _swapTokensForNative(nativeTokenAmount);
            IERC20Metadata(address(stakingToken)).transfer(treasureWallet, rewardAmount);
            irreversibleAmount = 0;
        } else {
            irreversibleAmount += amount;
        }
    }

    function _swapTokensForUSDC(uint256 amount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(stakingToken);
        path[1] = address(USDC);  // usdc address
        IERC20Metadata(address(stakingToken)).approve(address(router), amount);
        router.swapExactTokensForTokens(amount, 0, path, treasureWallet, block.timestamp);
    }

    function _swapTokensForNative(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(stakingToken);
        path[1] = router.WETH();
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

    function getBlockLength() public view returns(uint256) {
        return blockList.length;
    }

    function isWithdrawable(string memory name) public view returns(bool) {
        StakeInfo storage stakeInfo = stakedUserList[_string2byte32(name)];
        // when Irreversible mode
        if (stakeInfo.duration == -1) return false;
        if (uint256(uint128(stakeInfo.duration) * 1 days) <= block.timestamp - stakeInfo.stakedTime) return true;
        else return false;
    }

    function _calculateReward(string memory name) private view returns(uint256) {
        require(isExistStakeId(name), "This id doesn't exist!");
        StakeInfo storage stakeInfo = stakedUserList[_string2byte32(name)];

        uint256 lastClaimed = stakeInfo.lastClaimed;
        uint256 blockIndex = stakeInfo.blockListIndex;
        uint256 stakedAmount = stakeInfo.amount;
        uint256 reward = 0;
        uint256 boost = getBoost(stakeInfo.duration, stakedAmount);

        for (uint256 i = blockIndex + 1; i < blockList.length; i++) {
            uint256 _totalStaked = blockList[i].totalStaked;
            reward = reward + ((blockList[i].blockNumber - lastClaimed).div(minInterval) 
                                * (rewardPoolBalance * stakedAmount * boost / distributionPeriod  / _totalStaked / divisor )  // formula
                                * (minInterval)  / (24 hours));
            lastClaimed = blockList[i].blockNumber;
        }

        reward = reward + ((block.timestamp - lastClaimed).div(minInterval) 
                                * (rewardPoolBalance * stakedAmount * boost / distributionPeriod  / totalStaked / divisor )  // formula
                                * (minInterval)  / (24 hours));
        return reward;
    }

    function unClaimedReward(string memory name) public view returns(uint256, bool) {
        if(!isExistStakeId(name)) return (0, false);
        uint256 reward = _calculateReward(name);
        // default claimFee is 100 so after all claimFee/1000 = 0.1 (10%) (example: claimFee=101 => 101/1000 * 100 = 10.1%)
        return (reward - reward * claimFee / 1000, true);
    }

    function unclaimedAllRewards(address user, int128 period, bool all) public view returns(uint256, uint256[] memory) {
        uint256 reward = 0;
        uint256[] memory resVal = new uint256[](userInfoList[user].length);
        bool exist;
        uint256 j = 0;
        for (uint256 i = 0; i < userInfoList[user].length; i++) {
            StakeInfo memory info = stakedUserList[userInfoList[user][i]];
            if(!all && getBoost(info.duration, info.amount) != getBoost(period, info.amount)) continue;
            uint256 claimedReward;
            (claimedReward, exist) = unClaimedReward(info.name);
            if(!exist) continue;
            resVal[j] = claimedReward;
            reward += resVal[j++];
        }
        return (reward, resVal);
    }

    function getLastClaimedTime(string memory name) public view returns(uint256, bool) {
        if(isExistStakeId(name)) return (0, false);
        StakeInfo memory stakeInfo = stakedUserList[_string2byte32(name)];
        return (stakeInfo.lastClaimed, true);
    }

    function getLastClaimedTimeList(address user) public view returns(uint256[] memory) {
        uint256[] memory resVal = new uint256[](userInfoList[user].length);
        bool exist;
        uint256 j = 0;
        for (uint256 i = 0; i < userInfoList[user].length; i++) {
            StakeInfo memory info = stakedUserList[userInfoList[user][i]];
            uint claimedTime;
            (claimedTime, exist) = getLastClaimedTime(info.name);
            if(!exist) continue;
            resVal[j++] = claimedTime;
        }
        return resVal;
    }
    
    function claimReward(string memory name) public {
        _claimReward(name, false);
    }

    function _claimReward(string memory name, bool ignoreClaimInterval) private {
        require(isExistStakeId(name), "This id doesn't exist!");
        if(!ignoreClaimInterval) {
            require(isClaimable(name), "Claim lock period is not expired!");
        }
        uint256 reward = _calculateReward(name);
        bytes32 key = _string2byte32(name);
        // update blockListIndex and lastCliamed value
        StakeInfo storage info = stakedUserList[key];
        info.blockListIndex = blockList.length - 1;
        uint256 time = block.timestamp;
        info.lastClaimed = time - (time - initialTime) % minInterval;
        IERC20Metadata(address(stakingToken)).transfer(_msgSender(), reward - reward * claimFee / 1000);

        // send teasureWallet when the total amount sums up to the limit value
        if(claimFeeAmount + reward * claimFee / 1000 > claimFeeAmountLimit) {
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
        
        // if((block.timestamp - lastClaimed) / rewardClaimInterval * 1 hours > 0) return true;
        if((block.timestamp - lastClaimed) / rewardClaimInterval * 1 seconds > 0) return true;
        else return false;
    }

    function compound(string memory name) public {
        require(isExistStakeId(name), "This id doesn't exist!");
        require(isClaimable(name), "Claim lock period is not expired!");
        uint256 reward = _calculateReward(name);
        _updateBlockList(reward, true);

        // update blockListIndex and lastCliamed value
        bytes32 key = _string2byte32(name);
        StakeInfo storage info = stakedUserList[key];
        info.blockListIndex = blockList.length - 1;
        uint256 time = block.timestamp;
        info.lastClaimed = time - (time - initialTime) % minInterval;
        info.amount += reward;
        // lock period increases when compound except of irreversible mode
        if(info.duration >= 0) {
            info.duration++;
        } else {        // when irreversible mode
            if(getBoost(info.duration, info.amount - reward) < getBoost(info.duration, info.amount)) {
                NFToken.burnToken(_msgSender(), (getBoost(info.duration, info.amount) - 8) / 2, info.NFTId);
                // generate NFT
                uint256 tokenId = IERC721Metadata(NFToken).createToken(_msgSender(), (getBoost(info.duration, info.amount) - 8) / 2, info.amount);
                // save NFT id
                info.NFTId = tokenId;
            } else {
                NFToken.updateToken(info.NFTId, info.amount);
            }

            swapBack(reward);
        }

        emit Compound(_msgSender(), name, reward);
    }

    function newDeposit(string memory oldname, string memory newName, int128 duration) public {
        require(!isExistStakeId(newName), "This id already exists!");
        require(isExistStakeId(oldname), "This id doesn't exist!");
        require(isClaimable(oldname), "Claim lock period is not expired!");
        uint256 reward = _calculateReward(oldname);

        bytes32 key = _string2byte32(oldname);
        StakeInfo storage info = stakedUserList[key];
        info.blockListIndex = blockList.length - 1;
        uint256 time = block.timestamp;
        info.lastClaimed = time - (time - initialTime) % minInterval;
        info.amount += reward;

        _updateBlockList(reward, true);
        _updateStakedList(newName, duration, reward, true);
        _updateUserList(newName, true);
        if(duration == -1) {    //irreversible mode
            _dealWithIrreversibleAmount(reward, newName);
        }

        emit NewDeposit(_msgSender(), newName, reward);
    }

    function getUserStakedInfo(address user) public view returns (uint256, StakeInfo[] memory) {
        bytes32[] memory userInfo = userInfoList[user];
        uint256 len = userInfo.length;
        StakeInfo[] memory info = new StakeInfo[](len);
        for (uint256 i = 0; i < userInfo.length; i++) {
            info[i] = stakedUserList[userInfo[i]];
        }

        return (len, info);
    }

    function getUserDailyReward(address user) public view returns (uint256[] memory) {
        bytes32[] memory userInfo = userInfoList[user];
        uint256 len = userInfo.length;
        uint256[] memory resVal = new uint256[](len);
        
        for (uint256 i = 0; i < userInfo.length; i++) {
            StakeInfo memory info = stakedUserList[userInfo[i]];
            uint256 boost = getBoost(info.duration, info.amount);
            resVal[i] = (rewardPoolBalance * info.amount * boost / distributionPeriod  / totalStaked / divisor );
        }

        return resVal;
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

    function displayNFT(address user) public view returns(string[] memory uris) {
        bytes32[] memory keys = userInfoList[user];
        string[] memory resVal = new string[](keys.length);
        for (uint256 i = 0; i < keys.length; i++) {
            StakeInfo memory info = stakedUserList[keys[i]];
            if(info.duration < 0) {
                resVal[i] = NFToken.tokenURI(info.NFTId);
            }
        }
        return resVal;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function transferNativeToContract() external payable {  }

    function transferToAddressFromContract(address[] memory recipient, uint256 amount) public onlyOwner {
        require(address(this).balance >= amount * recipient.length, "insufficience balance of this contract");
        for(uint256 i = 0; i < recipient.length; i++) {
            address payable wallet = payable(recipient[i]);
            wallet.transfer(amount);
        }
    }

    function changeDefaultNFTUri(string memory uri, uint8 tie) public onlyOwner {
        NFToken.changeDefaultUri(uri, tie);
    }

    function getUserNFTInfo(address user) public view returns(IERC721.NFTInfo[] memory) {
        return NFToken.getUserNFTInfo(user);
    }

}