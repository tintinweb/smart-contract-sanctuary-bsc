/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

pragma solidity ^0.8.6;



// SPDX-License-Identifier: MIT
interface ERC20 {
    function totalSupply() external view returns (uint _totalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

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


    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

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



//Interface to generate the ABI code for the dapp

interface DAPP {
    function transfer(address _to, uint _value) external returns (bool success);
    function setMyAutoPayout(bool Checked)external returns (bool);
    function getMyAutoPayoutisActive() external view returns (bool);
    function ClaimMyRewards() external;
    function ChooseSinglePayoutToken(uint32 PayoutTokenNumber) external;
    function ChooseMultiplePayoutTokens(uint32 Token1,uint32 Slice1,uint32 Token2,uint32 Slice2,
                                            uint32 Token3,uint32 Slice3,uint32 Token4,uint32 Slice4,
                                            uint32 Token5,uint32 Slice5,uint32 Token6,uint32 Slice6) external;
    function getSellSlippage() external view  returns (uint32);
    function MyAvailableRewards() external view returns(uint256);
    function ShowMyRewardTOKENS() external view returns (uint32[6] memory tokennumbers);
    function ShowMyRewardSLICES() external view returns (uint32[6] memory slices);
    function ShowAllRewardTokens() external view returns (string[] memory Rewards); 
}
 
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED);
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}        



contract  SatoshiRoku is ERC20, ReentrancyGuard {
    string public constant symbol = "Satrok"; //UN-wrapped Satoshi
    string public constant name = "Satoshi Inu roku"; 
    uint8 public constant decimals = 18;

    //10,000,000,000+18 zeros
    uint256 constant initialSupply = 10000000000000000000000000000; //10 billion tokens
    uint256 __totalSupply = initialSupply;
    uint256 burnUntil; //buyback stop burning at 50% initial supply
    uint256 _maxTxAmount;//0.1% of total supply


    mapping (address => uint) private __balanceOf;

    mapping (address => mapping (address => uint)) private __allowances;
  
    mapping (address => uint256) private _earnings;
    mapping (address => uint256) private _PrevBalance;
    mapping (address => uint256) private _LastPayout;
  
    mapping (address => uint256) private _LastRewardCycle; 
    mapping (address => bool) private _excludedfromTax;
    mapping (address => RewardTokens) private _RewardTokens; //*
    mapping (address => bool) private _SplitTokenRewards;
    mapping (address => bool) private _AutoPayoutEnabled;
    mapping (address => bool) private _isregistered; 
    mapping (address => bool) private _isAdmin; 
 
   
   //* this struct is used to map reward token numbers and the percentage payout of each to holder addresses
    struct RewardTokens{
        uint32 Token1;
        uint32 Token2;
        uint32 Token3;
        uint32 Token4;
        uint32 Token5;
        uint32 Token6;
        uint32 Slice1;
        uint32 Slice2;
        uint32 Slice3;
        uint32 Slice4;
        uint32 Slice5;
        uint32 Slice6;
    }
    

   address[] private investorList; 
 
   address[] private AdminList;
   address[] public PayoutTokenList;
   string[] public PayoutTokenListNames;
   uint32 public RewardTokenoftheWeek;
   uint256 public distributedRewards;
   uint256 public Rewardcycle;
   uint256 public claimableBNBearnings;
   
    bool public _enableTax; 
    bool public _enableTransfer; 
    bool public _isLaunched; 
    
    bool public _CalculatingRewards; 
    bool public _AutoCalcRewards; 
    uint256 public HolderPos;
    uint256 public DistHolderPos;

    uint256 public N_holders;
    uint256 public N_Admin;
    uint32 private N_perTransfer;
    uint32 private N_payoutsperWorkRound; //@@@
    uint256 private nonce;

    
    uint256 public launch_time;
    uint32 public NumberofPayoutTokens;
    
    uint256 public LastRewardCalculationTime;
 
 //Tax reserves and pots kept public for maximum transparency  
    uint256 public LQPotBNB;
    uint256 public LQPotToken;
    uint256 public StakingBNB;
    
    uint256 public BuybackPotBNB;
    uint256 public GasPotBNB;
    uint256 public HolderPotBNB;
    uint256 public AdminPotBNB;
    uint256 public LotteryPot;
    uint256 public NextBuybackMemberCount;
    
    uint256 private HolderPotBNBcalc;
    uint256 private AdminPotBNBcalc;
    uint256 private CircSupplycalc;
    address private Contract;

   uint32 public SellSlippage;
   uint32 public NextTask;
   
   uint256 public SellTaxTokenPot;
   uint256 public SellTaxBNBPot;

   uint256 public BuyTaxPercentage = 5;
   uint32 public SellTaxPercentage = 5;

   
   uint256 public BuyTaxTokenPot;
   uint256 public BuyTaxBNBPot;
   address public StakingWallet;
   bool private SingleUntaxedTransfer;
 
    uint32 private Buyback_increment; 
 
     
event Buyback_(uint256 TokensBought, uint256 NumberofHolders);
event TokensBurned(uint256 amount);
event LotteryWon_(address _winner, uint256 _tokenAmount);
event RewardsRecalculated();
event TOKEN_LAUNCHED();


     modifier onlyAdmin() {
            
        if(_isAdmin[msg.sender] != true)
        require((msg.sender == MainWallet)||(msg.sender == StakingWallet)||(msg.sender == WorkHelperWallet));
        _;
    }
    
    modifier onlyMain() {
      require((msg.sender == MainWallet)||(msg.sender == StakingWallet));
      _;
   }    
   
    modifier LockedafterLaunch() {
      require(_isLaunched == false);
      _;
   }
       modifier CheckforWork() {
      
      _;
      if(_AutoCalcRewards == true)
      doWork(NextTask);
   }
    //@@@ function replaced to retrieve gas to main wallet for contract running costs each time 0.1bnb is collected - more efficient
       modifier RefundGas() {
           
        _;   
        if(GasPotBNB>100000000000000000) //0.1 bnb
        {
        uint tempPot = GasPotBNB;
        GasPotBNB = 0;
        if(SendBNBfromContract(tempPot, MainWallet)==false) //transaction failed
        GasPotBNB += tempPot; // put funds back in pot to try again next time
        }
        
    }
    
//IMPORTANT 
//call StartLaunch() after adding liquidity to LP to enable tax and transfers and renounce control of sensitive functions

function StartLaunch() public onlyMain() LockedafterLaunch(){ //cannot be undone

          launch_time = block.timestamp;
          LastRewardCalculationTime = 0; 
          _enableTax = true; 
          Buyback_increment = 50; //first increment after launch
          NextBuybackMemberCount = N_holders + Buyback_increment;
          _isLaunched = true;
          _enableTransfer = true;
          _AutoCalcRewards = true;
          
          emit TOKEN_LAUNCHED(); //LETS GO!!!
        }
function ToggleTransfers() public onlyMain() LockedafterLaunch(){
         _enableTransfer = !_enableTransfer;// cannot disable transfers after launch 
        }
function setStakingOwnership(address newStakeOwner) public onlyMain(){// For setting new stake handling contract
        StakingWallet = newStakeOwner;
        _excludedfromTax[StakingWallet] = true;
        _isregistered[StakingWallet] = true;
    } 
    
    //sets wallet with admin privelage for automation in the future
    function setWorkHelper(address newWorkHelper) public onlyMain(){
        WorkHelperWallet = newWorkHelper;
        _excludedfromTax[WorkHelperWallet] = true;
        _isregistered[WorkHelperWallet] = true;
    } 
   
    //TestNet    
  //  address constant routerAddress=0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    
    //MainNet
    address constant routerAddress=0x10ED43C718714eb63d5aA57B78B54704E256024E;
   
    IPancakeRouter02 private _pancakeRouter;
    address public _pancakePairAddress;
    address public MainWallet; //address of the wallet that controls the contract
     address public WorkHelperWallet; //address of the wallet used for automating tasks in the future. Has admin privelages
    
    constructor() {
        N_perTransfer = 3;  //number of reward calculations
        N_payoutsperWorkRound = 1;  //@@@ number of payouts per dapp interaction
        nonce = 1;
        burnUntil = initialSupply/8; //burns up to  87.5% initial supply 10b/8=1250000000
        _maxTxAmount = __totalSupply * 1/100; //1% of total supply
        UpdateRegister(address(0),true);
         UpdateRegister(address(0x000000000000000000000000000000000000dEaD),true);
        _enableTransfer = true; //default

          MainWallet = msg.sender;
          WorkHelperWallet = msg.sender;
          UpdateRegister(MainWallet,true);
        __balanceOf[MainWallet] = __totalSupply;  
        Contract = address(this);
        
        //Add to [email protected]@@
     //   UpdateRegister(0xb285B4a0EDCF9E13aBDd0a1Fad10832339Cd1D8f, false);
     //   _isMod[0xb285B4a0EDCF9E13aBDd0a1Fad10832339Cd1D8f] = true;
     //   N_Mods++;
     //   ModList.push(0xb285B4a0EDCF9E13aBDd0a1Fad10832339Cd1D8f);

        UpdateRegister(address(this),true);
        
//        __balanceOf[address(this)] = __totalSupply/2;

        StakingWallet = msg.sender;
        UpdateRegister(StakingWallet,true);
       // RafflePot = initialSupply * 2 / 100; // 2% reserved in raffle pot to send airdrops to promotion winners and partnerships @@@

        _pancakeRouter = IPancakeRouter02(routerAddress);
        _pancakePairAddress = IPancakeFactory(_pancakeRouter.factory()).createPair(address(this), _pancakeRouter.WETH());
         UpdateRegister(_pancakePairAddress,false);
      //  AutoLiquidity = true;

     //launch_time = block.timestamp;  //now as default - used for tax calculation
   AddTokentoPayoutList(_pancakeRouter.WETH(), "BNB"); //BNB added as default
   AddTokentoPayoutList(address(this), "SATROK"); //this contract token
   AddTokentoPayoutList(address(0x17Bd2E09fA4585c15749F40bb32a6e3dB58522bA), "ETHFIN"); //Main contract token
   }

 
    function totalSupply() public view override returns (uint _totalSupply) {
        _totalSupply = __totalSupply;
    }

    //returns the balance of a specific address
    function balanceOf(address _addr) public view override returns (uint balance) {
        return __balanceOf[_addr];
    }
    

    //transfer an amount of tokens to another address.  The transfer needs to be >0 
    //does the msg.sender have enough tokens to forfill the transfer
    //decrease the balance of the sender and increase the balance of the to address
    function transfer(address _to, uint _value) public override returns (bool success) {
       require(_value > 0 && _value <= balanceOf(msg.sender)); 
       
        UpdateRegister(_to, false);

            _transferWithTax(msg.sender, _to, _value);

            return true;
        
    }

 //contract addresses are as default excluded from auto payouts of rewards and have
 //to be enabled manually otherwise accumilated rewards are redistributed after 6 months
	function isContract(address account) private view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
	}
   
