// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./ISunswapV2Pair.sol";
import "./ISunswapV2Factory.sol";
import "./ISunswapV2Router02.sol";
import "./IERC721.sol";
import "./ReentrancyGuard.sol";
import "./SafeMathInt.sol";

import "./ERC20.sol";

import "./IDividendTracker.sol";
import "./IRewardNFT.sol";
import "./IConvert.sol";
import "./IDividendNFT.sol";
import "./IRepo.sol";


contract TBToken is ERC20, Ownable,ReentrancyGuard {

    using SafeMath for uint256;

    // //
    // //TKzxdSv2FZKQrEqkKVgp5DcwEXBEKMg2Ax  0x6E0617948FE030a7E4970f8389d4Ad295f249B7e
    // ISunswapV2Router02 public sunswapV2Router = ISunswapV2Router02(0x6E0617948FE030a7E4970f8389d4Ad295f249B7e);

    // //TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t  0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C
    // address public USDT = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
    // address public deadWallet = address(0x000000000000000000000000000000000000dEaD);



    

    // IConvert public convert                 = IConvert(0xE33F6e3DF55F991B5093310D229D0af3DB9F9Cd8);

    // IDividendTracker public dividendTracker = IDividendTracker(0x12428B1921D82D6d698Dd5BB9506c3f518c684b1);
    // IRewardNFT public rewardNFT             = IRewardNFT(0x60E339D2EcFAB864DF187BFB568e174601F900E7);
    // IDividendNFT public dividendNFT         = IDividendNFT(0x12428B1921D82D6d698Dd5BB9506c3f518c684b1);
    // IRepo public repo                       = IRepo(0x12428B1921D82D6d698Dd5BB9506c3f518c684b1);


    //BSC-TEST
    ISunswapV2Router02 public sunswapV2Router = ISunswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    address public USDT = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
    address public deadWallet = address(0x000000000000000000000000000000000000dEaD);


    IConvert public convert                 = IConvert(0x3823be6A7F1870B8D69A8F57D48a834A0907Abe9);

    IDividendTracker public dividendTracker = IDividendTracker(0xDa8e3C75f521e3589F6fdd402D77d39ABbd45d72);
    IRewardNFT public rewardNFT             = IRewardNFT(0x6Db85a5427077Fa80429dA068De5B129d08e5b2e);
    IDividendNFT public dividendNFT         = IDividendNFT(0x184f7C609377561e915D3a9eE58e1309422a079c);
    IRepo public repo                       = IRepo(0x86d3B3Dc2a142e434681245c47712031F841D715);



    //-----------------------------------------------------

    address public  sunswapV2Pair;
    bool private swapping;

    //----------------------------fee-------------------------
    uint256 private repoFee = 2;
    uint256 private burnFee = 1;
    uint256 private nftHolderFee = 5;
    uint256 private tbHolderFee = 7;
    uint256 public totalFees = tbHolderFee.add(repoFee).add(burnFee).add(nftHolderFee);

    uint256 public swapTokensAtAmount = 10000 * 10000 * (10**18);  //本合约的TB数量，触发分红的最低TB数量  单位 TB
    uint256 public buyAmount = 5 * (10 ** 6)  * (10**18) ;//5u   奖励NFT的达标量  单位 U 


    //-----------------------------------------------------
    mapping (address => bool) public automatedMarketMakerPairs;  //流动池地址
    mapping (address => bool) private _isExcludedFromFees;      //不收手续费
    mapping(address => bool) public _isExcludedFromRestrict;   //交易额不受限制

    //-----------------------------------------------------
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeFromDividends(address indexed account);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event nottriggerSwapEvent(uint256 indexed contractTokenBalance, uint256 indexed swapTokensAtAmount);
    event triggerSwapEvent(address indexed processor,uint256 burnTokens,uint256 swapTokens,uint256 tbHolderTokens,uint256 nftHolderTokens);
    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor,
        bool indexed dividendType //false tb true nft
    );
    //-----------------------------------------------------


    constructor() ERC20("TB", "TB") {
        address _sunswapV2Pair = ISunswapV2Factory(sunswapV2Router.factory()).createPair(address(this), USDT);
        sunswapV2Pair = _sunswapV2Pair;

        _setAutomatedMarketMakerPair(_sunswapV2Pair, true);


        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        // 不收税地址
        excludeFromFees(address(convert),true);
        excludeFromFees(address(dividendTracker),true);
        excludeFromFees(address(rewardNFT),true);
        excludeFromFees(address(dividendNFT),true);
        excludeFromFees(address(repo),true);

        _isExcludedFromRestrict[owner()] = true;
        _isExcludedFromRestrict[address(this)] = true;
        _isExcludedFromRestrict[deadWallet] = true;
        _isExcludedFromRestrict[address(sunswapV2Router)] = true;
        _isExcludedFromRestrict[address(sunswapV2Pair)] = true;
        // 不限制交易量
        _isExcludedFromRestrict[address(convert)] = true;
        _isExcludedFromRestrict[address(dividendTracker)] = true;
        _isExcludedFromRestrict[address(rewardNFT)] = true;
        _isExcludedFromRestrict[address(dividendNFT)] = true;
        _isExcludedFromRestrict[address(repo)] = true;



        _mint(owner(), 1000000000000000 * (10**18)); //总量：1000万亿
    }

    function getFees() public view returns (uint256, uint256, uint256,uint256) {
        return (repoFee,burnFee,nftHolderFee,tbHolderFee);
    }

    function initData() external onlyOwner {
        
        //不分红地址
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(sunswapV2Router));
        dividendTracker.excludeFromDividends(sunswapV2Pair);

        dividendTracker.excludeFromDividends(address(convert));
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(rewardNFT));
        dividendTracker.excludeFromDividends(address(dividendNFT));
        dividendTracker.excludeFromDividends(address(repo));


        convert.initData(sunswapV2Pair,address(sunswapV2Router),USDT,address(this));
    }

    //设置TB持币量达标多少才能分红TRX
    function setMinimumTokenBalanceForDividends(uint256 _minimumTokenBalanceForDividends) external onlyOwner{
        dividendTracker.setMinimumTokenBalanceForDividends(_minimumTokenBalanceForDividends);
    }
    //
    function setUsdtAddress(address _usdtAddress) external onlyOwner {
        USDT = _usdtAddress;
    }

    //-----------------------------------------------------------------------------------------
    //设置TB转TRX的合约配置
    function updateConvert(address newAddress) external onlyOwner{
        convert = IConvert(newAddress);

        convert.initData(sunswapV2Pair,address(sunswapV2Router), USDT,address(this));
    }
    //设置DividendTracker
    function updateDividendTracker(address newAddress) external onlyOwner {
        dividendTracker = IDividendTracker(newAddress);

        //不分红地址
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(sunswapV2Router));
        dividendTracker.excludeFromDividends(sunswapV2Pair);

        dividendTracker.excludeFromDividends(address(convert));
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(rewardNFT));
        dividendTracker.excludeFromDividends(address(dividendNFT));
        dividendTracker.excludeFromDividends(address(repo));

    }
    function updateRewardNFT(address newAddress) external onlyOwner{
        rewardNFT = IRewardNFT(newAddress);
    }
    function updateRepo(address newAddress) external onlyOwner{
        repo = IRepo(newAddress);
    }
    function updateDividendNFT(address newAddress) external onlyOwner{
        dividendNFT = IDividendNFT(newAddress);
    }

    //-----------------------------------------------------------------------------------------
    

    //设置手续费比率
    function setFees(uint256 _repoFee,uint256 _burnFee,uint256 _nftHolderFee,uint256 _tbHolderFee) external onlyOwner {
        repoFee = _repoFee;
        burnFee = _burnFee;
        nftHolderFee = _nftHolderFee;
        tbHolderFee = _tbHolderFee;
        totalFees = tbHolderFee.add(repoFee).add(burnFee).add(nftHolderFee);
    }
    //设置触发分红的最低TB数量
    function setSwapTokensAtAmount(uint256 _swapTokensAtAmount) external onlyOwner{
        swapTokensAtAmount = _swapTokensAtAmount;
    }
    //奖励NFT的达标量
    function setBuyAmount(uint256 _buyAmount) public onlyOwner {
        buyAmount = _buyAmount;
    }

    //----------------------------------------------------------------------------------
    //设置免除手续费
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "TB: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    //是否免除交易额限制
    function excludeFromRestrict(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromRestrict[account] != excluded, "bitcoin: Account is already the value of 'excluded'");
        _isExcludedFromRestrict[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    //设置LP池地址
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "TB: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }
    //是否免除手续费
    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }
    //----------------------------------------------------------------------------

    //dividendTracker里设置不分红地址
    function excludeFromDividends(address account) external onlyOwner{
        dividendTracker.excludeFromDividends(account);
    }

    function withdrawByDividendTracker(uint256 amount) external onlyOwner{
        dividendTracker.withdrawEth(owner(),amount);
    }

    //----------------------------------------------------------------------------

    function multiTransfer(address[] memory addrs,uint256[] memory datas) external{
        for (uint i = 0; i < addrs.length; i++) {
            _transfer(msg.sender,addrs[i],datas[i]);
        }
    }




    function _isLp(address _addr) internal view returns (bool) {
        return automatedMarketMakerPairs[_addr];
    }
    // 0: normal transfer
    // 1: buy from official LP  or  remove official LP
    // 2: sell to official LP   or  add official LP
    function _getTransferType(address _from, address _to) internal view returns (uint256) {
        if (_isLp(_from) && !_isLp(_to)) {
            return 1;
        }

        if (!_isLp(_from) && _isLp(_to)) {
            return 2;
        }

        return 0;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
 
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(amount == 0 ) {
            super._transfer(from, to, 0);
            return;
        }
        if (swapping){
            super._transfer(from, to, amount);
            return;
        }
        swapping = true;

        //获取交易类型
        uint256 _transferType = _getTransferType(from, to);

        //普通用户+(sell to official LP   or  add official LP) 有限制额度
        if(!_isExcludedFromRestrict[from] &&  _transferType == 2){
            require(amount <= balanceOf(address(from)).mul(90).div(100),"(sale or add LP) limit 90%");
        }

        bool takeFee = true;
        //项目方钱包地址应该要加入_isExcludedFromFees
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        // //1: buy from official LP  or  remove official LP ,项目方添加LP的钱包地址应该要加入_isExcludedFromFees
        // if (_transferType == 1 && _isExcludedFromFees[to]){
        //     takeFee = false;
        // }
        // //2: sell to official LP   or  add official LP ,  项目方添加LP的钱包地址应该要加入_isExcludedFromFees
        // if (_transferType == 2 && _isExcludedFromFees[from]){
        //     takeFee = false;
        // }

        //普通转账也需要收手续费
        if(takeFee) {
            uint256 fees = amount.mul(totalFees).div(100);
            // if(automatedMarketMakerPairs[to]){
            //     fees += amount.mul(1).div(100);
            // }
            amount = amount.sub(fees);
            super._transfer(from, address(this), fees);   //15%
        }
        super._transfer(from, to, amount);


        //奖励NFT
        if( amount.mul(getPrice()) >= buyAmount  ) {
            rewardNFT.addRewardNftInfo(to,block.timestamp,balanceOf(to),  true);
        }
        rewardNFT.addRewardNftInfo(from,block.timestamp,balanceOf(from),  false);
        

        triggerSwap(from,to);
        swapping = false;
    }

    function triggerSwaptest(address from, address to)  public{
        swapping = true;
        triggerSwap(from,to);
        swapping = false;
    }

    function triggerSwap(address from, address to)  internal {
        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance < swapTokensAtAmount){
            emit nottriggerSwapEvent(contractTokenBalance,swapTokensAtAmount);
            return;
        }

        //--------1% 销毁--------------------------------------------
        uint256 burnTokens = contractTokenBalance.mul(burnFee).div(totalFees);
        if (burnFee>0){  
            super._transfer(address(this),deadWallet,burnTokens);
        }

        //--------2% 回购TB,待定--------------------------------------
        uint256 repoTokens = contractTokenBalance.mul(repoFee).div(totalFees);
        if (repoFee>0){  
            super._transfer(address(this),address(repo),repoTokens);
            repo.addRewardInfo(repoTokens);
        }


        //--------7% 兑换为TRX分红------------------------------------
        uint256 tbHolderTokens = contractTokenBalance.mul(tbHolderFee).div(totalFees);
        if (tbHolderFee>0){  
            dividendTracker.setBalance(payable(to), balanceOf(to)) ;
            dividendTracker.setBalance(payable(from), balanceOf(from)) ;
            
            //记录dividendTracker上次的余额
            uint256 tempBalance = address(dividendTracker).balance;
            //TB换为TRX
            super._transfer(address(this),address(convert),tbHolderTokens);
            convert.TBToTrxToDivide(tbHolderTokens,address(dividendTracker));
            //dividendTracker 增量余额
            dividendTracker.distributeDividends(address(dividendTracker).balance.sub(tempBalance));
        }

        //--------5% NFT持有者分红 TB----------------------------------
        uint256 nftHolderTokens = contractTokenBalance.mul(nftHolderFee).div(totalFees);
        if (nftHolderFee>0){  
            super._transfer(address(this),address(dividendNFT),nftHolderTokens);
            dividendNFT.addRewardInfo(nftHolderTokens);
        }
        
        emit triggerSwapEvent(msg.sender,burnTokens,repoTokens,tbHolderTokens,nftHolderTokens);
    }

    function getPrice() public view returns (uint256) {
        address _token0 = ISunswapV2Pair(sunswapV2Pair).token0();
        (uint256 _reserve0, uint256 _reserve1, ) = ISunswapV2Pair(sunswapV2Pair).getReserves();
        (uint256 _main, uint256 _quote) = address(USDT) == _token0
        ? (_reserve1, _reserve0)
        : (_reserve0, _reserve1);
        return _main == 0 ? 0 : _quote.mul(1e18).div(_main);
    }
}