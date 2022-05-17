/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

//便携式开发者平台《比特熊》
//////www.bitbear.info////////
// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.13;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


}

contract BBTFactory {
    event CreatToken(address deployer , address token);
     mapping(address => address)getToken;
     uint256 public acounts;

    function creatNewToken(string memory _names,string memory _symbles, uint8 _decimals, uint256 _totals , uint256 kbn , address payable markaddr,uint256 marfee, uint256 burnfee) external returns(address) {
       BitBearTOKEN Ftoken = new BitBearTOKEN(_names,_symbles,_decimals,_totals,msg.sender,kbn , markaddr,marfee,burnfee);
        getToken[msg.sender] = address(Ftoken);
        emit CreatToken(address(msg.sender),address(Ftoken));
        acounts++;

        return address(Ftoken);
    }

    function TokenAddr(address account) external view returns(address){
    return getToken[account];  
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
    
  
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
   
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

interface IUniswapV2Router02 is IUniswapV2Router01 {
 
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}




contract BitBearTOKEN is IERC20  {
    using SafeMath for uint256;
    using Address for address;

    string  internal _name;
    string  internal _symbol;
    uint8   internal _decimals;
    uint256 internal  _totalSupply;
    
    mapping (address => uint256) internal _balanceOf;
    mapping (address => mapping(address => uint256)) internal _allowance;
    mapping (address => bool) public isMarketPair; 
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isBOT;

    address internal _owner;
    address internal pair;
    address public  marktingAddress;
    IUniswapV2Router02 public router;

    uint256 public launchBlock;
    uint256 public numberOfSnipe;
    uint256 internal KBnum;
    uint256 public minswapnum;

    uint256 internal marktingfee;
    uint256 internal burnfee;

    bool public _ismobility;
    bool internal lock;

    modifier lockTheSwap {
        lock = true;
        _;
        lock = false;
    }
    modifier onlyOwner { require(msg.sender == _owner); _;}
    constructor(string memory names, string memory symbols, uint8 dec, uint256 total,address owners , uint256 kbn , address payable markaddr,uint256 marfees, uint256 burnfees) {
         router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //TEST
         pair = IUniswapV2Factory(router.factory()).createPair(address(this),address(router.WETH()));

        _name = names;
        _symbol = symbols;
        _decimals = dec;
        _totalSupply = total * (10**_decimals);
        _owner = owners;
        KBnum = kbn;
        marktingAddress = markaddr;
        marktingfee = marfees;
        burnfee = burnfees;


        minswapnum = (total * 3 / 100) * (10**3);

        isMarketPair[address(pair)] = true;
        isExcludedFromFee[owners] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[markaddr] = true;

        _balanceOf[owners] = _totalSupply;
        emit Transfer (address(0) ,_owner , _totalSupply);
    }

    receive() external payable {}

    function setFee(uint256 _marfee , uint256 _burnfee) external onlyOwner {
        require(_marfee.add(_burnfee) <= 20);
        marktingfee = _marfee;
        burnfee = _burnfee;
    }

    function Ownership() external onlyOwner {
        _owner = address(0);
    }

    function setMarktingWallet(address payable _val) external onlyOwner {
       marktingAddress = _val;
        isExcludedFromFee[_val] = true;
    }








    //////////////////////ERC20 VIEW///////////////////////
    function name() external  override view returns (string memory){ return _name;}
    function symbol() external override  view returns (string memory){return _symbol;}
    function decimals() external override view returns (uint8){return _decimals;}
    function owner() external view returns(address){return _owner;}
    function totalSupply() public override view returns (uint256){return _totalSupply;}
    function balanceOf(address account) public override view returns (uint256){return _balanceOf[account];}
    function approve(address spender, uint256 amount) external override returns (bool){
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address sender, address spender, uint256 amounts) private {
         require(sender != address(0), "ERC20: approve from the zero address");
         require(spender != address(0), "ERC20: approve to the zero address");
         require(balanceOf(sender) >= amounts);
        _allowance[sender][spender] = amounts;
        emit Approval(sender, spender, amounts);

    }
    function allowance(address owners, address spender) external override view returns (uint256){
         return _allowance[owners][spender];
    }
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool){
        require(_balanceOf[sender] >= amount , 'IS NOT ENOUGH');
        require(sender != (address(0)), "is address 0");

         uint256 allowancess = _allowance[sender][msg.sender];
         require(allowancess >= amount);
         unchecked{_allowance[sender][msg.sender] = _allowance[sender][msg.sender].sub(amount);}

        _transfer(sender, recipient, amount);
        return true;
    }
    function transfer(address recipient, uint256 amount) external override returns (bool){
        require(msg.sender != address(0));
        require(_balanceOf[msg.sender] >= amount , "is not enough");
        _transfer(msg.sender, recipient , amount);
        return true;
    }

    //////////////////////TRANSFER///////////////////////
    function _transfer(address from , address  to ,uint256 amount) internal returns(bool) {
        require(!isBOT[from] && !isBOT[to]);

        if(!_ismobility  && isMarketPair[to]){  
         _ismobility = true;
         launchBlock = block.number;
         }

        if(!_ismobility){   
          return UNcost(from , to,amount);
        }

        if(_ismobility){
            if(lock) {
                return UNcost(from,to,amount);
            }else{
                uint256 contractBlance = balanceOf(address(this));
                bool canswap = contractBlance >= minswapnum;

                if(canswap && !isMarketPair[from] && !lock){
                    swaptokenforETH(contractBlance);

                     uint256 contractETH = address(this).balance;
                     if(contractETH > 0){
                         swapETHforWallet(contractETH);
                     }
                }

             uint256 shouldAmount = takeFee(from , to , amount);
             unchecked{ _balanceOf[from] = _balanceOf[from].sub(amount);}
             unchecked{_balanceOf[to] = _balanceOf[to].add(shouldAmount);}
             emit Transfer(from , to ,shouldAmount);

            }
        }
       return true;
    }


    function swaptokenforETH(uint256 tokenAmount) private lockTheSwap {
        _approve(address(this),address(router),tokenAmount);
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

       
       router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }


    function swapETHforWallet(uint256 tokenETH) private {
        payable(marktingAddress).transfer(tokenETH);
    }

    function takeFee(address _from, address _to, uint256 _amount) internal returns(uint256){
         uint256 burnsFee;
         uint256 markFee;

          if(launchBlock.add(KBnum) > block.number && !isExcludedFromFee[_from] && !isExcludedFromFee[_to]){
             burnsFee = _amount.mul(30).div(100);
              unchecked{_balanceOf[address(0)] = _balanceOf[address(0)].add(burnsFee);}
              emit Transfer(_from ,address(0),burnsFee);   
              if(pair != _to){
                  addBots(_to);
                }
          }else{
              if(isExcludedFromFee[_from] || isExcludedFromFee[_to]){
                  return _amount;
              }else{
                  burnsFee = _amount.mul(burnfee).div(100);
                  unchecked{_balanceOf[address(0)] = _balanceOf[address(0)].add(burnsFee);}
                  emit Transfer(_from ,address(0),burnsFee);

                  markFee = _amount.mul(marktingfee).div(100);
                  unchecked{_balanceOf[address(this)] = _balanceOf[address(this)].add(markFee);}
                  emit Transfer(_from ,address(this),markFee);
              }
          }

          return _amount.sub(burnsFee).sub(markFee);
    }


    function UNcost(address from , address to , uint256 amount) internal returns(bool) {
        unchecked{_balanceOf[from] = _balanceOf[from] .sub(amount);}
        unchecked{_balanceOf[to] = _balanceOf[to] .add(amount);}
        emit Transfer(from , to , amount);
        return true;
    }

     function addBots(address bot) private  {
        isBOT[bot] = true;
        numberOfSnipe++;
    }

}