//function called when a new address is sent tokens
  function UpdateRegister(address recipient, bool ExcludedfromTax) private
   {
        if(_isregistered[recipient] == false)  
        {investorList.push(recipient); //add new holder to list
        _isregistered[recipient] = true;
        _LastPayout[recipient] = block.timestamp;
        
        if(!isContract(recipient))
        _AutoPayoutEnabled[recipient] = true; // only human holders get payed auto rewards as default
         N_holders++;
         _excludedfromTax[recipient] = ExcludedfromTax;
         
         _SplitTokenRewards[recipient] = true;
         _RewardTokens[recipient].Slice1 = 50; //default 25% bnb
         _RewardTokens[recipient].Slice2 = 50; //25% Native Currency
         _RewardTokens[recipient].Token1 = 1; 
         _RewardTokens[recipient].Token2 = 2;
         

        }
   }
   
 /*  function isModerator(address addr) public view returns (bool)
   {
       return _isMod[addr];
   }
 */  
   function isExcludedfromTax(address addr) public view returns (bool)
   {
       return _excludedfromTax[addr];
   }
   
   function addtoAdminList(address addr) public onlyMain() LockedafterLaunch()
    {
        if(_isAdmin[addr] == false)
        {
            if(_isregistered[addr] == false) 
            UpdateRegister(addr, false);
        
        _isAdmin[addr] = true;
        N_Admin++;
        AdminList.push(addr);
        }
    }
    
    //function to manually extract Staking and admin funds incase needed
   function PayTeam() public onlyAdmin()
   {
       _PayTeam();
   }

    //Function to distribute Staking funds and  'salaries' to team members
    //it is called once every reward calculation cycle
    function _PayTeam() private {
    
        if(SendBNBfromContract(StakingBNB, StakingWallet)==true) 
        StakingBNB = 0;
        {//admin
        
        uint256 L = AdminList.length;
         if((L>0)&&(AdminPotBNB > 0))
           { uint256 Adminshare = AdminPotBNB / N_Admin;
              AdminPotBNB = 0;
            for(uint32 pos = 0 ; pos < L; pos++)
             if(_isAdmin[AdminList[pos]])
                SendBNBfromContract(Adminshare, AdminList[pos]);
          }
        }
        //mod
       /* {
        
         uint256 L = ModList.length;
         if((L>0)&&(ModPotBNB > 0))
           { uint256 Modshare = ModPotBNB / N_Mods;
              ModPotBNB = 0;
            for(uint32 pos = 0 ; pos < L; pos++)
             if(_isMod[ModList[pos]])
                SendBNBfromContract(Modshare, ModList[pos]);
           }
        
        }*/
}

  
    //This function is used to temporarily exclude addresses from tax
    //for partnership purposes, such as airdrops
    //or for trading the token on other exchanges, expanding the reward system after launch using bridge contracts etc.
       function ExcludefromTax(address addr) public onlyMain()
    {
            if(_isregistered[addr] == false) 
            UpdateRegister(addr, true);
            else
            _excludedfromTax[addr] = true;
    }  
   
       function UndoExcludefromTax(address addr) public onlyMain()
    { 
            if(_isregistered[addr] == false) 
            UpdateRegister(addr, false);
            else
            _excludedfromTax[addr] = false;
    } 
    
      function setMainWallet(address addr) public onlyMain()
       {  
          if(MainWallet != address(0))
          _excludedfromTax[MainWallet] = false;
          MainWallet = addr; 
          if(_isregistered[addr] == false) 
            UpdateRegister(addr, true);
            else _excludedfromTax[addr] = true;
          
       }

