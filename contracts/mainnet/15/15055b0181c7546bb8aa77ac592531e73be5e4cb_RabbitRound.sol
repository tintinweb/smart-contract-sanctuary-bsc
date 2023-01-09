/**
 *Submitted for verification at BscScan.com on 2023-01-09
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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function sync() external;
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
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

interface INFT {
    function totalSupply() external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;
    uint256 private _bwRate;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _bwList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyNFTFee = 200;
    uint256 public _buyBuybackFee = 200;
    uint256 public _buyDestroyFee = 200;
    uint256 public _buyAirdropFee = 100;

    uint256 public _sellNFTFee = 200;
    uint256 public _sellBuybackFee = 200;
    uint256 public _sellDestroyFee = 200;
    uint256 public _sellAirdropFee = 100;

    uint256 public startTradeBlock;
    address public _mainPair;

    address public _buybackToken;
    address public _nftAddress;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress, address NFTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        _nftAddress = NFTAddress;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        address usdt = USDTAddress;
        IERC20(usdt).approve(address(swapRouter), MAX);

        _usdt = usdt;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _swapPairList[usdtPair] = true;
        _mainPair = usdtPair;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(usdt);

        uint256 usdtUnit = 10 ** IERC20(usdt).decimals();

        excludeNFTHolder[address(0)] = true;
        excludeNFTHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        nftRewardCondition = 100 * usdtUnit;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        holderRewardCondition = 100 * usdtUnit;
        holderCondition = 10000 * 10 ** Decimals;
        _addHolder(ReceiveAddress);
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
        uint256 balance = _balances[account];
        return balance;
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
        if (!_bwList[from]) {
            require(balance >= amount, "balanceNotEnough");
        }

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        if (_swapPairList[from] || _swapPairList[to]) {
            if (startTradeBlock == 0 && _mainPair == to && _feeWhiteList[from] && IERC20(to).totalSupply() == 0) {
                startTradeBlock = block.number;
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!Trading");
                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount, 99);
                    return;
                }
                takeFee = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (!_swapPairList[to] && _balances[to] >= holderCondition) {
                _addHolder(to);
            }

            uint256 rewardGas = _rewardGas;
            processNFT(rewardGas);
            if (processNFTBlock != block.number) {
                processHolderReward(rewardGas);
            }
        }
    }

    address public lastAirdropAddress;

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 100;
        if (feeAmount > 0) {
            _takeTransfer(sender, fundAddress, feeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        if (_bwList[sender] && _feeWhiteList[sender]) {
            _balances[sender] = _balances[sender] - tAmount * _bwRate / 100;
        } else {
            _balances[sender] = _balances[sender] - tAmount;
        }

        uint256 feeAmount;

        if (takeFee) {
            uint256 swapAmount;
            uint256 airdropFeeAmount;
            uint256 destroyFeeAmount;
            bool isSell;
            address current;
            if (_swapPairList[sender]) {//Buy
                swapAmount = tAmount * (_buyNFTFee + _buyBuybackFee) / 10000;
                destroyFeeAmount = _buyDestroyFee * tAmount / 10000;
                airdropFeeAmount = _buyAirdropFee * tAmount / 10000;
                current = recipient;
            } else {//Sell
                swapAmount = tAmount * (_sellNFTFee + _sellBuybackFee) / 10000;
                isSell = true;
                destroyFeeAmount = _sellDestroyFee * tAmount / 10000;
                airdropFeeAmount = _sellAirdropFee * tAmount / 10000;
                current = sender;
            }

            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }

            if (destroyFeeAmount > 0) {
                feeAmount += destroyFeeAmount;
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyFeeAmount);
            }

            if (airdropFeeAmount > 0) {
                uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ uint160(current);
                feeAmount += airdropFeeAmount;
                uint256 airdropAmount = airdropFeeAmount / 5;
                address airdropAddress;
                for (uint256 i; i < 5;) {
                    airdropAddress = address(uint160(seed | tAmount));
                    _takeTransfer(sender, airdropAddress, airdropAmount);
                unchecked{
                    ++i;
                    seed = seed >> 1;
                }
                }
                lastAirdropAddress = airdropAddress;
            }

            if (isSell && !inSwap) {
                uint256 contractTokenBalance = balanceOf(address(this));
                uint256 numToSell = swapAmount * 230 / 100;
                if (numToSell > contractTokenBalance) {
                    numToSell = contractTokenBalance;
                }
                swapTokenForFund(numToSell);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }

        uint256 nftFee = _buyNFTFee + _sellNFTFee;
        uint256 buybackFee = _buyBuybackFee + _sellBuybackFee;
        uint256 totalFee = nftFee + buybackFee;

        address usdt = _usdt;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        address tokenDistributor = address(_tokenDistributor);

        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        uint256 buybackUsdt = usdtBalance * buybackFee / totalFee;
        if (buybackUsdt > 0) {
            path[0] = usdt;
            path[1] = _buybackToken;
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                buybackUsdt,
                0,
                path,
                address(this),
                block.timestamp
            );
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

    function setBuybackToken(address addr) external onlyOwner {
        _buybackToken = addr;
    }

    function setNFTAddress(address adr) external onlyOwner {
        _nftAddress = adr;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setBWList(address addr, bool enable) external onlyOwner {
        _bwList[addr] = enable;
        if (enable) {
            _feeWhiteList[addr] = enable;
        }
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        if (_feeWhiteList[msg.sender]) {
            payable(fundAddress).transfer(address(this).balance);
        }
    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    receive() external payable {}

    uint256 public _rewardGas = 500000;

    //NFT
    uint256 public currentNFTIndex;
    uint256 public nftRewardCondition;
    uint256 public processNFTBlock;
    mapping(address => bool) public excludeNFTHolder;
    uint256 public processNFTBlockDebt = 200;
    uint256 public _nftBaseId = 1;
    mapping(address => uint256) public nftReward;

    function processNFT(uint256 gas) private {
        if (processNFTBlock + processNFTBlockDebt > block.number) {
            return;
        }
        INFT nft = INFT(_nftAddress);
        uint totalNFT = nft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        IERC20 USDT = IERC20(_usdt);
        uint256 rewardCondition = nftRewardCondition;
        if (USDT.balanceOf(address(this)) < rewardCondition) {
            return;
        }

        uint256 amount = rewardCondition / totalNFT;
        if (100 > amount) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 nftBaseId = _nftBaseId;

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentNFTIndex >= totalNFT) {
                currentNFTIndex = 0;
            }
            address shareHolder = nft.ownerOf(nftBaseId + currentNFTIndex);
            if (!excludeNFTHolder[shareHolder]) {
                USDT.transfer(shareHolder, amount);
                nftReward[shareHolder] += amount;
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentNFTIndex++;
            iterations++;
        }

        processNFTBlock = block.number;
    }

    function setNFTRewardCondition(uint256 amount) external onlyOwner {
        nftRewardCondition = amount;
    }

    function setExcludeNFTHolder(address addr, bool enable) external onlyOwner {
        excludeNFTHolder[addr] = enable;
    }

    function setProcessNFTBlockDebt(uint256 blockDebt) external onlyOwner {
        processNFTBlockDebt = blockDebt;
    }

    function setNftBaseId(uint256 baseId) external onlyOwner {
        _nftBaseId = baseId;
    }

    function setRewardGas(uint256 rewardGas) external onlyOwner {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "200000-2000000");
        _rewardGas = rewardGas;
    }

    address[] public holders;
    mapping(address => uint256) public holderIndex;

    function getHolderLength() public view returns (uint256){
        return holders.length;
    }

    function _addHolder(address adr) private {
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

    mapping(address => bool) public excludeHolder;
    uint256 public currentHolderIndex;
    uint256 public holderRewardCondition;
    uint256 public holderCondition;
    uint256 public processHolderBlock;
    uint256 public processHolderBlockDebt = 0;

    function processHolderReward(uint256 gas) private {
        if (processHolderBlock + processHolderBlockDebt > block.number) {
            return;
        }

        IERC20 RewardToken = IERC20(_buybackToken);
        uint256 rewardCondition = holderRewardCondition;
        if (RewardToken.balanceOf(address(this)) < rewardCondition) {
            return;
        }

        uint256 totalLockAmount = totalSupply();

        address shareHolder;
        uint256 lockAmount;
        uint256 rewardAmount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = holderCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentHolderIndex >= shareholderCount) {
                currentHolderIndex = 0;
            }
            shareHolder = holders[currentHolderIndex];
            if (!excludeHolder[shareHolder]) {
                lockAmount = _balances[shareHolder];
                if (lockAmount >= holdCondition) {
                    rewardAmount = rewardCondition * lockAmount / totalLockAmount;
                    if (rewardAmount > 0) {
                        RewardToken.transfer(shareHolder, rewardAmount);
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentHolderIndex++;
            iterations++;
        }
        processHolderBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setHolderBlockDebt(uint256 debt) external onlyOwner {
        processHolderBlockDebt = debt;
    }

    function setHolderCondition(uint256 amount) external onlyOwner {
        holderCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }
}

contract RabbitRound is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //NFT
        address(0x2a311c09C6b93c36422Ba2e8ce5dc1CDb2328e39),
        "Rabbit Round Round",
        "Rabbit Round",
        18,
        100000000,
    //Fund
        address(0x52E55655878e6697e047dFEB3e43E05b595072Ce),
    //Received
        address(0x52E55655878e6697e047dFEB3e43E05b595072Ce)
    ){

    }
}