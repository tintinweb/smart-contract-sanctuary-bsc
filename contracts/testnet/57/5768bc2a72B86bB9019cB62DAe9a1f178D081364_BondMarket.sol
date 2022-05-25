//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/ITriangleNFT.sol";

interface ILPDividend{
    function registerLP(address userAddr, uint256 amount_) external;
}
interface ITriangleNFTErc721{
    function mintBronzeNFT(address addr_) external returns(uint256);
}

// market负责 bond的抢购
contract BondMarket{
    struct UserInfo{
        // 用户已预约bond的数量
        uint8 reserveAmount;
        // 用户可用的预约金
        uint reserveDeposit;
        // 用户已中签数量
        uint8 haveBonds;
        // 更新时间
        uint updateTime;
    }
    mapping(address => UserInfo) public users;

    uint public defaultDeposit;
    uint public defaultAdditionalU;

    address[] private reserveQueue;

    uint8 public first;

    address public udstToken;
    address public triangleNFT721;
    address public lpDividend;

    address private owner;
    mapping(address => bool) private operators;
    bool private initialized;

    // 
    function initialize() public {
        require(!initialized, "BondMarket: already been initialized");
        initialized = true;
        owner = msg.sender;
        operators[msg.sender] = true;

        defaultDeposit = 10**18 * 10;      // 默认10 USDT开启预约
        defaultAdditionalU = 10**18 * 90;  // 默认每个Bond补交90U
        first = 50;     // 默认初始中签概率

        udstToken = 0xb676d07eb60261DD82510c97Dd3076EBb1722A36;
        lpDividend = 0xD40b76Af273a585b4E0F0a5ae35fEd7ca6B55907;

    }

    modifier onlyOperator() {
        require(operators[msg.sender], "BondMarket: You're not operator !");
        _;
    }

    // 预约抢bond，限10000人
    // amount_, 该用户预约bond数量
    function reserve(uint8 amount_) public {
        require(amount_ > 0 && amount_ <= 6, "BondMarket: invaild parameter.");
        require(reserveQueue.length < 10000, "BondMarket: The pond is overrun.");

        UserInfo storage user = users[msg.sender];
        // 该用户持有的NFT数量
        uint limitAmount = 6 - 0;
        require(amount_ <= limitAmount, "BondMarket: Exceed the limit.");
        
        // 是否需要补交预约金
        uint needDeposit = amount_ * defaultDeposit;
        if(user.reserveDeposit < needDeposit){
            // 补交预约金
            IERC20(udstToken).transferFrom(msg.sender, address(this), needDeposit - user.reserveDeposit);
            user.reserveDeposit = 0;
        }else{
            user.reserveDeposit -= needDeposit;
        }
        // 预约成功
        user.reserveAmount = amount_;
        reserveQueue.push(msg.sender);
    }

    // bond释放，amount_为释放张数
    function issueBond(uint amount_) external onlyOperator {
        require(amount_ >= 6, "BondMarket: invaild parameter.");

        for(uint i = 0; i < reserveQueue.length; i++){
            UserInfo storage user = users[reserveQueue[i]];
            uint probability = first;
            // 
            if(amount_ < 6){
                break;
            }

            for(uint8 j = 0; j < user.reserveAmount; j++){
                if(_randomNum(reserveQueue[i]) < probability){
                    // 中签
                    amount_ -= 1;
                    user.haveBonds += 1;
                    // 更新用户bond时间
                    user.updateTime = block.timestamp; 
                }else{
                    // 没中签
                    probability += 10;
                    user.reserveDeposit += defaultDeposit;
                }
            }
            
        }
        // Bond全部释放完后，清空预约者数组
        delete reserveQueue;
    }

    // 退预约金
    function refund() external {
        UserInfo storage user = users[msg.sender];
        require(user.reserveDeposit > 0, "BondMarket: You don't have reserve deposit.");

        uint amount = user.reserveDeposit;
        user.reserveDeposit = 0;
        // 扣15%的手续费
        IERC20(udstToken).transfer(msg.sender, amount * 85 / 100);
    }

    // 用户使用bond
    function useBond(uint8 amount_) external{
        UserInfo storage user = users[msg.sender];
        require(amount_ > 0 && user.haveBonds >= amount_, "BondMarket: you must have enough bonds.");
        require(block.timestamp - user.updateTime < 24 hours, "BondMarket: Sorry, your bonds time out.");
        
        // 补交USDT
        IERC20(udstToken).transferFrom(msg.sender, address(this), defaultAdditionalU * amount_);
        // 发放NFT
        for(uint8 i =0; i<amount_; i++){
            ITriangleNFTErc721(triangleNFT721).mintBronzeNFT(msg.sender);
        }
        
        // 发放LP
        ILPDividend(lpDividend).registerLP(msg.sender, amount_ * 10);

        //
        user.haveBonds -= amount_;
    }

    // 查看用户的 bond的有效期
    function viewEndTime() external view returns(uint256){
        require(users[msg.sender].haveBonds > 0, "BondMarket: you must have bonds.");

        return block.timestamp - users[msg.sender].updateTime;
    }
    
    // 100内随机数,上线后改为 private
    function _randomNum(address addr_) public view returns(uint){
        return uint(keccak256(abi.encode(addr_, block.difficulty, block.timestamp)) ) % 100;
    }

    // set && view
    // function setDeposit(uint deposit_) external onlyOperator{
    //     deposit = deposit_;
    // }
    function setUdstToken(address udstToken_) external onlyOperator{
        udstToken = udstToken_;
    }
    function setNFTAddr(address nftAddr_) external onlyOperator{
        triangleNFT721 = nftAddr_;
    }


    function getReserveQueue() external view returns(uint){
        return reserveQueue.length;
    }





    function setOperator(address addr_, bool temp_) external {
        require(msg.sender == owner, "BondMarket: Insufficient permissions");
        operators[addr_] = temp_;
    }
    function getOperator(address addr_) external view returns (bool res) {
        res = operators[addr_];
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface ITriangleNFT {

    function mintBronzeNFT(address addr_) external returns(uint256);

    function upgradeNFT(uint256[3] calldata tokenIds_) external returns(uint256 newTokenId);

    function repaireRecycleValue(address userAddr_) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "./TriangleNFT.sol";
// import "./interface/IUniswapV2Pair.sol";

interface IUniswapV2Pair {
    function getReserves() external returns (uint, uint, uint);
}

interface ITriangleNFT {
    function endNFT(uint256) external ;
    function ownerOf(uint256) external returns(address);
    function getNFTQuality(uint256) external returns (uint8);
    function setNFTInvestStart(uint256) external;
    function _calcuNeedTMTAmount(uint256) external returns(uint256);
    function setUpgradePool(address, uint256) external;
    function setNFTInvestEnd(uint256,uint256) external;
}

contract TriangleNFTInvest{
    bool private initialized;

    address public TSTToken;
    address public TMTToken;
    address public USDTToken;
    ITriangleNFT public triangleNFT;
    IUniswapV2Pair private pair;

    address private owner;

    struct NFTInvestInfo {
        uint256 investTime;
        uint256 value;          // 该NFT的价值
        uint8[6] rateOfEarn;    // 该 NFT的收益率
        uint8 plateAmount;      // 总共开启了几个板块
        uint256 earnMax;        // 该 nft能获得的最大收益  单位 U
        uint256 earn;           // 能拿到多少收益 earn
        uint256 amountAB;       // 领奖时需要多少a，b
    }
    // mapping from tokenId to NFTInvestInfo
    mapping(uint256 => NFTInvestInfo) _NFTInvests;

    // 各板块已有投资数量
    // difi, gamefi, metaverse, layer, nft, innovation
    uint256[6] public _plateAmount;
    // 各板块已投资 NFT总价值
    // 100, 300, 900, 2700, 8100
    uint256[6] public _plateValue;
    // 投资收益率  5/1000  50/1000       保持 10% 左右
    uint8[6] private rateOfEarns;


    function initialize() external {
        require(!initialized, "already been initialized");
        initialized = true;
        owner = msg.sender;

        TSTToken = 0x6989213aD41e29396DE5a2c99005c482E9Be5f02;
        TMTToken = 0xEf1b9De716fA7e765069fAf4Bf0b16B23Cc7B529;
        USDTToken = 0xb676d07eb60261DD82510c97Dd3076EBb1722A36;
        triangleNFT = ITriangleNFT(0x411F85402960a31160E698928fC5493CDA425F98);
        pair = IUniswapV2Pair(0x411F85402960a31160E698928fC5493CDA425F98);

        rateOfEarns = [5, 10, 6, 15, 8, 50];
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "TriangleNFT: only owner.");
        _;
    }

    function setPairAddr(IUniswapV2Pair addr_) external onlyOwner {
        pair = addr_;
    }
    function getPairAddr() external view returns(address) {
        return address(pair);
    }
    function getrateOfEarns() external view returns(uint8[6] memory) {
        return rateOfEarns;
    }
    function setrateOfEarns(uint8[6] calldata rateOfEarns_) external onlyOwner{
        for(uint8 i=0; i<6; i++){
            rateOfEarns[i] = rateOfEarns_[i];
        }
    }

    // nft投资板块
    function invest(uint256 tokenId_, bool[6] calldata whichPlates_) external {
        require(msg.sender == triangleNFT.ownerOf(tokenId_), "TriangleNFTInvest: Invest must by owner.");
        NFTInvestInfo storage nftInvestInfo = _NFTInvests[tokenId_];

        triangleNFT.endNFT(tokenId_);

        require(nftInvestInfo.investTime == 0, "TriangleNFTInvest: NFT is investing.");

        uint8 quality_ = triangleNFT.getNFTQuality(tokenId_);

        if (quality_ > 5) {
            revert();
        }

        uint80[5] memory nftPriceArr = [100 ether, 300 ether, 900 ether, 2700 ether, 8100 ether];
        
        nftInvestInfo.value = nftPriceArr[quality_];
        
        for(uint8 i = 0; i < 6; i++){
            if(whichPlates_[i]){
                if (i == 5) {
                    // innovation 板块
                    require(quality_ == 3 || quality_ == 4, "TriangleNFTInvest: only epic or legend can invest this.");
                }
                _plateAmount[i] += 1;
                _plateValue[i] += nftInvestInfo.value;

                nftInvestInfo.rateOfEarn[i] = rateOfEarns[i];   
                // 
                nftInvestInfo.plateAmount += 1;
            }
        }
        // 投资板块数量限制
        require(nftInvestInfo.plateAmount <= quality_ + 1 && nftInvestInfo.plateAmount > 0, "TriangleNFTInvest: invaild whichPlates.");

        // 最大收益
        for(uint8 i=0; i<6; i++){
            if(nftInvestInfo.rateOfEarn[i] != 0){
                nftInvestInfo.earnMax += nftInvestInfo.value * nftInvestInfo.rateOfEarn[i] / 1000;
            }
        }

        // 持币数量 a & b
        (uint256 userBalanceOfA, uint256 userBalanceOfB) = _getBalnaceOfAB(msg.sender);
        
        uint256 needAmountA = _calcuAmountA(nftInvestInfo.value);
        if((userBalanceOfA + userBalanceOfB) >= needAmountA){
            nftInvestInfo.earn = nftInvestInfo.earnMax;

            nftInvestInfo.amountAB = needAmountA;
        }else{
            nftInvestInfo.earn = (userBalanceOfA + userBalanceOfB) / needAmountA * nftInvestInfo.earnMax;

            nftInvestInfo.amountAB = userBalanceOfA + userBalanceOfB;
        }
        nftInvestInfo.investTime = block.timestamp;
        // nft开启投资质押
        triangleNFT.setNFTInvestStart(tokenId_);
    }

    // 用户领取收益
    function claimInvest(uint256 tokenId_, uint8 option_) external {
        require(msg.sender == triangleNFT.ownerOf(tokenId_), "TriangleNFTInvest: claimInvest must by owner.");
        NFTInvestInfo storage nftInvestInfo = _NFTInvests[tokenId_];

        require(nftInvestInfo.earn > 0, "TriangleNFTInvest: no earn.");
        require(block.timestamp > (nftInvestInfo.investTime + 3 days), "TriangleNFTInvest: no time.");

        // 需持有 a & b才能领取
        (uint256 userBalanceOfA, uint256 userBalanceOfB) = _getBalnaceOfAB(msg.sender);
        require(userBalanceOfA + userBalanceOfB >= nftInvestInfo.amountAB, "TriangleNFTInvest: amonutTST add amountTMT not enough.");

        // 更新数组
        for(uint8 i = 0; i < 6; i++){
            if(nftInvestInfo.rateOfEarn[i] > 0){
                _plateAmount[i] -= 1;
                _plateValue[i] -= nftInvestInfo.value;
            }
        }
    
        // 清空收益率
        delete nftInvestInfo.rateOfEarn;

        // option1 : 按a币底价的一半回收
        // option2 : 存进用户的 NFT升级池
        // option3 : 参加烧烤，未开放
        // option other : 默认放弃收益，清0
        if(option_ == 1){
            uint256 amountTMT = triangleNFT._calcuNeedTMTAmount(nftInvestInfo.earn);
            uint256 amountU = amountTMT * _calcuReservePrice();

            require(IERC20(USDTToken).balanceOf(address(this)) > amountU);
            IERC20(USDTToken).transfer(msg.sender, amountU);

        }else if(option_ == 2){
            uint256 amountTMT = triangleNFT._calcuNeedTMTAmount(nftInvestInfo.earn);
            triangleNFT.setUpgradePool(msg.sender, amountTMT);
        }

        nftInvestInfo.investTime = 0;
        nftInvestInfo.earn = 0;

        // nft结束投资质押
        triangleNFT.setNFTInvestEnd(tokenId_, nftInvestInfo.earn);
    }


    function _getBalnaceOfAB(address addr_) public view returns(uint256 amountA, uint256 amountB){
        amountA = IERC20(TSTToken).balanceOf(addr_);
        amountB = IERC20(TMTToken).balanceOf(addr_);
    }

    // 价值 value_的 NFT此时质押需要多少 a币才能拿到最大收益
    function _calcuAmountA(uint256 value_) public returns(uint256 needTSTAmount){
        (uint256 tstRes, uint256 USDTRes,) = pair.getReserves();
        needTSTAmount = value_ * tstRes / USDTRes;
        // 需要价值的一半
        needTSTAmount = needTSTAmount / 2;
    }

    function _calcuReservePrice() public returns(uint256 price){
        (, uint256 USDTRes,) = pair.getReserves();
        price = USDTRes / 2000000;
    }


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// import "./interface/IUniswapV2Pair.sol";
// import "./interface/ITMTMarket.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniswapV2Pair {
    function getReserves() external returns (uint, uint, uint);
}

interface ITMTMarket {
    function getMoneyWater() external returns (uint);
}

contract TriangleNFTErc721 is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address public bondimpls = 0xFF916989D3E13d3eAe57400B5026a5F497E7EaFC;
    address public TMTToken = 0xEf1b9De716fA7e765069fAf4Bf0b16B23Cc7B529;
    address public dailyQA;
    address public NFTInvestAddr;
    IUniswapV2Pair private pair = IUniswapV2Pair(0xbb82F9E613c9Ffe3c31DC8A03FBeBF65C557f3C5);
    ITMTMarket private tmtMarket = ITMTMarket(0xEf1b9De716fA7e765069fAf4Bf0b16B23Cc7B529);

    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;
    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;
    // Mapping from token ID to TriangleNFT
    mapping (uint256 => TriangleNFT) public _TriangleNFTs;
    // 各品质NFT已有数量
    uint256[5] public _totalSupply;
    // 各类别NFT已有数量
    uint256[6] public _classSupply;
    // bronze NFT limit 10W.
    uint256 public constant MAXTotalSupply = 10_0000;
    // 升级需消耗 [0, 100]
    uint8 public consumePercentage = 1;
    // 升级池
    mapping(address => uint256) upgradePool;
    // 品质： (青铜， 白银， 黄金， 史诗， 传说)
    enum Quality {bronze, silver, gold, epic, legend}
    // 类型
    enum NFTClass {difi, gamefi, metaverse, layer, nft, innovation}
    // NFT struct
    struct TriangleNFT {
        uint256 tokenId;
        Quality quality;
        NFTClass class;
        uint256 createTime;
        uint256 recycleValue;
        bool isInvest;              // 是否处于投资质押状态
        uint256 investTimes;        // 投资次数
        uint256 income;             // 总收益
    }

    constructor() ERC721("triangleNFT", "triangleNFT") {
        
    }

    modifier onlyNFTInvest() {
        require(_msgSender() == NFTInvestAddr, "TriangleNFT: only by NFTInvest contract.");
        _;
    }

    function setDailyQA(address addr_) external onlyOwner{
        dailyQA = addr_;
    }
    function setNFTInvestAddr(address addr_) external onlyOwner{
        NFTInvestAddr = addr_;
    }

    function setPairAddr(IUniswapV2Pair addr_) external onlyOwner {
        pair = addr_;
    }
    function getPairAddr() external view returns(address) {
        return address(pair);
    }
    function setTMTMarketAddr(ITMTMarket addr_) external onlyOwner {
        tmtMarket = addr_;
    }
    function getTMTMarketAddr() external view returns(address) {
        return address(tmtMarket);
    }

    function getNFTQuality(uint256 tokenId_) external view returns(uint8){
        return uint8(_TriangleNFTs[tokenId_].quality);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < ERC721.balanceOf(owner), "TriangleNFT: ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }
    
    // invest by NFTInvest
    function setNFTInvestStart(uint256 tokenId_) external onlyNFTInvest{
        _TriangleNFTs[tokenId_].isInvest = true;
        _TriangleNFTs[tokenId_].investTimes += 1;
    }
    function setNFTInvestEnd(uint256 tokenId_, uint256 earn_) external onlyNFTInvest{
        _TriangleNFTs[tokenId_].isInvest = false;
        _TriangleNFTs[tokenId_].income += earn_;
    }
    function setUpgradePool(address userAddr_, uint256 amountTMT_) external onlyNFTInvest{
        upgradePool[userAddr_] += amountTMT_;
    }


    // only mint by bond impls
    function mintBronzeNFT(address addr_) external returns(uint256){
        require(_msgSender() == bondimpls, "TriangleNFT: only mint by bond.");

        _tokenIds.increment();      // tokenId 从 1开始
        uint256 newNFTId = _tokenIds.current();
        _totalSupply[0] += 1;
        // 
        NFTClass newNFTClass = _randomNftClass(addr_);

        _TriangleNFTs[newNFTId] = TriangleNFT(newNFTId, Quality.bronze, newNFTClass, block.timestamp, 0, false, 0, 0);
        _countClassAmount(newNFTClass);
        // tokenURL待处理
        _mint(addr_, newNFTId);
        return newNFTId;
    }

    // upgrade by three low level NFT
    function upgradeNFT(uint256[3] calldata tokenIds_) external returns(uint256 newTokenId){
        // must by owner
        Quality consistentQuality = _TriangleNFTs[tokenIds_[0]].quality;
        // 神话级不能升级
        require(consistentQuality != Quality.legend, "TriangleNFT: legend can't upgrade.");
        // 板块        
        NFTClass consistentClass = _TriangleNFTs[tokenIds_[0]].class;
        // 减少 msg.sender 调用
        address _sender = _msgSender();
        // 判断每个nft的归属 & quality & class 是否相同
        for (uint8 i=0; i < tokenIds_.length; i ++) {
            require(_sender == ownerOf(tokenIds_[i]), "TriangleNFT: upgrade only by owner.");
            // NFT级别不同
            require(_TriangleNFTs[tokenIds_[i]].quality == consistentQuality, "TriangleNFT: invaild quality.");
            // NFT板块不同
            require(_TriangleNFTs[tokenIds_[i]].class == consistentClass, "TriangleNFT: invaild class.");
            // NFT不能处于投资状态
            require(!_TriangleNFTs[tokenIds_[i]].isInvest, "TriangleNFT: NFT is in invest.");
            // NFT投资次数不超过30次
            require(_TriangleNFTs[tokenIds_[i]].investTimes <= 30, "TriangleNFT: NFT is out of used.");
        }
        // burn 这里要先burn再mint，释放位置
        _burn(tokenIds_[0]);
        _burn(tokenIds_[1]);
        _burn(tokenIds_[2]);
        _subQualityAndClassAmount(consistentQuality, consistentClass, 3);
        //
        uint256 amount;
        uint needTMTAmount;
        uint80[4] memory nftPriceArr = [300 ether, 900 ether, 2700 ether, 8100 ether];
        // 100, 300, 900, 2700, 8100

        // need consume n U tmt 
        amount = nftPriceArr[uint8(consistentQuality)] * consumePercentage / 100;
        needTMTAmount = _calcuNeedTMTAmount(amount);
        // 升级消耗 TMT
        require(upgradePool[_msgSender()] >= needTMTAmount, "TriangleNFT: upgradePool TMT is not enough.");
        upgradePool[_msgSender()] -= needTMTAmount;        
        // mint
        newTokenId = _mintNFT(_msgSender(), consistentQuality, consistentClass);
    }
    
    // UpgradePool 充值
    function addUpgradePool(uint256 amount_) external{
        require(amount_ > 0, "TriangleNFT: invaild amount.");
        // 直接销毁
        IERC20(TMTToken).transferFrom(_msgSender(), address(0), amount_);

        upgradePool[_msgSender()] += amount_;
    }

    // for DailyQA contract
    function repaireRecycleValue(address userAddr_) external {
        require(_msgSender() == dailyQA, "TriangleNFT: repaire only by DailyQA contract.");

        uint256 repaireTokenId;
        for(uint i=0; i<6; i++){
            repaireTokenId = _ownedTokens[userAddr_][i];

            if(repaireTokenId != 0 && _TriangleNFTs[repaireTokenId].recycleValue < 30 ether){
                // 0.1 U
                _TriangleNFTs[repaireTokenId].recycleValue += 1 * 10 ** 17;
            } 
        }
    }

    // burn 寿命到了的 NFT
    function endNFT(uint256 tokenId_) public {
        if(_TriangleNFTs[tokenId_].investTimes > 300 || _isThreeTimesValue(tokenId_)){
            _burn(tokenId_);
            _subQualityAndClassAmount(_TriangleNFTs[tokenId_].quality, _TriangleNFTs[tokenId_].class, 1);
        }
    }

    // 3倍本金
    function _isThreeTimesValue(uint256 tokenId_) internal view returns(bool){
        // amount
        uint256 amount = _TriangleNFTs[tokenId_].income + _TriangleNFTs[tokenId_].recycleValue;

        uint80[5] memory nftPriceArr = [100 ether, 300 ether, 900 ether, 2700 ether, 8100 ether];

        uint256 originAmount = nftPriceArr[uint8(_TriangleNFTs[tokenId_].quality)];
        //
        if(amount > originAmount * 3){
            return true;
        }
        return false;
    }

    function _subQualityAndClassAmount(Quality quality_, NFTClass class_, uint8 num_) internal {
        // 
        require(quality_ != Quality.legend);
        require(class_ != NFTClass.innovation);
        // 
        _totalSupply[uint8(quality_)] -= num_;
        _classSupply[uint8(class_)] -= num_;
    }

    function _mintNFT(address addr_, Quality quality_, NFTClass class_) internal returns(uint256){
        //
        _tokenIds.increment(); 
        uint256 newNFTId = _tokenIds.current();
        Quality newNFTQuality;

        if(quality_ == Quality.bronze){
            newNFTQuality = Quality.silver;
        }else if(quality_ == Quality.silver){
            newNFTQuality = Quality.gold;
        }else if(quality_ == Quality.gold){
            newNFTQuality = Quality.epic;
        }else if(quality_ == Quality.epic){
            newNFTQuality = Quality.legend;
        }else{
            revert();
        }

        _totalSupply[uint8(newNFTQuality)] += 1;

        _TriangleNFTs[newNFTId] = TriangleNFT(newNFTId, newNFTQuality, class_, block.timestamp, 0, false, 0, 0);
        _mint(addr_, newNFTId);
        _countClassAmount(class_);
        return newNFTId;
    }

    function _countClassAmount(NFTClass class_) internal {
        // difi, gamefi, metaverse, layer, nft, innovation
        _classSupply[uint8(class_)] += 1;
    }

    function _calcuNeedTMTAmount(uint256 amount_) internal returns(uint256) {
        (uint256 tstRes, uint256 USDTRes,) = pair.getReserves();
        uint256 needTSTAmount = amount_ * tstRes / USDTRes;
        // amountA = amountB * moneyWater / 100;
        // amountB = amountA * 100 / moneyWater;
        uint256 moneyWater = tmtMarket.getMoneyWater();
        uint256 needTMTAmount = needTSTAmount * 100 / moneyWater;
        
        return needTMTAmount;
    }

    function _randomNftClass(address addr_) internal view returns(NFTClass) {
        uint256 seed = _getRandom(addr_);
        // difi, gamefi, metaverse, layer, nft, innovation
        if(seed >= 95) {
            return NFTClass.innovation;
        }else if (seed >= 76) {
            return NFTClass.nft;
        }else if (seed >= 57) {
            return NFTClass.layer;
        }else if (seed >= 38) {
            return NFTClass.metaverse;
        }else if (seed >= 19) {
            return NFTClass.gamefi;
        }else{
            return NFTClass.difi;
        }
    }
     
    function _getRandom(address addr_) internal view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(addr_, block.difficulty, block.timestamp, _totalSupply[0]))) % 100;
    }


    /**
     * @dev return tokenURI, image SVG data in it.
     */
    // function tokenURI(uint256 tokenId) override public pure returns (string memory) {
    //     string[3] memory parts;

    //     parts[0] = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 300px; }</style><rect width='100%' height='100%' fill='brown' /><text x='100' y='260' class='base'>";

    //     parts[1] = Strings.toString(tokenId);

    //     parts[2] = "</text></svg>";

    //     string memory json = Base64.encode(bytes(string(abi.encodePacked(
    //             "{\"name\":\"Badge #",
    //             Strings.toString(tokenId),
    //             "\",\"description\":\"Badge NFT with on-chain SVG image.\",",
    //             "\"image\": \"data:image/svg+xml;base64,",
    //         // Base64.encode(bytes(output)),
    //             Base64.encode(bytes(abi.encodePacked(parts[0], parts[1], parts[2]))),
    //             "\"}"
    //         ))));

    //     return string(abi.encodePacked("data:application/json;base64,", json));
    // }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {

            require(_totalSupply[0] < MAXTotalSupply, "TriangleNFT: bronze NFT total supply is limit 10W.");

        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            // _removeTokenFromAllTokensEnumeration(tokenId);

        } else if (to != from) {
            require(ERC721.balanceOf(to) < 6, "TriangleNFT: one address hold most 6 NFTs.");

            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) internal {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) internal {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

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
     * by default, can be overridden in child contracts.
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
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Base64.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides a set of functions to operate with Base64 strings.
 *
 * _Available since v4.5._
 */
library Base64 {
    /**
     * @dev Base64 Encoding/Decoding Table
     */
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /**
     * @dev Converts a `bytes` to its Bytes64 `string` representation.
     */
    function encode(bytes memory data) internal pure returns (string memory) {
        /**
         * Inspired by Brecht Devos (Brechtpd) implementation - MIT licence
         * https://github.com/Brechtpd/base64/blob/e78d9fd951e7b0977ddca77d92dc85183770daf4/base64.sol
         */
        if (data.length == 0) return "";

        // Loads the table into memory
        string memory table = _TABLE;

        // Encoding takes 3 bytes chunks of binary data from `bytes` data parameter
        // and split into 4 numbers of 6 bits.
        // The final Base64 length should be `bytes` data length multiplied by 4/3 rounded up
        // - `data.length + 2`  -> Round up
        // - `/ 3`              -> Number of 3-bytes chunks
        // - `4 *`              -> 4 characters for each chunk
        string memory result = new string(4 * ((data.length + 2) / 3));

        assembly {
            // Prepare the lookup table (skip the first "length" byte)
            let tablePtr := add(table, 1)

            // Prepare result pointer, jump over length
            let resultPtr := add(result, 32)

            // Run over the input, 3 bytes at a time
            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {

            } {
                // Advance 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // To write each character, shift the 3 bytes (18 bits) chunk
                // 4 times in blocks of 6 bits for each character (18, 12, 6, 0)
                // and apply logical AND with 0x3F which is the number of
                // the previous character in the ASCII table prior to the Base64 Table
                // The result is then added to the table to get the character to write,
                // and finally write it in the result pointer but with a left shift
                // of 256 (1 byte) - 8 (1 ASCII char) = 248 bits

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance
            }

            // When data `bytes` is not exactly 3 bytes long
            // it is padded with `=` characters at the end
            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }

        return result;
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/extensions/draft-ERC20Permit.sol)

pragma solidity ^0.8.0;

import "./draft-IERC20Permit.sol";
import "../ERC20.sol";
import "../../../utils/cryptography/draft-EIP712.sol";
import "../../../utils/cryptography/ECDSA.sol";
import "../../../utils/Counters.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    /**
     * @dev In previous versions `_PERMIT_TYPEHASH` was declared as `immutable`.
     * However, to ensure consistency with the upgradeable transpiler, we will continue
     * to reserve a slot.
     * @custom:oz-renamed-from _PERMIT_TYPEHASH
     */
    // solhint-disable-next-line var-name-mixedcase
    bytes32 private _PERMIT_TYPEHASH_DEPRECATED_SLOT;

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

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
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        uint256 currentAllowance = allowance(owner, spender);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
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
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
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
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract TriangleMarketplace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _items;
    Counters.Counter private _soldItems;
    using SafeERC20 for IERC20;

    address owner;
    address aContract;
    address nftContract;
    address treasury;

    uint256 fee;

    bool private initialized;

    enum State { ForSale, SoldOut, Removed }

    // interface to marketplace item
    struct MarketplaceItem {
        uint256 itemId;
        uint256 tokenId;
        address owner;
        address buyer;
        uint256 price;
        State state;
    }

    mapping(uint256 => MarketplaceItem) private _marketItems;

    event ItemForSale (
        uint indexed itemId,
        uint256 indexed tokenId,
        address owner,
        uint256 price
    );

    event ItemSold (
        uint indexed itemId,
        uint256 indexed tokenId,
        address seller,
        address buyer,
        uint256 price
    );


    modifier onlyOwner() {
        require(owner == msg.sender, "Access: caller don;t have enough power.");
        _;
    }

    modifier tokenOwner(uint256 tokenId) {
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "Sender does not own the item");
        _;
    }

    modifier itemOwner(uint256 itemId) {
        require(_marketItems[itemId].owner == msg.sender, "Sender does not own the item");
        _;
    }

    /*
    * @initialize
    */
    function initialize() public {
        require(!initialized, "already been initialized");
        initialized = true;
        //
        owner = msg.sender;
        nftContract = 0x170A9A1f6fc5e5956e46c23dAb4FD0c693E58B70;
        aContract = 0x6989213aD41e29396DE5a2c99005c482E9Be5f02;
        treasury = 0xd1547Ec54f8421f4cDDc2d5e8094E51Ace3041eE;

        fee = 5; // handle fee 5%
    }

    // places an item for sale on the marketplace
    function putForSale(uint256 tokenId, uint256 price) public nonReentrant {
        require(price > 0, "Price must be bigger than zero.");

        _items.increment();
        uint256 itemId = _items.current();

        address seller = msg.sender;

        _marketItems[itemId] = MarketplaceItem(
            itemId,
            tokenId,
            seller,
            address(0),
            price,
            State.ForSale
        );

        IERC721(nftContract).transferFrom(seller, address(this), tokenId);

        // item for sale
        emit ItemForSale(
            itemId,
            tokenId,
            seller,
            price
        );

    }

    // transfers ownership of the item, as well as funds between parties
    function purchase(uint256 itemId) public nonReentrant {
        // require for sale
        require(_marketItems[itemId].state == State.ForSale, "This NFT state is not for sale");
        // price
        uint256 price = _marketItems[itemId].price;
        uint256 tokenId = _marketItems[itemId].tokenId;
        address buyer = msg.sender;
        //  tokenA balance
        uint256 tokenABalance = IERC20(aContract).balanceOf(buyer);
        //
        require(tokenABalance > price, "You don;t have enough token.");
        //
        uint256 handlerFee = price * fee / 100;
        // 从买家扣除 token a
        IERC20(aContract).safeTransferFrom(buyer, address(this), price);
        // 部分转给卖家
        IERC20(aContract).safeTransferFrom(address(this), _marketItems[itemId].owner, price - handlerFee);
        // 手续费转给国库
        IERC20(aContract).safeTransferFrom(address(this), treasury, handlerFee);
        // nft 转给买家
        IERC721(nftContract).transferFrom(address(this), buyer, tokenId);
        _marketItems[itemId].buyer = buyer;
        _marketItems[itemId].state = State.SoldOut;

        _soldItems.increment();

        // item for sale
        emit ItemSold (
            itemId,
            tokenId,
            _marketItems[itemId].owner,
            buyer,
            price
        );
    }

    // removeFromSale
    function removeFromSale(uint256 itemId) nonReentrant itemOwner(itemId) public {
        _marketItems[itemId].state = State.Removed;
    }

    // returns only items that a user has purchased
    function fetchMyNFTs() public view returns (MarketplaceItem[] memory) {
        uint256 totalItemCount = _items.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;
        address mineAddr = msg.sender;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (_marketItems[i + 1].owner == mineAddr) {
                itemCount += 1;
            }
        }

        MarketplaceItem[] memory items = new MarketplaceItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (_marketItems[i + 1].owner == mineAddr) {
                uint256 currentId = i + 1;
                MarketplaceItem storage currentItem = _marketItems[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // getItemsForSale
    function getItemsForSale() public view returns (MarketplaceItem[] memory) {
        uint256 itemCount = 0;
        uint256 numItems = _items.current();

        for (uint itemId = 1; itemId <= numItems; itemId++) {
            if (_marketItems[itemId].state == State.ForSale) {
                itemCount++;
            }
        }

        uint256 index = 0;
        MarketplaceItem[] memory itemList = new MarketplaceItem[](itemCount);

        for (uint itemId = 1; itemId <= numItems; itemId++) {
            if (_marketItems[itemId].state == State.ForSale) {
                itemList[index] = _marketItems[itemId];
                index++;
            }
        }

        return itemList;
    }

    // getAllItems
    function getAllItems() public view returns (MarketplaceItem[] memory) {
        uint256 numItems = _items.current();
        MarketplaceItem[] memory itemList = new MarketplaceItem[](numItems);

        for (uint itemId = 1; itemId <= numItems; itemId++) {
            itemList[itemId - 1] = _marketItems[itemId];
        }

        return itemList;
    }


    function setHanldFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "./interface/IUniswapV2Router02.sol";

interface IUniswapV2Router02 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract SwapTest{
    using SafeERC20 for IERC20;

    address public router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address public usdt = 0xb676d07eb60261DD82510c97Dd3076EBb1722A36;
    address public tst = 0xe91BE3C7a4Ea42a589d020e4fBC0700f7afc6Bfe;

    constructor(){

    }

    function swapUSDTToTST(uint amountIn_, uint amountOutMin_) external{
        IERC20(usdt).safeTransferFrom(msg.sender, address(this), amountIn_);
        IERC20(usdt).safeApprove(router, amountIn_);

        address[] memory path = new address[](2);
        path[0] = usdt;       // U
        path[1] = tst;       // TST

        IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn_,
            amountOutMin_,
            path,
            msg.sender,
            block.timestamp
        );
    }

    function swapTSTToUSDT(uint amountIn_, uint amountOutMin_) external{
        IERC20(tst).safeTransferFrom(msg.sender, address(this), amountIn_);
        IERC20(tst).safeApprove(router, amountIn_);

        address[] memory path = new address[](2);
        path[0] = tst;       // TST
        path[1] = usdt;       // U

        IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn_,
            amountOutMin_,
            path,
            msg.sender,
            block.timestamp
        );
    }

    // function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //     uint amountIn,
    //     uint amountOutMin,
    //     address[] calldata path,
    //     address to,
    //     uint deadline
    // ) external virtual override ensure(deadline)
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDTT is ERC20 {
    constructor() ERC20("USDTT", "USDTT") {
        _mint(msg.sender, 10000000 * 10 ** 18);
    }

    function mint(address addr_, uint256 amount_) external {
        _mint(addr_, amount_);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IWhiteList.sol";

contract TSTToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    // 最大供给量 100 万
    uint256 public constant MaxTotalAmount = 10**18 * 10**6;
    // 基金会的地址
    address private fund = 0x3E59Ec88Db095538AdEDC9137BBDe54d440AAfeE;
    address private pair = 0xbb82F9E613c9Ffe3c31DC8A03FBeBF65C557f3C5;          // need
    address private LPDividend = 0xD40b76Af273a585b4E0F0a5ae35fEd7ca6B55907;    // need
    address private treasury = 0xd1547Ec54f8421f4cDDc2d5e8094E51Ace3041eE;       // 国库
    address private lottery = 0xdF60201b6C2A67804AC3F876dDC6a9deD329c65b;       // 抽奖
    address private whiteList = 0xf44DadF514Db3786C51C99bA58D815dEb3a406c0;      // need

    uint8[3] public feeSetting = [3, 6, 5];   // 初始默认手续费
    bool public closeWhiteList;
    bool public feeOn;  
    
    uint256 public DividendTotalAmount;   // 记录总的分红量，只增不减

    constructor() {
        _name = "TriangleToken";
        _symbol = "TST";
        // mint for fund
        _mint(fund, MaxTotalAmount);
        
    }

    event TransferWithFee(address indexed from, address indexed to, uint256 fee, uint256 treasuryFee, uint256 lpFee, uint256 lotteryFee);

    // view
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return 18;
    }
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    // 
    function setPairAddr(address pairAddr_) external onlyOwner {
        pair = pairAddr_;
    }
    function getPairAddr() external view returns(address){
        return pair;
    }
    function setLPDividend(address dividendAddr_) external onlyOwner {
        LPDividend = dividendAddr_;
    }
    function getLPDividend() external view returns(address){
        return LPDividend;
    }
    function setTreasury(address treasuryAddr_) external onlyOwner {
        treasury = treasuryAddr_;
    }
    function getTreasury() external view returns(address){
        return treasury;
    }
    function setLottery(address lotteryAddr_) external onlyOwner {
        lottery = lotteryAddr_;
    }
    function getLottery() external view returns(address) {
        return lottery;
    }
    
    function setFee(uint8 buyFee_, uint8 sellFee_, uint8 transferFee_) external onlyOwner {
        require(buyFee_ + sellFee_ + transferFee_ < 100, "invaild fee");
        feeSetting[0] = buyFee_;
        feeSetting[1] = sellFee_;
        feeSetting[2] = transferFee_;
    }
    function getFee() external view returns(uint8[3] memory feeArray) {
        feeArray = feeSetting;
    }
    function setWhiteList(address addr_) external onlyOwner{
        whiteList = addr_;
    }
    function setCloseWhiteList(bool flag_) external onlyOwner{
        closeWhiteList = flag_;
    }
    // 加池子后开启手续费
    function setfeeOn() external onlyOwner{
        feeOn = true;
    }
 

    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    // 
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != to, "ERC20: from = to");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }

        uint256 fee;            // 手续费
        uint256 LPShare;        // LP分红
        uint256 lotteryShare;   // 抽奖池分红
        if(feeOn){
            if(from == pair){           // 买币
                fee = amount * feeSetting[0] / 100;
                amount -= fee;
                // share[3,5,2]=[3/10,1/2,1/5]
                LPShare = fee * 3 / 10;
                lotteryShare = fee / 5;
                _balances[LPDividend] += LPShare;
                _balances[lottery] += lotteryShare;
                _balances[treasury] += (fee - LPShare - lotteryShare);

                DividendTotalAmount += LPShare;
                
            }else if(to == pair){       // 卖币
                fee = amount * feeSetting[1] / 100;
                amount -= fee;
                // share[3,5,2]=[3/10,1/2,1/5]
                LPShare = fee * 3 / 10;
                lotteryShare = fee / 5;
                _balances[LPDividend] += LPShare;
                _balances[lottery] += lotteryShare;
                _balances[treasury] += (fee - LPShare - lotteryShare);

                DividendTotalAmount += LPShare;
                
            }else{                      // 转账
                fee = amount * feeSetting[2] / 100;
                amount -= fee;
                // share[2,3,0]=[2/5,3/5,0]
                LPShare = fee * 2 / 5;
                _balances[LPDividend] += LPShare;
                _balances[treasury] += (fee - LPShare);

                DividendTotalAmount += LPShare;
            }
        }
        
        _balances[to] += amount;

        // event TransferWithFee(address indexed from, address indexed to, uint256 fee, uint256 treasuryFee, uint256 lpFee, uint256 lotteryFee);
        emit TransferWithFee(from, to, fee, (fee - LPShare - lotteryShare), LPShare, lotteryShare);

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) private {
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        if(!closeWhiteList){
            if(from == pair){
                require(IWhiteList(whiteList).confirm(to, amount), "please wait whitelist over.");
            }
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IWhiteList {
    function confirm(address userAddr_, uint256 tstAmount_) external returns(bool);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./TSTToken.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract LPDividend is Context {
    struct UserInfo{
        // 持有的分红令牌LP数量
        uint256 lpAmount;
        // 进入时刻已奖励部分
        uint256 rewardDebt;
        // 记录用户已领取的分红奖励，只增不减
        uint256 rewardPastTotal;
    }
    mapping(address => UserInfo) public users;

    // 每个分红令牌可获得的分红，只增不减
    // 用户可获得的分红为：   user.amount * accATokenPerShare - user.rewardDebt
    uint256 public accATokenPerShare;
    // 记录上次分红
    uint256 public lastDividendAmount;
    // LP分红令牌总数
    uint256 public lpTotalSupply;
    
    TSTToken public aToken = TSTToken(0x6989213aD41e29396DE5a2c99005c482E9Be5f02);
    address public bond;
    address private owner;
    
    constructor(){
        owner = _msgSender();
    }

    function setBond(address addr_) external {
        require(_msgSender() == owner, "only by owner.");
        bond = addr_;
    }

    event RegisterLP(address indexed userAddr, uint amount);
    event TransferDividend(address indexed from, address indexed to, uint256 value);

    // register
    function registerLP(address userAddr, uint256 amount_) external {
        require(_msgSender() == bond, "register only by bond.");
        require(userAddr != address(0) && amount_ > 0, "invaild parameter.");
        updateDividend();
        UserInfo storage user = users[userAddr];
        // 如果用户之前已有LP，则先发放之前的分红奖励
        if(user.lpAmount > 0){
            uint256 rewardAmount = user.lpAmount * accATokenPerShare - user.rewardDebt;
            _safeATokenTransfer(userAddr, rewardAmount);
            user.rewardPastTotal += rewardAmount;
        }
        user.lpAmount += amount_;
        user.rewardDebt = user.lpAmount * accATokenPerShare;
        lpTotalSupply += amount_;

        emit RegisterLP(userAddr, amount_);
    }

    // update accATokenPerShare
    function updateDividend() public {
        uint256 dividendAmount = aToken.DividendTotalAmount();
        uint256 addtionAmount = dividendAmount - lastDividendAmount;
        if(addtionAmount > 0 && lpTotalSupply > 0){
            accATokenPerShare += addtionAmount / lpTotalSupply;
            lastDividendAmount = dividendAmount;
        }
    }
    // 查看用户可获得的分红为
    function viewUserReward(address addr_) public view returns(uint256){
        require(addr_ != address(0), "invaild address");
        uint256 dividendAmount = aToken.DividendTotalAmount();
        uint256 addtionAmount = dividendAmount - lastDividendAmount;
        if(addtionAmount > 0){
            uint256 accATokenPerShareTemp = accATokenPerShare + (addtionAmount / lpTotalSupply);
            return users[addr_].lpAmount * accATokenPerShareTemp - users[addr_].rewardDebt;
        }
        return users[addr_].lpAmount * accATokenPerShare - users[addr_].rewardDebt;
    }
    // withdraw , 用户自己领取分红奖励
    function withdraw() public {
        UserInfo storage user = users[_msgSender()];
        require(user.lpAmount > 0, "user's LP amount is 0.");
        updateDividend();
        uint256 rewardAmount = user.lpAmount * accATokenPerShare - user.rewardDebt;
        user.rewardDebt = user.lpAmount * accATokenPerShare;
        user.rewardPastTotal += rewardAmount;
        _safeATokenTransfer(_msgSender(), rewardAmount);
    }

    function _safeATokenTransfer(address _to, uint256 _amount) private {
        uint256 aTokenBal = aToken.balanceOf(address(this));
        require(_amount < aTokenBal, "invaild amount.");

        aToken.transfer(_to, _amount);

        emit TransferDividend(address(this), _to, _amount);
    }

}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract TMTToken is ERC20Permit {

    // 最大供给量 200 万
    uint256 public constant MaxTotalAmount = 10**18 * 20**6;

    address private TMTMarket;
    address private owner;
    

    constructor() ERC20("TMT", "TMT") ERC20Permit("TMT") {
        owner = msg.sender;
    }

    // 只能由 NFT 产出
    function mint(address to_, uint amount_) external{
        require(msg.sender == TMTMarket, "only by TMTToken");    // 
        require(totalSupply() + amount_ <= MaxTotalAmount, "Exceeded maximum limit");

        _mint(to_, amount_);
    }

    function setTMTMarket(address addr_) external {
        require(msg.sender == owner, "only by owner");

        TMTMarket = addr_;
    }

    function getTMTMarket() external view returns(address){
        require(msg.sender == owner, "only by owner");

        return TMTMarket;
    }

    
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITMTToken{
    function mint(address to_, uint amount_) external;
}

contract TMTMarket {
    address public tst;
    address public tmt;
    address private owner;

    // amountTST = amountTMT * moneyWater / 100;
    // amountTMT = amountTST * 100 / moneyWater;
    uint256 private moneyWater;

    bool private initialized;

    function initialize() external {
        require(!initialized, "already been initialized");
        initialized = true;
        owner = msg.sender;

        tst = 0x6989213aD41e29396DE5a2c99005c482E9Be5f02;
        tmt = 0xEf1b9De716fA7e765069fAf4Bf0b16B23Cc7B529;
        moneyWater = 200;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "TriangleNFT: only owner.");
        _;
    }

    // swap TMT to TST
    function viewTSTAmount(uint256 amountTMT_) public view returns(uint256){
        return amountTMT_ * moneyWater / 100;
    }

    // swap TST to TMT
    function viewTMTAmount(uint256 amountTST_) public view returns(uint256){
        return amountTST_ * 100 / moneyWater;
    }

    function viewBalanceOfTMT() public view returns(uint256){
        return IERC20(tmt).balanceOf(address(this));
    }

    // buy TMT by TST
    function buyTMT(uint256 amountTMT_) external {
        require(amountTMT_ > 0, "invaild amount.");
        require(viewBalanceOfTMT() >= amountTMT_, "TriangleNFT: Market's TMT not enough.");

        uint256 needTSTAmount = amountTMT_ * moneyWater / 100;

        IERC20(tst).transferFrom(msg.sender, address(this), needTSTAmount);

        ITMTToken(tmt).mint(msg.sender, amountTMT_);
    }


    function setMoneyWater(uint256 moneyWater_) external onlyOwner{
        moneyWater = moneyWater_;
    }
    function getMoneyWater() external view returns(uint256){
        return moneyWater;
    }

    function toTreasury() external onlyOwner{
        
    }


}