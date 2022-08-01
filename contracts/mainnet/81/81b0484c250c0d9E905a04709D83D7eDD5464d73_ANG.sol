/**
 *Submitted for verification at BscScan.com on 2022-08-01
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
interface ANGTOOL{
    function bind( address parent ) external returns (bool);
    function bindforce(address son, address parent ) external returns (bool);
    function parent1(address son) external view returns (address);
    function parent2(address son) external view returns (address);
    function parent3(address son) external view returns (address);
    function parent4(address son) external view returns (address);
    function parent5(address son) external view returns (address);
    function parent6(address son) external view returns (address);
    function parent7(address son) external view returns (address);
    function parent8(address son) external view returns (address);
    function parent9(address son) external view returns (address);
    function parent10(address son) external view returns (address);
    function parent11(address son) external view returns (address);
    function parent12(address son) external view returns (address);
    function parent13(address son) external view returns (address);
    function parent14(address son) external view returns (address);
    function parent15(address son) external view returns (address);
    
}
contract ANG is IERC20,Ownable {
    using SafeMath for uint256;

    uint8 private transferFeeOnOff=1; // 1 fee 2 nofee
    uint8 private buyOnOff=1;
    uint8 private sellOnOff=1;

    bool private swapping;

    uint8 public sellPartnerFee = 7;
    uint8 public sellDeadFee = 2;
    uint8 public sellAngelFee = 2;
    uint8 public sellUnionFee = 2;

    address public walletDead = 0x000000000000000000000000000000000000dEaD;
    address public walletAngel = 0x0203D0E5F9c5c53438332aE437491386763F7B8b;
    address public walletUnion = 0x5557E01f513C6499A01Ab7feB47c5afc85bD795e;
    address public walletPoolAngel = 0x2CAE731334075E71D90e4bD88aF3d70091F6aA85;
    address public walletFinance = 0xAB9FD3f49A4D59FDbe1BbEa30637F5A524d4D85d;

    ANGTOOL angtool;

    address public uniswapV2Pair;
    IUniswapV2Router02 uniswapV2Router;

    uint256 public dayseconds = 86400;//86400
    uint256[] public dailyRates = new uint256[](16);
    mapping(address => uint256) public userKeepStartTime;
    mapping(address => uint256) public userDailyProfit;//which day already profited

    uint256 public partnerPool;
    uint256 public partnerPoolAmountToProfit = 100;
    address[] public partnerList;
    uint256 public partnerShares;//how many shares , 1 + 2 + 4
    mapping(address => uint256) public partnerLevel; //1 , 2 , 4
    mapping(uint256 => bool) public partnerDailyProfit;//which day already profited

    address public contractUSDT;//test 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 main 0x55d398326f99059fF775485246999027B3197955

    //router test 0x9ac64cc6e4415144c455bd8e4837fea55603e5c3 main 0x10ED43C718714eb63d5aA57B78B54704E256024E
    //angtool test 0xAbbE18E3afe64232cf93e8A6CA156F63e53aaD29 main 0xb5c67Fe67A9c1B85425Ec4258b9B8962728F588A
    constructor(address ROUTER, address USDT, address ANGTOOL_){
        _decimals = 9;
        _symbol = "ANG";
        _name = "ANG";
        _totalSupply = 2021800 * (10**_decimals);

        partnerShares = partnerShares * (10**_decimals);

        angtool = ANGTOOL(ANGTOOL_);

        _creator = _msgSender();

        contractUSDT = USDT;
 
        uniswapV2Router = IUniswapV2Router02(ROUTER);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(contractUSDT, address(this));

        emit Transfer(address(0), address(_creator), _totalSupply);
        _balances[address(_creator)] = _totalSupply;

        dailyRates[0] = 0;
        dailyRates[1] = 1011;//0.011
        dailyRates[2] = 1012;
        dailyRates[3] = 1013;
        dailyRates[4] = 1014;
        dailyRates[5] = 1015;
        dailyRates[6] = 1016;
        dailyRates[7] = 1017;
        dailyRates[8] = 1018;
        dailyRates[9] = 1019;
        dailyRates[10] = 1020;
        dailyRates[11] = 1021;
        dailyRates[12] = 1022;
        dailyRates[13] = 1023;
        dailyRates[14] = 1024;
        dailyRates[15] = 1025;//0.025
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


    function profiting(address user)internal returns (uint256){
        uint256 profit = 0;
        uint256 today = block.timestamp.div(dayseconds);

        if(userKeepStartTime[user] == 0){
            resetRate(user);
        }

        if(user == address(uniswapV2Pair)) return 0;

        // if(_balances[user] < 11*(10**_decimals) ) return 0;

        //first time
        if(userDailyProfit[user] == 0){
            userDailyProfit[user] = today;
        }

        if(
            userDailyProfit[user] < today 
            && getRate(user) > 0
            && _balances[user] > 11*(10**_decimals) 
        ){
            uint256 daydiff = today - userDailyProfit[user];

            profit = (_balances[user]*(getRate(user)**daydiff)).div(1000**daydiff).sub(_balances[user]);

            if(profit>0)
            updateBalance( user, profit);

            userDailyProfit[user] = today;
        }


        return profit;
    }
    function updateBalance(address user,uint256 profit)internal{
        _balances[user] += profit;
        _totalSupply += profit;

    }
    function getRate(address user)public view returns (uint256){

        uint256 keepdays = (block.timestamp-userKeepStartTime[user]).div(dayseconds);

        if(keepdays>=15){
            return dailyRates[15];//11=0.
        }
        return dailyRates[keepdays];
    }
    function resetRate(address user)internal {
        userKeepStartTime[user] = block.timestamp;
    }


    function setPartner1(address partner) external onlyOwner{
        partnerList.push(partner);
        partnerLevel[partner] = 1;
        partnerShares = partnerShares+1;
    }
    function setPartner2(address partner) external onlyOwner{
        partnerList.push(partner);
        partnerLevel[partner] = 2;
        partnerShares = partnerShares+2;
    }
    function setPartner4(address partner) external onlyOwner{
        partnerList.push(partner);
        partnerLevel[partner] = 4;
        partnerShares = partnerShares+4;
    }
    function profitPartner()public{
        uint256 today = block.timestamp.div(dayseconds);

        if(partnerDailyProfit[today] == true) return;

        if(partnerPool < partnerPoolAmountToProfit) return;

        if(partnerShares == 0) return;

        uint256 eachshareprofit = partnerPool.div(partnerShares);

        if(_balances[address(this)] < eachshareprofit) return;

        uint256 iterations = 0;
        uint256 partnerCount = partnerList.length;	
        while(iterations < partnerCount) {
            uint256 myprofit = eachshareprofit * partnerLevel[partnerList[iterations]];

            if(myprofit > partnerPool) return;
            if(_balances[address(this)] < myprofit) return;

            doTransfer(address(this), partnerList[iterations], myprofit);
            partnerPool = partnerPool.sub(myprofit);

            iterations++;
        }

        partnerDailyProfit[today] = true;
    }
    function setPartnerPoolAmountToProfit(uint256 num)external onlyOwner{
        partnerPoolAmountToProfit = num;
    }

    
    function setDayseconds(uint256 num) external onlyOwner returns (uint256){
        dayseconds = num;
        return dayseconds;
    }

    function setSellDeadFee(uint8 num) external onlyOwner returns (uint8){
        sellDeadFee = num;
        return sellDeadFee;
    }
    function setSellPartnerFee(uint8 num) external onlyOwner returns (uint8){
        sellPartnerFee = num;
        return sellPartnerFee;
    }
    function setSellAngelFee(uint8 num) external onlyOwner returns (uint8){
        sellAngelFee = num;
        return sellAngelFee;
    }
    function setSellUnionFee(uint8 num) external onlyOwner returns (uint8){
        sellUnionFee = num;
        return sellUnionFee;
    }
    
    function setWalletDead(address add) external onlyOwner returns (address){
        walletDead = add;
        return walletDead;
    }
    function setWalletAngel(address add) external onlyOwner returns (address){
        walletAngel = add;
        return walletAngel;
    }
    function setWalletUnion(address add) external onlyOwner returns (address){
        walletUnion = add;
        return walletUnion;
    }
    function setWalletPoolAngel(address add) external onlyOwner returns (address){
        walletPoolAngel = add;
        return walletPoolAngel;
    }

    function setTransferFeeOnOff(uint8 oneortwo) external onlyOwner returns (uint8){
        transferFeeOnOff = oneortwo;
        return transferFeeOnOff;
    }
    function setBuyOnOff(uint8 oneortwo) external onlyOwner returns (uint8){
        buyOnOff = oneortwo;
        return buyOnOff;
    }
    function setSellOnOff(uint8 oneortwo) external onlyOwner returns (uint8){
        sellOnOff = oneortwo;
        return sellOnOff;
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

        //buy
        if(from == uniswapV2Pair){
            
            uint256 feeBuy = amount.mul(26).div(200);//13%
            amountAfter = amountAfter.sub(feeBuy);

            if(address(angtool.parent1(recipient)) != address(0)){
                feeBuy = feeBuy.sub(amount.mul(4).div(100));//4%
                doTransfer(from, address(angtool.parent1(recipient)), amount.mul(4).div(100));
                if(address(angtool.parent2(recipient)) != address(0)){
                    feeBuy = feeBuy.sub(amount.mul(5).div(200));//2.5%
                    doTransfer(from, address(angtool.parent2(recipient)), amount.mul(5).div(200));
                    if(address(angtool.parent3(recipient)) != address(0)){
                        feeBuy = feeBuy.sub(amount.div(200));//0.5%
                        doTransfer(from, address(angtool.parent3(recipient)), amount.div(200));
                        if(address(angtool.parent4(recipient)) != address(0)){
                            feeBuy = feeBuy.sub(amount.div(200));//0.5%
                            doTransfer(from, address(angtool.parent4(recipient)), amount.div(200));
                            if(address(angtool.parent5(recipient)) != address(0)){
                                feeBuy = feeBuy.sub(amount.div(200));//0.5%
                                doTransfer(from, address(angtool.parent5(recipient)), amount.div(200));
                                if(address(angtool.parent6(recipient)) != address(0)){
                                    feeBuy = feeBuy.sub(amount.div(200));//0.5%
                                    doTransfer(from, address(angtool.parent6(recipient)), amount.div(200));
                                    if(address(angtool.parent7(recipient)) != address(0)){
                                        feeBuy = feeBuy.sub(amount.div(200));//0.5%
                                        doTransfer(from, address(angtool.parent7(recipient)), amount.div(200));
                                        if(address(angtool.parent8(recipient)) != address(0)){
                                            feeBuy = feeBuy.sub(amount.div(200));//0.5%
                                            doTransfer(from, address(angtool.parent8(recipient)), amount.div(200));
                                            if(address(angtool.parent9(recipient)) != address(0)){
                                                feeBuy = feeBuy.sub(amount.div(200));//0.5%
                                                doTransfer(from, address(angtool.parent9(recipient)), amount.div(200));
                                                if(address(angtool.parent10(recipient)) != address(0)){
                                                    feeBuy = feeBuy.sub(amount.div(200));//0.5%
                                                    doTransfer(from, address(angtool.parent10(recipient)), amount.div(200));
                                                    if(address(angtool.parent11(recipient)) != address(0)){
                                                        feeBuy = feeBuy.sub(amount.div(200));//0.5%
                                                        doTransfer(from, address(angtool.parent11(recipient)), amount.div(200));
                                                        if(address(angtool.parent12(recipient)) != address(0)){
                                                            feeBuy = feeBuy.sub(amount.div(200));//0.5%
                                                            doTransfer(from, address(angtool.parent12(recipient)), amount.div(200));
                                                            if(address(angtool.parent13(recipient)) != address(0)){
                                                                feeBuy = feeBuy.sub(amount.div(200));//0.5%
                                                                doTransfer(from, address(angtool.parent13(recipient)), amount.div(200));
                                                                if(address(angtool.parent14(recipient)) != address(0)){
                                                                    feeBuy = feeBuy.sub(amount.div(200));//0.5%
                                                                    doTransfer(from, address(angtool.parent14(recipient)), amount.div(200));
                                                                    if(address(angtool.parent15(recipient)) != address(0)){
                                                                        feeBuy = feeBuy.sub(amount.div(200));//0.5%
                                                                        doTransfer(from, address(angtool.parent15(recipient)), amount.div(200));
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if(feeBuy>0)
                doTransfer(from, walletUnion, feeBuy);

        }
        //sell
        if(recipient == uniswapV2Pair){
            uint256 FeeDead = amount.mul(sellDeadFee).div(100);
            uint256 FeePartner = amount.mul(sellPartnerFee).div(100);
            uint256 FeeAngel = amount.mul(sellAngelFee).div(100);
            uint256 FeeUnion = amount.mul(sellUnionFee).div(100);

            amountAfter = amountAfter.sub(FeeDead);
            if(FeeDead > 0) doTransfer(from, walletDead, FeeDead);

            amountAfter = amountAfter.sub(FeePartner);
            if(FeePartner > 0) doTransfer(from, address(this), FeePartner);
            partnerPool = partnerPool + FeePartner;

            amountAfter = amountAfter.sub(FeeAngel);
            if(FeeAngel > 0) doTransfer(from, walletAngel, FeeAngel);

            amountAfter = amountAfter.sub(FeeUnion);
            if(FeeUnion > 0) doTransfer(from, walletUnion, FeeUnion);
        }

        uint256 FeePool = amount.mul(3).div(200);//1.5% angel pool
        amountAfter = amountAfter.sub(FeePool);
        if(FeePool > 0) doTransfer(from, walletPoolAngel, FeePool);

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
            || from == walletDead
            || recipient == walletDead
            || from == walletAngel
            || recipient == walletAngel
            || from == walletUnion
            || recipient == walletUnion
            || from == walletPoolAngel
            || recipient == walletPoolAngel
            || from == walletFinance
            || recipient == walletFinance
        ){
            
        }else{

            //LP/swap 
            if(from == uniswapV2Pair || recipient == uniswapV2Pair){

                if(!swapping) {
                    swapping = true;
                    //buy
                    if(from == uniswapV2Pair){
                        profiting(recipient);
                    }
                    //sell
                    if(recipient == uniswapV2Pair){
                        
                        profiting(from);
                        resetRate(from);
                    }
                    swapping = false;
                }

                if(!swapping) {
                    swapping = true;
                    //sell
                    if(recipient == uniswapV2Pair){
                        profitPartner();
                    }
                    swapping = false;
                }

                if(!swapping) {
                    swapping = true;
                    amount = takeAllFee( from,recipient,  amount);
                    swapping = false;
                }
            }else{

                uint256 feeTrans = amount.mul(29).div(200);//14.5%
                doTransfer(from, walletUnion, feeTrans);
                amount = amount.sub(feeTrans);

                //normal transfer
                resetRate(from);
            }


        }

        doTransfer(from, recipient, amount);



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