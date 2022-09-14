/**
 *Submitted for verification at BscScan.com on 2022-09-14
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

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
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

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
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

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
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
}

interface IBWORKER_NFT is IERC721Metadata {
    function minNFT(address _owner, uint256 numOfNFT) external;

    function minLegendNFT(address _owner, uint256 numOfNFT) external;

    function profitAt(address account, uint256 snapshotId)
        external
        view
        returns (uint256);

    function totalProfitAt(uint256 snapshotId) external view returns (uint256);
}

contract BWORKER is Context, IERC20, IERC20Metadata, Ownable, IBWORKER {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    mapping(address => bool) private _gameValidator;
    modifier onlyValidator() {
        require(_gameValidator[msg.sender]);
        _;
    }
    uint256 constant MAX_UINT256 = ~uint256(0);

    mapping(address => bool) private _whiteList;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _gameBalances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private claimTime;
    mapping(address => uint256) private autoClaimEpoch;
    mapping(uint256 => uint256) private _mintProfit;
    mapping(address => uint256) private _nftPresale;

    uint8 private DECIMALS = 10;
    uint256 private _totalSupply = 10**6 * 10**DECIMALS;
    uint256 private _maxSupply = 11 * 10**9 * 10**DECIMALS;
    string private _name = "BWorker";
    string private _symbol = "BWP";
    bool public buyToUnlockAccount = false;

    IPancakeSwapRouter private router;
    IPancakeSwapPair public pairContract;
    address public pair;

    IBWORKER_NFT nftContract;

    uint256 public _initTime;
    address public treasuryReceiver =
        0x69D420467d2c026ba6f961B2e8F6700618c513e1;
    address public insuranceReceiver =
        0x225e1350920b736AD663D8bde66156B70701b0e3;
    address public buyBackReceiver = 0xD52C578617DCD45B44584655a05B0F0EA27fEAd2;

    address private mintHolderAddress =
        0x000000000000000000000000000000000000000A;
    address private gameHolderAddress =
        0x000000000000000000000000000000000000000b;

    address public presalePinkSaleAddress;
    uint256 public presaleNFTPrice;
    uint256 public lastMintEpoch = 0;

    uint256 minTokenSwapback = 100 * 10**DECIMALS;
    uint256 public NFTPrice = 100 * 10**18;
    uint256 public LegendNFTPrice = 500 * 10**18;
    uint256 public bnbForBuyBack = 0;
    uint256 public bnbForAddLiquidity = 0;
    uint256 public feeDenominator = 1000;
    uint256 public sellFee = 50;
    uint256 public buyFee = 20;
    uint256 tokenForSwapback = 0;

    bool public _autoMintProfit = true;
    bool public lockMintLegendNFT = true;
    bool public _autoBuyBack = true;
    bool public _autoAddLiquidity = true;
    bool public _autoSwapback = true;

    uint256 public NFTsCanBeSold = MAX_UINT256;
    uint256 public LegendNFTsCanBeSold = MAX_UINT256;

    event MintProfit(uint256 amount);
    event GameDeposit(address account, uint256 amount);
    event GameWithdraw(address account, uint256 amount);

    constructor() Ownable() {
        router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        pairContract = IPancakeSwapPair(pair);
        _allowances[address(this)][address(router)] = MAX_UINT256;
        _allowances[treasuryReceiver][address(router)] = MAX_UINT256;

        _whiteList[address(this)] = true;
        _whiteList[treasuryReceiver] = true;
        _whiteList[insuranceReceiver] = true;
        _whiteList[buyBackReceiver] = true;
        _whiteList[address(router)] = true;
        _gameValidator[0xdd349a4776735d243c066252948ba4278b040deB] = true;

        _balances[treasuryReceiver] = _totalSupply;
        _initTime = block.timestamp;
    }

    function setGameValidator(address acc, bool _flag) external onlyOwner {
        _gameValidator[acc] = _flag;
    }

    function setNFTPrice(uint256 nftPrice, uint256 legendPrice)
        external
        onlyOwner
    {
        require(nftPrice >= 50 * 10**18 && legendPrice > 250 * 10**18);
        NFTPrice = nftPrice;
        LegendNFTPrice = legendPrice;
    }

    function nftContractAddress() external view override returns (address) {
        return address(nftContract);
    }

    function setLockMintLegendNFT(bool _flag) external onlyOwner {
        lockMintLegendNFT = _flag;
    }

    function setNFTsCanBeSold(uint256 nums, uint256 legendNums)
        external
        onlyOwner
    {
        NFTsCanBeSold = nums;
        LegendNFTsCanBeSold = legendNums;
    }

    function mintNFT() external payable {
        require(
            msg.value >= NFTPrice,
            "The amount of BNB is not enough to mint NFT"
        );
        require(NFTsCanBeSold > 0, "Sold out");
        NFTsCanBeSold = NFTsCanBeSold.sub(1);
        _tokenDistribution(msg.value);
        nftContract.minNFT(msg.sender, 1);
    }

    function mintNFTByToken() external {
        require(NFTsCanBeSold > 0, "Sold out");
        NFTsCanBeSold = NFTsCanBeSold.sub(1);
        uint256 tokenAmountOut = getTokenAmountToMintNFT();
        minTokenSwapback = tokenAmountOut;

        if (
            _nftPresale[msg.sender] > 0 &&
            presaleNFTPrice > 0 &&
            presaleNFTPrice < tokenAmountOut
        ) {
            tokenAmountOut = presaleNFTPrice;
            _nftPresale[msg.sender] = _nftPresale[msg.sender].sub(1);
        }

        _basicTransfer(msg.sender, address(this), tokenAmountOut);
        tokenForSwapback = tokenForSwapback.add(tokenAmountOut);
        nftContract.minNFT(msg.sender, 1);
    }

    function mintLegendNFT() external payable {
        require(!lockMintLegendNFT, "Lock Legend NFT");
        require(
            msg.value >= LegendNFTPrice,
            "The amount of BNB is not enough to mint NFT"
        );
        require(LegendNFTsCanBeSold > 0, "Sold out");
        LegendNFTsCanBeSold = LegendNFTsCanBeSold.sub(1);
        _tokenDistribution(msg.value);
        nftContract.minLegendNFT(msg.sender, 1);
    }

    function getTokenAmountToMintNFT() public view returns (uint256) {
        (uint256 lqTokenAmount, uint256 lqBNBAmount) = tokenPrice();
        return router.getAmountOut(NFTPrice, lqBNBAmount, lqTokenAmount);
    }

    function getTokenAmountToMintLegendNFT() public view returns (uint256) {
        (uint256 lqTokenAmount, uint256 lqBNBAmount) = tokenPrice();
        return router.getAmountOut(LegendNFTPrice, lqBNBAmount, lqTokenAmount);
    }

    function mintLegendNFTByToken() external {
        require(!lockMintLegendNFT, "Lock Legend NFT");
        require(LegendNFTsCanBeSold > 0, "Sold out");
        LegendNFTsCanBeSold = LegendNFTsCanBeSold.sub(1);
        uint256 tokenAmountOut = getTokenAmountToMintLegendNFT();
        _basicTransfer(msg.sender, address(this), tokenAmountOut);
        tokenForSwapback = tokenForSwapback.add(tokenAmountOut);
        nftContract.minLegendNFT(msg.sender, 1);
    }

    function _tokenDistribution(uint256 amountETH) internal {
        require(address(nftContract) != address(0));
        uint256 amount = amountETH.div(4);
        if (address(this).balance >= amount) {
            (bool success, ) = payable(insuranceReceiver).call{
                value: amount,
                gas: 30000
            }("");
            (success, ) = payable(treasuryReceiver).call{
                value: amountETH.sub(amount).sub(amount).sub(amount),
                gas: 30000
            }("");
            bnbForBuyBack = bnbForBuyBack.add(amount);
            bnbForAddLiquidity = bnbForAddLiquidity.add(amount);
        }
    }

    //todo: fix addLQ, add From buyback
    function _addLiquidity() internal swapping {
        (uint256 lqTokenAmount, uint256 lqBNBAmount) = tokenPrice();
        if (
            lqBNBAmount == 0 ||
            lqTokenAmount == 0 ||
            bnbForAddLiquidity == 0 ||
            address(this).balance < bnbForAddLiquidity
        ) {
            return;
        }
        uint256 amountBNB = bnbForAddLiquidity;
        uint256 amountToken = amountBNB.mul(lqTokenAmount).div(lqBNBAmount);
        _totalSupply = _totalSupply.add(amountToken);
        _balances[address(this)] = _balances[address(this)].add(amountToken);

        if (BWORKER.allowance(address(this), address(router)) < amountToken) {
            BWORKER.approve(address(router), MAX_UINT256);
        }

        router.addLiquidityETH{value: amountBNB}(
            address(this),
            amountToken,
            0,
            0,
            treasuryReceiver,
            block.timestamp
        );
        bnbForAddLiquidity = 0;
    }

    //todo:check swapback
    function _swapBack() internal swapping {
        if (
            tokenForSwapback == 0 || balanceOf(address(this)) < tokenForSwapback
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
        if (lqBNBAmount.mul(lqTokenAmount) == 0 || bnbForBuyBack == 0) {
            return;
        }
        uint256 amount = bnbForBuyBack;
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, buyBackReceiver, block.timestamp);
        bnbForBuyBack = 0;
    }

    function manualMintProfit() public {
        uint256 _currentEpoch = currentEpoch();
        require(
            address(nftContract) != address(0) &&
                _currentEpoch > lastMintEpoch.add(1)
        );
        mintProfit();
    }

    function mintProfit() internal {
        uint256 _currentEpoch = currentEpoch();
        if (_totalSupply >= _maxSupply) {
            lastMintEpoch = _currentEpoch.sub(1);
            return;
        }
        (uint256 lqTokenAmount, uint256 lqBNBAmount) = tokenPrice();
        uint256 mintAmount = 0;
        if (lqBNBAmount.mul(lqTokenAmount) > 0) {
            for (
                uint256 epoch = lastMintEpoch.add(1);
                epoch < _currentEpoch;
                epoch++
            ) {
                uint256 BNBAmount = nftContract.totalProfitAt(epoch);
                uint256 tokenAmount;
                tokenAmount = BNBAmount.mul(lqTokenAmount).div(lqBNBAmount);
                _mintProfit[epoch] = tokenAmount;
                _totalSupply = _totalSupply.add(tokenAmount);
                mintAmount = mintAmount.add(tokenAmount);
                _gameBalances[mintHolderAddress] = _gameBalances[
                    mintHolderAddress
                ].add(tokenAmount);
            }
        }
        emit MintProfit(mintAmount);
    }

    function _autoClaimNftReward(address account) internal {
        if (address(nftContract) == address(0)) {
            return;
        }
        uint256 _nftRewardAmount = nftRewardAmount(account);
        autoClaimEpoch[account] = lastMintEpoch;
        _gameBalances[account] = _gameBalances[account].add(_nftRewardAmount);
        _gameBalances[mintHolderAddress] = _gameBalances[mintHolderAddress].sub(
            _nftRewardAmount
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
                uint256 profit = nftContract.profitAt(account, epoch);
                uint256 totalProfit = nftContract.totalProfitAt(epoch);
                if (profit.mul(totalProfit).mul(_mintProfit[epoch]) != 0) {
                    _nftRewardAmount = _nftRewardAmount.add(
                        _mintProfit[epoch].mul(profit).div(totalProfit)
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

    function shouldMintProfit() internal view returns (bool) {
        uint256 _currentEpoch = currentEpoch();
        return
            _autoMintProfit &&
            address(nftContract) != address(0) &&
            _currentEpoch > lastMintEpoch.add(1);
    }

    function shouldBuyBack() internal view returns (bool) {
        return
            _autoBuyBack &&
            bnbForBuyBack >= 5 * 10**17 &&
            !inSwap &&
            msg.sender != pair;
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
            _autoAddLiquidity &&
            bnbForAddLiquidity >= 5 * 10**17 &&
            !inSwap &&
            msg.sender != pair;
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            _autoSwapback &&
            tokenForSwapback >= minTokenSwapback &&
            !inSwap &&
            msg.sender != pair;
    }

    function setAuto(
        bool _flagAutoMintProfit,
        bool _flagAutoAddLiquidity,
        bool _flagAutoBuyBack,
        bool _flagAutoSwapBack
    ) external onlyOwner {
        _autoMintProfit = _flagAutoMintProfit;
        _autoAddLiquidity = _flagAutoAddLiquidity;
        _autoBuyBack = _flagAutoBuyBack;
        _autoSwapback = _flagAutoSwapBack;
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

    function setpresaleNFTPrice(uint256 _rate) external onlyOwner {
        require(_rate != 0);
        presaleNFTPrice = _rate;
    }

    function currentEpoch() public view override returns (uint256) {
        return (block.timestamp - _initTime).div(1 days).add(1);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return DECIMALS;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function gameBalanceOf(address account) public view returns (uint256) {
        uint256 _nftRewardAmount = nftRewardAmount(account);
        return _gameBalances[account].add(_nftRewardAmount);
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
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
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);

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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (shouldMintProfit()) {
            mintProfit();
        }
        if (shouldBuyBack()) {
            _buyBack();
        } else if (shouldSwapBack()) {
            _swapBack();
        } else if (shouldAddLiquidity()) {
            _addLiquidity();
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
            ? amount.mul(sellFee).div(feeDenominator)
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
            ? amount.mul(buyFee).div(feeDenominator)
            : 0;
        uint256 amount2 = amount.sub(fee);

        tokenForSwapback = tokenForSwapback.add(fee);
        _balances[address(this)] = _balances[address(this)].add(fee);

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount2);
    }

    function depositOffchainGame(uint256 amount) external {
        if (shouldMintProfit()) {
            mintProfit();
        }
        _autoClaimNftReward(msg.sender);
        require(_gameBalances[msg.sender].add(_balances[msg.sender]) >= amount);

        if (amount <= _gameBalances[msg.sender]) {
            _gameBalances[msg.sender] = _gameBalances[msg.sender].sub(amount);
        } else {
            _balances[msg.sender] = _balances[msg.sender].sub(
                amount.sub(_gameBalances[msg.sender])
            );
            _gameBalances[msg.sender] = 0;
        }

        _balances[gameHolderAddress] = _balances[gameHolderAddress].add(amount);
        emit GameDeposit(msg.sender, amount);
    }

    function widthdrawOffchainGame(address account, uint256 amount)
        external
        onlyValidator
    {
        _basicTransfer(gameHolderAddress, account, amount);
        emit GameWithdraw(account, amount);
    }

    function setWhiteList(address account, bool _flag) external onlyOwner {
        _whiteList[account] = _flag;
    }

    function _presaleClaim(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        //user claim not addLQ
        require(presaleNFTPrice > 0);
        require(
            _balances[sender] >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _nftPresale[recipient] = _nftPresale[recipient].add(
            amount.div(presaleNFTPrice)
        );
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

    function setFee(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 50 && _sellFee <= 50, "Fees are too big");
        buyFee = _buyFee;
        sellFee = _sellFee;
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

    receive() external payable {}
}