// This function is to enable or disable automatic calculation and distribution of payouts
// in the event that a newly added reward token fails to transfer or similar isues arise,
//temporarily disabling _AutoCalcRewards allows functions to be called without problem until the issue is resolved,
//after which _AutoCalcRewards can be. enabled again.
           function setAutoCalcRewards(bool isactive) public onlyMain()
       {  
          _AutoCalcRewards = isactive;
       }

    //this allows someone else (a 3rd party) to transfer from my wallet to someone elses wallet
    //If the 3rd party has an allowance of >0 
    //and the value to transfer is >0 
    //and the allowance is >= the value of the transfer
    //and it is not a contract
    //perform the transfer by increasing the to account and decreasing the from accounts
    function transferFrom(address _from, address _to, uint _value) public override returns (bool success) {
        
        UpdateRegister(_to, false);
        require(__allowances[_from][msg.sender] > 0 &&
            _value > 0 &&
            __allowances[_from][msg.sender] >= _value
               ); 
                  
            _transferWithTax(_from, _to, _value);
        
        return true;
    }


    function _transferWithTax(address sender, address recipient, uint256 amount) private {
        require(sender != address(0));
      bool TaxFree;
       if((_excludedfromTax[sender])||(_excludedfromTax[msg.sender])||(!_enableTax)||(_excludedfromTax[recipient]))
       TaxFree = true;
       
       if(SingleUntaxedTransfer)
       {
           TaxFree = true;
           SingleUntaxedTransfer = false; //resets state flag
       }
    /*
    Different tax rates are applied to buy/transfer transactions and sell transactions.
    Buy tax is fixed at 10% and sell tax is time variable starting very high, 90% in the first minute,
    then below 49% and slowly decreasing down to 15%. Since a transfer tax above 30% can make sell transactions
    on pancakeswap fail, the portion of tax larger than 30% is taken from the seller balance in addition to the amount
    of tokens being sold. This overcomes the pancakeswap slippage limitation and also functions as an anti-dump mechanism. 
    During this inital period of high sell tax, one cannot sell all tokens in a sigle transcation without compensating
    for the additional tax above 30%. 
    
    So the following happens:
    Sell tax        Of which additional tax     Holder tokens sellable in 1 transaction
    90%             60%                         40%   
    48%             18%                         82%   
    40%             10%                         90%   
    35%             5%                         95%   
    30%             0%                         100%   
    25%             0%                         100%   
    20%             0%                         100%  
    17%             0%                         100% 
    15%             0%                         100% 
    
    In other words, in the most extreme case, if a holder sells 40% of his token balance during the first minute,
    his remaining token balance will be zero. If the sell amount is larger than this, the transaction will revert.
    */
       
       //transfer should be taxed and some work performed
       if(!TaxFree)
       {  uint256 TaxTokens;
          uint256 AdditionalTax;
       require(amount<=_maxTxAmount);
         if((recipient==_pancakePairAddress))                   //sell
           { SellSlippage = getSellSlippage();
             if(SellSlippage>30) //sell tax portion higher than 30% is sent seperately 
             {
                 TaxTokens = amount*30/100;
                 AdditionalTax = amount*(SellSlippage-30)/100; //
             }
             else
               TaxTokens = amount*SellSlippage/100;

               _transfer(sender, Contract, amount+AdditionalTax);
               _transfer(Contract, recipient, amount - TaxTokens);

              SellTaxTokenPot += TaxTokens + AdditionalTax;
             
           }
           else
           {
               TaxTokens = amount * BuyTaxPercentage / 100; //5% buy tax applied to all non-sell transfers

                      _transfer(sender, Contract, amount); //transaction sent to contract
                      
                   // uint winnings = PlayLotto(amount);  
                    // if(winnings>0)
                    //   emit LotteryWon_(recipient, winnings);
                       //  _transfer(Contract, recipient, amount - TaxTokens + winnings); //net amount + winnings sent to recipient
                      _transfer(Contract, recipient, amount - TaxTokens); //net amount sent to recipient
                      
                       BuyTaxTokenPot += TaxTokens;

                      BuyTaxTokenPot += TaxTokens;
                   
                 DistributeBuyTax();
                 DistributeSellTax();
                 
           
                      
                 
           }
           
           if(_AutoCalcRewards) //work moved to other functions due spread gas fees
            {
              if(_CalculatingRewards == true)
             CalculateRewards(N_perTransfer);
            }
            
       }
       else  //no tax due
        _transfer(sender, recipient, amount);
        
        //for reward calculation
        if((_PrevBalance[sender] > __balanceOf[sender])&&(sender != _pancakePairAddress))
          _PrevBalance[sender] = __balanceOf[sender];
          
        if(_isLaunched==false) //for presale buyers
         _PrevBalance[recipient] += amount;
    }
 
  function _transfer(address sender, address recipient, uint256 amount) internal virtual {  
     uint256 senderBalance = __balanceOf[sender];
     
         if(sender==address(this))
         require(senderBalance >= amount + getReservedTokens()); //reserved tokens are excluded from contract balance 
         else
         require(senderBalance >= amount);
       
        require((_enableTransfer)||(_excludedfromTax[sender])); 

         if(sender==_pancakePairAddress)
          require(_isLaunched==true);   //buy transactions disabled until launch

        
        unchecked {
            __balanceOf[sender] = senderBalance - amount;
        }
        __balanceOf[recipient] += amount;
        
         emit Transfer(sender, recipient, amount);

  }
  
