/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
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
        require(b != 0);
        return a % b;
    }
}

library Arrays {
    function findDownerBound(uint256[] storage array, uint256 element)
        internal
        view
        returns (uint256)
    {
        if (array.length == 0) {
            return 0;
        }
        uint256 low = 0;
        uint256 high = array.length - 1;
        while (low <= high) {
            uint256 mid = (low + high) / 2;
            if (array[mid] == element) {
                return mid;
            } else if (array[mid] > element) {
                if (mid == 0) {
                    return 0;
                } else {
                    high = mid - 1;
                }
            } else {
                low = mid + 1;
            }
        }
        return low == 0 ? low : low - 1;
    }
}

interface IPancakeSwapPair {
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

interface IPancakeSwapRouter {
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

interface IPancakeSwapFactory {
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

contract Ownable {
    address private _owner;
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC20 {
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IBWORKER is IERC20Metadata {
    function nftContractAddress() external view returns (address);

    function currentEpoch() external view returns (uint256);

    function transferNFT(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

interface IBWORKER_NFT is IERC721Metadata {
    function autoIncrementTokenId() external view returns (uint256);

    function mintNFT(address to) external;
}

contract BWORKER is IERC20, IERC20Metadata, Ownable, IBWORKER {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using Arrays for uint256[];

    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }
    struct NFTData {
        uint8 class;
        uint256 timestamp;
        uint256 profit;
    }

    mapping(address => bool) private _gameValidator;
    modifier onlyValidator() {
        require(_gameValidator[msg.sender]);
        _;
    }
    modifier onlyNftContract() {
        require(msg.sender == address(nftContract));
        _;
    }
    uint256 constant MAX_UINT256 = ~uint256(0);

    mapping(address => bool) private _whiteList;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _gameBalances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private autoClaimEpoch;
    mapping(uint256 => uint256) private _mintProfit;
    mapping(address => uint256) private _nftPresale;
    mapping(address => uint256) public accountProfit;
    mapping(address => Snapshots) private _accountProfitSnapshots;
    mapping(uint256 => NFTData) private _nftData;

    Snapshots private totalProfitSnapshots;

    uint256 constant LEGEND_NFT_DIFFICULTY = 6;
    uint256 constant NFT_DIFFICULTY = 2;

    uint8 private constant DECIMALS = 10;
    uint256 private constant TOTAL_SUPPLY = 50**6 * 10**DECIMALS;
    address public constant TREASURY_RECEIVER =
        0x69D420467d2c026ba6f961B2e8F6700618c513e1;
    address public constant INSURANCE_RECEIVER =
        0x225e1350920b736AD663D8bde66156B70701b0e3;

    address private constant PROFIT_HOLDER = address(0xA);
    address private constant DEAD_ADDRESS = address(0x0);
    address private constant GAME_HOLDER = address(0xb);
    uint256 public constant FEE_DENOMINATOR = 1000;

    IPancakeSwapRouter private router;
    IPancakeSwapPair public pairContract;
    address public pair;

    IBWORKER_NFT nftContract;

    uint256 public initTime;
    uint256 public totalNFTProfit = 0;

    address public presalePinkSaleAddress;
    uint256 public presaleNFTPrice;
    uint256 public lastMintEpoch = 0;

    uint256 public NFTPrice = 100 * 10**18;
    uint256 public LegendNFTPrice = 500 * 10**18;

    uint256 public sellFee = 50;
    uint256 public buyFee = 20;

    bool public allowAutoMintProfit = true;
    bool public allowMintLegendNFT = false;
    bool public allowAutoBuyBack = true;
    bool public allowAutoAddLiquidity = true;
    bool public allowAutoSwapback = true;
    bool public allowMintNFTByToken = true;

    uint256 public NFTsCanBeSold = MAX_UINT256;
    uint256 public LegendNFTsCanBeSold = MAX_UINT256;

    uint256 minTokenToSwapback = 100 * 10**DECIMALS;
    uint256 bnbForBuyBack = 0;
    uint256 bnbForAddLiquidity = 0;
    uint256 treasuryBnb = 0;
    uint256 insuranceBnb = 0;
    uint256 tokenForSwapback = 0;

    event TokenProfit(uint256 amount);
    event GameDeposit(
        address account,
        uint256 gameAmount,
        uint256 unlockAmount
    );
    event GameWithdraw(
        address account,
        uint256 gameAmount,
        uint256 unlockAmount
    );
    event SetFee(uint256 buyFee, uint256 sellFee);
    event SetNFTPrice(uint256 nftPrice, uint256 legendNFTPrice);

    constructor() Ownable() {
        router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        pairContract = IPancakeSwapPair(pair);
        _allowances[address(this)][address(router)] = MAX_UINT256;

        _whiteList[address(this)] = true;
        _whiteList[TREASURY_RECEIVER] = true;
        _whiteList[INSURANCE_RECEIVER] = true;
        _whiteList[address(router)] = true;

        _gameValidator[0xdd349a4776735d243c066252948ba4278b040deB] = true;

        _balances[TREASURY_RECEIVER] = 10**6 * 10**DECIMALS;
        _balances[DEAD_ADDRESS] = TOTAL_SUPPLY.sub(
            _balances[TREASURY_RECEIVER]
        );
        initTime = block.timestamp;
        emit Transfer(
            address(0),
            TREASURY_RECEIVER,
            _balances[TREASURY_RECEIVER]
        );
        emit Transfer(address(0), DEAD_ADDRESS, _balances[DEAD_ADDRESS]);
    }

    function setGameValidator(address acc, bool _flag) external onlyOwner {
        _gameValidator[acc] = _flag;
    }

    function setNFTPrice(uint256 nftPrice, uint256 legendPrice)
        external
        onlyOwner
    {
        require(nftPrice >= 1 * 10**16 && legendPrice > 5 * 10**16);
        NFTPrice = nftPrice;
        LegendNFTPrice = legendPrice;
        emit SetNFTPrice(NFTPrice, LegendNFTPrice);
    }

    function nftContractAddress() external view override returns (address) {
        return address(nftContract);
    }

    function setNFTsCanBeSold(uint256 nums, uint256 legendNums)
        external
        onlyOwner
    {
        NFTsCanBeSold = nums;
        LegendNFTsCanBeSold = legendNums;
    }

    function mintNFT() external payable {
        require(NFTsCanBeSold > 0, "Sold out");
        NFTsCanBeSold = NFTsCanBeSold.sub(1);
        _mintNFTByBNB(NFTPrice, false);
    }

    function mintNFTByToken() external {
        require(NFTsCanBeSold > 0, "Sold out");
        NFTsCanBeSold = NFTsCanBeSold.sub(1);
        uint256 tokenAmountOut = getTokenAmountToMintNFT(false);
        minTokenToSwapback = tokenAmountOut;

        if (
            _nftPresale[msg.sender] > 0 &&
            presaleNFTPrice > 0 &&
            presaleNFTPrice < tokenAmountOut
        ) {
            tokenAmountOut = presaleNFTPrice;
            _nftPresale[msg.sender] = _nftPresale[msg.sender].sub(1);
        }
        _mintNFTByToken(tokenAmountOut, msg.sender, false);
    }

    function mintLegendNFT() external payable {
        require(allowMintLegendNFT, "Lock Legend NFT");
        require(LegendNFTsCanBeSold > 0, "Sold out");
        LegendNFTsCanBeSold = LegendNFTsCanBeSold.sub(1);
        _mintNFTByBNB(LegendNFTPrice, true);
    }

    function mintLegendNFTByToken() external {
        require(allowMintLegendNFT, "Lock Legend NFT");
        require(LegendNFTsCanBeSold > 0, "Sold out");
        LegendNFTsCanBeSold = LegendNFTsCanBeSold.sub(1);
        uint256 tokenAmountOut = getTokenAmountToMintNFT(true);
        _mintNFTByToken(tokenAmountOut, msg.sender, true);
    }

    function transferNFT(
        address from,
        address to,
        uint256 tokenId
    ) external override onlyNftContract {
        accountProfit[to] = accountProfit[to].add(_nftData[tokenId].profit);
        accountProfit[from] = accountProfit[from].sub(_nftData[tokenId].profit);
        _updateAccountSnapshot(to);
        _updateAccountSnapshot(from);
    }

    function setAuto(
        bool _flagAutoMintProfit,
        bool _flagAutoAddLiquidity,
        bool _flagAutoBuyBack,
        bool _flagAutoSwapBack,
        bool _flagAllowMintNFTByToken,
        bool _flagAllowMintLegendNFT
    ) external onlyOwner {
        allowAutoMintProfit = _flagAutoMintProfit;
        allowAutoAddLiquidity = _flagAutoAddLiquidity;
        allowAutoBuyBack = _flagAutoBuyBack;
        allowAutoSwapback = _flagAutoSwapBack;
        allowMintNFTByToken = _flagAllowMintNFTByToken;
        allowMintLegendNFT = _flagAllowMintLegendNFT;
    }

    function setPairContract(address _address) external onlyOwner {
        require(Address.isContract(_address), "contract only");
        pair = _address;
        pairContract = IPancakeSwapPair(pair);
    }

    function setNFTContract(address _address) external onlyOwner {
        require(Address.isContract(_address), "contract only");
        nftContract = IBWORKER_NFT(_address);
    }

    function setPresaleAddress(address _address) external onlyOwner {
        require(Address.isContract(_address), "Contract Only");
        presalePinkSaleAddress = _address;
    }

    function setPresaleNFTPrice(uint256 _price) external onlyOwner {
        require(_price != 0);
        presaleNFTPrice = _price;
    }

    function name() external view virtual override returns (string memory) {
        return "BWorker";
    }

    function symbol() external view virtual override returns (string memory) {
        return "BWP";
    }

    function decimals() external view virtual override returns (uint8) {
        return DECIMALS;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return TOTAL_SUPPLY;
    }

    function balanceOf(address account)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function gameBalanceOf(address account) external view returns (uint256) {
        uint256 _nftRewardAmount = nftRewardAmount(account);
        return _gameBalances[account].add(_nftRewardAmount);
    }

    function allowance(address owner, address spender)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        virtual
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
    ) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(msg.sender, spender, currentAllowance - subtractedValue);

        return true;
    }

    function depositOffchainGame(uint256 amount) external {
        if (shouldTokenProfit()) {
            tokenProfit();
        }
        _autoClaimNftReward(msg.sender);
        require(_gameBalances[msg.sender].add(_balances[msg.sender]) >= amount);
        uint256 gameAmount = 0;
        uint256 balanceAmount = 0;
        if (amount <= _gameBalances[msg.sender]) {
            _gameBalances[msg.sender] = _gameBalances[msg.sender].sub(amount);
            gameAmount = amount;
        } else {
            gameAmount = _gameBalances[msg.sender];
            balanceAmount = amount.sub(_gameBalances[msg.sender]);
            _balances[msg.sender] = _balances[msg.sender].sub(balanceAmount);
            _gameBalances[msg.sender] = 0;
        }

        _balances[GAME_HOLDER] = _balances[GAME_HOLDER].add(amount);
        emit GameDeposit(msg.sender, gameAmount, balanceAmount);
    }

    function widthdrawOffchainGame(
        address account,
        uint256 gameAmount,
        uint256 unlockAmount
    ) external onlyValidator {
        _balances[GAME_HOLDER] = _balances[GAME_HOLDER].sub(
            gameAmount.add(unlockAmount)
        );
        _balances[account] = _balances[account].add(unlockAmount);
        _gameBalances[account] = _gameBalances[account].add(gameAmount);
        emit GameWithdraw(account, gameAmount, unlockAmount);
    }

    function setWhiteList(address account, bool _flag) external onlyOwner {
        _whiteList[account] = _flag;
    }

    function setFee(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 50 && _sellFee <= 50, "Fees are too big");
        buyFee = _buyFee;
        sellFee = _sellFee;
        emit SetFee(buyFee, sellFee);
    }

    receive() external payable {}

    function getTokenAmountToMintNFT(bool isLegend)
        public
        view
        returns (uint256)
    {
        (uint256 lqTokenAmount, uint256 lqBNBAmount) = tokenPrice();
        return
            router.getAmountOut(
                !isLegend ? NFTPrice : LegendNFTPrice,
                lqBNBAmount,
                lqTokenAmount
            );
    }

    function nftRewardAmount(address account) public view returns (uint256) {
        uint256 _nftRewardAmount = 0;
        if (
            address(nftContract) != address(0) &&
            autoClaimEpoch[account] < lastMintEpoch
        ) {
            for (
                uint256 epoch = autoClaimEpoch[account].add(1);
                epoch <= lastMintEpoch;
                epoch++
            ) {
                uint256 profit = profitAt(account, epoch);
                uint256 _totalProfit = totalProfitAt(epoch);
                if (profit.mul(_totalProfit).mul(_mintProfit[epoch]) != 0) {
                    _nftRewardAmount = _nftRewardAmount.add(
                        _mintProfit[epoch].mul(profit).div(_totalProfit)
                    );
                }
            }
        }
        return _nftRewardAmount;
    }

    function tokenPrice() public view returns (uint256, uint256) {
        (uint256 a0, uint256 a1, ) = pairContract.getReserves();
        if (pairContract.token0() == address(this)) {
            return (a0, a1);
        } else {
            return (a1, a0);
        }
    }

    function currentEpoch() public view override returns (uint256) {
        return (block.timestamp - initTime).div(1 days).add(1);
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function profitAt(address account, uint256 snapshotId)
        public
        view
        returns (uint256)
    {
        return _valueAt(snapshotId, _accountProfitSnapshots[account]);
    }

    function totalProfitAt(uint256 snapshotId) public view returns (uint256) {
        return _valueAt(snapshotId, totalProfitSnapshots);
    }

    function _mintNFTByBNB(uint256 price, bool isLegend) internal {
        require(
            msg.value >= price,
            "The amount of BNB is not enough to mint NFT"
        );
        _tokenDistribution(msg.value);
        nftContract.mintNFT(msg.sender);
        uint256 tokenId = nftContract.autoIncrementTokenId();
        _calProfit(msg.sender, tokenId, isLegend);
    }

    function _mintNFTByToken(
        uint256 price,
        address to,
        bool isLegend
    ) internal {
        require(allowMintNFTByToken);
        _basicTransfer(to, address(this), price);
        tokenForSwapback = tokenForSwapback.add(price);
        nftContract.mintNFT(to);
        uint256 tokenId = nftContract.autoIncrementTokenId();
        _calProfit(to, tokenId, isLegend);
    }

    function _tokenDistribution(uint256 amountETH) internal {
        require(address(nftContract) != address(0));
        uint256 amount = amountETH.div(4);
        uint256 amount2 = amountETH.sub(amount.mul(3));
        if (address(this).balance >= amount) {
            bnbForBuyBack = bnbForBuyBack.add(amount);
            bnbForAddLiquidity = bnbForAddLiquidity.add(amount);
            (bool check1, ) = payable(INSURANCE_RECEIVER).call{
                value: amount + insuranceBnb,
                gas: 30000
            }("");
            (bool check2, ) = payable(TREASURY_RECEIVER).call{
                value: amount2 + treasuryBnb,
                gas: 30000
            }("");
            if (!check1) {
                insuranceBnb = amount + insuranceBnb;
            } else {
                insuranceBnb = 0;
            }
            if (!check2) {
                treasuryBnb = amount + treasuryBnb;
            } else {
                treasuryBnb = 0;
            }
        }
    }

    function _addLiquidity() internal swapping {
        (uint256 lqTokenAmount, uint256 lqBNBAmount) = tokenPrice();
        uint256 contractBalance = address(this).balance;
        if (
            lqBNBAmount == 0 ||
            lqTokenAmount == 0 ||
            bnbForAddLiquidity == 0 ||
            contractBalance == 0
        ) {
            return;
        }
        if (contractBalance < bnbForAddLiquidity) {
            bnbForAddLiquidity = contractBalance;
        }
        uint256 amountBNB = bnbForAddLiquidity;
        uint256 amountToken = amountBNB.mul(lqTokenAmount).div(lqBNBAmount);
        if (_balances[DEAD_ADDRESS] >= amountToken) {
            _balances[DEAD_ADDRESS] = _balances[DEAD_ADDRESS].sub(amountToken);
            _balances[address(this)] = _balances[address(this)].add(
                amountToken
            );

            router.addLiquidityETH{value: amountBNB}(
                address(this),
                amountToken,
                0,
                0,
                TREASURY_RECEIVER,
                block.timestamp
            );
        } else {
            bnbForBuyBack = bnbForBuyBack.add(bnbForAddLiquidity);
        }
        bnbForAddLiquidity = 0;
    }

    function _swapBack() internal swapping {
        if (
            tokenForSwapback == 0 || _balances[address(this)] < tokenForSwapback
        ) {
            return;
        }
        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenForSwapback,
            0,
            path,
            address(this),
            block.timestamp
        );
        tokenForSwapback = 0;
        uint256 amountETH = address(this).balance.sub(balanceBefore);
        _tokenDistribution(amountETH);
    }

    function _buyBack() internal swapping {
        (uint256 lqTokenAmount, uint256 lqBNBAmount) = tokenPrice();
        if (
            lqBNBAmount.mul(lqTokenAmount) == 0 ||
            bnbForBuyBack == 0 ||
            address(this).balance < bnbForBuyBack
        ) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: bnbForBuyBack
        }(0, path, DEAD_ADDRESS, block.timestamp);
        bnbForBuyBack = 0;
    }

