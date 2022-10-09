/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

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

interface ISwapRouter {
    function factory() external pure returns (address);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface INFT {
    function totalSupply() external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract NFTDistributor {

}

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 totalNFTReward;
        uint256 claimedNFTReward;
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public devAddress;
    address public defaultNFTFeeReceiver;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _lpDividendFee = 500;
    uint256 public _fundFee = 200;
    uint256 public _devFee = 100;
    uint256 public _goldNFTFee = 400;
    uint256 public _silverNFTFee = 300;
    uint256 public _copperNFTFee = 300;

    uint256 public startTradeBlock;

    address public _mainPair;

    address public _goldNFT;
    address public _silverNFT;
    address public _copperNFT;

    address  public _nftDistributor;
    mapping(address => UserInfo) private _userInfos;

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress, address DevAddress, address DefaultNFTFeeReceiver
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        devAddress = DevAddress;
        defaultNFTFeeReceiver = DefaultNFTFeeReceiver;

        _feeWhiteList[DefaultNFTFeeReceiver] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[DevAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        holderRewardCondition = 10 * 10 ** Decimals;
        nftRewardCondition = 10 * 10 ** Decimals;
        excludeNFTHolder[address(0)] = true;
        excludeNFTHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        NFTDistributor nftDistributor = new NFTDistributor();
        _nftDistributor = address(nftDistributor);
        _feeWhiteList[_nftDistributor] = true;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 999 / 1000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                if (_feeWhiteList[from] && to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startTradeBlock = block.number;
                }
            }
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!trade");
                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    return;
                }
                takeFee = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (_swapPairList[to]) {
                addHolder(from);
            }
            processReward(500000);
            uint256 blockNum = block.number;
            if (processRewardBlock != blockNum) {
                processGoldNFT(500000);
                if (processGoldNFTBlock != blockNum) {
                    processSilverNFT(500000);
                    if (processSilverNFTBlock != blockNum) {
                        processCopperNFT(500000);
                    }
                }
            }
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 lpDividendAmount = tAmount * _lpDividendFee / 10000;
            feeAmount += lpDividendAmount;
            _takeTransfer(
                sender,
                address(this),
                lpDividendAmount
            );

            uint256 fundAmount = tAmount * _fundFee / 10000;
            feeAmount += fundAmount;
            _takeTransfer(
                sender,
                fundAddress,
                fundAmount
            );

            uint256 devAmount = tAmount * _devFee / 10000;
            feeAmount += devAmount;
            _takeTransfer(
                sender,
                devAddress,
                devAmount
            );

            uint256 goldNFTAmount = tAmount * _goldNFTFee / 10000;
            feeAmount += goldNFTAmount;
            _giveNFTFeeAmount(sender, _goldNFT, goldNFTAmount);

            uint256 silverNFTAmount = tAmount * _silverNFTFee / 10000;
            feeAmount += silverNFTAmount;
            _giveNFTFeeAmount(sender, _silverNFT, silverNFTAmount);