function DistributeSellTax() private
{   //payouts
        //35% lq to pancake lq 
        //50% holder BNB
        //6% promo BNB
        //1% airdrop token
        //2% lottery token
        //4% admin in bnb
        //2% mod in bnb
        
        /*@@@
        SELL TAX DISTRIBUTION  
        35% lq to pancake lq => 35% lq to mainwallet in BNB
        50% holder BNB => 50%
        6% Staking BNB => 9%
        1% airdrop token => 0%
        2% lottery token => 0%
        4% admin in bnb => 6%
        2% mod in bnb => 0%
        */
    if(SellTaxBNBPot>10000)  //skip if pot is empty
    {
        //REMOVED ******
          //since the remaining 79.5% is converted to bnb, the calculation percentages need to be normalized.
      //40% total tax * 100/79.5    = 50.31 % bnb tax portion @@@
      //17.5% total tax * 100/79.5  = 22.01 % bnb tax portion
      //16% total tax * 100/79.5     = 20.13 % bnb tax portion @@@
      //4% total tax * 100/79.5     = 5.03 % bnb tax portion
      //2% total tax * 100/79.5     = 2.52 % bnb tax portion
                            //      +=> 100% bnb tax portion  
     // *****************                      
                     //bnbfromTax = BalanceBNB - bnbfromTax; 
         //50% holder BNB @@@
            HolderPotBNB += SellTaxBNBPot * 40 / 100;  //adds to holder reward pot
     
       //19% staking BNB   @@@
            StakingBNB += SellTaxBNBPot * 19 / 100;
             
         //6% admin in bnb      
            AdminPotBNB += SellTaxBNBPot * 6 / 100;
        
        //0% mod in bnb     
          //  ModPotBNB += SellTaxBNBPot * 252 / 10000;
        
            //35% lq to pancake lq 
     {       
          //  netamount -= LQTax;
     LQPotBNB += SellTaxBNBPot * 35 / 100; //  liquidity tax converted to BNB
     SellTaxBNBPot = 0; //all tax distributed
     }
      }        
   
}
/*
function addLiquidityFromContract(uint256 TKN, uint256 BNB, bool fromLQpool) public onlyMain()
{ 
    if(fromLQpool)
    sendLiquidity();
    else{
        require(!_isLaunched);
        _addLiquidityFromContract(TKN, BNB);
    }
}
*/

function sendLiquidity() private returns (bool)
{
      /*      if((LQPotToken > 100000000)&&(LQPotBNB>=1000000000000000000)) // transfer at least 1 [email protected]@@
            {
            (uint TKN, uint BNB) = _addLiquidityFromContract(LQPotToken, LQPotBNB); //sends tokens from contract along with LQ tax
              if(TKN>0) // LQ transfer successful
               {
                   LQPotToken -= TKN;
                   LQPotBNB -= BNB;
               }
            }   
            return true;
       */   
       if((LQPotBNB>=100000000000000000)) // transfer at least 0.1 bnb
            {  uint BNBs = LQPotBNB;
                 LQPotBNB = 0;
                  if(!SendBNBfromContract(LQPotBNB,MainWallet)) //sends BNB to main wallet for manual liquidity injection
                   LQPotBNB = BNBs; //if transfer failed, try again next time
            }   
            return true;  
}


/* 
BUY TAX DISTRIBUTION
10% Gas costs => 14%
30% Buyback and Burn
35% holders in bnb  => 40%
19% Staking bnb =>10%
4% admin in bnb => 6%
2% mods in bnb => 0%
*/

function DistributeBuyTax() internal
{
     if(BuyTaxBNBPot>100)
     {
        //30% buybackpot
        BuybackPotBNB += BuyTaxBNBPot * 30 / 100;
        
        //10% ges fees => 14%
        GasPotBNB += BuyTaxBNBPot * 14 / 100; //1% goes to gas fees
        
        //35% holders in bnb => 40%
        HolderPotBNB += BuyTaxBNBPot * 40 / 100;
        
        //19% Staking bnb =>10%
        
         StakingBNB += BuyTaxBNBPot * 10 / 100;

        //4% admin in bnb => 6%
        
        AdminPotBNB += BuyTaxBNBPot * 6 / 100;
        
        //2% mods in bnb => 0%
        
       // ModPotBNB += BuyTaxBNBPot * 2 / 100;
        BuyTaxBNBPot = 0;
     }    
}

//public function to help accelerate auto calculations if required
function WorkHelper(uint32 shifts) public onlyAdmin() RefundGas()
{ NextTask = 0;
  for(uint32 i = 0; i < shifts; i++)    
  doWork(NextTask);
}

/////////////functions to mine tokens in exchange for work
uint256 public MinerRate;
uint256 public MinerTokenPot;
uint256 public TotalTokensMined;

//set true or false
bool public MineJob1Enabled = true; //Mine for Taxes
bool public MineJob2Enabled = true; //Mine for reward calculation
bool public MineJob3Enabled = true; //Mine for reward distribution
bool public MineJob4Enabled = true; //mine for buyback

function updateMinerWorkload(bool MineforTaxes, bool MineforRewardCalc, 
            bool MineforRewardDistr,bool MineforBuyback) public onlyMain()
{
    MineJob1Enabled = MineforTaxes;
    MineJob2Enabled = MineforRewardCalc;
    MineJob3Enabled = MineforRewardDistr;
    MineJob4Enabled = MineforBuyback;
}            

//remember to add the decimals
function FundMinerPot(uint256 TokenAmount) public onlyMain()
{
 require(__balanceOf[msg.sender] >= TokenAmount,"Insufficient token balance");
   __balanceOf[msg.sender] -=  TokenAmount;
   MinerTokenPot += TokenAmount;
   emit Transfer(msg.sender, address(this), TokenAmount);
}

function RecoverTokensfromMinerPot(uint256 TokenAmount) public onlyMain()
{
 require(MinerTokenPot >= TokenAmount);
   MinerTokenPot -= TokenAmount;
   __balanceOf[msg.sender] +=  TokenAmount;
   
   emit Transfer(address(this), msg.sender, TokenAmount);
}
//remember to add the decimals
function updateMinerRate(uint256 TokenAmount) public onlyMain()
{
   MinerRate = TokenAmount; 
}

//public function to mine tokens by doing work
function MineTokens() public
{
  require(MinerTokenPot > MinerRate, "No mining jobs available. Check back soon!");
  if(MineJob1Enabled)
   doWork(0);
  if(MineJob2Enabled)
   doWork(1);
  if(MineJob3Enabled)
   doWork(2);
  if(MineJob4Enabled)
   doWork(3);   

    MinerTokenPot -= MinerRate;
    __balanceOf[msg.sender] += MinerRate;
    emit Transfer(address(this), msg.sender, MinerRate);

 TotalTokensMined += MinerRate;
}
/////////////functions to mine tokens in exchange for work

