/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value); 

}

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

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


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

interface IAFBGov {
    function mastermind() external view returns (address);
    function viewActorLevelOf(address _address) external view returns (uint256);
    function viewFeeDestination() external view returns (address);
    function viewTxThreshold() external view returns (uint256);
    function viewBurnRate() external view returns (uint256);
    function viewFeeRate() external view returns (uint256);
}


abstract contract AFBUtils is Ownable {
    event TokenSweep(address indexed user, address indexed token, uint256 amount);

    // Sweep any tokens/BNB accidentally sent or airdropped to the contract
    function sweep(address token) external onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
        require(amount > 0, "Sweep: No token balance");

        IERC20(token).transfer(msg.sender, amount); // use of the ERC20 traditional transfer

        if (address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }

        emit TokenSweep(msg.sender, token, amount);
    }

    // Self-Destruct contract to free space on-chain, sweep any BNB to owner
    function kill() external onlyOwner {
        selfdestruct(payable(msg.sender));
    }
}

contract AFBGovernance is IAFBGov, AFBUtils {
    event RightsUpdated(address indexed caller, address indexed subject, uint256 level);
    event RightsRevoked(address indexed caller, address indexed subject);
    event MastermindUpdated(address indexed caller, address indexed subject);
    event FeeDestinationUpdated(address indexed caller, address feeDestination);
    event TxThresholdUpdated(address indexed caller, uint256 txThreshold);
    event BurnRateUpdated(address indexed caller, uint256 burnRate);
    event FeeRateUpdated(address indexed caller, uint256 feeRate);

    address public override mastermind;
    mapping (address => uint256) private actorLevel; // governance = multi-tier level
    
    address private feeDestination; // target address for fees
    uint256 private txThreshold; // min AFB transferred to mint AFBPoints
    uint256 private burnRate; // % burn on each tx, 10 = 1%
    uint256 private feeRate; // % fee on each tx, 10 = 1% 

    modifier onlyMastermind {
        require(msg.sender == mastermind, "Gov: Only Mastermind");
        _;
    }

    modifier onlyGovernor {
        require(actorLevel[msg.sender] >= 2,"Gov: Only Governors");
        _;
    }

    modifier onlyPartner {
        require(actorLevel[msg.sender] >= 1,"Gov: Only Partners");
        _;
    }

    constructor() {
        mastermind = msg.sender;
        actorLevel[mastermind] = 3;
        feeDestination = mastermind;
    }
    
    // Gov - Actor Level
    function viewActorLevelOf(address _address) public override view returns (uint256) {
        return actorLevel[_address];
    }

    // Gov - Fee Destination / Treasury
    function viewFeeDestination() public override view returns (address) {
        return feeDestination;
    }

    // Points - Transaction Threshold
    function viewTxThreshold() public override view returns (uint256) {
        return txThreshold;
    }

    // Token - Burn Rate
    function viewBurnRate() public override view returns (uint256) {
        return burnRate;
    }

    // Token - Fee Rate
    function viewFeeRate() public override view returns (uint256) {
        return feeRate;
    }

    // Governed Functions

    // Update Actor Level, can only be performed with level strictly lower than msg.sender's level
    // Add/Remove user governance rights
    function setActorLevel(address user, uint256 level) public {
        require(level < actorLevel[msg.sender], "ActorLevel: Can only grant rights below you");
        require(actorLevel[user] < actorLevel[msg.sender], "ActorLevel: Can only update users below you");

        actorLevel[user] = level; // updates level -> adds or removes rights
        emit RightsUpdated(msg.sender, user, level);
    }
    
    // MasterMind - Revoke all rights
    function removeAllRights(address user) public onlyMastermind {
        require(user != mastermind, "Mastermind: Cannot revoke own rights");

        actorLevel[user] = 0; 
        emit RightsRevoked(msg.sender, user);
    }

    // Mastermind - Transfer ownership of Governance
    function setMastermind(address _mastermind) public onlyMastermind {
        require(_mastermind != mastermind, "Mastermind: Cannot call self");

        mastermind = _mastermind; // Only one mastermind
        actorLevel[_mastermind] = 3;
        actorLevel[mastermind] = 2; // new level for previous mastermind
        emit MastermindUpdated(msg.sender, mastermind);
    }

    // Gov - Update the Fee Destination
    function setFeeDestination(address _feeDestination) public onlyGovernor {
        require(_feeDestination != feeDestination, "FeeDestination: No destination change");

        feeDestination = _feeDestination;
        emit FeeDestinationUpdated(msg.sender, feeDestination);
    }

    // Points - Update the Tx Threshold
    function changeTxThreshold(uint _txThreshold) public onlyGovernor {
        require(_txThreshold != txThreshold, "TxThreshold: No threshold change");

        txThreshold = _txThreshold;
        emit TxThresholdUpdated(msg.sender, txThreshold);
    }
    
    // Token - Update the Burn Rate
    function changeBurnRate(uint _burnRate) public onlyGovernor {
        require(_burnRate <= 200, "BurnRate: 20% limit");

        burnRate = _burnRate; 
        emit BurnRateUpdated(msg.sender, burnRate);
    }

    // Token - Update the Fee Rate
    function changeFeeRate(uint _feeRate) public onlyGovernor {
        require(_feeRate <= 200, "FeeRate: 20% limit");

        feeRate = _feeRate;
        emit FeeRateUpdated(msg.sender, feeRate);
    }
}