    function tokenProfit() internal {
        uint256 _currentEpoch = currentEpoch();
        lastMintEpoch = _currentEpoch.sub(1);
        (uint256 lqTokenAmount, uint256 lqBNBAmount) = tokenPrice();
        uint256 mintAmount = 0;
        if (lqBNBAmount.mul(lqTokenAmount) > 0) {
            for (
                uint256 epoch = lastMintEpoch.add(1);
                epoch < _currentEpoch;
                epoch++
            ) {
                uint256 BNBAmount = totalProfitAt(epoch);
                uint256 tokenAmount;
                tokenAmount = BNBAmount.mul(lqTokenAmount).div(lqBNBAmount);
                _mintProfit[epoch] = tokenAmount;
                if (mintAmount.add(tokenAmount) <= _balances[DEAD_ADDRESS]) {
                    mintAmount = mintAmount.add(tokenAmount);
                } else {
                    break;
                }
            }

            if (mintAmount > 0) {
                _balances[DEAD_ADDRESS] = _balances[DEAD_ADDRESS].sub(
                    mintAmount
                );
                _gameBalances[PROFIT_HOLDER] = _gameBalances[PROFIT_HOLDER].add(
                    mintAmount
                );
                emit TokenProfit(mintAmount);
            }
        }
    }