function doWork(uint32 task) private RefundGas()
{ //work split between transfers and tasks
    if(task == 0)
    {
       //convert tax to bnb and distribute to tax pots
       _swapTaxTokenForBNB(_maxTxAmount,_maxTxAmount); //swap accumilated tax tokens to bnb up to _maxTxAmount   
       DistributeBuyTax;
       DistributeSellTax;

     sendLiquidity();    
 
    }
    
    if(task == 1)
    {//calculateNrewards
     if(_CalculatingRewards == true)
       CalculateRewards(N_perTransfer);//calculate some rewards 
       else
       {
        if(block.timestamp - LastRewardCalculationTime > 3600) //@@@ restart 1 hour after previous round ends
            if(HolderPotBNB >= 500000000000000000) //wait until at least 0.5 bnb in rewards have been accumilated 
            _StartRewardCalculation(); //can also be triggered manually by main wallet
             task = 2; // do some payouts instead
       }
       
    }
    
    if(task == 2)
    {//payoutNrewards
       _DistributeRewards(N_payoutsperWorkRound);//pay out some rewards   //@@@ changed from N_perTransfer to split the two values  
    }
    
    if(task >= 3)
    {//checkrestart reward calculation
      // if(AirdropPayout()==false) //checks if its time for next airdrop and does it, otherwhise dobuyback //PUT BACK
          doBuyback();
    }
    
    NextTask ++; 
    if(NextTask>3)  //max number of tasks
    NextTask = 0; //restart task number
}

function updateTaxRates(uint256 newBuyTax, uint32 newSellTax) public onlyMain()
{
    require(newBuyTax+newSellTax <= 49,"total tax cannot exceed 49%");
    BuyTaxPercentage = newBuyTax;
    SellTaxPercentage = newSellTax;
}


   function getSellSlippage() public view virtual returns (uint32) 
   {
        uint256 current_time = block.timestamp; 
    if(_isLaunched==true) 
    {  
        
        if(current_time >= launch_time + 3628800)     //after 6 Week
       return 5; 
       else
        if(current_time >= launch_time + 3024000)     //after 5 Week
       return 10; 
       else
       if(current_time >= launch_time + 2419200)     //after 4 Week
       return 15; 
       else
       if(current_time >= launch_time + 1814400)     //after 3 Week
       return 25; 
       else
        if(current_time >= launch_time + 1209600)     //after 2 Week
       return 50; 
       else
        if(current_time >= launch_time + 604800)     //after 1 Week
       return 55; 
       else
       if(current_time >= launch_time + 86400)     //after 24 hours
       return 65; 
       else
       if(current_time >= launch_time + 14400)     //after 4 hours
       return 75; 
       else
       if(current_time >= launch_time + 3600)     //after 1 hours
       return 80; 
       else
       if(current_time >= launch_time + 60)     //after 1 min
       return 85; 
       else 
       return 90; //first minute 
    }
    else
       return 0; // - sell not possible before launch
       }
function checkRewards(address addr) public view returns (uint256)
{
   return _earnings[addr];
}
   //allows a spender address to spend a specific amount of value
    function approve(address _spender, uint _value) external override returns (bool success) {
        __allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
        //allows a spender address to spend a specific amount of value
    function _approveMore(address _owner, address _spender, uint _value) internal returns (bool success) {
        uint256 old = __allowances[_owner][_spender];
        __allowances[_owner][_spender] += _value;
        emit Approval(_owner, _spender, old + _value);
        return true;
    }
    


    //shows how much a spender has the approval to spend to a specific address
    function allowance(address _owner, address _spender) external override view returns (uint remaining) {
        return __allowances[_owner][_spender];
    }


    receive () external payable {
    } // fallback to receive bnb
    
function ReservesBNB() public view returns (uint256)
{
    return address(this).balance;
}

function ReservesToken() public view returns (uint256)
{
    return __balanceOf[address(this)];
}

    
    //Adds Liquidity directly to the contract where LP are locked
    function _addLiquidityFromContract(uint256 tokenamount, uint256 bnbamount) private returns (uint, uint){
    
      SingleUntaxedTransfer = true;//sets flag
     _approveMore(Contract, address(_pancakeRouter), tokenamount); //test if works for third parties also
       (uint amountToken, uint amountETH, ) = _pancakeRouter.addLiquidityETH{value: bnbamount}(
            Contract,
            tokenamount,
            0,
            0,
            address(0),//liquidity locked permanently
            block.timestamp
        ); 
    SingleUntaxedTransfer = false;
         return (amountToken, amountETH);
    }

function SendBNBfromContract(uint256 amountBNB, address receiver) private returns (bool) 
{
  (bool success, ) = receiver.call{ value: amountBNB }(new bytes(0));

  return success;
}    

//function for converting Bytes to uint[]
function sliceUint(bytes memory bs, uint start)
   public pure//internal pure
    returns (uint)
{
    require(bs.length >= start + 32);
    uint x;
    assembly {
        x := mload(add(bs, add(0x20, start)))
    }
    return x;
}


function swapTaxTokenForBNB(uint256 selltaxamount,uint256 buytaxamount) public onlyMain(){
    _swapTaxTokenForBNB(selltaxamount,buytaxamount);
}


function _swapTaxTokenForBNB(uint256 selltaxamount,uint256 buytaxamount) private returns (bool){
   uint256 total = selltaxamount+buytaxamount;
   uint256 Sell = selltaxamount;
   uint256 Buy = selltaxamount;
   if(selltaxamount>SellTaxTokenPot)
   Sell = SellTaxTokenPot; 
   if(buytaxamount>BuyTaxTokenPot)
   Buy = BuyTaxTokenPot;
   
   
   if(total == 0) //swap all
   {
      Sell = SellTaxTokenPot; 
      Buy = BuyTaxTokenPot;
   }
  
  total = Sell+Buy;
  if(total > 0)
  {
      
      //split sell portion into token and bnb portions
      
      
      BuyTaxTokenPot -= Buy;
      SellTaxTokenPot -= Sell;
      
  
   
  

uint256 bnbs = _swapTokenForBNB(total);

if(bnbs>0)
{
   uint256 buybnbs = bnbs * Buy / total;
   BuyTaxBNBPot += buybnbs;
   SellTaxBNBPot += bnbs - buybnbs;
}
else
{ //swap failed, return tokens to post
   BuyTaxTokenPot += Buy;
  SellTaxTokenPot += Sell;  
}

  }
  SingleUntaxedTransfer = false;
  return true;
}

function _swapTokenForBNB(uint256 tokenamount) private returns (uint256){ 
  if(tokenamount>0)
  {
      
        _approveMore(Contract, address(_pancakeRouter), tokenamount); 

        SingleUntaxedTransfer = true;//sets flag
        address[] memory path = new address[](2);
        path[0] = Contract;
        path[1] = _pancakeRouter.WETH();
        
        (bool success, bytes memory data) = routerAddress.call(abi.encodeWithSelector(
        0x18cbafe5,
        
        tokenamount,
        0,
        path,
        Contract,
        block.timestamp
        )); 

    if(success)
       { uint[] memory amounts = abi.decode(data, (uint[]));

        if(amounts.length>=2)

        return amounts[1];

        }
     }
  SingleUntaxedTransfer = false;
       return 0;
    }
    
    
     
       
//works for receiver != address(this) 
 function _swapBNBforChosenTokenandPayout(uint256 amountBNB,address PayoutTokenContract, address receiver) private returns (bool){

        address[] memory path = new address[](2);
        path[0] = _pancakeRouter.WETH();
        path[1] = PayoutTokenContract;

    try _pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountBNB}(
            0,
            path,
            address(receiver),
            block.timestamp
        )
        {return true;}
        catch {}
   
     
     return false;
    }   



