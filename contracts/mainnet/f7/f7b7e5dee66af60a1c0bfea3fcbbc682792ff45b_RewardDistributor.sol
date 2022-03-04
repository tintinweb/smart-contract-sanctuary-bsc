/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface IMoonshotMechanism {
    function setShare(address crew, uint256 amount) external;
    function getGoal() external view returns(uint);
    function getMoonshotBalance() external view returns(uint);
}

interface IRewardDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address keeper, uint256 amount) external;
    //function deposit() external;
    function process(uint256 gas) external;
}

interface IPYESwapRouter01 {
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

interface IPYESwapRouter is IPYESwapRouter01 {
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
    function pairFeeAddress(address pair) external view returns (address);
    function adminFee() external view returns (uint256);
    function feeAddressGet() external view returns (address);
}

interface IPYESwapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function baseToken() external view returns (address);
    function getTotalFee() external view returns (uint);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function updateTotalFee(uint totalFee) external returns (bool);

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
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast, address _baseToken);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, uint amount0Fee, uint amount1Fee, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
    function setBaseToken(address _baseToken) external;
}

interface IPYESwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function pairExist(address pair) external view returns (bool);

    function createPair(address tokenA, address tokenB, bool supportsTokenFee) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function routerInitialize(address) external;
    function routerAddress() external view returns (address);
}

interface IWETH {
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IPYE {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
	
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
	
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
	
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
	
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
	
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
		
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
	
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
	
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
	
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
	
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
	
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
	
    function owner() public view virtual returns (address) {
        return _owner;
    }
	
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
	
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
	
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
          uint256 c = a * b;
        if (c / a != b) return (false, 0);
          return (true, c);
    }
	
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
	
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
	
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
	
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
	
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
	
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
	
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
	
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
	
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
	
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

contract MoonshotMechanism is IMoonshotMechanism {
    using SafeMath for uint256;

    address public _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    struct Moonshot {
        string Name;
        uint Value;
    }

    address[] crews;
    mapping (address => uint256) crewIndexes;

    mapping (address => Share) public shares;

    uint256 public totalForceShares;
    uint256 public totalForceBountys;
    uint256 public totalForceDistributed;
    uint256 public forceBountysPerShare;
    uint256 public forceBountysPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 9);

    uint256 currentIndex;

    bool public initialized = true;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    Moonshot[] internal Moonshots;
    address admin;
    uint public disbursalThreshold;
    uint public lastMoonShot;

