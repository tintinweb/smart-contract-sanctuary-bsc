// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Ownable.sol";
import "./ISwapFactory.sol";
import "./ISwapRouter.sol";

interface FeeDistributor {
    function distribute() external returns(bool);
}
contract YD is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public dividendAddress;
    address public lpDivAddress;
    address public tecDivAddress;

    string private _name = 'YD';
    string private _symbol = 'YD';
    uint8 private _decimals = 18;


    address public mainPair;

    mapping(address => bool) private _feeWhiteList;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;

    ISwapRouter public _swapRouter;

    address public _sellFeeDistributor;
    address public _buyFeeDistributor;
    address private usdt;

    uint256 private startTradeBlock;
    address public adm;



    constructor (address FundAddress, address DividendAddress,address LpDivAddress,address TecDivAddress,address router,address usdtAddr){
        _swapRouter = ISwapRouter(router);
        usdt = usdtAddr;
        adm = msg.sender;

        mainPair = ISwapFactory(_swapRouter.factory()).createPair(address(this), usdt);
        _allowances[address(this)][address(_swapRouter)] = MAX;
        IERC20(usdt).approve(address(_swapRouter), MAX);

        _tTotal = 2888 * 10 ** _decimals;
        _balances[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        fundAddress = FundAddress;
        dividendAddress = DividendAddress;
        lpDivAddress = LpDivAddress;
        tecDivAddress = TecDivAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[LpDivAddress] = true;
        _feeWhiteList[TecDivAddress] = true;
        _feeWhiteList[DividendAddress] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;
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

    function totalSupply() external view override returns (uint256) {
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
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");


        if (from == mainPair || to == mainPair) {
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "Trade not start");
                startTradeBlock = block.number;
            }
            if(mainPair == from){
                addLpProvider(to);
                _tokenTransfer(from, to, amount, 1);
            }else{
                addLpProvider(from);
                _tokenTransfer(from, to, amount, 2);
            }

            FeeDistributor(_buyFeeDistributor).distribute();
            FeeDistributor(_sellFeeDistributor).distribute();

        }else{
            _tokenTransfer(from,to,amount,0);
        }

        if (from != address(this) && startTradeBlock > 0){
            processLP(500000);
        }

    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint8 flag
    ) private {
        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount;
        if(flag == 1 && !_feeWhiteList[sender] && !_feeWhiteList[recipient]){
            feeAmount = tAmount * 2 / 100;
            _takeTransfer(sender, _buyFeeDistributor, feeAmount);
        }
        if(flag == 2 && !_feeWhiteList[sender] && !_feeWhiteList[recipient]){
            feeAmount = tAmount * 6 / 100;
            _takeTransfer(sender, _sellFeeDistributor, feeAmount);
        }
        tAmount = tAmount - feeAmount;
        _takeTransfer(sender, recipient, tAmount);
    }


    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    receive() external payable {}

    function setFeeWhiteList(address addr, bool enable) external {
        require(msg.sender == adm,'only adm');
        _feeWhiteList[addr] = enable;
    }

    function isFeeWhiteList(address addr) external view returns (bool){
        return _feeWhiteList[addr];
    }



    function claimBalance() public {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) public {
        IERC20(token).transfer(fundAddress, amount);
    }


    address[] private lpProviders;
    mapping(address => uint256) lpProviderIndex;
    mapping(address => bool) excludeLpProvider;

    function addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 private currentIndex;
    uint256 private lpRewardCondition = 10;
    uint256 private progressLPBlock;

    function processLP(uint256 gas) private {
        if (progressLPBlock + 200 > block.number) {
            return;
        }
        uint totalPair = IERC20(mainPair).totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(this));
        if (usdtBalance < lpRewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;

        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = lpProviders[currentIndex];
            pairBalance = IERC20(mainPair).balanceOf(shareHolder);
            if (pairBalance > 0 && !excludeLpProvider[shareHolder]) {
                amount = usdtBalance * pairBalance / totalPair;
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
    }

    function setLPRewardCondition(uint256 amount) external {
        require(msg.sender == adm,'only adm');
        lpRewardCondition = amount;
    }
    function setAdm(address newAdm) external {
        require(msg.sender == adm,'only adm');
        adm = newAdm;
    }
    function setDistributor(address buyDistributor,address sellDistributor) external {
        require(msg.sender == adm,'only adm');
        _buyFeeDistributor = buyDistributor;
        _sellFeeDistributor = sellDistributor;
    }

    function setExcludeLPProvider(address addr, bool enable) external {
        require(msg.sender == adm,'only adm');
        excludeLpProvider[addr] = enable;
    }


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


abstract contract Ownable {
    address private _owner;

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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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