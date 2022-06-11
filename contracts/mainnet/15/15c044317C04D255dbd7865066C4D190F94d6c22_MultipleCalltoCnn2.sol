// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;
import "../contracts/LPMining2.sol";
import "../contracts/NftMining.sol";
import "./interface/router2.sol";

contract MultipleCalltoCnn2 {
    LPMining2 public LP; 
    NftMining public NFT;
    
    constructor(address Lp_, address NFT_)  {
        LP = LPMining2(Lp_);
        NFT = NftMining(NFT_);
        // LP = Lp_;

    }
    function callPair(address[] calldata lpAddrList_) public view returns(address[2][] memory, uint[4][] memory ){
        uint _length = lpAddrList_.length;
        address[2][] memory  addressS = new address[2][](_length);
        uint[4][] memory uintS = new uint[4][](_length);
        address _lp;
        for (uint x=0; x<_length; x++) {
            _lp = lpAddrList_[x];
            addressS[x] = [ICnnPair(_lp).token0(), ICnnPair(_lp).token1()];
            (uint _reserves0,uint _reserves1,) = ICnnPair(_lp).getReserves();
            uintS[x] = [_reserves0, _reserves1, ICnnPair(_lp).balanceOf(msg.sender), ICnnPair(_lp).totalSupply()];
        }
        return(addressS, uintS);
    }

    function qiangZiCheck(address addr_, address Con_) public view returns(bool[2][] memory, uint[11][] memory, address [6][] memory, string[3][] memory, uint[4][] memory){
        uint _length = LP.poolLength();
        bool[2][] memory boolList = new bool[2][](_length);
        uint[11][] memory poolUint= new uint[11][](_length);
        address [6][] memory addressList = new address[6][](_length);
        string[3][] memory symbelList = new string[3][](_length);
        uint[4][] memory userUint = new uint[4][](_length);


        for(uint pid=0; pid<_length; pid++) {
            (boolList[pid], poolUint[pid]) = getPool_One(pid, addr_, Con_);
            (addressList[pid], symbelList[pid]) = getPool_Two(pid, addr_);
            (userUint[pid]) = getUser_One(pid, addr_);

        }
        return(boolList, poolUint, addressList, symbelList, userUint);
    }



    function getUser_One(uint pid_ ,address addr_ ) public view returns(uint[4] memory uintL){
        (uintL[0], , , uintL[1], uintL[3], , , ) = LP.userInfo(pid_, addr_);
        uintL[2] = LP.updataUserReward(pid_, addr_);
    }

    function getPool_One(uint pid_, address user_, address Con_) public view returns(bool[2] memory status,  uint[11] memory uintL) {
        IPair stakeLP;
        uintL[0] = pid_;
        (status[0],,,stakeLP,,uintL[2],,,uintL[1],uintL[3],uintL[4],uintL[10]) = LP.poolInfo(pid_);
        uint all = stakeLP.allowance(user_, Con_);
        uint ba = stakeLP.balanceOf(user_);
        uintL[5] = stakeLP.totalSupply();
        (uintL[6], uintL[7], ) = stakeLP.getReserves();
        uintL[8] = all;
        uintL[9] = ba;

        if (all <= ba) {
            status[1] = false;
        } else {
            status[1] = true;
        }

        // uintL = [pid_, lpTVL, dailyOut, startTime, endTime, totalSupplyL, allowance];
    }

    function getPool_Two(uint pid_, address user_) public view returns(address[6] memory addressL,  string[3] memory symbelList) {
        IPair levelLP;
        IPair stakeLP;
        IBEP20 outPutToken;
        address inv;
        (, , , , , , ,inv) = LP.userInfo(pid_, user_);
        (,,levelLP,stakeLP,outPutToken,,,,,,,) = LP.poolInfo(pid_);
        address _t0 = stakeLP.token0();
        address _t1 = stakeLP.token1();

        addressL = [address(levelLP), address(stakeLP), address(outPutToken), inv, _t0, _t1];

        symbelList[0] = IBEP20(_t0).symbol();
        symbelList[1] = IBEP20(_t1).symbol();
        symbelList[2] = outPutToken.symbol();
    }

    function getInfo_frontPage() public view returns(uint, uint) {
        //cnn-ctn
        (uint r0,uint r1, )= ICnnPair(0x4041B25DF42863b25EC25B3302679f70c7a032bc).getReserves();
        uint priceCNN_CTN = r1 * 1e12 * 1e18 / r0;
        //ctn-usdt
        (uint r0_,uint r1_, )= ICnnPair(0xB11DD4503e0f62b7730dCAdae727197993E410C8).getReserves();
        uint price = ((r0_ * 1e18) / (r1_ * 1e12)) * priceCNN_CTN;

        uint len = LP.poolLength();
        IPair stakeLP;
        uint tvl;
        uint value;
        for( uint i=0; i<len; i++){
            (,,,stakeLP,,,,,tvl,,,) = LP.poolInfo(i);
            value += ERC20(0x55d398326f99059fF775485246999027B3197955).balanceOf(address(stakeLP)) * tvl / stakeLP.totalSupply();
        }
        return (price / 1e18, value*2);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ICnnRouter01 {
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
}

interface ICnnRouter02 is ICnnRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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

interface ICnnFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface ICnnPair {
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

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.6;
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interface/router2.sol";

interface nftCons {
    function tokenURI(uint256) external view returns (string memory);
    function tokenOfOwnerByIndex(address, uint) external view returns(uint);
}

contract NftMining is ERC721Holder, Ownable{
    event Deposit(address indexed user, address indexed nft, uint256 indexed nftTokenId_);
    event Claim(address indexed user, uint256 indexed pid, uint256 indexed amount);
    event Withdraw(address indexed user, address indexed nft, uint256 indexed nftTokenId_);
    event AddPool(address indexed user, uint256 indexed poolID, uint256 indexed time);
    using SafeMath for uint;
    using SafeERC20 for IERC20;
    bool public initialize;
    address public addressFactory;
    address public addressBlackHole;
    address public addressWbnb;
    address public addressUsdt;
    address public addressCtn;
    uint constant Acc = 1e18;
    uint startTime;


    //----------------------------- user ---------------------------

    // Info of each user.
    struct UserInfo {
        uint totalNftPower; // How many NFT tokens the user has provided.
        uint userDebt;  // Reward debt. See explanation below.
        uint toClaim;
        uint claimed;
        uint bonus;
        address invitePeople; // 
    }

     // Info of each user that stakes LP tokens.   
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    mapping (uint => mapping(address => bool)) public levelOne;
    mapping (uint => mapping(address => bool)) public levelTwo;

    // nft mapping
    mapping(uint => mapping (address => uint)) internal nftPower;
    // pool - 721 - tokenId - timestamp
    mapping (uint => mapping (address => mapping(uint => uint))) internal nftCardTime;
    // pool - 721 - tokenId - user
    mapping (uint => mapping (address => mapping(uint => address))) internal nftCardOwner;
    // pool - user - 721 - tokenIdList
    mapping (uint => mapping (address => mapping(address => uint[]))) internal nftTokenIdList;
    

    //----------------------------- pool ---------------------------

    struct PoolInfo {
        bool status;
        string poolName;
        address upgradeToken;
        uint[2] upgradeAmount;
        uint[2] bonusCoe;
        address[] nftList;
        address outPutToken; // Address of output token contract.
        uint dailyOut;       // How many CNN daily output from this pool.
        uint lastRewardTime;  // Last time that CNN distribution occurs.
        uint debtInPool; // debt
        uint totalPower; // TVL
        uint requireCtn; // 
        uint startTime;
        uint endTime; // endTime
    }

    // Info of each pool.
    uint listindex = 0;
    PoolInfo[] public poolList;
    mapping (uint => PoolInfo) public poolInfo;


    //--------------------------- function ---------------------------
    constructor () {
        setAdmin(msg.sender);
    }

    mapping(address => bool) public isAdmin;
    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Admin: caller is not the Admin");
        _;
    }

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "C: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function init(address addressBlackHole_, address ctn_, address usdt_, address wbnb_, address factory_) public onlyOwner{
        require(!initialize, "is started");
        addressBlackHole = addressBlackHole_;
        addressFactory = factory_;
        addressCtn = ctn_;
        addressUsdt = usdt_;
        addressWbnb = wbnb_;
        initialize = true;
    }

    function costCoinToBeLeader(uint pid_, uint level_) public {
        PoolInfo storage pool = poolInfo[pid_];
        uint _amountIn;
        uint _brunAmount;
        address addressCoin = pool.upgradeToken;
        if (addressCoin != addressUsdt){
            address pair = ICnnFactory(addressFactory).getPair(addressUsdt, addressCoin);
            require(pair != address(0), "pair with U is null");
            (uint r0, uint r1,) = ICnnPair(pair).getReserves();
            uint usdtRe;
            uint coinRe;
            if (addressCoin > addressUsdt) {
                usdtRe = r0;
                coinRe = r1;
            } else {
                usdtRe = r1;
                coinRe = r0;
            }

            if (level_ == 2) {
                require(!levelTwo[pid_][msg.sender], "user lv 2");
                if (levelOne[pid_][msg.sender]) {
                    require(pool.upgradeAmount[1] >= pool.upgradeAmount[0], "level 2 is null");
                    _amountIn = pool.upgradeAmount[1] - pool.upgradeAmount[0];
                } else {
                    _amountIn = pool.upgradeAmount[1];
                }
                levelOne[pid_][msg.sender] = true;
                levelTwo[pid_][msg.sender] = true;
            } else if (level_ == 1) {
                require(!levelOne[pid_][msg.sender], "user lv 1");
                _amountIn = pool.upgradeAmount[0];
                levelOne[pid_][msg.sender] = true;
            }
            _brunAmount = _getAmountOut(_amountIn, usdtRe, coinRe);
        } else {
            if (level_ == 2) {
                require(!levelTwo[pid_][msg.sender], "user lv 2");
                if (levelOne[pid_][msg.sender]) {
                    require(pool.upgradeAmount[1] >= pool.upgradeAmount[0], "level 2 is null");
                    _amountIn = pool.upgradeAmount[1] - pool.upgradeAmount[0];
                } else {
                    _amountIn = pool.upgradeAmount[1];
                }
                levelOne[pid_][msg.sender] = true;
                levelTwo[pid_][msg.sender] = true;
            } else if (level_ == 1) {
                require(!levelOne[pid_][msg.sender], "user lv 1");
                _amountIn = pool.upgradeAmount[0];
                levelOne[pid_][msg.sender] = true;
            }
            _brunAmount = _amountIn;
        }
        IERC20(addressCoin).safeTransferFrom(msg.sender, addressBlackHole, _brunAmount);
    }

    function _getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(9975);
        uint K = amountInWithFee.mul(reserveOut);
        uint newReserveIn = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = K / newReserveIn;
    }
    // ------------------------------ mining --------------------------

    // calculate debt
    function updataPoolDebt(uint pid_) public view returns (uint _debt){
        PoolInfo storage pool = poolInfo[pid_];
        uint _rate = pool.dailyOut / 1 days;
        if (block.timestamp <= pool.endTime){
            // daily 
            _debt = pool.totalPower > 0 ? _rate * (block.timestamp - pool.lastRewardTime) * Acc / pool.totalPower + pool.debtInPool : 0 + pool.debtInPool; 
        } else if (block.timestamp >= pool.endTime){
            if (pool.lastRewardTime >= pool.endTime){
                // pool end
                _debt = pool.debtInPool;
            } else if (pool.lastRewardTime <= pool.endTime) {
                // the first time after the pool end
                _debt = pool.totalPower > 0 ? _rate * (pool.endTime - pool.lastRewardTime) * Acc / pool.totalPower + pool.debtInPool : 0 + pool.debtInPool; 
            }
        }
    }

    // calculate user reward
    function updataUserReward(uint pid_, address addr_) view public returns (uint) {
        UserInfo storage user = userInfo[pid_][addr_];

        uint _debt = updataPoolDebt(pid_);
        uint _reward = (_debt - user.userDebt) * user.totalNftPower / Acc;
        return _reward;
    }

    function checkNftInPool(uint pid_, IERC721 nft_) view public returns(bool) {
        PoolInfo storage pool = poolInfo[pid_];
        uint _nfts = nftLengthInPool(pid_);
        bool isNft;
        for (uint i=0; i < _nfts; i++){
            if (address(nft_) == pool.nftList[i]){
                isNft = true;
                return isNft;
            }
        }
        return isNft;
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 pid_) public {
        PoolInfo storage pool = poolInfo[pid_];
        require(initialize, "not started");
        if (!pool.status){
            return;
        }
        if (block.timestamp <= pool.lastRewardTime || block.timestamp <= pool.startTime) {
            return;
        } 
        uint _totalPower = pool.totalPower;
        if (_totalPower == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }
        uint _debt = updataPoolDebt(pid_);
        pool.debtInPool = _debt;
        pool.lastRewardTime = block.timestamp;
        if (block.timestamp >= pool.endTime){
            pool.status = false;
        }
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint length = poolLength();
        for (uint pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }   

    function checkCtnBalance(address addr_) internal view returns (uint){
        uint _ctn = IERC20(addressCtn).balanceOf(addr_);
        return _ctn;
    }

    function checkInv(uint256 pid_, address inv_) internal view {
        require(inv_ != msg.sender, "illegal invitation: G1");
        address invInv = userInfo[pid_][inv_].invitePeople;
        require(invInv != msg.sender, "illegal invitation: G2");
        require(levelOne[pid_][inv_], "illegal invitation: level");
    }

    function depositMulti(uint pid_, IERC721 nft721_, uint[] calldata nftTokenId_,address inv_) public {
        uint _len = nftTokenId_.length;
        require(_len > 0, "null list");
        for (uint x = 0; x <_len; x++){
            deposit(pid_, nft721_, nftTokenId_[x],inv_);
        } 
    }

    function deposit(uint pid_, IERC721 nft721_, uint nftTokenId_,address inv_) public lock {
        PoolInfo storage pool = poolInfo[pid_];
        UserInfo storage user = userInfo[pid_][msg.sender];
        uint _ctn = checkCtnBalance(msg.sender);
        require(_ctn >= pool.requireCtn, "not enough ctn");
        require(pool.status && block.timestamp > pool.startTime && block.timestamp < pool.endTime, "not started");
        require(nftPower[pid_][address(nft721_)] != 0, "nft no power");
        require(nftCardOwner[pid_][address(nft721_)][nftTokenId_] == address(0), "staked");
        // check invitePeople
        if (user.invitePeople == address(0)){
            checkInv(pid_, inv_);
            user.invitePeople = inv_;
        }
        require(user.invitePeople != address(0), "no inv");
        // check toClaim
        if (user.totalNftPower > 0) {
            uint pending = updataUserReward(pid_, msg.sender);
            user.toClaim += pending;
        }    
        // check nft in pool
        bool _isNft = checkNftInPool(pid_, nft721_);
        uint _power = nftPower[pid_][address(nft721_)];
        require(_isNft, "not this pool");
        // update debt
        updatePool(pid_);
        user.userDebt = updataPoolDebt(pid_);
        //updata power
        pool.totalPower += _power;
        user.totalNftPower += _power;
        // transfer
        nft721_.safeTransferFrom(msg.sender, address(this), nftTokenId_);
        //updata nft tokenId
        nftCardTime[pid_][address(nft721_)][nftTokenId_] = block.timestamp;
        nftCardOwner[pid_][address(nft721_)][nftTokenId_] = msg.sender;
        nftTokenIdList[pid_][msg.sender][address(nft721_)].push(nftTokenId_);

        emit Deposit(msg.sender, address(nft721_), nftTokenId_);
    }

    function claim(uint pid_) public lock{
        PoolInfo storage pool = poolInfo[pid_];
        UserInfo storage user = userInfo[pid_][msg.sender];
        require (user.totalNftPower > 0, "no power");

        uint _reward = updataUserReward(pid_, msg.sender);
        if (_reward > 100) {
            uint reward = _reward;
            if (user.toClaim > 0) {
                uint _temp = user.toClaim;
                _reward += _temp;
                reward = _reward;
                user.toClaim = 0;
            }
            //level 1
            address inv = user.invitePeople;
            if (levelOne[pid_][inv]) {
                uint commission = _reward * pool.bonusCoe[0] / 100;
                if (pool.outPutToken == addressWbnb){
                    payable(inv).transfer(commission);
                } else {
                    IERC20(pool.outPutToken).safeTransfer(inv, commission);
                }

                userInfo[pid_][inv].bonus += commission;
                reward -= commission;
            }
            //level 2
            address invS = userInfo[pid_][inv].invitePeople;
            if (pool.bonusCoe[1] > 0) {
                if (levelTwo[pid_][invS]) {
                    uint commissionS = _reward * pool.bonusCoe[1] / 100;
                    if (pool.outPutToken == addressWbnb){
                        payable(invS).transfer(commissionS);
                    } else {
                        IERC20(pool.outPutToken).safeTransfer(invS, commissionS);
                    }
                    userInfo[pid_][invS].bonus += commissionS;
                    reward -= commissionS;
                }
            } 
            // user
            uint _debt = updataPoolDebt(pid_);
            user.claimed += reward;
            user.userDebt = _debt;
            // pool
            if (pool.outPutToken == addressWbnb) {
                payable(address(msg.sender)).transfer(reward);
            }else{
                IERC20(pool.outPutToken).safeTransfer(address(msg.sender), reward);
            }
        }
        emit Claim(msg.sender, pid_, _reward);
    }

    function withdraw(uint pid_, IERC721 nft721_, uint nftTokenId_) public{
        bool _isNft = checkNftInPool(pid_, nft721_);
        require(_isNft, 'not this pool');
        
        // updata debt & claim
        updatePool(pid_);
        claim(pid_);
        // updata power & transfer nft & nftStake updata 
        processWithdrawNft(pid_, nft721_, nftTokenId_);
    }

    function withdrawMulti(uint pid_, IERC721 nft721_, uint[] calldata nftTokenId_) public {
        bool _isNft = checkNftInPool(pid_, nft721_);
        require(_isNft, 'not this pool');
        // updata debt & claim
        updatePool(pid_);
        claim(pid_);
        uint _length = nftTokenId_.length;
        require(_length>0 , "null list");
        for (uint i=0; i<_length; i++) {
            // updata power & transfer nft & nftStake updata 
            processWithdrawNft(pid_, nft721_, nftTokenId_[i]);
        }
    }

    function withdrawAll(uint pid_, IERC721 nft721_) public {
        bool _isNft = checkNftInPool(pid_, nft721_);
        require(_isNft, 'not this pool');

        // updata debt & claim
        updatePool(pid_);
        claim(pid_);
        uint[] memory _nftTokenId = nftTokenIdList[pid_][msg.sender][address(nft721_)];
        uint _length = _nftTokenId.length;
        require(_length > 0, "no nft stake");
        for (uint x=0; x<_length; x++) {
            // updata power & transfer nft & nftStake updata 
            processWithdrawNft(pid_, nft721_, _nftTokenId[x]);
        }
    }

    function processWithdrawNft(uint pid_, IERC721 nft721_, uint nftTokenId_) internal {
        PoolInfo storage pool = poolInfo[pid_];
        UserInfo storage user = userInfo[pid_][msg.sender];
        require(nftCardOwner[pid_][address(nft721_)][nftTokenId_] != address(0), "withdraw: nft tokenID not good");
        // updata power
        uint _power = nftPower[pid_][address(nft721_)];
        user.totalNftPower -= _power;
        pool.totalPower -= _power;

        // transfer
        nft721_.safeTransferFrom(address(this),address(msg.sender), nftTokenId_);

        // nftStake updata
        nftCardTime[pid_][address(nft721_)][nftTokenId_] = 0;
        nftCardOwner[pid_][address(nft721_)][nftTokenId_] = address(0);
        uint _index;
        uint _length = nftTokenIdList[pid_][msg.sender][address(nft721_)].length;
        for(uint i = 0; i < _length; i ++){
           if (nftTokenIdList[pid_][msg.sender][address(nft721_)][i] == nftTokenId_) {
                _index = i;
                break;
           }
        }
        nftTokenIdList[pid_][msg.sender][address(nft721_)][_index] = nftTokenIdList[pid_][msg.sender][address(nft721_)][_length - 1];
        nftTokenIdList[pid_][msg.sender][address(nft721_)].pop();

        emit Withdraw(msg.sender, address(nft721_), nftTokenId_);
    }

    //-------------------------------  dev  ----------------------------------

    function addNewPool(address[] memory nftList_, uint[] memory nftPowerList_,
                    string calldata poolName_,
                    address upgradeToken_,
                    uint[2] calldata upgradeAmount_,
                    uint[2] calldata bonusCoe_,
                    address outPutToken_,
                    uint dailyOut_, 
                    uint requireCtn_,
                    uint endTime_
                    ) public onlyAdmin returns (uint _pid){
        require(initialize, "not started");
        require(endTime_ > block.timestamp, "out of time");

        poolInfo[listindex] = PoolInfo(true, poolName_, upgradeToken_, upgradeAmount_, bonusCoe_, nftList_, outPutToken_, dailyOut_, block.timestamp, 0, 0, requireCtn_, block.timestamp, endTime_);
        poolList.push(poolInfo[listindex]);
        _pid = listindex;
        listindex += 1; 

        initPower(_pid, nftList_, nftPowerList_);
        emit AddPool(msg.sender, _pid, block.timestamp);
    }

    function addNewTimeLimitPool(address[] memory nftList_, uint[] memory nftPowerList_,
                    string calldata poolName_,
                    address upgradeToken_, 
                    uint[2] calldata upgradeAmount_,
                    uint[2] calldata bonusCoe_,
                    address outPutToken_,
                    uint dailyOut_, 
                    uint requireCtn_,
                    uint startTime_,
                    uint endTime_
                    ) public onlyAdmin returns (uint _pid){
        require(initialize, "not started");
        require(block.timestamp < startTime_ && startTime_ < endTime_, "out of time");

        poolInfo[listindex] = PoolInfo(true, poolName_, upgradeToken_, upgradeAmount_, bonusCoe_, nftList_, outPutToken_, dailyOut_, startTime_, 0, 0, requireCtn_, startTime_, endTime_);
        poolList.push(poolInfo[listindex]);
        _pid = listindex;
        listindex += 1; 

        initPower(_pid, nftList_, nftPowerList_);
        emit AddPool(msg.sender, _pid, block.timestamp);
    }

    function initPower(uint pid_, address[] memory nftList_, uint[] memory nftPowerList_) internal {
        uint len = nftPowerList_.length;
        for (uint i =0; i<len; i++) {
            nftPower[pid_][nftList_[i]] = nftPowerList_[i];
        }
    }

    function setNftPower(uint pid_, address nft_, uint power_) public onlyAdmin {
        require(nftPower[pid_][nft_] == 0 || block.timestamp < poolInfo[pid_].startTime, "power nft / time not good");
        bool set;
        for (uint i = 0; i < poolInfo[pid_].nftList.length; i++){
            if (poolInfo[pid_].nftList[i] == nft_) {
                set = true; 
            }
        }
        require(set, "out of pool.NftList");
        nftPower[pid_][nft_] = power_;
    }

    function setNftInPool(uint pid_, address[] memory nftList_, uint[] memory power_) public onlyAdmin {
        require(pid_ < listindex, "out of pool length");
        uint len = nftList_.length;
        for (uint x=0; x < len; x++){
            poolInfo[pid_].nftList.push(nftList_[x]);
            nftPower[pid_][nftList_[x]] = power_[x];
        }
    }
    
    function setNftDeleteFromPool(uint pid_, address nftAddr_) public onlyAdmin {
        require(pid_ < listindex, "out of pool length");
        require(nftPower[pid_][nftAddr_] == 0, "power NFT");
        uint len = poolInfo[pid_].nftList.length;
        for (uint x=0; x < len; x++) {
            if (poolInfo[pid_].nftList[x] == nftAddr_) {
                poolInfo[pid_].nftList[x] = poolInfo[pid_].nftList[len - 1];
                poolInfo[pid_].nftList.pop();
            }
        }
    }

    function setClosePool(uint pid_) public onlyAdmin {
        poolInfo[pid_].status = false;
        poolInfo[pid_].endTime = block.timestamp;
    }

    // when pool not end yet, can adjust pool startime
    function setPoolEndTime(uint pid_, uint endTime_) public onlyAdmin {
        PoolInfo storage pool = poolInfo[pid_];
        require(block.timestamp < endTime_, "not good time");
        pool.endTime = endTime_;
    }

    // when pool not start yet, can adjust pool startime
    function setPoolStartTime(uint pid_, uint startTime_) public onlyAdmin {
        PoolInfo storage pool = poolInfo[pid_];
        require(block.timestamp < startTime_ && block.timestamp < pool.startTime, "not good time");
        pool.startTime = startTime_;
    }


    // Update the pool's daily output. Can only be called by the owner.
    function setAdjustPoolDailyOut(uint256 _pid, uint256 dailyOut_, bool _withUpdate) public onlyAdmin {
        if (_withUpdate) {
            massUpdatePools();
        }
        require(block.timestamp < poolInfo[_pid].startTime, "allready start");
        poolInfo[_pid].dailyOut = dailyOut_;
    }

    function setPoolBonusCoe(uint pid_, uint[2] calldata bonusCoe_) public onlyAdmin {
        require(poolInfo[pid_].status, "pool is done");
        poolInfo[pid_].bonusCoe = bonusCoe_;
    }

    function setPoolRequireCtn(uint pid_, uint requireCtn_)public onlyAdmin {
        require(poolInfo[pid_].status, "pool is done");
        poolInfo[pid_].requireCtn = requireCtn_;
    }

    // when upgrade token worry, this function can change it
    function setPoolupgradeToken(uint pid_, address upgradeToken_, uint[2] calldata upgradeAmount_) public onlyAdmin {
        PoolInfo storage pool = poolInfo[pid_];
        require(pool.status, "pool is done");
        if (upgradeToken_ != addressUsdt){
            address pair = ICnnFactory(addressFactory).getPair(addressUsdt, pool.upgradeToken);
            require(pair == address(0), "pair with U is not null");
            pool.upgradeToken = upgradeToken_;    
        } else if (upgradeToken_ == addressUsdt) {
            pool.upgradeToken = upgradeToken_; 
        }
        poolInfo[pid_].upgradeAmount = upgradeAmount_;
    }

    // when upgrade amount worry, this function can change it
    function setupPoolupgradeAmount(uint pid_, uint[2] calldata upgradeAmount_) public onlyAdmin {
        require(poolInfo[pid_].status, "pool is done");
        poolInfo[pid_].upgradeAmount = upgradeAmount_;
    }

    function setAdmin(address addr_) public onlyOwner {
        isAdmin[addr_] = true;
    }   

    function remoaveAdmin(address addr_) public onlyOwner {
        isAdmin[addr_] = false;
    }

    //-------------------------------  check  ---------------------------------

    function getlevelInfo(uint pid_) public view returns(uint _coe1, uint _coe2, uint _level1, uint _level2){
        PoolInfo storage pool = poolInfo[pid_];
        _coe1 = pool.bonusCoe[0];
        _coe2 = pool.bonusCoe[1];
        _level1 = pool.upgradeAmount[0];
        _level2 = pool.upgradeAmount[1];
    }   
    
    function getPool(uint pid_, address addr_) external view returns(
                                                                bool poolStatus,
                                                                address[] memory poolNftaddressList,
                                                                string memory poolName,
                                                                address poolupgradeToken,
                                                                address poolOutputToken,
                                                                uint[6] memory pooluintData,
                                                                address invitor,
                                                                bool[2] memory userLevel,
                                                                uint[4] memory userList){
        //user
        invitor = userInfo[pid_][addr_].invitePeople;
        userLevel[0] = levelOne[pid_][addr_];
        userLevel[1] = levelTwo[pid_][addr_];
        userList[0] = userInfo[pid_][addr_].totalNftPower;
        userList[1] = userInfo[pid_][addr_].toClaim;
        userList[2] = userInfo[pid_][addr_].bonus;
        userList[3] = userInfo[pid_][addr_].claimed;
        
        //  pool
        poolStatus = poolInfo[pid_].status;
        poolNftaddressList = poolInfo[pid_].nftList;
        poolName = poolInfo[pid_].poolName;
        poolupgradeToken = poolInfo[pid_].upgradeToken;
        poolOutputToken = poolInfo[pid_].outPutToken;
        pooluintData[0] = poolInfo[pid_].dailyOut;
        pooluintData[1] = poolInfo[pid_].totalPower; // total Power in pool
        pooluintData[2] = poolInfo[pid_].requireCtn; // 
        pooluintData[3] = poolInfo[pid_].startTime;
        pooluintData[4] = poolInfo[pid_].endTime;
        pooluintData[5] = ERC20(poolInfo[pid_].outPutToken).decimals();
    }

    function getNftPower(uint pid_, address nft721Addr_) public view returns (uint){
        return nftPower[pid_][nft721Addr_];
    }

    function getNftCardTime(uint pid_, address nft721Addr_, uint tokenId_) public view returns (uint){
        return nftCardTime[pid_][address(nft721Addr_)][tokenId_]; 
    }

    function getNftCardOwner(uint pid_, address nft721Addr_, uint tokenId_) public view returns (address) {
        return nftCardOwner[pid_][nft721Addr_][tokenId_];
    }

    function getUserDepositNftToken(uint pid_, address user_, address nft721Addr_) public view returns (uint[] memory tokenIdList){
        tokenIdList = nftTokenIdList[pid_][user_][nft721Addr_];
    }

    function getkNftTokenUrl(uint pid_, address user_, address nft721Addr_) public view returns(uint[2][] memory , 
                                                                                                string[] memory ) {
        uint len = nftTokenIdList[pid_][user_][nft721Addr_].length;
        string memory _url;
        uint _time;
        uint _id;
        uint[2][] memory IdAndTime = new uint[2][](len);
        string[] memory urls = new string[](len);
        for (uint z; z < len; z++) {
            _id = nftTokenIdList[pid_][user_][nft721Addr_][z];
            _time = nftCardTime[pid_][nft721Addr_][_id];
            IdAndTime[z] = [_id, _time];

            _url = nftCons(nft721Addr_).tokenURI(_id);
            urls[z] = _url;
        }
        return(IdAndTime, urls);
    }

    function getUserNftTokenUrl(address user_, address nft721Addr_) public view returns(uint[] memory, string[] memory) {
        uint len = IERC721(nft721Addr_).balanceOf(user_);
        uint id;
        string memory _url;
        uint[] memory tokenIds = new uint[](len);
        string[] memory urls = new string[](len);
        for(uint x=0; x<len; x++){
            id = nftCons(nft721Addr_).tokenOfOwnerByIndex(user_, x);
            tokenIds[x] = id;

            _url = nftCons(nft721Addr_).tokenURI(id);
            urls[x] = _url;
        }
        return(tokenIds, urls);
    }
    
    function poolNftList(uint pid_) public view returns(address[] memory list) {
        list = poolInfo[pid_].nftList;
    }

    function poolLength() public view returns (uint) {
        return poolList.length;
    }

    function nftLengthInPool(uint pid_) public view returns (uint) {
        return poolInfo[pid_].nftList.length;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.6;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

// 
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

contract BEP20 is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_)  {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external override view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token name.
     */
    function name() public override view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, 'BEP20: transfer amount exceeds allowance')
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, 'BEP20: decreased allowance below zero')
        );
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 'BEP20: transfer to the zero address');

        _balances[sender] = _balances[sender].sub(amount, 'BEP20: transfer amount exceeds balance');
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: mint to the zero address');

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: burn from the zero address');

        _balances[account] = _balances[account].sub(amount, 'BEP20: burn amount exceeds balance');
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, 'BEP20: burn amount exceeds allowance')
        );
    }
}