    bool private inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    IPYESwapRouter public pyeSwapRouter;
    address public WBNB;

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }
	
    constructor() public {
        pyeSwapRouter = IPYESwapRouter(0x2f080082f2b2DE0362a3c008c275DD2c9143e1E4);
        WBNB = pyeSwapRouter.WETH();
        _token = msg.sender;
		
        admin = 0x5f46913071f854A99FeB5B3cF54851E539CA6D44;
        Moonshots.push(Moonshot("Waxing", 250));
        Moonshots.push(Moonshot("Waning", 500));
        Moonshots.push(Moonshot("Half Moon", 750));
        Moonshots.push(Moonshot("Full Moon", 1000));
        Moonshots.push(Moonshot("Blue Moon", 2000));
    }

    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }
	
    function createMoonshot(string memory _newName, uint _newValue) public onlyAdmin {
        Moonshots.push(Moonshot(_newName, _newValue));
    }
	
    function popMoonshot() public onlyAdmin {
        Moonshots.pop();
    }
	
    function deleteMoonshot(uint _value) public onlyAdmin {
        uint moonshotLength = Moonshots.length;
        for(uint i = 0; i < moonshotLength; i++) {
            if (_value == Moonshots[i].Value) {
                if (1 < Moonshots.length && i < moonshotLength-1) {
                    Moonshots[i] = Moonshots[moonshotLength-1]; }
                    delete Moonshots[moonshotLength-1];
                    Moonshots.pop();
                    break;
            }
        }
    }
	
    function updateAdmin(address _newAdmin) public onlyAdmin {
        admin = _newAdmin;
    }

    function getGoal() external view override returns(uint256){
        return disbursalThreshold;
    }

    function getMoonshotBalance() external view override returns(uint256){
        return IERC20(address(WBNB)).balanceOf(address(this));
    }
	
    function getMoonshotNameAndValue(uint _index) public view returns (string memory, uint) {
        return (Moonshots[_index].Name, Moonshots[_index].Value);
    }

    function getContractValue() public view onlyAdmin returns (uint) {
        return address(this).balance;
    }
	
    function getDisbursalValue() public view onlyAdmin returns (uint) {
        return disbursalThreshold;
    }
	
    function random() internal view onlyAdmin returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty + block.timestamp)));
    }
	
    function overrideDisbursalThreshold(uint newDisbursalThreshold) public onlyAdmin returns (uint) {
        disbursalThreshold = newDisbursalThreshold;
        return disbursalThreshold;
    }
	
    function pickMoonshot() public onlyAdmin {
        require(Moonshots.length > 1, "The Moonshot array has only one moonshot, please create a new Moonshot!");
        Moonshot storage winningStruct = Moonshots[random() % Moonshots.length];
        uint disbursalValue = winningStruct.Value;
        lastMoonShot = disbursalThreshold;
        disbursalThreshold = disbursalValue * 10**18;
        
        if (disbursalThreshold == lastMoonShot) {
            verifyNewMoonshot();
        }
    }
	
    function verifyNewMoonshot() internal {
        if (disbursalThreshold == lastMoonShot) {
            pickMoonshot();
        }
    }    

    function launchMoonshot() public  {
        uint256 moonBalance = IERC20(address(WBNB)).balanceOf(address(this));
        require(moonBalance >= disbursalThreshold, "Moonshot: Not allowed before threshold");
        buyReflectTokens(disbursalThreshold, address(this));
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address crew, uint256 amount) external override onlyToken {
        if(amount == 0)
		{
            distributeBounty(crew);
        }
		
        if(amount > 0 && shares[crew].amount == 0)
		{
            addCrew(crew);
        }
		
		else if(amount == 0 && shares[crew].amount > 0)
		{
            removeCrew(crew);
        }
		
        totalForceShares = totalForceShares.sub(shares[crew].amount).add(amount);
        shares[crew].amount = amount;
        shares[crew].totalExcluded = getCumulativeBountys(shares[crew].amount);
    }

    function buyReflectTokens(uint256 amount, address to) internal {
        uint256 balanceBefore = IERC20(address(_token)).balanceOf(address(this));
		
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = _token;

        IERC20(WBNB).approve(address(pyeSwapRouter), amount);

        pyeSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            to,
            block.timestamp + 10 minutes
        );
		
        uint256 newAmount = IERC20(address(_token)).balanceOf(address(this)).sub(balanceBefore);

        totalForceBountys = totalForceBountys.add(newAmount);
        forceBountysPerShare = forceBountysPerShare.add(forceBountysPerShareAccuracyFactor.mul(newAmount).div(totalForceShares));
        pickMoonshot();
    }
	
    function distributeBounty(address crew) internal {
        if(shares[crew].amount == 0){ return; }
		
        uint256 amount = getUnpaidEarnings(crew);
        if(amount > 0){
            totalForceDistributed = totalForceDistributed.add(amount);
            IERC20(_token).transfer(crew, amount);
            shares[crew].totalRealised = shares[crew].totalRealised.add(amount);
            shares[crew].totalExcluded = getCumulativeBountys(shares[crew].amount);
        }
    }
	
	function swapToken(address token, uint256 amount, address to) public onlyAdmin {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = WBNB;
		
        IERC20(token).approve(address(pyeSwapRouter), amount);
		
        pyeSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            to,
            block.timestamp + 10 minutes
        );
    }
	
    function claimMoon() external {
        distributeBounty(msg.sender);
    }
	
    function getUnpaidEarnings(address crew) public view returns (uint256) {
        if(shares[crew].amount == 0){ return 0; }

        uint256 crewTotalBountys = getCumulativeBountys(shares[crew].amount);
        uint256 crewTotalExcluded = shares[crew].totalExcluded;

        if(crewTotalBountys <= crewTotalExcluded){ return 0; }

        return crewTotalBountys.sub(crewTotalExcluded);
    }

    function getCumulativeBountys(uint256 share) internal view returns (uint256) {
        return share.mul(forceBountysPerShare).div(forceBountysPerShareAccuracyFactor);
    }

    function addCrew(address crew) internal {
        crewIndexes[crew] = crews.length;
        crews.push(crew);
    }
	
    function removeCrew(address crew) internal {
        crews[crewIndexes[crew]] = crews[crews.length-1];
        crewIndexes[crews[crews.length-1]] = crewIndexes[crew];
        crews.pop();
    }

    function rescueBNB(uint256 amount, address to) external onlyAdmin{
        payable(to).transfer(amount);
    }
	
    function rescueToken(IERC20 token, uint256 amount, address to) external onlyAdmin {
        if( token.balanceOf(address(this)) < amount ) {
            amount = token.balanceOf(address(this));
        }
        token.transfer(to, amount);
    }
}

