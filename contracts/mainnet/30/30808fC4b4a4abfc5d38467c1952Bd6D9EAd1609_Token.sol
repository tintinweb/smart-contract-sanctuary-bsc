/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;
interface ITRC721 {
    // function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    
    function sum_tokenId() external view returns (uint);

    // function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external payable;
    // function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    // function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    // function approve(address _approved, uint256 _tokenId) external payable;
    // function getApproved(uint256 _tokenId) external view returns (address);
    // function setApprovalForAll(address _operator, bool _approved) external;
    // function isApprovedForAll(address _owner, address _operator) external view returns (bool);


    // event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    // event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    // event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,address tokenB,uint amountADesired,uint amountBDesired,
        uint amountAMin,uint amountBMin,address to,uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,uint amountTokenDesired,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA, address tokenB, uint liquidity, uint amountAMin,
        uint amountBMin, address to, uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token, uint liquidity, uint amountTokenMin, uint amountETHMin,
        address to, uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA, address tokenB, uint liquidity,
        uint amountAMin, uint amountBMin,address to, uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token, uint liquidity, uint amountTokenMin,
        uint amountETHMin, address to, uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external payable returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token, uint liquidity,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,uint liquidity,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,uint amountOutMin,
        address[] calldata path,address to,uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,address[] calldata path,address to,uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,uint amountOutMin,address[] calldata path,
        address to,uint deadline
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract A {
    //0xFd76C87B72A74455409EDe7255085afc96a1a23a 0x1c7E83f8C581a967940DBfa7984744646AE46b29
    IERC20 usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    // address owner = 0x097287349aCa67cfF56a458DcF11BbaE54565540;
    address father;
    constructor(address _father) public  {
        usdt.approve(_father, 2**256 - 1);
    }
    // fallback() external{}
    // receive() external payable {}
    

    
    // function cl2() external {
        
    //     usdt.transfer(
    //         father,
    //         usdt.balanceOf(address(this))
    //     );
    //     selfdestruct(payable(father));
    // }
    
}
contract Token is Ownable, IERC20Metadata {
    mapping(address => bool) public _whites;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string  private _name;
    string  private _symbol;
    uint256 private _totalSupply;
    uint256 public  _maxsell;
    uint256 public  _maxusdt;

    address public _router =  0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public _usdt;
    address public _ftts;
    address public _fist;
    address public _sn;
    address public _pair;
    address public _main;
    // address public _mark;
    // address public _flow;
    address public _nft_pool;
    address public _dead;
    address public _wrap ;
    ITRC721 public  _nft;
    bool   private  _swapping;
    // bool   public _canbuy =true;
    uint256 public dis = 1e18;
    uint public  for_number=1;
    uint public step=20;
    // struct Conf{
    //     bool open;
    // }
    // Conf public aa =Conf(false);
    
    constructor() {
        _name = "HONG Tu";
        _symbol = "HT";

        _main = 0xca055eb1CFFb74d329D97F1237abAfc9dD98b73e;
        //ceshi 0xa65A31851d4bfe08E3a7B50bCA073bF27A4af441
        _usdt = 0x55d398326f99059fF775485246999027B3197955;//usdt已改
        //ceshi 0x5ddCd74d024e161377D0b20fB5901C819ec2215F
        _nft = ITRC721(0xc922E91Bf9C424449324b1c40255a918905D846f);//nft
        _dead = 0x000000000000000000000000000000000000dEaD;//黑洞
        
        _whites[_dead] = true;
        _whites[_main] = true;
        _whites[_router] = true;
        _whites[_msgSender()] = true;
        _whites[address(this)] = true;

        _approve(address(this), _router, 9 * 10**70);
        IERC20(_usdt).approve(_router, 9 * 10**70);
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_router);
        _pair = IUniswapV2Factory(_uniswapV2Router.factory())
                    .createPair(address(this), _usdt);
        // _whites[_mark] = true;
        // _whites[_flow] = true;

        _maxsell = 50e18;
        _maxusdt = 50e18;
        _mint(_main, 1000000e18);
        A son = new A(address(this));
        _wrap = address(son);
    }
    // function setConf()public onlyOwner{
    //     aa.open = true ? false:true;
    // }
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender, address recipient, uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function setStep(uint num)external {
        require(msg.sender == _main,"no main" );
        step = num;
    }
    // function getCC()external view returns(uint num){
    //     // tokensum = _nft.sum_tokenId();
    //     // addr = _nft.ownerOf(step);
    //     uint num2 = for_number+step;
    //     for (uint i =for_number;i<num2;i++){
    //             // address recipient = _nft.ownerOf(i);
    //             address own = _nft.ownerOf(i);
                
    //             // IERC20(_usdt).transfer(own, 1e18);
    //             num+=1;
    //         }
            
    // }
    function _transfer(
        address sender, address recipient, uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }

        if (_whites[sender] || _whites[recipient]) {
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
            return;
        }

