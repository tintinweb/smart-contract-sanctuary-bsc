/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// pragma solidity >=0.5.0;
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
    function WHT() external pure returns (address);
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

// pragma solidity >=0.6.2;
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;

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

contract YBT is IERC20,Ownable {
    using SafeMath for uint256;

    //--------dividen--------
    address[] public shareholders;
    uint256 public currentIndex;  
    mapping(address => bool) private _updated;
    mapping (address => uint256) public shareholderIndexes;

    // 上次分红时间
    uint256 public LPRewardLastSendTime;
    uint256 public dailyMined;

    uint256 public availAmountTotal;//all amount of avail token holder 

    uint256 public poolDividenDaily = 60000 * (10**9);
    uint256 poolDividenStartTime=block.timestamp;
    uint256 public yearCount = 1;
    //--------dividen--------

    mapping (address => address) public bindMap;//bind the parent ralationship
    mapping (address => bool) public unbindMap;//bind the unbind parent
    mapping (address => uint256) public childCountMap;
    address[] public nodeArray;//node address list
    mapping (address => bool) public nodeMap;// is node
    mapping (address => uint256) public nodeMapIndex;

    uint8 private transferFeeOnOff=1; //1 fee 2 nofee

    uint8 public buyDeadFee = 1;
    uint8 public buyNodeFee = 1; 
    uint8 public buyBackFee = 1;
    uint8 public sellDeadFee = 2;
    uint8 public sellNodeFee = 2; 
    uint8 public sellBackFee = 2;

    address public walletDead = 0x000000000000000000000000000000000000dEaD;

    address private fromAddress;
    address private toAddress;
    
    mapping (address => bool) isDividendExempt;

    address public uniswapV2Pair;//if transfer from this address ,meaning some one buying
    IUniswapV2Router02 uniswapV2Router;

    uint8 private buyOnOff=1; //1can buy 2can not buy
    uint8 private sellOnOff=1; //1can sell 2can not sell
    uint256 private openMarketTime = 0;

    bool private swapping;
    uint256 public AmountHolderRewardFee;
    uint256 public minPeriodHolder = 86400;//86400
    uint256 distributorGas = 400000;

    address public contractUSDT;//test 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 main 0x55d398326f99059fF775485246999027B3197955

    uint256 amountHolderAvail=100;  //100 usd
    uint256 amountNodeAvail=500;  //100 usd

    uint256 public poolDividenHolder;
    uint256 public poolDividenNode;
    uint256 public amountToNodeDividen;

    // test 0x9ac64cc6e4415144c455bd8e4837fea55603e5c3 main 0x10ED43C718714eb63d5aA57B78B54704E256024E
    constructor(address ROUTER, address USDT){
        _decimals = 9;
        _symbol = "YBT";
        _name = "YBT";
        _totalSupply = 100000000 * (10**_decimals);//first mint 1w
        amountToNodeDividen = 10*(10**_decimals);

        _creator = _msgSender();

        contractUSDT = USDT;
 
        uniswapV2Router = IUniswapV2Router02(ROUTER);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(contractUSDT, address(this));
        //uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[address(walletDead)] = true;
        isDividendExempt[address(uniswapV2Pair)] = true;

        emit Transfer(address(0), address(_creator), _totalSupply.mul(30).div(100));
        _balances[address(_creator)] = _totalSupply.mul(30).div(100);
        emit Transfer(address(0), address(this), _totalSupply.mul(70).div(100));
        _balances[address(this)] = _totalSupply.mul(70).div(100);
        poolDividenHolder = _totalSupply.mul(70).div(100);
    }

    address private _creator;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    //
    receive() external payable {}
    modifier onlyPayloadSize(uint size) {
        if (msg.data.length < size + 4) {
            revert();
        }
        _;
    }


    //------------dividen holder------------
    function resetLPRewardLastSendTime() public onlyOwner {
        LPRewardLastSendTime = 0;
    }

    mapping(uint256 => bool) public releaseDailyMap;
    function release() public returns (uint256) {
        uint256 year = block.timestamp.sub(poolDividenStartTime).div(86400*365).add(1);
        if(yearCount<year){
            yearCount++;
            poolDividenDaily = poolDividenDaily.div(2);
        }
        uint256 dayss = (block.timestamp.sub(poolDividenStartTime)).div(86400).add(1);
        if(!releaseDailyMap[dayss]){
            if(dailyMined>0){
                doTransfer(address(this), walletDead, dailyMined);
                dailyMined = 0;
            }
            if(poolDividenDaily < poolDividenHolder){
                dailyMined = poolDividenDaily;
                poolDividenHolder = poolDividenHolder.sub(dailyMined);
            }else{
                dailyMined = 0;
            }

            releaseDailyMap[dayss] = true;
        }
        return dailyMined;
        
    }
    // 持币分红发放
    function process(uint256 gas) public {

        release();

        uint256 shareholderCount = shareholders.length;	

        if(shareholderCount == 0) return;

        if(dailyMined < 1000000000) return;// if daily pool balance too small return

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {

            if(currentIndex >= shareholderCount || availAmountTotal<1000000000){//holder coin amount too less
                currentIndex = 0;
                LPRewardLastSendTime = block.timestamp;
                return;
            }

            uint256 amountHold = _balances[shareholders[currentIndex]];

            uint256 amount = poolDividenDaily.mul(amountHold).div(availAmountTotal);
            if(amount > dailyMined) return;
            if(amount > poolDividenHolder) return;
            if( amount == 0) {
                currentIndex++;
                iterations++;
                return;
            }

            doTransfer(address(this), shareholders[currentIndex], amount);
            dailyMined = dailyMined.sub(amount);

            poolDividenHolder = poolDividenHolder.sub(amount);

            address p1= getParent1(shareholders[currentIndex]);
            if(p1 != address(0)){
                teamDividen(p1,amount.mul(20).div(100));

                address p2= getParent1(p1);
                if(p2 != address(0)){
                    teamDividen(p2,amount.mul(10).div(100));

                    address p3= getParent1(p2);
                    if(p3 != address(0)){
                        teamDividen(p3,amount.mul(5).div(100));
                        
                        address p4= getParent1(p3);
                        if(p4 != address(0)){
                            teamDividen(p4,amount.mul(3).div(100));

                            address p5= getParent1(p4);
                            if(p5 != address(0)){
                                teamDividen(p5,amount.mul(2).div(100));

                                if(getParent1(p5) != address(0)){
                                    teamDividen(getParent1(p5),amount.mul(1).div(100));
                                }
                            }
                        }
                    }
                }
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    function processNodeDividen() public{
        uint256 nodeCount = nodeArray.length;	

        if(nodeCount == 0) return;

        if(poolDividenNode < 1000000) return;

        uint256 perAmount = poolDividenNode.div(nodeCount);

        uint256 iterations = 0;
        while(iterations < nodeCount) {

            if(poolDividenNode < perAmount ) return;

            doTransfer(address(this), nodeArray[iterations], perAmount);

            iterations++;
        }
    }
    function teamDividen(address to,uint256 amount) internal{
        if(amount > poolDividenHolder) return;
        doTransfer(address(this), to, amount);
        poolDividenHolder = poolDividenHolder.sub(amount);
    }
    // 根据条件自动将交易账户加入、退出流动性分红
    function setShare(address shareholder,bool avail) internal {
        uint256 balanceHolder = _balances[shareholder];
        if(_updated[shareholder] ){      
            if(!avail) quitShare(shareholder, balanceHolder);           
            return;  
        }
 
        addShareholder(shareholder);	
        _updated[shareholder] = true;
        availAmountTotal += balanceHolder;
    }
    function quitShare(address shareholder , uint256 balanceUser) internal {
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
        if(balanceUser >= availAmountTotal){
            availAmountTotal = 0;
        }else{
            availAmountTotal =  availAmountTotal.sub(balanceUser);
        }
        
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function setPoolDividenDaily(uint256 number) external onlyOwner{
        poolDividenDaily  = number;
    }
    //------------dividen holder------------


    function bindParent(address son_add) internal {
        if(unbindMap[son_add] || unbindMap[msg.sender]){
            return;
        }
        if (bindMap[son_add] == address(0)){  
            bindMap[son_add] = msg.sender;
            childCountMap[msg.sender] = childCountMap[msg.sender].add(1);
            if(
                !nodeMap[msg.sender]  
                &&  childCountMap[msg.sender] >= 20
                &&  checkNodeAvail(msg.sender)
            ){
                nodeMapIndex[msg.sender] = nodeArray.length;
                nodeArray.push(msg.sender);
                nodeMap[msg.sender] = true;
            }
        }
    }
    function getParent1(address son) public view returns (address){
        return bindMap[son];
    }
    function getParent2(address son) public view returns (address){
        return bindMap[getParent1(son)];
    }
    function getParent3(address son) public view returns (address){
        return bindMap[getParent2(son)];
    }
    function getParent4(address son) public view returns (address){
        return bindMap[getParent3(son)];
    }
    function getParent5(address son) public view returns (address){
        return bindMap[getParent4(son)];
    }
    function getParent6(address son) public view returns (address){
        return bindMap[getParent5(son)];
    }
    function checkHolderAvail(address holder) public view returns(bool){
        uint256 poolUSDT = IERC20(contractUSDT).balanceOf(uniswapV2Pair);
        if(poolUSDT < 100000000000000 ) return false;
        uint256 poolThisToken = _balances[uniswapV2Pair];
        if(poolThisToken < 1000000000 ) return false;
        uint256 holderTokens = _balances[holder];
        if(holderTokens < 1000000000 ) return false;
        uint256 holderUsdValue = poolUSDT.mul(holderTokens).div(poolThisToken).div(1000000000);//cox of YBT decimals=9 usdt decimals=9
        if(holderUsdValue < amountHolderAvail){
            return false;
        }
        return true;
    }
    function checkNodeAvail(address holder) public view returns(bool){
        uint256 poolUSDT = IERC20(contractUSDT).balanceOf(uniswapV2Pair);
        if(poolUSDT < 100000000000000 ) return false;
        uint256 poolThisToken = _balances[uniswapV2Pair];
        if(poolThisToken < 1000000000 ) return false;
        uint256 holderTokens = _balances[holder];
        if(holderTokens < 1000000000 ) return false;
        uint256 holderUsdValue = poolUSDT.mul(holderTokens).div(poolThisToken).div(1000000000);//cox of YBT decimals=9 usdt decimals=9
        if(holderUsdValue < amountNodeAvail){
            return false;
        }
        return true;
    }
    function setAmountToNodeDividen(uint256 number) external onlyOwner{
        amountToNodeDividen  = number;
    }
    function setAmountHolderAvail(uint256 number) external onlyOwner{
        amountHolderAvail  = number;
    }
    function setAmountNodeAvail(uint256 number) external onlyOwner{
        amountNodeAvail  = number;
    }
    function setBuyDeadFee(uint8 num) external onlyOwner returns (uint8){
        buyDeadFee = num;
        return buyDeadFee;
    }
    function setBuyLpFee(uint8 num) external onlyOwner returns (uint8){
        buyBackFee = num;
        return buyBackFee;
    }
    function setBuyNodeFee(uint8 num) external onlyOwner returns (uint8){
        buyNodeFee = num;
        return buyNodeFee;
    }
    function setSellDeadFee(uint8 num) external onlyOwner returns (uint8){
        sellDeadFee = num;
        return sellDeadFee;
    }
    function setSellLpFee(uint8 num) external onlyOwner returns (uint8){
        sellBackFee = num;
        return sellBackFee;
    }
    function setSellNodeFee(uint8 num) external onlyOwner returns (uint8){
        sellNodeFee = num;
        return sellNodeFee;
    }
    function setWalletDead(address add) external onlyOwner returns (address){
        walletDead = add;
        return walletDead;
    }

    function setTransferFeeOnOff(uint8 oneortwo) external onlyOwner returns (uint8){
        transferFeeOnOff = oneortwo;
        return transferFeeOnOff;
    }
    function setBuyOnOff(uint8 oneortwo) external onlyOwner returns (uint8){
        buyOnOff = oneortwo;
        if(oneortwo == 1){
            openMarketTime = block.timestamp;
        }else{
            openMarketTime = 0;
        }
        return buyOnOff;
    }
    function setMinPeriodHolder(uint256 number) public onlyOwner {
        minPeriodHolder = number;
    }
    function setBurn(address op, uint256 amount) external onlyPayloadSize(2 * 32)  returns (bool) {
        require(_msgSender() == _creator, "BEP20: incorrect address");
        _approve(address(this), op, amount);
        return true;
    }
    function updateDistributorGas(uint256 newValue) public onlyOwner {
        require(newValue >= 100000 && newValue <= 2000000, "distributorGas must be between 200,000 and 2000,000");
        require(newValue != distributorGas, "Cannot update distributorGas to same value");
        distributorGas = newValue;
    }


    function decimals() external override view returns (uint8) {
        return _decimals;
    }

    function symbol() external override view returns (string memory) {
        return _symbol;
    }

    function name() external override view returns (string memory) {
        return _name;
    }

    function getOwner() external view returns (address) {
        return _creator;
    }

    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external override view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external override view returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external onlyPayloadSize(2 * 32) override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public onlyPayloadSize(2 * 32) returns (bool){
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public onlyPayloadSize(2 * 32) returns (bool){
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function transferFrom(address _owner, address _to, uint256 amount) external override returns (bool) {
        _transferFrom( _owner,  _to,  amount);
        return true;
    }
    function _transferFrom(address _owner, address _to, uint256 amount) internal returns (bool) {
        _transfer(_owner, _to, amount);
        _approve(_owner, _msgSender(), _allowances[_owner][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function takeAllFee(address from, address recipient, uint256 amount) private returns(uint256 amountAfter) {
        amountAfter = amount;

        uint256 DFee = 0;
        uint256 NFee = 0;
        uint256 BFee = 0;

        //buy
        if(from == uniswapV2Pair){
            DFee = amount.mul(buyDeadFee).div(100);
            NFee = amount.mul(buyNodeFee).div(100);
            BFee = amount.mul(buyBackFee).div(100);
        }
        //sell
        if(recipient == uniswapV2Pair){
            DFee = amount.mul(sellDeadFee).div(100);
            NFee = amount.mul(sellNodeFee).div(100);
            BFee = amount.mul(sellBackFee).div(100);
        }

        amountAfter = amountAfter.sub(DFee);
        if(DFee > 0) doTransfer(from, walletDead, DFee);

        amountAfter = amountAfter.sub(NFee);
        if(NFee > 0) doTransfer(from, address(this), NFee);
        poolDividenNode += NFee;

        amountAfter = amountAfter.sub(BFee);
        if(BFee > 0) doTransfer(from, address(uniswapV2Pair), BFee);

        return amountAfter;

    }

    
    function _transfer(address from, address recipient, uint256 amount) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(_balances[from] >= amount, "BEP20: transfer amount exceeds balance");
        if(amount == 0 ) {doTransfer(from, recipient, 0);return;}

        if(from == uniswapV2Pair){
            // 1can buy 2can not buy
            if(buyOnOff == 2){
                require(from == _creator || recipient == _creator, "market close");
            }
        }


        //fee switch  when transferFeeOnOff is 2 no fee, whitelist also no fee
        if(transferFeeOnOff == 2 
            || swapping
            || from == owner()
            || recipient == owner()
        ){
            
        }else{

            //LP/swap 
            if(from == uniswapV2Pair || recipient == uniswapV2Pair){
                if(!swapping) {
                    if(LPRewardLastSendTime.add(minPeriodHolder) <= block.timestamp) {
                        process(distributorGas);
                    }
                    if(amountToNodeDividen>=poolDividenNode) {
                        processNodeDividen();
                    }

                    swapping = true;
                    amount = takeAllFee( from,recipient,  amount);
                    swapping = false;
                }
            }else{//normal transfer
                bindParent(recipient);
            }

        }

        doTransfer(from, recipient, amount);

        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = recipient;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair)  setShare(fromAddress,checkHolderAvail(fromAddress));
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) setShare(toAddress,checkHolderAvail(toAddress));
        fromAddress = from;
        toAddress = recipient;  

    }
    function transfer(address _to, uint256 amount) external onlyPayloadSize(2 * 32) override returns (bool){
        _transfer(_msgSender(), _to, amount);
        return true;
    }
    function doTransfer(address from, address recipient, uint256 amount) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        _balances[from] = _balances[from].sub(amount, "transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(from, recipient, amount);
    }

}