contract RewardDistributor is IRewardDistributor {
    using SafeMath for uint256;

    address public _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;


    address[] keepers;
    mapping (address => uint256) keeperIndexes;
    mapping (address => uint256) keeperClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    //uint256 public totalBountys;
    uint256 public totalDistributed;
    //uint256 public bountysPerShare;
    uint256 public bountysPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 18);

    //uint256 public balanceBefore;
    address admin;

    uint256 currentIndex;

    bool public initialized = true;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor () public {
        _token = msg.sender;
        admin = 0x5f46913071f854A99FeB5B3cF54851E539CA6D44;
    }

    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }

    receive() external payable {}

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }
	
    function setShare(address keeper, uint256 amount) external override onlyToken {
        if(amount == 0)
		{
           distributeBounty(keeper);
        }
		
        if(amount > 0 && shares[keeper].amount == 0)
		{
            addKeeper(keeper);
        }
		else if(amount == 0 && shares[keeper].amount > 0)
		{
            removeKeeper(keeper);
        }
		
        totalShares = totalShares.sub(shares[keeper].amount).add(amount);
        shares[keeper].amount = amount;
        shares[keeper].totalExcluded = getCumulativeBountys(shares[keeper].amount);
    }

    function updateAdmin(address _newAdmin) public onlyAdmin {
        admin = _newAdmin;
    }
	
	/*
    function deposit() external override onlyToken {
        uint256 amount   = IERC20(address(WBNB)).balanceOf(address(this)).sub(balanceBefore);
        totalBountys     = totalBountys.add(amount);
        bountysPerShare  = bountysPerShare.add(bountysPerShareAccuracyFactor.mul(amount).div(totalShares));
        balanceBefore    = totalBountys;
    }
	*/
	
    function process(uint256 gas) external override onlyToken {
        uint256 keeperCount = keepers.length;

        if(keeperCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < keeperCount) {
            if(currentIndex >= keeperCount){
                currentIndex = 0;
            }

            if(shouldDistribute(keepers[currentIndex])){
                distributeBounty(keepers[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address keeper) internal view returns (bool) {
        return keeperClaims[keeper] + minPeriod < block.timestamp
        && getUnpaidEarnings(keeper) > minDistribution;
    }
	
    function distributeBounty(address keeper) internal {
        if(shares[keeper].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(keeper);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            IERC20(WBNB).transfer(keeper, amount);
            keeperClaims[keeper] = block.timestamp;
            shares[keeper].totalRealised = shares[keeper].totalRealised.add(amount);
            shares[keeper].totalExcluded = getCumulativeBountys(shares[keeper].amount);
        }
    }

    function claimBounty() external {
        distributeBounty(msg.sender);
    }
	
    function getUnpaidEarnings(address keeper) public view returns (uint256) {
        if(shares[keeper].amount == 0){ return 0; }

        uint256 keeperTotalBountys = getCumulativeBountys(shares[keeper].amount);
        uint256 keeperTotalExcluded = shares[keeper].totalExcluded;

        if(keeperTotalBountys <= keeperTotalExcluded){ return 0; }

        return keeperTotalBountys.sub(keeperTotalExcluded);
    }

    function getCumulativeBountys(uint256 share) internal view returns (uint256) {
	    uint256 amount   = IERC20(address(WBNB)).balanceOf(address(this));
        uint256 bountysPerShare  = bountysPerShareAccuracyFactor.mul(amount).div(totalShares);
		
        return share.mul(bountysPerShare).div(bountysPerShareAccuracyFactor);
    }

    function addKeeper(address keeper) internal {
        keeperIndexes[keeper] = keepers.length;
        keepers.push(keeper);
    }
	
    function removeKeeper(address keeper) internal {
        keepers[keeperIndexes[keeper]] = keepers[keepers.length-1];
        keeperIndexes[keepers[keepers.length-1]] = keeperIndexes[keeper];
        keepers.pop();
    }
	
    function rescueBNB(uint256 amount, address to) external onlyAdmin{
        payable(to).transfer(amount);
    }
	
    function rescueToken(IERC20 token, uint256 amount, address to) external onlyAdmin {
        if( token.balanceOf(address(this)) < amount ) {
            amount = token.balanceOf(address(this));
        }
        token.transfer(to, amount);
    }
}

contract MoonForce is IPYE, Context, Ownable {
    using SafeMath for uint256;
    using Address for address;
	
    struct Fees {
        uint256 reflectionFee;
        uint256 marketingFee;
        uint256 moonshotFee;
        uint256 buybackFee;
        uint256 liquifyFee;
        address marketingAddress;
        address liquifyAddress;
    }

    struct FeeValues {
        uint256 transferAmount;
        uint256 reflection;
        uint256 marketing;
        uint256 moonshots;
        uint256 buyBack;
        uint256 liquify;
    }
	
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _tTotal = 10 * 10**9 * 10**9;
	
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isBountyExempt;
    mapping (address => bool) isBlacklisted;
	
    mapping (uint256 => address) private pairs;
    mapping (uint256 => address) private tokens;
    uint256 private pairsLength;

    string constant _name = "MoonForce";
    string constant _symbol = "FORCE";
    uint8 constant _decimals = 9;
    uint minimumBuyBackThreshold;

    Fees public _defaultFees;
    Fees private _previousFees;
    Fees private _emptyFees;

    IPYESwapRouter public pyeSwapRouter;
    address public pyeSwapPair;
    address public WBNB;
    address public _burnAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public _maxTxAmount = 5 * 10**8 * 10**9;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;

    uint256 buybackMultiplierNumerator = 200;
    uint256 buybackMultiplierDenominator = 100;
    uint256 buybackMultiplierTriggeredAt;
    uint256 buybackMultiplierLength = 30 minutes;

    bool public autoBuybackEnabled = false;
    uint256 autoBuybackCap;
    uint256 autoBuybackAccumulator;
    uint256 autoBuybackAmount;
    uint256 autoBuybackBlockPeriod;
    uint256 autoBuybackBlockLast;

    RewardDistributor distributor;
    address public distributorAddress;

    MoonshotMechanism moonshot;
    address public moonshotAddress;

    uint256 distributorGas = 500000;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _tTotal / 2000; // 0.005%
    bool inSwap;

    modifier swapping() { inSwap = true; _; inSwap = false; }
    modifier onlyExchange() {
        bool isPair = false;
        for(uint i = 0; i < pairsLength; i++) {
            if(pairs[i] == msg.sender) isPair = true;
        }
        require(
            msg.sender == address(pyeSwapRouter)
            || isPair
            , "PYE: NOT_ALLOWED"
        );
        _;
    }

    event BuybackMultiplierActive(uint256 duration);
	
    constructor() public {
        _balances[_msgSender()] = _tTotal;

        pyeSwapRouter = IPYESwapRouter(0x2f080082f2b2DE0362a3c008c275DD2c9143e1E4);
        WBNB = pyeSwapRouter.WETH();
        pyeSwapPair = IPYESwapFactory(pyeSwapRouter.factory())
        .createPair(address(this), WBNB, true);
        distributor = new RewardDistributor();
        distributorAddress = address(distributor);
        
        moonshot = new MoonshotMechanism();
        moonshotAddress = address(moonshot);

        tokens[pairsLength] = WBNB;
        pairs[pairsLength] = pyeSwapPair;
        pairsLength += 1;

        isTxLimitExempt[_msgSender()] = true;
        isTxLimitExempt[pyeSwapPair] = true;
        isTxLimitExempt[address(pyeSwapRouter)] = true;
        isTxLimitExempt[distributorAddress] = true;
        isTxLimitExempt[moonshotAddress] = true;

        isBountyExempt[pyeSwapPair] = true;
        isBountyExempt[address(this)] = true;
        isBountyExempt[_burnAddress] = true;
        isBountyExempt[distributorAddress] = true;
        isBountyExempt[moonshotAddress] = true;

        _defaultFees = Fees(
            800,
            300,
            200,
            100,
            0,
            0xdfc2aeD317d8ef2bC90183FD0e365BFE190bFCBD,
            0x8539a0c8D96610527140E97A9ae458F6A5bb1F86
        );

        IPYESwapPair(pyeSwapPair).updateTotalFee(1400);
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }
	
    function blacklistAddress(address addressToBlacklist) public onlyOwner {
        require(!isBlacklisted[addressToBlacklist] , "Address is already blacklisted!");
        isBlacklisted[addressToBlacklist] = true;
    }

    function removeFromBlacklist(address addressToRemove) public onlyOwner {
        require(isBlacklisted[addressToRemove] , "Address has not been blacklisted! Enter an address that is on the blacklist.");
        isBlacklisted[addressToRemove] = false;
    }

    function setMinimumBuyBackThreshold(uint _newMinimum) public onlyOwner {
        minimumBuyBackThreshold = _newMinimum;
    } 

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return isBountyExempt[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function _updatePairsFee() internal {
        for (uint j = 0; j < pairsLength; j++) {
            IPYESwapPair(pairs[j]).updateTotalFee(getTotalFee());
        }
    }

    function setReflectionPercent(uint256 _reflectionFee) external onlyOwner {
        _defaultFees.reflectionFee = _reflectionFee;
        _updatePairsFee();
    }

    function setLiquifyPercent(uint256 _liquifyFee) external onlyOwner {
        _defaultFees.liquifyFee = _liquifyFee;
        _updatePairsFee();
    }

    function setMoonshotPercent(uint256 _moonshotFee) external onlyOwner {
        _defaultFees.moonshotFee = _moonshotFee;
        _updatePairsFee();
    }

    function setMarketingPercent(uint256 _marketingFee) external onlyOwner {
        _defaultFees.marketingFee = _marketingFee;
        _updatePairsFee();
    }

    function setBuyBackPercent(uint256 _burnFee) external onlyOwner {
        _defaultFees.buybackFee = _burnFee;
        _updatePairsFee();
    }

    function setMarketingAddress(address _marketing) external onlyOwner {
        require(_marketing != address(0), "PYE: Address Zero is not allowed");
        _defaultFees.marketingAddress = _marketing;
    }

    function setLiquifyAddress(address _liquify) external onlyOwner {
        require(_liquify != address(0), "PYE: Address Zero is not allowed");
        _defaultFees.marketingAddress = _liquify;
    }

    function setDistributorAddress(address _distributorAddress) external onlyOwner {
        require(_distributorAddress != address(0), "PYE: Address Zero is not allowed");
        distributorAddress = _distributorAddress;
    }

    function setMoonshotAddress(address _moonshotAddress) external onlyOwner {
        require(_moonshotAddress != address(0), "PYE: Address Zero is not allowed");
        moonshotAddress = _moonshotAddress;
    }

    function updateRouterAndPair(address _router, address _pair) public onlyOwner {
        _isExcludedFromFee[address(pyeSwapRouter)] = false;
        _isExcludedFromFee[pyeSwapPair] = false;
        pyeSwapRouter = IPYESwapRouter(_router);
        pyeSwapPair = _pair;
        WBNB = pyeSwapRouter.WETH();

        _isExcludedFromFee[address(pyeSwapRouter)] = true;
        _isExcludedFromFee[pyeSwapPair] = true;

        isBountyExempt[pyeSwapPair] = true;
        

        isTxLimitExempt[pyeSwapPair] = true;
        isTxLimitExempt[address(pyeSwapRouter)] = true;

        pairs[0] = pyeSwapPair;
        tokens[0] = WBNB;

        IPYESwapPair(pyeSwapPair).updateTotalFee(getTotalFee());
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(
            10**4
        );
    }

    //to receive BNB from pyeRouter when swapping
    receive() external payable {}

    function _getValues(uint256 tAmount) private view returns (FeeValues memory) {
        FeeValues memory values = FeeValues(
            0,
            calculateFee(tAmount, _defaultFees.reflectionFee),
            calculateFee(tAmount, _defaultFees.marketingFee),
            calculateFee(tAmount, _defaultFees.moonshotFee),
            calculateFee(tAmount, _defaultFees.buybackFee),
            calculateFee(tAmount, _defaultFees.liquifyFee)
        );

        values.transferAmount = tAmount.sub(values.reflection).sub(values.marketing).sub(values.moonshots).sub(values.buyBack).sub(values.liquify);
        return values;
    }

    function calculateFee(uint256 _amount, uint256 _fee) private pure returns (uint256) {
        if(_fee == 0) return 0;
        return _amount.mul(_fee).div(
            10**4
        );
    }

    function removeAllFee() private {
        _previousFees = _defaultFees;
        _defaultFees = _emptyFees;
    }

    function restoreAllFee() private {
        _defaultFees = _previousFees;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function getBalance(address keeper) public view returns (uint256){
        return _balances[keeper];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!isBlacklisted[to]);

        checkTxLimit(from, amount);

        if(shouldAutoBuyback(amount)){ triggerAutoBuyback(); }

        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to])
		{
            takeFee = false;
        }
		
		if(takeFee && from != pyeSwapPair && to != pyeSwapPair)
		{
		    takeFee = false;
		}
		
        //transfer amount, it will take tax
        _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee)
            removeAllFee();

        FeeValues memory _values = _getValues(amount);
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(_values.transferAmount);
        _takeFees(_values);

        if(!isBountyExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isBountyExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }
        if(!isBountyExempt[sender]){ try moonshot.setShare(sender, _balances[sender]) {} catch {} }
        if(!isBountyExempt[recipient]){ try moonshot.setShare(recipient, _balances[recipient]) {} catch {} }

        try distributor.process(distributorGas) {} catch {}
        emit Transfer(sender, recipient, _values.transferAmount);
		
        if(!takeFee)
            restoreAllFee();
    }

    function _takeFees(FeeValues memory values) private {
        _takeFee(values.reflection, address(this));
        _takeFee(values.marketing, _defaultFees.marketingAddress);
        _takeFee(values.buyBack, _burnAddress);
    }

    function _takeFee(uint256 tAmount, address recipient) private {
        if(recipient == address(0)) return;
        if(tAmount == 0) return;

        _balances[address(this)] = _balances[address(this)].add(tAmount);
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsBountyExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && holder != pyeSwapPair);
        isBountyExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldAutoBuyback(uint256 amount) internal view returns (bool) {
        return msg.sender != pyeSwapPair
        && !inSwap
        && autoBuybackEnabled
        && autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number // After N blocks from last buyback
        && IERC20(address(WBNB)).balanceOf(address(this)) >= autoBuybackAmount
        && amount >= minimumBuyBackThreshold;
    }

    function triggerAutoBuyback() internal {
        buyTokens(autoBuybackAmount, _burnAddress);
        autoBuybackBlockLast = block.number;
        autoBuybackAccumulator = autoBuybackAccumulator.add(autoBuybackAmount);
        if(autoBuybackAccumulator > autoBuybackCap){ autoBuybackEnabled = false; }
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        IERC20(WBNB).approve(address(pyeSwapRouter), amount);
        pyeSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _tTotal.sub(balanceOf(_burnAddress)).sub(balanceOf(address(0)));
    }

    function getTotalFee() internal view returns (uint256) {
        return _defaultFees.reflectionFee
            .add(_defaultFees.marketingFee)
            .add(_defaultFees.moonshotFee)
            .add(_defaultFees.buybackFee)
            .add(_defaultFees.liquifyFee);
    }

    function setAutoBuybackSettings(bool _enabled, uint256 _cap, uint256 _amount, uint256 _period) external onlyOwner {
        autoBuybackEnabled = _enabled;
        autoBuybackCap = _cap;
        autoBuybackAccumulator = 0;
        autoBuybackAmount = _amount;
        autoBuybackBlockPeriod = _period;
        autoBuybackBlockLast = block.number;
    }

    function setBuybackMultiplierSettings(uint256 numerator, uint256 denominator, uint256 length) external onlyOwner {
        require(numerator / denominator <= 2 && numerator > denominator);
        buybackMultiplierNumerator = numerator;
        buybackMultiplierDenominator = denominator;
        buybackMultiplierLength = length;
    }

    function clearBuybackMultiplier() external onlyOwner {
        buybackMultiplierTriggeredAt = 0;
    }

    function depositLPFee(uint256 amount, address token) public onlyExchange {
        uint256 tokenIndex = _getTokenIndex(token);
        if(tokenIndex < pairsLength) {
            uint256 allowanceT = IERC20(token).allowance(msg.sender, address(this));
            if(allowanceT >= amount) {
                IERC20(token).transferFrom(msg.sender, address(this), amount);

                uint256 totalFee = getTotalFee();
                uint256 marketingFeeAmount = amount.mul(_defaultFees.marketingFee).div(totalFee);
                uint256 reflectionFeeAmount = amount.mul(_defaultFees.reflectionFee).div(totalFee);
                uint256 moonshotFeeAmount = amount.mul(_defaultFees.moonshotFee).div(totalFee);
                uint256 liquifyFeeAmount = amount.mul(_defaultFees.liquifyFee).div(totalFee);

                IERC20(token).transfer(_defaultFees.marketingAddress, marketingFeeAmount);
                IERC20(token).transfer(distributorAddress, reflectionFeeAmount);
                IERC20(token).transfer(moonshotAddress, moonshotFeeAmount);
                if(liquifyFeeAmount > 0) {IERC20(token).transfer(_defaultFees.liquifyAddress, liquifyFeeAmount);}
                // try distributor.deposit() {} catch {}
            }
        }
    }

    function _getTokenIndex(address _token) internal view returns (uint256) {
        uint256 index = pairsLength + 1;
        for(uint256 i = 0; i < pairsLength; i++) {
            if(tokens[i] == _token) index = i;
        }

        return index;
    }

    function addPair(address _pair, address _token) public {
        address factory = pyeSwapRouter.factory();
        require(
            msg.sender == factory
            || msg.sender == address(pyeSwapRouter)
            || msg.sender == address(this)
        , "PYE: NOT_ALLOWED"
        );

        if(!_checkPairRegistered(_pair)) {
            _isExcludedFromFee[_pair] = true;
            isTxLimitExempt[_pair] = true;
            isBountyExempt[_pair] = true;

            pairs[pairsLength] = _pair;
            tokens[pairsLength] = _token;

            pairsLength += 1;

            IPYESwapPair(_pair).updateTotalFee(getTotalFee());
        }
    }
	
    function _checkPairRegistered(address _pair) internal view returns (bool) {
        bool isPair = false;
        for(uint i = 0; i < pairsLength; i++) {
            if(pairs[i] == _pair) isPair = true;
        }
		
        return isPair;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
         distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

	function swapTokenFromMoonshotContract(address token, uint256 amount, address to) external onlyOwner {
	    require(token != address(0) && amount != 0 && to != address(0));
        moonshot.swapToken(token, amount, to);
    }
	
    function setDistributorSettings(uint256 _gas) external onlyOwner {
        require(_gas < 750000, "PYE: TOO_HIGH_GAS_AMOUNT");
        distributorGas = _gas;
    }
	
    function rescueBNB(uint256 amount, address to) external onlyOwner{
        payable(to).transfer(amount);
    }
	
    function rescueToken(IERC20 token, uint256 amount, address to) external onlyOwner {
        if( token.balanceOf(address(this)) < amount ) {
            amount = token.balanceOf(address(this));
        }
        token.transfer(to, amount);
    }
	
	function updateMoonshotAddress(address payable newAddress) public onlyOwner {
        require(newAddress != address(moonshot), "The moonshot already has that address");

        MoonshotMechanism newMoonshot = MoonshotMechanism(newAddress);
        moonshot = newMoonshot;

        isTxLimitExempt[newAddress] = true;
        isBountyExempt[newAddress] = true;

        moonshotAddress = newAddress;
    }
    
	function updateRewardDistributorAddress(address payable newAddress) public onlyOwner {
        require(newAddress != address(distributorAddress), "The moonshot already has that address");
		
        RewardDistributor newDistributor = RewardDistributor(newAddress);
        distributor = newDistributor;
        
        isTxLimitExempt[newAddress] = true;
        isBountyExempt[newAddress] = true;

        distributorAddress = newAddress;
    }
}