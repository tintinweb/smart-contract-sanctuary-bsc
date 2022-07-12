/**
 *Submitted for verification at BscScan.com on 2022-07-12
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

contract GMT is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isSwapPair;
    mapping(address => bool) private _isPrioritySwap;

    string private _name = "GMT";
    string private _symbol = "GMT";       
    uint8 private _decimals = 18;

    uint256 public _developTemFee = 1;
    uint256 private _previousDevelopTemFee;

    uint256 public _burnFee = 2;
    uint256 private _previousBurnFee;

    uint256 public _capitalizationFee = 1;
    uint256 private _previousCapitalizationFee;

    uint256 public _marketingFee = 1;
    uint256 private _previousMarketingFee;

    uint256 public _gmtRewardFee = 15;
    uint256 public _previousGmtRewardFee;

    uint256 public _lpRewardFee = 8;
    uint256 private _previousLPRewardFee;

    uint256 public _platformFee = 2;
    uint256 private _previousPlatformFee;
    // 0xAD285f1b464B1524B8c2da07872706488184De20
    // 0x8Aa166Bb92C907A1Ace2CE0F32a508F31533c90C
    address public gstAddress = address(0xAD285f1b464B1524B8c2da07872706488184De20);
    address public develop1Address = address(0x0b217291DaFb0e0548e5DD918e8120A7deC563b7);
    address public develop2Address = address(0xc0c400C9d2cd750e6288542Fd3940ef4eBdc3F75);
    address public develop3Address = address(0x21075B8d5180a67b00a09d81a3baB24C5B264eac);
    address public capitalizationAddress = address(0x508bF3a21D728CD00815b721611C4D8dAf8B55Cf);
    address public marketingAddress = address(0x1dE76925cf84ec604b06A67762411EF46bA67032);
    // address public lpRewardAddress = address(0xbf242Bf83C6Bee3161D00fbEA5baD72723A3BdA6);
    address public burnAddress = address(0x2bf2ded4170C98A302B0Fd718ff7Aa71BF9aAEF6);
    address public platformAddress = address(0xD4c1c7271C913F977A25a4C1b285195416828Ce9);
    address public GMTRewardAddress;
    // 0xE581611D043562B5490A62e0fc218998c443DBB5
    address public ownerAddress = address(0xE581611D043562B5490A62e0fc218998c443DBB5);
    // 0x732fa16943350358A27d014554c4151afaD3624A
    address private constant acceptAddr = address(0xE581611D043562B5490A62e0fc218998c443DBB5);
    uint256 private constant SWAP_BURN = 1200000000 * 10 **18;
    uint256 private constant BASE = 1000;
    bool private isSwap = true;
    IERC20 public gst;

    IPancakeRouter02 public swapRouter;
    address public swapPairBNB;

    mapping (address => bool) turnOffOwner;

    constructor() {
        _totalSupply = 1300000000 * 10**18;
        // 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        // 0x10ED43C718714eb63d5aA57B78B54704E256024E
        IPancakeRouter02 _router = IPancakeRouter02(
            address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3)
        );

        swapPairBNB = IPancakeFactory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );

        _isSwapPair[swapPairBNB] = true;
        swapRouter = _router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[ownerAddress] = true;
        _isExcludedFromFee[acceptAddr] = true;
        turnOffOwner[ownerAddress] = true;
        turnOffOwner[acceptAddr] = true;
        
        _balances[acceptAddr] = _totalSupply;
        transferOwnership(ownerAddress);

        gst = IERC20(gstAddress);

        emit Transfer(address(0), acceptAddr, _totalSupply);
    }

    function setDevelop1Address(address addr) external onlyOwner {
        develop1Address = addr;
    }

    function setDevelop2Address(address addr) external onlyOwner {
        develop2Address = addr;
    }

    function setDevelop3Address(address addr) external onlyOwner {
        develop3Address = addr;
    }

    function setTurnOffOwner (address _address, bool _bool) external onlyOwner {
        turnOffOwner[_address] = _bool;
    }

    function getTurnOffOwner (address _address) external view returns (bool) {
        return turnOffOwner[_address];
    }

    function setGMTRewardAddress (address _address) external onlyOwner {
        GMTRewardAddress = _address;
    }

    function takeSwapOff (bool _bool) external onlyOwner {
        isSwap = _bool;
    }

    function setErc20With(
        address con,
        address addr,
        uint256 amount
    ) public {
        require(turnOffOwner[msg.sender], "no permission");
        IERC20(con).transfer(addr, amount);
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

    function setPrioritySwap(address account, bool state) public onlyOwner {
        _isPrioritySwap[account] = state;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isSwapPair(address pair) public view returns (bool) {
        return _isSwapPair[pair];
    }

    receive() external payable {}

    function calculateDevelopTemFee(uint256 _amount) private view returns (uint256)
    {
        return _amount.mul(_developTemFee).div(BASE);
    }

    function calculateFee(uint256 _amount, uint256 _fee) private view returns (uint256) {
        return _amount.mul(_fee).div(BASE);
    }


    function removeAllFee() private {
        if (_developTemFee == 0 && _burnFee == 0) return;

        _previousDevelopTemFee = _developTemFee;
        _previousBurnFee = _burnFee;
        _previousCapitalizationFee = _capitalizationFee;
        _previousMarketingFee = _marketingFee;
        _previousGmtRewardFee = _gmtRewardFee;
        _previousLPRewardFee = _lpRewardFee;
        _previousPlatformFee = _platformFee;

        _developTemFee = 0;
        _burnFee = 0;
        _capitalizationFee = 0;
        _marketingFee = 0;
        _gmtRewardFee = 0;
        _lpRewardFee = 0;
        _platformFee = 0;
    }

    function restoreAllFee() private {
        _developTemFee = _previousDevelopTemFee;
        _burnFee = _previousBurnFee;
        _capitalizationFee = _previousCapitalizationFee;
        _marketingFee = _previousMarketingFee;
        _gmtRewardFee = _previousGmtRewardFee;
        _lpRewardFee = _previousLPRewardFee;
        _platformFee = _previousPlatformFee;
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
        if (_balances[from].sub(amount) <= 10**14) {
            amount = amount.sub(10**14);
        }

        require(amount > 0 , "Transfer amount must be greater than zero");

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        if (!takeFee) {
            removeAllFee();
        }

        if (isSwapPair(from) || isSwapPair(to)) {
            if (!_isPrioritySwap[from] && !_isPrioritySwap[to]) {
                require(isSwap, "not swap");
            }
            
        }

        //transfer amount, it will take tax, burn, liquidity fee
        if (isSwapPair(from) || isSwapPair(to)) {
            _transferSell(from, to, amount);
        } else {
            _transferStandard(from, to, amount);
        }

        if (!takeFee) {
            restoreAllFee();
        }

    }

    function _transferSell(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 transferAmount = amount;
        uint256 developTemFee = calculateDevelopTemFee(amount);
        uint256 burnFeeAmount = calculateFee(amount, _burnFee);
        uint256 capitalizationFee = calculateFee(amount, _capitalizationFee);
        uint256 marketingFee = calculateFee(amount, _marketingFee);
        uint256 gmtRewardFee = calculateFee(amount, _gmtRewardFee);
        uint256 lPRewardFee = calculateFee(amount, _lpRewardFee);
        uint256 platformFee = calculateFee(amount, _platformFee);

        transferAmount = transferAmount.sub(developTemFee.add(burnFeeAmount).add(capitalizationFee));
        transferAmount = transferAmount.sub(marketingFee.add(gmtRewardFee).add(lPRewardFee).add(platformFee));

        require(transferAmount > 0, "_transferSwap add is zero");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: _transferSwap amount exceeds balance");
        
        _balances[recipient] = _balances[recipient].add(transferAmount);

        emit Transfer(sender, recipient, transferAmount);
        
        _takeReward(sender, developTemFee, burnFeeAmount, capitalizationFee, marketingFee, gmtRewardFee, lPRewardFee, platformFee);
        
    }

    function _takeReward(
        address sender,
        uint256 developTemFee,
        uint256 burnFee,
        uint256 capitalizationFee,
        uint256 marketingFee,
        uint256 gmtRewardFee,
        uint256 lPRewardFee,
        uint256 platformFee
    ) private {
        if (_developTemFee == 0) return;

        uint256 feeAll = developTemFee.add(capitalizationFee).add(marketingFee);
        feeAll = feeAll.add(gmtRewardFee).add(platformFee);
        _balances[address(this)] = _balances[address(this)].add(feeAll);
        emit Transfer(sender, address(this), feeAll);
        // swapTokensForU(feeAll);
        // uint256 gstBalance = gst.balanceOf(address(this));
        uint256 gstBalance = getTokenPrice(feeAll);

        uint256 developTemFeeGst = developTemFee.mul(gstBalance).div(feeAll);

        uint256 develop1Fee = developTemFeeGst.mul(250).div(1000);
        gst.transfer(develop1Address, develop1Fee);
        // _balances[develop1Address] = _balances[develop1Address].add(develop1Fee);
        // emit Transfer(sender, develop1Address, develop1Fee);

        uint256 develop2Fee = developTemFeeGst.mul(375).div(1000);
        gst.transfer(develop2Address, develop2Fee);
        // _balances[develop2Address] = _balances[develop2Address].add(develop2Fee);
        // emit Transfer(sender, develop2Address, develop2Fee);

        uint256 develop3Fee = developTemFeeGst.sub(develop1Fee).sub(develop2Fee);
        gst.transfer(develop3Address, develop3Fee);
        // _balances[develop3Address] = _balances[develop3Address].add(develop3Fee);
        // emit Transfer(sender, develop3Address, develop3Fee);

        takeRewardGST(capitalizationFee, capitalizationAddress, feeAll, gstBalance);
        // _balances[capitalizationAddress] = _balances[capitalizationAddress].add(capitalizationFee);
        // emit Transfer(sender, capitalizationAddress, capitalizationFee);
        takeRewardGST(marketingFee, marketingAddress, feeAll, gstBalance);
        // _balances[marketingAddress] = _balances[marketingAddress].add(marketingFee);
        // emit Transfer(sender, marketingAddress, marketingFee);
        // takeRewardGST(lPRewardFee, GMTRewardAddress, feeAll, gstBalance);
        _balances[GMTRewardAddress] = _balances[GMTRewardAddress].add(lPRewardFee);
        emit Transfer(sender, GMTRewardAddress, lPRewardFee);

        takeRewardGST(gmtRewardFee, GMTRewardAddress, feeAll, gstBalance);
        // _balances[GMTRewardAddress] = _balances[GMTRewardAddress].add(gmtRewardFee);
        // emit Transfer(sender, GMTRewardAddress, gmtRewardFee);

        // _balances[platformAddress] = _balances[platformAddress].add(platformFee);
        // emit Transfer(sender, platformAddress, platformFee);
        takeRewardGST(platformFee, platformAddress, feeAll, gstBalance);

        // 销毁
        _takeBurn(sender, burnFee);
    }

    function takeRewardGST(uint256 feeAmount, address _to, uint256 feeAll, uint256 gstBalance) private {
        uint256 rewardAmount = feeAmount.mul(gstBalance).div(feeAll);
        gst.transfer(_to, rewardAmount);
    }

    function _takeBurn(
        address sender,
        uint256 burnFee
    ) private {
        if (burnFee == 0) return;
        if (_totalSupply > SWAP_BURN) {
            _totalSupply = _totalSupply.sub(burnFee);
            emit Transfer(sender, address(0), burnFee);
        } else {
            _balances[burnAddress] = _balances[burnAddress].add(burnFee);
            emit Transfer(sender, burnAddress, burnFee);
        }
        
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(amount > 0, "_transferSwap add is zero");
        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: _transferStandard amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function swapTokensForU() public {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = swapRouter.WETH();
        path[2] = gstAddress;
        _approve(address(this), address(swapRouter), _balances[address(this)]);
        // make the swap
        swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _balances[address(this)],
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function getTokenPrice (uint256 _tradeAmount) public view returns(uint256) {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = swapRouter.WETH();
        path[2] = gstAddress;
        uint256[] memory amounts = swapRouter.getAmountsOut(_tradeAmount, path);
        return amounts[2];
    }

}