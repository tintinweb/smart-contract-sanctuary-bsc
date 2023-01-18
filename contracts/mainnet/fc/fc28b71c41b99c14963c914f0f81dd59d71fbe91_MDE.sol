// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "AbsToken.sol";

contract MDE is AbsToken {constructor()AbsToken(address(0x10ED43C718714eb63d5aA57B78B54704E256024E),address(0x55d398326f99059fF775485246999027B3197955),"MDE","MDE",18,16396263,address(0x4A46D6204DBF65f1AC2Ec06135164f5C731cDE32),address(0xC14971Fa1EF3F272E05355Ce03fbEEdF9aB79513),1000){}}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "IERC20.sol";
import "Ownable.sol";
import "ISwapRouter.sol";
import "TokenDistributor.sol";
import "TokenDistributor.sol";
import "ISwapFactory.sol";

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    address private _usdt;

    mapping(address => bool) private _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor private _tokenDistributor;

    uint256 public _buyInviteFee = 200;
    uint256 public _buyFundFee = 50;

    uint256 public _sellHoldersFee = 80;
    uint256 public _sellFundFee = 50;
    uint256 public _sellLPDividendFee = 120;

    uint256 public _transferFee = 0;

    uint256 public startTradeBlock;

    uint256 public startAddLPBlock;

    address public _mainPair;

    mapping(address => address) public _invitor;

    uint256 public _invitorHoldCondition;

    uint256 public _numToSell;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address RouterAddress,
        address USDTAddress,
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply,
        address FundAddress,
        address ReceiveAddress,
        uint256 NumToSell
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

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

        uint256 total = Supply * 10**Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _tokenDistributor = new TokenDistributor(usdt);

        excludeHolder[address(0)] = true;
        excludeHolder[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        holderRewardCondition = 100 * 10**Decimals;

        _numToSell = NumToSell * 10**Decimals;
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

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
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
        bool takeFee;

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (_swapPairList[to]) {
                addHolder(from);
            }
            processReward(500000);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount = (tAmount * 99) / 100;
        _takeTransfer(sender, fundAddress, feeAmount);
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
            if (_swapPairList[sender]) {
                //Buy

                uint256 inviteAmount = (tAmount * _buyInviteFee) / 10000;
                if (inviteAmount > 0) {
                    feeAmount += inviteAmount;
                    address current = recipient;
                    uint256 perInviteAmount = inviteAmount / 2;
                    uint256 invitorHoldCondition = _invitorHoldCondition;
                    uint256 invitorAmount;
                    for (uint256 i; i < 1; ++i) {
                        address inviter = _invitor[current];
                        if (address(0) == inviter) {
                            break;
                        }
                        if (
                            invitorHoldCondition == 0 ||
                            balanceOf(inviter) >= invitorHoldCondition
                        ) {
                            if (0 == i) {
                                invitorAmount = perInviteAmount * 1;
                            } else {
                                invitorAmount = perInviteAmount;
                            }
                            inviteAmount -= invitorAmount;
                            _takeTransfer(sender, inviter, invitorAmount);
                        }
                        current = inviter;
                    }
                }

                if (inviteAmount > 100) {
                    _takeTransfer(sender, fundAddress, inviteAmount);
                }

                uint256 fundAmount = (tAmount * _buyFundFee) / 10000;
                address tokenDistributor = address(_tokenDistributor);
                if (fundAmount > 0) {
                    feeAmount += fundAmount;
                    _takeTransfer(sender, tokenDistributor, fundAmount);
                }
            } else if (_swapPairList[recipient]) {
                //Sell

                uint256 fundAmount = (tAmount * _sellFundFee) / 10000;
                address tokenDistributor = address(_tokenDistributor);
                if (fundAmount > 0) {
                    feeAmount += fundAmount;
                    _takeTransfer(sender, tokenDistributor, fundAmount);
                }

                uint256 lpDividendAmount = (tAmount * _sellLPDividendFee) /
                    10000;
                if (lpDividendAmount > 0) {
                    feeAmount += lpDividendAmount;
                    _takeTransfer(sender, address(this), lpDividendAmount);
                }

                uint256 HolderAmount = (tAmount * _sellHoldersFee) / 10000;
                if (HolderAmount > 0) {
                    feeAmount += HolderAmount;
                    _takeTransfer(sender, address(this), HolderAmount);
                }

                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(tokenDistributor);
                    uint256 numTokensSellToFund = _numToSell;
                    if (contractTokenBalance >= numTokensSellToFund) {
                        _tokenTransfer(
                            tokenDistributor,
                            address(this),
                            contractTokenBalance,
                            false
                        );
                        swapTokenForFund(contractTokenBalance);
                    }
                }
            } else {
                //Transfer
                feeAmount = (tAmount * _transferFee) / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(
                        sender,
                        address(0x000000000000000000000000000000000000dEaD),
                        feeAmount
                    );
                }
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            fundAddress,
            block.timestamp
        );
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
    }

    function setBuyFee(uint256 buyInviteFee, uint256 buyFundFee)
        external
        onlyOwner
    {
        _buyInviteFee = buyInviteFee;
        _buyFundFee = buyFundFee;
    }

    function setSellFee(
        uint256 sellFundFee,
        uint256 sellLPDividendFee,
        uint256 sellHoldersFee
    ) external onlyOwner {
        _sellFundFee = sellFundFee;
        _sellLPDividendFee = sellLPDividendFee;
        _sellHoldersFee = sellHoldersFee;
    }

    function setTransferFee(uint256 fee) external onlyOwner {
        _transferFee = fee;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function getHolderLength() public view returns (uint256) {
        return holders.length;
    }

    function addHolder(address adr) private {
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                uint256 size;
                assembly {
                    size := extcodesize(adr)
                }
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
    uint256 public progressRewardBlock;

    function processReward(uint256 gas) private {
        if (0 == startTradeBlock) {
            return;
        }

        address sender = address(this);
        uint256 balance = balanceOf(sender);

        if (balance < holderRewardCondition) {
            return;
        }

        IERC20 mainPair = IERC20(_mainPair);

        address shareHolder;
        uint256 tokenBalance;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = mainPair.balanceOf(shareHolder);

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setInvitorHoldCondition(uint256 amount) external onlyOwner {
        _invitorHoldCondition = amount;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface ISwapFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../IERC20.sol";

contract TokenDistributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface ISwapRouter {
    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}