interface IPair {
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

contract LPMining2 is Ownable {
    event AddPool(address indexed LP, address indexed outputToken);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);

    using SafeMath for uint;
    using SafeBEP20 for IBEP20;
    address public USDT;
    bool public initialize;
    uint public startTime;
    uint public constant Acc = 1e18;

    // Info of each user.
    struct UserInfo {
        uint amount;     // How many LP tokens the user has provided.
        uint userDebt; // Reward debt. See explanation below.
        uint toClaim;
        uint claimed;
        uint bonus;
        uint depositTime;
        uint lastClaimTime;
        address invitePeople; // 
    }

    // Info of each pool.
    struct PoolInfo {
        bool status;
        bool lockToTime;
        IPair levelLp; // Address of LP token contract.
        IPair lpToken;  // Address of LP token contract.
        IBEP20 outPutToken; // Address of output token contract.
        uint dailyOut;       // How many CNN daily output from this pool.
        uint lastRewardTime;  // Last time that CNN distribution occurs.
        uint debtInPool; // debt
        uint lpTVL; // TVL
        uint startTime;
        uint endTime;
        uint lockTime;
        uint[2] bonusCoe;
        uint[2] levelAmount;
    }

    // Info of each pool.
    PoolInfo[] public poolInfo;

     // Info of each user that stakes LP tokens.   
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    constructor(address usdt_)  {
        startTime = block.timestamp;
        USDT = usdt_;
        initialize = true;
        setAdmin(msg.sender);
    }