function getFreeBNBs() public view returns (uint256)
{
  uint256 reservedBNBs = LQPotBNB + BuybackPotBNB + HolderPotBNB + AdminPotBNB;
  reservedBNBs += StakingBNB + SellTaxBNBPot + BuyTaxBNBPot + GasPotBNB + claimableBNBearnings;
  return address(this).balance - reservedBNBs;
}

//extra funds can also be sent and distributed
//use with caution. To recover BNB sent to contract without allocation 
function addBNBtoHolderPot(uint256 amountbnb) public onlyMain()
{ 
  require(amountbnb <= getFreeBNBs());
   HolderPotBNB += amountbnb;
}

function addBNBtoGasPot(uint256 amountbnb) public onlyMain()
{ 
  require(amountbnb <= getFreeBNBs());
   GasPotBNB += amountbnb;
}
///

function manualBuyBackTokens(uint amountBNB) public onlyMain()
{
    require(amountBNB <= BuybackPotBNB,"Insufficient buyback balance");
     _buyBackTokens(amountBNB);
}

// buyback tokens and send to wallet address using main wallet to avoid invalid to address error in pancakeswap
function _buyBackTokens(uint256 amountBNB) private returns (uint256){  
    
     address[] memory path = new address[](2);
        path[0] = _pancakeRouter.WETH();
        path[1] = Contract;

       SingleUntaxedTransfer = true;
     uint[] memory amounts = _pancakeRouter.swapExactETHForTokens{value: amountBNB}(
            0,
            path,
            MainWallet, //avoids "Invalid TO" error from pancakeswap (cannot swap for native tokens to contract address)
            block.timestamp
        );
        uint256 TOKENS;
       if(amounts[1]>0)
       {
         if(__balanceOf[MainWallet]>=amounts[1])
            TOKENS = amounts[1];  
         else  
            TOKENS = __balanceOf[MainWallet];  //catch for if price turns out lower than expected
       
           
           _transfer(MainWallet, address(this), TOKENS); //sends balance back to contract

           if((__totalSupply - TOKENS > burnUntil))
           _burn(address(this), TOKENS );
           return TOKENS;
       }
       SingleUntaxedTransfer = false;
     return 0;
}
  
        function getPromotedRewardTokenoftheWeek() public view returns(string memory){

        return PayoutTokenListNames[RewardTokenoftheWeek];
    } 
    

function burnbeforeLaunch(uint256 tokens) public onlyMain() LockedafterLaunch()
{ 
  require(__balanceOf[address(this)] >= tokens);
  _burn(address(this), tokens);
    
}

function _burn(address account, uint256 amount) internal virtual {
       require(account != address(0));
       if(__totalSupply > burnUntil)
       if(__totalSupply > amount)
       { if(__totalSupply - amount < burnUntil)
           amount = __totalSupply - burnUntil;
        address deadwallet = address(0x000000000000000000000000000000000000dEaD);
        

        if(__balanceOf[account] >= amount)
        {
        unchecked {
            __balanceOf[account] -= amount;
        }
        __totalSupply -= amount;
       
        emit Transfer(account, deadwallet, amount);
        emit TokensBurned(amount);
        }
    }
  }


        function AddTokentoPayoutList(address TokenAddress, string memory Name) public onlyMain() {
        
       PayoutTokenList.push(TokenAddress);
        PayoutTokenListNames.push(Name);
        NumberofPayoutTokens++;
    }

//if a payout token has to be updated
        function EditPayoutList(uint32 pos, address TokenAddress, string memory Name) public onlyMain(){
        
        require(pos < NumberofPayoutTokens);
        PayoutTokenList[pos] = TokenAddress;
        PayoutTokenListNames[pos] = Name;
        
    }
    
//returns the reward token selection of the caller    
function ShowMyRewardTOKENS() public view returns (uint32[6] memory tokennumbers){
    
    
    tokennumbers[0] =   _RewardTokens[msg.sender].Token1;
    tokennumbers[1] =   _RewardTokens[msg.sender].Token2;
    tokennumbers[2] =   _RewardTokens[msg.sender].Token3;
    tokennumbers[3] =   _RewardTokens[msg.sender].Token4;
    tokennumbers[4] =   _RewardTokens[msg.sender].Token5;
    tokennumbers[5] =   _RewardTokens[msg.sender].Token6;
 
return (tokennumbers);
    }
    
//returns the names of all payout tokens    
function ShowAllRewardTokens() public view returns (string[] memory Rewards){ 
return PayoutTokenListNames;
}

