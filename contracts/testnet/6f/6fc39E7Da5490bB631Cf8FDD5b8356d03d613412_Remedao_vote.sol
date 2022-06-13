/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

// SPDX-License-Identifier: Unlicensed
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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract IERC20Metadata is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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
}

interface IRemedao is IERC20 {
    function TOTAL_GONS() external view returns (uint256);

    function currentMemeEpoch() external view returns (uint256);

    function gonOf(address who) external view returns (uint256);

    function gonOfAt(address account, uint256 epoch)
        external
        view
        returns (uint256);

    function gonsPerFragment() external view returns (uint256);
}

interface IRemedaoVote {
    function lockVote(uint256 epoch, address who) external view returns (bool);

    function highestVote(uint256 epoch) external view returns (address);

    function getVote(address _address, uint256 epoch)
        external
        view
        returns (
            address,
            uint256,
            address,
            uint8
        );
}

contract Remedao_vote is Ownable, IRemedaoVote {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    IRemedao rmdContract;
    struct VoteToken {
        address token;
        uint256 vote;
        address makeBy;
        uint8 lqType;
    }
    uint256 public minMakeVote = 100;
    uint256 public constant minMakeVoteDenominator = 100_000;

    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    mapping(uint256 => mapping(address => VoteToken)) public voteData;
    mapping(uint256 => address) public override highestVote;
    mapping(uint256 => mapping(address => bool)) public override lockVote;

    mapping(uint256 => bool) public isBoughtTokens;

    mapping(uint256 => uint256) public memeTokenAmount;
    mapping(uint256 => address) public memeTokenAddress;
    mapping(address => uint256) public memeTokenClaim;
    mapping(address => mapping(uint256 => bool)) public userMemeTokenClaim;
    uint256 public lastVotingEpoch = 0;
    uint256 public minLQBNB = 150 * 10**18;
    uint256 public minLQUSD = 5 * 10**4 * 10**18;

    IPancakeSwapRouter public router;

    event MakeVote(
        address indexed tokenAddress,
        address indexed by,
        uint8 indexed lqType,
        uint256 epoch
    );
    event Vote(
        address indexed tokenAddress,
        address indexed wallet,
        uint256 epoch,
        uint256 amount,
        uint256 totalVote
    );

    event BuyMeme(
        uint256 indexed epoch,
        address indexed tokenAddress,
        uint256 amount
    );

    event ClaimMemeToken(
        address indexed who,
        uint256 indexed from,
        uint256 indexed to
    );
    event ClaimAToken(
        address indexed who,
        address indexed token,
        uint256 indexed epoch
    );

    constructor() Ownable() {
        //todo: change router
        //0xD99D1c33F9fC3444f8101754aBC46c52416550D1 testnet router
        //0x10ED43C718714eb63d5aA57B78B54704E256024E bsc router
        router = IPancakeSwapRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    }

    function setRMDContract(address _address) external onlyOwner {
        require(isContract(_address));
        rmdContract = IRemedao(_address);
    }

    function findLQ(address _erc20TokenAddress, address _bigToken)
        public
        view
        returns (uint256)
    {
        IPancakeSwapPair pairLQ = IPancakeSwapPair(
            IPancakeSwapFactory(router.factory()).getPair(
                _bigToken,
                address(_erc20TokenAddress)
            )
        );
        (uint256 a0, uint256 a1, ) = pairLQ.getReserves();
        return pairLQ.token0() == _bigToken ? a0 : a1;
    }

    function setMinMakeVote(uint256 _minMakeVote) external onlyOwner {
        require(_minMakeVote <= 10000);
        minMakeVote = _minMakeVote;
    }

    function makeVote(address _erc20TokenAddress) external {
        uint256 epoch = rmdContract.currentMemeEpoch();
        require(isContract(_erc20TokenAddress), "contract only");
        require(
            !lockVote[epoch][msg.sender] &&
                rmdContract.gonOf(msg.sender) >=
                rmdContract.TOTAL_GONS().div(minMakeVoteDenominator).mul(
                    minMakeVote
                )
        );

        if (lastVotingEpoch < epoch) {
            buyToken(lastVotingEpoch);
        }

        lastVotingEpoch = epoch;
        uint8 pairType = 0;
        uint256 lqAmount = findLQ(_erc20TokenAddress, router.WETH());
        uint256 minAmount = minLQBNB;
        if (lqAmount == 0) {
            minAmount = minLQUSD;
            lqAmount = findLQ(
                _erc20TokenAddress,
                0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
            );
            pairType = 1;
            if (lqAmount == 0) {
                lqAmount = findLQ(
                    _erc20TokenAddress,
                    0x55d398326f99059fF775485246999027B3197955
                );
                pairType = 2;
            }
        }
        require(lqAmount >= minAmount, "LQ too low");
        voteData[epoch][_erc20TokenAddress] = VoteToken(
            _erc20TokenAddress,
            rmdContract.gonOf(msg.sender),
            msg.sender,
            pairType
        );
        lockVote[epoch][msg.sender] = true;
        if (
            voteData[epoch][highestVote[epoch]].vote <
            voteData[epoch][_erc20TokenAddress].vote
        ) {
            highestVote[epoch] = _erc20TokenAddress;
        }
        emit MakeVote(_erc20TokenAddress, msg.sender, pairType, epoch);
        emit Vote(
            _erc20TokenAddress,
            msg.sender,
            epoch,
            rmdContract.gonOf(msg.sender),
            rmdContract.gonOf(msg.sender)
        );
    }

    function setMinLQ(uint256 _minInBNB, uint256 _minInUSD) external onlyOwner {
        minLQBNB = _minInBNB;
        minLQUSD = _minInUSD;
    }

    function buyToken(uint256 epoch) internal {
        if (
            epoch > 0 &&
            epoch < rmdContract.currentMemeEpoch() &&
            !isBoughtTokens[epoch]
        ) {
            buyMeme(epoch);
        }
    }

    function buyTokenManual(uint256 epoch) external onlyOwner {
        buyMeme(epoch);
    }

    function buyMeme(uint256 epoch) internal {
        require(
            epoch > 0 &&
                epoch < rmdContract.currentMemeEpoch() &&
                !isBoughtTokens[epoch]
        );
        address _tokenAddress = highestVote[epoch];
        isBoughtTokens[epoch] = true;
        memeTokenAddress[epoch] = _tokenAddress;
        uint256 tokenAmount;
        if (_tokenAddress == address(0)) {
            tokenAmount = 0;
        } else {
            (, , , uint8 lqType) = getVote(_tokenAddress, epoch);
            tokenAmount = _buyMeme(_tokenAddress, lqType);
        }
        memeTokenAmount[epoch] = tokenAmount;
        emit BuyMeme(epoch, _tokenAddress, tokenAmount);
    }

    /*todo: remove function, test remove after */
    function testBuy(address _tokenAddress, uint8 lqType) external onlyOwner {
        _buyMeme(_tokenAddress, lqType);
    }

    /*todo: remove function, test remove after */
    function claimToken(address _tokenAddress) external onlyOwner {
        IERC20 tokenContract = IERC20(_tokenAddress);
        require(tokenContract.balanceOf(address(this)) > 0);
        tokenContract.transfer(
            msg.sender,
            tokenContract.balanceOf(address(this))
        );
    }

    /*todo: remove function, test remove after */
    function claimBNB() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function _buyMeme(address _tokenAddress, uint8 lqType)
        internal
        returns (uint256)
    {
        address[] memory path;
        uint256 amount = address(this).balance;
        IERC20 tokenContract = IERC20(_tokenAddress);
        if (lqType == 0) {
            path = new address[](2);
            path[0] = router.WETH();
            path[1] = _tokenAddress;
        } else if (lqType == 1) {
            path = new address[](3);
            path[0] = router.WETH();
            path[1] = BUSD;
            path[2] = _tokenAddress;
        } else {
            path = new address[](3);
            path[0] = router.WETH();
            path[1] = USDT;
            path[2] = _tokenAddress;
        }
        if (amount == 0) {
            return 0;
        }
        uint256 balanceBefore = tokenContract.balanceOf(address(this));
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, address(this), block.timestamp);

        uint256 tokenAmount = tokenContract.balanceOf(address(this)).sub(
            balanceBefore
        );
        return tokenAmount;
    }

    function vote(address _erc20TokenAddress) external {
        uint256 epoch = rmdContract.currentMemeEpoch();
        require(
            voteData[epoch][_erc20TokenAddress].token != address(0) &&
                !lockVote[epoch][msg.sender]
        );
        lockVote[epoch][msg.sender] = true;
        voteData[epoch][_erc20TokenAddress].vote = voteData[epoch][
            _erc20TokenAddress
        ].vote.add(rmdContract.gonOf(msg.sender));

        if (
            voteData[epoch][highestVote[epoch]].vote <
            voteData[epoch][_erc20TokenAddress].vote
        ) {
            highestVote[epoch] = _erc20TokenAddress;
        }

        emit Vote(
            _erc20TokenAddress,
            msg.sender,
            epoch,
            rmdContract.gonOf(msg.sender),
            voteData[epoch][_erc20TokenAddress].vote
        );
    }

    function getVote(address _address, uint256 epoch)
        public
        view
        override
        returns (
            address,
            uint256,
            address,
            uint8
        )
    {
        return (
            voteData[epoch][_address].token,
            voteData[epoch][_address].vote,
            voteData[epoch][_address].makeBy,
            voteData[epoch][_address].lqType
        );
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function claimTokenAt(uint256 epoch) external {
        uint256 currentEpoch = rmdContract.currentMemeEpoch();
        require(
            epoch < currentEpoch &&
                !userMemeTokenClaim[msg.sender][epoch] &&
                memeTokenAddress[epoch] != address(0) &&
                isBoughtTokens[epoch]
        );

        uint256 epochAmount = memeTokenAmount[epoch];
        IERC20 token = IERC20(memeTokenAddress[epoch]);
        uint256 gonAtEpoch = rmdContract.gonOfAt(msg.sender, epoch);
        uint256 amountToken = epochAmount.mul(gonAtEpoch).div(
            rmdContract.TOTAL_GONS()
        );
        if (amountToken > 0) {
            token.transfer(msg.sender, amountToken);
        }
        userMemeTokenClaim[msg.sender][epoch] = true;
        emit ClaimAToken(msg.sender, memeTokenAddress[epoch], epoch);
    }

    function memeBalanceOf(address who, uint256 epoch)
        external
        view
        returns (address, uint256)
    {
        uint256 currentEpoch = rmdContract.currentMemeEpoch();
        require(epoch < currentEpoch && isBoughtTokens[epoch]);
        uint256 epochAmount = memeTokenAmount[epoch];
        if (epoch <= memeTokenClaim[who] || epochAmount == 0) {
            return (memeTokenAddress[epoch], 0);
        }

        uint256 gonAtEpoch = rmdContract.gonOfAt(who, epoch);
        uint256 amountToken = epochAmount.mul(gonAtEpoch).div(
            rmdContract.TOTAL_GONS()
        );
        return (memeTokenAddress[epoch], amountToken);
    }

    function claimToken() external {
        uint256 currentEpoch = rmdContract.currentMemeEpoch();
        uint256 from = memeTokenClaim[msg.sender] + 1;
        uint256 to = currentEpoch - from <= 30 ? currentEpoch : from + 30;
        require(to > from);
        for (uint256 i = from; i <= to; i++) {
            if (
                userMemeTokenClaim[msg.sender][i] ||
                memeTokenAddress[i] == address(0) ||
                !isBoughtTokens[i]
            ) {
                continue;
            }
            uint256 total = memeTokenAmount[i];
            IERC20 token = IERC20(memeTokenAddress[i]);
            uint256 gonAtEpoch = rmdContract.gonOfAt(msg.sender, i);
            uint256 amountToken = total.div(rmdContract.TOTAL_GONS()).mul(
                gonAtEpoch
            );
            if (amountToken > 0) {
                token.transfer(msg.sender, amountToken);
            }
            userMemeTokenClaim[msg.sender][i] = true;
        }
        memeTokenClaim[msg.sender] = to;
        emit ClaimMemeToken(msg.sender, from, to);
    }

    receive() external payable {}
}