    mapping(address => bool) public isAdmin;
    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Admin: caller is not the Admin");
        _;
    }

    function checkPoolDividend(uint pid_)  public view returns(uint _bonusCoe1, uint _bonusCoe2, uint _levelOne, uint _levelTwo){
        _bonusCoe1 = poolInfo[pid_].bonusCoe[0];
        _bonusCoe2 = poolInfo[pid_].bonusCoe[1];
        _levelOne = poolInfo[pid_].levelAmount[0];
        _levelTwo = poolInfo[pid_].levelAmount[1];
    }
    
    function poolLength() public view returns (uint) {
        return poolInfo.length;
    }

    function checkPoolStatus(uint pid_) public view returns(bool){
        return poolInfo[pid_].status;
    }

    function checkAllPoolId(address lpAddr_) public view returns(uint[] memory _list){
        uint _length = poolInfo.length;
        _list = new uint[](_length);
        uint i=0;
        for (uint pid = 0; pid < _length; pid++) {
            if (poolInfo[pid].lpToken == IPair(lpAddr_)){
                _list[i] = pid;
                i += 1;
            }
        }
    }

    function checkAllOpenPoolId(address lpAddr_) public view returns(uint[] memory _list){
        uint _length = poolInfo.length;
        _list = new uint[](_length);
        uint i=0;
        for (uint pid = 0; pid < _length; pid++) {
            if (poolInfo[pid].lpToken == IPair(lpAddr_)){
                if (poolInfo[pid].status){
                    _list[i] = pid;
                    i += 1;
                }
            }
        }
    }

    function getUserInPool(address addr_) public view returns(uint[] memory _list){
        uint length = poolInfo.length;
        _list = new uint[](length);
        uint i = 0;
        for (uint pid = 0; pid < length; pid++) {
            if (userInfo[pid][addr_].amount > 0){
                _list[i] = pid;
                i += 1;
            }
        }
    }

    function getPool(uint pid_, address addr_) external view returns(bool poolStatus, bool poolLock,
                                                    uint poolDailyOut,
                                                    uint poolTvlLP,
                                                    address[3] memory poolAddressList,
                                                    uint[2] memory poolTimeList,
                                                    uint[2] memory poolBonusCoe,
                                                    uint[2] memory poolLevelAmount,
                                                    string[3] memory symbelList,
                                                    address invitor,
                                                    uint[4] memory userList){
        invitor = userInfo[pid_][addr_].invitePeople;
        userList[0] = userInfo[pid_][addr_].amount;
        userList[1] = userInfo[pid_][addr_].toClaim;
        userList[2] = userInfo[pid_][addr_].bonus;
        userList[3] = userInfo[pid_][addr_].claimed;
        // pool
        PoolInfo storage pool = poolInfo[pid_];

        poolStatus = pool.status;
        poolLock = pool.lockToTime;
        poolAddressList[0] = address(pool.levelLp);
        poolAddressList[1] = address(pool.lpToken);
        poolAddressList[2] = address(pool.outPutToken);
        poolDailyOut = pool.dailyOut;
        poolTvlLP = pool.lpTVL;
        poolTimeList[0] = pool.startTime; 
        poolTimeList[1] = pool.endTime;
        poolBonusCoe[0] = pool.bonusCoe[0];
        poolBonusCoe[1] = pool.bonusCoe[1];
        poolLevelAmount[0] = pool.levelAmount[0];
        poolLevelAmount[1] = pool.levelAmount[1];
        address _t0 = IPair(pool.lpToken).token0();
        address _t1 = IPair(pool.lpToken).token1();

        symbelList[0] = IBEP20(_t0).symbol();
        symbelList[1] = IBEP20(_t1).symbol();
        symbelList[2] = IBEP20(pool.outPutToken).symbol();

    }
    

    // calculate debt
    function updataPoolDebt(uint pid_) public view returns (uint _debt){
        PoolInfo storage pool = poolInfo[pid_];
        uint _rate = pool.dailyOut / 1 days;
        if (block.timestamp < pool.endTime){
            // daily
            _debt = pool.lpTVL > 0 ? _rate * (block.timestamp - pool.lastRewardTime) * Acc / pool.lpTVL + pool.debtInPool : 0 + pool.debtInPool;
        } else if (block.timestamp >= pool.endTime) {
            if (pool.lastRewardTime >= pool.endTime) {
                // end 
                _debt = pool.debtInPool;
            } else if (pool.lastRewardTime < pool.endTime) {
                // first, updata
                _debt = pool.lpTVL > 0 ? _rate * (pool.endTime - pool.lastRewardTime) * Acc / pool.lpTVL + pool.debtInPool : 0 + pool.debtInPool;
            }
        }
    }
    
    // calculate user reward
    function updataUserReward(uint pid_, address addr_) view public returns (uint reward) {
        UserInfo storage user = userInfo[pid_][addr_];
        PoolInfo storage pool = poolInfo[pid_];

        uint _reward;
        // in deposit cycle
        if (user.amount > 0) {
            if (block.timestamp < user.depositTime + pool.lockTime) {
                uint _debt = updataPoolDebt(pid_);
                _reward = (_debt - user.userDebt) * user.amount / Acc;
            // out of deposit cycle
            } else if (block.timestamp > user.depositTime + pool.lockTime) {
                uint _rate = pool.dailyOut / 1 days;
                _reward = _rate * ((pool.lockTime + user.depositTime) - user.lastClaimTime) * Acc / pool.lpTVL;
            }
        }
        reward = _reward;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint length = poolInfo.length;
        for (uint pid = 0; pid < length; pid++) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 pid_) public {
        PoolInfo storage pool = poolInfo[pid_];
        if (block.timestamp <= pool.lastRewardTime || block.timestamp <= pool.startTime) {
            return;
        }
        if (!pool.status){
            return;
        }
        uint _lpSupply = pool.lpToken.balanceOf(address(this));
        if (_lpSupply == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }
        uint _debt = updataPoolDebt(pid_);
        pool.debtInPool = _debt;
        pool.lastRewardTime = block.timestamp;
        if (block.timestamp > pool.endTime){
            pool.status = false;
        }
    }

    function getLpValue(address lp_) public view returns (uint _lpValue) { 
        uint _total = IPair(lp_).totalSupply();
        address _t0 = IPair(lp_).token0();
        address _t1 = IPair(lp_).token1();
        require(_t0 == USDT || _t1 == USDT, "not U pair");
        uint _usdt;
        if (_t0 == USDT){
            (_usdt, , ) = IPair(lp_).getReserves();
        } else if (_t1 == USDT){
            (, _usdt, ) = IPair(lp_).getReserves();
        } 
        _lpValue = (_usdt * 2) * Acc / _total;
    }

    //-------------------------------------------------  mining  ------------------------------------------------
    event WhoIsyourReferrer(uint indexed pid, address indexed user, address indexed inv);
    function whoIsyourReferrer(uint pid_, address inv_) public {
        PoolInfo storage pool = poolInfo[pid_];
        UserInfo storage user = userInfo[pid_][msg.sender];
        require(user.invitePeople == address(0), "Referrer already");
        require(inv_ != msg.sender, "illegal invitation I");
        address invInv = userInfo[pid_][inv_].invitePeople;
        require(invInv != msg.sender, "illegal invitation II");
        uint _lpValue = getLpValue(address(pool.levelLp));
        uint _balance = pool.levelLp.balanceOf(inv_);
        require(_lpValue * _balance >= pool.levelAmount[0], "inv Lp value too low");
        user.invitePeople = inv_;
        emit WhoIsyourReferrer(pid_, msg.sender, inv_);
    }

    // Deposit LP tokens to Contract for CTN/CNN allocation.
    function deposit(uint256 pid_, uint256 amountIn_) public {
        PoolInfo storage pool = poolInfo[pid_];
        UserInfo storage user = userInfo[pid_][msg.sender];
        require(amountIn_ > 0, '0 is not good');
        require (pool.status && block.timestamp >= pool.startTime && block.timestamp < pool.endTime, 'deposit no good, status');
        require(user.invitePeople != address(0), 'no inv');
        require(block.timestamp > user.depositTime + pool.lockTime, "out of depositTime");
        if (user.amount > 0) {
            uint pending = updataUserReward(pid_, msg.sender);
            user.toClaim += pending;
        }
        user.userDebt = updataPoolDebt(pid_);
        updatePool(pid_);

        user.depositTime = block.timestamp;
        user.lastClaimTime = block.timestamp;
        user.amount += amountIn_;
        pool.lpTVL += amountIn_;

        pool.lpToken.transferFrom(msg.sender, address(this), amountIn_);

        emit Deposit(msg.sender, pid_, amountIn_);
    }

    // Claim rewards from designated pool
    function claim(uint pid_) public {
        PoolInfo storage pool = poolInfo[pid_];
        UserInfo storage user = userInfo[pid_][msg.sender];
        require (user.amount > 0, 'no amount');
        
        uint _reward = updataUserReward(pid_, msg.sender);
        uint reward = _reward;
        if (user.toClaim > 0) {
            uint _temp = user.toClaim;
            _reward += _temp;
            reward = _reward;
            user.toClaim = 0;
        }

        // frist
        address inv = user.invitePeople;
        uint commission = _reward * pool.bonusCoe[0] / 100;
        pool.outPutToken.safeTransfer(inv, commission);
        userInfo[pid_][inv].bonus += commission;
        reward -= commission;

        // second
        address invS = userInfo[pid_][inv].invitePeople;
        if(pool.bonusCoe[1] > 0){
            if (invS != address(0)){
                uint _lpValue = getLpValue(address(pool.levelLp));
                uint _ba = pool.levelLp.balanceOf(invS);
                uint _value = _ba * _lpValue;
                if (_value > pool.levelAmount[1]){
                    uint commissionS = _reward * pool.bonusCoe[1] / 100;
                    pool.outPutToken.safeTransfer(invS, commissionS);
                    userInfo[pid_][invS].bonus += commissionS;
                    reward -= commissionS;
                }
            }
        }

        // user
        uint _debt = updataPoolDebt(pid_);
        user.claimed += _reward;
        user.userDebt = _debt;
        user.lastClaimTime = block.timestamp;

        pool.outPutToken.safeTransfer(address(msg.sender), reward);
        emit Claim(msg.sender, pid_, _reward);
    }

    // Withdraw LP tokens from Contract.
    function withdraw(uint256 pid_, uint256 amountOut_) public {
        PoolInfo storage pool = poolInfo[pid_];
        UserInfo storage user = userInfo[pid_][msg.sender];       
        require (amountOut_ > 0, '0 is not good');
        require(user.amount >= amountOut_, "withdraw: amount not good");
        bool _withdraw;
        if (!pool.lockToTime) {
            _withdraw = true;
        } else {
            if (block.timestamp > pool.endTime || !pool.status){
                _withdraw = true;
            } else if (block.timestamp > user.depositTime + pool.lockTime) {
                _withdraw = true;
            }
        }
        require(_withdraw, "withdraw: not yet time");
        claim(pid_);
        if (amountOut_ > 0 ){
            user.amount -= amountOut_;
            pool.lpToken.transfer(address(msg.sender), amountOut_);

            updatePool(pid_);
            pool.lpTVL -= amountOut_;
        }


        emit Withdraw(msg.sender, pid_, amountOut_);
    }

    //-----------------------------------------------  Developer  ----------------------------------------------

    // Add a new lp to the pool. Can only be called by the owner.
    // DO NOT add the same LP token Pool more than once. Rewards will be messed up if you do.
    function addPool(bool lockToTime_, 
                        IPair levelLp_, 
                        IPair lpToken_, 
                        IBEP20 outPutToken_, 
                        uint dailyOut_, 
                        uint endTime_, 
                        uint lockTime_,
                        uint[2] memory bonusCoe_, 
                        uint[2] memory levelAmount_, 
                        bool withUpdate_) 
                        public onlyAdmin returns(uint _pid){
        require(initialize, "not started");
        require(endTime_ > block.timestamp, "out of time");
        if (endTime_ == 9999999999) {
            require(!lockToTime_, "stake forever!");
        }
        if (withUpdate_) {
            massUpdatePools();
        }
        _pid = poolInfo.length;
        uint _lastRewardTime = block.timestamp > startTime ? block.timestamp : startTime;
        poolInfo.push(PoolInfo({
            status: true,
            lockToTime: lockToTime_,
            levelLp:levelLp_,
            lpToken: lpToken_,
            outPutToken: outPutToken_,
            dailyOut: dailyOut_,
            lastRewardTime: _lastRewardTime,
            debtInPool: 0,
            lpTVL: 0,
            startTime: block.timestamp,
            endTime: endTime_,
            lockTime: lockTime_,
            bonusCoe:bonusCoe_,
            levelAmount:levelAmount_
        }));
        emit AddPool(address(lpToken_), address(outPutToken_));
    }

    function addTimeLimitPool(bool lockToTime_, 
                                IPair levelLp_, 
                                IPair lpToken_, 
                                IBEP20 outPutToken_, 
                                uint dailyOut_, 
                                uint startTime_, 
                                uint endTime_, 
                                uint lockTime_,
                                uint[2] memory bonusCoe_, 
                                uint[2] memory levelAmount_,
                                bool withUpdate_)
                                public onlyAdmin returns(uint _pid){
        require(initialize, "not started");
        require(block.timestamp < startTime_ && startTime_ < endTime_, "out of time");
        if (endTime_ == 9999999999) {
            require(!lockToTime_, "stake forever!");
        }
        if (withUpdate_) {
            massUpdatePools();
        }
        _pid = poolInfo.length;
        // uint _lastRewardTime = block.timestamp > startTime ? block.timestamp : startTime;
        poolInfo.push(PoolInfo({
            status: true,
            lockToTime: lockToTime_,
            levelLp:levelLp_,
            lpToken: lpToken_,
            outPutToken: outPutToken_,
            dailyOut: dailyOut_,
            lastRewardTime: startTime_,
            debtInPool: 0,
            lpTVL: 0,
            startTime: startTime_,
            endTime: endTime_,
            lockTime: lockTime_,
            bonusCoe:bonusCoe_,
            levelAmount:levelAmount_
        }));
        emit AddPool(address(lpToken_), address(outPutToken_));
    }

    function setClosePool(uint pid_) public onlyAdmin {
        require(poolInfo[pid_].status, "allready close");
        poolInfo[pid_].status = false;
        poolInfo[pid_].endTime = block.timestamp;
    }
    
    // Update the pool's daily output. Can only be called by the owner.
    function setAdjustPoolDailyOut(uint256 _pid, uint256 dailyOut_, bool _withUpdate) public onlyAdmin {
        if (_withUpdate) {
            massUpdatePools();
        }
        require(block.timestamp < poolInfo[_pid].startTime, "allready start");
        poolInfo[_pid].dailyOut = dailyOut_;
    }
 
    function setPoolEndTime(uint pid_, uint endTime_) public onlyAdmin {
        PoolInfo storage pool = poolInfo[pid_];
        require(block.timestamp < endTime_, "not good time");
        pool.endTime = endTime_;
    }

    function setPoolStartTime(uint pid_, uint startTime_)public onlyAdmin {
        PoolInfo storage pool = poolInfo[pid_];
        require( block.timestamp < startTime_ && block.timestamp < pool.startTime, "not good time");
        pool.startTime = startTime_;
    }   
    function setbonusCoe(uint pid_, uint first_, uint second_) public onlyAdmin{
        poolInfo[pid_].bonusCoe[0] = first_;
        poolInfo[pid_].bonusCoe[1] = second_;
    }

    function setlevel(uint pid_, uint inviteRequirement_, uint levelTwoDividend_) public onlyAdmin {
        poolInfo[pid_].levelAmount[0] = inviteRequirement_;
        poolInfo[pid_].levelAmount[1] = levelTwoDividend_;
    }

    function setAdmin(address addr_) public onlyOwner {
        isAdmin[addr_] = true;
    }   

    function remoaveAdmin(address addr_) public onlyOwner {
        isAdmin[addr_] = false;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    // function burn(uint amount) external ;
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}