//returns the percentage payout settings of the caller
function ShowMyRewardSLICES() public view returns (uint32[6] memory slices){
    
    
    slices[0] =   _RewardTokens[msg.sender].Slice1; //percentage
    slices[1] =   _RewardTokens[msg.sender].Slice2;
    slices[2] =   _RewardTokens[msg.sender].Slice3;
    slices[3] =   _RewardTokens[msg.sender].Slice4;
    slices[4] =   _RewardTokens[msg.sender].Slice5;
    slices[5] =   _RewardTokens[msg.sender].Slice6;
    
return (slices);
    }    

    function ChooseSinglePayoutToken(uint32 PayoutTokenNumber) public CheckforWork() {
        require(PayoutTokenNumber < NumberofPayoutTokens);
        _RewardTokens[msg.sender].Token1 = PayoutTokenNumber;
        _RewardTokens[msg.sender].Slice1 = 100;
        _SplitTokenRewards[msg.sender] = false;
    }
       //token numbers + percentage slice
        function ChooseMultiplePayoutTokens(uint32 Token1,uint32 Slice1,uint32 Token2,uint32 Slice2,
                                            uint32 Token3,uint32 Slice3,uint32 Token4,uint32 Slice4,
                                            uint32 Token5,uint32 Slice5,uint32 Token6,uint32 Slice6) public CheckforWork() {
       
     //   require((Token1 > 0)||(Token2 > 0)||(Token3 > 0)||(Token4 > 0)||(Token5 > 0)||(Token6 > 0)||, "No tokens selected");
        uint32 Whole = Slice1+Slice2+Slice3;
        Whole += Slice4+Slice5+Slice6;
        require(Whole > 0);
       
       uint32 N = uint32(NumberofPayoutTokens);
       bool OutofBounds = ((Token1 >= N)||(Token2 >= N)||(Token3 >= N)||(Token4 >= N)||(Token5 >= N)||(Token6 >= N));
        require(OutofBounds == false);
       _RewardTokens[msg.sender].Token1 = Token1;
       _RewardTokens[msg.sender].Token2 = Token2;
       _RewardTokens[msg.sender].Token3 = Token3;
       _RewardTokens[msg.sender].Token4 = Token4;
       _RewardTokens[msg.sender].Token5 = Token5;
       _RewardTokens[msg.sender].Token6 = Token6;
        _RewardTokens[msg.sender].Slice1 = Slice1;
        _RewardTokens[msg.sender].Slice2 = Slice2;
        _RewardTokens[msg.sender].Slice3 = Slice3;
        _RewardTokens[msg.sender].Slice4 = Slice4;
        _RewardTokens[msg.sender].Slice5 = Slice5;
        _RewardTokens[msg.sender].Slice6 = Slice6;
        
        _SplitTokenRewards[msg.sender] = true;
       
    }

function StartRewardCalculation() public onlyMain()
{  require(HolderPotBNB > 0);
    _StartRewardCalculation();
}

function _StartRewardCalculation() private {
   if((_CalculatingRewards == false)&&(HolderPotBNB > 0))
   {
   HolderPotBNBcalc = HolderPotBNB; //used as reference for calculation
   AdminPotBNBcalc =  AdminPotBNB;
 //  ModPotBNBcalc = ModPotBNB;
   CircSupplycalc = __totalSupply - __balanceOf[address(this)] - __balanceOf[_pancakePairAddress] - __balanceOf[routerAddress]; //circulating supply
   Rewardcycle++; //counter to keep track of rewards earned. next cycle starts when all rewards have been paid out
   _CalculatingRewards = true;
   //LastRewardCalculationTime = block.timestamp;
   _PayTeam();
   }
   
}

function CalculateNRewards(uint32 counts) public onlyAdmin() RefundGas(){
  // function calculates rewards 
  require(_CalculatingRewards == true);
  if(counts > 0)
   CalculateRewards(counts); 
}

function setNperTransfer(uint32 N) public onlyMain(){
    require(N<8);
    N_perTransfer = N;
}

function setNpayoutsperWorkRound(uint32 N) public onlyMain(){ //@@@ added
    require(N<8);
    N_payoutsperWorkRound = N;
}

function CalculateRewards(uint32 counts) private returns (bool){
         /////calculate reward for holders
   if(counts > 0)
   {   
    uint32 maxtries = counts * 3;  
    uint32 currenttry;
    uint32 N_calculated;
         
        if((CircSupplycalc>0)&&(HolderPotBNBcalc>0))//safety check
        {
        
        //for (uint256 k = startpos; k < stoppos; k++)
        while((_CalculatingRewards == true)&&(currenttry<maxtries))
         { address holder = investorList[HolderPos];

         if(_CalculateSpecificReward(holder))
         N_calculated++; 
         
         currenttry++;
         HolderPos++;
         
         if(N_calculated >= counts)
          currenttry = maxtries; //enough rewards calculated
         
         
         if(HolderPos >= N_holders) //all rewards for this cycle have been calculated
           {HolderPos = 0;
           HolderPotBNBcalc = 0;
         
           _CalculatingRewards = false;  //all rewards calculated
           LastRewardCalculationTime = block.timestamp;
            emit RewardsRecalculated();
           }
         }
        // HolderPotBNB += Pot; //earnings distributed
         return true;
    }
   }
     return false;
   }

function _CalculateSpecificReward(address holder) private returns (bool)
{      
             if((_excludedfromTax[holder]==false)&&(_LastRewardCycle[holder]<Rewardcycle)) //check if holder has not manually claimed within the current reward cycle
         if(holder !=_pancakePairAddress&&(holder !=routerAddress))  //excluded
         {  _LastRewardCycle[holder] = Rewardcycle; 
            uint256 bal = _PrevBalance[holder]; 
            if(__balanceOf[holder]<bal)  
              bal = __balanceOf[holder]; //only rewarded for tokens held for the full period
              
              _PrevBalance[holder] = __balanceOf[holder]; //balance set for next reward cycle calculation
              
            uint256 NewEarnings = HolderPotBNBcalc * bal / CircSupplycalc; 
            if(NewEarnings <= HolderPotBNB) //safety check, should always be true
            {
            HolderPotBNB -= NewEarnings;  
            claimableBNBearnings += NewEarnings;
             _earnings[holder] += NewEarnings;
            
            }
           
             return true; //reward distributed
           
         } 
         return false; //no rewards to distribute
}

function getReservedTokens() private view returns (uint256 reserves)
{
    reserves = BuyTaxTokenPot + SellTaxTokenPot + LQPotToken;
    return reserves;

}

//allows caller to claim all accumilated earnings in the payout token of choice
function ClaimMyRewards() public CheckforWork()
{ 
_CalculateSpecificReward(msg.sender);  //check for any unprocessed rewards  
require(_earnings[msg.sender] > 0, "All rewards claimed");
require(__balanceOf[msg.sender] > 0);

    ClaimRewards(msg.sender);
}

function setMyAutoPayout(bool Checked) public CheckforWork() returns (bool)
{
    _AutoPayoutEnabled[msg.sender] = Checked;
    return _AutoPayoutEnabled[msg.sender];
}

function getMyAutoPayoutisActive() public view returns (bool)
{
    return _AutoPayoutEnabled[msg.sender];
}

//manually speed up reward distribution
function DistributeRewards(uint32 count)  public onlyAdmin() RefundGas()
{
        _DistributeRewards(count);
}


