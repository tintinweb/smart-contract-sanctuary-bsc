pragma solidity =0.8.0;

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }
    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    function safeTransferBNB(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed to);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Ownable: Caller is not the owner");
        _;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transferOwnership(address transferOwner) external onlyOwner {
        require(transferOwner != newOwner);
        newOwner = transferOwner;
    }

    function acceptOwnership() virtual external {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

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

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

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

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IBEP165 {
function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IBEP165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IBEP165).interfaceId;
    }
}

interface IBEP721 is IBEP165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

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
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface IBEP721Metadata is IBEP721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IBEP20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IRouter {
    function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function addLiquidityBNB(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountBNB, uint liquidity);
    function removeLiquidityBNB(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountBNB);
    function getAmountsOut(
        uint amountIn, 
        address[] memory path
    ) external view returns (uint[] memory amounts);
    function NBU_WBNB() external view returns(address);
}

interface ILpStaking {
    function stakeNonces (address) external view returns (uint256);
    function stake(uint256 amount) external;
    function stakeFor(uint256 amount, address user) external;
    function getCurrentLPPrice() external view returns (uint);
    function getReward() external;
    function withdraw(uint256 nonce) external;
    function rewardDuration() external returns (uint256);
    function stakingLPToken() external view returns (address);
}

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function approve(address spender, uint value) external returns (bool);
}

interface ILending {
    function mintWithBnb(address receiver) external payable returns (uint256 mintAmount);
    function tokenPrice() external view returns (uint256);
    function burnToBnb(address receiver, uint256 burnAmount) external returns (uint256 loanAmountPaid);
}

interface IPriceFeed {
    function queryRate(address sourceTokenAddress, address destTokenAddress) external view returns (uint256 rate, uint256 precision);
    function wbnbToken() external view returns(address);
}

interface INimbusPair is IBEP20 {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract SmartLP_APStorage is Ownable, Context, ERC165, ReentrancyGuard {    
    IWBNB public WBNB;
    IRouter public swapRouter;
    ILpStaking public lpStakingBnbNbu;
    ILpStaking public lpStakingBnbGnbu;
    ILending public lendingContract;
    IBEP20 public nbuToken;
    IBEP20 public gnbuToken;

    uint public tokenCount;
    uint public minPurchaseAmount;
    uint256 public rewardDuration;
    
    
    struct UserSupply { 
    uint ProvidedBnb;
    uint NbuBnbLpAmount;
    uint GnbuBnbLpAmount;
    uint LendedBNBAmount;
    uint PoolNbuAmount;
    uint PoolGnbuAmount;
    uint LendedITokenAmount;
    uint NbuBnbStakeNonce;
    uint GnbuBnbStakeNonce;
    uint SupplyTime;
    uint TokenId;
    bool IsActive;
    }
    
    mapping(uint => uint[]) internal _userRewards;
    mapping(uint => uint256) internal _balancesRewardEquivalentBnbNbu;
    mapping(uint => uint256) internal _balancesRewardEquivalentBnbGnbu;
    mapping(uint => UserSupply) public tikSupplies;
    mapping(uint => uint256) public weightedStakeDate;

    string internal _name;
    string internal _symbol;
    mapping(uint256 => address) internal _owners;
    mapping(address => uint256) internal _balances;
    mapping(uint256 => address) internal _tokenApprovals;
    mapping(address => mapping(address => bool)) internal _operatorApprovals;
    mapping(address => uint[]) internal _userTokens;
    