    function _autoClaimNftReward(address account) internal {
        if (address(nftContract) == address(0)) {
            return;
        }
        uint256 _nftRewardAmount = nftRewardAmount(account);
        autoClaimEpoch[account] = lastMintEpoch;
        _gameBalances[account] = _gameBalances[account].add(_nftRewardAmount);
        _gameBalances[PROFIT_HOLDER] = _gameBalances[PROFIT_HOLDER].sub(
            _nftRewardAmount
        );
    }

    function shouldTokenProfit() internal view returns (bool) {
        uint256 _currentEpoch = currentEpoch();
        return
            allowAutoMintProfit &&
            address(nftContract) != address(0) &&
            _currentEpoch > lastMintEpoch.add(1);
    }

    function shouldBuyBack() internal view returns (bool) {
        return
            allowAutoBuyBack &&
            bnbForBuyBack >= 5 * 10**17 &&
            !inSwap &&
            msg.sender != pair;
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
            allowAutoAddLiquidity &&
            bnbForAddLiquidity >= 5 * 10**17 &&
            !inSwap &&
            msg.sender != pair;
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            allowAutoSwapback &&
            tokenForSwapback >= minTokenToSwapback &&
            !inSwap &&
            msg.sender != pair;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (shouldTokenProfit()) {
            tokenProfit();
        }
        if (shouldBuyBack()) {
            _buyBack();
        } else if (shouldAddLiquidity()) {
            _addLiquidity();
        } else if (shouldSwapBack()) {
            _swapBack();
        }
        if (
            presalePinkSaleAddress != address(0) &&
            sender == presalePinkSaleAddress
        ) {
            if (recipient == pair) {
                //Pinksale presale addLQ
                _basicTransfer(sender, recipient, amount);
            } else {
                //claim from Pinksale presale
                _presaleClaim(sender, recipient, amount);
            }
        } else if (recipient == pair) {
            _sell(sender, recipient, amount);
        } else if (sender == pair) {
            _buy(sender, recipient, amount);
        } else {
            _basicTransfer(sender, recipient, amount);
        }
        emit Transfer(sender, recipient, amount);
    }

