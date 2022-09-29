/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.16;

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
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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
}


contract BalckGoldDogeToken is IERC20 { 
  using SafeMath for uint256;
  using Address for address;
    
    mapping (address => uint256) internal _balanceof;
    mapping (address => mapping(address => uint256)) internal _allowance;
    mapping (address => bool) public isBlacklist;
    mapping (address => bool) internal isExclude;
    mapping (address => bool) internal isMarketPair;
    mapping (address => uint256) shareholderIndexes;
    mapping(address => bool) private _updated;
    mapping (address => bool) isDividendExempt;
    event SwapTokensForETH(uint256 amountIn,address[] path );

//ERC20 INF0
    string  internal _name;
    string  internal _symbol;
    uint8   internal _decimals;
    uint256 internal _totalSupply;


 //fee
    uint256 public addLiquityfee = 1;
    uint256 public bnbRewardsfee = 1;
    uint256 public marktingfee = 3;
    uint256 public teamfee = 1; 

    uint256 internal maxTrade;  
    uint256 internal dispense; 
    uint256 distributorGas = 500000;
    address[] shareholders;
    address private fromAddress;
    address private toAddress;
    uint256 currentIndex;  
    uint256 minEthVal = 1000000;
    uint256 internal constant magnitude = 2**128; 

    address public teamWallet = 0xb90f1Ee6f32aECcC5096DC1ac3a433454f374936;
    address public marktingWallet = 0x9b9f008847d98a9b18ceD246547cfd26e13C7051;


    address internal _owner;
    address internal pair;

    bool internal  _ismobility;
    bool internal  _lock;

    IPancakeRouter02 internal Router;
    modifier onlydev {require (msg.sender == _owner);_;}
    modifier _lockTheSwap {_lock = true;_; _lock = false;}

    receive() external payable {}

    constructor () {
       _name = "BalckGoldDoge";
       _symbol = "BGD";
       _decimals = 9;
       _totalSupply = 100 * 10**15 * 10**_decimals;  
       maxTrade = 9 * 10**14 * 10**_decimals;  //lp -> 3%
       dispense = 100 * 10**5 * 10**_decimals;    

       //get pair    
       Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
       //router test 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3  
       //mainnet v2 0x10ED43C718714eb63d5aA57B78B54704E256024E
       pair = IPancakeFactory(Router.factory()).createPair(address(this),address(Router.WETH()));

       isExclude[address(this)] = true;
       isExclude[teamWallet] = true;
       isExclude[marktingWallet] = true;
       isExclude[address(0)] = true;
       isExclude[msg.sender] = true;

       isMarketPair[address(pair)] = true;

       isDividendExempt[address(pair)] = true;
       isDividendExempt[address(this)] = true;
       isDividendExempt[address(0)] = true;
       
       _owner = msg.sender;
       _balanceof[msg.sender] = _totalSupply; //mint
       emit Transfer (address(0) ,msg.sender , _totalSupply);
    }

    //view
    function name() external override view returns (string memory) { return _name; }
    function symbol() external view override returns (string memory){ return _symbol; }
    function decimals() external view override returns (uint8){ return _decimals; }
    function totalSupply() public override view returns (uint256){  return _totalSupply; }
    function balanceOf(address account) override public view returns (uint256) {return _balanceof[account];}
    function Owner() public view returns(address) {return _owner;}
    function Pair() external view returns(address) {return pair;}
    function allowance(address owner, address spender) external view returns (uint256){
         return _allowance[owner][spender];
    }


    //call
    function Renounce() external onlydev {
        _owner = address(0);
    }

    function setMaxTxAmout(uint256 val) external onlydev {
        maxTrade = val * 10**_decimals;
    }

    function addblacklist(address wallet, bool val) external onlydev {
        isBlacklist[wallet] = val;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender,spender,amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amounts) private {
         require(sender != address(0), "ERC20: approve from the zero address");
         require(spender != address(0), "ERC20: approve to the zero address");
         require(balanceOf(sender) >= amounts);
        _allowance[sender][spender] = amounts;
        emit Approval(sender, spender, amounts);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(msg.sender != address(0));
        require(_balanceof[msg.sender] >= amount , "is not enough");
        _transfer(msg.sender, recipient , amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool){
        require(_balanceof[sender] >= amount , "is not enough");
        require(sender != (address(0)), "is not address 0");
        uint256 allowancess = _allowance[sender][msg.sender];
        require(allowancess >= amount);
        unchecked{_allowance[sender][msg.sender] = _allowance[sender][msg.sender].sub(amount);}
        _transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(address from , address to , uint256 amount) internal returns(bool) {
       require(!isBlacklist[from] && !isBlacklist[to]);
       
       if(!_ismobility  && isMarketPair[to]){  
         _ismobility = true;
         }

        if(!_ismobility){   
          return UNcost(from , to,amount);
        }


        if(_ismobility) {
          if(!isExclude[from] && !isExclude[to]){
            if(isMarketPair[from]) {require(balanceOf(to).add(amount) <= maxTrade );}
          }

           if(_lock){
               return UNcost(from , to,amount);
           }else {
             uint256 contractBlance = balanceOf(address(this));
             bool canswap = contractBlance >= dispense;

             if(canswap && !isMarketPair[from] && !_lock){
                   SwapFee(contractBlance);   
                }
           }

            uint256 shouldAmount = takeFee(from , to , amount);
            unchecked{_balanceof[from] = _balanceof[from].sub(amount);}
            unchecked{_balanceof[to] = _balanceof[to].add(shouldAmount);}
            emit Transfer(from , to ,shouldAmount);


            if(fromAddress == address(0) )fromAddress = from;
            if(toAddress == address(0) )toAddress = to;  
            if(!isDividendExempt[fromAddress]) setShare(fromAddress);
            if(!isDividendExempt[toAddress]  ) setShare(toAddress);

            fromAddress = from;
            toAddress = to;  
        }
      return true;
     }


     function UNcost(address from , address to , uint256 amount) internal returns(bool) {
        unchecked{_balanceof[from] = _balanceof[from] .sub(amount);}
        unchecked{_balanceof[to] = _balanceof[to] .add(amount);}
        emit Transfer(from , to , amount);
        return true;
    }  

     function takeFee(address from , address to , uint256 amount) internal returns(uint256) {
       uint256 WBNBfee;
       if(isExclude[from] || isExclude[to]) {
           return amount;
       }else{
            WBNBfee = amount.mul(bnbRewardsfee.add(marktingfee).add(teamfee).add(addLiquityfee)).div(100);
            unchecked{_balanceof[address(this)] = _balanceof[address(this)].add(WBNBfee);}
            emit Transfer(from,address(this),WBNBfee);
       }
       return amount.sub(WBNBfee);
    }

     function SwapFee(uint256 tokenAmount) private _lockTheSwap {

      uint256 lptokenAll = tokenAmount.mul(addLiquityfee).div(marktingfee.add(teamfee).add(bnbRewardsfee).add(addLiquityfee));
      uint256 lptokenAmount = lptokenAll.div(2);
      uint256 swaptokenAll = tokenAmount.sub(lptokenAmount);

        SwapTokenForBNB(swaptokenAll); //swap

        uint256 treatyBNB = address(this).balance;
        
        uint256 marktingBNB = treatyBNB.mul(marktingfee).div(marktingfee.add(teamfee).add(bnbRewardsfee).add(addLiquityfee));
        uint256 teamBNB = treatyBNB.mul(teamfee).div(marktingfee.add(teamfee).add(bnbRewardsfee).add(addLiquityfee));
        uint256 lpBNB = treatyBNB.mul(bnbRewardsfee).div(marktingfee.add(teamfee).add(bnbRewardsfee).add(addLiquityfee));
        uint256 halfLpBNB = lpBNB.div(2);
        uint256 rewardBNB = treatyBNB.sub(marktingBNB).sub(teamBNB).sub(halfLpBNB);
      

        if(marktingBNB > 0){
             swapETHforWallet(marktingWallet , marktingBNB);
        }
        if(teamBNB > 0){
             swapETHforWallet(teamWallet,teamBNB);
        }
        if(rewardBNB > minEthVal) {
            process(distributorGas , rewardBNB) ;
        }

        if(halfLpBNB > 0) {
          addliquity(lptokenAmount, halfLpBNB);
        }
    }


    function process(uint256 gas , uint256 rewardsbnbamount) private {
        uint256 shareholderCount = shareholders.length;
        if(shareholderCount == 0)return;
        uint256 nowbananceEth = rewardsbnbamount;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        uint256 divper = nowbananceEth.mul(magnitude).div(totalSupply());
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }
        uint256 amount   = balanceOf(shareholders[currentIndex]).mul(divper).div(magnitude);
  
         if( amount <  10) {
             currentIndex++;
             iterations++;
             return;
         }
         if(rewardsbnbamount  < amount )return;
            swapETHforWallet(shareholders[currentIndex],amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function SwapTokenForBNB(uint256 tokenAmount) private {
        _approve(address(this), address(Router) , tokenAmount);

       address[] memory path = new address[](2);
       path[0] = address(this);
       path[1] = Router.WETH();

       Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
          tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
         emit SwapTokensForETH(tokenAmount, path);
    }

    function swapETHforWallet( address wallet ,uint256 tokenETH) private {
        payable(wallet).transfer(tokenETH);
    }

    function setShare(address shareholder) private {
           if(_updated[shareholder] ){      
                if(balanceOf(shareholder) == 0) quitShare(shareholder);              
                return;  
           }
           if(balanceOf(shareholder) == 0) return;  
            addShareholder(shareholder);
            _updated[shareholder] = true;
    }

    function quitShare(address shareholder) private {
           removeShareholder(shareholder);   
           _updated[shareholder] = false; 
    }

    function addShareholder(address shareholder) private {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) private {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    function addliquity(uint256 tokenAmount , uint256 bnbAmount) private {
       _approve(address(this), address(Router), tokenAmount);

       //addliquity
       Router.addLiquidityETH{value:bnbAmount}(
        address(this),
        tokenAmount,
        0,
        0,
        Owner(),
        block.timestamp
       );
    }








}