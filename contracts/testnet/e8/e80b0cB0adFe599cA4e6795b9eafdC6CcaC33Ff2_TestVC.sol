/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

 //IERC20Metadata
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

/*abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}*/

//////Pancake
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

interface IPancakePair {
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

 //   function mint(address to) external returns (uint liquidity);
 //   function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
 //   function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
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


contract TestVC {

event DEPOSIT(address OWNER, uint VALUE);
event WITHDRAW(address OWNER, uint VALUE);
event TARGET_REACHED(uint VALUE);

     //TestNet BSC   
    address constant routerAddress=0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    //MainNet BSC
  //  address constant routerAddress=0x10ED43C718714eb63d5aA57B78B54704E256024E;
   
    IPancakeRouter02 private _pancakeRouter;
  //  address public _pancakePairAddress;
    address public MainWallet; //address of the wallet that controls the contract
     address public WorkHelperWallet; //address of the wallet used for automating tasks in the future. Has admin privelages
 //   address public BankWallet;
  //  address public PayoutContract;
    address  public USDContract;

  //  bool public AcceptingDeposits;
  //  bool public ClaimsEnabled;
  //  bool public TargetReached;
    bool public AutoSwapEnabled;
    bool distributeAtEthDeposit;
    bool distributeAtUSDDeposit;
   // uint minInvestment; //USD value
   // uint maxInvestment; //USD value
   // uint investmentGoal; //USD value
    uint maxGoalExceedance; //USD value
    uint GrandTotalInvested;
    uint USDdecimals;
    uint64 public DisplayFromID;

//mapping (address => mapping (address => uint)) private __allowances;

 //   mapping(address => uint256) public balanceUSD;
  //  mapping(address => uint256) public tokensReceived;
  //  mapping(uint256 => address) public investorID;

    

/*    struct SaleInfo { 
     string SaleName;
     string logoURL;
     address payoutToken;
     address BankWallet;

     uint64 minInvestment;
     uint64 maxInvestment;
     uint64 InvestmentGoal;

     bool AcceptingDeposits;
     bool isActive;
}*/

 /*   struct Sale { 

     uint64 starttime;
     uint64 endtime;
     
     uint256 TokensClaimed; //claimed tokens
     uint256 TotalTokens; //original token deposit amount
     uint256 totalInvested; //BUSD invested

    uint64 N_Investors;  
    uint64 SaleID;
}*/
//mapping(uint64 => Sale) public Sales;
//mapping(uint64 => SaleInfo) public SalesInfo;

mapping (address => mapping (uint64 => uint256)) public _balanceUSD;
mapping (address => mapping (uint64 => uint256)) public _totalUSDshare;
mapping (address => mapping (uint64 => uint256)) public _tokensReceived;
//mapping (address => mapping (uint64 => uint256)) public _tokenPortionClaimed;
mapping (uint64 => mapping (uint64 => address)) public _investorID;

     mapping(uint64 => string) SaleName;
     mapping(uint64 => string) logoURL;
     mapping(uint64 => address) payoutToken;
     mapping(uint64 => address) BankWallet;

     mapping(uint64 => uint256) minInvestment;
     mapping(uint64 => uint256) maxInvestment;
     mapping(uint64 => uint256) InvestmentGoal;

     mapping(uint64 => bool) AcceptingDeposits;
     mapping(uint64 => bool) ClaimsEnabled;
     mapping(uint64 => bool) isActive;

     mapping(uint64 => uint256) starttime;
     mapping(uint64 => uint256) endtime;
     
     mapping(uint64 => uint256) TokensClaimed; //claimed tokens
     mapping(uint64 => uint256) TotalTokens; //original token deposit amount
     mapping(uint64 => uint256) MaxTotalTokens; //original token deposit amount
     mapping(uint64 => uint256) totalInvested; //BUSD invested
     mapping(uint64 => uint256) public VestingPeriod;
     mapping(uint64 => uint256) public ClaimStartTime;
     mapping(uint64 => uint256) public NumberofPayouts;


    mapping(uint64 => uint64) public N_Investors;  
    mapping(uint64 => uint64) SaleID;
    mapping(uint64 => bool) public TargetReached;

      //whitelist project functions

    mapping(uint64 => bool) public WhitelistRequired;
    mapping (address => mapping (uint64 => bool)) public _isWhitelisted;
    mapping(uint64 => uint64) public WhitelistLength;

    IERC20 USD; 
    IERC20 PayoutToken;
    uint256 public TotalUSDInvested;
    constructor() {
        _pancakeRouter = IPancakeRouter02(routerAddress);
 //      PayoutContract[0] = 0x8BaBbB98678facC7342735486C851ABD7A0d17Ca; // testnet ETH
   //     PayoutToken = IERC20(PayoutContract);

    //Default values
 /*   AcceptingDeposits = true;
    ClaimsEnabled = false;
    TargetReached = false;
    AutoSwapEnabled = true;
    distributeAtEthDeposit = true;
    distributeAtUSDDeposit = true;
    minInvestment = 1 * 10 ** 18; //USD value
    maxInvestment = 10000 * 10 ** 18; //USD value
    investmentGoal = 109000 * 10 ** 18; //USD value
    maxGoalExceedance = 500 * 10 ** 18; //USD value
    totalInvested = 0;
    USDdecimals = 18;
*/
    maxGoalExceedance = 500 * 10 ** 18; //USD value
    distributeAtEthDeposit = true;
    distributeAtUSDDeposit = true;
    USDdecimals = 18;
    AutoSwapEnabled = true;
//All control given to the contract creator
        MainWallet = msg.sender;
        WorkHelperWallet = msg.sender;
        BankWallet[0] = msg.sender;

   //TestNet BSC BUSD
        USDContract = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

        USD = IERC20(USDContract); 
    }

   //Admin reserved functions use this modifier. Similar to Ownership in some ERC20 contracts
    modifier onlyMain() {
      require((msg.sender == MainWallet)||(msg.sender == WorkHelperWallet));
      _;
   }    


   function StartNewProject(string memory ProjectName, string memory LogoURL, uint minimumInvestmentUSD, uint maximumInvestmentUSD, 
        uint256 InvestmentGoalUSD, address PayoutTokenAddr, address BankWalletAddr, uint256 DelaybeforeStart_h, uint256 Duration_h) public onlyMain()
   {
    uint64 ProjectID = NewestProjectID;   
    
    SaleID[ProjectID] = ProjectID;
    SaleName[ProjectID] = ProjectName;
    logoURL[ProjectID] = LogoURL;
    payoutToken[ProjectID] = PayoutTokenAddr;
    BankWallet[ProjectID] = BankWalletAddr;

    minInvestment[ProjectID] = minimumInvestmentUSD * 10 ** 18; //USD value
    maxInvestment[ProjectID] = maximumInvestmentUSD * 10 ** 18; //USD value
    InvestmentGoal[ProjectID] = InvestmentGoalUSD * 10 ** 18; //USD value

    isActive[ProjectID] = true;

 //if(DelaybeforeStart_h==0)
    AcceptingDeposits[ProjectID] = true;
   starttime[ProjectID] = block.timestamp + DelaybeforeStart_h * 3600;
 
    endtime[ProjectID] = starttime[ProjectID] + Duration_h * 3600;
    NumberofPayouts[ProjectID] = 1; //full amount as default 
    NewestProjectID++;
   }


   //mapping(uint64 => bool) public WhitelistRequired;
  //  mapping (address => mapping (uint64 => bool)) public _isWhitelisted;

//different from starting a project from whitelist. Use this when you only want certain wallets to be able to invest.
function setWhitelistforProject(uint64 ProjectID, address[] memory WLaddresses) public onlyMain()
{ WhitelistRequired[ProjectID] = true;
   for(uint64 i = 0; i < WLaddresses.length; i++)
   { 
      _isWhitelisted[WLaddresses[i]][ProjectID] = true;
   }
   WhitelistLength[ProjectID] = uint64(WLaddresses.length);
}

function setWhitelistRequiredforProject(uint64 ProjectID, bool isRequired) public onlyMain()
{
  WhitelistRequired[ProjectID] = isRequired;
}

function getProjectInvestorList(uint64 ProjectID) public view returns (address[] memory)
{ uint64 len = N_Investors[ProjectID]; 
  address[] memory retarr = new address[](len);
   for(uint64 i = 0; i < len; i++)
   { 
      retarr[i] = _investorID[ProjectID][i];
   }

   return retarr;
}

function getProjectInvestmentsList(uint64 ProjectID) public view returns (uint256[] memory)
{
  uint64 len = N_Investors[ProjectID]; 
  uint256[] memory retarr = new uint256[](len);
   for(uint64 i = 0; i < len; i++)
   {
      retarr[i] = _totalUSDshare[_investorID[ProjectID][i]][ProjectID];
   }

   return retarr;
}

function getProjectRemainingUSDList(uint64 ProjectID) public view returns (uint256[] memory)
{
   uint64 len = N_Investors[ProjectID]; 
   uint256[] memory retarr = new uint256[](len);
   for(uint64 i = 0; i < len; i++)
   {
      retarr[i] = _balanceUSD[_investorID[ProjectID][i]][ProjectID];
   }

   return retarr;
}

function getProjectTokensClaimedList(uint64 ProjectID) public view returns (uint256[] memory)
{
  uint64 len = N_Investors[ProjectID]; 
  uint256[] memory retarr = new uint256[](len);
   for(uint64 i = 0; i < len; i++)
   {
      retarr[i] = _tokensReceived[_investorID[ProjectID][i]][ProjectID];
   }

   return retarr;
}



//function for starting a project from an existing VC Whitelist.
 function StartNewProjectfromWhitelist(string memory ProjectName, string memory LogoURL, uint minimumInvestmentUSD, uint maximumInvestmentUSD, 
   address PayoutTokenAddr, address BankWalletAddr, address[] memory WLaddresses, uint256[] memory WLsharesUSD, uint256 MaxPayoutTokenAmount) public onlyMain()
   {

      uint64 Count = uint64(WLaddresses.length);
      require(Count > 0, "Whitelist empty");
      require(Count == WLsharesUSD.length, "Array lengths do not match");

    uint64 ProjectID = NewestProjectID;   
    
    SaleID[ProjectID] = ProjectID;
    SaleName[ProjectID] = ProjectName;
    logoURL[ProjectID] = LogoURL;
    payoutToken[ProjectID] = PayoutTokenAddr;
    BankWallet[ProjectID] = BankWalletAddr;

    minInvestment[ProjectID] = minimumInvestmentUSD * 10 ** 18; //USD value
    maxInvestment[ProjectID] = maximumInvestmentUSD * 10 ** 18; //USD value
   NumberofPayouts[ProjectID] = 1;
    MaxTotalTokens[ProjectID] = MaxPayoutTokenAmount;

  for(uint64 i = 0; i < Count; i++)
   {        if(_totalUSDshare[WLaddresses[i]][ProjectID]==0) //new investor
                {
                 _investorID[ProjectID][i] = WLaddresses[i];
                 N_Investors[ProjectID]++;
                }

                _balanceUSD[WLaddresses[i]][ProjectID] += WLsharesUSD[i];
                _totalUSDshare[WLaddresses[i]][ProjectID] += WLsharesUSD[i];
                totalInvested[ProjectID] += WLsharesUSD[i];
                TotalUSDInvested += totalInvested[ProjectID];
   }
   InvestmentGoal[ProjectID] = totalInvested[ProjectID];

    isActive[ProjectID] = true;

    AcceptingDeposits[ProjectID] = false;
    starttime[ProjectID] = block.timestamp;
 
    endtime[ProjectID] = starttime[ProjectID];  //investments already finished
     
    NewestProjectID++;
   }

//used for splitting vesting periods => copies parent investment attributes
   function DuplicateProjectfromParent(uint64 ParentProjectID) public onlyMain()
   {
      uint64 ProjectID = NewestProjectID;   
    
    SaleID[ProjectID] = SaleID[ParentProjectID];
    SaleName[ProjectID] = SaleName[ParentProjectID];
    logoURL[ProjectID] = logoURL[ParentProjectID];
    payoutToken[ProjectID] = payoutToken[ParentProjectID];
    BankWallet[ProjectID] = BankWallet[ParentProjectID];

    minInvestment[ProjectID] = minInvestment[ParentProjectID];
    maxInvestment[ProjectID] = maxInvestment[ParentProjectID];
    InvestmentGoal[ProjectID] = InvestmentGoal[ParentProjectID];

    isActive[ProjectID] = isActive[ParentProjectID];

    AcceptingDeposits[ProjectID] = false;
   starttime[ProjectID] = starttime[ParentProjectID];
 
    endtime[ProjectID] = endtime[ParentProjectID];
   NumberofPayouts[ProjectID] = 1;
N_Investors[ProjectID] = N_Investors[ParentProjectID];
totalInvested[ProjectID] = totalInvested[ParentProjectID];
     for(uint64 i = 0; i < N_Investors[ParentProjectID]; i++)
        {
            address investor = _investorID[ParentProjectID][i];
                 _investorID[ProjectID][i] = investor;
                _balanceUSD[investor][ProjectID] = _totalUSDshare[investor][ParentProjectID]; //amount reset
                _totalUSDshare[investor][ProjectID] = _totalUSDshare[investor][ParentProjectID];
                
        }        
     
    NewestProjectID++;
   }

         //function to change payout currency
         function setPayoutContract(uint64 ProjectID, address addr) public onlyMain()
       {  
          //PayoutContract = addr; 
          payoutToken[ProjectID] = addr;
         // PayoutToken = IERC20(addr);
       }

    //function to hide old / completed projects from dapp interface
         function setDisplayFromID(uint64 startPos) public onlyMain()
       {  
          DisplayFromID = startPos;
       }

         function setUSDContract(address addr) public onlyMain()
       {  
          USDContract = addr; 
          USD = IERC20(addr);
       }

       function getPayoutName(uint64 ProjectID) public view returns (string memory)
       { 
         return IERC20(payoutToken[ProjectID]).name();
       }

       function getPayoutSymbol(uint64 ProjectID) public view returns (string memory)
       {
         return IERC20(payoutToken[ProjectID]).symbol();
       }

       function getPayoutDecimals(uint64 ProjectID) public view returns (uint8)
       {
         return IERC20(payoutToken[ProjectID]).decimals();
       }
       
        function setMainWallet(address addr) public onlyMain()
       {  
          if(MainWallet != address(0))
          MainWallet = addr; 
       }
       
         function setHelperWallet(address addr) public onlyMain()
       {  
          WorkHelperWallet = addr;
       }

         function setMinInvestment(uint64 ProjectID, uint USDvalue) public onlyMain()
       {  
          minInvestment[ProjectID] = USDvalue * (10**USDdecimals);
       }

         function getMinInvestment(uint64 ProjectID) public view returns (uint)
       {  
          return minInvestment[ProjectID] / (10**USDdecimals);
       }

         function setMaxInvestment(uint64 ProjectID, uint USDvalue) public onlyMain()
       {  
          maxInvestment[ProjectID] = USDvalue * (10**USDdecimals);
       }
       

        function getMaxInvestment(uint64 ProjectID) public view returns (uint)
       {  
          return maxInvestment[ProjectID] / (10**USDdecimals);
       }

         function setmaxGoalExceedance(uint USDvalue) public onlyMain()
       {  
          maxGoalExceedance = USDvalue * (10**USDdecimals);
       }

        function setdistributeAtEthDeposit(bool enabled) public onlyMain()
       {  
          distributeAtEthDeposit = enabled;
       }

       function setdistributeAtUSDDeposit(bool enabled) public onlyMain()
       {  
          distributeAtUSDDeposit = enabled;
       }

       function getmaxGoalExceedance() public view returns (uint)
       {  
          return maxGoalExceedance / (10**USDdecimals);
       }
      
         function setInvestmentGoal(uint64 ProjectID, uint USDvalue) public onlyMain()
       {  
          InvestmentGoal[ProjectID] = USDvalue * (10**USDdecimals);
       }
       
        function getInvestmentGoal(uint64 ProjectID) public view returns (uint)
       {  
          return InvestmentGoal[ProjectID] / (10**USDdecimals);
       }

        function getUSDInvested(uint64 ProjectID) public view returns (uint)
       {  
          return totalInvested[ProjectID] / (10**USDdecimals);
       }

        function getTokensPaidOut(uint64 ProjectID) public view returns (uint)
       {  
          return TokensClaimed[ProjectID];
       }

        function getTotalTokens(uint64 ProjectID) public view returns (uint)
       {  
          return TotalTokens[ProjectID];
       }

        function getMaxTotalTokens(uint64 ProjectID) public view returns (uint)
       {  
          return MaxTotalTokens[ProjectID];
       }

       function getPercInvested(uint64 ProjectID) public view returns (uint)
       {  
          return 100 * totalInvested[ProjectID] / InvestmentGoal[ProjectID];
       }

         function setUSDdecimals(uint dec) public onlyMain()
       {  
          USDdecimals = dec;
       }

         function enableDeposits(uint64 ProjectID) public onlyMain()
       {  
          AcceptingDeposits[ProjectID] = true;
       }

         function enableAutoSwap() public onlyMain()
       {  
          AutoSwapEnabled = true;
       }

         function disableAutoSwap() public onlyMain()
       {  
          AutoSwapEnabled = false;
       }

         function setProjectVisibility(uint64 ProjectID, bool isVisible) public onlyMain()
       {  
          isActive[ProjectID] = isVisible;
       }

         function setProjectName(uint64 ProjectID, string memory newName) public onlyMain()
       {  
          SaleName[ProjectID] = newName;
       }

         function setProjectURL(uint64 ProjectID, string memory newURL) public onlyMain()
       {  
          logoURL[ProjectID] = newURL;
       }

         function disableDeposits(uint64 ProjectID) public onlyMain()
       {  
          AcceptingDeposits[ProjectID] = false;
       }

    function getDepositedUSD(uint64 ProjectID,address holder) public view returns (uint)
       {  
          return _balanceUSD[holder][ProjectID] / (10**USDdecimals);
       }

           function getShareUSD(uint64 ProjectID,address holder) public view returns (uint)
       {  
          return _totalUSDshare[holder][ProjectID] / (10**USDdecimals);
       }


        function gettokensReceived(uint64 ProjectID,address holder) public view returns (uint)
       {  
          return _tokensReceived[holder][ProjectID];
       }

   /*      function getclaimableTokens(uint64 ProjectID,address holder) public view returns (uint)
       {  uint256 balance = getDepositedUSD(ProjectID,holder);
          uint256 Tokens = getTotalTokens(ProjectID); 
          uint256 TotalUSD = getUSDInvested(ProjectID);
            if((balance == 0)||(Tokens == 0))
            return 0;
            else
            return Tokens * balance / TotalUSD;
       }
    */   

    function getclaimableTokens(uint64 ProjectID,address holder) public view returns (uint)
       {  uint256 balance = getDepositedUSD(ProjectID,holder); 
          uint256 share = getShareUSD(ProjectID,holder);
          uint256 Tokens = getTotalTokens(ProjectID); 
          uint256 maxTokens = getMaxTotalTokens(ProjectID);
          uint256 TotalUSD = getUSDInvested(ProjectID);

            if(maxTokens == 0)
            return 0;

          uint256 AvailableTokenShare;

          if(VestingPeriod[ProjectID]>0) //preset intervals
           {
                  uint DaysProgress = (block.timestamp - ClaimStartTime[ProjectID]);
                  uint DaysPerPeriod = VestingPeriod[ProjectID]; 
                  uint PeriodsFinished = 1 + DaysProgress / DaysPerPeriod;
                  uint _TotalPayouts = NumberofPayouts[ProjectID];
                  if(PeriodsFinished > _TotalPayouts)
                   {
                      PeriodsFinished > _TotalPayouts;
                   }

                AvailableTokenShare = (maxTokens * share / TotalUSD) * PeriodsFinished / _TotalPayouts;  
           }
         else AvailableTokenShare = Tokens * share / TotalUSD;

          uint256 claimedTokenShare = _tokensReceived[holder][ProjectID];

            if((balance == 0)||(Tokens == 0))
            return 0;
            else
            return AvailableTokenShare - claimedTokenShare;
       }

         function getInvestorID(uint64 ProjectID, uint64 Num) public view returns (address)
       {  
          return _investorID[ProjectID][Num];
       }     

       
//Returns the USD value of ETH tokens to calculate investor share
   function getTokenprice(uint amountBNB) public view returns (uint256)
{
     address[] memory path = new address[](2);
        path[0] = _pancakeRouter.WETH();
        path[1] = address(USDContract);
       uint[] memory amounts =  _pancakeRouter.getAmountsOut(amountBNB, path);
        
       
    return amounts[1];    
}
 
function getCountDown(uint64 ProjectID) public view returns (uint256 Days, uint256 Hours, uint256 Minutes){
        uint256 currentTime = block.timestamp;
        uint256 endTime = endtime[ProjectID];
        
        if(currentTime < endTime)
         {
            uint256 RemainingTime = endTime - currentTime;
            Days = RemainingTime / 86400;
            Hours = RemainingTime / 3600 - Days*24;
            Minutes = RemainingTime / 60 - (Hours+Days*24)*60;
    
         }
         else
         {   
             Days = 0;
             Hours = 0;
             Minutes = 0;
         }
         
         return (Days, Hours, Minutes);
    }

 function getProjectDetails(uint64 ProjectID) public view returns (string memory Logo,string memory Name,
    string memory Status,uint USDInvested,uint PercInvested,uint Goal,uint TokensPaidOut,uint8 PayoutDecimals,
    uint totalTokens,uint MinInvest,uint MaxInvest) 
 {
 Logo = getProjectLogo(ProjectID);
 Name = getProjectName(ProjectID);
 Status = getProjectStatus(ProjectID);
 USDInvested = getUSDInvested(ProjectID);
 PercInvested = getPercInvested(ProjectID);
 Goal = getInvestmentGoal(ProjectID);
 TokensPaidOut = getTokensPaidOut(ProjectID);
 PayoutDecimals = getPayoutDecimals(ProjectID);
 totalTokens = getTotalTokens(ProjectID);
 MinInvest = getMinInvestment(ProjectID);
 MaxInvest = getMaxInvestment(ProjectID);

return (Logo, Name, Status, USDInvested, PercInvested, Goal, TokensPaidOut, PayoutDecimals,
     totalTokens, MinInvest, MaxInvest);
 }  

function countActiveProjects() public view returns (uint64 count)
{
  for(uint64 i = 0; i<NewestProjectID; i++)
     {if(isActive[i])
      count++;
     }
     return count;
}

 function getActiveProjects() public view returns (uint64 pos, uint64[] memory) 
 {  pos = 0;
    uint64[] memory IDlist = new uint64[](countActiveProjects()); 
     for(uint64 i = 0; i<NewestProjectID; i++)
     {if(isActive[i])
        {
            IDlist[pos] = i;
            pos++;
        }
     }

     return (pos, IDlist);
 }

 function getProjectName(uint64 ProjectID) public view returns (string memory)
 {
     return SaleName[ProjectID];
 }

  function getProjectLogo(uint64 ProjectID) public view returns (string memory)
 {
     return logoURL[ProjectID];
 }

 

   function getProjectStatus(uint64 ProjectID) public view returns (string memory)
 {
     if(isActive[ProjectID])
      {  if(ClaimsEnabled[ProjectID])
       { if(TokensClaimed[ProjectID] < TotalTokens[ProjectID])
         return "Claim Tokens";
         else
          if(TotalTokens[ProjectID]==0)
          return "Wait for Tokens";
          else
          return "All Tokens Claimed";
       }  
          else
          if(AcceptingDeposits[ProjectID])
          { uint time = block.timestamp;
           if(time>endtime[ProjectID])
            return "Deposits Closed";
           else 
           if(time<starttime[ProjectID])
            return "Project Starting Soon";
           else 
            {if(WhitelistRequired[ProjectID])
               return "Whitelist Investments Only";
             else  
               return "Accepting Investments";
            } 
          }
          else
          if(TargetReached[ProjectID])
          return "Target Reached";
          else
          return "Pending";
      }
      else
      return "Complete";
 }

function getClaimStatus(uint64 ProjectID) public view returns (bool)
{
    return ClaimsEnabled[ProjectID];
}

function getInvestStatus(uint64 ProjectID) public view returns (bool)
{
   return AcceptingDeposits[ProjectID];
}




// function to receive blockchain native currency directly (BNB, ETH, FTM etc.)
//To send USD tokens instead, use the DepositUSD function

uint64 NewestProjectID;
receive () external payable {
        uint64 projectID = NewestProjectID-1;
        uint64 InvestorCount = N_Investors[projectID];
        
       if(WhitelistRequired[projectID])
        require(_isWhitelisted[msg.sender][projectID],"Address not Whitelisted");

        uint time = block.timestamp;
        require(time<=endtime[projectID],"Project Closed");
        require(time>=starttime[projectID],"Project has not started");

            if(msg.value > 0)
             {
              require(AcceptingDeposits[projectID], "Deposits closed");
                uint USDvalue = getTokenprice(msg.value); //convert eth/bnb amount to USD value
                TotalUSDInvested += USDvalue;
                require(_totalUSDshare[msg.sender][projectID]+USDvalue <= maxInvestment[projectID], "Value exceeds maximum deposit");
                require(USDvalue >= minInvestment[projectID], "Value below minimum deposit");
                if(_totalUSDshare[msg.sender][projectID]==0) //new investor
                {
                _investorID[projectID][InvestorCount] = msg.sender;
                N_Investors[projectID]++;
                }

                _balanceUSD[msg.sender][projectID] += USDvalue;
                _totalUSDshare[msg.sender][projectID] += USDvalue;
                totalInvested[projectID] += USDvalue;
                
                emit DEPOSIT(msg.sender, USDvalue);

                if(distributeAtEthDeposit)
                    SendDepositsToBankWallet(projectID);

                if(totalInvested[projectID] >= InvestmentGoal[projectID]) //Finalize deposits
                 {
                    TargetReached[projectID] = true;
                     emit TARGET_REACHED(totalInvested[projectID]);
                     AcceptingDeposits[projectID] = false;
                 }        
             }
        }

 
function getUSDBalance() public view returns (uint256)
{
   return USD.balanceOf(address(this));
}   

function getPayoutTokenBalance(uint64 ProjectID) public view returns (uint256)
{
   return IERC20(payoutToken[ProjectID]).balanceOf(address(this));
}  

//minimum value = 10% of token balance to avoid decimal errors
/*function FundTokensBalanceToProject(uint64 ProjectID, address PayoutContractAddr, uint256 TokenAmount) public onlyMain()
{   
    uint256 Tokens;
    uint256 Balance = getPayoutTokenBalance(ProjectID);
    require(Balance > 0,"Token Balance = 0");
    if(TokenAmount==0) //zero input results in full balance being funded
     Tokens = Balance;
    else
     Tokens = TokenAmount; 
    require (Tokens > (Balance / 10), "Amount < 10%, check decimals?"); 
    require (Tokens <= Balance, "Amount > Balance, check decimals?"); 
    require(PayoutContractAddr == payoutToken[ProjectID]); //safety check
    require(Tokens>0,"NO TOKENS UPLOADED");
    require(ClaimsEnabled[ProjectID]==false,"Claims already enabled"); //safety check

    AcceptingDeposits[ProjectID] = false;
    TotalTokens[ProjectID] = Tokens;
    ClaimsEnabled[ProjectID] = true;
    
}
*/

function FundTokensBalanceToProject(uint64 ProjectID, address PayoutContractAddr, uint256 TokenAmount, uint256 MaxTokenAmount, uint256 daysbetweenpayouts, uint256 _NumberofPayouts) public onlyMain()
{   
    uint256 Tokens;
    uint256 Balance = getPayoutTokenBalance(ProjectID);
    require(Balance > 0,"Token Balance = 0");

    if(MaxTotalTokens[ProjectID]==0)
    {
       ClaimStartTime[ProjectID] = block.timestamp;
    }
    if(TokenAmount==0) //zero input results in full balance being funded
     Tokens = Balance;
     
    else
     Tokens = TokenAmount; 

         if(TokenAmount==0) //zero input results in full balance being funded
     MaxTotalTokens[ProjectID] = Tokens;    
    else
     MaxTotalTokens[ProjectID] = MaxTokenAmount; 
   // require (Tokens > (Balance / 10), "Amount < 10%, check decimals?"); 
   // require (Tokens <= Balance, "Amount > Balance, check decimals?"); 
    require(PayoutContractAddr == payoutToken[ProjectID]); //safety check
    require(Tokens>0,"NO TOKENS UPLOADED");
    
   // require(ClaimsEnabled[ProjectID]==false,"Claims already enabled"); //safety check
  
  if(daysbetweenpayouts>0)
   require(MaxTokenAmount == TokenAmount, "Combination not possible");

    AcceptingDeposits[ProjectID] = false;
    VestingPeriod[ProjectID] = daysbetweenpayouts; // * 3600 * 24; seconds used for debugging - change back
    require(_NumberofPayouts>0,"N Payouts = 0");
    NumberofPayouts[ProjectID] = _NumberofPayouts;
    require(TotalTokens[ProjectID] + Tokens <= MaxTokenAmount,"Token amount exceeds Max");
    TotalTokens[ProjectID] += Tokens;
    
    ClaimsEnabled[ProjectID] = true;
}

function setpayoutToken(uint64 ProjectID, address PayoutContractAddr) public onlyMain()
{
    require(PayoutContractAddr!=address(0));
    require(ClaimsEnabled[ProjectID]==false,"Claims already enabled");
    payoutToken[ProjectID] = PayoutContractAddr;
}
function getETHBalance() public view returns (uint256)
{
   return address(this).balance;
} 

function getMyUSDInvested(uint64 ProjectID) public view returns (uint256)
{
   return _balanceUSD[msg.sender][ProjectID];
} 

function getMyTokensClaimed(uint64 ProjectID) public view returns (uint256)
{
   return _tokensReceived[msg.sender][ProjectID];
} 

function getUSDcontractAddress() public view returns (address)
{
   return USDContract;
} 

//Function to deposit USD tokens to contract. 
// USDvalue is the amount of dollars to invest
//Before calling this function, make sure that the contract has sufficient allowance by calling approve 
// on the USD token contract with this contract address and the desired investment amount * 10^18 decimals
//DO NOT SEND USD TOKENS DIRECTLY TO THIS CONTRACT. ONLY USE THE DepositUSD function or send 
//blockchain native currency (BNB/ETH/FTM etc.) directly
 function DepositUSD(uint64 ProjectID,uint USDvalue) public

       {  
          if(WhitelistRequired[ProjectID])
        require(_isWhitelisted[msg.sender][ProjectID],"Address not Whitelisted");

          uint time = block.timestamp;
            require(time<=endtime[ProjectID],"Project Closed");
            require(time>=starttime[ProjectID],"Project has not started"); 
          require(AcceptingDeposits[ProjectID], "Deposits closed");
          require(_totalUSDshare[msg.sender][ProjectID]+USDvalue <= maxInvestment[ProjectID], "Value exceeds maximum deposit");
          require(USD.balanceOf(msg.sender)>= USDvalue, "Insufficient balance for deposit");
          require(USD.allowance(msg.sender,address(this))>= USDvalue, "Approval required to deposit");
          require(USDvalue >= minInvestment[ProjectID], "Value below minimum deposit");
          require(USD.transferFrom(msg.sender,BankWallet[ProjectID],USDvalue), "TransferFrom Failed");
          //success
          TotalUSDInvested += USDvalue;
          uint64 InvestorCount = N_Investors[ProjectID];
          if(_totalUSDshare[msg.sender][ProjectID]==0) //new investor
                {
                _investorID[ProjectID][InvestorCount] = msg.sender;
                N_Investors[ProjectID]++;
                }
             _balanceUSD[msg.sender][ProjectID] += USDvalue;
             _totalUSDshare[msg.sender][ProjectID] += USDvalue;
                totalInvested[ProjectID] += USDvalue;
                
                emit DEPOSIT(msg.sender, USDvalue);

                if(distributeAtUSDDeposit)
                    SendDepositsToBankWallet(ProjectID);

              if(totalInvested[ProjectID] >= InvestmentGoal[ProjectID]) //Finalize deposits
                 {
                    TargetReached[ProjectID] = true;
                     emit TARGET_REACHED(totalInvested[ProjectID]);
                     AcceptingDeposits[ProjectID] = false;
                 }          
                 
       } 

//Calculates the share of each investor and pays out tokens accordingly
function ClaimTokens(uint64 ProjectID, address recipient) internal returns (bool)
{ 
   require(ClaimsEnabled[ProjectID], "Claiming Disabled");
   require(TotalTokens[ProjectID] > 0, "Wait for Token Deposit");
   uint256 balance = _balanceUSD[recipient][ProjectID];

   if(balance>0)
   {
       uint256 share = getclaimableTokens(ProjectID,recipient);

       uint256 USDvalue = totalInvested[ProjectID] * share / MaxTotalTokens[ProjectID];
       
       _balanceUSD[recipient][ProjectID] -= USDvalue;
       bool success;
      if(share>0) 
      {
         uint256 contractbalance = IERC20(payoutToken[ProjectID]).balanceOf(address(this));
        if(share > contractbalance) 
        { //insufficient balance on contract, try to retrieve from bank wallet
        uint256 bankBalance = IERC20(payoutToken[ProjectID]).balanceOf(BankWallet[ProjectID]);
        if(share <= bankBalance)
         IERC20(payoutToken[ProjectID]).transferFrom(BankWallet[ProjectID],address(this),share);
         else
          return false; //unsiffucient funds available
        }
        
        success = IERC20(payoutToken[ProjectID]).transfer(recipient,share);
      }
      if(success)
      {
         TokensClaimed[ProjectID] += share; 
         _tokensReceived[recipient][ProjectID] += share;
         return true;
      }
      else 
      {
        _balanceUSD[recipient][ProjectID] = balance; // transfer failed
      }  

   }
  return false;
}

//Investor calls this function to claim his or her tokens
function ClaimMyTokens(uint64 ProjectID) public 
{
    require(ClaimTokens(ProjectID, msg.sender));
}

//Used to auto airdrop tokens to holders
//Avoid sending too many transfers in one go as a single failed transfer will cause all to revert.
//Increase gas limit by a couple of percent when calling this function to avoid unecessary failed transfers.
function DistributeTokens(uint64 ProjectID, uint64 startPos, uint64 endPos) public onlyMain() 
{
 if(endPos > N_Investors[ProjectID])
  endPos = N_Investors[ProjectID];
  for(uint64 i = startPos; i < endPos; i++)
  {
      ClaimTokens(ProjectID,_investorID[ProjectID][i]);
  }
}

//Sends USD token balance to bank wallet + converts ETH/BNB to USD token and sends.
//Called by deposit functions
function SendDepositsToBankWallet(uint64 ProjectID) public
{
 //send USD deposits
   //uint USDbal = USD.balanceOf(address(this));
   //if(USDbal > 0)
   //USD.transfer(BankWallet[ProjectID],USDbal);

//Swap and send ETH
   uint ETHbal = address(this).balance;

   if(ETHbal > 0)
   {
     if(AutoSwapEnabled)
     {
        _swapBNBforChosenTokenandPayout(ETHbal,USDContract, BankWallet[ProjectID]); //only for BUSD deposits
     }  
     else
     { //send eth/bnb directly without swapping
       (bool success, ) = BankWallet[ProjectID].call{ value: ETHbal }(new bytes(0));
        if(success){}
     } 
   }  

}

//Call this function after payout tokens have been deposited
function StartClaiming(uint64 ProjectID) public onlyMain() 
{
    AcceptingDeposits[ProjectID] = false;
    require(TotalTokens[ProjectID]>0,"NO TOKENS FUNDED");
    ClaimsEnabled[ProjectID] = true;
}

//function to recover tokens wrongfully sent to contract
function RecoverTokens(address ContractAddress, uint256 amount) public onlyMain()
{
    IERC20(ContractAddress).transfer(msg.sender,amount);
}

 /*Abi bytecodes for pancakerouter

{
    "ad5c4648": "WETH()",
    "e8e33700": "addLiquidity(address,address,uint256,uint256,uint256,uint256,address,uint256)",
    "f305d719": "addLiquidityETH(address,uint256,uint256,uint256,address,uint256)",
    "c45a0155": "factory()",
    "85f8c259": "getAmountIn(uint256,uint256,uint256)",
    "054d50d4": "getAmountOut(uint256,uint256,uint256)",
    "1f00ca74": "getAmountsIn(uint256,address[])",
    "d06ca61f": "getAmountsOut(uint256,address[])",
    "ad615dec": "quote(uint256,uint256,uint256)",
    "baa2abde": "removeLiquidity(address,address,uint256,uint256,uint256,address,uint256)",
    "02751cec": "removeLiquidityETH(address,uint256,uint256,uint256,address,uint256)",
    "af2979eb": "removeLiquidityETHSupportingFeeOnTransferTokens(address,uint256,uint256,uint256,address,uint256)",
    "ded9382a": "removeLiquidityETHWithPermit(address,uint256,uint256,uint256,address,uint256,bool,uint8,bytes32,bytes32)",
    "5b0d5984": "removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address,uint256,uint256,uint256,address,uint256,bool,uint8,bytes32,bytes32)",
    "2195995c": "removeLiquidityWithPermit(address,address,uint256,uint256,uint256,address,uint256,bool,uint8,bytes32,bytes32)",
    "fb3bdb41": "swapETHForExactTokens(uint256,address[],address,uint256)",
    "7ff36ab5": "swapExactETHForTokens(uint256,address[],address,uint256)",
    "b6f9de95": "swapExactETHForTokensSupportingFeeOnTransferTokens(uint256,address[],address,uint256)",
    "18cbafe5": "swapExactTokensForETH(uint256,uint256,address[],address,uint256)",
    "791ac947": "swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)",
    "38ed1739": "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)",
    "5c11d795": "swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)",
    "4a25d94a": "swapTokensForExactETH(uint256,uint256,address[],address,uint256)",
    "8803dbee": "swapTokensForExactTokens(uint256,uint256,address[],address,uint256)"
}*/   
       
    
 //Swaps ETH/BNB to USD token and transfers to external wallet. Works for receiver != address(this) 
 function _swapBNBforChosenTokenandPayout(uint256 amountBNB,address PayoutTokenContract, address receiver) internal returns (bool){

        address[] memory path = new address[](2);
        path[0] = _pancakeRouter.WETH();
        path[1] = address(PayoutTokenContract);

     _pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountBNB}(
            0,
            path,
            address(receiver),
            block.timestamp + 20
        );
     
     return true;
    }    
    
    
    
}