    function _sell(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(
            _balances[sender] >= amount,
            "ERC20: transfer amount exceeds unlock balance"
        );
        uint256 fee = !_whiteList[sender]
            ? amount.mul(sellFee).div(FEE_DENOMINATOR)
            : 0;
        uint256 amount2 = amount.sub(fee);

        tokenForSwapback = tokenForSwapback.add(fee);
        _balances[address(this)] = _balances[address(this)].add(fee);

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount2);
    }

    function _buy(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(
            _balances[sender] >= amount,
            "ERC20: transfer amount exceeds unlock balance"
        );

        uint256 fee = !_whiteList[recipient]
            ? amount.mul(buyFee).div(FEE_DENOMINATOR)
            : 0;
        uint256 amount2 = amount.sub(fee);

        tokenForSwapback = tokenForSwapback.add(fee);
        _balances[address(this)] = _balances[address(this)].add(fee);

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount2);
    }

    function _presaleClaim(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        if (presaleNFTPrice > 0) {
            require(
                _balances[sender] >= amount,
                "ERC20: transfer amount exceeds balance"
            );
            _nftPresale[recipient] = _nftPresale[recipient].add(
                amount.div(presaleNFTPrice)
            );
        }

        _basicTransfer(sender, recipient, amount);
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(
            _balances[sender] >= amount,
            "ERC20: transfer amount exceeds unlock balance"
        );
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _calProfit(
        address to,
        uint256 tokenId,
        bool isLegend
    ) internal {
        uint256 ran = _randomNumber(1000, to, tokenId);
        uint8 _class = 0;
        uint256 price = NFTPrice;
        uint256 minProfit = 30;
        uint256 rangeProfit = 20;
        uint256 fromNumber = 0;
        uint256 toNumber = 1000;
        if (isLegend) {
            _class = 4;
            price = LegendNFTPrice;
            rangeProfit = 40;
            minProfit = 160;
        } else {
            if (ran >= 950) {
                _class = 3;
                minProfit = 110;
                rangeProfit = 40;
                fromNumber = 950;
                toNumber = 50;
            } else if (ran >= 800) {
                _class = 2;
                minProfit = 70;
                rangeProfit = 30;
                fromNumber = 800;
                toNumber = 150;
            } else if (ran >= 600) {
                _class = 1;
                minProfit = 50;
                fromNumber = 600;
                toNumber = 200;
            }
        }
        uint256 nftProfit = _calNFTProfit(
            ran.sub(fromNumber).mul(1000).div(toNumber),
            _class == 4 ? LEGEND_NFT_DIFFICULTY : NFT_DIFFICULTY,
            rangeProfit,
            minProfit,
            price
        );
        _nftData[tokenId].class = _class;
        _nftData[tokenId].timestamp = block.timestamp;

        _nftData[tokenId].profit = nftProfit;
        totalNFTProfit = totalNFTProfit.add(nftProfit);
        accountProfit[to] = accountProfit[to].add(nftProfit);
        _updateAccountSnapshot(to);
        _updateTotalProfitSnapshot();
    }

    function _calNFTProfit(
        uint256 ranNumber,
        uint256 difficulty,
        uint256 range,
        uint256 min,
        uint256 nftPrice
    ) internal pure returns (uint256) {
        return
            (
                (ranNumber**difficulty).mul(range).mul(nftPrice).div(
                    1000**(difficulty.add(1))
                )
            ).add(nftPrice.mul(min).div(1000));
    }

    function _randomNumber(
        uint256 maxNumber,
        address _address,
        uint256 tokenId
    ) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        _address,
                        tokenId
                    )
                )
            ) % maxNumber;
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
        private
        view
        returns (uint256)
    {
        uint256 currentId = currentEpoch();
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(snapshotId <= currentId, "ERC20Snapshot: nonexistent id");
        uint256 index = snapshots.ids.findDownerBound(snapshotId);
        if (index == 0 && snapshots.ids.length == 0) {
            return 0;
        } else {
            return snapshots.values[index];
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(
            _accountProfitSnapshots[account],
            accountProfit[account]
        );
    }

    function _updateTotalProfitSnapshot() private {
        _updateSnapshot(totalProfitSnapshots, totalNFTProfit);
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue)
        private
    {
        uint256 currentId = currentEpoch();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        } else {
            snapshots.values[snapshots.values.length - 1] = currentValue;
        }
    }

    function _lastSnapshotId(uint256[] storage ids)
        private
        view
        returns (uint256)
    {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}