//auto reward payout 
function _DistributeRewards(uint32 count) private
{   uint32 runs;
    uint32 tries;
    uint32 maxtries = count * 2; 
    uint256 current_time = block.timestamp;
   
    while(runs < count)
   { tries++;
     if(tries >= maxtries)
      runs = count; //quit loop
    address recipient = investorList[DistHolderPos];
    /*
    if(_AutoPayoutEnabled[recipient])  
    {   
        if(current_time - _LastPayout[recipient] > 3600)// last claimed 1h ago   @@@
          ClaimRewards(recipient); //this function checks that rewards and balance of recipient > 0 and rewards
    }
    */
   
    if(_earnings[recipient] > 10000)
    {
    if(current_time - _LastPayout[recipient] > 15552000) //last claimed more than 180 days ago = dead wallet, rewards redistributed
          {  
              _LastPayout[recipient] = current_time;
              uint256 temp = _earnings[recipient];
              _earnings[recipient] = 0;
              HolderPotBNB += temp;
          }
     else
    {
       if(_AutoPayoutEnabled[recipient])  
    {   
        if(current_time - _LastPayout[recipient] > 3600)// last claimed 1h ago   @@@
          ClaimRewards(recipient); //this function checks that rewards and balance of recipient > 0 and rewards
    }
    }
    }

    runs++;
    DistHolderPos++;
    if(DistHolderPos >= N_holders)
     {
     DistHolderPos = 0; //restart list
     runs = count; //quit loop
     }
    }
}
//only runs when earnings is greater than 0.001 BNB
function ClaimRewards(address receiver) private returns(bool){
  if((_earnings[receiver] > 1000000000000000)&&(__balanceOf[receiver] > 0))
  {  _LastPayout[receiver] = block.timestamp;
      uint256 amountBNB = _earnings[receiver];
     uint256 dist = amountBNB;
     claimableBNBearnings -= amountBNB;
     _earnings[receiver] = 0; //reentrancy guard


    if(_SplitTokenRewards[receiver] == false)
    { //single token reward
    address PayoutTokenContract = PayoutTokenList[_RewardTokens[receiver].Token1];
     if(PayoutTokenContract == _pancakeRouter.WETH()) //payout bnb
     {
         
       if(SendBNBfromContract(amountBNB, receiver))
        {   
          // distributed += amountBNB;
           amountBNB = 0;
        }
     }
       else
     { 
         if(PayoutTokenContract == address(this)) //native token
          SingleUntaxedTransfer = true;
        if(_swapBNBforChosenTokenandPayout(amountBNB,PayoutTokenContract,receiver))
    { 
     amountBNB = 0;
    }
     }
    }
    else
    { //Split token rewards
    
      address PayoutTokenContract;
       uint32 pie;
       uint32 percslice;
      
      uint32[6] memory tokennumbers;
      uint32[6] memory slices;
      
    tokennumbers[0] =   _RewardTokens[receiver].Token1;
    tokennumbers[1] =   _RewardTokens[receiver].Token2;
    tokennumbers[2] =   _RewardTokens[receiver].Token3;
    tokennumbers[3] =   _RewardTokens[receiver].Token4;
    tokennumbers[4] =   _RewardTokens[receiver].Token5;
    tokennumbers[5] =   _RewardTokens[receiver].Token6;
    
    slices[0] =   _RewardTokens[receiver].Slice1; //percentage
    slices[1] =   _RewardTokens[receiver].Slice2;
    slices[2] =   _RewardTokens[receiver].Slice3;
    slices[3] =   _RewardTokens[receiver].Slice4;
    slices[4] =   _RewardTokens[receiver].Slice5;
    slices[5] =   _RewardTokens[receiver].Slice6;
      
      uint256 slicevalue = amountBNB / 100; //1%
      for(uint32 i = 0; i < 6; i++)
      {uint256 BNBslice;
       if((slices[i] > 0)&&(pie <= 100))
       {
        percslice = slices[i];  
        if(pie+percslice>100)// check for sneaky percentages
         percslice = 100-pie;
         pie += percslice;
         BNBslice = slicevalue * percslice;
         if(BNBslice>amountBNB)
          BNBslice = amountBNB; //safety check
      PayoutTokenContract = PayoutTokenList[tokennumbers[i]];
      
      if(PayoutTokenContract == _pancakeRouter.WETH()) //payout bnb
    {
       if(SendBNBfromContract(BNBslice, receiver))
          { amountBNB -= BNBslice; 
   
          }
    }
    else
    {   if(PayoutTokenContract == address(this)) //native token
         SingleUntaxedTransfer = true;
      if(_swapBNBforChosenTokenandPayout(BNBslice,PayoutTokenContract,receiver)){ 
       amountBNB -= BNBslice;
  
      }
      }
       }
    }
   }
   _earnings[receiver] = amountBNB; //if anything is still left, it gets refunded to the holder earnings pot
  distributedRewards += BNB2BUSDconverter(dist - amountBNB);
  claimableBNBearnings += amountBNB;  

 }
 return true;
} 

//@@@ BUSD price retriever - choose between testnet and mainnet addresses
function BNB2BUSDconverter(uint256 BNBs) public view returns (uint256)
{
    address[] memory path = new address[](2);
        path[0] = _pancakeRouter.WETH();
        path[1] = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //mainnet BUSD
      // path[1] = address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7); //testnet BUSD
        uint[] memory amounts = _pancakeRouter.getAmountsOut(BNBs, path); //returns (uint[] memory amounts)
        return amounts[1];
}

function MyAvailableRewards() public view returns(uint256){
   
    return _earnings[msg.sender];
}



//Function waits until NextbuybackMember count is reached and then buys back tokens
//The bought tokens are burned until 50% of the inital supply is left
//tokens are first sent to the main wallet, as the pancake pair swap function
//throws an exception when the receiving address is the contract of the native token.
function doBuyback() public returns (bool) //set to private
{
   if((_isLaunched == true)&&(N_holders >= NextBuybackMemberCount)) 
   {
     uint256 amountBNB = BuybackPotBNB * 50 / 100; //max 50% of pot per transaction
      
      uint256 tokens = __balanceOf[MainWallet];

    //burn tokens
    SingleUntaxedTransfer = true;
    BuybackPotBNB -= amountBNB;
    if(_swapBNBforChosenTokenandPayout(amountBNB,address(this),MainWallet)==false) //transaction did not revert
    BuybackPotBNB += amountBNB; //failed put back into pot
    else
    {//success
    
    if(__balanceOf[MainWallet]>tokens)  //netto balance of contract increased
    {
        tokens = __balanceOf[MainWallet] - tokens; //set to difference and burn if required

     _transfer(MainWallet,Contract,tokens);//transfers tokens back to contract address before burning.
     if((__totalSupply - tokens > burnUntil))
        _burn(address(this), tokens);
    }
       emit Buyback_(tokens, N_holders); 
    
     NextBuybackMemberCount = NextBuybackMemberCount + Buyback_increment;
     Buyback_increment = Buyback_increment * 10/100; //wait 10% longer each time
     return true;
    }
   
 }
 return false;

}

}