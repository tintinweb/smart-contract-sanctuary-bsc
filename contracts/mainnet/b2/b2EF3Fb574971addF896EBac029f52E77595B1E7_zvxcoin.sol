/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IBEP20 {
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
    event Burn(address indexed owner, address indexed to, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract TokenRecipient {
    constructor(address token) {
        IBEP20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}

contract zvxcoin is Ownable, IBEP20 {
    using SafeMath for uint256;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    address private _pairAddress;
    IPancakeRouter02 private _router;
    TokenRecipient private _tokenRecipient;
    address private WBNB = 0x55d398326f99059fF775485246999027B3197955;
    address private pancakeRouterAddr =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public marketing = 0xf92e356647915b9750404de0CA341c664839D764; // 营销地址
    uint256 public buyFeeToDifidend = 3;
    uint256 public buyFeeToMarketing = 1;
    uint256 public buyFeeToInviter = 2;
    uint256 public sellFeeToDifidend = 3;
    uint256 public sellFeeToMarketing = 1;
    uint256 public sellFeeToInviter = 2;

    uint256 public feeToLpDifidend = 4;
    uint256 public feeToLiquidity = 2;
    uint256 public feeToburn = 1;

    uint256 public amountToStopBurn;
    uint256 public amountTodifidend;
    uint256 public amountToAddLiquidity;
    uint256 public amountToDifidendWBNB;
    address[] public tokenHolders;
    mapping(address => bool) private _holderIsExist;
    mapping(address => bool) public _exemptFee;
    mapping(address => bool) private _isBlacklist;
    mapping(address => address) public inviter;
    uint256 private _blacklistStartTime;
    bool private _isFirstAddLiquidityFlag;
    bool public firstadd = false;

    constructor() {
        _name = "XXXcoin";
        _symbol = "XXX";
        _decimals = 18;
        _totalSupply = 1000000000000000 * (10**18); //总供应量
        _balances[msg.sender] = _totalSupply;
        tokenHolders.push(msg.sender);
        _holderIsExist[msg.sender] = true;
        _router = IPancakeRouter02(pancakeRouterAddr);
        _pairAddress = IPancakeFactory(_router.factory()).createPair(
            _router.WETH(),
            address(this)
        );
        _tokenRecipient = new TokenRecipient(WBNB);
        _exemptFee[marketing] = true;
        _exemptFee[msg.sender] = true;
        _exemptFee[address(this)] = true;
        _exemptFee[pancakeRouterAddr] = true;
        amountToStopBurn = _totalSupply.div(2); //销毁一半时就不再销毁
        amountToAddLiquidity = _totalSupply.div(100000); //LP回流的阀值
        amountTodifidend = _totalSupply.div(50000000000); //获得分红的最小持币量
        amountToDifidendWBNB = _totalSupply.div(1000000); //分红wbnb的阀值
        emit Transfer(address(0), marketing, _totalSupply);
    }

    receive() external payable {}

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
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

    function allowance(address towner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[towner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(
            sender,
            msg.sender,
            currentAllowance.sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_isBlacklist[sender], "Transfer from the blackList address");
        if (!_isFirstAddLiquidityFlag && address(recipient) == _pairAddress) {
            require(address(sender) == owner(), "firstadd need owner");
            _isFirstAddLiquidityFlag = true;
            _blacklistStartTime = block.timestamp;
        }
        if (
            block.timestamp <= (_blacklistStartTime + 15 seconds) &&
            address(sender) == _pairAddress
        ) {
            _isBlacklist[recipient] = true;
        }
        bool isInviter = sender != _pairAddress &&
            balanceOf(recipient) == 0 &&
            inviter[recipient] == address(0);
        if (isInviter) {
            inviter[recipient] = sender;
        }
        if (
            recipient != address(0) &&
            !_holderIsExist[recipient] &&
            recipient != address(_pairAddress) &&
            recipient != address(this) &&
            recipient != address(_tokenRecipient)
        ) {
            tokenHolders.push(recipient);
            _holderIsExist[recipient] = true;
        }
        uint256 finalAmount = amount;
        if (sender == _pairAddress && !_exemptFee[recipient]) {
            // buy
            finalAmount = processFee(
                sender,
                recipient,
                amount,
                buyFeeToDifidend,
                buyFeeToMarketing,
                buyFeeToInviter
            );
        }
        if (
            recipient == _pairAddress &&
            !_exemptFee[sender] &&
            sender != address(marketing)
        ) {
            // sell or addLiquidity
            finalAmount = processFee(
                sender,
                recipient,
                amount,
                sellFeeToDifidend,
                sellFeeToMarketing,
                sellFeeToInviter
            );
        }
        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(finalAmount);
        emit Transfer(sender, recipient, finalAmount);
    }

    function processFee(
        address sender,
        address recipient,
        uint256 amount,
        uint256 feeToDifidend,
        uint256 feeToMarketing,
        uint256 feeToInviter
    ) private returns (uint256 finalAmount) {
        uint256 difidendAmount = amount.mul(feeToDifidend).div(100);
        _balances[address(_tokenRecipient)] = _balances[
            address(_tokenRecipient)
        ].add(difidendAmount);
        difidendToAllHolders(sender);
        uint256 difidendToLPHoldersAmount = amount.mul(feeToLpDifidend).div(
            100
        );
        difidendToLPHolders(sender, difidendToLPHoldersAmount);
        uint256 addLiquidityAmount = amount.mul(feeToLiquidity).div(100);
        _balances[address(this)] = _balances[address(this)].add(
            addLiquidityAmount
        );
        emit Transfer(sender, address(this), addLiquidityAmount);
        swapAndAddLiquidity(sender);
        uint256 amountToMarketing = amount.mul(feeToMarketing).div(100);
        _balances[marketing] = _balances[marketing].add(amountToMarketing);
        emit Transfer(sender, marketing, amountToMarketing);
        uint256 burnAmount;
        if (_totalSupply > amountToStopBurn) {
            burnAmount = amount.mul(feeToburn).div(100);
            _balances[address(0)] = _balances[address(0)].add(burnAmount);
            _totalSupply = _totalSupply.sub(burnAmount);
            emit Transfer(sender, address(0), burnAmount);
        }
        uint256 amountToInviter = amount.mul(feeToInviter).div(100);
        difidendToInviter(sender, recipient, amountToInviter);
        uint256 tatalFeeAmounts = difidendAmount
            .add(difidendToLPHoldersAmount)
            .add(addLiquidityAmount);
        tatalFeeAmounts = tatalFeeAmounts
            .add(amountToMarketing)
            .add(burnAmount)
            .add(amountToInviter);
        finalAmount = amount.sub(tatalFeeAmounts);
    }

    function difidendToAllHolders(address sender) private {
        if (
            _balances[address(_tokenRecipient)] < amountToDifidendWBNB ||
            sender == address(this) ||
            sender == _pairAddress
        ) {
            return;
        }
        uint256 swapAmount = _balances[address(_tokenRecipient)];
        _balances[address(_tokenRecipient)] = 0;
        _balances[address(this)] = _balances[address(this)].add(swapAmount);
        _approve(address(this), pancakeRouterAddr, swapAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        IPancakeRouter02(_router)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                swapAmount,
                0,
                path,
                address(_tokenRecipient),
                block.timestamp
            );
        uint256 totalAmount;
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            totalAmount = totalAmount + _balances[tokenHolders[i]];
        }
        uint256 balances = IBEP20(WBNB).balanceOf(address(_tokenRecipient));
        uint256 difidentBalances;
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            uint256 amount = _balances[tokenHolders[i]];
            if (amount > amountTodifidend) {
                uint256 reward = balances.mul(amount).div(totalAmount);
                if (reward > 0) {
                    IBEP20(WBNB).transferFrom(
                        address(_tokenRecipient),
                        tokenHolders[i],
                        reward
                    );
                    difidentBalances = difidentBalances.add(reward);
                }
            }
        }
        uint256 leftBalances = balances.sub(difidentBalances);
        if (leftBalances > 0) {
            IBEP20(WBNB).transferFrom(
                address(_tokenRecipient),
                marketing,
                leftBalances
            );
        }
    }

    function difidendToLPHolders(address sender, uint256 amount) private {
        uint256 totalLPAmount = IBEP20(_pairAddress).totalSupply();
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            uint256 LPAmount = IBEP20(_pairAddress).balanceOf(tokenHolders[i]);
            if (LPAmount > 0) {
                uint256 difidendAmount = amount.mul(LPAmount).div(
                    totalLPAmount
                );
                _balances[tokenHolders[i]] = _balances[tokenHolders[i]].add(
                    difidendAmount
                );
                emit Transfer(sender, tokenHolders[i], difidendAmount);
            }
        }
    }

    function difidendToInviter(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        address cur;
        address receiveD;
        if (sender == _pairAddress) {
            cur = recipient;
        } else {
            cur = sender;
        }
        for (int256 i = 0; i < 2; i++) {
            cur = inviter[cur];
            if (cur == address(0)) {
                receiveD = marketing;
            } else {
                receiveD = cur;
            }
            uint256 amountToInviter = amount.div(2);
            _balances[receiveD] = _balances[receiveD].add(amountToInviter);
            emit Transfer(sender, receiveD, amountToInviter);
        }
    }

    function swapAndAddLiquidity(address sender) private {
        if (
            _balances[address(this)] < amountToAddLiquidity ||
            sender == address(this) ||
            sender == _pairAddress
        ) {
            return;
        }
        uint256 balanceBefore = address(this).balance;
        uint256 amountToSwap = _balances[address(this)].div(2);
        _approve(address(this), pancakeRouterAddr, _balances[address(this)]);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 receivedBalance = address(this).balance.sub(balanceBefore);
        if (receivedBalance > 0) {
            uint256 amount = _balances[address(this)];
            _router.addLiquidityETH{value: receivedBalance}(
                address(this),
                amount,
                0,
                0,
                marketing,
                block.timestamp
            );
        }
    }

    function setBuyFeeToDifidend(uint256 value) public onlyOwner {
        buyFeeToDifidend = value;
    }

    function setBuyFeeToMarketing(uint256 value) public onlyOwner {
        buyFeeToMarketing = value;
    }

    function setBuyFeeToInviter(uint256 value) public onlyOwner {
        buyFeeToInviter = value;
    }

    function setSellFeeToDifidend(uint256 value) public onlyOwner {
        sellFeeToDifidend = value;
    }

    function setSellFeeToMarketing(uint256 value) public onlyOwner {
        sellFeeToMarketing = value;
    }

    function setSellFeeToInviter(uint256 value) public onlyOwner {
        sellFeeToInviter = value;
    }

    function setAmountToStopBurn(uint256 value) public onlyOwner {
        amountToStopBurn = value;
    }

    function setAmountToAddLiquidity(uint256 value) public onlyOwner {
        amountToAddLiquidity = value;
    }

    function exemptFromFee(address account, bool flag) public onlyOwner {
        _exemptFee[account] = flag;
    }

    function addToBlacklist(address account, bool flag) public onlyOwner {
        _isBlacklist[account] = flag;
    }

    function setAmountTodifidend(uint256 value) public onlyOwner {
        amountTodifidend = value;
    }
}