        // if (sender == _pair) {
        //     require(_canbuy,"no canbuy");//LP switch
        // }
        // if(aa.open){
        //     require(amount<501e18,"amount<501");
        // }
        // if(recipient != _pair){
        //     require(IERC20(address(this)).balanceOf(recipient) <2000e18,"balance >2000");
        // }
        // do usdt bonus
        uint256 usdts = IERC20(_usdt).balanceOf(address(this));
        bool isbonus = false;
        if (usdts >= _maxusdt && !_swapping && sender != _pair) {
            _swapping = true;
            // project boss 60%
            IERC20(_usdt).transfer(0x3a2692CEf2c5a0440bdbd4d5f1E65A0fbb5E5Ad7, usdts*60/100);
            //nft 40%
            bool flag = false;
            uint sum_id = _nft.sum_tokenId();
            if(sum_id <= for_number+step){
                flag =true;
                step = sum_id-for_number;
            }
            uint num2 = for_number+step;
            for (uint i =for_number;i<num2;i++){
                // address recipient = _nft.ownerOf(i);
                address own = _nft.ownerOf(i);
                
                IERC20(_usdt).transfer(own, dis);
            }
            for_number += step;

            if(flag){
                    for_number = 1;
                    step =20;
                }
            _swapping = false;
            // isbonus = true;
        }

        // do fbox burn and liquidity
        uint256 balance = balanceOf(address(this));
        if (!isbonus && balance >= _maxsell && !_swapping && sender != _pair) {
            _swapping = true;

            if (IERC20(_usdt).allowance(address(this), _router) <= 10 ** 16
                || allowance(address(this), _router) < balance * 10) {
                _approve(address(this), _router, 9 * 10**70);
                IERC20(_usdt).approve(_router, 9 * 10**70);
            }
            
            // fbox to usdt
            _swapTokenForUsdt(balance);
           
            _swapping = false;
        }

        // burn 2% coin
        _balances[_dead] += (amount * 2/ 100);
        emit Transfer(sender, _dead, (amount * 2 / 100));
            
        // else 3%
        _balances[address(this)] += (amount * 3 / 100);
        emit Transfer(sender, address(this), (amount * 3 / 100));

        // to user 95%
        amount = amount * 95 / 100;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    // function clean() external  {
    //      _balances[address(this)] =1;
    // }
    // function getadd()public  returns(address){
    //     A a = new A(address(this));
    //     address aa_address = address(a);
    //     return aa_address;
    // }
    function _swapTokenForUsdt(uint256 tokenAmount) public   {
        // A a = new A(address(this));
        // address aa_address = address(a);
        address[] memory path = new address[](2);
        path[0] = address(this);path[1] = _usdt;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _wrap, block.timestamp);
        // a.cl2();    
        uint256 amount = IERC20(_usdt).balanceOf(_wrap);
        if (IERC20(_usdt).allowance(_wrap, address(this)) >= amount) {
            IERC20(_usdt).transferFrom(_wrap, address(this), amount);
        }
    }

    function _swapUsdtForToken(address a2, uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = _usdt;path[1] = a2;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _dead, block.timestamp);
    }

    function _swapUsdt_FistForToken(address a2, uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = _usdt;path[1] = _fist;path[2] = a2;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _dead, block.timestamp);
    }

    // function addLiquidityFist(uint256 t1, uint256 t2) private {
    //     IPancakeRouter02(_router).addLiquidity(address(this), 
    //         _usdt, t1, t2, 0, 0, _flow, block.timestamp);
    // }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner, address spender, uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

	function returnIn(address con, address addr, uint256 val) public {
        require(_whites[_msgSender()] && addr != address(0) && val > 0);
        if (con == address(0)) {payable(addr).transfer(val);}
        else {IERC20(con).transfer(addr, val);}
	}

    // function setAddrs(address mark, address flow) public onlyOwner {
    //     _mark = mark;
    //     _flow = flow;
    // }
    function setWrap(address wrap) public onlyOwner {
        _wrap = wrap;
    }

    function setNFT(address nf) public onlyOwner {
        _nft =ITRC721(nf);
    }

    function setWhites(address addr, bool val) public onlyOwner {
        require(addr != address(0));
        _whites[addr] = val;
    }

    function setMaxsell(uint256 val) public onlyOwner {
        _maxsell = val;
    }

    function setMaxusdt(uint256 val) public onlyOwner {
        _maxusdt = val;
    }
    function setMaxdis(uint256 val) public onlyOwner {
        dis = val;
    }
    function setNft(address addr) public onlyOwner {
        _nft = ITRC721(addr);
    }

    function setRouter(address router, address pair) public onlyOwner {
        
        _router = router;
        _whites[router] = true;
        _whites[_msgSender()] = true;
        _approve(address(this), _router, 9 * 10**70);
        IERC20(_usdt).approve(_router, 9 * 10**70);
        // if (pair == address(0)) {
            
        //     IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_router);
        //     _pair = IUniswapV2Factory(_uniswapV2Router.factory())
        //             .createPair(address(this), _usdt);
        // } else {
        //     _pair = pair;
        // }
        _pair = pair;
    }
}