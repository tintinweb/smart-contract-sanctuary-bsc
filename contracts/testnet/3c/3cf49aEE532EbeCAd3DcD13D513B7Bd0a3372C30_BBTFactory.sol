/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external  view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external  returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
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
contract BBTFactory {
    event CreatToken(address deployer , address token);
     mapping(address => address)getToken;
     uint256 public acounts;

    function creatNewToken(
        string memory _names,
        string memory _symbles,
        uint8 _decimals,
        uint256 _totals ,
        address payable devaddr,
        address payable markaddr,
        uint256[2] memory fees,
        uint256 _maxtx,
        uint256 limitx
        )

       external returns(address) {
       BitBearTOKEN Ftoken = new BitBearTOKEN(msg.sender,_names,_symbles,_decimals,_totals,
       devaddr, markaddr,fees,_maxtx,limitx);
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


 /////////////////////ERC20 TOKEN////////////////////////
  contract BitBearTOKEN is IERC20Metadata {
        using SafeMath for uint256;

        mapping (address => uint256) private _balances;  
        mapping (address => mapping(address => uint256)) private _allowances;  
        mapping (address => bool) public isExcludFee; 
        mapping (address => bool) public isLimitExempt;
        mapping (address => bool) public _isRobot;
        mapping (address => bool) public isMarkPair;

        bool public ismobility; 
        
        string  private _name ;
        string  private _symbol;
        uint8   private _decimals;
        uint256 private _totalSupply;

        address internal Owner; 
        address internal pair;
        IUniswapV2Router02 public router;
        address internal devAddress; 
        address internal marketAddress;
        ///////The current contract storage is used by default//////
        address internal layIn;


        uint256 buyTax;
        uint256 sellTax;

        uint256 internal maxTxAmount; 
        ////////Participation amount//////
        uint256 internal NDlimit; 

        uint256 public launchBlock;
        uint256 public Scientist;
     
        constructor (
            address owners,string memory names, string memory symbols,uint8 dec, uint256 totals,
            address devaddr,address markaddr,uint256[2] memory fees, uint256 maxTx, uint256 limiTx
            )  {
            router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //TEST
              pair = IUniswapV2Factory(router.factory()).createPair(address(this),address(router.WETH()));

            Owner = owners;
            _name = names;
            _symbol = symbols;
            _decimals = dec;
            _totalSupply = totals *(10**dec);
            devAddress = devaddr;
            marketAddress = markaddr;
            buyTax = fees[0];
            sellTax= fees[1];
            maxTxAmount = maxTx * (10**dec);
            NDlimit = limiTx * (10**dec); 


            isExcludFee[owners] = true;
            isExcludFee[devaddr] =true;
            isExcludFee[markaddr] = true;
            isExcludFee[address(this)] =true;

            layIn = address(address(this));

            isLimitExempt[owners] =true;
            isLimitExempt[markaddr] = true;
            isLimitExempt[address(this)] = true;
            isLimitExempt[devaddr] = true;
            isLimitExempt[address(0)] = true;

            isMarkPair[pair] = true;

            _balances[owners] = _totalSupply;
            emit Transfer(address(0) , owners , _totalSupply);
        }

    modifier onlyOwner { require(msg.sender == Owner); _;}

    function name() external virtual override view returns (string memory){return _name;}
    function symbol() external virtual override  view returns (string memory){return _symbol;}
    function decimals() external virtual override view returns (uint8){return _decimals;}
    function totalSupply() external virtual override view returns (uint256){return _totalSupply;}
    function balanceOf(address account)  external virtual override view returns (uint256){return _balances[account];}
    function owner() external view returns(address) { return Owner; }
    function Pair() external view returns(address){ return pair;}
    function getNextFee() external view returns(uint256){return _balances[address(this)].div(10 **_decimals); }

    

    function Renounce() external onlyOwner {
         Owner = 0x000000000000000000000000000000000000dEaD;
     }

    function upDdLimit(uint256 val) external onlyOwner {
        NDlimit = val * (10 **_decimals); 
    }

    function upMaxSwap( uint256 value) external onlyOwner { 
        maxTxAmount  = value * ( 10**_decimals);
    }

    function upDev(address _newAddr) external onlyOwner {
        isExcludFee[_newAddr] =true;
        isLimitExempt[_newAddr] =true;
        devAddress = _newAddr;
    }
     function upmarket(address _newAddr) external onlyOwner {
        isExcludFee[_newAddr] =true;
        isLimitExempt[_newAddr] =true;
        marketAddress = _newAddr;
    }
    
   
    function allowance( address _owner, address spender)  external virtual override  view returns (uint256){
        return _allowances[_owner][spender];
    }
    function approve( address spender, uint256 amount)   external   virtual  override   returns (bool){
        require(msg.sender != address(0) , "ERC20: Sender prohibit address 0 ");
        require(spender != address(0),"ERC20: spender prohibit address 0"); 
        require(_balances[msg.sender] >= amount);
         _allowances[msg.sender][spender] = amount;
         emit Approval(msg.sender , spender , amount);
         return true;
    }
    function transfer( address recipient, uint256 amount)  external virtual  override returns (bool){
        require(msg.sender != address(0) , "ERC20: Sender prohibit address 0");
        require(recipient !=  address(0) , "ERC20 : recipient prohibit address 0");
        _transfer(msg.sender , recipient , amount);
        return true;
    }
    function transferFrom(address sender,address recipient,uint256 amount) external  virtual  override returns (bool){
        require(sender != address(0) , "ERC20: sender prohibit address (0)");
        require(recipient != address(0) , "ERC20 : recipient prohibit address(0)");
        uint256 allowancess = _allowances[sender][msg.sender];
        require(allowancess >= amount);
        unchecked{
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);
            }
        _transfer(sender , recipient , amount);
        return true;
    }
    function _transfer( address from ,  address to , uint256 amounts) internal {
        require(!_isRobot[from] && !_isRobot[to]);
 
        if(isMarkPair[to] && !ismobility){  
           ismobility = true;        
           launchBlock = block.number; 
        }

        if(!ismobility){
           Uncost(from , to ,  amounts);
     }
        if(ismobility && !isLimitExempt[from] && !isLimitExempt[to]) { 
            require(amounts <= maxTxAmount  , "Max Exchange");
    }
        if(ismobility){
        uint256 shouldfee = takeFees(from, to ,amounts);
        unchecked{ _balances[from] = _balances[from].sub(amounts);}
        unchecked{_balances[to] = _balances[to].add(shouldfee);}
        emit Transfer(from , to , shouldfee);
       } 
    }

    function Uncost(address from , address to , uint256 amount) internal returns(bool) {
         unchecked{ _balances[from] = _balances[from].sub(amount);}
         unchecked{ _balances[to] = _balances[to].add(amount);}
         emit Transfer(from , to , amount);
         return true;
    }


    function takeFees(address from,address to,uint256 amount)internal returns(uint256){
           uint256 buyfee;
           uint256 sellfee;

           uint256 burns;
           uint256 devs;
           uint256 marks;
           uint256 nexts;

        if(launchBlock.add(3) > block.number && !isExcludFee[from]){          
            burns = amount.mul(30).div(100);
            unchecked{
                _balances[address(0)] = _balances[address(0)].add(burns);
                }
            if(!isMarkPair[to]){
                 addBots(to);
                 }
            emit Transfer(from , address(0), burns);
        } else{
              if(isExcludFee[from] || isExcludFee[to]) { 
                    return amount;
                 }else{ 
            if(!isMarkPair[to]){ 
                             if(isMarkPair[from]&&_balances[address(this)] > 1 && amount >= NDlimit){
                                 uint256 quantity = _balances[address(this)];
                                 _balances[address(this)] = _balances[address(this)].sub(quantity);
                                 _balances[to] = _balances[to].add(quantity);

                                 emit Transfer(address(this),to,quantity);
                             }
                  buyfee = amount.mul(buyTax).div(100);   

                  burns  = buyfee.mul(1).div(3);
                  devs   = buyfee.mul(1).div(3);
                  marks  = buyfee.sub(burns).sub(devs);

                 unchecked{_balances[address(0)] = _balances[address(0)].add(burns);}
                 emit Transfer(from , address(0) , burns);

                 unchecked{ _balances[devAddress] = _balances[devAddress].add(devs);}
                 emit Transfer(from , address(devAddress), devs);

                 unchecked{_balances[marketAddress] = _balances[marketAddress].add(marks);}
                 emit Transfer(from , address(marketAddress), marks);
                      }
            if(isMarkPair[to]){  
                         sellfee = amount.mul(sellTax).div(100);  
                           devs   = sellfee.mul(10).div(100);
                           marks  = sellfee.mul(20).div(100);
                           nexts  =sellfee.sub(devs).sub(marks);

                           unchecked{
                               _balances[devAddress] = _balances[devAddress].add(devs);}
                           emit Transfer(from , address(devAddress), devs);

                           unchecked{
                               _balances[marketAddress] = _balances[marketAddress].add(marks);}
                           emit Transfer(from , address(marketAddress), marks);

                           unchecked{
                               _balances[layIn] = _balances[layIn].add(nexts);}
                           emit Transfer(from, address(layIn), nexts);
                      }

                }
            }

             return amount.sub(buyfee).sub(sellfee);
    }
    function addBots(address bot) internal {
            _isRobot[bot] = true;
            Scientist++;
        }

     
}