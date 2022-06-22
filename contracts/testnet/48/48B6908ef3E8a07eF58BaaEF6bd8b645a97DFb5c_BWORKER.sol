/**
 *Submitted for verification at BscScan.com on 2022-06-22
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

interface IBWORKER {
    function currenEpoch() external view returns (uint256);
}

interface IBWORKER_NFT {
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
    bool _swapping = false;
    modifier swapping() {
        _swapping = true;
        _;
        _swapping = false;
    }
    uint256 constant MAX_UINT256 = ~uint256(0);

    mapping(address => bool) private _whiteList;

    mapping(address => uint256) private _unLockBalances;
    mapping(address => uint256) private _lockBalances;
    mapping(address => uint256) private _pinksaleClaimBalances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => mapping(uint256 => uint256)) public sell;
    mapping(address => mapping(uint256 => uint256)) public maxSellInEpoch;
    mapping(address => uint256) private claimTime;
    mapping(address => uint256) private autoClaimEpoch;
    mapping(uint256 => uint256) private _mintProfit;
    uint256 public maxSell = 10;
    uint256 public constant maxSellDenominator = 1000;
    uint8 private DECIMALS = 10;
    uint256 private _totalSupply = 10**6 * 10**DECIMALS;
    string private _name = "BWorker";
    string private _symbol = "BWP";
    bool public lockBuy = false;
    bool public buyToUnlockAccount = false;

    IPancakeSwapRouter private router;
    IPancakeSwapPair public pairContract;
    address public pair;

    IBWORKER_NFT nftContract;

    uint256 public _initTime;

    address public treasuryReceiver =
        0x6789f1D065Cdc321DE0EB4AD0e6950e152686789;
    address public insuranceReceiver =
        0x6789d7FC289771d5d094B5E64b6B90f145926789;
    address public buyBackReceiver = 0x678944e4d708Ad6393965e065c9f3Fa67B383456;

    //address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public BUSD = 0x3eDf6A6fc783e533d67908fB0eC0620F5852Abc9; //testnet

    IERC20 BUSDContract = IERC20(BUSD);

    address private mintHolderAddress =
        0x000000000000000000000000000000000000000A;

    address public presalePinkSaleAddress;
    uint256 public presaleRate;
    uint256 public lastMintEpoch = 0;

    uint256 public NFTPrice = 100 * 10**18;
    uint256 public LegendNFTPrice = 500 * 10**18;
    uint256 public busdForBuyBack = 0;
    uint256 public busdForAddLiquidity = 0;
    bool public _autoBuyBack = true;
    bool public _autoMintProfit = true;
    bool public _autoAddLiquidity = true;
    bool public lockMintLegendNFT = true;

    constructor() Ownable() {
        //0xD99D1c33F9fC3444f8101754aBC46c52416550D1 testnet router
        //0x10ED43C718714eb63d5aA57B78B54704E256024E bsc router
        router = IPancakeSwapRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        pair = IPancakeSwapFactory(router.factory()).createPair(
            BUSD,
            address(this)
        );
        pairContract = IPancakeSwapPair(pair);
        _allowances[address(this)][address(router)] = MAX_UINT256;
        _allowances[treasuryReceiver][address(router)] = MAX_UINT256;
        BUSDContract.approve(address(router), MAX_UINT256);

        _whiteList[address(this)] = true;
        _whiteList[treasuryReceiver] = true;
        _whiteList[insuranceReceiver] = true;
        _whiteList[buyBackReceiver] = true;

        _unLockBalances[treasuryReceiver] = _totalSupply;
        _initTime = block.timestamp;
    }

    function setLockMintLegendNFT(bool _flag) external onlyOwner {
        lockMintLegendNFT = _flag;
    }

    function mintNFT() external {
        _mintNFT(NFTPrice);
        nftContract.minNFT(msg.sender, 1);
    }

    function mintLegendNFT() external {
        require(!lockMintLegendNFT);
        _mintNFT(LegendNFTPrice);
        nftContract.minLegendNFT(msg.sender, 1);
    }

    function _mintNFT(uint256 price) internal {
        require(address(nftContract) != address(0));
        require(
            BUSDContract.allowance(msg.sender, address(this)) >= price &&
                BUSDContract.balanceOf(msg.sender) >= price
        );
        (, uint256 lqBUSDAmount) = tokenPrice();
        require(lqBUSDAmount > 0);

        BUSDContract.transferFrom(msg.sender, address(this), price);
        uint256 amount = price.div(4);
        busdForAddLiquidity = busdForAddLiquidity.add(amount);
        busdForBuyBack = busdForBuyBack.add(amount);
        BUSDContract.transfer(insuranceReceiver, amount);
        BUSDContract.transfer(
            treasuryReceiver,
            price.sub(amount).sub(amount).sub(amount)
        );
    }

    function _addLiquidity() internal swapping {
        uint256 amount = busdForAddLiquidity;
        uint256 amountToLiquify = amount.div(2);
        uint256 amountToSwap = amount.sub(amountToLiquify);
        address[] memory path = new address[](2);
        path[0] = BUSD;
        path[1] = address(this);
        uint256 tokenAmountBefore = balanceOf(address(this));
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 tokenAmountToSwap = balanceOf(address(this)).sub(
            tokenAmountBefore
        );
        router.addLiquidity(
            BUSD,
            address(this),
            amountToLiquify,
            tokenAmountToSwap,
            0,
            0,
            treasuryReceiver,
            block.timestamp
        );
        busdForAddLiquidity = 0;
    }

    function _buyBack() internal swapping {
        uint256 amount = busdForBuyBack;
        address[] memory path = new address[](2);
        path[0] = BUSD;
        path[1] = address(this);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            buyBackReceiver,
            block.timestamp
        );
        busdForBuyBack = 0;
    }

    function manualMintProfit() public {
        require(shouldMintProfit());
        mintProfit();
    }

    function mintProfit() internal {
        if (!shouldMintProfit()) {
            return;
        }
        uint256 _currentEpoch = currenEpoch();
        (uint256 lqTokenAmount, uint256 lqBUSDAmount) = tokenPrice();
        if (lqBUSDAmount.mul(lqTokenAmount) > 0) {
            for (
                uint256 epoch = lastMintEpoch.add(1);
                epoch < _currentEpoch;
                epoch++
            ) {
                uint256 BUSDAmount = nftContract.totalProfitAt(epoch);
                uint256 tokenAmount = BUSDAmount.mul(lqTokenAmount).div(
                    lqBUSDAmount
                );
                _mintProfit[epoch] = tokenAmount;
                _totalSupply = _totalSupply.add(tokenAmount);
                _lockBalances[mintHolderAddress] = _lockBalances[
                    mintHolderAddress
                ].add(tokenAmount);
            }
        }
        lastMintEpoch = _currentEpoch.sub(1);
    }

    function _nftRewardAmount(address account) internal view returns (uint256) {
        uint256 nftRewardAmount = 0;
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
                uint256 tokenAmount = _mintProfit[epoch].mul(profit).div(
                    totalProfit
                );
                nftRewardAmount = nftRewardAmount.add(tokenAmount);
            }
        }
        return nftRewardAmount;
    }

    function _autoClaimNftReward(address account) internal {
        if (address(nftContract) != address(0)) {
            uint256 nftRewardAmount = _nftRewardAmount(account);
            autoClaimEpoch[account] = lastMintEpoch;

            _lockBalances[account] = _lockBalances[account].add(
                nftRewardAmount
            );
            _lockBalances[mintHolderAddress] = _lockBalances[mintHolderAddress]
                .sub(nftRewardAmount);
        }
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
        uint256 _currentEpoch = currenEpoch();
        return
            _autoMintProfit &&
            address(nftContract) != address(0) &&
            _currentEpoch > lastMintEpoch.add(1);
    }

    function shouldBuyBack() internal view returns (bool) {
        return
            _autoBuyBack &&
            busdForBuyBack >= 25 * 10**18 &&
            !_swapping &&
            msg.sender != pair;
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
            _autoAddLiquidity &&
            busdForAddLiquidity >= 25 * 10**18 &&
            !_swapping &&
            msg.sender != pair;
    }

    function setAutoBuyBack(bool _flag) external onlyOwner {
        _autoBuyBack = _flag;
    }

    function setAutoMintProfit(bool _flag) external onlyOwner {
        _autoMintProfit = _flag;
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        _autoAddLiquidity = _flag;
    }

    function setPairContract(address _address) external onlyOwner {
        require(Address.isContract(_address), "contract only");
        pair = _address;
        pairContract = IPancakeSwapPair(pair);
    }

    function setNFTContract(address _address) external onlyOwner {
        require(
            Address.isContract(_address) && address(nftContract) == address(0),
            "contract only"
        );
        nftContract = IBWORKER_NFT(_address);
    }

    function setLockBuy(bool _lockBuy, bool _buyToUnlockAccount)
        external
        onlyOwner
    {
        lockBuy = _lockBuy;
        buyToUnlockAccount = _buyToUnlockAccount;
    }

    function setPresaleAddress(address _address) external onlyOwner {
        require(Address.isContract(_address), "Contract Only");
        require(presalePinkSaleAddress == address(0));
        presalePinkSaleAddress = _address;
    }

    function setPresaleRate(uint256 _rate) external onlyOwner {
        require(_rate != 0);
        presaleRate = _rate;
    }

    function currenEpoch() public view override returns (uint256) {
        //return (block.timestamp - _initTime).div(1 days).add(1);
        return (block.timestamp - _initTime).div(10 minutes).add(1);
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
        uint256 nftRewardAmount = _nftRewardAmount(account);
        if (
            _pinksaleClaimBalances[account] > 0 &&
            block.timestamp - claimTime[account] <= 6 seconds
        ) {
            //fix pinksale claim
            return
                _lockBalances[account]
                    .add(_unLockBalances[account])
                    .add(_pinksaleClaimBalances[account])
                    .add(nftRewardAmount);
        } else {
            return
                _lockBalances[account].add(_unLockBalances[account]).add(
                    nftRewardAmount
                );
        }
    }

    function lockBalanceOf(address account) public view returns (uint256) {
        return _lockBalances[account];
    }

    function unLockBalanceOf(address account) public view returns (uint256) {
        return _unLockBalances[account];
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

        mintProfit();
        _autoClaimNftReward(sender);
        _autoClaimNftReward(recipient);

        if (shouldAddLiquidity()) {
            _addLiquidity();
        } else if (shouldBuyBack()) {
            _buyBack();
        }

        //transfer
        uint256 senderBalance = _lockBalances[sender].add(
            _unLockBalances[sender]
        );
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        if (
            presalePinkSaleAddress != address(0) &&
            sender == presalePinkSaleAddress
        ) {
            if (recipient == pair) {
                //Pinksale presale addLQ
                _presaleAddLQ(sender, recipient, amount);
            } else {
                //claim from Pinksale presale
                _presaleClaim(sender, recipient, amount);
            }
        } else if (recipient == pair) {
            //sell
            _sell(sender, recipient, amount);
        } else if (sender == pair) {
            //buy
            _buy(sender, recipient, amount);
        } else {
            _basicTransfer(sender, recipient, amount);
        }
        emit Transfer(sender, recipient, amount);
    }

    function _presaleAddLQ(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        _unLockBalances[sender].sub(amount);
        _unLockBalances[recipient] = _unLockBalances[recipient].add(amount);
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
        require(presaleRate > 0);
        uint256 numOfNFT = amount.div(presaleRate);
        uint256 lockAmount = amount.sub(amount.mul(numOfNFT));

        autoConvertNFTAfterClaim(recipient, numOfNFT);

        //transfer
        _unLockBalances[sender] = _unLockBalances[sender].sub(amount);
        _lockBalances[recipient] = _lockBalances[recipient].add(lockAmount);

        //fix pinksale claim error
        uint256 pinksaleAmount = amount.sub(lockAmount);
        claimTime[recipient] = block.timestamp;
        _pinksaleClaimBalances[recipient] = _pinksaleClaimBalances[recipient]
            .add(pinksaleAmount);
        //end: fix pinksale claim error
    }

    function autoConvertNFTAfterClaim(address recipient, uint256 numOfNFT)
        internal
    {
        nftContract.minNFT(recipient, numOfNFT);
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        if (amount < _unLockBalances[sender]) {
            _unLockBalances[sender] = _unLockBalances[sender].sub(amount);
            _unLockBalances[recipient] = _unLockBalances[recipient].add(amount);
        } else {
            uint256 unLockAmount = _unLockBalances[sender];
            uint256 lockAmount = amount.sub(unLockAmount);

            _unLockBalances[sender] = 0;
            _unLockBalances[recipient] = _unLockBalances[recipient].add(
                unLockAmount
            );

            _lockBalances[sender] = _lockBalances[sender].sub(lockAmount);
            _lockBalances[recipient] = _lockBalances[recipient].add(lockAmount);
        }
    }

    function _sell(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        uint256 epoch = currenEpoch();
        require(
            amount <= _unLockBalances[sender],
            "Unlocked account does not have enough balance"
        );
        //max sell 0.5-100%
        if (!_whiteList[sender]) {
            uint256 currentMaxSell = _unLockBalances[sender].mul(maxSell).div(
                maxSellDenominator
            );
            maxSellInEpoch[sender][epoch] = currentMaxSell >
                maxSellInEpoch[sender][epoch]
                ? currentMaxSell
                : maxSellInEpoch[sender][epoch];
            require(
                sell[sender][epoch].add(amount) <=
                    maxSellInEpoch[sender][epoch],
                "maxSell"
            );
            sell[sender][epoch] = sell[sender][epoch].add(amount);
        }

        //transfer
        _unLockBalances[sender] = _unLockBalances[sender].sub(amount);
        _unLockBalances[recipient] = _unLockBalances[recipient].add(amount);
    }

    function _buy(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(!lockBuy || _whiteList[recipient], "Lock buy");
        _unLockBalances[sender] = _unLockBalances[sender].sub(amount);
        if (buyToUnlockAccount) {
            _unLockBalances[recipient] = _unLockBalances[recipient].add(amount);
        } else {
            _lockBalances[recipient] = _lockBalances[recipient].add(amount);
        }
    }

    function setMaxSell(uint256 _maxSell) external onlyOwner {
        require(maxSell <= 1000 && maxSell >= 5);
        maxSell = _maxSell;
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