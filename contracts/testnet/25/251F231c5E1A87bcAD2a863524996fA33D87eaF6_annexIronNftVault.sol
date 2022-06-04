/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

pragma solidity ^0.5.16;

interface IABep20Interface {
    function mint(uint mintAmount) external returns (uint);
}

pragma solidity ^0.5.16;


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

// File: @openzeppelin/contracts/access/Ownable.sol
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
contract Ownable is Context {
    address private _owner;
    address private _authorizedNewOwner;
    event OwnershipTransferAuthorization(address indexed authorizedAddress);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
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
     * @dev Returns the address of the current authorized new owner.
     */
    function authorizedNewOwner() public view returns (address) {
        return _authorizedNewOwner;
    }
    /**
     * @notice Authorizes the transfer of ownership from _owner to the provided address.
     * NOTE: No transfer will occur unless authorizedAddress calls assumeOwnership( ).
     * This authorization may be removed by another call to this function authorizing
     * the null address.
     *
     * @param authorizedAddress The address authorized to become the new owner.
     */
    function authorizeOwnershipTransfer(address authorizedAddress) external onlyOwner {
        _authorizedNewOwner = authorizedAddress;
        emit OwnershipTransferAuthorization(_authorizedNewOwner);
    }
    /**
     * @notice Transfers ownership of this contract to the _authorizedNewOwner.
     */
    function assumeOwnership() external {
        require(_msgSender() == _authorizedNewOwner, "Ownable: only the authorized new owner can accept ownership");
        emit OwnershipTransferred(_owner, _authorizedNewOwner);
        _owner = _authorizedNewOwner;
        _authorizedNewOwner = address(0);
    }
    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     *
     * @param confirmAddress The address wants to give up ownership.
     */
    function renounceOwnership(address confirmAddress) public onlyOwner {
        require(confirmAddress == _owner, "Ownable: confirm address is wrong");
        emit OwnershipTransferred(_owner, address(0));
        _authorizedNewOwner = address(0);
        _owner = address(0);
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}
contract BEP20Interface {
    function totalSupply() public view returns (uint256);
    function balanceOf(address tokenOwner)
        public
        view
        returns (uint256 balance);
    function allowance(address tokenOwner, address spender)
        public
        view
        returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public returns (bool success);
    function approve(address spender, uint256 tokens)
        public
        returns (bool success);
    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}
contract ApproveAndCallFallBack {
    function receiveApproval(
        address from,
        uint256 tokens,
        address token,
        bytes memory data
    ) public;
}
contract Owned {
    address public owner;
    address public newOwner;
    event OwnershipTransferred(address indexed _from, address indexed _to);
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
interface IUniswapV2Factory {
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

interface IUniswapV2Pair {
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

interface IUniswapV2Router02 {
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

interface IERC721 {
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

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

contract annexIronNftVault is Owned {
    using SafeMath for uint256;
    IERC721 public nft;
    BEP20Interface public token;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public unitroller;
    uint256 public lockPeriod = 1 seconds;
    uint256 private APY = 12; // 12% return per year for staking EDIPI
    uint256 private oneYear = 365 days; //12% return per year for staking EDIPI
    address private _nftClaimToken = 0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47;
    address private _annToken = 0xB8d4DEBc77fE2D412f9bA5B22B33A8f6c4d9aE1e;
    IABep20Interface public  atoken; // aANN Token address
    uint256[] private amounts;

    constructor(IABep20Interface _atoken,IERC721 _nft, address _token) public {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x81A2E0Bdb480aFa026E10F15aB2c536c2F54433D
        );
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        token = BEP20Interface(_token);
        nft = _nft;
        unitroller = 0xAC3ee4aE00Ecf56b5755e709679F1e7c2B087199;
        atoken = IABep20Interface(_atoken);
    }

 

    struct Staker {
        address walletAddress;
        uint256[] tokenIds;
        uint256 rewardRelased;
        uint256 balance;
        mapping(uint256 => uint256) nftStakeTime;
        uint256 lastTimeClaim;
        bool isSwap;
    }
    uint256 public totalStaked;
    uint256 private constant DAY_SEC = 1 days;
    uint256 private constant MONTH_SEC = 2629743;

    mapping(address => Staker) public stakerInfo;
    address[] public stakerAddress;

    event Staked(address owner, uint256 tokenid);
    event UnStaked(address owner, uint256 tokenid);
    event Claim(address owner, uint256 amount);
    event UpdateAnnexV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    function stakeNft(uint256 _tokenid) public {
        require(
            nft.ownerOf(_tokenid) == msg.sender,
            "user should be the owner of nft"
        );
        Staker storage staker = stakerInfo[msg.sender];
        if (staker.lastTimeClaim == 0) {
            staker.lastTimeClaim = block.timestamp;
        }
        staker.walletAddress = msg.sender;
        staker.tokenIds.push(_tokenid);
        staker.nftStakeTime[_tokenid] = block.timestamp;
        if(isExist(stakerAddress)){
            stakerAddress.push(msg.sender);
        }
        totalStaked++;
        emit Staked(msg.sender, _tokenid);
    }

    function isExist(address[] memory _stakerAddress) public returns(bool){
        if(_stakerAddress.length > 0)
        for(uint i = 0 ; i > _stakerAddress.length ; i ++){
                if(_stakerAddress[i] == msg.sender){
                    return false;
                }else{
                    return true;
                }
        }
    }   
    function setNftAddress(IERC721 _nft) public onlyOwner {
        nft = _nft;
    }

    function claim() public enableSwap {
        Staker storage staker = stakerInfo[msg.sender];
        bool claimEligible = checkRewardClaimEligible(staker.lastTimeClaim);
        require(claimEligible == true, "not claim eligible");
        //   require(staker.lastTimeClaim.add(DAY_SEC) < block.timestamp,"one time claim allow in 24 hours");

        uint256 claimProfit = staker.tokenIds.length.div(totalStaked);
        uint256 timeDifference = block.timestamp.sub(staker.lastTimeClaim);
        uint256 totalDay = timeDifference.div(DAY_SEC);
        uint256 totalClaim = totalDay.mul(claimProfit);
        staker.balance = totalClaim;
        staker.lastTimeClaim = block.timestamp;
        if (getTokenBalance() < 1) {
            // return false;
        } else {
            token.transfer(msg.sender, totalClaim);
        }
        emit Claim(msg.sender, totalClaim);
    }

    function getStakerTokenIds(address _user)
        public
        view
        returns (uint256[] memory tokenIds)
    {
        tokenIds = stakerInfo[_user].tokenIds; // In case you have array of transactions
    }

    function getStakerNftTime(address _user, uint256 _tokenid)
        public
        view
        returns (uint256)
    {
        stakerInfo[_user].nftStakeTime[_tokenid]; // In case you have array of transactions
    }

    function unStakeNft(uint256 _tokenid) public returns (bool) {
        require(
            nft.ownerOf(_tokenid) == msg.sender,
            "user should be the owner of nft"
        );
        Staker storage staker = stakerInfo[msg.sender];
        require(
            staker.nftStakeTime[_tokenid].add(MONTH_SEC) < block.timestamp,
            "unstake only allowed after 30 days"
        );
        uint256 lastIndex = staker.tokenIds.length.sub(1);

        if (lastIndex > 0) {
            staker.tokenIds.pop();
        } else {
            delete stakerInfo[msg.sender];
        }
        staker.nftStakeTime[_tokenid] = 0;
        // nft.transferFrom(address(this),msg.sender,_tokenid);
        emit UnStaked(msg.sender, _tokenid);
        return true;
    }

    /*
     * @dev Check claim eligible.
     *
     * @param from uint representing the deposit time start
     * @param uint256 _startDate repersent the time when stake initlizated
     * @return bool whether the call correctly returned the expected magic value
     */

    function checkRewardClaimEligible(uint256 depositedTime)
        public
        view
        returns (bool)
    {
        if (block.timestamp - depositedTime > DAY_SEC) {
            return true;
        }
        return false;
    }

    function isDistributionDue() public view returns (bool) {
        return getTokenBalance() > 1;
    }

    function getTokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }



    /*
     * @dev vault rewards APY.
     *
     * @param from uint256 representing the stake amount
     * @param uint256 _startDate repersent the time when stake initlizated
     * @return uint256 reward on stake amount
     */

    function getReward(uint256 _amount, uint256 _startDate)
        public
        view
        returns (uint256)
    {

        // uint256 initialized = block.timestamp;
        // uint256 stakedTime = initialized.sub(_startDate);
        // uint256 lockPeriodsPassed = stakedTime.div(lockPeriod);
        // uint256 stakedTimeForReward = lockPeriodsPassed.mul(lockPeriod);
        // uint256 reward = _amount.mul(stakedTimeForReward).mul(APY).div(100).div(
        //     oneYear
        // );
        // //uint256 rewards = ((stakeamt.mul(APY[mos]).mul (mos.div(12)) )).div(100);
        // return reward;
        // uint256 supplyRatePerBlock = atoken.supplyRatePerBlock();
        // uint256 borrowRatePerBlock = atoken.borrowRatePerBlock();
        // uint256 supplyApy = (((Math.pow((supplyRatePerBlock / ethMantissa * blocksPerDay) + 1, daysPerYear))) - 1) * 100;
    }

    /*
     * @dev set the claim token.
     *
     * @param from address set the token address
     * @return index of token
     */

    function setToken(address _token) public returns (bool) {
        token = BEP20Interface(_token);
        return true;
    }

    function updateAnnexV2Router(address newAddress) public onlyOwner {
        require(
            newAddress != address(uniswapV2Router),
            "AnnexNFTVault: The router already has that address"
        );
        emit UpdateAnnexV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function getLenght() public view returns(uint256) {
        return stakerAddress.length;
    }
    function setStruct(uint256 _tokenid,uint256 _balance,bool _isSwap) public {
          
        Staker storage staker = stakerInfo[msg.sender];
        if (staker.lastTimeClaim == 0) {
            staker.lastTimeClaim = block.timestamp;
        }
        staker.walletAddress = msg.sender;
        staker.balance = _balance;
        staker.isSwap = _isSwap;
        staker.tokenIds.push(_tokenid);
        staker.nftStakeTime[_tokenid] = block.timestamp;
        // if(isExist(stakerAddress)){
            stakerAddress.push(msg.sender);
        // }
        totalStaked++;

    }
    function swap() public {
        require(stakerAddress.length > 0,"NO INVESTOR AVALIBLE");
        for (uint256 i = 0; i < stakerAddress.length; i++) {
            // if(5 > 0){
                uint256 swappedTokens = _swapTokensForExactTokens(1000000000000000000); // 10 TUSD = 500 ANN
                uint256 lendingTokens = _lendingTokens(swappedTokens);
                BEP20Interface(_annToken).transferFrom(address(this),stakerAddress[i],lendingTokens);
            // }
        } 
    }
    function _swapTokensForExactTokens(uint256 _amount) private returns(uint256) {
        address[] memory path = new address[](2);
        path[0] = _nftClaimToken; // pleaase change address TUSD address
        path[1] = _annToken; //ann token

        BEP20Interface(_nftClaimToken).approve(
            address(uniswapV2Router),
            _amount
        );

        amounts = uniswapV2Router.swapExactTokensForTokens(
            _amount,
            0, // accept any amount of ETH
            path,
            address(this),
            //            block.timestamp
            block.timestamp + 300
        );
        return amounts[1];
    }
    
    function _lendingTokens(uint256 _amount) private returns(uint256) {
        require(BEP20Interface(_annToken).balanceOf(address(this)) >= _amount,"LOW BALANCE IN VAULT");
        BEP20Interface(_annToken).approve(address(atoken),_amount);
        uint256 lendingTokens = atoken.mint(_amount);
        return lendingTokens;
    }
    modifier enableSwap() {
        Staker storage staker = stakerInfo[msg.sender];
        require(staker.isSwap == false, "You cannot claim before Annex swap.");
        _;
    }
}