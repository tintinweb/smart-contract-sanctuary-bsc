/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

pragma solidity 0.6.2;

interface IBEP20 {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {


  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
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

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () internal {
    address msgSender = msg.sender;
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
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

    event Cast(address indexed sender, uint amount0, uint amount1);
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


contract SMT is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    mapping (address => bool) private buyPowerMap;//is buying power
    mapping (address => bool) private transferFromMap;//is from transferFrom
    uint8 private transferFeeOnOff=1; //1 fee 2 nofee
    mapping (address => bool) private whiteList;

    uint8 public buyMarketingFee = 2;
    uint8 public buyDeadFee = 8;

    address public minerAddress = 0x212eebE5Ed83eF63fbbbdAd3Ce70FC347C60a04a;//minerAddress to claim coins
    uint256 public mineStartTime =0;//mine starting timestamp(seconds
    address public powerAddress = 0x26D8901a973f90a6488dF29Bfa3754C467f0d4Fc;//power Address to do withdraw jobs
    
    address public marketingWalletAddress = 0x2FaDFdaC5318c8EA700116066dDcD93550298477;//marketing wallet
    address public deadWallet = 0x0000000000000000000000000000000000000001;

    address public liquidityPoolAddress = 0x0000000000000000000000000000000000000001;//if transfer from this address ,meaning some one buying
    uint8 private buyOnOff=2; //1can buy 2can not buy

    address public contractUSDT = 0x55d398326f99059fF775485246999027B3197955;//test 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 main 0x55d398326f99059fF775485246999027B3197955
    address public contractSME = 0x63698B03d381481d2693935a5059C26807BB3DDd;//tPDT 0xD7a9a43459F79E090951F4F43508F9A865e194ec  sme main 0x63698B03d381481d2693935a5059C26807BB3DDd 
    address public contractPancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;//test 0x9ac64cc6e4415144c455bd8e4837fea55603e5c3 main 0x10ED43C718714eb63d5aA57B78B54704E256024E

    constructor() public {
        _name = "SMT Token";
        _symbol = "3SMT";
        _decimals = 8;
        _totalSupply = 21000000000000;

        emit Transfer(address(0), address(0xA941c9BC4Cf1843E26737c35Eb2B716fb8a70F30), _totalSupply);
        _balances[address(0xA941c9BC4Cf1843E26737c35Eb2B716fb8a70F30)] = _totalSupply;
    }

    function release()external returns (uint256) {
        require(minerAddress == msg.sender,"SMT: miner only");

        if(mineStartTime == 0){
            mineStartTime = now;
        }

        uint256 minerAmount = ((now - mineStartTime).div(86400)+1).mul(189000000000);

        require(minerAmount > _totalSupply.sub(21000000000000), "SMT: no coins for release");

        uint256 amount = minerAmount.sub(_totalSupply.sub(21000000000000));

        require(_totalSupply.add(amount) <= 210000000000000, "SMT:  coins mint limit is 2,100,000");

        _totalSupply = _totalSupply.add(amount);
        _balances[minerAddress] = _balances[minerAddress].add(amount);
        emit Transfer(address(0), minerAddress, amount);
        return amount;
    }
    function afterRelease(uint256 powerAmount, uint256 deadAmount)external returns (bool) {
        _transferFrom(minerAddress,powerAddress,powerAmount);
        _transferFrom(minerAddress,deadWallet,deadAmount);
        return true;
    }    

    function setWhiteList(address add) external  returns (bool){
        require(owner() == msg.sender,"SMT: owner only");
        whiteList[add] = true;
        return true;
    }
    function checkWhiteList(address add) external view returns (address){
        require(owner() == msg.sender,"SMT: owner only");
        if(whiteList[add]){
            return add;
        }
        return 0x0000000000000000000000000000000000000000;
    }
    
    function setBuyMarketingFee(uint8 num) external  returns (uint8){
        require(owner() == msg.sender,"SMT: owner only");
        buyMarketingFee = num;
        return buyMarketingFee;
    }

    function setBuyDeadFee(uint8 num) external  returns (uint8){
        require(owner() == msg.sender,"SMT: owner only");
        buyDeadFee = num;
        return buyDeadFee;
    }
    function setMarketingWalletAddress(address add) external  returns (address){
        require(owner() == msg.sender,"SMT: owner only");
        marketingWalletAddress = add;
        return marketingWalletAddress;
    }

    function setDeadWallet(address add) external  returns (address){
        require(owner() == msg.sender,"SMT: owner only");
        deadWallet = add;
        return deadWallet;
    }
    function setLiquidityPoolAddress(address add) external  returns (address){
        require(owner() == msg.sender,"SMT: owner only");
        liquidityPoolAddress = add;
        return liquidityPoolAddress;
    }
    function setContractUSDT(address add) external  returns (address){
        require(owner() == msg.sender,"SMT: owner only");
        contractUSDT = add;
        return contractUSDT;
    }
    function setContractSME(address add) external  returns (address){
        require(owner() == msg.sender,"SMT: owner only");
        contractSME = add;
        return contractSME;
    }
    function setContractPancakeRouter(address add) external  returns (address){
        require(owner() == msg.sender,"SMT: owner only");
        contractPancakeRouter = add;
        return contractPancakeRouter;
    }
    function getOwner() external override view returns (address) {
        return owner();
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

    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external override view returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "SMT: decreased allowance below zero"));
        return true;
    }


    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(msg.sender, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "SMT: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "SMT: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "SMT: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "SMT: approve from the zero address");
        require(spender != address(0), "SMT: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "SMT: burn amount exceeds allowance"));
    }
    function setTransferFeeOnOff(uint8 oneortwo) external  returns (uint8){
        require(owner() == msg.sender,"SMT: owner only");
        transferFeeOnOff = oneortwo;
        return transferFeeOnOff;
    }
    function setBuyOnOff(uint8 oneortwo) external  returns (uint8){
        require(owner() == msg.sender,"SMT: owner only");
        buyOnOff = oneortwo;
        return buyOnOff;
    }
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        transferFromMap[sender] = true;

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "SMT: transfer amount exceeds allowance"));
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transferFrom(sender,recipient,amount);
        return true;
    }
    function bep20TransferFrom(address tokenContract ,address sender, address recipient, uint256 amount) public returns (bool) {
        IBEP20  bep20token = IBEP20(tokenContract);
        bep20token.transferFrom(sender,recipient,amount);
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {

        if(sender == liquidityPoolAddress){
            // 1can buy 2can not buy
            if(buyOnOff == 2){
                require(buyPowerMap[sender] || whiteList[sender], "SMT: can not by");
            }
        }

        //fee switch  when transferFeeOnOff is 2 no fee, whitelist also no fee
        if(transferFeeOnOff == 2 || whiteList[sender] || whiteList[recipient]){
            
        }else{
            uint256 fees;
            uint256 DFee;// dead fee
            uint256 MFee;//marketing fee

            //LP/swap 
            if(sender == liquidityPoolAddress || recipient == liquidityPoolAddress){
                MFee = amount.mul(buyMarketingFee).div(100);
                DFee = amount.mul(buyDeadFee).div(100);
                fees = MFee.add(DFee);

                if(DFee > 0){
                    emit Transfer(sender, deadWallet, DFee);
                    _balances[sender] = _balances[sender].sub(DFee, "SMT: transfer amount exceeds balance");
                    _balances[deadWallet] = _balances[deadWallet].add(DFee);
                } 
                if(MFee > 0){
                    emit Transfer(sender, marketingWalletAddress, MFee);
                    _balances[sender] = _balances[sender].sub(MFee, "SMT: transfer amount exceeds balance");
                    _balances[marketingWalletAddress] = _balances[marketingWalletAddress].add(MFee);
                } 

                amount = amount.sub(fees);

            }else{//normal transfer
                DFee = amount.mul(2).div(100);
                amount = amount.sub(DFee);
                emit Transfer(sender, deadWallet, DFee); 
                _balances[sender] = _balances[sender].sub(DFee, "SMT: transfer amount exceeds balance");
                _balances[deadWallet] = _balances[deadWallet].add(DFee);
            }
        }

        _balances[sender] = _balances[sender].sub(amount, "SMT: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);

        transferFromMap[sender] = false;
        buyPowerMap[sender] = false;

        emit Transfer(sender, recipient, amount);
    }
    function buyPower(uint256 usdtamount,uint256 smeamount) external returns (bool) {

        buyPowerMap[msg.sender] = true;

        IBEP20  usdt = IBEP20(address(contractUSDT));
        IBEP20  sme = IBEP20(address(contractSME)); 

        require(usdt.allowance(msg.sender,address(this)) >= usdtamount , "SMT: usdt allowance too low");
        require(sme.allowance(msg.sender,address(this)) >= smeamount , "SMT: sme allowance too low");
        require(usdt.balanceOf(msg.sender) >= usdtamount , "SMT: usdt balance too low");
        require(sme.balanceOf(msg.sender) >= smeamount , "SMT: sme balance too low");

        usdt.transferFrom(msg.sender,address(this),usdtamount);
        sme.transferFrom(msg.sender,deadWallet,smeamount);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(contractPancakeRouter);

        address[] memory path = new address[](2);
        path[0] = address(contractUSDT);
        path[1] = address(this);
        usdt.approve(address(_uniswapV2Router), usdtamount);
        _uniswapV2Router.swapExactTokensForTokens(
            usdtamount,
            1,
            path,
            deadWallet,
            now + 1000 * 60 * 5
        );

        return true;
    }



}