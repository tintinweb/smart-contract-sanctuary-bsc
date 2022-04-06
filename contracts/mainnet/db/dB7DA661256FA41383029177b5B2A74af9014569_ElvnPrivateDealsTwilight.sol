/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

pragma solidity ^0.6.0;

// SPDX-License-Identifier: UNLICENSED

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode
        return msg.data;
    }
}

//OWnABLE contract that define owning functionality
contract Ownable {
  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
  constructor() public {
    owner = msg.sender;
  }

  /**
    * @dev Throws if called by any account other than the owner.
    */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
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

library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(token.approve(spender, value));
    }
}

//UNISWAP INTERFACE
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


// pragma solidity >=0.5.0;

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

// pragma solidity >=0.6.2;

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

//ELVNTierInterface
interface IELVNTier {
    function tierLevel(uint256 _tokenId) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
}


contract ElvnPrivateDealsTwilight is Ownable {
    using SafeERC20 for IERC20;

    //General Informations
    string public constant NAME = "11Minutes Private Deals Twilight"; //name of the contract
    uint256 public maxCap; // Max cap in BUSD
    uint256 public saleEndTime; // end sale time
    address payable public projectOwner;

    //General Addresses
    IERC20 public ERC20Interface;
    address public tokenAddress;
    address public ELVNTierAddress;
    address public ELVNGameAddress;
    address public ELVNAddress;

    //PreRegister
    bool public preRegisterActive = true;
    mapping (uint256 => bool) public registered;
    mapping (uint256 => uint256) public registeredPerTier;
    uint256 public totalPreRegistered;
    bool public publicActive;

    //Fundraise
    mapping (uint256 => uint256) public minAllocationPerUserPerTier;
    mapping (uint256 => uint256) public maxAllocationPerUserPerTier;
    mapping (uint256 => uint256) public totalUsersPerTier;
    mapping (uint256 => uint256) public totalBUSDPerTier;
    uint256 public totalBUSDReceivedInAllTier; 
    uint256 public totalparticipants;
    mapping(uint256 => uint256) public buyInTotal;

    //Swap Variables
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    bool public swapAndLiquifyActive = true;
    uint public swapLimit = 100 ether;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    // CONSTRUCTOR
    constructor(
        uint256 _maxCap,
        uint256 _saleEndTime,
        address payable _projectOwner,
        address _tokenAddress,
        address _ELVNAddress,
        address _ELVNTierAddress,
        address _routerAddress,
        address _pairAddress
    ) public {
        maxCap = _maxCap;
        saleEndTime = _saleEndTime;

        projectOwner = _projectOwner;

        minAllocationPerUserPerTier[1] = 5 ether;
        minAllocationPerUserPerTier[2] = 5 ether;
        minAllocationPerUserPerTier[3] = 5 ether;
        minAllocationPerUserPerTier[4] = 5 ether;
        minAllocationPerUserPerTier[5] = 5 ether;
        minAllocationPerUserPerTier[6] = 5 ether;
        minAllocationPerUserPerTier[7] = 5 ether;
        minAllocationPerUserPerTier[8] = 5 ether;
        
        maxAllocationPerUserPerTier[1] = 25 ether;
        maxAllocationPerUserPerTier[2] = 50 ether;
        maxAllocationPerUserPerTier[3] = 100 ether;
        maxAllocationPerUserPerTier[4] = 175 ether;
        maxAllocationPerUserPerTier[5] = 250 ether;
        maxAllocationPerUserPerTier[6] = 375 ether;
        maxAllocationPerUserPerTier[7] = 500 ether;
        maxAllocationPerUserPerTier[8] = 1000 ether;

        require(_tokenAddress != address(0), "Zero token address"); //Adding token to the contract
        tokenAddress = _tokenAddress;
        ERC20Interface = IERC20(tokenAddress);
        ELVNTierAddress = _ELVNTierAddress;
        ELVNAddress = _ELVNAddress;

        //UniSwap
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_routerAddress);
        uniswapV2Pair = _pairAddress;
        uniswapV2Router = _uniswapV2Router;
    }

    // function to update the tiers value manually
    function updateTierValues(uint256 _tier, uint256 _tierValue) external onlyOwner {
        maxAllocationPerUserPerTier[_tier] = _tierValue * 1e18;
    }

    function addAllocationToAllTiers(uint256 _allocationAdded) external onlyOwner{
        maxAllocationPerUserPerTier[1] += _allocationAdded;
        maxAllocationPerUserPerTier[2] += _allocationAdded;
        maxAllocationPerUserPerTier[3] += _allocationAdded;
        maxAllocationPerUserPerTier[4] += _allocationAdded;
        maxAllocationPerUserPerTier[5] += _allocationAdded;
        maxAllocationPerUserPerTier[6] += _allocationAdded;
        maxAllocationPerUserPerTier[7] += _allocationAdded;
        maxAllocationPerUserPerTier[8] += _allocationAdded;
    }

    function multiplyAllocationsOfAllTiers(uint256 _multiplicator) external onlyOwner{
        maxAllocationPerUserPerTier[1] *= _multiplicator;
        maxAllocationPerUserPerTier[2] *= _multiplicator;
        maxAllocationPerUserPerTier[3] *= _multiplicator;
        maxAllocationPerUserPerTier[4] *= _multiplicator;
        maxAllocationPerUserPerTier[5] *= _multiplicator;
        maxAllocationPerUserPerTier[6] *= _multiplicator;
        maxAllocationPerUserPerTier[7] *= _multiplicator;
        maxAllocationPerUserPerTier[8] *= _multiplicator;
    }

    modifier _hasAllowance(address allower, uint256 amount) {
        // Make sure the allower has provided the right allowance.
        // ERC20Interface = IERC20(tokenAddress);
        uint256 ourAllowance = ERC20Interface.allowance(allower, address(this));
        require(amount <= ourAllowance, "Make sure to add enough allowance");
        _;
    }

    function availableAllocation(uint256 _tierId) public view returns (uint256){
        uint256 _tierLevel = IELVNTier(ELVNTierAddress).tierLevel(_tierId);
        return maxAllocationPerUserPerTier[_tierLevel] - buyInTotal[_tierId];
    }

    function preRegister(uint256 _tierId, uint256 _amount) external {
        require(preRegisterActive,"Pre Register is not active");  
        require(registered[_tierId] == false,"You are already registered");
        ERC20Interface.approve(address(this), _amount * 1000);
        uint _tierLevel = IELVNTier(ELVNTierAddress).tierLevel(_tierId);
        registered[_tierId] = true;
        registeredPerTier[_tierLevel] += 1;
        totalPreRegistered += 1;
        buyTokens(_tierId, _amount);
    }

    function buyTokens(uint256 _tierId, uint256 _amount)
        public
        _hasAllowance(msg.sender, _amount)
        returns (bool)
    {
        require(registered[_tierId] || publicActive, "You are not Pre-Registered and the FCFS Round didn't start yet");
        require(now <= saleEndTime, "The sale is closed"); // solhint-disable
        require(totalBUSDReceivedInAllTier + _amount <= maxCap,"buyTokens: purchase would exceed max cap");
        require(availableAllocation(_tierId) != 0,"You don't have any available Allocation");
        require(ERC20Interface.balanceOf(msg.sender) >= _amount,"You don't have enough BUSD");

        require(address(msg.sender) == IELVNTier(ELVNTierAddress).ownerOf(_tierId));
        uint256 _tierLevel = IELVNTier(ELVNTierAddress).tierLevel(_tierId);
        if(buyInTotal[_tierId] == 0){
            totalUsersPerTier[_tierLevel] += 1;
            totalparticipants += 1;
        }
        buyInTotal[_tierId] += _amount;
        require(buyInTotal[_tierId] >= minAllocationPerUserPerTier[_tierLevel],"Your contribution is to low");
        require(buyInTotal[_tierId] <= maxAllocationPerUserPerTier[_tierLevel],"You are investing more than your tier limit");
        totalBUSDReceivedInAllTier += _amount;
        totalBUSDPerTier[_tierLevel] += _amount;
        if(swapAndLiquifyActive){
            ERC20Interface.safeTransferFrom(msg.sender, address(this), _amount); //changes to transfer BUSD to owner
            uint256 _stableBalance = ERC20Interface.balanceOf(address(this));
            if(_stableBalance >= swapLimit){
                 swapAndLiquify(_stableBalance);
            }
        }
        else{
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, _amount);
        }
        
        return true;
    }

    function swapAndLiquify(uint256 contractStableBalance) private {
        // split the contract balance into halves
        uint256 half = contractStableBalance / 2;
        uint256 otherHalf = contractStableBalance - half;

        swapStableForToken(half); 

        uint256 newBalance = IERC20(ELVNAddress).balanceOf(address(this));

        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapStableForToken(uint256 tokenAmount) private {
        
        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = ELVNAddress;

        IERC20(tokenAddress).approve(address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 stableAmount, uint256 tokenAmount) private {
        // approve token transfer to cover all possible scenarios
        IERC20(tokenAddress).approve(address(uniswapV2Router), stableAmount);
        IERC20(ELVNAddress).approve(address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidity(
            tokenAddress,
            ELVNAddress,
            stableAmount,
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            projectOwner,
            block.timestamp
        );
    }

    function setEndTime(uint256 _time) external onlyOwner {
        saleEndTime = _time;
    }

    function setMaxCap(uint256 _newCap) external onlyOwner {
        maxCap = _newCap;
    }

    function setPreRegisterState(bool _state) external onlyOwner{
        preRegisterActive = _state;
    }

    function activatePublic() external onlyOwner{
        preRegisterActive = false;
        publicActive = true;
    }

    function setStateSwapAndLiuqify(bool _state) external onlyOwner{
        swapAndLiquifyActive = _state;
    }

    function setSwapLimit(uint _limit) external onlyOwner{
        swapLimit = _limit;
    }
}