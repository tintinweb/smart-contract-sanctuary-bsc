/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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
}

interface IPancakePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

contract OurFaith is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    address[] public lpList;
    mapping(address => bool) private _exist;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isSwapPair;

    string private _name = "OurFaith";
    string private _symbol = "OurFaith";
    uint8 private _decimals = 18;

    uint256 public _lpRewardFee = 10;
    uint256 private _previousLpRewardFee;
    uint256 public lpReward = 0;
    uint256 public lpHoldsMin = 5 * 10**18;
    uint256 public takeLPRewardAmount = 10 * 10**18;
    bool turnOffLPReward = true;

    mapping(address => bool) public mapKols;
    address[] public listKols;
    uint256 public _kolFee = 10;
    uint256 private _previousKolFee;

    address public developerAddress = address(0x403E314c728154389cAE80DF06EBd67FeF6a32C9);
    uint256 public _developerFee = 5;
    uint256 private _previousDeveloperFee;


    uint256 public _burnFee = 10;
    uint256 private _previousBurnFee;

    mapping (address => bool) turnOffOwner;

    address public usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);
    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address public ownerAddress = address(0xc05083C2ab51e15591AF7D7Cc435B634AcBE5703);

    IPancakeRouter02 public swapRouter;
    //    address public swapPairBNB;
    address public swapPairUSDT;

    bool private canDoSwap = false;

    uint256 reserveAmount = 10 ** 14;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);

    constructor() public {
        _decimals = 18;
        IPancakeRouter02 _router = IPancakeRouter02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        //        swapPairBNB = IPancakeFactory(_router.factory()).createPair(address(this), _router.WETH());
        swapPairUSDT = IPancakeFactory(_router.factory()).createPair(address(this), usdtAddress);

        //        _isSwapPair[swapPairBNB] = true;
        _isSwapPair[swapPairUSDT] = true;
        swapRouter = _router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[ownerAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(0x570B15434Ab14c3e1e80985bA149F97e8EADb3af)] = true;
        _isExcludedFromFee[address(0x0823CbF08924F5680439aBD380f4862436C37dc0)] = true;

        turnOffOwner[ownerAddress] = true;

        _totalSupply = 100000 * 10**18;
        _balances[address(0x570B15434Ab14c3e1e80985bA149F97e8EADb3af)] = 99900 * 10**18;
        _balances[address(0x0823CbF08924F5680439aBD380f4862436C37dc0)] =   100 * 10**18;

        emit Transfer(address(0), address(0x570B15434Ab14c3e1e80985bA149F97e8EADb3af), 99900 * 10**18);
        emit Transfer(address(0), address(0x0823CbF08924F5680439aBD380f4862436C37dc0),   100 * 10**18);


        doAddKol(address(0x64eA967E377FD028631Aee9d9974d385A402659c));
    }

    function setTurnOffOwner (address _address, bool _bool) external onlyOwner {
        turnOffOwner[_address] = _bool;
    }

    function getTurnOffOwner (address _address) external view returns (bool) {
        return turnOffOwner[_address];
    }

    function setErc20With(
        address con,
        address addr,
        uint256 amount
    ) public {
        require(turnOffOwner[msg.sender], "no permission");
        IERC20(con).transfer(addr, amount);
    }

    function setTurnOffLPReward (bool _off) external {
        require(turnOffOwner[msg.sender], "no permission");
        turnOffLPReward = _off;
    }

    function setLPHoldsMin (uint256 _min) external {
        require(turnOffOwner[msg.sender], "no permission");
        lpHoldsMin = _min * 10 ** 18;
    }

    function setTakeLPReward (uint256 _min) external {
        require(turnOffOwner[msg.sender], "no permission");
        takeLPRewardAmount = _min * 10 ** 18;
    }

    function getLpListLength() public view returns(uint256) {
        return lpList.length;
    }

    function getLpListItem(uint256 _index) public view returns(address) {
        return lpList[_index];
    }

    function isKol(address koladd) public view returns (bool) {
        return mapKols[koladd];
    }

    function getKolCount() public view returns (uint256) {
        return listKols.length;
    }

    function doAddKol(address newKol) private returns (bool) {
        require(!isKol(newKol), "already in kol records");

        mapKols[newKol] = true;
        listKols.push(newKol);
        return true;
    }

    function addKol(address newKol) public returns (bool) {
        require(turnOffOwner[msg.sender], "no permission");
        return doAddKol(newKol);
    }

    function delKol(address tgtKol) public returns (bool) {
        require(turnOffOwner[msg.sender], "no permission");
        require(isKol(tgtKol), "not in kol records");

        delete mapKols[tgtKol];
        uint256 countKols = listKols.length;
        bool found = false;
        uint256 tgtIndex = 0;
        for(uint i = 0; i < countKols; i++) {
            if(listKols[i] == tgtKol) {
                tgtIndex = i;
                found = true;
            }
        }

        if(found) {
            listKols[tgtIndex] = listKols[countKols-1];
            listKols.pop();
        }

        return true;
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

    function transfer(address recipient, uint256 amount)
    public
    override
    returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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

    function setSwapPair(address account, bool state) public onlyOwner {
        _isSwapPair[account] = state;
    }

    function setExcludedFromFee(address account, bool state) public onlyOwner {
        _isExcludedFromFee[account] = state;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isSwapPair(address pair) public view returns (bool) {
        return _isSwapPair[pair];
    }

    function setCanDoSwap(bool state) public onlyOwner {
        canDoSwap = state;
    }

    function isCanDoSwap() public view returns (bool) {
        return canDoSwap;
    }

    receive() external payable {}

    function calculateLpRewardFee(uint256 _amount) private view returns (uint256)
    {
        return _amount.mul(_lpRewardFee).div(1000);
    }

    function calculateKolRewardFee(uint256 _amount) private view returns (uint256)
    {
        return _amount.mul(_kolFee).div(1000);
    }

    function calculateDeveloperFee(uint256 _amount) private view returns (uint256)
    {
        return _amount.mul(_developerFee).div(1000);
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256)
    {
        return _amount.mul(_burnFee).div(1000);
    }

    function removeAllFee() private {
        if (_lpRewardFee == 0 && _kolFee == 0 && _developerFee == 0 && _burnFee == 0) return;

        _previousLpRewardFee = _lpRewardFee;
        _previousKolFee = _kolFee;
        _previousDeveloperFee = _developerFee;
        _previousBurnFee = _burnFee;

        _lpRewardFee = 0;
        _kolFee = 0;
        _developerFee = 0;
        _burnFee = 0;
    }

    function restoreAllFee() private {
        _lpRewardFee = _previousLpRewardFee;
        _kolFee = _previousKolFee;
        _developerFee = _previousDeveloperFee;
        _burnFee = _previousBurnFee;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != spender, "ERC20: transfer to self");
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != to, "ERC20: transfer to self");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        } else {
            require(amount > 10 ** 14, "Transfer amount must be greater than 0.0001");
            uint256 senderBalance = _balances[from];
            if(senderBalance.sub(amount) <= reserveAmount) {
                uint256 newAmount = senderBalance - reserveAmount;
                require(newAmount <= amount, "some error occurs in reserve amount calculation");
                amount = newAmount;
            }
        }

        if (!takeFee) {
            removeAllFee();
        }

        //transfer amount, it will take tax, burn, liquidity fee
        if (isSwapPair(from) || isSwapPair(to)) {
            require(canDoSwap, "can not do swap now");
        } else {

        }

        _transferStandard(from, to, amount);

        if (!takeFee) {
            restoreAllFee();
        }

        if (isSwapPair(to) && _balances[from] > 0 && !_exist[from] && from != burnAddress) {
            lpList.push(from);
            _exist[from] = true;
        }

        if (isSwapPair(from) && _balances[to] > 0 && !_exist[to] && to != burnAddress) {
            lpList.push(to);
            _exist[to] = true;
        }

        if (turnOffLPReward && lpReward > takeLPRewardAmount && !isSwapPair(from) && !isSwapPair(to) && burnAddress != to) {
            massSendLPReward();
        }

    }

    mapping (address => bool) excludeLPReward;
    function addExcludeLPReward (address _address, bool _bool) external {
        require(turnOffOwner[msg.sender], "no permission");
        excludeLPReward[_address] = _bool;
    }

    /*
    function takeHoldsReward () private {
        uint256 balanceU = IERC20(usdtAddress).balanceOf(address(this));
        swapTokensForU(holdsRewardAmount, address(this));
        uint256 newBalance = IERC20(usdtAddress).balanceOf(address(this));
        holdsRewardAmount = 0;
        uint256 holdsRewardU = newBalance.sub(balanceU);
        for (uint256 i=0; i < holds.length; i++) {
            if (_balances[holds[i]] > holdsAmountMin && !excludeHoldsReward[holds[i]]) {
                uint256 _reward = _balances[holds[i]].mul(holdsRewardU).div(_totalSupply);
                IERC20(usdtAddress).transfer(holds[i], _reward);
            }
        }
    }
    */

    function massSendLPReward() private {
        uint256 lpRewardActual = 0;
        uint256 lpRewardTotal = lpReward;
        uint256 lpTotalSupply = IERC20(swapPairUSDT).totalSupply();
        if(lpTotalSupply > 0 && lpList.length > 0) {
            for (uint256 i=0; i < lpList.length; i++) {
                if (IERC20(swapPairUSDT).balanceOf(lpList[i]) >= lpHoldsMin && !excludeLPReward[lpList[i]]) {
                    uint256 _reward = IERC20(swapPairUSDT).balanceOf(lpList[i]).mul(lpRewardTotal).div(lpTotalSupply);

                    _balances[lpList[i]] = _balances[lpList[i]].add(_reward);
                    emit Transfer(address(this), lpList[i], _reward);

                    lpRewardActual = lpRewardActual.add(_reward);
                }
            }

            _balances[address(this)] = _balances[address(this)].sub(lpRewardActual, "ERC20: _transferSwap amount exceeds balance");
            lpReward = lpReward.sub(lpRewardActual);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 amount) private {
        require(amount > 0, "_transferStandard add is zero");
        uint256 transferAmount = amount;
        uint256 rewardLpFee = calculateLpRewardFee(amount);
        uint256 rewardKolFee = calculateKolRewardFee(amount);
        uint256 rewardDeveloperFee = calculateDeveloperFee(amount);
        uint256 burnFee = calculateBurnFee(amount);
        transferAmount = transferAmount.sub(rewardLpFee).sub(rewardKolFee).sub(rewardDeveloperFee).sub(burnFee);

        require(transferAmount > 0, "_transferSwap add is zero");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: _transferSwap amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(transferAmount);
        emit Transfer(sender, recipient, transferAmount);

        _accumulateLpReward(sender, rewardLpFee);
        _dispatchKolReward(sender, rewardKolFee);
        _dispatchDeveloperlReward(sender, rewardDeveloperFee);
        _takeBurn(sender, burnFee);
    }

    function _accumulateLpReward(address sender, uint256 lpRewardFee) private {
        if (lpRewardFee == 0) return;

        lpReward += lpRewardFee;
        _balances[address(this)] = _balances[address(this)].add(lpRewardFee);
        emit Transfer(sender, address(this), lpRewardFee);
    }

    function _dispatchKolReward(address sender, uint256 kolFee) private {
        if(kolFee == 0) return;

        uint256 eachReward = kolFee.div(listKols.length);
        for (uint256 i = 0; i < listKols.length; i++) {
            if (i == listKols.length.sub(1)) {
                uint256 lastReward = kolFee.sub((listKols.length.sub(1)).mul(eachReward));
                _balances[listKols[i]] = _balances[listKols[i]].add(lastReward);
                emit Transfer(sender, listKols[i], lastReward);
            } else {
                _balances[listKols[i]] = _balances[listKols[i]].add(eachReward);
                emit Transfer(sender, listKols[i], eachReward);
            }
        }
    }

    function _dispatchDeveloperlReward(address sender, uint256 developerFee) private {
        if(developerFee == 0) return;

        _balances[developerAddress] = _balances[developerAddress].add(developerFee);
        emit Transfer(sender, developerAddress, developerFee);
    }

    function _takeBurn(address sender, uint256 burnFee) private {
        if (burnFee == 0) return;

        _totalSupply = _totalSupply.sub(burnFee);
        emit Transfer(sender, address(0), burnFee);

    }

    function doBurn(uint256 amount) public {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_balances[_msgSender()] >= amount, "no enough balance to burn");

        _totalSupply = _totalSupply.sub(amount);
        _balances[_msgSender()] = _balances[_msgSender()].sub(amount, "ERC20: doBurn amount exceeds balance");
        emit Transfer(_msgSender(), address(0), amount);
    }

}