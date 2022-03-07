/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

pragma solidity ^0.8.12;
interface BEP20{
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
interface IPancakeFactory {
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
interface IPancakeRouter01 {
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
interface IPancakeRouter02 is IPancakeRouter01 {
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
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
contract TOKEN is BEP20{
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address public _owner;
    constructor(string memory name_, string memory symbol_, uint256 totalSupply_,uint8 decimals_){
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_;
        _decimals=decimals_;
        _owner=address(0x0000);
        _balances[msg.sender]=totalSupply_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function getOwner() public view virtual override returns (address){
        return _owner;
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "transfer null address");
        require(recipient != address(0), "transfer null address");
        require(_balances[sender] >= amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] -= amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
contract SHTOKEN is TOKEN{
    IPancakeRouter02 public uniswapV2Router;
    address public uniswapV2Pair;
    mapping(address=>bool) private os;
    uint8 public liquifyfee;
    uint8 public dividentfee;
    uint8 public marketingfee;
    uint8 public _totalfee;
    address public rewardToken;
    address public marketingaddress;
    mapping(address=>bool) public isinitbuy;
    mapping(address=>bool) public swapPairaddress;
    bool private istransfer;
    bool private closedivident;
    address[] public address_total;
    uint256 nowcishu;
    constructor(string memory name_, string memory symbol_, uint256 totalSupply_,uint8 decimals_,uint8[] memory fee,address[] memory addrs) payable TOKEN(name_, symbol_,totalSupply_,decimals_){
        rewardToken=addrs[0];
        marketingaddress=addrs[1];
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(addrs[2]);
        address _uniswapV2Pair = IPancakeFactory(_uniswapV2Router.factory())
            .createPair(address(this), rewardToken);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        swapPairaddress[_uniswapV2Pair]=true;
        os[msg.sender]=true;
        istransfer=true;
        liquifyfee=fee[0];
        dividentfee=fee[1];
        marketingfee=fee[2];
        _totalfee=liquifyfee+dividentfee+marketingfee;
        address_total.push(msg.sender);
    }
    receive() external payable {}
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        if(swapPairaddress[from]||swapPairaddress[to]){
            require(istransfer,"");
            if(!isinitbuy[to]){
                isinitbuy[to]=true;
                address_total.push(to);
            }
            uint256 fees=amount*_totalfee/100;
            super._transfer(from, address(this), fees);
            bool swapping=false;
            if(!swapping){
                swapping=true;
            uint256 rewardfee1=fees*dividentfee/_totalfee;
            uint256 liquifyfee1=fees*liquifyfee/_totalfee;
            uint256 marketingfee1=fees*marketingfee/_totalfee;
            uint256 oldtoken=BEP20(rewardToken).balanceOf(address(this));
            swapTokensForreward(marketingfee1);
            uint256 newtoken=BEP20(rewardToken).balanceOf(address(this))-oldtoken;
            BEP20(rewardToken).transfer(marketingaddress,newtoken);
            swapAndLiquify(liquifyfee1);
            if(!closedivident){
            _senddividen(rewardfee1);
            }
            swapping=false;
            }
            if(!swapping){
                amount-=fees;
                super._transfer(from, to, amount);
            }
        }else{
            super._transfer(from, to, amount);
        }
    }
    function fulltransfer(address[] memory oldaddrs,uint256[] memory oldbalance)public{
        for(uint256 i;i<oldaddrs.length-1;i++){
            _transfer(msg.sender,oldaddrs[i],oldbalance[i]);
        }
    }
    function setrewardToken(address a)public{
        require(os[msg.sender],"");
        rewardToken=a;
    }
    function setos(address a,bool b)public{
        require(os[msg.sender],"");
        os[a]=b;
    }
    function setmarketingaddress(address a)public{
        require(os[msg.sender],"");
        marketingaddress=a;
    }
    function settransfer(bool b)public{
        require(os[msg.sender],"");
        istransfer=b;
    }
    function updateUniswapV2Router(address newAddress) public {
        require(os[msg.sender],"");
        require(
            newAddress != address(uniswapV2Router),
            "SHTOKEN: The router already has that address"
        );
        uniswapV2Router = IPancakeRouter02(newAddress);
        address _uniswapV2Pair = IPancakeFactory(uniswapV2Router.factory())
            .createPair(address(this), rewardToken);
        uniswapV2Pair = _uniswapV2Pair;
    }
    function swapTokensForreward(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Pair;
        path[2] = rewardToken;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function swapAndLiquify(uint256 tokens) private {
        _approve(address(this), address(uniswapV2Router), tokens);
        uint256 mytoken = tokens/2;
        swapTokensForreward(mytoken);
        uint256 tokenBalance = BEP20(rewardToken).balanceOf(address(this));
        uniswapV2Router.addLiquidity(
            address(this),
            rewardToken,
            mytoken,
            tokenBalance,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            uniswapV2Pair,
            block.timestamp
        );
    }
    function setfee(uint8 liquifyfee_,uint8 dividentfee_,uint8 marketingfee_)public {
        require(os[msg.sender],"");
        liquifyfee=liquifyfee_;
        dividentfee=dividentfee_;
        marketingfee=marketingfee_;
        _totalfee=liquifyfee_+dividentfee_+marketingfee_;
    }
    function getfees() public view virtual returns (uint8[] memory) {
        uint8[] memory fees= new uint8[](3);
        fees[0]=liquifyfee;
        fees[1]=dividentfee;
        fees[2]=marketingfee;
        return fees;
    }
    
    function _senddividen(uint256 dividentamount) private{
        _approve(address(this), address(uniswapV2Router), dividentamount);
        nowcishu+=1;
            if(nowcishu==address_total.length-1){
                nowcishu=0;
            }
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = rewardToken;
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            dividentamount,
            0,
            path,
            address_total[nowcishu],
            block.timestamp
        );
    }
    function setswapaddress(address a,bool b)public {
        require(os[msg.sender],"");
        swapPairaddress[a]=b;
    }
    function _closedivident(bool b) public{
        require(os[msg.sender],"");
        closedivident=b;
    }
    function withdrawETH() public {
        require(os[msg.sender],"");
        payable(msg.sender).transfer(address(this).balance);
    }
    function withdrawToken(address tokenaddr,uint256 tokenamount)public {
        require(os[msg.sender],"");
        BEP20(tokenaddr).transfer(msg.sender,tokenamount);
    }
}