            uint256 copperNFTAmount = tAmount * _copperNFTFee / 10000;
            feeAmount += copperNFTAmount;
            _giveNFTFeeAmount(sender, _copperNFT, copperNFTAmount);
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _giveNFTFeeAmount(address sender, address nftAddress, uint256 nftFeeAmount) private {
        if (INFT(nftAddress).totalSupply() == 0) {
            _takeTransfer(sender, defaultNFTFeeReceiver, nftFeeAmount);
        } else {
            _takeTransfer(sender, nftAddress, nftFeeAmount);
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setDevAddress(address addr) external onlyOwner {
        devAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setDefaultNFTFeeReceiver(address addr) external onlyOwner {
        defaultNFTFeeReceiver = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        if (token != address(this)) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function getHolderLength() external view returns (uint256){
        return holders.length;
    }

    function addHolder(address adr) private {
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 public processRewardBlock;
    uint256 public processRewardBlockDebt = 200;

    function processReward(uint256 gas) public {
        if (processRewardBlock + processRewardBlockDebt > block.number) {
            return;
        }

        address sender = address(this);
        uint256 balance = balanceOf(sender);
        if (balance < holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    _tokenTransfer(sender, shareHolder, amount, false);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        processRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount * 10 ** _decimals;
    }

    function setProcessRewardBlockDebt(uint256 blockDebt) external onlyOwner {
        processRewardBlockDebt = blockDebt;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setGoldNFT(address adr) external onlyOwner {
        _goldNFT = adr;
    }

    function setSilverNFT(address adr) external onlyOwner {
        _silverNFT = adr;
    }

    function setCopperNFT(address adr) external onlyOwner {
        _copperNFT = adr;
    }

    uint256 public nftRewardCondition;
    uint256 public processNFTBlockDebt = 200;
    mapping(address => bool) public excludeNFTHolder;

    function setNFTRewardCondition(uint256 amount) external onlyOwner {
        nftRewardCondition = amount * 10 ** _decimals;
    }

    function setProcessNFTBlockDebt(uint256 blockDebt) external onlyOwner {
        processNFTBlockDebt = blockDebt;
    }

    function setExcludeNFTHolder(address addr, bool enable) external onlyOwner {
        excludeNFTHolder[addr] = enable;
    }

    uint256 public currentGoldNFTIndex;
    uint256 public processGoldNFTBlock;

    function processGoldNFT(uint256 gas) private {
        if (processGoldNFTBlock + processNFTBlockDebt > block.number) {
            return;
        }
        address sender = _goldNFT;
        INFT nft = INFT(sender);
        uint totalNFT = nft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        uint256 tokenBalance = balanceOf(sender);
        if (tokenBalance < nftRewardCondition) {
            return;
        }

        uint256 amount = tokenBalance / totalNFT;
        if (0 == amount) {
            return;
        }

        address shareHolder;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 nftBaseId = 1;

        uint256 totalReward;

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentGoldNFTIndex >= totalNFT) {
                currentGoldNFTIndex = 0;
            }
            shareHolder = nft.ownerOf(nftBaseId + currentGoldNFTIndex);
            if (!excludeNFTHolder[shareHolder]) {
                totalReward += amount;
                _userInfos[shareHolder].totalNFTReward += amount;
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentGoldNFTIndex++;
            iterations++;
        }

        processGoldNFTBlock = block.number;

        if (totalReward > 0) {
            _tokenTransfer(sender, _nftDistributor, totalReward, false);
        }
    }

    uint256 public currentSilverNFTIndex;
    uint256 public processSilverNFTBlock;

    function processSilverNFT(uint256 gas) private {
        if (processSilverNFTBlock + processNFTBlockDebt > block.number) {
            return;
        }
        address sender = _silverNFT;
        INFT nft = INFT(sender);
        uint totalNFT = nft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        uint256 tokenBalance = balanceOf(sender);
        if (tokenBalance < nftRewardCondition) {
            return;
        }

        uint256 amount = tokenBalance / totalNFT;
        if (0 == amount) {
            return;
        }

        address shareHolder;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 nftBaseId = 1;

        uint256 totalReward;

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentSilverNFTIndex >= totalNFT) {
                currentSilverNFTIndex = 0;
            }
            shareHolder = nft.ownerOf(nftBaseId + currentSilverNFTIndex);
            if (!excludeNFTHolder[shareHolder]) {
                totalReward += amount;
                _userInfos[shareHolder].totalNFTReward += amount;
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentSilverNFTIndex++;
            iterations++;
        }

        processSilverNFTBlock = block.number;
        if (totalReward > 0) {
            _tokenTransfer(sender, _nftDistributor, totalReward, false);
        }
    }

    uint256 public currentCopperNFTIndex;
    uint256 public processCopperNFTBlock;

    function processCopperNFT(uint256 gas) private {
        if (processCopperNFTBlock + processNFTBlockDebt > block.number) {
            return;
        }
        address sender = _copperNFT;
        INFT nft = INFT(sender);
        uint totalNFT = nft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        uint256 tokenBalance = balanceOf(sender);
        if (tokenBalance < nftRewardCondition) {
            return;
        }

        uint256 amount = tokenBalance / totalNFT;
        if (0 == amount) {
            return;
        }

        address shareHolder;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 nftBaseId = 1;
        uint256 totalReward;

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentCopperNFTIndex >= totalNFT) {
                currentCopperNFTIndex = 0;
            }
            shareHolder = nft.ownerOf(nftBaseId + currentCopperNFTIndex);
            if (!excludeNFTHolder[shareHolder]) {
                totalReward += amount;
                _userInfos[shareHolder].totalNFTReward += amount;
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentCopperNFTIndex++;
            iterations++;
        }

        processCopperNFTBlock = block.number;
        if (totalReward > 0) {
            _tokenTransfer(sender, _nftDistributor, totalReward, false);
        }
    }

    function getUserInfo(address account) view public returns (uint256 totalReward, uint256 claimedReward){
        UserInfo storage userInfo = _userInfos[account];
        totalReward = userInfo.totalNFTReward;
        claimedReward = userInfo.claimedNFTReward;
    }

    function claimNFTReward() public {
        address account = msg.sender;
        UserInfo storage userInfo = _userInfos[account];
        uint256 pendingReward = userInfo.totalNFTReward - userInfo.claimedNFTReward;
        if (pendingReward > 0) {
            userInfo.claimedNFTReward += pendingReward;
            _tokenTransfer(_nftDistributor, account, pendingReward, false);
        }
    }
}

contract JKDAO is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "JKDAO",
        "JKDAO",
    //Decimals
        18,
    //Total
        33333,
    //Receive
        address(0x20F48A777bF5ef1511Dae717108699e884cBd71d),
    //Fund
        address(0xB8C0d6455F89ca26C03887DEd0cf2E47B8Fa1cA3),
    //Dev
        address(0x2F602809e0E18b0bc48913f912A00EDa5D24eF1A),
    //DefaultNFTReceiver
        address(0xB8C0d6455F89ca26C03887DEd0cf2E47B8Fa1cA3)
    ){

    }
}