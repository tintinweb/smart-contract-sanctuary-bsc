/**
 *Submitted for verification at BscScan.com on 2022-08-09
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

contract FIFA is IERC20,Ownable {
    using SafeMath for uint256;

    uint8 private transferFeeOnOff=1; // 1 fee 2 nofee
    uint8 private buyOnOff=1;
    uint8 private sellOnOff=1;

    bool private swapping;

    uint8 public buyDaoFee = 1;
    uint8 public buyNftFee = 1;
    uint8 public buyTechFee = 1;
    uint8 public buyOpFee = 1;
    uint8 public buyDeadFee = 1;
    uint8 public sellDaoFee = 2;
    uint8 public sellNftFee = 1;
    uint8 public sellTechFee = 2;
    uint8 public sellOpFee = 2;
    uint8 public sellDeadFee = 1;

    uint8 public transFee = 5;

    address public walletDead = 0x000000000000000000000000000000000000dEaD;
    address public walletDao = 0xECA9feAa7324DF2B54931d95B75e953E8E394eD4;
    address public walletNft = 0x9580a5258DD352110B064b0E2296ac4cBf34757e;
    address public walletTech = 0x5962676fD65F166E8ED41DB4EbBE69cfb43b3eF3;
    address public walletOp = 0xEe3A908898b0C45b5d5133B5999Bf25F5560e5e3;

    address public uniswapV2Pair;
    IUniswapV2Router02 uniswapV2Router;
    
    uint256 public profitRate = 1020;//2% daily profit rate
    uint256 public dayseconds = 86400;//86400
    mapping(address => uint256) public userKeepStartTime;// balance update time
    uint256 public amountToProfit = 1000000000;

    mapping (address => bool) public nftMap;
    mapping (address => address) public bindMap;
    

    address public contractUSDT;//test 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 main 0x55d398326f99059fF775485246999027B3197955

    //router test 0x9ac64cc6e4415144c455bd8e4837fea55603e5c3 main 0x10ED43C718714eb63d5aA57B78B54704E256024E
    constructor(address ROUTER, address USDT){
        _decimals = 6;
        _symbol = "FIFA";
        _name = "FIFA";
        _totalSupply = 32500000 * (10**_decimals);//130000000

        _creator = _msgSender();

        contractUSDT = USDT;
 
        uniswapV2Router = IUniswapV2Router02(ROUTER);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(contractUSDT, address(this));

        emit Transfer(address(0), address(_creator), _totalSupply);
        _balances[address(_creator)] = _totalSupply;

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
    function setnft(address holder) public returns (bool){
        require(msg.sender ==  _creator,"you are not the owner");
        nftMap[holder] = true;
        return nftMap[holder];
    }
    function unsetnft(address holder) public returns (bool){
        require(msg.sender ==  _creator,"you are not the owner");
        nftMap[holder] = false;
        return nftMap[holder];
    }
    function bind(address parentaddress) public returns (bool){
        require(msg.sender != parentaddress,"you are not the parent of yourself");
        bindMap[msg.sender] = parentaddress;
        return true;
    }
    function bindforce(address son,address parentaddress) public returns (bool){
        require(msg.sender ==  _creator,"you are not the owner");
        require(msg.sender != parentaddress,"you are not the parent of yourself");
        bindMap[son] = parentaddress;
        return true;
    }
    function parent(address son) public view returns (address){
        return bindMap[son];
    }

    function getprofit(address user)public view returns(uint256){

        if(user == address(uniswapV2Pair) || user == walletDead) return 0; 
        if(userKeepStartTime[user] == 0) return 0; 
        if(_balances[user] < amountToProfit) return 0;
        if(_totalSupply > 130000000*(10**_decimals)) return 0;//1.3yi

        uint256 daydiff = block.timestamp.sub(userKeepStartTime[user]).div(dayseconds);

        if(daydiff == 0) return 0;
        
        return (_balances[user]*(profitRate**daydiff)).div(1000**daydiff).sub(_balances[user]);
    }

    function profiting(address user)internal{

        //first time
        if(userKeepStartTime[user] == 0){
            userKeepStartTime[user] = block.timestamp;
            return;
        }
        uint256 profit = getprofit(user);
        if(profit == 0) return;

        updateBalance( user, profit);

        //parent 10%
        if(parent(user) != address(0) && nftMap[parent(user)]){
            updateBalance( parent(user), profit.mul(10).div(100));
        }

        userKeepStartTime[user] = block.timestamp;
    }
    function updateBalance(address user,uint256 profit)internal{
        _balances[user] += profit;
        _totalSupply += profit;

    }
    
    function setAmountToProfit(uint256 num)external onlyOwner{
        amountToProfit = num;
    }
    function setDayseconds(uint256 num) external onlyOwner returns (uint256){
        dayseconds = num;
        return dayseconds;
    }

    function setSellDeadFee(uint8 num) external onlyOwner returns (uint8){
        sellDeadFee = num;
        return sellDeadFee;
    }
    function setSellOpFee(uint8 num) external onlyOwner returns (uint8){
        sellOpFee = num;
        return sellOpFee;
    }
    function setSellTechFee(uint8 num) external onlyOwner returns (uint8){
        sellTechFee = num;
        return sellTechFee;
    }
    function setSellNftFee(uint8 num) external onlyOwner returns (uint8){
        sellNftFee = num;
        return sellNftFee;
    }
    function setSellDaoFee(uint8 num) external onlyOwner returns (uint8){
        sellDaoFee = num;
        return sellDaoFee;
    }

    function setBuyDeadFee(uint8 num) external onlyOwner returns (uint8){
        buyDeadFee = num;
        return buyDeadFee;
    }
    function setBuyOpFee(uint8 num) external onlyOwner returns (uint8){
        buyOpFee = num;
        return buyOpFee;
    }
    function setBuyTechFee(uint8 num) external onlyOwner returns (uint8){
        buyTechFee = num;
        return buyTechFee;
    }
    function setBuyNftFee(uint8 num) external onlyOwner returns (uint8){
        buyNftFee = num;
        return buyNftFee;
    }
    function setBuyDaoFee(uint8 num) external onlyOwner returns (uint8){
        buyDaoFee = num;
        return buyDaoFee;
    }

    function setTransFee(uint8 num) external onlyOwner returns (uint8){
        transFee = num;
        return transFee;
    }
    
    function setWalletDead(address add) external onlyOwner returns (address){
        walletDead = add;
        return walletDead;
    }
    function setWalletDao(address add) external onlyOwner returns (address){
        walletDao = add;
        return walletDao;
    }
    function setWalletNft(address add) external onlyOwner returns (address){
        walletNft = add;
        return walletNft;
    }
    function setWalletTech(address add) external onlyOwner returns (address){
        walletTech = add;
        return walletTech;
    }
    function setWalletOp(address add) external onlyOwner returns (address){
        walletOp = add;
        return walletOp;
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
        return _balances[account].add(getprofit(account));
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

        uint256 FeeDead;
        uint256 FeeDao;
        uint256 FeeNft;
        uint256 FeeTech;
        uint256 FeeOp;

        //buy
        if(from == uniswapV2Pair){
            FeeDead = amount.mul(buyDeadFee).div(100);
            amountAfter = amountAfter.sub(FeeDead);
            FeeDao = amount.mul(buyDaoFee).div(100);
            amountAfter = amountAfter.sub(FeeDao);
            FeeNft = amount.mul(buyNftFee).div(100);
            amountAfter = amountAfter.sub(FeeNft);
            FeeTech = amount.mul(buyTechFee).div(100);
            amountAfter = amountAfter.sub(FeeTech);
            FeeOp = amount.mul(buyTechFee).div(100);
            amountAfter = amountAfter.sub(FeeOp);

            if(FeeDead>0)
                doTransfer(from, walletDead, FeeDead);
            if(FeeDao>0)
                doTransfer(from, walletDao, FeeDao);
            if(FeeNft>0)
                doTransfer(from, walletNft, FeeNft);
            if(FeeTech>0)
                doTransfer(from, walletTech, FeeTech);
            if(FeeOp>0)
                doTransfer(from, walletOp, FeeOp);
        }
        //sell
        if(recipient == uniswapV2Pair){
            FeeDead = amount.mul(sellDeadFee).div(100);
            amountAfter = amountAfter.sub(FeeDead);
            FeeDao = amount.mul(sellDaoFee).div(100);
            amountAfter = amountAfter.sub(FeeDao);
            FeeNft = amount.mul(sellNftFee).div(100);
            amountAfter = amountAfter.sub(FeeNft);
            FeeTech = amount.mul(sellTechFee).div(100);
            amountAfter = amountAfter.sub(FeeTech);
            FeeOp = amount.mul(sellTechFee).div(100);
            amountAfter = amountAfter.sub(FeeOp);

            if(FeeDead>0)
                doTransfer(from, walletDead, FeeDead);
            if(FeeDao>0)
                doTransfer(from, walletDao, FeeDao);
            if(FeeNft>0)
                doTransfer(from, walletNft, FeeNft);
            if(FeeTech>0)
                doTransfer(from, walletTech, FeeTech);
            if(FeeOp>0)
                doTransfer(from, walletOp, FeeOp);
        }

        return amountAfter;

    }
    function takeTransferFee(address from, uint256 amount) private returns(uint256 amountAfter) {
        amountAfter = amount;

        uint256 FeeTrans = amount.mul(transFee).div(100);
        amountAfter = amountAfter.sub(FeeTrans);

        if(FeeTrans>0)
            doTransfer(from, walletOp, FeeTrans);

        return amountAfter;

    }
    
    function _transfer(address from, address recipient, uint256 amount) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(_balances[from] >= amount, "BEP20: transfer amount exceeds balance");
        if(amount == 0 ) {doTransfer(from, recipient, 0);return;}

        profiting(from);
        profiting(recipient);

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
            || from == walletDao
            || recipient == walletDao
            || from == walletOp
            || recipient == walletOp
            || from == walletTech
            || recipient == walletTech
        ){
            
        }else{

            //LP/swap 
            if(from == uniswapV2Pair || recipient == uniswapV2Pair){
                if(!swapping) {
                    swapping = true;
                    amount = takeAllFee( from,recipient,  amount);
                    swapping = false;
                }
            }else{
                //normal transfer
                if(!swapping) {
                    swapping = true;
                    amount = takeTransferFee( from,  amount);
                    swapping = false;
                }
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