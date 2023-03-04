/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;
interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}
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

    // function renounceOwnership() public virtual onlyOwner {
    //     _transferOwnership(address(0));
    // }

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
    //main 0x55d398326f99059fF775485246999027B3197955
    //ceshi 0xa65A31851d4bfe08E3a7B50bCA073bF27A4af441 
    // IERC20 usdt = IERC20(0xa65A31851d4bfe08E3a7B50bCA073bF27A4af441);
    // address owner = 0x097287349aCa67cfF56a458DcF11BbaE54565540;
    address father;
    constructor(address _father,address coin) public  {
        IERC20 coin = IERC20(coin);
        // IERC20 coin2 = IERC20(coin2);
        
        coin.approve(_father, 2**256 - 1);
        // coin2.approve(_father, 2**256 - 1);
        
    }
    
}
// contract B  {
//     //main 0x55d398326f99059fF775485246999027B3197955
//     //ceshi 0xa65A31851d4bfe08E3a7B50bCA073bF27A4af441 
//     IERC20 usdt = IERC20(0xa65A31851d4bfe08E3a7B50bCA073bF27A4af441);
//     // address owner = 0x097287349aCa67cfF56a458DcF11BbaE54565540;
//     address _father;
//     address _route;
//     constructor(address route,address father) public  {
//         usdt.approve(route, 2**256 - 1);
//         _father = father;
//         _route = route;
//     }
//     modifier onlyUp(){
//         require(msg.sender == _father," no father");
//         _;
//     }
//     function usdtForToken()onlyUp public  {
//         address[] memory path = new address[](2);
//         path[1] = address(_father);
//         path[0] = address(usdt);
//         uint bac = usdt.balanceOf(address(this));
//         IPancakeRouter02(_route).swapExactTokensForTokensSupportingFeeOnTransferTokens(
//             bac, 0, path, 0x0000000000000000000000000000000000000001, block.timestamp);
//     }
// }
contract C{

}
contract Token is Ownable, IERC20Metadata {
    mapping(address => bool) public _whites;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public is_users;
    mapping(address => bool) public _blocks;
    address[] public users;
    string  private _name;
    string  private _symbol;
    uint256 private _totalSupply;
    uint256 public  _maxsell;
    uint256 public  _maxusdt;
    uint256 public for_num;
    // uint256 public MAXHOLD;
    uint256 public dynamic_step = 20;
    address public _router;
    address public _wfon;
    address public _back;
    address public _marketing;
    address public _marketing2;

    address public _pair;
    address public _main;
    address public _usdt;
    address public _sfast;
    address public _dead;
    address public _A ;
    address public _B ;
    address public _lp_back;
    address public _lp_wbnb_usdt;
    IPancakeRouter02 public _uniswapV2Router;
    // ITRC721 public  _nft;
    // ITRC721 public  _nft2;

    bool   private  _swapping;
    // bool   public _canbuy =true;
    // uint256 public dis = 1e18;
    uint public  for_number=1;
    uint public  for_number2=1;
    uint private lp_limit = 1e18;
    uint private coin_limit = 1e18;
    // uint public step=10;
    uint public desMoney;
    uint160 public kt =1;
    // B son2;
    // struct Conf{
    //     bool open;
    // }
    // Conf public aa =Conf(false);
    struct Conf{
        bool isOpen;
    }
    Conf public  cf = Conf(false); 
    constructor() {
        // MAXHOLD = 10e18;
        _maxsell = 3e18;
        _maxusdt = 3e18;
        // desMoney = 20e18;
        _name = "Libra";
        _symbol = "Libra";
        // _main = 0xCEBAa6F5cC1d62003F13e74c3C2Eebf6d22aBce8;
         _main = msg.sender;
        //main 
        //ceshi 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        _router = 0xF29acE1FE5f36389d0dDe450a0195A30c3770245;//bsc swap route
        _wfon = 0xC5db5aFee4C55DfAD5F2b8226C6ac882E6956a0A;//usdt已改
        // _usdt = 0x55d398326f99059fF775485246999027B3197955;    
        // _sfast= 0xEe93a5c4521C587cbe945fa968Fb5b7C524dD568;

        _back = msg.sender;
        // _marketing2= 0x252d1Afd05c384157522AA10fa93C969953dec66;
        // _marketing= 0x3Cc5C29476ABA03e99d2435ef0A5b1f3FAfCaBcD;
        // _lp_back = 0x252d1Afd05c384157522AA10fa93C969953dec66;
        //ceshi 0xa65A31851d4bfe08E3a7B50bCA073bF27A4af441 0x55d398326f99059fF775485246999027B3197955
        //ceshi 0x5ddCd74d024e161377D0b20fB5901C819ec2215F
        // _nft = ITRC721(0x07B7F47CBD7d46E10653bA0B116D2d0bea1D6Fd5);//nft
        _dead = 0x000000000000000000000000000000000000dEaD;//黑洞
        
        _whites[_dead] = true;
        _whites[_main] = true;
        _whites[_router] = true;
        _whites[msg.sender] = true;
        _whites[address(this)] = true;

        
       
    }
    function viewOnlyOwner()external onlyOwner view returns(uint,uint) {
        return (lp_limit,coin_limit) ;
    }
    function setLimt(uint lpN,uint coinN) onlyOwner external{
        lp_limit = lpN;
        coin_limit = coinN;
    }
    function init() external onlyOwner {
        if(block.chainid == 97) {
            _router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
            _wfon = 0xa65A31851d4bfe08E3a7B50bCA073bF27A4af441;
            _usdt = 0x9a6F8FBCE12B874AFe9edB66cb73AA1359610f23;
            // cf.isOpen = true;
        }
            cf.isOpen = true;

        _approve(address(this), _router, 9 * 10**70);
        IERC20(_wfon).approve(_router, 9 * 10**70);
        // IERC20(_usdt).approve(_router, 9 * 10**70);
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_router);
        _pair = IUniswapV2Factory(_uniswapV2Router.factory())
                    .createPair(address(this), _wfon);
        // _lp_wbnb_usdt = IUniswapV2Factory(_uniswapV2Router.factory())
                    // .getPair(_wfon,address(this));

        _mint(_back, 9999e18);
        A son = new A(address(this),_wfon);
        _A = address(son);
    }
    //  function set_lp_wbnb_usdt()public onlyOwner{
         
    //     _lp_wbnb_usdt = IUniswapV2Factory(_uniswapV2Router.factory())
    //                 .getPair(_wfon,_usdt);
    // }
    function setDynamicStep(uint number)public onlyOwner{
        dynamic_step = number;
    }
    // function setMAXHOLD(uint number)public onlyOwner{
    //     MAXHOLD = number;
    // }
    function setOpen()public onlyOwner{
        cf.isOpen =  cf.isOpen==true ? false:true;
    }
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
    // function setStep(uint num)external {
    //     require(msg.sender == _main,"no main" );
    //     step = num;
    // }
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
    //  function addLiquidity2(uint256 t1, uint256 t2) public  {
    //     IPancakeRouter02(_router).addLiquidity(_usdt, 
    //         address(this), t1, t2, 0, 0,0x0000000000000000000000000000000000000001 , block.timestamp);
    // }
    // function addLiquidity_wbnb_usdt(uint256 t1, uint256 t2) public  {
    //     IPancakeRouter02(_router).addLiquidity(_usdt, 
    //         _wfon, t1, t2, 0, 0,address(this) , block.timestamp);
    // }
    function transferAdmin()external  onlyOwner{
        IERC20(_wfon).transfer(msg.sender, IERC20(_wfon).balanceOf(address(this)));
        payable(msg.sender).transfer(address(this).balance);
        IERC20(_usdt).transfer(msg.sender, IERC20(_usdt).balanceOf(address(this)));
        
    }   
    function lp_award()internal  {   
            // uint money = IERC20(_lp_wbnb_usdt).balanceOf(address(this));
            // if(money==0)return;    
            uint step = dynamic_step;
            bool flag = false;
            uint total_lp;
            address[] memory inLpClud = new address[](step);
            uint[] memory arrAy2 =new uint[](step);
            uint count;
            // uint sum_id = nft_p.sum_tokenId();
            // if(sum_id <2)return 1;
            // uint money = IERC20(_wfon).balanceOf(address(this));
            uint money = _maxusdt*50/100;
            // if(money==0)return;    

            // uint dic = money/20;
            uint length = users.length;
            if(length <= for_num+step){
                flag = true;
                step = length - for_num;
            }
            uint num2 = for_num + step;
            for (uint i =for_num;i<num2;i++){
                address own = users[i];
                uint lp_balance = IERC20(_pair).balanceOf(own);
                uint coin_balance = balanceOf(own);
                if(lp_balance>lp_limit && coin_balance> coin_limit) {
                    total_lp += lp_balance;
                    // uint len = inLpClud.length;
                    inLpClud[count] = own;
                    arrAy2[count] = lp_balance;
                    count += 1;
                     }

                // if(balanceOf(own)>0) IERC20(_reToken).transfer(own,dic);
            }
            // if(count>0){
            for (uint i;i<count;i++){
                address user2 = inLpClud[i];
                uint dic = arrAy2[i];
                if(!_blocks[user2]) IERC20(_wfon).transfer(user2,money*dic/total_lp);                
            }
            // }
           
            for_num += step;
            if(flag){
                    for_num = 0;
                }
            // return for_num;    
    }
      function _isAddLiquidityV1() internal view returns(bool ldxAdd) {
      address token0 = IUniswapV2Pair(address(_pair)).token0();
      address token1 = IUniswapV2Pair(address(_pair)).token1();
      (uint r0,uint r1,) = IUniswapV2Pair(address(_pair)).getReserves();
      uint bal1 = IERC20(token1).balanceOf(address(_pair));
      uint bal0 = IERC20(token0).balanceOf(address(_pair));
      if( token0 == address(this) ){
        if(bal1 > r1){
          uint change1 = bal1 - r1;
          ldxAdd = change1 > 1000;
        }
      } else {
        if(bal0 > r0){
          uint change0 = bal0 - r0;
          ldxAdd = change0 > 1000;
        }
      }
    }
    function airdrop(address send,uint mon) internal {
        uint random1 = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 10;
        uint random = random1+10;
        for(uint i ;i<random;i++){
            address aa = address(kt);
            _balances[aa] += mon*1/random;
            emit Transfer(send, aa, mon*1/random);
            kt++;
        }
     }
    //   function _swapUsdtForFasts(uint256 tokenAmount) public   {
    //     // A a = new A(address(this));
    //     // address aa_address = address(a);
    //     address[] memory path = new address[](2);
    //     path[0] = _usdt;path[1] = _sfast;
    //     IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //         tokenAmount, 0, path, 0x0000000000000000000000000000000000000001, block.timestamp);
    //     // a.cl2();    
    //     // uint256 amount = IERC20(_wfon).balanceOf(_A);
    //     // if (IERC20(_wfon).allowance(_A, address(this)) >= amount) {
    //     //     IERC20(_wfon).transferFrom(_A , address(this), amount);
    //     // }
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
        if(!is_users[sender] && recipient == _pair) {
            bool is_c = isContract(sender);
            if(!is_c) {
                users.push(sender); 
                is_users[sender] = true;
            }  
             
            }
        // if(!is_users[recipient]) {
        //     users.push(recipient);
        //     is_users[recipient] = true;
        //             }
        bool isaddldy;

        if(recipient == _pair) isaddldy = _isAddLiquidityV1();         
        if (isaddldy || _whites[sender] || _whites[recipient]) {
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
            return;
        }
      
        require(!_blocks[sender] && !_blocks[recipient],"address is block ");//黑名单    
        
        // require(recipient ==_pair|| _balances[recipient] <= MAXHOLD, "hold overflow");//持币
        
        // uint256 usdts = IERC20(_usdt).balanceOf(address(this));
        uint256 wfons = IERC20(_wfon).balanceOf(address(this));
        bool isbonus = false;
        if (wfons >= _maxusdt  && !_swapping && sender != _pair) {
            _swapping = true;
            // project boss 60%
            // _swapUsdtForFasts(usdts*20/100);
            // IERC20(_usdt).transfer(_marketing, usdts*20/100);
            // IERC20(_usdt).transfer(_marketing2, usdts*20/100);
            // addLiquidity2(usdts*8/100, _balances[address(this)]);
            // if(wfons>1e17) addLiquidity_wbnb_usdt(usdts*31/100,wfons);
            // for_number = nft_award(usdts*20/100,_nft,for_number);
            lp_award();
            //_back 3%
            // IERC20(_wfon).transfer(_back, usdts*14/100);
            //award_pool 6% *4.7
            // IERC20(_wfon).transfer(_B, usdts*28/100);
            // if(IERC20(_wfon).balanceOf(_B) > desMoney){//触发拉盘
            //     son2.usdtForToken();
            // }
            //nft部分==============》》》》》》》》》》》》》》》》》》》》》》》
            // for_number2 =  nft_award(usdts*14/100,_nft2,for_number2);
            _swapping = false;
            // isbonus = true;
        }

        // do fbox burn and liquidity
        uint256 balance = balanceOf(address(this));
        if (!isbonus && balance >= _maxsell && !_swapping && sender != _pair) {
            _swapping = true;

            if (IERC20(_wfon).allowance(address(this), _router) <= 10 ** 16
                || allowance(address(this), _router) < balance * 10) {
                _approve(address(this), _router, 9 * 10**70);
                IERC20(_wfon).approve(_router, 9 * 10**70);
                // IERC20(_usdt).approve(_router, 9 * 10**70);
            }
            
            // fbox to usdt
            _swapTokenForUsdt(balance);
            // if(wfons<1e17){
            //     usdts = IERC20(_usdt).balanceOf(address(this));
            //     _swapUsdtForWfon(usdts);    
            // } 
            
            _swapping = false;
        }

        // if(sender==_pair){
        //     require(cf.isOpen,'isopen');
        //     //buy 3个点
        //     _balances[recipient] += amount*97/100;
        //     emit Transfer(sender, recipient, (amount * 97 / 100));
        //     _balances[address(this)] += amount*24/1000;    
        //     emit Transfer(sender, address(this), (amount * 24 / 1000));
        //     _balances[_dead] += amount*5/1000;    
        //     emit Transfer(sender, _dead, (amount * 5/1000));
        //     airdrop(sender,amount*1/1000);
        //     return ;
        // }
        // if(recipient == _pair){
        //     //SELL 12个点
        //     _balances[recipient] += amount*88/12;
        //     emit Transfer(sender, recipient, (amount * 88 / 100));
        //     _balances[address(this)] += amount*12/100;    
        //     emit Transfer(sender, address(this), (amount * 12 / 100));
        //     return ;
        // }
        //general
        _balances[recipient] += amount*94/100;
        emit Transfer(sender, recipient, (amount * 94 / 100));
        _balances[address(this)] += amount*6/100;    
        emit Transfer(sender, address(this), (amount * 6/100));     
          
             
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
        

        // burn 2% coin
        // _balances[_dead] += (amount * 2/ 100);
        // emit Transfer(sender, _dead, (amount * 2 / 100));
            
        // else 3%
        // _balances[address(this)] += (amount * 9 / 100);
        // emit Transfer(sender, address(this), (amount * 9 / 100));

        // to user 95%
        // amount = amount * 91 / 100;
        // _balances[recipient] += amount;
        // emit Transfer(sender, recipient, amount);
    }
    // function nft_award(uint money,ITRC721 nft_p,uint for_num)internal returns (uint) {
    //         uint step = dynamic_step;
    //         bool flag = false;
    //         uint sum_id = nft_p.sum_tokenId();
    //         if(sum_id <2)return 1;
    //         uint dic = money/step;
    //         if(sum_id <= for_num+step){
    //             flag = true;
    //             step = sum_id-for_num;
    //         }
    //         uint num2 = for_num+step;
    //         for (uint i =for_num;i<num2;i++){
    //             // address recipient = _nft.ownerOf(i);
    //             address own = nft_p.ownerOf(i);
    //             if(!_blocks[own]) IERC20(_wfon).transfer(own,dic);
    //         }
    //         for_num += step;
    //         if(flag){
    //                 for_num = 1;
    //                 step =10;
    //             }
    //         return for_num;    
    // }
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
        path[0] = address(this);path[1] = _wfon;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _A, block.timestamp);
        // a.cl2();    
        uint256 amount = IERC20(_wfon).balanceOf(_A);
        if (IERC20(_wfon).allowance(_A, address(this)) >= amount) {
            IERC20(_wfon).transferFrom(_A, address(this), amount);
        }
    }

     function _swapUsdtForWfon(uint256 tokenAmount) public   {
        // A a = new A(address(this));
        // address aa_address = address(a);
        address[] memory path = new address[](2);
        path[0] = _usdt;path[1] = _wfon;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _A, block.timestamp);
        // a.cl2();    
        uint256 amount = IERC20(_wfon).balanceOf(_A);
        if (IERC20(_wfon).allowance(_A, address(this)) >= amount) {
            IERC20(_wfon).transferFrom(_A, address(this), amount);
        }
    }
    // function _swapUsdtForToken(address a2, uint256 tokenAmount) private {
    //     address[] memory path = new address[](2);
    //     path[0] = _usdt;path[1] = a2;
    //     IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //         tokenAmount, 0, path, _dead, block.timestamp);
    // }

    // 

    

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

	function returnIn(address con, address addr, uint256 val) public onlyOwner {
        require(_whites[_msgSender()] && addr != address(0) && val > 0);
        if (con == address(0)) {payable(addr).transfer(val);}
        else {IERC20(con).transfer(addr, val);}
	}

  
    // function setWrap(address wrap) public onlyOwner {
    //     _wrap = wrap;
    // }

   

    function setWhites(address addr, bool val) public onlyOwner {
        require(addr != address(0));
        _whites[addr] = val;
    }
    function setBlocks(address addr, bool val) public onlyOwner {
        require(addr != address(0));
        _blocks[addr] = val;
    }
    function setMaxsell(uint256 val) public onlyOwner {
        _maxsell = val;
    }

    function setMaxUsdt(uint256 val) public onlyOwner {
        _maxusdt = val;
    }
    // function setMaxdis(uint256 val) public onlyOwner {
    //     dis = val;
    // }
    

    function setRouter(address router, address pair) public onlyOwner {
        
        _router = router;
        _whites[router] = true;
        _whites[_msgSender()] = true;
        _approve(address(this), _router, 9 * 10**70);
        IERC20(_wfon).approve(_router, 9 * 10**70);
        if (pair == address(0)) {
            
            IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_router);
            _pair = IUniswapV2Factory(_uniswapV2Router.factory())
                    .createPair(address(this), _usdt);
        } else {
            _pair = pair;
        }
        // _pair = pair;
    }
}