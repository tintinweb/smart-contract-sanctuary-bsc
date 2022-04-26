pragma solidity 0.8.12;
// SPDX-License-Identifier: Unlicensed

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Router01.sol";
import "./interfaces/IUniswapV2Router02.sol";

import "./interfaces/IPYE.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IPYESwapFactory.sol";
import "./interfaces/IPYESwapPair.sol";
import "./interfaces/IPYESwapRouter.sol";

contract DMTPyeSwap is Context, IPYE, Ownable {
    using Address for address;
    // Fees
    // Add and remove fee types and destinations here as needed
    struct Fees {
        uint256 performanceFee;
        uint256 rewardFee;
        uint256 liquidityFee;
        uint256 burnFee;
        address performanceAddress;
        address rewardAddress;
        address liquidityAddress;
        address burnAddress;
    }

    // Transaction fee values
    // Add and remove fee value types here as needed
    struct FeeValues {
        uint256 transferAmount;
        uint256 performance;
        uint256 reward;
        uint256 liquidity;
        uint256 burn;
    }

    struct Balance {
        uint256 r;
        uint256 t;
    }

    mapping(address => Balance) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee; // exclude from any fees
    mapping(address => bool) private _isExcludedFromReward; // exclude from rewards
    address[] private _excluded; // exclude from rewards
    //mapping (address => bool) isTxLimitExempt;//PYE

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 10 * 10**6 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    // Pair Details PYE
    mapping(uint256 => address) private pairs;
    mapping(uint256 => address) private tokens;
    uint256 private pairsLength;

    Fees public _defaultFees;
    Fees private _previousFees;
    Fees private _emptyFees;

    string private _name = "Demetra Token (testnet)";
    string private _symbol = "DMT3";
    uint8 private _decimals = 9;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    // address public uniswapV2RouterAddress;

    IPYESwapRouter public pyeSwapRouter;
    address public pyeSwapPair;
    //address public pyeSwapRouterAddress;
    address public WBNB;
    address public _burnAddress = 0x000000000000000000000000000000000000dEaD;
    //uint256 public maxTxAmount = 2000000 * 10**9;
    uint256 public swapThreshold = 5 * 10**14; // 0.0005 WBNB

    bool public swapEnabled = true;
    bool inSwap;
    bool isPye;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    modifier onlyExchange() {
        bool isPair = false;
        for (uint256 i = 0; i < pairsLength; i++) {
            if (pairs[i] == msg.sender) isPair = true;
        }
        require(
            msg.sender == address(pyeSwapRouter) || isPair,
            "PYE: NOT_ALLOWED"
        );
        _;
    }

    event msgLog(string txt);

    constructor() {
        //uniswapV2RouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        //pyeSwapRouterAddress = 0x6b2e0d1e1d1922a08A7C7BCed77aD38a0C2A2C5d;
        // Create a uniswap pair for this new token
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        //Create a PYE swap pair for this new token
        pyeSwapRouter = IPYESwapRouter(
            0x6b2e0d1e1d1922a08A7C7BCed77aD38a0C2A2C5d
        );
        WBNB = pyeSwapRouter.WETH();
        pyeSwapPair = IPYESwapFactory(pyeSwapRouter.factory()).createPair(
            address(this),
            WBNB,
            true
        );

        tokens[pairsLength] = WBNB;
        pairs[pairsLength] = pyeSwapPair;
        pairsLength += 1;

        //set rest of variables
        _defaultFees = Fees({
            performanceFee: 100,
            rewardFee: 300,
            liquidityFee: 300,
            burnFee: 300,
            performanceAddress: 0x55Cb93C70969955141AE7E6e0cb2d9950d2c1989,
            rewardAddress: 0x07B19D13A025732F2A0f292ea9F88C5989fe1426,
            liquidityAddress: 0x88FA28De96204181FcB6Cc8a0622f37c89693C91,
            burnAddress: 0x8f9537d3e6090CcbBf66207ec508581F516083d3
        });

        _balances[_msgSender()].r = _rTotal;
        excludeFromFee(owner(), true);
        excludeFromReward(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //uni router
        excludeFromReward(address(this));
        //PYE excludes
        excludeFromFee(pyeSwapPair, true);
        excludeFromReward(0x6b2e0d1e1d1922a08A7C7BCed77aD38a0C2A2C5d); //pye router

        // isTxLimitExempt[_msgSender()] = true;
        // isTxLimitExempt[pyeSwapPair] = true;
        // isTxLimitExempt[uniswapV2Pair] = true;
        // isTxLimitExempt[address(pyeSwapRouter)] = true;
        // isTxLimitExempt[address(uniswapV2Router)] = true;

        IPYESwapPair(pyeSwapPair).updateTotalFee(1000);

        emit Transfer(address(0), _msgSender(), _tTotal);
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromReward[account]) return _balances[account].t;
        return tokenFromReflection(_balances[account].r);
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), to, amount);
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
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        _transfer(from, to, amount);
        require(
            _allowances[from][_msgSender()] >= amount,
            "BEP20:amount exceeds allowance"
        );
        _approve(from, _msgSender(), _allowances[from][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        require(
            _allowances[_msgSender()][spender] >= subtractedValue,
            "BEP20:decreased allowance below zero"
        );
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcludedFromReward[account];
    }

    function reflect(uint256 tAmount) public {
        address from = _msgSender();
        require(!_isExcludedFromReward[from], "Excluded address");
        _balances[from].r = _balances[from].r - (tAmount * _getRate());
        _rTotal = _rTotal - (tAmount * _getRate());
    }

    function reflectionFromToken(uint256 tAmount, address account)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount exceeds supply");

        if (_isExcludedFromFee[account]) {
            return tAmount * _getRate();
        } else {
            FeeValues memory _values = _getValues(tAmount);
            uint256 tTransferAmount = _values.transferAmount;
            uint256 rTransferAmount = tTransferAmount * _getRate();
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(rAmount <= _rTotal, "Amount exceeds total reflections");
        return rAmount / _getRate();
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcludedFromReward[account], "Account already excluded");
        if (_balances[account].r > 0) {
            _balances[account].t = tokenFromReflection(_balances[account].r);
        }
        _isExcludedFromReward[account] = true;
        _excluded.push(account);
    }

    function IncludeInReward(address account) public onlyOwner {
        require(_isExcludedFromReward[account], "Account already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _balances[account].t = 0;
                _isExcludedFromReward[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function calculateFee(uint256 _amount, uint256 _fee)
        private
        pure
        returns (uint256)
    {
        if (_fee == 0) return 0;
        return _amount * (_fee / 10**4);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20:approve from zero address");
        require(spender != address(0), "ERC20:approve to zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 tAmount
    ) internal {
        require(from != address(0), "ERC20:transfer from zero address");
        require(to != address(0), "ERC20:transfer to zero address");
        require(tAmount > 0, "Amount must be greater than zero");
        //require(amount <= maxTxAmount || isTxLimitExempt[from], "TX Limit Exceeded");
        //checkTxLimit(from, amount);
        //indicates if fee should be deducted from transfer of tokens
        bool takeFee = true;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        isPye = false;

        if (
            to == 0x6b2e0d1e1d1922a08A7C7BCed77aD38a0C2A2C5d ||
            from == 0x6b2e0d1e1d1922a08A7C7BCed77aD38a0C2A2C5d
        ) isPye = true;

        if (!takeFee) {
            removeAllFee();
        }

        // if (isPye) 
        //     _transferBothExcluded(from, to, amount);
        // else
            
        _tokenTransfer(from, to, tAmount);

        if (!takeFee) {
            restoreAllFee();
        }
    }

    //pye
    // function _takeFeesPye(address from,FeeValues memory values) private {
    //     _takeFee(from,values.performance, address(this));
    //     _takeFee(from,values.burn, address(this));
    //     _takeFee(from,values.liquidity,address(this));
    //     _takeFee(from,values.reward, address(this));
    //     //_takeBurn(from, _values.burn);
    // }
    //pye
    // function _takeFeePye(uint256 tAmount, address to) private {
    //     if(to == address(0)) return;
    //     if(tAmount == 0) return;

    //     _balances[address(this)].t += tAmount;
    //     _balances[address(this)].r += tAmount * _getRate();
    // }

    function _takeFees(address sender, FeeValues memory values) private {
        if (isPye) {
            _takeFee(sender, values.performance, address(this));
            _takeFee(sender, values.burn, address(this));
            _takeFee(sender, values.liquidity, address(this));
            _takeFee(sender, values.reward, address(this));
        } else {
            _takeFee(sender, values.liquidity, _defaultFees.liquidityAddress);
            _takeFee(
                sender,
                values.performance,
                _defaultFees.performanceAddress
            );
            _takeFee(sender, values.burn, _defaultFees.burnAddress);
            _reflectReward(values.reward * _getRate());
        }

        //_takeBurn(sender, values.burn);
    }

    function _takeFee(
        address sender,
        uint256 tAmount,
        address recipient
    ) private {
        if (recipient == address(0)) return;
        if (tAmount == 0) return;

        //uint256 rAmount = tAmount * _getRate();
        _balances[recipient].r += tAmount * _getRate();
        if (_isExcludedFromReward[recipient]) _balances[recipient].t += tAmount;

        emit Transfer(sender, recipient, tAmount);
    }

    // function _takeBurn(address sender, uint256 _amount) private {
    //     if(_amount == 0) return;
    //     _balances[_burnAddress].t +=_amount;
    //     emit Transfer(sender, _burnAddress, _amount);
    // }

    //pye
    // This function transfers the fees to the correct addresses.
    function depositLPFee(uint256 amount, address token) public onlyExchange {
        uint256 tokenIndex = _getTokenIndex(token);
        if (tokenIndex < pairsLength) {
            uint256 allowanceT = IERC20(token).allowance(
                msg.sender,
                address(this)
            );
            if (allowanceT >= amount) {
                IERC20(token).transferFrom(msg.sender, address(this), amount);

                // All fees to be declared here in order to be calculated and sent
                uint256 totalFee = getTotalFee();
                uint256 performanceFeeAmount = amount *
                    (_defaultFees.performanceFee / totalFee);
                uint256 burnFeeAmount = amount *
                    (_defaultFees.burnFee / totalFee);
                uint256 liquidityFeeAmount = amount *
                    (_defaultFees.liquidityFee / totalFee);
                uint256 rewardFeeAmount = amount *
                    (_defaultFees.rewardFee / totalFee);

                IERC20(token).transfer(
                    _defaultFees.performanceAddress,
                    performanceFeeAmount
                );
                IERC20(token).transfer(_defaultFees.burnAddress, burnFeeAmount);
                IERC20(token).transfer(
                    _defaultFees.liquidityAddress,
                    liquidityFeeAmount
                );
                IERC20(token).transfer(
                    _defaultFees.rewardAddress,
                    rewardFeeAmount
                );
            }
        }
    }

    //pye
    function _getTokenIndex(address _token) internal view returns (uint256) {
        uint256 index = pairsLength + 1;
        for (uint256 i = 0; i < pairsLength; i++) {
            if (tokens[i] == _token) index = i;
        }

        return index;
    }

    //pye
    function addPair(address _pair, address _token) public {
        address factory = pyeSwapRouter.factory();
        require(
            msg.sender == factory ||
                msg.sender == address(pyeSwapRouter) ||
                msg.sender == address(this),
            "PYE: NOT_ALLOWED"
        );

        if (!_checkPairRegistered(_pair)) {
            _isExcludedFromFee[_pair] = true;
            //isTxLimitExempt[_pair] = true;

            pairs[pairsLength] = _pair;
            tokens[pairsLength] = _token;

            pairsLength += 1;

            IPYESwapPair(_pair).updateTotalFee(getTotalFee());
        }
    }

    //pye
    function _checkPairRegistered(address _pair) internal view returns (bool) {
        bool isPair = false;
        for (uint256 i = 0; i < pairsLength; i++) {
            if (pairs[i] == _pair) isPair = true;
        }

        return isPair;
    }

    //pye
    //  function getCirculatingSupply() public view returns (uint256) {

    //     return _tTotal - balanceOf(_burnAddress) - balanceOf(address(0));
    // }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        // if(!takeFee)
        //     removeAllFee();

        if (
            _isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]
        ) {
            _transferFromExcluded(sender, recipient, tAmount);
        } else if (
            !_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]
        ) {
            _transferToExcluded(sender, recipient, tAmount);
        } else if (
            !_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]
        ) {
            _transferStandard(sender, recipient, tAmount);
        } else if (
            _isExcludedFromReward[sender] && _isExcludedFromReward[recipient]
        ) {
            _transferBothExcluded(sender, recipient, tAmount);
        } else {
            _transferStandard(sender, recipient, tAmount);
        }

        // if(!takeFee)
        //     restoreAllFee();
    }

    function _reflectReward(uint256 rDist) internal {
        _rTotal = _rTotal - rDist;
    }

    function _transferStandard(
        address from,
        address to,
        uint256 tAmount
    ) internal {
        FeeValues memory _values = _getValues(tAmount);
        _balances[from].r -= _values.transferAmount * _getRate();
        _balances[to].r += _values.transferAmount * _getRate();
        _takeFees(from, _values);
        //_reflectReward(_values.reward * _getRate());
        emit Transfer(from, to, _values.transferAmount);
    }

    function _transferToExcluded(
        address from,
        address to,
        uint256 tAmount
    ) private {
        FeeValues memory _values = _getValues(tAmount);
        _balances[from].r -= (tAmount * _getRate());
        _balances[to].t += _values.transferAmount;
        _balances[to].r += _values.transferAmount * _getRate();
        _takeFees(from, _values);
        //_reflectReward(_values.reward * _getRate());
        emit Transfer(from, to, _values.transferAmount);
    }

    function _transferFromExcluded(
        address from,
        address to,
        uint256 tAmount
    ) internal {
        FeeValues memory _values = _getValues(tAmount);
        _balances[from].t -= tAmount;
        _balances[from].r -= (tAmount * _getRate());
        _balances[to].r += (tAmount * _getRate());
        _takeFees(from, _values);
       // _reflectReward(_values.reward * _getRate());
        emit Transfer(from, to, _values.transferAmount);
    }

    function _transferBothExcluded(
        address from,
        address to,
        uint256 tAmount
    ) internal {
        FeeValues memory _values = _getValues(tAmount);
        _balances[from].t -= tAmount;
        _balances[from].r -= (tAmount * _getRate());
        _balances[to].t += _values.transferAmount;
        _balances[to].r += (_values.transferAmount * _getRate());

        _takeFees(from, _values);

        emit Transfer(from, to, _values.transferAmount);
    }

    //pye
    //this method is responsible for taking all fee, if takeFee is true
    // function _tokenTransfer(address from, address to, uint256 amount) private {
    //     // if(!takeFee) {
    //     //     removeAllFee();
    //     // }

    //     FeeValues memory _values = _getValues(amount);
    //     require(_balances[from].t - amount >= 0, "Insufficient Balance");
    //     _balances[from].t -= amount;
    //     _balances[from].r -= (amount * _getRate());
    //     _balances[to].t += _values.transferAmount;
    //     _balances[to].r += _values.transferAmount * _getRate();
    //     _takeFeesPye(from,_values);

    //     emit Transfer(from, to, _values.transferAmount);

    //     // if(!takeFee) {
    //     //     restoreAllFee();
    //     // }
    // }

    function _getValues(uint256 tAmount)
        private
        view
        returns (FeeValues memory)
    {
        FeeValues memory values = FeeValues(
            0,
            calculateFee(100000000000000, _defaultFees.performanceFee),
            calculateFee(100000000000000, _defaultFees.rewardFee),
            calculateFee(100000000000000, _defaultFees.liquidityFee),
            calculateFee(100000000000000, _defaultFees.burnFee) 
        );

       

        values.transferAmount =
            tAmount -
            values.performance -
            values.reward -
            values.liquidity -
            values.burn;
        return values;
    }

    function _getRate() internal view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() internal view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _balances[_excluded[i]].r > rSupply ||
                _balances[_excluded[i]].t > tSupply
            ) return (_rTotal, _tTotal);
            rSupply -= _balances[_excluded[i]].r;
            tSupply -= _balances[_excluded[i]].t;
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    receive() external payable {}

    // function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
    //     maxTxAmount = (_tTotal * maxTxPercent) / 100;
    // }

    function excludeFromFee(address account, bool value) public onlyOwner {
        _isExcludedFromFee[account] = value;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    //pye
    function _updatePairsFee() internal {
        for (uint256 j = 0; j < pairsLength; j++) {
            IPYESwapPair(pairs[j]).updateTotalFee(getTotalFee());
        }
    }

    //pye
    function updateRouterAndPair(address _router, address _pair)
        public
        onlyOwner
    {
        _isExcludedFromFee[pyeSwapPair] = false;
        pyeSwapRouter = IPYESwapRouter(_router);
        pyeSwapPair = _pair;
        WBNB = pyeSwapRouter.WETH();

        _isExcludedFromFee[pyeSwapPair] = true;

        //isTxLimitExempt[pyeSwapPair] = true;
        //isTxLimitExempt[address(pyeSwapRouter)] = true;

        pairs[0] = pyeSwapPair;
        tokens[0] = WBNB;

        IPYESwapPair(pyeSwapPair).updateTotalFee(getTotalFee());
    }

    //pye
    function getTotalFee() internal view returns (uint256) {
        return
            _defaultFees.performanceFee +
            _defaultFees.burnFee +
            _defaultFees.liquidityFee +
            _defaultFees.rewardFee;
    }

    //pye
    function removeAllFee() private {
        _previousFees = _defaultFees;
        _defaultFees = _emptyFees;
    }

    //pye
    function restoreAllFee() private {
        _defaultFees = _previousFees;
    }

    // function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
    //     isTxLimitExempt[holder] = exempt;
    // }

    // function checkTxLimit(address from, uint256 amount) internal view {
    //     require(amount <= maxTxAmount || isTxLimitExempt[from], "TX Limit Exceeded");
    // }

    function updateUniswapV2Router(address newRouter) public onlyOwner {
        uniswapV2Router = IUniswapV2Router02(newRouter);
        //uniswapV2Router = _newRouter;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
        excludeFromReward(newRouter);
    }

    //  // Functions to update fees and addresses
    function setFees(Fees calldata newFees) public onlyOwner {
        _defaultFees.rewardFee = newFees.rewardFee;
        _defaultFees.rewardAddress = newFees.rewardAddress;
        _defaultFees.liquidityFee = newFees.liquidityFee;
        _defaultFees.liquidityAddress = newFees.liquidityAddress;
        _defaultFees.burnFee = newFees.burnFee;
        _defaultFees.burnAddress = newFees.burnAddress;
        _defaultFees.performanceFee = newFees.performanceFee;
        _defaultFees.performanceAddress = newFees.performanceAddress;
        //_defaultFees = newFees;
    }

    // function setLiquidityFee(uint256 newLiquidityFee, address liquidityAddress) public onlyOwner {
    //     _defaultFees.liquidityFee = newLiquidityFee;
    //     _defaultFees.liquidityAddress = liquidityAddress;
    // }
    // function setBurnFee(uint256 newBurnFee, address burnAddress) public onlyOwner {
    //     _defaultFees.burnFee = newBurnFee;
    //     _defaultFees.burnAddress = burnAddress;
    // }
    // function setPerformanceFee(uint256 newPerformance, address performanceAddress) public onlyOwner {
    //     _defaultFees.performanceFee = newPerformance;
    //      _defaultFees.performanceAddress = performanceAddress;
    // }
    // Rescue bnb that is sent here by mistake
    function rescueBNB(uint256 amount, address to) external onlyOwner {
        payable(to).transfer(amount);
    }

    // Rescue tokens that are sent here by mistake
    function rescueToken(
        IERC20 token,
        uint256 amount,
        address to
    ) external onlyOwner {
        if (token.balanceOf(address(this)) < amount) {
            amount = token.balanceOf(address(this));
        }
        token.transfer(to, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IWETH {
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

pragma solidity 0.8.12;
// SPDX-License-Identifier: Unlicensed
import './IUniswapV2Router01.sol';
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity 0.8.12;
// SPDX-License-Identifier: Unlicensed

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity 0.8.12;
// SPDX-License-Identifier: Unlicensed

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity 0.8.12;
// SPDX-License-Identifier: Unlicensed

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


// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPYESwapRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

import './IPYESwapRouter01.sol';

interface IPYESwapRouter is IPYESwapRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function pairFeeAddress(address pair) external view returns (address);
    function adminFee() external view returns (uint256);
    function feeAddressGet() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IPYESwapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function baseToken() external view returns (address);
    function getTotalFee() external view returns (uint);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function updateTotalFee(uint totalFee) external returns (bool);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast, address _baseToken);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, uint amount0Fee, uint amount1Fee, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
    function setBaseToken(address _baseToken) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IPYESwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function pairExist(address pair) external view returns (bool);

    function createPair(address tokenA, address tokenB, bool supportsTokenFee) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function routerInitialize(address) external;
    function routerAddress() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IPYE {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);



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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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