    event BuySmartLP(address indexed user, uint indexed tokenId, uint providedBnb, uint supplyTime);
    event WithdrawRewards(address indexed user, uint indexed tokenId, address indexed paymentToken, uint totalNbuReward);
    event BalanceRewardsNotEnough(address indexed user, uint indexed tokenId, uint totalNbuReward);
    event BurnSmartLP(uint indexed tokenId);
    event UpdateSwapRouter(address indexed newSwapRouterContract);
    event UpdateLpStakingBnbNbu(address indexed newLpStakingAContract);
    event UpdateLpStakingBnbGnbu(address indexed newLpStakingBContract);
    event UpdateLendingContract(address indexed newLending);
    event UpdateTokenNbu(address indexed newToken);
    event UpdateTokenGnbu(address indexed newToken);
    event UpdateMinPurchaseAmount(uint indexed newAmount);
    event Rescue(address indexed to, uint amount);
    event RescueToken(address indexed to, address indexed token, uint amount);
    event UpdateLpStakingBnbGnimb(address indexed newLpStakingContract);
    event UpdateUsePriceFeeds(bool indexed isUsePriceFeeds);
    event UpdateLpStakingBnbNimb(address indexed newLpStakingAContract);
}

contract SmartLP_APProxy is SmartLP_APStorage {
    address public target;
    
    event SetTarget(address indexed newTarget);

    constructor(address _newTarget) SmartLP_APStorage() {
        _setTarget(_newTarget);
    }

    fallback() external payable {
        if (gasleft() <= 2300) {
            revert();
        }

        address target_ = target;
        bytes memory data = msg.data;
        assembly {
            let result := delegatecall(gas(), target_, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize()
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    function setTarget(address _newTarget) external onlyOwner {
        _setTarget(_newTarget);
    }

    function _setTarget(address _newTarget) internal {
        require(Address.isContract(_newTarget), "Target not a contract");
        target = _newTarget;
        emit SetTarget(_newTarget);
    }
}

contract SmartLP_AP is SmartLP_APStorage, IBEP721, IBEP721Metadata {
    using Address for address;
    using Strings for uint256;
    
    address public target;
    uint256 public lockTime;
    mapping(uint256 => bool) public lockEnabled;   
    IBEP20 public nimbToken;
    IBEP20 public gnimbToken;
    IBEP20 public paymentToken;
    ILpStaking public lpStakingBnbGnimb;
    
    bool public usePriceFeeds;
    IPriceFeed public priceFeed;

    mapping(uint256 => uint256) internal _balancesRewardEquivalentBnbGnimb;
    mapping(uint256 => bool) public GnimbPurchases;

    ILpStaking public lpStakingBnbNimb;

    mapping(uint256 => uint256) internal _balancesRewardEquivalentBnbNimb;
    mapping(uint256 => bool) public NimbPurchases;

    ILending public newLendingContract;
    mapping(uint256 => bool) public newLended;

    function initialize(
        address _swapRouter, 
        address _nimbToken, 
        address _gnimbToken, 
        address _bnbNimbPair, 
        address _gnimbBnbPair, 
        address _lpStakingBnbNimb, 
        address _lpStakingBnbGnimb, 
        address _paymentToken,
        address _priceFeed
    ) external onlyOwner {
        require(
            Address.isContract(_swapRouter) && 
            Address.isContract(_nimbToken) && 
            Address.isContract(_gnimbToken) && 
            Address.isContract(_bnbNimbPair) && 
            Address.isContract(_gnimbBnbPair) && 
            Address.isContract(_lpStakingBnbNimb) && 
            Address.isContract(_lpStakingBnbGnimb) && 
            Address.isContract(_paymentToken) && 
            Address.isContract(_priceFeed)
            , "Not contract");

        _name = "Smart LP BNB Affiliate Program";
        _symbol = "SL_BNB_AP";
        
        swapRouter = IRouter(_swapRouter);
        WBNB = IWBNB(swapRouter.NBU_WBNB());
        nimbToken = IBEP20(_nimbToken);
        gnimbToken = IBEP20(_gnimbToken);
        lpStakingBnbNimb = ILpStaking(_lpStakingBnbNimb);
        lpStakingBnbGnimb = ILpStaking(_lpStakingBnbGnimb);
        
        paymentToken = IBEP20(_paymentToken);
        priceFeed = IPriceFeed(_priceFeed);
        usePriceFeeds = true;

        rewardDuration = ILpStaking(_lpStakingBnbNimb).rewardDuration();
        minPurchaseAmount = 1 ether;
        lockTime = 90 days;

        IBEP20(_nimbToken).approve(_swapRouter, type(uint256).max);
        IBEP20(_gnimbToken).approve(_swapRouter, type(uint256).max);
        IBEP20(_bnbNimbPair).approve(address(_swapRouter), type(uint256).max);
        IBEP20(_bnbNimbPair).approve(address(_lpStakingBnbNimb), type(uint256).max);
        IBEP20(_gnimbBnbPair).approve(address(_lpStakingBnbGnimb), type(uint256).max);  
        IBEP20(_gnimbBnbPair).approve(address(_swapRouter), type(uint256).max);  
    }

    receive() external payable {
        assert(msg.sender == address(WBNB) || msg.sender == address(swapRouter));
    }
    


    // ========================== SmartLP functions ==========================

    function buySmartLP() payable external {
        require(msg.value >= minPurchaseAmount, 'Token price is more than sent');
        uint amountBNB = msg.value;
        uint swapAmount = amountBNB/4;
        tokenCount = ++tokenCount;
        
        address[] memory path = new address[](2);
        path[0] = address(WBNB);
        path[1] = address(nimbToken);
        (uint[] memory amountsBnbNimbSwap) = swapRouter.swapExactBNBForTokens{value: swapAmount}(0, path, address(this), block.timestamp);

        path[1] = address(gnimbToken);      
        (uint[] memory amountsBnbGnimbSwap) = swapRouter.swapExactBNBForTokens{value: swapAmount}(0, path, address(this), block.timestamp);
        
        amountBNB -= swapAmount * 2;
        
        (, uint amountBnbNimb, uint liquidityBnbNimb) = swapRouter.addLiquidityBNB{value: amountBNB}(address(nimbToken), amountsBnbNimbSwap[1], 0, 0, address(this), block.timestamp);
        amountBNB -= amountBnbNimb;
        
        (, uint amountBnbGnimb, uint liquidityBnbGnimb) = swapRouter.addLiquidityBNB{value: amountBNB}(address(gnimbToken), amountsBnbGnimbSwap[1], 0, 0, address(this), block.timestamp);
        amountBNB -= amountBnbGnimb;
        
        uint256 noncesBnbNimb = lpStakingBnbNimb.stakeNonces(address(this));
        lpStakingBnbNimb.stake(liquidityBnbNimb);
        uint amountRewardEquivalentBnbNimb = lpStakingBnbNimb.getCurrentLPPrice() * liquidityBnbNimb / 1e18;
        _balancesRewardEquivalentBnbNimb[tokenCount] += amountRewardEquivalentBnbNimb;

        uint256 noncesBnbGnimb = lpStakingBnbGnimb.stakeNonces(address(this));
        lpStakingBnbGnimb.stake(liquidityBnbGnimb);
        uint amountRewardEquivalentBnbGnimb = lpStakingBnbGnimb.getCurrentLPPrice() * liquidityBnbGnimb / 1e18;
        _balancesRewardEquivalentBnbGnimb[tokenCount] += amountRewardEquivalentBnbGnimb;
        
        uint mintAmount = 0;

        UserSupply storage userSupply = tikSupplies[tokenCount];
        userSupply.ProvidedBnb = msg.value;
        userSupply.IsActive = true;
        userSupply.PoolNbuAmount = amountsBnbNimbSwap[1];
        userSupply.PoolGnbuAmount = amountsBnbGnimbSwap[1];
        userSupply.GnbuBnbLpAmount = liquidityBnbGnimb;
        userSupply.NbuBnbLpAmount = liquidityBnbNimb;
        userSupply.LendedITokenAmount = mintAmount;
        userSupply.LendedBNBAmount = 0;   
        userSupply.NbuBnbStakeNonce = noncesBnbNimb;
        userSupply.GnbuBnbStakeNonce = noncesBnbGnimb;
        userSupply.SupplyTime = block.timestamp;
        userSupply.TokenId = tokenCount;

        weightedStakeDate[tokenCount] = userSupply.SupplyTime;
        _userTokens[msg.sender].push(tokenCount); 
        _mint(msg.sender, tokenCount);
        lockEnabled[tokenCount] = true;

        if (amountBNB > 0) {
            uint256 toSend = amountBNB;
            TransferHelper.safeTransferBNB(msg.sender, toSend);
        }
        GnimbPurchases[tokenCount] = true;
        NimbPurchases[tokenCount] = true;

        emit BuySmartLP(msg.sender, tokenCount, msg.value, block.timestamp);
    }
    
    function withdrawUserRewards(uint tokenId) external nonReentrant {
        require(_owners[tokenId] == msg.sender, "Not token owner");
        UserSupply memory userSupply = tikSupplies[tokenId];
        require(userSupply.IsActive, "Not active");
        (uint nbuReward, ) = getTotalAmountsOfRewards(tokenId);
        _withdrawUserRewards(tokenId, nbuReward);
    }
    
    function burnSmartLP(uint tokenId) external nonReentrant {
        require(_owners[tokenId] == msg.sender, "Not token owner");
        UserSupply storage userSupply = tikSupplies[tokenId];
        require(!lockEnabled[tokenId] || block.timestamp > userSupply.SupplyTime + lockTime, 
            "Token is locked"
        );        
        require(userSupply.IsActive, "Token not active");
        (uint nbuReward, ) = getTotalAmountsOfRewards(tokenId);
        
        if(nbuReward > 0) {
            _withdrawUserRewards(tokenId, nbuReward);
        }

        if (NimbPurchases[tokenId]) {
            lpStakingBnbNimb.withdraw(userSupply.NbuBnbStakeNonce);
            swapRouter.removeLiquidityBNB(address(nimbToken), userSupply.NbuBnbLpAmount, 0, 0,  msg.sender, block.timestamp);
        } else {
            lpStakingBnbNbu.withdraw(userSupply.NbuBnbStakeNonce);
            (uint nbuAmount, uint bnbAmount) = swapRouter.removeLiquidityBNB(address(nbuToken), userSupply.NbuBnbLpAmount, 0, 0, address(this), block.timestamp);
            TransferHelper.safeTransfer(address(nimbToken), msg.sender, nbuAmount);
            TransferHelper.safeTransferBNB(msg.sender, bnbAmount);
        }

        if (GnimbPurchases[tokenId]) {
            lpStakingBnbGnimb.withdraw(userSupply.GnbuBnbStakeNonce);
            swapRouter.removeLiquidityBNB(address(gnimbToken), userSupply.GnbuBnbLpAmount, 0, 0, msg.sender, block.timestamp);
        } else {
            lpStakingBnbGnbu.withdraw(userSupply.GnbuBnbStakeNonce);
            (uint gnbuAmount, uint bnbAmount) = swapRouter.removeLiquidityBNB(address(gnbuToken), userSupply.GnbuBnbLpAmount, 0, 0, address(this), block.timestamp);
            TransferHelper.safeTransfer(address(gnimbToken), msg.sender, gnbuAmount);
            TransferHelper.safeTransferBNB(msg.sender, bnbAmount);
        }

        if (userSupply.LendedITokenAmount > 0) {
            ILending(newLended[tokenId] ? newLendingContract : lendingContract).burnToBnb(msg.sender, userSupply.LendedITokenAmount);
        }
        
        transferFrom(msg.sender, address(0x1), tokenId);
        userSupply.IsActive = false;
        
        emit BurnSmartLP(tokenId);      
    }

    function getTokenRewardsAmounts(uint tokenId) public view returns (uint lpBnbNimbUserRewards, uint lpBnbGnbuUserRewards, uint lendedUserRewards) {
        UserSupply memory userSupply = tikSupplies[tokenId];
        require(userSupply.IsActive, "Not active");
        uint convertITokenToBNB = (userSupply.LendedITokenAmount * ILending(newLended[tokenId] ? newLendingContract : lendingContract).tokenPrice()) / 1e18;
        
        lpBnbNimbUserRewards = ((_balancesRewardEquivalentBnbNbu[tokenId] + _balancesRewardEquivalentBnbNimb[tokenId]) * ((block.timestamp - weightedStakeDate[tokenId]) * 100)) / (100 * rewardDuration);
        lpBnbGnbuUserRewards = ((_balancesRewardEquivalentBnbGnbu[tokenId] + _balancesRewardEquivalentBnbGnimb[tokenId]) * ((block.timestamp - weightedStakeDate[tokenId]) * 100)) / (100 * rewardDuration);
        lendedUserRewards = (convertITokenToBNB > userSupply.LendedBNBAmount) ? (convertITokenToBNB - userSupply.LendedBNBAmount) : 0;
    }
    
    function getTotalAmountsOfRewards(uint tokenId) public view returns (uint nbuReward, uint bnbReward) {
        (uint lpBnbNimbUserRewards, uint lpBnbGnbuUserRewards, uint rewardsBnb) = getTokenRewardsAmounts(tokenId);
        nbuReward = getTokenAmountForToken(
            address(nimbToken), 
            address(paymentToken), 
            lpBnbNimbUserRewards + lpBnbGnbuUserRewards
        );

        bnbReward = rewardsBnb;
    }
    
    function getUserTokens(address user) public view returns (uint[] memory) {
        return _userTokens[user];
    }

    function _withdrawUserRewards(uint tokenId, uint totalNbuReward) private {
        require(totalNbuReward > 0, "Claim not enough");
        address tokenOwner = _owners[tokenId];
        TransferHelper.safeTransfer(address(paymentToken), tokenOwner, totalNbuReward);
        weightedStakeDate[tokenId] = block.timestamp;

        emit WithdrawRewards(tokenOwner, tokenId, address(paymentToken), totalNbuReward);
    }


    function getTokenAmountForToken(address tokenSrc, address tokenDest, uint256 tokenAmount) public view returns (uint) { 
        if (tokenSrc == tokenDest) return tokenAmount;
        if (usePriceFeeds && address(priceFeed) != address(0)) {
            (uint256 rate, uint256 precision) = priceFeed.queryRate(tokenSrc, tokenDest);
            return tokenAmount * rate / precision;
        } 
        address[] memory path = new address[](2);
        path[0] = tokenSrc;
        path[1] = tokenDest;
        return swapRouter.getAmountsOut(tokenAmount, path)[1];
    }

    function getNftLpInfo(uint256 tokenId) public view returns (uint lpNimbBnb, uint lpNimbToken, uint lpGnimbBnb, uint lpGnimbToken) {
        INimbusPair curGnimbPair = GnimbPurchases[tokenId] ? INimbusPair(lpStakingBnbGnimb.stakingLPToken()) : INimbusPair(lpStakingBnbGnbu.stakingLPToken());
        INimbusPair curNimbPair = NimbPurchases[tokenId] ? INimbusPair(lpStakingBnbNimb.stakingLPToken()) : INimbusPair(lpStakingBnbNbu.stakingLPToken());

        (uint112 gnimbReserve0, uint112 gnimbReserve1,) = curGnimbPair.getReserves();
        (uint112 nimbReserve0, uint112 nimbReserve1,) = curNimbPair.getReserves();

        uint256 gnimbPairPerc = (tikSupplies[tokenId].GnbuBnbLpAmount * 1 ether) / curGnimbPair.totalSupply();
        uint256 nimbPairPerc = (tikSupplies[tokenId].NbuBnbLpAmount * 1 ether) / curNimbPair.totalSupply();

        bool gnimbPairBnbToken0 = curGnimbPair.token0() == swapRouter.NBU_WBNB();
        lpGnimbBnb = (gnimbPairPerc * (gnimbPairBnbToken0 ? gnimbReserve0 : gnimbReserve1)) / 1 ether;
        lpGnimbToken = (gnimbPairPerc * (gnimbPairBnbToken0 ? gnimbReserve1 : gnimbReserve0)) / 1 ether;

        bool nimbPairBnbToken0 = curNimbPair.token0() == swapRouter.NBU_WBNB();
        lpNimbBnb = (nimbPairPerc * (nimbPairBnbToken0 ? nimbReserve0 : nimbReserve1)) / 1 ether;
        lpNimbToken = (nimbPairPerc * (nimbPairBnbToken0 ? nimbReserve1 : nimbReserve0)) / 1 ether;
    }

    // ========================== EIP 721 functions ==========================

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IBEP165) returns (bool) {
        return
            interfaceId == type(IBEP721).interfaceId ||
            interfaceId == type(IBEP721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = SmartLP_AP.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }
    
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
    
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = SmartLP_AP.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = SmartLP_AP.ownerOf(tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: transfer to the zero address");
        require(SmartLP_AP.ownerOf(tokenId) == from, "ERC721: transfer of token that is not owner");

        for (uint256 i; i < _userTokens[from].length; i++) {
            if(_userTokens[from][i] == tokenId) {
                _remove(i, from);
                break;
            }
        }
        // Clear approvals from the previous owner
        _approve(address(0), tokenId);
        _userTokens[to].push(tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _remove(uint index, address tokenOwner) internal virtual {
        _userTokens[tokenOwner][index] = _userTokens[tokenOwner][_userTokens[tokenOwner].length - 1];
        _userTokens[tokenOwner].pop();
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(SmartLP_AP.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll( address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(address from, address to,uint256 tokenId, bytes memory _data) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    // ========================== Owner functions ==========================

    function rescue(address to, address tokenAddress, uint256 amount) external onlyOwner {
        require(to != address(0), "Cannot rescue to the zero address");
        require(amount > 0, "Cannot rescue 0");

        IBEP20(tokenAddress).transfer(to, amount);
        emit RescueToken(to, address(tokenAddress), amount);
    }

    function rescue(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "Cannot rescue to the zero address");
        require(amount > 0, "Cannot rescue 0");

        to.transfer(amount);
        emit Rescue(to, amount);
    }

    function updatePaymentToken(address _paymentToken) external onlyOwner {
        require(Address.isContract(_paymentToken), "Not a contract");
        paymentToken = IBEP20(_paymentToken);
    }

    function updateSwapRouter(address newSwapRouter) external onlyOwner {
        require(Address.isContract(newSwapRouter), "Not a contract");
        swapRouter = IRouter(newSwapRouter);
        emit UpdateSwapRouter(newSwapRouter);
    }

    function updateNimbTokenContract(address _nimbToken, address _NimbBnbPair, address newLpStaking) external onlyOwner {
        require(Address.isContract(_nimbToken) && Address.isContract(_NimbBnbPair) && Address.isContract(newLpStaking), "Not a contract");
        lpStakingBnbNimb = ILpStaking(newLpStaking);
        IBEP20(_nimbToken).approve(address(swapRouter), type(uint256).max);
        IBEP20(_NimbBnbPair).approve(address(lpStakingBnbNimb), type(uint256).max);  
        IBEP20(_NimbBnbPair).approve(address(swapRouter), type(uint256).max);  
        nimbToken = IBEP20(_nimbToken);
        emit UpdateLpStakingBnbNimb(newLpStaking);
    }

    function updateGnimbTokenContract(address _gnimbToken, address _GnimbBnbPair,address newLpStaking) external onlyOwner {
        require(Address.isContract(_gnimbToken) && Address.isContract(_GnimbBnbPair) && Address.isContract(newLpStaking), "Not a contract");
        lpStakingBnbGnimb = ILpStaking(newLpStaking);
        IBEP20(_gnimbToken).approve(address(swapRouter), type(uint256).max);
        IBEP20(_GnimbBnbPair).approve(address(lpStakingBnbGnimb), type(uint256).max);  
        IBEP20(_GnimbBnbPair).approve(address(swapRouter), type(uint256).max);  
        gnimbToken = IBEP20(_gnimbToken);
        emit UpdateLpStakingBnbGnimb(newLpStaking);
    }
    
    function updateLendingContract(address _oldLendingContract, address _newLendingContract) external onlyOwner {
        require(Address.isContract(_oldLendingContract) && Address.isContract(_newLendingContract), "Not a contract");
        lendingContract = ILending(_oldLendingContract);
        newLendingContract = ILending(_newLendingContract);
        emit UpdateLendingContract(_oldLendingContract);
        emit UpdateLendingContract(_newLendingContract);
    }
    
    function updateLockTime(uint256 newLockTime) external onlyOwner {
        require(newLockTime != lockTime, "Lock time must differ from current");
        lockTime = newLockTime;
    }

    function updateTokenAllowance(address token, address spender, int amount) external onlyOwner {
        require(Address.isContract(token), "Not a contract");
        uint allowance;
        if (amount < 0) {
            allowance = type(uint256).max;
        } else {
            allowance = uint256(amount);
        }
        IBEP20(token).approve(spender, allowance);
    }
    
    function updateMinPurchaseAmount (uint newAmount) external onlyOwner {
        require(newAmount > 0, "Amount must be greater than zero");
        minPurchaseAmount = newAmount;
        emit UpdateMinPurchaseAmount(newAmount);
    }

    function updatePriceFeed(address newPriceFeed) external onlyOwner {
        require(newPriceFeed != address(0), "StakingRewardFixedAPY: Address is zero");
        priceFeed = IPriceFeed(newPriceFeed);
    }

    function updateUsePriceFeeds(bool isUsePriceFeeds) external onlyOwner {
        usePriceFeeds = isUsePriceFeeds;
        emit UpdateUsePriceFeeds(isUsePriceFeeds);
    }

}